-- ============================================
-- Migration: Update pipeline_referrals schema to v2
-- Date: 2026-01-30
--
-- This migration updates the pipeline_referrals table from the old design
-- (with cob_id, lob_id, potential_premium) to the new design where:
-- - Entire customer is transferred (not specific COB/LOB)
-- - Receiver decides products after accepting
-- - Regional office IDs added for ROH fallback approval
-- - Approver type (any role besides RM: BH, BM, ROH, ADMIN, SUPERADMIN)
--
-- New Schema Reference (docs/04-database/sql/02_business_data.sql):
-- - customer_id: NOT NULL
-- - referrer_rm_id, receiver_rm_id: NOT NULL
-- - referrer_branch_id, receiver_branch_id: NULLABLE (kanwil-level RMs)
-- - referrer_regional_office_id, receiver_regional_office_id: NULLABLE
-- - approver_type: 'BH', 'BM', 'ROH', 'ADMIN', or 'SUPERADMIN'
-- - No cob_id, lob_id, potential_premium
-- ============================================

BEGIN;

-- ============================================
-- STEP 1: Make old required columns nullable
-- ============================================
DO $$
BEGIN
  -- cob_id
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'pipeline_referrals' AND column_name = 'cob_id') THEN
    ALTER TABLE pipeline_referrals ALTER COLUMN cob_id DROP NOT NULL;
    RAISE NOTICE 'Made cob_id nullable';
  END IF;

  -- lob_id
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'pipeline_referrals' AND column_name = 'lob_id') THEN
    ALTER TABLE pipeline_referrals ALTER COLUMN lob_id DROP NOT NULL;
    RAISE NOTICE 'Made lob_id nullable';
  END IF;

  -- potential_premium
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'pipeline_referrals' AND column_name = 'potential_premium') THEN
    ALTER TABLE pipeline_referrals ALTER COLUMN potential_premium DROP NOT NULL;
    RAISE NOTICE 'Made potential_premium nullable';
  END IF;

  -- referrer_branch_id (make nullable for kanwil-level RMs)
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'pipeline_referrals' AND column_name = 'referrer_branch_id'
             AND is_nullable = 'NO') THEN
    ALTER TABLE pipeline_referrals ALTER COLUMN referrer_branch_id DROP NOT NULL;
    RAISE NOTICE 'Made referrer_branch_id nullable';
  END IF;

  -- receiver_branch_id (make nullable for kanwil-level RMs)
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'pipeline_referrals' AND column_name = 'receiver_branch_id'
             AND is_nullable = 'NO') THEN
    ALTER TABLE pipeline_referrals ALTER COLUMN receiver_branch_id DROP NOT NULL;
    RAISE NOTICE 'Made receiver_branch_id nullable';
  END IF;
END $$;

-- ============================================
-- STEP 2: Add new columns
-- ============================================

-- Regional office IDs
ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS referrer_regional_office_id UUID REFERENCES regional_offices(id);

ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS receiver_regional_office_id UUID REFERENCES regional_offices(id);

-- Approver type (any role besides RM: BH, BM, ROH, ADMIN, SUPERADMIN)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'pipeline_referrals'
                 AND column_name = 'approver_type') THEN
    ALTER TABLE pipeline_referrals
      ADD COLUMN approver_type VARCHAR(10) NOT NULL DEFAULT 'BM';

    ALTER TABLE pipeline_referrals
      ADD CONSTRAINT chk_approver_type CHECK (approver_type IN ('BH', 'BM', 'ROH', 'ADMIN', 'SUPERADMIN'));
    RAISE NOTICE 'Added approver_type column';
  ELSE
    -- Update existing constraint to allow expanded approver types
    ALTER TABLE pipeline_referrals
      DROP CONSTRAINT IF EXISTS chk_approver_type;
    ALTER TABLE pipeline_referrals
      ADD CONSTRAINT chk_approver_type CHECK (approver_type IN ('BH', 'BM', 'ROH', 'ADMIN', 'SUPERADMIN'));
    RAISE NOTICE 'Updated approver_type constraint';
  END IF;
END $$;

-- Receiver notes
ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS receiver_notes TEXT;

-- BM/Manager notes
ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS bm_notes TEXT;

-- Bonus tracking
ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS bonus_calculated BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS bonus_amount DECIMAL(18, 2);

-- Expiration and cancellation
ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS cancel_reason TEXT;

-- Offline sync support
ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS is_pending_sync BOOLEAN DEFAULT false;

ALTER TABLE pipeline_referrals
  ADD COLUMN IF NOT EXISTS last_sync_at TIMESTAMPTZ;

-- ============================================
-- STEP 3: Drop obsolete columns (optional)
-- ============================================
-- Uncomment to fully remove old columns:

ALTER TABLE pipeline_referrals DROP COLUMN IF EXISTS cob_id;
ALTER TABLE pipeline_referrals DROP COLUMN IF EXISTS lob_id;
ALTER TABLE pipeline_referrals DROP COLUMN IF EXISTS potential_premium;
ALTER TABLE pipeline_referrals DROP COLUMN IF EXISTS pipeline_id;

-- ============================================
-- STEP 4: Create indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_pipeline_referrals_referrer ON pipeline_referrals(referrer_rm_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_referrals_receiver ON pipeline_referrals(receiver_rm_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_referrals_status ON pipeline_referrals(status);
CREATE INDEX IF NOT EXISTS idx_pipeline_referrals_approver ON pipeline_referrals(bm_approved_by);
CREATE INDEX IF NOT EXISTS idx_pipeline_referrals_updated_at ON pipeline_referrals(updated_at);
CREATE INDEX IF NOT EXISTS idx_pipeline_referrals_customer ON pipeline_referrals(customer_id);

COMMIT;

-- ============================================
-- VERIFICATION
-- ============================================
-- Run this query to verify the schema:
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'pipeline_referrals'
ORDER BY ordinal_position;
