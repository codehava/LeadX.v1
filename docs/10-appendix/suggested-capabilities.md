# 🚀 Suggested Capabilities

## Fitur-fitur Potensial untuk Pengembangan LeadX CRM

Dokumen ini berisi rekomendasi fitur baru berdasarkan analisis kebutuhan dan best practices industri.

---

## 📋 Capability Roadmap

| Priority | Capability | Target Sprint |
|----------|------------|---------------|
| P1 | Duplicate Detection | Sprint 13 |
| P1 | Document Attachment | Sprint 13 |
| P2 | Customer Handover | Sprint 14 |
| P2 | Activity Delegation | Sprint 14 |
| P2 | Pipeline Forecasting | Sprint 15 |
| P2 | Smart Routing | Sprint 15 |
| P2 | Integration Hub | Sprint 16 |

---

## 🔍 CAP-001: Duplicate Detection

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P1 |
| **Effort** | Medium |
| **Dependencies** | Customer Module |

### Description

Sistem untuk mendeteksi dan mengelola customer duplikat berdasarkan nama, NPWP, atau informasi kontak yang mirip.

### Features

1. **Detection on Create**
   - Cek similarity saat input customer baru
   - Warning jika ada kemungkinan duplikat
   - Show existing matches

2. **Batch Deduplication**
   - Admin tool untuk scan seluruh customer
   - Similarity threshold configurable
   - Merge workflow dengan approval

3. **Merge Capability**
   - Pilih master record
   - Merge pipelines dan activities
   - Audit trail

### Technical Approach

```sql
-- Similarity function
CREATE OR REPLACE FUNCTION customer_similarity(name1 TEXT, name2 TEXT)
RETURNS NUMERIC AS $$
BEGIN
  RETURN similarity(LOWER(name1), LOWER(name2));
END;
$$ LANGUAGE plpgsql;

-- Duplicate candidates query
SELECT c1.id, c2.id, customer_similarity(c1.name, c2.name) as score
FROM customers c1
CROSS JOIN customers c2
WHERE c1.id < c2.id
  AND customer_similarity(c1.name, c2.name) > 0.8;
```

---

## 📎 CAP-002: Document Attachment

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P1 |
| **Effort** | Medium |
| **Dependencies** | Pipeline Module, Supabase Storage |

### Description

Kemampuan melampirkan dokumen (proposal, kontrak, dsb) ke pipeline atau customer.

### Features

1. **Upload Documents**
   - Support: PDF, DOC, DOCX, XLS, XLSX, JPG, PNG
   - Max size: 10MB per file
   - Max files per pipeline: 20

2. **Document Categories**
   - Proposal
   - Quotation
   - Contract
   - Supporting Documents
   - Correspondence

3. **View & Download**
   - Preview (PDF, images)
   - Download
   - Version history

### Data Model

```sql
CREATE TABLE pipeline_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pipeline_id UUID NOT NULL REFERENCES pipelines(id),
  category VARCHAR(50) NOT NULL,
  filename VARCHAR(255) NOT NULL,
  file_path TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  uploaded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔄 CAP-003: Customer Handover

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P2 |
| **Effort** | Medium |
| **Dependencies** | Customer Module, Role Management |

### Description

Transfer ownership customer ke RM lain dengan approval workflow, biasanya saat RM resign atau mutasi.

### Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CUSTOMER HANDOVER WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  BM/Admin ────▶ Initiate Handover ────▶ Select Customers ────▶ Select       │
│       │                                                     New RM    │     │
│       │                                                        │            │
│       │                                                        ▼            │
│       │                                              ┌──────────────┐       │
│       │                                              │   Preview    │       │
│       │                                              │  (Customers, │       │
│       │                                              │   Pipelines, │       │
│       │                                              │  Activities) │       │
│       │                                              └──────┬───────┘       │
│       │                                                     │               │
│       │                                                     ▼               │
│       └─────────────────────────────────────────▶   Execute Handover        │
│                                                             │               │
│                                                             ▼               │
│                                                    Notify Both RMs          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Business Rules

- Handover includes: customers + related pipelines + related activities
- Old RM loses access immediately
- Audit trail maintained

---

## 📋 CAP-004: Activity Delegation

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P2 |
| **Effort** | Low |
| **Dependencies** | Activity Module |

### Description

RM atau BH dapat mendelegasikan aktivitas ke subordinate dengan tracking status.

### Features

1. **Delegate Activity**
   - Select subordinate
   - Add delegation notes
   - Set priority

2. **Track Delegated**
   - View delegated activities
   - Monitor completion
   - Receive notification on complete

3. **Accept Delegation**
   - Subordinate sees incoming delegations
   - Can accept or request reassign

---

## 📈 CAP-005: Pipeline Forecasting

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P2 |
| **Effort** | High |
| **Dependencies** | Pipeline Module, Historical Data |

### Description

AI-based probability prediction untuk pipeline berdasarkan historical data dan activity pattern.

### Features

1. **Win Probability**
   - ML model trained on historical wins/losses
   - Features: activity count, stage duration, customer segment
   - Weekly recalculation

2. **Close Date Prediction**
   - Estimate realistic close date
   - Based on similar pipeline patterns

3. **Risk Indicators**
   - Flag pipelines at risk of stalling
   - Suggest actions

### Algorithm Approach

```python
# Features for prediction
features = [
  'activity_count',
  'days_in_current_stage',
  'customer_segment',
  'cob_category',
  'premium_amount',
  'previous_stage_duration',
  'contact_frequency'
]

# Model: Gradient Boosting / XGBoost
# Output: probability (0-100%)
```

---

## 🗺️ CAP-006: Smart Routing

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P2 |
| **Effort** | High |
| **Dependencies** | Activity Module, Maps API |

### Description

Optimisasi rute kunjungan berdasarkan lokasi customer dan jadwal aktivitas.

### Features

1. **Daily Route Optimization**
   - Input: scheduled activities for today
   - Output: optimal visit sequence
   - Consider: traffic, distance, customer priority

2. **Map Visualization**
   - Show customers on map
   - Color by priority/activity status
   - Cluster nearby customers

3. **Turn-by-turn Navigation**
   - Integration with Google Maps/Waze
   - One-tap navigate

---

## 🔌 CAP-007: Integration Hub

### Overview

| Attribute | Value |
|-----------|-------|
| **Priority** | P2 |
| **Effort** | High |
| **Dependencies** | API Gateway |

### Description

Platform untuk integrasi dengan sistem eksternal (ERP, Policy Admin, etc).

### Potential Integrations

| System | Type | Data Flow |
|--------|------|-----------|
| Policy Admin System | Bidirectional | Pipeline → Policy |
| Finance/ERP | Outbound | Premium data |
| Email Service | Outbound | Notifications |
| WhatsApp Business | Bidirectional | Customer communication |
| Calendar | Bidirectional | Activities sync |

---

## 📚 Related Documents

- [Feature Specs](../06-features/README.md)
- [Functional Requirements](../02-requirements/functional-requirements.md)
- [Sprint Planning](../09-implementation/sprint-planning.md)

---

*Suggested Capabilities - January 2025*
