# Phase 10: Scoring Optimization - Research

**Researched:** 2026-02-23
**Domain:** Server-side score aggregation, ranking calculation, multi-period scoring, RLS, Flutter leaderboard display
**Confidence:** HIGH

## Summary

Phase 10 addresses two specific gaps in the existing 4DX scoring system: (1) the `rank` and `rank_change` columns in `user_score_aggregates` are never populated, and (2) the client needs a scoring summary grid for admins/managers. The multi-period scoring infrastructure is already solid -- SQL functions (`update_all_measure_scores`, `recalculate_aggregate`) correctly join `measure_definitions.period_type` to `scoring_periods.is_current` since the `20260207000001_multi_period_scoring.sql` migration. The cron Edge Function (`score-aggregation-cron`) already processes dirty users every 10 minutes and calls `recalculate_aggregate` for each.

The primary server-side work is: (a) add ranking logic to the cron after aggregate recalculation, (b) add an auto-deactivation mechanism for expired measures, and (c) broaden RLS policies (already done in the seed SQL but needs verification). The primary client-side work is: (a) read `rank`/`rank_change` from `user_score_aggregates` instead of returning `null`, (b) add role-based ranking filter to leaderboard, (c) build a scoring summary grid screen, and (d) add "score update pending" hints.

**Primary recommendation:** Add ranking calculation as a server-side SQL function called by the cron after all dirty users are processed. Rankings are computed per-pool (company-wide, per-regional, per-branch) within same-role groups, with rank_change derived from previous same-type period comparison. Keep all scoring server-computed; Flutter remains display-only.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **Three ranking pools**: company-wide, per-regional office, and per-branch
- **Role-based ranking**: Same role only (RM vs RM, BH vs BH, BM vs BM, ROH vs ROH) -- all 4 levels have separate ranking pools
- **Admins excluded** from all scoring and ranking entirely
- **Inactive users excluded** (is_active=false) from rankings
- **Users with zero scores** still appear at the bottom of rankings (included, not excluded)
- **New users ranked immediately** -- even if they join mid-period, they appear in rankings as soon as they have any score data
- **rank_change stored server-side** -- cron calculates and persists rank_change in the database after ranking
- **rank_change persists across period transitions** -- each period's rank_change is frozen when computed; historical periods retain their rank_change values
- **All ranking pools** have their own rank_change (company, regional, branch, role -- each tracks independent rank movement)
- **LAG = 0 when missing**: Composite = (lead * 0.6) + (0 * 0.4). Missing LAG/LEAD contributes zero; users ranked with partial composite score
- **Measures with no target assigned**: Show "No target" text on personal scoreboard (not hidden)
- **Multi-period matching**: Each measure scores against its own period_type's current period (existing server logic is correct)
- **Measures auto-deactivate** (is_active=false) when their period ends
- **Admin manually reactivates** measures for new periods -- no auto-reactivation
- **Server-computed scores only** -- Flutter displays what the server calculated; no client-side score calculation
- **Leaderboard is server-first** -- always tries to fetch from server; falls back to local cache if offline
- **Rankings fetched on-demand only** -- not pulled during regular sync; fetched when user opens leaderboard
- **"Score update pending" subtle hint** -- show indicator when local data was recently modified but scores haven't been recalculated yet
- **Manual refresh button** on scoreboard -- pull-to-refresh or refresh icon triggers server fetch
- **Broader SELECT on user_score_aggregates** -- all authenticated users can SELECT (scores are public for leaderboard)
- **Broader SELECT on user_scores** -- all authenticated users can SELECT per-measure detail (full transparency)
- **Broader SELECT on users** -- all authenticated users can SELECT basic profile for leaderboard name resolution
- **Scoring Summary Grid**: Users x Measures grid with actual/target/% per cell, composite score at end. Admin sees all; managers see subordinates. Period-aware.

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

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SCORE-01 | Multi-period score aggregation correctly pulls LEAD and LAG scores from their respective active scoring periods and computes the composite score | Migration `20260207000001_multi_period_scoring.sql` already implements this in SQL functions. Client-side `getUserScoresForCurrentPeriods()` fetches from all current periods. Verification needed that it works end-to-end. |
| SCORE-02 | Team ranking calculation is implemented -- compares scores across team members per period and updates rank/rankChange fields | `rank` and `rank_change` columns exist in `user_score_aggregates` Drift table and PostgreSQL but are never populated (set to NULL). Need new SQL function + cron integration + client reads. |
</phase_requirements>

## Standard Stack

### Core (Already in project)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Supabase Edge Functions (Deno) | - | Cron job for score aggregation + ranking | Already used for `score-aggregation-cron` |
| PostgreSQL functions | - | Score calculation, ranking via RANK()/DENSE_RANK() | Already used for `recalculate_aggregate` |
| Drift (SQLite) | Project version | Local cache for scoring data | Project standard |
| Riverpod | Project version | State management for scoreboard providers | Project standard |
| Supabase Flutter | Project version | Remote data fetching | Project standard |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| PostgreSQL `DENSE_RANK()` window function | Built-in | Computing rankings within partition | For ranking calculation in SQL |
| `pg_cron` | Supabase-managed | Scheduling the score-aggregation-cron | Already configured for 10-minute intervals |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Separate ranking table | Columns on user_score_aggregates | Columns already exist; separate table adds JOIN overhead for no benefit. **Use existing columns.** |
| Client-side ranking | Server-side DENSE_RANK() | Client can't rank across all users (only sees fetched subset). **Server-side only.** |
| Separate ranking cron | Same cron after aggregates | Adding a separate schedule increases complexity; ranking after aggregate is the natural sequence. **Same cron.** |

## Architecture Patterns

### Current Server-Side Scoring Architecture
```
Business Event (activity, pipeline, customer)
    |
    v
Trigger Function (on_activity_completed, on_pipeline_won, etc.)
    |
    +--> update_all_measure_scores(user_id)  -- per-measure score update
    |      Joins measure_definitions.period_type to scoring_periods.is_current
    |
    +--> mark_user_and_ancestors_dirty(user_id)  -- queues for cron
           Inserts user + ancestors into dirty_users table

    ... (up to 10 minutes later) ...

score-aggregation-cron Edge Function
    |
    +--> For each dirty user:
    |      recalculate_aggregate(user_id, display_period_id)
    |        Pulls LEAD/LAG from respective current periods
    |        Upserts into user_score_aggregates
    |      Remove from dirty_users
    |
    +--> [NEW] calculate_rankings()  <-- THIS IS THE GAP
           Rank all users by total_score within pools
           Update rank and rank_change columns
```

### Pattern 1: Ranking Calculation via SQL Window Function
**What:** Use PostgreSQL `DENSE_RANK() OVER (PARTITION BY ... ORDER BY total_score DESC)` to compute rankings after all dirty users are processed.
**When to use:** After the cron finishes processing all dirty users for the current period.
**Recommendation:** Use DENSE_RANK (not RANK) -- if two users tie at #2, the next user is #3 (not #4). This is more intuitive for a CRM leaderboard.

```sql
-- Ranking within a pool (e.g., company-wide, same-role)
-- This would be called AFTER all dirty_users are processed in a cron run
CREATE OR REPLACE FUNCTION calculate_rankings(
  p_period_id UUID
) RETURNS VOID AS $$
BEGIN
  -- Update company-wide ranking per role
  WITH ranked AS (
    SELECT
      usa.id,
      usa.user_id,
      DENSE_RANK() OVER (
        PARTITION BY u.role
        ORDER BY usa.total_score DESC
      ) AS new_rank
    FROM user_score_aggregates usa
    JOIN users u ON u.id = usa.user_id
    WHERE usa.period_id = p_period_id
      AND u.is_active = TRUE
      AND u.role NOT IN ('ADMIN', 'SUPERADMIN')
  )
  UPDATE user_score_aggregates usa
  SET rank = ranked.new_rank
  FROM ranked
  WHERE usa.id = ranked.id;

  -- rank_change = previous_period_rank - current_rank
  -- (positive = improved, negative = dropped)
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Pattern 2: Multiple Ranking Pools Storage
**What:** The decision requires 3 ranking pools (company, regional, branch) x 4 roles = up to 12 independent ranking pools. Storing these as separate columns on `user_score_aggregates` would be impractical (12 rank columns + 12 rank_change columns).
**Recommendation:** Create a dedicated `user_rankings` table with pool_type + role as composite key. This keeps `user_score_aggregates` clean and allows flexible querying.

```sql
CREATE TABLE user_rankings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  period_id UUID NOT NULL REFERENCES scoring_periods(id),
  pool_type TEXT NOT NULL,  -- 'COMPANY', 'REGIONAL', 'BRANCH'
  pool_id TEXT,             -- NULL for company, regional_office_id, or branch_id
  role TEXT NOT NULL,       -- 'RM', 'BH', 'BM', 'ROH'
  rank INTEGER NOT NULL,
  rank_change INTEGER,      -- NULL for first period
  total_score NUMERIC NOT NULL DEFAULT 0,
  calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, period_id, pool_type, pool_id, role)
);
```

**Alternative (simpler):** Keep only the company-wide rank on `user_score_aggregates` (the existing `rank`/`rank_change` columns) and compute regional/branch rankings on-demand via filtered queries. This avoids a new table but limits offline caching of filtered rankings. Given that "Rankings fetched on-demand only" is a locked decision, on-demand computation might be sufficient.

**My recommendation:** Use the simpler approach -- populate the existing `rank`/`rank_change` columns on `user_score_aggregates` for the primary (company-wide, same-role) ranking. For regional/branch filtered views, compute rankings dynamically in the Supabase query using `ROW_NUMBER()` or `DENSE_RANK()` via an RPC function. This avoids a migration for a new table and keeps complexity low.

### Pattern 3: Rank Change Computation
**What:** Compare current rank to same user's rank in the previous period of the same type.
**Recommendation:** Previous same-type period is the natural baseline (e.g., current WEEKLY rank vs previous WEEKLY rank).

```sql
-- Find previous period of same type
SELECT id INTO v_prev_period_id
FROM scoring_periods
WHERE period_type = v_current_period_type
  AND end_date < v_current_start_date
ORDER BY end_date DESC
LIMIT 1;

-- rank_change = previous_rank - current_rank
-- Positive = improved (was #5, now #3 = +2)
-- Negative = dropped (was #3, now #5 = -2)
```

For first-ever period: `rank_change = NULL` (not 0). The client already handles `rankChange == null` by showing a dash (`-`).

### Pattern 4: Score Update Pending Hint
**What:** Show subtle indicator when local data was modified but server hasn't recalculated scores yet.
**Implementation:** Check if any sync queue items exist for scoring-relevant entities (activities, pipelines, customers) that were modified after the last `calculated_at` on the user's aggregate.

### Pattern 5: Scoring Summary Grid
**What:** Admin/manager screen with users as rows, measures as columns, cells showing actual/target/%.
**Implementation:** New screen under admin routes. Uses a Supabase RPC or view that cross-joins users with measures and left-joins user_scores. Server-side aggregation avoids pulling all data client-side.

### Anti-Patterns to Avoid
- **Client-side ranking computation:** Never rank on client -- incomplete dataset, inconsistent results
- **Ranking during individual dirty user processing:** Must wait until ALL dirty users are processed for current run, otherwise rankings are computed against stale data for other users
- **Per-entity StreamProvider for ranking:** Use batch fetch, not per-user streams (same pattern as sync status badges)
- **Hardcoding period_id in ranking queries:** Always resolve "current period" dynamically via `is_current = TRUE`

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Ranking computation | Custom Dart sorting | PostgreSQL `DENSE_RANK()` window function | Database has full dataset; client only has partial |
| Rank change tracking | Client-side comparison | Server stores rank_change on each cron run | Needs historical data, atomic with rank update |
| Period type matching | Client-side period lookup | SQL `JOIN scoring_periods ON period_type` | Already implemented in `update_all_measure_scores` |
| Filtered ranking (branch/region) | Client-side filter+re-rank | SQL window function with PARTITION BY | Server has all users' data; client filters are incomplete |
| Score staleness detection | Complex timestamp comparison | Simple check: sync_queue has pending items for user's entities | Existing sync queue infrastructure supports this |

**Key insight:** Rankings are a global computation (comparing all users) that fundamentally cannot be done client-side. The server MUST compute and store them. The client's job is purely display.

## Common Pitfalls

### Pitfall 1: Ranking Before All Aggregates Are Updated
**What goes wrong:** If ranking runs for each dirty user individually, a user processed early gets ranked against stale aggregates of users processed later.
**Why it happens:** The cron processes dirty users sequentially.
**How to avoid:** Compute rankings ONCE, AFTER all dirty users in the batch are processed. The cron should: (1) loop through all dirty users and recalculate aggregates, (2) THEN call ranking function once for the display period.
**Warning signs:** Rankings that flip-flop between cron runs with no score changes.

### Pitfall 2: NULL Rank in Leaderboard Queries
**What goes wrong:** Leaderboard `ORDER BY rank ASC` puts NULL-ranked users first (PostgreSQL sorts NULLs last by default with ASC, but Supabase PostgREST may differ).
**Why it happens:** Users who haven't been ranked yet (e.g., new users before first cron run) have NULL rank.
**How to avoid:** Use `ORDER BY rank ASC NULLS LAST` in SQL, or ensure ranking function runs for all active users (not just dirty ones) at least once per period.
**Warning signs:** Unranked users appearing at top of leaderboard.

### Pitfall 3: Ranking Stale After Period Transition
**What goes wrong:** When a new period starts, user_score_aggregates for the new period don't exist yet, so rankings show the old period.
**Why it happens:** No dirty_users entries for the new period until business events occur.
**How to avoid:** When a new period is set as current (admin action), mark all active users as dirty to trigger recalculation in the new period.
**Warning signs:** Leaderboard showing previous period data after period transition.

### Pitfall 4: RLS Blocking Leaderboard Queries
**What goes wrong:** Leaderboard query joins user_score_aggregates with users table, but RLS on users restricts visibility.
**Why it happens:** Current users RLS policy already allows all authenticated SELECT (`users_select_authenticated`), and user_score_aggregates also has `user_score_aggregates_select_authenticated`. The RLS is already correct per the seed SQL. But the remote data source query `fetchLeaderboard` uses `.select('*, users!inner(...)')` which requires JOIN access.
**How to avoid:** Verify the RLS policies are deployed. The seed SQL has the right policies. No changes needed if policies match seed.
**Warning signs:** Empty leaderboard for non-admin users, 403 errors on leaderboard fetch.

### Pitfall 5: `snapshot_at` Column Reference in Remote Data Source
**What goes wrong:** `fetchUserPeriodSummary` orders by `snapshot_at` but the actual column may be `calculated_at`.
**Why it happens:** Legacy column naming from before rename to `user_score_aggregates`.
**How to avoid:** Check actual PostgreSQL column name. The Drift table has `calculated_at`. If PostgreSQL also uses `calculated_at`, the `.order('snapshot_at')` call will fail silently or throw.
**Warning signs:** Period summary returning NULL when data exists.

### Pitfall 6: Measure Auto-Deactivation Race Condition
**What goes wrong:** Measures deactivated mid-cron-run cause zero scores for some users but not others.
**Why it happens:** Auto-deactivation runs concurrently with score calculation.
**How to avoid:** Run auto-deactivation BEFORE score calculation in the cron, or run it as a separate scheduled task that doesn't overlap.
**Warning signs:** Inconsistent scores for same period across users.

## Code Examples

### Server-Side: Ranking Function (PostgreSQL)
```sql
-- Calculate rankings for a specific period
-- Called ONCE after all dirty users are processed
CREATE OR REPLACE FUNCTION calculate_rankings(
  p_period_id UUID
) RETURNS VOID AS $$
DECLARE
  v_prev_period_id UUID;
  v_current_period_type TEXT;
  v_current_start_date TIMESTAMPTZ;
BEGIN
  -- Get current period info for rank_change comparison
  SELECT period_type, start_date INTO v_current_period_type, v_current_start_date
  FROM scoring_periods WHERE id = p_period_id;

  -- Find previous period of same type
  SELECT id INTO v_prev_period_id
  FROM scoring_periods
  WHERE period_type = v_current_period_type
    AND end_date < v_current_start_date
    AND id != p_period_id
  ORDER BY end_date DESC
  LIMIT 1;

  -- Step 1: Calculate company-wide rank per role using DENSE_RANK
  WITH ranked AS (
    SELECT
      usa.id,
      DENSE_RANK() OVER (
        PARTITION BY u.role
        ORDER BY usa.total_score DESC
      ) AS new_rank
    FROM user_score_aggregates usa
    JOIN users u ON u.id = usa.user_id
    WHERE usa.period_id = p_period_id
      AND u.is_active = TRUE
      AND u.role NOT IN ('ADMIN', 'SUPERADMIN')
  )
  UPDATE user_score_aggregates
  SET rank = ranked.new_rank
  FROM ranked
  WHERE user_score_aggregates.id = ranked.id;

  -- Step 2: Calculate rank_change from previous period
  IF v_prev_period_id IS NOT NULL THEN
    UPDATE user_score_aggregates usa_current
    SET rank_change = usa_prev.rank - usa_current.rank
    FROM user_score_aggregates usa_prev
    WHERE usa_current.period_id = p_period_id
      AND usa_prev.period_id = v_prev_period_id
      AND usa_prev.user_id = usa_current.user_id
      AND usa_prev.rank IS NOT NULL;
    -- Users without previous period rank keep rank_change = NULL
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Server-Side: Updated Cron Edge Function (add ranking after dirty processing)
```typescript
// After all dirty users processed, calculate rankings
if (successCount > 0) {
  console.log("Calculating rankings...");
  const { error: rankError } = await supabase.rpc(
    "calculate_rankings",
    { p_period_id: periodId }
  );
  if (rankError) {
    console.error("Ranking calculation failed:", rankError);
  } else {
    console.log("Rankings updated");
  }
}
```

### Client-Side: Reading rank_change (fix in remote data source)
```dart
// Currently returns null:
// rankChange: null, // Would need previous period comparison

// Should read from server response:
rankChange: jsonMap['rank_change'] as int?,
```

### Client-Side: On-Demand Filtered Ranking (RPC)
```sql
-- RPC for filtered leaderboard with dynamic ranking
CREATE OR REPLACE FUNCTION get_filtered_leaderboard(
  p_period_id UUID,
  p_role TEXT DEFAULT NULL,
  p_branch_id UUID DEFAULT NULL,
  p_regional_office_id UUID DEFAULT NULL
) RETURNS TABLE (
  user_id UUID, user_name TEXT, branch_name TEXT, role TEXT,
  total_score NUMERIC, lead_score NUMERIC, lag_score NUMERIC,
  rank BIGINT, rank_change INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id AS user_id,
    u.name AS user_name,
    b.name AS branch_name,
    u.role,
    usa.total_score,
    usa.lead_score,
    usa.lag_score,
    DENSE_RANK() OVER (ORDER BY usa.total_score DESC)::BIGINT AS rank,
    usa.rank_change
  FROM user_score_aggregates usa
  JOIN users u ON u.id = usa.user_id
  LEFT JOIN branches b ON b.id = u.branch_id
  WHERE usa.period_id = p_period_id
    AND u.is_active = TRUE
    AND u.role NOT IN ('ADMIN', 'SUPERADMIN')
    AND (p_role IS NULL OR u.role = p_role)
    AND (p_branch_id IS NULL OR u.branch_id = p_branch_id::TEXT)
    AND (p_regional_office_id IS NULL OR u.regional_office_id = p_regional_office_id::TEXT)
  ORDER BY rank;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
```

### Client-Side: Score Update Pending Indicator
```dart
// Check if there are pending sync items for scoring-relevant entities
// that are newer than the last calculated_at
@riverpod
Future<bool> isScoreUpdatePending(ref) async {
  final db = ref.watch(appDatabaseProvider);
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return false;

  // Check sync queue for pending items from entities that affect scoring
  final pendingCount = await (db.select(db.syncQueueItems)
    ..where((t) => t.entityType.isIn(['activity', 'pipeline', 'customer'])
      & t.status.equals('pending')))
    .get();

  return pendingCount.isNotEmpty;
}
```

### Client-Side: Scoring Summary Grid Data Model
```dart
// Row in the scoring summary grid
class ScoringSummaryRow {
  final String userId;
  final String userName;
  final String role;
  final Map<String, ScoringSummaryCell> measureCells; // measureId -> cell
  final double compositeScore;
}

class ScoringSummaryCell {
  final double actualValue;
  final double targetValue;
  final double percentage;
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single period scoring (LIMIT 1 on is_current) | Multi-period via `JOIN scoring_periods ON period_type` | Migration 20260207000001 | Each measure scored against its own period type |
| Manual rank display ("0") | Server-computed DENSE_RANK | This phase | Actual rankings visible to users |
| `snapshot_at` column reference in remote DS | Should be `calculated_at` | Needs fix this phase | Prevents period summary fetch errors |

**Deprecated/outdated:**
- `recalculate_aggregate` from `20260206000004_fix_recalculate_aggregate.sql` -- superseded by `20260207000001_multi_period_scoring.sql` version
- `update_all_measure_scores` from `20260206000001_score_calculation_functions.sql` -- superseded by multi-period version

## Current Codebase State Analysis

### What Already Works
1. **Multi-period SQL functions** -- `update_all_measure_scores` joins measure_definitions to scoring_periods on period_type
2. **Dirty users pattern** -- Triggers mark users + ancestors dirty, cron processes batch
3. **Aggregate calculation** -- `recalculate_aggregate` computes lead_score, lag_score, total_score with hierarchical rollup
4. **RLS policies** -- user_score_aggregates and user_scores already have `SELECT_authenticated` policies
5. **Client-side multi-period fetching** -- `getUserScoresForCurrentPeriods()` fetches from all current periods
6. **Leaderboard UI** -- Full screen with period selector, filter chips (All/Branch/Region), search
7. **LeaderboardCard widget** -- Already handles rankChange display (arrows, colors)
8. **ScoreboardScreen** -- Personal score card, lead/lag measures sections, mini leaderboard
9. **TeamSummary** -- Shows team average score, member count, team rank (when populated)

### What Needs Fixing/Adding
1. **`rank`/`rank_change` never populated** -- The gap confirmed by `rankChange: null, // Would need previous period comparison` comments in `scoreboard_remote_data_source.dart` (lines 261, 310)
2. **`snapshot_at` reference** -- `fetchUserPeriodSummary` uses `.order('snapshot_at')` but column is likely `calculated_at`
3. **No ranking function** -- Need `calculate_rankings()` SQL function
4. **No role filter** on leaderboard -- Filter chips show All/Branch/Region but no role filter
5. **No scoring summary grid** -- New screen needed under admin/manager routes
6. **No "score update pending" hint** -- No staleness indicator on scoreboard
7. **No measure auto-deactivation** -- Measures stay active indefinitely
8. **Scoring data not in regular pull sync** -- `_pullFromRemote()` in SyncNotifier doesn't pull scoring data; scoring data is only fetched on-demand when opening scoreboard
9. **user_scores.targetValue** -- Remote data source reads `target_value` from measure_definitions join but the field name in the response is `target_value` on user_targets, not on the scores response. Need to verify the Supabase response includes the right field.

### Files That Need Changes

**Server-Side (SQL migrations):**
- New migration: `calculate_rankings()` function
- New migration: `get_filtered_leaderboard()` RPC function
- New migration: measure auto-deactivation function (cron or trigger)
- Verify: `snapshot_at` vs `calculated_at` column name in PostgreSQL

**Server-Side (Edge Functions):**
- `supabase/functions/score-aggregation-cron/index.ts` -- Add ranking call after dirty user processing

**Client-Side:**
- `lib/data/datasources/remote/scoreboard_remote_data_source.dart` -- Fix `rankChange: null` to read from response; fix `snapshot_at` reference
- `lib/presentation/providers/scoreboard_providers.dart` -- Add role filter, score pending indicator
- `lib/presentation/screens/scoreboard/leaderboard_screen.dart` -- Add role filter chip
- `lib/presentation/screens/scoreboard/scoreboard_screen.dart` -- Add "score update pending" hint
- New: `lib/presentation/screens/admin/4dx/scoring_summary_screen.dart` -- Grid screen
- `lib/config/routes/app_router.dart` + `route_names.dart` -- Add scoring summary route

## Discretion Recommendations

Based on the codebase analysis:

| Decision Area | Recommendation | Rationale |
|---------------|----------------|-----------|
| Tie-breaking | DENSE_RANK (ties share rank, no gaps) | More intuitive: 1,2,2,3 not 1,2,2,4 |
| Rank change baseline | Previous same-type period | Natural comparison; code already fetches periods by type |
| First-ever period | `rank_change = NULL` (show dash) | Already handled by client: `if (rankChange == null) return '-'` |
| Rank change display | Exact positions + direction ("+2 up") | LeaderboardCard already shows arrow icon; add position count |
| Role filter | Add as 4th filter chip alongside All/Branch/Region | Low effort, high value for comparing within role |
| Ranking timing | Same cron, after aggregate processing | Avoids second cron; natural sequence |
| Ranking storage | Existing columns for company-wide; RPC for filtered | Avoids new table migration; on-demand is sufficient per locked decision |
| Stale data | Check sync_queue for pending scoring-relevant items | Reuses existing sync infrastructure |
| Personal scoreboard source | Local-first (synced during scoreboard open) | Already works this way in repository impl |
| Period end detection | Cron checks `end_date < NOW()` for is_current periods | Simple, reliable; runs every 10 minutes anyway |

## Open Questions

1. **`snapshot_at` vs `calculated_at` in PostgreSQL**
   - What we know: Drift table uses `calculated_at`. Remote data source queries `.order('snapshot_at')`.
   - What's unclear: What the actual PostgreSQL column name is (may have been renamed).
   - Recommendation: Check PostgreSQL schema. If `calculated_at`, fix the remote data source query. If `snapshot_at`, fix the Drift table.

2. **Cron scheduling**
   - What we know: Edge Function exists at `supabase/functions/score-aggregation-cron/index.ts`. No pg_cron config visible in config.toml.
   - What's unclear: How the cron is actually scheduled (Supabase dashboard? pg_cron extension?).
   - Recommendation: Document the cron scheduling mechanism. The Edge Function is invoked via HTTP, so either pg_cron calls it or Supabase Cron (dashboard) triggers it.

3. **user_score_aggregates unique constraint**
   - What we know: The upsert uses `ON CONFLICT (user_id, period_id)`, implying a unique constraint on these columns.
   - What's unclear: Whether this unique constraint is explicitly defined or just via the primary key (id column is PK).
   - Recommendation: Verify the unique constraint exists. The upsert pattern requires it.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: Direct reading of all scoring-related files (database tables, entities, repositories, data sources, providers, screens, SQL migrations, Edge Functions)
- `lib/data/database/tables/scoring.dart` -- Drift table definitions with rank/rank_change columns
- `supabase/migrations/20260207000001_multi_period_scoring.sql` -- Multi-period scoring functions
- `supabase/functions/score-aggregation-cron/index.ts` -- Current cron implementation
- `docs/04-database/sql/04_rls_policies.sql` -- RLS policies (already correct for leaderboard access)
- `lib/data/datasources/remote/scoreboard_remote_data_source.dart` -- Lines 261, 310 confirm `rankChange: null` gap

### Secondary (MEDIUM confidence)
- PostgreSQL window functions (DENSE_RANK, RANK) -- well-established SQL standard, no version concerns
- Pattern analysis of existing cron Edge Function for ranking integration point

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All technologies already in project, no new libraries needed
- Architecture: HIGH -- Server-side scoring infrastructure exists and is well-structured; ranking is a natural extension
- Pitfalls: HIGH -- Identified from direct codebase analysis (snapshot_at bug, null rank ordering, period transition)
- Scoring summary grid: MEDIUM -- New screen following existing admin patterns, but grid layout needs design decisions

**Research date:** 2026-02-23
**Valid until:** 2026-03-23 (stable domain, no external dependency version concerns)
