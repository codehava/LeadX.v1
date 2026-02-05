-- Verification queries for Phase -1 (System Bootstrap)
-- Run these queries after applying migrations 20260205100000, 20260205100001, 20260205100002

-- ============================================================================
-- 1. Verify template fields were added to measure_definitions
-- ============================================================================
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'measure_definitions'
  AND column_name IN ('template_type', 'template_config')
ORDER BY column_name;
-- Expected: 2 rows (template_config: jsonb, template_type: character varying)


-- ============================================================================
-- 2. Verify 10 default measures were seeded
-- ============================================================================
SELECT COUNT(*) as total_measures
FROM measure_definitions
WHERE is_active = TRUE;
-- Expected: 10


-- ============================================================================
-- 3. Verify correct distribution of LEAD vs LAG measures
-- ============================================================================
SELECT
  measure_type,
  COUNT(*) as count,
  ROUND(SUM(weight), 1) as total_weight
FROM measure_definitions
WHERE is_active = TRUE
GROUP BY measure_type
ORDER BY measure_type;
-- Expected:
--   LAG  | 4 | (varies by weight)
--   LEAD | 6 | (varies by weight)


-- ============================================================================
-- 4. Verify all measures have template info populated
-- ============================================================================
SELECT
  code,
  name,
  template_type,
  template_config IS NOT NULL as has_config
FROM measure_definitions
WHERE is_active = TRUE
ORDER BY code;
-- Expected: 10 rows, all with template_type and has_config = true


-- ============================================================================
-- 5. Verify initial scoring period was created
-- ============================================================================
SELECT
  name,
  period_type,
  start_date,
  end_date,
  is_current,
  is_locked
FROM scoring_periods
WHERE is_current = TRUE;
-- Expected: 1 row
--   'Week 6, Feb 2026' | WEEKLY | 2026-02-09 | 2026-02-15 | true | false


-- ============================================================================
-- 6. Verify period count
-- ============================================================================
SELECT COUNT(*) as total_periods
FROM scoring_periods;
-- Expected: 1 (only the initial period)


-- ============================================================================
-- 7. Detailed measure verification (shows all measure details)
-- ============================================================================
SELECT
  code,
  name,
  measure_type,
  source_table,
  data_type,
  default_target,
  weight,
  period_type,
  template_type,
  is_active
FROM measure_definitions
WHERE is_active = TRUE
ORDER BY
  CASE WHEN measure_type = 'LEAD' THEN 1 ELSE 2 END,
  code;
-- Expected: 10 rows showing all measure details


-- ============================================================================
-- 8. Verify activity type UUIDs were correctly used in source_condition
-- ============================================================================
SELECT
  md.code,
  md.name,
  md.source_condition,
  CASE
    WHEN md.source_condition LIKE '%activity_type_id%' THEN 'Uses UUID'
    ELSE 'No UUID'
  END as uuid_usage
FROM measure_definitions md
WHERE md.code IN ('LEAD-001', 'LEAD-002', 'LEAD-003')
ORDER BY md.code;
-- Expected: All 3 should show "Uses UUID" and have valid UUID in source_condition


-- ============================================================================
-- 9. Check index was created
-- ============================================================================
SELECT
  indexname,
  tablename,
  indexdef
FROM pg_indexes
WHERE tablename = 'measure_definitions'
  AND indexname = 'idx_measures_template_type';
-- Expected: 1 row showing the index definition


-- ============================================================================
-- SUCCESS CRITERIA
-- ============================================================================
-- ✅ All 9 verification queries should return expected results
-- ✅ No errors during migration execution
-- ✅ template_type and template_config columns exist
-- ✅ 10 measures seeded (6 LEAD + 4 LAG)
-- ✅ 1 current period (Week 6, Feb 2026)
-- ✅ Activity-based measures use UUIDs from activity_types table
-- ✅ Index idx_measures_template_type exists

-- ============================================================================
-- NEXT STEPS
-- ============================================================================
-- After verifying Phase -1:
-- 1. Proceed to Phase 0: Score Calculation Infrastructure
-- 2. Create dirty_users table
-- 3. Implement score calculation functions
-- 4. Set up triggers and cron jobs
