-- ============================================
-- LeadX CRM - RLS Policies
-- Run this FOURTH after 03_4dx_system_seed.sql
-- ============================================

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Get current user's role
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() 
    AND role IN ('ADMIN', 'SUPERADMIN')
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if user is supervisor of target user
CREATE OR REPLACE FUNCTION is_supervisor_of(target_user_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = auth.uid()
    AND descendant_id = target_user_id
    AND depth > 0
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if user can access a specific customer (bypasses RLS to prevent recursion)
CREATE OR REPLACE FUNCTION can_access_customer(p_customer_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM customers c
    WHERE c.id = p_customer_id
    AND (
      c.assigned_rm_id = (SELECT auth.uid())
      OR c.created_by = (SELECT auth.uid())
      OR EXISTS (
        SELECT 1 FROM user_hierarchy
        WHERE ancestor_id = (SELECT auth.uid())
        AND descendant_id = c.assigned_rm_id
      )
      OR is_admin()
    )
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if user has HVC access to a customer (bypasses RLS to prevent recursion)
CREATE OR REPLACE FUNCTION has_hvc_access_to_customer(p_customer_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM customer_hvc_links chl
    WHERE chl.customer_id = p_customer_id
    AND chl.hvc_id IN (
      SELECT c2.id FROM customers c2 
      WHERE c2.assigned_rm_id = (SELECT auth.uid())
    )
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================
-- USERS TABLE
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can view themselves
CREATE POLICY "users_select_self" ON users
FOR SELECT USING (id = (SELECT auth.uid()));

-- Supervisors can view subordinates
CREATE POLICY "users_select_subordinates" ON users
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = users.id
  )
);

-- Admins have full access
CREATE POLICY "users_admin_all" ON users
FOR ALL USING (is_admin());

-- Users can update own profile (limited fields handled by trigger)
CREATE POLICY "users_update_self" ON users
FOR UPDATE USING (id = (SELECT auth.uid()));

-- ============================================
-- CUSTOMERS TABLE
-- ============================================

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- RM can view own customers
CREATE POLICY "customers_select_own" ON customers
FOR SELECT USING (
  assigned_rm_id = (SELECT auth.uid())
  OR created_by = (SELECT auth.uid())
);

-- Supervisors can view subordinate customers
CREATE POLICY "customers_select_subordinates" ON customers
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = customers.assigned_rm_id
  )
);

-- Users with related HVC can view customers (uses helper function to prevent recursion)
CREATE POLICY "customers_select_via_hvc" ON customers
FOR SELECT USING (has_hvc_access_to_customer(customers.id));

-- Admins have full access
CREATE POLICY "customers_admin_all" ON customers
FOR ALL USING (is_admin());

-- Users can create customers
CREATE POLICY "customers_insert" ON customers
FOR INSERT WITH CHECK (
  created_by = (SELECT auth.uid())
);

-- Users can update own assigned customers
CREATE POLICY "customers_update_own" ON customers
FOR UPDATE USING (
  assigned_rm_id = (SELECT auth.uid())
);

-- Only admins can delete (via admin_all policy)

-- ============================================
-- PIPELINES TABLE
-- ============================================

ALTER TABLE pipelines ENABLE ROW LEVEL SECURITY;

-- RM can view own pipelines
CREATE POLICY "pipelines_select_own" ON pipelines
FOR SELECT USING (
  assigned_rm_id = (SELECT auth.uid())
  OR created_by = (SELECT auth.uid())
);

-- Supervisors can view subordinate pipelines
CREATE POLICY "pipelines_select_subordinates" ON pipelines
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = pipelines.assigned_rm_id
  )
);

-- Admins have full access
CREATE POLICY "pipelines_admin_all" ON pipelines
FOR ALL USING (is_admin());

-- Users can create pipelines
CREATE POLICY "pipelines_insert" ON pipelines
FOR INSERT WITH CHECK (
  created_by = (SELECT auth.uid())
);

-- Users can update own pipelines
CREATE POLICY "pipelines_update_own" ON pipelines
FOR UPDATE USING (
  assigned_rm_id = (SELECT auth.uid())
);

-- ============================================
-- ACTIVITIES TABLE
-- ============================================

ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Users can view own activities
CREATE POLICY "activities_select_own" ON activities
FOR SELECT USING (
  user_id = (SELECT auth.uid())
  OR created_by = (SELECT auth.uid())
);

-- Supervisors can view subordinate activities
CREATE POLICY "activities_select_subordinates" ON activities
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = activities.user_id
  )
);

-- Admins have full access
CREATE POLICY "activities_admin_all" ON activities
FOR ALL USING (is_admin());

-- Users can create activities
CREATE POLICY "activities_insert" ON activities
FOR INSERT WITH CHECK (
  created_by = (SELECT auth.uid())
);

-- Users can update own activities
CREATE POLICY "activities_update_own" ON activities
FOR UPDATE USING (
  user_id = (SELECT auth.uid())
);

-- ============================================
-- ACTIVITY PHOTOS TABLE
-- ============================================

ALTER TABLE activity_photos ENABLE ROW LEVEL SECURITY;

-- Access via activity ownership
CREATE POLICY "activity_photos_via_activity" ON activity_photos
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM activities a
    WHERE a.id = activity_photos.activity_id
    AND (a.user_id = (SELECT auth.uid()) OR is_admin())
  )
);

-- ============================================
-- ACTIVITY AUDIT LOGS TABLE
-- ============================================

ALTER TABLE activity_audit_logs ENABLE ROW LEVEL SECURITY;

-- Users can view audit logs for their activities
CREATE POLICY "activity_audit_logs_select" ON activity_audit_logs
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM activities a
    WHERE a.id = activity_audit_logs.activity_id
    AND (
      a.user_id = (SELECT auth.uid())
      OR EXISTS (
        SELECT 1 FROM user_hierarchy
        WHERE ancestor_id = (SELECT auth.uid())
        AND descendant_id = a.user_id
      )
      OR is_admin()
    )
  )
);

-- ============================================
-- HVC TABLE (Admin managed, read by all authenticated)
-- ============================================

ALTER TABLE hvc ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view HVC
CREATE POLICY "hvc_select_authenticated" ON hvc
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can modify
CREATE POLICY "hvc_admin_all" ON hvc
FOR ALL USING (is_admin());

-- ============================================
-- BROKERS TABLE (Admin managed, read by all authenticated)
-- ============================================

ALTER TABLE brokers ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view brokers
CREATE POLICY "brokers_select_authenticated" ON brokers
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can modify
CREATE POLICY "brokers_admin_all" ON brokers
FOR ALL USING (is_admin());

-- ============================================
-- KEY PERSONS TABLE
-- ============================================

ALTER TABLE key_persons ENABLE ROW LEVEL SECURITY;

-- Access based on owner entity (uses helper function to prevent recursion)
CREATE POLICY "key_persons_customer_owner" ON key_persons
FOR ALL USING (
  customer_id IS NOT NULL 
  AND can_access_customer(key_persons.customer_id)
);

-- HVC/Broker key persons - admins only for modify
CREATE POLICY "key_persons_hvc_broker" ON key_persons
FOR SELECT USING (
  (hvc_id IS NOT NULL OR broker_id IS NOT NULL)
  AND auth.uid() IS NOT NULL
);

CREATE POLICY "key_persons_admin" ON key_persons
FOR ALL USING (is_admin());

-- ============================================
-- CUSTOMER HVC LINKS TABLE
-- ============================================

ALTER TABLE customer_hvc_links ENABLE ROW LEVEL SECURITY;

-- View if owns customer or is admin
CREATE POLICY "customer_hvc_links_select" ON customer_hvc_links
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM customers c
    WHERE c.id = customer_hvc_links.customer_id
    AND (
      c.assigned_rm_id = (SELECT auth.uid())
      OR EXISTS (
        SELECT 1 FROM user_hierarchy
        WHERE ancestor_id = (SELECT auth.uid())
        AND descendant_id = c.assigned_rm_id
      )
    )
  )
  OR is_admin()
);

-- Only admins can modify
CREATE POLICY "customer_hvc_links_admin" ON customer_hvc_links
FOR ALL USING (is_admin());

-- ============================================
-- PIPELINE REFERRALS TABLE
-- ============================================

ALTER TABLE pipeline_referrals ENABLE ROW LEVEL SECURITY;

-- Users can see referrals they're involved in
CREATE POLICY "pipeline_referrals_involved" ON pipeline_referrals
FOR SELECT USING (
  referrer_rm_id = (SELECT auth.uid())
  OR receiver_rm_id = (SELECT auth.uid())
  OR bm_approved_by = (SELECT auth.uid())
  OR is_admin()
);

-- Users can create referrals
CREATE POLICY "pipeline_referrals_insert" ON pipeline_referrals
FOR INSERT WITH CHECK (
  referrer_rm_id = (SELECT auth.uid())
);

-- Receiving user can update (accept/reject)
CREATE POLICY "pipeline_referrals_update_receiver" ON pipeline_referrals
FOR UPDATE USING (
  receiver_rm_id = (SELECT auth.uid())
);

-- BM+ can approve
CREATE POLICY "pipeline_referrals_approve" ON pipeline_referrals
FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('BM', 'ROH', 'ADMIN', 'SUPERADMIN')
  )
);

-- ============================================
-- 4DX TABLES
-- ============================================

-- Scoring Periods - read all, admin modify
ALTER TABLE scoring_periods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "scoring_periods_select" ON scoring_periods
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "scoring_periods_admin" ON scoring_periods
FOR ALL USING (is_admin());

-- Measure Definitions - read all, admin modify
ALTER TABLE measure_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "measure_definitions_select" ON measure_definitions
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "measure_definitions_admin" ON measure_definitions
FOR ALL USING (is_admin());

-- User Targets
ALTER TABLE user_targets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_targets_select_own" ON user_targets
FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY "user_targets_select_subordinates" ON user_targets
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = user_targets.user_id
  )
);

-- BH+ can set targets for subordinates
CREATE POLICY "user_targets_modify" ON user_targets
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('BH', 'BM', 'ROH', 'ADMIN', 'SUPERADMIN')
  )
  AND (
    is_admin()
    OR EXISTS (
      SELECT 1 FROM user_hierarchy
      WHERE ancestor_id = (SELECT auth.uid())
      AND descendant_id = user_targets.user_id
    )
  )
);

-- User Scores
ALTER TABLE user_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_scores_select_own" ON user_scores
FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY "user_scores_select_subordinates" ON user_scores
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = user_scores.user_id
  )
);

CREATE POLICY "user_scores_admin" ON user_scores
FOR ALL USING (is_admin());

-- ============================================
-- CADENCE TABLES
-- ============================================

ALTER TABLE cadence_schedule_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "cadence_config_select" ON cadence_schedule_config
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "cadence_config_admin" ON cadence_schedule_config
FOR ALL USING (is_admin());

ALTER TABLE cadence_meetings ENABLE ROW LEVEL SECURITY;

-- Users can see meetings they're part of
CREATE POLICY "cadence_meetings_select" ON cadence_meetings
FOR SELECT USING (
  host_id = (SELECT auth.uid())
  OR EXISTS (
    SELECT 1 FROM cadence_participants cp
    WHERE cp.meeting_id = cadence_meetings.id
    AND cp.user_id = (SELECT auth.uid())
  )
  OR is_admin()
);

-- BH+ can create meetings
CREATE POLICY "cadence_meetings_create" ON cadence_meetings
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('BH', 'BM', 'ROH', 'ADMIN', 'SUPERADMIN')
  )
);

ALTER TABLE cadence_participants ENABLE ROW LEVEL SECURITY;

-- Users can see/update their own participation
CREATE POLICY "cadence_participants_own" ON cadence_participants
FOR ALL USING (user_id = (SELECT auth.uid()));

-- Host can manage participants
CREATE POLICY "cadence_participants_host" ON cadence_participants
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM cadence_meetings cm
    WHERE cm.id = cadence_participants.meeting_id
    AND cm.host_id = (SELECT auth.uid())
  )
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_own" ON notifications
FOR ALL USING (user_id = (SELECT auth.uid()));

-- ============================================
-- ANNOUNCEMENTS TABLE
-- ============================================

ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- All authenticated can read active announcements
CREATE POLICY "announcements_select" ON announcements
FOR SELECT USING (
  auth.uid() IS NOT NULL
  AND is_active = true
  AND (start_at IS NULL OR start_at <= NOW())
  AND (end_at IS NULL OR end_at >= NOW())
);

CREATE POLICY "announcements_admin" ON announcements
FOR ALL USING (is_admin());

ALTER TABLE announcement_reads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "announcement_reads_own" ON announcement_reads
FOR ALL USING (user_id = (SELECT auth.uid()));

-- ============================================
-- SYSTEM TABLES
-- ============================================

-- Sync queue - users own
ALTER TABLE sync_queue_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sync_queue_own" ON sync_queue_items
FOR ALL USING (true); -- Handled by app logic

-- Audit logs - admins only
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_logs_admin" ON audit_logs
FOR SELECT USING (is_admin());

-- App settings - read all, admin modify
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_settings_select" ON app_settings
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "app_settings_admin" ON app_settings
FOR ALL USING (is_admin());

-- ============================================
-- MASTER DATA TABLES (Read-only for all, Admin modify)
-- ============================================

-- Apply to all master data tables
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'provinces', 'cities', 'company_types', 'ownership_types', 
    'industries', 'cobs', 'lobs', 'pipeline_stages', 
    'pipeline_statuses', 'activity_types', 'lead_sources', 
    'decline_reasons', 'hvc_types'
  ] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tbl);
    EXECUTE format('CREATE POLICY "%s_select" ON %I FOR SELECT USING (auth.uid() IS NOT NULL)', tbl, tbl);
    EXECUTE format('CREATE POLICY "%s_admin" ON %I FOR ALL USING (is_admin())', tbl, tbl);
  END LOOP;
END $$;

-- ============================================
-- END RLS POLICIES
-- ============================================
