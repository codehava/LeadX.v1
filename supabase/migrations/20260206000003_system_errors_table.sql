-- Create system_errors table for centralized error logging
-- Used by score calculation functions to log errors without breaking transactions

-- Drop table if exists (for idempotency)
DROP TABLE IF EXISTS system_errors;

-- Create system_errors table
CREATE TABLE system_errors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  error_type VARCHAR(50) NOT NULL,
  entity_id UUID,
  error_message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- Create indexes
CREATE INDEX idx_system_errors_unresolved ON system_errors(created_at) WHERE resolved_at IS NULL;
CREATE INDEX idx_system_errors_type ON system_errors(error_type);
CREATE INDEX idx_system_errors_entity ON system_errors(entity_id) WHERE entity_id IS NOT NULL;

-- Enable RLS
ALTER TABLE system_errors ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Only admins can view/modify errors
CREATE POLICY "Admins can view all errors"
  ON system_errors FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

CREATE POLICY "Admins can resolve errors"
  ON system_errors FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

CREATE POLICY "Admins can delete errors"
  ON system_errors FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

-- NO INSERT policy - system functions insert errors via SECURITY DEFINER

-- Add comments for documentation
COMMENT ON TABLE system_errors IS 'Centralized error logging for system operations (score calculation, cron jobs, etc.). Only accessible to admins.';
COMMENT ON COLUMN system_errors.error_type IS 'Error category: MEASURE_CALC_FAILED, TRIGGER_FAILED, CRON_USER_FAILED, etc.';
COMMENT ON COLUMN system_errors.entity_id IS 'Related entity ID (measure_id, user_id, etc.) if applicable';
COMMENT ON COLUMN system_errors.error_message IS 'Full error message/stack trace';
COMMENT ON COLUMN system_errors.resolved_at IS 'Timestamp when error was marked as resolved (NULL = unresolved)';
COMMENT ON COLUMN system_errors.resolved_by IS 'Admin user who resolved the error';


-- ============================================================================
-- Enhanced calculate_measure_value with Error Logging
-- ============================================================================
-- Update the function to log errors to system_errors table

CREATE OR REPLACE FUNCTION calculate_measure_value(
  p_user_id UUID,
  p_measure_id UUID,
  p_period_id UUID
) RETURNS NUMERIC AS $$
DECLARE
  v_measure RECORD;
  v_period RECORD;
  v_result NUMERIC;
  v_query TEXT;
BEGIN
  -- Get measure definition
  SELECT
    source_table,
    source_condition,
    data_type,
    code
  INTO v_measure
  FROM measure_definitions
  WHERE id = p_measure_id AND is_active = TRUE;

  -- If measure not found or inactive, return 0
  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  -- Get period date range
  SELECT start_date, end_date
  INTO v_period
  FROM scoring_periods
  WHERE id = p_period_id;

  -- If period not found, return 0
  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  -- Build query based on data_type
  BEGIN
    IF v_measure.data_type = 'COUNT' THEN
      -- Count records matching condition
      -- Use appropriate date column based on source table
      IF v_measure.source_table = 'pipeline_stage_history' THEN
        v_query := format(
          'SELECT COUNT(*) FROM %I WHERE %s AND changed_at BETWEEN $1 AND $2',
          v_measure.source_table,
          replace(v_measure.source_condition, ':user_id', '$3')
        );
      ELSE
        v_query := format(
          'SELECT COUNT(*) FROM %I WHERE %s AND created_at BETWEEN $1 AND $2',
          v_measure.source_table,
          replace(v_measure.source_condition, ':user_id', '$3')
        );
      END IF;
      EXECUTE v_query INTO v_result USING v_period.start_date, v_period.end_date, p_user_id;

    ELSIF v_measure.data_type = 'SUM' THEN
      -- Sum a specific field (e.g., final_premium)
      IF v_measure.source_table = 'pipelines' THEN
        -- For pipelines, sum final_premium when closed_at is in the period
        v_query := format(
          'SELECT COALESCE(SUM(final_premium), 0) FROM %I WHERE %s AND closed_at BETWEEN $1 AND $2',
          v_measure.source_table,
          replace(v_measure.source_condition, ':user_id', '$3')
        );
        EXECUTE v_query INTO v_result USING v_period.start_date, v_period.end_date, p_user_id;
      ELSE
        -- Default SUM behavior for other tables
        v_result := 0;
      END IF;

    ELSIF v_measure.data_type = 'PERCENTAGE' THEN
      -- Special calculation for conversion rate
      IF v_measure.source_table = 'pipelines' THEN
        -- Calculate (won pipelines / total closed pipelines) * 100
        v_query := format(
          'SELECT
             CASE WHEN COUNT(*) > 0
             THEN (COUNT(*) FILTER (WHERE stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true))::NUMERIC / COUNT(*)) * 100
             ELSE 0
             END
           FROM %I
           WHERE scored_to_user_id = $1 AND closed_at BETWEEN $2 AND $3',
          v_measure.source_table
        );
        EXECUTE v_query INTO v_result USING p_user_id, v_period.start_date, v_period.end_date;
      ELSE
        v_result := 0;
      END IF;

    ELSE
      -- Unknown data_type, return 0
      v_result := 0;
    END IF;

    RETURN COALESCE(v_result, 0);

  EXCEPTION WHEN OTHERS THEN
    -- Log error to system_errors table
    INSERT INTO system_errors (error_type, entity_id, error_message, created_at)
    VALUES (
      'MEASURE_CALC_FAILED',
      p_measure_id,
      format('Measure %s calculation failed for user %s: %s', v_measure.code, p_user_id, SQLERRM),
      NOW()
    );

    -- Return 0 to avoid breaking the transaction
    RETURN 0;
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
