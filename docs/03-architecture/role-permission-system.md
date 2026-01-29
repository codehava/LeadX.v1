# 🔐 Role & Permission System

## Sistem Manajemen Akses LeadX CRM

---

## 📋 Overview

LeadX CRM menggunakan sistem **Role-Based Access Control (RBAC)** dengan permission granular untuk mengontrol akses ke setiap fitur dan data dalam aplikasi.

---

## 🎯 Design Principles

| Principle | Description |
|-----------|-------------|
| **Least Privilege** | User hanya mendapat akses minimal yang dibutuhkan |
| **Hierarchical Access** | Supervisor dapat melihat data subordinat |
| **Separation of Duties** | Pemisahan antara operasional dan administratif |
| **Audit Trail** | Semua perubahan permission tercatat |

---

## 👥 Role Definitions

### System Roles

| Role | Code | Level | Scope | Primary Responsibility |
|------|------|-------|-------|----------------------|
| **Super Admin** | SUPERADMIN | 0 | System | Full access, system configuration |
| **Admin** | ADMIN | 1 | Company | User management, master data, configuration |
| **Regional Head** | ROH | 2 | Regional | Regional performance, strategic oversight |
| **Branch Manager** | BM | 3 | Branch | Branch operations, approvals, team management |
| **Branch Head** | BH | 4 | Team | Team coordination, cadence hosting |
| **Relationship Manager** | RM | 5 | Personal | Customer management, sales activities |

### Role Hierarchy Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ROLE HIERARCHY                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                    ┌──────────────┐                                         │
│                    │ SUPERADMIN   │                                         │
│                    │ (Level 0)    │                                         │
│                    └──────┬───────┘                                         │
│                           │                                                  │
│                    ┌──────▼───────┐                                         │
│                    │    ADMIN     │                                         │
│                    │  (Level 1)   │                                         │
│                    └──────┬───────┘                                         │
│                           │                                                  │
│              ┌────────────┼────────────┐                                    │
│              │            │            │                                    │
│       ┌──────▼─────┐     ...    ┌──────▼─────┐                              │
│       │    ROH     │            │    ROH     │                              │
│       │ (Level 2)  │            │ (Level 2)  │                              │
│       └──────┬─────┘            └────────────┘                              │
│              │                                                               │
│    ┌─────────┼─────────┐                                                    │
│    │         │         │                                                    │
│ ┌──▼───┐  ┌──▼───┐  ┌──▼───┐                                               │
│ │  BM  │  │  BM  │  │  BM  │                                               │
│ │ (L3) │  │ (L3) │  │ (L3) │                                               │
│ └──┬───┘  └──────┘  └──────┘                                               │
│    │                                                                         │
│  ┌─┴──────┬────────┐                                                        │
│  │        │        │                                                        │
│ ┌▼──┐   ┌─▼─┐   ┌─▼─┐                                                      │
│ │BH │   │BH │   │BH │                                                      │
│ │L4 │   │L4 │   │L4 │                                                      │
│ └┬──┘   └───┘   └───┘                                                      │
│  │                                                                           │
│ ┌┴───┬────┬────┐                                                            │
│ │    │    │    │                                                            │
│ ▼    ▼    ▼    ▼                                                            │
│ RM   RM   RM   RM                                                           │
│ (L5) (L5) (L5) (L5)                                                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Permission System

### Permission Categories

| Category | Description | Example Permissions |
|----------|-------------|---------------------|
| **CUSTOMER** | Customer data access | view, create, edit, delete, assign |
| **PIPELINE** | Pipeline management | view, create, edit_stage, delete |
| **ACTIVITY** | Activity logging | view, create, edit, approve |
| **HVC** | High Value Customer | view, create, edit, delete, bulk_upload |
| **BROKER** | Broker/Agent | view, create, edit, delete, bulk_upload |
| **REFERRAL** | Pipeline referral | create, accept, reject, approve_bm |
| **4DX** | Scoring system | view_score, view_team, config, set_targets |
| **CADENCE** | Meeting management | view, submit, mark_attend, config |
| **ADMIN** | Administrative | manage_users, manage_roles, manage_config |

### Full Permission Matrix

#### Customer & Pipeline

| Permission | RM | BH | BM | ROH | ADMIN |
|------------|:--:|:--:|:--:|:---:|:-----:|
| customer.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| customer.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| customer.view_all | ❌ | ❌ | ❌ | ❌ | ✅ |
| customer.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| customer.edit_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| customer.edit_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| customer.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| customer.reassign | ❌ | ❌ | ✅ | ✅ | ✅ |
| pipeline.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| pipeline.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| pipeline.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| pipeline.edit_stage | ✅ | ✅ | ✅ | ✅ | ✅ |
| pipeline.delete | ❌ | ❌ | ❌ | ❌ | ✅ |

#### HVC, Broker, Activity

| Permission | RM | BH | BM | ROH | ADMIN |
|------------|:--:|:--:|:--:|:---:|:-----:|
| hvc.view | ✅ | ✅ | ✅ | ✅ | ✅ |
| hvc.create | ❌ | ❌ | ❌ | ❌ | ✅ |
| hvc.edit | ❌ | ❌ | ❌ | ❌ | ✅ |
| hvc.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| hvc.bulk_upload | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.view | ✅ | ✅ | ✅ | ✅ | ✅ |
| broker.create | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.edit | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.delete | ❌ | ❌ | ❌ | ❌ | ✅ |
| broker.bulk_upload | ❌ | ❌ | ❌ | ❌ | ✅ |
| activity.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| activity.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| activity.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| activity.view_audit | ✅ | ✅ | ✅ | ✅ | ✅ |

#### Referral & Approval

| Permission | RM | BH | BM | ROH | ADMIN |
|------------|:--:|:--:|:--:|:---:|:-----:|
| referral.create | ✅ | ✅ | ✅ | ✅ | ✅ |
| referral.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| referral.view_subordinate | ❌ | ✅ | ✅ | ✅ | ✅ |
| referral.view_all | ❌ | ❌ | ❌ | ❌ | ✅ |
| referral.accept | ✅ | ✅ | ✅ | ✅ | ✅ |
| referral.reject | ✅ | ✅ | ✅ | ✅ | ✅ |
| referral.approve | ❌ | ❌ | ✅ | ✅ | ✅ |
| referral.cancel | ✅ | ✅ | ✅ | ✅ | ✅ |

> **Note on referral.approve**: BM can approve referrals where they are the designated approver (receiver has BM in hierarchy). ROH can approve referrals where they are the designated approver (receiver has no BM, or is at kanwil level). See [Pipeline Referral System](pipeline-referral-system.md#-approver-determination) for details.

#### 4DX & Cadence

| Permission | RM | BH | BM | ROH | ADMIN |
|------------|:--:|:--:|:--:|:---:|:-----:|
| score.view_own | ✅ | ✅ | ✅ | ✅ | ✅ |
| score.view_team | ❌ | ✅ | ✅ | ✅ | ✅ |
| score.view_all | ❌ | ❌ | ❌ | ❌ | ✅ |
| score.set_targets | ❌ | ✅ | ✅ | ✅ | ✅ |
| score.config_measures | ❌ | ❌ | ❌ | ❌ | ✅ |
| cadence.view | ✅ | ✅ | ✅ | ✅ | ✅ |
| cadence.submit_form | ✅ | ✅ | ✅ | ✅ | ✅ |
| cadence.host_meeting | ❌ | ✅ | ✅ | ✅ | ✅ |
| cadence.mark_attendance | ❌ | ✅ | ✅ | ✅ | ✅ |
| cadence.config | ❌ | ❌ | ❌ | ❌ | ✅ |

#### Administration

| Permission | RM | BH | BM | ROH | ADMIN |
|------------|:--:|:--:|:--:|:---:|:-----:|
| admin.access_panel | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_users | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_roles | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_config | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.manage_master_data | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.view_all_audit | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.bulk_upload | ❌ | ❌ | ❌ | ❌ | ✅ |
| admin.export_data | ❌ | ❌ | ✅ | ✅ | ✅ |

---

## 🗄️ Database Schema

```sql
-- Roles table
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  level INTEGER NOT NULL,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permissions table
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Role-Permission mapping
CREATE TABLE role_permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  granted_by UUID REFERENCES users(id),
  UNIQUE(role_id, permission_id)
);

-- Permission check function
CREATE OR REPLACE FUNCTION has_permission(
  p_user_id UUID,
  p_permission_code TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM users u
    JOIN role_permissions rp ON rp.role_id = u.role_id
    JOIN permissions p ON p.id = rp.permission_id
    WHERE u.id = p_user_id
      AND p.code = p_permission_code
      AND p.is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Example usage in RLS policy
CREATE POLICY "hvc_admin_only_insert" ON hvc
FOR INSERT WITH CHECK (
  has_permission(auth.uid(), 'hvc.create')
);
```

---

## 📤 Bulk Upload System

### Supported Entities

| Entity | Template Columns | Admin Only |
|--------|-----------------|:----------:|
| **HVC** | name, type, address, phone, email, lat, lng | ✅ |
| **Broker** | name, type, address, phone, email, bank_info | ✅ |
| **Users** | name, email, role, branch, supervisor | ✅ |
| **Customers** | name, address, phone, industry, assigned_rm | ✅ |

### Upload Process Flow

```
1. Download Template (Excel/CSV)
        ↓
2. Fill data following format
        ↓
3. Upload file to Admin Panel
        ↓
4. System validates each row
        ↓
5. Show preview with errors highlighted
        ↓
6. Confirm to process valid rows
        ↓
7. Generate report (success/failed)
```

### Bulk Upload Table

```sql
CREATE TABLE bulk_uploads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type VARCHAR(50) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  total_rows INTEGER,
  success_count INTEGER DEFAULT 0,
  error_count INTEGER DEFAULT 0,
  status VARCHAR(20) DEFAULT 'PENDING',
  error_details JSONB,
  uploaded_by UUID REFERENCES users(id),
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🛡️ Security Considerations

### Permission Enforcement

1. **API Level**: Supabase RLS policies check permissions
2. **UI Level**: Hide/disable features based on permissions
3. **Service Level**: Double-check in business logic

### Best Practices

- Never trust client-side permission checks alone
- Always validate at database level with RLS
- Log all permission-related actions
- Regular audit of role-permission assignments

---

## 📚 Related Documents

- [RLS Policies](../04-database/rls-policies.md)
- [Security Architecture](security-architecture.md)
- [User Stories](../02-requirements/user-stories.md)
- [Admin Panel Screen Flows](../05-ui-ux/screen-flows.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Security Documentation.*
