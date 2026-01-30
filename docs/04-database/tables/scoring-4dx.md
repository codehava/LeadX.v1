# 🏆 Scoring & 4DX Tables

## Database Tables - 4DX Framework

---

## 📋 Overview

Tabel-tabel untuk implementasi 4 Disciplines of Execution. Schema ini konsisten dengan:
- SQL: `docs/04-database/sql/03_4dx_system_seed.sql`
- Drift: `lib/data/database/tables/scoring.dart` dan `wigs.dart`
- Dokumentasi: `docs/07-4dx-framework/`

---

## 📊 4DX Scoring Tables

### measure_definitions

Definisi measure untuk lead & lag metrics.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR(20) | Unique code (VISIT_COUNT, PREMIUM_WON, etc.) |
| name | VARCHAR(100) | Display name |
| description | TEXT | Detail description |
| measure_type | VARCHAR(20) | LEAD or LAG |
| data_type | VARCHAR(20) | COUNT, SUM, PERCENTAGE |
| unit | VARCHAR(50) | Unit (visits, IDR, %) |
| calculation_method | VARCHAR(50) | How to calculate |
| calculation_formula | TEXT | Formula for computed measures |
| source_table | VARCHAR(50) | Auto-pull source (activities, pipelines, customers) |
| source_condition | TEXT | WHERE clause for source |
| weight | DECIMAL(5,2) | Scoring weight (default 1.0) |
| default_target | DECIMAL(18,2) | Default target value |
| period_type | VARCHAR(20) | WEEKLY, MONTHLY, QUARTERLY |
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
| is_current | BOOLEAN | Current active period |
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

Skor aktual per user per period per measure.

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

### user_score_snapshots

Agregat skor final per period (untuk history & ranking).

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
| calculated_at | TIMESTAMPTZ | Snapshot timestamp |

---

## 🎯 WIG Tables (Discipline 1)

### wigs (Wildly Important Goals)

Format: "From [baseline] to [target] by [deadline]"

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| title | VARCHAR(200) | WIG title |
| description | TEXT | Description |
| level | VARCHAR(20) | COMPANY, REGIONAL, BRANCH, TEAM |
| owner_id | UUID | FK to users |
| parent_wig_id | UUID | FK to wigs (cascade) |
| measure_type | VARCHAR(20) | LAG or LEAD |
| measure_id | UUID | FK to measure_definitions |
| baseline_value | NUMERIC | From X |
| target_value | NUMERIC | To Y |
| current_value | NUMERIC | Current progress |
| start_date | DATE | Start date |
| end_date | DATE | By when |
| status | VARCHAR(20) | DRAFT, PENDING_APPROVAL, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED |
| submitted_at | TIMESTAMPTZ | When submitted |
| approved_by | UUID | FK to users |
| approved_at | TIMESTAMPTZ | When approved |
| rejection_reason | TEXT | Why rejected |
| last_progress_update | TIMESTAMPTZ | Last update |
| progress_percentage | NUMERIC | Progress % |
| created_by | UUID | FK to users |

### wig_progress

History progress per WIG.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| wig_id | UUID | FK to wigs |
| recorded_date | DATE | Recording date |
| value | NUMERIC | Value at this point |
| progress_percentage | NUMERIC | Calculated % |
| status | VARCHAR(20) | ON_TRACK, AT_RISK, OFF_TRACK |
| notes | TEXT | Notes |
| recorded_by | UUID | FK to users |

---

## 📈 Score Calculation

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

### WIG Status Calculation
```
expected_progress = (days_elapsed / total_days) × 100

ON_TRACK:  ≥ 90% of expected
AT_RISK:   70-89% of expected
OFF_TRACK: < 70% of expected
```

---

## 🔗 Related Files

- SQL Schema: `docs/04-database/sql/03_4dx_system_seed.sql`
- Drift Tables: `lib/data/database/tables/scoring.dart`, `wigs.dart`
- 4DX Overview: `docs/07-4dx-framework/4dx-overview.md`
- WIG Management: `docs/07-4dx-framework/wig-management.md`

---

*Scoring Tables - Updated January 2026*
