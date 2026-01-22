# 💼 Business Data Tables

## Database Tables - Core Business Data

---

## 📋 Overview

Tabel-tabel transaksi utama untuk data bisnis.

---

## 📊 Tables

### customers
See: [customers.md](customers.md)

### pipelines
See: [pipelines.md](pipelines.md)

### activities
See: [activities.md](activities.md)

### key_persons

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| entity_type | VARCHAR(20) | CUSTOMER/BROKER/HVC |
| entity_id | UUID | Polymorphic FK |
| name | VARCHAR(200) | Person name |
| title | VARCHAR(100) | Job title |
| phone | VARCHAR(20) | Phone |
| email | VARCHAR(100) | Email |
| is_primary | BOOLEAN | Primary contact |

### hvcs (High Value Customers)

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(20) | HVC code |
| name | VARCHAR(200) | HVC name |
| type_id | UUID | FK to hvc_types |
| address | TEXT | Address |
| is_active | BOOLEAN | Status |

### brokers

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(20) | Broker code |
| name | VARCHAR(200) | Broker name |
| broker_type_id | UUID | FK to broker_types |
| license_number | VARCHAR(50) | License |
| is_active | BOOLEAN | Status |

### pipeline_referrals

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| referrer_id | UUID | FK to users |
| receiver_id | UUID | FK to users |
| customer_id | UUID | FK to customers |
| status | VARCHAR(20) | PENDING/ACCEPTED/DECLINED |
| resulting_pipeline_id | UUID | FK to pipelines |

---

*Business Data Tables - January 2025*
