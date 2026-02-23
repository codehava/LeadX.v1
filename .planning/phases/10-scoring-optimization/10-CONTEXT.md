# Phase 10: Scoring Optimization - Context

**Gathered:** 2026-02-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix multi-period score aggregation, implement team ranking calculation across multiple pools, add a scoring summary grid for admins/managers, and resolve RLS visibility issues for leaderboard. Server-side score calculation already exists (triggers, cron, dirty_users pattern); this phase ensures rankings are computed, stored, and displayed correctly.

</domain>

<decisions>
## Implementation Decisions

### Team Ranking Scope
- **Three ranking pools**: company-wide, per-regional office, and per-branch
- **Role-based ranking**: Same role only (RM vs RM, BH vs BH, BM vs BM, ROH vs ROH) — all 4 levels have separate ranking pools
- **Admins excluded** from all scoring and ranking entirely
- **Inactive users excluded** (is_active=false) from rankings
- **Users with zero scores** still appear at the bottom of rankings (included, not excluded)
- **New users ranked immediately** — even if they join mid-period, they appear in rankings as soon as they have any score data

### Rank Change Baseline
- **rank_change stored server-side** — cron calculates and persists rank_change in the database after ranking
- **rank_change persists across period transitions** — each period's rank_change is frozen when computed; historical periods retain their rank_change values
- **All ranking pools** have their own rank_change (company, regional, branch, role — each tracks independent rank movement)

### Missing Score Behavior
- **LAG = 0 when missing**: Composite = (lead * 0.6) + (0 * 0.4). Missing LAG/LEAD contributes zero; users ranked with partial composite score
- **Measures with no target assigned**: Show "No target" text on personal scoreboard (not hidden)
- **Multi-period matching**: Each measure scores against its own period_type's current period (existing server logic is correct). Multiple scoring periods can be active simultaneously (e.g., current WEEKLY + current MONTHLY + current QUARTERLY)

### Measure Auto-Deactivation
- **Measures auto-deactivate** (is_active=false) when their period ends
- **Admin manually reactivates** measures for new periods — no auto-reactivation
- Trigger mechanism: Claude's discretion (cron-based date check vs admin action)

### Client-Side Sync & Display
- **Server-computed scores only** — Flutter displays what the server calculated; no client-side score calculation
- **Leaderboard is server-first** — always tries to fetch from server; falls back to local cache if offline
- **Rankings fetched on-demand only** — not pulled during regular sync; fetched when user opens leaderboard
- **"Score update pending" subtle hint** — show indicator when local data was recently modified but scores haven't been recalculated yet
- **Manual refresh button** on scoreboard — pull-to-refresh or refresh icon triggers server fetch

### RLS Policy Changes
- **Broader SELECT on user_score_aggregates** — all authenticated users can SELECT (scores are public for leaderboard)
- **Broader SELECT on user_scores** — all authenticated users can SELECT per-measure detail (full transparency)
- **Broader SELECT on users** — all authenticated users can SELECT basic profile (id, name, branch_id) for leaderboard name resolution

### Scoring Summary Grid (New Screen)
- **Users x Measures grid**: Table with users as rows, measures as columns; each cell shows actual/target/%; composite score at end
- **Access**: Admin sees all users; managers (BH/BM/ROH) see grid filtered to their subordinates
- **Period-aware**: Grid shows scores for selected period

### Claude's Discretion
- Tie-breaking approach for same composite score (standard competition ranking vs dense ranking)
- Rank change comparison baseline (previous same-type period is natural choice)
- First-ever period handling (NEW badge vs 0 change)
- Historical period rank_change behavior (relative to prior period or current-only)
- Rank change display format (exact positions vs direction only)
- Role filter chip on leaderboard UI (whether to add alongside existing branch/region filters)
- Team-vs-team ranking on manager summary card
- Role + geography interaction (role as primary filter vs combined pools)
- Ranking timing (with aggregate cron vs separate schedule)
- Ranking storage approach (columns on aggregate vs separate table)
- Stale data behavior on scoreboard (cached + indicator pattern)
- Personal scoreboard data source (local-first since it syncs during regular pull)
- Period end detection mechanism for auto-deactivation

</decisions>

<specifics>
## Specific Ideas

- The existing server-side infrastructure is solid: triggers fire on business events, dirty_users tracks who needs recalculation, cron Edge Function processes dirty users every 10 minutes, multi-period SQL functions already join measure_definitions.period_type to scoring_periods.is_current
- The `rank` and `rank_change` columns already exist in `user_score_aggregates` but are never populated — this is the primary gap
- Leaderboard remote data source already queries user_score_aggregates with user joins — just needs RLS fix and ranking data populated
- `rankChange: null` comments in existing code (`// Would need previous period comparison`) confirm ranking was always intended but never implemented
- Score aggregation cron (`score-aggregation-cron` Edge Function) is the natural place to add ranking calculation after aggregate recalculation

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 10-scoring-optimization*
*Context gathered: 2026-02-23*
