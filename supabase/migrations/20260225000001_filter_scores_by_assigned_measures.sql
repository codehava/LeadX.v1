-- Filter Scoreboard to Only Show Assigned Measures
-- Problem: update_all_measure_scores iterates ALL active measure_definitions,
-- and update_user_score falls back to default_target when no user_targets row exists,
-- creating user_scores for every measure regardless of assignment.
-- Fix: Guard all scoring functions to only process measures assigned via user_targets.

-- ============================================================================
-- 1A. Replace update_all_measure_scores — skip unassigned measures
-- ============================================================================
-- Previously: scored ALL active measures for a user.
-- Now: only scores measures where a user_targets row exists for the user.

CREATE OR REPLACE FUNCTION update_all_measure_scores(
  p_user_id UUID
) RETURNS VOID AS $$
DECLARE
  v_rec RECORD;
BEGIN
  -- For each active measure that the user is assigned to,
  -- find its matching current period by period_type
  FOR v_rec IN
    SELECT md.id AS measure_id, sp.id AS period_id
    FROM measure_definitions md
    JOIN scoring_periods sp
      ON sp.period_type = md.period_type
      AND sp.is_current = TRUE
    WHERE md.is_active = TRUE
      AND EXISTS (
        SELECT 1 FROM user_targets ut
        WHERE ut.user_id = p_user_id
          AND ut.measure_id = md.id
          AND ut.period_id = sp.id
      )
  LOOP
    PERFORM update_user_score(p_user_id, v_rec.measure_id, v_rec.period_id);
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_all_measure_scores IS
  'Updates measure scores for a user. Only processes measures assigned via user_targets. Each measure scored against its own current period (matched by period_type).';


-- ============================================================================
-- 1B. Replace update_user_score — remove default_target fallback
-- ============================================================================
-- Previously: fell back to measure_definitions.default_target when no user_targets row.
-- Now: returns early if no user_targets row (belt-and-suspenders with 1A guard).

CREATE OR REPLACE FUNCTION update_user_score(
  p_user_id UUID,
  p_measure_id UUID,
  p_period_id UUID
) RETURNS VOID AS $$
DECLARE
  v_actual_value NUMERIC;
  v_target_value NUMERIC;
  v_achievement_pct NUMERIC;
  v_points NUMERIC;
  v_weight NUMERIC;
BEGIN
  -- Get target from user_targets — if not assigned, skip this measure
  SELECT target_value INTO v_target_value
  FROM user_targets
  WHERE user_id = p_user_id
    AND measure_id = p_measure_id
    AND period_id = p_period_id;

  -- No assignment → do nothing (belt-and-suspenders with update_all_measure_scores guard)
  IF NOT FOUND THEN
    RETURN;
  END IF;

  -- Get weight from measure definition
  SELECT weight INTO v_weight
  FROM measure_definitions
  WHERE id = p_measure_id;

  -- Calculate actual value
  v_actual_value := calculate_measure_value(p_user_id, p_measure_id, p_period_id);

  -- Calculate achievement percentage
  IF v_target_value > 0 THEN
    v_achievement_pct := (v_actual_value / v_target_value) * 100;
  ELSE
    v_achievement_pct := 0;
  END IF;

  -- Calculate score (cap percentage at 150%, then multiply by weight)
  v_points := LEAST(v_achievement_pct, 150) * v_weight;

  -- Upsert into user_scores
  INSERT INTO user_scores (
    user_id, measure_id, period_id,
    actual_value, target_value, percentage, score,
    calculated_at, updated_at
  ) VALUES (
    p_user_id, p_measure_id, p_period_id,
    v_actual_value, v_target_value, v_achievement_pct, v_points,
    NOW(), NOW()
  )
  ON CONFLICT (user_id, measure_id, period_id)
  DO UPDATE SET
    actual_value = EXCLUDED.actual_value,
    target_value = EXCLUDED.target_value,
    percentage = EXCLUDED.percentage,
    score = EXCLUDED.score,
    calculated_at = NOW(),
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_user_score IS
  'Updates a single user_scores row. Returns early if no user_targets assignment exists (no default_target fallback).';


-- ============================================================================
-- 1C. Replace recalculate_aggregate — count measures per user (assigned only)
-- ============================================================================
-- Previously: counted ALL active measures globally.
-- Now: counts only measures assigned to the user via user_targets.

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

  -- Count assigned LEAD measures for this user (not global count)
  SELECT COUNT(*) INTO v_lead_measures_count
  FROM measure_definitions md
  WHERE md.measure_type = 'LEAD' AND md.is_active = TRUE
    AND EXISTS (
      SELECT 1 FROM user_targets ut
      WHERE ut.measure_id = md.id
        AND ut.user_id = p_user_id
    );

  -- Count assigned LAG measures for this user (not global count)
  SELECT COUNT(*) INTO v_lag_measures_count
  FROM measure_definitions md
  WHERE md.measure_type = 'LAG' AND md.is_active = TRUE
    AND EXISTS (
      SELECT 1 FROM user_targets ut
      WHERE ut.measure_id = md.id
        AND ut.user_id = p_user_id
    );

  -- Calculate LEAD points: join through scoring_periods to match period_type
  -- user_scores now only contains assigned measures (after 1A guard),
  -- but add EXISTS guard for safety
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lead_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE
    AND sp.period_type = md.period_type
    AND md.measure_type = 'LEAD'
    AND md.is_active = TRUE
    AND EXISTS (
      SELECT 1 FROM user_targets ut
      WHERE ut.measure_id = us.measure_id
        AND ut.user_id = us.user_id
        AND ut.period_id = us.period_id
    );

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
    AND md.is_active = TRUE
    AND EXISTS (
      SELECT 1 FROM user_targets ut
      WHERE ut.measure_id = us.measure_id
        AND ut.user_id = us.user_id
        AND ut.period_id = us.period_id
    );

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
  'Recalculates user_score_aggregates with HIERARCHICAL ROLLUP. Only counts measures assigned via user_targets (per-user, not global). Upsert key uses the display period (shortest granularity).';


-- ============================================================================
-- 1D. Clean up orphaned user_scores (one-time)
-- ============================================================================
-- Remove scores where no corresponding user_targets assignment exists.
-- Wrapped in DO block to skip gracefully if user_scores table doesn't exist yet.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'user_scores'
  ) THEN
    DELETE FROM user_scores us
    WHERE NOT EXISTS (
      SELECT 1 FROM user_targets ut
      WHERE ut.user_id = us.user_id
        AND ut.measure_id = us.measure_id
        AND ut.period_id = us.period_id
    );
  END IF;
END $$;
