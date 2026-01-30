-- ============================================
-- LeadX CRM - 4DX Schema Migration v2.0
-- Adds WIG tables, updates scoring tables to match documentation
-- Run AFTER 03_4dx_system_seed.sql and 04_rls_policies.sql
-- ============================================

-- ============================================
-- 1. UPDATE SCORING_PERIODS
-- ============================================

-- Add WEEKLY to period_type constraint and add is_active column
ALTER TABLE scoring_periods
  DROP CONSTRAINT IF EXISTS scoring_periods_period_type_check;

ALTER TABLE scoring_periods
  ADD CONSTRAINT scoring_periods_period_type_check
  CHECK (period_type IN ('WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'));

ALTER TABLE scoring_periods
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- ============================================
-- 2. UPDATE MEASURE_DEFINITIONS
-- ============================================

-- Add new columns for auto-calculation and configuration
ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS data_type VARCHAR(20) DEFAULT 'COUNT'
    CHECK (data_type IN ('COUNT', 'SUM', 'PERCENTAGE'));

ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS calculation_formula TEXT;

ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS source_table VARCHAR(50);

ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS source_condition TEXT;

ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS default_target DECIMAL(18, 2);

ALTER TABLE measure_definitions
  ADD COLUMN IF NOT EXISTS period_type VARCHAR(20) DEFAULT 'WEEKLY'
    CHECK (period_type IN ('WEEKLY', 'MONTHLY', 'QUARTERLY'));

-- ============================================
-- 3. UPDATE USER_TARGETS
-- ============================================

ALTER TABLE user_targets
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE user_targets
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_user_targets_user ON user_targets(user_id);
CREATE INDEX IF NOT EXISTS idx_user_targets_period ON user_targets(period_id);

-- ============================================
-- 4. UPDATE USER_SCORES
-- ============================================

-- Add target_value for denormalization and calculated_at
ALTER TABLE user_scores
  ADD COLUMN IF NOT EXISTS target_value DECIMAL(18, 2);

ALTER TABLE user_scores
  ADD COLUMN IF NOT EXISTS calculated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE user_scores
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_user_scores_user ON user_scores(user_id);
CREATE INDEX IF NOT EXISTS idx_user_scores_period ON user_scores(period_id);
CREATE INDEX IF NOT EXISTS idx_user_scores_measure ON user_scores(measure_id);

-- ============================================
-- 5. UPDATE USER_SCORE_SNAPSHOTS
-- ============================================

-- Add bonus/penalty columns and rank_change
ALTER TABLE user_score_snapshots
  ADD COLUMN IF NOT EXISTS bonus_points DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE user_score_snapshots
  ADD COLUMN IF NOT EXISTS penalty_points DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE user_score_snapshots
  ADD COLUMN IF NOT EXISTS rank_change INTEGER;

ALTER TABLE user_score_snapshots
  ADD COLUMN IF NOT EXISTS calculated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE user_score_snapshots
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Add unique constraint
ALTER TABLE user_score_snapshots
  DROP CONSTRAINT IF EXISTS user_score_snapshots_user_period_key;

ALTER TABLE user_score_snapshots
  ADD CONSTRAINT user_score_snapshots_user_period_key
  UNIQUE (user_id, period_id);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_user_score_snapshots_user ON user_score_snapshots(user_id);
CREATE INDEX IF NOT EXISTS idx_user_score_snapshots_period ON user_score_snapshots(period_id);

-- ============================================
-- 6. CREATE WIG TABLES
-- ============================================

-- WIGs - Discipline 1: Focus on the Wildly Important
CREATE TABLE IF NOT EXISTS wigs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Basic info
  title VARCHAR(200) NOT NULL,
  description TEXT,

  -- Hierarchy
  level VARCHAR(20) NOT NULL CHECK (level IN ('COMPANY', 'REGIONAL', 'BRANCH', 'TEAM')),
  owner_id UUID NOT NULL REFERENCES users(id),
  parent_wig_id UUID REFERENCES wigs(id),

  -- Measure link
  measure_type VARCHAR(20) CHECK (measure_type IN ('LAG', 'LEAD')),
  measure_id UUID REFERENCES measure_definitions(id),

  -- WIG Statement: "From X to Y by When"
  baseline_value NUMERIC NOT NULL,
  target_value NUMERIC NOT NULL,
  current_value NUMERIC DEFAULT 0,

  -- Timeline
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,

  -- Workflow
  status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'ACTIVE', 'COMPLETED', 'CANCELLED')),
  submitted_at TIMESTAMPTZ,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,

  -- Progress tracking
  last_progress_update TIMESTAMPTZ,
  progress_percentage NUMERIC DEFAULT 0,

  -- Timestamps
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_wigs_owner ON wigs(owner_id);
CREATE INDEX IF NOT EXISTS idx_wigs_level ON wigs(level);
CREATE INDEX IF NOT EXISTS idx_wigs_status ON wigs(status);
CREATE INDEX IF NOT EXISTS idx_wigs_parent ON wigs(parent_wig_id);

-- WIG Progress History
CREATE TABLE IF NOT EXISTS wig_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wig_id UUID NOT NULL REFERENCES wigs(id) ON DELETE CASCADE,
  recorded_date DATE NOT NULL,
  value NUMERIC NOT NULL,
  progress_percentage NUMERIC NOT NULL,
  status VARCHAR(20) CHECK (status IN ('ON_TRACK', 'AT_RISK', 'OFF_TRACK')),
  notes TEXT,
  recorded_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(wig_id, recorded_date)
);

CREATE INDEX IF NOT EXISTS idx_wig_progress_wig ON wig_progress(wig_id);
CREATE INDEX IF NOT EXISTS idx_wig_progress_date ON wig_progress(recorded_date);

-- ============================================
-- 7. ADD TRIGGERS FOR WIG TABLES
-- ============================================

CREATE TRIGGER wigs_updated_at
  BEFORE UPDATE ON wigs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- 8. ADD RLS POLICIES FOR WIG TABLES
-- ============================================

ALTER TABLE wigs ENABLE ROW LEVEL SECURITY;

-- Users can view WIGs they own
CREATE POLICY "wigs_select_own" ON wigs
FOR SELECT USING (owner_id = (SELECT auth.uid()));

-- Users can view WIGs from their organizational level and above
CREATE POLICY "wigs_select_hierarchy" ON wigs
FOR SELECT USING (
  level = 'COMPANY'
  OR (level = 'REGIONAL' AND EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = (SELECT auth.uid())
    AND u.regional_office_id = (SELECT regional_office_id FROM users WHERE id = wigs.owner_id)
  ))
  OR (level = 'BRANCH' AND EXISTS (
    SELECT 1 FROM users u
    WHERE u.id = (SELECT auth.uid())
    AND u.branch_id = (SELECT branch_id FROM users WHERE id = wigs.owner_id)
  ))
  OR EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = wigs.owner_id
    AND descendant_id = (SELECT auth.uid())
  )
);

CREATE POLICY "wigs_insert" ON wigs
FOR INSERT WITH CHECK (
  owner_id = (SELECT auth.uid())
  OR is_admin()
);

CREATE POLICY "wigs_update_own" ON wigs
FOR UPDATE USING (owner_id = (SELECT auth.uid()));

CREATE POLICY "wigs_approve" ON wigs
FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = wigs.owner_id
    AND depth > 0
  )
);

CREATE POLICY "wigs_admin" ON wigs
FOR ALL USING (is_admin());

-- WIG Progress RLS
ALTER TABLE wig_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wig_progress_select" ON wig_progress
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM wigs w
    WHERE w.id = wig_progress.wig_id
    AND (
      w.owner_id = (SELECT auth.uid())
      OR w.level = 'COMPANY'
      OR EXISTS (
        SELECT 1 FROM user_hierarchy
        WHERE ancestor_id = w.owner_id
        AND descendant_id = (SELECT auth.uid())
      )
    )
  )
);

CREATE POLICY "wig_progress_insert" ON wig_progress
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM wigs w
    WHERE w.id = wig_progress.wig_id
    AND w.owner_id = (SELECT auth.uid())
  )
  OR is_admin()
);

CREATE POLICY "wig_progress_admin" ON wig_progress
FOR ALL USING (is_admin());

-- User Score Snapshots RLS
ALTER TABLE user_score_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_score_snapshots_select_own" ON user_score_snapshots
FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY "user_score_snapshots_select_subordinates" ON user_score_snapshots
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = (SELECT auth.uid())
    AND descendant_id = user_score_snapshots.user_id
  )
);

CREATE POLICY "user_score_snapshots_admin" ON user_score_snapshots
FOR ALL USING (is_admin());

-- ============================================
-- 9. UPDATE MEASURE DEFINITIONS SEED DATA
-- ============================================

-- Delete old measure definitions
DELETE FROM measure_definitions WHERE code IN ('VISIT', 'P3_NEW', 'PREMIUM', 'CONVERSION');

-- Insert updated measure definitions with all 9 documented measures
INSERT INTO measure_definitions (id, code, name, description, measure_type, data_type, unit, source_table, source_condition, weight, default_target, period_type, sort_order) VALUES
  -- Lead Measures (60% of total score)
  (uuid_generate_v4(), 'VISIT_COUNT', 'Kunjungan Pelanggan', 'Physical customer visits completed', 'LEAD', 'COUNT', 'visits', 'activities', 'type=VISIT AND status=COMPLETED', 1.0, 10, 'WEEKLY', 1),
  (uuid_generate_v4(), 'CALL_COUNT', 'Telepon', 'Phone calls made to customers', 'LEAD', 'COUNT', 'calls', 'activities', 'type=CALL AND status=COMPLETED', 1.0, 20, 'WEEKLY', 2),
  (uuid_generate_v4(), 'MEETING_COUNT', 'Meeting', 'Meetings conducted with customers', 'LEAD', 'COUNT', 'meetings', 'activities', 'type=MEETING AND status=COMPLETED', 1.0, 5, 'WEEKLY', 3),
  (uuid_generate_v4(), 'NEW_CUSTOMER', 'Pelanggan Baru', 'New customers registered', 'LEAD', 'COUNT', 'customers', 'customers', 'created_by=user_id', 1.0, 4, 'MONTHLY', 4),
  (uuid_generate_v4(), 'NEW_PIPELINE', 'Pipeline Baru', 'New pipelines created', 'LEAD', 'COUNT', 'pipelines', 'pipelines', 'assigned_rm_id=user_id', 1.0, 5, 'MONTHLY', 5),
  (uuid_generate_v4(), 'PROPOSAL_SENT', 'Proposal Terkirim', 'Proposals sent to customers', 'LEAD', 'COUNT', 'proposals', 'activities', 'type=PROPOSAL AND status=COMPLETED', 1.0, 3, 'WEEKLY', 6),
  -- Lag Measures (40% of total score)
  (uuid_generate_v4(), 'PIPELINE_WON', 'Pipeline Closing', 'Pipelines closed as won', 'LAG', 'COUNT', 'deals', 'pipelines', 'stage=ACCEPTED', 1.5, 3, 'MONTHLY', 7),
  (uuid_generate_v4(), 'PREMIUM_WON', 'Premium Closing', 'Total premium from won pipelines', 'LAG', 'SUM', 'IDR', 'pipelines', 'stage=ACCEPTED', 2.0, 500000000, 'MONTHLY', 8),
  (uuid_generate_v4(), 'CONVERSION_RATE', 'Conversion Rate', 'Pipeline win rate percentage', 'LAG', 'PERCENTAGE', '%', 'pipelines', 'is_final=true', 1.5, 40, 'MONTHLY', 9)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  measure_type = EXCLUDED.measure_type,
  data_type = EXCLUDED.data_type,
  unit = EXCLUDED.unit,
  source_table = EXCLUDED.source_table,
  source_condition = EXCLUDED.source_condition,
  weight = EXCLUDED.weight,
  default_target = EXCLUDED.default_target,
  period_type = EXCLUDED.period_type,
  sort_order = EXCLUDED.sort_order,
  updated_at = NOW();

-- ============================================
-- 10. ADD COMMENTS
-- ============================================

COMMENT ON TABLE wigs IS 'Wildly Important Goals - Discipline 1 of 4DX';
COMMENT ON COLUMN wigs.baseline_value IS 'Starting value (From X in WIG statement)';
COMMENT ON COLUMN wigs.target_value IS 'Target value (To Y in WIG statement)';
COMMENT ON COLUMN wigs.end_date IS 'Deadline (By When in WIG statement)';
COMMENT ON COLUMN wigs.status IS 'Workflow: DRAFT -> PENDING_APPROVAL -> APPROVED -> ACTIVE -> COMPLETED';

COMMENT ON TABLE wig_progress IS 'Historical progress tracking for WIGs';
COMMENT ON COLUMN wig_progress.status IS 'ON_TRACK (>=90%), AT_RISK (70-89%), OFF_TRACK (<70%)';

COMMENT ON TABLE measure_definitions IS '4DX Lead and Lag measure definitions';
COMMENT ON COLUMN measure_definitions.weight IS 'Scoring weight - higher = more impact on score';
COMMENT ON COLUMN measure_definitions.source_table IS 'Table to auto-calculate from (activities, pipelines, customers)';
COMMENT ON COLUMN measure_definitions.source_condition IS 'WHERE clause for auto-calculation';

COMMENT ON TABLE user_score_snapshots IS 'Aggregated scores per user per period for historical tracking';
COMMENT ON COLUMN user_score_snapshots.bonus_points IS 'Cadence attendance, immediate logging, etc.';
COMMENT ON COLUMN user_score_snapshots.penalty_points IS 'Absences, late submissions, etc.';
COMMENT ON COLUMN user_score_snapshots.total_score IS '(lead*0.6 + lag*0.4) + bonus - penalty';

-- ============================================
-- END MIGRATION
-- ============================================
