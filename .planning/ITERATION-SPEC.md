# LeadX CRM - Iteration v5 Specification

Compressed reference for GSD-based iteration planning. Self-contained -- no other .planning files needed.

---

## Project Identity

**What:** Mobile-first, offline-first CRM for PT Askrindo's sales team implementing the 4 Disciplines of Execution (4DX) framework.

**Value:** Sales reps reliably capture and access customer data in the field regardless of connectivity -- data is never lost, always available, syncs transparently when online.

**Users:** Relationship Managers (field sales), Managers, Admins at PT Askrindo (enterprise insurance). Field reps work in areas with poor/no connectivity.

| Layer | Technology | Version/Notes |
|-------|-----------|---------------|
| Framework | Flutter | Cross-platform: iOS, Android, Web |
| State | Riverpod | Code-gen `@riverpod` |
| Navigation | GoRouter | Declarative, deep linking |
| Local DB | Drift | Type-safe SQLite, WASM for web |
| Backend | Supabase | PostgreSQL, Auth (GoTrue), Edge Functions |
| Models | Freezed | Immutable + JSON serialization |
| Crash Reporting | Sentry Flutter | Optional (empty DSN disables) |
| Logging | Talker v4.x | Module-prefixed structured logging |

---

## Architecture Summary

### Clean Architecture Layers

```
lib/
  config/          # env (.env), routes (GoRouter)
  core/            # errors (Result, Failures, SyncError, mapException), theme, logging (AppLogger), utils
  data/
    database/      # Drift tables (30+), migrations (v10), app_database.dart
    datasources/   # local/ (Drift), remote/ (Supabase)
    dtos/          # CreateDto, UpdateDto, SyncDto per entity
    repositories/  # Impl: orchestrate local DS + remote DS + SyncService
    services/      # SyncService, ConnectivityService, AppSettingsService, etc.
  domain/
    entities/      # Freezed business entities
    repositories/  # Interfaces (Result<T> return types)
  presentation/
    providers/     # Riverpod providers (StreamProvider for reactive UI)
    screens/       # Feature screens
    widgets/       # Reusable: OfflineBanner, SearchableDropdown, AppErrorState
```

### Offline-First Pattern

1. Write to local Drift/SQLite DB (immediate UI feedback)
2. Queue operation in sync_queue (inside same Drift transaction for atomicity)
3. `triggerSync()` outside transaction (fire-and-forget, 500ms debounced)
4. SyncService processes queue: coalesces redundant ops, pushes to Supabase
5. UI reads from local DB only via Drift `.watch()` streams

### Code Generation Chain

Freezed (`@freezed`) + Riverpod (`@riverpod`) + Drift (tables) + JSON serialization -> `dart run build_runner build --delete-conflicting-outputs`

Generated files: `*.freezed.dart`, `*.g.dart`

### Database

- 30+ Drift tables mirroring Supabase PostgreSQL schema
- Migration versioning at v10 (standardized sync metadata)
- All syncable tables have: `isPendingSync`, `lastSyncAt`, `updatedAt`
- Soft deletes via `deleted_at` timestamp (never hard delete business data)

---

## Requirements Status

### Validated (Shipped)

| Area | Features |
|------|----------|
| Auth | Supabase GoTrue login, session persistence, password recovery |
| RBAC | Superadmin/Admin/Manager/RM roles with route guards |
| Customer | CRUD, search, list with filtering, key person management |
| Pipeline | CRUD, stage tracking, referral tracking |
| Activity | Create, list, detail view with photos, GPS visit verification |
| HVC/Broker | CRUD for both entity types |
| 4DX | Measure definitions, user targets, user scores, scoreboard |
| Cadence | Meeting management (host/participant, pre-meeting forms, feedback) |
| Admin | User management (Edge Functions), period/measure management, team targets |
| Infrastructure | Drift 30+ tables, sync queue, initial sync, reactive UI (StreamProviders) |

### Active (In Progress)

- Reliable sync without data loss, duplicates, or silent failures
- Conflict resolution when local/remote diverge (LWW planned)
- All screens functional offline with cached data
- Typed error handling throughout (sealed Result<T> -- DONE for all repos)
- Sync queue pruning and lifecycle management
- Complete customer detail actions (share, delete, phone, email)
- Complete activity editing flow
- Phone/email launch from HVC and activity screens
- Notification settings screen, admin user deletion, reports/help, dashboard quick activity

### Out of Scope

- New features beyond completing stubs -- stability first
- CI/CD pipeline -- manual deployment acceptable
- Analytics integration -- defer until deployed
- OAuth/social login -- email/password sufficient for enterprise
- Real-time collaborative editing -- single-user-per-record model

---

## Completed Phases (v5 Iteration)

### Phase 01: Foundation & Observability

**Plans:** 3 | **Duration:** 41 min | **Completed:** 2026-02-13

**Deliverables:**
- Sealed `SyncError` hierarchy (6 subclasses: Network, Timeout, Server, Auth, Validation, Conflict) with `isRetryable` classification
- Drift schema migration v9->v10: standardized `isPendingSync` + `lastSyncAt` + `updatedAt` across all 11 syncable tables
- Sentry Flutter SDK with `appRunner` pattern, user context on login/logout, DSN from `.env`
- `AppLogger` singleton wrapping Talker with module-prefixed logging; replaced 266+ `debugPrint` calls across 26 files
- `SentryTalkerObserver` forwarding errors to Sentry; `TalkerRiverpodObserver` for provider lifecycle

**Key files:** `lib/core/errors/sync_errors.dart`, `lib/core/logging/app_logger.dart`, `lib/core/logging/sentry_observer.dart`

| Decision | Rationale |
|----------|-----------|
| Talker v4.x (not v5.x) | talker_riverpod_logger constrains to ^4.5.2 |
| SyncError implements Exception | Satisfies `only_throw_errors` lint while keeping sealed class |
| Module prefix convention `module.sub \| message` | Pipe separator for searchable production logs |
| SENTRY_DSN optional | Empty string silently disables Sentry |

### Phase 02: Sync Engine Core

**Plans:** 3 | **Duration:** 19 min | **Completed:** 2026-02-13

**Deliverables:**
- Queue coalescing with 4 rules: create+update -> create (payload replaced), create+delete -> remove, update+update -> update (payload replaced), update+delete -> delete
- 500ms debounced `triggerSync()` batching rapid writes; `processQueue()` direct path for manual sync
- Atomic Drift transactions wrapping all 42 write methods across 8 repositories (local write + sync queue insert)
- Constructor injection of `_database` field to Customer, HVC, Broker, Cadence repositories
- Incremental per-entity sync timestamps via `AppSettingsService` with 30-second safety margin

**Key files:** `lib/data/services/sync_service.dart`, `lib/presentation/providers/sync_providers.dart`, all 8 `*_repository_impl.dart`

| Decision | Rationale |
|----------|-----------|
| Full payload replacement on coalesce | Repos read full entity state before queueing |
| 500ms debounce window | Balances responsiveness with batching |
| 30s safety margin on since timestamps | Prevents missed records at cost of occasional duplicates |
| Dart 3 record pattern matching for coalescing | `switch ((existingOp, newOp))` for clean exhaustive handling |

### Phase 02.1: Pre-existing Bug Fixes (INSERTED)

**Plans:** 3 | **Duration:** 14 min | **Completed:** 2026-02-13

**Trigger:** Phase 02 UAT revealed two pre-existing bugs unrelated to Phase 02 changes.

**Deliverables:**
- `toUtcIso8601()` extension on `DateTime` and `DateTime?` -- centralized UTC serialization
- Fixed 88 bare `.toIso8601String()` calls in 10 repository files + 1 provider
- Fixed 61 bare `.toIso8601String()` calls in 14 remote data source + service files
- Date-only fields (expected_close_date, start_date, end_date) use `.toIso8601String().substring(0,10)` to prevent UTC date-shift
- Replaced all 11 `AutocompleteField` overlay dropdowns with `SearchableDropdown` modal bottom sheets (5 customer form + 6 pipeline form)
- Deleted `autocomplete_field.dart` (422 lines dead code)

**Key files:** `lib/core/utils/date_time_utils.dart`, `lib/presentation/widgets/common/searchable_dropdown.dart`

| Decision | Rationale |
|----------|-----------|
| Extension method (not standalone function) | Natural `.toUtcIso8601()` call syntax |
| substring(0,10) for DATE columns | Prevents UTC conversion shifting dates backward for UTC+ |
| Modal titles in Indonesian | Matches existing UI language conventions |

### Phase 03: Error Classification & Recovery

**Plans:** 3 | **Duration:** 37 min | **Completed:** 2026-02-14

**Deliverables:**
- Sealed `Result<T>` type with `Success`/`ResultFailure` variants for exhaustive pattern matching
- `mapException()` classifying SocketException, TimeoutException, PostgrestException, AuthException, FormatException to typed Failures
- `runCatching()` convenience wrapper for async Result operations
- Customer + Pipeline + Activity repositories (3 core repos, 21 methods) fully migrated from dartz `Either` to `Result`
- `OfflineBanner` widget watching connectivity; deployed on 6 core entity screens
- `AppErrorState` replacing raw `Text('Error')` patterns across all screens

**Key files:** `lib/core/errors/result.dart`, `lib/core/errors/exception_mapper.dart`, `lib/presentation/widgets/common/offline_banner.dart`

| Decision | Rationale |
|----------|-----------|
| ResultFailure (not Failure_) | Satisfies camel_case_types lint |
| runCatching for simple CRUD | Minimal boilerplate for straightforward methods |
| Explicit try/catch+mapException for complex methods | Needed for not-found logic, multi-step validation |
| OfflineBanner defaults to connected | Avoids false offline flash on startup |

### Phase 03.1: Remaining Repo Result Migration (INSERTED)

**Plans:** 5 | **Duration:** 64 min | **Completed:** 2026-02-14

**Trigger:** Phase 03 only migrated 3 core repos; 7 remaining repos + dartz dependency still present.

**Deliverables:**
- 7 remaining repositories migrated: Broker (4), AdminUser (6), HVC (7), AdminMasterData (~14), PipelineReferral (6), Auth (11), Cadence (18)
- All 66 methods across 7 repos returning `Result<T>` instead of `Either<Failure, T>`
- ~60 `.fold()` consumer call sites replaced with switch pattern matching
- Auth test suite completely rewritten from broken mockito to working mocktail with custom Fakes (`FakeSupabaseClient`, `FakeQueryChain`)
- `dartz` dependency removed from `pubspec.yaml` -- zero remaining imports
- `EitherToResult` bridge adapter removed from `result.dart`

**Key files:** All 10 `*_repository.dart` interfaces + impls, `test/data/repositories/auth_repository_impl_test.dart`

| Decision | Rationale |
|----------|-----------|
| Preserved _mapAuthError() with Indonesian messages | Auth errors need locale-specific UX |
| mocktail Fakes for Supabase types | PostgrestBuilder implements Future, breaking mockito/mocktail when/thenReturn |
| Vertical slice per plan (1 repo end-to-end) | Keeps each plan self-contained and testable |

---

## Remaining Phases (v6 Scope)

### Phase 4: Conflict Resolution

**Goal:** Detect local/remote divergence, apply Last-Write-Wins, log conflicts, ensure idempotent sync operations
**Depends on:** Phase 2 (delta sync timestamps), Phase 3 (typed errors)
**Plans:** 2 (04-01, 04-02 -- already planned)
**Success criteria:** LWW merge on updatedAt comparison, sync_conflicts audit table, upsert for idempotent creates, version guard on updates, conflict count in UI

### Phase 5: Background Sync & Dead Letter Queue

**Goal:** Sync across app restarts, prune completed queue items, surface failed items
**Depends on:** Phase 3 (error classification), Phase 4 (idempotent ops)
**Plans:** TBD (needs research: WorkManager + iOS BGTaskScheduler)
**Success criteria:** Background sync within 15 min, 7-day queue pruning, 5-retry dead letter, failed items UI

### Phase 6: Sync Coordination

**Goal:** Prevent race conditions between initial/regular sync, serialize push/pull, single sync execution
**Depends on:** Phase 2 (delta sync), Phase 5 (background sync)
**Plans:** TBD
**Success criteria:** Queue during initial sync, push-before-pull ordering, sync lock with logging

### Phase 7: Offline UX Polish

**Goal:** Transparent offline state and sync status via banners, badges, staleness indicators
**Depends on:** Phase 3 (offline error handling), Phase 5 (reliable sync for status accuracy)
**Plans:** TBD
**Success criteria:** Persistent connectivity banner, pending/synced badges on cards, "Last synced" timestamp, failed sync navigation

### Phase 8: Stubbed Feature Completion

**Goal:** Complete half-implemented features: customer actions, activity editing, communication launchers
**Depends on:** Phase 3 (typed errors)
**Plans:** TBD
**Success criteria:** Share button, soft delete, phone/email launch, activity edit mode, notification settings screen

### Phase 9: Admin & Dashboard Features

**Goal:** Admin user deletion, dashboard quick activity logging
**Depends on:** Phase 3 (typed errors)
**Plans:** TBD
**Success criteria:** Soft-delete user with cascade, quick activity FAB with validation

### Phase 10: Scoring Optimization

**Goal:** Multi-period score aggregation and team ranking
**Depends on:** Phase 2 (stable sync for score data integrity)
**Plans:** TBD
**Success criteria:** Composite LEAD+LAG scores, period boundary queries, team ranking with rank change indicators

---

## Established Patterns

These patterns MUST be followed in v6 for consistency.

| Pattern | Description | Established In |
|---------|-------------|----------------|
| Sealed error hierarchy | `SyncError` implements Exception; `isRetryable` for retry decisions | Phase 01-01 |
| Sealed Result<T> | `Success`/`ResultFailure` with exhaustive switch; replaces dartz Either | Phase 03-01 |
| runCatching vs try/catch | runCatching for simple CRUD; explicit try/catch+mapException for complex methods with not-found/validation | Phase 03-01 |
| Atomic Drift transactions | `_database.transaction(() async { localWrite + queueOperation })` then `triggerSync()` outside | Phase 02-02 |
| triggerSync() fire-and-forget | Always outside transactions; 500ms debounced; processQueue() for manual sync | Phase 02-01 |
| Per-entity incremental sync | `_getSafeSince(tableName)` -> pull -> `setTableLastSyncAt` on success; 30s safety margin | Phase 02-03 |
| toUtcIso8601() | All sync payload timestamps use `.toUtcIso8601()`; DATE-only use `.substring(0,10)` | Phase 02.1-01 |
| SearchableDropdown | Modal bottom sheet for all form dropdowns; not overlay-based | Phase 02.1-03 |
| OfflineBanner | `ConsumerWidget` watching `connectivityStreamProvider`; defaults connected; first child in Column | Phase 03-03 |
| AppErrorState | `.general()` in `AsyncValue.when()` error callbacks; replaces raw Text('Error') | Phase 03-03 |
| AppLogger module prefixes | `sync.queue`, `sync.push`, `sync.pull`, `auth`, `db`, `connectivity`, etc. with pipe separator | Phase 01-03 |
| Repository _database injection | Constructor injection of `AppDatabase` for transaction support | Phase 02-02 |
| StreamProvider + Drift .watch() | Reactive UI -- NO manual invalidation for Drift-backed data | Pre-existing |
| Lookup cache invalidation | `invalidateCaches()` after sync pull for in-memory name resolution caches | Pre-existing |
| DTO naming convention | `{Entity}CreateDto` (camelCase), `{Entity}SyncDto` (@JsonKey snake_case) | Pre-existing |
| Fake-based Supabase testing | `FakeSupabaseClient` + `FakeQueryChain` for types implementing Future | Phase 03.1-03 |

---

## Key Decisions Registry

### Architecture

| Decision | Rationale | Phase |
|----------|-----------|-------|
| Focus stability before new features | Unreliable sync/offline undermines all other value | Init |
| Complete stubs after stability | Half-done features create user confusion | Init |
| Maintain offline-first for all fixes | Every fix must preserve write-local-first-sync-later | Init |
| Clean Architecture layers | Presentation/domain/data separation maintained | Pre-existing |
| CustomerRepositoryImpl _database via constructor injection | Matches pipeline/activity pattern for transactions | 02-02 |

### Error Handling

| Decision | Rationale | Phase |
|----------|-----------|-------|
| SyncError implements Exception | Satisfies only_throw_errors lint while keeping sealed | 01-01 |
| ResultFailure variant name | camel_case_types lint compliance | 03-01 |
| Generic Exception -> UnexpectedFailure | More accurate than catch-all DatabaseFailure | 03-01 |
| Preserved _mapAuthError() | Indonesian-locale auth messages needed | 03.1-03 |
| NotFoundFailure for not-found cases | Typed failures enable better downstream handling | 03.1-04 |
| Exception thrown inside transactions | Only_throw_errors lint; outer catch wraps in Failure | 02-02 |

### Sync Engine

| Decision | Rationale | Phase |
|----------|-----------|-------|
| Last-write-wins conflict resolution | Full CRDT/merge too complex; single-user-per-record sufficient | Init |
| Full payload replacement on coalesce | Repos read full entity state before queueing | 02-01 |
| 500ms debounce window | Balances responsiveness with batching | 02-01 |
| Dart 3 record pattern matching for coalescing | Clean exhaustive handling of 4 rule combos | 02-01 |
| 30s safety margin on since timestamps | Prevents missed records; occasional duplicate cost acceptable | 02-03 |
| Per-entity timestamp keys = table names | `customers`, `key_persons`, `pipelines`, etc. | 02-03 |
| endMeeting single transaction | All participant scores + meeting end + all queue ops atomic | 02-03 |
| clearPrimaryForCustomer inside transaction | Full atomicity for key person primary flag changes | 02-02 |
| triggerSync() added to broker create/delete | Consistency with all other repositories | 02-03 |

### UI/UX

| Decision | Rationale | Phase |
|----------|-----------|-------|
| toUtcIso8601() as extension method | Natural .toUtcIso8601() call syntax | 02.1-01 |
| Date-only fields use substring(0,10) | Prevents UTC date-shift for UTC+ timezones | 02.1-01 |
| SearchableDropdown with modal bottom sheet | Eliminates overlay focus/tap race condition on mobile | 02.1-03 |
| Modal titles in Indonesian | Matches existing UI conventions (Pilih Provinsi, etc.) | 02.1-03 |
| OfflineBanner defaults to connected | Avoids false offline flash on startup | 03-03 |
| AppErrorState.general() for Drift errors | Network errors handled by OfflineBanner separately | 03-03 |

### Logging & Observability

| Decision | Rationale | Phase |
|----------|-----------|-------|
| Talker v4.x (not v5.x) | talker_riverpod_logger constrains to ^4.5.2 | 01-03 |
| Module prefix pipe separator | Searchable production logs | 01-03 |
| Log levels: debug/info/warning/error | Semantic: routine/state changes/non-critical/exceptions | 01-03 |
| appRunner pattern for Sentry | Captures widget tree construction errors | 01-02 |
| tracesSampleRate 0.2 | 20% balances observability with performance | 01-02 |
| SENTRY_DSN optional | Empty string silently disables | 01-02 |

### Testing

| Decision | Rationale | Phase |
|----------|-----------|-------|
| mocktail Fakes for Supabase types | PostgrestBuilder implements Future, breaking mockito | 03.1-03 |
| FakeSupabaseClient + FakeQueryChain + _FakeTransformBuilder | Delegates Future interface to proper Future instance | 03.1-03 |
| Mock transaction pattern | `when(mockDatabase.transaction(any)).thenAnswer((inv) => (inv.positionalArguments[0] as Future<dynamic> Function())())` | 02-02 |
| .isSuccess replacing .isRight() | Unmounted-notifier early-return pattern in StateNotifiers | 03.1-02 |

---

## Lessons Learned

### From UAT Failures

1. **UAT catches pre-existing bugs, not just new regressions.** Phase 02 UAT revealed 2 pre-existing bugs (timezone serialization, dropdown race condition) requiring Phase 02.1 insertion. Budget for inserted phases after UAT.

2. **Centralize serialization helpers EARLY.** 88+ bare `.toIso8601String()` calls across 9 repos -- a convention without enforcement (extension method) from day 1 would have prevented this. The `toUtcIso8601()` extension now prevents regression.

3. **Prefer modal patterns over overlay patterns on mobile.** `AutocompleteField` had a 200ms focus/tap race condition affecting all 11 form fields. `SearchableDropdown` with modal bottom sheet eliminated it entirely. Overlays and focus management are fragile on mobile.

### From Execution Deviations

4. **Plans that change interfaces ALWAYS have downstream consumer updates.** Constructor parameter changes (adding `_database`), return type changes (Either->Result) always ripple to providers, screens, and tests. Plans MUST include consumer updates explicitly -- they are not optional extras.

5. **Auto-fix rules (1-3) are essential.** ~20 deviations auto-fixed across 16 plans. Categories:
   - **Rule 3 (Blocking):** Constructor changes requiring provider/test updates not in plan scope (most common)
   - **Rule 2 (Missing Critical):** Methods/files not identified in plan but required for completeness
   - **Rule 1 (Bug):** Pre-existing bugs discovered during related work

   Strict plan adherence would have left broken code.

6. **Screen-level consumers that call repository methods directly must be updated too.** Plan 03-02 discovered `pipeline_stage_update_sheet` and `pipeline_status_update_sheet` calling `.fold()` directly on repository results (not through providers). Always grep for all callers.

### From Performance Data

7. **Pre-existing test debt multiplies migration effort.** Auth repository migration (03.1-03) was 35 min vs 5-8 min average because the test suite was already broken (stale mockito mocks, wrong constructor args, obsolete Supabase API). Pre-audit test health before planning migration scope.

8. **Supabase types implementing Future break mock libraries.** Both mockito and mocktail fail on `PostgrestBuilder implements Future<T>`. Solution: custom Fake classes with Future delegation. This pattern (`FakeSupabaseClient`, `FakeQueryChain`, `_FakeTransformBuilder`) is reusable.

### From Phase Insertions

9. **Plan for "completion phases" after partial migrations.** Both Phase 02.1 and Phase 03.1 were INSERTED:
   - 02.1: Pre-existing bugs surfaced during UAT
   - 03.1: Original Phase 3 only migrated 3 repos, leaving 7 + dartz dependency

   If migrating a pattern, budget for ALL instances, not just the core ones.

### From GSD Framework Usage

10. **2-3 tasks per plan works well.** Never exceeded context budget across 16 plans.

11. **Vertical slice approach works for repo migrations.** Each plan = one repo end-to-end (interface, impl, providers, tests) keeps plans self-contained and verifiable.

12. **SUMMARY frontmatter (dependency graph, tech tracking) is valuable.** Cross-phase context comes from structured metadata, not prose.

13. **Research phase before planning prevents wrong choices.** Example: Talker v4 vs v5 constraint discovered during research, not during execution. Without research, plan would have specified v5 and hit a blocking deviation.

---

## Metrics Summary

| Metric | Value |
|--------|-------|
| Total phases completed | 5 (including 2 inserted) |
| Total plans completed | 17 (3+3+3+3+5) |
| Total execution time | ~2.9 hours |
| Average plan duration | 10.6 min |
| Fastest plan | 3 min (01-02 Sentry, 02-01 Coalescing) |
| Slowest plan | 35 min (03.1-03 Auth test rewrite) |
| Total files modified | ~120+ |
| Total deviations auto-fixed | ~20 |
| Test suites passing | 55+ repo tests |
| dartz dependency | REMOVED |
| debugPrint calls remaining | 0 |
| Bare .toIso8601String() in sync | 0 |
| Repositories on Result<T> | 10/10 (100%) |

**By Phase:**

| Phase | Plans | Duration | Avg/Plan |
|-------|-------|----------|----------|
| 01 Foundation & Observability | 3 | 41 min | 14 min |
| 02 Sync Engine Core | 3 | 19 min | 6 min |
| 02.1 Pre-existing Bug Fixes | 3 | 14 min | 5 min |
| 03 Error Classification | 3 | 37 min | 12 min |
| 03.1 Remaining Repo Migration | 5 | 64 min | 13 min |

---

## Recommendations for v6

1. **Start Phase 4 (Conflict Resolution)** -- already planned with 2 plans. Highest priority: LWW detection + sync_conflicts audit table.

2. **Phase 5 (Background Sync) needs research.** WorkManager (Android) + iOS BGTaskScheduler have platform-specific constraints. Research before planning.

3. **Phase 6 (Sync Coordination) may merge with Phase 5.** Evaluate during discuss-phase -- sync locks and push/pull serialization are tightly coupled with background sync.

4. **Phase 7 (Offline UX) is mostly UI polish.** Good candidate for parallel execution with sync-related phases since it's presentation-layer only.

5. **Phases 8-9 (stubbed features) are independent of sync work.** Could run in parallel after Phase 3 (typed errors already done). Low-risk, user-visible value.

6. **Phase 10 (scoring) has lowest priority and fewest dependencies.**

7. **Consider UAT checkpoints after Phase 4 and Phase 5.** Sync changes are highest risk for data integrity issues.

8. **Pre-audit test health before Phase 5-6.** The 03.1-03 auth migration was 4x slower due to broken tests. Identify and fix broken test suites BEFORE planning migration scope.

9. **Grep for ALL callers when changing interfaces.** Not just providers -- screens, sheets, test helpers, and other repos may call methods directly.

---

*Generated: 2026-02-16 | Covers: v5 iteration (Phases 01 through 03.1, 17 plans, ~2.9 hours)*
