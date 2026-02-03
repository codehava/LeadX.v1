-- ============================================
-- LeadX CRM - Add scored_to_user_id for Pipeline Scoring Attribution
-- ============================================
-- This migration adds a dedicated field for 4DX scoring credit that:
-- - Gets set when a pipeline reaches the "WON" stage
-- - Never changes after being set, regardless of assignedRmId changes
-- - Separates operational ownership from scoring attribution
-- ============================================

-- 1. Add scored_to_user_id column
ALTER TABLE pipelines ADD COLUMN IF NOT EXISTS scored_to_user_id UUID REFERENCES users(id);

-- 2. Create index for scoring queries
CREATE INDEX IF NOT EXISTS idx_pipelines_scored_to_user ON pipelines(scored_to_user_id);

-- 3. Backfill: Set scored_to_user_id for already-won pipelines
-- Uses assigned_rm_id as the scored user for historical data
UPDATE pipelines p
SET scored_to_user_id = p.assigned_rm_id
WHERE p.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
  AND p.scored_to_user_id IS NULL;

-- 4. Create trigger function to set scored_to_user_id when pipeline is won (UPDATE)
CREATE OR REPLACE FUNCTION handle_pipeline_won()
RETURNS TRIGGER AS $$
BEGIN
  -- Only act when transitioning TO a won stage
  -- Check: new stage is a won stage, old stage was not a won stage (or NULL), and scored_to_user_id not already set
  IF NEW.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
     AND (OLD.stage_id IS NULL OR OLD.stage_id NOT IN (SELECT id FROM pipeline_stages WHERE is_won = true))
     AND NEW.scored_to_user_id IS NULL
  THEN
    NEW.scored_to_user_id := NEW.assigned_rm_id;
    NEW.updated_at := NOW();

    RAISE NOTICE 'Pipeline % won: scored_to_user_id set to %', NEW.id, NEW.scored_to_user_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Create the UPDATE trigger
DROP TRIGGER IF EXISTS on_pipeline_won ON pipelines;
CREATE TRIGGER on_pipeline_won
  BEFORE UPDATE ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION handle_pipeline_won();

-- 6. Create trigger function for INSERT (pipelines created directly in won stage)
CREATE OR REPLACE FUNCTION handle_pipeline_won_insert()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
     AND NEW.scored_to_user_id IS NULL
  THEN
    NEW.scored_to_user_id := NEW.assigned_rm_id;

    RAISE NOTICE 'Pipeline % created as won: scored_to_user_id set to %', NEW.id, NEW.scored_to_user_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Create the INSERT trigger
DROP TRIGGER IF EXISTS on_pipeline_won_insert ON pipelines;
CREATE TRIGGER on_pipeline_won_insert
  BEFORE INSERT ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION handle_pipeline_won_insert();

-- 8. Add column comment for documentation
COMMENT ON COLUMN pipelines.scored_to_user_id IS
'The user who receives 4DX lag measure credit for this pipeline.
Set automatically when pipeline reaches WON stage (via trigger).
Never changes after being set, even if assigned_rm_id changes.
This separates operational ownership (assigned_rm_id) from scoring attribution (scored_to_user_id).';

-- 9. Update measure_definitions to use scored_to_user_id for lag measures
-- Only update if the source_condition references assigned_rm_id for lag measures
UPDATE measure_definitions
SET source_condition = REPLACE(source_condition, 'assigned_rm_id', 'scored_to_user_id')
WHERE measure_type = 'LAG'
  AND source_condition LIKE '%assigned_rm_id%';
