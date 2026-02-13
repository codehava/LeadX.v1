-- ============================================
-- LeadX CRM - Schema Part 3: 4DX, Cadence, System + Seed Data
-- Run this THIRD after 02_business_data.sql
-- ============================================

-- ============================================
-- 4DX SCORING TABLES
-- ============================================

CREATE TABLE scoring_periods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  period_type VARCHAR(20) NOT NULL CHECK (period_type IN ('WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_current BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enforce one current period per period_type (allows simultaneous WEEKLY + QUARTERLY current periods)
CREATE UNIQUE INDEX idx_scoring_periods_one_current_per_type
  ON scoring_periods (period_type)
  WHERE is_current = TRUE;

CREATE TABLE measure_definitions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  measure_type VARCHAR(20) NOT NULL CHECK (measure_type IN ('LEAD', 'LAG')),
  data_type VARCHAR(20) NOT NULL DEFAULT 'COUNT' CHECK (data_type IN ('COUNT', 'SUM', 'PERCENTAGE')),
  unit VARCHAR(50) NOT NULL,
  calculation_method VARCHAR(50),
  calculation_formula TEXT,           -- For computed measures
  source_table VARCHAR(50),           -- Auto-pull from table (activities, pipelines, customers, pipeline_stage_history)
  source_condition TEXT,              -- WHERE clause for source (uses UUIDs for FK columns, :user_id placeholder)
  weight DECIMAL(5, 2) DEFAULT 1.0,
  default_target DECIMAL(18, 2),      -- Default target value
  period_type VARCHAR(20) DEFAULT 'WEEKLY' CHECK (period_type IN ('WEEKLY', 'MONTHLY', 'QUARTERLY')),
  template_type VARCHAR(50),          -- Template used (activity_count, pipeline_count, pipeline_revenue, stage_milestone, etc.)
  template_config JSONB,              -- Original template selections for editing
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_measures_template_type ON measure_definitions(template_type);

CREATE TABLE user_targets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  measure_id UUID REFERENCES measure_definitions(id),
  target_value DECIMAL(18, 2) NOT NULL,
  assigned_by UUID REFERENCES users(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, period_id, measure_id)
);

CREATE INDEX idx_user_targets_user ON user_targets(user_id);
CREATE INDEX idx_user_targets_period ON user_targets(period_id);

CREATE TABLE user_scores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  measure_id UUID REFERENCES measure_definitions(id),
  target_value DECIMAL(18, 2) NOT NULL,    -- Denormalized for efficiency
  actual_value DECIMAL(18, 2) DEFAULT 0,
  percentage DECIMAL(5, 2) DEFAULT 0,      -- (actual/target)*100, capped at 150
  score DECIMAL(10, 2) DEFAULT 0,          -- Weighted score
  rank INTEGER,
  calculated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, period_id, measure_id)
);

CREATE INDEX idx_user_scores_user ON user_scores(user_id);
CREATE INDEX idx_user_scores_period ON user_scores(period_id);
CREATE INDEX idx_user_scores_measure ON user_scores(measure_id);

-- Real-time aggregated scores (synced to local SQLite)
CREATE TABLE user_score_aggregates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  lead_score DECIMAL(10, 2) DEFAULT 0,     -- Average of lead measure achievements (60%)
  lag_score DECIMAL(10, 2) DEFAULT 0,      -- Average of lag measure achievements (40%)
  bonus_points DECIMAL(10, 2) DEFAULT 0,   -- Cadence, immediate logging, etc.
  penalty_points DECIMAL(10, 2) DEFAULT 0, -- Absences, late submissions, etc.
  total_score DECIMAL(10, 2) DEFAULT 0,    -- (lead*0.6 + lag*0.4) + bonus - penalty
  rank INTEGER,
  rank_change INTEGER,                      -- +/- from previous period
  calculated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, period_id)
);

CREATE INDEX idx_user_score_aggregates_user ON user_score_aggregates(user_id);
CREATE INDEX idx_user_score_aggregates_period ON user_score_aggregates(period_id);

-- Historical snapshots of individual scores (server-only)
CREATE TABLE user_score_snapshots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  measure_id UUID REFERENCES measure_definitions(id),
  snapshot_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  target_value DECIMAL(18, 2),
  actual_value DECIMAL(18, 2),
  percentage DECIMAL(5, 2),
  score DECIMAL(10, 2),
  rank INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_score_snapshots_user ON user_score_snapshots(user_id);
CREATE INDEX idx_user_score_snapshots_period ON user_score_snapshots(period_id);
CREATE INDEX idx_user_score_snapshots_at ON user_score_snapshots(snapshot_at);

-- Historical snapshots of aggregated scores (server-only)
CREATE TABLE user_score_aggregate_snapshots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  snapshot_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  lead_score DECIMAL(10, 2) DEFAULT 0,
  lag_score DECIMAL(10, 2) DEFAULT 0,
  bonus_points DECIMAL(10, 2) DEFAULT 0,
  penalty_points DECIMAL(10, 2) DEFAULT 0,
  total_score DECIMAL(10, 2) DEFAULT 0,
  rank INTEGER,
  rank_change INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_score_aggregate_snapshots_user ON user_score_aggregate_snapshots(user_id);
CREATE INDEX idx_user_score_aggregate_snapshots_period ON user_score_aggregate_snapshots(period_id);
CREATE INDEX idx_user_score_aggregate_snapshots_at ON user_score_aggregate_snapshots(snapshot_at);

-- ============================================
-- CADENCE TABLES
-- ============================================

-- Cadence schedule configuration per level (Team/Branch/Regional/Company)
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

-- Cadence meeting instances
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

-- Cadence participants - combined table for attendance, form, and feedback
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
-- NOTIFICATIONS & ANNOUNCEMENTS
-- ============================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  title VARCHAR(200) NOT NULL,
  body TEXT,
  notification_type VARCHAR(50) NOT NULL,
  reference_type VARCHAR(50),
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;

CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  priority VARCHAR(20) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
  target_roles TEXT[],
  target_branches UUID[],
  start_at TIMESTAMPTZ DEFAULT NOW(),
  end_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE announcement_reads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  announcement_id UUID REFERENCES announcements(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(announcement_id, user_id)
);

-- ============================================
-- SYSTEM TABLES
-- ============================================

CREATE TABLE sync_queue_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_name VARCHAR(50) NOT NULL,
  record_id UUID NOT NULL,
  operation VARCHAR(20) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  payload JSONB,
  status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED')),
  retry_count INTEGER DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  synced_at TIMESTAMPTZ
);

CREATE INDEX idx_sync_queue_pending ON sync_queue_items(status) WHERE status = 'PENDING';

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  user_email VARCHAR(255),
  action VARCHAR(50) NOT NULL,
  target_table VARCHAR(50),
  target_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE app_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT,
  value_type VARCHAR(20) DEFAULT 'STRING' CHECK (value_type IN ('STRING', 'NUMBER', 'BOOLEAN', 'JSON')),
  description TEXT,
  is_editable BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SEED DATA
-- ============================================

-- Company Types
INSERT INTO company_types (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'PT', 'Perseroan Terbatas', 1),
  (uuid_generate_v4(), 'CV', 'Commanditaire Vennootschap', 2),
  (uuid_generate_v4(), 'UD', 'Usaha Dagang', 3),
  (uuid_generate_v4(), 'PERORANGAN', 'Perorangan', 4),
  (uuid_generate_v4(), 'KOPERASI', 'Koperasi', 5),
  (uuid_generate_v4(), 'YAYASAN', 'Yayasan', 6),
  (uuid_generate_v4(), 'BUMN', 'BUMN', 7),
  (uuid_generate_v4(), 'BUMD', 'BUMD', 8);

-- Ownership Types
INSERT INTO ownership_types (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'BUMN', 'BUMN', 1),
  (uuid_generate_v4(), 'BUMD', 'BUMD', 2),
  (uuid_generate_v4(), 'SWASTA', 'Swasta Nasional', 3),
  (uuid_generate_v4(), 'ASING', 'Swasta Asing', 4),
  (uuid_generate_v4(), 'CAMPURAN', 'Campuran', 5);

-- Lead Sources
INSERT INTO lead_sources (id, code, name, requires_referrer, requires_broker) VALUES
  (uuid_generate_v4(), 'COLD_CALL', 'Cold Call', false, false),
  (uuid_generate_v4(), 'REFERRAL', 'Referral', true, false),
  (uuid_generate_v4(), 'BROKER', 'Broker', false, true),
  (uuid_generate_v4(), 'EXISTING', 'Existing Customer', false, false),
  (uuid_generate_v4(), 'TENDER', 'Tender', false, false),
  (uuid_generate_v4(), 'WALK_IN', 'Walk In', false, false);

-- Pipeline Stages
INSERT INTO pipeline_stages (id, code, name, probability, sequence, color, is_final, is_won) VALUES
  (uuid_generate_v4(), 'NEW', 'New Lead', 10, 0, '#6366F1', false, false),
  (uuid_generate_v4(), 'P3', 'P3 - Prospecting', 25, 1, '#9CA3AF', false, false),
  (uuid_generate_v4(), 'P2', 'P2 - Negotiation', 50, 2, '#F59E0B', false, false),
  (uuid_generate_v4(), 'P1', 'P1 - Proposal', 75, 3, '#3B82F6', false, false),
  (uuid_generate_v4(), 'ACCEPTED', 'Accepted', 100, 4, '#10B981', true, true),
  (uuid_generate_v4(), 'DECLINED', 'Declined', 0, 5, '#EF4444', true, false);

-- Activity Types
INSERT INTO activity_types (id, code, name, icon, require_location, require_photo, require_notes) VALUES
  (uuid_generate_v4(), 'VISIT', 'Kunjungan', 'location_on', true, true, false),
  (uuid_generate_v4(), 'CALL', 'Telepon', 'phone', false, false, false),
  (uuid_generate_v4(), 'MEETING', 'Meeting', 'groups', true, false, true),
  (uuid_generate_v4(), 'EMAIL', 'Email', 'email', false, false, false),
  (uuid_generate_v4(), 'PRESENTATION', 'Presentasi', 'slideshow', true, false, true),
  (uuid_generate_v4(), 'FOLLOW_UP', 'Follow Up', 'replay', false, false, true);

-- HVC Types
INSERT INTO hvc_types (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'KONGLOMERAT', 'Konglomerat', 1),
  (uuid_generate_v4(), 'HOLDING', 'Holding Company', 2),
  (uuid_generate_v4(), 'GROUP', 'Business Group', 3),
  (uuid_generate_v4(), 'ASOSIASI', 'Asosiasi', 4);

-- COBs
INSERT INTO cobs (id, code, name, sort_order) VALUES
  (uuid_generate_v4(), 'SB', 'Surety Bond', 1),
  (uuid_generate_v4(), 'KI', 'Kredit Investasi', 2),
  (uuid_generate_v4(), 'GI', 'General Insurance', 3);

-- ============================================
-- MEASURE DEFINITIONS SEED DATA (4DX)
-- ============================================
-- 10 measures total: 6 LEAD (60% weight) + 4 LAG (40% weight)
-- NOTE: This is DOCUMENTATION ONLY - actual seed in supabase/migrations/20260205100000_seed_default_measures.sql
-- UUIDs are fetched dynamically from activity_types and pipeline_stages master tables

-- Lead Measures (60% of total score) - Activities that drive results
DO $$
DECLARE
  v_visit_type_id UUID;
  v_call_type_id UUID;
  v_meeting_type_id UUID;
BEGIN
  -- Fetch activity type UUIDs from master data
  SELECT id INTO v_visit_type_id FROM activity_types WHERE code = 'VISIT';
  SELECT id INTO v_call_type_id FROM activity_types WHERE code = 'CALL';
  SELECT id INTO v_meeting_type_id FROM activity_types WHERE code = 'MEETING';

  INSERT INTO measure_definitions (code, name, measure_type, source_table, source_condition, data_type, default_target, weight, period_type, unit, template_type, template_config, is_active) VALUES
    -- LEAD-001: Visit Count
    ('LEAD-001', 'Visit Count', 'LEAD', 'activities',
     'activity_type_id = ''' || v_visit_type_id || ''' AND status = ''COMPLETED''',
     'COUNT', 10, 1.0, 'WEEKLY', 'count', 'activity_count',
     '{"activity_types":["VISIT"],"statuses":["COMPLETED"],"customer_type":null}', TRUE),

    -- LEAD-002: Call Count
    ('LEAD-002', 'Call Count', 'LEAD', 'activities',
     'activity_type_id = ''' || v_call_type_id || ''' AND status = ''COMPLETED''',
     'COUNT', 20, 1.0, 'WEEKLY', 'count', 'activity_count',
     '{"activity_types":["CALL"],"statuses":["COMPLETED"],"customer_type":null}', TRUE),

    -- LEAD-003: Meeting Count
    ('LEAD-003', 'Meeting Count', 'LEAD', 'activities',
     'activity_type_id = ''' || v_meeting_type_id || ''' AND status = ''COMPLETED''',
     'COUNT', 5, 1.0, 'WEEKLY', 'count', 'activity_count',
     '{"activity_types":["MEETING"],"statuses":["COMPLETED"],"customer_type":null}', TRUE),

    -- LEAD-004: New Customer
    ('LEAD-004', 'New Customer', 'LEAD', 'customers',
     'created_by = :user_id',
     'COUNT', 4, 1.5, 'MONTHLY', 'count', 'customer_acquisition',
     '{"customer_types":null,"company_sizes":null}', TRUE),

    -- LEAD-005: New Pipeline
    ('LEAD-005', 'New Pipeline', 'LEAD', 'pipelines',
     'assigned_rm_id = :user_id',
     'COUNT', 5, 1.2, 'MONTHLY', 'count', 'pipeline_count',
     '{"stages":["NEW"],"filters":{}}', TRUE),

    -- LEAD-006: Proposal Sent (stage milestone)
    ('LEAD-006', 'Proposal Sent', 'LEAD', 'pipeline_stage_history',
     'to_stage_id IN (SELECT id FROM pipeline_stages WHERE code = ''P2'') AND changed_by = :user_id',
     'COUNT', 3, 1.3, 'WEEKLY', 'count', 'stage_milestone',
     '{"target_stage":"P2","from_any":true}', TRUE);

  -- Lag Measures (40% of total score) - Results/outcomes
  -- NOTE: Lag measures use scored_to_user_id (not assigned_rm_id) to credit the user
  -- who actually won the pipeline, even if ownership later transferred.
  INSERT INTO measure_definitions (code, name, measure_type, source_table, source_condition, data_type, default_target, weight, period_type, unit, template_type, template_config, is_active) VALUES
    -- LAG-001: Pipeline Won
    ('LAG-001', 'Pipeline Won', 'LAG', 'pipelines',
     'stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true) AND scored_to_user_id = :user_id',
     'COUNT', 3, 1.5, 'MONTHLY', 'count', 'pipeline_count',
     '{"stages":["ACCEPTED"],"filters":{}}', TRUE),

    -- LAG-002: Premium Won
    ('LAG-002', 'Premium Won', 'LAG', 'pipelines',
     'stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true) AND scored_to_user_id = :user_id',
     'SUM', 500000000, 2.0, 'MONTHLY', 'IDR', 'pipeline_revenue',
     '{"stage":"ACCEPTED","revenue_field":"final_premium","filters":{}}', TRUE),

    -- LAG-003: Conversion Rate
    ('LAG-003', 'Conversion Rate', 'LAG', 'pipelines',
     'scored_to_user_id = :user_id AND closed_at IS NOT NULL',
     'PERCENTAGE', 40, 1.0, 'MONTHLY', '%', 'pipeline_conversion',
     '{}', TRUE),

    -- LAG-004: Referral Premium
    ('LAG-004', 'Referral Premium', 'LAG', 'pipelines',
     'referred_by_user_id = :user_id AND stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)',
     'SUM', 100000000, 1.5, 'MONTHLY', 'IDR', 'pipeline_revenue',
     '{"stage":"ACCEPTED","revenue_field":"final_premium","filters":{"referral":true}}', TRUE);

  RAISE NOTICE 'Successfully seeded 10 default measures (6 LEAD + 4 LAG)';
END $$;

-- App Settings
INSERT INTO app_settings (key, value, value_type, description) VALUES
  ('gps_accuracy_threshold', '50', 'NUMBER', 'Maximum GPS accuracy in meters'),
  ('gps_distance_threshold', '100', 'NUMBER', 'Maximum distance from target in meters'),
  ('offline_retention_days', '30', 'NUMBER', 'Days to keep offline data'),
  ('sync_interval_minutes', '5', 'NUMBER', 'Background sync interval');

-- ============================================
-- ADDITIONAL MASTER DATA SEED
-- ============================================

-- Provinces (Top 10 Indonesia)
INSERT INTO provinces (id, code, name, is_active) VALUES
  (uuid_generate_v4(), 'JKT', 'DKI Jakarta', true),
  (uuid_generate_v4(), 'JBR', 'Jawa Barat', true),
  (uuid_generate_v4(), 'JTG', 'Jawa Tengah', true),
  (uuid_generate_v4(), 'JTM', 'Jawa Timur', true),
  (uuid_generate_v4(), 'BTN', 'Banten', true),
  (uuid_generate_v4(), 'DIY', 'DI Yogyakarta', true),
  (uuid_generate_v4(), 'SMT', 'Sumatera Utara', true),
  (uuid_generate_v4(), 'SLS', 'Sulawesi Selatan', true),
  (uuid_generate_v4(), 'KTM', 'Kalimantan Timur', true),
  (uuid_generate_v4(), 'BLI', 'Bali', true);

-- Cities (Sample major cities per province)
WITH province_ids AS (
  SELECT id, code FROM provinces
)
INSERT INTO cities (id, code, name, province_id, is_active)
SELECT uuid_generate_v4(), city.code, city.name, p.id, true
FROM province_ids p
CROSS JOIN (VALUES
  ('JKT', 'JKT-PS', 'Jakarta Pusat'),
  ('JKT', 'JKT-BR', 'Jakarta Barat'),
  ('JKT', 'JKT-SL', 'Jakarta Selatan'),
  ('JKT', 'JKT-TM', 'Jakarta Timur'),
  ('JKT', 'JKT-UT', 'Jakarta Utara'),
  ('JBR', 'BDG', 'Bandung'),
  ('JBR', 'BKS', 'Bekasi'),
  ('JBR', 'BGR', 'Bogor'),
  ('JBR', 'DPK', 'Depok'),
  ('JBR', 'CRB', 'Cirebon'),
  ('JTG', 'SMG', 'Semarang'),
  ('JTG', 'SKT', 'Surakarta'),
  ('JTM', 'SBY', 'Surabaya'),
  ('JTM', 'MLG', 'Malang'),
  ('JTM', 'SDJ', 'Sidoarjo'),
  ('BTN', 'TGR', 'Tangerang'),
  ('BTN', 'SRP', 'Tangerang Selatan'),
  ('BTN', 'SRG', 'Serang'),
  ('DIY', 'YGY', 'Yogyakarta'),
  ('DIY', 'SLM', 'Sleman'),
  ('SMT', 'MDN', 'Medan'),
  ('SMT', 'BTM', 'Batam'),
  ('SLS', 'MKS', 'Makassar'),
  ('KTM', 'BPN', 'Balikpapan'),
  ('KTM', 'SMD', 'Samarinda'),
  ('BLI', 'DPS', 'Denpasar'),
  ('BLI', 'GYN', 'Gianyar')
) AS city(prov_code, code, name)
WHERE p.code = city.prov_code;

-- Industries
INSERT INTO industries (id, code, name, sort_order, is_active) VALUES
  (uuid_generate_v4(), 'CONSTRUCTION', 'Konstruksi', 1, true),
  (uuid_generate_v4(), 'MANUFACTURING', 'Manufaktur', 2, true),
  (uuid_generate_v4(), 'TRADING', 'Perdagangan', 3, true),
  (uuid_generate_v4(), 'MINING', 'Pertambangan', 4, true),
  (uuid_generate_v4(), 'OIL_GAS', 'Minyak & Gas', 5, true),
  (uuid_generate_v4(), 'POWER', 'Pembangkit Listrik', 6, true),
  (uuid_generate_v4(), 'TRANSPORTATION', 'Transportasi', 7, true),
  (uuid_generate_v4(), 'INFRASTRUCTURE', 'Infrastruktur', 8, true),
  (uuid_generate_v4(), 'PROPERTY', 'Properti', 9, true),
  (uuid_generate_v4(), 'TELECOMMUNICATION', 'Telekomunikasi', 10, true),
  (uuid_generate_v4(), 'FINANCIAL', 'Keuangan', 11, true),
  (uuid_generate_v4(), 'AGRICULTURE', 'Pertanian', 12, true),
  (uuid_generate_v4(), 'HEALTHCARE', 'Kesehatan', 13, true),
  (uuid_generate_v4(), 'RETAIL', 'Ritel', 14, true),
  (uuid_generate_v4(), 'HOSPITALITY', 'Perhotelan', 15, true),
  (uuid_generate_v4(), 'EDUCATION', 'Pendidikan', 16, true),
  (uuid_generate_v4(), 'GOVERNMENT', 'Pemerintahan', 17, true),
  (uuid_generate_v4(), 'OTHERS', 'Lainnya', 99, true);

-- LOBs (Line of Business per COB)
INSERT INTO lobs (id, cob_id, code, name, description, sort_order, is_active)
SELECT 
  uuid_generate_v4(), 
  c.id, 
  lob.code, 
  lob.name, 
  lob.description, 
  lob.sort_order, 
  true
FROM cobs c
CROSS JOIN (VALUES
  ('SB', 'KU', 'Kontra Bank Uang Muka', 'Jaminan uang muka', 1),
  ('SB', 'KP', 'Kontra Bank Pelaksanaan', 'Jaminan pelaksanaan', 2),
  ('SB', 'KPM', 'Kontra Bank Pemeliharaan', 'Jaminan pemeliharaan', 3),
  ('SB', 'PN', 'Jaminan Penawaran', 'Jaminan penawaran tender', 4),
  ('SB', 'PB', 'Jaminan Pembayaran', 'Jaminan pembayaran', 5),
  ('SB', 'BEA', 'Customs Bond', 'Jaminan kepabeanan', 6),
  ('KI', 'EQUIPMENT', 'Kredit Alat Berat', 'Kredit pembelian alat berat', 1),
  ('KI', 'PROPERTY', 'Kredit Properti', 'Kredit properti komersial', 2),
  ('KI', 'VEHICLE', 'Kredit Kendaraan', 'Kredit kendaraan operasional', 3),
  ('GI', 'FIRE', 'Fire Insurance', 'Asuransi kebakaran', 1),
  ('GI', 'CAR', 'Contractor All Risk', 'Asuransi proyek konstruksi', 2),
  ('GI', 'EAR', 'Erection All Risk', 'Asuransi pemasangan mesin', 3),
  ('GI', 'MARINE', 'Marine Cargo', 'Asuransi pengiriman barang', 4),
  ('GI', 'LIABILITY', 'Public Liability', 'Asuransi tanggung gugat', 5),
  ('GI', 'MV', 'Motor Vehicle', 'Asuransi kendaraan bermotor', 6),
  ('GI', 'PA', 'Personal Accident', 'Asuransi kecelakaan diri', 7)
) AS lob(cob_code, code, name, description, sort_order)
WHERE c.code = lob.cob_code;

-- Decline Reasons
INSERT INTO decline_reasons (id, code, name, description, sort_order, is_active) VALUES
  (uuid_generate_v4(), 'PRICE', 'Harga Tidak Kompetitif', 'Penolakan karena premi terlalu mahal', 1, true),
  (uuid_generate_v4(), 'COMPETITOR', 'Memilih Pesaing', 'Nasabah memilih asuransi/penjamin lain', 2, true),
  (uuid_generate_v4(), 'NO_BUDGET', 'Tidak Ada Anggaran', 'Nasabah tidak memiliki anggaran', 3, true),
  (uuid_generate_v4(), 'CANCELLED', 'Proyek Dibatalkan', 'Proyek nasabah dibatalkan', 4, true),
  (uuid_generate_v4(), 'DOCUMENT', 'Dokumen Tidak Lengkap', 'Persyaratan dokumen tidak terpenuhi', 5, true),
  (uuid_generate_v4(), 'TIMING', 'Waktu Tidak Sesuai', 'Timing proses tidak sesuai kebutuhan', 6, true),
  (uuid_generate_v4(), 'CREDIT', 'Masalah Kredit/Reasuransi', 'Tidak lolos assessment kredit', 7, true),
  (uuid_generate_v4(), 'RELATIONSHIP', 'Hubungan Dengan Pesaing', 'Sudah memiliki hubungan dengan competitor', 8, true),
  (uuid_generate_v4(), 'OTHER', 'Alasan Lainnya', 'Alasan lain yang tidak termasuk di atas', 99, true);

-- Pipeline Statuses per Stage
INSERT INTO pipeline_statuses (id, stage_id, code, name, description, sequence, is_default, is_active, created_at, updated_at)
SELECT 
  uuid_generate_v4(), 
  ps.id, 
  status.code, 
  status.name, 
  status.description, 
  status.sequence, 
  status.is_default, 
  true,
  NOW(),
  NOW()
FROM pipeline_stages ps
CROSS JOIN (VALUES
  ('NEW', 'NEW_CREATED', 'Baru Dibuat', 'Lead baru ditambahkan ke pipeline', 1, true),
  ('P3', 'P3_NEW', 'Baru Diinput', 'Lead baru ditambahkan', 1, true),
  ('P3', 'P3_CONTACTED', 'Sudah Dihubungi', 'Sudah melakukan kontak awal', 2, false),
  ('P3', 'P3_MEETING', 'Jadwal Meeting', 'Ada jadwal pertemuan', 3, false),
  ('P2', 'P2_QUOTATION', 'Quotation Sent', 'Penawaran sudah dikirim', 1, true),
  ('P2', 'P2_NEGOTIATING', 'Negosiasi', 'Dalam proses negosiasi harga/syarat', 2, false),
  ('P2', 'P2_REVISION', 'Revisi Penawaran', 'Ada revisi penawaran', 3, false),
  ('P1', 'P1_PROPOSAL', 'Proposal Submitted', 'Proposal final sudah disubmit', 1, true),
  ('P1', 'P1_WAITING', 'Menunggu Keputusan', 'Menunggu keputusan nasabah', 2, false),
  ('P1', 'P1_FINAL', 'Final Review', 'Review akhir sebelum keputusan', 3, false),
  ('ACCEPTED', 'ACCEPTED_ACTIVE', 'Aktif', 'Polis/Jaminan aktif', 1, true),
  ('DECLINED', 'DECLINED_CLOSED', 'Closed Lost', 'Pipeline ditolak', 1, true)
) AS status(stage_code, code, name, description, sequence, is_default)
WHERE ps.code = status.stage_code;

-- ============================================
-- END PART 3
-- ============================================
