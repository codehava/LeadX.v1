# Phase 4: Conflict Resolution - Research

**Researched:** 2026-02-14
**Domain:** Offline-first sync conflict detection, Last-Write-Wins resolution, idempotent operations
**Confidence:** HIGH

## Summary

Phase 4 adds conflict detection and resolution to the existing sync engine. The core problem: when two users (or the same user on two devices) edit the same record while at least one is offline, the push sync must detect the divergence, resolve it deterministically via Last-Write-Wins (LWW), and log the conflict for audit.

The codebase already has most primitives needed: `updatedAt` timestamps on all syncable entities (standardized in Phase 1), `ConflictSyncError` in the sealed error hierarchy, `SyncConflictFailure` in the failure types, and client-generated UUIDs for all entities. The main gaps are: (1) the `_processItem` method in `SyncService` uses raw `insert()` for creates instead of `upsert()`, (2) updates have no version guard (they blindly overwrite via `.update(payload).eq('id', entityId)`), (3) there is no `sync_conflicts` audit table, and (4) there is no conflict count exposed to the UI.

**Primary recommendation:** Modify `SyncService._processItem` to use `upsert()` for creates and add `updated_at` version guard on updates, create a local `SyncConflicts` Drift table for audit logging, and add a conflict count stream provider for the UI.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| drift | (existing) | Local SQLite - sync_conflicts table, conflict queries | Already in project |
| supabase_flutter | (existing) | Supabase upsert(), update with filters | Already in project |
| freezed | (existing) | SyncConflict entity model | Already in project |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| riverpod | (existing) | StreamProvider for conflict count | UI integration |

No new dependencies are needed. All work uses existing libraries.

## Architecture Patterns

### Recommended Changes to Project Structure
```
lib/
├── core/
│   └── errors/
│       └── sync_errors.dart          # Enhance ConflictSyncError with payloads
├── data/
│   ├── database/
│   │   ├── tables/
│   │   │   └── sync_queue.dart       # ADD SyncConflicts table definition
│   │   └── app_database.dart         # Schema v11 migration, register new table
│   ├── datasources/
│   │   └── local/
│   │       └── sync_queue_local_data_source.dart  # ADD conflict logging/querying
│   └── services/
│       └── sync_service.dart         # MODIFY _processItem for upsert + version guard
├── domain/
│   └── entities/
│       └── sync_models.dart          # ADD SyncConflict freezed entity (optional)
└── presentation/
    └── providers/
        └── sync_providers.dart       # ADD conflict count provider
```

### Pattern 1: Idempotent Creates via Supabase Upsert
**What:** Replace `insert(payload)` with `upsert(payload)` in `SyncService._processItem` for create operations.
**When to use:** All create operations during push sync.
**Why:** Client-generated UUIDs mean the `id` primary key is known before pushing. If a create is retried (network timeout, app crash mid-sync), `insert()` would fail with 409 conflict. `upsert()` handles this gracefully -- either inserts if new, or updates if already exists.

**Example:**
```dart
// BEFORE (current code):
case 'create':
  await _supabaseClient.from(tableName).insert(payload);

// AFTER:
case 'create':
  await _supabaseClient.from(tableName).upsert(payload);
```

**Important:** Since all entities use client-generated UUIDs as their primary key (`id`), Supabase's default upsert behavior (conflict on primary key) works correctly without needing `onConflict` parameter. The `id` column in all tables is the primary key.

### Pattern 2: Version Guard on Updates (Optimistic Locking)
**What:** Add an `updated_at` filter to update operations so that the update only succeeds if the server's `updated_at` matches what we expect (the value before our local edit).
**When to use:** All update operations during push sync.
**Why:** Without a version guard, a push update silently overwrites whatever is on the server, even if another user changed it. With the guard, the update returns zero rows if someone else updated the record, which we detect and handle as a conflict.

**Implementation approach:**
The challenge is that the current sync payload already contains the NEW `updated_at` value (set during local write). We need the OLD `updated_at` (the value before the local edit) to use as the version guard. There are two viable approaches:

**Approach A (Recommended): Store `server_updated_at` in the sync queue payload.**
When queueing an update operation, include the server's `updated_at` value (from `lastSyncAt` or the record's previous `updatedAt`) as a separate field in the payload metadata. The sync service extracts this for the version guard.

```dart
// In repository when queueing update:
await _syncService.queueOperation(
  entityType: SyncEntityType.customer,
  entityId: id,
  operation: SyncOperation.update,
  payload: {
    ...syncPayload,
    '_server_updated_at': previousUpdatedAt.toUtcIso8601(), // version guard value
  },
);

// In SyncService._processItem:
case 'update':
  final serverUpdatedAt = payload.remove('_server_updated_at');
  var query = _supabaseClient.from(tableName).update(payload).eq('id', item.entityId);
  if (serverUpdatedAt != null) {
    query = query.eq('updated_at', serverUpdatedAt);
  }
  final result = await query.select();
  if (result.isEmpty) {
    // Conflict detected! Server record was modified by someone else.
    await _handleConflict(item, payload, tableName);
  }
```

**Approach B: Fetch-before-update.** Before pushing, fetch the current server record, compare `updated_at`, and decide. This adds a network round-trip per update, which is slower.

Approach A is recommended because it avoids the extra network call and the version guard data is captured at the moment of the local edit (most accurate).

### Pattern 3: Last-Write-Wins Conflict Resolution
**What:** When a version guard detects conflict (0 rows updated), compare local `updated_at` with server `updated_at`. The higher timestamp wins.
**When to use:** When update push returns 0 rows affected.
**Logic:**

```dart
Future<void> _handleConflict(SyncQueueItem item, Map<String, dynamic> localPayload, String tableName) async {
  // 1. Fetch current server record
  final serverRecord = await _supabaseClient
      .from(tableName).select().eq('id', item.entityId).single();

  final serverUpdatedAt = DateTime.parse(serverRecord['updated_at'] as String);
  final localUpdatedAt = DateTime.parse(localPayload['updated_at'] as String);

  // 2. Log the conflict regardless of winner
  await _logConflict(
    entityType: item.entityType,
    entityId: item.entityId,
    localPayload: localPayload,
    serverPayload: serverRecord,
    localUpdatedAt: localUpdatedAt,
    serverUpdatedAt: serverUpdatedAt,
    winner: localUpdatedAt.isAfter(serverUpdatedAt) ? 'local' : 'server',
  );

  // 3. LWW resolution
  if (localUpdatedAt.isAfter(serverUpdatedAt)) {
    // Local wins - force push (no version guard this time)
    await _supabaseClient.from(tableName)
        .update(localPayload).eq('id', item.entityId);
  } else {
    // Server wins - pull server data to local
    await _applyServerDataLocally(item.entityType, item.entityId, serverRecord);
  }
}
```

### Pattern 4: Conflict Audit Logging
**What:** A local `sync_conflicts` table stores all detected conflicts with before/after payloads.
**When to use:** Every time a version guard detects divergence.

```dart
// New Drift table
class SyncConflicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get localPayload => text()();   // JSON
  TextColumn get serverPayload => text()();  // JSON
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get winner => text()();  // 'local' or 'server'
  TextColumn get resolution => text().withDefault(const Constant('lww'))();
  DateTimeColumn get detectedAt => dateTime()();

  @override
  String get tableName => 'sync_conflicts';
}
```

### Anti-Patterns to Avoid
- **Fetching server record before every update:** Wasteful; use version guard in WHERE clause instead. Only fetch on conflict (the rare case).
- **Silently overwriting on conflict:** The current code does this. Always log the conflict even if LWW resolves automatically.
- **Per-field merge for LWW:** Out of scope per project decisions. Full-payload LWW is the strategy -- the entire record from the winner replaces the loser.
- **Storing conflicts on the server:** The `sync_conflicts` table is local-only audit. Don't sync it. It's for debugging and user visibility.
- **Using `insert()` for creates in push sync:** Must use `upsert()` for idempotency. If a create push times out but actually succeeded, retry with `insert()` would fail with 409.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Idempotent inserts | Custom "check if exists then insert" logic | Supabase `.upsert()` | Atomic, handles race conditions, no extra round-trip |
| Version comparison | String comparison of ISO timestamps | `DateTime.parse()` then `.isAfter()` | Handles timezone normalization, sub-second precision |
| Conflict logging schema | JSON files or print statements | Drift table with typed columns | Queryable, watchable via streams, survives app restart |
| UUID generation | Custom ID schemes | Existing `Uuid().v4()` (already in codebase) | Standard, collision-resistant, already used everywhere |

**Key insight:** The complexity in this phase is not in individual operations but in correctly threading the version guard through the existing sync pipeline. The `_processItem` method is the single choke point where all sync operations pass through, making it the ideal place for conflict detection.

## Common Pitfalls

### Pitfall 1: Timestamp Precision Mismatch
**What goes wrong:** Local `DateTime` has microsecond precision, PostgreSQL `timestamptz` has microsecond precision, but JSON serialization via `.toIso8601String()` may truncate. If the version guard compares a truncated local timestamp against a full-precision server timestamp, they won't match even for the same record.
**Why it happens:** Different serialization paths produce different precision.
**How to avoid:** Always use `.toUtcIso8601()` (already the project standard) for timestamps in both payloads and version guards. Ensure the `_server_updated_at` value stored in the sync queue is the exact string received from the server (not re-parsed and re-serialized).
**Warning signs:** Version guard returns 0 rows for records that haven't actually been modified by anyone else.

### Pitfall 2: Coalesced Operations Lose Version Guard
**What goes wrong:** Queue coalescing (create+update -> create with updated payload) could lose the `_server_updated_at` metadata if the coalescing logic doesn't preserve it.
**Why it happens:** The coalescing logic in `SyncService.queueOperation` replaces payloads. If a create is coalesced with an update, the `_server_updated_at` from the update's payload might get dropped.
**How to avoid:** For create+update coalescing, the version guard is irrelevant (the record was just created locally, so there's nothing on the server to conflict with -- it will be upserted). For update+update coalescing, keep the `_server_updated_at` from the FIRST update (that's the server state we expect).
**Warning signs:** Coalesced updates always trigger false conflict detection.

### Pitfall 3: Pull Sync Overwriting Pending Local Changes
**What goes wrong:** During pull sync, `upsertCustomers()` (local Drift upsert) overwrites a record that has `isPendingSync=true` with server data, losing the local edit.
**Why it happens:** The current pull sync does `insertAllOnConflictUpdate` without checking `isPendingSync`.
**How to avoid:** During pull, skip records where `isPendingSync=true` in the local database. These have local changes that haven't been pushed yet. Let push happen first (Phase 6 will enforce push-before-pull ordering). For now, add a guard in the local upsert.
**Warning signs:** User's offline edits disappear after pull sync completes.

### Pitfall 4: Creating a ConflictSyncError for LWW-Resolved Conflicts
**What goes wrong:** If the version guard triggers a `ConflictSyncError`, the existing `processQueue` error handler marks it as a permanent failure (non-retryable). But with LWW, the conflict IS resolved -- it shouldn't fail the queue item.
**Why it happens:** `ConflictSyncError.isRetryable` is `false`, and the handler calls `markAsFailed()`.
**How to avoid:** Handle conflict resolution WITHIN `_processItem` (resolve via LWW, log to audit table), then let the item proceed as successful. Only throw `ConflictSyncError` if LWW resolution itself fails (e.g., can't fetch server record, can't write back).
**Warning signs:** Successfully LWW-resolved conflicts show up as failed sync items.

### Pitfall 5: Supabase `onConflict` Parameter Bug
**What goes wrong:** There's a known bug in the Supabase Flutter SDK where `onConflict` parameter on `upsert()` may not be properly passed through to the PostgREST API.
**Why it happens:** SDK implementation issue (GitHub issue #1227).
**How to avoid:** For this project, we don't need `onConflict` -- all entities use `id` (UUID) as their primary key, which is Supabase's default conflict column for upsert. The default behavior is correct for our use case.
**Warning signs:** 409 errors when using upsert with custom `onConflict` columns.

## Code Examples

### Example 1: Modified _processItem with Upsert and Version Guard

```dart
// Source: Synthesized from codebase analysis + Supabase docs
Future<void> _processItem(SyncQueueItem item) async {
  final Map<String, dynamic> payload;
  try {
    payload = jsonDecode(item.payload) as Map<String, dynamic>;
  } on FormatException catch (e) {
    throw FormatException('Invalid JSON payload for ${item.entityType}/${item.entityId}: $e');
  }

  final tableName = _getTableName(item.entityType);

  try {
    switch (item.operation) {
      case 'create':
        // Idempotent: upsert instead of insert
        await _supabaseClient.from(tableName).upsert(payload);

      case 'update':
        // Extract version guard metadata (added by repository when queueing)
        final serverUpdatedAt = payload.remove('_server_updated_at') as String?;

        if (serverUpdatedAt != null) {
          // Optimistic locking: only update if server record hasn't changed
          final result = await _supabaseClient
              .from(tableName)
              .update(payload)
              .eq('id', item.entityId)
              .eq('updated_at', serverUpdatedAt)
              .select();

          if ((result as List).isEmpty) {
            // Version guard failed - conflict detected
            await _resolveConflict(item, payload, tableName);
          }
        } else {
          // Fallback: no version guard (legacy queue items)
          await _supabaseClient
              .from(tableName)
              .update(payload)
              .eq('id', item.entityId);
        }

      case 'delete':
        if (item.entityType == 'customerHvcLink') {
          await _supabaseClient.from(tableName).delete().eq('id', item.entityId);
        } else {
          await _supabaseClient.from(tableName).update({
            'deleted_at': DateTime.now().toUtcIso8601(),
          }).eq('id', item.entityId);
        }

      default:
        throw ArgumentError('Unknown operation: ${item.operation}');
    }
  } on PostgrestException catch (e, st) {
    // ... existing error mapping ...
  }
}
```

### Example 2: Conflict Resolution Method

```dart
Future<void> _resolveConflict(
  SyncQueueItem item,
  Map<String, dynamic> localPayload,
  String tableName,
) async {
  _log.warning('sync.push | Conflict detected for ${item.entityType}/${item.entityId}');

  // Fetch current server state
  final serverRecord = await _supabaseClient
      .from(tableName)
      .select()
      .eq('id', item.entityId)
      .maybeSingle();

  if (serverRecord == null) {
    // Record was deleted on server - treat as server wins
    _log.warning('sync.push | Server record deleted, removing local: ${item.entityId}');
    return;
  }

  final serverUpdatedAt = DateTime.parse(serverRecord['updated_at'] as String);
  final localUpdatedAt = DateTime.parse(localPayload['updated_at'] as String);
  final winner = localUpdatedAt.isAfter(serverUpdatedAt) ? 'local' : 'server';

  // Log conflict to audit table
  await _logConflict(
    entityType: item.entityType,
    entityId: item.entityId,
    localPayload: jsonEncode(localPayload),
    serverPayload: jsonEncode(serverRecord),
    localUpdatedAt: localUpdatedAt,
    serverUpdatedAt: serverUpdatedAt,
    winner: winner,
  );

  if (winner == 'local') {
    // Local wins - force update without version guard
    await _supabaseClient
        .from(tableName)
        .update(localPayload)
        .eq('id', item.entityId);
    _log.info('sync.push | Conflict resolved: LOCAL wins for ${item.entityType}/${item.entityId}');
  } else {
    // Server wins - update local DB with server data
    await _applyServerDataLocally(item.entityType, item.entityId, serverRecord);
    _log.info('sync.push | Conflict resolved: SERVER wins for ${item.entityType}/${item.entityId}');
  }
}
```

### Example 3: Drift Schema Migration for SyncConflicts Table

```dart
// In app_database.dart migration:
if (from < 11) {
  await m.createTable(syncConflicts);
}
```

### Example 4: Queueing Update with Version Guard Metadata

```dart
// In CustomerRepositoryImpl.updateCustomer:
final updated = await _database.transaction(() async {
  // Read current state BEFORE writing (for version guard)
  final existing = await _localDataSource.getCustomerById(id);
  if (existing == null) return null;

  // The server_updated_at is the existing record's updatedAt
  // (which was set from the server during last pull sync)
  final serverUpdatedAt = existing.updatedAt;

  await _localDataSource.updateCustomer(id, companion);

  final data = await _localDataSource.getCustomerById(id);
  if (data == null) return null;

  await _syncService.queueOperation(
    entityType: SyncEntityType.customer,
    entityId: id,
    operation: SyncOperation.update,
    payload: {
      ..._createUpdateSyncPayload(data),
      '_server_updated_at': serverUpdatedAt.toUtcIso8601(),
    },
  );

  return data;
});
```

### Example 5: Conflict Count Provider

```dart
// In sync_providers.dart:
final conflictCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  // Count conflicts from last 7 days
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  return (db.select(db.syncConflicts)
    ..where((t) => t.detectedAt.isBiggerOrEqualValue(cutoff)))
    .watch()
    .map((conflicts) => conflicts.length);
});
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `insert()` for creates | `upsert()` for idempotency | This phase | Retrying creates no longer causes 409 errors |
| Blind update (no guard) | `updated_at` version guard | This phase | Conflicts detected instead of silently overwritten |
| No conflict logging | Local `sync_conflicts` audit table | This phase | Conflicts traceable for debugging |
| `ConflictSyncError` unused | Used as fallback when LWW resolution fails | This phase | Error hierarchy fully utilized |

**Current state of code:**
- `SyncService._processItem` line 251: `insert(payload)` -- needs `upsert(payload)`
- `SyncService._processItem` line 253-256: `.update(payload).eq('id', ...)` -- needs version guard
- `ConflictSyncError` exists but is only thrown for HTTP 409 from PostgrestException -- needs to be part of conflict resolution flow
- `SyncConflictFailure` exists in failures.dart -- ready to use
- All sync payloads already include `updated_at` -- ready for version guard

## Open Questions

1. **Pull sync conflict with pending local changes**
   - What we know: Pull sync currently uses `insertAllOnConflictUpdate` which overwrites local records regardless of `isPendingSync` status.
   - What's unclear: Should we add an `isPendingSync` guard to pull sync in this phase, or defer to Phase 6 (Sync Coordination) which enforces push-before-pull ordering?
   - Recommendation: Add a lightweight guard in this phase (skip pull-overwrite for `isPendingSync=true` records), but defer the full push-before-pull serialization to Phase 6. Document the interaction.

2. **Timestamp precision edge case**
   - What we know: PostgreSQL `timestamptz` stores microseconds. Dart `DateTime` supports microseconds. The `toUtcIso8601()` extension preserves milliseconds.
   - What's unclear: Are there edge cases where truncation causes false conflicts?
   - Recommendation: Use the raw server timestamp string (from the JSON response) directly as the version guard value, avoiding any parse/re-serialize cycle. LOW risk.

3. **Conflict count UI placement**
   - What we know: Success criterion 5 requires "count of recent conflicts in sync status UI."
   - What's unclear: Where exactly should this appear?
   - Recommendation: Add it as a small indicator near the existing sync status display. Phase 7 (Offline UX Polish) will handle detailed UI. For this phase, just expose the `StreamProvider<int>` and add a minimal text display.

4. **Delete operation conflicts**
   - What we know: Delete operations currently use soft-delete (setting `deleted_at`). No version guard is applied.
   - What's unclear: Should delete operations also have version guards?
   - Recommendation: No. Deletes are rare and the soft-delete pattern is inherently safe (setting `deleted_at` is idempotent). If someone edited a record that another user soft-deleted, the edit will show up during next pull anyway. Keep delete operations simple.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `lib/data/services/sync_service.dart` -- current push sync implementation
- Codebase analysis: `lib/core/errors/sync_errors.dart` -- existing `ConflictSyncError`
- Codebase analysis: `lib/core/errors/failures.dart` -- existing `SyncConflictFailure`
- Codebase analysis: `lib/data/database/app_database.dart` -- schema v10, migration patterns
- Codebase analysis: `lib/data/repositories/customer_repository_impl.dart` -- sync payload construction
- [Supabase Dart Upsert Docs](https://supabase.com/docs/reference/dart/upsert) -- upsert API, onConflict, ignoreDuplicates
- [Supabase Dart Update Docs](https://supabase.com/docs/reference/dart/update) -- update with filter chaining

### Secondary (MEDIUM confidence)
- [Supabase Flutter SDK Issue #1227](https://github.com/supabase/supabase-flutter/issues/1227) -- onConflict parameter bug (not relevant since we use default PK conflict)
- Optimistic locking patterns from PostgreSQL documentation -- standard `UPDATE ... WHERE version = expected` pattern

### Tertiary (LOW confidence)
- None. All findings verified against codebase and official docs.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new libraries needed, all existing
- Architecture: HIGH - clear patterns from codebase analysis, well-understood LWW semantics
- Pitfalls: HIGH - identified from actual code paths in sync_service.dart and repository implementations
- Version guard approach: MEDIUM - the `_server_updated_at` metadata approach is sound but needs careful threading through coalescing logic

**Research date:** 2026-02-14
**Valid until:** 2026-03-14 (stable domain, no fast-moving dependencies)
