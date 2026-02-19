# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-13)

**Core value:** Sales reps can reliably capture and access customer data in the field regardless of connectivity — data is never lost, always available, and syncs transparently when online.
**Current focus:** Phase 6 complete (5/5 plans) - ready for Phase 7

## Current Position

Phase: 7 of 10 (Offline UX Polish)
Plan: 0 of TBD
Status: Not started
Last activity: 2026-02-19 - Phase 6 gap closure plan (06-05) executed

Progress: [███████░░░] ~70%

## Performance Metrics

**Velocity:**
- Total plans completed: 26
- Average duration: 10 min
- Total execution time: 4.2 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation-observability | 3/3 | 41 min | 14 min |
| 02-sync-engine-core | 3/3 | 19 min | 6 min |
| 02.1-pre-existing-bug-fixes | 3/3 | 14 min | 5 min |
| 03-error-classification-recovery | 3/3 | 37 min | 12 min |
| 03.1-remaining-repo-result-migration | 5/5 | 64 min | 13 min |
| 04-conflict-resolution | 2/2 | 26 min | 13 min |
| 05-background-sync-dead-letter-queue | 3/3 | 24 min | 8 min |
| 06-sync-coordination | 5/5 | 41 min | 8 min |

**Recent Trend:**
- Last 5 plans: 06-05 (5 min), 06-04 (5 min), 06-03 (12 min), 06-02 (6 min), 06-01 (13 min)
- Trend: Stable

*Updated after each plan completion*
| Phase 06 P01 | 13 | 2 tasks | 5 files |
| Phase 06 P02 | 6 | 2 tasks | 4 files |
| Phase 06 P03 | 12 | 2 tasks | 4 files |
| Phase 06 P04 | 5 | 2 tasks | 4 files |
| Phase 06 P05 | 5 | 2 tasks | 4 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- Focus on stability before new features — Unreliable sync/offline undermines all other value
- Complete stubbed features after stability — Features half-done create user confusion
- Keep last-write-wins conflict resolution for now — Full CRDT/merge is complex; last-write-wins sufficient for single-user-per-record
- Maintain offline-first pattern for all fixes — Every fix must preserve the write-local-first-sync-later contract
- Used appRunner pattern for Sentry so widget tree errors are captured (01-02)
- SENTRY_DSN is optional; empty string silently disables Sentry (01-02)
- tracesSampleRate 0.2 (20%) balances observability with performance (01-02)
- SyncError implements Exception for lint compliance while keeping sealed class (01-01)
- Activities.syncedAt renamed via ALTER TABLE RENAME COLUMN to preserve data (01-01)
- All syncable tables now have standardized isPendingSync + lastSyncAt + updatedAt (01-01)
- Talker v4.x instead of v5.x due to talker_riverpod_logger dependency constraints (01-03)
- Module prefix convention 'module.sub | message' with pipe separator for searchability (01-03)
- Log levels: debug (routine), info (state changes), warning (non-critical), error (exceptions) (01-03)
- Full payload replacement on create+update coalesce, not merge (02-01)
- SyncNotifier calls processQueue() directly to bypass debounce for manual sync (02-01)
- 500ms debounce window for triggerSync() balances responsiveness with batching (02-01)
- Dart 3 record pattern matching for coalescing rules (02-01)
- CustomerRepositoryImpl gets _database via constructor injection matching pipeline/activity pattern (02-02)
- Exception thrown inside transactions (not NotFoundFailure) to satisfy only_throw_errors lint (02-02)
- clearPrimaryForCustomer moved inside transaction for full atomicity (02-02)
- rescheduleActivity wrapped as 5th activity method since updateActivity doesn't exist (02-02)
- 30-second safety margin on since timestamps prevents missed records at cost of occasional duplicates (02-03)
- Per-entity timestamp keys use table names: customers, key_persons, pipelines, activities, hvcs, customer_hvc_links, brokers, cadence_meetings, pipeline_referrals (02-03)
- endMeeting wraps all participant score calculations + meeting end + all queue ops in single transaction (02-03)
- toUtcIso8601() extension method for natural call syntax matching .toIso8601String() pattern (02.1-01)
- Date-only fields use .toIso8601String().substring(0,10) to prevent UTC date-shift for UTC+ timezones (02.1-01)
- Direct widget swap from AutocompleteField to SearchableDropdown -- APIs compatible (same param names) (02.1-03)
- Modal titles in Indonesian matching existing UI conventions (Pilih Provinsi, Pilih COB, etc.) (02.1-03)
- All dropdown selection fields use SearchableDropdown with modal bottom sheet pattern (02.1-03)
- [Phase 02.1]: admin_user_remote_data_source.dart left unchanged -- already uses .toUtc().toIso8601String() correctly (02.1-02)
- ResultFailure instead of Failure_ to satisfy camel_case_types lint (03-01)
- runCatching for simple CRUD, explicit try/catch+mapException for complex methods with not-found logic (03-01)
- Generic Exception maps to UnexpectedFailure via mapException, not DatabaseFailure (03-01)
- OfflineBanner defaults to connected (valueOrNull ?? true) to avoid false offline flash on startup (03-03)
- OfflineBanner placed inside Column above Expanded content, not wrapping children (03-03)
- AppErrorState.general() for all Drift error callbacks since network errors handled by OfflineBanner separately (03-03)
- updateCustomer returns null from transaction on not-found, enabling proper NotFoundFailure return (03-01)
- runCatching for simple CRUD (deletePipeline, addPhoto, deletePhoto, addPhotoFromUrl); explicit try/catch+mapException for complex methods (03-02)
- Pipeline screen sheets (stage_update, status_update) updated as blocking deviation -- direct .fold() callers must migrate too (03-02)
- Pre-existing test bug fixed: closedAt test missing finalPremium and mock override ordering issue (03-02)
- NotFoundFailure for not-found cases in CadenceRepository submitPreMeetingForm (replacing generic DatabaseFailure) (03.1-04)
- runCatching for simple CRUD in CadenceRepository (8 methods), explicit try/catch+mapException for complex multi-step (7 methods) (03.1-04)
- linkCustomerToHvc uses explicit try/catch (not runCatching) for early-return ValidationFailure on duplicate link check (03.1-01)
- AdminUser methods all use runCatching since they are simple online-only remote calls (03.1-01)
- runCatching for simple AdminMasterData methods; explicit try/catch+mapException for validation methods with code uniqueness or dependency checks (03.1-02)
- PipelineReferral: explicit try/catch+mapException for all 6 mutation methods since all have validation (status/auth/not-found checks) (03.1-02)
- .isSuccess replacing .isRight() for unmounted-notifier early-return pattern in StateNotifiers (03.1-02)
- Preserved custom _mapAuthError() with Indonesian-locale messages instead of replacing with generic mapException (03.1-03)
- Auth test suite rewritten from mockito to mocktail with custom Fakes for Supabase Future-implementing types (03.1-03)
- FakeSupabaseClient + FakeQueryChain + _FakeTransformBuilder pattern for testing Supabase-dependent code (03.1-03)
- Pull sync upsert methods skip isPendingSync=true records to prevent server data overwriting unsynced local edits (04-02)
- Coalescing update+update preserves first _server_updated_at (true server state); create+update strips it (irrelevant for new records) (04-02)
- Batch pre-filter pattern for pull guard: query pending IDs into Set, filter upsert list; individual check for single-record upserts (04-02)
- Upsert for creates makes retry-after-timeout idempotent (no duplicate records on server) (04-01)
- Version guard via _server_updated_at payload metadata + .eq('updated_at') filter for optimistic locking (04-01)
- LWW resolution: higher updated_at wins; resolved conflicts treated as successful (not failed) (04-01)
- Full field-level server-wins for customer/pipeline/activity; secondary entities defer to next pull cycle (04-01)
- Pipeline/activity _applyServerDataLocally field mappings corrected to match actual Drift schema (04-01)
- No 'completed' status on sync queue -- completed items deleted immediately via markAsCompleted() (05-01)
- isPendingSync implicitly true for all unsynced items; only cleared on sync success or explicit discard (05-01)
- _markEntityAsLocalOnly sets isPendingSync=false and lastSyncAt=null for local-only state (05-01)
- Pruning errors caught non-fatally to prevent blocking sync result (05-01)
- [Phase 05]: SyncErrorTranslator uses contains-based pattern matching for error classification (05-02)
- [Phase 05]: Dead letter badge (red) takes priority over pending count badge (warning) in app bar (05-02)
- [Phase 05]: Gagal filter default view shows failed+dead_letter since that is primary user concern (05-02)
- [Phase 05]: Push-only in background (no pull) to stay within iOS 30-second BGTaskScheduler limit (05-03)
- [Phase 05]: Always register periodic task on startup; callback checks toggle setting and skips if disabled (05-03)
- [Phase 05]: Background sync defaults to OFF -- user must opt in via Settings toggle (05-03)
- [Phase 05]: backgroundSyncEnabledProvider uses AppSettings (Drift) -- no shared_preferences dependency added (05-03)
- [Phase 06]: SyncCoordinator injected as optional parameter to preserve backward compatibility for standalone background sync (06-01)
- [Phase 06]: Completer-based lock with 5-minute timeout and startup crash recovery via persisted lock holder key (06-01)
- [Phase 06]: 5-second cooldown after initial sync prevents premature regular sync triggers (06-01)
- [Phase 06]: Queue collapse -- multiple sync requests while locked collapse into single follow-up execution (06-01)
- [Phase 06]: SyncProgressSheet.show() returns Future<bool> for caller flow control -- true=success, false=failure/cancelled (06-02)
- [Phase 06]: Cancel-and-logout calls signOut() + preserves local DB, relies on GoRouter auth guard for redirect (06-02)
- [Phase 06]: Re-sync guard uses syncService.isSyncing as bridge until coordinator provider wired in plan 03 (06-02)
- [Phase 06]: Retry delays 2s/5s/15s (3 attempts) for progressive backoff on initial sync failure (06-02)
- [Phase 06]: UncontrolledProviderScope in main.dart for eager initializeSyncServices() call before widget tree (06-03)
- [Phase 06]: Manual sync toast shown at UI layer via coordinator.isLocked check; non-manual triggers are silent (06-03)
- [Phase 06]: Background sync uses AppSettingsService.hasInitialSyncCompleted() gate before processing queue (06-03)
- [Phase 06]: Queued sync silent for non-manual triggers; only user-initiated manual sync shows toast (06-03)
- [Phase 06]: WidgetsFlutterBinding moved inside Sentry appRunner to avoid zone mismatch -- binding must be in same zone as runApp (06-04)
- [Phase 06]: coordinator.markInitialSyncComplete() replaces direct appSettings call in UI to set both persisted and in-memory flags (06-04)
- [Phase 06]: onLongPress re-sync guard checks coordinator.isLocked plus legacy isSyncing fallback (06-04)
- [Phase 06]: skipInitialSyncChecks bypasses both _initialSyncComplete gate AND cooldown gate for Phase 2/3 of initial sync (06-05)
- [Phase 06]: markInitialSyncComplete() called AFTER Phase 3 (not before Phase 2) so cooldown starts only after full sequence (06-05)
- [Phase 06]: Safety-net markInitialSyncComplete() calls in login_screen/home_screen left untouched as harmless redundancy (06-05)

### Roadmap Evolution

- Phase 2.1 inserted after Phase 2: Pre-existing Bug Fixes — Timezone Serialization + Dropdown Race Condition (URGENT) — discovered during Phase 2 UAT, both bugs pre-date Phase 2 changes
- Phase 3.1 inserted after Phase 3: Remaining Repo Result Migration — migrate 7 remaining repos from dartz Either to sealed Result, remove dartz dependency

### Pending Todos

None yet.

### Blockers/Concerns

None yet.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 1 | create a compressed spec md for a potential sixth iteration listing the spec the reqs and lesson learned for the next GSD framework based iteration | 2026-02-16 | 33c472e | [1-create-a-compressed-spec-md-for-a-potent](./quick/1-create-a-compressed-spec-md-for-a-potent/) |

## Session Continuity

Last session: 2026-02-19
Stopped at: Completed 06-05-PLAN.md (cooldown-gate bypass for initial sync phases)
Resume file: N/A

---
*Last updated: 2026-02-19 (Phase 6 gap closure 06-05 complete)*
