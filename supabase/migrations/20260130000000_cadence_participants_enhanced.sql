-- ============================================
-- LeadX CRM - Cadence Participants Enhancement Migration
-- Run this to add attendance, form submission, and feedback fields
-- ============================================

-- ============================================
-- 1. UPDATE ATTENDANCE_STATUS CONSTRAINT
-- ============================================
-- Drop existing constraint and add new one with LATE status
ALTER TABLE cadence_participants
DROP CONSTRAINT IF EXISTS cadence_participants_attendance_status_check;

ALTER TABLE cadence_participants
ADD CONSTRAINT cadence_participants_attendance_status_check
CHECK (attendance_status IN ('PENDING', 'PRESENT', 'LATE', 'EXCUSED', 'ABSENT'));

-- ============================================
-- 2. ADD ATTENDANCE FIELDS
-- ============================================
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS arrived_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS excused_reason TEXT,
ADD COLUMN IF NOT EXISTS attendance_score_impact INTEGER,
ADD COLUMN IF NOT EXISTS marked_by UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS marked_at TIMESTAMPTZ;

-- ============================================
-- 3. ADD/RENAME PRE-MEETING FORM FIELDS
-- ============================================
-- Rename existing JSONB to explicit Q1-Q4 fields for clarity
-- Keep pre_meeting_data for backward compatibility during migration

-- Q1: Previous commitment (auto-filled from last Q4)
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS q1_previous_commitment TEXT,
ADD COLUMN IF NOT EXISTS q1_completion_status VARCHAR(20); -- COMPLETED, PARTIAL, NOT_DONE

-- Q2: What achieved (required)
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS q2_what_achieved TEXT;

-- Q3: Obstacles (optional)
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS q3_obstacles TEXT;

-- Q4: Next commitment (required)
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS q4_next_commitment TEXT;

-- Form submission tracking
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS form_submission_status VARCHAR(20), -- ON_TIME, LATE, VERY_LATE, NOT_SUBMITTED
ADD COLUMN IF NOT EXISTS form_score_impact INTEGER; -- +2, 0, -1, -3

-- Add constraint for form_submission_status
ALTER TABLE cadence_participants
ADD CONSTRAINT cadence_participants_form_status_check
CHECK (form_submission_status IS NULL OR form_submission_status IN ('ON_TIME', 'LATE', 'VERY_LATE', 'NOT_SUBMITTED'));

-- Add constraint for q1_completion_status
ALTER TABLE cadence_participants
ADD CONSTRAINT cadence_participants_q1_status_check
CHECK (q1_completion_status IS NULL OR q1_completion_status IN ('COMPLETED', 'PARTIAL', 'NOT_DONE'));

-- ============================================
-- 4. ADD HOST NOTES & FEEDBACK FIELDS
-- ============================================
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS host_notes TEXT,
ADD COLUMN IF NOT EXISTS feedback_text TEXT,
ADD COLUMN IF NOT EXISTS feedback_given_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS feedback_updated_at TIMESTAMPTZ;

-- ============================================
-- 5. ADD SYNC FIELDS
-- ============================================
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS last_sync_at TIMESTAMPTZ;

-- ============================================
-- 6. MIGRATE EXISTING JSONB DATA (if any)
-- ============================================
-- Extract Q1-Q4 from pre_meeting_data JSONB if it exists
UPDATE cadence_participants
SET
  q1_previous_commitment = pre_meeting_data->>'q1_previous_commitment',
  q1_completion_status = pre_meeting_data->>'q1_completion_status',
  q2_what_achieved = pre_meeting_data->>'q2_what_achieved',
  q3_obstacles = pre_meeting_data->>'q3_obstacles',
  q4_next_commitment = pre_meeting_data->>'q4_next_commitment'
WHERE pre_meeting_data IS NOT NULL
  AND q2_what_achieved IS NULL;

-- ============================================
-- 7. CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_cadence_participants_meeting
ON cadence_participants(meeting_id);

CREATE INDEX IF NOT EXISTS idx_cadence_participants_user
ON cadence_participants(user_id);

CREATE INDEX IF NOT EXISTS idx_cadence_participants_attendance
ON cadence_participants(attendance_status);

CREATE INDEX IF NOT EXISTS idx_cadence_participants_form_status
ON cadence_participants(form_submission_status);

-- ============================================
-- 8. UPDATE RLS POLICIES FOR NEW FIELDS
-- ============================================
-- Note: RLS policies cannot use OLD/NEW like triggers.
-- Field-level protection (preventing participants from editing attendance/feedback)
-- should be enforced at the application layer or via a trigger.

-- Existing policies from 04_rls_policies.sql handle basic access:
-- - cadence_participants_own: Users can see/update their own participation
-- - cadence_participants_host: Host can manage all participants in their meeting

-- No changes needed to existing policies - they already cover the use cases.
-- The application layer should enforce that:
-- 1. Participants can only update: pre_meeting_submitted, q1-q4 fields, form_submitted_at
-- 2. Hosts can update: attendance_status, attendance_score_impact, host_notes, feedback_text, etc.

-- ============================================
-- 9. ADD COMMENTS FOR DOCUMENTATION
-- ============================================
COMMENT ON COLUMN cadence_participants.attendance_status IS 'PENDING, PRESENT, LATE, EXCUSED, ABSENT';
COMMENT ON COLUMN cadence_participants.attendance_score_impact IS '+3 present, +1 late, 0 excused, -5 absent';
COMMENT ON COLUMN cadence_participants.form_submission_status IS 'ON_TIME, LATE, VERY_LATE, NOT_SUBMITTED';
COMMENT ON COLUMN cadence_participants.form_score_impact IS '+2 on-time, 0 late, -1 very late, -3 not submitted';
COMMENT ON COLUMN cadence_participants.host_notes IS 'Internal notes by host (not visible to participant)';
COMMENT ON COLUMN cadence_participants.feedback_text IS 'Formal feedback visible to participant';
COMMENT ON COLUMN cadence_participants.q1_previous_commitment IS 'Auto-filled from previous meeting Q4';
COMMENT ON COLUMN cadence_participants.q1_completion_status IS 'COMPLETED, PARTIAL, NOT_DONE';
