-- Migration: Refactor user_score_snapshots to user_score_aggregates + create snapshot tables
-- Purpose: Rename existing aggregate table and add historical snapshot tables

-- ============================================
-- 1. Rename user_score_snapshots to user_score_aggregates
-- ============================================

ALTER TABLE user_score_snapshots RENAME TO user_score_aggregates;

-- Update primary key constraint
ALTER INDEX IF EXISTS user_score_snapshots_pkey RENAME TO user_score_aggregates_pkey;

-- Update indexes
ALTER INDEX IF EXISTS idx_user_score_snapshots_user RENAME TO idx_user_score_aggregates_user;
ALTER INDEX IF EXISTS idx_user_score_snapshots_period RENAME TO idx_user_score_aggregates_period;

-- ============================================
-- 2. Create new user_score_snapshots table (individual score history)
-- ============================================

CREATE TABLE IF NOT EXISTS user_score_snapshots (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  measure_id UUID REFERENCES measure_definitions(id),
  snapshot_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  target_value DECIMAL(18,2),
  actual_value DECIMAL(18,2),
  percentage DECIMAL(5,2),
  score DECIMAL(10,2),
  rank INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE user_score_snapshots IS 'Historical point-in-time snapshots of individual user_scores';

CREATE INDEX IF NOT EXISTS idx_user_score_snapshots_user ON user_score_snapshots(user_id);
CREATE INDEX IF NOT EXISTS idx_user_score_snapshots_period ON user_score_snapshots(period_id);
CREATE INDEX IF NOT EXISTS idx_user_score_snapshots_at ON user_score_snapshots(snapshot_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_score_snapshots_unique
  ON user_score_snapshots(user_id, period_id, measure_id, snapshot_at);

-- ============================================
-- 3. Create user_score_aggregate_snapshots table
-- ============================================

CREATE TABLE IF NOT EXISTS user_score_aggregate_snapshots (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  period_id UUID REFERENCES scoring_periods(id),
  snapshot_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  lead_score DECIMAL(10,2) DEFAULT 0,
  lag_score DECIMAL(10,2) DEFAULT 0,
  bonus_points DECIMAL(10,2) DEFAULT 0,
  penalty_points DECIMAL(10,2) DEFAULT 0,
  total_score DECIMAL(10,2) DEFAULT 0,
  rank INTEGER,
  rank_change INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE user_score_aggregate_snapshots IS 'Historical point-in-time snapshots of user_score_aggregates';

CREATE INDEX IF NOT EXISTS idx_user_score_aggregate_snapshots_user ON user_score_aggregate_snapshots(user_id);
CREATE INDEX IF NOT EXISTS idx_user_score_aggregate_snapshots_period ON user_score_aggregate_snapshots(period_id);
CREATE INDEX IF NOT EXISTS idx_user_score_aggregate_snapshots_at ON user_score_aggregate_snapshots(snapshot_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_score_aggregate_snapshots_unique
  ON user_score_aggregate_snapshots(user_id, period_id, snapshot_at);

-- ============================================
-- 4. Create snapshot function (called by cron and period lock trigger)
-- ============================================

CREATE OR REPLACE FUNCTION create_score_snapshots(target_period_id UUID)
RETURNS void AS $$
DECLARE
  snapshot_time TIMESTAMPTZ := NOW();
BEGIN
  -- Snapshot individual scores
  INSERT INTO user_score_snapshots (user_id, period_id, measure_id, snapshot_at,
    target_value, actual_value, percentage, score, rank)
  SELECT user_id, period_id, measure_id, snapshot_time,
    target_value, actual_value, percentage, score, rank
  FROM user_scores
  WHERE period_id = target_period_id;

  -- Snapshot aggregates
  INSERT INTO user_score_aggregate_snapshots (user_id, period_id, snapshot_at,
    lead_score, lag_score, bonus_points, penalty_points, total_score, rank, rank_change)
  SELECT user_id, period_id, snapshot_time,
    lead_score, lag_score, bonus_points, penalty_points, total_score, rank, rank_change
  FROM user_score_aggregates
  WHERE period_id = target_period_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_score_snapshots(UUID) IS 'Creates point-in-time snapshots of user scores and aggregates for a given period';

-- ============================================
-- 5. Trigger for automatic snapshot on period lock
-- ============================================

CREATE OR REPLACE FUNCTION on_period_locked()
RETURNS TRIGGER AS $$
BEGIN
  -- When a period becomes locked, create snapshots
  IF NEW.is_locked = true AND (OLD.is_locked IS NULL OR OLD.is_locked = false) THEN
    PERFORM create_score_snapshots(NEW.id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if any
DROP TRIGGER IF EXISTS trigger_period_locked ON scoring_periods;

CREATE TRIGGER trigger_period_locked
AFTER UPDATE ON scoring_periods
FOR EACH ROW
EXECUTE FUNCTION on_period_locked();

-- ============================================
-- 6. RLS policies for new tables
-- ============================================

ALTER TABLE user_score_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_score_aggregate_snapshots ENABLE ROW LEVEL SECURITY;

-- User score snapshots policies (3 separate policies like existing pattern)
CREATE POLICY "user_score_snapshots_admin" ON user_score_snapshots
  USING (is_admin());

CREATE POLICY "user_score_snapshots_select_own" ON user_score_snapshots
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "user_score_snapshots_select_subordinates" ON user_score_snapshots
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_hierarchy
      WHERE user_hierarchy.ancestor_id = auth.uid()
      AND user_hierarchy.descendant_id = user_score_snapshots.user_id
    )
  );

-- Aggregate snapshots policies (same pattern)
CREATE POLICY "user_score_aggregate_snapshots_admin" ON user_score_aggregate_snapshots
  USING (is_admin());

CREATE POLICY "user_score_aggregate_snapshots_select_own" ON user_score_aggregate_snapshots
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "user_score_aggregate_snapshots_select_subordinates" ON user_score_aggregate_snapshots
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_hierarchy
      WHERE user_hierarchy.ancestor_id = auth.uid()
      AND user_hierarchy.descendant_id = user_score_aggregate_snapshots.user_id
    )
  );

-- ============================================
-- 7. Update RLS policies for renamed table
-- ============================================

-- Drop old policies on renamed table (they were renamed with the table)
DROP POLICY IF EXISTS "user_score_snapshots_admin" ON user_score_aggregates;
DROP POLICY IF EXISTS "user_score_snapshots_select_own" ON user_score_aggregates;
DROP POLICY IF EXISTS "user_score_snapshots_select_subordinates" ON user_score_aggregates;

-- Create policies for aggregates table with new names
CREATE POLICY "user_score_aggregates_admin" ON user_score_aggregates
  USING (is_admin());

CREATE POLICY "user_score_aggregates_select_own" ON user_score_aggregates
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "user_score_aggregates_select_subordinates" ON user_score_aggregates
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_hierarchy
      WHERE user_hierarchy.ancestor_id = auth.uid()
      AND user_hierarchy.descendant_id = user_score_aggregates.user_id
    )
  );

-- ============================================
-- 8. Update table comment for renamed table
-- ============================================

COMMENT ON TABLE user_score_aggregates IS 'Real-time aggregated scores per user per period (lead, lag, total scores with ranking)';
