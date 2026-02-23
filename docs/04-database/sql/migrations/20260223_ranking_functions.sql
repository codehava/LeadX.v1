-- ============================================================================
-- Ranking Functions for Phase 10: Scoring Optimization
-- Creates: calculate_rankings, get_filtered_leaderboard, deactivate_expired_measures
-- ============================================================================
--
-- RLS VERIFICATION NOTE (Phase 10):
-- The following SELECT policies already exist in 04_rls_policies.sql and are
-- sufficient for leaderboard access:
--   - user_score_aggregates_select_authenticated (all authenticated can SELECT)
--   - user_scores_select_authenticated (all authenticated can SELECT)
--   - users_select_authenticated (all authenticated can SELECT basic profile)
-- The get_filtered_leaderboard() RPC uses SECURITY DEFINER, so RLS is bypassed
-- for the ranking computation. Results are filtered by the function's parameters.
-- No new RLS policies needed for Phase 10.
-- ============================================================================


-- ============================================================================
-- 1. Schema Additions: New rank columns for branch and regional pools
-- ============================================================================
-- The existing `rank` and `rank_change` columns represent company-wide ranking.
-- Add four new columns for the other two ranking pools.

ALTER TABLE user_score_aggregates
  ADD COLUMN IF NOT EXISTS branch_rank INTEGER,
  ADD COLUMN IF NOT EXISTS branch_rank_change INTEGER,
  ADD COLUMN IF NOT EXISTS regional_rank INTEGER,
  ADD COLUMN IF NOT EXISTS regional_rank_change INTEGER;

COMMENT ON COLUMN user_score_aggregates.rank IS 'Company-wide rank within role (DENSE_RANK)';
COMMENT ON COLUMN user_score_aggregates.rank_change IS 'Company-wide rank change vs previous period (positive = improved)';
COMMENT ON COLUMN user_score_aggregates.branch_rank IS 'Per-branch rank within role (DENSE_RANK)';
COMMENT ON COLUMN user_score_aggregates.branch_rank_change IS 'Per-branch rank change vs previous period (positive = improved)';
COMMENT ON COLUMN user_score_aggregates.regional_rank IS 'Per-regional-office rank within role (DENSE_RANK)';
COMMENT ON COLUMN user_score_aggregates.regional_rank_change IS 'Per-regional-office rank change vs previous period (positive = improved)';


-- ============================================================================
-- 2. calculate_rankings(p_period_id UUID)
-- ============================================================================
-- Computes rankings across THREE pools per locked decisions.
-- All pools partition by role (RM vs RM, BH vs BH, etc.).
--
-- Pool 1: Company-wide   -> rank, rank_change columns
-- Pool 2: Per-branch     -> branch_rank, branch_rank_change columns
-- Pool 3: Per-regional   -> regional_rank, regional_rank_change columns
--
-- Called by the cron Edge Function AFTER all dirty users are processed.
-- Excludes admins and inactive users. Includes zero-score users at bottom.
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_rankings(
  p_period_id UUID
) RETURNS VOID AS $$
DECLARE
  v_prev_period_id UUID;
  v_current_period_type TEXT;
  v_current_start_date TIMESTAMPTZ;
BEGIN
  -- Get current period info for rank_change comparison
  SELECT period_type, start_date
  INTO v_current_period_type, v_current_start_date
  FROM scoring_periods
  WHERE id = p_period_id;

  IF v_current_period_type IS NULL THEN
    RAISE EXCEPTION 'Period % not found', p_period_id;
  END IF;

  -- Find previous period of same type for rank_change computation
  SELECT id INTO v_prev_period_id
  FROM scoring_periods
  WHERE period_type = v_current_period_type
    AND end_date < v_current_start_date
    AND id != p_period_id
  ORDER BY end_date DESC
  LIMIT 1;

  -- -----------------------------------------------------------------------
  -- Step 1: Compute all three pool ranks in a single UPDATE using CTEs
  -- -----------------------------------------------------------------------
  WITH ranked AS (
    SELECT
      usa.id AS agg_id,
      -- Pool 1: Company-wide rank (partition by role only)
      DENSE_RANK() OVER (
        PARTITION BY u.role
        ORDER BY usa.total_score DESC
      ) AS company_rank,
      -- Pool 2: Per-branch rank (partition by role + branch)
      DENSE_RANK() OVER (
        PARTITION BY u.role, u.branch_id
        ORDER BY usa.total_score DESC
      ) AS new_branch_rank,
      -- Pool 3: Per-regional rank (partition by role + regional_office_id via branches)
      DENSE_RANK() OVER (
        PARTITION BY u.role, COALESCE(u.regional_office_id, b.regional_office_id)
        ORDER BY usa.total_score DESC
      ) AS new_regional_rank
    FROM user_score_aggregates usa
    JOIN users u ON u.id = usa.user_id
    LEFT JOIN branches b ON b.id = u.branch_id
    WHERE usa.period_id = p_period_id
      AND u.is_active = TRUE
      AND u.role NOT IN ('ADMIN', 'SUPERADMIN')
  )
  UPDATE user_score_aggregates usa
  SET
    rank = ranked.company_rank,
    branch_rank = ranked.new_branch_rank,
    regional_rank = ranked.new_regional_rank
  FROM ranked
  WHERE usa.id = ranked.agg_id;

  -- -----------------------------------------------------------------------
  -- Step 2: Compute rank_change for all three pools from previous period
  -- -----------------------------------------------------------------------
  IF v_prev_period_id IS NOT NULL THEN
    -- Update rank_change for all three pools in a single statement
    UPDATE user_score_aggregates usa_current
    SET
      rank_change = usa_prev.rank - usa_current.rank,
      branch_rank_change = usa_prev.branch_rank - usa_current.branch_rank,
      regional_rank_change = usa_prev.regional_rank - usa_current.regional_rank
    FROM user_score_aggregates usa_prev
    WHERE usa_current.period_id = p_period_id
      AND usa_prev.period_id = v_prev_period_id
      AND usa_prev.user_id = usa_current.user_id;
    -- Users without previous period data keep all rank_change columns as NULL
    -- (first-ever period, or new user). Client already handles NULL as dash.
  END IF;
  -- If v_prev_period_id IS NULL (first-ever period), all rank_change columns
  -- remain NULL. This is intentional per locked decision.
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION calculate_rankings(UUID) IS
  'Computes rankings across 3 pools (company-wide, per-branch, per-regional) partitioned by role. Called by cron AFTER all dirty users are processed. Uses DENSE_RANK for intuitive tie handling (1,2,2,3 not 1,2,2,4). Rank_change computed from previous same-type period.';


-- ============================================================================
-- 3. get_filtered_leaderboard(...)
-- ============================================================================
-- Returns dynamically ranked results for the leaderboard screen.
-- Computes DENSE_RANK within the filtered subset for the rank column.
-- Selects appropriate pre-computed rank_change based on filter context:
--   - p_branch_id set     -> usa.branch_rank_change
--   - p_regional_office_id set -> usa.regional_rank_change
--   - Otherwise           -> usa.rank_change (company-wide)
-- ============================================================================

CREATE OR REPLACE FUNCTION get_filtered_leaderboard(
  p_period_id UUID,
  p_role TEXT DEFAULT NULL,
  p_branch_id UUID DEFAULT NULL,
  p_regional_office_id UUID DEFAULT NULL
) RETURNS TABLE (
  user_id UUID,
  user_name TEXT,
  branch_name TEXT,
  role TEXT,
  total_score NUMERIC,
  lead_score NUMERIC,
  lag_score NUMERIC,
  rank BIGINT,
  rank_change INTEGER
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
    -- Select rank_change based on filter context
    CASE
      WHEN p_branch_id IS NOT NULL THEN usa.branch_rank_change
      WHEN p_regional_office_id IS NOT NULL THEN usa.regional_rank_change
      ELSE usa.rank_change
    END AS rank_change
  FROM user_score_aggregates usa
  JOIN users u ON u.id = usa.user_id
  LEFT JOIN branches b ON b.id = u.branch_id
  WHERE usa.period_id = p_period_id
    AND u.is_active = TRUE
    AND u.role NOT IN ('ADMIN', 'SUPERADMIN')
    AND (p_role IS NULL OR u.role = p_role)
    AND (p_branch_id IS NULL OR u.branch_id = p_branch_id)
    AND (p_regional_office_id IS NULL OR
         COALESCE(u.regional_office_id, b.regional_office_id) = p_regional_office_id)
  ORDER BY rank ASC NULLS LAST;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION get_filtered_leaderboard(UUID, TEXT, UUID, UUID) IS
  'Returns dynamically ranked leaderboard results filtered by optional role, branch, and regional office. Uses DENSE_RANK within the filtered subset. Returns appropriate rank_change based on filter context (branch/regional/company-wide).';


-- ============================================================================
-- 4. deactivate_expired_measures()
-- ============================================================================
-- Auto-deactivates measures whose period has ended.
-- Finds measures where the matching scoring_period (by period_type) is current
-- but its end_date has passed.
-- Returns count of deactivated measures for logging.
-- ============================================================================

CREATE OR REPLACE FUNCTION deactivate_expired_measures()
RETURNS INTEGER AS $$
DECLARE
  v_deactivated_count INTEGER;
BEGIN
  UPDATE measure_definitions md
  SET is_active = FALSE
  WHERE md.is_active = TRUE
    AND EXISTS (
      SELECT 1
      FROM scoring_periods sp
      WHERE sp.period_type = md.period_type
        AND sp.is_current = TRUE
        AND sp.end_date < NOW()
    );

  GET DIAGNOSTICS v_deactivated_count = ROW_COUNT;
  RETURN v_deactivated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION deactivate_expired_measures() IS
  'Auto-deactivates measure_definitions whose period has ended (is_current=true but end_date < NOW()). Returns count of deactivated measures. Admin manually reactivates for new periods.';
