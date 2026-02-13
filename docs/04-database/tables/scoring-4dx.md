# 🏆 Scoring & 4DX Tables

## Database Tables - 4DX Framework

---

## 📋 Overview

Tabel-tabel untuk implementasi 4 Disciplines of Execution. Schema ini konsisten dengan:
- SQL: `docs/04-database/sql/03_4dx_system_seed.sql`
- Drift: `lib/data/database/tables/scoring.dart`
- Dokumentasi: `docs/07-4dx-framework/`

---

## 📊 4DX Scoring Tables

### measure_definitions

Definisi measure untuk lead & lag metrics. Uses template-based configuration for admin UI.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(20) | Unique code (LEAD-001, LEAD-002, LAG-001, etc.) |
| name | VARCHAR(100) | Display name |
| description | TEXT | Detail description |
| measure_type | VARCHAR(20) | LEAD or LAG |
| data_type | VARCHAR(20) | COUNT, SUM, PERCENTAGE |
| unit | VARCHAR(50) | Unit (count, IDR, %) |
| calculation_method | VARCHAR(50) | How to calculate |
| calculation_formula | TEXT | Formula for computed measures |
| source_table | VARCHAR(50) | Auto-pull source (activities, pipelines, customers, pipeline_stage_history) |
| source_condition | TEXT | WHERE clause for source (uses UUIDs, :user_id placeholder) |
| weight | DECIMAL(5,2) | Scoring weight (default 1.0) |
| default_target | DECIMAL(18,2) | Default target value |
| period_type | VARCHAR(20) | WEEKLY, MONTHLY, QUARTERLY |
| template_type | VARCHAR(50) | Template used (activity_count, pipeline_count, pipeline_revenue, etc.) |
| template_config | JSONB | Original template selections for editing |
| sort_order | INTEGER | Display order |
| is_active | BOOLEAN | Active flag |

### scoring_periods

Periode scoring (weekly, monthly, quarterly).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | VARCHAR(100) | Period name |
| period_type | VARCHAR(20) | WEEKLY, MONTHLY, QUARTERLY, YEARLY |
| start_date | DATE | Period start |
| end_date | DATE | Period end |
| is_current | BOOLEAN | Current active period (one per period_type, enforced by partial unique index) |
| is_locked | BOOLEAN | Locked prevents changes |
| is_active | BOOLEAN | Active flag |

### user_targets

Target per user per period per measure.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK to users |
| period_id | UUID | FK to scoring_periods |
| measure_id | UUID | FK to measure_definitions |
| target_value | DECIMAL(18,2) | Target value |
| assigned_by | UUID | FK to users (who assigned) |
| assigned_at | TIMESTAMPTZ | When assigned |

### user_scores

Skor aktual per user per period per measure. **Calculated server-side** - client reads only.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK to users |
| period_id | UUID | FK to scoring_periods |
| measure_id | UUID | FK to measure_definitions |
| target_value | DECIMAL(18,2) | Target (denormalized) |
| actual_value | DECIMAL(18,2) | Actual value achieved |
| percentage | DECIMAL(5,2) | (actual/target)*100, capped at 150 |
| score | DECIMAL(10,2) | Weighted score |
| rank | INTEGER | Rank within team |
| calculated_at | TIMESTAMPTZ | When calculated |

**Notes:**
- Multiple activity types can contribute to a single measure through the `source_condition` field in `measure_definitions`
- Discrimination by customer type, broker status, etc. is supported via `source_condition`
- Stage transition tracking uses `pipeline_stage_history` as source table
- RM scores updated immediately via triggers; manager aggregates recalculated every 10 min via cron with dirty user tracking
- **Multi-period scoring:** Each measure scores against the current period matching its `period_type` (e.g., LEAD measures with period_type=WEEKLY score against the current WEEKLY period, LAG measures with period_type=QUARTERLY score against the current QUARTERLY period)

### user_score_aggregates

Real-time aggregated scores per user per period for leaderboard and dashboard display.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK to users |
| period_id | UUID | FK to scoring_periods |
| lead_score | DECIMAL(10,2) | Average lead measure achievements (60%) |
| lag_score | DECIMAL(10,2) | Average lag measure achievements (40%) |
| bonus_points | DECIMAL(10,2) | Cadence, immediate logging, etc. |
| penalty_points | DECIMAL(10,2) | Absences, late submissions, etc. |
| total_score | DECIMAL(10,2) | (lead*0.6 + lag*0.4) + bonus - penalty |
| rank | INTEGER | Rank in period |
| rank_change | INTEGER | +/- from previous period |
| calculated_at | TIMESTAMPTZ | Last calculation timestamp |

### user_score_snapshots (Server-only)

Historical point-in-time snapshots of individual user scores. Created on period lock or scheduled intervals.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK to users |
| period_id | UUID | FK to scoring_periods |
| measure_id | UUID | FK to measure_definitions |
| snapshot_at | TIMESTAMPTZ | When snapshot was taken |
| target_value | DECIMAL(18,2) | Target at snapshot time |
| actual_value | DECIMAL(18,2) | Actual at snapshot time |
| percentage | DECIMAL(5,2) | Achievement percentage |
| score | DECIMAL(10,2) | Weighted score |
| rank | INTEGER | Rank at snapshot time |

### user_score_aggregate_snapshots (Server-only)

Historical point-in-time snapshots of aggregated scores. Created on period lock or scheduled intervals.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK to users |
| period_id | UUID | FK to scoring_periods |
| snapshot_at | TIMESTAMPTZ | When snapshot was taken |
| lead_score | DECIMAL(10,2) | Lead score at snapshot |
| lag_score | DECIMAL(10,2) | Lag score at snapshot |
| bonus_points | DECIMAL(10,2) | Bonus at snapshot |
| penalty_points | DECIMAL(10,2) | Penalty at snapshot |
| total_score | DECIMAL(10,2) | Total score at snapshot |
| rank | INTEGER | Rank at snapshot |
| rank_change | INTEGER | Rank change at snapshot |

---

## 🗂️ Indexes

### idx_scoring_periods_one_current_per_type
```sql
CREATE UNIQUE INDEX idx_scoring_periods_one_current_per_type
  ON scoring_periods (period_type)
  WHERE is_current = TRUE;
```
Partial unique index enforcing at most one current period per `period_type`. Allows simultaneous current WEEKLY + QUARTERLY periods for multi-period scoring.

---

## 📈 Score Calculation

### Multi-Period Scoring

Each measure is scored against the current period matching its `period_type`:
- LEAD measures (period_type=WEEKLY) → scored against the current WEEKLY period
- LAG measures (period_type=QUARTERLY) → scored against the current QUARTERLY period

The **display period** (used for aggregates/leaderboard) is the shortest-granularity current period (WEEKLY < MONTHLY < QUARTERLY < YEARLY).

### Achievement Formula
```
percentage = MIN(150, (actual_value / target_value) × 100)
```
- Capped at 150% to prevent gaming
- 0% if target = 0

### Total Score Formula
```
total_score = (lead_score × 0.6) + (lag_score × 0.4) + bonus_points - penalty_points
```

---

## 🔗 Related Files

- SQL Schema: `docs/04-database/sql/03_4dx_system_seed.sql`
- Drift Tables: `lib/data/database/tables/scoring.dart`
- 4DX Overview: `docs/07-4dx-framework/4dx-overview.md`
- Lead-Lag Measures: `docs/07-4dx-framework/lead-lag-measures.md`

---

*Scoring Tables - Updated February 2026*
