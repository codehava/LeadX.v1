# Roadmap: LeadX CRM Stability

## Overview

This roadmap transforms LeadX from a feature-complete but unreliable offline CRM into a production-ready application. We build foundation first (schema, observability, error types), stabilize the sync engine (atomic operations, delta sync, debouncing), add conflict resolution and error recovery, implement background sync, polish offline UX, complete stubbed features, and optimize scoring. Each phase delivers verifiable user value while building toward rock-solid offline-first reliability.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation & Observability** - Schema standardization, error types, crash reporting, structured logging
- [x] **Phase 2: Sync Engine Core** - Atomic operations, delta sync, queue coalescing, debounced triggers
- [x] **Phase 02.1: Pre-existing Bug Fixes** - Timezone serialization + dropdown race condition (INSERTED)
- [x] **Phase 3: Error Classification & Recovery** - Typed error hierarchy, retry policy, graceful offline fallback
- [x] **Phase 03.1: Remaining Repo Result Migration** - Migrate 7 remaining repos from dartz Either to sealed Result, remove dartz (INSERTED)
- [x] **Phase 4: Conflict Resolution** - Last-Write-Wins detection, conflict logging, idempotent operations
- [x] **Phase 5: Background Sync & Dead Letter Queue** - Workmanager integration, queue pruning, failed sync UI
- [ ] **Phase 6: Sync Coordination** - Initial sync gating, phase serialization, sync locks
- [ ] **Phase 7: Offline UX Polish** - Connectivity banner, sync status badges, staleness indicators
- [ ] **Phase 8: Stubbed Feature Completion** - Customer actions, activity editing, phone/email launch, notification settings
- [ ] **Phase 9: Admin & Dashboard Features** - User deletion, quick activity logging
- [ ] **Phase 10: Scoring Optimization** - Multi-period aggregation, team ranking calculation

## Phase Details

### Phase 1: Foundation & Observability
**Goal**: Establish consistent sync metadata schema, typed error foundation, and production observability before touching sync engine logic
**Depends on**: Nothing (first phase)
**Requirements**: SYNC-05, ERR-01, OBS-01, OBS-02
**Success Criteria** (what must be TRUE):
  1. All syncable tables have identical sync metadata columns (isPendingSync, lastSyncAt, updatedAt) with no entity-specific special cases
  2. Unhandled exceptions in production are captured in Sentry with user context and breadcrumbs
  3. All sync operations log to Talker with module prefixes (sync.queue, sync.push, sync.pull) replacing scattered debugPrint calls
  4. Sealed SyncError hierarchy exists with retryable vs permanent classification (NetworkSyncError, TimeoutSyncError, AuthSyncError, ValidationSyncError, ConflictSyncError)
  5. Drift schema baseline is exported and migration tested on production data copy before deployment
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md — SyncError hierarchy + schema migration v10 (ERR-01, SYNC-05)
- [x] 01-02-PLAN.md — Sentry crash reporting integration (OBS-01)
- [x] 01-03-PLAN.md — Talker structured logging replacing debugPrint (OBS-02)

### Phase 2: Sync Engine Core
**Goal**: Prevent data loss and reduce sync duration through atomic write-queue transactions, incremental sync, intelligent coalescing, and debounced triggers
**Depends on**: Phase 1 (requires standardized schema and error types)
**Requirements**: SYNC-01, SYNC-02, SYNC-03, SYNC-04
**Success Criteria** (what must be TRUE):
  1. User creating customer record followed by immediate edit never loses the edit during sync (create+update coalesces to create with updated payload)
  2. App crash between local DB write and sync queue insertion never loses data (single Drift transaction wraps both)
  3. Sync after initial full pull completes in under 5 seconds for typical field rep usage (50 customers, 200 activities) instead of 30+ seconds
  4. Rapid successive repository writes (e.g., importing 10 customers) trigger only one sync batch after 500ms window instead of 10 thundering syncs
  5. Incremental sync passes since timestamps to all remote data source methods and fetches only records with updated_at > last_pull_sync_at
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md — Queue coalescing + debounced sync triggers (SYNC-03, SYNC-04)
- [x] 02-02-PLAN.md — Atomic transactions for Customer, Pipeline, Activity repos (SYNC-01 part 1)
- [x] 02-03-PLAN.md — Atomic transactions for remaining repos + incremental sync (SYNC-01 part 2, SYNC-02)

### Phase 02.1: Pre-existing Bug Fixes — Timezone Serialization + Dropdown Race Condition (INSERTED)

**Goal:** Fix two pre-existing bugs discovered during Phase 2 UAT: (1) timezone serialization — all `.toIso8601String()` calls in sync payloads omit UTC indicator, causing Supabase to misinterpret local timestamps as UTC (86 occurrences across 9 repos), (2) AutocompleteField dropdown race condition — 200ms overlay removal window causes selection loss on tap
**Depends on:** Phase 2
**Requirements:** None (pre-existing bugs, not tracked requirements)
**Success Criteria** (what must be TRUE):
  1. Activity created at 9 PM WIB appears as 9 PM WIB on the server (not 4 AM next day)
  2. All `.toIso8601String()` in sync payloads use `.toUtc().toIso8601String()` producing timestamps with `Z` suffix
  3. Selecting a dropdown value in customer and pipeline forms consistently populates the form field
  4. AutocompleteField overlay race condition eliminated or mitigated
**Plans:** 3 plans

Plans:
- [x] 02.1-01-PLAN.md — UTC helper + repository sync payload timestamp fixes (88 occurrences)
- [x] 02.1-02-PLAN.md — Remote data source + service + provider timestamp fixes (72 occurrences)
- [x] 02.1-03-PLAN.md — Replace AutocompleteField with SearchableDropdown (11 fields)

### Phase 3: Error Classification & Recovery
**Goal**: Replace generic exception handling with typed error propagation, enable intelligent retry decisions, and gracefully handle offline states in UI
**Depends on**: Phase 1 (requires SyncError hierarchy), Phase 2 (requires stable sync engine to layer errors on)
**Requirements**: ERR-02, ERR-03, ERR-04
**Success Criteria** (what must be TRUE):
  1. All repository methods return Result<T> instead of throwing raw exceptions (migration complete for at least CustomerRepository, PipelineRepository, ActivityRepository)
  2. Customer list screen shows cached customer data with "Offline - data may be stale" warning when network unavailable instead of error text or crash
  3. Supabase 401 auth errors during sync are mapped to AuthFailure and stop retrying immediately instead of retrying 5 times
  4. Network timeout during customer create returns NetworkFailure with user-facing message "Check your connection and try again" instead of raw TimeoutException
  5. Screens handle Result errors with pattern matching (success/failure) and show appropriate UI states (loading, success, error with retry)
**Plans**: 3 plans

Plans:
- [x] 03-01-PLAN.md -- Sealed Result<T> type + exception mapper + CustomerRepository migration
- [x] 03-02-PLAN.md -- PipelineRepository + ActivityRepository migration to Result type
- [x] 03-03-PLAN.md -- OfflineBanner widget + screen error display improvements

### Phase 03.1: Remaining Repo Result Migration (INSERTED)

**Goal:** Migrate 7 remaining repositories (auth, admin_user, admin_master_data, broker, hvc, cadence, pipeline_referral) from dartz Either<Failure, T> to sealed Result<T>, update provider consumers from .fold() to switch pattern matching, update tests, and remove dartz from pubspec.yaml
**Depends on:** Phase 3 (requires Result type and migration pattern)
**Requirements:** None (consistency cleanup, not tracked requirement)
**Success Criteria** (what must be TRUE):
  1. All 7 remaining repository interfaces use Result<T> instead of Either<Failure, T>
  2. All provider .fold() call sites for these repos use switch/when pattern matching
  3. All repository tests pass with Result-based assertions
  4. dartz removed from pubspec.yaml with no remaining imports in lib/
  5. Either.toResult() adapter removed from result.dart
**Plans:** 5 plans

Plans:
- [x] 03.1-01-PLAN.md — Broker + AdminUser + HVC repository migration (17 methods)
- [x] 03.1-02-PLAN.md — AdminMasterData + PipelineReferral migration + key_person_form_sheet bug fix (20 methods)
- [x] 03.1-03-PLAN.md — AuthRepository migration with tests (11 methods, 6 consumers, 3 test files)
- [x] 03.1-04-PLAN.md — CadenceRepository migration with Unit-to-void conversion (18 methods)
- [x] 03.1-05-PLAN.md — Remove dartz dependency and EitherToResult adapter (final cleanup)

### Phase 4: Conflict Resolution
**Goal**: Detect when local and remote data diverge, apply Last-Write-Wins policy, log conflicts for audit, and ensure sync operations are idempotent
**Depends on**: Phase 2 (requires delta sync with updatedAt timestamps), Phase 3 (requires typed error handling)
**Requirements**: CONF-01, CONF-03
**Success Criteria** (what must be TRUE):
  1. User editing customer offline while another user edits same customer results in deterministic Last-Write-Wins merge based on updatedAt comparison (higher timestamp wins)
  2. Conflicts are logged to sync_conflicts audit table with before/after payload snapshots and timestamp metadata
  3. Sync create operations use Supabase upsert on client-generated UUIDs so retrying same operation doesn't create duplicates
  4. Sync update operations include updatedAt version guard so concurrent updates don't silently overwrite without detection
  5. User can see count of recent conflicts in sync status UI (even if resolution is automatic LWW)
**Plans**: 2 plans

Plans:
- [x] 04-01-PLAN.md — SyncConflicts table + SyncService conflict detection and LWW resolution (CONF-01, CONF-03)
- [x] 04-02-PLAN.md — Repository version guard metadata + coalescing update + pull sync guard + conflict count UI

### Phase 5: Background Sync & Dead Letter Queue
**Goal**: Sync persists across app restarts, failed items are pruned and surfaced to users, and queue doesn't grow indefinitely
**Depends on**: Phase 3 (requires error classification for dead letter detection), Phase 4 (requires idempotent operations for safe background retry)
**Requirements**: SYNC-06, CONF-02, CONF-04
**Success Criteria** (what must be TRUE):
  1. User creating activity while app is backgrounded has sync complete via workmanager within 15 minutes (Android WorkManager, iOS BGTaskScheduler)
  2. Sync queue items older than 7 days with status completed are pruned automatically (deleted from sync_queue table)
  3. Items exceeding 5 retry attempts are moved to dead letter state and visible in Failed Sync Items UI with retry/discard buttons
  4. User sees badge count of failed sync items on Settings screen and can navigate to dead letter queue list
  5. Retrying a dead letter item resets retryCount and marks isPendingSync=true, discarding removes from queue and marks entity as sync error
**Plans**: 3 plans

Plans:
- [x] 05-01-PLAN.md — Dead letter foundation: status column migration v12, sync service dead letter logic, queue pruning, providers (SYNC-06, CONF-02)
- [x] 05-02-PLAN.md — Dead letter UI: evolve SyncQueueScreen, error translator, settings badge + timestamp, app bar warning (CONF-02, SYNC-06)
- [x] 05-03-PLAN.md — Background sync: workmanager integration, iOS/Android config, settings toggle (CONF-04)

### Phase 6: Sync Coordination
**Goal**: Prevent race conditions between initial sync and regular sync, serialize push/pull phases, and ensure single sync execution at a time
**Depends on**: Phase 2 (requires delta sync), Phase 5 (requires background sync)
**Requirements**: CONF-05
**Success Criteria** (what must be TRUE):
  1. User creating customer during initial sync sees sync queued but not pushed until initial sync completes (prevents pushing before reference data is pulled)
  2. Regular sync executes push phase fully before pull phase starts (prevents pull overwriting data that hasn't pushed yet)
  3. Triggering sync while another sync is in progress queues the request and executes after current sync completes instead of silently dropping
  4. Multiple repositories triggering sync simultaneously results in single coordinated sync execution instead of multiple overlapping syncs
  5. Sync lock acquisition and release is logged with phase metadata (push/pull) and duration for debugging coordination issues
**Plans**: 3 plans

Plans:
- [ ] 06-01-PLAN.md -- SyncCoordinator service + SyncType enum + SyncService/InitialSyncService integration (CONF-05)
- [ ] 06-02-PLAN.md -- SyncProgressSheet retry/backoff/cancel-logout + caller fixes (CONF-05)
- [ ] 06-03-PLAN.md -- Provider wiring + SyncNotifier coordination + background sync gate + app startup (CONF-05)

### Phase 7: Offline UX Polish
**Goal**: Make offline state and sync status transparent to users through persistent banners, status badges, and staleness indicators
**Depends on**: Phase 3 (requires stable offline error handling), Phase 5 (requires reliable sync for status accuracy)
**Requirements**: UX-01, UX-02, UX-03, UX-04
**Success Criteria** (what must be TRUE):
  1. Offline connectivity banner appears at top of every screen when device has no internet access and remains visible until connection restored
  2. Customer cards in list view show pending/synced badge icon and activity detail screen shows sync status at top
  3. Dashboard displays "Last synced: X minutes ago" timestamp sourced from last_pull_sync_at in AppSettings
  4. User tapping failed sync badge count navigates to dead letter queue UI showing failed items with entity type, timestamp, and error message
  5. Sync status indicators update reactively via Drift streams (pending badge disappears immediately when isPendingSync=false after sync)
**Plans**: TBD

Plans:
- [ ] 07-01: TBD
- [ ] 07-02: TBD

### Phase 8: Stubbed Feature Completion
**Goal**: Complete half-implemented features for customer actions, activity editing, and communication launchers
**Depends on**: Phase 3 (requires typed error handling for feature robustness)
**Requirements**: FEAT-01, FEAT-02, FEAT-03, FEAT-04, FEAT-05
**Success Criteria** (what must be TRUE):
  1. User tapping Share button on customer detail screen launches native share sheet with customer data (name, company, phone, email) via share_plus
  2. User tapping Delete button on customer detail screen shows confirmation dialog, soft-deletes customer (sets deleted_at), and navigates back to list
  3. User tapping phone number on customer detail, HVC detail, or activity detail launches phone dialer with pre-filled number via url_launcher
  4. User tapping email address on customer detail, HVC detail, or activity detail launches email client with pre-filled recipient via url_launcher
  5. User tapping existing activity card navigates to activity form in edit mode with pre-filled data and can update fields and save changes
  6. Notification Settings screen exists and is navigable from Settings menu with placeholder UI for future notification preferences
**Plans**: TBD

Plans:
- [ ] 08-01: TBD
- [ ] 08-02: TBD

### Phase 9: Admin & Dashboard Features
**Goal**: Complete admin user management and dashboard quick actions
**Depends on**: Phase 3 (requires typed error handling)
**Requirements**: FEAT-06, FEAT-07
**Success Criteria** (what must be TRUE):
  1. Admin user deleting user from admin panel soft-deletes user (sets deleted_at), cascades to user_hierarchy/user_targets/user_scores, and removes from active user list
  2. User tapping quick activity FAB on dashboard opens bottom sheet with activity form (customer picker, activity type, notes) and successfully creates activity
  3. Quick activity bottom sheet validates required fields (customer, activity type) and shows error states for incomplete submissions
  4. Activity created via quick logging appears immediately in activity list and dashboard recent activities (reactive Drift stream update)
**Plans**: TBD

Plans:
- [ ] 09-01: TBD
- [ ] 09-02: TBD

### Phase 10: Scoring Optimization
**Goal**: Fix multi-period score aggregation and implement team ranking calculation
**Depends on**: Phase 2 (requires stable sync for score data integrity)
**Requirements**: SCORE-01, SCORE-02
**Success Criteria** (what must be TRUE):
  1. User scoreboard displays LEAD and LAG scores pulled from their respective active scoring periods and computes composite score correctly
  2. Multi-period queries fetch scores using period.start_date and period.end_date boundaries instead of assuming single active period
  3. Team ranking calculation runs after score updates and populates rank/rankChange fields based on composite score comparison within team
  4. Manager viewing team scoreboard sees team members sorted by rank with correct rank values (1, 2, 3) and rank change indicators (up/down/same)
  5. Score aggregation handles missing LEAD or LAG scores gracefully (uses 0 or null appropriately instead of crashing)
**Plans**: TBD

Plans:
- [ ] 10-01: TBD
- [ ] 10-02: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 2.1 → 3 → 3.1 → 4 → 5 → 6 → 7 → 8 → 9 → 10

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Observability | 3/3 | ✓ Complete | 2026-02-13 |
| 2. Sync Engine Core | 3/3 | ✓ Complete | 2026-02-13 |
| 02.1. Pre-existing Bug Fixes | 3/3 | ✓ Complete | 2026-02-13 |
| 3. Error Classification & Recovery | 3/3 | ✓ Complete | 2026-02-14 |
| 03.1. Remaining Repo Result Migration | 5/5 | ✓ Complete | 2026-02-14 |
| 4. Conflict Resolution | 2/2 | ✓ Complete | 2026-02-16 |
| 5. Background Sync & Dead Letter Queue | 3/3 | Complete | 2026-02-18 |
| 6. Sync Coordination | 0/TBD | Not started | - |
| 7. Offline UX Polish | 0/TBD | Not started | - |
| 8. Stubbed Feature Completion | 0/TBD | Not started | - |
| 9. Admin & Dashboard Features | 0/TBD | Not started | - |
| 10. Scoring Optimization | 0/TBD | Not started | - |

---
*Created: 2026-02-13*
*Last updated: 2026-02-18 — Phase 5 complete (3/3)*
