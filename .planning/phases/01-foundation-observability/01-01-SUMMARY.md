---
phase: 01-foundation-observability
plan: 01
subsystem: database, sync
tags: [drift, sqlite, migration, sealed-class, sync-errors, schema-standardization]

# Dependency graph
requires: []
provides:
  - Sealed SyncError hierarchy with 6 concrete subclasses for typed sync failure classification
  - Standardized sync metadata columns (isPendingSync, lastSyncAt, updatedAt) across all 11 syncable tables
  - Migration v9 -> v10 for existing databases
  - SyncService typed error handling with retryable/permanent branching
affects:
  - 02-sync-queue-resilience (uses SyncError.isRetryable for retry logic)
  - 03-logging-observability (replaces debugPrint calls that reference sync errors)
  - All future sync-related features (standardized schema enables uniform sync logic)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Sealed class hierarchy for error classification (SyncError with isRetryable)"
    - "Exhaustive pattern matching on sync errors via Dart 3 sealed classes"
    - "Standardized sync metadata: every syncable table has isPendingSync + lastSyncAt + updatedAt"

key-files:
  created:
    - lib/core/errors/sync_errors.dart
  modified:
    - lib/data/services/sync_service.dart
    - lib/data/database/app_database.dart
    - lib/data/database/tables/activities.dart
    - lib/data/database/tables/customers.dart
    - lib/data/database/tables/master_data.dart
    - lib/data/database/tables/cadence.dart
    - lib/data/database/tables/history_log_tables.dart
    - lib/data/datasources/local/activity_local_data_source.dart
    - lib/data/datasources/local/hvc_local_data_source.dart
    - lib/data/datasources/local/broker_local_data_source.dart
    - lib/data/datasources/local/cadence_local_data_source.dart
    - lib/data/repositories/activity_repository_impl.dart
    - lib/domain/entities/activity.dart

key-decisions:
  - "SyncError implements Exception to satisfy only_throw_errors lint while keeping sealed class"
  - "Activities column rename uses SQLite ALTER TABLE RENAME COLUMN (supported since 3.25+) to preserve existing data"
  - "FK disabled during migration with PRAGMA foreign_keys = OFF, re-enabled in beforeOpen"
  - "Local data sources for hvc/broker/cadence fixed to use lastSyncAt instead of updatedAt for sync tracking"

patterns-established:
  - "Sealed error hierarchy: use sealed class implements Exception for throwable typed errors"
  - "All syncable tables must have isPendingSync + lastSyncAt + updatedAt columns"
  - "_markEntityAsSynced must set lastSyncAt for every entity type"

# Metrics
duration: 13min
completed: 2026-02-13
---

# Phase 1 Plan 1: Sync Error Hierarchy & Schema Standardization Summary

**Sealed SyncError hierarchy with 6 typed subclasses and Drift migration v10 standardizing sync metadata across all 11 syncable tables**

## Performance

- **Duration:** 13 min
- **Started:** 2026-02-13T06:26:13Z
- **Completed:** 2026-02-13T06:39:22Z
- **Tasks:** 2
- **Files modified:** 16

## Accomplishments
- Created sealed SyncError hierarchy enabling exhaustive pattern matching on sync failures (retryable vs permanent)
- Standardized sync metadata columns (isPendingSync + lastSyncAt + updatedAt) across all 11 syncable entity tables
- Updated SyncService to throw typed SyncErrors with retryable/permanent branching in processQueue
- Eliminated 5 different sync metadata patterns (missing lastSyncAt, wrong column name, missing updatedAt)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create sealed SyncError hierarchy and update SyncService error handling** - `f2cab71` (feat)
2. **Task 2: Standardize sync metadata schema via Drift migration v10 and update dependent code** - `7fac55b` (feat)

## Files Created/Modified
- `lib/core/errors/sync_errors.dart` - Sealed SyncError base + 6 final subclasses (Network, Timeout, Server, Auth, Validation, Conflict)
- `lib/data/services/sync_service.dart` - Typed error throwing in _processItem, SyncError catching in processQueue, lastSyncAt in all _markEntityAsSynced cases
- `lib/data/database/app_database.dart` - schemaVersion 10, migration v9->v10 adding columns and renaming Activities.syncedAt
- `lib/data/database/tables/activities.dart` - syncedAt renamed to lastSyncAt
- `lib/data/database/tables/customers.dart` - lastSyncAt added to KeyPersons
- `lib/data/database/tables/master_data.dart` - lastSyncAt added to Hvcs, CustomerHvcLinks, Brokers
- `lib/data/database/tables/cadence.dart` - lastSyncAt added to CadenceMeetings
- `lib/data/database/tables/history_log_tables.dart` - lastSyncAt and updatedAt added to PipelineStageHistoryItems
- `lib/data/datasources/local/activity_local_data_source.dart` - syncedAt -> lastSyncAt in markAsSynced and getLastSyncTimestamp
- `lib/data/datasources/local/hvc_local_data_source.dart` - updatedAt -> lastSyncAt in markAsSynced and markLinkAsSynced
- `lib/data/datasources/local/broker_local_data_source.dart` - updatedAt -> lastSyncAt in markAsSynced
- `lib/data/datasources/local/cadence_local_data_source.dart` - updatedAt -> lastSyncAt in markMeetingAsSynced
- `lib/data/repositories/activity_repository_impl.dart` - syncedAt -> lastSyncAt in mapper and sync companion
- `lib/domain/entities/activity.dart` - Entity field syncedAt -> lastSyncAt
- `lib/domain/entities/activity.freezed.dart` - Regenerated Freezed code
- `lib/domain/entities/activity.g.dart` - Regenerated JSON serialization

## Decisions Made
- SyncError implements Exception (not extends Error) to satisfy Dart lint `only_throw_errors` while preserving sealed class exhaustiveness
- Used SQLite `ALTER TABLE RENAME COLUMN` for Activities.syncedAt -> lastSyncAt to preserve existing sync timestamps (avoids data loss)
- FK constraint disabled during migration to prevent constraint issues on tables with foreign key relationships
- Fixed hvc/broker/cadence local data sources to write to `lastSyncAt` instead of `updatedAt` for sync tracking (was a pre-existing bug)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed HVC local data source writing sync timestamp to updatedAt instead of lastSyncAt**
- **Found during:** Task 2 (sync metadata standardization)
- **Issue:** `hvc_local_data_source.dart` markAsSynced and markLinkAsSynced were writing sync timestamp to `updatedAt` column instead of the proper sync tracking column
- **Fix:** Changed to write to `lastSyncAt` now that the column exists
- **Files modified:** lib/data/datasources/local/hvc_local_data_source.dart
- **Verification:** flutter analyze passes with zero errors
- **Committed in:** 7fac55b (Task 2 commit)

**2. [Rule 1 - Bug] Fixed broker local data source writing sync timestamp to updatedAt instead of lastSyncAt**
- **Found during:** Task 2 (sync metadata standardization)
- **Issue:** `broker_local_data_source.dart` markAsSynced was writing sync timestamp to `updatedAt` column
- **Fix:** Changed to write to `lastSyncAt`
- **Files modified:** lib/data/datasources/local/broker_local_data_source.dart
- **Verification:** flutter analyze passes with zero errors
- **Committed in:** 7fac55b (Task 2 commit)

**3. [Rule 1 - Bug] Fixed cadence local data source markMeetingAsSynced writing to updatedAt instead of lastSyncAt**
- **Found during:** Task 2 (sync metadata standardization)
- **Issue:** `cadence_local_data_source.dart` markMeetingAsSynced was writing sync timestamp to `updatedAt` column instead of tracking when the entity was last synced
- **Fix:** Changed to write to `lastSyncAt`
- **Files modified:** lib/data/datasources/local/cadence_local_data_source.dart
- **Verification:** flutter analyze passes with zero errors
- **Committed in:** 7fac55b (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (3 bug fixes via Rule 1)
**Impact on plan:** All auto-fixes were necessary correctness bugs in local data sources that were writing sync timestamps to the wrong column. The plan explicitly called out the cadenceMeeting bug; the hvc and broker bugs were discovered during the same audit. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Sealed SyncError hierarchy ready for use by Phase 2-3 sync resilience work
- Standardized schema enables uniform sync logic across all entity types
- All generated code regenerated and passing analysis
- Ready for Plan 02 (Sentry crash reporting) and Plan 03 (Talker structured logging)

## Self-Check: PASSED

All created files verified present. Both task commits (f2cab71, 7fac55b) verified in git log.

---
*Phase: 01-foundation-observability*
*Completed: 2026-02-13*
