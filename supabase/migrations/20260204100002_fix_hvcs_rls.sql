-- ============================================
-- Migration: Fix hvcs RLS policies
-- Priority: MEDIUM
-- Issue: hvcs_select_authenticated allowed ALL users to see ALL HVCs
-- Fix: Replace with scoped policies (own, hierarchy, customer-link)
-- ============================================

-- Remove the overly permissive policy
DROP POLICY IF EXISTS "hvcs_select_authenticated" ON hvcs;

-- Policy 1: Users can view HVCs they created
CREATE POLICY "hvcs_select_own" ON hvcs
FOR SELECT USING (created_by = (SELECT auth.uid()));

-- Policy 2: Users can view HVCs created by their subordinates
CREATE POLICY "hvcs_select_hierarchy" ON hvcs
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = hvcs.created_by
  )
);

-- Policy 3: Users can view HVCs linked to customers they own or supervise
-- This preserves the business requirement: if your customer is linked to an HVC, you can see that HVC
CREATE POLICY "hvcs_select_via_customer_link" ON hvcs
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM customer_hvc_links chl
    JOIN customers c ON c.id = chl.customer_id
    WHERE chl.hvc_id = hvcs.id
    AND chl.deleted_at IS NULL
    AND c.deleted_at IS NULL
    AND (
      c.assigned_rm_id = (SELECT auth.uid())
      OR EXISTS (
        SELECT 1 FROM user_hierarchy
        WHERE ancestor_id = (SELECT auth.uid())
        AND descendant_id = c.assigned_rm_id
      )
    )
  )
);

-- hvcs_admin_all policy already exists - no change needed

COMMENT ON POLICY "hvcs_select_own" ON hvcs IS 'Users can see HVCs they created';
COMMENT ON POLICY "hvcs_select_hierarchy" ON hvcs IS 'Users can see HVCs created by subordinates';
COMMENT ON POLICY "hvcs_select_via_customer_link" ON hvcs IS 'Users can see HVCs linked to their customers or subordinate customers';
