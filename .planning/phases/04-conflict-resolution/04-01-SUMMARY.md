---
phase: 04-conflict-resolution
plan: 01
subsystem: database, sync
tags: [drift, sqlite, supabase, lww, conflict-resolution, upsert, optimistic-locking]

# Dependency graph
requires:
  - phase: 02-sync-engine-core
    provides: SyncService with queue processing, coalescing, and retry logic
  - phase: 01-foundation-observability
    provides: Standardized sync metadata columns (isPendingSync, lastSyncAt, updatedAt)
provides:
  - SyncConflicts Drift table for conflict audit logging
  - Schema v11 migration
  - Idempotent creates via Supabase upsert
  - Version guard for updates using _server_updated_at metadata
  - LWW conflict resolution with full field-level server-wins for customer/pipeline/activity
  - Conflict logging methods (insertConflict, watchRecentConflictCount, getRecentConflicts)
affects: [04-02-PLAN, sync-ui, pull-sync, repository-queue-operations]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Upsert for idempotent creates (retry-after-timeout safe)"
    - "Version guard via _server_updated_at payload metadata + .eq('updated_at') filter"
    - "LWW conflict resolution: higher updated_at timestamp wins"
    - "Full field-level server-wins resolution for primary entities (customer, pipeline, activity)"
    - "Secondary entities defer to next pull cycle on server-wins conflict"

key-files:
  created:
    - lib/data/database/tables/sync_queue.dart (SyncConflicts table class)
  modified:
    - lib/data/database/app_database.dart (schema v11, SyncConflicts in tables list)
    - lib/data/database/app_database.g.dart (regenerated)
    - lib/data/services/sync_service.dart (upsert, version guard, _resolveConflict, _applyServerDataLocally)
    - lib/data/datasources/local/sync_queue_local_data_source.dart (insertConflict, watchRecentConflictCount, getRecentConflicts)

key-decisions:
  - "Pipeline and activity _applyServerDataLocally field mappings corrected to match actual Drift schema (plan had incorrect field names)"
  - "Secondary entities (keyPerson, hvc, broker, cadence, pipelineReferral) log conflict but defer server data application to next pull cycle"
  - "_resolveConflict resolves internally without throwing -- queue item treated as successfully processed after LWW resolution"

patterns-established:
  - "Version guard: repositories must include _server_updated_at in update payloads for conflict detection"
  - "Conflict audit: all detected conflicts logged to sync_conflicts with both payloads regardless of winner"
  - "LWW resolution: local wins -> force push; server wins -> apply server data to local DB"

# Metrics
duration: 8min
completed: 2026-02-16
---

# Phase 4 Plan 1: Conflict Detection and LWW Resolution Summary

**SyncConflicts audit table at schema v11 with idempotent upsert creates, version-guarded updates, and LWW conflict resolution for customer/pipeline/activity entities**

## Performance

- **Duration:** 8 min
- **Started:** 2026-02-16T12:12:52Z
- **Completed:** 2026-02-16T12:21:28Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- SyncConflicts Drift table with entity tracking, payload snapshots, winner, and resolution type at schema v11
- Creates changed from insert to upsert for idempotent retry-after-timeout handling
- Updates now use version guard via _server_updated_at metadata with optimistic locking
- Full LWW conflict resolution with field-level server-wins for customer, pipeline, and activity entities

## Task Commits

Each task was committed atomically:

1. **Task 1: Add SyncConflicts Drift table and schema v11 migration** - `8a6e5b2` (feat)
2. **Task 2: Implement conflict detection and LWW resolution in SyncService** - `4d6308a` (feat)

## Files Created/Modified
- `lib/data/database/tables/sync_queue.dart` - Added SyncConflicts table class with 10 columns
- `lib/data/database/app_database.dart` - Schema v11 migration, added SyncConflicts to tables list
- `lib/data/database/app_database.g.dart` - Regenerated with SyncConflict data class and companions
- `lib/data/services/sync_service.dart` - Upsert for creates, version guard for updates, _resolveConflict and _applyServerDataLocally methods
- `lib/data/datasources/local/sync_queue_local_data_source.dart` - insertConflict, watchRecentConflictCount, getRecentConflicts methods

## Decisions Made
- Pipeline and activity field mappings in _applyServerDataLocally corrected to match actual Drift schema (plan had field names from a different schema revision)
- Secondary entities (keyPerson, hvc, broker, cadenceMeeting, pipelineReferral) log the conflict to audit table but defer full server data application to the next pull cycle -- reasonable trade-off since primary entities are most likely to have real conflicts
- _resolveConflict resolves internally without throwing; the queue item is treated as successfully processed after LWW resolution

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed pipeline companion field names to match actual schema**
- **Found during:** Task 2 (Implement conflict detection and LWW resolution)
- **Issue:** Plan specified field names (title, description, estimatedValue, declineReasonId, declineNotes) that don't exist in the Pipelines Drift table. Actual fields are cobId, lobId, potentialPremium, tsi, declineReason, policyNumber, etc.
- **Fix:** Rewrote pipeline case in _applyServerDataLocally to use correct field names matching Pipelines table definition
- **Files modified:** lib/data/services/sync_service.dart
- **Verification:** flutter analyze shows no new errors
- **Committed in:** 4d6308a (Task 2 commit)

**2. [Rule 1 - Bug] Fixed activity companion field names to match actual schema**
- **Found during:** Task 2 (Implement conflict detection and LWW resolution)
- **Issue:** Plan specified checkInTime/checkOutTime fields that don't exist in the Activities Drift table. Actual fields are executedAt, scheduledDatetime, summary, locationAccuracy, distanceFromTarget, cancelledAt, cancelReason.
- **Fix:** Rewrote activity case in _applyServerDataLocally to use correct field names matching Activities table definition
- **Files modified:** lib/data/services/sync_service.dart
- **Verification:** flutter analyze shows no new errors
- **Committed in:** 4d6308a (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 bugs - incorrect field names in plan)
**Impact on plan:** Both auto-fixes essential for correctness. No scope creep. The plan's field mappings were based on an outdated or incorrect schema understanding; corrected to match actual Drift table definitions.

## Issues Encountered
None - both tasks executed smoothly after correcting the field name mismatches.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Conflict detection and LWW resolution infrastructure is complete
- Plan 04-02 can now add _server_updated_at to repository update payloads to enable version guard for actual sync operations
- Future UI can use watchRecentConflictCount() and getRecentConflicts() to display conflict history

## Self-Check: PASSED

- All 5 key files verified present on disk
- Commit 8a6e5b2 (Task 1) verified in git log
- Commit 4d6308a (Task 2) verified in git log
- flutter analyze: 260 issues (all pre-existing, no new errors)

---
*Phase: 04-conflict-resolution*
*Completed: 2026-02-16*
