-- ============================================
-- Migration: Enable user_hierarchy RLS
-- Priority: HIGH
-- Issue: Table had no RLS - exposed full org chart to all authenticated users
-- Fix: Enable RLS with self-access and admin policies
-- ============================================

-- Enable RLS on user_hierarchy table
ALTER TABLE user_hierarchy ENABLE ROW LEVEL SECURITY;

-- Users can see relationships where they are the ancestor or descendant
-- This allows:
--   - Seeing own self-reference (depth=0)
--   - Seeing who they supervise (as ancestor)
--   - Seeing who supervises them (as descendant)
CREATE POLICY "user_hierarchy_select_own" ON user_hierarchy
FOR SELECT USING (
  ancestor_id = (SELECT auth.uid())
  OR descendant_id = (SELECT auth.uid())
);

-- Admins have full access for management purposes
CREATE POLICY "user_hierarchy_admin_all" ON user_hierarchy
FOR ALL USING (is_admin());

-- No INSERT/UPDATE/DELETE policies for non-admins
-- Hierarchy is managed by triggers on users.parent_id changes

COMMENT ON TABLE user_hierarchy IS 'Closure table for user supervisor relationships. RLS restricts to own relationships + admin access.';
