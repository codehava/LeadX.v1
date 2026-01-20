# 📅 Cadence Tables

## Database Tables - Cadence Meeting

---

## 📋 Overview

Tabel-tabel untuk Cadence of Accountability.

---

## 📊 Tables

### cadence_schedules

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| team_id | UUID | Team identifier |
| host_id | UUID | FK to users (BH) |
| day_of_week | INTEGER | 1=Monday, 7=Sunday |
| time | TIME | Meeting time |
| duration_minutes | INTEGER | Duration |
| is_active | BOOLEAN | Status |

### cadence_meetings

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| schedule_id | UUID | FK to cadence_schedules |
| meeting_date | DATE | Meeting date |
| status | VARCHAR(20) | SCHEDULED/COMPLETED/CANCELLED |
| notes | TEXT | Meeting notes |

### cadence_submissions

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| meeting_id | UUID | FK to cadence_meetings |
| user_id | UUID | FK to users |
| submitted_at | TIMESTAMPTZ | Submission time |
| is_on_time | BOOLEAN | Before deadline |
| q1_commitments | JSONB | Previous commitments |
| q2_achievements | TEXT | What achieved |
| q3_obstacles | TEXT | Obstacles faced |
| q4_commitments | JSONB | Next commitments |

### cadence_attendance

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| meeting_id | UUID | FK to cadence_meetings |
| user_id | UUID | FK to users |
| status | VARCHAR(20) | PRESENT/ABSENT/EXCUSED |
| joined_at | TIMESTAMPTZ | Join time |
| left_at | TIMESTAMPTZ | Leave time |

---

*Cadence Tables - January 2025*
