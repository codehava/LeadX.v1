# LeadX CRM - Compressed Requirements & Architecture Reference

> Generated: 2026-02-19 | Source: 160+ docs across docs/, .planning/, CLAUDE.md, compressed_schema.md

---

## 1. PROJECT IDENTITY

| Field | Value |
|-------|-------|
| **Product** | LeadX CRM |
| **Owner** | PT Askrindo (Persero) - Indonesian state insurance company |
| **What** | Mobile-first, offline-first CRM for field sales team |
| **Why** | Replace manual Excel tracking with real-time digital pipeline + 4DX accountability |
| **Framework** | 4 Disciplines of Execution (4DX) natively embedded |
| **Platforms** | iOS, Android, Web (Flutter single codebase) |
| **Backend** | Self-hosted Supabase on VPS Biznet Gio (Indonesia) |
| **Core Value** | Sales reps reliably capture/access data in field regardless of connectivity |
| **Cost** | ~Rp 600K/month (VPS prod 8GB + UAT 4GB; Cloudflare/Sentry free tiers) |

---

## 2. USERS & HIERARCHY

| Role | Count | Primary Function |
|------|-------|------------------|
| **RM** (Relationship Manager) | ~300 | Field sales, customer/pipeline CRUD, activity logging |
| **BH** (Business Head) | ~50 | Team supervision, target setting, daily cadence hosting |
| **BM** (Branch Manager) | ~20 | Branch management, approval workflows, branch cadence |
| **ROH** (Regional Office Head) | ~5 | Regional supervision, strategic cadence |
| **Admin/Superadmin** | ~5 | System config, master data, user management |
| **Total** | **~380** | |

**Org Tree:** SUPERADMIN > ADMIN > ROH (5 regions) > BM (~20 branches) > BH (optional) > RM
- Type A: BM > BH > RM (large branches)
- Type B: BM > BH + RM direct (hybrid)
- Type C: BM > RM direct (small branches, no BH)

**Access Model:** Closure table (`user_hierarchy`). Users see own + subordinate data. Admins see all.

---

## 3. TECH STACK

| Layer | Technology | Version |
|-------|-----------|---------|
| UI Framework | Flutter | 3.x |
| State Management | Riverpod (code-gen `@riverpod`) | 2.6.1 |
| Navigation | GoRouter (declarative, deep linking) | 14.6.3 |
| Local Database | Drift (type-safe SQLite, WASM for web) | 2.22.1 |
| Backend Platform | Supabase (PostgreSQL + PostGIS + Auth + Realtime) | 2.8.3 |
| Auth | Supabase GoTrue (JWT: 1hr access, 7day refresh) | - |
| Models | Freezed (immutable) + json_serializable | 2.5.7 |
| Error Handling | Sealed `Result<T>` (migrated from dartz Either) | custom |
| Location | Geolocator + PostGIS | 13.0.2 |
| Charts | fl_chart | 0.69.0 |
| Logging | Talker (module prefixes: `sync.queue \| msg`) | 4.x |
| Crash Reporting | Sentry (optional, disabled if DSN empty) | - |
| Edge Functions | TypeScript (Deno runtime) | - |
| Hosting | VPS Biznet Gio Indonesia (prod 8GB, UAT 4GB) | - |
| CDN/DNS | Cloudflare (free tier) | - |
| Code Generation | build_runner + Freezed + Riverpod + Drift + JSON | - |

**Build Commands:**
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome          # web
flutter build apk --release    # android
flutter test                   # all tests
```

---

## 4. ARCHITECTURE

**Pattern:** Clean Architecture + offline-first sync + reactive streams

**Layers:**
- `lib/presentation/` - Screens, widgets, Riverpod providers. Depends on domain entities.
- `lib/domain/` - Freezed entities, repository interfaces. Pure Dart, no dependencies.
- `lib/data/` - Repository impls, local/remote data sources, Drift DB, services, DTOs.
- `lib/core/` - Theme, errors (Result/Failure), constants, extensions.
- `lib/config/` - GoRouter routes, env config (.env via flutter_dotenv).

**Offline-First Write Flow:**
1. User submits form > Repository creates UUID
2. Insert into local Drift DB (immediate UI feedback)
3. Queue sync operation in `sync_queue` (same Drift transaction for atomicity)
4. SyncService processes queue when online (FIFO, batch 10, retry with backoff)
5. UI reads from local DB only via `StreamProvider` > Drift `.watch()` streams

**Offline-First Read Flow:**
1. Screen uses `StreamProvider` watching `repository.watchAll*()`
2. Repository delegates to `localDataSource.watch*()`
3. Drift emits changes via `Stream<List<T>>`
4. UI auto-rebuilds on each emission. NO `ref.invalidate()` needed.

**Provider Chain:** Screen > StreamProvider > Repository > LocalDataSource > Drift `.watch()`

**Key Patterns:**
- Soft deletes via `deleted_at` (never hard delete business data)
- `SearchableDropdown` with modal bottom sheet for all selection fields
- `OfflineBanner` at shell level for connectivity status
- `AppErrorState` for error callbacks in `AsyncValue.when()`
- `AppLogger` (Talker wrapper) with module prefixes, not `debugPrint`

---

## 5. DATABASE SCHEMA

**Extensions:** pg_cron, pg_graphql, pg_stat_statements, pgcrypto, postgis, supabase_vault, uuid-ossp

### Functions (Business Logic)

| Function | Purpose |
|----------|---------|
| `calculate_measure_value(user, measure, period)` | COUNT/SUM/PERCENTAGE from source tables |
| `update_user_score(user, measure, period)` | actual/target*100, score = min(150, pct)*weight |
| `update_all_measure_scores(user)` | Loops all active measures for current period |
| `recalculate_aggregate(user, period)` | Hierarchical rollup: lead*0.6 + lag*0.4 + bonus - penalty |
| `recalculate_all_scores()` | Admin: recalculate all users |
| `create_score_snapshots(period)` | Snapshot scores when period locked |
| `mark_user_and_ancestors_dirty(user)` | Queue for cron processing |
| `is_admin()`, `get_user_role()` | Access control helpers |
| `is_supervisor_of(target)` | Via user_hierarchy depth > 0 |
| `can_access_customer(customer)` | assigned_rm OR created_by OR supervisor OR admin |
| `generate_pipeline_code()` | 'PIP' + last 8 digits of epoch ms |
| `handle_pipeline_won()` | Sets `scored_to_user_id` = assigned_rm on WON stage |
| `handle_referral_approval()` | On BM_APPROVED: reassign customer + pipelines to receiver |
| `log_entity_changes()` | INSERT/UPDATE/DELETE > audit_logs (skips sync-only changes) |
| `log_pipeline_stage_change()` | Records stage transitions in pipeline_stage_history |

### Tables

**Organization:**
```
users (id PK=auth.users.id, email, name, nip, phone, role[SUPERADMIN|ADMIN|ROH|BM|BH|RM],
       parent_id->users, branch_id, regional_office_id, is_active, last_login_at)
user_hierarchy (ancestor_id+descendant_id PK, depth) -- closure table
regional_offices (id, code, name, address, lat, lng)
branches (id, code, name, regional_office_id, address, lat, lng)
```

**Master Data (all have: id, code UNIQUE, name, is_active):**
```
company_types | ownership_types | industries | hvc_types | decline_reasons
lead_sources (+requires_referrer, +requires_broker)
activity_types (+icon, color, require_location, require_photo, require_notes)
provinces | cities (province_id)
cobs | lobs (cob_id)
pipeline_stages (probability 0-100, sequence, is_final, is_won)
pipeline_statuses (stage_id, sequence, is_default)
```

**Business Data:**
```
customers (code, name, address, province_id, city_id, lat, lng, phone, email,
           company_type_id, ownership_type_id, industry_id, assigned_rm_id,
           is_pending_sync, created_by, deleted_at, last_sync_at)

pipelines (code, customer_id, stage_id, status_id, cob_id, lob_id, lead_source_id,
           broker_id, tsi, potential_premium, final_premium, weighted_value,
           expected_close_date, assigned_rm_id, scored_to_user_id, referred_by_user_id,
           is_pending_sync, closed_at, deleted_at, last_sync_at)

activities (user_id, object_type[CUSTOMER|HVC|BROKER|PIPELINE], customer_id, hvc_id,
            broker_id, pipeline_id, activity_type_id, summary, notes,
            scheduled_datetime, is_immediate, status[PLANNED|IN_PROGRESS|COMPLETED|
            CANCELLED|RESCHEDULED|OVERDUE], executed_at, lat, lng, distance_from_target,
            is_pending_sync, deleted_at, last_sync_at)

activity_photos (activity_id, file_path, photo_url, taken_at, lat, lng)
pipeline_stage_history (pipeline_id, from_stage_id, to_stage_id, changed_by, changed_at)
key_persons (owner_type[CUSTOMER|BROKER|HVC], name, position, phone, email, is_primary)

hvcs (code, name, type_id, address, lat, lng, visit_frequency_days=30, radius_meters=500)
customer_hvc_links (customer_id+hvc_id UNIQUE, relationship_type)
brokers (code, name, license_number, address, commission_rate)
pipeline_referrals (customer_id, referrer_rm_id, receiver_rm_id,
                    status[PENDING_RECEIVER|RECEIVER_ACCEPTED|RECEIVER_REJECTED|
                    PENDING_BM|BM_APPROVED|BM_REJECTED|COMPLETED|CANCELLED],
                    approver_type[BM|ROH], bonus_calculated, bonus_amount)
```

**4DX Scoring:**
```
measure_definitions (code, name, measure_type[LEAD|LAG], weight, data_type[COUNT|SUM|PERCENTAGE],
                     source_table, source_condition, default_target, period_type[WEEKLY|MONTHLY|QUARTERLY])
scoring_periods (name, period_type, start_date, end_date, is_current, is_locked)
user_targets (user_id+period_id+measure_id UNIQUE, target_value)
user_scores (user_id+period_id+measure_id UNIQUE, actual_value, percentage, score, rank)
user_score_aggregates (user_id+period_id UNIQUE, total_score, lead_score, lag_score,
                       bonus_points, penalty_points, rank, rank_change)
user_score_snapshots / user_score_aggregate_snapshots (immutable period snapshots)
dirty_users (user_id PK, dirtied_at) -- cron processes every 10 min
```

**Cadence:**
```
cadence_schedule_config (target_role, facilitator_role, frequency, day_of_week, duration_minutes)
cadence_meetings (config_id, title, scheduled_at, facilitator_id, status[SCHEDULED|IN_PROGRESS|COMPLETED|CANCELLED])
cadence_participants (meeting_id+user_id UNIQUE, attendance_status[PENDING|PRESENT|LATE|EXCUSED|ABSENT],
                      attendance_score_impact(+3/+1/0/-5), q1-q4 pre-meeting answers,
                      form_submission_status[ON_TIME|LATE|VERY_LATE|NOT_SUBMITTED], form_score_impact(+2/0/-1/-3))
```

**System:**
```
announcements (title, body, priority, target_roles[], target_branches[])
announcement_reads (announcement_id+user_id UNIQUE)
notifications (user_id, title, body, type, is_read)
app_settings (key UNIQUE, value, value_type)
audit_logs (user_id, action, target_table, target_id, old_values, new_values)
system_errors (error_type, entity_id, error_message, resolved_at)
sync_queue_items (table_name, record_id, operation, payload, status, retry_count) -- service_role only
```

### RLS Patterns

| Pattern | Tables |
|---------|--------|
| Master data: SELECT authenticated, full CRUD admin | activity_types, cities, cobs, company_types, etc. |
| Business: own (assigned_rm/user_id/created_by) + subordinates (user_hierarchy) + admin | customers, pipelines, activities |
| HVC: own + hierarchy + via customer_hvc_links (cross-RM visibility) | hvcs |
| Key persons: via can_access_customer() | key_persons |
| Referrals: involved parties + BH/BM/ROH roles | pipeline_referrals |
| Scores: own + subordinates + admin | user_scores, user_targets, user_score_aggregates |

### Triggers Summary

| Event | Action |
|-------|--------|
| Activity status > COMPLETED | update_all_measure_scores + mark dirty |
| Customer INSERT | update measures for created_by + mark dirty |
| Pipeline stage change (INSERT on history) | update measures for changed_by + mark dirty |
| Pipeline stage > is_won=true | update measures for scored_to_user_id + referred_by |
| Pipeline closed_at set | update measures for scored_to_user_id + mark dirty |
| Period is_locked=true | create_score_snapshots |
| Users INSERT/UPDATE parent_id | update_user_hierarchy closure table |
| Pipeline BEFORE UPDATE | handle_pipeline_won (sets scored_to_user_id) |
| Referral BEFORE UPDATE | handle_referral_approval (reassign customer+pipelines) |
| All business tables UPDATE | update_updated_at trigger |
| customers, pipelines, referrals, brokers, hvcs | log_entity_changes to audit_logs |

---

## 6. ENTITIES & DATA MODEL

Source entities from `lib/domain/entities/`:

| Entity | Key Fields | Display Helpers |
|--------|-----------|-----------------|
| **Customer** | id, code, name, address, province/city, company/ownership/industry type, assignedRmId, lat/lng, isPendingSync | displayName, isDeleted, needsSync |
| **Pipeline** | id, code, customerId, stageId, statusId, cob/lob, potentialPremium, finalPremium, weightedValue, expectedCloseDate, assignedRmId, scoredToUserId | stageName, statusName, isWon, isClosed |
| **Activity** | id, userId, objectType, customerId/hvcId/brokerId/pipelineId, activityTypeId, summary, scheduledDatetime, isImmediate, status, executedAt, lat/lng | isCompleted, canExecute, isDeleted, needsSync |
| **KeyPerson** | id, ownerType[CUSTOMER/BROKER/HVC], name, position, phone, email, isPrimary | displayName |
| **HVC** | id, code, name, typeId, address, lat/lng, visitFrequencyDays, radiusMeters | displayName |
| **Broker** | id, code, name, licenseNumber, address, commissionRate | displayName |
| **PipelineReferral** | id, code, customerId, referrerRmId, receiverRmId, status (8 states), approverType | statusText |
| **User** | id, email, name, nip, phone, role, parentId, branchId, regionalOfficeId | displayName, isAdmin |
| **Cadence** (3 classes) | CadenceMeeting, CadenceParticipant, CadenceScheduleConfig | statusText, attendanceText |
| **ScoringEntities** (5 classes) | MeasureDefinition, ScoringPeriod, UserTarget, UserScore, UserScoreAggregate | measureType, periodLabel |
| **SyncModels** | SyncQueueItem, SyncEntityType enum, SyncOperation enum | statusText |
| **AuditLogEntity** | id, userId, action, targetTable, targetId, oldValues, newValues | - |
| **AppAuthState** | user, session, isAuthenticated | - |

---

## 7. FUNCTIONAL REQUIREMENTS (FR-001 to FR-018)

| FR | Name | Pri | Summary |
|----|------|-----|---------|
| FR-001 | Authentication | P0 | Email/password login, JWT (1hr/7day), auto-refresh, password reset |
| FR-002 | Customer Management | P0 | CRUD customers + key persons, search/filter/sort, GPS auto-capture |
| FR-003 | Pipeline Management | P0 | 6-stage pipeline (NEW 10% > P3 25% > P2 50% > P1 75% > ACCEPTED 100% > DECLINED 0%), weighted value |
| FR-004 | Scheduled Activities | P0 | Create PLANNED activities, reschedule, cancel, GPS on execution |
| FR-005 | Immediate Activities | P0 | Log as DONE instantly, +15% scoring bonus, GPS on creation |
| FR-006 | Dashboard & Scoreboard | P0 | Score 0-100, ranking, lead/lag progress bars, team leaderboard (BH+) |
| FR-007 | Target Assignment | P0 | Admin/BH/BM set targets per user/period, cascade validation |
| FR-008 | Cadence Meetings | P0 | Weekly auto-scheduled, pre-meeting Q1-Q4 form, attendance +bonus/-penalty |
| FR-009 | HVC Management | P1 | Admin CRUD, RM view-only, many-to-many customer links (9 relationship types) |
| FR-010 | Broker Management | P1 | Admin CRUD, all view, pipeline lead source, broker PICs |
| FR-011 | Admin Panel | P0 | User CRUD (Edge Function), role assignment, master data management |
| FR-012 | Notifications | P1 | In-app bell, categories (activity/pipeline/score/system), read/unread |
| FR-013 | Reporting & Export | P1 | Activity/Pipeline/Score/Customer reports, export Excel/PDF/CSV |
| FR-014 | Offline Mode | P0 | Full CRUD offline, sync queue visible, auto-sync when online |
| FR-015 | Audit Trail | P1 | Timeline view, CREATE/UPDATE/DELETE/stage-change, timestamp+user |
| FR-016 | Pipeline Referral | P1 | RM>RM>BM approval flow, 3-day receiver deadline, referrer bonus on WIN |
| FR-017 | Role & Permission | P1 | Custom roles, permission matrix (CRUD+EXPORT), scope (OWN/TEAM/BRANCH/REGIONAL/ALL) |
| FR-018 | Bulk Upload | P1 | Template download, Excel/CSV (max 5MB/1000 rows), validation, error report |

---

## 8. STABILITY REQUIREMENTS (v1 Milestone)

### Sync Engine (SYNC)
| ID | Requirement |
|----|-------------|
| SYNC-01 | Local DB write + sync queue insertion in single Drift transaction (no crash data loss) |
| SYNC-02 | Incremental sync with `since` timestamps (not full table pulls) |
| SYNC-03 | Queue coalescing: create+update > create, create+delete > remove, update+update > replace |
| SYNC-04 | Debounced sync triggers (500ms batch window, no thundering herd) |
| SYNC-05 | Standardized sync metadata: isPendingSync, lastSyncAt, updatedAt on all syncable tables |
| SYNC-06 | Queue pruning (completed >7 days removed), dead items surfaced |

### Error Handling (ERR)
| ID | Requirement |
|----|-------------|
| ERR-01 | Sealed SyncError hierarchy: retryable (network, timeout, 5xx) vs permanent (auth 401, validation 400) |
| ERR-02 | All repos use sealed Result<T> (migrated from dartz Either) |
| ERR-03 | Screens show cached data + staleness warning when offline (not error strings) |
| ERR-04 | Supabase/network exceptions mapped to typed Failure subclasses |

### Conflict Resolution (CONF)
| ID | Requirement |
|----|-------------|
| CONF-01 | LWW conflict detection comparing updatedAt timestamps, logged to audit table |
| CONF-02 | Dead letter queue UI: view/retry/discard failed sync items |
| CONF-03 | Idempotent sync: creates use upsert on client UUIDs, updates use version guards |
| CONF-04 | Background sync via WorkManager (Android) / BGTaskScheduler (iOS) |
| CONF-05 | SyncCoordinator: gating (no push before initial sync), serialization (push then pull), single execution |

### Offline UX (UX)
| ID | Requirement |
|----|-------------|
| UX-01 | Persistent offline banner at top of every screen |
| UX-02 | Sync status badges (pending/synced) on all entity cards |
| UX-03 | Dashboard "Last synced: X minutes ago" timestamp |
| UX-04 | Failed sync badge count + tap to retry UI |

### Observability (OBS)
| ID | Requirement |
|----|-------------|
| OBS-01 | Sentry crash reporting with user context and breadcrumbs |
| OBS-02 | Talker structured logging replacing debugPrint (module prefixes: sync.queue, sync.push, sync.pull) |

### Scoring (SCORE)
| ID | Requirement |
|----|-------------|
| SCORE-01 | Multi-period aggregation: LEAD (weekly) + LAG (quarterly) composite score |
| SCORE-02 | Team ranking: compare scores across team per period, update rank/rankChange |

### Stubbed Features (FEAT)
| ID | Requirement | Status |
|----|-------------|--------|
| FEAT-01 | Customer share (share_plus) | Pending |
| FEAT-02 | Customer delete with confirmation | Complete |
| FEAT-03 | Phone/email launch from detail screens (url_launcher) | Pending |
| FEAT-04 | Activity editing in form screen | Complete |
| FEAT-05 | Notification settings screen | Complete |
| FEAT-06 | Admin user deletion with cascade | Pending |
| FEAT-07 | Dashboard quick activity logging bottom sheet | Pending |

**Total v1 requirements:** 30 | **Complete:** 7 | **Pending:** 23

---

## 9. SCREENS & NAVIGATION

**Bottom Navigation (5 tabs):** Home (Dashboard) | Customers | + (Quick Add) | Activities | Account

### Screen Inventory (57 screens)

**Auth:** login, splash, forgot_password, reset_password
**Home:** home (4 tabs: dashboard, customers, activities, pipeline), settings, edit_profile, change_password, about, notification_settings
**Customer:** customer_form, customer_detail, customer_history
**Pipeline:** pipeline_form, pipeline_detail, pipeline_history
**Activity:** activity_form (create+edit), activity_detail, activity_calendar
**HVC:** hvc_list, hvc_form, hvc_detail
**Broker:** broker_list, broker_form, broker_detail
**Referral:** referral_list, referral_create, referral_detail, manager_approval
**Cadence:** cadence_list, cadence_form, cadence_detail, host_dashboard
**Scoreboard:** scoreboard, leaderboard, measure_detail, my_targets
**Team Targets:** team_target_list, team_target_form
**Sync:** sync_queue (dead letter + pending items, entity-filtered view)
**Admin:** admin_home, unauthorized
**Admin > Users:** user_list, user_form, user_detail
**Admin > Master Data:** master_data_menu, master_data_list, master_data_form
**Admin > 4DX:** admin_4dx_home, admin_measure_list/form, admin_period_list/form, admin_target_list/form
**Admin > Cadence:** cadence_config_list, cadence_config_form

---

## 10. 4DX FRAMEWORK

### Scoring Formula
```
Final Score = (Lead Score x 0.6) + (Lag Score x 0.4) + Bonuses - Penalties
Measure Achievement = min(150%, (Actual / Target) x 100)
Aggregate: lead_score=(lead_points / (count * 150)) * 150, total=lead*0.6+lag*0.4
```

### Measures
**Lead (60%, predictive):** Visit count, call count, meeting count, new customer, new pipeline, proposal sent
**Lag (40%, outcomes):** Pipeline won, premium won, conversion rate, referral premium

### Bonuses & Penalties
| Item | Impact |
|------|--------|
| Cadence attendance (PRESENT) | +3 pts |
| Cadence attendance (LATE) | +1 pt |
| Cadence on-time form | +2 pts |
| Immediate activity logging | +15% per activity |
| Photo attached | +5% per activity |
| Location verified (<500m) | +5% per activity |
| Cadence absence (ABSENT) | -5 pts |
| Late form | -1 pt |
| Very late form | -3 pts |
| Overdue activity | -1 pt/overdue |

### Cadence Schedule
| Type | Frequency | Day | Hosted By | Duration |
|------|-----------|-----|-----------|----------|
| Team | Weekly | Monday 09:00 | BH | 30 min |
| Branch | Weekly | Friday 09:00 | BM | 45 min |
| Regional | Monthly | Configurable | ROH | 60 min |

**Pre-meeting Form (due 1hr before):** Q1: Last week commitment (auto-filled), Q2: What achieved, Q3: Obstacles, Q4: Next commitment

### Score Calculation
- **RM scores:** Updated via PostgreSQL triggers on activity/pipeline/customer events
- **Manager aggregates:** Hierarchical rollup via cron every 10 minutes (dirty_users queue)
- **Period types:** WEEKLY (lead), MONTHLY, QUARTERLY (lag)
- **Snapshots:** Created when period is_locked=true (immutable historical record)

---

## 11. SYNC ENGINE

### Architecture
```
Write: User Action > Local Drift DB + Sync Queue (atomic transaction)
Push:  Queue FIFO > Supabase upsert/update > Mark synced | Retry on failure
Pull:  Fetch since last_pull_sync_at > Upsert local (skip isPendingSync=true records)
```

### Features
| Feature | Implementation |
|---------|---------------|
| **Atomic writes** | Drift transaction wraps local DB write + queue insertion |
| **Coalescing** | create+update > create (updated payload), create+delete > remove both, update+update > replace |
| **Debouncing** | 500ms batch window; manual sync bypasses debounce |
| **Incremental sync** | Per-entity `since` timestamps with 30s safety margin |
| **Version guard** | `_server_updated_at` payload metadata + `.eq('updated_at')` filter |
| **LWW conflict** | Higher updatedAt wins; conflicts logged to sync_conflicts table |
| **Idempotent creates** | Supabase upsert on client-generated UUIDs |
| **Pull guard** | Skip upsert for records with isPendingSync=true (preserve local edits) |
| **Dead letter** | Items exceeding 5 retries moved to dead_letter status; visible in UI |
| **Queue pruning** | Completed items >7 days auto-deleted |
| **Background sync** | WorkManager (Android) / BGTaskScheduler (iOS); push-only (30s iOS limit) |
| **Coordination** | SyncCoordinator: lock with 5min timeout, queue collapse, cooldown after initial sync |

### Sync Entity Types
customer, key_person, pipeline, activity, hvc, customer_hvc_link, broker, cadence_meeting, pipeline_referral

### Timestamp Serialization
- DateTime: `.toUtcIso8601()` extension (produces `Z` suffix)
- Date-only: `.toIso8601String().substring(0, 10)` (prevents UTC date-shift)

---

## 12. EDGE FUNCTIONS

| Function | Purpose | Trigger |
|----------|---------|---------|
| **admin-create-user** | Create Supabase Auth user + users table entry | Admin UI |
| **admin-reset-password** | Generate temporary password for user recovery | Admin UI |
| **score-aggregation-cron** | Process dirty_users queue for manager score recalculation | pg_cron (10 min) |

**Why Edge Functions:** Admin API ops require `service_role` key which must never be exposed client-side.

---

## 13. ROADMAP & PROGRESS

| Phase | Name | Plans | Status | Date |
|-------|------|-------|--------|------|
| 1 | Foundation & Observability | 3/3 | Complete | 2026-02-13 |
| 2 | Sync Engine Core | 3/3 | Complete | 2026-02-13 |
| 2.1 | Pre-existing Bug Fixes (timezone + dropdown) | 3/3 | Complete | 2026-02-13 |
| 3 | Error Classification & Recovery | 3/3 | Complete | 2026-02-14 |
| 3.1 | Remaining Repo Result Migration | 5/5 | Complete | 2026-02-14 |
| 4 | Conflict Resolution | 2/2 | Complete | 2026-02-16 |
| 5 | Background Sync & Dead Letter Queue | 3/3 | Complete | 2026-02-18 |
| 6 | Sync Coordination | 5/5 | Complete | 2026-02-19 |
| 7 | Offline UX Polish | 3/3 | Complete | 2026-02-19 |
| 8 | Stubbed Feature Completion | 3/4 | In Progress | - |
| 9 | Admin & Dashboard Features | 0/TBD | Not Started | - |
| 10 | Scoring Optimization | 0/TBD | Not Started | - |

**Velocity:** 32 plans complete | ~10 min avg/plan | ~5.1 hours total execution
**Progress:** ~86% (Phase 8 plan 3 of 4)

### Requirement Traceability
| Req Group | Phase(s) | Complete |
|-----------|----------|----------|
| SYNC-01..06 | P1, P2, P5 | 6/6 |
| ERR-01..04 | P1, P3 | 4/4 |
| CONF-01..05 | P4, P5, P6 | 5/5 |
| UX-01..04 | P7 | 4/4 |
| OBS-01..02 | P1 | 2/2 |
| SCORE-01..02 | P10 | 0/2 |
| FEAT-01..07 | P8, P9 | 3/7 |

---

## 14. KEY DECISIONS

### Architecture & Data
- Offline-first: write-local-first-sync-later contract for all operations
- Last-write-wins conflict resolution (not CRDT/merge); sufficient for single-user-per-record
- Soft deletes via `deleted_at` for all business data
- Client-generated UUIDs with Supabase upsert for idempotent creates
- Closure table (`user_hierarchy`) for hierarchical access control
- Per-entity timestamp keys for incremental sync (30s safety margin)
- Pull sync upsert skips isPendingSync=true records (preserve unsynced local edits)

### Sync Engine
- Full payload replacement on create+update coalesce (not field merge)
- 500ms debounce window for triggerSync() (balances responsiveness with batching)
- Background sync: push-only (no pull) to stay within iOS 30s BGTaskScheduler limit
- Background sync defaults OFF; user opt-in via Settings
- SyncCoordinator: Completer-based lock, 5min timeout, startup crash recovery
- Queue collapse: multiple sync requests while locked collapse into single follow-up
- 5s cooldown after initial sync prevents premature regular sync triggers

### Error Handling
- Sealed `Result<T>` replaces dartz `Either<Failure, T>` (full migration, dartz removed)
- `runCatching` for simple CRUD; explicit try/catch + `mapException` for complex methods
- `OfflineBanner` defaults to connected (avoid false offline flash on startup)

### UI & Forms
- SearchableDropdown with modal bottom sheet for ALL selection fields (not AutocompleteField)
- Modal titles in Indonesian (Pilih Provinsi, Pilih COB, etc.)
- Completed activities: only summary + notes editable (other fields locked)
- Object type/association always shown as read-only card in edit mode

### Scoring
- `scored_to_user_id` set on WON via trigger, never changes after (separates operational ownership from scoring)
- Dirty user tracking: triggers mark users dirty, cron processes every 10 min

### Infrastructure
- Sentry optional (empty DSN silently disables); tracesSampleRate 0.2 (20%)
- Talker v4.x (not v5.x) due to talker_riverpod_logger constraints
- `appRunner` pattern for Sentry so widget tree errors are captured

---

## 15. OUT OF SCOPE

| Excluded | Reason |
|----------|--------|
| Real-time sync via WebSocket/Realtime | Conflicts with offline-first, battery drain, unnecessary for CRM freshness |
| Per-field sync tracking | Exponential payload complexity for 12 entities; full-payload LWW sufficient |
| Full offline CRUD for admin ops | Edge Functions use service_role key; inherently online-only for security |
| Automatic merge for all conflicts | Silent data loss worse than LWW with notification |
| Infinite retry for sync failures | Battery waste; permanent errors (403, 404) should stop immediately |
| PowerSync / third-party sync | Vendor dependency + cost; existing architecture is sound |
| CI/CD pipeline | Manual deployment acceptable for now |
| OAuth/social login | Email/password sufficient for enterprise |
| Core Insurance System Integration | Separate integration project (Phase 2) |
| Commission Calculation | Existing finance system handles |
| Customer Self-Service Portal | Different product line |
| Email Marketing Automation | Different product category |
| Advanced AI/ML Predictions | Requires data maturity (Phase 3) |

### v2 Deferred
- DIFF-01: Smart sync prioritization (by business value)
- DIFF-02: Wi-Fi-only sync for photos
- DIFF-03: Optimistic UI with 5s undo window
- DIFF-04: Offline full-text search (Drift FTS5)
- DIFF-05: Per-entity sync progress display
- DIFF-06: Automatic conflict notification with field-level diff
- INFRA-01: Riverpod 3 + Freezed 3 upgrade
- INFRA-02..04: CI/CD, error tracking dashboard, analytics

---

## 16. BUILD & TEST

### Build Commands
```
flutter pub get                                          # install deps
dart run build_runner build --delete-conflicting-outputs  # code gen (Drift, Freezed, Riverpod, JSON)
flutter run -d chrome                                    # run web
flutter build apk --release                              # android release
flutter build ios --release                              # iOS release
flutter test                                             # all tests
flutter test test/path/to/specific_test.dart             # single test
flutter analyze                                          # lint check
```

### Test Inventory
| Category | Location | Framework |
|----------|----------|-----------|
| Unit (repositories) | test/data/repositories/ | flutter_test + mocktail |
| Unit (services) | test/data/services/ | flutter_test + mocktail |
| Integration (flows) | test/integration/ | flutter_test + fakes |
| Widget (screens) | test/presentation/screens/ | flutter_test + ProviderScope overrides |
| Helpers | test/helpers/ | Factory functions, fakes, mocks |

**Test Patterns:** Arrange-Act-Assert, mocktail for mocking, FakeRepository pattern for widget tests, `createTestCustomer()` factory functions.

### Code Generation Triggers
Run `build_runner` after modifying: `*.freezed.dart`, `*.g.dart`, DTOs in `lib/data/dtos/`, entities in `lib/domain/entities/`, database tables in `lib/data/database/tables/`.

### Environment
- `.env` bundled as asset (SUPABASE_URL, SUPABASE_ANON_KEY required)
- Optional: DEBUG, API_TIMEOUT, SYNC_INTERVAL, MAX_SYNC_RETRIES, GPS_DISTANCE_FILTER, VISIT_DISTANCE_THRESHOLD
- Supabase Edge Functions deployed via `supabase functions deploy`

---

*End of compressed reference. Total: 30 stability requirements, 18 functional requirements, 57 screens, 13 entity types, 40+ DB tables, 10 roadmap phases.*
