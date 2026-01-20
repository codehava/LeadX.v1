# 🔗 Entity Relationships

## Detail Relasi Antar Entity LeadX CRM

---

## 📋 Overview

Dokumen ini menjelaskan secara detail hubungan antar entity dalam LeadX CRM, termasuk cardinality, business rules, dan contoh use case.

---

## 👥 User Hierarchy (Flexible Structure)

### Konsep

Struktur hierarki user bersifat **fleksibel** untuk mengakomodasi berbagai tipe cabang:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FLEXIBLE USER HIERARCHY                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SUPERADMIN → ADMIN → ROH → BM → [BH] → RM                                  │
│                                    ↑                                         │
│                                    │                                         │
│                              OPTIONAL                                        │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ TIPE CABANG                                                           │   │
│  ├──────────────────────────────────────────────────────────────────────┤   │
│  │                                                                       │   │
│  │  Type A (Besar):     BM → BH → RM                                    │   │
│  │                       │    │                                          │   │
│  │                       │    ├── RM 1                                   │   │
│  │                       │    ├── RM 2                                   │   │
│  │                       │    └── RM n                                   │   │
│  │                                                                       │   │
│  │  Type B (Hybrid):    BM → BH (beberapa)                              │   │
│  │                       │ → RM (langsung)                               │   │
│  │                       │                                               │   │
│  │                       ├── BH → RM 1, RM 2                            │   │
│  │                       └── RM 3 (direct report)                       │   │
│  │                                                                       │   │
│  │  Type C (Kecil):     BM → RM (langsung)                              │   │
│  │                       │                                               │   │
│  │                       ├── RM 1                                        │   │
│  │                       ├── RM 2                                        │   │
│  │                       └── RM n                                        │   │
│  │                                                                       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Implementation

```sql
-- users table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  role VARCHAR(20) NOT NULL,  -- SUPERADMIN/ADMIN/ROH/BM/BH/RM
  parent_id UUID REFERENCES users(id),  -- Direct supervisor (NULLABLE)
  branch_id UUID REFERENCES branches(id),
  -- ...
);

-- Contoh data:
-- Cabang BESAR (Type A)
INSERT INTO users (id, name, role, parent_id) VALUES
  ('bm-1', 'Budi (BM)', 'BM', 'roh-1'),
  ('bh-1', 'Ani (BH)', 'BH', 'bm-1'),     -- BH lapor ke BM
  ('rm-1', 'Dodi (RM)', 'RM', 'bh-1');    -- RM lapor ke BH

-- Cabang KECIL (Type C) - tanpa BH
INSERT INTO users (id, name, role, parent_id) VALUES
  ('bm-2', 'Siti (BM)', 'BM', 'roh-1'),
  ('rm-2', 'Eko (RM)', 'RM', 'bm-2');     -- RM langsung lapor ke BM
```

### Business Rules

| Rule | Description |
|------|-------------|
| RM harus punya parent | `parent_id` NOT NULL untuk RM |
| Parent harus di level atas | RM → BH/BM, BH → BM, BM → ROH |
| Cabang tanpa BH valid | RM bisa langsung ke BM |

---

## 🏢 HVC → Customer → Pipeline Hierarchy

### Konsep (CORRECTED)

**Hierarchy yang benar:** `HVC → Customer → Pipeline`

- HVC adalah pengelompokan strategis (Kawasan Industri, Banking Group, dll)
- Customer adalah entitas yang berada di dalam/terkait dengan HVC (optional)
- Pipeline adalah prospek bisnis yang dimiliki oleh Customer

**BUKAN:** Customer → HVC → Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CORRECT HIERARCHY: HVC → CUSTOMER → PIPELINE            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                           HVC                                        │    │
│  │  (Kawasan Industri MM2100)                                          │    │
│  │                                                                      │    │
│  │  📍 KEY PERSONS (HVC Level):                                        │    │
│  │     • General Manager Kawasan                                        │    │
│  │     • Marketing Manager                                              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               │ 1 : N (One HVC → Many Customers)            │
│                               │                                              │
│          ┌────────────────────┼────────────────────┐                        │
│          │                    │                    │                        │
│          ▼                    ▼                    ▼                        │
│    ┌───────────┐        ┌───────────┐        ┌───────────┐                 │
│    │ Customer  │        │ Customer  │        │ Customer  │                 │
│    │ A (HVC)   │        │ B (HVC)   │        │ C (HVC)   │                 │
│    │           │        │           │        │           │                 │
│    │ KEY PERS: │        │ KEY PERS: │        │ KEY PERS: │                 │
│    │ • Fin Dir │        │ • CFO     │        │ • GM      │                 │
│    └─────┬─────┘        └─────┬─────┘        └─────┬─────┘                 │
│          │                    │                    │                        │
│          ▼                    ▼                    ▼                        │
│    ┌───────────┐        ┌───────────┐        ┌───────────┐                 │
│    │ Pipelines │        │ Pipelines │        │ Pipelines │                 │
│    │ • Surety  │        │ • CAR     │        │ • Fire    │                 │
│    │ • Marine  │        │           │        │ • Marine  │                 │
│    └───────────┘        └───────────┘        └───────────┘                 │
│                                                                              │
│    ┌───────────┐        ┌───────────┐                                       │
│    │ Customer  │        │ Customer  │    ← Customer TANPA HVC              │
│    │ D         │        │ E         │      (standalone customers)           │
│    │           │        │           │                                       │
│    │ KEY PERS: │        │ KEY PERS: │                                       │
│    │ • Owner   │        │ • Manager │                                       │
│    └─────┬─────┘        └─────┬─────┘                                       │
│          │                    │                                             │
│          ▼                    ▼                                             │
│    ┌───────────┐        ┌───────────┐                                       │
│    │ Pipelines │        │ Pipelines │                                       │
│    └───────────┘        └───────────┘                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Persons Structure

**PENTING:** Key Persons ada di 3 level berbeda:

| Entity | Key Persons | Example |
|--------|-------------|---------|
| **HVC** | Contact person untuk kawasan/group | General Manager Kawasan, Marketing Manager |
| **Customer** | Contact person untuk perusahaan | Finance Director, Procurement Manager |
| **Broker** | Contact person untuk broker | Account Director, Account Executive |

```sql
-- Key Persons table (polymorphic)
CREATE TABLE key_persons (
  id UUID PRIMARY KEY,
  entity_type VARCHAR(20) NOT NULL,  -- 'HVC', 'CUSTOMER', 'BROKER'
  entity_id UUID NOT NULL,            -- FK to respective table
  name VARCHAR(200) NOT NULL,
  position VARCHAR(100),
  department VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(100),
  is_primary BOOLEAN DEFAULT FALSE,
  -- ...
  
  -- Check constraint for valid entity types
  CONSTRAINT valid_entity_type CHECK (entity_type IN ('HVC', 'CUSTOMER', 'BROKER'))
);

-- Index for efficient lookup by entity
CREATE INDEX idx_key_persons_entity ON key_persons(entity_type, entity_id);
```

### Database Implementation

```sql
-- HVC table
CREATE TABLE hvc (
  id UUID PRIMARY KEY,
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  type_id UUID REFERENCES hvc_types(id),
  -- ...
);

-- Customer HVC Links (Many-to-Many, OPTIONAL)
CREATE TABLE customer_hvc_links (
  id UUID PRIMARY KEY,
  customer_id UUID REFERENCES customers(id) NOT NULL,
  hvc_id UUID REFERENCES hvc(id) NOT NULL,
  relationship_type VARCHAR(50) NOT NULL,  -- TENANT, SUBSIDIARY, MEMBER, etc.
  is_active BOOLEAN DEFAULT TRUE,
  
  UNIQUE(customer_id, hvc_id)  -- 1 customer hanya 1 link ke 1 HVC
);

-- Contoh data:
-- HVC: Kawasan Industri MM2100
INSERT INTO hvc (id, code, name) VALUES 
  ('hvc-1', 'HVC-MM2100', 'Kawasan Industri MM2100');

-- Customer yang ADA di HVC
INSERT INTO customers (id, name) VALUES 
  ('cust-1', 'PT Astra Otoparts');
INSERT INTO customer_hvc_links (customer_id, hvc_id, relationship_type) VALUES
  ('cust-1', 'hvc-1', 'TENANT');

-- Customer yang TIDAK di HVC (standalone)
INSERT INTO customers (id, name) VALUES 
  ('cust-2', 'PT ABC Mandiri');  -- Tidak ada entry di customer_hvc_links
```

### Business Rules

| Rule | Description |
|------|-------------|
| HVC itu optional | Customer tidak harus punya HVC |
| 1 Customer bisa di multiple HVC | Rare, tapi possible (via customer_hvc_links) |
| Relationship type wajib | Jika di-link, harus specify hubungan |

### Use Cases

| Scenario | Description |
|----------|-------------|
| **View HVC Customers** | Tampilkan semua customer yang linked ke HVC tertentu |
| **Standalone Customers** | Customer yang tidak linked ke HVC manapun |
| **HVC Activity Tracking** | Track aktivitas RM di customer dalam 1 HVC |

---

## 👤 Customer → Pipeline Relationship

### Konsep

**1 Customer bisa memiliki banyak Pipeline**. Pipeline adalah prospek bisnis, bukan customer itu sendiri.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CUSTOMER - PIPELINE RELATIONSHIP                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│    ┌───────────────────────────────────────────────────────────────────┐    │
│    │                         CUSTOMER                                   │    │
│    │                    PT Bank Mandiri                                │    │
│    └───────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               │ 1 : N (One Customer → Many Pipelines)       │
│                               │                                              │
│          ┌────────────────────┼────────────────────┐                        │
│          │                    │                    │                        │
│          ▼                    ▼                    ▼                        │
│    ┌───────────┐        ┌───────────┐        ┌───────────┐                 │
│    │ Pipeline  │        │ Pipeline  │        │ Pipeline  │                 │
│    │ Surety    │        │ CAR       │        │ Fire      │                 │
│    │ Bond      │        │ Insurance │        │ Insurance │                 │
│    │ (P1-HOT)  │        │ (NEW)     │        │ (WON)     │                 │
│    └───────────┘        └───────────┘        └───────────┘                 │
│                                                                              │
│    Note: 1 customer bisa punya multiple produk/pipeline berbeda             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Business Rules

| Rule | Description |
|------|-------------|
| Customer wajib | Pipeline harus punya customer_id |
| Multiple pipelines OK | 1 customer bisa punya banyak pipeline berbeda COB |
| Stage independent | Tiap pipeline punya stage sendiri |

---

## 🤝 Broker → Pipeline Relationship

### Konsep

**Broker adalah SUMBER LEAD**, bukan entity terpisah yang punya pipeline. Pipeline yang berasal dari broker ditandai dengan `lead_source = 'BROKER'` dan memiliki `broker_id`.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      BROKER - PIPELINE RELATIONSHIP                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Lead Sources:                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐                    │
│  │ DIRECT   │  │ BROKER   │  │ REFERRAL │  │ EVENT    │                    │
│  └──────────┘  └────┬─────┘  └──────────┘  └──────────┘                    │
│                     │                                                        │
│                     │ lead_source = 'BROKER'                                │
│                     │                                                        │
│                     ▼                                                        │
│    ┌────────────────────────────────────────────────────────────────────┐   │
│    │                           BROKER                                    │   │
│    │                    (PT Marsh Indonesia)                            │   │
│    └────────────────────────────────────────────────────────────────────┘   │
│                               │                                              │
│                               │ 1 : N (Broker sources many Pipelines)       │
│                               │                                              │
│          ┌────────────────────┼────────────────────┐                        │
│          │                    │                    │                        │
│          ▼                    ▼                    ▼                        │
│    ┌───────────┐        ┌───────────┐        ┌───────────┐                 │
│    │ Pipeline  │        │ Pipeline  │        │ Pipeline  │                 │
│    │ PIP-001   │        │ PIP-002   │        │ PIP-003   │                 │
│    │ Customer: │        │ Customer: │        │ Customer: │                 │
│    │ PT ABC    │        │ PT XYZ    │        │ PT 123    │                 │
│    └───────────┘        └───────────┘        └───────────┘                 │
│                                                                              │
│    Note: Broker mereferensikan pipeline, bukan memiliki customer            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Implementation

```sql
-- Pipeline with Broker reference
CREATE TABLE pipelines (
  id UUID PRIMARY KEY,
  customer_id UUID REFERENCES customers(id) NOT NULL,  -- Always required
  lead_source_id UUID REFERENCES lead_sources(id) NOT NULL,
  broker_id UUID REFERENCES brokers(id),  -- ONLY if lead_source = BROKER
  broker_pic_id UUID REFERENCES key_persons(id),  -- Broker contact
  -- ...
  
  -- Constraint: broker_id only allowed when lead_source is BROKER
  CONSTRAINT check_broker_source CHECK (
    (lead_source_id IN (SELECT id FROM lead_sources WHERE code = 'BROKER') AND broker_id IS NOT NULL)
    OR
    (lead_source_id NOT IN (SELECT id FROM lead_sources WHERE code = 'BROKER') AND broker_id IS NULL)
  )
);

-- Contoh data:
-- Pipeline dari DIRECT (tanpa broker)
INSERT INTO pipelines (id, customer_id, lead_source_id, broker_id) VALUES
  ('pip-1', 'cust-1', 'src-direct', NULL);

-- Pipeline dari BROKER
INSERT INTO pipelines (id, customer_id, lead_source_id, broker_id) VALUES
  ('pip-2', 'cust-2', 'src-broker', 'broker-1');
```

### Business Rules

| Rule | Description |
|------|-------------|
| Broker = Lead Source | Broker menghasilkan pipeline, bukan memiliki |
| broker_id conditional | Hanya diisi jika lead_source = BROKER |
| Customer tetap wajib | Pipeline tetap milik customer |
| Broker bisa multiple PIC | Key persons untuk tiap broker |

### Use Cases

| Scenario | Description |
|----------|-------------|
| **Track Broker Performance** | Hitung berapa pipeline dari broker X yang WON |
| **Commission Calculation** | Identifikasi pipeline broker untuk komisi |
| **Broker Relationship** | RM bisa visit broker untuk cari lead baru |

---

## 🔄 Pipeline Referral Relationship

### Konsep

**Pipeline Referral** adalah mekanisme untuk meneruskan prospek ke RM lain (biasanya di cabang/territory berbeda).

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PIPELINE REFERRAL WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────┐         ┌───────────────┐         ┌───────────────┐      │
│  │   REFERRER    │ ──────▶ │   RECEIVER    │ ──────▶ │   RECEIVER    │      │
│  │    RM (A)     │ creates │    RM (B)     │ accepts │    BM         │      │
│  └───────────────┘         └───────────────┘         └───────┬───────┘      │
│         │                         │                          │ approves     │
│         │                         │                          ▼              │
│         │                         │                  ┌───────────────┐      │
│         │                         │                  │   PIPELINE    │      │
│         │                         │                  │   (Created)   │      │
│         │                         │                  └───────┬───────┘      │
│         │                         │                          │ WON          │
│         │                         │                          ▼              │
│         │                         │                  ┌───────────────┐      │
│         └─────────────────────────┴───────────────── │ REFERRAL      │      │
│                                   bonus              │ BONUS (10%)   │      │
│                                                      └───────────────┘      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Implementation

```sql
-- Pipeline Referrals table
CREATE TABLE pipeline_referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Source info
  referrer_id UUID NOT NULL REFERENCES users(id),        -- RM yang mereferensikan
  customer_id UUID NOT NULL REFERENCES customers(id),    -- Customer yang di-refer
  cob_id UUID REFERENCES cob(id),
  lob_id UUID REFERENCES lob(id),
  estimated_premium DECIMAL(15,2),
  reason TEXT NOT NULL,                                  -- Alasan referral
  
  -- Target info
  receiver_id UUID NOT NULL REFERENCES users(id),        -- RM penerima
  receiver_branch_id UUID REFERENCES branches(id),
  
  -- Workflow status
  status VARCHAR(20) DEFAULT 'PENDING',  -- PENDING, ACCEPTED, REJECTED, APPROVED, DECLINED, COMPLETED
  
  -- Receiver response
  receiver_response_at TIMESTAMPTZ,
  receiver_notes TEXT,
  
  -- BM approval
  approver_id UUID REFERENCES users(id),                 -- BM yang approve
  approved_at TIMESTAMPTZ,
  approval_notes TEXT,
  rejection_reason TEXT,
  
  -- Result
  resulting_pipeline_id UUID REFERENCES pipelines(id),   -- Pipeline yang dibuat
  bonus_applied BOOLEAN DEFAULT FALSE,
  bonus_amount DECIMAL(15,2),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_referrals_referrer ON pipeline_referrals(referrer_id);
CREATE INDEX idx_referrals_receiver ON pipeline_referrals(receiver_id);
CREATE INDEX idx_referrals_status ON pipeline_referrals(status);
```

### Business Rules

| Rule | Description |
|------|-------------|
| Referrer ≠ Receiver | Tidak bisa refer ke diri sendiri |
| Customer must be owned | Hanya bisa refer customer yang di-own |
| BM approval required | Referral yang di-accept perlu approval BM receiver |
| Bonus on WON | Referrer mendapat bonus saat pipeline WON |

---

## 🔐 Role & Permission Relationship

### Konsep

**Role-Based Access Control (RBAC)** dengan permission granular per resource dan action.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ROLE - PERMISSION - USER RELATIONSHIP                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                           PERMISSIONS                                │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │    │
│  │  │customer: │  │pipeline: │  │activity: │  │ report:  │            │    │
│  │  │ create   │  │ create   │  │ create   │  │ view     │            │    │
│  │  │ read     │  │ read     │  │ read     │  │ export   │            │    │
│  │  │ update   │  │ update   │  │ update   │  │          │            │    │
│  │  │ delete   │  │ delete   │  │ delete   │  │          │            │    │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │    │
│  └───────┼─────────────┼─────────────┼─────────────┼───────────────────┘    │
│          │             │             │             │                        │
│          └─────────────┴──────┬──────┴─────────────┘                        │
│                               │  assigned to                                │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                            ROLES                                     │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │    │
│  │  │    RM    │  │    BH    │  │    BM    │  │  ADMIN   │            │    │
│  │  │ (system) │  │ (system) │  │ (system) │  │ (system) │            │    │
│  │  │          │  │          │  │          │  │          │            │    │
│  │  │ scope:   │  │ scope:   │  │ scope:   │  │ scope:   │            │    │
│  │  │ OWN      │  │ TEAM     │  │ BRANCH   │  │ ALL      │            │    │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │    │
│  └───────┼─────────────┼─────────────┼─────────────┼───────────────────┘    │
│          │             │             │             │                        │
│          └─────────────┴──────┬──────┴─────────────┘                        │
│                               │  assigned to                                │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                            USERS                                     │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │    │
│  │  │  Budi    │  │  Ani     │  │  Doni    │  │  Admin   │            │    │
│  │  │ role: RM │  │ role: BH │  │ role: BM │  │role:Admin│            │    │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Implementation

```sql
-- Roles table
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,         -- RM, BH, BM, ADMIN, CUSTOM_1
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,          -- System roles cannot be deleted
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permissions table
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(100) UNIQUE NOT NULL,        -- customer:create, pipeline:read
  resource VARCHAR(50) NOT NULL,            -- customer, pipeline, activity
  action VARCHAR(20) NOT NULL,              -- create, read, update, delete
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE
);

-- Role-Permission mapping (many-to-many)
CREATE TABLE role_permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role_id UUID NOT NULL REFERENCES roles(id),
  permission_id UUID NOT NULL REFERENCES permissions(id),
  scope VARCHAR(20) DEFAULT 'OWN',          -- OWN, TEAM, BRANCH, REGIONAL, ALL
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(role_id, permission_id)
);

-- User role assignment
ALTER TABLE users ADD COLUMN role_id UUID REFERENCES roles(id);

-- Indexes
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_users_role ON users(role_id);
```

### Business Rules

| Rule | Description |
|------|-------------|
| System roles immutable | RM, BH, BM, ROH, ADMIN, SUPERADMIN tidak bisa diedit/hapus |
| Scope inheritance | BRANCH includes TEAM, TEAM includes OWN |
| Permission caching | Permissions di-cache per session (5 min TTL) |

---

## 📝 Activity Audit Logs Relationship

### Konsep

**Activity Audit Logs** mencatat semua perubahan penting untuk traceability.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AUDIT LOG RELATIONSHIP                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ANY ENTITY (Customer, Pipeline, Activity, etc.)                            │
│        │                                                                     │
│        │ CREATE / UPDATE / DELETE                                           │
│        ▼                                                                     │
│  ┌───────────────────────────────────────────────────────────────────┐      │
│  │                    ACTIVITY_AUDIT_LOGS                             │      │
│  │                                                                    │      │
│  │  id | entity_type | entity_id | action | old_values | new_values │      │
│  │  ---|-------------|-----------|--------|------------|----------- │      │
│  │  1  | customer    | cust-123  | UPDATE | {name:A}   | {name:B}   │      │
│  │  2  | pipeline    | pip-456   | UPDATE | {stage:P3} | {stage:P2} │      │
│  │  3  | activity    | act-789   | CREATE | null       | {type:..}  │      │
│  └───────────────────────────────────────────────────────────────────┘      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Implementation

```sql
-- Activity Audit Logs table
CREATE TABLE activity_audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Entity reference (polymorphic)
  entity_type VARCHAR(50) NOT NULL,         -- customer, pipeline, activity, etc.
  entity_id UUID NOT NULL,
  
  -- Action
  action VARCHAR(20) NOT NULL,              -- CREATE, UPDATE, DELETE, STAGE_CHANGE
  
  -- Change details
  old_values JSONB,                         -- Previous state (null for CREATE)
  new_values JSONB,                         -- New state (null for DELETE)
  changed_fields TEXT[],                    -- Array of field names that changed
  
  -- Actor
  user_id UUID REFERENCES users(id),
  user_name VARCHAR(200),                   -- Denormalized for performance
  
  -- Context
  ip_address INET,
  user_agent TEXT,
  
  -- Timestamp
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for efficient queries
CREATE INDEX idx_audit_entity ON activity_audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_user ON activity_audit_logs(user_id);
CREATE INDEX idx_audit_created ON activity_audit_logs(created_at);
CREATE INDEX idx_audit_action ON activity_audit_logs(action);
```

### Business Rules

| Rule | Description |
|------|-------------|
| Immutable | Audit logs tidak bisa diedit atau dihapus |
| Performance | Menggunakan JSONB untuk flexibility query |
| Retention | Data disimpan 2 tahun (configurable) |

---

## 📊 Summary: Complete Entity Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COMPLETE ENTITY RELATIONSHIPS                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ORGANIZATION                                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ Regional Office → Branch → User (flexible hierarchy)                │    │
│  │                                    ↓                                 │    │
│  │                            BM → [BH] → RM                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                       │                                      │
│                                       │ owns                                 │
│                                       ▼                                      │
│  BUSINESS DATA                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                                                                      │    │
│  │  ┌─────────────────────────────────────────────────────┐            │    │
│  │  │                     CUSTOMER                         │            │    │
│  │  │  (assigned to RM, optional HVC link)                │            │    │
│  │  └──────────────────────┬──────────────────────────────┘            │    │
│  │                         │                                            │    │
│  │            ┌────────────┼────────────┐                              │    │
│  │            │            │            │                              │    │
│  │            ▼            ▼            ▼                              │    │
│  │      ┌──────────┐  ┌──────────┐  ┌──────────┐                      │    │
│  │      │PIPELINE 1│  │PIPELINE 2│  │PIPELINE n│                      │    │
│  │      │          │  │          │  │          │                      │    │
│  │      │ COB: X   │  │ COB: Y   │  │ COB: Z   │                      │    │
│  │      │ Source:  │  │ Source:  │  │ Source:  │                      │    │
│  │      │ DIRECT   │  │ BROKER   │  │ REFERRAL │                      │    │
│  │      └──────────┘  └────┬─────┘  └──────────┘                      │    │
│  │                         │                                            │    │
│  │                         │ if lead_source = BROKER                   │    │
│  │                         ▼                                            │    │
│  │                   ┌──────────┐                                      │    │
│  │                   │ BROKER   │                                      │    │
│  │                   └──────────┘                                      │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  HVC (OPTIONAL GROUPING)                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  ┌─────────────┐                                                    │    │
│  │  │    HVC      │ ←──── Groups customers strategically               │    │
│  │  │ (optional)  │       Not all customers belong to HVC              │    │
│  │  └──────┬──────┘                                                    │    │
│  │         │                                                            │    │
│  │         │ many-to-many (via customer_hvc_links)                     │    │
│  │         │                                                            │    │
│  │    ┌────┴────┬────────────┐                                         │    │
│  │    ▼         ▼            ▼                                         │    │
│  │ Customer  Customer    Customer                                      │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Related Documents

- [Schema Overview](schema-overview.md) - Database tables
- [RLS Policies](rls-policies.md) - Access control
- [Functional Requirements](../02-requirements/functional-requirements.md) - Business rules

---

*Entity relationships version 1.0 - January 2025*
