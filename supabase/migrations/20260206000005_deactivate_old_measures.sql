-- Deactivate old measures that were created before Phase -1
-- These measures use incorrect column names (e.g., 'type' instead of 'activity_type_id')
-- Our new measures (LEAD-001 through LAG-004) use correct schema

-- Deactivate measures without template_type (old measures)
UPDATE measure_definitions
SET is_active = FALSE
WHERE template_type IS NULL;

-- Show what was deactivated
DO $$
DECLARE
  v_deactivated_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_deactivated_count
  FROM measure_definitions
  WHERE is_active = FALSE AND template_type IS NULL;

  RAISE NOTICE 'Deactivated % old measures (without template_type)', v_deactivated_count;
  RAISE NOTICE 'Active measures remain: LEAD-001 through LEAD-006, LAG-001 through LAG-004';
END $$;
