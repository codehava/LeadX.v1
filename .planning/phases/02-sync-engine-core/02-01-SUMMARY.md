---
phase: 02-sync-engine-core
plan: 01
subsystem: sync
tags: [drift, sqlite, sync-queue, coalescing, debounce, timer, completer]

# Dependency graph
requires:
  - phase: 01-foundation-observability
    provides: Structured logging with Talker (AppLogger), sync error hierarchy, standardized sync metadata columns
provides:
  - Intelligent sync queue coalescing with 4 operation-combination rules
  - Debounced triggerSync() with 500ms batching window
  - Atomic queue operations via Drift transactions
  - getPendingItemForEntity() for efficient single-entity queue lookup
  - Immediate processQueue() path for manual sync (bypasses debounce)
affects: [02-02-PLAN, 02-03-PLAN, sync-service, repository-implementations]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dart 3 record pattern matching for coalescing rules: switch ((existingOp, newOp))"
    - "Timer + Completer pattern for debounced async operations"
    - "Drift transaction wrapping for atomic queue coalescing"

key-files:
  created: []
  modified:
    - lib/data/datasources/local/sync_queue_local_data_source.dart
    - lib/data/services/sync_service.dart
    - lib/presentation/providers/sync_providers.dart

key-decisions:
  - "Full payload replacement on create+update coalesce (not merge) since repos read full entity state before queueing"
  - "SyncNotifier calls processQueue() directly to bypass debounce for user-initiated sync"
  - "500ms debounce window balances responsiveness with batching efficiency"

patterns-established:
  - "Coalescing at insertion time in queueOperation(), not at processing time in processQueue()"
  - "Manual sync bypasses debounce via processQueue(), repository fire-and-forget uses triggerSync()"

# Metrics
duration: 3min
completed: 2026-02-13
---

# Phase 2 Plan 1: Sync Queue Coalescing and Debounced Triggers Summary

**Sync queue coalescing with 4 operation rules (create+update, create+delete, update+update, update+delete) in Drift transactions, plus 500ms debounced triggerSync with immediate manual sync bypass**

## Performance

- **Duration:** 3 min
- **Started:** 2026-02-13T07:57:44Z
- **Completed:** 2026-02-13T08:01:23Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- SyncService.queueOperation() now handles all 4 coalescing combinations atomically within Drift transactions, preventing race conditions and redundant sync operations
- triggerSync() debounces with 500ms window so rapid repository writes batch into a single processQueue() call
- SyncNotifier.triggerSync() calls processQueue() directly for immediate user-initiated manual sync
- Added getPendingItemForEntity() to SyncQueueLocalDataSource for efficient single-entity queue lookup (replaces the less precise hasPendingOperation boolean check in the coalescing path)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add getPendingItemForEntity and rewrite queueOperation with full coalescing** - `d2ba63e` (feat)
2. **Task 2: Add debounced triggerSync and update SyncNotifier to bypass debounce** - `dee4335` (feat)

**Plan metadata:** (pending final commit)

## Files Created/Modified
- `lib/data/datasources/local/sync_queue_local_data_source.dart` - Added getPendingItemForEntity() method for efficient entity-specific queue lookup
- `lib/data/services/sync_service.dart` - Rewrote queueOperation() with full coalescing logic in Drift transaction; replaced triggerSync() with debounced version; updated dispose() with timer/completer cleanup
- `lib/presentation/providers/sync_providers.dart` - Changed SyncNotifier push step from triggerSync() to processQueue() for immediate manual sync

## Decisions Made
- Full payload replacement on create+update coalesce (not merge) since repositories read the full entity state from local DB before calling queueOperation for updates
- SyncNotifier calls processQueue() directly to bypass debounce for user-initiated sync -- debounce only applies to fire-and-forget calls from repositories
- 500ms debounce window chosen to balance responsiveness with batching efficiency
- Used Dart 3 record pattern matching `switch ((existingOp, newOp))` for clean, exhaustive coalescing rule handling

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Coalescing and debounce foundation in place for remaining sync engine plans
- Plan 02-02 (atomic transactions wrapping local write + queue insert) can proceed -- it will use the coalescing-aware queueOperation() built here
- Plan 02-03 (incremental sync with timestamps) is independent and can proceed in parallel

## Self-Check: PASSED

All files exist, all commits verified.

---
*Phase: 02-sync-engine-core*
*Completed: 2026-02-13*
