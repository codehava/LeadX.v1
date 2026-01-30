-- ============================================
-- Migration: Update pipeline_referrals INSERT RLS policy
-- Date: 2026-01-30
-- Description: Allow supervisors and admins to create referrals
--              on behalf of subordinates
-- ============================================

-- Drop the existing restrictive INSERT policy
DROP POLICY IF EXISTS "pipeline_referrals_insert" ON pipeline_referrals;

-- Create new INSERT policy that allows:
-- 1. Users creating referrals for their own customers (referrer_rm_id = auth.uid())
-- 2. Supervisors creating referrals for customers owned by subordinates
-- 3. Admins can create any referral
CREATE POLICY "pipeline_referrals_insert" ON pipeline_referrals
FOR INSERT WITH CHECK (
  -- User is the referrer (owns the customer being referred)
  referrer_rm_id = (SELECT auth.uid())
  -- OR user is a supervisor of the referrer
  OR EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = referrer_rm_id
    AND depth > 0
  )
  -- OR user is admin
  OR is_admin()
);

-- Also add admin full access policy for completeness (covers all operations)
DROP POLICY IF EXISTS "pipeline_referrals_admin_all" ON pipeline_referrals;

CREATE POLICY "pipeline_referrals_admin_all" ON pipeline_referrals
FOR ALL USING (is_admin());
