# Architecture Research: Offline-First Sync Reliability for LeadX CRM

**Domain:** Offline-first mobile CRM sync system (Flutter/Drift/Supabase)
**Researched:** 2026-02-13
**Confidence:** HIGH (based on codebase analysis + Flutter official docs + multiple verified sources)

## Current Architecture Assessment

LeadX already has a Clean Architecture foundation (presentation/domain/data layers) with an offline-first sync system. The architecture is sound in structure but has five specific reliability problems that need targeted fixes rather than a rewrite.

### Diagnosed Problems (from codebase analysis)

| Problem | Evidence | Severity |
|---------|----------|----------|
| Inconsistent sync timestamp fields | `lastSyncAt` (Customers, Pipelines, PipelineReferrals, CadenceParticipants), `syncedAt` (Activities), absent (KeyPersons, Hvcs, CustomerHvcLinks, Brokers, CadenceMeetings, PipelineStageHistory) | HIGH |
| No conflict detection | `_processItem()` does blind insert/update with no timestamp comparison against server state | HIGH |
| Race condition in initial sync | `performInitialSync` and `processQueue` share no coordination -- if a user creates data during initial sync, the queue may push before reference data is pulled | HIGH |
| Sync queue never pruned | Failed items (retryCount >= maxRetries) stay in queue forever; `clearCompletedItems()` exists but is never called | MEDIUM |
| Generic exceptions lose error type info | `_processItem()` catches `SocketException` and `TimeoutException` then wraps them in generic `Exception()`, discarding the typed hierarchy | MEDIUM |

## Recommended Architecture (Target State)

The existing Clean Architecture layers remain. What changes is the internal structure of the sync subsystem within the data layer.

```
+----------------------------------------------------------------+
|                    Presentation Layer                           |
|  +------------------+  +------------------+  +---------------+ |
|  | SyncNotifier     |  | SyncStatusWidget |  | Entity UIs    | |
|  | (push+pull       |  | (pending count,  |  | (read from    | |
|  |  orchestration)  |  |  connectivity)   |  |  Drift watch) | |
|  +--------+---------+  +--------+---------+  +-------+-------+ |
|           |                      |                    |         |
+-----------|----------------------|--------------------|---------+
            |                      |                    |
+-----------|----------------------|--------------------|---------+
|           v                      v                    v         |
|                      Domain Layer                               |
|  +------------------+  +------------------+  +---------------+ |
|  | SyncRepository   |  | ConnectivityRepo |  | EntityRepos   | |
|  | (interface)      |  | (interface)      |  | (interfaces)  | |
|  +--------+---------+  +--------+---------+  +-------+-------+ |
|           |                      |                    |         |
+-----------|----------------------|--------------------|---------+
            |                      |                    |
+-----------|----------------------|--------------------|---------+
|           v                      v                    v         |
|                       Data Layer                                |
|  +----------------------------------------------------------+  |
|  |                    Sync Subsystem                         |  |
|  |  +----------------+  +-----------------+  +------------+ |  |
|  |  | SyncService    |  | InitialSync     |  | SyncQueue  | |  |
|  |  | (queue push,   |  | Service         |  | DataSource | |  |
|  |  |  retry, error  |  | (master data    |  | (FIFO ops, | |  |
|  |  |  classification)|  |  + delta sync)  |  |  pruning)  | |  |
|  |  +--------+-------+  +--------+--------+  +------+-----+ |  |
|  |           |                    |                  |        |  |
|  |  +--------v--------------------v------------------v-----+ |  |
|  |  |              SyncCoordinator (NEW)                   | |  |
|  |  | - Ensures initial sync completes before queue push   | |  |
|  |  | - Manages sync locks to prevent concurrent execution | |  |
|  |  | - Orchestrates: initial sync -> queue push -> pull   | |  |
|  |  +-----------------------------------------------------+ |  |
|  +----------------------------------------------------------+  |
|                                                                 |
|  +----------------------------------------------------------+  |
|  |              Error Classification (NEW)                   |  |
|  |  +------------------+  +------------------+              |  |
|  |  | SyncErrorMapper  |  | RetryPolicy      |              |  |
|  |  | (exception ->    |  | (retryable vs     |              |  |
|  |  |  typed SyncError)|  |  permanent fail)  |              |  |
|  |  +------------------+  +------------------+              |  |
|  +----------------------------------------------------------+  |
|                                                                 |
|  +----------------------------------------------------------+  |
|  |              Data Sources (existing)                      |  |
|  |  +----------+  +----------+  +---------------------------+|  |
|  |  | Local DS |  | Remote DS|  | ConnectivityService       ||  |
|  |  | (Drift)  |  |(Supabase)|  | (connectivity_plus + poll)||  |
|  |  +----------+  +----------+  +---------------------------+|  |
|  +----------------------------------------------------------+  |
+-----------------------------------------------------------------+
```

### Component Responsibilities

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **SyncCoordinator** (NEW) | Prevents race conditions by gating queue processing on initial sync completion; serializes sync phases (push -> photos -> audit -> pull) | SyncService, InitialSyncService, SyncNotifier |
| **SyncService** (ENHANCED) | Processes sync queue FIFO with typed error handling; classifies errors as retryable vs permanent; prunes dead items | SyncQueueLocalDataSource, SyncErrorMapper, RetryPolicy |
| **InitialSyncService** (EXISTING) | Downloads master/reference data on first login with resume support; performs delta sync for transactional tables | Supabase, Drift, AppSettingsService |
| **SyncNotifier** (EXISTING) | Orchestrates bidirectional sync from UI: push local changes, pull remote changes, invalidate caches | SyncCoordinator, entity repositories |
| **SyncErrorMapper** (NEW) | Maps raw exceptions (SocketException, PostgrestException, TimeoutException) to typed SyncError hierarchy | SyncService |
| **RetryPolicy** (NEW) | Determines whether a SyncError is retryable and with what backoff; classifies permanent failures (auth, validation) vs transient (network, timeout) | SyncService |
| **SyncQueueLocalDataSource** (ENHANCED) | FIFO queue operations plus periodic pruning of permanently failed items older than configurable threshold | Drift database |
| **ConnectivityService** (EXISTING) | Monitors network state via connectivity_plus with server reachability polling every 30s | Supabase health check |
| **Entity Repositories** (EXISTING) | Write locally first, queue for sync, trigger immediate sync attempt; pull from remote on demand | Local DS, Remote DS, SyncService |

## Data Flow

### Write Flow (Create/Update/Delete)

```
User Action
    |
    v
EntityNotifier.create/update/delete()
    |
    v
Repository.create/update/delete()
    |
    +---> Local DataSource: write to Drift (immediate)
    |     - isPendingSync = true
    |     - updatedAt = DateTime.now()
    |
    +---> SyncService.queueOperation()
    |     - Coalesces: if pending update exists, replace payload
    |     - Stores in sync_queue table (atomic with local write -- IMPROVEMENT NEEDED)
    |
    +---> SyncService.triggerSync() (unawaited)
          |
          v
    SyncCoordinator.canPushSync()  <-- NEW gate
          |
          +-- Initial sync incomplete? SKIP (queue preserved for later)
          +-- Already syncing? SKIP
          +-- Offline? SKIP
          |
          v
    SyncService.processQueue()
          |
          v (for each item FIFO)
    SyncService._processItem(item)
          |
          +---> Supabase.from(table).insert/update/delete(payload)
          |
          +---> On success:
          |     - markAsCompleted(item.id)  [removes from queue]
          |     - _markEntityAsSynced(entityType, entityId)
          |       [sets isPendingSync=false, lastSyncAt=now]
          |
          +---> On failure:
                - SyncErrorMapper.classify(exception)  <-- NEW
                  |
                  +-- Retryable (network, timeout, 5xx):
                  |   incrementRetryCount, markAsFailed with typed error
                  |
                  +-- Permanent (auth 401, validation 400, constraint 409):
                      markAsPermanentlyFailed  <-- NEW status
```

### Read Flow (unchanged, already sound)

```
UI Widget
    |
    v
StreamProvider / StreamProvider.family
    |
    v
Repository.watch*() / Repository.watchById()
    |
    v
LocalDataSource.watch*()
    |
    v
Drift .watch() / .watchSingleOrNull()
    |
    v (automatic emission on table change)
UI updates reactively
```

### Pull (Remote -> Local) Flow

```
SyncNotifier.triggerSync()
    |
    v
Step 1: Push (processQueue) -- upload local changes
    |
    v
Step 2: Sync photos (syncPendingPhotos)
    |
    v
Step 3: Sync audit logs (syncPendingAuditLogs)
    |
    v
Step 4: Pull -- download remote changes
    |
    +---> For each entity type:
    |     repository.syncFromRemote(since: lastSyncAt)
    |       |
    |       v
    |     RemoteDataSource.fetch*(since: timestamp)
    |       |
    |       v
    |     Map remote JSON -> Drift Companion
    |       - isPendingSync = false
    |       - lastSyncAt = DateTime.now()  <-- MUST BE CONSISTENT
    |       |
    |       v
    |     LocalDataSource.upsert*(companions)
    |       - InsertMode.insertOrReplace
    |       |
    |       v  (conflict detection -- NEW)
    |     Before upsert: check if local has isPendingSync=true
    |       - If local isPendingSync AND remote updatedAt > local updatedAt:
    |         Log conflict, server wins (LWW), clear pending
    |       - If local isPendingSync AND local updatedAt >= remote updatedAt:
    |         Keep local version, skip this remote record
    |
    v
Step 5: Invalidate lookup caches
    |
    v
Step 6: Refresh auth state
```

### Initial Sync Flow

```
Login Success
    |
    v
AppSettingsService.hasInitialSyncCompleted()
    |
    +-- true: proceed to main app, start background sync
    +-- false: show sync progress screen
          |
          v
    InitialSyncService.performInitialSync()
          |
          +-- Resume check: getResumeSyncIndex()
          |   (if interrupted, resume from last completed table)
          |
          v (sequential, dependency-ordered)
    1. regional_offices
    2. branches
    3. users (two-pass: insert all, then update parent_id)
    4. user_hierarchy
    5. master data (provinces, cities, company_types, etc.)
    6. scoring data (measure_definitions, scoring_periods)
    7. cadence config
          |
          v
    markInitialSyncCompleted()
          |
          v
    InitialSyncService.performDeltaSync()  <-- transactional tables
    (hvcs, brokers, customer_hvc_links, pipeline_referrals)
          |
          v
    SyncCoordinator: unlock queue processing  <-- NEW gate opens
          |
          v
    Background sync timer starts (every 5 min)
```

## Architectural Patterns

### Pattern 1: Consistent Sync Metadata Columns

**What:** Every syncable entity table uses the same three sync tracking columns: `isPendingSync` (bool), `lastSyncAt` (DateTime nullable), `updatedAt` (DateTime required).

**When to use:** Every table that participates in bidirectional sync.

**Trade-offs:** Requires a migration to add `lastSyncAt` to tables that lack it (Activities currently uses `syncedAt`, KeyPersons/Hvcs/CustomerHvcLinks/Brokers/CadenceMeetings/PipelineStageHistory lack it entirely). Migration is safe because adding nullable columns with no default is non-destructive.

**Example:**
```dart
// STANDARD sync columns -- every syncable table MUST include these
BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
DateTimeColumn get lastSyncAt => dateTime().nullable()();
DateTimeColumn get createdAt => dateTime()();
DateTimeColumn get updatedAt => dateTime()();
DateTimeColumn get deletedAt => dateTime().nullable()(); // for soft-delete entities
```

**Current inconsistencies to fix:**

| Entity | Has isPendingSync | Has timestamp | Column Name | Action Needed |
|--------|-------------------|---------------|-------------|---------------|
| Customers | yes | yes | `lastSyncAt` | none (reference) |
| Pipelines | yes | yes | `lastSyncAt` | none (reference) |
| PipelineReferrals | yes | yes | `lastSyncAt` | none |
| CadenceParticipants | yes | yes | `lastSyncAt` | none |
| Activities | yes | yes | `syncedAt` | RENAME to `lastSyncAt` |
| KeyPersons | yes | NO | -- | ADD `lastSyncAt` |
| Hvcs | yes | NO | -- | ADD `lastSyncAt` |
| CustomerHvcLinks | yes | NO | -- | ADD `lastSyncAt` |
| Brokers | yes | NO | -- | ADD `lastSyncAt` |
| CadenceMeetings | yes | NO | -- | ADD `lastSyncAt` |
| PipelineStageHistory | yes | NO | -- | ADD `lastSyncAt` |

### Pattern 2: Typed Error Classification for Sync

**What:** Map raw exceptions from Supabase/network into a sealed class hierarchy that the retry policy can act on without string parsing.

**When to use:** In `SyncService._processItem()` and any repository `syncFromRemote()` method.

**Trade-offs:** Adds a layer of indirection, but eliminates the current problem where `Exception('Network error: ...')` loses the original exception type.

**Example:**
```dart
/// Sealed class for sync errors -- enables exhaustive matching.
sealed class SyncError {
  final String message;
  final Object? originalError;
  const SyncError(this.message, {this.originalError});
}

/// Transient errors -- safe to retry with backoff.
class NetworkSyncError extends SyncError {
  const NetworkSyncError(super.message, {super.originalError});
}

class TimeoutSyncError extends SyncError {
  const TimeoutSyncError(super.message, {super.originalError});
}

class ServerSyncError extends SyncError {
  final int? statusCode;
  const ServerSyncError(super.message, {this.statusCode, super.originalError});
}

/// Permanent errors -- do NOT retry, require user action or code fix.
class AuthSyncError extends SyncError {
  const AuthSyncError(super.message, {super.originalError});
}

class ValidationSyncError extends SyncError {
  final Map<String, dynamic>? details;
  const ValidationSyncError(super.message, {this.details, super.originalError});
}

class ConflictSyncError extends SyncError {
  final String entityType;
  final String entityId;
  const ConflictSyncError(super.message, {
    required this.entityType,
    required this.entityId,
    super.originalError,
  });
}

/// Mapper from raw exceptions to typed SyncError.
class SyncErrorMapper {
  static SyncError classify(Object error) {
    return switch (error) {
      SocketException e => NetworkSyncError('Network unreachable', originalError: e),
      TimeoutException e => TimeoutSyncError('Request timed out', originalError: e),
      PostgrestException e when e.code == '401' || e.code == '403' =>
        AuthSyncError('Authentication failed', originalError: e),
      PostgrestException e when e.code == '409' || e.code == '23505' =>
        ConflictSyncError('Constraint violation', entityType: '', entityId: '', originalError: e),
      PostgrestException e when e.code?.startsWith('4') == true =>
        ValidationSyncError('Validation error: ${e.message}', originalError: e),
      PostgrestException e =>
        ServerSyncError('Server error: ${e.message}', statusCode: int.tryParse(e.code ?? ''), originalError: e),
      _ => ServerSyncError('Unexpected error: $error', originalError: error),
    };
  }
}
```

### Pattern 3: Sync Coordination Gate

**What:** A coordinator that prevents the sync queue from pushing data before initial sync completes, and serializes sync phases to prevent concurrent modification.

**When to use:** Between login and first successful initial sync; and during any active sync operation.

**Trade-offs:** Adds latency for the very first write after login (queued but not pushed until initial sync finishes). This is acceptable because the data is safe in the local queue and will sync once the gate opens.

**Example:**
```dart
class SyncCoordinator {
  final AppSettingsService _appSettings;
  bool _isSyncing = false;

  /// Check if push sync is allowed.
  Future<bool> canPushSync() async {
    if (_isSyncing) return false;
    final initialComplete = await _appSettings.hasInitialSyncCompleted();
    return initialComplete;
  }

  /// Acquire sync lock. Returns false if already locked.
  bool acquireLock() {
    if (_isSyncing) return false;
    _isSyncing = true;
    return true;
  }

  void releaseLock() => _isSyncing = false;
}
```

### Pattern 4: Last-Writer-Wins Conflict Detection

**What:** Before upserting remote data over local data, check if the local record has unsaved changes (isPendingSync = true). If it does, compare `updatedAt` timestamps. Higher timestamp wins.

**When to use:** In every repository's `syncFromRemote()` method during the pull phase.

**Trade-offs:** LWW can lose data when two users edit the same record offline simultaneously. For a CRM where records are typically owned by a single RM (assigned_rm_id), this risk is low. Field-level merge would be more robust but far more complex; it is not warranted for this use case.

**Why not CRDTs:** CRDTs add significant complexity (per-field clocks, operation logs, custom merge logic). LeadX entities are predominantly single-writer (one RM owns a customer). The concurrency risk is low enough that LWW with conflict logging is the right trade-off.

**Example:**
```dart
/// In repository syncFromRemote:
for (final remoteRecord in remoteData) {
  final localRecord = await _localDataSource.getById(remoteRecord.id);

  if (localRecord != null && localRecord.isPendingSync) {
    // Local has unsaved changes -- conflict!
    final remoteUpdatedAt = DateTime.parse(remoteRecord['updated_at']);
    if (localRecord.updatedAt.isAfter(remoteUpdatedAt) ||
        localRecord.updatedAt.isAtSameMomentAs(remoteUpdatedAt)) {
      // Local wins -- skip this remote record, let push sync handle it
      debugPrint('[Sync] Conflict: local wins for ${remoteRecord.id}');
      continue;
    } else {
      // Remote wins -- overwrite local, discard local changes
      debugPrint('[Sync] Conflict: remote wins for ${remoteRecord.id}');
      // Also remove any pending queue items for this entity
      await _syncQueueDataSource.removeOperation(entityType, remoteRecord.id);
    }
  }

  // Upsert remote data
  await _localDataSource.upsert(remoteRecord.toCompanion());
}
```

### Pattern 5: Queue Pruning

**What:** Periodically remove sync queue items that have permanently failed (exceeded max retries) or are older than a configurable age.

**When to use:** After every successful sync cycle; optionally on app startup.

**Example:**
```dart
/// In SyncService, after processQueue completes:
Future<void> _pruneDeadItems() async {
  // Remove items that exceeded max retries and are older than 7 days
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  final deadItems = await _syncQueueDataSource.getDeadItems(
    maxRetries: maxRetries,
    olderThan: cutoff,
  );

  for (final item in deadItems) {
    debugPrint('[SyncService] Pruning dead item: ${item.entityType}/${item.entityId}');
    // Optionally: mark entity as having sync error for UI display
    await _syncQueueDataSource.markAsCompleted(item.id);
  }
}
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Generic Exception Wrapping

**What people do:** Catch typed exceptions (SocketException, PostgrestException) and wrap them in `Exception('some string')`, losing type information.

**Why it is wrong:** Downstream code cannot distinguish retryable errors from permanent errors without string parsing. The `_processItem` method currently does this:
```dart
// CURRENT CODE -- BAD
} on SocketException catch (e) {
  throw Exception('Network error: Device appears to be offline. $e');
}
```

**Do this instead:** Throw typed SyncError subclasses (see Pattern 2 above) so that the queue processor can make intelligent retry decisions.

### Anti-Pattern 2: Fire-and-Forget Sync Without Coordination

**What people do:** Call `unawaited(_syncService.triggerSync())` from entity creation without checking whether initial sync has completed.

**Why it is wrong:** If a user creates a customer immediately after login but before master data syncs, the push may execute against a Supabase table that has RLS policies depending on user context that is not yet established locally. The push might succeed on Supabase but the local state is inconsistent.

**Do this instead:** Route all sync triggers through a SyncCoordinator that gates on initial sync completion (see Pattern 3).

### Anti-Pattern 3: Inconsistent Sync Metadata

**What people do:** Use different column names (`syncedAt` vs `lastSyncAt` vs nothing) across entity tables, and handle each entity type differently in `_markEntityAsSynced()` with a growing switch statement.

**Why it is wrong:** Every new entity type requires adding another case to the switch. Missing a case means data silently stays marked as pending. The current switch statement already has 12 cases with different column patterns.

**Do this instead:** Standardize to three columns (`isPendingSync`, `lastSyncAt`, `updatedAt`) across all syncable tables. Create a mixin or abstract method that all entity data sources implement:
```dart
abstract class SyncableLocalDataSource {
  Future<void> markAsSynced(String id, DateTime syncedAt);
  Future<bool> hasPendingSync(String id);
}
```

### Anti-Pattern 4: Unbounded Queue Growth

**What people do:** Never prune failed sync queue items, allowing the table to grow indefinitely with items that will never succeed.

**Why it is wrong:** Each sync cycle re-fetches and re-processes all items with retryCount < maxRetries. Items that hit maxRetries stay in the table but are never processed or removed. Over months, this degrades query performance and leaks intent that will never be fulfilled.

**Do this instead:** After each sync cycle, prune items that exceeded maxRetries and are older than 7 days. Optionally log them for admin review before deletion.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-50 users (current) | Current architecture is adequate with the targeted fixes described. Single Supabase project, background sync every 5 minutes. |
| 50-500 users | Add server-side sync timestamps (Supabase stores per-user last_sync_at). Move from polling to Supabase Realtime for push-based pull triggers. Consider batching queue items by entity type for more efficient uploads. |
| 500+ users | Evaluate PowerSync for managed sync infrastructure. Current Drift + custom sync works but operational burden increases. Consider server-side conflict resolution (PostgreSQL triggers that implement LWW) to reduce client complexity. |

### Scaling Priorities

1. **First bottleneck:** Sync queue processing time. Currently processes items one-at-a-time sequentially. For users with many pending items, this blocks. Fix: batch processing by entity type (one Supabase call with array of records rather than N individual calls).
2. **Second bottleneck:** Pull sync fetches all records since last sync without pagination for some entities. For large datasets, this can time out. Fix: add pagination to all `syncFromRemote()` methods, similar to how `_syncBrokers()` already does it.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Supabase PostgREST | Direct REST via `supabase-flutter` client | Rate limits should be configured server-side; client should respect 429 responses with backoff |
| Supabase Auth | JWT tokens via GoTrue | Tokens may expire during long offline periods; sync must handle 401 by triggering re-auth flow |
| Supabase Storage | File upload for activity photos | Photos have their own sync tracking (`isPendingUpload`) separate from the main sync queue |
| Supabase Edge Functions | Admin operations (user creation, password reset) | These bypass the sync queue entirely -- they are online-only operations |
| Supabase Realtime | NOT currently used | Could be added later for push-based pull triggers instead of polling |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Presentation -> Domain | Via Riverpod providers watching repository streams | UI never talks directly to data sources |
| Domain -> Data | Repository interfaces in domain, implementations in data | Repositories orchestrate local DS, remote DS, SyncService |
| SyncService -> Entity Tables | Direct Drift database access in `_markEntityAsSynced()` | This should be refactored to go through data sources for consistency |
| SyncNotifier -> Repositories | Direct method calls for pull sync | Each repository owns its own `syncFromRemote()` logic |
| InitialSyncService -> Database | Direct Drift batch inserts | Bypasses repositories intentionally (no need for sync queue during initial download) |

## Build Order for Fixes

The fixes have dependency relationships that dictate implementation order:

```
1. Standardize sync metadata columns (migration)
   |
   +---> 2. Typed error classification (SyncErrorMapper + SyncError hierarchy)
   |     |
   |     +---> 3. Enhanced SyncService (use SyncErrorMapper, retry policy, pruning)
   |
   +---> 4. SyncCoordinator (gate queue on initial sync)
   |
   +---> 5. Conflict detection in syncFromRemote() methods
         |
         +---> 6. Unified _markEntityAsSynced via SyncableLocalDataSource interface
```

**Phase 1 (Foundation):** Items 1 + 2 -- no behavioral changes, just normalize the schema and add error types.

**Phase 2 (Reliability):** Items 3 + 4 -- the sync service becomes smarter about errors and coordination.

**Phase 3 (Correctness):** Items 5 + 6 -- actual conflict detection and unified sync marking.

## Sources

- [Flutter Official: Offline-first support design pattern](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) -- HIGH confidence (official Flutter docs)
- [Hasura: Design Guide for Building Offline First Apps](https://hasura.io/blog/design-guide-to-offline-first-apps) -- MEDIUM confidence (verified architecture patterns)
- [Android Developers: Build an offline-first app](https://developer.android.com/topic/architecture/data-layer/offline-first) -- MEDIUM confidence (platform-adjacent, architecture principles apply)
- [DevelopersVoice: Offline-First Sync Patterns for Real-World Mobile Networks](https://developersvoice.com/blog/mobile/offline-first-sync-patterns/) -- MEDIUM confidence (multiple patterns verified against Flutter docs)
- [droidcon: Complete Guide to Offline-First Architecture](https://www.droidcon.com/2025/12/16/the-complete-guide-to-offline-first-architecture-in-android/) -- MEDIUM confidence (transactional outbox pattern verified)
- LeadX codebase analysis: `lib/data/services/sync_service.dart`, `lib/data/services/initial_sync_service.dart`, `lib/presentation/providers/sync_providers.dart`, `lib/data/database/tables/*.dart` -- HIGH confidence (direct code inspection)

---
*Architecture research for: LeadX CRM Offline-First Sync Reliability*
*Researched: 2026-02-13*
