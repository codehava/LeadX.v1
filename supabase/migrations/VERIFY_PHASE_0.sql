-- Verification queries for Phase 0 (Score Calculation Infrastructure)
-- Run these queries after applying migrations 20260206000000, 20260206000001, 20260206000002, 20260206000003
-- And deploying the score-aggregation-cron Edge Function

-- ============================================================================
-- 1. Verify dirty_users table exists
-- ============================================================================
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'dirty_users'
ORDER BY ordinal_position;
-- Expected: 2 rows (user_id: uuid NOT NULL, dirtied_at: timestamptz NOT NULL)


-- ============================================================================
-- 2. Verify system_errors table exists with RLS
-- ============================================================================
SELECT
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'system_errors'
ORDER BY ordinal_position;
-- Expected: 6 rows (id, error_type, entity_id, error_message, created_at, resolved_at, resolved_by)

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('dirty_users', 'system_errors');
-- Expected: dirty_users = false (NO RLS), system_errors = true (RLS enabled)


-- ============================================================================
-- 3. Verify score calculation functions exist
-- ============================================================================
SELECT
  routine_name,
  routine_type,
  data_type as return_type
FROM information_schema.routines
WHERE routine_name IN (
  'calculate_measure_value',
  'update_user_score',
  'recalculate_aggregate',
  'mark_user_and_ancestors_dirty',
  'update_all_measure_scores',
  'recalculate_all_scores'
)
ORDER BY routine_name;
-- Expected: 6 functions (all FUNCTION type)


-- ============================================================================
-- 4. Verify triggers exist
-- ============================================================================
SELECT
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation
FROM information_schema.triggers
WHERE trigger_name IN (
  'trigger_activity_completed',
  'trigger_pipeline_won',
  'trigger_customer_created',
  'trigger_pipeline_stage_changed',
  'trigger_pipeline_closed'
)
ORDER BY trigger_name;
-- Expected: 5 triggers (all AFTER timing)


-- ============================================================================
-- 5. Verify indexes on dirty_users
-- ============================================================================
SELECT
  indexname,
  tablename,
  indexdef
FROM pg_indexes
WHERE tablename = 'dirty_users'
ORDER BY indexname;
-- Expected: 2 indexes (primary key + idx_dirty_users_dirtied_at)


-- ============================================================================
-- 6. Verify indexes on system_errors
-- ============================================================================
SELECT
  indexname,
  tablename,
  indexdef
FROM pg_indexes
WHERE tablename = 'system_errors'
ORDER BY indexname;
-- Expected: 4 indexes (primary key + 3 custom indexes)


-- ============================================================================
-- 7. Test calculate_measure_value function
-- ============================================================================
-- This tests if the function can be called (doesn't validate correctness yet)
DO $$
DECLARE
  v_user_id UUID;
  v_measure_id UUID;
  v_period_id UUID;
  v_result NUMERIC;
BEGIN
  -- Get a sample user, measure, and period
  SELECT id INTO v_user_id FROM users WHERE is_active = TRUE LIMIT 1;
  SELECT id INTO v_measure_id FROM measure_definitions WHERE is_active = TRUE LIMIT 1;
  SELECT id INTO v_period_id FROM scoring_periods WHERE is_current = TRUE LIMIT 1;

  IF v_user_id IS NOT NULL AND v_measure_id IS NOT NULL AND v_period_id IS NOT NULL THEN
    -- Test function call
    v_result := calculate_measure_value(v_user_id, v_measure_id, v_period_id);
    RAISE NOTICE 'calculate_measure_value test: % (user: %, measure: %, period: %)',
      v_result, v_user_id, v_measure_id, v_period_id;
  ELSE
    RAISE WARNING 'Cannot test calculate_measure_value: missing user, measure, or period';
  END IF;
END $$;
-- Expected: NOTICE with calculated value (or 0 if no data)


-- ============================================================================
-- 8. Test update_user_score function
-- ============================================================================
DO $$
DECLARE
  v_user_id UUID;
  v_measure_id UUID;
  v_period_id UUID;
BEGIN
  -- Get a sample user, measure, and period
  SELECT id INTO v_user_id FROM users WHERE is_active = TRUE LIMIT 1;
  SELECT id INTO v_measure_id FROM measure_definitions WHERE is_active = TRUE LIMIT 1;
  SELECT id INTO v_period_id FROM scoring_periods WHERE is_current = TRUE LIMIT 1;

  IF v_user_id IS NOT NULL AND v_measure_id IS NOT NULL AND v_period_id IS NOT NULL THEN
    -- Test function call
    PERFORM update_user_score(v_user_id, v_measure_id, v_period_id);
    RAISE NOTICE 'update_user_score test: SUCCESS (user: %, measure: %, period: %)',
      v_user_id, v_measure_id, v_period_id;

    -- Check if row was created in user_scores
    IF EXISTS (
      SELECT 1 FROM user_scores
      WHERE user_id = v_user_id
        AND measure_id = v_measure_id
        AND period_id = v_period_id
    ) THEN
      RAISE NOTICE '✓ user_scores row created successfully';
    ELSE
      RAISE WARNING '✗ user_scores row NOT created';
    END IF;
  ELSE
    RAISE WARNING 'Cannot test update_user_score: missing user, measure, or period';
  END IF;
END $$;
-- Expected: NOTICE with SUCCESS + confirmation that user_scores row exists


-- ============================================================================
-- 9. Test mark_user_and_ancestors_dirty function
-- ============================================================================
DO $$
DECLARE
  v_user_id UUID;
  v_dirty_count INTEGER;
BEGIN
  -- Get a sample user
  SELECT id INTO v_user_id FROM users WHERE is_active = TRUE LIMIT 1;

  IF v_user_id IS NOT NULL THEN
    -- Test function call
    PERFORM mark_user_and_ancestors_dirty(v_user_id);

    -- Count dirty users created
    SELECT COUNT(*) INTO v_dirty_count FROM dirty_users;

    RAISE NOTICE 'mark_user_and_ancestors_dirty test: % dirty users (user: %)',
      v_dirty_count, v_user_id;

    -- Clean up test data
    DELETE FROM dirty_users WHERE user_id = v_user_id;
  ELSE
    RAISE WARNING 'Cannot test mark_user_and_ancestors_dirty: no active users';
  END IF;
END $$;
-- Expected: NOTICE with count of dirty users (1+ depending on hierarchy)


-- ============================================================================
-- 10. Test recalculate_aggregate function
-- ============================================================================
DO $$
DECLARE
  v_user_id UUID;
  v_period_id UUID;
  v_lead_score NUMERIC;
  v_lag_score NUMERIC;
  v_total_score NUMERIC;
BEGIN
  -- Get a sample user and period
  SELECT id INTO v_user_id FROM users WHERE is_active = TRUE LIMIT 1;
  SELECT id INTO v_period_id FROM scoring_periods WHERE is_current = TRUE LIMIT 1;

  IF v_user_id IS NOT NULL AND v_period_id IS NOT NULL THEN
    -- Test function call
    PERFORM recalculate_aggregate(v_user_id, v_period_id);
    RAISE NOTICE 'recalculate_aggregate test: SUCCESS (user: %, period: %)',
      v_user_id, v_period_id;

    -- Check if row was created in user_score_aggregates
    IF EXISTS (
      SELECT 1 FROM user_score_aggregates
      WHERE user_id = v_user_id AND period_id = v_period_id
    ) THEN
      RAISE NOTICE '✓ user_score_aggregates row created successfully';

      -- Show the aggregate values
      SELECT lead_score, lag_score, total_score
      INTO v_lead_score, v_lag_score, v_total_score
      FROM user_score_aggregates
      WHERE user_id = v_user_id AND period_id = v_period_id;

      RAISE NOTICE '  Lead score: %, Lag score: %, Total score: %',
        v_lead_score, v_lag_score, v_total_score;
    ELSE
      RAISE WARNING '✗ user_score_aggregates row NOT created';
    END IF;
  ELSE
    RAISE WARNING 'Cannot test recalculate_aggregate: missing user or period';
  END IF;
END $$;
-- Expected: NOTICE with SUCCESS + aggregate values


-- ============================================================================
-- 11. Verify RLS policies on system_errors
-- ============================================================================
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'system_errors'
ORDER BY policyname;
-- Expected: 3 policies (SELECT, UPDATE, DELETE - all for admins only)


-- ============================================================================
-- 12. Check for any errors in system_errors table
-- ============================================================================
SELECT
  error_type,
  COUNT(*) as count,
  MAX(created_at) as latest_error
FROM system_errors
WHERE resolved_at IS NULL
GROUP BY error_type
ORDER BY latest_error DESC;
-- Expected: 0 rows (no unresolved errors yet)
-- If there are errors, investigate immediately


-- ============================================================================
-- SUCCESS CRITERIA
-- ============================================================================
-- ✅ All 12 verification queries should return expected results
-- ✅ No errors during migration execution
-- ✅ dirty_users and system_errors tables exist
-- ✅ 6 score calculation functions exist
-- ✅ 5 triggers exist on activities, pipelines, customers, pipeline_stage_history
-- ✅ All test function calls succeed
-- ✅ RLS policies protect system_errors (admins only)
-- ✅ No unresolved errors in system_errors table

-- ============================================================================
-- NEXT STEPS
-- ============================================================================
-- After verifying Phase 0:
-- 1. Deploy score-aggregation-cron Edge Function:
--    supabase functions deploy score-aggregation-cron
--
-- 2. Schedule the Edge Function (via Supabase dashboard or CLI):
--    - Navigate to Database > Functions > score-aggregation-cron
--    - Set up a scheduled trigger: Every 10 minutes
--    - OR use pg_cron (see alternative below)
--
-- 3. Test the cron job manually:
--    curl -X POST https://<project-ref>.supabase.co/functions/v1/score-aggregation-cron \
--      -H "Authorization: Bearer <anon-key>"
--
-- 4. Monitor system_errors table for any issues
--
-- 5. Proceed to Phase 1: Admin UI (measure/period management)

-- ============================================================================
-- ALTERNATIVE: pg_cron Setup (if preferred over Edge Function)
-- ============================================================================
-- If you prefer pg_cron instead of Edge Function, run this:

SELECT cron.schedule(
  'score-aggregation-cron',
  '*/10 * * * *',  -- Every 10 minutes
  $$
  DECLARE
    v_user_id UUID;
    v_period_id UUID;
  BEGIN
    SELECT id INTO v_period_id FROM scoring_periods WHERE is_current = TRUE;

    FOR v_user_id IN SELECT user_id FROM dirty_users ORDER BY dirtied_at LOOP
      BEGIN
        PERFORM recalculate_aggregate(v_user_id, v_period_id);
        DELETE FROM dirty_users WHERE user_id = v_user_id;
      EXCEPTION WHEN OTHERS THEN
        INSERT INTO system_errors (error_type, entity_id, error_message)
        VALUES ('CRON_USER_FAILED', v_user_id, SQLERRM);
      END;
    END LOOP;
  END;
  $$
);
