# 📊 Pipelines Table

## Table Documentation

---

## 📋 Overview

| Attribute | Value |
|-----------|-------|
| **Table Name** | `pipelines` |
| **Schema** | `public` |
| **Category** | Business |
| **RLS** | ✅ Enabled |

---

## 📊 Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| code | VARCHAR(20) | NO | Auto-gen | PIP-XXXXX format |
| customer_id | UUID | NO | - | FK to customers |
| cob_id | UUID | NO | - | FK to cob |
| lob_id | UUID | NO | - | FK to lob |
| lead_source_id | UUID | NO | - | FK to lead_sources |
| broker_id | UUID | YES | - | FK to brokers (if source=BROKER) |
| broker_pic_id | UUID | YES | - | FK to key_persons |
| customer_contact_id | UUID | YES | - | FK to key_persons |
| tsi | DECIMAL(18,2) | YES | - | Total Sum Insured |
| potential_premium | DECIMAL(15,2) | NO | - | Expected premium |
| stage | VARCHAR(20) | NO | 'NEW' | Current stage |
| status_id | UUID | YES | - | FK to pipeline_statuses |
| probability | DECIMAL(5,2) | NO | 10 | Stage probability |
| weighted_value | DECIMAL(15,2) | NO | Calculated | Premium × Probability |
| is_tender | BOOLEAN | NO | false | Is tender process |
| expected_close_date | DATE | YES | - | Expected close |
| closed_at | TIMESTAMPTZ | YES | - | When won/lost |
| notes | TEXT | YES | - | Notes |
| assigned_to | UUID | NO | - | FK to users |
| referral_id | UUID | YES | - | FK to pipeline_referrals |
| created_at | TIMESTAMPTZ | NO | NOW() | Created |
| updated_at | TIMESTAMPTZ | NO | NOW() | Updated |

---

## 🔗 Relationships

### Foreign Keys

| Column | References | On Delete |
|--------|------------|-----------|
| customer_id | customers(id) | RESTRICT |
| cob_id | cob(id) | RESTRICT |
| lob_id | lob(id) | RESTRICT |
| lead_source_id | lead_sources(id) | RESTRICT |
| broker_id | brokers(id) | SET NULL |
| assigned_to | users(id) | RESTRICT |

### Referenced By

| Table | Column |
|-------|--------|
| activities | object_id (polymorphic) |
| pipeline_stage_history | pipeline_id |
| pipeline_referrals | resulting_pipeline_id |

---

## 📇 Indexes

| Name | Columns | Type |
|------|---------|------|
| pipelines_pkey | id | PRIMARY KEY |
| pipelines_code_key | code | UNIQUE |
| idx_pipelines_customer | customer_id | BTREE |
| idx_pipelines_stage | stage | BTREE |
| idx_pipelines_assigned | assigned_to | BTREE |

---

*Table documentation v1.0*
