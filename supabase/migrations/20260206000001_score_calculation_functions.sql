-- Score Calculation Functions for 4DX System
-- Implements dynamic query building from measure_definitions
-- Includes hierarchical score aggregation (managers include subordinates)

-- ============================================================================
-- Function 1: calculate_measure_value
-- ============================================================================
-- Dynamically builds and executes SQL query based on measure_definition
-- Returns the raw value for a measure (e.g., count of visits, sum of premium)

CREATE OR REPLACE FUNCTION calculate_measure_value(
  p_user_id UUID,
  p_measure_id UUID,
  p_period_id UUID
) RETURNS NUMERIC AS $$
DECLARE
  v_measure RECORD;
  v_period RECORD;
  v_result NUMERIC;
  v_query TEXT;
BEGIN
  -- Get measure definition
  SELECT
    source_table,
    source_condition,
    data_type,
    code
  INTO v_measure
  FROM measure_definitions
  WHERE id = p_measure_id AND is_active = TRUE;

  -- If measure not found or inactive, return 0
  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  -- Get period date range
  SELECT start_date, end_date
  INTO v_period
  FROM scoring_periods
  WHERE id = p_period_id;

  -- If period not found, return 0
  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  -- Build query based on data_type
  BEGIN
    IF v_measure.data_type = 'COUNT' THEN
      -- Count records matching condition
      -- Use appropriate date column based on source table
      IF v_measure.source_table = 'pipeline_stage_history' THEN
        v_query := format(
          'SELECT COUNT(*) FROM %I WHERE %s AND changed_at BETWEEN $1 AND $2',
          v_measure.source_table,
          replace(v_measure.source_condition, ':user_id', '$3')
        );
      ELSE
        v_query := format(
          'SELECT COUNT(*) FROM %I WHERE %s AND created_at BETWEEN $1 AND $2',
          v_measure.source_table,
          replace(v_measure.source_condition, ':user_id', '$3')
        );
      END IF;
      EXECUTE v_query INTO v_result USING v_period.start_date, v_period.end_date, p_user_id;

    ELSIF v_measure.data_type = 'SUM' THEN
      -- Sum a specific field (e.g., final_premium)
      -- Extract field name from source_table context
      IF v_measure.source_table = 'pipelines' THEN
        -- For pipelines, sum final_premium when closed_at is in the period
        v_query := format(
          'SELECT COALESCE(SUM(final_premium), 0) FROM %I WHERE %s AND closed_at BETWEEN $1 AND $2',
          v_measure.source_table,
          replace(v_measure.source_condition, ':user_id', '$3')
        );
        EXECUTE v_query INTO v_result USING v_period.start_date, v_period.end_date, p_user_id;
      ELSE
        -- Default SUM behavior for other tables
        v_result := 0;
      END IF;

    ELSIF v_measure.data_type = 'PERCENTAGE' THEN
      -- Special calculation for conversion rate
      IF v_measure.source_table = 'pipelines' THEN
        -- Calculate (won pipelines / total closed pipelines) * 100
        v_query := format(
          'SELECT
             CASE WHEN COUNT(*) > 0
             THEN (COUNT(*) FILTER (WHERE stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true))::NUMERIC / COUNT(*)) * 100
             ELSE 0
             END
           FROM %I
           WHERE scored_to_user_id = $1 AND closed_at BETWEEN $2 AND $3',
          v_measure.source_table
        );
        EXECUTE v_query INTO v_result USING p_user_id, v_period.start_date, v_period.end_date;
      ELSE
        v_result := 0;
      END IF;

    ELSE
      -- Unknown data_type, return 0
      v_result := 0;
    END IF;

    RETURN COALESCE(v_result, 0);

  EXCEPTION WHEN OTHERS THEN
    -- Log error to system_errors table (will be created in next migration)
    -- For now, just return 0 to avoid breaking the transaction
    RAISE WARNING 'calculate_measure_value failed for measure %: %', v_measure.code, SQLERRM;
    RETURN 0;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================================
-- Function 2: update_user_score
-- ============================================================================
-- Updates a single user_scores row for a specific measure
-- Calculates actual value, achievement percentage, and points

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
  -- Calculate actual value
  v_actual_value := calculate_measure_value(p_user_id, p_measure_id, p_period_id);

  -- Get target and weight
  SELECT target_value INTO v_target_value
  FROM user_targets
  WHERE user_id = p_user_id
    AND measure_id = p_measure_id
    AND period_id = p_period_id;

  -- If no target assigned, use default target from measure_definition
  IF v_target_value IS NULL THEN
    SELECT default_target, weight INTO v_target_value, v_weight
    FROM measure_definitions
    WHERE id = p_measure_id;
  ELSE
    SELECT weight INTO v_weight
    FROM measure_definitions
    WHERE id = p_measure_id;
  END IF;

  -- Calculate achievement percentage
  IF v_target_value > 0 THEN
    v_achievement_pct := (v_actual_value / v_target_value) * 100;
  ELSE
    v_achievement_pct := 0;
  END IF;

  -- Calculate score (cap percentage at 150%, then multiply by weight)
  v_points := LEAST(v_achievement_pct, 150) * v_weight;

  -- Upsert into user_scores
  -- Note: Using correct column names (actual_value, target_value, percentage, score, calculated_at)
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


-- ============================================================================
-- Function 3: recalculate_aggregate (WITH HIERARCHICAL ROLLUP)
-- ============================================================================
-- Recalculates user_score_aggregates for a user
-- IMPORTANT: Includes user's own scores + all subordinates' scores
-- This implements the 4DX principle: leaders accountable for team results

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


-- ============================================================================
-- Function 4: mark_user_and_ancestors_dirty
-- ============================================================================
-- Marks a user and all their ancestors as dirty
-- This ensures manager scores get recalculated when subordinates' data changes

CREATE OR REPLACE FUNCTION mark_user_and_ancestors_dirty(
  p_user_id UUID
) RETURNS VOID AS $$
BEGIN
  -- Insert user and all ancestors into dirty_users
  INSERT INTO dirty_users (user_id, dirtied_at)
  SELECT DISTINCT ancestor_id, NOW()
  FROM user_hierarchy
  WHERE descendant_id = p_user_id
  UNION
  SELECT p_user_id, NOW()  -- Include self
  ON CONFLICT (user_id) DO NOTHING;  -- Avoid duplicate key errors
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================================
-- Helper Function: update_all_measure_scores
-- ============================================================================
-- Updates all measure scores for a user in the current period
-- Used by triggers to recalculate all measures when data changes

CREATE OR REPLACE FUNCTION update_all_measure_scores(
  p_user_id UUID
) RETURNS VOID AS $$
DECLARE
  v_current_period_id UUID;
  v_measure_id UUID;
BEGIN
  -- Get current period
  SELECT id INTO v_current_period_id
  FROM scoring_periods
  WHERE is_current = TRUE
  LIMIT 1;

  -- If no current period, nothing to do
  IF v_current_period_id IS NULL THEN
    RETURN;
  END IF;

  -- Update all active measures
  FOR v_measure_id IN
    SELECT id FROM measure_definitions WHERE is_active = TRUE
  LOOP
    PERFORM update_user_score(p_user_id, v_measure_id, v_current_period_id);
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Add comments for documentation
COMMENT ON FUNCTION calculate_measure_value IS 'Dynamically calculates measure value from source_table/source_condition. Returns raw value (count, sum, percentage).';
COMMENT ON FUNCTION update_user_score IS 'Updates user_scores row with calculated actual_value, achievement_percentage, and points.';
COMMENT ON FUNCTION recalculate_aggregate IS 'Recalculates user_score_aggregates with HIERARCHICAL ROLLUP (includes subordinates). Example: ROH score = ROH activities + all BMs + all BHs + all RMs.';
COMMENT ON FUNCTION mark_user_and_ancestors_dirty IS 'Marks user and all ancestors for aggregate recalculation. Used by triggers to cascade updates up the hierarchy.';
COMMENT ON FUNCTION update_all_measure_scores IS 'Helper function to update all measure scores for a user in the current period.';
