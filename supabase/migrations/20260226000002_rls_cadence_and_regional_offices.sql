-- ============================================
-- RLS fixes for cadence tables and regional_offices/branches
-- 2026-02-26
-- ============================================

-- ============================================
-- 1. cadence_meetings: Add missing UPDATE and admin policies
-- ============================================

-- Facilitator or creator can update their meetings
CREATE POLICY "cadence_meetings_update" ON cadence_meetings
FOR UPDATE USING (
  facilitator_id = (SELECT auth.uid())
  OR created_by = (SELECT auth.uid())
);

-- Admin full access
CREATE POLICY "cadence_meetings_admin" ON cadence_meetings
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);

-- ============================================
-- 2. cadence_participants: Add missing admin policy
-- ============================================

CREATE POLICY "cadence_participants_admin" ON cadence_participants
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);

-- ============================================
-- 3. regional_offices: Enable RLS + master data policies
-- ============================================

ALTER TABLE regional_offices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "regional_offices_select" ON regional_offices
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "regional_offices_admin" ON regional_offices
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);

-- ============================================
-- 4. branches: Enable RLS + master data policies
-- ============================================

ALTER TABLE branches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "branches_select" ON branches
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "branches_admin" ON branches
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);
