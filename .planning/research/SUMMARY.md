# Project Research Summary

**Project:** LeadX CRM Stability Improvements
**Domain:** Offline-first mobile CRM (Flutter/Drift/Supabase)
**Researched:** 2026-02-13
**Confidence:** HIGH

## Executive Summary

LeadX CRM is an existing Flutter/Supabase application implementing an offline-first architecture for PT Askrindo's sales team. The codebase has a sound Clean Architecture foundation with Drift for local storage, Riverpod for state management, and a FIFO sync queue. However, analysis reveals five critical reliability problems that cause data loss, silent failures, and sync inconsistencies. These are not architectural flaws requiring rewrites — they are targeted issues with specific, well-documented solutions.

The recommended approach focuses on stabilizing the existing sync engine rather than replacing infrastructure. Research confirms the current stack (Flutter, Drift, Supabase, Riverpod) is industry-standard for offline-first CRM. The priority additions are: Dart-native sealed Result types replacing dartz, Sentry for crash reporting, Talker for structured logging, internet_connection_checker_plus for reliable connectivity, and the retry package for network resilience. Package upgrades (Drift 2.31.0, Supabase 2.12.0) address known stability issues. Defer major version bumps (Riverpod 3, Freezed 3) until after stability work.

Key risks center on sync reliability: full-table pulls on every sync waste bandwidth and increase failure windows; queue coalescing destroys create-then-update sequences causing silent data loss; no conflict resolution means last-write silently overwrites changes; inconsistent sync metadata columns create maintenance traps. The mitigation strategy is incremental: standardize sync metadata first (schema migration), add typed error classification, implement delta sync with proper timestamps, introduce conflict detection, then layer on background sync. Each phase builds on a stable foundation from the previous.

## Key Findings

### Recommended Stack

The core stack (Flutter, Supabase, Drift, Riverpod, Freezed) is established and appropriate. Research focused on what to add or upgrade for reliability. Current packages are multiple major versions behind (Riverpod 2.6.1 vs 3.2.1, Freezed 2.5.7 vs 3.2.5, connectivity_plus 6.1.1 vs 7.0.0), creating a stability debt.

**Critical additions for stability:**
- **Dart-native sealed Result<T>**: Replaces dartz Either<Failure, T> — Flutter official docs recommend sealed classes for exhaustive error handling. dartz is unmaintained since 2022. Migration is incremental (keep dartz during transition).
- **sentry_flutter ^9.13.0**: Industry-standard crash reporting with native crash support. Supabase-compatible (no Firebase dependency). Free tier sufficient for current scale.
- **talker_flutter ^5.1.13**: Structured logging with in-app viewer, Riverpod integration, Sentry forwarding. Replaces scattered debugPrint calls. Critical for debugging provider chains.
- **internet_connection_checker_plus ^2.9.1**: Actual internet reachability verification (connectivity_plus only checks WiFi/mobile is connected, not internet access). Replaces custom checkServerReachability.
- **retry ^3.1.2**: Exponential backoff with jitter for network operations. SyncService has retry counting but no backoff delays. Simple API wraps Supabase calls.

**Required package upgrades (priority order):**
1. **drift ^2.31.0** (from 2.22.1): 9 minor versions of bug fixes, no breaking changes. Must export schema baseline first.
2. **supabase_flutter ^2.12.0** (from 2.8.3): Auth token refresh reliability, realtime reconnection fixes, connection pooling. Directly addresses sync reliability.
3. **connectivity_plus ^7.0.0** (from 6.1.1): Major version, required by internet_connection_checker_plus. Review changelog for breaking changes.

**Defer to separate milestone:**
- Riverpod 3 + Freezed 3: Major version bumps change code generation patterns. Large migration surface. Do AFTER stability work, not during.

**What NOT to use:**
- PowerSync (vendor dependency, cost, replaces working sync engine)
- Firebase Crashlytics (adds Firebase to Supabase project, SDK bloat)
- fpdart (lateral move from dartz, not forward to Dart-native)
- Hive/ObjectBox/isar (second database creates fragmentation)
- Dio (Supabase has HTTP client, two layers create complexity)

### Expected Features

Research identified 9 table-stakes features for offline-first CRM reliability (users expect these and missing them erodes trust) and 6 differentiators (competitive advantage for field sales in poor connectivity areas).

**Must have (table stakes):**
- **Atomic write+queue operations**: Wrap local DB write and sync queue insertion in single Drift transaction. Current implementation has crash window between operations causing silent data loss. Most critical fix.
- **Offline connectivity banner**: Persistent banner showing offline state. Google's Open Health Stack design guidelines mandate this. Users who don't know they're offline blame the app for "losing data."
- **Sync status per record**: Show pending/synced badges on every entity card. isPendingSync flag exists but not consistently displayed.
- **Last synced timestamp**: Display "Last synced: X minutes ago" on dashboard. Android official docs recommend this for data freshness awareness.
- **Graceful error states with offline fallback**: Screens should show cached data with staleness warning when offline, not crash or show raw error text. Current pattern error: (error, _) => Text('Error: $error') is unacceptable.
- **Retry mechanism with user feedback**: Surface failed sync items to users with retry/discard options. Current sync queue debug screen is dev-only.
- **Dead letter queue handling**: Items exceeding maxRetries (5) need user notification and resolution path. Currently they sit in queue forever.
- **Conflict resolution policy (Last-Write-Wins)**: When same record edited offline on multiple devices, need deterministic merge. SyncConflictException exists but is never thrown. Implement LWW using updated_at timestamps.
- **Typed error handling throughout**: Failure class hierarchy is well-designed but underused. Repositories catch generic Exception, screens receive raw errors. Map all Supabase/network exceptions to typed Failure subclasses.

**Should have (competitive differentiators):**
- **Optimistic UI with undo**: Show transient "Undo" SnackBar for 5 seconds after offline create/edit. Rare in CRM apps, builds user confidence.
- **Smart sync prioritization**: Prioritize by business value (activities with photos > customer profile updates). Add priority column to sync_queue, process by priority then FIFO.
- **Offline data integrity validation**: Pre-sync validation that payload references still valid (e.g., pipeline referencing deleted stage). Prevents sending data that fails server constraints.
- **Selective sync (Wi-Fi only for large payloads)**: Photos sync only on Wi-Fi to prevent data charges. Text data syncs on any connection. Sales reps in Indonesia use metered mobile data.
- **Sync progress with per-entity detail**: Show "Syncing 3/12 items... (Customer: PT Askrindo)" during sync, not just initial sync sheet.
- **Offline search with FTS5**: Drift supports FTS5 virtual tables for faster partial/fuzzy search. Matters when sales reps misspell names.

**Defer (v2+):**
- Offline FTS5 search (defer until search performance is reported issue)
- Automatic conflict notification with diff UI (defer until LWW proves insufficient)
- Selective Wi-Fi sync for photos (defer until data usage is concern)

**Anti-features (commonly requested, problematic):**
- Real-time sync via WebSocket/Supabase Realtime: Adds complexity, assumes connectivity, conflicts with offline-first model, battery drain. Use pull-based delta sync on 5-minute timer instead.
- Automatic merge for all conflicts: Silent data loss worse than conflict dialog for CRM. Use LWW with user notification.
- Full offline CRUD for admin operations: Admin ops (user creation, password reset) use Edge Functions with service_role key. Inherently online-only. Keep admin buttons disabled when offline.
- Per-field sync tracking: Exponential payload size increase for 12 entity types × 20 fields. Full-payload sync with LWW is Flutter official recommendation.
- Infinite retry for all failures: Wastes battery/data. Some errors are permanent (403, 404, validation). Max 5 retries then dead letter queue.

### Architecture Approach

LeadX has a Clean Architecture foundation (presentation/domain/data layers) with sound structure. Five specific reliability problems need targeted fixes, not rewrites. Current architecture already implements offline-first patterns: writes go to local Drift DB first with immediate UI feedback, operations queue in sync_queue table, background sync processes FIFO, UI reads from Drift via reactive streams.

**Diagnosed problems (HIGH severity):**
1. **Inconsistent sync timestamp fields**: lastSyncAt (Customers, Pipelines), syncedAt (Activities), absent (KeyPersons, Hvcs, CustomerHvcLinks, Brokers). Requires growing switch statement in _markEntityAsSynced with no compile-time safety.
2. **No conflict detection**: _processItem does blind insert/update with no timestamp comparison. Pull sync overwrites local unconditionally.
3. **Race condition in initial sync**: performInitialSync and processQueue share no coordination. User creating data during initial sync may push before reference data is pulled.
4. **Sync queue never pruned**: Failed items (retryCount >= maxRetries) stay forever. clearCompletedItems exists but never called.
5. **Generic exceptions lose type info**: _processItem catches SocketException/TimeoutException then wraps in generic Exception(), discarding typed hierarchy.

**Major components to add/enhance:**
1. **SyncCoordinator (NEW)** — Prevents race conditions by gating queue processing on initial sync completion. Serializes sync phases (push -> photos -> audit -> pull). Manages sync locks to prevent concurrent execution.
2. **SyncErrorMapper (NEW)** — Maps raw exceptions (SocketException, PostgrestException, TimeoutException) to sealed SyncError hierarchy. Enables exhaustive pattern matching without string parsing.
3. **RetryPolicy (NEW)** — Determines whether SyncError is retryable (network, timeout, 5xx) vs permanent (auth 401, validation 400, constraint 409). Classifies errors with appropriate backoff.
4. **SyncService (ENHANCED)** — Process sync queue FIFO with typed error handling. Classify errors as retryable vs permanent. Prune dead items. Apply exponential backoff.
5. **Standardized sync metadata** — Every syncable table uses isPendingSync (bool), lastSyncAt (DateTime nullable), updatedAt (DateTime). Requires migration to rename Activities.syncedAt and add lastSyncAt to 6 tables lacking it.

**Key architectural patterns:**
- **Pattern 1: Consistent sync metadata columns** — All syncable tables use same 3 columns (isPendingSync, lastSyncAt, updatedAt). Eliminates entity-specific switch statements.
- **Pattern 2: Typed error classification** — Sealed SyncError class hierarchy (NetworkSyncError, TimeoutSyncError, AuthSyncError, ValidationSyncError, ConflictSyncError). SyncErrorMapper.classify converts raw exceptions.
- **Pattern 3: Sync coordination gate** — Coordinator prevents queue push before initial sync completes. canPushSync checks initial sync status, acquireLock/releaseLock serializes phases.
- **Pattern 4: Last-Writer-Wins conflict detection** — Before upserting remote data over local, check if local has isPendingSync=true. Compare updatedAt timestamps, higher wins. Log conflicts.
- **Pattern 5: Queue pruning** — After each sync cycle, remove items exceeding maxRetries and older than 7 days. Optionally mark entities with sync error for UI display.

**Anti-patterns to avoid:**
- Generic exception wrapping (loses type info for retry decisions)
- Fire-and-forget sync without coordination (race conditions with initial sync)
- Inconsistent sync metadata (growing switch statements, missing cases cause silent failures)
- Unbounded queue growth (degrades performance, leaks unfulfillable intent)

### Critical Pitfalls

**Pitfall 1: Full-table pull sync on every bidirectional sync**
Every _pullFromRemote call fetches entire dataset — syncFromRemote accepts since parameter but it's never passed. As dataset grows, sync takes progressively longer and increases failure windows. Remote data sources support .gte('updated_at', since.toIso8601String()) but it's unused. FIX: Store last_pull_sync_at per entity type in AppSettings, pass since to all syncFromRemote calls, use server timestamps to avoid clock skew. Phase 1 (foundation).

**Pitfall 2: Queue coalescing destroys create-then-update sequences**
queueOperation coalesces by removing old operation when hasPending is true, but doesn't check operation type. Create followed by update removes the create and replaces with update. When sync runs, it tries to update non-existent server record (Supabase update().eq() on missing row silently succeeds with 0 rows affected). FIX: Coalesce intelligently — create+update merges to create with updated payload, create+delete removes both, update+update replaces payload, update+delete becomes delete. Phase 1 (data integrity).

**Pitfall 3: No conflict resolution — silent last-write-wins**
No conflict detection during push or pull. _processItem does raw insert/update without checking if server version changed. syncFromRemote does unconditional upsert. SyncConflictException exists but is never thrown. Two users editing same record offline = whichever syncs last wins silently. FIX: Implement explicit LWW using updated_at comparison, log conflicts to audit table, flag conflicts for manual resolution on high-value entities (pipelines). Phase 2 (after sync engine stable).

**Pitfall 4: Inconsistent sync timestamp columns cause silent failures**
Three naming conventions (lastSyncAt, syncedAt, absent). _markEntityAsSynced has entity-specific switch cases. New entity types fall through to default case with only debugPrint — no error, data stuck pending forever. FIX: Standardize to last_sync_at via migration, replace switch with generic table reference mapping, add compile-time check for SyncEntityType coverage. Phase 1 (prerequisite for delta sync).

**Pitfall 5: Refactoring sync while users have pending queue items**
Changing payload format, queue processing logic, or entityType strings breaks existing queue items in production. Developers test with empty queues. Users may have days of unsynced operations. FIX: Before deploying sync refactors, drain queue with OLD code or transform payloads to new format. Add queue format version field. Keep backward compatibility for one version cycle. Phase 1 (must address BEFORE payload changes).

**Pitfall 6: Race condition between push and pull**
triggerSync runs push then pull sequentially, but user may queue new operations during pull phase. Pull overwrites local data, but queue still has operations referencing pre-pull state. Additionally, unawaited(_syncService.triggerSync()) from every repository write triggers thundering herd. _isSyncing guard prevents parallel execution but second trigger silently returns without processing newly queued item. FIX: Debounce sync triggers (500ms batch window), lock entity rows during push so pull doesn't overwrite until push completes, re-check for new queue items after pull. Phase 1 (debouncing eliminates most symptoms).

## Implications for Roadmap

Based on research, recommend 3-phase structure focusing on incremental stability improvements. Avoid the temptation to rewrite the sync engine — the architecture is sound, the issues are specific and addressable.

### Phase 1: Sync Engine Stabilization

**Rationale:** All other improvements depend on a correct sync foundation. Atomic operations prevent data loss (the root cause users report). Delta sync reduces bandwidth and failure windows. Typed error handling enables intelligent retry and user feedback. Standardized metadata eliminates maintenance traps.

**Delivers:**
- Zero data loss during sync (atomic write+queue transactions)
- 10x faster incremental sync (delta sync with timestamps)
- Structured error handling (Result<T> replaces dartz, SyncErrorMapper)
- Reliable connectivity detection (internet_connection_checker_plus)
- Observability (Sentry crash reporting, Talker structured logging)
- Clean sync metadata schema (standardized columns across all tables)

**Addresses features:**
- Atomic write+queue operations (TABLE STAKES — highest priority)
- Typed error handling throughout (TABLE STAKES)
- Last synced timestamp on dashboard (TABLE STAKES)
- Graceful error states with offline fallback (TABLE STAKES)

**Avoids pitfalls:**
- Pitfall 1: Full-table pull sync (implement delta sync)
- Pitfall 2: Queue coalescing errors (intelligent operation merging)
- Pitfall 4: Inconsistent sync metadata (schema standardization)
- Pitfall 5: Queue format migration risks (establish baseline before refactors)
- Pitfall 6: Push-pull race conditions (debounced triggers)

**Stack usage:**
- Add: sentry_flutter, talker_flutter, internet_connection_checker_plus, retry
- Upgrade: drift 2.31.0, supabase_flutter 2.12.0, connectivity_plus 7.0.0
- Migrate: Begin dartz -> Result<T> transition (incremental, repository-by-repository)

**Research needs:** SKIP — patterns well-documented in Flutter official docs, Drift docs, and multiple verified sources. Straightforward implementation.

### Phase 2: Conflict Handling & Error Recovery

**Rationale:** With a stable sync engine from Phase 1, layer on conflict detection and user-facing error recovery. Last-Write-Wins is sufficient for CRM domain with single-user record ownership. Dead letter queue handling surfaces permanently failed items instead of hiding them. Background sync ensures data reaches server even when app is backgrounded.

**Delivers:**
- Last-Write-Wins conflict resolution with user notification
- Dead letter queue UI (retry/discard permanently failed items)
- Idempotent sync operations (upsert for creates, version guards for updates)
- Background sync via workmanager (Android WorkManager, iOS BGTaskScheduler)
- Retry mechanism with error classification (retryable vs permanent)

**Addresses features:**
- Conflict resolution policy (LWW) (TABLE STAKES)
- Dead letter queue handling (TABLE STAKES)
- Retry mechanism with user feedback (TABLE STAKES)
- Background sync across app restarts (TABLE STAKES)
- Idempotent sync operations (TABLE STAKES)

**Avoids pitfalls:**
- Pitfall 3: No conflict resolution (explicit LWW with logging)
- JWT expiry during offline (handle auth errors specifically in sync)

**Builds on:**
- Phase 1's atomic operations (background sync requires transaction safety)
- Phase 1's typed errors (classify retryable vs permanent)
- Phase 1's delta sync (conflict detection compares timestamps)

**Research needs:** MEDIUM — Workmanager iOS limitations need platform-specific research. LWW patterns are standard, but field-level merge vs record-level trade-offs may need domain validation with stakeholders.

### Phase 3: UX Polish & Performance

**Rationale:** With stable sync and conflict handling in place, optimize UX and address performance at scale. Smart prioritization ensures important data syncs first. Optimistic UI with undo builds user trust. FTS5 improves offline search for large datasets.

**Delivers:**
- Offline connectivity banner (persistent, not dismissible SnackBar)
- Sync status badges on all entity cards (pending/synced indicators)
- Smart sync prioritization (business-value-based queue ordering)
- Optimistic UI with undo (5-second undo window for offline writes)
- Offline search with FTS5 (full-text indexes on customer/pipeline names)
- Selective Wi-Fi sync for photos (prevent mobile data charges)

**Addresses features:**
- Offline connectivity banner (TABLE STAKES)
- Sync status per record (TABLE STAKES)
- Smart sync prioritization (DIFFERENTIATOR)
- Optimistic UI with undo (DIFFERENTIATOR)
- Offline FTS5 search (DIFFERENTIATOR)
- Selective sync Wi-Fi-only (DIFFERENTIATOR)

**Avoids pitfalls:**
- N+1 cache queries (profile and optimize lookup patterns)
- Unbounded sync queue growth (size limits, TTL-based pruning)
- Silent partial failures (UI shows sync errors persistently)

**Builds on:**
- Phase 1's stable sync (can now add UX without fighting data loss)
- Phase 2's error recovery (can surface sync status confidently)

**Research needs:** LOW for UX features (standard patterns). MEDIUM for FTS5 (Drift supports it but indexing strategy for CRM search needs design).

### Phase Ordering Rationale

**Why Phase 1 first:**
- Atomic operations are prerequisite for everything else (prevent data loss during refactors)
- Delta sync reduces sync duration, shrinking window for failures during Phase 2/3 work
- Typed errors enable Phase 2's retry classification and Phase 3's UX error states
- Schema standardization must happen before conflict detection (Phase 2) which compares timestamps
- Observability (Sentry/Talker) needed before rolling out user-facing features in Phase 2/3

**Why Phase 2 second:**
- Conflict resolution requires Phase 1's delta sync (compares server/local updated_at)
- Background sync requires Phase 1's atomic operations (safe unattended execution)
- Idempotency requires Phase 1's coalescing fixes (can't make operations idempotent if coalescing is broken)
- Dead letter queue depends on Phase 1's typed errors (classify permanent vs transient)

**Why Phase 3 last:**
- UX polish should wait until underlying reliability is proven
- Users trust sync status badges only if sync actually works (Phase 1+2)
- Optimistic undo creates expectations of reliability (must deliver first)
- Performance optimization is premature before stability (optimize a working system, not a broken one)

**Dependencies across phases:**
```
Phase 1: Sync Engine Stabilization
    |
    +---> Atomic operations (foundation for Phase 2 background sync)
    +---> Typed errors (foundation for Phase 2 retry + Phase 3 UX)
    +---> Delta sync (foundation for Phase 2 conflict detection)
    +---> Schema standardization (foundation for Phase 2 LWW comparison)
    |
Phase 2: Conflict Handling & Error Recovery
    |
    +---> Working sync (foundation for Phase 3 UX trust)
    +---> Error classification (foundation for Phase 3 UI error states)
    |
Phase 3: UX Polish & Performance
    |
    +---> Stable sync (can confidently show sync status)
    +---> Conflict resolution (optimistic UI assumes conflicts handled)
```

### Research Flags

**Phases needing deeper research during planning:**
- **Phase 2 (Background Sync):** Workmanager iOS limitations need investigation. iOS restricts background execution to ~30 seconds and schedules at OS discretion. Background Dart isolate cannot access Flutter plugins without careful initialization. May need platform-specific implementation research.
- **Phase 3 (FTS5 Search):** Drift FTS5 integration is documented, but indexing strategy for CRM search (customer names, company names, pipeline descriptions) needs design. Rebuild indexes after each sync pull — performance implications for 1000+ records.

**Phases with standard patterns (skip research-phase):**
- **Phase 1 (Sync Engine):** All patterns documented in Flutter official offline-first docs, Drift migration docs, pub.dev verified packages. Straightforward implementation.
- **Phase 2 (LWW Conflict Resolution):** Standard pattern, well-documented in Android offline-first guide and Hasura offline design guide.
- **Phase 3 (UX Patterns):** Google Open Health Stack design guidelines, Android official docs. Standard UI patterns.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All recommended packages verified on pub.dev with recent publication dates. Flutter official docs explicitly recommend sealed Result types. Supabase compatibility confirmed. Version compatibility matrix validated. |
| Features | HIGH | Table stakes identified from Flutter official docs, Android official docs, Google design guidelines. Differentiators validated against competitor analysis (Salesforce Mobile, Resco, HubSpot). Anti-features confirmed problematic via multiple sources. |
| Architecture | HIGH | Patterns sourced from Flutter official offline-first docs, verified against LeadX codebase analysis (direct code inspection). Component responsibilities and data flows match industry consensus. Build order dependencies validated. |
| Pitfalls | HIGH | All 6 critical pitfalls verified via direct codebase inspection with code evidence. Cross-referenced against offline-first ecosystem common mistakes. Prevention strategies sourced from Drift docs, Flutter docs, multiple community sources. |

**Overall confidence:** HIGH

Research is grounded in official documentation (Flutter, Android, Drift, Supabase), verified package versions on pub.dev, and direct codebase analysis. Recommended approach aligns with Flutter team's guidance and ecosystem consensus. Risk areas (background sync iOS limitations, package upgrade breaking changes) are explicitly flagged.

### Gaps to Address

**Gap: Supabase rate limiting and API quotas**
Research focused on client-side sync patterns. Supabase free tier rate limits and API quotas not explicitly researched. With 50+ users syncing every 5 minutes, may approach limits. **How to handle:** During Phase 1 planning, review Supabase project settings for current usage baseline. Add server-side rate limit monitoring. Consider upgrading Supabase tier or adjusting sync intervals if approaching limits.

**Gap: Drift schema migration testing strategy**
Phase 1 requires renaming Activities.syncedAt to lastSyncAt and adding lastSyncAt to 6 tables. Research identified the need but not specific migration testing approach for production data. **How to handle:** Before Phase 1 execution, export production schema snapshot (dart run drift_dev schema dump), write migration in Drift step-by-step migrations format, test migration on copy of production database. Document rollback procedure.

**Gap: Workmanager reliability on budget Android devices**
Phase 2 recommends workmanager for background sync. Research noted iOS limitations but didn't deeply investigate Android OEM battery optimization behaviors (Xiaomi, Oppo, Samsung kill background tasks aggressively). **How to handle:** During Phase 2 planning, research Android OEM-specific battery optimization workarounds. May need user-facing instructions to whitelist app from battery optimization. Consider fallback to foreground service for critical sync.

**Gap: Conflict resolution for specific high-value fields**
Research recommends Last-Write-Wins for general use but flags pipelines with monetary values as needing field-level consideration. Didn't research which specific fields need special handling. **How to handle:** During Phase 2 planning, validate with stakeholders which pipeline fields are high-value (estimated_value, stage, close_date). Determine if LWW with audit logging is sufficient or if manual conflict resolution UI is needed for those fields.

## Sources

### Primary (HIGH confidence)
- [Flutter Official: Offline-first support design pattern](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) — architecture patterns, sync strategies, Result type recommendation
- [Flutter Official: Result type pattern](https://docs.flutter.dev/app-architecture/design-patterns/result) — sealed Result class, exhaustive error handling
- [Android Official: Build an offline-first app](https://developer.android.com/topic/architecture/data-layer/offline-first) — platform architecture principles, data layer patterns
- [Google Open Health Stack: Design Guidelines for Offline & Sync](https://developers.google.com/open-health-stack/design/offline-sync-guideline) — UX patterns, connectivity banner, last synced timestamp
- [pub.dev: sentry_flutter 9.13.0](https://pub.dev/packages/sentry_flutter) — version, features, publication date verified 2026-02-12
- [pub.dev: drift 2.31.0](https://pub.dev/packages/drift) — version, changelog, migration docs verified
- [pub.dev: supabase_flutter 2.12.0](https://pub.dev/packages/supabase_flutter) — version, auth session reliability improvements verified
- [pub.dev: talker_flutter 5.1.13](https://pub.dev/packages/talker_flutter) — version verified 2026-01-26
- [pub.dev: retry 3.1.2](https://pub.dev/packages/retry) — version, google.dev publisher verified
- [Drift migration docs](https://drift.simonbinder.eu/migrations/) — schema export, step-by-step migrations
- LeadX codebase analysis: sync_service.dart, initial_sync_service.dart, sync_providers.dart, connectivity_service.dart, all repository implementations, all Drift table definitions — HIGH confidence (direct code inspection)

### Secondary (MEDIUM confidence)
- [pub.dev: internet_connection_checker_plus 2.9.1](https://pub.dev/packages/internet_connection_checker_plus) — verified, community-maintained
- [pub.dev: workmanager 0.9.0+3](https://pub.dev/packages/workmanager) — verified, federated plugin, iOS limitations noted
- [Supabase auth sessions docs](https://supabase.com/docs/guides/auth/sessions) — token refresh behavior
- [Hasura: Design Guide for Building Offline First Apps](https://hasura.io/blog/design-guide-to-offline-first-apps) — conflict resolution patterns, sync architecture
- [GeekyAnts: Offline-First Flutter Implementation Blueprint](https://geekyants.com/blog/offline-first-flutter-implementation-blueprint-for-real-world-apps) — sync patterns, queue processing
- [droidcon: Complete Guide to Offline-First Architecture](https://www.droidcon.com/2025/12/16/the-complete-guide-to-offline-first-architecture-in-android/) — transactional outbox pattern verified
- [DevelopersVoice: Offline-First Sync Patterns for Real-World Mobile Networks](https://developersvoice.com/blog/mobile/offline-first-sync-patterns/) — multiple patterns verified against Flutter docs
- [Medium: Building a Flutter Offline-First Sync Engine with Conflict Resolution](https://medium.com/@pravinkunnure9/building-a-flutter-offline-first-sync-engine-flutter-sync-engine-with-conflict-resolution-5a087f695104) — LWW implementation examples
- [Medium: Building Offline-First Flutter Apps with Drift](https://777genius.medium.com/building-offline-first-flutter-apps-a-complete-sync-solution-with-drift-d287da021ab0) — Drift patterns
- [Beefed AI: Offline-First Mobile Apps: Queueing & Sync](https://beefed.ai/en/offline-first-queueing-sync) — queue patterns
- [Resco: How Offline is Offline?](https://www.resco.net/blog/how-offline-is-offline/) — competitor analysis
- [DashDevs: Offline Applications Challenges and Solutions](https://dashdevs.com/blog/offline-applications-and-offline-first-design-challenges-and-solutions/) — common challenges

### Tertiary (LOW confidence)
- [PowerSync pricing](https://www.powersync.com/pricing) — evaluated and rejected, vendor dependency concern
- [fpdart vs dartz comparison](https://medium.com/@yazanabedo112/functional-programming-experience-in-dart-a-journey-between-dartz-and-fpdart-afef3f97c45d) — informed decision to go Dart-native
- [Offline-first architecture: designing for reality](https://medium.com/@jusuftopic/offline-first-architecture-designing-for-reality-not-just-the-cloud-e5fd18e50a79) — single source
- [Common SQLite mistakes Flutter developers make](https://medium.com/@sparkleo/common-sqlite-mistakes-flutter-devs-make-and-how-to-avoid-them-1102ab0117d5) — single source

---
*Research completed: 2026-02-13*
*Ready for roadmap: yes*
