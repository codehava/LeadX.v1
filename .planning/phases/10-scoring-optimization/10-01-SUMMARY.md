---
phase: 10-scoring-optimization
plan: 01
subsystem: database
tags: [postgresql, dense-rank, window-functions, edge-functions, cron, ranking, scoring]

# Dependency graph
requires:
  - phase: 09-admin-dashboard-features
    provides: "Existing score aggregation cron and multi-period scoring SQL functions"
provides:
  - "calculate_rankings() SQL function computing 3 ranking pools (company, branch, regional)"
  - "get_filtered_leaderboard() RPC for dynamic filtered leaderboard queries"
  - "deactivate_expired_measures() SQL function for auto-deactivation"
  - "4 new rank columns on user_score_aggregates (branch_rank, branch_rank_change, regional_rank, regional_rank_change)"
  - "Updated cron Edge Function that calls ranking after aggregate processing"
affects: [10-02, 10-03, leaderboard-ui, scoreboard-ui]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "DENSE_RANK window function for ranking within partitioned pools"
    - "Multi-pool ranking pattern: company/branch/regional with independent rank_change per pool"
    - "Context-aware rank_change: get_filtered_leaderboard selects appropriate rank_change based on filter params"

key-files:
  created:
    - "supabase/migrations/20260223000002_ranking_functions.sql"
  modified:
    - "supabase/functions/score-aggregation-cron/index.ts"
    - "docs/04-database/sql/04_rls_policies.sql"

key-decisions:
  - "Migration filename uses 20260223000002 (not 000001 as planned) because 20260223000001 was already taken by add_users_deleted_at"
  - "DENSE_RANK for all ranking pools (1,2,2,3 not 1,2,2,4) for intuitive tie handling"
  - "COALESCE(u.regional_office_id, b.regional_office_id) for regional pool to handle users with direct regional assignment or branch-inferred regional"
  - "rank_change NULL for first-ever period (client already handles NULL as dash)"

patterns-established:
  - "Ranking pools: DENSE_RANK OVER (PARTITION BY role [+ geography]) for per-pool ranking"
  - "Cron ordering: dirty users -> deactivate measures -> calculate rankings (this specific sequence)"
  - "Non-fatal cron extensions: new cron steps log errors but don't fail the entire batch response"

requirements-completed: [SCORE-01, SCORE-02]

# Metrics
duration: 3min
completed: 2026-02-23
---

# Phase 10 Plan 01: Server-Side Ranking Infrastructure Summary

**Three-pool DENSE_RANK ranking system (company/branch/regional) with cron integration, filtered leaderboard RPC, and measure auto-deactivation**

## Performance

- **Duration:** 3 min
- **Started:** 2026-02-23T07:38:55Z
- **Completed:** 2026-02-23T07:42:15Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Created SQL migration with 4 new rank columns and 3 functions (calculate_rankings, get_filtered_leaderboard, deactivate_expired_measures)
- Updated cron Edge Function to call deactivation then ranking after dirty user processing, in correct order per pitfall analysis
- Documented RLS policy verification confirming existing policies are sufficient for Phase 10 leaderboard

## Task Commits

Each task was committed atomically:

1. **Task 1: Create SQL migration with ranking functions** - `43ea1a6` (feat)
2. **Task 2: Update cron Edge Function with ranking and auto-deactivation** - `9f09f58` (feat)
3. **Task 3: Document RLS policy verification in scoring section** - `72d9c14` (docs)

## Files Created/Modified
- `supabase/migrations/20260223000002_ranking_functions.sql` - Schema additions (4 rank columns) + 3 SQL functions for ranking, filtered leaderboard, and measure deactivation
- `supabase/functions/score-aggregation-cron/index.ts` - Added deactivation and ranking steps after dirty user processing loop
- `docs/04-database/sql/04_rls_policies.sql` - Phase 10 note confirming existing SELECT policies are sufficient

## Decisions Made
- Used `20260223000002` for migration filename since `20260223000001` was already taken by `add_users_deleted_at.sql`
- DENSE_RANK chosen over RANK for all pools (ties share rank, next rank is sequential: 1,2,2,3)
- Used `COALESCE(u.regional_office_id, b.regional_office_id)` for regional pool partitioning to handle both direct and branch-inferred regional assignments
- rank_change = NULL for first-ever period (already handled by client showing dash)
- Deactivation runs BEFORE ranking in cron (per pitfall #6) to ensure consistent scores

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Migration filename conflict**
- **Found during:** Task 1 (Create SQL migration)
- **Issue:** Plan specified `20260223000001_ranking_functions.sql` but that timestamp was already taken by `20260223000001_add_users_deleted_at.sql`
- **Fix:** Used `20260223000002_ranking_functions.sql` instead
- **Files modified:** N/A (filename only)
- **Verification:** File created successfully, no naming conflict
- **Committed in:** 43ea1a6

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Trivial filename adjustment. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required. The SQL migration and Edge Function update will be applied via standard Supabase deployment.

## Next Phase Readiness
- Server-side ranking infrastructure complete, ready for Plan 02 (client-side leaderboard integration)
- All six rank/rank_change columns will be populated after the next cron run
- get_filtered_leaderboard RPC available for client-side filtered queries
- Measure auto-deactivation active on every cron cycle

## Self-Check: PASSED

All files verified present. All commit hashes confirmed in git log.

---
*Phase: 10-scoring-optimization*
*Completed: 2026-02-23*
