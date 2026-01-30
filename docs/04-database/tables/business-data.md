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

Transfer nasabah antar RM dengan approval workflow. Seluruh nasabah (termasuk semua pipeline) ditransfer, bukan per-produk.

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | UUID | NO | Primary key |
| code | VARCHAR(20) | NO | Unique code (REF-YYYYMMDD-XXX) |
| customer_id | UUID | NO | FK to customers |
| referrer_rm_id | UUID | NO | RM yang mereferral |
| receiver_rm_id | UUID | NO | RM tujuan |
| referrer_branch_id | UUID | YES | Branch referrer (nullable untuk kanwil) |
| receiver_branch_id | UUID | YES | Branch receiver (nullable untuk kanwil) |
| referrer_regional_office_id | UUID | YES | Kanwil referrer |
| receiver_regional_office_id | UUID | YES | Kanwil receiver |
| approver_type | VARCHAR(10) | NO | 'BM' atau 'ROH' |
| reason | TEXT | NO | Alasan referral |
| notes | TEXT | YES | Catatan tambahan |
| status | VARCHAR(30) | NO | Status workflow |
| receiver_accepted_at | TIMESTAMPTZ | YES | Waktu receiver accept |
| receiver_rejected_at | TIMESTAMPTZ | YES | Waktu receiver reject |
| receiver_reject_reason | TEXT | YES | Alasan penolakan receiver |
| receiver_notes | TEXT | YES | Catatan dari receiver |
| bm_approved_at | TIMESTAMPTZ | YES | Waktu manager approve |
| bm_approved_by | UUID | YES | FK to users (approver) |
| bm_rejected_at | TIMESTAMPTZ | YES | Waktu manager reject |
| bm_reject_reason | TEXT | YES | Alasan penolakan manager |
| bm_notes | TEXT | YES | Catatan dari manager |
| bonus_calculated | BOOLEAN | NO | Bonus sudah dihitung? |
| bonus_amount | DECIMAL(18,2) | YES | Jumlah bonus |
| expires_at | TIMESTAMPTZ | YES | Waktu kadaluarsa |
| cancelled_at | TIMESTAMPTZ | YES | Waktu dibatalkan |
| cancel_reason | TEXT | YES | Alasan pembatalan |
| created_at | TIMESTAMPTZ | YES | Waktu dibuat |
| updated_at | TIMESTAMPTZ | YES | Waktu update terakhir |

**Status Flow:**
```
PENDING_RECEIVER → RECEIVER_ACCEPTED → BM_APPROVED → COMPLETED
                 ↘ RECEIVER_REJECTED (END)
                                     ↘ BM_REJECTED (END)
                 ↘ CANCELLED (END)
```

See: [Pipeline Referral System](../../03-architecture/pipeline-referral-system.md)

---

*Business Data Tables - January 2026*
