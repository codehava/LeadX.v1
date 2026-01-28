-- ============================================
-- LeadX CRM - Schema Part 6: Audit Triggers
-- Run this AFTER all other SQL migrations
-- ============================================

-- ============================================
-- 1. AUDIT LOGS TABLE (if not exists)
-- ============================================

-- Note: audit_logs table should already exist from previous migrations
-- This ensures the structure is correct

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  user_email VARCHAR(255),
  action VARCHAR(50) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
  target_table VARCHAR(100) NOT NULL,
  target_id UUID NOT NULL,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_target ON audit_logs(target_table, target_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);

-- ============================================
-- 2. PIPELINE STAGE HISTORY TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS pipeline_stage_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pipeline_id UUID REFERENCES pipelines(id) ON DELETE CASCADE NOT NULL,
  from_stage_id UUID REFERENCES pipeline_stages(id),
  to_stage_id UUID REFERENCES pipeline_stages(id) NOT NULL,
  from_status_id UUID REFERENCES pipeline_statuses(id),
  to_status_id UUID REFERENCES pipeline_statuses(id),
  notes TEXT,
  changed_by UUID REFERENCES users(id),
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  -- GPS data (optional, can be captured when stage is changed via mobile)
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8)
);

CREATE INDEX IF NOT EXISTS idx_pipeline_stage_history_pipeline ON pipeline_stage_history(pipeline_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_stage_history_changed_at ON pipeline_stage_history(changed_at DESC);

-- ============================================
-- 3. GENERIC AUDIT TRIGGER FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION log_entity_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT;
  v_action TEXT;
  v_old_values JSONB;
  v_new_values JSONB;
BEGIN
  -- Get current user from Supabase auth
  v_user_id := auth.uid();
  
  -- Get user email
  SELECT email INTO v_user_email 
  FROM users 
  WHERE id = v_user_id;
  
  -- Determine action type
  v_action := TG_OP;
  
  -- Build old/new values based on operation
  IF TG_OP = 'DELETE' THEN
    v_old_values := to_jsonb(OLD);
    v_new_values := NULL;
    
    INSERT INTO audit_logs (
      user_id, user_email, action, target_table, target_id,
      old_values, new_values
    ) VALUES (
      v_user_id, v_user_email, v_action, TG_TABLE_NAME, OLD.id,
      v_old_values, v_new_values
    );
    
    RETURN OLD;
    
  ELSIF TG_OP = 'UPDATE' THEN
    v_old_values := to_jsonb(OLD);
    v_new_values := to_jsonb(NEW);
    
    -- Only log if there are actual changes (excluding updated_at, last_sync_at)
    IF v_old_values - 'updated_at' - 'last_sync_at' - 'is_pending_sync' 
       IS DISTINCT FROM 
       v_new_values - 'updated_at' - 'last_sync_at' - 'is_pending_sync' THEN
      
      INSERT INTO audit_logs (
        user_id, user_email, action, target_table, target_id,
        old_values, new_values
      ) VALUES (
        v_user_id, v_user_email, v_action, TG_TABLE_NAME, NEW.id,
        v_old_values, v_new_values
      );
    END IF;
    
    RETURN NEW;
    
  ELSIF TG_OP = 'INSERT' THEN
    v_old_values := NULL;
    v_new_values := to_jsonb(NEW);
    
    INSERT INTO audit_logs (
      user_id, user_email, action, target_table, target_id,
      old_values, new_values
    ) VALUES (
      v_user_id, v_user_email, v_action, TG_TABLE_NAME, NEW.id,
      v_old_values, v_new_values
    );
    
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. PIPELINE STAGE HISTORY TRIGGER FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION log_pipeline_stage_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Only log when stage_id actually changes
  IF OLD.stage_id IS DISTINCT FROM NEW.stage_id THEN
    -- Check if this exact transition already exists (from client sync)
    -- This prevents duplicates when client creates history and syncs
    IF NOT EXISTS (
      SELECT 1 FROM pipeline_stage_history
      WHERE pipeline_id = NEW.id
        AND from_stage_id IS NOT DISTINCT FROM OLD.stage_id
        AND to_stage_id = NEW.stage_id
        AND changed_at >= NOW() - INTERVAL '5 minutes'
    ) THEN
      INSERT INTO pipeline_stage_history (
        pipeline_id,
        from_stage_id,
        to_stage_id,
        from_status_id,
        to_status_id,
        notes,
        changed_by,
        changed_at
      ) VALUES (
        NEW.id,
        OLD.stage_id,
        NEW.stage_id,
        OLD.status_id,
        NEW.status_id,
        NEW.notes,  -- Capture current notes as the change reason
        auth.uid(),
        NOW()
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. APPLY TRIGGERS TO TABLES
-- ============================================

-- Drop existing triggers if they exist (to allow re-running)
DROP TRIGGER IF EXISTS customers_audit_trigger ON customers;
DROP TRIGGER IF EXISTS pipelines_audit_trigger ON pipelines;
DROP TRIGGER IF EXISTS pipeline_referrals_audit_trigger ON pipeline_referrals;
DROP TRIGGER IF EXISTS pipelines_stage_history_trigger ON pipelines;
DROP TRIGGER IF EXISTS hvc_audit_trigger ON hvcs;
DROP TRIGGER IF EXISTS customer_hvc_links_audit_trigger ON customer_hvc_links;


-- Add broker audit trigger
DROP TRIGGER IF EXISTS brokers_audit_trigger ON brokers;
CREATE TRIGGER brokers_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON brokers
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- Customers audit trigger
CREATE TRIGGER customers_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON customers
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- Pipelines audit trigger
CREATE TRIGGER pipelines_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- Pipeline referrals audit trigger
CREATE TRIGGER pipeline_referrals_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON pipeline_referrals
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- Pipeline stage history trigger (separate from generic audit)
CREATE TRIGGER pipelines_stage_history_trigger
  AFTER UPDATE ON pipelines
  FOR EACH ROW
  EXECUTE FUNCTION log_pipeline_stage_change();

-- HVC audit trigger
CREATE TRIGGER hvc_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON hvcs
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- Customer-HVC links audit trigger
CREATE TRIGGER customer_hvc_links_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON customer_hvc_links
  FOR EACH ROW
  EXECUTE FUNCTION log_entity_changes();

-- ============================================
-- 6. RLS POLICIES FOR AUDIT TABLES
-- ============================================

-- Audit Logs RLS
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "audit_logs_admin" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_select_own" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_select_subordinates" ON audit_logs;

-- Admins can view all audit logs
CREATE POLICY "audit_logs_admin" ON audit_logs
FOR ALL USING (is_admin());

-- Users can view audit logs for their own actions
CREATE POLICY "audit_logs_select_own" ON audit_logs
FOR SELECT USING (user_id = (SELECT auth.uid()));

-- Supervisors can view audit logs from their subordinates
CREATE POLICY "audit_logs_select_subordinates" ON audit_logs
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = audit_logs.user_id
    AND depth > 0
  )
);

-- Pipeline Stage History RLS
ALTER TABLE pipeline_stage_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "pipeline_stage_history_admin" ON pipeline_stage_history;
DROP POLICY IF EXISTS "pipeline_stage_history_select_own" ON pipeline_stage_history;
DROP POLICY IF EXISTS "pipeline_stage_history_select_subordinates" ON pipeline_stage_history;
DROP POLICY IF EXISTS "pipeline_stage_history_insert_own" ON pipeline_stage_history;

-- Admins can view all
CREATE POLICY "pipeline_stage_history_admin" ON pipeline_stage_history
FOR ALL USING (is_admin());

-- Users can view history for their own pipelines
CREATE POLICY "pipeline_stage_history_select_own" ON pipeline_stage_history
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM pipelines p
    WHERE p.id = pipeline_stage_history.pipeline_id
    AND (p.assigned_rm_id = (SELECT auth.uid()) OR p.created_by = (SELECT auth.uid()))
  )
);

-- Supervisors can view history for subordinate pipelines
CREATE POLICY "pipeline_stage_history_select_subordinates" ON pipeline_stage_history
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM pipelines p
    WHERE p.id = pipeline_stage_history.pipeline_id
    AND EXISTS (
      SELECT 1 FROM user_hierarchy
      WHERE ancestor_id = (SELECT auth.uid())
      AND descendant_id = p.assigned_rm_id
    )
  )
);

-- Users can insert their own history entries (for offline sync)
CREATE POLICY "pipeline_stage_history_insert_own" ON pipeline_stage_history
FOR INSERT WITH CHECK (
  changed_by = (SELECT auth.uid())
);

-- ============================================
-- 7. GRANT PERMISSIONS (for authenticated users)
-- ============================================

-- Grant insert permission on audit tables for trigger function
GRANT INSERT ON audit_logs TO authenticated;
GRANT INSERT ON pipeline_stage_history TO authenticated;

-- Grant select for viewing history
GRANT SELECT ON audit_logs TO authenticated;
GRANT SELECT ON pipeline_stage_history TO authenticated;

-- ============================================
-- END AUDIT TRIGGERS MIGRATION
-- ============================================

-- ============================================
-- VERIFICATION QUERIES (run manually to test)
-- ============================================

-- Test: Check if triggers are installed
-- SELECT trigger_name, event_object_table, action_timing, event_manipulation
-- FROM information_schema.triggers
-- WHERE trigger_schema = 'public'
-- AND trigger_name LIKE '%audit%' OR trigger_name LIKE '%history%';

-- Test: Check recent audit logs
-- SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT 10;

-- Test: Check pipeline stage history
-- SELECT 
--   psh.*, 
--   ps_from.name as from_stage_name,
--   ps_to.name as to_stage_name
-- FROM pipeline_stage_history psh
-- LEFT JOIN pipeline_stages ps_from ON psh.from_stage_id = ps_from.id
-- LEFT JOIN pipeline_stages ps_to ON psh.to_stage_id = ps_to.id
-- ORDER BY changed_at DESC LIMIT 10;
