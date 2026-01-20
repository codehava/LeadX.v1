# 📅 Activities Table

## Table Documentation

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Table Name** | `activities` |
| **Schema** | `public` |
| **Category** | Business |
| **RLS** | ✅ Enabled |

---

## 📊 Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| object_type | VARCHAR(20) | NO | - | CUSTOMER/PIPELINE/HVC/BROKER |
| object_id | UUID | NO | - | Polymorphic FK |
| activity_type_id | UUID | NO | - | FK to activity_types |
| summary | VARCHAR(255) | YES | - | Short description |
| notes | TEXT | YES | - | Detailed notes |
| scheduled_at | TIMESTAMPTZ | YES | - | Scheduled time |
| executed_at | TIMESTAMPTZ | YES | - | Execution time |
| cancelled_at | TIMESTAMPTZ | YES | - | Cancellation time |
| status | VARCHAR(20) | NO | 'PLANNED' | PLANNED/COMPLETED/CANCELLED/RESCHEDULED |
| is_immediate | BOOLEAN | NO | false | Logged immediately |
| latitude | DECIMAL(10,7) | YES | - | GPS latitude |
| longitude | DECIMAL(10,7) | YES | - | GPS longitude |
| distance_meters | DECIMAL(10,2) | YES | - | Distance from target |
| is_gps_verified | BOOLEAN | YES | - | Within verification radius |
| gps_override_reason | TEXT | YES | - | Reason for override |
| photo_url | TEXT | YES | - | Photo attachment |
| rescheduled_from_id | UUID | YES | - | FK to activities |
| rescheduled_to_id | UUID | YES | - | FK to activities |
| assigned_to | UUID | NO | - | FK to users |
| created_at | TIMESTAMPTZ | NO | NOW() | Created |
| updated_at | TIMESTAMPTZ | NO | NOW() | Updated |

---

## 🔗 Relationships

### Foreign Keys

| Column | References | On Delete |
|--------|------------|-----------|
| activity_type_id | activity_types(id) | RESTRICT |
| assigned_to | users(id) | RESTRICT |
| rescheduled_from_id | activities(id) | SET NULL |
| rescheduled_to_id | activities(id) | SET NULL |

---

## 📇 Indexes

| Name | Columns | Type |
|------|---------|------|
| activities_pkey | id | PRIMARY KEY |
| idx_activities_object | object_type, object_id | BTREE |
| idx_activities_assigned | assigned_to | BTREE |
| idx_activities_scheduled | scheduled_at | BTREE |
| idx_activities_status | status | BTREE |

---

*Table documentation v1.0*
