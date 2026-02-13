-- Multi-Period Scoring Support
-- Allows LEAD measures scored on short-term periods (e.g., WEEKLY)
-- and LAG measures on long-term periods (e.g., QUARTERLY),
-- configurable per measure_definitions.period_type.
--
-- Actual migration: supabase/migrations/20260207000001_multi_period_scoring.sql

-- ============================================================================
-- 1. Partial unique index: enforce one current period per period_type
-- ============================================================================

CREATE UNIQUE INDEX IF NOT EXISTS idx_scoring_periods_one_current_per_type
  ON scoring_periods (period_type)
  WHERE is_current = TRUE;

-- ============================================================================
-- 2. update_all_measure_scores: now matches each measure to its own current period
-- ============================================================================

CREATE OR REPLACE FUNCTION update_all_measure_scores(
  p_user_id UUID
) RETURNS VOID AS $$
DECLARE
  v_rec RECORD;
BEGIN
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

-- ============================================================================
-- 3. recalculate_aggregate: pulls LEAD/LAG from their respective current periods
-- ============================================================================

CREATE OR REPLACE FUNCTION recalculate_aggregate(
  p_user_id UUID,
  p_period_id UUID  -- display period (shortest granularity)
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
  SELECT ARRAY_AGG(DISTINCT descendant_id)
  INTO v_subordinate_ids
  FROM user_hierarchy
  WHERE ancestor_id = p_user_id;

  IF v_subordinate_ids IS NULL THEN
    v_subordinate_ids := ARRAY[p_user_id];
  ELSE
    v_subordinate_ids := v_subordinate_ids || p_user_id;
  END IF;

  SELECT COUNT(*) INTO v_lead_measures_count
  FROM measure_definitions WHERE measure_type = 'LEAD' AND is_active = TRUE;

  SELECT COUNT(*) INTO v_lag_measures_count
  FROM measure_definitions WHERE measure_type = 'LAG' AND is_active = TRUE;

  -- LEAD: join through scoring_periods to match period_type
  SELECT COALESCE(SUM(us.score), 0) INTO v_lead_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE AND sp.period_type = md.period_type
    AND md.measure_type = 'LEAD' AND md.is_active = TRUE;

  -- LAG: same pattern
  SELECT COALESCE(SUM(us.score), 0) INTO v_lag_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE AND sp.period_type = md.period_type
    AND md.measure_type = 'LAG' AND md.is_active = TRUE;

  IF v_lead_measures_count > 0 THEN
    v_lead_score := (v_lead_points / (v_lead_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;
  IF v_lag_measures_count > 0 THEN
    v_lag_score := (v_lag_points / (v_lag_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  v_total_score := (v_lead_score * 0.6) + (v_lag_score * 0.4);

  INSERT INTO user_score_aggregates (
    user_id, period_id, lead_score, lag_score, total_score,
    bonus_points, penalty_points, calculated_at, created_at
  ) VALUES (
    p_user_id, p_period_id, v_lead_score, v_lag_score, v_total_score,
    0, 0, NOW(), NOW()
  )
  ON CONFLICT (user_id, period_id) DO UPDATE SET
    lead_score = EXCLUDED.lead_score, lag_score = EXCLUDED.lag_score,
    total_score = EXCLUDED.total_score, calculated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 4. recalculate_all_scores: resolves display period as shortest current period
-- ============================================================================

CREATE OR REPLACE FUNCTION recalculate_all_scores()
RETURNS VOID AS $$
DECLARE
  v_user_id UUID;
  v_display_period_id UUID;
BEGIN
  SELECT id INTO v_display_period_id
  FROM scoring_periods
  WHERE is_current = TRUE
  ORDER BY CASE period_type
    WHEN 'WEEKLY' THEN 1 WHEN 'MONTHLY' THEN 2
    WHEN 'QUARTERLY' THEN 3 WHEN 'YEARLY' THEN 4 ELSE 5
  END
  LIMIT 1;

  IF v_display_period_id IS NULL THEN
    RAISE EXCEPTION 'No current scoring period found';
  END IF;

  FOR v_user_id IN SELECT id FROM users WHERE is_active = TRUE LOOP
    PERFORM update_all_measure_scores(v_user_id);
  END LOOP;

  FOR v_user_id IN SELECT id FROM users WHERE is_active = TRUE LOOP
    PERFORM recalculate_aggregate(v_user_id, v_display_period_id);
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
