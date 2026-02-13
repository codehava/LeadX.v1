# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-13)

**Core value:** Sales reps can reliably capture and access customer data in the field regardless of connectivity — data is never lost, always available, and syncs transparently when online.
**Current focus:** Phase 3.1 - Remaining Repo Result Migration

## Current Position

Phase: 3.1 of 10 (Remaining Repo Result Migration)
Plan: 4 of 5 (03.1-01, 03.1-02, 03.1-03, 03.1-04 complete)
Status: Executing Phase 3.1
Last activity: 2026-02-14 — Completed 03.1-03 AuthRepository migration

Progress: [████░░░░░░] ~35%

## Performance Metrics

**Velocity:**
- Total plans completed: 15
- Average duration: 10 min
- Total execution time: 2.6 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation-observability | 3/3 | 41 min | 14 min |
| 02-sync-engine-core | 3/3 | 19 min | 6 min |
| 02.1-pre-existing-bug-fixes | 3/3 | 14 min | 5 min |
| 03-error-classification-recovery | 3/3 | 37 min | 12 min |
| 03.1-remaining-repo-result-migration | 4/5 | 56 min | 14 min |

**Recent Trend:**
- Last 5 plans: 03.1-03 (35 min), 03.1-02 (5 min), 03.1-04 (8 min), 03.1-01 (8 min), 03-03 (5 min)
- Trend: Stable

*Updated after each plan completion*

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

### Roadmap Evolution

- Phase 2.1 inserted after Phase 2: Pre-existing Bug Fixes — Timezone Serialization + Dropdown Race Condition (URGENT) — discovered during Phase 2 UAT, both bugs pre-date Phase 2 changes
- Phase 3.1 inserted after Phase 3: Remaining Repo Result Migration — migrate 7 remaining repos from dartz Either to sealed Result, remove dartz dependency

### Pending Todos

None yet.

### Blockers/Concerns

None yet.

## Session Continuity

Last session: 2026-02-14
Stopped at: Completed 03.1-03-PLAN.md (AuthRepository migration to sealed Result)
Resume file: None

---
*Last updated: 2026-02-14 (Phase 3.1, 03.1-03 complete)*
