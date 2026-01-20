# 🏢 Customers Table

## Table Documentation

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Table Name** | `customers` |
| **Schema** | `public` |
| **Category** | Business |
| **RLS** | ✅ Enabled |

---

## 📊 Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| code | VARCHAR(20) | NO | Auto-gen | CUS-XXXXX format |
| name | VARCHAR(200) | NO | - | Company name |
| address | TEXT | NO | - | Street address |
| province_id | UUID | NO | - | FK to provinces |
| city_id | UUID | NO | - | FK to cities |
| postal_code | VARCHAR(10) | YES | - | Postal code |
| phone | VARCHAR(20) | YES | - | Phone number |
| email | VARCHAR(100) | YES | - | Email (validated) |
| website | VARCHAR(200) | YES | - | Website URL |
| company_type_id | UUID | NO | - | FK to company_types |
| ownership_type_id | UUID | NO | - | FK to ownership_types |
| industry_id | UUID | NO | - | FK to industries |
| npwp | VARCHAR(30) | YES | - | Tax ID |
| notes | TEXT | YES | - | Notes |
| latitude | DECIMAL(10,7) | YES | - | GPS latitude |
| longitude | DECIMAL(10,7) | YES | - | GPS longitude |
| assigned_to | UUID | NO | - | FK to users |
| is_active | BOOLEAN | NO | true | Status |
| created_at | TIMESTAMPTZ | NO | NOW() | Created |
| updated_at | TIMESTAMPTZ | NO | NOW() | Updated |
| created_by | UUID | YES | - | FK to users |

---

## 🔗 Relationships

### Foreign Keys

| Column | References | On Delete |
|--------|------------|-----------|
| province_id | provinces(id) | RESTRICT |
| city_id | cities(id) | RESTRICT |
| company_type_id | company_types(id) | RESTRICT |
| ownership_type_id | ownership_types(id) | RESTRICT |
| industry_id | industries(id) | RESTRICT |
| assigned_to | users(id) | RESTRICT |

### Referenced By

| Table | Column |
|-------|--------|
| pipelines | customer_id |
| activities | object_id (polymorphic) |
| key_persons | entity_id (polymorphic) |
| customer_hvc_links | customer_id |

---

## 📇 Indexes

| Name | Columns | Type |
|------|---------|------|
| customers_pkey | id | PRIMARY KEY |
| customers_code_key | code | UNIQUE |
| idx_customers_assigned | assigned_to | BTREE |
| idx_customers_name | name | BTREE |
| idx_customers_province | province_id | BTREE |

---

## 🔐 RLS Policies

See [RLS Policies](../rls-policies.md#customer-policies)

---

*Table documentation v1.0*
