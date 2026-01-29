# 📅 Cadence Tables

## Database Tables - Cadence Meeting

---

## 📋 Overview

Tables for Cadence of Accountability (4DX Discipline 4). Uses a **combined table approach** where `cadence_participants` contains attendance, form submission, and feedback data for each participant per meeting.

---

## 📊 Tables

### cadence_schedule_config

Global configuration for cadence meeting schedules.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| day_of_week | INTEGER | 0=Sunday, 6=Saturday |
| time_of_day | TIME | Meeting start time |
| duration_minutes | INTEGER | Default 60 |
| pre_meeting_hours | INTEGER | Hours before meeting for form deadline (default 24) |
| is_active | BOOLEAN | Whether schedule is active |
| created_at | TIMESTAMPTZ | Record creation |
| updated_at | TIMESTAMPTZ | Last update |

### cadence_meetings

Individual meeting instances.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| scheduled_at | TIMESTAMPTZ | Meeting date/time |
| host_id | UUID | FK to users (BH/facilitator) |
| meeting_type | VARCHAR(50) | WEEKLY, MONTHLY, etc. |
| status | VARCHAR(20) | SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED |
| notes | TEXT | General meeting notes by host |
| started_at | TIMESTAMPTZ | When meeting actually started |
| ended_at | TIMESTAMPTZ | When meeting ended |
| created_at | TIMESTAMPTZ | Record creation |
| updated_at | TIMESTAMPTZ | Last update |

### cadence_participants

**Combined table** for participant attendance, form submission, and feedback per meeting.

#### Core Fields

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| meeting_id | UUID | FK to cadence_meetings |
| user_id | UUID | FK to users (participant) |
| created_at | TIMESTAMPTZ | Record creation |
| updated_at | TIMESTAMPTZ | Last update |

#### Attendance Fields

| Column | Type | Description |
|--------|------|-------------|
| attendance_status | VARCHAR(20) | PENDING, PRESENT, LATE, EXCUSED, ABSENT |
| arrived_at | TIMESTAMPTZ | When participant joined |
| excused_reason | TEXT | Reason if excused |
| attendance_score_impact | INTEGER | +3 present, +1 late, 0 excused, -5 absent |
| marked_by | UUID | FK to users (host who marked) |
| marked_at | TIMESTAMPTZ | When attendance was marked |

#### Pre-Meeting Form Fields (Q1-Q4)

| Column | Type | Description |
|--------|------|-------------|
| pre_meeting_submitted | BOOLEAN | Whether form was submitted |
| q1_previous_commitment | TEXT | Previous commitment (auto-filled from last Q4) |
| q1_completion_status | VARCHAR(20) | COMPLETED, PARTIAL, NOT_DONE |
| q2_what_achieved | TEXT | What was achieved (required) |
| q3_obstacles | TEXT | Obstacles faced (optional) |
| q4_next_commitment | TEXT | Next period commitment (required) |
| form_submitted_at | TIMESTAMPTZ | When form was submitted |
| form_submission_status | VARCHAR(20) | ON_TIME, LATE, VERY_LATE, NOT_SUBMITTED |
| form_score_impact | INTEGER | +2 on-time, 0 late, -1 very late, -3 not submitted |

#### Host Notes & Feedback Fields

| Column | Type | Description |
|--------|------|-------------|
| host_notes | TEXT | Internal notes by host (not visible to participant) |
| feedback_text | TEXT | Formal feedback visible to participant |
| feedback_given_at | TIMESTAMPTZ | When feedback was first given |
| feedback_updated_at | TIMESTAMPTZ | When feedback was last edited |

#### Sync Fields

| Column | Type | Description |
|--------|------|-------------|
| last_sync_at | TIMESTAMPTZ | Last sync with server |

---

## 📊 Score Impact Summary

### Attendance Scoring

| Status | Points |
|--------|--------|
| PRESENT | +3 |
| LATE | +1 |
| EXCUSED | 0 |
| ABSENT | -5 |

### Form Submission Scoring

| Status | Timing | Points |
|--------|--------|--------|
| ON_TIME | Before deadline | +2 |
| LATE | Within 2 hours after deadline | 0 |
| VERY_LATE | 2+ hours after deadline | -1 |
| NOT_SUBMITTED | Never submitted | -3 |

### Maximum/Minimum Weekly Impact

```
Maximum: +5 points (+2 form + +3 attendance)
Minimum: -8 points (-3 form + -5 absent)
```

---

## 🔗 Relationships

```
cadence_schedule_config
         │
         │ (optional reference)
         ▼
cadence_meetings ◄──────────── cadence_participants
    │                                   │
    │ host_id                          │ user_id
    ▼                                   ▼
  users                               users
```

---

## 📝 Notes

- **Combined Table Approach**: `cadence_participants` combines what could be separate attendance, submissions, and feedback tables into one record per participant per meeting
- **Offline-First**: Single table simplifies sync conflict resolution
- **1:1 Relationship**: One record per participant per meeting (enforced by UNIQUE constraint)
- **JSONB Migration**: Legacy `pre_meeting_data` JSONB field is migrated to explicit Q1-Q4 columns

---

*Cadence Tables v2.0 - January 2025*
