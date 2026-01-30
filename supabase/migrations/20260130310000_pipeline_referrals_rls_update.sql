-- ============================================
-- Migration: Update pipeline_referrals RLS policies
-- Date: 2026-01-30
--
-- Updates:
-- 1. SELECT policy - allow BH, BM, ROH to see all referrals for approval workflow
-- 2. INSERT policy - allow BH, BM, ROH roles to create referrals
-- 3. Approve policy - add BH to allowed approver roles
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "pipeline_referrals_involved" ON pipeline_referrals;
DROP POLICY IF EXISTS "pipeline_referrals_insert" ON pipeline_referrals;
DROP POLICY IF EXISTS "pipeline_referrals_approve" ON pipeline_referrals;

-- Recreate SELECT policy - supervisors can see all referrals for approval workflow
CREATE POLICY "pipeline_referrals_involved" ON pipeline_referrals
FOR SELECT USING (
  -- Referrer can see their outbound referrals
  referrer_rm_id = (SELECT auth.uid())
  -- Receiver can see their inbound referrals
  OR receiver_rm_id = (SELECT auth.uid())
  -- Approver can see referrals they approved
  OR bm_approved_by = (SELECT auth.uid())
  -- Supervisors (BH, BM, ROH) can see all referrals (for approval workflow)
  OR EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('BH', 'BM', 'ROH')
  )
  -- Admins have full access
  OR is_admin()
);

-- Recreate INSERT policy with BH, BM, ROH role fallback
CREATE POLICY "pipeline_referrals_insert" ON pipeline_referrals
FOR INSERT WITH CHECK (
  -- User is the referrer (owns the customer being referred)
  referrer_rm_id = (SELECT auth.uid())
  -- OR user is a supervisor of the referrer (via hierarchy)
  OR EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = referrer_rm_id
    AND depth > 0
  )
  -- OR user has a supervisory role (BH, BM, ROH) - fallback if hierarchy not populated
  OR EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('BH', 'BM', 'ROH')
  )
  -- OR user is admin
  OR is_admin()
);

-- Recreate approve policy with BH included
CREATE POLICY "pipeline_referrals_approve" ON pipeline_referrals
FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('BH', 'BM', 'ROH', 'ADMIN', 'SUPERADMIN')
  )
);
