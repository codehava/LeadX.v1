-- ============================================
-- Migration: Enable RLS on regional_offices and branches
-- Priority: MEDIUM
-- Issue: These organizational tables had no RLS enabled
-- Fix: Add master data pattern (read-all authenticated, admin-write)
-- ============================================

-- Regional Offices
ALTER TABLE regional_offices ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view regional offices (master data)
CREATE POLICY "regional_offices_select" ON regional_offices
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can modify
CREATE POLICY "regional_offices_admin" ON regional_offices
FOR ALL USING (is_admin());

-- Branches
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view branches (master data)
CREATE POLICY "branches_select" ON branches
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can modify
CREATE POLICY "branches_admin" ON branches
FOR ALL USING (is_admin());

-- Add comments
COMMENT ON POLICY "regional_offices_select" ON regional_offices IS 'All authenticated users can view regional offices';
COMMENT ON POLICY "regional_offices_admin" ON regional_offices IS 'Only admins can modify regional offices';
COMMENT ON POLICY "branches_select" ON branches IS 'All authenticated users can view branches';
COMMENT ON POLICY "branches_admin" ON branches IS 'Only admins can modify branches';
