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

## pg_cron Setup (Production)

### Installation

pg_cron is a PostgreSQL extension for scheduling recurring jobs. On Supabase, it's pre-installed but needs to be enabled:

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### Score Aggregation Cron Job

This job processes the `dirty_users` queue every 10 minutes, recalculating aggregate scores for managers:

```sql
-- Schedule score aggregation cron job
SELECT cron.schedule(
  'score-aggregation-cron',        -- Job name
  '*/10 * * * *',                  -- Every 10 minutes
  $$
  DECLARE
    v_user_id UUID;
    v_period_id UUID;
  BEGIN
    -- Get current period
    SELECT id INTO v_period_id FROM scoring_periods WHERE is_current = TRUE;

    -- Process each dirty user
    FOR v_user_id IN SELECT user_id FROM dirty_users ORDER BY dirtied_at LOOP
      BEGIN
        -- Recalculate aggregate (includes subordinates)
        PERFORM recalculate_aggregate(v_user_id, v_period_id);

        -- Remove from dirty queue
        DELETE FROM dirty_users WHERE user_id = v_user_id;

      EXCEPTION WHEN OTHERS THEN
        -- Log error but continue processing other users
        INSERT INTO system_errors (error_type, entity_id, error_message)
        VALUES ('CRON_USER_FAILED', v_user_id, SQLERRM);
      END;
    END LOOP;
  END;
  $$
);
```

### Verify Cron Job

Check that the job is scheduled:

```sql
-- List all cron jobs
SELECT * FROM cron.job WHERE jobname = 'score-aggregation-cron';

-- View recent job runs
SELECT
  jobid,
  runid,
  job_pid,
  status,
  start_time,
  end_time,
  end_time - start_time as duration
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'score-aggregation-cron')
ORDER BY start_time DESC
LIMIT 10;
```

### Monitoring & Troubleshooting

**Check for errors:**
```sql
-- View failed job runs
SELECT * FROM cron.job_run_details
WHERE status = 'failed'
  AND jobid = (SELECT jobid FROM cron.job WHERE jobname = 'score-aggregation-cron')
ORDER BY start_time DESC;

-- View system errors from cron processing
SELECT * FROM system_errors
WHERE error_type = 'CRON_USER_FAILED'
  AND resolved_at IS NULL
ORDER BY created_at DESC;
```

**Manual trigger (for testing):**
```sql
-- Manually run the cron job logic
DO $$
DECLARE
  v_user_id UUID;
  v_period_id UUID;
BEGIN
  SELECT id INTO v_period_id FROM scoring_periods WHERE is_current = TRUE;

  FOR v_user_id IN SELECT user_id FROM dirty_users ORDER BY dirtied_at LOOP
    BEGIN
      PERFORM recalculate_aggregate(v_user_id, v_period_id);
      DELETE FROM dirty_users WHERE user_id = v_user_id;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Failed to process user %: %', v_user_id, SQLERRM;
    END;
  END LOOP;
END;
$$;
```

**Unschedule (if needed):**
```sql
-- Remove the cron job
SELECT cron.unschedule('score-aggregation-cron');
```

### Alternative: Supabase Edge Function

Instead of pg_cron, you can use a Supabase Edge Function with scheduled invocations:

```typescript
// supabase/functions/score-aggregation-cron/index.ts
import { createClient } from '@supabase/supabase-js';

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  );

  // Get current period
  const { data: period } = await supabase
    .from('scoring_periods')
    .select('id')
    .eq('is_current', true)
    .single();

  if (!period) {
    return new Response('No current period', { status: 400 });
  }

  // Get dirty users
  const { data: dirtyUsers } = await supabase
    .from('dirty_users')
    .select('user_id')
    .order('dirtied_at');

  let processed = 0;
  let failed = 0;

  for (const { user_id } of dirtyUsers ?? []) {
    try {
      await supabase.rpc('recalculate_aggregate', {
        p_user_id: user_id,
        p_period_id: period.id
      });

      await supabase
        .from('dirty_users')
        .delete()
        .eq('user_id', user_id);

      processed++;
    } catch (error) {
      await supabase.from('system_errors').insert({
        error_type: 'CRON_USER_FAILED',
        entity_id: user_id,
        error_message: error.message
      });
      failed++;
    }
  }

  return new Response(
    JSON.stringify({ processed, failed }),
    { headers: { 'Content-Type': 'application/json' } }
  );
});
```

Then schedule via Supabase dashboard or CLI:
```bash
# Deploy function
supabase functions deploy score-aggregation-cron

# Schedule via pg_cron (pointing to Edge Function)
SELECT cron.schedule(
  'score-aggregation-edge',
  '*/10 * * * *',
  $$SELECT net.http_post(
    url := 'https://<project-ref>.supabase.co/functions/v1/score-aggregation-cron',
    headers := '{"Authorization": "Bearer <anon-key>"}'::jsonb
  );$$
);
```

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

| Measure Code | Source Table | Filter Condition | Calculation | Period | Target |
|--------------|-------------|------------------|-------------|--------|--------|
| LEAD-001 | `activities` | activity_type_id='VISIT' AND status='COMPLETED' | COUNT(*) | Weekly | 10 |
| LEAD-002 | `activities` | activity_type_id='CALL' AND status='COMPLETED' | COUNT(*) | Weekly | 20 |
| LEAD-003 | `activities` | activity_type_id='MEETING' AND status='COMPLETED' | COUNT(*) | Weekly | 5 |
| LEAD-004 | `customers` | created_by=:user_id | COUNT(*) | Monthly | 4 |
| LEAD-005 | `pipelines` | assigned_rm_id=:user_id | COUNT(*) | Monthly | 5 |
| LEAD-006 | `pipeline_stage_history` | to_stage_id='P2' AND changed_by=:user_id | COUNT(*) | Weekly | 3 |
| LAG-001 | `pipelines` | stage_id IN (is_won) AND scored_to_user_id=:user_id | COUNT(*) | Monthly | 3 |
| LAG-002 | `pipelines` | stage_id IN (is_won) AND scored_to_user_id=:user_id | SUM(final_premium) | Monthly | 500M IDR |
| LAG-003 | `pipelines` | scored_to_user_id=:user_id AND closed_at IS NOT NULL | (WON/TOTAL)×100 | Monthly | 40% |
| LAG-004 | `pipelines` | referred_by_user_id=:user_id AND stage_id IN (is_won) | SUM(final_premium×referral_pct) | Monthly | 100M IDR |

> **Note**: Admin can modify target, weight, and bonus config - but NOT source_condition (locked after creation to preserve historical data integrity).

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

### LEAD-001: Visit Count (Kunjungan Customer)

| Attribute | Value |
|-----------|-------|
| **Code** | `LEAD-001` |
| **Name** | Visit Count |
| **Category** | LEAD |
| **Description** | Jumlah kunjungan fisik ke customer yang tercatat dan verified |
| **Source Table** | `activities` |
| **Filter Criteria** | `activity_type_id = '<VISIT_UUID>' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Data Type** | COUNT |
| **Period** | Weekly |
| **Default Target** | 10 per week |
| **Weight** | 1.0 |
| **Unit** | count |
| **Template Type** | `activity_count` |

**Template Config:**
```json
{
  "activity_types": ["VISIT"],
  "statuses": ["COMPLETED"],
  "customer_type": null
}
```

**SQL Query (runtime - UUIDs resolved):**
```sql
SELECT COUNT(*) as visit_count
FROM activities
WHERE user_id = :user_id
  AND activity_type_id = (SELECT id FROM activity_types WHERE code = 'VISIT')
  AND status = 'COMPLETED'
  AND created_at >= :period_start
  AND created_at < :period_end;
```

---

### LEAD-002: Call Count (Telepon)

| Attribute | Value |
|-----------|-------|
| **Code** | `LEAD-002` |
| **Name** | Call Count |
| **Category** | LEAD |
| **Description** | Jumlah telepon ke customer/prospect yang tercatat |
| **Source Table** | `activities` |
| **Filter Criteria** | `activity_type_id = '<CALL_UUID>' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Data Type** | COUNT |
| **Period** | Weekly |
| **Default Target** | 20 per week |
| **Weight** | 1.0 |
| **Unit** | count |
| **Template Type** | `activity_count` |

**Template Config:**
```json
{
  "activity_types": ["CALL"],
  "statuses": ["COMPLETED"],
  "customer_type": null
}
```

---

### LEAD-003: Meeting Count (Meeting)

| Attribute | Value |
|-----------|-------|
| **Code** | `LEAD-003` |
| **Name** | Meeting Count |
| **Category** | LEAD |
| **Description** | Jumlah meeting (virtual/offline) yang dilakukan |
| **Source Table** | `activities` |
| **Filter Criteria** | `activity_type_id = '<MEETING_UUID>' AND status = 'COMPLETED'` |
| **Calculation** | COUNT of matching records |
| **Data Type** | COUNT |
| **Period** | Weekly |
| **Default Target** | 5 per week |
| **Weight** | 1.0 |
| **Unit** | count |
| **Template Type** | `activity_count` |

**Template Config:**
```json
{
  "activity_types": ["MEETING"],
  "statuses": ["COMPLETED"],
  "customer_type": null
}
```

---

### LEAD-004: New Customer (Customer Baru)

| Attribute | Value |
|-----------|-------|
| **Code** | `LEAD-004` |
| **Name** | New Customer |
| **Category** | LEAD |
| **Description** | Jumlah customer baru yang didaftarkan oleh RM |
| **Source Table** | `customers` |
| **Filter Criteria** | `created_by = :user_id` |
| **Calculation** | COUNT of new records in period |
| **Data Type** | COUNT |
| **Period** | Monthly |
| **Default Target** | 4 per month |
| **Weight** | 1.5 (higher weight) |
| **Unit** | count |
| **Template Type** | `customer_acquisition` |

**Template Config:**
```json
{
  "customer_types": null,
  "company_sizes": null
}
```

**SQL Query:**
```sql
SELECT COUNT(*) as new_customer_count
FROM customers
WHERE created_by = :user_id
  AND created_at >= :period_start
  AND created_at < :period_end;
```

---

### LEAD-005: New Pipeline (Pipeline Baru)

| Attribute | Value |
|-----------|-------|
| **Code** | `LEAD-005` |
| **Name** | New Pipeline |
| **Category** | LEAD |
| **Description** | Jumlah pipeline/opportunity baru yang dibuat |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `assigned_rm_id = :user_id` |
| **Calculation** | COUNT of new records in period |
| **Data Type** | COUNT |
| **Period** | Monthly |
| **Default Target** | 5 per month |
| **Weight** | 1.2 |
| **Unit** | count |
| **Template Type** | `pipeline_count` |

**Template Config:**
```json
{
  "stages": ["NEW"],
  "filters": {}
}
```

**SQL Query:**
```sql
SELECT COUNT(*) as new_pipeline_count
FROM pipelines
WHERE assigned_rm_id = :user_id
  AND created_at >= :period_start
  AND created_at < :period_end;
```

---

### LEAD-006: Proposal Sent (Proposal Stage Reached)

| Attribute | Value |
|-----------|-------|
| **Code** | `LEAD-006` |
| **Name** | Proposal Sent |
| **Category** | LEAD |
| **Description** | Jumlah pipeline yang mencapai stage P2 (Proposal Sent) |
| **Source Table** | `pipeline_stage_history` |
| **Filter Criteria** | `to_stage_id IN (SELECT id FROM pipeline_stages WHERE code = 'P2') AND changed_by = :user_id` |
| **Calculation** | COUNT of stage transitions |
| **Data Type** | COUNT |
| **Period** | Weekly |
| **Default Target** | 3 per week |
| **Weight** | 1.3 (higher importance) |
| **Unit** | count |
| **Template Type** | `stage_milestone` |

**Template Config:**
```json
{
  "target_stage": "P2",
  "from_any": true
}
```

**SQL Query:**
```sql
SELECT COUNT(*) as proposal_sent_count
FROM pipeline_stage_history
WHERE to_stage_id IN (SELECT id FROM pipeline_stages WHERE code = 'P2')
  AND changed_by = :user_id
  AND changed_at >= :period_start
  AND changed_at < :period_end;
```

> **Note:** This measure tracks when pipelines reach the P2 (Proposal Sent) stage, regardless of previous stage. Uses `pipeline_stage_history` table to capture the milestone event.

---

## 📉 Lag Measures (40% Score Weight)

### LAG-001: Pipeline Won (Pipeline Closing)

| Attribute | Value |
|-----------|-------|
| **Code** | `LAG-001` |
| **Name** | Pipeline Won |
| **Category** | LAG |
| **Description** | Jumlah pipeline yang berhasil closing (won stages) |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true) AND scored_to_user_id = :user_id` |
| **Calculation** | COUNT where stage_id is a won stage in period |
| **Data Type** | COUNT |
| **Period** | Monthly |
| **Default Target** | 3 per month |
| **Weight** | 1.5 |
| **Unit** | count |
| **Template Type** | `pipeline_count` |

**Template Config:**
```json
{
  "stages": ["ACCEPTED"],
  "filters": {}
}
```

**SQL Query:**
```sql
SELECT COUNT(*) as pipeline_won
FROM pipelines
WHERE scored_to_user_id = :user_id
  AND stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
  AND closed_at >= :period_start
  AND closed_at < :period_end;
```

> **Note:** Uses `scored_to_user_id` (not `assigned_rm_id`) to credit the user who won the pipeline. Uses `stage_id` (UUID) with join to `pipeline_stages.is_won` flag rather than hardcoded stage text.

---

### LAG-002: Premium Won (Premium dari Closing)

| Attribute | Value |
|-----------|-------|
| **Code** | `LAG-002` |
| **Name** | Premium Won |
| **Category** | LAG |
| **Description** | Total nilai premium dari pipeline yang closing |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true) AND scored_to_user_id = :user_id` |
| **Calculation** | SUM of final_premium |
| **Data Type** | SUM |
| **Period** | Monthly |
| **Default Target** | Rp 500.000.000 per month |
| **Weight** | 2.0 (highest weight) |
| **Unit** | IDR |
| **Template Type** | `pipeline_revenue` |

**Template Config:**
```json
{
  "stage": "ACCEPTED",
  "revenue_field": "final_premium",
  "filters": {}
}
```

**SQL Query:**
```sql
SELECT COALESCE(SUM(final_premium), 0) as premium_won
FROM pipelines
WHERE scored_to_user_id = :user_id
  AND stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
  AND closed_at >= :period_start
  AND closed_at < :period_end;
```

> **Note:** Uses `scored_to_user_id` (not `assigned_rm_id`) to credit the user who won the pipeline. Uses `stage_id` (UUID) with join to `pipeline_stages.is_won` flag.

---

### LAG-003: Conversion Rate (Win Rate)

| Attribute | Value |
|-----------|-------|
| **Code** | `LAG-003` |
| **Name** | Conversion Rate |
| **Category** | LAG |
| **Description** | Persentase pipeline yang berhasil closing vs total closed |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `scored_to_user_id = :user_id AND closed_at IS NOT NULL` |
| **Calculation** | (COUNT WON / COUNT ALL CLOSED) × 100 |
| **Data Type** | PERCENTAGE |
| **Period** | Monthly |
| **Default Target** | 40% |
| **Weight** | 1.0 |
| **Unit** | % |
| **Template Type** | `pipeline_conversion` |

**Template Config:**
```json
{}
```

**SQL Query:**
```sql
SELECT
  CASE WHEN COUNT(*) > 0
  THEN (COUNT(*) FILTER (WHERE stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true))::NUMERIC / COUNT(*)) * 100
  ELSE 0
  END as conversion_rate
FROM pipelines
WHERE scored_to_user_id = :user_id
  AND closed_at >= :period_start
  AND closed_at < :period_end;
```

> **Note:** Uses `scored_to_user_id` (not `assigned_rm_id`) to credit the user who closed the pipeline. Special calculation type that divides won count by total closed count.

---

### LAG-004: Referral Premium (Premium dari Pipeline yang Di-referral)

| Attribute | Value |
|-----------|-------|
| **Code** | `LAG-004` |
| **Name** | Referral Premium |
| **Category** | LAG |
| **Description** | Premium dari pipeline yang di-referral oleh user lain dan won. Dihitung sebagai `final_premium × referral_percentage` untuk partial credit ke referrer. |
| **Source Table** | `pipelines` |
| **Filter Criteria** | `referred_by_user_id = :user_id AND stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)` |
| **Calculation** | SUM(final_premium × referral_percentage) |
| **Data Type** | SUM |
| **Period** | Monthly |
| **Default Target** | Rp 100.000.000 per month |
| **Weight** | 1.5 |
| **Unit** | IDR |
| **Template Type** | `pipeline_revenue` |

**Template Config:**
```json
{
  "stage": "ACCEPTED",
  "revenue_field": "final_premium",
  "filters": {
    "referral": true
  }
}
```

**SQL Query:**
```sql
SELECT COALESCE(SUM(final_premium * referral_percentage), 0) as referral_premium
FROM pipelines
WHERE referred_by_user_id = :user_id
  AND stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
  AND closed_at >= :period_start
  AND closed_at < :period_end;
```

> **Note:** When a pipeline with `referred_by_user_id` set reaches a won stage:
> - The `scored_to_user_id` (closer) gets full PREMIUM_WON credit (LAG-002)
> - The `referred_by_user_id` (referrer) gets partial REFERRAL_PREMIUM credit (LAG-004, percentage-based)

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
