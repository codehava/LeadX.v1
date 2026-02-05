-- Add template support fields to measure_definitions table
-- Enables template-based measure creation wizard and "Edit Template" functionality

-- Add template fields (if not already present)
ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS template_type VARCHAR(50),
  ADD COLUMN IF NOT EXISTS template_config JSONB;

-- Create index for template type lookups
CREATE INDEX IF NOT EXISTS idx_measures_template_type
  ON measure_definitions(template_type);

-- Add comments for documentation
COMMENT ON COLUMN measure_definitions.template_type IS 'Template used to create this measure (activity_count, pipeline_count, pipeline_revenue, pipeline_conversion, stage_milestone, customer_acquisition, custom)';
COMMENT ON COLUMN measure_definitions.template_config IS 'Original template configuration (JSONB) - allows "Edit Template" to re-populate wizard with saved choices';

-- Update existing measures to have template info (if any exist without it)
-- This migration is idempotent and safe to run multiple times
DO $$
BEGIN
  -- Check if there are any measures without template_type
  IF EXISTS (SELECT 1 FROM measure_definitions WHERE template_type IS NULL LIMIT 1) THEN
    RAISE NOTICE 'Found measures without template_type - this is expected if seed migration ran before this migration';
    RAISE NOTICE 'Seed migration (20260205100000) will populate template fields for default measures';
  ELSE
    RAISE NOTICE 'All measures have template_type populated';
  END IF;
END $$;
