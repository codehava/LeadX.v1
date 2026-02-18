---
phase: 05-background-sync-dead-letter-queue
plan: 01
subsystem: sync
tags: [drift, sqlite, dead-letter, queue, pruning, offline-first]

# Dependency graph
requires:
  - phase: 03-error-classification-recovery
    provides: "Sealed SyncError hierarchy with isRetryable classification"
  - phase: 04-conflict-resolution
    provides: "sync_conflicts table, version guard metadata, LWW resolution"
provides:
  - "status column on sync_queue (pending/failed/dead_letter lifecycle)"
  - "Migration v12 with status column and backfill"
  - "Dead letter management methods (markAsDeadLetter, watchDeadLetterCount, getDeadLetterItems, discardDeadLetterItem)"
  - "Queue pruning (orphaned items 7d, expired dead letters 30d, old sync_conflicts 30d)"
  - "Status-based processQueue filtering (dead_letter excluded from processing)"
  - "discardDeadLetterItem + _markEntityAsLocalOnly on SyncService"
  - "deadLetterCountProvider and lastSyncTimestampProvider"
affects: [05-02, 05-03]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Status lifecycle on sync queue: pending -> failed -> dead_letter (no completed - deleted on success)"
    - "Non-retryable errors immediately dead-letter instead of silent reprocessing"
    - "Post-sync pruning pattern: orphans + expired dead letters + old conflicts"

key-files:
  created: []
  modified:
    - "lib/data/database/tables/sync_queue.dart"
    - "lib/data/database/app_database.dart"
    - "lib/data/database/app_database.g.dart"
    - "lib/data/datasources/local/sync_queue_local_data_source.dart"
    - "lib/data/services/sync_service.dart"
    - "lib/presentation/providers/sync_providers.dart"
    - "test/helpers/mock_sync_infrastructure.dart"

key-decisions:
  - "No 'completed' status -- completed items are deleted immediately via markAsCompleted()"
  - "isPendingSync on entity is implicitly true for all unsynced items (set on queue creation, only cleared on sync success or discard)"
  - "_markEntityAsLocalOnly sets isPendingSync=false and lastSyncAt=null to indicate local-only state"
  - "Pruning wrapped in try/catch to prevent pruning errors from blocking sync result"

patterns-established:
  - "Dead letter lifecycle: non-retryable errors immediately dead-letter; retryable errors dead-letter after maxRetries exhausted"
  - "Post-sync pruning: called after every processQueue() run"
  - "Entity local-only marking: isPendingSync=false, lastSyncAt=null indicates 'exists locally, never synced'"

requirements-completed: [SYNC-06, CONF-02]

# Metrics
duration: 10min
completed: 2026-02-18
---

# Phase 05 Plan 01: Dead Letter Queue Summary

**Dead letter status tracking on sync queue with non-retryable error classification, pruning lifecycle, and reactive dead letter count provider**

## Performance

- **Duration:** 10 min
- **Started:** 2026-02-18T18:20:49Z
- **Completed:** 2026-02-18T18:30:22Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Fixed the non-retryable error reprocessing bug: auth/validation/conflict errors now immediately move to dead_letter status instead of being silently reprocessed every sync cycle
- Added status column (pending/failed/dead_letter) to sync_queue table with migration v12 including backfill
- Implemented post-sync pruning: orphaned items (7d), expired dead letters (30d), old sync_conflicts (30d)
- Added deadLetterCountProvider (reactive Drift stream) and lastSyncTimestampProvider for UI
- Added discardDeadLetterItem with _markEntityAsLocalOnly covering all 12 entity types

## Task Commits

Each task was committed atomically:

1. **Task 1: Add status column to sync_queue table + migration v12** - `0f3b004` (feat)
2. **Task 2: Dead letter data source methods + sync service status-based processing + pruning + providers** - `f3f8a1d` (feat)

## Files Created/Modified
- `lib/data/database/tables/sync_queue.dart` - Added status text column with default 'pending'
- `lib/data/database/app_database.dart` - Schema v12, migration with status backfill
- `lib/data/database/app_database.g.dart` - Regenerated Drift code with status column
- `lib/data/datasources/local/sync_queue_local_data_source.dart` - Dead letter queries, pruning methods, status-aware getRetryableItems/markAsFailed/resetRetryCount
- `lib/data/services/sync_service.dart` - Status-based error handling, post-sync pruning, discardDeadLetterItem, _markEntityAsLocalOnly
- `lib/presentation/providers/sync_providers.dart` - deadLetterCountProvider, lastSyncTimestampProvider
- `test/helpers/mock_sync_infrastructure.dart` - Updated for new status field and all new methods

## Decisions Made
- No 'completed' status needed -- completed items are deleted immediately via markAsCompleted(), so the status column only tracks pending/failed/dead_letter
- isPendingSync on entities is implicitly true for all unsynced items (set when queue item created, only cleared on sync success or explicit discard) -- no need to re-set it on retry
- _markEntityAsLocalOnly sets isPendingSync=false AND lastSyncAt=null to distinguish "local-only" from "successfully synced"
- Pruning errors are caught non-fatally to prevent them from blocking the sync result return

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Updated test mock infrastructure for new status field and methods**
- **Found during:** Task 2 (verification)
- **Issue:** TrackingSyncQueueDataSource and FakeConnectivityService were missing new methods (markAsDeadLetter, watchDeadLetterCount, getDeadLetterItems, discardDeadLetterItem, pruneOldItems, pruneExpiredDeadLetters, pruneSyncConflicts, getPendingItemForEntity, insertConflict, watchRecentConflictCount, getRecentConflicts, ensureInitialized, isInitialized) and SyncQueueItem constructors lacked required status parameter
- **Fix:** Updated mock_sync_infrastructure.dart with all new method implementations, added status parameter to all SyncQueueItem constructors, added ensureInitialized/isInitialized to FakeConnectivityService
- **Files modified:** test/helpers/mock_sync_infrastructure.dart
- **Verification:** flutter analyze passes, tests compile
- **Committed in:** f3f8a1d (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Test mock update was necessary for tests to compile with new status field. No scope creep.

## Issues Encountered
- Pre-existing test failures in test/data/services/sync_service_test.dart due to AppLogger._instance not being initialized -- these are not caused by this plan's changes

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Dead letter infrastructure ready for Plan 02 (Dead Letter UI screen)
- deadLetterCountProvider available for badge/indicator in sync status UI
- discardDeadLetterItem and resetRetryCount available for UI actions
- Plan 03 (background sync timer improvements) can build on the pruning foundation

---
*Phase: 05-background-sync-dead-letter-queue*
*Completed: 2026-02-18*
