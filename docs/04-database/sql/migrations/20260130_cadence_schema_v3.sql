-- ============================================
-- LeadX CRM - Cadence Schema Migration v3.0
-- Upgrades cadence tables to support multi-level cadence
-- Run AFTER 03_4dx_system_seed.sql
-- ============================================

-- ============================================
-- 1. BACKUP EXISTING DATA (if any)
-- ============================================
CREATE TABLE IF NOT EXISTS _cadence_backup_schedule_config AS
  SELECT * FROM cadence_schedule_config;
CREATE TABLE IF NOT EXISTS _cadence_backup_meetings AS
  SELECT * FROM cadence_meetings;
CREATE TABLE IF NOT EXISTS _cadence_backup_participants AS
  SELECT * FROM cadence_participants;

-- ============================================
-- 2. DROP OLD TABLES
-- ============================================
DROP TABLE IF EXISTS cadence_participants CASCADE;
DROP TABLE IF EXISTS cadence_meetings CASCADE;
DROP TABLE IF EXISTS cadence_schedule_config CASCADE;

-- ============================================
-- 3. CREATE NEW CADENCE_SCHEDULE_CONFIG
-- ============================================
CREATE TABLE cadence_schedule_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  target_role VARCHAR(20) NOT NULL,      -- Role that attends: RM, BH, BM, ROH
  facilitator_role VARCHAR(20) NOT NULL, -- Role that hosts: BH, BM, ROH, DIRECTOR
  frequency VARCHAR(20) NOT NULL,        -- DAILY, WEEKLY, MONTHLY, QUARTERLY
  day_of_week INTEGER CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday for weekly
  day_of_month INTEGER CHECK (day_of_month >= 1 AND day_of_month <= 31), -- For monthly
  default_time TEXT,                     -- HH:mm format
  duration_minutes INTEGER DEFAULT 60,
  pre_meeting_hours INTEGER DEFAULT 24,  -- Hours before meeting for form deadline
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT cadence_config_frequency_check
    CHECK (frequency IN ('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY')),
  CONSTRAINT cadence_config_target_role_check
    CHECK (target_role IN ('RM', 'BH', 'BM', 'ROH')),
  CONSTRAINT cadence_config_facilitator_role_check
    CHECK (facilitator_role IN ('BH', 'BM', 'ROH', 'DIRECTOR', 'ADMIN'))
);

-- ============================================
-- 4. CREATE NEW CADENCE_MEETINGS
-- ============================================
CREATE TABLE cadence_meetings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  config_id UUID REFERENCES cadence_schedule_config(id),
  title TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL,
  facilitator_id UUID REFERENCES users(id) NOT NULL,
  status VARCHAR(20) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  location TEXT,
  meeting_link TEXT,
  agenda TEXT,
  notes TEXT,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id) NOT NULL,
  is_pending_sync BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_cadence_meetings_config ON cadence_meetings(config_id);
CREATE INDEX idx_cadence_meetings_facilitator ON cadence_meetings(facilitator_id);
CREATE INDEX idx_cadence_meetings_scheduled ON cadence_meetings(scheduled_at);
CREATE INDEX idx_cadence_meetings_status ON cadence_meetings(status);

-- ============================================
-- 5. CREATE NEW CADENCE_PARTICIPANTS
-- ============================================
CREATE TABLE cadence_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meeting_id UUID REFERENCES cadence_meetings(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) NOT NULL,

  -- Attendance (marked by host during meeting)
  attendance_status VARCHAR(20) DEFAULT 'PENDING' CHECK (attendance_status IN ('PENDING', 'PRESENT', 'LATE', 'EXCUSED', 'ABSENT')),
  arrived_at TIMESTAMPTZ,
  excused_reason TEXT,
  attendance_score_impact INTEGER,       -- +3 present, +1 late, 0 excused, -5 absent
  marked_by UUID REFERENCES users(id),
  marked_at TIMESTAMPTZ,

  -- Pre-meeting form (Q1-Q4)
  pre_meeting_submitted BOOLEAN DEFAULT false,
  q1_previous_commitment TEXT,           -- Auto-filled from last meeting's Q4
  q1_completion_status VARCHAR(20) CHECK (q1_completion_status IN ('COMPLETED', 'PARTIAL', 'NOT_DONE')),
  q2_what_achieved TEXT,                 -- Required
  q3_obstacles TEXT,                     -- Optional
  q4_next_commitment TEXT,               -- Required
  form_submitted_at TIMESTAMPTZ,
  form_submission_status VARCHAR(20) CHECK (form_submission_status IN ('ON_TIME', 'LATE', 'VERY_LATE', 'NOT_SUBMITTED')),
  form_score_impact INTEGER,             -- +2 on-time, 0 late, -1 very late, -3 not submitted

  -- Host notes & feedback
  host_notes TEXT,                       -- Internal notes (not visible to participant)
  feedback_text TEXT,                    -- Formal feedback visible to participant
  feedback_given_at TIMESTAMPTZ,
  feedback_updated_at TIMESTAMPTZ,

  -- Sync
  is_pending_sync BOOLEAN DEFAULT false,
  last_sync_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(meeting_id, user_id)
);

CREATE INDEX idx_cadence_participants_meeting ON cadence_participants(meeting_id);
CREATE INDEX idx_cadence_participants_user ON cadence_participants(user_id);
CREATE INDEX idx_cadence_participants_attendance ON cadence_participants(attendance_status);
CREATE INDEX idx_cadence_participants_form_status ON cadence_participants(form_submission_status);

-- ============================================
-- 6. CREATE UPDATE TRIGGERS
-- ============================================
CREATE TRIGGER cadence_schedule_config_updated_at
  BEFORE UPDATE ON cadence_schedule_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER cadence_meetings_updated_at
  BEFORE UPDATE ON cadence_meetings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER cadence_participants_updated_at
  BEFORE UPDATE ON cadence_participants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- 7. SEED DEFAULT CONFIGS
-- ============================================
INSERT INTO cadence_schedule_config (
  name, description, target_role, facilitator_role,
  frequency, day_of_week, default_time, duration_minutes,
  pre_meeting_hours, is_active
) VALUES
-- Team Cadence: BH hosts RMs, Weekly Monday 09:00
(
  'Team Cadence',
  'Weekly team accountability meeting',
  'RM', 'BH', 'WEEKLY', 1, '09:00', 30, 24, true
),
-- Branch Cadence: BM hosts BHs, Weekly Friday 09:00
(
  'Branch Cadence',
  'Weekly branch review meeting',
  'BH', 'BM', 'WEEKLY', 5, '09:00', 45, 24, true
),
-- Regional Cadence: ROH hosts BMs, Monthly last Friday 14:00
(
  'Regional Cadence',
  'Monthly regional review meeting',
  'BM', 'ROH', 'MONTHLY', 5, '14:00', 60, 24, true
),
-- Company Cadence: Director hosts ROHs, Quarterly 1st Monday 09:00
(
  'Company Cadence',
  'Quarterly company review meeting',
  'ROH', 'DIRECTOR', 'QUARTERLY', 1, '09:00', 90, 48, true
);

-- ============================================
-- 8. ADD COMMENTS
-- ============================================
COMMENT ON TABLE cadence_schedule_config IS 'Configuration for cadence meeting schedules per organizational level';
COMMENT ON COLUMN cadence_schedule_config.target_role IS 'Role that attends: RM, BH, BM, ROH';
COMMENT ON COLUMN cadence_schedule_config.facilitator_role IS 'Role that hosts: BH, BM, ROH, DIRECTOR';
COMMENT ON COLUMN cadence_schedule_config.frequency IS 'DAILY, WEEKLY, MONTHLY, QUARTERLY';
COMMENT ON COLUMN cadence_schedule_config.pre_meeting_hours IS 'Hours before meeting for form submission deadline';

COMMENT ON TABLE cadence_meetings IS 'Individual cadence meeting instances';
COMMENT ON COLUMN cadence_meetings.facilitator_id IS 'Host/supervisor who runs the meeting';
COMMENT ON COLUMN cadence_meetings.completed_at IS 'When meeting ended (formerly ended_at)';

COMMENT ON TABLE cadence_participants IS 'Combined table for attendance, form submission, and feedback';
COMMENT ON COLUMN cadence_participants.attendance_score_impact IS '+3 present, +1 late, 0 excused, -5 absent';
COMMENT ON COLUMN cadence_participants.form_score_impact IS '+2 on-time, 0 late, -1 very late, -3 not submitted';
COMMENT ON COLUMN cadence_participants.q1_previous_commitment IS 'Auto-filled from previous meeting Q4';

-- ============================================
-- 9. CLEANUP BACKUP TABLES (optional - run manually after verification)
-- ============================================
-- DROP TABLE IF EXISTS _cadence_backup_schedule_config;
-- DROP TABLE IF EXISTS _cadence_backup_meetings;
-- DROP TABLE IF EXISTS _cadence_backup_participants;

-- ============================================
-- END MIGRATION
-- ============================================
