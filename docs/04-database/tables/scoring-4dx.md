# 🏆 Scoring & 4DX Tables

## Database Tables - 4DX Framework

---

## 📋 Overview

Tabel-tabel untuk implementasi 4 Disciplines of Execution.

---

## 📊 Tables

### wigs (Wildly Important Goals)

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| title | VARCHAR(255) | WIG title |
| description | TEXT | Description |
| owner_id | UUID | FK to users |
| level | VARCHAR(20) | COMPANY/REGIONAL/BRANCH/TEAM |
| parent_wig_id | UUID | FK to wigs |
| x_value | DECIMAL | From X |
| y_value | DECIMAL | To Y |
| deadline | DATE | By when |
| status | VARCHAR(20) | Status |

### wig_progress

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| wig_id | UUID | FK to wigs |
| period | DATE | Period date |
| actual_value | DECIMAL | Current value |
| notes | TEXT | Notes |
| created_by | UUID | FK to users |

### user_scores

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | FK to users |
| period_start | DATE | Week start |
| period_end | DATE | Week end |
| lead_score | DECIMAL | Lead measures score |
| lag_score | DECIMAL | Lag measures score |
| bonus_points | DECIMAL | Bonus total |
| penalty_points | DECIMAL | Penalty total |
| final_score | DECIMAL | Final score |

### score_measures

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_score_id | UUID | FK to user_scores |
| measure_type | VARCHAR(20) | LEAD/LAG |
| measure_name | VARCHAR(100) | Measure name |
| target | DECIMAL | Target value |
| actual | DECIMAL | Actual value |
| percentage | DECIMAL | Achievement % |

---

*Scoring Tables - January 2025*
