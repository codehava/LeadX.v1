


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."calculate_measure_value"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") RETURNS numeric
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
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
$_$;


ALTER FUNCTION "public"."calculate_measure_value"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."calculate_measure_value"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") IS 'Dynamically calculates measure value from source_table/source_condition. Returns raw value (count, sum, percentage).';



CREATE OR REPLACE FUNCTION "public"."can_access_customer"("p_customer_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM customers c
    WHERE c.id = p_customer_id
    AND (
      c.assigned_rm_id = (SELECT auth.uid())
      OR c.created_by = (SELECT auth.uid())
      OR EXISTS (
        SELECT 1 FROM user_hierarchy
        WHERE ancestor_id = (SELECT auth.uid())
        AND descendant_id = c.assigned_rm_id
      )
      OR is_admin()
    )
  );
$$;


ALTER FUNCTION "public"."can_access_customer"("p_customer_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_score_snapshots"("target_period_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."create_score_snapshots"("target_period_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."create_score_snapshots"("target_period_id" "uuid") IS 'Creates point-in-time snapshots of user scores and aggregates for a given period';



CREATE OR REPLACE FUNCTION "public"."generate_pipeline_code"() RETURNS character varying
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_timestamp BIGINT;
  v_code VARCHAR(20);
BEGIN
  -- Generate code based on milliseconds timestamp (similar to client-side logic)
  v_timestamp := EXTRACT(EPOCH FROM NOW())::BIGINT * 1000;
  v_code := 'PIP' || RIGHT(v_timestamp::TEXT, 8);
  RETURN v_code;
END;
$$;


ALTER FUNCTION "public"."generate_pipeline_code"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_atasan"("p_user_id" "uuid") RETURNS json
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  v_parent_id UUID;
  v_regional_office_id UUID;
  v_result JSON;
BEGIN
  -- Get user's parent_id and regional_office_id
  SELECT parent_id, regional_office_id INTO v_parent_id, v_regional_office_id
  FROM users WHERE id = p_user_id;

  -- If user has a direct atasan, return them
  IF v_parent_id IS NOT NULL THEN
    SELECT json_build_object(
      'approver_id', id,
      'approver_name', name,
      'approver_type', CASE WHEN role = 'ROH' THEN 'ROH' ELSE 'BM' END
    ) INTO v_result
    FROM users
    WHERE id = v_parent_id AND is_active = true;

    IF v_result IS NOT NULL THEN
      RETURN v_result;
    END IF;
  END IF;

  -- Fallback: find ROH by regional_office_id
  IF v_regional_office_id IS NOT NULL THEN
    SELECT json_build_object(
      'approver_id', id,
      'approver_name', name,
      'approver_type', 'ROH'
    ) INTO v_result
    FROM users
    WHERE role = 'ROH' AND is_active = true AND regional_office_id = v_regional_office_id
    LIMIT 1;

    RETURN v_result;
  END IF;

  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."get_user_atasan"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_role"() RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT role FROM users WHERE id = auth.uid();
$$;


ALTER FUNCTION "public"."get_user_role"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_pipeline_won"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Only act when transitioning TO a won stage
  -- Check: new stage is a won stage, old stage was not a won stage (or NULL), and scored_to_user_id not already set
  IF NEW.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
     AND (OLD.stage_id IS NULL OR OLD.stage_id NOT IN (SELECT id FROM pipeline_stages WHERE is_won = true))
     AND NEW.scored_to_user_id IS NULL
  THEN
    NEW.scored_to_user_id := NEW.assigned_rm_id;
    NEW.updated_at := NOW();

    RAISE NOTICE 'Pipeline % won: scored_to_user_id set to %', NEW.id, NEW.scored_to_user_id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_pipeline_won"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_pipeline_won_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF NEW.stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)
     AND NEW.scored_to_user_id IS NULL
  THEN
    NEW.scored_to_user_id := NEW.assigned_rm_id;

    RAISE NOTICE 'Pipeline % created as won: scored_to_user_id set to %', NEW.id, NEW.scored_to_user_id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_pipeline_won_insert"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_referral_approval"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Only act when status changes to BM_APPROVED
  IF NEW.status = 'BM_APPROVED' AND OLD.status != 'BM_APPROVED' THEN

    -- 1. Reassign customer to receiver RM
    UPDATE customers
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      updated_at = NOW()
    WHERE id = NEW.customer_id;

    -- 2. Reassign OPEN pipelines for this customer to receiver
    --    AND set referred_by_user_id for 4DX tracking (referral bonus if pipeline wins)
    UPDATE pipelines
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      referred_by_user_id = NEW.referrer_rm_id,
      referral_id = NEW.id,
      updated_at = NOW()
    WHERE customer_id = NEW.customer_id
      AND deleted_at IS NULL
      AND closed_at IS NULL;  -- Only open pipelines

    -- 3. Reassign CLOSED pipelines for visibility (new RM can see customer history)
    --    Note: scored_to_user_id is already set and won't change - original owner keeps scoring credit
    UPDATE pipelines
    SET
      assigned_rm_id = NEW.receiver_rm_id,
      updated_at = NOW()
    WHERE customer_id = NEW.customer_id
      AND deleted_at IS NULL
      AND closed_at IS NOT NULL;  -- Only closed pipelines

    -- 4. Mark referral as COMPLETED
    NEW.status := 'COMPLETED';
    NEW.updated_at := NOW();

    RAISE NOTICE 'Referral % approved: Customer % reassigned to RM %, pipelines transferred with referrer credit',
      NEW.code, NEW.customer_id, NEW.receiver_rm_id;

  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_referral_approval"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."handle_referral_approval"() IS 'Handles pipeline referral approval by:
1. Reassigning customer to receiver RM
2. Reassigning OPEN pipelines to receiver with referred_by_user_id set for 4DX tracking
3. Reassigning CLOSED pipelines to receiver for visibility (customer history)
4. Marking the referral as COMPLETED

IMPORTANT: scored_to_user_id on closed pipelines is NOT changed - original owner keeps scoring credit.
Only assigned_rm_id changes so the new RM can view the customer pipeline history.';



CREATE OR REPLACE FUNCTION "public"."has_hvc_access_to_customer"("p_customer_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM customer_hvc_links chl
    WHERE chl.customer_id = p_customer_id
    AND chl.hvc_id IN (
      SELECT c2.id FROM customers c2 
      WHERE c2.assigned_rm_id = (SELECT auth.uid())
    )
  );
$$;


ALTER FUNCTION "public"."has_hvc_access_to_customer"("p_customer_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() 
    AND role IN ('ADMIN', 'SUPERADMIN')
  );
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_supervisor_of"("target_user_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = auth.uid()
    AND descendant_id = target_user_id
    AND depth > 0
  );
$$;


ALTER FUNCTION "public"."is_supervisor_of"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_entity_changes"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT;
  v_action TEXT;
  v_old_values JSONB;
  v_new_values JSONB;
BEGIN
  -- Get current user from Supabase auth
  v_user_id := auth.uid();
  
  -- Get user email
  SELECT email INTO v_user_email 
  FROM users 
  WHERE id = v_user_id;
  
  -- Determine action type
  v_action := TG_OP;
  
  -- Build old/new values based on operation
  IF TG_OP = 'DELETE' THEN
    v_old_values := to_jsonb(OLD);
    v_new_values := NULL;
    
    INSERT INTO audit_logs (
      user_id, user_email, action, target_table, target_id,
      old_values, new_values
    ) VALUES (
      v_user_id, v_user_email, v_action, TG_TABLE_NAME, OLD.id,
      v_old_values, v_new_values
    );
    
    RETURN OLD;
    
  ELSIF TG_OP = 'UPDATE' THEN
    v_old_values := to_jsonb(OLD);
    v_new_values := to_jsonb(NEW);
    
    -- Only log if there are actual changes (excluding updated_at, last_sync_at)
    IF v_old_values - 'updated_at' - 'last_sync_at' - 'is_pending_sync' 
       IS DISTINCT FROM 
       v_new_values - 'updated_at' - 'last_sync_at' - 'is_pending_sync' THEN
      
      INSERT INTO audit_logs (
        user_id, user_email, action, target_table, target_id,
        old_values, new_values
      ) VALUES (
        v_user_id, v_user_email, v_action, TG_TABLE_NAME, NEW.id,
        v_old_values, v_new_values
      );
    END IF;
    
    RETURN NEW;
    
  ELSIF TG_OP = 'INSERT' THEN
    v_old_values := NULL;
    v_new_values := to_jsonb(NEW);
    
    INSERT INTO audit_logs (
      user_id, user_email, action, target_table, target_id,
      old_values, new_values
    ) VALUES (
      v_user_id, v_user_email, v_action, TG_TABLE_NAME, NEW.id,
      v_old_values, v_new_values
    );
    
    RETURN NEW;
  END IF;
  
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."log_entity_changes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_pipeline_stage_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Only log when stage_id actually changes
  IF OLD.stage_id IS DISTINCT FROM NEW.stage_id THEN
    INSERT INTO pipeline_stage_history (
      pipeline_id,
      from_stage_id,
      to_stage_id,
      from_status_id,
      to_status_id,
      notes,
      changed_by,
      changed_at
    ) VALUES (
      NEW.id,
      OLD.stage_id,
      NEW.stage_id,
      OLD.status_id,
      NEW.status_id,
      NEW.notes,  -- Capture current notes as the change reason
      auth.uid(),
      NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."log_pipeline_stage_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_user_and_ancestors_dirty"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Insert user and all ancestors into dirty_users
  INSERT INTO dirty_users (user_id, dirtied_at)
  SELECT DISTINCT ancestor_id, NOW()
  FROM user_hierarchy
  WHERE descendant_id = p_user_id
  UNION
  SELECT p_user_id, NOW()  -- Include self
  ON CONFLICT (user_id) DO NOTHING;  -- Avoid duplicate key errors
END;
$$;


ALTER FUNCTION "public"."mark_user_and_ancestors_dirty"("p_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."mark_user_and_ancestors_dirty"("p_user_id" "uuid") IS 'Marks user and all ancestors for aggregate recalculation. Used by triggers to cascade updates up the hierarchy.';



CREATE OR REPLACE FUNCTION "public"."on_activity_completed"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF NEW.status = 'COMPLETED' AND (OLD IS NULL OR OLD.status != 'COMPLETED') THEN
    PERFORM update_all_measure_scores(NEW.user_id);
    PERFORM mark_user_and_ancestors_dirty(NEW.user_id);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_activity_completed"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."on_activity_completed"() IS 'Triggered when activity status changes to COMPLETED. Updates LEAD measure scores and marks hierarchy dirty.';



CREATE OR REPLACE FUNCTION "public"."on_customer_created"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Update all measure scores for the user who created the customer
  IF NEW.created_by IS NOT NULL THEN
    PERFORM update_all_measure_scores(NEW.created_by);
    PERFORM mark_user_and_ancestors_dirty(NEW.created_by);
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_customer_created"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."on_customer_created"() IS 'Triggered when new customer is created. Updates NEW_CUSTOMER LEAD measure and marks hierarchy dirty.';



CREATE OR REPLACE FUNCTION "public"."on_period_locked"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- When a period becomes locked, create snapshots
  IF NEW.is_locked = true AND (OLD.is_locked IS NULL OR OLD.is_locked = false) THEN
    PERFORM create_score_snapshots(NEW.id);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_period_locked"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_pipeline_closed"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Only process if closed_at was just set
  IF NEW.closed_at IS NOT NULL AND (OLD IS NULL OR OLD.closed_at IS NULL) THEN
    -- Update all measure scores for the user credited with this pipeline
    IF NEW.scored_to_user_id IS NOT NULL THEN
      PERFORM update_all_measure_scores(NEW.scored_to_user_id);
      PERFORM mark_user_and_ancestors_dirty(NEW.scored_to_user_id);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_pipeline_closed"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."on_pipeline_closed"() IS 'Triggered when pipeline closed_at is set. Updates CONVERSION_RATE LAG measure and marks hierarchy dirty.';



CREATE OR REPLACE FUNCTION "public"."on_pipeline_stage_changed"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Update all measure scores for the user who changed the stage
  IF NEW.changed_by IS NOT NULL THEN
    PERFORM update_all_measure_scores(NEW.changed_by);
    PERFORM mark_user_and_ancestors_dirty(NEW.changed_by);
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_pipeline_stage_changed"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."on_pipeline_stage_changed"() IS 'Triggered when pipeline stage changes. Updates LEAD measures tracking milestones (e.g., PROPOSAL_SENT at P2) and marks hierarchy dirty.';



CREATE OR REPLACE FUNCTION "public"."on_pipeline_won"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_is_won BOOLEAN;
  v_was_won BOOLEAN := FALSE;
BEGIN
  -- Check if NEW stage is a won stage
  SELECT is_won INTO v_is_won
  FROM pipeline_stages
  WHERE id = NEW.stage_id;

  -- Check if OLD stage was a won stage (for UPDATE operations)
  IF OLD IS NOT NULL AND OLD.stage_id IS NOT NULL THEN
    SELECT is_won INTO v_was_won
    FROM pipeline_stages
    WHERE id = OLD.stage_id;
  END IF;

  -- Only process if stage changed to won (and wasn't won before)
  IF v_is_won = TRUE AND v_was_won = FALSE THEN
    -- Update all measure scores for the user who is credited with the win
    -- Use scored_to_user_id (the user who gets credit for this pipeline)
    IF NEW.scored_to_user_id IS NOT NULL THEN
      PERFORM update_all_measure_scores(NEW.scored_to_user_id);
      PERFORM mark_user_and_ancestors_dirty(NEW.scored_to_user_id);
    END IF;

    -- Also update for referring user if this is a referral
    IF NEW.referred_by_user_id IS NOT NULL THEN
      PERFORM update_all_measure_scores(NEW.referred_by_user_id);
      PERFORM mark_user_and_ancestors_dirty(NEW.referred_by_user_id);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_pipeline_won"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."on_pipeline_won"() IS 'Triggered when pipeline stage changes to a won stage (is_won = true). Updates LAG measure scores (PIPELINE_WON, PREMIUM_WON, REFERRAL_PREMIUM) and marks hierarchy dirty.';



CREATE OR REPLACE FUNCTION "public"."recalculate_aggregate"("p_user_id" "uuid", "p_period_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_lead_points NUMERIC := 0;
  v_lag_points NUMERIC := 0;
  v_lead_measures_count INTEGER;
  v_lag_measures_count INTEGER;
  v_lead_score NUMERIC := 0;
  v_lag_score NUMERIC := 0;
  v_total_score NUMERIC := 0;
  v_subordinate_ids UUID[];
BEGIN
  -- Get all subordinate IDs from hierarchy
  SELECT ARRAY_AGG(DISTINCT descendant_id)
  INTO v_subordinate_ids
  FROM user_hierarchy
  WHERE ancestor_id = p_user_id;

  -- Include self in the array
  IF v_subordinate_ids IS NULL THEN
    v_subordinate_ids := ARRAY[p_user_id];
  ELSE
    v_subordinate_ids := v_subordinate_ids || p_user_id;
  END IF;

  -- Count active measures by type
  SELECT COUNT(*) INTO v_lead_measures_count
  FROM measure_definitions
  WHERE measure_type = 'LEAD' AND is_active = TRUE;

  SELECT COUNT(*) INTO v_lag_measures_count
  FROM measure_definitions
  WHERE measure_type = 'LAG' AND is_active = TRUE;

  -- Calculate LEAD points: join through scoring_periods to match period_type
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lead_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE
    AND sp.period_type = md.period_type
    AND md.measure_type = 'LEAD'
    AND md.is_active = TRUE;

  -- Calculate LAG points: same pattern
  SELECT COALESCE(SUM(us.score), 0)
  INTO v_lag_points
  FROM user_scores us
  JOIN measure_definitions md ON us.measure_id = md.id
  JOIN scoring_periods sp ON us.period_id = sp.id
  WHERE us.user_id = ANY(v_subordinate_ids)
    AND sp.is_current = TRUE
    AND sp.period_type = md.period_type
    AND md.measure_type = 'LAG'
    AND md.is_active = TRUE;

  -- Calculate scores (0-150 scale)
  IF v_lead_measures_count > 0 THEN
    v_lead_score := (v_lead_points / (v_lead_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  IF v_lag_measures_count > 0 THEN
    v_lag_score := (v_lag_points / (v_lag_measures_count * array_length(v_subordinate_ids, 1) * 150)) * 150;
  END IF;

  -- Total score: weighted average (60% LEAD, 40% LAG)
  v_total_score := (v_lead_score * 0.6) + (v_lag_score * 0.4);

  -- Upsert into user_score_aggregates
  -- p_period_id is the display period (shortest granularity)
  INSERT INTO user_score_aggregates (
    user_id, period_id,
    lead_score, lag_score, total_score,
    bonus_points, penalty_points,
    calculated_at, created_at
  ) VALUES (
    p_user_id, p_period_id,
    v_lead_score, v_lag_score, v_total_score,
    0, 0,
    NOW(), NOW()
  )
  ON CONFLICT (user_id, period_id)
  DO UPDATE SET
    lead_score = EXCLUDED.lead_score,
    lag_score = EXCLUDED.lag_score,
    total_score = EXCLUDED.total_score,
    calculated_at = NOW();
END;
$$;


ALTER FUNCTION "public"."recalculate_aggregate"("p_user_id" "uuid", "p_period_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."recalculate_aggregate"("p_user_id" "uuid", "p_period_id" "uuid") IS 'Recalculates user_score_aggregates with HIERARCHICAL ROLLUP. Pulls LEAD/LAG scores from their respective current periods (matched by period_type). Upsert key uses the display period (shortest granularity).';



CREATE OR REPLACE FUNCTION "public"."recalculate_all_scores"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_user_id UUID;
  v_display_period_id UUID;
BEGIN
  -- Find display period: shortest-granularity current period
  SELECT id INTO v_display_period_id
  FROM scoring_periods
  WHERE is_current = TRUE
  ORDER BY
    CASE period_type
      WHEN 'WEEKLY' THEN 1
      WHEN 'MONTHLY' THEN 2
      WHEN 'QUARTERLY' THEN 3
      WHEN 'YEARLY' THEN 4
      ELSE 5
    END
  LIMIT 1;

  IF v_display_period_id IS NULL THEN
    RAISE EXCEPTION 'No current scoring period found';
  END IF;

  -- Recalculate individual measures for all active users
  -- (update_all_measure_scores handles per-measure period matching internally)
  FOR v_user_id IN
    SELECT id FROM users WHERE is_active = TRUE
  LOOP
    PERFORM update_all_measure_scores(v_user_id);
  END LOOP;

  -- Recalculate aggregates for all active users using display period
  FOR v_user_id IN
    SELECT id FROM users WHERE is_active = TRUE
  LOOP
    PERFORM recalculate_aggregate(v_user_id, v_display_period_id);
  END LOOP;

  RAISE NOTICE 'Recalculated all scores for display period %', v_display_period_id;
END;
$$;


ALTER FUNCTION "public"."recalculate_all_scores"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."recalculate_all_scores"() IS 'ADMIN ONLY: Recalculates all user scores and aggregates. Each measure scores against its own current period. Aggregates use the shortest-granularity display period.';



CREATE OR REPLACE FUNCTION "public"."update_all_measure_scores"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_rec RECORD;
BEGIN
  -- For each active measure, find its matching current period by period_type
  FOR v_rec IN
    SELECT md.id AS measure_id, sp.id AS period_id
    FROM measure_definitions md
    JOIN scoring_periods sp
      ON sp.period_type = md.period_type
      AND sp.is_current = TRUE
    WHERE md.is_active = TRUE
  LOOP
    PERFORM update_user_score(p_user_id, v_rec.measure_id, v_rec.period_id);
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."update_all_measure_scores"("p_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_all_measure_scores"("p_user_id" "uuid") IS 'Updates all measure scores for a user. Each measure is scored against its own current period (matched by period_type).';



CREATE OR REPLACE FUNCTION "public"."update_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_hierarchy"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  DELETE FROM user_hierarchy WHERE descendant_id = NEW.id;
  INSERT INTO user_hierarchy (ancestor_id, descendant_id, depth) VALUES (NEW.id, NEW.id, 0);
  IF NEW.parent_id IS NOT NULL THEN
    INSERT INTO user_hierarchy (ancestor_id, descendant_id, depth)
    SELECT ancestor_id, NEW.id, depth + 1 FROM user_hierarchy WHERE descendant_id = NEW.parent_id;
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_hierarchy"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_score"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_actual_value NUMERIC;
  v_target_value NUMERIC;
  v_achievement_pct NUMERIC;
  v_points NUMERIC;
  v_weight NUMERIC;
BEGIN
  -- Calculate actual value
  v_actual_value := calculate_measure_value(p_user_id, p_measure_id, p_period_id);

  -- Get target and weight
  SELECT target_value INTO v_target_value
  FROM user_targets
  WHERE user_id = p_user_id
    AND measure_id = p_measure_id
    AND period_id = p_period_id;

  -- If no target assigned, use default target from measure_definition
  IF v_target_value IS NULL THEN
    SELECT default_target, weight INTO v_target_value, v_weight
    FROM measure_definitions
    WHERE id = p_measure_id;
  ELSE
    SELECT weight INTO v_weight
    FROM measure_definitions
    WHERE id = p_measure_id;
  END IF;

  -- Calculate achievement percentage
  IF v_target_value > 0 THEN
    v_achievement_pct := (v_actual_value / v_target_value) * 100;
  ELSE
    v_achievement_pct := 0;
  END IF;

  -- Calculate score (cap percentage at 150%, then multiply by weight)
  v_points := LEAST(v_achievement_pct, 150) * v_weight;

  -- Upsert into user_scores
  -- Note: Using correct column names (actual_value, target_value, percentage, score, calculated_at)
  INSERT INTO user_scores (
    user_id, measure_id, period_id,
    actual_value, target_value, percentage, score,
    calculated_at, updated_at
  ) VALUES (
    p_user_id, p_measure_id, p_period_id,
    v_actual_value, v_target_value, v_achievement_pct, v_points,
    NOW(), NOW()
  )
  ON CONFLICT (user_id, measure_id, period_id)
  DO UPDATE SET
    actual_value = EXCLUDED.actual_value,
    target_value = EXCLUDED.target_value,
    percentage = EXCLUDED.percentage,
    score = EXCLUDED.score,
    calculated_at = NOW(),
    updated_at = NOW();
END;
$$;


ALTER FUNCTION "public"."update_user_score"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_user_score"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") IS 'Updates user_scores row with calculated actual_value, achievement_percentage, and points.';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."_cadence_backup_meetings" (
    "id" "uuid",
    "scheduled_at" timestamp with time zone,
    "host_id" "uuid",
    "meeting_type" character varying(50),
    "status" character varying(20),
    "notes" "text",
    "started_at" timestamp with time zone,
    "ended_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."_cadence_backup_meetings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."_cadence_backup_participants" (
    "id" "uuid",
    "meeting_id" "uuid",
    "user_id" "uuid",
    "pre_meeting_submitted" boolean,
    "pre_meeting_data" "jsonb",
    "pre_meeting_submitted_at" timestamp with time zone,
    "attendance_status" character varying(20),
    "marked_at" timestamp with time zone,
    "arrived_at" timestamp with time zone,
    "excused_reason" "text",
    "attendance_score_impact" integer,
    "marked_by" "uuid",
    "q1_previous_commitment" "text",
    "q1_completion_status" character varying(20),
    "q2_what_achieved" "text",
    "q3_obstacles" "text",
    "q4_next_commitment" "text",
    "form_submission_status" character varying(20),
    "form_score_impact" integer,
    "host_notes" "text",
    "feedback_text" "text",
    "feedback_given_at" timestamp with time zone,
    "feedback_updated_at" timestamp with time zone,
    "last_sync_at" timestamp with time zone
);


ALTER TABLE "public"."_cadence_backup_participants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."_cadence_backup_schedule_config" (
    "id" "uuid",
    "day_of_week" integer,
    "time_of_day" time without time zone,
    "duration_minutes" integer,
    "pre_meeting_hours" integer,
    "is_active" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."_cadence_backup_schedule_config" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activities" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "created_by" "uuid",
    "object_type" character varying(20) NOT NULL,
    "customer_id" "uuid",
    "hvc_id" "uuid",
    "broker_id" "uuid",
    "pipeline_id" "uuid",
    "activity_type_id" "uuid",
    "summary" "text",
    "notes" "text",
    "scheduled_datetime" timestamp with time zone NOT NULL,
    "is_immediate" boolean DEFAULT false,
    "status" character varying(20) DEFAULT 'PLANNED'::character varying,
    "executed_at" timestamp with time zone,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "location_accuracy" numeric(10,2),
    "distance_from_target" numeric(10,2),
    "is_location_override" boolean DEFAULT false,
    "override_reason" "text",
    "rescheduled_from_id" "uuid",
    "rescheduled_to_id" "uuid",
    "cancelled_at" timestamp with time zone,
    "cancel_reason" "text",
    "is_pending_sync" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    "last_sync_at" timestamp with time zone,
    CONSTRAINT "activities_object_type_check" CHECK ((("object_type")::"text" = ANY ((ARRAY['CUSTOMER'::character varying, 'HVC'::character varying, 'BROKER'::character varying, 'PIPELINE'::character varying])::"text"[]))),
    CONSTRAINT "activities_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PLANNED'::character varying, 'IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'RESCHEDULED'::character varying, 'OVERDUE'::character varying])::"text"[])))
);


ALTER TABLE "public"."activities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_audit_logs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "activity_id" "uuid",
    "action" character varying(50) NOT NULL,
    "old_values" "jsonb",
    "new_values" "jsonb",
    "performed_by" "uuid",
    "performed_at" timestamp with time zone DEFAULT "now"(),
    "old_status" character varying(20),
    "new_status" character varying(20),
    "changed_fields" "jsonb",
    "latitude" numeric(10,7),
    "longitude" numeric(10,7),
    "device_info" "jsonb",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."activity_audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_photos" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "activity_id" "uuid" NOT NULL,
    "file_path" "text" NOT NULL,
    "file_size" integer,
    "mime_type" character varying(50),
    "caption" "text",
    "uploaded_at" timestamp with time zone DEFAULT "now"(),
    "is_synced" boolean DEFAULT false,
    "photo_url" "text" NOT NULL,
    "taken_at" timestamp with time zone,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."activity_photos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_types" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "icon" character varying(50),
    "color" character varying(10),
    "require_location" boolean DEFAULT false,
    "require_photo" boolean DEFAULT false,
    "require_notes" boolean DEFAULT false,
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."activity_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."announcement_reads" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "announcement_id" "uuid",
    "user_id" "uuid",
    "read_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."announcement_reads" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."announcements" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "title" character varying(200) NOT NULL,
    "body" "text" NOT NULL,
    "priority" character varying(20) DEFAULT 'NORMAL'::character varying,
    "target_roles" "text"[],
    "target_branches" "uuid"[],
    "start_at" timestamp with time zone DEFAULT "now"(),
    "end_at" timestamp with time zone,
    "is_active" boolean DEFAULT true,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "announcements_priority_check" CHECK ((("priority")::"text" = ANY ((ARRAY['LOW'::character varying, 'NORMAL'::character varying, 'HIGH'::character varying, 'URGENT'::character varying])::"text"[])))
);


ALTER TABLE "public"."announcements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."app_settings" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "key" character varying(100) NOT NULL,
    "value" "text",
    "value_type" character varying(20) DEFAULT 'STRING'::character varying,
    "description" "text",
    "is_editable" boolean DEFAULT true,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "app_settings_value_type_check" CHECK ((("value_type")::"text" = ANY ((ARRAY['STRING'::character varying, 'NUMBER'::character varying, 'BOOLEAN'::character varying, 'JSON'::character varying])::"text"[])))
);


ALTER TABLE "public"."app_settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "user_email" character varying(255),
    "action" character varying(50) NOT NULL,
    "target_table" character varying(50),
    "target_id" "uuid",
    "old_values" "jsonb",
    "new_values" "jsonb",
    "ip_address" character varying(50),
    "user_agent" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."branches" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "regional_office_id" "uuid",
    "address" "text",
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "phone" character varying(20),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."branches" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."brokers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(200) NOT NULL,
    "license_number" character varying(50),
    "address" "text",
    "province_id" "uuid",
    "city_id" "uuid",
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "phone" character varying(20),
    "email" character varying(255),
    "website" character varying(255),
    "commission_rate" numeric(5,2),
    "image_url" "text",
    "notes" "text",
    "is_active" boolean DEFAULT true,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."brokers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cadence_meetings" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "config_id" "uuid",
    "title" "text" NOT NULL,
    "scheduled_at" timestamp with time zone NOT NULL,
    "duration_minutes" integer NOT NULL,
    "facilitator_id" "uuid" NOT NULL,
    "status" character varying(20) DEFAULT 'SCHEDULED'::character varying,
    "location" "text",
    "meeting_link" "text",
    "agenda" "text",
    "notes" "text",
    "started_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "created_by" "uuid" NOT NULL,
    "is_pending_sync" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "cadence_meetings_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['SCHEDULED'::character varying, 'IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::"text"[])))
);


ALTER TABLE "public"."cadence_meetings" OWNER TO "postgres";


COMMENT ON TABLE "public"."cadence_meetings" IS 'Individual cadence meeting instances';



COMMENT ON COLUMN "public"."cadence_meetings"."facilitator_id" IS 'Host/supervisor who runs the meeting';



COMMENT ON COLUMN "public"."cadence_meetings"."completed_at" IS 'When meeting ended (formerly ended_at)';



CREATE TABLE IF NOT EXISTS "public"."cadence_participants" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "meeting_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "attendance_status" character varying(20) DEFAULT 'PENDING'::character varying,
    "arrived_at" timestamp with time zone,
    "excused_reason" "text",
    "attendance_score_impact" integer,
    "marked_by" "uuid",
    "marked_at" timestamp with time zone,
    "pre_meeting_submitted" boolean DEFAULT false,
    "q1_previous_commitment" "text",
    "q1_completion_status" character varying(20),
    "q2_what_achieved" "text",
    "q3_obstacles" "text",
    "q4_next_commitment" "text",
    "form_submitted_at" timestamp with time zone,
    "form_submission_status" character varying(20),
    "form_score_impact" integer,
    "host_notes" "text",
    "feedback_text" "text",
    "feedback_given_at" timestamp with time zone,
    "feedback_updated_at" timestamp with time zone,
    "is_pending_sync" boolean DEFAULT false,
    "last_sync_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "cadence_participants_attendance_status_check" CHECK ((("attendance_status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'PRESENT'::character varying, 'LATE'::character varying, 'EXCUSED'::character varying, 'ABSENT'::character varying])::"text"[]))),
    CONSTRAINT "cadence_participants_form_submission_status_check" CHECK ((("form_submission_status")::"text" = ANY ((ARRAY['ON_TIME'::character varying, 'LATE'::character varying, 'VERY_LATE'::character varying, 'NOT_SUBMITTED'::character varying])::"text"[]))),
    CONSTRAINT "cadence_participants_q1_completion_status_check" CHECK ((("q1_completion_status")::"text" = ANY ((ARRAY['COMPLETED'::character varying, 'PARTIAL'::character varying, 'NOT_DONE'::character varying])::"text"[])))
);


ALTER TABLE "public"."cadence_participants" OWNER TO "postgres";


COMMENT ON TABLE "public"."cadence_participants" IS 'Combined table for attendance, form submission, and feedback';



COMMENT ON COLUMN "public"."cadence_participants"."attendance_score_impact" IS '+3 present, +1 late, 0 excused, -5 absent';



COMMENT ON COLUMN "public"."cadence_participants"."q1_previous_commitment" IS 'Auto-filled from previous meeting Q4';



COMMENT ON COLUMN "public"."cadence_participants"."form_score_impact" IS '+2 on-time, 0 late, -1 very late, -3 not submitted';



CREATE TABLE IF NOT EXISTS "public"."cadence_schedule_config" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "target_role" character varying(20) NOT NULL,
    "facilitator_role" character varying(20) NOT NULL,
    "frequency" character varying(20) NOT NULL,
    "day_of_week" integer,
    "day_of_month" integer,
    "default_time" "text",
    "duration_minutes" integer DEFAULT 60,
    "pre_meeting_hours" integer DEFAULT 24,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "cadence_config_facilitator_role_check" CHECK ((("facilitator_role")::"text" = ANY ((ARRAY['BH'::character varying, 'BM'::character varying, 'ROH'::character varying, 'DIRECTOR'::character varying, 'ADMIN'::character varying])::"text"[]))),
    CONSTRAINT "cadence_config_frequency_check" CHECK ((("frequency")::"text" = ANY ((ARRAY['DAILY'::character varying, 'WEEKLY'::character varying, 'MONTHLY'::character varying, 'QUARTERLY'::character varying])::"text"[]))),
    CONSTRAINT "cadence_config_target_role_check" CHECK ((("target_role")::"text" = ANY ((ARRAY['RM'::character varying, 'BH'::character varying, 'BM'::character varying, 'ROH'::character varying])::"text"[]))),
    CONSTRAINT "cadence_schedule_config_day_of_month_check" CHECK ((("day_of_month" >= 1) AND ("day_of_month" <= 31))),
    CONSTRAINT "cadence_schedule_config_day_of_week_check" CHECK ((("day_of_week" >= 0) AND ("day_of_week" <= 6)))
);


ALTER TABLE "public"."cadence_schedule_config" OWNER TO "postgres";


COMMENT ON TABLE "public"."cadence_schedule_config" IS 'Configuration for cadence meeting schedules per organizational level';



COMMENT ON COLUMN "public"."cadence_schedule_config"."target_role" IS 'Role that attends: RM, BH, BM, ROH';



COMMENT ON COLUMN "public"."cadence_schedule_config"."facilitator_role" IS 'Role that hosts: BH, BM, ROH, DIRECTOR';



COMMENT ON COLUMN "public"."cadence_schedule_config"."frequency" IS 'DAILY, WEEKLY, MONTHLY, QUARTERLY';



COMMENT ON COLUMN "public"."cadence_schedule_config"."pre_meeting_hours" IS 'Hours before meeting for form submission deadline';



CREATE TABLE IF NOT EXISTS "public"."cities" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(10) NOT NULL,
    "name" character varying(100) NOT NULL,
    "province_id" "uuid",
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."cities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cobs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."cobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."company_types" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."company_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customer_hvc_links" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "customer_id" "uuid",
    "hvc_id" "uuid",
    "relationship_type" character varying(50),
    "notes" "text",
    "linked_at" timestamp with time zone DEFAULT "now"(),
    "linked_by" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."customer_hvc_links" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(200) NOT NULL,
    "address" "text",
    "province_id" "uuid",
    "city_id" "uuid",
    "postal_code" character varying(10),
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "phone" character varying(20),
    "email" character varying(255),
    "website" character varying(255),
    "company_type_id" "uuid",
    "ownership_type_id" "uuid",
    "industry_id" "uuid",
    "npwp" character varying(50),
    "assigned_rm_id" "uuid",
    "image_url" "text",
    "notes" "text",
    "is_active" boolean DEFAULT true,
    "created_by" "uuid",
    "is_pending_sync" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    "last_sync_at" timestamp with time zone
);


ALTER TABLE "public"."customers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."decline_reasons" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."decline_reasons" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."dirty_users" (
    "user_id" "uuid" NOT NULL,
    "dirtied_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."dirty_users" OWNER TO "postgres";


COMMENT ON TABLE "public"."dirty_users" IS 'System table tracking users whose aggregate scores need recalculation. Processed by score-aggregation-cron every 10 minutes.';



COMMENT ON COLUMN "public"."dirty_users"."user_id" IS 'User whose aggregate score needs recalculation (includes their own scores + subordinates)';



COMMENT ON COLUMN "public"."dirty_users"."dirtied_at" IS 'Timestamp when user was marked dirty (for debugging/monitoring)';



CREATE TABLE IF NOT EXISTS "public"."hvc_types" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."hvc_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."hvcs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(200) NOT NULL,
    "type_id" "uuid",
    "description" "text",
    "address" "text",
    "province_id" "uuid",
    "city_id" "uuid",
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "phone" character varying(20),
    "email" character varying(255),
    "website" character varying(255),
    "industry_id" "uuid",
    "image_url" "text",
    "notes" "text",
    "visit_frequency_days" integer DEFAULT 30,
    "is_active" boolean DEFAULT true,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    "radius_meters" integer DEFAULT 500,
    "potential_value" numeric(18,2)
);


ALTER TABLE "public"."hvcs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."industries" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."industries" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."key_persons" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_type" character varying(20) NOT NULL,
    "customer_id" "uuid",
    "broker_id" "uuid",
    "hvc_id" "uuid",
    "name" character varying(100) NOT NULL,
    "position" character varying(100),
    "department" character varying(100),
    "phone" character varying(20),
    "email" character varying(255),
    "is_primary" boolean DEFAULT false,
    "is_active" boolean DEFAULT true,
    "notes" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    CONSTRAINT "key_persons_owner_type_check" CHECK ((("owner_type")::"text" = ANY ((ARRAY['CUSTOMER'::character varying, 'BROKER'::character varying, 'HVC'::character varying])::"text"[])))
);


ALTER TABLE "public"."key_persons" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lead_sources" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "requires_referrer" boolean DEFAULT false,
    "requires_broker" boolean DEFAULT false,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."lead_sources" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."lobs" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "cob_id" "uuid",
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."lobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."measure_definitions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "measure_type" character varying(20) NOT NULL,
    "unit" character varying(50) NOT NULL,
    "calculation_method" character varying(50),
    "weight" numeric(5,2) DEFAULT 1.0,
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "data_type" character varying(20) DEFAULT 'COUNT'::character varying,
    "calculation_formula" "text",
    "source_table" character varying(50),
    "source_condition" "text",
    "default_target" numeric(18,2),
    "period_type" character varying(20) DEFAULT 'WEEKLY'::character varying,
    "template_type" character varying(50),
    "template_config" "jsonb",
    CONSTRAINT "measure_definitions_data_type_check" CHECK ((("data_type")::"text" = ANY ((ARRAY['COUNT'::character varying, 'SUM'::character varying, 'PERCENTAGE'::character varying])::"text"[]))),
    CONSTRAINT "measure_definitions_measure_type_check" CHECK ((("measure_type")::"text" = ANY ((ARRAY['LEAD'::character varying, 'LAG'::character varying])::"text"[]))),
    CONSTRAINT "measure_definitions_period_type_check" CHECK ((("period_type")::"text" = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'QUARTERLY'::character varying])::"text"[])))
);


ALTER TABLE "public"."measure_definitions" OWNER TO "postgres";


COMMENT ON TABLE "public"."measure_definitions" IS '4DX Lead and Lag measure definitions';



COMMENT ON COLUMN "public"."measure_definitions"."weight" IS 'Scoring weight - higher = more impact on score';



COMMENT ON COLUMN "public"."measure_definitions"."source_table" IS 'Table to auto-calculate from (activities, pipelines, customers)';



COMMENT ON COLUMN "public"."measure_definitions"."source_condition" IS 'WHERE clause for auto-calculation';



COMMENT ON COLUMN "public"."measure_definitions"."template_type" IS 'Template used to create this measure (activity_count, pipeline_count, pipeline_revenue, pipeline_conversion, stage_milestone, customer_acquisition, custom)';



COMMENT ON COLUMN "public"."measure_definitions"."template_config" IS 'Original template configuration (JSONB) - allows "Edit Template" to re-populate wizard with saved choices';



CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "title" character varying(200) NOT NULL,
    "body" "text",
    "notification_type" character varying(50) NOT NULL,
    "reference_type" character varying(50),
    "reference_id" "uuid",
    "is_read" boolean DEFAULT false,
    "read_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ownership_types" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "sort_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."ownership_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pipeline_referrals" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "referrer_rm_id" "uuid" NOT NULL,
    "receiver_rm_id" "uuid" NOT NULL,
    "referrer_branch_id" "uuid",
    "receiver_branch_id" "uuid",
    "reason" "text" NOT NULL,
    "notes" "text",
    "status" character varying(30) DEFAULT 'PENDING_RECEIVER'::character varying NOT NULL,
    "receiver_accepted_at" timestamp with time zone,
    "receiver_rejected_at" timestamp with time zone,
    "receiver_reject_reason" "text",
    "bm_approved_at" timestamp with time zone,
    "bm_approved_by" "uuid",
    "bm_rejected_at" timestamp with time zone,
    "bm_reject_reason" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "referrer_regional_office_id" "uuid",
    "receiver_regional_office_id" "uuid",
    "approver_type" character varying(10) DEFAULT 'BM'::character varying NOT NULL,
    "receiver_notes" "text",
    "bm_notes" "text",
    "bonus_calculated" boolean DEFAULT false NOT NULL,
    "bonus_amount" numeric(18,2),
    "expires_at" timestamp with time zone,
    "cancelled_at" timestamp with time zone,
    "cancel_reason" "text",
    CONSTRAINT "chk_approver_type" CHECK ((("approver_type")::"text" = ANY ((ARRAY['BH'::character varying, 'BM'::character varying, 'ROH'::character varying, 'ADMIN'::character varying, 'SUPERADMIN'::character varying])::"text"[]))),
    CONSTRAINT "pipeline_referrals_approver_type_check" CHECK ((("approver_type")::"text" = ANY ((ARRAY['BM'::character varying, 'ROH'::character varying])::"text"[]))),
    CONSTRAINT "pipeline_referrals_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PENDING_RECEIVER'::character varying, 'RECEIVER_ACCEPTED'::character varying, 'RECEIVER_REJECTED'::character varying, 'PENDING_BM'::character varying, 'BM_APPROVED'::character varying, 'BM_REJECTED'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::"text"[])))
);


ALTER TABLE "public"."pipeline_referrals" OWNER TO "postgres";


COMMENT ON TABLE "public"."pipeline_referrals" IS 'Pipeline referrals for RM-to-RM customer handoffs.
When approved, the entire customer (and all their pipelines) transfers to the receiver RM.
The receiver decides what products to pursue - no auto-pipeline creation.

Status flow:
1. PENDING_RECEIVER - Waiting for receiver to accept/reject
2. RECEIVER_ACCEPTED - Waiting for manager (BM/ROH) approval
3. BM_APPROVED -> COMPLETED (trigger handles transfer)
4. RECEIVER_REJECTED / BM_REJECTED / CANCELLED - End states';



COMMENT ON COLUMN "public"."pipeline_referrals"."receiver_notes" IS 'Notes from receiver when accepting the referral';



COMMENT ON COLUMN "public"."pipeline_referrals"."bm_notes" IS 'Notes from manager when approving/rejecting';



COMMENT ON COLUMN "public"."pipeline_referrals"."bonus_calculated" IS 'Whether referral bonus has been calculated';



COMMENT ON COLUMN "public"."pipeline_referrals"."bonus_amount" IS 'Calculated bonus amount for the referrer';



COMMENT ON COLUMN "public"."pipeline_referrals"."expires_at" IS 'When the referral expires if not acted upon';



COMMENT ON COLUMN "public"."pipeline_referrals"."cancelled_at" IS 'Timestamp when referral was cancelled';



COMMENT ON COLUMN "public"."pipeline_referrals"."cancel_reason" IS 'Reason provided for cancellation';



CREATE TABLE IF NOT EXISTS "public"."pipeline_stage_history" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "pipeline_id" "uuid" NOT NULL,
    "from_stage_id" "uuid",
    "to_stage_id" "uuid" NOT NULL,
    "from_status_id" "uuid",
    "to_status_id" "uuid",
    "notes" "text",
    "changed_by" "uuid",
    "changed_at" timestamp with time zone DEFAULT "now"(),
    "latitude" numeric(10,8),
    "longitude" numeric(11,8)
);


ALTER TABLE "public"."pipeline_stage_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pipeline_stages" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "probability" integer NOT NULL,
    "sequence" integer NOT NULL,
    "color" character varying(10),
    "is_final" boolean DEFAULT false,
    "is_won" boolean DEFAULT false,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "pipeline_stages_probability_check" CHECK ((("probability" >= 0) AND ("probability" <= 100)))
);


ALTER TABLE "public"."pipeline_stages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pipeline_statuses" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "stage_id" "uuid",
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "sequence" integer DEFAULT 0,
    "is_default" boolean DEFAULT false,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."pipeline_statuses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pipelines" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "customer_id" "uuid",
    "stage_id" "uuid",
    "status_id" "uuid",
    "cob_id" "uuid",
    "lob_id" "uuid",
    "lead_source_id" "uuid",
    "broker_id" "uuid",
    "broker_pic_id" "uuid",
    "customer_contact_id" "uuid",
    "tsi" numeric(18,2),
    "potential_premium" numeric(18,2) NOT NULL,
    "final_premium" numeric(18,2),
    "weighted_value" numeric(18,2),
    "expected_close_date" "date",
    "policy_number" character varying(50),
    "decline_reason" "text",
    "notes" "text",
    "is_tender" boolean DEFAULT false,
    "referred_by_user_id" "uuid",
    "referral_id" "uuid",
    "assigned_rm_id" "uuid",
    "created_by" "uuid",
    "is_pending_sync" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "closed_at" timestamp with time zone,
    "deleted_at" timestamp with time zone,
    "last_sync_at" timestamp with time zone,
    "scored_to_user_id" "uuid"
);


ALTER TABLE "public"."pipelines" OWNER TO "postgres";


COMMENT ON COLUMN "public"."pipelines"."scored_to_user_id" IS 'The user who receives 4DX lag measure credit for this pipeline.
Set automatically when pipeline reaches WON stage (via trigger).
Never changes after being set, even if assigned_rm_id changes.
This separates operational ownership (assigned_rm_id) from scoring attribution (scored_to_user_id).';



CREATE TABLE IF NOT EXISTS "public"."provinces" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(10) NOT NULL,
    "name" character varying(100) NOT NULL,
    "is_active" boolean DEFAULT true
);


ALTER TABLE "public"."provinces" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."regional_offices" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "code" character varying(20) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "address" "text",
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "phone" character varying(20),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."regional_offices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."scoring_periods" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying(100) NOT NULL,
    "period_type" character varying(20) NOT NULL,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "is_current" boolean DEFAULT false,
    "is_locked" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_active" boolean DEFAULT true,
    CONSTRAINT "scoring_periods_period_type_check" CHECK ((("period_type")::"text" = ANY ((ARRAY['WEEKLY'::character varying, 'MONTHLY'::character varying, 'QUARTERLY'::character varying, 'YEARLY'::character varying])::"text"[])))
);


ALTER TABLE "public"."scoring_periods" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sync_queue_items" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "table_name" character varying(50) NOT NULL,
    "record_id" "uuid" NOT NULL,
    "operation" character varying(20) NOT NULL,
    "payload" "jsonb",
    "status" character varying(20) DEFAULT 'PENDING'::character varying,
    "retry_count" integer DEFAULT 0,
    "last_error" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "synced_at" timestamp with time zone,
    CONSTRAINT "sync_queue_items_operation_check" CHECK ((("operation")::"text" = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::"text"[]))),
    CONSTRAINT "sync_queue_items_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['PENDING'::character varying, 'SYNCING'::character varying, 'SYNCED'::character varying, 'FAILED'::character varying])::"text"[])))
);


ALTER TABLE "public"."sync_queue_items" OWNER TO "postgres";


COMMENT ON TABLE "public"."sync_queue_items" IS 'Sync queue for debugging/admin only. RLS enabled with no policies = service_role access only. App uses local SQLite sync queue.';



CREATE TABLE IF NOT EXISTS "public"."system_errors" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "error_type" character varying(50) NOT NULL,
    "entity_id" "uuid",
    "error_message" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "resolved_at" timestamp with time zone,
    "resolved_by" "uuid"
);


ALTER TABLE "public"."system_errors" OWNER TO "postgres";


COMMENT ON TABLE "public"."system_errors" IS 'Centralized error logging for system operations (score calculation, cron jobs, etc.). Only accessible to admins.';



COMMENT ON COLUMN "public"."system_errors"."error_type" IS 'Error category: MEASURE_CALC_FAILED, TRIGGER_FAILED, CRON_USER_FAILED, etc.';



COMMENT ON COLUMN "public"."system_errors"."entity_id" IS 'Related entity ID (measure_id, user_id, etc.) if applicable';



COMMENT ON COLUMN "public"."system_errors"."error_message" IS 'Full error message/stack trace';



COMMENT ON COLUMN "public"."system_errors"."resolved_at" IS 'Timestamp when error was marked as resolved (NULL = unresolved)';



COMMENT ON COLUMN "public"."system_errors"."resolved_by" IS 'Admin user who resolved the error';



CREATE TABLE IF NOT EXISTS "public"."user_hierarchy" (
    "ancestor_id" "uuid" NOT NULL,
    "descendant_id" "uuid" NOT NULL,
    "depth" integer NOT NULL
);


ALTER TABLE "public"."user_hierarchy" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_hierarchy" IS 'Closure table for user supervisor relationships. RLS restricts to own relationships + admin access.';



CREATE TABLE IF NOT EXISTS "public"."user_score_aggregate_snapshots" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "period_id" "uuid",
    "snapshot_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "lead_score" numeric(10,2) DEFAULT 0,
    "lag_score" numeric(10,2) DEFAULT 0,
    "bonus_points" numeric(10,2) DEFAULT 0,
    "penalty_points" numeric(10,2) DEFAULT 0,
    "total_score" numeric(10,2) DEFAULT 0,
    "rank" integer,
    "rank_change" integer,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_score_aggregate_snapshots" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_score_aggregate_snapshots" IS 'Historical point-in-time snapshots of user_score_aggregates';



CREATE TABLE IF NOT EXISTS "public"."user_score_aggregates" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "period_id" "uuid",
    "total_score" numeric(10,2),
    "lead_score" numeric(10,2),
    "lag_score" numeric(10,2),
    "rank" integer,
    "snapshot_at" timestamp with time zone DEFAULT "now"(),
    "bonus_points" numeric(10,2) DEFAULT 0,
    "penalty_points" numeric(10,2) DEFAULT 0,
    "rank_change" integer,
    "calculated_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_score_aggregates" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_score_aggregates" IS 'Real-time aggregated scores per user per period (lead, lag, total scores with ranking)';



COMMENT ON COLUMN "public"."user_score_aggregates"."total_score" IS '(lead*0.6 + lag*0.4) + bonus - penalty';



COMMENT ON COLUMN "public"."user_score_aggregates"."bonus_points" IS 'Cadence attendance, immediate logging, etc.';



COMMENT ON COLUMN "public"."user_score_aggregates"."penalty_points" IS 'Absences, late submissions, etc.';



CREATE TABLE IF NOT EXISTS "public"."user_score_snapshots" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "period_id" "uuid",
    "measure_id" "uuid",
    "snapshot_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "target_value" numeric(18,2),
    "actual_value" numeric(18,2),
    "percentage" numeric(5,2),
    "score" numeric(10,2),
    "rank" integer,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_score_snapshots" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_score_snapshots" IS 'Historical point-in-time snapshots of individual user_scores';



CREATE TABLE IF NOT EXISTS "public"."user_scores" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "period_id" "uuid",
    "measure_id" "uuid",
    "actual_value" numeric(18,2) DEFAULT 0,
    "percentage" numeric(5,2) DEFAULT 0,
    "score" numeric(10,2) DEFAULT 0,
    "rank" integer,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "target_value" numeric(18,2),
    "calculated_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_scores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_targets" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "period_id" "uuid",
    "measure_id" "uuid",
    "target_value" numeric(18,2) NOT NULL,
    "assigned_by" "uuid",
    "assigned_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_targets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "email" character varying(255) NOT NULL,
    "name" character varying(100) NOT NULL,
    "nip" character varying(50),
    "phone" character varying(20),
    "role" character varying(20) NOT NULL,
    "parent_id" "uuid",
    "branch_id" "uuid",
    "regional_office_id" "uuid",
    "photo_url" "text",
    "is_active" boolean DEFAULT true,
    "last_login_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "users_role_check" CHECK ((("role")::"text" = ANY ((ARRAY['SUPERADMIN'::character varying, 'ADMIN'::character varying, 'ROH'::character varying, 'BM'::character varying, 'BH'::character varying, 'RM'::character varying])::"text"[])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_audit_logs"
    ADD CONSTRAINT "activity_audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_photos"
    ADD CONSTRAINT "activity_photos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."activity_types"
    ADD CONSTRAINT "activity_types_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."activity_types"
    ADD CONSTRAINT "activity_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."announcement_reads"
    ADD CONSTRAINT "announcement_reads_announcement_id_user_id_key" UNIQUE ("announcement_id", "user_id");



ALTER TABLE ONLY "public"."announcement_reads"
    ADD CONSTRAINT "announcement_reads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."app_settings"
    ADD CONSTRAINT "app_settings_key_key" UNIQUE ("key");



ALTER TABLE ONLY "public"."app_settings"
    ADD CONSTRAINT "app_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."branches"
    ADD CONSTRAINT "branches_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."branches"
    ADD CONSTRAINT "branches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."brokers"
    ADD CONSTRAINT "brokers_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."brokers"
    ADD CONSTRAINT "brokers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cadence_meetings"
    ADD CONSTRAINT "cadence_meetings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cadence_participants"
    ADD CONSTRAINT "cadence_participants_meeting_id_user_id_key" UNIQUE ("meeting_id", "user_id");



ALTER TABLE ONLY "public"."cadence_participants"
    ADD CONSTRAINT "cadence_participants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cadence_schedule_config"
    ADD CONSTRAINT "cadence_schedule_config_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cobs"
    ADD CONSTRAINT "cobs_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."cobs"
    ADD CONSTRAINT "cobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."company_types"
    ADD CONSTRAINT "company_types_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."company_types"
    ADD CONSTRAINT "company_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."customer_hvc_links"
    ADD CONSTRAINT "customer_hvc_links_customer_id_hvc_id_key" UNIQUE ("customer_id", "hvc_id");



ALTER TABLE ONLY "public"."customer_hvc_links"
    ADD CONSTRAINT "customer_hvc_links_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."decline_reasons"
    ADD CONSTRAINT "decline_reasons_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."decline_reasons"
    ADD CONSTRAINT "decline_reasons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."dirty_users"
    ADD CONSTRAINT "dirty_users_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hvc_types"
    ADD CONSTRAINT "hvc_types_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."hvc_types"
    ADD CONSTRAINT "hvc_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."industries"
    ADD CONSTRAINT "industries_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."industries"
    ADD CONSTRAINT "industries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."key_persons"
    ADD CONSTRAINT "key_persons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lead_sources"
    ADD CONSTRAINT "lead_sources_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."lead_sources"
    ADD CONSTRAINT "lead_sources_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."lobs"
    ADD CONSTRAINT "lobs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."measure_definitions"
    ADD CONSTRAINT "measure_definitions_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."measure_definitions"
    ADD CONSTRAINT "measure_definitions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ownership_types"
    ADD CONSTRAINT "ownership_types_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."ownership_types"
    ADD CONSTRAINT "ownership_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pipeline_stages"
    ADD CONSTRAINT "pipeline_stages_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."pipeline_stages"
    ADD CONSTRAINT "pipeline_stages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pipeline_statuses"
    ADD CONSTRAINT "pipeline_statuses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."provinces"
    ADD CONSTRAINT "provinces_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."provinces"
    ADD CONSTRAINT "provinces_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."regional_offices"
    ADD CONSTRAINT "regional_offices_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."regional_offices"
    ADD CONSTRAINT "regional_offices_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."scoring_periods"
    ADD CONSTRAINT "scoring_periods_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sync_queue_items"
    ADD CONSTRAINT "sync_queue_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."system_errors"
    ADD CONSTRAINT "system_errors_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_hierarchy"
    ADD CONSTRAINT "user_hierarchy_pkey" PRIMARY KEY ("ancestor_id", "descendant_id");



ALTER TABLE ONLY "public"."user_score_aggregate_snapshots"
    ADD CONSTRAINT "user_score_aggregate_snapshots_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_score_aggregates"
    ADD CONSTRAINT "user_score_aggregates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_score_snapshots"
    ADD CONSTRAINT "user_score_snapshots_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_score_aggregates"
    ADD CONSTRAINT "user_score_snapshots_user_period_key" UNIQUE ("user_id", "period_id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_user_id_period_id_measure_id_key" UNIQUE ("user_id", "period_id", "measure_id");



ALTER TABLE ONLY "public"."user_targets"
    ADD CONSTRAINT "user_targets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_targets"
    ADD CONSTRAINT "user_targets_user_id_period_id_measure_id_key" UNIQUE ("user_id", "period_id", "measure_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_activities_scheduled" ON "public"."activities" USING "btree" ("scheduled_datetime");



CREATE INDEX "idx_activities_status" ON "public"."activities" USING "btree" ("status");



CREATE INDEX "idx_activities_user" ON "public"."activities" USING "btree" ("user_id");



CREATE INDEX "idx_activity_audit_logs_action" ON "public"."activity_audit_logs" USING "btree" ("action");



CREATE INDEX "idx_activity_audit_logs_activity_id" ON "public"."activity_audit_logs" USING "btree" ("activity_id");



CREATE INDEX "idx_activity_audit_logs_performed_at" ON "public"."activity_audit_logs" USING "btree" ("performed_at" DESC);



CREATE INDEX "idx_activity_audit_logs_performed_by" ON "public"."activity_audit_logs" USING "btree" ("performed_by");



CREATE INDEX "idx_audit_logs_created" ON "public"."audit_logs" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_audit_logs_target" ON "public"."audit_logs" USING "btree" ("target_table", "target_id");



CREATE INDEX "idx_audit_logs_user" ON "public"."audit_logs" USING "btree" ("user_id");



CREATE INDEX "idx_cadence_meetings_config" ON "public"."cadence_meetings" USING "btree" ("config_id");



CREATE INDEX "idx_cadence_meetings_facilitator" ON "public"."cadence_meetings" USING "btree" ("facilitator_id");



CREATE INDEX "idx_cadence_meetings_scheduled" ON "public"."cadence_meetings" USING "btree" ("scheduled_at");



CREATE INDEX "idx_cadence_meetings_status" ON "public"."cadence_meetings" USING "btree" ("status");



CREATE INDEX "idx_cadence_participants_attendance" ON "public"."cadence_participants" USING "btree" ("attendance_status");



CREATE INDEX "idx_cadence_participants_form_status" ON "public"."cadence_participants" USING "btree" ("form_submission_status");



CREATE INDEX "idx_cadence_participants_meeting" ON "public"."cadence_participants" USING "btree" ("meeting_id");



CREATE INDEX "idx_cadence_participants_user" ON "public"."cadence_participants" USING "btree" ("user_id");



CREATE INDEX "idx_customer_hvc_links_deleted_at" ON "public"."customer_hvc_links" USING "btree" ("deleted_at") WHERE ("deleted_at" IS NOT NULL);



CREATE INDEX "idx_customer_hvc_links_updated_at" ON "public"."customer_hvc_links" USING "btree" ("updated_at");



CREATE INDEX "idx_customers_assigned_rm" ON "public"."customers" USING "btree" ("assigned_rm_id");



CREATE INDEX "idx_customers_created_by" ON "public"."customers" USING "btree" ("created_by");



CREATE INDEX "idx_dirty_users_dirtied_at" ON "public"."dirty_users" USING "btree" ("dirtied_at");



CREATE INDEX "idx_key_persons_customer" ON "public"."key_persons" USING "btree" ("customer_id");



CREATE INDEX "idx_measures_template_type" ON "public"."measure_definitions" USING "btree" ("template_type");



CREATE INDEX "idx_notifications_unread" ON "public"."notifications" USING "btree" ("user_id", "is_read") WHERE ("is_read" = false);



CREATE INDEX "idx_notifications_user" ON "public"."notifications" USING "btree" ("user_id");



CREATE INDEX "idx_pipeline_stage_history_changed_at" ON "public"."pipeline_stage_history" USING "btree" ("changed_at" DESC);



CREATE INDEX "idx_pipeline_stage_history_pipeline" ON "public"."pipeline_stage_history" USING "btree" ("pipeline_id");



CREATE INDEX "idx_pipelines_assigned_rm" ON "public"."pipelines" USING "btree" ("assigned_rm_id");



CREATE INDEX "idx_pipelines_customer" ON "public"."pipelines" USING "btree" ("customer_id");



CREATE INDEX "idx_pipelines_scored_to_user" ON "public"."pipelines" USING "btree" ("scored_to_user_id");



CREATE INDEX "idx_pipelines_stage" ON "public"."pipelines" USING "btree" ("stage_id");



CREATE INDEX "idx_referrals_approver_type" ON "public"."pipeline_referrals" USING "btree" ("approver_type");



CREATE UNIQUE INDEX "idx_scoring_periods_one_current_per_type" ON "public"."scoring_periods" USING "btree" ("period_type") WHERE ("is_current" = true);



COMMENT ON INDEX "public"."idx_scoring_periods_one_current_per_type" IS 'Ensures at most one current period per period_type (WEEKLY, MONTHLY, QUARTERLY, YEARLY).';



CREATE INDEX "idx_sync_queue_pending" ON "public"."sync_queue_items" USING "btree" ("status") WHERE (("status")::"text" = 'PENDING'::"text");



CREATE INDEX "idx_system_errors_entity" ON "public"."system_errors" USING "btree" ("entity_id") WHERE ("entity_id" IS NOT NULL);



CREATE INDEX "idx_system_errors_type" ON "public"."system_errors" USING "btree" ("error_type");



CREATE INDEX "idx_system_errors_unresolved" ON "public"."system_errors" USING "btree" ("created_at") WHERE ("resolved_at" IS NULL);



CREATE INDEX "idx_user_hierarchy_descendant" ON "public"."user_hierarchy" USING "btree" ("descendant_id");



CREATE INDEX "idx_user_score_aggregate_snapshots_at" ON "public"."user_score_aggregate_snapshots" USING "btree" ("snapshot_at");



CREATE INDEX "idx_user_score_aggregate_snapshots_period" ON "public"."user_score_aggregate_snapshots" USING "btree" ("period_id");



CREATE UNIQUE INDEX "idx_user_score_aggregate_snapshots_unique" ON "public"."user_score_aggregate_snapshots" USING "btree" ("user_id", "period_id", "snapshot_at");



CREATE INDEX "idx_user_score_aggregate_snapshots_user" ON "public"."user_score_aggregate_snapshots" USING "btree" ("user_id");



CREATE INDEX "idx_user_score_aggregates_period" ON "public"."user_score_aggregates" USING "btree" ("period_id");



CREATE INDEX "idx_user_score_aggregates_user" ON "public"."user_score_aggregates" USING "btree" ("user_id");



CREATE INDEX "idx_user_score_snapshots_at" ON "public"."user_score_snapshots" USING "btree" ("snapshot_at");



CREATE INDEX "idx_user_score_snapshots_period" ON "public"."user_score_snapshots" USING "btree" ("period_id");



CREATE UNIQUE INDEX "idx_user_score_snapshots_unique" ON "public"."user_score_snapshots" USING "btree" ("user_id", "period_id", "measure_id", "snapshot_at");



CREATE INDEX "idx_user_score_snapshots_user" ON "public"."user_score_snapshots" USING "btree" ("user_id");



CREATE INDEX "idx_user_scores_measure" ON "public"."user_scores" USING "btree" ("measure_id");



CREATE INDEX "idx_user_scores_period" ON "public"."user_scores" USING "btree" ("period_id");



CREATE INDEX "idx_user_scores_user" ON "public"."user_scores" USING "btree" ("user_id");



CREATE INDEX "idx_user_targets_period" ON "public"."user_targets" USING "btree" ("period_id");



CREATE INDEX "idx_user_targets_user" ON "public"."user_targets" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "activities_updated_at" BEFORE UPDATE ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "branches_updated_at" BEFORE UPDATE ON "public"."branches" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "brokers_audit_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."brokers" FOR EACH ROW EXECUTE FUNCTION "public"."log_entity_changes"();



CREATE OR REPLACE TRIGGER "brokers_updated_at" BEFORE UPDATE ON "public"."brokers" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "cadence_meetings_updated_at" BEFORE UPDATE ON "public"."cadence_meetings" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "cadence_participants_updated_at" BEFORE UPDATE ON "public"."cadence_participants" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "cadence_schedule_config_updated_at" BEFORE UPDATE ON "public"."cadence_schedule_config" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "customer_hvc_links_audit_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."customer_hvc_links" FOR EACH ROW EXECUTE FUNCTION "public"."log_entity_changes"();



CREATE OR REPLACE TRIGGER "customer_hvc_links_updated_at" BEFORE UPDATE ON "public"."customer_hvc_links" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "customers_audit_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."customers" FOR EACH ROW EXECUTE FUNCTION "public"."log_entity_changes"();



CREATE OR REPLACE TRIGGER "customers_updated_at" BEFORE UPDATE ON "public"."customers" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "hvc_audit_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."hvcs" FOR EACH ROW EXECUTE FUNCTION "public"."log_entity_changes"();



CREATE OR REPLACE TRIGGER "hvc_updated_at" BEFORE UPDATE ON "public"."hvcs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "key_persons_updated_at" BEFORE UPDATE ON "public"."key_persons" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "on_pipeline_won" BEFORE UPDATE ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."handle_pipeline_won"();



CREATE OR REPLACE TRIGGER "on_pipeline_won_insert" BEFORE INSERT ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."handle_pipeline_won_insert"();



CREATE OR REPLACE TRIGGER "on_referral_approved" BEFORE UPDATE ON "public"."pipeline_referrals" FOR EACH ROW EXECUTE FUNCTION "public"."handle_referral_approval"();



CREATE OR REPLACE TRIGGER "pipeline_referrals_audit_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."pipeline_referrals" FOR EACH ROW EXECUTE FUNCTION "public"."log_entity_changes"();



CREATE OR REPLACE TRIGGER "pipeline_stages_updated_at" BEFORE UPDATE ON "public"."pipeline_stages" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "pipeline_statuses_updated_at" BEFORE UPDATE ON "public"."pipeline_statuses" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "pipelines_audit_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."log_entity_changes"();



CREATE OR REPLACE TRIGGER "pipelines_stage_history_trigger" AFTER UPDATE ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."log_pipeline_stage_change"();



CREATE OR REPLACE TRIGGER "pipelines_updated_at" BEFORE UPDATE ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "regional_offices_updated_at" BEFORE UPDATE ON "public"."regional_offices" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_activity_completed" AFTER INSERT OR UPDATE OF "status" ON "public"."activities" FOR EACH ROW EXECUTE FUNCTION "public"."on_activity_completed"();



CREATE OR REPLACE TRIGGER "trigger_customer_created" AFTER INSERT ON "public"."customers" FOR EACH ROW EXECUTE FUNCTION "public"."on_customer_created"();



CREATE OR REPLACE TRIGGER "trigger_period_locked" AFTER UPDATE ON "public"."scoring_periods" FOR EACH ROW EXECUTE FUNCTION "public"."on_period_locked"();



CREATE OR REPLACE TRIGGER "trigger_pipeline_closed" AFTER INSERT OR UPDATE OF "closed_at" ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."on_pipeline_closed"();



CREATE OR REPLACE TRIGGER "trigger_pipeline_stage_changed" AFTER INSERT ON "public"."pipeline_stage_history" FOR EACH ROW EXECUTE FUNCTION "public"."on_pipeline_stage_changed"();



CREATE OR REPLACE TRIGGER "trigger_pipeline_won" AFTER INSERT OR UPDATE OF "stage_id" ON "public"."pipelines" FOR EACH ROW EXECUTE FUNCTION "public"."on_pipeline_won"();



CREATE OR REPLACE TRIGGER "user_hierarchy_trigger" AFTER INSERT OR UPDATE OF "parent_id" ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_hierarchy"();



CREATE OR REPLACE TRIGGER "users_updated_at" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_activity_type_id_fkey" FOREIGN KEY ("activity_type_id") REFERENCES "public"."activity_types"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_broker_id_fkey" FOREIGN KEY ("broker_id") REFERENCES "public"."brokers"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_hvc_id_fkey" FOREIGN KEY ("hvc_id") REFERENCES "public"."hvcs"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_pipeline_id_fkey" FOREIGN KEY ("pipeline_id") REFERENCES "public"."pipelines"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_rescheduled_from_id_fkey" FOREIGN KEY ("rescheduled_from_id") REFERENCES "public"."activities"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_rescheduled_to_id_fkey" FOREIGN KEY ("rescheduled_to_id") REFERENCES "public"."activities"("id");



ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."activity_audit_logs"
    ADD CONSTRAINT "activity_audit_logs_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."activity_audit_logs"
    ADD CONSTRAINT "activity_audit_logs_changed_by_fkey" FOREIGN KEY ("performed_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."activity_photos"
    ADD CONSTRAINT "activity_photos_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."announcement_reads"
    ADD CONSTRAINT "announcement_reads_announcement_id_fkey" FOREIGN KEY ("announcement_id") REFERENCES "public"."announcements"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."announcement_reads"
    ADD CONSTRAINT "announcement_reads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."announcements"
    ADD CONSTRAINT "announcements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."branches"
    ADD CONSTRAINT "branches_regional_office_id_fkey" FOREIGN KEY ("regional_office_id") REFERENCES "public"."regional_offices"("id");



ALTER TABLE ONLY "public"."brokers"
    ADD CONSTRAINT "brokers_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id");



ALTER TABLE ONLY "public"."brokers"
    ADD CONSTRAINT "brokers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."brokers"
    ADD CONSTRAINT "brokers_province_id_fkey" FOREIGN KEY ("province_id") REFERENCES "public"."provinces"("id");



ALTER TABLE ONLY "public"."cadence_meetings"
    ADD CONSTRAINT "cadence_meetings_config_id_fkey" FOREIGN KEY ("config_id") REFERENCES "public"."cadence_schedule_config"("id");



ALTER TABLE ONLY "public"."cadence_meetings"
    ADD CONSTRAINT "cadence_meetings_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."cadence_meetings"
    ADD CONSTRAINT "cadence_meetings_facilitator_id_fkey" FOREIGN KEY ("facilitator_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."cadence_participants"
    ADD CONSTRAINT "cadence_participants_marked_by_fkey" FOREIGN KEY ("marked_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."cadence_participants"
    ADD CONSTRAINT "cadence_participants_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "public"."cadence_meetings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."cadence_participants"
    ADD CONSTRAINT "cadence_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_province_id_fkey" FOREIGN KEY ("province_id") REFERENCES "public"."provinces"("id");



ALTER TABLE ONLY "public"."customer_hvc_links"
    ADD CONSTRAINT "customer_hvc_links_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."customer_hvc_links"
    ADD CONSTRAINT "customer_hvc_links_hvc_id_fkey" FOREIGN KEY ("hvc_id") REFERENCES "public"."hvcs"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."customer_hvc_links"
    ADD CONSTRAINT "customer_hvc_links_linked_by_fkey" FOREIGN KEY ("linked_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_assigned_rm_id_fkey" FOREIGN KEY ("assigned_rm_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_company_type_id_fkey" FOREIGN KEY ("company_type_id") REFERENCES "public"."company_types"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_industry_id_fkey" FOREIGN KEY ("industry_id") REFERENCES "public"."industries"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_ownership_type_id_fkey" FOREIGN KEY ("ownership_type_id") REFERENCES "public"."ownership_types"("id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_province_id_fkey" FOREIGN KEY ("province_id") REFERENCES "public"."provinces"("id");



ALTER TABLE ONLY "public"."dirty_users"
    ADD CONSTRAINT "dirty_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."key_persons"
    ADD CONSTRAINT "fk_key_persons_broker" FOREIGN KEY ("broker_id") REFERENCES "public"."brokers"("id");



ALTER TABLE ONLY "public"."key_persons"
    ADD CONSTRAINT "fk_key_persons_hvc" FOREIGN KEY ("hvc_id") REFERENCES "public"."hvcs"("id");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_hvc_type_id_fkey" FOREIGN KEY ("type_id") REFERENCES "public"."hvc_types"("id");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_industry_id_fkey" FOREIGN KEY ("industry_id") REFERENCES "public"."industries"("id");



ALTER TABLE ONLY "public"."hvcs"
    ADD CONSTRAINT "hvc_province_id_fkey" FOREIGN KEY ("province_id") REFERENCES "public"."provinces"("id");



ALTER TABLE ONLY "public"."key_persons"
    ADD CONSTRAINT "key_persons_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."key_persons"
    ADD CONSTRAINT "key_persons_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."lobs"
    ADD CONSTRAINT "lobs_cob_id_fkey" FOREIGN KEY ("cob_id") REFERENCES "public"."cobs"("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_bm_approved_by_fkey" FOREIGN KEY ("bm_approved_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_receiver_branch_id_fkey" FOREIGN KEY ("receiver_branch_id") REFERENCES "public"."branches"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_receiver_regional_office_id_fkey" FOREIGN KEY ("receiver_regional_office_id") REFERENCES "public"."regional_offices"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_receiver_rm_id_fkey" FOREIGN KEY ("receiver_rm_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_referrer_branch_id_fkey" FOREIGN KEY ("referrer_branch_id") REFERENCES "public"."branches"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_referrer_regional_office_id_fkey" FOREIGN KEY ("referrer_regional_office_id") REFERENCES "public"."regional_offices"("id");



ALTER TABLE ONLY "public"."pipeline_referrals"
    ADD CONSTRAINT "pipeline_referrals_referrer_rm_id_fkey" FOREIGN KEY ("referrer_rm_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_from_stage_id_fkey" FOREIGN KEY ("from_stage_id") REFERENCES "public"."pipeline_stages"("id");



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_from_status_id_fkey" FOREIGN KEY ("from_status_id") REFERENCES "public"."pipeline_statuses"("id");



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_pipeline_id_fkey" FOREIGN KEY ("pipeline_id") REFERENCES "public"."pipelines"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_to_stage_id_fkey" FOREIGN KEY ("to_stage_id") REFERENCES "public"."pipeline_stages"("id");



ALTER TABLE ONLY "public"."pipeline_stage_history"
    ADD CONSTRAINT "pipeline_stage_history_to_status_id_fkey" FOREIGN KEY ("to_status_id") REFERENCES "public"."pipeline_statuses"("id");



ALTER TABLE ONLY "public"."pipeline_statuses"
    ADD CONSTRAINT "pipeline_statuses_stage_id_fkey" FOREIGN KEY ("stage_id") REFERENCES "public"."pipeline_stages"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_assigned_rm_id_fkey" FOREIGN KEY ("assigned_rm_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_broker_id_fkey" FOREIGN KEY ("broker_id") REFERENCES "public"."brokers"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_broker_pic_id_fkey" FOREIGN KEY ("broker_pic_id") REFERENCES "public"."key_persons"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_cob_id_fkey" FOREIGN KEY ("cob_id") REFERENCES "public"."cobs"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_customer_contact_id_fkey" FOREIGN KEY ("customer_contact_id") REFERENCES "public"."key_persons"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_lead_source_id_fkey" FOREIGN KEY ("lead_source_id") REFERENCES "public"."lead_sources"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_lob_id_fkey" FOREIGN KEY ("lob_id") REFERENCES "public"."lobs"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_referral_id_fkey" FOREIGN KEY ("referral_id") REFERENCES "public"."pipeline_referrals"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_referred_by_user_id_fkey" FOREIGN KEY ("referred_by_user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_scored_to_user_id_fkey" FOREIGN KEY ("scored_to_user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_stage_id_fkey" FOREIGN KEY ("stage_id") REFERENCES "public"."pipeline_stages"("id");



ALTER TABLE ONLY "public"."pipelines"
    ADD CONSTRAINT "pipelines_status_id_fkey" FOREIGN KEY ("status_id") REFERENCES "public"."pipeline_statuses"("id");



ALTER TABLE ONLY "public"."system_errors"
    ADD CONSTRAINT "system_errors_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_hierarchy"
    ADD CONSTRAINT "user_hierarchy_ancestor_id_fkey" FOREIGN KEY ("ancestor_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_hierarchy"
    ADD CONSTRAINT "user_hierarchy_descendant_id_fkey" FOREIGN KEY ("descendant_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_score_aggregate_snapshots"
    ADD CONSTRAINT "user_score_aggregate_snapshots_period_id_fkey" FOREIGN KEY ("period_id") REFERENCES "public"."scoring_periods"("id");



ALTER TABLE ONLY "public"."user_score_aggregate_snapshots"
    ADD CONSTRAINT "user_score_aggregate_snapshots_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_score_snapshots"
    ADD CONSTRAINT "user_score_snapshots_measure_id_fkey" FOREIGN KEY ("measure_id") REFERENCES "public"."measure_definitions"("id");



ALTER TABLE ONLY "public"."user_score_aggregates"
    ADD CONSTRAINT "user_score_snapshots_period_id_fkey" FOREIGN KEY ("period_id") REFERENCES "public"."scoring_periods"("id");



ALTER TABLE ONLY "public"."user_score_snapshots"
    ADD CONSTRAINT "user_score_snapshots_period_id_fkey1" FOREIGN KEY ("period_id") REFERENCES "public"."scoring_periods"("id");



ALTER TABLE ONLY "public"."user_score_aggregates"
    ADD CONSTRAINT "user_score_snapshots_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_score_snapshots"
    ADD CONSTRAINT "user_score_snapshots_user_id_fkey1" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_measure_id_fkey" FOREIGN KEY ("measure_id") REFERENCES "public"."measure_definitions"("id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_period_id_fkey" FOREIGN KEY ("period_id") REFERENCES "public"."scoring_periods"("id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_targets"
    ADD CONSTRAINT "user_targets_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_targets"
    ADD CONSTRAINT "user_targets_measure_id_fkey" FOREIGN KEY ("measure_id") REFERENCES "public"."measure_definitions"("id");



ALTER TABLE ONLY "public"."user_targets"
    ADD CONSTRAINT "user_targets_period_id_fkey" FOREIGN KEY ("period_id") REFERENCES "public"."scoring_periods"("id");



ALTER TABLE ONLY "public"."user_targets"
    ADD CONSTRAINT "user_targets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "public"."branches"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_regional_office_id_fkey" FOREIGN KEY ("regional_office_id") REFERENCES "public"."regional_offices"("id");



CREATE POLICY "Admins can delete errors" ON "public"."system_errors" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."role")::"text" = 'ADMIN'::"text")))));



CREATE POLICY "Admins can resolve errors" ON "public"."system_errors" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."role")::"text" = 'ADMIN'::"text")))));



CREATE POLICY "Admins can view all errors" ON "public"."system_errors" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = "auth"."uid"()) AND (("users"."role")::"text" = 'ADMIN'::"text")))));



CREATE POLICY "Users can insert own audit logs" ON "public"."activity_audit_logs" FOR INSERT WITH CHECK (("performed_by" = "auth"."uid"()));



CREATE POLICY "Users can read related audit logs" ON "public"."activity_audit_logs" FOR SELECT USING ((("performed_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."activities" "a"
  WHERE (("a"."id" = "activity_audit_logs"."activity_id") AND ("a"."user_id" = "auth"."uid"()))))));



ALTER TABLE "public"."activities" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activities_admin_all" ON "public"."activities" USING ("public"."is_admin"());



CREATE POLICY "activities_insert" ON "public"."activities" FOR INSERT WITH CHECK (("created_by" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "activities_select_own" ON "public"."activities" FOR SELECT USING ((("user_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("created_by" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "activities_select_subordinates" ON "public"."activities" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "activities"."user_id")))));



CREATE POLICY "activities_update_own" ON "public"."activities" FOR UPDATE USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."activity_audit_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_audit_logs_select" ON "public"."activity_audit_logs" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."activities" "a"
  WHERE (("a"."id" = "activity_audit_logs"."activity_id") AND (("a"."user_id" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
           FROM "public"."user_hierarchy"
          WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "a"."user_id")))) OR "public"."is_admin"())))));



ALTER TABLE "public"."activity_photos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_photos_via_activity" ON "public"."activity_photos" USING ((EXISTS ( SELECT 1
   FROM "public"."activities" "a"
  WHERE (("a"."id" = "activity_photos"."activity_id") AND (("a"."user_id" = ( SELECT "auth"."uid"() AS "uid")) OR "public"."is_admin"())))));



ALTER TABLE "public"."activity_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "activity_types_admin" ON "public"."activity_types" USING ("public"."is_admin"());



CREATE POLICY "activity_types_select" ON "public"."activity_types" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."announcement_reads" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "announcement_reads_own" ON "public"."announcement_reads" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."announcements" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "announcements_admin" ON "public"."announcements" USING ("public"."is_admin"());



CREATE POLICY "announcements_select" ON "public"."announcements" FOR SELECT USING ((("auth"."uid"() IS NOT NULL) AND ("is_active" = true) AND (("start_at" IS NULL) OR ("start_at" <= "now"())) AND (("end_at" IS NULL) OR ("end_at" >= "now"()))));



ALTER TABLE "public"."app_settings" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "app_settings_admin" ON "public"."app_settings" USING ("public"."is_admin"());



CREATE POLICY "app_settings_select" ON "public"."app_settings" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "audit_logs_admin" ON "public"."audit_logs" USING ("public"."is_admin"());



CREATE POLICY "audit_logs_select_own" ON "public"."audit_logs" FOR SELECT USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "audit_logs_select_subordinates" ON "public"."audit_logs" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "audit_logs"."user_id") AND ("user_hierarchy"."depth" > 0)))));



ALTER TABLE "public"."brokers" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "brokers_admin_all" ON "public"."brokers" USING ("public"."is_admin"());



CREATE POLICY "brokers_select_authenticated" ON "public"."brokers" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."cities" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "cities_admin" ON "public"."cities" USING ("public"."is_admin"());



CREATE POLICY "cities_select" ON "public"."cities" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."cobs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "cobs_admin" ON "public"."cobs" USING ("public"."is_admin"());



CREATE POLICY "cobs_select" ON "public"."cobs" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."company_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "company_types_admin" ON "public"."company_types" USING ("public"."is_admin"());



CREATE POLICY "company_types_select" ON "public"."company_types" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."customer_hvc_links" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "customer_hvc_links_admin" ON "public"."customer_hvc_links" USING ("public"."is_admin"());



CREATE POLICY "customer_hvc_links_delete_own" ON "public"."customer_hvc_links" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."customers" "c"
  WHERE (("c"."id" = "customer_hvc_links"."customer_id") AND (("c"."assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
           FROM "public"."user_hierarchy"
          WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "c"."assigned_rm_id")))))))));



CREATE POLICY "customer_hvc_links_insert" ON "public"."customer_hvc_links" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."customers" "c"
  WHERE (("c"."id" = "customer_hvc_links"."customer_id") AND (("c"."assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("c"."created_by" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
           FROM "public"."user_hierarchy"
          WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "c"."assigned_rm_id")))))))));



CREATE POLICY "customer_hvc_links_update_own" ON "public"."customer_hvc_links" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."customers" "c"
  WHERE (("c"."id" = "customer_hvc_links"."customer_id") AND (("c"."assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
           FROM "public"."user_hierarchy"
          WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "c"."assigned_rm_id")))))))));



ALTER TABLE "public"."customers" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "customers_admin_all" ON "public"."customers" USING ("public"."is_admin"());



CREATE POLICY "customers_insert" ON "public"."customers" FOR INSERT WITH CHECK (("created_by" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "customers_select_own" ON "public"."customers" FOR SELECT USING ((("assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("created_by" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "customers_select_subordinates" ON "public"."customers" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "customers"."assigned_rm_id")))));



CREATE POLICY "customers_select_via_hvc" ON "public"."customers" FOR SELECT USING ("public"."has_hvc_access_to_customer"("id"));



CREATE POLICY "customers_update_own" ON "public"."customers" FOR UPDATE USING (("assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."decline_reasons" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "decline_reasons_admin" ON "public"."decline_reasons" USING ("public"."is_admin"());



CREATE POLICY "decline_reasons_select" ON "public"."decline_reasons" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."hvc_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "hvc_types_admin" ON "public"."hvc_types" USING ("public"."is_admin"());



CREATE POLICY "hvc_types_select" ON "public"."hvc_types" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."hvcs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "hvcs_admin_all" ON "public"."hvcs" USING ("public"."is_admin"());



CREATE POLICY "hvcs_select_hierarchy" ON "public"."hvcs" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "hvcs"."created_by")))));



COMMENT ON POLICY "hvcs_select_hierarchy" ON "public"."hvcs" IS 'Users can see HVCs created by subordinates';



CREATE POLICY "hvcs_select_own" ON "public"."hvcs" FOR SELECT USING (("created_by" = ( SELECT "auth"."uid"() AS "uid")));



COMMENT ON POLICY "hvcs_select_own" ON "public"."hvcs" IS 'Users can see HVCs they created';



CREATE POLICY "hvcs_select_via_customer_link" ON "public"."hvcs" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."customer_hvc_links" "chl"
     JOIN "public"."customers" "c" ON (("c"."id" = "chl"."customer_id")))
  WHERE (("chl"."hvc_id" = "hvcs"."id") AND ("chl"."deleted_at" IS NULL) AND ("c"."deleted_at" IS NULL) AND (("c"."assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
           FROM "public"."user_hierarchy"
          WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "c"."assigned_rm_id")))))))));



COMMENT ON POLICY "hvcs_select_via_customer_link" ON "public"."hvcs" IS 'Users can see HVCs linked to their customers or subordinate customers';



ALTER TABLE "public"."industries" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "industries_admin" ON "public"."industries" USING ("public"."is_admin"());



CREATE POLICY "industries_select" ON "public"."industries" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."key_persons" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "key_persons_admin" ON "public"."key_persons" USING ("public"."is_admin"());



CREATE POLICY "key_persons_customer_owner" ON "public"."key_persons" USING ((("customer_id" IS NOT NULL) AND "public"."can_access_customer"("customer_id")));



CREATE POLICY "key_persons_hvc_broker" ON "public"."key_persons" FOR SELECT USING (((("hvc_id" IS NOT NULL) OR ("broker_id" IS NOT NULL)) AND ("auth"."uid"() IS NOT NULL)));



ALTER TABLE "public"."lead_sources" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "lead_sources_admin" ON "public"."lead_sources" USING ("public"."is_admin"());



CREATE POLICY "lead_sources_select" ON "public"."lead_sources" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."lobs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "lobs_admin" ON "public"."lobs" USING ("public"."is_admin"());



CREATE POLICY "lobs_select" ON "public"."lobs" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."measure_definitions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "measure_definitions_admin" ON "public"."measure_definitions" USING ("public"."is_admin"());



CREATE POLICY "measure_definitions_select" ON "public"."measure_definitions" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notifications_own" ON "public"."notifications" USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."ownership_types" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "ownership_types_admin" ON "public"."ownership_types" USING ("public"."is_admin"());



CREATE POLICY "ownership_types_select" ON "public"."ownership_types" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."pipeline_referrals" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pipeline_referrals_admin_all" ON "public"."pipeline_referrals" USING ("public"."is_admin"());



CREATE POLICY "pipeline_referrals_approve" ON "public"."pipeline_referrals" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND (("users"."role")::"text" = ANY ((ARRAY['BH'::character varying, 'BM'::character varying, 'ROH'::character varying, 'ADMIN'::character varying, 'SUPERADMIN'::character varying])::"text"[]))))));



CREATE POLICY "pipeline_referrals_insert" ON "public"."pipeline_referrals" FOR INSERT WITH CHECK ((("referrer_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "pipeline_referrals"."referrer_rm_id") AND ("user_hierarchy"."depth" > 0)))) OR (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND (("users"."role")::"text" = ANY ((ARRAY['BH'::character varying, 'BM'::character varying, 'ROH'::character varying])::"text"[]))))) OR "public"."is_admin"()));



CREATE POLICY "pipeline_referrals_involved" ON "public"."pipeline_referrals" FOR SELECT USING ((("referrer_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("receiver_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("bm_approved_by" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND (("users"."role")::"text" = ANY ((ARRAY['BH'::character varying, 'BM'::character varying, 'ROH'::character varying])::"text"[]))))) OR "public"."is_admin"()));



CREATE POLICY "pipeline_referrals_update_receiver" ON "public"."pipeline_referrals" FOR UPDATE USING (("receiver_rm_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."pipeline_stage_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pipeline_stage_history_admin" ON "public"."pipeline_stage_history" USING ("public"."is_admin"());



CREATE POLICY "pipeline_stage_history_select_own" ON "public"."pipeline_stage_history" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."pipelines" "p"
  WHERE (("p"."id" = "pipeline_stage_history"."pipeline_id") AND (("p"."assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("p"."created_by" = ( SELECT "auth"."uid"() AS "uid")))))));



CREATE POLICY "pipeline_stage_history_select_subordinates" ON "public"."pipeline_stage_history" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."pipelines" "p"
  WHERE (("p"."id" = "pipeline_stage_history"."pipeline_id") AND (EXISTS ( SELECT 1
           FROM "public"."user_hierarchy"
          WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "p"."assigned_rm_id"))))))));



ALTER TABLE "public"."pipeline_stages" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pipeline_stages_admin" ON "public"."pipeline_stages" USING ("public"."is_admin"());



CREATE POLICY "pipeline_stages_select" ON "public"."pipeline_stages" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."pipeline_statuses" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pipeline_statuses_admin" ON "public"."pipeline_statuses" USING ("public"."is_admin"());



CREATE POLICY "pipeline_statuses_select" ON "public"."pipeline_statuses" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."pipelines" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pipelines_admin_all" ON "public"."pipelines" USING ("public"."is_admin"());



CREATE POLICY "pipelines_insert" ON "public"."pipelines" FOR INSERT WITH CHECK (("created_by" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "pipelines_select_own" ON "public"."pipelines" FOR SELECT USING ((("assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("created_by" = ( SELECT "auth"."uid"() AS "uid"))));



CREATE POLICY "pipelines_select_subordinates" ON "public"."pipelines" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "pipelines"."assigned_rm_id")))));



CREATE POLICY "pipelines_update_own" ON "public"."pipelines" FOR UPDATE USING (("assigned_rm_id" = ( SELECT "auth"."uid"() AS "uid")));



ALTER TABLE "public"."provinces" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "provinces_admin" ON "public"."provinces" USING ("public"."is_admin"());



CREATE POLICY "provinces_select" ON "public"."provinces" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."scoring_periods" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "scoring_periods_admin" ON "public"."scoring_periods" USING ("public"."is_admin"());



CREATE POLICY "scoring_periods_select" ON "public"."scoring_periods" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "public"."sync_queue_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."system_errors" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_hierarchy" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_hierarchy_admin_all" ON "public"."user_hierarchy" USING ("public"."is_admin"());



CREATE POLICY "user_hierarchy_select_own" ON "public"."user_hierarchy" FOR SELECT USING ((("ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("descendant_id" = ( SELECT "auth"."uid"() AS "uid"))));



ALTER TABLE "public"."user_score_aggregate_snapshots" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_score_aggregate_snapshots_admin" ON "public"."user_score_aggregate_snapshots" USING ("public"."is_admin"());



CREATE POLICY "user_score_aggregate_snapshots_select_own" ON "public"."user_score_aggregate_snapshots" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "user_score_aggregate_snapshots_select_subordinates" ON "public"."user_score_aggregate_snapshots" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = "auth"."uid"()) AND ("user_hierarchy"."descendant_id" = "user_score_aggregate_snapshots"."user_id")))));



ALTER TABLE "public"."user_score_aggregates" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_score_aggregates_admin" ON "public"."user_score_aggregates" USING ("public"."is_admin"());



CREATE POLICY "user_score_aggregates_select_own" ON "public"."user_score_aggregates" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "user_score_aggregates_select_subordinates" ON "public"."user_score_aggregates" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = "auth"."uid"()) AND ("user_hierarchy"."descendant_id" = "user_score_aggregates"."user_id")))));



ALTER TABLE "public"."user_score_snapshots" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_score_snapshots_admin" ON "public"."user_score_snapshots" USING ("public"."is_admin"());



CREATE POLICY "user_score_snapshots_select_own" ON "public"."user_score_snapshots" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "user_score_snapshots_select_subordinates" ON "public"."user_score_snapshots" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = "auth"."uid"()) AND ("user_hierarchy"."descendant_id" = "user_score_snapshots"."user_id")))));



ALTER TABLE "public"."user_scores" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_scores_admin" ON "public"."user_scores" USING ("public"."is_admin"());



CREATE POLICY "user_scores_select_own" ON "public"."user_scores" FOR SELECT USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "user_scores_select_subordinates" ON "public"."user_scores" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "user_scores"."user_id")))));



ALTER TABLE "public"."user_targets" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_targets_modify" ON "public"."user_targets" USING (((EXISTS ( SELECT 1
   FROM "public"."users"
  WHERE (("users"."id" = ( SELECT "auth"."uid"() AS "uid")) AND (("users"."role")::"text" = ANY ((ARRAY['BH'::character varying, 'BM'::character varying, 'ROH'::character varying, 'ADMIN'::character varying, 'SUPERADMIN'::character varying])::"text"[]))))) AND ("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "user_targets"."user_id")))))));



CREATE POLICY "user_targets_select_own" ON "public"."user_targets" FOR SELECT USING (("user_id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "user_targets_select_subordinates" ON "public"."user_targets" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "user_targets"."user_id")))));



ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users_admin_all" ON "public"."users" USING ("public"."is_admin"());



CREATE POLICY "users_select_self" ON "public"."users" FOR SELECT USING (("id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "users_select_subordinates" ON "public"."users" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_hierarchy"
  WHERE (("user_hierarchy"."ancestor_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("user_hierarchy"."descendant_id" = "users"."id")))));



CREATE POLICY "users_update_self" ON "public"."users" FOR UPDATE USING (("id" = ( SELECT "auth"."uid"() AS "uid")));



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."calculate_measure_value"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_measure_value"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_measure_value"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."can_access_customer"("p_customer_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."can_access_customer"("p_customer_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_access_customer"("p_customer_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_score_snapshots"("target_period_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_score_snapshots"("target_period_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_score_snapshots"("target_period_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_pipeline_code"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_pipeline_code"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_pipeline_code"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_atasan"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_atasan"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_atasan"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_pipeline_won"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_pipeline_won"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_pipeline_won"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_pipeline_won_insert"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_pipeline_won_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_pipeline_won_insert"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_referral_approval"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_referral_approval"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_referral_approval"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_hvc_access_to_customer"("p_customer_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_hvc_access_to_customer"("p_customer_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_hvc_access_to_customer"("p_customer_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_supervisor_of"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_supervisor_of"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_supervisor_of"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_entity_changes"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_entity_changes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_entity_changes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."log_pipeline_stage_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_pipeline_stage_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_pipeline_stage_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_user_and_ancestors_dirty"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_user_and_ancestors_dirty"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_user_and_ancestors_dirty"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."on_activity_completed"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_activity_completed"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_activity_completed"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_customer_created"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_customer_created"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_customer_created"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_period_locked"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_period_locked"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_period_locked"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_pipeline_closed"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_pipeline_closed"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_pipeline_closed"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_pipeline_stage_changed"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_pipeline_stage_changed"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_pipeline_stage_changed"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_pipeline_won"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_pipeline_won"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_pipeline_won"() TO "service_role";



GRANT ALL ON FUNCTION "public"."recalculate_aggregate"("p_user_id" "uuid", "p_period_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."recalculate_aggregate"("p_user_id" "uuid", "p_period_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."recalculate_aggregate"("p_user_id" "uuid", "p_period_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."recalculate_all_scores"() TO "anon";
GRANT ALL ON FUNCTION "public"."recalculate_all_scores"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."recalculate_all_scores"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_all_measure_scores"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_all_measure_scores"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_all_measure_scores"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_hierarchy"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_hierarchy"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_hierarchy"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_score"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_score"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_score"("p_user_id" "uuid", "p_measure_id" "uuid", "p_period_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."_cadence_backup_meetings" TO "anon";
GRANT ALL ON TABLE "public"."_cadence_backup_meetings" TO "authenticated";
GRANT ALL ON TABLE "public"."_cadence_backup_meetings" TO "service_role";



GRANT ALL ON TABLE "public"."_cadence_backup_participants" TO "anon";
GRANT ALL ON TABLE "public"."_cadence_backup_participants" TO "authenticated";
GRANT ALL ON TABLE "public"."_cadence_backup_participants" TO "service_role";



GRANT ALL ON TABLE "public"."_cadence_backup_schedule_config" TO "anon";
GRANT ALL ON TABLE "public"."_cadence_backup_schedule_config" TO "authenticated";
GRANT ALL ON TABLE "public"."_cadence_backup_schedule_config" TO "service_role";



GRANT ALL ON TABLE "public"."activities" TO "anon";
GRANT ALL ON TABLE "public"."activities" TO "authenticated";
GRANT ALL ON TABLE "public"."activities" TO "service_role";



GRANT ALL ON TABLE "public"."activity_audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."activity_audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."activity_audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."activity_photos" TO "anon";
GRANT ALL ON TABLE "public"."activity_photos" TO "authenticated";
GRANT ALL ON TABLE "public"."activity_photos" TO "service_role";



GRANT ALL ON TABLE "public"."activity_types" TO "anon";
GRANT ALL ON TABLE "public"."activity_types" TO "authenticated";
GRANT ALL ON TABLE "public"."activity_types" TO "service_role";



GRANT ALL ON TABLE "public"."announcement_reads" TO "anon";
GRANT ALL ON TABLE "public"."announcement_reads" TO "authenticated";
GRANT ALL ON TABLE "public"."announcement_reads" TO "service_role";



GRANT ALL ON TABLE "public"."announcements" TO "anon";
GRANT ALL ON TABLE "public"."announcements" TO "authenticated";
GRANT ALL ON TABLE "public"."announcements" TO "service_role";



GRANT ALL ON TABLE "public"."app_settings" TO "anon";
GRANT ALL ON TABLE "public"."app_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."app_settings" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."branches" TO "anon";
GRANT ALL ON TABLE "public"."branches" TO "authenticated";
GRANT ALL ON TABLE "public"."branches" TO "service_role";



GRANT ALL ON TABLE "public"."brokers" TO "anon";
GRANT ALL ON TABLE "public"."brokers" TO "authenticated";
GRANT ALL ON TABLE "public"."brokers" TO "service_role";



GRANT ALL ON TABLE "public"."cadence_meetings" TO "anon";
GRANT ALL ON TABLE "public"."cadence_meetings" TO "authenticated";
GRANT ALL ON TABLE "public"."cadence_meetings" TO "service_role";



GRANT ALL ON TABLE "public"."cadence_participants" TO "anon";
GRANT ALL ON TABLE "public"."cadence_participants" TO "authenticated";
GRANT ALL ON TABLE "public"."cadence_participants" TO "service_role";



GRANT ALL ON TABLE "public"."cadence_schedule_config" TO "anon";
GRANT ALL ON TABLE "public"."cadence_schedule_config" TO "authenticated";
GRANT ALL ON TABLE "public"."cadence_schedule_config" TO "service_role";



GRANT ALL ON TABLE "public"."cities" TO "anon";
GRANT ALL ON TABLE "public"."cities" TO "authenticated";
GRANT ALL ON TABLE "public"."cities" TO "service_role";



GRANT ALL ON TABLE "public"."cobs" TO "anon";
GRANT ALL ON TABLE "public"."cobs" TO "authenticated";
GRANT ALL ON TABLE "public"."cobs" TO "service_role";



GRANT ALL ON TABLE "public"."company_types" TO "anon";
GRANT ALL ON TABLE "public"."company_types" TO "authenticated";
GRANT ALL ON TABLE "public"."company_types" TO "service_role";



GRANT ALL ON TABLE "public"."customer_hvc_links" TO "anon";
GRANT ALL ON TABLE "public"."customer_hvc_links" TO "authenticated";
GRANT ALL ON TABLE "public"."customer_hvc_links" TO "service_role";



GRANT ALL ON TABLE "public"."customers" TO "anon";
GRANT ALL ON TABLE "public"."customers" TO "authenticated";
GRANT ALL ON TABLE "public"."customers" TO "service_role";



GRANT ALL ON TABLE "public"."decline_reasons" TO "anon";
GRANT ALL ON TABLE "public"."decline_reasons" TO "authenticated";
GRANT ALL ON TABLE "public"."decline_reasons" TO "service_role";



GRANT ALL ON TABLE "public"."dirty_users" TO "anon";
GRANT ALL ON TABLE "public"."dirty_users" TO "authenticated";
GRANT ALL ON TABLE "public"."dirty_users" TO "service_role";



GRANT ALL ON TABLE "public"."hvc_types" TO "anon";
GRANT ALL ON TABLE "public"."hvc_types" TO "authenticated";
GRANT ALL ON TABLE "public"."hvc_types" TO "service_role";



GRANT ALL ON TABLE "public"."hvcs" TO "anon";
GRANT ALL ON TABLE "public"."hvcs" TO "authenticated";
GRANT ALL ON TABLE "public"."hvcs" TO "service_role";



GRANT ALL ON TABLE "public"."industries" TO "anon";
GRANT ALL ON TABLE "public"."industries" TO "authenticated";
GRANT ALL ON TABLE "public"."industries" TO "service_role";



GRANT ALL ON TABLE "public"."key_persons" TO "anon";
GRANT ALL ON TABLE "public"."key_persons" TO "authenticated";
GRANT ALL ON TABLE "public"."key_persons" TO "service_role";



GRANT ALL ON TABLE "public"."lead_sources" TO "anon";
GRANT ALL ON TABLE "public"."lead_sources" TO "authenticated";
GRANT ALL ON TABLE "public"."lead_sources" TO "service_role";



GRANT ALL ON TABLE "public"."lobs" TO "anon";
GRANT ALL ON TABLE "public"."lobs" TO "authenticated";
GRANT ALL ON TABLE "public"."lobs" TO "service_role";



GRANT ALL ON TABLE "public"."measure_definitions" TO "anon";
GRANT ALL ON TABLE "public"."measure_definitions" TO "authenticated";
GRANT ALL ON TABLE "public"."measure_definitions" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."ownership_types" TO "anon";
GRANT ALL ON TABLE "public"."ownership_types" TO "authenticated";
GRANT ALL ON TABLE "public"."ownership_types" TO "service_role";



GRANT ALL ON TABLE "public"."pipeline_referrals" TO "anon";
GRANT ALL ON TABLE "public"."pipeline_referrals" TO "authenticated";
GRANT ALL ON TABLE "public"."pipeline_referrals" TO "service_role";



GRANT ALL ON TABLE "public"."pipeline_stage_history" TO "anon";
GRANT ALL ON TABLE "public"."pipeline_stage_history" TO "authenticated";
GRANT ALL ON TABLE "public"."pipeline_stage_history" TO "service_role";



GRANT ALL ON TABLE "public"."pipeline_stages" TO "anon";
GRANT ALL ON TABLE "public"."pipeline_stages" TO "authenticated";
GRANT ALL ON TABLE "public"."pipeline_stages" TO "service_role";



GRANT ALL ON TABLE "public"."pipeline_statuses" TO "anon";
GRANT ALL ON TABLE "public"."pipeline_statuses" TO "authenticated";
GRANT ALL ON TABLE "public"."pipeline_statuses" TO "service_role";



GRANT ALL ON TABLE "public"."pipelines" TO "anon";
GRANT ALL ON TABLE "public"."pipelines" TO "authenticated";
GRANT ALL ON TABLE "public"."pipelines" TO "service_role";



GRANT ALL ON TABLE "public"."provinces" TO "anon";
GRANT ALL ON TABLE "public"."provinces" TO "authenticated";
GRANT ALL ON TABLE "public"."provinces" TO "service_role";



GRANT ALL ON TABLE "public"."regional_offices" TO "anon";
GRANT ALL ON TABLE "public"."regional_offices" TO "authenticated";
GRANT ALL ON TABLE "public"."regional_offices" TO "service_role";



GRANT ALL ON TABLE "public"."scoring_periods" TO "anon";
GRANT ALL ON TABLE "public"."scoring_periods" TO "authenticated";
GRANT ALL ON TABLE "public"."scoring_periods" TO "service_role";



GRANT ALL ON TABLE "public"."sync_queue_items" TO "anon";
GRANT ALL ON TABLE "public"."sync_queue_items" TO "authenticated";
GRANT ALL ON TABLE "public"."sync_queue_items" TO "service_role";



GRANT ALL ON TABLE "public"."system_errors" TO "anon";
GRANT ALL ON TABLE "public"."system_errors" TO "authenticated";
GRANT ALL ON TABLE "public"."system_errors" TO "service_role";



GRANT ALL ON TABLE "public"."user_hierarchy" TO "anon";
GRANT ALL ON TABLE "public"."user_hierarchy" TO "authenticated";
GRANT ALL ON TABLE "public"."user_hierarchy" TO "service_role";



GRANT ALL ON TABLE "public"."user_score_aggregate_snapshots" TO "anon";
GRANT ALL ON TABLE "public"."user_score_aggregate_snapshots" TO "authenticated";
GRANT ALL ON TABLE "public"."user_score_aggregate_snapshots" TO "service_role";



GRANT ALL ON TABLE "public"."user_score_aggregates" TO "anon";
GRANT ALL ON TABLE "public"."user_score_aggregates" TO "authenticated";
GRANT ALL ON TABLE "public"."user_score_aggregates" TO "service_role";



GRANT ALL ON TABLE "public"."user_score_snapshots" TO "anon";
GRANT ALL ON TABLE "public"."user_score_snapshots" TO "authenticated";
GRANT ALL ON TABLE "public"."user_score_snapshots" TO "service_role";



GRANT ALL ON TABLE "public"."user_scores" TO "anon";
GRANT ALL ON TABLE "public"."user_scores" TO "authenticated";
GRANT ALL ON TABLE "public"."user_scores" TO "service_role";



GRANT ALL ON TABLE "public"."user_targets" TO "anon";
GRANT ALL ON TABLE "public"."user_targets" TO "authenticated";
GRANT ALL ON TABLE "public"."user_targets" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







