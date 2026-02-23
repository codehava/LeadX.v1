# LeadX CRM - Compressed Database Schema

> **NOT FOR AI CONSUMPTION.** This file is a human-readable reference for planning the next iteration. Read current_schema.sql for the full authoritative schema.

Generated: 2026-02-18 from current_schema.sql (~10,000 lines compressed to this doc)

---

## Extensions
pg_cron, pg_graphql, pg_stat_statements, pgcrypto, postgis, supabase_vault, uuid-ossp

---

## Functions (Business Logic)

### Scoring Engine
- **calculate_measure_value**(user_id, measure_id, period_id) -> numeric
  - Reads measure_definitions (source_table, source_condition, data_type)
  - Supports COUNT, SUM, PERCENTAGE data types
  - SUM: pipelines.final_premium where closed_at in period
  - PERCENTAGE: won/total closed pipelines * 100
  - Logs errors to system_errors on failure, returns 0

- **update_user_score**(user_id, measure_id, period_id) -> void
  - Calls calculate_measure_value, gets target from user_targets (fallback: measure_definitions.default_target)
  - achievement_pct = actual/target * 100, score = LEAST(pct, 150) * weight
  - Upserts into user_scores

- **update_all_measure_scores**(user_id) -> void
  - Loops all active measure_definitions, calls update_user_score for current period

- **recalculate_aggregate**(user_id, period_id) -> void
  - HIERARCHICAL ROLLUP: sums scores across self + all subordinates (via user_hierarchy)
  - lead_score = (lead_points / (lead_count * subordinate_count * 150)) * 150
  - total_score = lead*0.6 + lag*0.4
  - Upserts user_score_aggregates (does NOT touch bonus/penalty - managed by cadence)

- **recalculate_all_scores**() -> void (ADMIN: recalculates all users for current period)
- **create_score_snapshots**(period_id) -> void (snapshots user_scores + user_score_aggregates)
- **mark_user_and_ancestors_dirty**(user_id) -> void (inserts into dirty_users for cron processing)

### Access Control
- **is_admin**() -> bool (role IN ADMIN, SUPERADMIN)
- **get_user_role**() -> text
- **is_supervisor_of**(target_user_id) -> bool (via user_hierarchy, depth > 0)
- **can_access_customer**(customer_id) -> bool (assigned_rm OR created_by OR supervisor OR admin)
- **has_hvc_access_to_customer**(customer_id) -> bool (via customer_hvc_links)
- **get_user_atasan**(user_id) -> json (finds approver: parent_id first, fallback ROH by regional_office)

### Pipeline Logic
- **generate_pipeline_code**() -> varchar ('PIP' + last 8 digits of epoch ms)
- **handle_pipeline_won**() -> trigger (BEFORE UPDATE: sets scored_to_user_id = assigned_rm_id when entering won stage)
- **handle_pipeline_won_insert**() -> trigger (BEFORE INSERT: same for new pipelines created as won)
- **handle_referral_approval**() -> trigger (BEFORE UPDATE on pipeline_referrals: when BM_APPROVED, reassigns customer + open pipelines to receiver, sets referred_by, marks COMPLETED)

### Audit & History
- **log_entity_changes**() -> trigger (INSERT/UPDATE/DELETE -> audit_logs, skips sync-only field changes)
- **log_pipeline_stage_change**() -> trigger (AFTER UPDATE on pipelines: records stage transitions in pipeline_stage_history)
- **update_updated_at**() -> trigger (sets updated_at = NOW())
- **update_user_hierarchy**() -> trigger (closure table maintenance on users INSERT/UPDATE of parent_id)

### Score Event Triggers (AFTER triggers that recalculate scores)
- **on_activity_completed**(): status -> COMPLETED => update_all_measure_scores + mark dirty
- **on_customer_created**(): INSERT => update measures for created_by + mark dirty
- **on_pipeline_stage_changed**(): INSERT on pipeline_stage_history => update measures for changed_by + mark dirty
- **on_pipeline_won**(): stage_id changes to is_won=true => update measures for scored_to_user_id + referred_by_user_id + mark dirty
- **on_pipeline_closed**(): closed_at set => update measures for scored_to_user_id + mark dirty
- **on_period_locked**(): is_locked=true => create_score_snapshots

---

## Tables

### Organization
```
users (id:uuid PK=auth.users.id, email UNIQUE, name, nip, phone, role[SUPERADMIN|ADMIN|ROH|BM|BH|RM], parent_id->users, branch_id->branches, regional_office_id->regional_offices, photo_url, is_active, last_login_at, created_at, updated_at)

user_hierarchy (ancestor_id+descendant_id PK->users CASCADE, depth:int) -- closure table

regional_offices (id PK, code UNIQUE, name, description, address, lat, lng, phone, is_active, created_at, updated_at)

branches (id PK, code UNIQUE, name, regional_office_id->regional_offices, address, lat, lng, phone, is_active, created_at, updated_at)
```

### Master Data (all have: id PK, code UNIQUE, name, is_active; some have sort_order, description)
```
company_types | ownership_types | industries | hvc_types | decline_reasons | lead_sources (+ requires_referrer, requires_broker)
activity_types (+ icon, color, require_location, require_photo, require_notes, sort_order)
provinces (id, code UNIQUE, name, is_active)
cities (id, code UNIQUE, name, province_id->provinces, is_active)
cobs (id, code UNIQUE, name, description, sort_order, is_active)
lobs (id, code UNIQUE, name, cob_id->cobs, description, sort_order, is_active)
pipeline_stages (id, code UNIQUE, name, probability 0-100, sequence, color, is_final, is_won, is_active, created_at, updated_at)
pipeline_statuses (id, stage_id->pipeline_stages, code, name, description, sequence, is_default, is_active, created_at, updated_at)
```

### Business Data

```
customers (id PK, code UNIQUE, name, address, province_id, city_id, postal_code, lat, lng, phone, email, website, company_type_id, ownership_type_id, industry_id, npwp, assigned_rm_id->users, image_url, notes, is_active, created_by->users, is_pending_sync, created_at, updated_at, deleted_at, last_sync_at)

hvcs (id PK, code UNIQUE, name, type_id->hvc_types, description, address, province_id, city_id, lat, lng, phone, email, website, industry_id, image_url, notes, visit_frequency_days=30, is_active, created_by->users, created_at, updated_at, deleted_at, radius_meters=500, potential_value)

customer_hvc_links (id PK, customer_id+hvc_id UNIQUE->customers/hvcs CASCADE, relationship_type, notes, linked_at, linked_by->users, updated_at, deleted_at)

brokers (id PK, code UNIQUE, name, license_number, address, province_id, city_id, lat, lng, phone, email, website, commission_rate, image_url, notes, is_active, created_by->users, created_at, updated_at, deleted_at)

key_persons (id PK, owner_type[CUSTOMER|BROKER|HVC], customer_id, broker_id, hvc_id, name, position, department, phone, email, is_primary, is_active, notes, created_by->users, created_at, updated_at, deleted_at)

pipelines (id PK, code UNIQUE, customer_id->customers, stage_id->pipeline_stages, status_id->pipeline_statuses, cob_id->cobs, lob_id->lobs, lead_source_id->lead_sources, broker_id->brokers, broker_pic_id->key_persons, customer_contact_id->key_persons, tsi, potential_premium NOT NULL, final_premium, weighted_value, expected_close_date, policy_number, decline_reason, notes, is_tender, referred_by_user_id->users, referral_id->pipeline_referrals, assigned_rm_id->users, created_by->users, is_pending_sync, created_at, updated_at, closed_at, deleted_at, last_sync_at, scored_to_user_id->users)
-- scored_to_user_id: set on WON via trigger, never changes after. Separates operational ownership from scoring.

pipeline_stage_history (id PK, pipeline_id->pipelines CASCADE, from_stage_id, to_stage_id->pipeline_stages, from_status_id, to_status_id->pipeline_statuses, notes, changed_by->users, changed_at, lat, lng)

pipeline_referrals (id PK, code UNIQUE, customer_id->customers, referrer_rm_id->users, receiver_rm_id->users, referrer_branch_id->branches, receiver_branch_id->branches, reason, notes, status[PENDING_RECEIVER|RECEIVER_ACCEPTED|RECEIVER_REJECTED|PENDING_BM|BM_APPROVED|BM_REJECTED|COMPLETED|CANCELLED], receiver_accepted_at, receiver_rejected_at, receiver_reject_reason, bm_approved_at, bm_approved_by->users, bm_rejected_at, bm_reject_reason, created_at, updated_at, referrer_regional_office_id, receiver_regional_office_id, approver_type[BM|ROH], receiver_notes, bm_notes, bonus_calculated=false, bonus_amount, expires_at, cancelled_at, cancel_reason)

activities (id PK, user_id->users, created_by->users, object_type[CUSTOMER|HVC|BROKER|PIPELINE], customer_id, hvc_id, broker_id, pipeline_id, activity_type_id->activity_types, summary, notes, scheduled_datetime, is_immediate, status[PLANNED|IN_PROGRESS|COMPLETED|CANCELLED|RESCHEDULED|OVERDUE], executed_at, lat, lng, location_accuracy, distance_from_target, is_location_override, override_reason, rescheduled_from_id->activities, rescheduled_to_id->activities, cancelled_at, cancel_reason, is_pending_sync, created_at, updated_at, deleted_at, last_sync_at)

activity_photos (id PK, activity_id->activities CASCADE, file_path, file_size, mime_type, caption, uploaded_at, is_synced, photo_url, taken_at, lat, lng, created_at)

activity_audit_logs (id PK, activity_id->activities CASCADE, action, old_values:jsonb, new_values:jsonb, performed_by->users, performed_at, old_status, new_status, changed_fields:jsonb, lat, lng, device_info:jsonb, notes, created_at)
```

### 4DX Scoring
```
measure_definitions (id PK, code UNIQUE, name, description, measure_type[LEAD|LAG], unit, calculation_method, weight=1.0, sort_order, is_active, data_type[COUNT|SUM|PERCENTAGE], calculation_formula, source_table, source_condition, default_target, period_type[WEEKLY|MONTHLY|QUARTERLY], template_type, template_config:jsonb, created_at, updated_at)

scoring_periods (id PK, name, period_type[WEEKLY|MONTHLY|QUARTERLY|YEARLY], start_date, end_date, is_current, is_locked, is_active, created_at, updated_at)

user_targets (id PK, user_id+period_id+measure_id UNIQUE, target_value, assigned_by->users, assigned_at, created_at, updated_at)

user_scores (id PK, user_id+period_id+measure_id UNIQUE, actual_value, percentage, score, rank, target_value, calculated_at, updated_at, created_at)

user_score_aggregates (id PK, user_id+period_id UNIQUE, total_score=(lead*0.6+lag*0.4)+bonus-penalty, lead_score, lag_score, rank, bonus_points, penalty_points, rank_change, calculated_at, snapshot_at, created_at)

user_score_snapshots (id PK, user_id+period_id+measure_id+snapshot_at UNIQUE, target_value, actual_value, percentage, score, rank, created_at)

user_score_aggregate_snapshots (id PK, user_id+period_id+snapshot_at UNIQUE, lead_score, lag_score, bonus_points, penalty_points, total_score, rank, rank_change, created_at)

dirty_users (user_id PK->users CASCADE, dirtied_at) -- cron processes every 10 min
```

### Cadence (4DX Meetings)
```
cadence_schedule_config (id PK, name, description, target_role[RM|BH|BM|ROH], facilitator_role[BH|BM|ROH|DIRECTOR|ADMIN], frequency[DAILY|WEEKLY|MONTHLY|QUARTERLY], day_of_week 0-6, day_of_month 1-31, default_time, duration_minutes=60, pre_meeting_hours=24, is_active, created_at, updated_at)

cadence_meetings (id PK, config_id->cadence_schedule_config, title, scheduled_at, duration_minutes, facilitator_id->users, status[SCHEDULED|IN_PROGRESS|COMPLETED|CANCELLED], location, meeting_link, agenda, notes, started_at, completed_at, created_by->users, is_pending_sync, created_at, updated_at)

cadence_participants (id PK, meeting_id+user_id UNIQUE, attendance_status[PENDING|PRESENT|LATE|EXCUSED|ABSENT], arrived_at, excused_reason, attendance_score_impact(+3/+1/0/-5), marked_by, marked_at, pre_meeting_submitted, q1_previous_commitment, q1_completion_status[COMPLETED|PARTIAL|NOT_DONE], q2_what_achieved, q3_obstacles, q4_next_commitment, form_submitted_at, form_submission_status[ON_TIME|LATE|VERY_LATE|NOT_SUBMITTED], form_score_impact(+2/0/-1/-3), host_notes, feedback_text, feedback_given_at, feedback_updated_at, is_pending_sync, last_sync_at, created_at, updated_at)
```

### System / Communication
```
announcements (id PK, title, body, priority[LOW|NORMAL|HIGH|URGENT], target_roles:text[], target_branches:uuid[], start_at, end_at, is_active, created_by->users, created_at)
announcement_reads (id PK, announcement_id+user_id UNIQUE->announcements CASCADE, read_at)
notifications (id PK, user_id->users, title, body, notification_type, reference_type, reference_id, is_read, read_at, created_at)
app_settings (id PK, key UNIQUE, value, value_type[STRING|NUMBER|BOOLEAN|JSON], description, is_editable, updated_at)
audit_logs (id PK, user_id->users, user_email, action, target_table, target_id, old_values:jsonb, new_values:jsonb, ip_address, user_agent, created_at)
system_errors (id PK, error_type, entity_id, error_message, created_at, resolved_at, resolved_by->users)
sync_queue_items (id PK, table_name, record_id, operation[INSERT|UPDATE|DELETE], payload:jsonb, status[PENDING|SYNCING|SYNCED|FAILED], retry_count, last_error, created_at, synced_at) -- service_role only, app uses local SQLite queue
```

---

## Key Indexes
- activities: user_id, status, scheduled_datetime
- customers: assigned_rm_id, created_by
- pipelines: customer_id, assigned_rm_id, stage_id, scored_to_user_id
- pipeline_stage_history: pipeline_id, changed_at DESC
- user_hierarchy: descendant_id
- user_scores: user_id, period_id, measure_id
- user_score_aggregates: user_id, period_id
- notifications: user_id (partial: is_read=false)
- dirty_users: dirtied_at
- system_errors: error_type, entity_id (partial: NOT NULL), created_at (partial: unresolved)
- audit_logs: user_id, target_table+target_id, created_at DESC
- cadence: meetings(config_id, facilitator_id, scheduled_at, status), participants(meeting_id, user_id, attendance_status, form_submission_status)
- referrals: approver_type

---

## Triggers Summary
| Table | Trigger | Function |
|-------|---------|----------|
| activities | BEFORE UPDATE | update_updated_at |
| activities | AFTER INSERT/UPDATE(status) | on_activity_completed |
| customers | BEFORE UPDATE | update_updated_at |
| customers | AFTER INSERT | on_customer_created |
| customers | AFTER IUD | log_entity_changes |
| pipelines | BEFORE UPDATE | update_updated_at |
| pipelines | BEFORE UPDATE | handle_pipeline_won (sets scored_to_user_id) |
| pipelines | BEFORE INSERT | handle_pipeline_won_insert |
| pipelines | AFTER UPDATE | log_pipeline_stage_change |
| pipelines | AFTER INSERT/UPDATE(stage_id) | on_pipeline_won |
| pipelines | AFTER INSERT/UPDATE(closed_at) | on_pipeline_closed |
| pipelines | AFTER IUD | log_entity_changes |
| pipeline_referrals | BEFORE UPDATE | handle_referral_approval |
| pipeline_referrals | AFTER IUD | log_entity_changes |
| pipeline_stage_history | AFTER INSERT | on_pipeline_stage_changed |
| scoring_periods | AFTER UPDATE | on_period_locked |
| users | AFTER INSERT/UPDATE(parent_id) | update_user_hierarchy |
| users | BEFORE UPDATE | update_updated_at |
| brokers, hvcs, customer_hvc_links | AFTER IUD | log_entity_changes |
| branches, key_persons, pipeline_stages, pipeline_statuses, cadence_*, regional_offices | BEFORE UPDATE | update_updated_at |

---

## RLS Policy Patterns

**All tables have RLS enabled.** Common patterns:

1. **Master data** (activity_types, cities, cobs, company_types, etc.): SELECT for authenticated, full CRUD for admin
2. **Business data** (customers, pipelines, activities):
   - SELECT own (assigned_rm_id/user_id/created_by = auth.uid)
   - SELECT subordinates (via user_hierarchy)
   - INSERT own (created_by = auth.uid)
   - UPDATE own (assigned_rm_id = auth.uid)
   - Admin: full access via is_admin()
3. **HVCs**: own + hierarchy + via customer_hvc_links (cross-RM visibility)
4. **Key persons**: via can_access_customer() for customer contacts; authenticated SELECT for HVC/broker contacts
5. **Pipeline referrals**: involved parties (referrer, receiver, approver) + BH/BM/ROH roles
6. **Scores/targets/aggregates**: own + subordinates + admin
7. **Cadence meetings**: (relies on facilitator/participant relationship, not explicitly shown - likely admin + facilitator/participant)
8. **System tables**: system_errors admin-only; sync_queue_items no policies (service_role only); dirty_users no explicit user policies

**Key RLS helper functions**: is_admin(), is_supervisor_of(), can_access_customer(), has_hvc_access_to_customer()

---

## Backup Tables (legacy, can be dropped)
_cadence_backup_meetings, _cadence_backup_participants, _cadence_backup_schedule_config
