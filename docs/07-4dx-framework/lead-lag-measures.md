# 📊 Lead & Lag Measures

## Definisi Detail Pengukuran 4DX LeadX CRM

---

## 📋 Overview

Dokumen ini menjelaskan secara detail semua **Lead Measures** dan **Lag Measures** yang digunakan dalam sistem scoring 4DX LeadX CRM, termasuk definisi, perhitungan, sumber data, dan konfigurasi.

> **⚠️ PENTING**: Semua metrics dalam 4DX LeadX adalah **AUTO-CALCULATED** dari data yang sudah ada di aplikasi. Tidak ada input manual untuk metrics - semuanya dihitung dari tabel `activities`, `pipelines`, `customers`, dan `cadence_*`.

> **Technical Note**: Lead and Lag measures use the identical `measure_definitions` table structure.
> The only programmatic difference is the `measure_type` field ('LEAD' or 'LAG'). This allows
> uniform handling in the scoring engine while maintaining semantic separation.

---

## Server-Side Calculation

All 4DX scores are calculated **server-side** (Supabase/PostgreSQL). The mobile app:
- Reads pre-calculated scores from `user_scores` and `user_score_snapshots` tables
- Does NOT perform score calculations locally
- Syncs calculation results via the standard sync mechanism


---

## Score Calculation Architecture

### Table Relationship
```
user_scores              →    user_score_snapshots
(per measure)                 (aggregate of all measures)

| user | measure | actual |    | user | lead_score | lag_score | total |
|------|---------|--------|    |------|------------|-----------|-------|
| RM1  | VISIT   | 8      | →  | RM1  | 85.5       | 72.0      | 80.1  |
| RM1  | CALL    | 15     |
| RM1  | PREMIUM | 300M   |
```

### Two-Tier Calculation Strategy

| Tier | Who | When | How |
|------|-----|------|-----|
| **RM (immediate)** | Individual RM | On activity completion | PostgreSQL trigger |
| **Atasan (periodic)** | BH, BM, ROH | Every 10 minutes | Cron job with dirty tracking |

### Dirty User Tracking

To avoid recalculating ALL users every 10 minutes, track who needs recalculation:

```sql
-- Internal table (NO RLS - system use only)
CREATE TABLE dirty_users (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  dirtied_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Trigger Flow (RM Immediate + Mark Dirty)
```
Activity Completed
    ↓
PostgreSQL Trigger fires (SECURITY DEFINER)
    ↓
1. Update user_scores for that measure
    ↓
2. Recalculate user_score_snapshots for RM
    ↓
3. Mark RM + ALL ancestors as dirty
   (INSERT INTO dirty_users SELECT ancestor_id FROM user_hierarchy...)
    ↓
RM sees updated score immediately
```

### Cron Job Flow (Atasan Every 10 Min)
```
Every 10 minutes (pg_cron or Supabase scheduled function)
    ↓
1. Get all dirty users (simple SELECT)
    ↓
2. For each dirty user, recalculate their aggregate
   (their own scores + all subordinates' scores)
    ↓
3. TRUNCATE dirty_users
    ↓
Managers see updated team scores
```

### RLS Considerations

| Component | RLS Setting | Reason |
|-----------|-------------|--------|
| `dirty_users` table | **NO RLS** | Internal system table, no user access |
| Trigger functions | `SECURITY DEFINER` | Must write to dirty_users, read user_hierarchy |
| Cron function | `SECURITY DEFINER` or service_role | Must update all user_score_snapshots |
| `user_score_snapshots` | **Keep existing RLS** | App users see own + subordinates only |

### Why This Approach?
- **RM gets immediate feedback** - Most important user sees real-time progress
- **Managers accept 10-min staleness** - Checking trends, not real-time
- **Efficient** - Only dirty users recalculated, not everyone
- **Simple cron job** - No hierarchy lookup, just process the dirty list
- **Consistent analytics** - All managers see same snapshot within each 10-min window

---

## Target Distribution & Score Ownership

### Target Distribution
Measure targets are distributed via **direct bawahans** (subordinates), not organizational structure:

- When a manager sets targets, they cascade to users where `user_hierarchy.depth = 1`
  (direct reports only)
- This differs from org structure (branches → regional offices) which is for administrative grouping
- Each RM receives individual targets set by their direct BH

### Score Ownership & Hierarchy Aggregation
Scores cascade UP the hierarchy - each atasan (superior) sees aggregated scores:

| Role | Sees |
|------|------|
| **RM** | Own scores only |
| **BH** | Own scores + all RMs under them (aggregated) |
| **BM** | Own scores + all BHs + their RMs (aggregated) |
| **ROH** | Own scores + all BMs + BHs + RMs (aggregated) |

**Key principle:** An atasan's view aggregates EVERYTHING below them in the hierarchy, not just direct reports.

This uses `user_hierarchy` table with varying depths:
- `depth = 1`: Direct bawahan
- `depth = 2`: Bawahan's bawahan
- `depth = n`: All descendants

```sql
-- Example: Get all scores for a BM (including all subordinates)
SELECT SUM(actual_value)
FROM user_scores us
JOIN user_hierarchy uh ON uh.descendant_id = us.user_id
WHERE uh.ancestor_id = :manager_id  -- All depths included
  AND us.measure_id = :measure_id;
```

---

## Flexible Source Configuration

Measures can pull from multiple sources and apply discriminators:

### Multiple Activity Types per Measure
A single measure can track multiple activity types:
```json
{
  "source_table": "activities",
  "source_condition": "activity_type_id IN ('VISIT', 'CALL', 'MEETING') AND status = 'COMPLETED'"
}
```

### Entity Type Discrimination
Measures can filter by customer type, broker involvement, etc:
```json
{
  "source_table": "activities",
  "source_condition": "customer_type = 'BROKER' AND status = 'COMPLETED'"
}
```

### Template-Based Measures
Different measures may source from entirely different tables based on their template/configuration:

| Template | Source Table | Example Measures |
|----------|-------------|------------------|
| Activity-based | `activities` | VISIT_COUNT, CALL_COUNT, MEETING_COUNT |
| Customer-based | `customers` | NEW_CUSTOMER |
| Pipeline-based | `pipelines` | PIPELINE_WON, PREMIUM_WON, REFERRAL_PREMIUM |
| Stage-transition-based | `pipeline_stage_history` | PROPOSAL_STAGE_REACHED, NEGOTIATION_REACHED |

**Note on Referral Measures:** Referral tracking uses `pipelines.referred_by_user_id` field.
When a referred pipeline wins, the referrer gets partial credit calculated as
`final_premium × referral_percentage`.

### Stage/Status Transition Measures
Measures can count when pipelines reach specific stages using `pipeline_stage_history`:
```json
{
  "source_table": "pipeline_stage_history",
  "source_condition": "to_stage_id = 'PROPOSAL_SENT_STAGE_UUID' AND changed_by = :user_id"
}
```

This tracks pipeline progression milestones:
- `from_stage_id` / `to_stage_id` - stage transitions
- `from_status_id` / `to_status_id` - status transitions
- `changed_by` - who moved the pipeline
- `changed_at` - when the transition occurred

Example use cases:
- Count pipelines that reached "Proposal Sent" stage
- Count pipelines moved to "Negotiation" stage
- Track stage velocity (time between stages)

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

### LAG-004: Referral Premium (Premium dari Pipeline yang Di-referral)

| Attribute | Value |
|-----------|-------|
| **Code** | `REFERRAL_PREMIUM` |
| **Name** | Premium from Referred Pipelines |
| **Category** | LAG |
| **Description** | Premium dari pipeline yang di-referral oleh user lain dan won. Dihitung sebagai `final_premium × referral_percentage` untuk partial credit ke referrer. |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `referred_by_user_id = :user_id AND stage = 'ACCEPTED'` |
| **Calculation** | SUM(final_premium × referral_percentage) |
| **Period** | Monthly |
| **Default Target** | Based on team targets |
| **Weight** | 1.0 |

**SQL Query:**
```sql
SELECT COALESCE(SUM(final_premium * referral_percentage), 0) as referral_premium
FROM pipelines
WHERE referred_by_user_id = :user_id
  AND stage = 'ACCEPTED'
  AND won_date >= :period_start
  AND won_date < :period_end;
```

> **Note:** When a pipeline with `referred_by_user_id` set reaches ACCEPTED stage:
> - The `scored_to_user_id` (closer) gets full PREMIUM_WON credit
> - The `referred_by_user_id` (referrer) gets partial REFERRAL_PREMIUM credit (percentage-based)

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

## ⚙️ Database Schema

For complete table schemas (`measure_definitions`, `scoring_periods`, `user_targets`, `user_scores`, `user_score_snapshots`), see:

**[Scoring & 4DX Tables](../04-database/tables/scoring-4dx.md)**

---

## 📚 Related Documents

- [4DX Overview](4dx-overview.md) - Framework overview
- [Scoreboard Design](scoreboard-design.md) - Visual display
- [Cadence Accountability](cadence-accountability.md) - Meeting structure
- [Schema Overview](../04-database/schema-overview.md) - Database tables

---

*Dokumen ini adalah bagian dari LeadX CRM 4DX Framework Documentation.*
