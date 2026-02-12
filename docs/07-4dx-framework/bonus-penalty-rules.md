# 🎯 Bonus & Penalty Rules

## 4DX Scoring Adjustments - LeadX CRM

---

## 📋 Overview

Bonuses and penalties are adjustments to the base 4DX score (Lead × 0.6 + Lag × 0.4) that incentivize desired behaviors and discourage negative ones. These adjustments are calculated **server-side** in PostgreSQL triggers and stored in the `user_score_aggregates` table.

---

## ✅ BONUSES (Added to Score)

### Cadence Attendance: +2.0 points per meeting
**When Awarded:**
- User attends scheduled cadence meeting
- Attendance status marked as "Present" or "Late" (within grace period)

**Not Awarded When:**
- Marked as "Absent"
- Marked as "Excused" (no penalty, but no bonus)

**Example:**
- Weekly cadence meetings: 4 meetings/month
- Perfect attendance: 4 × 2.0 = **+8.0 points**

---

### On-Time Form Submission: +1.0 point per form
**When Awarded:**
- Pre-cadence form (Q1-Q4) submitted before deadline
- Form submission status: "OnTime"

**Not Awarded When:**
- Form submitted late ("Late" or "VeryLate")
- Form not submitted ("NotSubmitted")

**Deadline:**
- Forms due 2 hours before cadence meeting start time

**Example:**
- 4 cadence meetings with on-time submissions
- Total bonus: 4 × 1.0 = **+4.0 points**

---

### Immediate Activity Logging: +4.5 points
**When Awarded:**
- Activity logged within 1 hour of completion
- Activity has `logged_at` timestamp within 1 hour of `end_time`
- Applies to: Customer visits, phone calls, meetings, proposals

**Not Awarded When:**
- Activity logged >1 hour after completion
- Activity scheduled for future (not yet executed)

**Rationale:**
- Immediate logging ensures data accuracy
- Prevents backfilling/gaming the system
- Encourages real-time updates

**Example:**
- Customer visit ends at 14:00
- Logged at 14:30: **+4.5 points** ✓
- Logged at 16:00: **0 points** ✗

**Per Period:**
- Maximum 1 bonus per activity
- If user logs 20 activities immediately in a week: **+90.0 points**

---

### GPS Verified Activity: +2.0 points per activity
**When Awarded:**
- Activity has GPS coordinates captured
- GPS verification flag: `is_gps_verified = true`
- Applies to: Customer visits (in-person activities)

**Not Awarded When:**
- Activity has no GPS data
- Activity type doesn't require GPS (phone calls, emails)

**Rationale:**
- Ensures field activities are actually performed
- Prevents fake activity logging
- Builds customer visit verification trail

**Example:**
- 10 customer visits with GPS in a week
- Total bonus: 10 × 2.0 = **+20.0 points**

---

## ❌ PENALTIES (Subtracted from Score)

### Late Form Submission: -1.0 point per form
**When Applied:**
- Pre-cadence form submitted after deadline but before meeting
- Form submission status: "Late" or "VeryLate"

**Not Applied When:**
- Form submitted on-time
- Form not submitted (different penalty applies)

**Example:**
- 1 late submission in a month
- Penalty: **-1.0 point**

---

### Missed Cadence Meeting: -2.0 points per absence
**When Applied:**
- User marked as "Absent" from cadence meeting
- No valid excuse provided

**Not Applied When:**
- Marked as "Excused" (approved absence)
- Marked as "Present" or "Late"

**Rationale:**
- Cadence accountability meetings are core to 4DX
- Discourages skipping team commitments

**Example:**
- 1 missed meeting in a month
- Penalty: **-2.0 points**

---

### Unverified Activity: -0.5 points per activity
**When Applied:**
- Customer visit activity has no GPS verification
- Activity type requires GPS but `is_gps_verified = false`

**Not Applied When:**
- Activity has GPS verification
- Activity type doesn't require GPS (calls, emails)
- GPS not available due to technical issues (grace period)

**Rationale:**
- Mild penalty to encourage GPS usage
- Not as harsh as missing the activity completely

**Example:**
- 5 unverified customer visits in a week
- Penalty: 5 × -0.5 = **-2.5 points**

---

## 🧮 CALCULATION FORMULA

### Final Score Calculation
```
Base Score = (Lead Score × 0.6) + (Lag Score × 0.4)

Total Bonuses =
  (Cadence Attendance × 2.0) +
  (On-Time Submissions × 1.0) +
  (Immediate Loggings × 4.5) +
  (GPS Verifications × 2.0)

Total Penalties =
  (Late Submissions × -1.0) +
  (Missed Cadences × -2.0) +
  (Unverified Activities × -0.5)

Net Adjustment = Total Bonuses + Total Penalties

Final Score = Base Score + Net Adjustment
```

### Score Cap
- Bonuses are uncapped (encourage excellence)
- Final score display capped at 150% for visualization
- Actual score stored without cap for ranking

---

## 📊 EXAMPLE SCENARIOS

### Scenario A: Excellent Performer
**Base Score:** Lead 95%, Lag 85% = (95×0.6 + 85×0.4) = 91.0

**Bonuses:**
- 4 cadence meetings attended: +8.0
- 4 on-time forms: +4.0
- 20 immediate logs: +90.0
- 15 GPS verified visits: +30.0
- **Total Bonuses: +132.0**

**Penalties:**
- None
- **Total Penalties: 0**

**Final Score:** 91.0 + 132.0 = **223.0** (capped at 150% for display)

---

### Scenario B: Average Performer
**Base Score:** Lead 80%, Lag 70% = (80×0.6 + 70×0.4) = 76.0

**Bonuses:**
- 3 cadence meetings attended: +6.0
- 3 on-time forms: +3.0
- 10 immediate logs: +45.0
- 8 GPS verified visits: +16.0
- **Total Bonuses: +70.0**

**Penalties:**
- 1 missed cadence: -2.0
- 1 late form: -1.0
- 5 unverified visits: -2.5
- **Total Penalties: -5.5**

**Final Score:** 76.0 + 70.0 - 5.5 = **140.5**

---

### Scenario C: Struggling Performer
**Base Score:** Lead 60%, Lag 50% = (60×0.6 + 50×0.4) = 56.0

**Bonuses:**
- 2 cadence meetings attended: +4.0
- 1 on-time form: +1.0
- 5 immediate logs: +22.5
- 3 GPS verified visits: +6.0
- **Total Bonuses: +33.5**

**Penalties:**
- 2 missed cadences: -4.0
- 3 late forms: -3.0
- 10 unverified visits: -5.0
- **Total Penalties: -12.0**

**Final Score:** 56.0 + 33.5 - 12.0 = **77.5**

---

## 🎯 IMPLEMENTATION NOTES

### Server-Side Calculation
Bonuses and penalties are calculated **server-side only** via PostgreSQL triggers:

1. **Activity Trigger:** On activity insert/update, check immediate logging and GPS
2. **Cadence Trigger:** On attendance update, check presence and form submission
3. **Period Trigger:** Aggregate bonuses/penalties into `user_score_aggregates`

### Client Display
The Flutter app **reads only** - it displays the bonus/penalty values from the API:
- `PeriodSummary.bonusPoints` - Total bonuses for the period
- `PeriodSummary.penaltyPoints` - Total penalties for the period
- `PeriodSummary.netAdjustment` - Bonuses minus penalties

### Database Tables
- **user_score_aggregates:** Stores `bonus_points` and `penalty_points` columns
- **cadence_attendances:** Tracks attendance status for cadence meetings
- **cadence_form_submissions:** Tracks form submission timing
- **activities:** Tracks GPS verification and logging timestamps

---

## 📚 Related Documents

- [4DX Overview](4dx-overview.md) - Framework overview
- [Scoreboard Design](scoreboard-design.md) - UI specifications
- [Database Schema](../04-database/tables/scoring-4dx.md) - Database tables

---

*Last Updated: February 2026*
