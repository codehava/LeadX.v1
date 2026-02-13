---
phase: 02-sync-engine-core
plan: 03
subsystem: sync
tags: [drift, sqlite, transactions, atomicity, sync-queue, offline-first, incremental-sync, timestamps]

# Dependency graph
requires:
  - phase: 02-sync-engine-core
    plan: 02
    provides: Atomic Drift transactions for customer/pipeline/activity repositories and _database injection pattern
  - phase: 01-foundation-observability
    provides: Structured logging, sync error hierarchy, standardized sync metadata columns
provides:
  - Atomic Drift transactions wrapping all write methods across HVC, Broker, Cadence, and PipelineReferral repositories
  - _database field injection for HVC, Broker, and Cadence repositories (PipelineReferral already had it)
  - Incremental per-entity sync timestamps via AppSettingsService in SyncNotifier._pullFromRemote()
  - 30-second safety margin on since timestamps to prevent missed records
  - All 8 syncable repositories now have crash-safe atomic local-write + queue-insert
affects: [sync-performance, test-infrastructure, future-repositories]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-entity incremental sync: _getSafeSince(tableName) reads stored timestamp with 30s safety margin"
    - "setTableLastSyncAt only on successful pull (inside fold right branch or after non-throwing sync)"
    - "All 8 syncable repositories follow: transaction { local write + queueOperation } then triggerSync() outside"

key-files:
  created: []
  modified:
    - lib/data/repositories/hvc_repository_impl.dart
    - lib/data/repositories/broker_repository_impl.dart
    - lib/data/repositories/cadence_repository_impl.dart
    - lib/data/repositories/pipeline_referral_repository_impl.dart
    - lib/presentation/providers/hvc_providers.dart
    - lib/presentation/providers/broker_providers.dart
    - lib/presentation/providers/cadence_providers.dart
    - lib/presentation/providers/sync_providers.dart

key-decisions:
  - "30-second safety margin on since timestamps prevents missed records at cost of occasional duplicate fetches"
  - "Per-entity timestamp keys match table names: customers, key_persons, pipelines, activities, hvcs, customer_hvc_links, brokers, cadence_meetings, pipeline_referrals"
  - "Added missing triggerSync() calls to broker create/delete for consistency with other repositories"
  - "endMeeting wraps all participant score calculations + meeting end + all queue ops in single transaction"

patterns-established:
  - "Incremental sync pattern: _getSafeSince(tableName) -> syncFromRemote(since:) -> setTableLastSyncAt on success"
  - "First sync uses null since (full pull); subsequent syncs pass stored timestamp minus 30s"
  - "Pipeline and activity repos: setTableLastSyncAt outside fold because they return void (wrapped in try-catch)"
  - "Customer, key_person, HVC, broker repos: setTableLastSyncAt inside Either.fold right branch"

# Metrics
duration: 9min
completed: 2026-02-13
---

# Phase 2 Plan 3: Atomic Transactions for Remaining Repos + Incremental Sync Timestamps Summary

**All 8 syncable repositories wrapped in Drift transactions; SyncNotifier._pullFromRemote() passes per-entity since timestamps to all 9 entity pull operations via AppSettingsService**

## Performance

- **Duration:** 9 min
- **Started:** 2026-02-13T08:14:15Z
- **Completed:** 2026-02-13T08:23:11Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- All 26 write methods across HVC (5), Broker (3), Cadence (13), and PipelineReferral (5) repositories wrapped in `_database.transaction()` blocks ensuring atomic local-write + sync-queue-insert
- Added `_database` field to HvcRepositoryImpl, BrokerRepositoryImpl, CadenceRepositoryImpl via constructor injection; updated 3 provider files to pass database parameter
- Rewrote `_pullFromRemote()` to read per-entity timestamps from AppSettingsService before each pull and store new timestamps on success
- Added `_getSafeSince()` helper with 30-second safety margin to prevent missed records during concurrent modifications
- Combined with Plan 02, all 8 syncable repositories (customer, pipeline, activity, HVC, broker, cadence, pipeline referral) now have complete atomic transaction coverage

## Task Commits

Each task was committed atomically:

1. **Task 1: Add _database to HVC/Broker/Cadence repos, update providers, wrap all write methods in transactions** - `e5c082a` (feat)
2. **Task 2: Wire incremental sync timestamps in SyncNotifier._pullFromRemote()** - `f8ff29d` (feat)

**Plan metadata:** (pending final commit)

## Files Created/Modified
- `lib/data/repositories/hvc_repository_impl.dart` - Added `_database` field; wrapped 5 write methods (create, update, delete, linkCustomer, unlinkCustomer)
- `lib/data/repositories/broker_repository_impl.dart` - Added `_database` field; wrapped 3 write methods (create, update, delete); added missing triggerSync() calls
- `lib/data/repositories/cadence_repository_impl.dart` - Added `_database` field; wrapped 13 write methods (config CRUD, meeting lifecycle, attendance, forms, feedback, meeting creation with participants)
- `lib/data/repositories/pipeline_referral_repository_impl.dart` - Wrapped 5 write methods (accept, reject, approve, rejectAsManager, cancel) in transactions
- `lib/presentation/providers/hvc_providers.dart` - Added `database` parameter to hvcRepositoryProvider
- `lib/presentation/providers/broker_providers.dart` - Added `database` parameter to brokerRepositoryProvider
- `lib/presentation/providers/cadence_providers.dart` - Added `database` parameter to cadenceRepositoryProvider
- `lib/presentation/providers/sync_providers.dart` - Added AppSettingsService to SyncNotifier; rewrote _pullFromRemote() with per-entity since timestamps

## Decisions Made
- Used 30-second safety margin (`since.subtract(Duration(seconds: 30))`) when reading since timestamps -- may cause occasional duplicate fetches but guarantees no records are missed
- Per-entity timestamp keys use table names directly: `customers`, `key_persons`, `pipelines`, `activities`, `hvcs`, `customer_hvc_links`, `brokers`, `cadence_meetings`, `pipeline_referrals`
- Added missing `triggerSync()` calls to BrokerRepositoryImpl's `createBroker` and `deleteBroker` methods for consistency with all other repositories
- The complex `endMeeting` method wraps all participant score calculations, meeting status update, and all queue operations (N+1 per participant + 1 for meeting) in a single transaction

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added missing triggerSync() calls to BrokerRepositoryImpl**
- **Found during:** Task 1
- **Issue:** BrokerRepositoryImpl's `createBroker` and `deleteBroker` methods did not call `triggerSync()` after queueOperation, unlike all other repositories
- **Fix:** Added `unawaited(syncService.triggerSync())` after the transaction block in both methods
- **Files modified:** lib/data/repositories/broker_repository_impl.dart
- **Committed in:** e5c082a (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Essential for consistency -- without triggerSync, broker creates/deletes would only sync on next manual sync or background cycle. No scope creep.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All 8 syncable repositories have atomic transactions (SYNC-01 complete)
- Incremental sync passes per-entity since timestamps (SYNC-02 complete)
- Phase 02 (Sync Engine Core) is now fully complete
- Ready for Phase 03 which can build on the stable sync foundation

## Self-Check: PASSED

All 8 modified files verified present. Both task commits (e5c082a, f8ff29d) verified in git log. 26 `_database.transaction()` calls confirmed across 4 repository files (5 + 3 + 13 + 5). 9 `setTableLastSyncAt` calls and 9 `_getSafeSince` calls confirmed in sync_providers.dart.

---
*Phase: 02-sync-engine-core*
*Completed: 2026-02-13*
