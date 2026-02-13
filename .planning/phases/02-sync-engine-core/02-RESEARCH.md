# Phase 2: Sync Engine Core - Research

**Researched:** 2026-02-13
**Domain:** Drift (SQLite) transactions, sync queue coalescing, incremental sync, debounced triggers
**Confidence:** HIGH

## Summary

Phase 2 transforms the existing sync engine from a naive full-pull, non-transactional design into an atomic, incremental, coalesced, debounced system. The codebase already has most of the infrastructure in place -- all remote data sources accept `since` parameters, all `syncFromRemote()` repository methods accept `DateTime? since`, the sync queue data source has `hasPendingOperation()`, `removeOperation()`, and `updatePayload()` methods, and Drift v2.22.1 supports `.transaction()` natively. The work is primarily wiring, refactoring, and adding missing orchestration logic rather than building new abstractions.

The four requirements (SYNC-01 through SYNC-04) map cleanly to four separable changes: (1) wrap local-write + queue-insert in Drift transactions across all 8+ repository implementations, (2) store and pass per-entity-type `last_pull_sync_at` timestamps via `AppSettingsService` to all `syncFromRemote()` calls in `SyncNotifier._pullFromRemote()`, (3) fix queue coalescing in `SyncService.queueOperation()` to handle all operation sequences (create+update, create+delete, update+update), and (4) add a debounce timer to `SyncService.triggerSync()` so rapid successive calls batch into a single sync.

**Primary recommendation:** Implement in 4 focused plans (one per requirement), with SYNC-01 (atomic transactions) first since it is the data-integrity foundation, then SYNC-03 (coalescing) since it depends on understanding the queue structure, then SYNC-04 (debouncing) as the simplest isolated change, and finally SYNC-02 (incremental sync) which touches the most files but is lowest risk.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| drift | 2.22.1 | Type-safe SQLite with `.transaction()` support | Already in project; `.transaction()` provides atomic multi-table writes |
| drift_flutter | 0.2.4 | WASM + native SQLite backend | Already in project; handles web and mobile uniformly |
| supabase_flutter | 2.8.3 | Remote backend with `.gte()` filter for incremental pull | Already in project; all remote data sources already accept `since` |
| dartz | 0.10.1 | `Either<Failure, T>` functional error handling | Already in project; used by all repository return types |
| talker | 4.5.2 | Structured logging with module prefixes | Already in project (Phase 1); use for sync debug/timing logs |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_test | SDK | Unit and widget testing | Test each requirement individually |
| mockito | 5.4.4 | Mock generation for tests | Already used in sync_service_test.dart |
| mocktail | 1.0.4 | Lightweight mocking (preferred per CLAUDE.md) | New tests should prefer mocktail |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Drift `.transaction()` | Manual rollback logic | Drift transactions are ACID-compliant, manual rollback is error-prone |
| `AppSettingsService` for timestamps | Dedicated sync_metadata table | AppSettingsService already has `getTableLastSyncAt()`/`setTableLastSyncAt()` -- reuse existing |
| Timer-based debounce | rxdart `debounceTime` | Adding rxdart dependency for one use case is overkill; `Timer` from dart:async is sufficient |
| In-memory coalesce map | Persistent coalesce state | Queue is already persistent in SQLite; coalescing should happen at insertion time in the queue table |

## Architecture Patterns

### Current Repository Write Pattern (BEFORE -- Non-Atomic)
```
Repository.createCustomer():
  1. await _localDataSource.insertCustomer(companion)    // DB write
  2. await _syncService.queueOperation(...)               // Separate DB write
  3. unawaited(_syncService.triggerSync())                 // Fire and forget
```

**Problem:** If app crashes between step 1 and step 2, the customer exists locally but never gets queued for sync. Data is "stuck" -- it appears in the UI but never reaches the server.

### Pattern 1: Atomic Write + Queue (SYNC-01)
**What:** Wrap the local DB write and sync queue insertion in a single Drift transaction.
**When to use:** Every repository create/update/delete that also queues a sync operation.
**Implementation approach:**

The key challenge is that repositories currently call `_localDataSource.insertCustomer()` and `_syncService.queueOperation()` as two separate operations. Both ultimately use the same `AppDatabase` instance, so Drift's `.transaction()` can wrap them.

Two viable approaches:
1. **Pass database to repository, use `_database.transaction()`:** Repositories already have access to `_database` (PipelineRepositoryImpl, ActivityRepositoryImpl) or can get it. Wrap both calls inside `_database.transaction((txn) async { ... })`.
2. **Create a helper on SyncService that accepts both operations:** Add a method like `SyncService.writeAndQueue()` that takes a "local write" callback and queue parameters, executing both in a transaction.

**Recommended: Approach 1** -- simpler, no new abstraction, each repository is explicit about what's transactional.

```dart
// AFTER -- atomic
await _database.transaction(() async {
  await _localDataSource.insertCustomer(companion);
  await _syncQueueDataSource.addToQueue(
    entityType: entityType.name,
    entityId: id,
    operation: operation.name,
    payload: jsonEncode(payload),
  );
});
```

**Critical detail:** Inside a Drift transaction, all database operations MUST use the same transaction executor. Since both `_localDataSource` and `_syncQueueDataSource` use the same `AppDatabase` instance, and Drift's `transaction()` automatically scopes operations on that database to the transaction, this works without modifying the data source classes. Drift v2.x handles this -- when you call `_db.transaction()`, any `_db.select()` / `_db.into()` / `_db.update()` within the callback uses the transaction implicitly.

**Files affected (8 repositories + sync service):**
- `customer_repository_impl.dart` -- createCustomer, updateCustomer, deleteCustomer, addKeyPerson, updateKeyPerson, deleteKeyPerson (6 methods)
- `pipeline_repository_impl.dart` -- createPipeline, updatePipeline, updatePipelineStage, updatePipelineStatus, deletePipeline (5 methods)
- `activity_repository_impl.dart` -- createActivity, createImmediateActivity, updateActivity, executeActivity, cancelActivity (5 methods)
- `hvc_repository_impl.dart` -- create, update, delete, link/unlink operations
- `broker_repository_impl.dart` -- create, update operations
- `cadence_repository_impl.dart` -- multiple meeting/participant operations (11+ methods)
- `pipeline_referral_repository_impl.dart` -- create, accept, reject, cancel, approve operations
- Each method follows the same refactor: wrap local-write + queue-insert in `_database.transaction()`

**Important:** Repositories that don't currently have `_database` (CustomerRepositoryImpl) need it added as a constructor parameter. CustomerRepositoryImpl is the main one that's missing it.

### Pattern 2: Incremental Sync with Timestamps (SYNC-02)
**What:** Store per-entity-type `last_pull_sync_at` timestamps and pass them to all `syncFromRemote()` calls.
**When to use:** Every pull sync in `SyncNotifier._pullFromRemote()`.

**Current state of the plumbing:**
- `AppSettingsService` already has `getTableLastSyncAt(tableName)` and `setTableLastSyncAt(tableName, timestamp)` -- used by `InitialSyncService.performDeltaSync()` for hvcs, brokers, customer_hvc_links, pipeline_referrals.
- All remote data sources already accept `since` parameter: `fetchCustomers({DateTime? since})`, `fetchPipelines({DateTime? since})`, etc.
- All repository `syncFromRemote({DateTime? since})` methods already pass `since` to remote data sources.
- **The gap:** `SyncNotifier._pullFromRemote()` calls `syncFromRemote()` WITHOUT passing `since`. It always does a full pull.

**Implementation:**
```dart
Future<void> _pullFromRemote() async {
  final appSettings = _ref.read(appSettingsServiceProvider);

  // Pull customers incrementally
  final customerSince = await appSettings.getTableLastSyncAt('customers');
  final customerResult = await _customerRepository.syncFromRemote(since: customerSince);
  customerResult.fold(
    (failure) => ...,
    (count) {
      appSettings.setTableLastSyncAt('customers', DateTime.now());
      ...
    },
  );

  // Repeat for each entity type...
}
```

**Entity types needing timestamps (table name as key):**
| Entity | Remote DS Method | AppSettings Key |
|--------|-----------------|-----------------|
| Customer | `fetchCustomers(since:)` | `table_sync_at_customers` |
| KeyPerson | `fetchKeyPersons(since:)` | `table_sync_at_key_persons` |
| Pipeline | `fetchPipelines(since:)` | `table_sync_at_pipelines` |
| Activity | `fetchActivities(since:)` | `table_sync_at_activities` |
| HVC | `fetchHvcs(since:)` | `table_sync_at_hvcs` |
| HVC Links | (via HvcRepository) | `table_sync_at_customer_hvc_links` |
| Broker | `fetchBrokers(since:)` | `table_sync_at_brokers` |
| Cadence | (via CadenceRepository) | `table_sync_at_cadence` |
| PipelineReferral | `fetchReferrals(since:)` | `table_sync_at_pipeline_referrals` |

**Files affected:**
- `sync_providers.dart` -- `SyncNotifier._pullFromRemote()` (primary change)
- `sync_providers.dart` -- inject `AppSettingsService` into `SyncNotifier` constructor
- Possibly `SyncNotifier` provider definition to add `appSettingsServiceProvider` dependency

### Pattern 3: Queue Coalescing (SYNC-03)
**What:** Intelligent merging of sync queue operations for the same entity.
**When to use:** In `SyncService.queueOperation()`.

**Current coalescing logic (incomplete):**
```dart
// Current: Only handles update+update
if (hasPending && operation == SyncOperation.update) {
  await _syncQueueDataSource.removeOperation(entityType.name, entityId);
}
// Then always adds new item
```

**Required coalescing rules:**
| Existing Op | New Op | Result | Rationale |
|-------------|--------|--------|-----------|
| create | update | create with updated payload | Entity hasn't been synced yet; send final state as create |
| create | delete | remove both from queue | Entity was never synced; no remote action needed |
| update | update | replace payload with latest | Only latest state matters |
| update | delete | replace with delete | Delete supersedes update |
| delete | create | error/unexpected | Should not happen in normal flow |
| delete | update | error/unexpected | Should not happen in normal flow |

**Implementation:**
```dart
Future<int> queueOperation({...}) async {
  final existingItems = await _syncQueueDataSource
      .getItemsByEntityType(entityType.name)
      .then((items) => items.where((i) => i.entityId == entityId).toList());

  if (existingItems.isEmpty) {
    // No existing operation, just add
    return _syncQueueDataSource.addToQueue(...);
  }

  final existing = existingItems.first;
  final existingOp = existing.operation;
  final newOp = operation.name;

  if (existingOp == 'create' && newOp == 'update') {
    // Merge: keep create operation, update payload
    await _syncQueueDataSource.updatePayload(existing.id, jsonEncode(payload));
    return existing.id;
  } else if (existingOp == 'create' && newOp == 'delete') {
    // Cancel: remove the create, don't add delete
    await _syncQueueDataSource.removeOperation(entityType.name, entityId);
    return -1; // Indicates no queue item needed
  } else if (existingOp == 'update' && newOp == 'update') {
    // Replace: remove old, add new
    await _syncQueueDataSource.removeOperation(entityType.name, entityId);
    return _syncQueueDataSource.addToQueue(...);
  } else if (existingOp == 'update' && newOp == 'delete') {
    // Supersede: remove update, add delete
    await _syncQueueDataSource.removeOperation(entityType.name, entityId);
    return _syncQueueDataSource.addToQueue(...);
  } else {
    // Unexpected combination, log warning and add anyway
    _log.warning('sync.queue | Unexpected coalesce: $existingOp + $newOp for ${entityType.name}/$entityId');
    return _syncQueueDataSource.addToQueue(...);
  }
}
```

**Key consideration:** The `getItemsByEntityType` method exists but returns ALL items of that type. We need to filter by `entityId` too. The existing `hasPendingOperation` method checks existence but doesn't return the operation type. We need the existing item's operation and id to make coalescing decisions.

**Existing helper methods on SyncQueueLocalDataSource that support this:**
- `hasPendingOperation(entityType, entityId)` -- boolean check
- `removeOperation(entityType, entityId)` -- removes all matching
- `updatePayload(id, payload)` -- updates payload by queue item ID
- `getItemsByEntityType(entityType)` -- returns items (need to filter by entityId in-memory)

**Missing helper:** A method to get the specific pending item for an entity (by entityType + entityId). Consider adding `getPendingItem(entityType, entityId)` to avoid loading all items of that type.

### Pattern 4: Debounced Sync Trigger (SYNC-04)
**What:** Replace immediate `triggerSync()` calls with a debounced version that batches within a 500ms window.
**When to use:** All repository calls to `_syncService.triggerSync()` or `unawaited(_syncService.triggerSync())`.

**Current state:** 35+ calls to `_syncService.triggerSync()` across 8 repositories, each firing immediately after a queue operation. If a user creates 10 customers rapidly, this triggers 10 concurrent `processQueue()` calls (though the `_isSyncing` mutex means only the first runs, the rest return "already in progress" -- but the initial one only processes items queued at that instant, not the later ones).

**Implementation:**
```dart
class SyncService {
  Timer? _debounceTimer;
  Completer<SyncResult>? _pendingSyncCompleter;

  /// Trigger sync with debouncing.
  /// Multiple calls within the debounce window result in a single sync.
  Future<SyncResult> triggerSync() {
    _debounceTimer?.cancel();
    _pendingSyncCompleter ??= Completer<SyncResult>();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final completer = _pendingSyncCompleter!;
      _pendingSyncCompleter = null;

      try {
        final result = await processQueue();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return _pendingSyncCompleter!.future;
  }
}
```

**Important considerations:**
- Current callers use both `unawaited(_syncService.triggerSync())` and plain `_syncService.triggerSync()` (without await). The debounce must preserve this -- callers that don't await should still not block.
- The returned Future allows callers who DO want to know when sync completes to await it.
- The `_isSyncing` guard in `processQueue()` is still needed as a safety net even with debouncing.
- `dispose()` must cancel the debounce timer.

**Files affected:**
- `sync_service.dart` -- add debounce logic to `triggerSync()`, update `dispose()`
- No changes needed in repositories -- they already call `triggerSync()` which will now debounce automatically

### Anti-Patterns to Avoid
- **Separate transaction per data source call:** Do NOT create a transaction in the local data source and another in the sync queue data source. They must be in the SAME transaction from the repository level.
- **Coalescing at processing time:** Do NOT coalesce during `processQueue()`. Coalesce at insertion time in `queueOperation()`. Processing-time coalescing is more complex and risks stale payload data.
- **Global sync timestamp:** Do NOT use a single `last_sync_at` for all entity types. Different entities sync at different times, and a failure in one should not reset others.
- **Debouncing in repositories:** Do NOT add debounce logic in each repository. Keep it centralized in `SyncService.triggerSync()`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Atomic multi-table writes | Manual try/catch with rollback | Drift `.transaction()` | Drift handles rollback on exception, WAL journal, and implicit scoping |
| Timer-based debouncing | Custom event queue or stream | `Timer` from dart:async + `Completer` | Built-in, well-tested, no dependencies |
| Per-table sync timestamps | Custom metadata table | `AppSettingsService.getTableLastSyncAt()` | Already exists and is used by InitialSyncService |

**Key insight:** The existing codebase already has 80% of the infrastructure for all four requirements. The `since` parameter plumbing exists end-to-end but isn't wired. The coalescing helpers exist but aren't fully utilized. The database reference exists in most repositories but isn't used for transactions. This is a wiring and orchestration phase, not an architecture-building phase.

## Common Pitfalls

### Pitfall 1: Transaction Scope with Data Sources
**What goes wrong:** Trying to use `_database.transaction()` but data source operations don't automatically participate because they use a different database reference.
**Why it happens:** If local data sources are created with a different `AppDatabase` instance than the repository's `_database`.
**How to avoid:** Verify that `_localDataSource._db` and the repository's `_database` are the same instance. In the Riverpod provider graph, both come from `databaseProvider`, so they should be identical. Write a test that verifies transaction rollback.
**Warning signs:** Data source operations succeed even when transaction is rolled back.

### Pitfall 2: Timestamp Drift Between Client and Server
**What goes wrong:** Using `DateTime.now()` on the client for `last_pull_sync_at` can miss records updated between the start of the pull and the timestamp recording if client clock is ahead of server.
**Why it happens:** Client clock and server clock are not synchronized. Network latency means records could be modified on the server during the pull.
**How to avoid:** Record the timestamp BEFORE starting the pull, not after. This may result in re-fetching a few records on the next sync, but never missing any. Use a small safety margin (e.g., subtract 30 seconds from `since` timestamp).
**Warning signs:** Intermittent missing records after incremental sync.

### Pitfall 3: Coalescing Race Conditions
**What goes wrong:** Two rapid writes to the same entity create a race condition in coalescing -- both see "has pending" as true, both try to remove, one fails.
**Why it happens:** `queueOperation()` is async and Dart's event loop can interleave.
**How to avoid:** Use Drift transactions to make the check-and-modify atomic. The `hasPendingOperation` + `removeOperation` + `addToQueue` sequence should be wrapped in a transaction.
**Warning signs:** Duplicate queue entries for the same entity, or missing entries.

### Pitfall 4: Debounce Timer Not Cancelled on Dispose
**What goes wrong:** The debounce timer fires after `SyncService.dispose()`, trying to call `processQueue()` on a disposed service.
**Why it happens:** The timer is set but the service is torn down before it fires.
**How to avoid:** Cancel `_debounceTimer` in `dispose()`. Complete any pending completer with an error.
**Warning signs:** Unhandled exception after navigation away from sync-related screens.

### Pitfall 5: Coalescing create+update Loses New Fields
**What goes wrong:** When coalescing create+update to a single create, the update's payload is used but it might not contain all fields that were in the original create payload (since updates are partial).
**Why it happens:** Update DTOs only include changed fields, but create operations need all fields.
**How to avoid:** When merging create+update, the new payload should be the FULL current state of the entity, read from the local database. The current implementation already does this -- `_createUpdateSyncPayload(updated)` reads the full entity from DB. Ensure this pattern is preserved during the coalescing refactor.
**Warning signs:** Server rejects create operation with "missing required field" errors.

### Pitfall 6: Incremental Sync Misses Soft-Deleted Records
**What goes wrong:** Incremental pull with `updated_at > since` misses records that were soft-deleted (deleted_at set) if the query doesn't include deleted records.
**Why it happens:** Remote data source queries may filter out deleted records.
**How to avoid:** Review each remote data source `fetch*` method to ensure it includes soft-deleted records when `since` is provided. The `fetchCustomers` method currently uses `.gte('updated_at', since)` without filtering deleted_at -- this is correct. Verify the same pattern for all entity types.
**Warning signs:** Locally deleted records reappear after sync, or remotely deleted records persist locally.

## Code Examples

### Example 1: Atomic Transaction (SYNC-01)
```dart
// customer_repository_impl.dart -- createCustomer()
// Source: Existing codebase + Drift documentation on transactions

@override
Future<Either<Failure, domain.Customer>> createCustomer(
  CustomerCreateDto dto,
) async {
  try {
    final now = DateTime.now();
    final id = _uuid.v4();
    final code = _generateCustomerCode();

    final companion = db.CustomersCompanion.insert(/* ... */);
    final syncPayload = _createSyncPayload(id, code, dto, now);

    // ATOMIC: Both local write and queue insertion in single transaction
    await _database.transaction(() async {
      await _localDataSource.insertCustomer(companion);
      await _syncQueueDataSource.addToQueue(
        entityType: SyncEntityType.customer.name,
        entityId: id,
        operation: SyncOperation.create.name,
        payload: jsonEncode(syncPayload),
      );
    });

    // Trigger sync OUTSIDE transaction (non-blocking)
    unawaited(_syncService.triggerSync());

    final customer = await getCustomerById(id);
    return Right(customer!);
  } catch (e) {
    return Left(DatabaseFailure(
      message: 'Failed to create customer: $e',
      originalError: e,
    ));
  }
}
```

### Example 2: Full Coalescing Logic (SYNC-03)
```dart
// sync_service.dart -- queueOperation()
// Source: Existing codebase pattern + coalescing rules from requirements

Future<int> queueOperation({
  required SyncEntityType entityType,
  required String entityId,
  required SyncOperation operation,
  required Map<String, dynamic> payload,
}) async {
  return _database.transaction(() async {
    // Find existing pending operation for this entity
    final existing = await _syncQueueDataSource
        .getPendingItemForEntity(entityType.name, entityId);

    if (existing == null) {
      return _syncQueueDataSource.addToQueue(
        entityType: entityType.name,
        entityId: entityId,
        operation: operation.name,
        payload: jsonEncode(payload),
      );
    }

    final existingOp = existing.operation;
    final newOp = operation.name;

    switch ((existingOp, newOp)) {
      case ('create', 'update'):
        // Keep create, update payload to latest state
        await _syncQueueDataSource.updatePayload(
          existing.id, jsonEncode(payload));
        return existing.id;

      case ('create', 'delete'):
        // Cancel both -- entity never reached server
        await _syncQueueDataSource.removeOperation(
          entityType.name, entityId);
        return -1;

      case ('update', 'update'):
        // Replace with latest update
        await _syncQueueDataSource.removeOperation(
          entityType.name, entityId);
        return _syncQueueDataSource.addToQueue(
          entityType: entityType.name,
          entityId: entityId,
          operation: newOp,
          payload: jsonEncode(payload),
        );

      case ('update', 'delete'):
        // Delete supersedes update
        await _syncQueueDataSource.removeOperation(
          entityType.name, entityId);
        return _syncQueueDataSource.addToQueue(
          entityType: entityType.name,
          entityId: entityId,
          operation: newOp,
          payload: jsonEncode(payload),
        );

      default:
        _log.warning('sync.queue | Unexpected coalesce: $existingOp + $newOp');
        return _syncQueueDataSource.addToQueue(
          entityType: entityType.name,
          entityId: entityId,
          operation: newOp,
          payload: jsonEncode(payload),
        );
    }
  });
}
```

### Example 3: Debounced Trigger (SYNC-04)
```dart
// sync_service.dart -- triggerSync()
// Source: dart:async Timer + Completer pattern

Timer? _debounceTimer;
Completer<SyncResult>? _pendingSyncCompleter;

/// Trigger sync with 500ms debounce window.
/// Multiple calls within the window result in a single processQueue().
Future<SyncResult> triggerSync() {
  _debounceTimer?.cancel();

  if (_pendingSyncCompleter == null || _pendingSyncCompleter!.isCompleted) {
    _pendingSyncCompleter = Completer<SyncResult>();
  }

  final completer = _pendingSyncCompleter!;

  _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
    try {
      final result = await processQueue();
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }
  });

  return completer.future;
}
```

### Example 4: Incremental Pull (SYNC-02)
```dart
// sync_providers.dart -- SyncNotifier._pullFromRemote()
// Source: Existing AppSettingsService pattern from InitialSyncService

Future<void> _pullFromRemote() async {
  final appSettings = _ref.read(appSettingsServiceProvider);

  // Pull customers incrementally
  try {
    final since = await appSettings.getTableLastSyncAt('customers');
    _log.debug('sync.pull | Pulling customers since=$since');
    final result = await _customerRepository.syncFromRemote(since: since);
    result.fold(
      (failure) => _log.warning('sync.pull | Customer pull failed: ${failure.message}'),
      (count) {
        _log.debug('sync.pull | Pulled $count customers');
        appSettings.setTableLastSyncAt('customers', DateTime.now());
      },
    );
  } catch (e) {
    _log.error('sync.pull | Customer pull error: $e');
  }

  // Repeat pattern for each entity type...
}
```

## State of the Art

| Old Approach (Current) | New Approach (Phase 2) | Impact |
|------------------------|------------------------|--------|
| Separate local write + queue insert | Single Drift transaction | Eliminates data loss window on crash |
| Full table pull every sync | Incremental `since` timestamp | Reduces sync from 30s to <5s for typical usage |
| Only update+update coalescing | Full create+update, create+delete, update+delete | Prevents stale creates, eliminates unnecessary remote operations |
| Immediate triggerSync() per write | 500ms debounce window | Reduces N concurrent syncs to 1 batched sync |

## Codebase Current State Inventory

### What Already Works
1. All remote data sources accept `DateTime? since` parameter
2. All repository `syncFromRemote()` methods accept and forward `since`
3. `AppSettingsService` has per-table timestamp storage (`getTableLastSyncAt`/`setTableLastSyncAt`)
4. `SyncQueueLocalDataSource` has `updatePayload()`, `removeOperation()`, `hasPendingOperation()`
5. Drift 2.22.1 supports `.transaction()` natively
6. `PipelineRepositoryImpl`, `ActivityRepositoryImpl` already have `_database` reference
7. All repositories follow the same write pattern (local write -> queue -> triggerSync)
8. Phase 1 provided standardized sync metadata (isPendingSync, lastSyncAt, updatedAt) on all tables

### What Needs to Be Built/Changed

**SYNC-01 (Atomic Transactions):**
- Add `_database` parameter to `CustomerRepositoryImpl` constructor (it's the only repo missing it)
- Add `_syncQueueDataSource` parameter to repositories that need direct queue access inside transactions
- Wrap 30+ create/update/delete methods across 8 repositories in `_database.transaction()`
- Update all repository provider definitions to pass database instance

**SYNC-02 (Incremental Sync):**
- Inject `AppSettingsService` into `SyncNotifier`
- Modify `_pullFromRemote()` to read/write per-entity timestamps (9 entity types)
- Update `syncNotifierProvider` to include `appSettingsServiceProvider`
- Verify that soft-deleted records are included in incremental pulls for all remote data sources

**SYNC-03 (Queue Coalescing):**
- Add `getPendingItemForEntity(entityType, entityId)` method to `SyncQueueLocalDataSource`
- Rewrite `SyncService.queueOperation()` with full coalescing logic
- Wrap coalescing check-and-modify in a transaction for atomicity
- Handle the `create+update -> create(updated payload)` case correctly with full entity state
- Handle the `create+delete -> remove both` case to avoid orphaned queue entries

**SYNC-04 (Debounced Trigger):**
- Add `_debounceTimer` and `_pendingSyncCompleter` fields to `SyncService`
- Replace `triggerSync()` body with debounced version
- Update `dispose()` to cancel timer and complete any pending completer
- Verify that `SyncNotifier.triggerSync()` (the direct call in bidirectional sync) still works correctly -- it should call `processQueue()` directly, not the debounced `triggerSync()`

### Repository Inventory (Files to Modify for SYNC-01)
| Repository | Has _database? | Queue Calls | Methods to Wrap |
|------------|---------------|-------------|-----------------|
| CustomerRepositoryImpl | NO (needs adding) | 6 | createCustomer, updateCustomer, deleteCustomer, addKeyPerson, updateKeyPerson, deleteKeyPerson |
| PipelineRepositoryImpl | YES | 5 | createPipeline, updatePipeline, updatePipelineStage, updatePipelineStatus, deletePipeline |
| ActivityRepositoryImpl | YES | 5 | createActivity, createImmediateActivity, updateActivity, executeActivity, cancelActivity |
| HvcRepositoryImpl | needs check | 5+ | createHvc, updateHvc, deleteHvc, linkCustomer, unlinkCustomer |
| BrokerRepositoryImpl | needs check | 2+ | createBroker, updateBroker |
| CadenceRepositoryImpl | needs check | 11+ | createMeeting, updateMeeting, deleteMeeting, addParticipant, etc. |
| PipelineReferralRepositoryImpl | YES | 5+ | createReferral, acceptReferral, rejectReferral, cancelReferral, approveReferral |

### triggerSync() Call Inventory (for SYNC-04 impact analysis)
- `unawaited(_syncService.triggerSync())` -- 28+ call sites across repositories
- `_syncService.triggerSync()` -- 7+ call sites (non-unawaited, in pipeline/activity repos)
- `_syncService.triggerSync()` in SyncNotifier -- 1 call site (this is the bidirectional sync trigger, should NOT be debounced)

**Critical distinction:** The debounce should apply to the repository-level "fire and forget" calls, but NOT to the `SyncNotifier.triggerSync()` which is the explicit user-triggered sync. Solution: Keep `processQueue()` as the immediate method. Make `triggerSync()` the debounced wrapper. SyncNotifier already calls `_syncService.triggerSync()` -> `processQueue()`. Change SyncNotifier to call `processQueue()` directly for the push phase.

## Open Questions

1. **Transaction scope with SyncQueueLocalDataSource in repositories**
   - What we know: Repositories currently call `_syncService.queueOperation()` which internally calls `_syncQueueDataSource.addToQueue()`. For SYNC-01, we need both the local write and queue insert in the same transaction.
   - What's unclear: Should repositories access `_syncQueueDataSource` directly (bypassing SyncService for the insert), or should we pass a transaction executor through SyncService?
   - Recommendation: Have repositories access `_syncQueueDataSource` directly for the insert inside the transaction, and keep `SyncService.queueOperation()` for non-transactional scenarios. Alternatively, refactor to inject `SyncQueueLocalDataSource` into repositories alongside `SyncService`. The coalescing logic (SYNC-03) complicates this -- the coalescing check should also be in the transaction. Best approach: Move the coalescing + insert logic into a method that can be called from within a transaction context.

2. **Debounce behavior during manual sync**
   - What we know: `SyncNotifier.triggerSync()` performs a full bidirectional sync (push + photos + audit logs + pull). It calls `_syncService.triggerSync()` for the push phase.
   - What's unclear: Should the SyncNotifier's push call be debounced? If user taps "Sync Now", they expect immediate execution.
   - Recommendation: SyncNotifier should call `_syncService.processQueue()` directly (not `triggerSync()`), bypassing the debounce. The debounce is only for the "fire and forget" calls from repository writes.

3. **Handling `create+delete` coalescing with `isPendingSync`**
   - What we know: When we coalesce create+delete to "remove both from queue", the local entity still exists with `isPendingSync: true` (since the create set it). The entity was soft-deleted locally but the queue entry is gone.
   - What's unclear: Should we also clear `isPendingSync` on the local entity when removing both queue entries? The entity is soft-deleted so it won't show in normal UI, but the pending sync count would be wrong.
   - Recommendation: Yes, clear `isPendingSync` during create+delete coalescing. This should also be inside the transaction.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `lib/data/services/sync_service.dart` -- current queue processing and coalescing logic
- Codebase analysis: `lib/data/datasources/local/sync_queue_local_data_source.dart` -- existing helper methods
- Codebase analysis: `lib/data/repositories/customer_repository_impl.dart` -- representative write pattern
- Codebase analysis: `lib/data/repositories/pipeline_repository_impl.dart` -- repository with `_database` reference
- Codebase analysis: `lib/presentation/providers/sync_providers.dart` -- SyncNotifier._pullFromRemote() gap
- Codebase analysis: `lib/data/services/initial_sync_service.dart` -- existing delta sync pattern with timestamps
- Codebase analysis: `lib/data/services/app_settings_service.dart` -- existing per-table timestamp storage
- Codebase analysis: `lib/data/datasources/remote/*.dart` -- all accept `since` parameter
- Drift v2.22.1 documentation -- `.transaction()` API scopes all operations on the database to the transaction

### Secondary (MEDIUM confidence)
- Drift transaction behavior with shared `AppDatabase` instance -- verified via API shape; Drift's `transaction()` uses zone-based scoping, so any `_db` operation within the callback participates in the transaction automatically

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all libraries already in project, no new dependencies needed
- Architecture: HIGH -- patterns are straightforward refactors of existing code, not new architecture
- Pitfalls: HIGH -- pitfalls identified from direct codebase analysis and Drift documentation
- Coalescing logic: MEDIUM -- the edge cases around create+delete with isPendingSync need careful testing
- Debounce interaction with SyncNotifier: MEDIUM -- the bidirectional sync flow has nuances that need verification

**Research date:** 2026-02-13
**Valid until:** 2026-03-15 (stable -- no fast-moving external dependencies)
