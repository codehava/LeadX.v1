-- ============================================
-- LeadX CRM - Pipeline Referral Approval Trigger
-- Handles full customer handoff when referral is approved
-- ============================================

-- Main trigger function for referral approval
CREATE OR REPLACE FUNCTION handle_referral_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Only act when status changes to BM_APPROVED
  IF NEW.status = 'BM_APPROVED' AND OLD.status != 'BM_APPROVED' THEN

    -- 1. Reassign customer to receiver RM
    UPDATE customers
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      updated_at = NOW()
    WHERE id = NEW.customer_id;

    -- 2. Reassign OPEN pipelines for this customer to receiver
    --    AND set referred_by_user_id for 4DX tracking (referral bonus if pipeline wins)
    UPDATE pipelines
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      referred_by_user_id = NEW.referrer_rm_id,
      referral_id = NEW.id,
      updated_at = NOW()
    WHERE customer_id = NEW.customer_id
      AND deleted_at IS NULL
      AND closed_at IS NULL;  -- Only open pipelines

    -- 3. Reassign CLOSED pipelines for visibility (new RM can see customer history)
    --    Note: scored_to_user_id is already set and won't change - original owner keeps scoring credit
    UPDATE pipelines
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      updated_at = NOW()
    WHERE customer_id = NEW.customer_id
      AND deleted_at IS NULL
      AND closed_at IS NOT NULL;  -- Only closed pipelines

    -- 4. Mark referral as COMPLETED
    NEW.status := 'COMPLETED';
    NEW.updated_at := NOW();

    RAISE NOTICE 'Referral % approved: Customer % reassigned to RM %, pipelines transferred with referrer credit',
      NEW.code, NEW.customer_id, NEW.receiver_rm_id;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS on_referral_approved ON pipeline_referrals;
CREATE TRIGGER on_referral_approved
  BEFORE UPDATE ON pipeline_referrals
  FOR EACH ROW
  EXECUTE FUNCTION handle_referral_approval();

-- Add comment for documentation
COMMENT ON FUNCTION handle_referral_approval() IS
'Handles pipeline referral approval by:
1. Reassigning customer to receiver RM
2. Reassigning OPEN pipelines to receiver with referred_by_user_id set for 4DX tracking
3. Reassigning CLOSED pipelines to receiver for visibility (customer history)
4. Marking the referral as COMPLETED

IMPORTANT: scored_to_user_id on closed pipelines is NOT changed - original owner keeps scoring credit.
Only assigned_rm_id changes so the new RM can view the customer pipeline history.';
