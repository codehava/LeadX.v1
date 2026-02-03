# 📊 Lead & Lag Measures

## Definisi Detail Pengukuran 4DX LeadX CRM

---

## 📋 Overview

Dokumen ini menjelaskan secara detail semua **Lead Measures** dan **Lag Measures** yang digunakan dalam sistem scoring 4DX LeadX CRM, termasuk definisi, perhitungan, sumber data, dan konfigurasi.

> **⚠️ PENTING**: Semua metrics dalam 4DX LeadX adalah **AUTO-CALCULATED** dari data yang sudah ada di aplikasi. Tidak ada input manual untuk metrics - semuanya dihitung dari tabel `activities`, `pipelines`, `customers`, dan `cadence_*`.

---

## ⚙️ Admin Panel Configuration

### Lokasi Konfigurasi
**Admin Panel > 4DX Settings > Measure Configuration**

### Apa yang Bisa Dikonfigurasi Admin?

| Setting | Description | Default |
|---------|-------------|---------|
| **Enable/Disable Measure** | Aktifkan/nonaktifkan measure tertentu | All enabled |
| **Default Target** | Target default untuk user baru | Per measure |
| **Weight** | Bobot measure dalam perhitungan score | 1.0 |
| **Lead/Lag Ratio** | Rasio bobot Lead vs Lag | 60:40 |
| **Bonus Config** | Konfigurasi bonus per kondisi | Per measure |
| **Period Type** | Weekly/Monthly/Quarterly | Per measure |
| **Cap Percentage** | Maximum achievement % | 150% |

### Admin UI Mockup

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  4DX MEASURE CONFIGURATION                                     [Admin Panel]│
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LEAD MEASURES (60% weight)                          [Edit Ratio]           │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ ☑ VISIT_COUNT    │ Visits    │ Weekly │ Target: 10 │ Weight: 1.0 [✎]│  │
│  │ ☑ CALL_COUNT     │ Calls     │ Weekly │ Target: 20 │ Weight: 1.0 [✎]│  │
│  │ ☑ MEETING_COUNT  │ Meetings  │ Weekly │ Target: 5  │ Weight: 1.0 [✎]│  │
│  │ ☑ NEW_CUSTOMER   │ New Cust  │ Monthly│ Target: 4  │ Weight: 1.5 [✎]│  │
│  │ ☑ NEW_PIPELINE   │ New Pipe  │ Monthly│ Target: 5  │ Weight: 1.2 [✎]│  │
│  │ ☑ PROPOSAL_SENT  │ Proposals │ Weekly │ Target: 3  │ Weight: 1.3 [✎]│  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  LAG MEASURES (40% weight)                                                  │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ ☑ PIPELINE_WON   │ Won Deals │ Monthly│ Target: 3  │ Weight: 1.5 [✎]│  │
│  │ ☑ PREMIUM_WON    │ Premium   │ Monthly│ Target:500M│ Weight: 2.0 [✎]│  │
│  │ ☑ CONVERSION_RATE│ Win Rate  │ Monthly│ Target: 40%│ Weight: 1.0 [✎]│  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  [+ Add Custom Measure]    [Save Changes]    [Reset to Defaults]            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Measure Calculation Source (Auto-Generated)

| Measure | Source Table | Filter | Calculation |
|---------|-------------|--------|-------------|
| VISIT_COUNT | `activities` | type='VISIT', status='COMPLETED' | COUNT(*) |
| CALL_COUNT | `activities` | type='CALL', status='COMPLETED' | COUNT(*) |
| MEETING_COUNT | `activities` | type='MEETING', status='COMPLETED' | COUNT(*) |
| PROPOSAL_SENT | `activities` | type='PROPOSAL', status='COMPLETED' | COUNT(*) |
| NEW_CUSTOMER | `customers` | created_by=user_id, created_at in period | COUNT(*) |
| NEW_PIPELINE | `pipelines` | assigned_rm_id=user_id, created_at in period | COUNT(*) |
| PIPELINE_WON | `pipelines` | scored_to_user_id=user_id, stage='ACCEPTED', won_date in period | COUNT(*) |
| PREMIUM_WON | `pipelines` | scored_to_user_id=user_id, stage='ACCEPTED', won_date in period | SUM(final_premium) |
| CONVERSION_RATE | `pipelines` | scored_to_user_id=user_id, closed in period | WON/TOTAL × 100 |

> **Note**: Admin TIDAK bisa mengubah source data - hanya target, weight, dan bonus config.

---

## 🎯 Prinsip Lead vs Lag

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LEAD vs LAG MEASURES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────┐  ┌─────────────────────────────────┐  │
│  │       LEAD MEASURES             │  │       LAG MEASURES              │  │
│  │                                 │  │                                 │  │
│  │  "Aktivitas yang MENDORONG     │  │  "Hasil yang MENGUKUR           │  │
│  │   hasil"                        │  │   keberhasilan"                 │  │
│  │                                 │  │                                 │  │
│  │  ✓ PREDICTIVE                   │  │  ✓ HISTORICAL                   │  │
│  │  ✓ INFLUENCEABLE               │  │  ✓ OUTCOME-BASED                │  │
│  │  ✓ IMMEDIATE FEEDBACK          │  │  ✓ DELAYED FEEDBACK             │  │
│  │                                 │  │                                 │  │
│  │  Contoh:                        │  │  Contoh:                        │  │
│  │  • Jumlah kunjungan            │  │  • Total revenue                │  │
│  │  • Jumlah telepon              │  │  • Pipeline won                 │  │
│  │  • Proposal terkirim           │  │  • Conversion rate              │  │
│  │                                 │  │                                 │  │
│  │  Bobot: 60%                     │  │  Bobot: 40%                     │  │
│  │                                 │  │                                 │  │
│  └─────────────────────────────────┘  └─────────────────────────────────┘  │
│                                                                              │
│                          ┌─────────────┐                                    │
│                          │ FINAL SCORE │                                    │
│                          │ = 60% Lead  │                                    │
│                          │ + 40% Lag   │                                    │
│                          └─────────────┘                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📈 Lead Measures (60% Score Weight)

### LM-001: Visit Count (Kunjungan Customer)

| Attribute | Value |
|-----------|-------|
| **Code** | `VISIT_COUNT` |
| **Name** | Customer Visits |
| **Category** | LEAD |
| **Description** | Jumlah kunjungan fisik ke customer yang tercatat dan verified |
| **Source Table** | `activities` |
| **Filter Criteria** | `type = 'VISIT' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Period** | Weekly (Monday 00:00 - Sunday 23:59) |
| **Default Target** | 10 per week |
| **Weight** | 1.0 |

**Bonuses:**
| Condition | Bonus |
|-----------|-------|
| GPS Verified (accuracy < 100m) | +5% |
| Photo Attached | +5% |
| Logged within 30 min of visit | +15% |
| Check-in & Check-out recorded | +10% |

**SQL Query:**
```sql
SELECT COUNT(*) as visit_count
FROM activities
WHERE user_id = :user_id
  AND type = 'VISIT'
  AND status = 'COMPLETED'
  AND activity_time >= :period_start
  AND activity_time < :period_end;
```

---

### LM-002: Call Count (Telepon)

| Attribute | Value |
|-----------|-------|
| **Code** | `CALL_COUNT` |
| **Name** | Phone Calls Made |
| **Category** | LEAD |
| **Description** | Jumlah telepon ke customer/prospect yang tercatat |
| **Source Table** | `activities` |
| **Filter Criteria** | `type = 'CALL' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Period** | Weekly |
| **Default Target** | 20 per week |
| **Weight** | 1.0 |

**Bonuses:**
| Condition | Bonus |
|-----------|-------|
| Call duration > 5 min | +10% |
| Notes recorded | +5% |
| Follow-up scheduled | +10% |

---

### LM-003: Meeting Count (Meeting)

| Attribute | Value |
|-----------|-------|
| **Code** | `MEETING_COUNT` |
| **Name** | Meetings Conducted |
| **Category** | LEAD |
| **Description** | Jumlah meeting (virtual/offline) yang dilakukan |
| **Source Table** | `activities` |
| **Filter Criteria** | `type = 'MEETING' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Period** | Weekly |
| **Default Target** | 5 per week |
| **Weight** | 1.0 |

---

### LM-004: New Customer (Customer Baru)

| Attribute | Value |
|-----------|-------|
| **Code** | `NEW_CUSTOMER` |
| **Name** | New Customers Registered |
| **Category** | LEAD |
| **Description** | Jumlah customer baru yang didaftarkan oleh RM |
| **Source Table** | `customers` |
| **Filter Criteria** | `created_by = :user_id` |
| **Calculation** | COUNT of new records in period |
| **Period** | Monthly |
| **Default Target** | 4 per month |
| **Weight** | 1.5 (higher weight) |

---

### LM-005: New Pipeline (Pipeline Baru)

| Attribute | Value |
|-----------|-------|
| **Code** | `NEW_PIPELINE` |
| **Name** | New Pipelines Created |
| **Category** | LEAD |
| **Description** | Jumlah pipeline/opportunity baru yang dibuat |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `assigned_rm_id = :user_id` |
| **Calculation** | COUNT of new records in period |
| **Period** | Monthly |
| **Default Target** | 5 per month |
| **Weight** | 1.2 |

---

### LM-006: Proposal Sent (Proposal Terkirim)

| Attribute | Value |
|-----------|-------|
| **Code** | `PROPOSAL_SENT` |
| **Name** | Proposals Sent |
| **Category** | LEAD |
| **Description** | Jumlah proposal yang dikirim ke customer |
| **Source Table** | `activities` |
| **Filter Criteria** | `type = 'PROPOSAL' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Period** | Weekly |
| **Default Target** | 3 per week |
| **Weight** | 1.3 (higher importance) |

---

## 📉 Lag Measures (40% Score Weight)

### LAG-001: Pipeline Won (Pipeline Closing)

| Attribute | Value |
|-----------|-------|
| **Code** | `PIPELINE_WON` |
| **Name** | Pipelines Closed Won |
| **Category** | LAG |
| **Description** | Jumlah pipeline yang berhasil closing (stage ACCEPTED) |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `scored_to_user_id = :user_id AND stage = 'ACCEPTED'` |
| **Calculation** | COUNT where stage changed to ACCEPTED in period |
| **Period** | Monthly |
| **Default Target** | 3 per month |
| **Weight** | 1.5 |

**SQL Query:**
```sql
SELECT COUNT(*) as pipeline_won
FROM pipelines
WHERE scored_to_user_id = :user_id
  AND stage = 'ACCEPTED'
  AND won_date >= :period_start
  AND won_date < :period_end;
```

> **Note:** Uses `scored_to_user_id` (not `assigned_rm_id`) to credit the user who won the pipeline, even if ownership later transferred.

---

### LAG-002: Premium Won (Premium dari Closing)

| Attribute | Value |
|-----------|-------|
| **Code** | `PREMIUM_WON` |
| **Name** | Total Premium from Won Pipelines |
| **Category** | LAG |
| **Description** | Total nilai premium dari pipeline yang closing |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `scored_to_user_id = :user_id AND stage = 'ACCEPTED'` |
| **Calculation** | SUM of final_premium |
| **Period** | Monthly |
| **Default Target** | Rp 500.000.000 per month |
| **Weight** | 2.0 (highest weight) |

**SQL Query:**
```sql
SELECT COALESCE(SUM(final_premium), 0) as premium_won
FROM pipelines
WHERE scored_to_user_id = :user_id
  AND stage = 'ACCEPTED'
  AND won_date >= :period_start
  AND won_date < :period_end;
```

> **Note:** Uses `scored_to_user_id` (not `assigned_rm_id`) to credit the user who won the pipeline.

---

### LAG-003: Conversion Rate (Win Rate)

| Attribute | Value |
|-----------|-------|
| **Code** | `CONVERSION_RATE` |
| **Name** | Pipeline Conversion Rate |
| **Category** | LAG |
| **Description** | Persentase pipeline yang berhasil closing vs total closed |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `scored_to_user_id = :user_id AND stage IN ('ACCEPTED', 'REJECTED')` |
| **Calculation** | (COUNT WON / COUNT ALL CLOSED) × 100 |
| **Period** | Monthly |
| **Default Target** | 40% |
| **Weight** | 1.0 |

**SQL Query:**
```sql
WITH closed_pipelines AS (
  SELECT
    COUNT(*) FILTER (WHERE stage = 'ACCEPTED') as won,
    COUNT(*) FILTER (WHERE stage IN ('ACCEPTED', 'REJECTED')) as total
  FROM pipelines
  WHERE scored_to_user_id = :user_id
    AND stage IN ('ACCEPTED', 'REJECTED')
    AND COALESCE(won_date, lost_date) >= :period_start
    AND COALESCE(won_date, lost_date) < :period_end
)
SELECT
  CASE WHEN total > 0 THEN (won::float / total * 100) ELSE 0 END as conversion_rate
FROM closed_pipelines;
```

> **Note:** Uses `scored_to_user_id` (not `assigned_rm_id`) to credit the user who closed the pipeline.

---

## 🧮 Score Calculation

### Formula Lengkap

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     SCORE CALCULATION FORMULA                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. Calculate each measure achievement:                                      │
│     measure_pct = MIN(150, (actual / target) × 100)                         │
│                                                                              │
│  2. Apply weights to get weighted score:                                     │
│     weighted_score = measure_pct × weight                                   │
│                                                                              │
│  3. Calculate Lead Score:                                                    │
│     lead_score = SUM(lead_weighted_scores) / SUM(lead_weights)              │
│                                                                              │
│  4. Calculate Lag Score:                                                     │
│     lag_score = SUM(lag_weighted_scores) / SUM(lag_weights)                 │
│                                                                              │
│  5. Combine with category weights:                                           │
│     base_score = (lead_score × 0.6) + (lag_score × 0.4)                     │
│                                                                              │
│  6. Add bonuses and subtract penalties:                                      │
│     final_score = base_score + total_bonus - total_penalty                  │
│                                                                              │
│  7. Cap final score:                                                         │
│     final_score = MAX(0, MIN(150, final_score))                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Achievement Cap (150%)

Untuk mencegah gaming, setiap measure di-cap pada 150%:
- Target: 10 visits
- Actual: 20 visits
- Achievement: 150% (bukan 200%)

---

## ⚙️ Measure Configuration

### Database Schema

```sql
CREATE TABLE measure_definitions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(10) CHECK (category IN ('LEAD', 'LAG')),
  description TEXT,
  source_table VARCHAR(100),
  filter_criteria JSONB,
  calculation_type VARCHAR(20), -- COUNT, SUM, AVERAGE, PERCENTAGE
  period_type VARCHAR(20), -- DAILY, WEEKLY, MONTHLY, QUARTERLY
  default_target NUMERIC,
  weight NUMERIC DEFAULT 1.0,
  bonus_config JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_measure_targets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  measure_id UUID REFERENCES measure_definitions(id),
  target_value NUMERIC NOT NULL,
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, measure_id, effective_from)
);

CREATE TABLE measure_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  measure_id UUID REFERENCES measure_definitions(id),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  target_value NUMERIC NOT NULL,
  actual_value NUMERIC NOT NULL,
  achievement_pct NUMERIC GENERATED ALWAYS AS (
    LEAST(150, CASE WHEN target_value > 0 
      THEN (actual_value / target_value * 100) 
      ELSE 0 END)
  ) STORED,
  calculated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, measure_id, period_start)
);
```

---

## 📚 Related Documents

- [4DX Overview](4dx-overview.md) - Framework overview
- [Scoreboard Design](scoreboard-design.md) - Visual display
- [Cadence Accountability](cadence-accountability.md) - Meeting structure
- [Schema Overview](../04-database/schema-overview.md) - Database tables

---

*Dokumen ini adalah bagian dari LeadX CRM 4DX Framework Documentation.*
