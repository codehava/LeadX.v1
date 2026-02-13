# Feature Research: Offline-First CRM Stability

**Domain:** Offline-first mobile CRM reliability (sync, errors, offline UX)
**Researched:** 2026-02-13
**Confidence:** HIGH (multiple authoritative sources agree: Flutter official docs, Android official docs, Google design guidelines, ecosystem consensus)

## Current State Analysis

LeadX already has the skeleton of an offline-first architecture: a FIFO sync queue in Drift, connectivity detection via `connectivity_plus` with server reachability checks, exponential backoff (max 5 retries), background sync on a 5-minute timer, and reactive UI via Drift streams. However, the current implementation has known gaps that manifest as data loss, crashes on generic exceptions, and screens failing when offline.

Key gaps identified in the codebase:
- **Queue coalescing deletes the old operation before inserting the new one** -- if the app crashes between the delete and the insert, the operation is lost
- **No transactional write+queue** -- the local DB write and queue insertion are separate operations, not wrapped in a single DB transaction
- **Error handling in screens is raw** -- `error: (error, _) => Text('Error: $error')` with no differentiation between offline errors, auth errors, and data errors
- **No offline banner/indicator on main screens** -- users do not see they are offline until an action fails
- **Sync queue has no "dead letter" handling** -- items that exceed max retries stay in the queue with no user notification or resolution path
- **Pull sync errors are silently caught** -- `_pullFromRemote()` catches all errors per entity type with only `debugPrint`, so partial pull failures are invisible to users
- **No "last synced" timestamp visible to users** -- there is no UI showing when data was last refreshed from the server

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these means users lose trust in the app and data integrity.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Atomic write+queue operations** | Without wrapping local DB write and sync queue insertion in a single Drift transaction, a crash between the two operations loses data silently. Users create a record, see it locally, but it never syncs. | MEDIUM | Use `database.transaction()` to wrap both the entity insert/update and the `syncQueueItems` insert. This is the single most critical reliability fix. |
| **Offline connectivity banner** | Users must know they are offline BEFORE they attempt actions that might behave differently. Every major offline-first app (Salesforce, Google Docs, Slack) shows a persistent banner. Google's Open Health Stack design guidelines mandate this. | LOW | A global `ConnectivityBanner` widget at the top of the Scaffold body, driven by `connectivityStreamProvider`. Show when offline, hide when online. Do not use SnackBars (they dismiss). |
| **Sync status per record** | Users need to see which records have pending changes vs which are synced. The current `SyncStatusBadge` widget exists but is not consistently shown across all entity list/detail screens. | LOW | The `isPendingSync` flag already exists on all syncable entities. Show a small badge (cloud-upload icon for pending, cloud-done for synced) on every card in list views and at the top of detail screens. |
| **"Last synced" timestamp** | Users need to know how fresh their data is, especially after being offline for extended periods. Android official docs and Google design guidelines both recommend this. | LOW | Display "Last synced: X minutes ago" on the Dashboard and in the Profile/Settings area. Source from `AppSettings` table (already tracks sync timestamps). |
| **Graceful error states with offline fallback** | When a StreamProvider errors, the screen should show cached data with a staleness warning, not crash or show a raw error string. The current pattern `error: (error, _) => Text('Error: $error')` is unacceptable for production. | MEDIUM | Wrap `.when()` calls to distinguish between network errors (show cached data + warning banner) vs data errors (show `AppErrorState` with retry). Use `AsyncValue.whenOrNull` or pattern-match the error type against the `Failure` hierarchy. |
| **Retry mechanism with user feedback** | When sync fails for a specific item, users should see which items failed and be able to retry. Currently, the sync queue debug screen exists but is hidden/dev-only. | MEDIUM | Surface failed sync items count as a badge on the sync icon in the app bar. Provide a user-facing (not debug) screen or bottom sheet listing failed items with "Retry" and "Discard" options. |
| **Dead letter queue handling** | Items that exceed `maxRetries` (5) currently sit in the queue forever with no resolution. They block the user's mental model of "my data is safe." | MEDIUM | After max retries, move items to a "failed" state. Notify the user via an in-app notification or badge. Provide clear actions: "Retry All Failed", "View Details", or "Discard" (with confirmation). |
| **Conflict resolution policy (Last-Write-Wins)** | When the same record is edited offline on one device and online on another, the sync must have a deterministic merge strategy. The current `SyncConflictFailure` class exists but is never actually used -- conflicts are not detected or handled. | HIGH | Implement Last-Write-Wins (LWW) using `updated_at` timestamps. During push sync, compare local `updated_at` with server `updated_at`. If server is newer, pull server version and surface the conflict to the user. For a CRM with single-user-per-record ownership, LWW is sufficient. |
| **Background sync that persists across app restarts** | The current `Timer.periodic` background sync stops when the app is killed. On mobile, apps are killed frequently. Data created offline but not synced before the app is killed will wait until next manual app open. | HIGH | On Android, use `workmanager` package with periodic tasks and network connectivity constraints. On iOS, use background fetch. On web, the Timer approach is fine. This ensures sync happens even if the app is not in the foreground. |
| **Idempotent sync operations** | If the same sync queue item is sent twice (e.g., app crash during sync, retry sends same create), the server must not create duplicates. The current implementation uses client-generated UUIDs for entity IDs, which provides natural idempotency for creates (Supabase upsert on ID). But updates do not use idempotency keys. | MEDIUM | For creates: already safe due to UUID primary keys and Supabase's insert behavior (will conflict on duplicate ID). For updates: add an `idempotency_key` or use `updated_at` as a version guard. Ensure the Supabase insert for creates uses `upsert` mode rather than raw `insert` to be truly idempotent. |
| **Typed error handling throughout the app** | The `Failure` class hierarchy is well-designed but underused. Many repository methods catch generic `Exception` and throw generic strings. Screens receive raw error objects instead of typed `Failure` instances. | MEDIUM | Ensure all repository methods return `Either<Failure, T>` consistently. Map Supabase `PostgrestException`, `SocketException`, `TimeoutException` to specific `Failure` subclasses. In screens, pattern-match on failure type to show appropriate UI. |

### Differentiators (Competitive Advantage)

Features that go beyond what users expect and create genuine competitive advantage, especially for a field sales CRM used in areas with poor connectivity.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Optimistic UI with undo** | Instead of just showing a pending badge, allow immediate action rollback. When a user creates/edits offline, show a transient "Undo" SnackBar for 5 seconds. This gives users confidence AND a safety net. Rare in CRM apps. | MEDIUM | Implement by delaying the sync queue insertion by 5 seconds, or by adding a "soft-created" flag. If undo is tapped, revert the local DB write and remove from queue. |
| **Smart sync prioritization** | Instead of FIFO for all entities, prioritize sync based on business value. For example: activities with photos sync before customer profile updates. Pipeline stage changes sync before broker edits. Ensures the most important data reaches the server first. | MEDIUM | Add a `priority` column to `sync_queue` table. Assign priorities based on entity type and operation. Process queue ordered by priority, then creation time. |
| **Offline data integrity validation** | Before syncing, validate that the payload still makes sense (e.g., a pipeline referencing a stage that was deleted server-side). Pre-sync validation prevents sending data that will be rejected by server constraints. | MEDIUM | Add a validation step in `_processItem` that checks foreign key references against local data. If validation fails, mark the item for user review rather than sending it to fail server-side. |
| **Selective sync (Wi-Fi only for large payloads)** | Photos and large attachments should only sync on Wi-Fi to prevent unexpected data charges. Text data syncs on any connection. Sales reps in Indonesia often use metered mobile data. | LOW | `connectivity_plus` already distinguishes WiFi vs mobile. Add a check in `processQueue` that skips photo sync items when on mobile data. User setting to override. |
| **Sync progress with per-entity detail** | The current `SyncProgressSheet` shows table-level progress during initial sync but gives no visibility during regular bidirectional sync. Show "Syncing 3/12 items... (Customer: PT Askrindo)" during regular sync. | LOW | The `SyncState.syncing` already has `currentEntity` field. Surface it in a non-blocking toast or persistent bottom bar during sync, not just the initial sync sheet. |
| **Offline search with full-text index** | Currently, search queries the Drift database. Adding FTS (Full-Text Search) to Drift would make offline search faster and support partial/fuzzy matching, which matters when sales reps misspell customer names. | HIGH | Drift supports FTS5 virtual tables. Create FTS indexes on customer name, company name, and pipeline description. Rebuild indexes after each sync pull. |
| **Automatic conflict notification** | When a conflict is detected during sync (another user modified the same record), show an in-app notification with "Your version" vs "Server version" comparison, letting the user choose. Goes beyond simple LWW. | HIGH | Requires a conflict detection layer that compares field-level changes. Store "pre-sync snapshot" of the local record before pushing. If push fails with a 409 or if server `updated_at` is newer, present a diff UI. |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create more problems than they solve for this specific project.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **Real-time sync (WebSocket/Supabase Realtime)** | "I want to see changes instantly when someone else edits" | Adds massive complexity to an offline-first app. Real-time assumes connectivity. Supabase Realtime requires active connection. Conflicts with the offline-first mental model. Battery drain. | Use pull-based delta sync on a 5-minute timer (already exists). When the app comes to the foreground, trigger a sync. This is sufficient for a CRM where data freshness tolerance is minutes, not seconds. |
| **Automatic merge for all conflict types** | "Just automatically resolve conflicts so users never see them" | Automatic merging can silently discard user changes. For a CRM, losing a phone number update or a pipeline stage change is worse than showing a conflict dialog. Silent data loss erodes trust more than a conflict prompt. | Use Last-Write-Wins as default with user notification. For high-value fields (pipeline stage, deal value), require user confirmation when conflict is detected. |
| **Full offline CRUD for all entities including admin operations** | "Admins should be able to create users and manage settings offline" | Admin operations (user creation, password reset) use Supabase Edge Functions with `service_role` key. These are inherently online-only. Queuing admin operations offline creates security risks and complex failure modes. | Keep admin operations online-only. Disable admin buttons when offline with a tooltip: "Requires internet connection." This is how Salesforce handles admin operations. |
| **Per-field sync tracking** | "Track which specific fields changed so we can merge at field level" | Exponentially increases sync queue payload size and complexity. For a CRM with ~12 entity types and ~20 fields each, this creates a combinatorial explosion. The sync queue currently stores full JSON payloads which is simpler and sufficient. | Keep full-payload sync with Last-Write-Wins at the record level. The full JSON payload approach is what Flutter's official offline-first docs recommend. |
| **Bidirectional real-time conflict resolution** | "When two users edit the same record, show them each other's cursors like Google Docs" | Requires CRDT or OT (Operational Transform) infrastructure. Completely inappropriate for a CRM where records are typically owned by one sales rep. Over-engineering for the use case. | Single-user record ownership (enforced by RLS) plus LWW for the rare case where a manager edits a rep's record simultaneously. |
| **Infinite retry for all sync failures** | "Never give up, keep trying forever" | Consumes battery and data. Some failures are permanent (deleted server record, schema change, permission revoked). Retrying forever for a 403 Forbidden is wasteful and masks the real problem. | Max 5 retries with exponential backoff (already implemented). After that, move to dead letter queue with user notification. Classify errors as retryable (network, timeout) vs permanent (403, 404, validation) and stop retrying permanent errors immediately. |

---

## Feature Dependencies

```
Atomic write+queue (transaction safety)
    |
    +--- All other sync features depend on this being correct first
    |
Typed error handling
    +--- Graceful error states (screens need typed errors to show appropriate UI)
    +--- Retry mechanism (needs to classify errors as retryable vs permanent)
    +--- Dead letter queue (needs error classification)
    |
Offline connectivity banner
    +--- Required BEFORE graceful error states (users need context)
    |
Sync status per record
    +--- Required BEFORE "last synced" timestamp (establishes visual language)
    |
Conflict resolution (LWW)
    +--- Required BEFORE automatic conflict notification (differentiator)
    +--- Required BEFORE smart sync prioritization (needs to handle conflicts from reordering)
    |
Background sync (workmanager)
    +--- Enhances: all sync features (ensures sync happens even when app is backgrounded)
    +--- Requires: atomic write+queue (must be safe before running unattended)
    |
Idempotent sync operations
    +--- Required BEFORE background sync (background sync retries need idempotency)
```

### Dependency Notes

- **Atomic write+queue requires all other features:** This is the foundation. If writes and queue insertions are not atomic, all other sync improvements are built on sand. Fix this first.
- **Typed error handling enables graceful error states:** Screens cannot show appropriate offline/error UI if they receive raw `Exception` objects instead of typed `Failure` instances.
- **Offline connectivity banner is a prerequisite for user trust:** Users who do not know they are offline will blame the app for "losing data" when they are actually just offline. This must be visible before any other UX improvements.
- **Conflict resolution requires idempotent operations:** If operations are not idempotent, resolving conflicts by replaying operations can create duplicates.
- **Background sync conflicts with non-atomic operations:** Running sync in the background (workmanager) when the app is killed mid-transaction could corrupt the sync queue if operations are not atomic.

---

## MVP Definition (Stability Milestone)

### Launch With (v1 -- Stability)

These are the minimum features needed to make LeadX's offline-first experience trustworthy.

- [ ] **Atomic write+queue operations** -- prevents silent data loss, the root cause of "sync loses data"
- [ ] **Typed error handling throughout repositories** -- enables all downstream error UI improvements
- [ ] **Graceful error states with offline fallback** -- screens show cached data when offline instead of crashing
- [ ] **Offline connectivity banner** -- users always know their connectivity state
- [ ] **Sync status per record (badges)** -- users can see which records are pending sync
- [ ] **"Last synced" timestamp on dashboard** -- users know how fresh their data is
- [ ] **Dead letter queue with user-facing UI** -- permanently failed items are surfaced, not hidden

### Add After Validation (v1.x)

Features to add once core stability is proven in the field.

- [ ] **Last-Write-Wins conflict resolution** -- add when multiple users start accessing overlapping records
- [ ] **Idempotent sync operations (upsert for creates)** -- add when background sync is introduced
- [ ] **Background sync via workmanager** -- add when field reps report "I forgot to open the app to sync"
- [ ] **Retry mechanism with error classification** -- add when dead letter queue reveals patterns of retryable vs permanent errors
- [ ] **Smart sync prioritization** -- add when sync queue grows large enough that FIFO order matters

### Future Consideration (v2+)

Features to defer until the stability foundation is proven.

- [ ] **Offline search with FTS5** -- defer until search performance is a reported issue
- [ ] **Optimistic UI with undo** -- defer until basic sync trust is established
- [ ] **Automatic conflict notification with diff UI** -- defer until LWW proves insufficient
- [ ] **Selective sync (Wi-Fi only for photos)** -- defer until data usage is a reported concern
- [ ] **Sync progress for regular sync (not just initial)** -- defer until users request visibility

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Atomic write+queue | HIGH | MEDIUM | **P1** |
| Typed error handling | HIGH | MEDIUM | **P1** |
| Graceful error states | HIGH | MEDIUM | **P1** |
| Offline connectivity banner | HIGH | LOW | **P1** |
| Sync status per record | HIGH | LOW | **P1** |
| "Last synced" timestamp | MEDIUM | LOW | **P1** |
| Dead letter queue UI | HIGH | MEDIUM | **P1** |
| LWW conflict resolution | HIGH | HIGH | **P2** |
| Idempotent sync ops | HIGH | MEDIUM | **P2** |
| Background sync (workmanager) | MEDIUM | HIGH | **P2** |
| Error classification (retryable vs permanent) | MEDIUM | MEDIUM | **P2** |
| Smart sync prioritization | LOW | MEDIUM | **P3** |
| Offline FTS5 search | LOW | HIGH | **P3** |
| Optimistic UI with undo | MEDIUM | MEDIUM | **P3** |
| Conflict notification diff UI | LOW | HIGH | **P3** |
| Selective Wi-Fi sync | LOW | LOW | **P3** |

**Priority key:**
- P1: Must have for stability milestone -- directly addresses reported issues (data loss, crashes, offline failures)
- P2: Should have -- prevents future issues and improves reliability for field deployment
- P3: Nice to have -- competitive differentiators for when the foundation is solid

---

## Competitor Feature Analysis

| Feature | Salesforce Mobile | Resco (Salesforce offline) | HubSpot Mobile | LeadX Current | LeadX Target |
|---------|------------------|---------------------------|----------------|---------------|-------------|
| Offline read | Partial (recent records only) | Full (all assigned data) | None | Full (Drift) | Full (no change) |
| Offline create/edit | Yes | Yes | No | Yes | Yes (no change) |
| Sync indicator | Persistent banner | Status bar + per-record | None | App bar icon only | Banner + per-record badges |
| Conflict resolution | LWW with notification | Configurable (LWW/manual) | N/A | None | LWW (P2) |
| Failed sync visibility | Sync error list | Detailed error log | N/A | Debug screen only | User-facing dead letter UI |
| Background sync | Yes (platform APIs) | Yes (WorkManager) | N/A | Timer only (dies with app) | WorkManager (P2) |
| Last synced timestamp | Yes (per record) | Yes (global + per record) | N/A | Not visible | Dashboard + settings |
| Offline admin ops | No (online only) | No (online only) | N/A | No (online only) | No (intentional) |

---

## Sources

- [Flutter Official: Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) -- HIGH confidence, authoritative
- [Android Official: Build an offline-first app](https://developer.android.com/topic/architecture/data-layer/offline-first) -- HIGH confidence, authoritative
- [Google Open Health Stack: Design Guidelines for Offline & Sync](https://developers.google.com/open-health-stack/design/offline-sync-guideline) -- HIGH confidence, authoritative UX patterns
- [GeekyAnts: Offline-First Flutter Implementation Blueprint](https://geekyants.com/blog/offline-first-flutter-implementation-blueprint-for-real-world-apps) -- MEDIUM confidence
- [Medium: Building a Flutter Offline-First Sync Engine with Conflict Resolution](https://medium.com/@pravinkunnure9/building-a-flutter-offline-first-sync-engine-flutter-sync-engine-with-conflict-resolution-5a087f695104) -- MEDIUM confidence
- [Medium: Building Offline-First Flutter Apps with Drift](https://777genius.medium.com/building-offline-first-flutter-apps-a-complete-sync-solution-with-drift-d287da021ab0) -- MEDIUM confidence
- [Beefed AI: Offline-First Mobile Apps: Queueing & Sync](https://beefed.ai/en/offline-first-queueing-sync) -- MEDIUM confidence
- [Resco: How Offline is Offline?](https://www.resco.net/blog/how-offline-is-offline/) -- MEDIUM confidence, competitor analysis
- [DashDevs: Offline Applications Challenges and Solutions](https://dashdevs.com/blog/offline-applications-and-offline-first-design-challenges-and-solutions/) -- MEDIUM confidence
- [Hasura: A Design Guide for Building Offline First Apps](https://hasura.io/blog/design-guide-to-offline-first-apps) -- MEDIUM confidence
- LeadX codebase analysis (direct inspection of `sync_service.dart`, `connectivity_service.dart`, `failures.dart`, `sync_providers.dart`, screen implementations) -- HIGH confidence

---
*Feature research for: Offline-First CRM Stability*
*Researched: 2026-02-13*
