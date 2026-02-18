# Phase 6: Sync Coordination - Research

**Researched:** 2026-02-18
**Domain:** Dart async concurrency control, sync state machine design, initial sync gating
**Confidence:** HIGH

## Summary

This phase replaces the simple `_isSyncing` boolean flag in `SyncService` and `InitialSyncService` with a proper coordination layer that prevents race conditions between initial sync, manual sync, repository-triggered sync, and background sync. The existing codebase has three independent sync entry points (`SyncService.processQueue()`, `SyncService.triggerSync()`, and `SyncNotifier.triggerSync()`) plus two independent `_isSyncing` booleans (one in `SyncService`, one in `InitialSyncService`) with no coordination between them. Currently, when sync is already running, callers receive a failure result with error message "Sync already in progress" and their request is silently dropped -- there is no queuing.

The core technical challenge is modest: Dart is single-threaded with cooperative async scheduling, so a `Completer`-based lock pattern (already used in `ConnectivityService._initCompleter` and `SyncService._pendingSyncCompleter`) is sufficient -- no external mutex package is needed. The real complexity lies in designing the correct state machine: initial sync must gate all user operations AND regular sync triggers, the push phase must fully complete before pull begins (which `SyncNotifier.triggerSync()` already does sequentially), and queued requests must collapse into a single execution (similar to the existing debounce pattern).

The `SyncProgressSheet` already supports resume from interruption via `AppSettingsService.getResumeSyncIndex()`, and the modal bottom sheet is already non-dismissable (`isDismissible: false, enableDrag: false`). The `SyncProgressSheet._isShowing` static boolean prevents duplicate sheets. These existing mechanisms provide a foundation, but they lack retry with backoff, cancel-and-logout, and cooldown-before-regular-sync capabilities that Phase 6 requires.

**Primary recommendation:** Introduce a `SyncCoordinator` service that wraps `SyncService` and `InitialSyncService`, holding a single Completer-based lock, an initial-sync-complete flag, and a queued-sync-pending flag. All sync entry points (repositories, manual trigger, background) go through the coordinator. The coordinator enforces: (1) initial sync blocks everything, (2) only one regular sync at a time, (3) excess triggers collapse into one queued execution, (4) push-then-pull serialization is preserved.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Block user interaction entirely until initial sync completes -- modal bottom sheet stays non-dismissable
- Resume from where it stopped on partial failure (track per-table progress) -- current SyncProgressSheet partially supports this
- User writes are blocked entirely during initial sync (the modal prevents form access)
- Short cooldown (~5 seconds) after initial sync before regular sync triggers are accepted
- Initial sync gate also applies after schema migration if new sync tables were added -- not just first-ever login
- Auto-retry with backoff on failure (2s/5s/15s intervals, 3 attempts)
- After 3 failed retries, show "Cancel and log out" button -- user can try again later
- Cancel clears auth session; next login re-attempts initial sync
- Toast notification when sync triggers while another is running: "Sync already in progress -- your request is queued"
- Existing SyncStatusBadge in app bar continues showing synced/pending/offline/deadLetter states as-is
- Coordination issues (lock contention, phase failures) are silent to user -- logged to Talker only
- User only sees final sync outcome (synced/failed) through existing badge

### Claude's Discretion
- Whether push failure should skip pull (pull guards exist from Phase 4 to protect pending local data)
- Sync lock recovery mechanism (timeout-based vs startup cleanup vs both)
- Maximum queued sync depth (cap at 1 vs unlimited -- likely cap at 1 to prevent runaway)
- Whether multiple queued requests collapse into one sync execution
- 'Queued' badge state on SyncStatusBadge vs relying on existing 'pending' state
- Whether to preserve or clear partial data on "Cancel and log out" (resume pattern suggests preserve)
- App kill during initial sync recovery strategy (resume vs fresh start -- current SyncProgressSheet has resume support)
- Progress display detail level (current table names + counter vs simplified messaging)
- Manual vs background vs repository sync priority handling
- Whether sync lock tracks sync type (initial/manual/background) or is type-agnostic
- Background sync (push-only) behavior during initial sync
- Whether master data re-sync (long press) respects or bypasses sync lock

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CONF-05 | SyncCoordinator prevents queue push before initial sync completes and serializes sync phases (push, pull) | Current `SyncService._isSyncing` and `InitialSyncService._isSyncing` operate independently with no cross-check. New `SyncCoordinator` service unifies all sync entry points behind a single lock. Initial sync completion gating uses `AppSettingsService.hasInitialSyncCompleted()` (already exists) plus a cooldown timer. Push-then-pull serialization already exists in `SyncNotifier.triggerSync()` and is preserved. |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| dart:async | (built-in) | `Completer`-based lock pattern for sync coordination | Dart's cooperative async model means a simple Completer is equivalent to a mutex. No external package needed. Already used in `SyncService._pendingSyncCompleter` and `ConnectivityService._initCompleter` |
| drift | 2.22.1 (existing) | Persist initial sync state and per-table resume progress | `AppSettingsService` already stores `initial_sync_completed`, `sync_in_progress`, `last_synced_table_index` in the `app_settings` table |
| supabase_flutter | 2.8.3 (existing) | Auth session access for cancel-and-logout flow | `Supabase.instance.client.auth.signOut()` clears the session |
| talker | 4.5.2 (existing) | Structured logging for lock acquisition, release, phase transitions | Uses `AppLogger` with module prefixes (`sync.coordinator`, `sync.lock`) |
| flutter_riverpod | 2.6.1 (existing) | Provider for SyncCoordinator, state exposure to UI | New provider wraps SyncCoordinator as singleton |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| workmanager | 0.9.0+3 (existing) | Background sync that must respect coordinator lock | Background callback currently calls `SyncService.processQueue()` directly; must coordinate with lock |
| connectivity_plus | 6.1.1 (existing) | Connectivity checks before sync attempts | Already integrated in `SyncService.processQueue()` |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Hand-rolled Completer lock | `synchronized` package (v3.4.0) | Adds dependency for marginal benefit; Completer pattern is already used twice in this codebase and is simpler to understand for this use case |
| Hand-rolled Completer lock | `mutex` package (v3.1.0) | ReadWriteMutex not needed here; only one sync at a time. Extra dependency for no gain |
| In-memory lock state | Drift-persisted lock state | Persistence only needed for initial sync tracking (already exists). Regular sync lock is ephemeral -- process crash naturally releases it |

## Architecture Patterns

### Recommended File Structure
```
lib/data/services/
├── sync_coordinator.dart        # NEW: Central coordination service
├── sync_service.dart            # MODIFIED: Remove _isSyncing, add lock hooks
├── initial_sync_service.dart    # MODIFIED: Remove _isSyncing, called via coordinator
├── background_sync_service.dart # MODIFIED: Coordinate with lock
├── connectivity_service.dart    # UNCHANGED
└── app_settings_service.dart    # MODIFIED: Add cooldown timestamp, lock recovery keys

lib/presentation/
├── providers/
│   └── sync_providers.dart      # MODIFIED: Add syncCoordinatorProvider, update SyncNotifier
├── widgets/sync/
│   └── sync_progress_sheet.dart # MODIFIED: Add retry/backoff, cancel-and-logout
└── widgets/common/
    └── sync_status_badge.dart   # MINIMAL: Possibly add 'queued' state
```

### Pattern 1: Completer-Based Async Lock
**What:** A single `Completer<void>?` guards the sync execution path. When null, the lock is available. When non-null, callers await its future.
**When to use:** Protecting a single async critical section in Dart's cooperative event loop.
**Example:**
```dart
/// Source: Existing pattern in ConnectivityService._initCompleter
class SyncCoordinator {
  Completer<void>? _activeSyncCompleter;
  bool _queuedSyncPending = false;
  bool _initialSyncComplete = false;
  DateTime? _initialSyncCompletedAt;

  /// Acquire the sync lock. Returns true if acquired, false if queued.
  Future<bool> acquireLock({required SyncType type}) async {
    if (_activeSyncCompleter != null) {
      // Lock is held -- queue this request (collapse multiple into one)
      if (type != SyncType.initial) {
        _queuedSyncPending = true;
        _log.info('sync.lock | Queued $type sync (lock held)');
      }
      return false;
    }

    // Check initial sync gate
    if (!_initialSyncComplete && type != SyncType.initial) {
      _log.info('sync.lock | Rejected $type sync (initial sync not complete)');
      return false;
    }

    // Check cooldown
    if (_initialSyncCompletedAt != null && type != SyncType.initial) {
      final elapsed = DateTime.now().difference(_initialSyncCompletedAt!);
      if (elapsed < const Duration(seconds: 5)) {
        _log.info('sync.lock | Rejected $type sync (cooldown active)');
        return false;
      }
    }

    _activeSyncCompleter = Completer<void>();
    _log.info('sync.lock | Acquired lock for $type');
    return true;
  }

  /// Release the sync lock.
  void releaseLock() {
    final completer = _activeSyncCompleter;
    _activeSyncCompleter = null;
    completer?.complete();
    _log.info('sync.lock | Released lock');
  }
}
```

### Pattern 2: Initial Sync Gating with Retry and Backoff
**What:** The initial sync blocks all app interaction via non-dismissable modal. On failure, auto-retries with escalating delays (2s/5s/15s). After 3 failures, shows cancel button.
**When to use:** First login, post-migration with new sync tables.
**Example:**
```dart
/// Source: Enhancement of existing SyncProgressSheet._startSync()
static const _retryDelays = [
  Duration(seconds: 2),
  Duration(seconds: 5),
  Duration(seconds: 15),
];
static const _maxRetries = 3;

Future<void> _startSyncWithRetry() async {
  int attempt = 0;
  while (attempt < _maxRetries) {
    final result = await _performSync();
    if (result.success) return; // Success -- close sheet

    attempt++;
    if (attempt < _maxRetries) {
      setState(() => _retryMessage = 'Retry in ${_retryDelays[attempt - 1].inSeconds}s...');
      await Future.delayed(_retryDelays[attempt - 1]);
    }
  }
  // All retries exhausted -- show cancel button
  setState(() => _showCancelButton = true);
}
```

### Pattern 3: Queued Sync Execution with Collapse
**What:** When sync triggers arrive while another sync is running, they collapse into a single "queued" flag. After the current sync completes, one more sync executes (not N).
**When to use:** Repository write triggers (create/update/delete) and manual sync button during active sync.
**Example:**
```dart
/// Source: Enhancement of existing triggerSync() debounce pattern
Future<SyncResult> executeSync() async {
  final acquired = await acquireLock(type: SyncType.regular);
  if (!acquired) {
    // Show toast: "Sync already in progress -- your request is queued"
    return SyncResult.queued();
  }

  try {
    final result = await _doSync();
    return result;
  } finally {
    releaseLock();

    // Execute queued sync if pending
    if (_queuedSyncPending) {
      _queuedSyncPending = false;
      // Delay slightly to avoid tight loop
      await Future.delayed(const Duration(milliseconds: 100));
      await executeSync(); // Recursive -- safe because lock is released
    }
  }
}
```

### Pattern 4: Background Sync Coordination
**What:** Background sync (push-only) must check the lock before executing. Since it runs in a separate FlutterEngine, it cannot share in-memory lock state.
**When to use:** WorkManager callback running in isolated FlutterEngine.
**Example:**
```dart
/// Source: Enhancement of existing callbackDispatcher()
/// Background sync runs in its own FlutterEngine -- cannot share in-memory lock.
/// It uses AppSettingsService (Drift DB) as a lightweight coordination signal.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // ... existing setup code ...

    // Check if initial sync is complete (persisted in DB)
    final initialSyncDone = await appSettings.hasInitialSyncCompleted();
    if (!initialSyncDone) {
      return true; // Skip -- let foreground handle initial sync
    }

    // Check if foreground is actively syncing (optional: use DB flag)
    // Note: This is best-effort. Race condition is acceptable because
    // push operations are idempotent (upsert on server).
    await syncService.processQueue();
    return true;
  });
}
```

### Anti-Patterns to Avoid
- **Multiple independent `_isSyncing` booleans:** The current codebase has one in `SyncService` and one in `InitialSyncService` with no coordination. These must be unified into a single lock in the coordinator.
- **Silently dropping sync requests:** Current behavior returns a failure result with no queuing. Phase 6 replaces this with queued execution.
- **Calling `processQueue()` directly from repositories:** Repositories currently call `_syncService.triggerSync()` which has 500ms debounce. The coordinator must sit above this, not replace the debounce.
- **Blocking on lock acquisition:** Never `await` lock indefinitely. Use fire-and-forget queuing with collapse.
- **Persisting regular sync lock to disk:** Only initial sync state needs persistence. Regular sync lock is in-memory only -- process crash naturally releases it.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Async mutual exclusion | Custom queue/semaphore implementation | Dart `Completer<void>` pattern | Dart's single-threaded event loop makes Completer equivalent to a mutex. The pattern is already used twice in this codebase (`SyncService._pendingSyncCompleter`, `ConnectivityService._initCompleter`) |
| Initial sync resume tracking | Custom file-based or SharedPreferences tracking | Existing `AppSettingsService` with `getResumeSyncIndex()` / `markTableSynced()` | Already implemented and working in Phase 1 |
| Toast notifications | Custom overlay system | Flutter `ScaffoldMessenger.showSnackBar()` | Standard Flutter pattern, used throughout the codebase |
| Auth session clearing | Manual token deletion | `Supabase.instance.client.auth.signOut()` | Handles all cleanup (token, session, refresh) automatically |

**Key insight:** The coordination problem is fundamentally simple in Dart's cooperative async model. The complexity is in the state machine design (what gates what, what queues, what collapses), not in the concurrency primitives.

## Common Pitfalls

### Pitfall 1: Background Sync Cannot Share In-Memory Lock
**What goes wrong:** The `callbackDispatcher()` in `BackgroundSyncService` runs in a separate `FlutterEngine` with its own Dart isolate. It cannot access the `SyncCoordinator` instance from the foreground app.
**Why it happens:** WorkManager creates an independent Flutter engine for background execution (Phase 5 already documented this).
**How to avoid:** Background sync checks `AppSettingsService.hasInitialSyncCompleted()` (persisted in SQLite) before proceeding. For regular sync coordination, accept that background push-only sync may occasionally overlap with foreground sync -- this is safe because: (a) push operations use upsert which is idempotent, (b) SQLite WAL mode handles concurrent access, (c) background sync is push-only (no pull).
**Warning signs:** Background sync produces duplicate queue processing attempts or conflicts with foreground sync.

### Pitfall 2: Deadlock From Lock Not Released on Exception
**What goes wrong:** If sync throws an unhandled exception after acquiring the lock but before releasing it, the lock is held forever and all subsequent syncs are blocked.
**Why it happens:** Missing try/finally around the sync execution path.
**How to avoid:** Always use try/finally: `try { await doSync(); } finally { releaseLock(); }`. Additionally, implement a timeout-based recovery: if the lock has been held for more than 5 minutes, force-release it on the next acquisition attempt.
**Warning signs:** Sync stops working entirely after an error, requiring app restart.

### Pitfall 3: Initial Sync Marked Complete Before Actually Complete
**What goes wrong:** Currently, `markInitialSyncCompleted()` is called AFTER `SyncProgressSheet.show()` returns, but the sheet returns when the user taps "Lanjutkan" (Continue), not necessarily when sync succeeded. If sync failed but the user tapped the button, the flag is set prematurely.
**Why it happens:** The current `SyncProgressSheet` sets `_isComplete = true` even on error, and the caller (`LoginScreen`, `HomeScreen`) calls `markInitialSyncCompleted()` unconditionally after the sheet closes.
**How to avoid:** `SyncProgressSheet` should return a success/failure result. Only call `markInitialSyncCompleted()` on success. On failure, the sheet's close button should NOT mark completion.
**Warning signs:** User sees initial sync error, taps button, then app allows normal operation without reference data.

### Pitfall 4: Cooldown Timer Blocks Legitimate First Sync After Initial
**What goes wrong:** The 5-second cooldown after initial sync completion prevents the immediately-following user data pull from executing.
**Why it happens:** The `SyncProgressSheet._startSync()` calls `syncNotifierProvider.notifier.triggerSync()` as Phase 3 of initial sync. If cooldown is naively applied, this pull is blocked.
**How to avoid:** The cooldown should only apply to *new* sync triggers after the initial sync coordinator releases its lock. The user data pull in Phase 3 of initial sync should happen WITHIN the initial sync lock, before the lock is released. Cooldown starts from lock release, not from initial sync phase completion.
**Warning signs:** Initial sync completes master data but fails to pull user data (customers, pipelines, activities).

### Pitfall 5: SyncNotifier.triggerSync() Bypasses Coordinator
**What goes wrong:** `SyncNotifier.triggerSync()` currently calls `_syncService.processQueue()` directly, then does its own pull logic. If the coordinator wraps `SyncService`, but `SyncNotifier` doesn't use the coordinator, the lock is bypassed.
**Why it happens:** The coordinator must be integrated at every sync entry point, not just `SyncService`.
**How to avoid:** `SyncNotifier.triggerSync()` must go through the coordinator. The coordinator either delegates to `SyncNotifier`'s push-then-pull logic, or the coordinator itself implements the push-then-pull pattern and `SyncNotifier` becomes a thin wrapper.
**Warning signs:** Two syncs running simultaneously despite coordinator being in place.

### Pitfall 6: Master Data Re-sync (Long Press) During Active Sync
**What goes wrong:** The long-press master data re-sync in `responsive_shell.dart` calls `SyncProgressSheet.show()` which triggers `InitialSyncService.performInitialSync()` -- this could overlap with a regular sync in progress.
**Why it happens:** Master data re-sync uses the same `SyncProgressSheet` flow as initial sync but doesn't check if regular sync is running.
**How to avoid:** Master data re-sync should acquire the coordinator lock (as `SyncType.masterDataResync` or similar) before proceeding. If lock is held, show a toast "Sync in progress, please try again later."
**Warning signs:** Concurrent initial sync and regular sync causing inconsistent local state.

## Code Examples

### Current Sync Entry Points (Must All Be Coordinated)

```dart
// Source: lib/data/services/sync_service.dart
// Entry point 1: Direct queue processing (used by background sync)
Future<SyncResult> processQueue() // line 80

// Entry point 2: Debounced trigger (used by repositories after write)
Future<SyncResult> triggerSync() // line 799

// Entry point 3: Background timer-based (in-app periodic)
void startBackgroundSync() // line 825, calls processQueue()

// Source: lib/presentation/providers/sync_providers.dart
// Entry point 4: Manual bidirectional sync (push + pull)
class SyncNotifier {
  Future<void> triggerSync() // line 179, calls processQueue() then _pullFromRemote()
}

// Source: lib/data/services/initial_sync_service.dart
// Entry point 5: Initial master data sync
Future<SyncResult> performInitialSync() // line 130

// Entry point 6: Delta sync for transactional tables
Future<SyncResult> performDeltaSync() // line 947

// Source: lib/data/services/background_sync_service.dart
// Entry point 7: WorkManager background push (separate FlutterEngine)
callbackDispatcher() // line 19, calls syncService.processQueue()
```

### Repositories That Trigger Sync (All Must Be Gated During Initial Sync)

```dart
// Source: Multiple repository files -- all call _syncService.triggerSync()
// These are fire-and-forget (unawaited) after local DB writes:

// CustomerRepositoryImpl: 6 call sites (create, update, delete, keyPerson ops)
// PipelineRepositoryImpl: 5 call sites (create, update, delete, stage change, notes)
// ActivityRepositoryImpl: 5 call sites (create, update, execute, cancel, delete)
// HvcRepositoryImpl: 5 call sites (create, update, delete, link, unlink)
// BrokerRepositoryImpl: 3 call sites (create, update, delete)
// CadenceRepositoryImpl: 13 call sites (various meeting/participant ops)
// PipelineReferralRepositoryImpl: 5 call sites (create, accept, reject, cancel, update)
```

### Current SyncProgressSheet Flow (To Be Enhanced)

```dart
// Source: lib/presentation/widgets/sync/sync_progress_sheet.dart
// Current 3-phase flow in _startSync():
// Phase 1: initialSyncService.performInitialSync() -- master data
// Phase 2: initialSyncService.performDeltaSync() -- transactional tables
// Phase 3: syncNotifierProvider.notifier.triggerSync() -- user data (push+pull)
// Then: _isComplete = true, user taps button, sheet closes
// Then: caller marks initial sync completed
```

### Toast Notification Pattern (Existing in Codebase)

```dart
// Source: lib/presentation/widgets/shell/responsive_shell.dart line 264
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Sinkronisasi dimulai...'),
    duration: Duration(seconds: 1),
  ),
);
// Phase 6 adds: "Sync sedang berjalan -- permintaan Anda diantrikan"
```

### AppSettingsService Keys for Sync State (Already Exist)

```dart
// Source: lib/data/services/app_settings_service.dart
static const String keyInitialSyncCompleted = 'initial_sync_completed';
static const String keyLastSyncAt = 'last_sync_at';
static const String keyLastSyncedTableIndex = 'last_synced_table_index';
static const String keySyncInProgress = 'sync_in_progress';
// Phase 6 adds: 'initial_sync_completed_at' for cooldown, 'sync_lock_holder' for recovery
```

## Discretion Recommendations

Based on the research, here are recommendations for the areas left to Claude's discretion:

### Push failure should NOT skip pull
**Recommendation:** Continue with pull even if push has failures. **Reason:** Pull sync already has `isPendingSync` guards from Phase 4 that skip local records with pending changes. The pull brings down fresh server data for *other* records. Skipping pull after push failure would leave the local DB increasingly stale. Individual push failures are already handled (retry/dead letter).

### Sync lock recovery: Timeout-based + Startup cleanup (both)
**Recommendation:** Implement both. On startup, clear any stale lock flag (for app kill recovery). During runtime, if lock has been held >5 minutes, force-release on next acquisition attempt. **Reason:** App kill leaves no opportunity for `finally` blocks. The 5-minute timeout handles foreground hangs.

### Maximum queued sync depth: Cap at 1 with collapse
**Recommendation:** Cap at 1. Multiple queued requests collapse into a single flag (`_queuedSyncPending = true`). After current sync completes, execute exactly one more sync. **Reason:** Each sync processes the *entire* pending queue, so running it once after the current sync finishes captures all accumulated changes. Running N times is wasteful.

### Queued badge state: Rely on existing 'pending' state
**Recommendation:** Do NOT add a new 'queued' state to `SyncStatusBadge`. The existing `pending` state (cloud_upload icon, yellow) is semantically correct -- there are pending items waiting to sync. **Reason:** The user decision says "Existing SyncStatusBadge continues as-is". Adding a queued state would be a UI change beyond scope.

### Preserve partial data on "Cancel and log out"
**Recommendation:** Preserve local database. Clear auth session only. **Reason:** The resume pattern (`getResumeSyncIndex()`) already exists and expects data to persist. Next login re-triggers initial sync which resumes from the last successful table.

### App kill during initial sync: Resume (not fresh start)
**Recommendation:** Resume using existing `AppSettingsService` resume tracking. `sync_in_progress` flag is already set to `true` by `markSyncStarted()` and cleared by `markInitialSyncCompleted()`. `hasInterruptedSync()` already checks for this case. **Reason:** Infrastructure already exists and works.

### Sync lock should track sync type
**Recommendation:** Track sync type (`initial`, `manual`, `background`, `repository`, `masterDataResync`). **Reason:** Enables better logging and allows type-specific policies (e.g., background sync defers to foreground, master data resync requires initial sync lock level).

### Background sync during initial sync: Skip entirely
**Recommendation:** Background sync callback should check `hasInitialSyncCompleted()` and skip if false. **Reason:** Initial sync must complete all master data first. Background push-only sync before reference data exists could push records referencing non-existent master data IDs.

### Master data re-sync (long press): Respect sync lock
**Recommendation:** Master data re-sync should attempt to acquire the coordinator lock. If lock is held, show toast and abort. **Reason:** Master data re-sync uses `SyncProgressSheet` which calls both `performInitialSync()` and `performDeltaSync()` -- these must not overlap with regular sync.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single `_isSyncing` boolean per service | Centralized `SyncCoordinator` with typed lock | Phase 6 | Prevents race conditions between 7 independent sync entry points |
| Silently dropping concurrent sync requests | Queued execution with collapse + toast notification | Phase 6 | User is informed, no sync requests are lost |
| Dismissable initial sync sheet | Non-dismissable with retry/backoff/cancel-logout | Phase 6 | Prevents users from operating without reference data |
| `markInitialSyncCompleted()` always called | Only called on actual success | Phase 6 | Prevents false "sync complete" on failure |

## Open Questions

1. **Schema migration detection for re-triggering initial sync**
   - What we know: The user decision says initial sync gate "also applies after schema migration if new sync tables were added." `AppSettingsService` tracks `initial_sync_completed`.
   - What's unclear: How to detect that a migration added new sync tables. Current migration strategy is sequential (`schemaVersion` in Drift). We could compare current version vs stored version.
   - Recommendation: Store the `schemaVersion` at time of initial sync completion. On app startup, if current schema version > stored version AND new migration involves sync-relevant tables, reset `initial_sync_completed` to false. This is a simple check in `main.dart` or the router guard.

2. **Concurrent foreground + background database access during initial sync**
   - What we know: Background sync runs in a separate FlutterEngine with its own DB connection. SQLite WAL mode handles concurrent reads. Background sync is push-only.
   - What's unclear: If background sync pushes a queue item while initial sync is pulling the same table, could there be write contention?
   - Recommendation: Low risk. Background sync writes to `sync_queue_items` table (mark completed). Initial sync writes to business tables. Different tables = no contention. Still, the `hasInitialSyncCompleted()` check in background callback is a good guard.

3. **SyncNotifier refactoring scope**
   - What we know: `SyncNotifier.triggerSync()` currently implements push-then-pull directly. The coordinator needs to wrap this.
   - What's unclear: Should the coordinator own the push-then-pull logic, or should `SyncNotifier` keep it and the coordinator just provides the lock?
   - Recommendation: The coordinator provides the lock and delegates to `SyncNotifier` for the actual sync execution. This minimizes refactoring. `SyncNotifier.triggerSync()` becomes the "do the actual work" method, and a new `coordinatedSync()` or similar wraps it with lock acquisition.

## Sources

### Primary (HIGH confidence)
- **Codebase analysis** - Direct reading of `SyncService`, `InitialSyncService`, `SyncNotifier`, `SyncProgressSheet`, `BackgroundSyncService`, `AppSettingsService`, `ConnectivityService`, `SyncStatusBadge`, `sync_models.dart`, `sync_errors.dart`, `login_screen.dart`, `home_screen.dart`, `responsive_shell.dart`, `settings_screen.dart`, `pubspec.yaml`, `main.dart`
- **Prior phase research** - `05-RESEARCH.md` documents WorkManager separate FlutterEngine behavior and SQLite WAL concurrent access

### Secondary (MEDIUM confidence)
- [synchronized package (v3.4.0)](https://pub.dev/packages/synchronized) - Dart async lock library by tekartik, considered but not recommended due to Completer pattern being sufficient
- [mutex package (v3.1.0)](https://pub.dev/packages/mutex) - Dart mutex with ReadWriteMutex, considered but not needed for single-lock use case

### Tertiary (LOW confidence)
- None -- all findings verified against codebase

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- No new dependencies needed; all patterns exist in codebase
- Architecture: HIGH -- Coordinator pattern is straightforward; all integration points clearly identified from codebase analysis
- Pitfalls: HIGH -- All pitfalls identified from reading actual code paths and their interactions

**Research date:** 2026-02-18
**Valid until:** 2026-03-18 (stable -- no external dependency changes)
