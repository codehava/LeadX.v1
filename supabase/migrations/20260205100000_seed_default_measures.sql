-- Seed default 4DX measures (6 LEAD + 4 LAG)
-- This migration populates initial measure definitions for the 4DX scoring system

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

  -- Validate that activity types exist
  IF v_visit_type_id IS NULL OR v_call_type_id IS NULL OR v_meeting_type_id IS NULL THEN
    RAISE EXCEPTION 'Required activity types (VISIT, CALL, MEETING) not found in activity_types table';
  END IF;

  -- Insert 6 LEAD Measures (60% weight)
  INSERT INTO measure_definitions (
    code, name, measure_type, source_table, source_condition,
    data_type, default_target, weight, period_type, unit,
    template_type, template_config, is_active
  ) VALUES
    (
      'LEAD-001',
      'Visit Count',
      'LEAD',
      'activities',
      'activity_type_id = ''' || v_visit_type_id || ''' AND status = ''COMPLETED''',
      'COUNT',
      10,
      1.0,
      'WEEKLY',
      'count',
      'activity_count',
      '{"activity_types":["VISIT"],"statuses":["COMPLETED"],"customer_type":null}',
      TRUE
    ),
    (
      'LEAD-002',
      'Call Count',
      'LEAD',
      'activities',
      'activity_type_id = ''' || v_call_type_id || ''' AND status = ''COMPLETED''',
      'COUNT',
      20,
      1.0,
      'WEEKLY',
      'count',
      'activity_count',
      '{"activity_types":["CALL"],"statuses":["COMPLETED"],"customer_type":null}',
      TRUE
    ),
    (
      'LEAD-003',
      'Meeting Count',
      'LEAD',
      'activities',
      'activity_type_id = ''' || v_meeting_type_id || ''' AND status = ''COMPLETED''',
      'COUNT',
      5,
      1.0,
      'WEEKLY',
      'count',
      'activity_count',
      '{"activity_types":["MEETING"],"statuses":["COMPLETED"],"customer_type":null}',
      TRUE
    ),
    (
      'LEAD-004',
      'New Customer',
      'LEAD',
      'customers',
      'created_by = :user_id',
      'COUNT',
      4,
      1.5,
      'MONTHLY',
      'count',
      'customer_acquisition',
      '{"customer_types":null,"company_sizes":null}',
      TRUE
    ),
    (
      'LEAD-005',
      'New Pipeline',
      'LEAD',
      'pipelines',
      'assigned_rm_id = :user_id',
      'COUNT',
      5,
      1.2,
      'MONTHLY',
      'count',
      'pipeline_count',
      '{"stages":["NEW"],"filters":{}}',
      TRUE
    ),
    (
      'LEAD-006',
      'Proposal Sent',
      'LEAD',
      'pipeline_stage_history',
      'to_stage_id IN (SELECT id FROM pipeline_stages WHERE code = ''P2'') AND changed_by = :user_id',
      'COUNT',
      3,
      1.3,
      'WEEKLY',
      'count',
      'stage_milestone',
      '{"target_stage":"P2","from_any":true}',
      TRUE
    );

  -- Insert 4 LAG Measures (40% weight) - These ARE the WIGs
  INSERT INTO measure_definitions (
    code, name, measure_type, source_table, source_condition,
    data_type, default_target, weight, period_type, unit,
    template_type, template_config, is_active
  ) VALUES
    (
      'LAG-001',
      'Pipeline Won',
      'LAG',
      'pipelines',
      'stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true) AND scored_to_user_id = :user_id',
      'COUNT',
      3,
      1.5,
      'MONTHLY',
      'count',
      'pipeline_count',
      '{"stages":["ACCEPTED"],"filters":{}}',
      TRUE
    ),
    (
      'LAG-002',
      'Premium Won',
      'LAG',
      'pipelines',
      'stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true) AND scored_to_user_id = :user_id',
      'SUM',
      500000000,
      2.0,
      'MONTHLY',
      'IDR',
      'pipeline_revenue',
      '{"stage":"ACCEPTED","revenue_field":"final_premium","filters":{}}',
      TRUE
    ),
    (
      'LAG-003',
      'Conversion Rate',
      'LAG',
      'pipelines',
      'scored_to_user_id = :user_id AND closed_at IS NOT NULL',
      'PERCENTAGE',
      40,
      1.0,
      'MONTHLY',
      '%',
      'pipeline_conversion',
      '{}',
      TRUE
    ),
    (
      'LAG-004',
      'Referral Premium',
      'LAG',
      'pipelines',
      'referred_by_user_id = :user_id AND stage_id IN (SELECT id FROM pipeline_stages WHERE is_won = true)',
      'SUM',
      100000000,
      1.5,
      'MONTHLY',
      'IDR',
      'pipeline_revenue',
      '{"stage":"ACCEPTED","revenue_field":"final_premium","filters":{"referral":true}}',
      TRUE
    );

  RAISE NOTICE 'Successfully seeded 10 default measures (6 LEAD + 4 LAG)';
END $$;
