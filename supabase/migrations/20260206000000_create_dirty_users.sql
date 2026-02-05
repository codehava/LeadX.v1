-- Create dirty_users table for tracking users needing score recalculation
-- This table is used by the score aggregation system to batch-process updates

-- Drop table if exists (for idempotency)
DROP TABLE IF EXISTS dirty_users;

-- Create dirty_users table
CREATE TABLE dirty_users (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  dirtied_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Create index for efficient time-based queries
CREATE INDEX idx_dirty_users_dirtied_at ON dirty_users(dirtied_at);

-- NO RLS - This is a system-only table
-- Users should never directly access this table
-- Access is restricted to SECURITY DEFINER functions and cron jobs

-- Add comment for documentation
COMMENT ON TABLE dirty_users IS 'System table tracking users whose aggregate scores need recalculation. Processed by score-aggregation-cron every 10 minutes.';
COMMENT ON COLUMN dirty_users.user_id IS 'User whose aggregate score needs recalculation (includes their own scores + subordinates)';
COMMENT ON COLUMN dirty_users.dirtied_at IS 'Timestamp when user was marked dirty (for debugging/monitoring)';
