# 🔐 RLS Policies

## Row Level Security Policies LeadX CRM

---

## 📋 Overview

Dokumen ini mendefinisikan semua Row Level Security (RLS) policies dan **Role & Permission** system yang diterapkan di PostgreSQL untuk mengontrol akses data.

---

## 🔐 Role & Permission System

### Roles

| Role | Code | Level | Description |
|------|------|-------|-------------|
| Super Admin | SUPERADMIN | 0 | Full system access, all permissions |
| Admin | ADMIN | 1 | Full operational access, manage all data |
| Regional Head | ROH | 2 | Regional scope, read all regional data |
| Branch Manager | BM | 3 | Branch scope, manage branch operations |
| Business Head | BH | 4 | Team scope, manage team |
| Relationship Manager | RM | 5 | Own data only |

### Permission Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PERMISSION CATEGORIES                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CUSTOMER          PIPELINE          ACTIVITY          HVC/BROKER           │
│  ├─ view           ├─ view           ├─ view           ├─ view              │
│  ├─ create         ├─ create         ├─ create         ├─ create (ADMIN)   │
│  ├─ edit           ├─ edit           ├─ edit           ├─ edit (ADMIN)     │
│  ├─ delete         ├─ edit_stage     ├─ delete         ├─ delete (ADMIN)   │
│  └─ assign         └─ delete         └─ approve        └─ bulk_upload      │
│                                                                              │
│  REFERRAL          4DX               CADENCE           ADMIN                │
│  ├─ create         ├─ view_score     ├─ view           ├─ manage_users     │
│  ├─ accept         ├─ view_team      ├─ submit_form    ├─ manage_roles     │
│  ├─ reject         ├─ config (ADMIN) ├─ mark_attend    ├─ manage_config    │
│  └─ approve_bm     └─ set_targets    └─ create_meeting ├─ view_audit       │
│                                                         └─ bulk_upload      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Permission Matrix

| Permission | RM | BH | BM | ROH | ADMIN |
|------------|----|----|----|----|-------|
| **CUSTOMER** |||||
| customer.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| customer.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| customer.view_all | ❌ | ❌ | ❌ | ❌ | ✅ |
| customer.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| customer.edit_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| customer.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| **PIPELINE** |||||
| pipeline.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| pipeline.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| pipeline.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| pipeline.edit_stage | ✅ | ✅ | ✅ | ✅ | ✅ |
| pipeline.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| **ACTIVITY** |||||
| activity.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| activity.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| activity.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| activity.edit_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| activity.view_audit_log | ✅ | ✅ | ✅ | ✅ | ✅ |
| **HVCS** |||||
| hvc.view | ✅ | ✅ | ✅ | ✅ | ✅ |
| hvc.create | ❌ | ❌ | ❌ | ❌ | ✅ |
| hvc.edit | ❌ | ❌ | ❌ | ❌ | ✅ |
| hvc.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| hvc.bulk_upload | ❌ | ❌ | ❌ | ❌ | ✅ |
| **BROKER/AGENT** |||||
| broker.view | ✅ | ✅ | ✅ | ✅ | ✅ |
| broker.create | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.edit | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.bulk_upload | ❌ | ❌ | ❌ | ❌ | ✅ |
| **REFERRAL** |||||
| referral.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| referral.accept_reject | ✅ | ✅ | ✅ | ✅ | ✅ |
| referral.approve_bm | ❌ | ❌ | ✅ | ✅ | ✅ |
| **4DX** |||||
| score.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| score.view_team | ❌ | ✅ | ✅ | ✅ | ✅ |
| score.view_all | ❌ | ❌ | ❌ | ❌ | ✅ |
| score.set_targets | ❌ | ✅ | ✅ | ✅ | ✅ |
| score.config_measures | ❌ | ❌ | ❌ | ❌ | ✅ |
| **CADENCE** |||||
| cadence.view | ✅ | ✅ | ✅ | ✅ | ✅ |
| cadence.submit_form | ✅ | ✅ | ✅ | ✅ | ✅ |
| cadence.mark_attendance | ❌ | ✅ | ✅ | ✅ | ✅ |
| cadence.create_meeting | ❌ | ✅ | ✅ | ✅ | ✅ |
| cadence.config | ❌ | ❌ | ❌ | ❌ | ✅ |
| **ADMIN** |||||
| admin.access_panel | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_users | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_roles | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_config | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.view_all_audit | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.bulk_upload | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.export_data | ❌ | ❌ | ✅ | ✅ | ✅ |

### Database Schema for Roles & Permissions

```sql
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  level INTEGER NOT NULL, -- Lower = higher authority
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE, -- Cannot be deleted
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(100) UNIQUE NOT NULL, -- e.g., 'customer.create'
  name VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL, -- CUSTOMER, PIPELINE, etc
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE role_permissions (
  role_id UUID REFERENCES roles(id),
  permission_id UUID REFERENCES permissions(id),
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  granted_by UUID REFERENCES users(id),
  PRIMARY KEY (role_id, permission_id)
);

-- Function to check permission
CREATE OR REPLACE FUNCTION has_permission(user_id UUID, permission_code TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users u
    JOIN role_permissions rp ON rp.role_id = u.role_id
    JOIN permissions p ON p.id = rp.permission_id
    WHERE u.id = user_id AND p.code = permission_code
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Bulk Upload (Admin Only)

Admin dapat upload data secara bulk untuk:
- **HVC**: Upload Excel/CSV dengan kolom (name, type, address, dll)
- **Broker/Agent**: Upload Excel/CSV dengan kolom (name, type, contact, dll)
- **Users**: Upload Excel/CSV untuk onboarding batch users

```sql
CREATE TABLE bulk_uploads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type VARCHAR(50) NOT NULL, -- 'HVC', 'BROKER', 'USER'
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  total_rows INTEGER,
  success_count INTEGER DEFAULT 0,
  error_count INTEGER DEFAULT 0,
  status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, PROCESSING, COMPLETED, FAILED
  error_details JSONB, -- Array of row errors
  uploaded_by UUID REFERENCES users(id),
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🏛️ Access Control Principles

### Role Hierarchy

```
SUPERADMIN (All data)
├── ADMIN (All data)
├── ROH (Regional data)
│   ├── BM (Branch data)
│   │   ├── BH (Team data)
│   │   │   └── RM (Own data only)
```

### Access Patterns

| Role | Own Data | Subordinate Data | Branch | Regional | All |
|------|----------|------------------|--------|----------|-----|
| RM | ✅ | ❌ | ❌ | ❌ | ❌ |
| BH | ✅ | ✅ (direct) | ❌ | ❌ | ❌ |
| BM | ✅ | ✅ | ✅ | ❌ | ❌ |
| ROH | ✅ | ✅ | ✅ | ✅ | ❌ |
| ADMIN | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 🔑 Core RLS Policies

### Users Table

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can view themselves
CREATE POLICY "users_self_view" ON users
FOR SELECT USING (id = auth.uid());

-- Supervisors can view subordinates
CREATE POLICY "users_subordinate_view" ON users
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = auth.uid()
    AND descendant_id = users.id
  )
);

-- Admins can view all
CREATE POLICY "users_admin_all" ON users
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = auth.uid()
    AND u.role IN ('ADMIN', 'SUPERADMIN')
  )
);
```

### Customers Table

```sql
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- RM can access own customers
CREATE POLICY "customers_rm_own" ON customers
FOR ALL USING (assigned_rm_id = (SELECT auth.uid()));

-- Supervisors can access subordinate customers
CREATE POLICY "customers_supervisor" ON customers
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = customers.assigned_rm_id
  )
);

-- Admins full access
CREATE POLICY "customers_admin" ON customers
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (SELECT auth.uid())
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);
```

### Pipelines Table

```sql
ALTER TABLE pipelines ENABLE ROW LEVEL SECURITY;

-- Same pattern as customers
CREATE POLICY "pipelines_rm_own" ON pipelines
FOR ALL USING (assigned_rm_id = (SELECT auth.uid()));

CREATE POLICY "pipelines_supervisor" ON pipelines
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = pipelines.assigned_rm_id
  )
);
```

### Activities Table

```sql
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Users can access own activities
CREATE POLICY "activities_own" ON activities
FOR ALL USING (user_id = (SELECT auth.uid()));

-- Supervisors can view subordinate activities
CREATE POLICY "activities_supervisor" ON activities
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = activities.user_id
  )
);
```

---

## 🔧 User Hierarchy (Closure Table)

```sql
-- Precomputed hierarchy for efficient RLS queries
CREATE TABLE user_hierarchy (
  ancestor_id UUID NOT NULL REFERENCES users(id),
  descendant_id UUID NOT NULL REFERENCES users(id),
  depth INTEGER NOT NULL,
  PRIMARY KEY (ancestor_id, descendant_id)
);

-- Indexes for performance
CREATE INDEX idx_hierarchy_ancestor ON user_hierarchy(ancestor_id);
CREATE INDEX idx_hierarchy_descendant ON user_hierarchy(descendant_id);

-- Trigger to maintain hierarchy on user changes
CREATE OR REPLACE FUNCTION update_user_hierarchy()
RETURNS TRIGGER AS $$
BEGIN
  -- Remove old relations
  DELETE FROM user_hierarchy WHERE descendant_id = NEW.id;
  
  -- Add self-reference
  INSERT INTO user_hierarchy VALUES (NEW.id, NEW.id, 0);
  
  -- Add ancestor relations
  IF NEW.supervisor_id IS NOT NULL THEN
    INSERT INTO user_hierarchy (ancestor_id, descendant_id, depth)
    SELECT ancestor_id, NEW.id, depth + 1
    FROM user_hierarchy
    WHERE descendant_id = NEW.supervisor_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## ⚡ Performance Optimizations

### Required Indexes

```sql
-- Index on RLS policy columns
CREATE INDEX idx_customers_assigned_rm ON customers(assigned_rm_id);
CREATE INDEX idx_pipelines_assigned_rm ON pipelines(assigned_rm_id);
CREATE INDEX idx_activities_user ON activities(user_id);

-- Wrap auth.uid() in SELECT for caching
-- Example of optimized policy:
CREATE POLICY "optimized_policy" ON customers
FOR SELECT USING (
  assigned_rm_id = (SELECT auth.uid())  -- Cached!
);
```

---

## 🛡️ Security Audit Fixes (2026-02-04)

### Issue 1: CRITICAL - sync_queue_items RLS Bypass

**Problem:** Policy `USING (true)` allowed ALL authenticated users to see ALL sync queue items, including sensitive payloads with customer data, pipeline values, and personal information.

**Fix:** Removed permissive policy. Table now has RLS enabled with no policies = service_role access only.

```sql
-- Migration: 20260204100000_fix_sync_queue_rls.sql
DROP POLICY IF EXISTS "sync_queue_own" ON sync_queue_items;
-- No new policy = no authenticated user access
```

### Issue 2: HIGH - user_hierarchy Missing RLS

**Problem:** Table had no RLS enabled, exposing the complete organizational hierarchy to any authenticated user.

**Fix:** Enabled RLS with scoped policies.

```sql
-- Migration: 20260204100001_enable_user_hierarchy_rls.sql
ALTER TABLE user_hierarchy ENABLE ROW LEVEL SECURITY;

-- Users see only their own relationships
CREATE POLICY "user_hierarchy_select_own" ON user_hierarchy
FOR SELECT USING (
  ancestor_id = (SELECT auth.uid())
  OR descendant_id = (SELECT auth.uid())
);

-- Admins have full access
CREATE POLICY "user_hierarchy_admin_all" ON user_hierarchy
FOR ALL USING (is_admin());
```

### Issue 3: MEDIUM - hvcs Overly Permissive Policy

**Problem:** Policy `hvcs_select_authenticated` allowed all users to see ALL HVCs regardless of ownership.

**Fix:** Replaced with three scoped policies.

```sql
-- Migration: 20260204100002_fix_hvcs_rls.sql
DROP POLICY IF EXISTS "hvcs_select_authenticated" ON hvcs;

-- Policy 1: Own HVCs
CREATE POLICY "hvcs_select_own" ON hvcs
FOR SELECT USING (created_by = (SELECT auth.uid()));

-- Policy 2: Subordinate HVCs
CREATE POLICY "hvcs_select_hierarchy" ON hvcs
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = hvcs.created_by
  )
);

-- Policy 3: HVCs linked to accessible customers
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
```

---

## ✅ RLS Checklist

- [x] Enable RLS on all user-facing tables
- [x] Create policies for SELECT, INSERT, UPDATE, DELETE
- [x] Index all columns used in policies
- [x] Use `(SELECT auth.uid())` for caching
- [x] Document all policies with comments
- [x] Test with different user roles
- [x] Security audit completed (2026-02-04)

---

## 🏢 Cadence Tables RLS

### cadence_schedule_config (Master Data Pattern)

```sql
ALTER TABLE cadence_schedule_config ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read configs
CREATE POLICY "cadence_config_select" ON cadence_schedule_config
FOR SELECT USING (auth.uid() IS NOT NULL);

-- Admins can manage configs
CREATE POLICY "cadence_config_admin" ON cadence_schedule_config
FOR ALL USING (is_admin());
```

### cadence_meetings

```sql
ALTER TABLE cadence_meetings ENABLE ROW LEVEL SECURITY;

-- Users can see meetings they're part of (as facilitator or participant)
CREATE POLICY "cadence_meetings_select" ON cadence_meetings
FOR SELECT USING (
  facilitator_id = (SELECT auth.uid())
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

-- Facilitator or creator can update their meetings
CREATE POLICY "cadence_meetings_update" ON cadence_meetings
FOR UPDATE USING (
  facilitator_id = (SELECT auth.uid())
  OR created_by = (SELECT auth.uid())
);

-- Admin full access
CREATE POLICY "cadence_meetings_admin" ON cadence_meetings
FOR ALL USING (is_admin());
```

### cadence_participants

```sql
ALTER TABLE cadence_participants ENABLE ROW LEVEL SECURITY;

-- Users can see/update their own participation
CREATE POLICY "cadence_participants_own" ON cadence_participants
FOR ALL USING (user_id = (SELECT auth.uid()));

-- Facilitator (host) can manage participants in their meetings
CREATE POLICY "cadence_participants_host" ON cadence_participants
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM cadence_meetings cm
    WHERE cm.id = cadence_participants.meeting_id
    AND cm.facilitator_id = (SELECT auth.uid())
  )
);

-- Admin full access
CREATE POLICY "cadence_participants_admin" ON cadence_participants
FOR ALL USING (is_admin());
```

### Organizational Tables (regional_offices, branches)

```sql
-- Master data pattern: read-all, admin-modify
ALTER TABLE regional_offices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "regional_offices_select" ON regional_offices
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "regional_offices_admin" ON regional_offices
FOR ALL USING (is_admin());

-- Same pattern applied to branches
```

### dirty_users (System Table - No RLS)

No RLS policies. System-only table accessed exclusively via `SECURITY DEFINER` functions and the `score-aggregation-cron` Edge Function with `service_role` key.

### spatial_ref_sys (PostGIS System Table - No RLS)

PostgreSQL system table auto-created by PostGIS extension. Not application-managed, no RLS needed.

---

## 📚 Related Documents

- [Security Architecture](../03-architecture/security-architecture.md)
- [Schema Overview](schema-overview.md)
- [Entity Relationships](entity-relationships.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Database Documentation.*
