-- Hotfix for recalculate_aggregate function
-- Fixes UNION types mismatch error when building subordinate array

CREATE OR REPLACE FUNCTION recalculate_aggregate(
  p_user_id UUID,
  p_period_id UUID
) RETURNS VOID AS $$
DECLARE
  v_lead_points NUMERIC := 0;
  v_lag_points NUMERIC := 0;
  v_total_points NUMERIC := 0;
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
    -- No subordinates, just self
    v_subordinate_ids := ARRAY[p_user_id];
  ELSE
    -- Has subordinates, add self to the array
    v_subordinate_ids := v_subordinate_ids || p_user_id;
  END IF;

  -- Count active measures by type
  SELECT COUNT(*) INTO v_lead_measures_count
  FROM measure_definitions
  WHERE measure_type = 'LEAD' AND is_active = TRUE;

  SELECT COUNT(*) INTO v_lag_measures_count
  FROM measure_definitions
  WHERE measure_type = 'LAG' AND is_active = TRUE;

  -- Calculate LEAD points (sum scores across self + subordinates)
  -- Note: using 'score' column, not 'points'
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lead_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND us.period_id = p_period_id
    AND md.measure_type = 'LEAD'
    AND md.is_active = TRUE;

  -- Calculate LAG points (sum scores across self + subordinates)
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lag_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND us.period_id = p_period_id
    AND md.measure_type = 'LAG'
    AND md.is_active = TRUE;

  -- Calculate scores (0-150 scale)
  -- Formula: (total_points / (measure_count * subordinate_count * 150)) * 150
  IF v_lead_measures_count > 0 THEN
    v_lead_score := (v_lead_points / (v_lead_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  IF v_lag_measures_count > 0 THEN
    v_lag_score := (v_lag_points / (v_lag_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  -- Total score: weighted average (60% LEAD, 40% LAG)
  v_total_score := (v_lead_score * 0.6) + (v_lag_score * 0.4);

  -- Upsert into user_score_aggregates
  -- Note: bonus_points and penalty_points default to 0 (will be updated by cadence system later)
  INSERT INTO user_score_aggregates (
    user_id, period_id,
    lead_score, lag_score, total_score,
    bonus_points, penalty_points,
    calculated_at, created_at
  ) VALUES (
    p_user_id, p_period_id,
    v_lead_score, v_lag_score, v_total_score,
    0, 0,  -- bonus/penalty handled by cadence system
    NOW(), NOW()
  )
  ON CONFLICT (user_id, period_id)
  DO UPDATE SET
    lead_score = EXCLUDED.lead_score,
    lag_score = EXCLUDED.lag_score,
    total_score = EXCLUDED.total_score,
    calculated_at = NOW();
  -- Note: NOT updating bonus_points/penalty_points here - managed by cadence system
  -- Note: NOT updating created_at - preserve original creation time
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION recalculate_aggregate IS 'Recalculates user_score_aggregates with HIERARCHICAL ROLLUP (includes subordinates). Example: ROH score = ROH activities + all BMs + all BHs + all RMs.';
