-- Multi-Period Scoring Support
-- Allows LEAD measures scored on short-term periods (e.g., WEEKLY)
-- and LAG measures on long-term periods (e.g., QUARTERLY),
-- configurable per measure_definitions.period_type.

-- ============================================================================
-- 1A. Partial unique index: enforce one current period per period_type
-- ============================================================================

CREATE UNIQUE INDEX IF NOT EXISTS idx_scoring_periods_one_current_per_type
  ON scoring_periods (period_type)
  WHERE is_current = TRUE;

COMMENT ON INDEX idx_scoring_periods_one_current_per_type IS
  'Ensures at most one current period per period_type (WEEKLY, MONTHLY, QUARTERLY, YEARLY).';


-- ============================================================================
-- 1B. Replace update_all_measure_scores
-- ============================================================================
-- Previously: got ONE current period, scored all measures against it.
-- Now: joins measure_definitions to scoring_periods on period_type
-- so each measure scores against its own current period.

CREATE OR REPLACE FUNCTION update_all_measure_scores(
  p_user_id UUID
) RETURNS VOID AS $$
DECLARE
  v_rec RECORD;
BEGIN
  -- For each active measure, find its matching current period by period_type
  FOR v_rec IN
    SELECT md.id AS measure_id, sp.id AS period_id
    FROM measure_definitions md
    JOIN scoring_periods sp
      ON sp.period_type = md.period_type
      AND sp.is_current = TRUE
    WHERE md.is_active = TRUE
  LOOP
    PERFORM update_user_score(p_user_id, v_rec.measure_id, v_rec.period_id);
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_all_measure_scores IS
  'Updates all measure scores for a user. Each measure is scored against its own current period (matched by period_type).';


-- ============================================================================
-- 1C. Replace recalculate_aggregate
-- ============================================================================
-- p_period_id is the "display period" (shortest granularity).
-- LEAD and LAG score queries now join through scoring_periods
-- to match each measure''s period_type to its current period.

CREATE OR REPLACE FUNCTION recalculate_aggregate(
  p_user_id UUID,
  p_period_id UUID
) RETURNS VOID AS $$
DECLARE
  v_lead_points NUMERIC := 0;
  v_lag_points NUMERIC := 0;
  v_lead_measures_count INTEGER;
  v_lag_measures_count INTEGER;
  v_lead_score NUMERIC := 0;
  v_lag_score NUMERIC := 0;
  v_total_score NUMERIC := 0;
  v_subordinate_ids UUID[];
BEGIN
  -- Get all subordinate IDs from hierarchy
  SELECT ARRAY_AGG(DISTINCT descendant_id)
  INTO v_subordinate_ids
  FROM user_hierarchy
  WHERE ancestor_id = p_user_id;

  -- Include self in the array
  IF v_subordinate_ids IS NULL THEN
    v_subordinate_ids := ARRAY[p_user_id];
  ELSE
    v_subordinate_ids := v_subordinate_ids || p_user_id;
  END IF;

  -- Count active measures by type
  SELECT COUNT(*) INTO v_lead_measures_count
  FROM measure_definitions
  WHERE measure_type = 'LEAD' AND is_active = TRUE;

  SELECT COUNT(*) INTO v_lag_measures_count
  FROM measure_definitions
  WHERE measure_type = 'LAG' AND is_active = TRUE;

  -- Calculate LEAD points: join through scoring_periods to match period_type
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lead_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE
    AND sp.period_type = md.period_type
    AND md.measure_type = 'LEAD'
    AND md.is_active = TRUE;

  -- Calculate LAG points: same pattern
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lag_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE
    AND sp.period_type = md.period_type
    AND md.measure_type = 'LAG'
    AND md.is_active = TRUE;

  -- Calculate scores (0-150 scale)
  IF v_lead_measures_count > 0 THEN
    v_lead_score := (v_lead_points / (v_lead_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  IF v_lag_measures_count > 0 THEN
    v_lag_score := (v_lag_points / (v_lag_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  -- Total score: weighted average (60% LEAD, 40% LAG)
  v_total_score := (v_lead_score * 0.6) + (v_lag_score * 0.4);

  -- Upsert into user_score_aggregates
  -- p_period_id is the display period (shortest granularity)
  INSERT INTO user_score_aggregates (
    user_id, period_id,
    lead_score, lag_score, total_score,
    bonus_points, penalty_points,
    calculated_at, created_at
  ) VALUES (
    p_user_id, p_period_id,
    v_lead_score, v_lag_score, v_total_score,
    0, 0,
    NOW(), NOW()
  )
  ON CONFLICT (user_id, period_id)
  DO UPDATE SET
    lead_score = EXCLUDED.lead_score,
    lag_score = EXCLUDED.lag_score,
    total_score = EXCLUDED.total_score,
    calculated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION recalculate_aggregate IS
  'Recalculates user_score_aggregates with HIERARCHICAL ROLLUP. Pulls LEAD/LAG scores from their respective current periods (matched by period_type). Upsert key uses the display period (shortest granularity).';


-- ============================================================================
-- 1D. Replace recalculate_all_scores
-- ============================================================================
-- Resolves display period as shortest current period
-- (WEEKLY < MONTHLY < QUARTERLY < YEARLY).

CREATE OR REPLACE FUNCTION recalculate_all_scores()
RETURNS VOID AS $$
DECLARE
  v_user_id UUID;
  v_display_period_id UUID;
BEGIN
  -- Find display period: shortest-granularity current period
  SELECT id INTO v_display_period_id
  FROM scoring_periods
  WHERE is_current = TRUE
  ORDER BY
    CASE period_type
      WHEN 'WEEKLY' THEN 1
      WHEN 'MONTHLY' THEN 2
      WHEN 'QUARTERLY' THEN 3
      WHEN 'YEARLY' THEN 4
      ELSE 5
    END
  LIMIT 1;

  IF v_display_period_id IS NULL THEN
    RAISE EXCEPTION 'No current scoring period found';
  END IF;

  -- Recalculate individual measures for all active users
  -- (update_all_measure_scores handles per-measure period matching internally)
  FOR v_user_id IN
    SELECT id FROM users WHERE is_active = TRUE
  LOOP
    PERFORM update_all_measure_scores(v_user_id);
  END LOOP;

  -- Recalculate aggregates for all active users using display period
  FOR v_user_id IN
    SELECT id FROM users WHERE is_active = TRUE
  LOOP
    PERFORM recalculate_aggregate(v_user_id, v_display_period_id);
  END LOOP;

  RAISE NOTICE 'Recalculated all scores for display period %', v_display_period_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION recalculate_all_scores IS
  'ADMIN ONLY: Recalculates all user scores and aggregates. Each measure scores against its own current period. Aggregates use the shortest-granularity display period.';
