---
phase: 10-scoring-optimization
plan: 02
subsystem: scoring
tags: [drift, riverpod, supabase-rpc, leaderboard, ranking, filter-chips]

# Dependency graph
requires:
  - phase: 10-scoring-optimization (plan 01)
    provides: Server-side ranking functions and get_filtered_leaderboard RPC
provides:
  - Client reads real rank/rank_change from server responses
  - RPC-based filtered leaderboard with role filter
  - Score update pending indicator on scoreboard
  - Branch/regional rank columns on Drift UserScoreAggregates table
affects: [10-scoring-optimization]

# Tech tracking
tech-stack:
  added: []
  patterns: [rpc-based-leaderboard-filtering, sync-queue-pending-indicator]

key-files:
  created: []
  modified:
    - lib/data/database/tables/scoring.dart
    - lib/data/datasources/remote/scoreboard_remote_data_source.dart
    - lib/domain/repositories/scoreboard_repository.dart
    - lib/data/repositories/scoreboard_repository_impl.dart
    - lib/presentation/providers/scoreboard_providers.dart
    - lib/presentation/screens/scoreboard/leaderboard_screen.dart
    - lib/presentation/screens/scoreboard/scoreboard_screen.dart

key-decisions:
  - "Role filter uses RPC method for dynamic ranking; geography-only filters use existing query method"
  - "Score pending indicator watches sync queue for activity/pipeline/customer entity types with pending status"
  - "Removed emoji prefixes from geography filter chip labels for cleaner UI"

patterns-established:
  - "RPC-based filtering: use Supabase RPC when server-side computation (ranking) is needed within filter context"
  - "Sync-aware indicators: watch sync_queue_items for pending entity types to show data freshness hints"

requirements-completed: [SCORE-01, SCORE-02]

# Metrics
duration: 13min
completed: 2026-02-23
---

# Phase 10 Plan 02: Client Scoring Data Layer Summary

**Fixed client-side ranking data reads, added role filter to leaderboard, and score pending indicator to scoreboard**

## Performance

- **Duration:** 13 min
- **Started:** 2026-02-23T07:45:54Z
- **Completed:** 2026-02-23T07:59:15Z
- **Tasks:** 2
- **Files modified:** 9 (7 source + 2 generated)

## Accomplishments
- Client now reads actual rank and rank_change values from server responses instead of hardcoding null
- Fixed snapshot_at column reference bug to use correct calculated_at column name
- Added RPC-based filtered leaderboard method using get_filtered_leaderboard server function
- Added role filter chips (Semua Jabatan, RM, BH, BM, ROH) to leaderboard screen
- Added score update pending indicator on scoreboard when sync queue has pending scoring-relevant items
- Added branch_rank, branch_rank_change, regional_rank, regional_rank_change columns to Drift UserScoreAggregates table
- Replaced raw error text with AppErrorState.general() on both scoreboard screens

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix remote data source for ranking data and add RPC-based filtered leaderboard** - `1ace949` (feat)
2. **Task 2: Add role filter to leaderboard screen and score pending indicator to scoreboard** - `d72034f` (feat)

**Plan metadata:** (pending final commit)

## Files Created/Modified
- `lib/data/database/tables/scoring.dart` - Added 4 nullable integer columns for branch/regional ranking
- `lib/data/database/app_database.g.dart` - Regenerated Drift code for new columns
- `lib/data/datasources/remote/scoreboard_remote_data_source.dart` - Fixed rankChange reads, fixed calculated_at, added RPC method
- `lib/domain/repositories/scoreboard_repository.dart` - Added getFilteredLeaderboardRpc interface method
- `lib/data/repositories/scoreboard_repository_impl.dart` - Implemented RPC method with offline fallback
- `lib/presentation/providers/scoreboard_providers.dart` - Added isScoreUpdatePending, role in filter, updated filteredLeaderboard
- `lib/presentation/providers/scoreboard_providers.g.dart` - Regenerated Riverpod code
- `lib/presentation/screens/scoreboard/leaderboard_screen.dart` - Added role filter chips, AppErrorState
- `lib/presentation/screens/scoreboard/scoreboard_screen.dart` - Added pending indicator, AppErrorState

## Decisions Made
- Role filter uses RPC method for dynamic ranking; geography-only filters use existing direct query method
- Score pending indicator watches sync queue for activity/pipeline/customer entity types with pending status
- Removed emoji prefixes from geography filter chip labels for cleaner UI consistency
- Used clearRole boolean flag in copyWith to allow clearing selectedRole back to null

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed unused local variable after error state refactor**
- **Found during:** Task 2 (Scoreboard screen)
- **Issue:** Replacing error block with AppErrorState.general() left unused `theme` variable in build method
- **Fix:** Removed unused `final theme = Theme.of(context)` from build method
- **Files modified:** lib/presentation/screens/scoreboard/scoreboard_screen.dart
- **Verification:** flutter analyze shows no warnings
- **Committed in:** d72034f (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 bug fix)
**Impact on plan:** Minor cleanup, no scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Client now reads real ranking data from server
- Role-based filtering works via RPC when online, falls back to basic filtering when offline
- Ready for Plan 03 (final scoring optimization tasks)

## Self-Check: PASSED

- All 9 modified files verified on disk
- Commit 1ace949 verified (Task 1)
- Commit d72034f verified (Task 2)
- flutter analyze: 0 errors (274 pre-existing info/warning only)
- rankChange: null occurrences = 0 (verified)
- snapshot_at occurrences = 0 (verified)
- isScoreUpdatePendingProvider in generated file (verified)
- Role filter chips in leaderboard (verified)

---
*Phase: 10-scoring-optimization*
*Completed: 2026-02-23*
