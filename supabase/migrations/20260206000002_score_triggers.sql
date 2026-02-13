-- Score Calculation Triggers for 4DX System
-- Auto-updates user scores when business data changes
-- Marks users and ancestors dirty for hierarchical recalculation

-- ============================================================================
-- Trigger 1: Activity Completion
-- ============================================================================
-- Fires when activity status changes to COMPLETED
-- Updates LEAD measures that track activity counts

CREATE OR REPLACE FUNCTION on_activity_completed()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process if status changed to COMPLETED
  IF NEW.status = 'COMPLETED' AND (OLD IS NULL OR OLD.status != 'COMPLETED') THEN
    -- Update all measure scores for the user who completed the activity
    PERFORM update_all_measure_scores(NEW.user_id);

    -- Mark user and ancestors dirty for aggregate recalculation
    PERFORM mark_user_and_ancestors_dirty(NEW.user_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_activity_completed ON activities;

-- Create trigger
CREATE TRIGGER trigger_activity_completed
  AFTER INSERT OR UPDATE OF status ON activities
  FOR EACH ROW
  EXECUTE FUNCTION on_activity_completed();

COMMENT ON FUNCTION on_activity_completed IS 'Triggered when activity status changes to COMPLETED. Updates LEAD measure scores and marks hierarchy dirty.';


-- ============================================================================
-- Trigger 2: Pipeline Won (Enhance Existing)
-- ============================================================================
-- Fires when pipeline stage changes to a "won" stage (is_won = true)
-- Updates LAG measures that track won deals

CREATE OR REPLACE FUNCTION on_pipeline_won()
RETURNS TRIGGER AS $$
DECLARE
  v_is_won BOOLEAN;
  v_was_won BOOLEAN := FALSE;
BEGIN
  -- Check if NEW stage is a won stage
  SELECT is_won INTO v_is_won
  FROM pipeline_stages
  WHERE id = NEW.stage_id;

  -- Check if OLD stage was a won stage (for UPDATE operations)
  IF OLD IS NOT NULL AND OLD.stage_id IS NOT NULL THEN
    SELECT is_won INTO v_was_won
    FROM pipeline_stages
    WHERE id = OLD.stage_id;
  END IF;

  -- Only process if stage changed to won (and wasn't won before)
  IF v_is_won = TRUE AND v_was_won = FALSE THEN
    -- Update all measure scores for the user who is credited with the win
    -- Use scored_to_user_id (the user who gets credit for this pipeline)
    IF NEW.scored_to_user_id IS NOT NULL THEN
      PERFORM update_all_measure_scores(NEW.scored_to_user_id);
      PERFORM mark_user_and_ancestors_dirty(NEW.scored_to_user_id);
    END IF;

    -- Also update for referring user if this is a referral
    IF NEW.referred_by_user_id IS NOT NULL THEN
      PERFORM update_all_measure_scores(NEW.referred_by_user_id);
      PERFORM mark_user_and_ancestors_dirty(NEW.referred_by_user_id);
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_pipeline_won ON pipelines;

-- Create trigger
CREATE TRIGGER trigger_pipeline_won
  AFTER INSERT OR UPDATE OF stage_id ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION on_pipeline_won();

COMMENT ON FUNCTION on_pipeline_won IS 'Triggered when pipeline stage changes to a won stage (is_won = true). Updates LAG measure scores (PIPELINE_WON, PREMIUM_WON, REFERRAL_PREMIUM) and marks hierarchy dirty.';


-- ============================================================================
-- Trigger 3: Customer Created
-- ============================================================================
-- Fires when new customer is created
-- Updates LEAD measure NEW_CUSTOMER

CREATE OR REPLACE FUNCTION on_customer_created()
RETURNS TRIGGER AS $$
BEGIN
  -- Update all measure scores for the user who created the customer
  IF NEW.created_by IS NOT NULL THEN
    PERFORM update_all_measure_scores(NEW.created_by);
    PERFORM mark_user_and_ancestors_dirty(NEW.created_by);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_customer_created ON customers;

-- Create trigger
CREATE TRIGGER trigger_customer_created
  AFTER INSERT ON customers
  FOR EACH ROW
  EXECUTE FUNCTION on_customer_created();

COMMENT ON FUNCTION on_customer_created IS 'Triggered when new customer is created. Updates NEW_CUSTOMER LEAD measure and marks hierarchy dirty.';


-- ============================================================================
-- Trigger 4: Pipeline Stage Changed
-- ============================================================================
-- Fires when pipeline_stage_history record is inserted
-- Updates LEAD measures that track stage milestones (e.g., PROPOSAL_SENT)

CREATE OR REPLACE FUNCTION on_pipeline_stage_changed()
RETURNS TRIGGER AS $$
BEGIN
  -- Update all measure scores for the user who changed the stage
  IF NEW.changed_by IS NOT NULL THEN
    PERFORM update_all_measure_scores(NEW.changed_by);
    PERFORM mark_user_and_ancestors_dirty(NEW.changed_by);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_pipeline_stage_changed ON pipeline_stage_history;

-- Create trigger
CREATE TRIGGER trigger_pipeline_stage_changed
  AFTER INSERT ON pipeline_stage_history
  FOR EACH ROW
  EXECUTE FUNCTION on_pipeline_stage_changed();

COMMENT ON FUNCTION on_pipeline_stage_changed IS 'Triggered when pipeline stage changes. Updates LEAD measures tracking milestones (e.g., PROPOSAL_SENT at P2) and marks hierarchy dirty.';


-- ============================================================================
-- Trigger 5: Pipeline Closed (for Conversion Rate)
-- ============================================================================
-- Fires when pipeline closed_at is set
-- Updates LAG measure CONVERSION_RATE

CREATE OR REPLACE FUNCTION on_pipeline_closed()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process if closed_at was just set
  IF NEW.closed_at IS NOT NULL AND (OLD IS NULL OR OLD.closed_at IS NULL) THEN
    -- Update all measure scores for the user credited with this pipeline
    IF NEW.scored_to_user_id IS NOT NULL THEN
      PERFORM update_all_measure_scores(NEW.scored_to_user_id);
      PERFORM mark_user_and_ancestors_dirty(NEW.scored_to_user_id);
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_pipeline_closed ON pipelines;

-- Create trigger
CREATE TRIGGER trigger_pipeline_closed
  AFTER INSERT OR UPDATE OF closed_at ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION on_pipeline_closed();

COMMENT ON FUNCTION on_pipeline_closed IS 'Triggered when pipeline closed_at is set. Updates CONVERSION_RATE LAG measure and marks hierarchy dirty.';


-- ============================================================================
-- Manual Recalculation Helper
-- ============================================================================
-- For admin/debugging: Manually recalculate all scores for all users

CREATE OR REPLACE FUNCTION recalculate_all_scores()
RETURNS VOID AS $$
DECLARE
  v_user_id UUID;
  v_period_id UUID;
BEGIN
  -- Get current period
  SELECT id INTO v_period_id
  FROM scoring_periods
  WHERE is_current = TRUE
  LIMIT 1;

  IF v_period_id IS NULL THEN
    RAISE EXCEPTION 'No current scoring period found';
  END IF;

  -- Recalculate individual measures for all active users
  FOR v_user_id IN
    SELECT id FROM users WHERE is_active = TRUE
  LOOP
    PERFORM update_all_measure_scores(v_user_id);
  END LOOP;

  -- Recalculate aggregates for all active users
  FOR v_user_id IN
    SELECT id FROM users WHERE is_active = TRUE
  LOOP
    PERFORM recalculate_aggregate(v_user_id, v_period_id);
  END LOOP;

  RAISE NOTICE 'Recalculated all scores for period %', v_period_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION recalculate_all_scores IS 'ADMIN ONLY: Manually recalculates all user scores and aggregates for the current period. Use for debugging or after data corrections.';
