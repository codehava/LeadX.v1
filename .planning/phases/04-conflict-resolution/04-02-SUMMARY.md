---
phase: 04-conflict-resolution
plan: 02
subsystem: sync
tags: [offline-first, conflict-resolution, version-guard, drift, riverpod, isPendingSync]

# Dependency graph
requires:
  - phase: 04-01
    provides: "SyncConflicts table, _resolveConflict method, LWW resolution, watchRecentConflictCount"
provides:
  - "_server_updated_at metadata in all 27 repository update sync payloads"
  - "Coalescing logic that preserves version guard metadata across update+update"
  - "Pull sync isPendingSync guard preventing server overwrites of pending local changes"
  - "conflictCountProvider StreamProvider for UI conflict visibility"
  - "Conflict count banner in sync queue debug screen"
affects: [04-03, sync-push, sync-pull, conflict-resolution]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Version guard pattern: read existing updatedAt before local write, include as _server_updated_at in sync payload"
    - "Pull sync guard pattern: query isPendingSync=true IDs, filter batch upsert to exclude them"
    - "Individual upsert guard pattern: check isPendingSync before insertOnConflictUpdate for single-record upserts"

key-files:
  created: []
  modified:
    - lib/data/repositories/customer_repository_impl.dart
    - lib/data/repositories/pipeline_repository_impl.dart
    - lib/data/repositories/activity_repository_impl.dart
    - lib/data/repositories/hvc_repository_impl.dart
    - lib/data/repositories/broker_repository_impl.dart
    - lib/data/repositories/cadence_repository_impl.dart
    - lib/data/repositories/pipeline_referral_repository_impl.dart
    - lib/data/services/sync_service.dart
    - lib/data/datasources/local/customer_local_data_source.dart
    - lib/data/datasources/local/pipeline_local_data_source.dart
    - lib/data/datasources/local/activity_local_data_source.dart
    - lib/data/datasources/local/key_person_local_data_source.dart
    - lib/data/datasources/local/hvc_local_data_source.dart
    - lib/data/datasources/local/broker_local_data_source.dart
    - lib/data/datasources/local/cadence_local_data_source.dart
    - lib/data/datasources/local/pipeline_referral_local_data_source.dart
    - lib/presentation/providers/sync_providers.dart
    - lib/presentation/screens/sync/sync_queue_screen.dart

key-decisions:
  - "Capture _server_updated_at from existing record BEFORE local write within same transaction to get true pre-edit server state"
  - "Coalescing update+update preserves FIRST _server_updated_at (original server state), create+update strips it (irrelevant for new records)"
  - "Pull sync guard uses batch pre-filter (query pending IDs, exclude from upsert list) for batch methods, individual check for single-record upserts"
  - "Guard logs skipped count at debug level using AppLogger sync.pull prefix"

patterns-established:
  - "Version guard metadata: all repository update queueOperation calls include _server_updated_at from pre-edit state"
  - "Pull sync guard: all local data source upsert methods filter out records with isPendingSync=true before writing"

# Metrics
duration: 18min
completed: 2026-02-16
---

# Phase 04 Plan 02: Version Guard Metadata + Pull Sync Guard Summary

**_server_updated_at metadata in all 27 update queue calls, coalescing preservation, isPendingSync pull guard across 10 upsert methods, and conflict count UI banner**

## Performance

- **Duration:** 18 min
- **Started:** 2026-02-16T19:22:00Z
- **Completed:** 2026-02-16T19:40:00Z
- **Tasks:** 2
- **Files modified:** 18

## Accomplishments
- All 27 repository update sync payloads now include `_server_updated_at` metadata for the version guard in SyncService
- Coalescing logic correctly preserves first `_server_updated_at` for update+update and strips it for create+update
- Pull sync upsert methods across all 8 local data sources (10 methods total) now skip records with `isPendingSync=true`
- `conflictCountProvider` StreamProvider exposes recent conflict count for UI
- Sync queue debug screen shows conflict count banner when conflicts detected in last 7 days

## Task Commits

Each task was committed atomically:

1. **Task 1: Add _server_updated_at to all repository update queue calls and update coalescing** - `23b0457` (feat)
2. **Task 2: Pull sync isPendingSync guard + conflict count provider + minimal UI** - `9c31576` (feat)

## Files Created/Modified

### Task 1 - Version Guard Metadata (7 repositories + sync service)
- `lib/data/repositories/customer_repository_impl.dart` - Added _server_updated_at to updateCustomer, updateKeyPerson (2 calls)
- `lib/data/repositories/pipeline_repository_impl.dart` - Added _server_updated_at to updatePipeline, updatePipelineStage, updatePipelineStatus (3 calls)
- `lib/data/repositories/activity_repository_impl.dart` - Added _server_updated_at to executeActivity, rescheduleActivity, cancelActivity (3 calls)
- `lib/data/repositories/hvc_repository_impl.dart` - Added _server_updated_at to updateHvc (1 call)
- `lib/data/repositories/broker_repository_impl.dart` - Added _server_updated_at to updateBroker (1 call)
- `lib/data/repositories/cadence_repository_impl.dart` - Added _server_updated_at to 12 update operations (meetings + participants)
- `lib/data/repositories/pipeline_referral_repository_impl.dart` - Added _server_updated_at to 5 status change operations
- `lib/data/services/sync_service.dart` - Updated coalescing: preserve first _server_updated_at for update+update, strip for create+update

### Task 2 - Pull Sync Guard + Conflict UI (8 local data sources + providers + screen)
- `lib/data/datasources/local/customer_local_data_source.dart` - isPendingSync guard in upsertCustomers
- `lib/data/datasources/local/pipeline_local_data_source.dart` - isPendingSync guard in upsertPipelines
- `lib/data/datasources/local/activity_local_data_source.dart` - isPendingSync guard in upsertActivities
- `lib/data/datasources/local/key_person_local_data_source.dart` - isPendingSync guard in upsertKeyPersons
- `lib/data/datasources/local/hvc_local_data_source.dart` - isPendingSync guard in upsertHvcs, upsertCustomerHvcLinks
- `lib/data/datasources/local/broker_local_data_source.dart` - isPendingSync guard in upsertBrokers
- `lib/data/datasources/local/cadence_local_data_source.dart` - isPendingSync guard in upsertMeeting, upsertParticipant (individual checks)
- `lib/data/datasources/local/pipeline_referral_local_data_source.dart` - isPendingSync guard in upsertReferrals
- `lib/presentation/providers/sync_providers.dart` - Added conflictCountProvider StreamProvider
- `lib/presentation/screens/sync/sync_queue_screen.dart` - Added conflict count banner above queue list

## Decisions Made
- Captured `_server_updated_at` from existing record BEFORE the local write within the same transaction, ensuring the metadata represents the true pre-edit server state
- For update+update coalescing, preserved the FIRST `_server_updated_at` value since it represents the original server state before any local edits began
- For create+update coalescing, stripped `_server_updated_at` entirely since it is irrelevant for records that do not yet exist on the server
- Used batch pre-filter pattern (query all pending IDs, build Set, filter list) for batch upsert methods to minimize DB queries
- Used individual check pattern (query single record by ID + isPendingSync) for cadence upserts which use single-record insertOnConflictUpdate

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Full conflict resolution pipeline is now complete: version guard metadata -> push sync conflict detection -> LWW resolution -> conflict logging -> pull sync protection -> UI visibility
- End-to-end flow: local edit queues with _server_updated_at -> SyncService extracts guard during push -> Supabase conditional update detects conflicts -> LWW resolves -> conflict logged to sync_conflicts table -> pull sync skips records with pending local changes -> conflict count visible in debug UI
- Ready for phase verification and any remaining conflict resolution plans

## Self-Check: PASSED

- All 18 modified files exist on disk
- Task 1 commit `23b0457` found in git log
- Task 2 commit `9c31576` found in git log
- _server_updated_at count: 2+3+3+1+1+12+5 = 27 across 7 repositories
- conflictCountProvider present in sync_providers.dart
- isPendingSync guard present in all 8 local data sources (10 upsert methods)

---
*Phase: 04-conflict-resolution*
*Completed: 2026-02-16*
