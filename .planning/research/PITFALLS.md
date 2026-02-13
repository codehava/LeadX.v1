# Pitfalls Research

**Domain:** Offline-first CRM sync reliability (Flutter/Drift/Supabase)
**Researched:** 2026-02-13
**Confidence:** HIGH (verified against codebase, official docs, and multiple community sources)

## Critical Pitfalls

These are mistakes that cause data loss, corrupt state, or require rewrites. Every one of them has evidence in this codebase or direct parallels observed in the Flutter offline-first ecosystem.

### Pitfall 1: Full-Table Pull Sync on Every Bidirectional Sync

**What goes wrong:**
Every call to `_pullFromRemote()` in `SyncNotifier` calls `syncFromRemote()` **without a `since` parameter** for customers, key persons, pipelines, activities, and most other entities. This means every sync downloads the entire dataset from Supabase for every entity type. The remote data sources all support `since` via `.gte('updated_at', since.toIso8601String())`, but the parameter is never passed. As the dataset grows, each sync takes progressively longer, uses more bandwidth, and increases the window for mid-sync failures.

**Why it happens:**
Delta sync requires tracking the last successful pull timestamp per entity type. This was implemented for `InitialSyncService._deltaSyncTables` (hvcs, brokers, customer_hvc_links, pipeline_referrals) using `AppSettingsService.getTableLastSyncAt()`, but the regular bidirectional sync in `SyncNotifier._pullFromRemote()` never adopted the same pattern. The omission was likely a "get it working first" shortcut that was never revisited.

**How to avoid:**
- Store `last_pull_sync_at` per entity type in `AppSettings` (the key-value table already exists).
- After a successful pull for each entity type, update the timestamp.
- Pass `since: lastPullSyncAt` to every `syncFromRemote()` call.
- On first sync or after schema migration, pass `null` to do a full pull.
- Use server timestamps (`now()` from PostgreSQL) rather than client `DateTime.now()` to avoid clock skew.

**Warning signs:**
- Sync takes longer than 5 seconds on subsequent syncs (should be near-instant if no changes).
- Network usage monitoring shows large payloads on routine syncs.
- Supabase dashboard shows high read counts on the `customers`/`pipelines` tables.

**Phase to address:**
Phase 1 (Sync Engine Stabilization) -- this is foundational and everything else depends on it.

---

### Pitfall 2: Sync Queue Operation Ordering and Coalescing Destroys Create-Then-Update Sequences

**What goes wrong:**
The current `queueOperation()` method in `SyncService` coalesces updates by removing the old operation when `hasPending` is true and the new operation is an `update`. But it does NOT handle the critical case: a `create` followed by an `update` for the same entity. If a user creates a customer offline, then immediately edits it, the coalescing logic removes the `create` from the queue and replaces it with an `update`. When the sync runs, it tries to `update` a record on Supabase that was never `insert`ed, causing a silent failure (Supabase `update().eq('id', ...)` on a non-existent row succeeds with 0 rows affected, no error thrown).

**Why it happens:**
The `hasPendingOperation` check returns `true` for any pending operation regardless of operation type. The `removeOperation` call then deletes whatever was there (the `create`), and the new `update` is inserted. The code assumes "the latest write is all that matters" but ignores that create/update/delete have different semantics on the server.

**How to avoid:**
- When coalescing: if existing operation is `create` and new is `update`, merge the update payload into the create payload (keep operation as `create`).
- When coalescing: if existing is `create` and new is `delete`, remove both (the record never needs to reach the server).
- When coalescing: if existing is `update` and new is `update`, replace payload (current behavior is correct).
- When coalescing: if existing is `update` and new is `delete`, replace with `delete`.
- Add the existing operation type to the `hasPendingOperation` query result so the coalescing logic can make informed decisions.

**Warning signs:**
- Items created offline appear locally but vanish after sync completes (the local record has `isPendingSync: false` but server never received it).
- Sync reports 100% success but server table has fewer records than local.
- Debug logs show `update` operations for entity IDs that don't exist on the server.

**Phase to address:**
Phase 1 (Sync Engine Stabilization) -- data integrity depends on this.

---

### Pitfall 3: No Conflict Resolution Strategy -- Last-Write-Wins Without Checking

**What goes wrong:**
The current system has no conflict detection or resolution. When pushing local changes, the `SyncService._processItem()` does a raw `insert` or `update` on Supabase without checking if the server version has changed since the local copy was last synced. When pulling, `syncFromRemote()` does `upsertCustomers()` which overwrites local data unconditionally. If two users edit the same customer offline, whichever syncs last wins, with no indication that the other user's changes were lost.

The `SyncConflictException` class exists in `exceptions.dart` but is never thrown anywhere in the codebase. Similarly, `SyncConflictFailure` exists but is never instantiated.

**Why it happens:**
Conflict resolution is genuinely hard, and the team correctly deferred it. But the exception/failure classes create a false sense of security -- they suggest conflict handling exists when it does not.

**How to avoid:**
- Implement server-side conflict detection: add a `version` column (integer, incrementing) or use `updated_at` comparison on Supabase. Before upserting, check `WHERE id = ? AND updated_at <= ?`. If no rows match, a conflict occurred.
- For this CRM domain, last-write-wins is acceptable for most fields, but it must be **explicit** last-write-wins with logging, not **silent** overwriting.
- At minimum: log conflicts to an audit table so they can be reviewed.
- For high-value entities (pipelines with monetary values), consider field-level merging or flagging conflicts for manual resolution.

**Warning signs:**
- Users report that their edits "disappeared" after sync.
- Pipeline values change unexpectedly (one RM's update clobbers another's).
- Audit trail shows gaps where changes were overwritten.

**Phase to address:**
Phase 2 (after sync engine is stable) -- conflict resolution requires a working sync engine first.

---

### Pitfall 4: Inconsistent Sync Timestamp Column Names Cause Silent Failures

**What goes wrong:**
The codebase uses three different names for the "when was this last synced" column:
- `lastSyncAt` (customers, pipelines, cadence_participants, pipeline_referrals)
- `syncedAt` (activities)
- No sync timestamp at all (key_persons, hvcs, customer_hvc_links, brokers)

The `_markEntityAsSynced()` method in `SyncService` has entity-specific switch cases that handle each naming convention separately. Some entities (like `cadenceConfig`) are completely skipped with just a `debugPrint`. If a new entity type is added to `SyncEntityType` but not to `_markEntityAsSynced()`, the entity silently falls through to the `default` case, which only prints a debug message -- no error, no crash, no indication that data is stuck as "pending sync" forever.

**Why it happens:**
The schema evolved organically. Different developers added tables at different times with different naming conventions. The switch statement grew to accommodate each one, but there is no compile-time safety.

**How to avoid:**
- Standardize on a single column name (`last_sync_at`) across all syncable tables via a Drift migration.
- Replace the entity-type switch statement with a generic approach: a mapping of `SyncEntityType` to table reference, so `_markEntityAsSynced` is a single codepath.
- Add a compile-time or test-time check: for every value in `SyncEntityType`, verify that `_markEntityAsSynced`, `_getTableName`, and `_processItem` all handle it.
- Similarly standardize `_getTableName()` -- if a new entity type is added to the enum but not the mapping, it throws at runtime.

**Warning signs:**
- Entities stuck in `isPendingSync: true` state permanently.
- Sync badge showing pending count that never decreases.
- New entity types added but sync doesn't work for them (no error, just stuck).

**Phase to address:**
Phase 1 (Sync Engine Stabilization) -- prerequisite for reliable delta sync.

---

### Pitfall 5: Refactoring Sync While Users Have Pending Queue Items

**What goes wrong:**
When you change the sync payload format, queue processing logic, or entity type names, any items already in the `sync_queue` table become incompatible with the new code. The JSON payload stored in the queue was serialized with the old format. If you rename a field from `customer_id` to `customerId` in the sync payload, existing queue items will fail to sync because the server expects the old format (or vice versa).

Worse: if you change the `entityType` string values (e.g., from `'customerHvcLink'` to `'customer_hvc_link'`), the `_getTableName()` switch will throw `ArgumentError` for old queue items.

**Why it happens:**
Developers test with empty queues. In production, users may have accumulated days of unsynced operations while offline. The refactored code processes their old payloads and breaks.

**How to avoid:**
- Before deploying sync refactors, add a migration step that either:
  1. Processes all pending queue items with the OLD code first (drain the queue).
  2. Transforms existing queue payloads to match the new format.
- Test with pre-populated sync queues containing items in the old format.
- Keep backward compatibility in `_processItem()` for at least one version cycle.
- Add a queue format version field to `SyncQueueItems` so the processor knows which format to use.

**Warning signs:**
- After app update, sync starts failing for some users but not others (those with empty queues are fine).
- `FormatException` or `ArgumentError` in sync processing logs.
- Users who were offline during the update lose all pending changes.

**Phase to address:**
Phase 1 (Sync Engine Stabilization) -- must be addressed BEFORE any payload format changes.

---

### Pitfall 6: Race Condition Between Push and Pull in Bidirectional Sync

**What goes wrong:**
`SyncNotifier.triggerSync()` runs push (Step 1) then pull (Step 4) sequentially. But during the pull phase, the app may also queue new local operations (the user is still interacting with the UI). The pull then overwrites local data with server data, but the sync queue still contains the user's new operations referencing the pre-pull state. When those queued operations are later pushed, they may send stale data back to the server.

Additionally, `unawaited(_syncService.triggerSync())` is called from every repository write operation (create, update, delete). This means a user rapidly creating entities could trigger multiple concurrent `processQueue()` calls. The `_isSyncing` guard prevents parallel execution but can cause the second trigger to silently return without processing the newly queued item.

**Why it happens:**
The `unawaited()` fire-and-forget pattern for `triggerSync()` makes every write optimistically kick off a sync. This is good for UX but creates timing windows where the queue state and the database state diverge.

**How to avoid:**
- Debounce sync triggers: instead of calling `triggerSync()` on every write, batch triggers with a short delay (e.g., 500ms). If another write comes in during the delay window, reset the timer.
- Lock entity rows during push: when a push is in progress for entity X, mark it so pull does not overwrite it until the push completes.
- After pull completes, re-check if new items were queued during the pull and process them.
- Consider implementing a sync lock per entity rather than a global `_isSyncing` flag.

**Warning signs:**
- Intermittent data "flickering" in the UI (value changes then reverts then changes again).
- Debug logs showing "Sync already in progress, returning" frequently.
- Data inconsistencies that only appear under rapid user interaction.

**Phase to address:**
Phase 1 (Sync Engine Stabilization) -- the debouncing alone eliminates most symptoms.

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| `unawaited(_syncService.triggerSync())` on every write | Instant sync attempt after each operation | Thundering herd of sync attempts, wasted battery, race conditions | Never in production -- replace with debounced trigger |
| Generic `catch (e)` wrapping all sync operations in `_pullFromRemote` | Prevents one entity failure from blocking others | Errors are swallowed silently, no aggregation, no user notification, no retry strategy | Acceptable during early development only |
| Using `DateTime.now()` for both client timestamps and sync watermarks | Simple, no server round-trip needed | Clock skew between client and server causes missed records in delta sync, or duplicate processing | Never for sync watermarks -- use server time. Acceptable for local-only timestamps |
| Storing full entity payload in sync queue JSON | Simple serialization, no joins needed at sync time | Queue grows large with redundant data, stale payloads if entity is updated again before sync | Only if queue items are actively coalesced |
| In-memory lookup caches without TTL or size limits | Fast name resolution for UI mapping | Memory grows unbounded, stale data after sync if invalidation is missed | Acceptable at current scale (<1000 records per type), must add limits before scaling |

## Integration Gotchas

Common mistakes when connecting to external services in this stack.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Supabase `.insert()` | Assuming a 4xx error on duplicate key -- actually Supabase returns a PostgrestException with code `23505` for unique violations, but the current code catches generic `Exception` | Catch `PostgrestException` specifically, check `code` field, and handle `23505` (duplicate) differently from `42501` (RLS violation) |
| Supabase `.update().eq()` on non-existent row | Assuming this throws an error -- it silently succeeds with 0 rows affected | Use `.update().eq().select()` and check the response length, or use `.upsert()` for idempotent operations |
| Supabase RLS policies | Assuming client-side errors mean "no permission" -- actually RLS returns empty results, not errors, for `SELECT` operations that are filtered by policy | When a `syncFromRemote()` returns 0 records, distinguish between "no data" and "RLS blocked all results" by checking if the user has the expected role/scope |
| Connectivity service polling | Querying `app_settings` table every 30 seconds as a health check -- this counts as API usage and can hit Supabase rate limits | Use a lightweight endpoint like Supabase's `/rest/v1/` base URL with HEAD request, or use the Supabase realtime heartbeat |
| Drift batch operations | Using `InsertMode.insertOrReplace` which deletes then re-inserts, potentially breaking foreign key references and resetting auto-increment IDs | Use `DoUpdate` with Drift's `onConflict` parameter for proper upsert behavior that preserves row identity |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| N+1 queries in lookup cache loading | `_ensureCachesLoaded()` fires separate queries per cache (stage names, status names, cob names, etc.) | Combine into a single query per repository, or use Drift joins to resolve names at query time | >500 pipelines with 10+ caches = 10+ queries per stream emission |
| Full-table `SELECT *` in `watchAllCustomers()` | Growing memory usage, slow stream emissions | Add pagination to list providers, only fetch visible records, use `LIMIT` in queries | >2000 customers -- initial load exceeds 1 second |
| Unbounded sync queue | Queue grows indefinitely if device stays offline for extended periods; `getRetryableItems()` fetches ALL items at once | Add queue size limits (e.g., 1000 items max), add `created_at` TTL (purge items older than 7 days), process in batches of 50 | >500 queue items -- sync takes minutes and may timeout |
| Sequential entity-by-entity pull sync | Each entity type's `syncFromRemote()` runs sequentially in `_pullFromRemote()` | Parallelize independent pulls using `Future.wait()` for entities without FK dependencies (e.g., customers and activities can pull simultaneously) | >8 entity types * network latency = 10+ seconds per sync |
| Stream-based providers with `asyncMap` for cache lookups | Every emission from Drift triggers cache check + re-mapping of the entire list | Pre-join data in the SQL query so no async mapping is needed, or use indexed lookups instead of full cache rebuilds | >100 items in a list with frequent DB changes (e.g., during sync) |

## Security Mistakes

Domain-specific security issues for this offline-first CRM.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Storing Supabase anon key in `.env` bundled as asset | Key is extractable from APK/IPA; if RLS policies are misconfigured, attackers can read/write data | Accept this as a known Supabase pattern BUT ensure RLS policies are ironclad; add server-side rate limiting; never store `service_role` key client-side (already correctly using Edge Functions for admin ops) |
| No JWT expiry handling during long offline periods | If a user is offline for >1 hour (default JWT expiry), their token expires; when they come back online, sync fails with auth errors but the error is caught generically | Check `supabase.auth.currentSession?.expiresAt` before sync; if expired, trigger token refresh before processing queue; handle `AuthException` specifically in sync error handling |
| Sync payload contains full entity data including fields user shouldn't modify | A malicious client could modify the sync payload in the queue to change `assigned_rm_id` or `created_by` fields they shouldn't control | Use Supabase database triggers or RLS policies to enforce which fields each role can modify; don't rely on client-side payload construction for security |
| Local SQLite database is unencrypted | On rooted/jailbroken devices, customer PII (names, emails, phone numbers, NPWP tax IDs) is readable from the SQLite file | Use `sqlcipher_flutter_libs` for encrypted SQLite; at minimum, document this as an accepted risk for the current deployment context |

## UX Pitfalls

Common user experience mistakes in offline-first CRM domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Showing sync errors as toasts/snackbars that disappear | Users miss critical sync failures, think their data is saved when it isn't | Use a persistent sync status indicator (already partially implemented via `pendingSyncCountProvider`); add a dedicated sync status screen showing queue details |
| No indication of which records are pending sync | Users can't tell which customers/pipelines they edited offline vs. which are confirmed on server | Show a subtle "pending" badge or indicator on list items where `isPendingSync == true` (domain entities already expose this field) |
| Blocking UI during sync | Users can't work while waiting for large sync to complete | Current implementation is non-blocking (good), but ensure pull sync doesn't lock UI thread -- large batch upserts should run in isolates or be chunked |
| Silent failure on permanent sync errors (retry count exceeded) | Items sit in queue forever at maxRetries, user never knows | When items exceed retry count, surface them to the user with a "retry" or "discard" option; provide a manual queue management UI |
| Sync triggered only on user action or 5-minute timer | Data could be 5 minutes stale; newly online device doesn't sync immediately | Listen to connectivity changes and trigger sync immediately when coming back online (partially implemented but the `ConnectivityService` listener doesn't auto-trigger sync on reconnect) |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Delta sync:** Repository interfaces accept `since` parameter -- but `SyncNotifier._pullFromRemote()` never passes it. Every pull is a full sync. Verify actual delta behavior with network monitoring.
- [ ] **Conflict resolution:** `SyncConflictException` and `SyncConflictFailure` classes exist -- but are never instantiated anywhere. No actual conflict detection logic exists. Search for `SyncConflictException` and `SyncConflictFailure` usage.
- [ ] **Retry with backoff:** `maxRetries` and `baseDelayMs` constants exist -- but exponential backoff is never applied. `incrementRetryCount()` increments the counter but `processQueue()` does not delay between retries based on the count. Items are retried immediately on the next `processQueue()` call.
- [ ] **Queue coalescing:** `hasPendingOperation` and `removeOperation` exist -- but only handle the `update` case. Create-then-update and create-then-delete sequences are not handled, leading to data loss (see Pitfall 2).
- [ ] **Error categorization:** Rich exception hierarchy exists (`NetworkException`, `ServerException`, `SyncException`, etc.) -- but `_processItem()` catches only `SocketException` and `TimeoutException`, throwing generic `Exception` for everything else. The exception hierarchy is unused in sync processing.
- [ ] **Sync state stream:** `SyncState` has `idle`, `syncing`, `success`, `error`, `offline` states -- but after a partial failure (some items succeed, some fail), state goes to `idle` instead of `error`, hiding the failure from the UI.
- [ ] **Background sync on reconnect:** `ConnectivityService` streams connectivity changes -- but no listener triggers `processQueue()` when connectivity is restored. Only the 5-minute timer and manual triggers process the queue.
- [ ] **Pagination on pull:** Remote data sources support pagination for brokers (`_syncBrokers` in `InitialSyncService`) -- but regular `syncFromRemote()` in repository implementations does not paginate, risking Supabase's default 1000-row limit.

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Sync queue corruption (bad payloads) | MEDIUM | Add a "reset sync queue" admin action that clears the queue and forces full re-sync from server. Ensure local data is preserved (only queue is cleared). |
| Data divergence (local and remote out of sync) | HIGH | Implement a "reconciliation sync" mode: pull ALL data from server with `since: null`, compare with local, generate a diff report, apply server state as authoritative. Notify user of any local changes that were overwritten. |
| Stuck pending items (maxRetries exceeded) | LOW | Add a scheduled cleanup job that flags items exceeding retry limit. Provide user-facing UI to retry or discard. Consider auto-discarding items older than configurable TTL (7 days). |
| Schema migration breaks existing queue | HIGH | Must be handled BEFORE migration runs: drain queue first, or transform payloads. If already broken: clear queue, force full re-sync. Users lose unsynced changes (document this risk). |
| Clock skew causes missed records in delta sync | MEDIUM | Use server-side `now()` for sync timestamps instead of client `DateTime.now()`. For existing data: one-time full re-sync to establish correct baseline. |
| Memory pressure from large caches | LOW | Add cache size limits and LRU eviction. If crash occurs: caches are rebuilt from DB on next access (already the case since caches are nullable with lazy init). |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Full-table pull sync (Pitfall 1) | Phase 1: Sync Engine | Network monitoring shows <10KB payload on incremental sync with no changes |
| Queue coalescing errors (Pitfall 2) | Phase 1: Sync Engine | Integration test: create entity offline, update it, sync, verify server has the entity with updated values |
| No conflict resolution (Pitfall 3) | Phase 2: Conflict Handling | Integration test: two clients edit same entity, both sync, both receive conflict notification |
| Inconsistent timestamp columns (Pitfall 4) | Phase 1: Sync Engine | `grep -r "isPendingSync" lib/data/database/tables/` shows all syncable tables have `lastSyncAt` column |
| Queue format migration (Pitfall 5) | Phase 1: Sync Engine (prereq) | Test with pre-populated queue from current format, verify items process after code changes |
| Push-pull race condition (Pitfall 6) | Phase 1: Sync Engine | Automated test: write during pull, verify no data loss. Manual test: rapid creates during sync |
| N+1 cache queries | Phase 3: Performance | Profile sync with 1000+ entities, verify <5 SQL queries per entity type |
| JWT expiry during offline | Phase 2: Error Handling | Test: go offline >1 hour, come back online, verify sync succeeds after token refresh |
| Unbounded sync queue | Phase 1: Sync Engine | Load test: queue 2000 items, verify batch processing and memory stability |
| Silent partial failure | Phase 2: Error Handling | UI test: simulate 50% item failure, verify error state shown to user |

## Sources

- [Flutter official offline-first design pattern documentation](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) - MEDIUM confidence (official docs)
- [Drift documentation on migrations](https://drift.simonbinder.eu/migrations/) - HIGH confidence (official library docs)
- [PowerSync: SQLite optimizations for ultra-high performance](https://www.powersync.com/blog/sqlite-optimizations-for-ultra-high-performance) - MEDIUM confidence
- [Supabase offline-first Flutter with Brick](https://supabase.com/blog/offline-first-flutter-apps) - MEDIUM confidence (official Supabase blog)
- [Offline-first mobile sync queue architecture](https://beefed.ai/en/offline-first-queueing-sync) - LOW confidence (single source)
- [Android offline-first architecture complete guide (droidcon)](https://www.droidcon.com/2025/12/16/the-complete-guide-to-offline-first-architecture-in-android/) - MEDIUM confidence (cross-platform patterns apply)
- [Offline-first architecture: designing for reality](https://medium.com/@jusuftopic/offline-first-architecture-designing-for-reality-not-just-the-cloud-e5fd18e50a79) - LOW confidence (single source)
- [Common SQLite mistakes Flutter developers make](https://medium.com/@sparkleo/common-sqlite-mistakes-flutter-devs-make-and-how-to-avoid-them-1102ab0117d5) - MEDIUM confidence
- Direct codebase analysis of `SyncService`, `SyncNotifier`, `CustomerRepositoryImpl`, `PipelineRepositoryImpl`, `ActivityRepositoryImpl`, `InitialSyncService`, `ConnectivityService`, and all Drift table definitions - HIGH confidence

---
*Pitfalls research for: LeadX CRM offline-first sync reliability*
*Researched: 2026-02-13*
