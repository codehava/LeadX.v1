# Codebase Concerns

**Analysis Date:** 2026-02-13

## Tech Debt

### Missing Feature Implementations

**Team Scoring and Ranking:**
- Issue: Team rank and score change calculations are not implemented
- Files: `lib/data/datasources/remote/scoreboard_remote_data_source.dart` (line 380)
- Impact: The `UserScoreAggregate` entity has `rank` and `rankChange` columns (schema exists), but the actual calculation logic does not compare scores across teams and periods
- Fix approach: Implement `_calculateTeamRanking()` method in scoreboard remote data source that queries all team aggregates for a period, ranks them, and updates `rank` and `rankChange` fields

**Customer Detail Features:**
- Issue: Multiple unimplemented features in customer detail screen
- Files: `lib/presentation/screens/customer/customer_detail_screen.dart`
  - Line 182: Share functionality not implemented
  - Line 201: Delete customer not implemented
  - Line 486: Call phone not implemented (commented out)
  - Line 493: Email not implemented (commented out)
- Impact: UI shows buttons but actions fail silently or are disabled, leading to user confusion
- Fix approach: Implement share (share_plus package), delete (with confirmation dialog), and contact methods (url_launcher package)

**Activity and HVC Call/Email Features:**
- Issue: Phone and email launch functionality stubbed out
- Files:
  - `lib/presentation/screens/hvc/hvc_detail_screen.dart` (lines 674, 682)
  - `lib/presentation/screens/activity/activity_detail_screen.dart` (line 40)
- Impact: UI components exist but are non-functional
- Fix approach: Use url_launcher to implement tel: and mailto: links

**Notification Settings Navigation:**
- Issue: Notification settings route not implemented
- Files: `lib/presentation/screens/profile/settings_screen.dart` (line 90)
- Impact: Link goes nowhere; users cannot customize notifications
- Fix approach: Create notification settings screen and route

**Navigation and Sidebar TODOs:**
- Issue: Reports and Help routes planned but not available
- Files: `lib/presentation/widgets/shell/responsive_shell.dart` (lines 942, 957)
- Impact: Navigation items partially stubbed; UI is ready but features not implemented
- Fix approach: Implement reports dashboard and help/documentation screens

**User Deletion in Admin Module:**
- Issue: Delete user functionality placeholder exists but not implemented
- Files: `lib/presentation/screens/admin/users/user_detail_screen.dart` (line 364)
- Impact: Admin cannot fully manage user lifecycle
- Fix approach: Add delete user method to admin user repository with cascading cleanup

**Activity Form TODO:**
- Issue: Edit activity functionality not routed
- Files: `lib/presentation/screens/activity/activity_detail_screen.dart` (line 40)
- Impact: Activities cannot be edited after creation
- Fix approach: Implement activity edit flow in activity form screen

**Dashboard Immediate Activity Sheet:**
- Issue: Immediate activity sheet action not shown
- Files: `lib/presentation/screens/home/tabs/dashboard_tab.dart` (line 325)
- Impact: Quick activity logging not triggered from dashboard
- Fix approach: Show bottom sheet to log immediate activity

---

## Error Handling Issues

### Silent Exception Catching

**Color Parsing Exception Silent Catch:**
- Issue: Color hex parsing silently fails without logging
- Files: `lib/presentation/widgets/activity/activity_card.dart` (line 239)
- Code: `catch (_) {}` when parsing activity type color
- Impact: Activity cards fall back to default color silently; no visibility into which color codes are malformed
- Fix approach: Log the exception and specific color value that failed

### Generic Exception Throwing in Notifiers

**Provider Error Propagation:**
- Issue: Exceptions are re-thrown as `Exception(failure.message)` instead of preserving error type
- Files: `lib/presentation/providers/admin_user_providers.dart` (lines 110, 125, 137, 149, 161, 177)
- Impact: Error types are lost; UI cannot differentiate between validation errors, network errors, and authorization errors
- Fix approach: Throw typed exceptions (ValidationException, NetworkException, etc.) or propagate AsyncError state properly

**Team Target Provider Exception:**
- Issue: Generic exception for hierarchy validation
- Files: `lib/presentation/providers/team_target_providers.dart` (line 70)
- Code: `throw Exception('User is not your subordinate')`
- Impact: Cannot distinguish authorization error from other failures
- Fix approach: Use custom AuthorizationException or return Either<Failure, T>

---

## Fragile Areas

### Race Conditions

**Initial Sync Race Condition:**
- Issue: SyncProgressSheet has static flag to prevent duplicates
- Files: `lib/presentation/widgets/sync/sync_progress_sheet.dart` (lines 12-23)
- Problem: Static boolean `_isShowing` is not thread-safe; if two navigation paths trigger sync simultaneously (LoginScreen and HomeScreen), the flag might not prevent actual duplicate syncs
- Impact: Initial sync could run twice, corrupting local data or creating duplicate records
- Fix approach: Replace static flag with a properly synchronized semaphore or use a provider-level guard

### Database Schema Inconsistencies

**Sync Timestamp Fields Inconsistent:**
- Issue: Different entities use different column names for sync tracking
- Files: `lib/data/services/sync_service.dart` (lines 261-346 in `_markEntityAsSynced`)
- Details:
  - `customers`, `pipelines`, `pipelineReferrals`: use `lastSyncAt`
  - `activities`: uses `syncedAt`
  - `hvcs`, `brokers`, `keyPersons`: don't have sync timestamp (only `isPendingSync`)
  - `cadenceMeetings`: uses `updatedAt` instead of sync timestamp
- Impact: Inconsistent sync state tracking; queries for "what was synced recently" must handle multiple column names
- Fix approach: Standardize all tables to use `syncedAt` timestamp column

**Multiple Sync Status Columns:**
- Issue: Some tables only have `isPendingSync`, others have both `isPendingSync` and `lastSyncAt`
- Impact: Drift-generated code in `_markEntityAsSynced` must handle each table individually; adding new entities requires remembering to update this switch statement
- Fix approach: Create a consistent sync tracking pattern with database views or helper functions

### Syncing Transactional Data

**Delta Sync vs Full Sync Boundary Unclear:**
- Issue: Some transactional tables (`hvcs`, `brokers`, `pipeline_referrals`) are synced in initial setup with full data instead of delta
- Files: `lib/data/services/initial_sync_service.dart` (lines 109-114)
- Problem: If user has many HVCs from previous login, all are re-fetched instead of just new/changed ones
- Impact: Bandwidth waste and longer initial sync time on repeat logins
- Fix approach: Track `last_synced_at` in AppSettingsService for each table and use `created_at >= lastSync` to fetch only changes

### Conditional Hard Delete Logic

**Entity-Specific Hard Delete in Sync:**
- Issue: Only `customerHvcLink` is hard-deleted; all others are soft-deleted
- Files: `lib/data/services/sync_service.dart` (lines 162-167, 241-246)
- Problem: Hardcoded check for one entity type; if more hard-delete entities are added, this must be updated
- Impact: Easy to forget and accidentally soft-delete when hard-delete is intended
- Fix approach: Add a property to entity schema definition that specifies delete strategy, or create a registry

---

## Performance Bottlenecks

### Inefficient Cadence Meeting Stats Calculation

**Multiple Async Calls Per Meeting:**
- Issue: `Future.wait()` used to map meetings to include stats
- Files: `lib/data/repositories/cadence_repository_impl.dart` (lines 308, 317, 326)
- Problem: Each meeting's stats are fetched via separate queries
- Impact: N+1 query pattern; if user has 20 meetings, 20+ queries are executed instead of one batch query
- Fix approach: Batch query for all meeting stats in one query, then attach to meetings

### Score Calculation Not Cached

**Real-Time Score Aggregation:**
- Issue: No indication of caching strategy for user score aggregates
- Files: `lib/domain/entities/scoring_entities.freezed.dart`
- Problem: Every scoreboard load might recalculate scores from individual measure scores
- Impact: Slow scoreboard rendering with many users
- Fix approach: Add materialized view or cached aggregate table that is updated on measure score insertion

### Initial Sync Full Table Loads

**Large Reference Table Pagination Issues:**
- Issue: Full tables like users, branches, master data are fetched with pagination but no batch optimization
- Files: `lib/data/services/initial_sync_service.dart`
- Problem: Each table sync makes separate API calls per page; 50-item pages mean 10+ calls for 500 items
- Impact: Slow initial setup on poor networks
- Fix approach: Increase page size or implement server-side filtering to reduce round trips

---

## Scaling Limits

### Local Database Growth

**Sync Queue Not Pruned:**
- Issue: Completed sync items are marked as completed but never deleted from `sync_queue` table
- Files: `lib/data/services/sync_service.dart` (line 159)
- Code: Only calls `markAsCompleted()`, no cleanup
- Impact: Local database grows indefinitely; after 1 year of syncing, the sync_queue table could have millions of old records
- Fix approach: Implement retention policy (delete items > 30 days old) or periodic cleanup job

**Activity Audit Log Unmanaged:**
- Issue: Audit logs are inserted but never archived or cleaned
- Impact: Mobile storage fills up with old audit records
- Fix approach: Archive old logs to cloud or implement local log rotation

### User Hierarchy Cache

**Name Lookup Cache Memory Impact:**
- Issue: Repositories have in-memory caches for name lookups (e.g., `_stageNameCache`)
- Files: `lib/data/repositories/pipeline_repository_impl.dart`, `activity_repository_impl.dart`
- Problem: Caches are never pruned or have unbounded size
- Impact: Long-running app instances accumulate cache memory; potential OOM on low-end devices
- Fix approach: Implement LRU cache with size limits or TTL-based cache expiration

---

## Network and Sync Issues

### Aggressive Server Reachability Checks

**Polling Interval Too Short:**
- Issue: ConnectivityService polls every 30 seconds
- Files: `lib/data/services/connectivity_service.dart` (line 29)
- Problem: Frequent health checks on `app_settings` table might create unnecessary database load
- Impact: Battery drain on mobile from frequent network activity
- Fix approach: Increase poll interval to 60-120 seconds or use exponential backoff

**Supabase API Call as Health Check:**
- Issue: Server reachability check queries `app_settings` table
- Files: `lib/data/services/connectivity_service.dart` (lines 157-160)
- Problem: If `app_settings` table has high contention or slow queries, health checks will be slow
- Impact: Sync operations delayed waiting for connectivity check
- Fix approach: Use a dedicated lightweight health check endpoint or a `SELECT 1` query instead

### Sync Retry Strategy Limited

**Fixed Max Retries:**
- Issue: All operations retry max 5 times with exponential backoff
- Files: `lib/data/services/sync_service.dart` (lines 45-49)
- Problem: No differentiation between transient (network timeout) and permanent (validation) failures
- Impact: Genuinely failed operations (invalid data) waste 5 retries before being abandoned
- Fix approach: Classify exceptions and use different retry strategies per type

**No Circuit Breaker Pattern:**
- Issue: If server is down, every sync attempt will fail after max retries
- Impact: No protection against cascading failures; UI might show sync failures repeatedly
- Fix approach: Implement exponential backoff with jitter, or circuit breaker pattern

---

## Security Considerations

### Incomplete Error Information Leakage

**Server Error Details Exposed:**
- Issue: Full exception messages from Supabase are exposed to UI
- Files: Multiple providers and repositories use `throw Exception(e.toString())`
- Impact: Internal error details (database schema, SQL errors) could be exposed in logs or UI
- Fix approach: Log full errors server-side; return generic user-facing error messages

### No Rate Limiting on Admin Operations

**Admin User Creation Not Rate Limited:**
- Issue: `createUser()` can be called repeatedly without rate limiting
- Files: `lib/data/datasources/remote/admin_user_remote_data_source.dart` (line 101)
- Impact: Malicious admin could spam user creation; no protection against API abuse
- Fix approach: Implement rate limiting on Edge Functions (admin-create-user)

---

## Test Coverage Gaps

### Sync Service Not Thoroughly Tested

**Edge Cases Missing:**
- What's not tested:
  - Sync failures partway through queue (some items succeed, others fail)
  - Duplicate sync items in queue
  - Sync with missing referenced entities
  - Database corruption during sync
- Files: `lib/data/services/sync_service.dart`
- Risk: Undetected sync data corruption; silent failures that corrupt local data
- Priority: High

### Initial Sync Resume Logic Untested

**What's not tested:**
- Resume from arbitrary checkpoint
- Resume with changed schema (new tables added)
- Recovery from corrupted resume state
- Files: `lib/data/services/initial_sync_service.dart` (lines 152-167)
- Risk: Resume feature could leave database in inconsistent state
- Priority: High

### Provider Notifier Error Paths

**What's not tested:**
- All admin user notifiers use `throw Exception` but don't have error state handling
- Exception propagation to UI not verified
- Files: `lib/presentation/providers/admin_user_providers.dart`
- Risk: Exceptions might crash the app instead of showing error dialogs
- Priority: Medium

### Connectivity Service on Real Networks

**What's not tested:**
- Actual WiFi/mobile network switching
- Server reachability checks with various network conditions (slow, intermittent)
- Race conditions in connectivity state transitions
- Files: `lib/data/services/connectivity_service.dart`
- Risk: Sync logic relies on accurate connectivity state; wrong state could cause data loss
- Priority: High

---

## Missing Critical Features

### No Offline-First Query Support

**What's missing:**
- Queries cannot be executed against local database with fallback to remote
- If user opens a screen offline, it fails instead of showing cached data
- Impact: Poor UX offline; users cannot view any data
- Blocks: Implementing offline-first viewing of master data

### No Data Synchronization Conflict Resolution

**What's missing:**
- If user edits locally and server has conflicting changes, sync will overwrite one or the other
- No merge strategy or conflict detection
- Impact: Data loss on concurrent edits from different devices
- Blocks: Multi-device support

### No Sync Queue Prioritization

**What's missing:**
- All sync items have equal priority; large batch create operations block important updates
- No way to prioritize critical syncs
- Impact: User creates 100 activities offline, then all must sync before any key customer updates are applied
- Blocks: High-priority data consistency

### No Offline Activity Queue Dashboard

**What's missing:**
- Users cannot see what changes are pending sync
- No way to inspect or manually trigger sync of specific items
- Impact: User has no visibility into sync state; doesn't know if changes were synced
- Blocks: Trust in offline-first system

---

## Dependencies at Risk

### Drift Database with Supabase Mismatch

**Risk:**
- Local Drift SQLite schema must exactly match PostgreSQL schema
- Generated Drift code can become out of sync with actual database
- Issue: Schema changes require manual synchronization; easy to miss a table or column
- Impact: Sync failures when columns don't exist, type mismatches
- Migration plan: Add schema versioning and validation; generate Dart code from PostgreSQL schema using migrations

### Deprecated or Unmaintained Packages

**Risk:**
- Freezed for model generation (widely used, stable)
- Riverpod for state management (actively maintained)
- Drift for local database (actively maintained)
- No identified risk with current dependencies
- Monitor: Check pub.dev for deprecation notices regularly

---

*Concerns audit: 2026-02-13*
