# 👤 Users Table

## Table Documentation

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Table Name** | `users` |
| **Schema** | `public` |
| **Category** | Organization |
| **RLS** | ✅ Enabled |

---

## 📊 Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| email | VARCHAR(255) | NO | - | Unique email |
| name | VARCHAR(200) | NO | - | Full name |
| role | VARCHAR(20) | NO | - | RM/BH/BM/ROH/ADMIN |
| role_id | UUID | YES | - | FK to roles |
| parent_id | UUID | YES | - | FK to users (supervisor) |
| branch_id | UUID | YES | - | FK to branches |
| regional_id | UUID | YES | - | FK to regional_offices |
| phone | VARCHAR(20) | YES | - | Phone number |
| avatar_url | TEXT | YES | - | Profile image URL |
| is_active | BOOLEAN | NO | true | Account status |
| last_login_at | TIMESTAMPTZ | YES | - | Last login timestamp |
| created_at | TIMESTAMPTZ | NO | NOW() | Created timestamp |
| updated_at | TIMESTAMPTZ | NO | NOW() | Updated timestamp |

---

## 🔗 Relationships

### Foreign Keys

| Column | References | On Delete |
|--------|------------|-----------|
| parent_id | users(id) | SET NULL |
| branch_id | branches(id) | SET NULL |
| regional_id | regional_offices(id) | SET NULL |
| role_id | roles(id) | SET NULL |

### Referenced By

| Table | Column |
|-------|--------|
| customers | assigned_to |
| pipelines | assigned_to |
| activities | assigned_to |
| wigs | owner_id |
| cadence_submissions | user_id |

---

## 📇 Indexes

| Name | Columns | Type |
|------|---------|------|
| users_pkey | id | PRIMARY KEY |
| users_email_key | email | UNIQUE |
| idx_users_role | role | BTREE |
| idx_users_parent | parent_id | BTREE |
| idx_users_branch | branch_id | BTREE |

---

## 🔐 RLS Policies

| Policy | Command | Using | With Check |
|--------|---------|-------|------------|
| users_select | SELECT | Based on hierarchy | - |
| users_update | UPDATE | Self or subordinates | - |

---

*Table documentation v1.0*
