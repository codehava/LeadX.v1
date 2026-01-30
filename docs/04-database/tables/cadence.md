# 📅 Cadence Tables

## Database Tables - Cadence Meeting System

---

## 📋 Overview

Tables for Cadence of Accountability (4DX Discipline 4). Supports multi-level cadence meetings (Team/Branch/Regional/Company) where supervisors (atasan) host meetings for their direct reports.

Uses a **combined table approach** where `cadence_participants` contains attendance, form submission, and feedback data for each participant per meeting.

---

## 📊 Tables

### cadence_schedule_config

Configuration for cadence meeting schedules per organizational level.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| name | VARCHAR(100) | NO | - | Config name (e.g., "Team Cadence") |
| description | TEXT | YES | - | Description of this cadence level |
| target_role | VARCHAR(20) | NO | - | Role that attends: RM, BH, BM, ROH |
| facilitator_role | VARCHAR(20) | NO | - | Role that hosts: BH, BM, ROH, DIRECTOR |
| frequency | VARCHAR(20) | NO | - | DAILY, WEEKLY, MONTHLY, QUARTERLY |
| day_of_week | INTEGER | YES | - | 0=Sunday, 6=Saturday (for weekly) |
| day_of_month | INTEGER | YES | - | 1-31 (for monthly) |
| default_time | TEXT | YES | - | HH:mm format |
| duration_minutes | INTEGER | NO | 60 | Meeting duration |
| pre_meeting_hours | INTEGER | NO | 24 | Hours before meeting for form deadline |
| is_active | BOOLEAN | NO | true | Whether schedule is active |
| created_at | TIMESTAMPTZ | NO | NOW() | Record creation |
| updated_at | TIMESTAMPTZ | NO | NOW() | Last update |

**Cadence Levels:**

| Level | Facilitator Role | Target Role | Frequency | Example Day |
|-------|------------------|-------------|-----------|-------------|
| Team Cadence | BH | RM | WEEKLY | Monday |
| Branch Cadence | BM | BH | WEEKLY | Friday |
| Regional Cadence | ROH | BM | MONTHLY | Last Friday |
| Company Cadence | DIRECTOR | ROH | QUARTERLY | 1st Monday |

### cadence_meetings

Individual meeting instances.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| config_id | UUID | YES | - | FK to cadence_schedule_config |
| title | TEXT | NO | - | Meeting title |
| scheduled_at | TIMESTAMPTZ | NO | - | Meeting date/time |
| duration_minutes | INTEGER | NO | - | Meeting duration |
| facilitator_id | UUID | NO | - | FK to users (host/supervisor) |
| status | VARCHAR(20) | NO | 'SCHEDULED' | SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED |
| location | TEXT | YES | - | Physical location |
| meeting_link | TEXT | YES | - | Virtual meeting URL |
| agenda | TEXT | YES | - | Meeting agenda |
| notes | TEXT | YES | - | General meeting notes by host |
| started_at | TIMESTAMPTZ | YES | - | When meeting actually started |
| completed_at | TIMESTAMPTZ | YES | - | When meeting ended |
| created_by | UUID | NO | - | FK to users |
| is_pending_sync | BOOLEAN | NO | false | Offline sync flag |
| created_at | TIMESTAMPTZ | NO | NOW() | Record creation |
| updated_at | TIMESTAMPTZ | NO | NOW() | Last update |

### cadence_participants

**Combined table** for participant attendance, form submission, and feedback per meeting.

#### Core Fields

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NO | uuid_generate_v4() | Primary key |
| meeting_id | UUID | NO | - | FK to cadence_meetings |
| user_id | UUID | NO | - | FK to users (participant) |
| created_at | TIMESTAMPTZ | NO | NOW() | Record creation |
| updated_at | TIMESTAMPTZ | NO | NOW() | Last update |

#### Attendance Fields

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| attendance_status | VARCHAR(20) | NO | 'PENDING' | PENDING, PRESENT, LATE, EXCUSED, ABSENT |
| arrived_at | TIMESTAMPTZ | YES | - | When participant joined |
| excused_reason | TEXT | YES | - | Reason if excused |
| attendance_score_impact | INTEGER | YES | - | +3 present, +1 late, 0 excused, -5 absent |
| marked_by | UUID | YES | - | FK to users (host who marked) |
| marked_at | TIMESTAMPTZ | YES | - | When attendance was marked |

#### Pre-Meeting Form Fields (Q1-Q4)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| pre_meeting_submitted | BOOLEAN | NO | false | Whether form was submitted |
| q1_previous_commitment | TEXT | YES | - | Previous commitment (auto-filled from last Q4) |
| q1_completion_status | VARCHAR(20) | YES | - | COMPLETED, PARTIAL, NOT_DONE |
| q2_what_achieved | TEXT | YES | - | What was achieved (required) |
| q3_obstacles | TEXT | YES | - | Obstacles faced (optional) |
| q4_next_commitment | TEXT | YES | - | Next period commitment (required) |
| form_submitted_at | TIMESTAMPTZ | YES | - | When form was submitted |
| form_submission_status | VARCHAR(20) | YES | - | ON_TIME, LATE, VERY_LATE, NOT_SUBMITTED |
| form_score_impact | INTEGER | YES | - | +2 on-time, 0 late, -1 very late, -3 not submitted |

#### Host Notes & Feedback Fields

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| host_notes | TEXT | YES | - | Internal notes by host (not visible to participant) |
| feedback_text | TEXT | YES | - | Formal feedback visible to participant |
| feedback_given_at | TIMESTAMPTZ | YES | - | When feedback was first given |
| feedback_updated_at | TIMESTAMPTZ | YES | - | When feedback was last edited |

#### Sync Fields

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| is_pending_sync | BOOLEAN | NO | false | Offline sync flag |
| last_sync_at | TIMESTAMPTZ | YES | - | Last sync with server |

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
         │ config_id
         ▼
cadence_meetings ◄──────────── cadence_participants
    │                                   │
    │ facilitator_id                   │ user_id
    ▼                                   ▼
  users                               users
```

---

## 📝 Notes

- **Multi-Level Support**: `cadence_schedule_config` defines different cadence levels (Team/Branch/Regional/Company) via `target_role` and `facilitator_role`
- **Combined Table Approach**: `cadence_participants` combines what could be separate attendance, submissions, and feedback tables into one record per participant per meeting
- **Offline-First**: Single table simplifies sync conflict resolution; `is_pending_sync` and `last_sync_at` track sync status
- **1:1 Relationship**: One record per participant per meeting (enforced by UNIQUE constraint)
- **Form Deadline**: Calculated as `scheduled_at - pre_meeting_hours` from the config
- **Q1 Auto-Fill**: `q1_previous_commitment` is auto-populated from the participant's `q4_next_commitment` in their previous completed meeting

---

*Cadence Tables v3.0 - January 2026*
