-- ============================================
-- LeadX CRM - Sync pipeline_referrals with Drift schema
-- Adds missing columns that exist in local Drift database
-- ============================================

-- Add receiver_notes column (for receiver's notes when accepting)
ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS receiver_notes TEXT;

-- Add bm_notes column (for manager's notes when approving)
ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS bm_notes TEXT;

-- Add bonus tracking columns
ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS bonus_calculated BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS bonus_amount DECIMAL(18, 2);

-- Add expiration column
ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

-- Add cancellation tracking columns
ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

ALTER TABLE pipeline_referrals
ADD COLUMN IF NOT EXISTS cancel_reason TEXT;

-- Remove referrer_approved_at if it exists (not in Drift schema)
ALTER TABLE pipeline_referrals
DROP COLUMN IF EXISTS referrer_approved_at;

-- Add comments for documentation
COMMENT ON COLUMN pipeline_referrals.receiver_notes IS 'Notes from receiver when accepting the referral';
COMMENT ON COLUMN pipeline_referrals.bm_notes IS 'Notes from manager when approving/rejecting';
COMMENT ON COLUMN pipeline_referrals.bonus_calculated IS 'Whether referral bonus has been calculated';
COMMENT ON COLUMN pipeline_referrals.bonus_amount IS 'Calculated bonus amount for the referrer';
COMMENT ON COLUMN pipeline_referrals.expires_at IS 'When the referral expires if not acted upon';
COMMENT ON COLUMN pipeline_referrals.cancelled_at IS 'Timestamp when referral was cancelled';
COMMENT ON COLUMN pipeline_referrals.cancel_reason IS 'Reason provided for cancellation';
