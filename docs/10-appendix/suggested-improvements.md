# 🔄 Suggested Flow Improvements

## Rekomendasi Perbaikan Flow LeadX CRM

Dokumen ini berisi rekomendasi improvement untuk flow yang sudah ada.

---

## 📋 Overview

| Flow | Current Status | Improvement Status |
|------|----------------|-------------------|
| Pipeline Referral | Implemented | Enhancement suggested |
| Activity Verification | Implemented | Enhancement suggested |
| Territory Assignment | Not implemented | New capability |
| Pipeline Stage Gate | Manual | Automation suggested |

---

## 🔄 IMP-001: Pipeline Referral Enhancement

### Current Flow

```
Referrer RM ──▶ Receiver RM ──▶ Receiver BM ──▶ Pipeline Created
```

Linear approval dari satu pihak ke pihak lain.

### Issue

- Referrer BM tidak terinformasi
- Potensi konflik jika kedua cabang merasa berhak

### Suggested Enhancement

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  ENHANCED REFERRAL WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Referrer RM ────────────────▶ Receiver RM                                  │
│       │                             │                                        │
│       │                             ▼                                        │
│       │                     ┌───────────────┐                               │
│       │                     │ Accept/Reject │                               │
│       │                     └───────┬───────┘                               │
│       │                             │ Accept                                 │
│       ▼                             ▼                                        │
│  ┌─────────────┐           ┌───────────────┐                                │
│  │ Referrer BM │◀── FYI ───│  Receiver BM  │                                │
│  │  (Notified) │           │   (Approver)  │                                │
│  └─────────────┘           └───────┬───────┘                                │
│                                    │ Approve                                 │
│                                    ▼                                        │
│                            Pipeline Created                                  │
│                                    │                                        │
│                     ┌──────────────┴──────────────┐                         │
│                     ▼                             ▼                         │
│               Receiver RM                   Referrer RM                      │
│              (Pipeline Owner)               (Bonus Eligible)                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementation Changes

```sql
-- Add referrer_bm_id to track notification
ALTER TABLE pipeline_referrals 
ADD COLUMN referrer_bm_id UUID REFERENCES users(id);

-- Add notification flag
ALTER TABLE pipeline_referrals 
ADD COLUMN referrer_bm_notified_at TIMESTAMPTZ;
```

---

## 📍 IMP-002: Activity Verification Enhancement

### Current Flow

- GPS verification only
- Distance threshold: 500m
- Override with reason

### Issue

- GPS dapat dimanipulasi
- Sulit membuktikan meeting benar-benar terjadi

### Suggested Enhancement

**Tier-based verification untuk High-Value Visits:**

| Customer Type | GPS Required | Photo Required | Signature |
|---------------|--------------|----------------|-----------|
| Regular | ✅ Yes | Optional | No |
| HVC | ✅ Yes | ✅ Yes | Optional |
| Strategic | ✅ Yes | ✅ Yes | ✅ Yes |

### Photo Verification Features

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PHOTO VERIFICATION SCREEN                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📸 Take Photo                                                               │
│  ─────────────────────────────────────────────────────────────────────      │
│                                                                              │
│  Requirements:                                                               │
│  ✅ GPS coordinates embedded in EXIF                                        │
│  ✅ Timestamp embedded                                                       │
│  ⚪ Face detection (optional)                                               │
│  ⚪ Object recognition (meeting room, office)                               │
│                                                                              │
│  [📷 Capture Photo]                                                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Signature Capture (Optional)

- Digital signature on screen
- Dengan nama dan jabatan
- Tersimpan sebagai image

---

## 🗺️ IMP-003: Territory Assignment

### Current State

- Tidak ada batasan geografis per RM
- Referral manual berdasarkan knowledge
- Overlap territory sering terjadi

### Suggested Improvement

**Geographic Territory Management:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TERRITORY MANAGEMENT                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Territory Definition:                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  RM: Budi Santoso                                                    │    │
│  │  Territory: Jakarta Selatan                                          │    │
│  │  └── Kecamatan: Kebayoran Baru, Mampang, Setiabudi                  │    │
│  │  └── Total area: 35 km²                                              │    │
│  │  └── Customers in territory: 45                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  Features:                                                                   │
│  • Map-based territory drawing                                              │
│  • Auto-assign new customers to RM based on location                        │
│  • Auto-suggest referral if customer outside territory                      │
│  • Territory overlap warning                                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Model

```sql
CREATE TABLE territories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  assigned_to UUID NOT NULL REFERENCES users(id),
  boundary GEOGRAPHY(POLYGON, 4326),  -- PostGIS polygon
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Check if customer is in RM's territory
CREATE OR REPLACE FUNCTION customer_in_territory(
  customer_lat DECIMAL,
  customer_lng DECIMAL,
  rm_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM territories t
    WHERE t.assigned_to = rm_id
      AND t.is_active = true
      AND ST_Contains(t.boundary, ST_SetSRID(ST_MakePoint(customer_lng, customer_lat), 4326))
  );
END;
$$ LANGUAGE plpgsql;
```

---

## 🚀 IMP-004: Pipeline Stage Gate Automation

### Current State

- Stage progression 100% manual
- Tidak ada guideline kapan harus move
- Stagnan pipeline tidak terdeteksi

### Suggested Improvement

**Smart Stage Suggestions:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STAGE GATE AUTOMATION                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Pipeline: PIP-2025-0042 (PT ABC Corporation)                               │
│  Current Stage: P3 (25%)                                                    │
│  ─────────────────────────────────────────────────────────────────────      │
│                                                                              │
│  💡 SUGGESTION: Move to P2                                                  │
│                                                                              │
│  Reason:                                                                     │
│  ✅ 3+ activities completed                                                 │
│  ✅ Proposal sent                                                           │
│  ✅ Decision maker identified                                               │
│  ✅ Budget confirmed                                                        │
│                                                                              │
│  [Move to P2]   [Remind Later]   [Dismiss]                                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Stage Gate Rules

| From | To | Auto-Suggest When |
|------|----|--------------------|
| NEW | P3 | First activity completed |
| P3 | P2 | Proposal activity + 2 meetings |
| P2 | P1 | Quote sent + verbal agreement |
| P1 | ACCEPTED | Contract signed activity |

### Stagnation Alert

```sql
-- Pipelines stuck in stage for too long
SELECT p.*, 
       EXTRACT(DAY FROM NOW() - p.stage_updated_at) as days_in_stage
FROM pipelines p
WHERE p.stage NOT IN ('ACCEPTED', 'DECLINED')
  AND p.stage_updated_at < NOW() - INTERVAL '21 days'
ORDER BY days_in_stage DESC;
```

---

## 📚 Related Documents

- [Pipeline Management](../06-features/pipeline-management.md)
- [Activity Logging](../06-features/activity-logging.md)
- [Pipeline Referral](../06-features/pipeline-referral.md)

---

*Flow Improvements - January 2025*
