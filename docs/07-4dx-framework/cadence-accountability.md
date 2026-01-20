# 📅 Cadence of Accountability

## Struktur Meeting Akuntabilitas 4DX LeadX CRM

---

## 📋 Overview

**Discipline 4: Create a Cadence of Accountability** - Setiap tim melakukan proses mingguan sederhana yang fokus pada WIG.

---

## 🏛️ Meeting Hierarchy

| Level | Frequency | Host | Participants | Duration |
|-------|-----------|------|--------------|----------|
| Team Cadence | Weekly (Monday) | BH | RMs | 30 min |
| Branch Cadence | Weekly (Friday) | BM | BHs | 45 min |
| Regional Cadence | Monthly | ROH | BMs | 60 min |
| Company Cadence | Quarterly | Director | ROHs | 90 min |

---

## 📝 Pre-Meeting Form (Q1-Q4)

### Form Questions

| Question | Description | Auto-populated |
|----------|-------------|----------------|
| Q1 | Komitmen minggu lalu | ✅ Yes (from last Q4) |
| Q2 | Apa yang tercapai? | ❌ Manual input |
| Q3 | Hambatan yang dihadapi? | ❌ Manual input |
| Q4 | Komitmen minggu depan? | ❌ Manual input |

### Submission Rules

- **Deadline**: Monday 08:00 (before Team Cadence)
- **On-time**: +1 point
- **Late (within 2 hours)**: 0 points
- **Very late (>2 hours)**: -1 point
- **Not submitted**: -2 points

---

## ⏰ Meeting Flow (30 min)

| Phase | Duration | Activity |
|-------|----------|----------|
| Opening | 2 min | BH opens, reminder Team WIG |
| Account | 10 min | Each RM reports Q2 achievements |
| Review | 8 min | Display scoreboard, celebrate wins, discuss obstacles |
| Plan | 8 min | Each RM shares Q4 commitment |
| Closing | 2 min | Recap, remind next deadline |

---

## 📊 Scoring Impact

### Attendance

| Scenario | Points |
|----------|--------|
| Present | +2 |
| Absent with notice (>24h) | 0 |
| Absent without notice | -3 |

### Commitment Tracking

| Scenario | Points |
|----------|--------|
| Q4 commitment completed | +2 |
| Partially completed | +1 |
| Not completed | 0 |

---

## 🗄️ Database Tables

```sql
CREATE TABLE cadence_schedules (
  id UUID PRIMARY KEY,
  level VARCHAR(20), -- TEAM, BRANCH, REGIONAL, COMPANY
  host_user_id UUID REFERENCES users(id),
  frequency VARCHAR(20), -- WEEKLY, MONTHLY, QUARTERLY
  day_of_week INTEGER,
  start_time TIME,
  duration_minutes INTEGER,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE cadence_meetings (
  id UUID PRIMARY KEY,
  schedule_id UUID REFERENCES cadence_schedules(id),
  meeting_date DATE,
  status VARCHAR(20) DEFAULT 'SCHEDULED'
);

CREATE TABLE cadence_submissions (
  id UUID PRIMARY KEY,
  meeting_id UUID REFERENCES cadence_meetings(id),
  user_id UUID REFERENCES users(id),
  q2_what_achieved TEXT NOT NULL,
  q3_obstacles TEXT,
  q4_next_commitment TEXT NOT NULL,
  submitted_at TIMESTAMPTZ,
  is_on_time BOOLEAN
);

CREATE TABLE cadence_attendance (
  id UUID PRIMARY KEY,
  meeting_id UUID REFERENCES cadence_meetings(id),
  user_id UUID REFERENCES users(id),
  status VARCHAR(20), -- PRESENT, ABSENT, EXCUSED
  score_impact NUMERIC
);
```

---

## 📚 Related Documents

- [4DX Overview](4dx-overview.md)
- [Lead-Lag Measures](lead-lag-measures.md)
- [WIG Management](wig-management.md)

---

*Dokumen ini adalah bagian dari LeadX CRM 4DX Framework Documentation.*
