# Requirements: LeadX CRM Stability

**Defined:** 2026-02-13
**Core Value:** Sales reps can reliably capture and access customer data in the field regardless of connectivity

## v1 Requirements

Requirements for stability milestone. Each maps to roadmap phases.

### Sync Engine

- [ ] **SYNC-01**: Local DB write and sync queue insertion are wrapped in a single Drift transaction so a crash between them never loses data
- [ ] **SYNC-02**: Incremental sync passes `since` timestamps to all `syncFromRemote()` calls instead of pulling full tables every time
- [ ] **SYNC-03**: Queue coalescing handles operation sequences correctly (create+update merges to create with updated payload, create+delete removes both, update+update replaces payload)
- [ ] **SYNC-04**: Sync triggers are debounced (500ms batch window) to prevent thundering herd from `unawaited(triggerSync())` on every repository write
- [ ] **SYNC-05**: All syncable tables use consistent sync metadata columns (`isPendingSync`, `lastSyncAt`, `updatedAt`) via Drift migration
- [x] **SYNC-06**: Sync queue is pruned periodically — completed items older than 7 days are removed, dead items are surfaced

### Error Handling

- [ ] **ERR-01**: A sealed `SyncError` hierarchy classifies sync failures as retryable (network, timeout, 5xx) vs permanent (auth 401, validation 400, constraint 409)
- [ ] **ERR-02**: Repositories use Dart-native sealed `Result<T>` type instead of dartz `Either<Failure, T>` (incremental migration, repository-by-repository)
- [ ] **ERR-03**: All screens show cached data with staleness warning when offline instead of raw error strings or crashes
- [ ] **ERR-04**: Supabase/network exceptions are mapped to typed `Failure` subclasses throughout all repository methods

### Conflict Resolution & Recovery

- [ ] **CONF-01**: Last-Write-Wins conflict detection compares local and server `updatedAt` timestamps during push sync, logging conflicts to audit table
- [x] **CONF-02**: User can view permanently failed sync items in a dead letter queue UI with retry and discard options
- [ ] **CONF-03**: Sync operations are idempotent — creates use Supabase upsert on client-generated UUIDs, updates use version guards
- [ ] **CONF-04**: Background sync persists across app restarts via workmanager (Android WorkManager, iOS BGTaskScheduler)
- [ ] **CONF-05**: SyncCoordinator prevents queue push before initial sync completes and serializes sync phases (push, pull)

### Offline UX

- [ ] **UX-01**: A persistent offline connectivity banner is visible at the top of every screen when the device is offline
- [ ] **UX-02**: Sync status badges (pending/synced) appear on all entity cards in list views and at top of detail screens
- [ ] **UX-03**: Dashboard displays "Last synced: X minutes ago" timestamp sourced from AppSettings
- [ ] **UX-04**: User can see failed sync items count as a badge and access a retry UI to retry or discard individual items

### Observability

- [ ] **OBS-01**: Sentry crash reporting is integrated and captures unhandled exceptions with context
- [ ] **OBS-02**: Talker structured logging replaces scattered `debugPrint` calls with module-prefixed, level-aware logging that forwards to Sentry

### Scoring

- [ ] **SCORE-01**: Multi-period score aggregation correctly pulls LEAD and LAG scores from their respective active scoring periods and computes the composite score
- [ ] **SCORE-02**: Team ranking calculation is implemented — compares scores across team members per period and updates rank/rankChange fields

### Stubbed Features

- [ ] **FEAT-01**: Customer detail screen share functionality works (via share_plus)
- [ ] **FEAT-02**: Customer detail screen delete functionality works with confirmation dialog
- [ ] **FEAT-03**: Phone call and email launch work from customer detail, HVC detail, and activity detail screens (via url_launcher)
- [ ] **FEAT-04**: Activities can be edited after creation via the activity form screen
- [ ] **FEAT-05**: Notification settings screen exists and is reachable from settings
- [ ] **FEAT-06**: Admin can delete users with cascading cleanup
- [ ] **FEAT-07**: Dashboard quick activity logging via bottom sheet is functional

## v2 Requirements

Deferred to future milestone. Tracked but not in current roadmap.

### Differentiators

- **DIFF-01**: Smart sync prioritization — queue ordered by business value, not just FIFO
- **DIFF-02**: Selective Wi-Fi-only sync for photos to prevent mobile data charges
- **DIFF-03**: Optimistic UI with 5-second undo window for offline writes
- **DIFF-04**: Offline full-text search via Drift FTS5 virtual tables
- **DIFF-05**: Per-entity sync progress display during regular sync (not just initial)
- **DIFF-06**: Automatic conflict notification with field-level diff UI

### Infrastructure

- **INFRA-01**: Riverpod 3 + Freezed 3 major version upgrade
- **INFRA-02**: CI/CD pipeline setup
- **INFRA-03**: Error tracking dashboard (beyond Sentry basics)
- **INFRA-04**: Analytics integration

## Out of Scope

| Feature | Reason |
|---------|--------|
| Real-time sync via WebSocket/Supabase Realtime | Conflicts with offline-first model, battery drain, unnecessary for CRM data freshness |
| Per-field sync tracking | Exponential payload complexity for 12 entity types; full-payload LWW is sufficient |
| Full offline CRUD for admin operations | Admin ops use Edge Functions with service_role key; inherently online-only for security |
| Automatic merge for all conflict types | Silent data loss worse than conflict dialog for CRM; LWW with notification is safer |
| Infinite retry for all sync failures | Wastes battery/data; permanent errors (403, 404) should stop retrying immediately |
| PowerSync or third-party sync service | Adds vendor dependency and cost; existing sync architecture is sound, needs targeted fixes |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SYNC-01 | Phase 2 | Pending |
| SYNC-02 | Phase 2 | Pending |
| SYNC-03 | Phase 2 | Pending |
| SYNC-04 | Phase 2 | Pending |
| SYNC-05 | Phase 1 | Pending |
| SYNC-06 | Phase 5 | Complete |
| ERR-01 | Phase 1 | Pending |
| ERR-02 | Phase 3 | Pending |
| ERR-03 | Phase 3 | Pending |
| ERR-04 | Phase 3 | Pending |
| CONF-01 | Phase 4 | Pending |
| CONF-02 | Phase 5 | Complete |
| CONF-03 | Phase 4 | Pending |
| CONF-04 | Phase 5 | Pending |
| CONF-05 | Phase 6 | Pending |
| UX-01 | Phase 7 | Pending |
| UX-02 | Phase 7 | Pending |
| UX-03 | Phase 7 | Pending |
| UX-04 | Phase 7 | Pending |
| OBS-01 | Phase 1 | Pending |
| OBS-02 | Phase 1 | Pending |
| SCORE-01 | Phase 10 | Pending |
| SCORE-02 | Phase 10 | Pending |
| FEAT-01 | Phase 8 | Pending |
| FEAT-02 | Phase 8 | Pending |
| FEAT-03 | Phase 8 | Pending |
| FEAT-04 | Phase 8 | Pending |
| FEAT-05 | Phase 8 | Pending |
| FEAT-06 | Phase 9 | Pending |
| FEAT-07 | Phase 9 | Pending |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0

---
*Requirements defined: 2026-02-13*
*Last updated: 2026-02-13 after roadmap creation*
