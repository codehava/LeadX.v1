-- ============================================
-- Migration: Rename 'hvc' to 'hvcs'
-- Description: Standardize table name to plural
-- ============================================

BEGIN;

-- 1. DROP DEPENDENT OBJECTS
-- ============================================

-- Drop audit trigger (will be recreated)
DROP TRIGGER IF EXISTS hvc_audit_trigger ON hvc;

-- Drop RLS policies (will be recreated)
DROP POLICY IF EXISTS "hvc_select_authenticated" ON hvc;
DROP POLICY IF EXISTS "hvc_admin_all" ON hvc;
DROP POLICY IF EXISTS "customer_hvc_links_select" ON customer_hvc_links; -- References hvc

-- 2. RENAME TABLE
-- ============================================
ALTER TABLE hvc RENAME TO hvcs;

-- 3. RECREATE DEPENDENCIES
-- ============================================

-- Recreate RLS Policies on new table name
ALTER TABLE hvcs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "hvcs_select_authenticated" ON hvcs
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "hvcs_admin_all" ON hvcs
FOR ALL USING (is_admin());

-- Recreate Audit Trigger
CREATE TRIGGER hvc_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON hvcs
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- 4. UPDATE FOREIGN KEYS (Optional but good for clarity)
-- ============================================
-- Note: Postgres automatically updates FKs when table is renamed, 
-- but we might want to rename constraints if they used the old name.
-- Checking existing constraints...

-- (Postgres handles internal references automatically)

COMMIT;
