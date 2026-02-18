# Phase 5: Background Sync & Dead Letter Queue - Research

**Researched:** 2026-02-18
**Domain:** Flutter background task scheduling, sync queue lifecycle management, dead letter UI
**Confidence:** HIGH

## Summary

This phase adds three capabilities to the existing sync infrastructure: (1) background sync via `workmanager` package that persists across app restarts using Android WorkManager and iOS BGTaskScheduler, (2) dead letter queue management with a production-ready UI evolved from the existing debug `SyncQueueScreen`, and (3) automatic queue pruning of completed and expired items. The existing codebase already has a solid foundation -- the `sync_queue_items` table has `retryCount`, `lastError`, `createdAt`, and `lastAttemptAt` columns, the `SyncService.processQueue()` handles retry logic, and the `SyncQueueScreen` has card-based UI with status badges.

The primary technical challenge is the background sync implementation. The `workmanager` package (v0.9.0+3) runs callbacks in a *separate FlutterEngine*, not just a separate Dart isolate. This means `shareAcrossIsolates: true` (already configured in this project's `_openConnection()`) will NOT synchronize stream queries between the foreground app and background task. However, since background sync only writes to the database and doesn't need stream synchronization, this is acceptable -- the foreground Drift streams will detect changes when the app resumes. The background callback must independently initialize Supabase and open a new database connection. SQLite's WAL mode (default in Drift) handles concurrent access safely.

A critical gap in the current codebase: non-retryable `SyncError` types (`AuthSyncError`, `ValidationSyncError`, `ConflictSyncError`) call `markAsFailed()` without incrementing `retryCount`, meaning these items are re-processed every sync cycle since `getRetryableItems(maxRetries: 5)` only filters on `retryCount`. This phase must add explicit dead letter status handling to prevent infinite reprocessing of permanently failed items.

**Primary recommendation:** Add a `status` column to `sync_queue_items` (migration v12) for explicit lifecycle tracking (`pending`/`failed`/`dead_letter`), implement the `workmanager` package with a top-level callback that independently initializes Supabase + Drift, and evolve the existing `SyncQueueScreen` into a production-ready dead letter UI with Indonesian language.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Dead letter UI evolves the existing debug `SyncQueueScreen` (not a separate screen)
- Keep full queue view but default to showing failed/dead letter items prominently
- UI language in Indonesian matching existing app conventions
- Empty state: "Semua data tersinkronisasi" with checkmark icon (already exists)
- Show user-friendly translated error reasons per failed item (not raw exception text)
- Discard action: keep local data but clear isPendingSync (entity exists locally only, never synced)
- WorkManager (Android) / BGTaskScheduler (iOS) for background sync
- Toggle in Settings to enable/disable background sync
- 5 retry attempts as dead letter threshold
- Pruning runs after each sync (completed items older than retention period)
- Dead letter items auto-expire after 30 days
- Settings "Sinkronisasi" row: red badge count when dead letter items exist
- Settings subtitle: "Terakhir sinkronisasi: X menit lalu" timestamp
- App bar sync indicator: persistent orange/red warning when dead letter items exist
- Tapping app bar warning navigates directly to dead letter screen

### Claude's Discretion
- Screen placement (inside Settings vs dedicated sync status screen)
- Detail level per failed item (minimal vs detailed)
- Available actions (retry + discard, or also edit-then-retry)
- Bulk "Retry All" vs per-item only
- How to handle discard for entities that should not exist without server confirmation
- Periodic vs connectivity-triggered scheduling
- Notification strategy for background sync results
- Completed item retention period before pruning
- Whether sync_conflicts audit table is pruned with same schedule
- Retry count reset behavior when user manually retries a dead letter item
- Non-retryable error categorization (immediate dead letter vs distinct "requires action" status)

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SYNC-06 | Sync queue is pruned periodically -- completed items older than 7 days are removed, dead items are surfaced | Queue pruning via `clearCompletedItems(olderThan)` method exists; needs enhancement with proper status-based filtering. Dead letter surfacing requires new `status` column + `watchDeadLetterCount()` stream |
| CONF-02 | User can view permanently failed sync items in a dead letter queue UI with retry and discard options | Existing `SyncQueueScreen` provides foundation (card UI, status badges, retry button). Needs discard button, error translation, production polish, and status-based filtering |
| CONF-04 | Background sync persists across app restarts via workmanager (Android WorkManager, iOS BGTaskScheduler) | `workmanager` v0.9.0+3 package provides unified API. Requires top-level callback, independent Supabase+Drift init, periodic task with 15min minimum, network constraint |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| workmanager | ^0.9.0+3 | Background task scheduling (Android WorkManager + iOS BGTaskScheduler) | Only maintained Flutter package for platform-native background task scheduling. Federated architecture (workmanager_android, workmanager_apple). MIT licensed, Flutter Community maintained |
| drift | 2.22.1 (existing) | Local SQLite database with schema migration for new `status` column | Already in use. WAL mode handles concurrent access from foreground + background FlutterEngines |
| drift_flutter | 0.2.4 (existing) | Cross-platform database connection with `shareAcrossIsolates` | Already configured. Works within same FlutterEngine; background task opens independent connection |
| supabase_flutter | 2.8.3 (existing) | Remote data operations in background sync callback | Already in use. Must be independently initialized in background FlutterEngine |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| connectivity_plus | 6.1.1 (existing) | Network state awareness for background sync guard | Check connectivity before attempting sync in background task |
| flutter_dotenv | 5.2.1 (existing) | Load env vars for Supabase init in background task | Background callback needs SUPABASE_URL and SUPABASE_ANON_KEY |
| shared_preferences | (add if needed) | Persist background sync toggle setting | Only if AppSettingsService (Drift-based) is too heavy for background init |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| workmanager | flutter_background_service | flutter_background_service keeps a persistent foreground service (always running), drains battery. workmanager uses platform-native scheduling which is battery-friendly and OS-managed |
| workmanager | Manual AlarmManager/BGTaskScheduler via platform channels | Massive implementation effort, no cross-platform abstraction. workmanager does this out of the box |
| Adding `status` column | Deriving status from retryCount + lastError | Current approach has a bug: non-retryable errors get reprocessed every sync. Explicit status column is cleaner and enables dead letter queries |

**Installation:**
```bash
flutter pub add workmanager
```

## Architecture Patterns

### Background Sync Architecture

```
Foreground (main FlutterEngine)                Background (workmanager FlutterEngine)
================================                ==========================================
main.dart                                       callbackDispatcher (top-level function)
  |                                               |
  +-- Supabase.initialize()                       +-- dotenv.load()
  +-- AppDatabase (shareAcrossIsolates)            +-- Supabase.initialize() (independent)
  +-- SyncService                                  +-- AppDatabase() (independent connection)
  +-- SyncNotifier (push + pull)                   +-- SyncService (push only, no pull)
  +-- Workmanager().initialize()                   +-- processQueue()
  +-- registerPeriodicTask()                       +-- pruneQueue()
                                                   +-- return Future.value(true/false)
```

**Key insight:** The background FlutterEngine is a completely separate Dart runtime. It has no access to Riverpod providers, the foreground's Supabase client, or the foreground's database instance. Everything must be re-initialized from scratch in the `callbackDispatcher`.

### Recommended File Structure for Phase 5 Changes

```
lib/
├── data/
│   ├── database/
│   │   └── app_database.dart           # Migration v12: add status column
│   ├── datasources/local/
│   │   └── sync_queue_local_data_source.dart  # New methods: dead letter queries, pruning
│   └── services/
│       ├── sync_service.dart           # Enhanced: status-based processing, pruning
│       └── background_sync_service.dart # NEW: workmanager init, callback, registration
├── core/
│   └── utils/
│       └── sync_error_translator.dart  # NEW: maps SyncError types to Indonesian messages
├── presentation/
│   ├── providers/
│   │   └── sync_providers.dart         # New: deadLetterCountProvider, lastSyncAtProvider
│   ├── screens/sync/
│   │   └── sync_queue_screen.dart      # EVOLVE: production dead letter UI
│   └── widgets/
│       ├── shell/
│       │   └── responsive_shell.dart   # MODIFY: dead letter warning in app bar
│       └── common/
│           └── sync_status_badge.dart  # MODIFY: add deadLetter status
```

### Pattern 1: Database Schema Migration for Status Column

**What:** Add explicit `status` column to `sync_queue_items` table to replace derived status logic
**When to use:** Migration v12
**Example:**
```dart
// In app_database.dart onUpgrade:
if (from < 12) {
  // Add status column with default 'pending'
  await m.addColumn(syncQueueItems, syncQueueItems.status);

  // Backfill existing items based on current retryCount/lastError
  await customStatement(
    "UPDATE sync_queue SET status = CASE "
    "WHEN retry_count >= 5 THEN 'dead_letter' "
    "WHEN last_error IS NOT NULL THEN 'failed' "
    "ELSE 'pending' "
    "END"
  );
}
```

### Pattern 2: Top-Level Background Sync Callback

**What:** The `callbackDispatcher` must be a top-level (non-class) function annotated with `@pragma('vm:entry-point')`
**When to use:** Required by workmanager package
**Example:**
```dart
// lib/data/services/background_sync_service.dart

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Load environment
      await dotenv.load(fileName: '.env');

      // 2. Initialize Supabase independently
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );

      // 3. Open database independently (not shared with foreground)
      final db = AppDatabase();

      // 4. Create sync service with fresh dependencies
      final syncQueueDs = SyncQueueLocalDataSource(db);
      final connectivityService = ConnectivityService(
        supabaseClient: Supabase.instance.client,
      );
      await connectivityService.initialize();

      final syncService = SyncService(
        syncQueueDataSource: syncQueueDs,
        connectivityService: connectivityService,
        supabaseClient: Supabase.instance.client,
        database: db,
      );

      // 5. Process queue (push only - no pull in background)
      final result = await syncService.processQueue();

      // 6. Prune completed items
      await syncQueueDs.pruneCompletedItems(
        olderThan: Duration(days: 7),
      );

      // 7. Cleanup
      connectivityService.dispose();
      await db.close();

      return Future.value(result.success);
    } catch (e) {
      return Future.value(false); // Tells WorkManager to retry
    }
  });
}
```

### Pattern 3: Error Message Translation

**What:** Map `SyncError` subtypes to user-friendly Indonesian messages
**When to use:** Displaying error reasons in the dead letter UI
**Example:**
```dart
// lib/core/utils/sync_error_translator.dart

class SyncErrorTranslator {
  static String translate(String? rawError) {
    if (rawError == null) return 'Kesalahan tidak diketahui';

    if (rawError.contains('Authentication failed')) {
      return 'Sesi login kedaluwarsa. Silakan login ulang.';
    }
    if (rawError.contains('Validation error')) {
      return 'Data tidak valid. Periksa dan coba lagi.';
    }
    if (rawError.contains('Network unreachable')) {
      return 'Tidak ada koneksi internet.';
    }
    if (rawError.contains('Request timed out')) {
      return 'Server tidak merespons. Coba lagi nanti.';
    }
    if (rawError.contains('Conflict')) {
      return 'Data konflik dengan server. Versi server lebih baru.';
    }
    if (rawError.contains('Server error')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }

    return 'Gagal sinkronisasi: $rawError';
  }
}
```

### Pattern 4: Discard Action for Dead Letter Items

**What:** When user discards a dead letter item, keep local data but clear sync status
**When to use:** User acknowledges the item cannot be synced and wants to continue
**Example:**
```dart
Future<void> discardDeadLetterItem(SyncQueueItem item) async {
  // 1. Remove from sync queue
  await syncQueueDataSource.removeOperation(item.entityType, item.entityId);

  // 2. Clear isPendingSync on the entity so it shows as "local only"
  //    but DON'T delete the entity from local DB
  await _markEntityAsLocalOnly(item.entityType, item.entityId);
}

Future<void> _markEntityAsLocalOnly(String entityType, String entityId) async {
  // Set isPendingSync = false, lastSyncAt = null (never synced)
  switch (entityType) {
    case 'customer':
      await (database.update(database.customers)
            ..where((c) => c.id.equals(entityId)))
          .write(const CustomersCompanion(
            isPendingSync: Value(false),
            lastSyncAt: Value(null),  // null indicates never synced
          ));
    // ... other entity types
  }
}
```

### Anti-Patterns to Avoid

- **Sharing Riverpod ProviderContainer with background FlutterEngine:** The background callback runs in a completely separate Dart runtime. Do NOT attempt to use `ref.read()` or pass providers. Create all dependencies manually.
- **Running pull sync in background:** Background tasks should be fast and minimal. Running the full bidirectional sync (push + pull across 10+ tables) risks exceeding iOS's 30-second background execution limit. Push only in background; pull happens when app returns to foreground.
- **Using Timer.periodic for background sync in main.dart:** The existing 5-minute Timer in `SyncService.startBackgroundSync()` only works while the app process is alive. WorkManager survives process death, which is the whole point.
- **Storing background sync toggle in AppSettingsService (Drift):** The background callback needs to check this setting, which means opening the database. Consider using `shared_preferences` for this single toggle since it's lighter weight for background init, OR just always run the background task but skip processing if the toggle is off (read from DB after opening it).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Platform-native background scheduling | Custom AlarmManager/BGTaskScheduler platform channels | `workmanager` package | Handles OS version differences, battery optimization APIs, task constraints, and retry policies across Android/iOS |
| Error message localization | Inline if/else in widget code | Centralized `SyncErrorTranslator` utility | Error messages need consistent Indonesian translations; centralizing prevents duplication and makes maintenance easier |
| Queue status tracking | Derive status from retryCount + lastError | Explicit `status` column in database | Current derived approach has a bug with non-retryable errors. Explicit column enables proper dead letter queries and prevents infinite reprocessing |
| Badge count reactivity | Manual count tracking with setState | Drift `.watch()` stream + StreamProvider | Follows existing pattern (`pendingSyncCountProvider`, `conflictCountProvider`). Drift automatically emits when rows change |

**Key insight:** The existing codebase already has the right patterns for reactive UI (StreamProviders watching Drift streams). The new `deadLetterCountProvider` should follow the same pattern as `pendingSyncCountProvider`.

## Common Pitfalls

### Pitfall 1: Background Task Exceeding iOS Time Limit
**What goes wrong:** iOS BGTaskScheduler gives background tasks approximately 30 seconds of execution time. If the sync processes too many items or does a full bidirectional sync, the task gets terminated.
**Why it happens:** iOS aggressively manages background execution to preserve battery.
**How to avoid:** Only process sync queue items (push) in background tasks. Skip the pull phase. Limit items processed per batch (e.g., max 10 items). Return early if running low on time.
**Warning signs:** Background tasks returning `false` (rescheduled) frequently, or tasks silently not completing.

### Pitfall 2: Database Migration Running in Background FlutterEngine
**What goes wrong:** If both the foreground app and background task try to run a database migration simultaneously, data corruption or crashes can occur.
**Why it happens:** The background FlutterEngine opens an independent database connection and may trigger migration v12.
**How to avoid:** Check `schemaVersion` in the background callback and skip sync if migration is needed. Only the foreground app should run migrations. Alternatively, use a file-based lock or check a `migration_completed` key in `app_settings` before proceeding.
**Warning signs:** Crash reports from background task with migration-related errors.

### Pitfall 3: Non-Retryable Errors Stuck in Retry Loop
**What goes wrong:** Currently, `AuthSyncError` and `ValidationSyncError` (non-retryable) call `markAsFailed()` but don't increment `retryCount`. Since `getRetryableItems(maxRetries: 5)` only checks `retryCount < 5`, these items are reprocessed every sync cycle.
**Why it happens:** The original code assumed all failed items would eventually exhaust retries, but non-retryable errors intentionally skip retry count increment.
**How to avoid:** Add explicit `status` column. When a non-retryable `SyncError` is caught, set `status = 'dead_letter'` immediately instead of just calling `markAsFailed()`. Update `getRetryableItems()` to filter `WHERE status = 'pending'`.
**Warning signs:** Items with `retryCount = 0` but `lastError IS NOT NULL` appearing repeatedly in sync logs.

### Pitfall 4: Supabase Auth Token Expired in Background Task
**What goes wrong:** The background FlutterEngine initializes Supabase with the anon key, but the user's auth session (JWT) may have expired. API calls fail with 401.
**Why it happens:** Background tasks run at arbitrary times, potentially hours after the user last opened the app. The JWT refresh token stored in secure storage may not be accessible from the background FlutterEngine, or the session may have truly expired.
**How to avoid:** In the background callback, check if Supabase has a valid session. If not, skip sync and return `true` (don't retry -- user needs to open the app and re-authenticate). Log the auth failure for the dead letter UI to show.
**Warning signs:** All queue items failing with `AuthSyncError` during background sync, accumulating dead letters.

### Pitfall 5: Queue Pruning Deleting Active Items
**What goes wrong:** Pruning logic deletes items older than N days, accidentally removing items that are still pending but were queued a long time ago (e.g., during extended offline period).
**Why it happens:** Pruning only checks `createdAt` without considering item status.
**How to avoid:** Only prune items with `status = 'completed'` (which doesn't exist yet -- completed items are deleted immediately). For dead letter pruning (30-day auto-expire), only prune items with `status = 'dead_letter'` and `lastAttemptAt` older than 30 days.
**Warning signs:** Users reporting data loss -- items they created offline disappearing without being synced.

### Pitfall 6: WorkManager Registration Called Multiple Times
**What goes wrong:** `registerPeriodicTask` called on every app launch creates duplicate registrations.
**Why it happens:** The task is registered in `main.dart` or during app initialization, which runs every time the app opens.
**How to avoid:** Use `ExistingPeriodicWorkPolicy.update` to replace existing registration rather than creating duplicates. The `workmanager` package supports this via the `existingWorkPolicy` parameter.
**Warning signs:** Background sync running more frequently than expected, excessive battery drain.

## Code Examples

### Workmanager Initialization in main.dart

```dart
// In main.dart or app initialization:
import 'package:workmanager/workmanager.dart';
import 'data/services/background_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing init ...

  // Initialize workmanager with the top-level callback
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: !kReleaseMode,
  );
}
```

### Periodic Task Registration (after login/sync setup)

```dart
// Register periodic background sync (minimum 15 minutes)
await Workmanager().registerPeriodicTask(
  'leadx-background-sync',        // uniqueName
  'backgroundSync',               // taskName (matched in callback)
  frequency: const Duration(minutes: 15),
  constraints: Constraints(
    networkType: NetworkType.connected,  // Only run with network
    requiresBatteryNotLow: true,        // Don't drain low battery
  ),
  existingWorkPolicy: ExistingPeriodicWorkPolicy.update,  // Replace existing
  backoffPolicy: BackoffPolicy.exponential,
  backoffPolicyDelay: const Duration(minutes: 1),
);
```

### iOS Info.plist Configuration

```xml
<!-- In ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>com.askrindo.leadx_crm.backgroundSync</string>
</array>
```

### iOS AppDelegate.swift Configuration

```swift
// In ios/Runner/AppDelegate.swift
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register background task identifier for workmanager
    WorkmanagerPlugin.registerTask(
      withIdentifier: "com.askrindo.leadx_crm.backgroundSync"
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Dead Letter Count Stream Provider

```dart
// In sync_providers.dart
final deadLetterCountProvider = StreamProvider<int>((ref) {
  final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
  return syncQueueDataSource.watchDeadLetterCount();
});

final lastSyncAtProvider = FutureProvider<DateTime?>((ref) {
  final appSettings = ref.watch(appSettingsServiceProvider);
  return appSettings.getLastSyncAt();
});
```

### Dead Letter Query in Local Data Source

```dart
// In sync_queue_local_data_source.dart

/// Watch count of dead letter items.
Stream<int> watchDeadLetterCount() {
  return (_db.selectOnly(_db.syncQueueItems)
        ..addColumns([_db.syncQueueItems.id.count()])
        ..where(_db.syncQueueItems.status.equals('dead_letter')))
      .map((row) => row.read(_db.syncQueueItems.id.count()) ?? 0)
      .watchSingle();
}

/// Get dead letter items for UI display.
Future<List<SyncQueueItem>> getDeadLetterItems() async {
  return (_db.select(_db.syncQueueItems)
        ..where((t) => t.status.equals('dead_letter'))
        ..orderBy([(t) => OrderingTerm.desc(t.lastAttemptAt)]))
      .get();
}

/// Prune completed items older than retention period.
Future<int> pruneCompletedItems({required Duration olderThan}) async {
  final cutoff = DateTime.now().subtract(olderThan);
  // Note: completed items are currently deleted immediately in markAsCompleted().
  // This prune targets any orphaned items and dead letters past expiry.
  return (_db.delete(_db.syncQueueItems)
        ..where((t) =>
            t.status.equals('dead_letter') &
            t.lastAttemptAt.isSmallerThanValue(
              cutoff.subtract(const Duration(days: 30)),
            )))
      .go();
}
```

### Enhanced SyncQueueScreen Status Badge (Indonesian)

```dart
// Status badge with Indonesian labels
String _statusLabel(String status) => switch (status) {
  'pending' => 'MENUNGGU',
  'failed' => 'GAGAL',
  'dead_letter' => 'GAGAL PERMANEN',
  _ => status.toUpperCase(),
};
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Timer.periodic for background sync | workmanager with platform-native scheduling | workmanager has existed since 2019, but v0.9.0 (2025) is the modern federated version | Survives app/process termination, battery-optimized, OS-managed scheduling |
| Derive status from retryCount + lastError | Explicit status column in sync queue table | Best practice for queue management | Enables proper dead letter queries, prevents non-retryable error reprocessing bug |
| Delete completed items immediately | Retain for audit trail, prune periodically | Common pattern in production sync systems | Enables sync health monitoring and debugging |
| workmanager v1 embedding (pre-0.6.0) | workmanager v0.9.0+ federated architecture | v0.6.0 removed V1 embedding, v0.9.0 federated | Compatible with Flutter 3.29+, fixes breaking changes |

**Deprecated/outdated:**
- `performFetchWithCompletionHandler` (iOS): Replaced by BGTaskScheduler. Adding BGTaskSchedulerPermittedIdentifiers to Info.plist disables the old API.
- workmanager versions < 0.6.0: Incompatible with Flutter 3.29+ due to V1 embedding removal.

## Discretion Recommendations

Based on research, here are recommendations for areas left to Claude's discretion:

### Screen Placement
**Recommend:** Keep the sync screen at its existing route `/home/sync-queue` accessible from Settings > Sinkronisasi. No need for a separate screen -- evolve in place.

### Detail Level per Failed Item
**Recommend:** Medium detail -- show entity type (translated: "Pelanggan", "Pipeline", "Aktivitas"), operation (translated: "Buat", "Ubah", "Hapus"), translated error message, and timestamp. Hide entity ID behind an expandable section for power users.

### Available Actions
**Recommend:** Retry + Discard only. Edit-then-retry is too complex -- users would need to know which field caused the validation error and have UI to edit a sync payload. That's far beyond scope.

### Bulk "Retry All"
**Recommend:** Include both "Coba Ulang Semua" bulk button and per-item retry. Bulk retry is important when dead letters accumulate from transient auth issues that are resolved by re-login.

### Discard for Entities Without Server Confirmation
**Recommend:** Show a confirmation dialog explaining the entity will exist only locally and not be visible to other users or the server. For `create` operations, warn that the item was never synced. For `update` operations, explain the server will keep the old version.

### Periodic vs Connectivity-Triggered
**Recommend:** Periodic scheduling (15-minute minimum enforced by both platforms). Connectivity-triggered is handled by the existing foreground `ConnectivityService` listener + `triggerSync()`. WorkManager's `NetworkType.connected` constraint already ensures the periodic task only runs when connected.

### Notification Strategy
**Recommend:** Silent. No notifications for background sync. The app bar indicator and Settings badge provide awareness when the user opens the app. Push notifications for sync results would be noisy and annoying.

### Completed Item Retention Period
**Recommend:** 7 days, matching the success criteria in the phase description. Completed items are already deleted immediately on success, so this primarily affects any future change to retain completed items for audit.

### sync_conflicts Table Pruning
**Recommend:** Yes, prune sync_conflicts older than 30 days on the same schedule. The existing `watchRecentConflictCount(days: 7)` already only shows recent conflicts, so old data serves no purpose.

### Retry Count Reset on Manual Retry
**Recommend:** Reset `retryCount` to 0 AND change `status` back to `pending`. This gives the item a fresh 5-attempt cycle. The existing `resetRetryCount()` method already resets count and clears error.

### Non-Retryable Error Categorization
**Recommend:** Immediate dead letter for `AuthSyncError` and `ValidationSyncError`. These require user intervention (re-login or data correction). `ConflictSyncError` should also be immediate dead letter since the existing LWW resolution handles it internally -- if a ConflictSyncError reaches the queue, it means resolution itself failed.

## Open Questions

1. **Supabase Session in Background FlutterEngine**
   - What we know: Background tasks create a new Supabase instance. The anon key is available via dotenv. Auth tokens are stored in flutter_secure_storage.
   - What's unclear: Whether `supabase_flutter` automatically restores the session from secure storage when initialized in a background FlutterEngine. If not, all API calls will fail with 401.
   - Recommendation: Test this during implementation. If session restoration doesn't work in background, the callback should detect the auth failure and gracefully skip sync (returning `true` to avoid retries). The foreground app will handle sync when user returns.

2. **WorkManager Task Registration Timing**
   - What we know: Tasks must be registered after `Workmanager().initialize()`. The toggle in Settings should control registration.
   - What's unclear: Whether to register during app init (and cancel if toggle is off) or only register when toggle is enabled. Also, what happens to an already-registered task when the user disables the toggle.
   - Recommendation: Always register during init. Check the toggle setting inside the callback and skip processing if disabled. This avoids the complexity of register/cancel lifecycle. Use `Workmanager().cancelByUniqueName()` only when user explicitly disables.

3. **Android minSdk for WorkManager**
   - What we know: The project uses `flutter.minSdkVersion` (likely 21). WorkManager supports API 14+.
   - What's unclear: Whether the project's minSdk is high enough. Very likely yes, but should be verified.
   - Recommendation: Verify during implementation. WorkManager's minimum API is well below any modern Flutter app.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `sync_queue.dart`, `sync_queue_local_data_source.dart`, `sync_service.dart`, `sync_models.dart`, `sync_errors.dart`, `sync_providers.dart`, `sync_queue_screen.dart`, `responsive_shell.dart`, `settings_screen.dart`, `connectivity_service.dart`, `app_settings_service.dart`, `app_database.dart`
- [workmanager pub.dev](https://pub.dev/packages/workmanager) - v0.9.0+3, API reference, Constraints class
- [workmanager API docs](https://pub.dev/documentation/workmanager/latest/workmanager/Workmanager-class.html) - Method signatures for initialize, registerPeriodicTask, registerOneOffTask
- [Drift isolates documentation](https://drift.simonbinder.eu/isolates/) - shareAcrossIsolates behavior
- [Drift GitHub Discussion #3249](https://github.com/simolus3/drift/discussions/3249) - Database access from background isolate in WorkManager
- [Drift GitHub Issue #637](https://github.com/simolus3/drift/issues/637) - Drift (Moor) with WorkManager concurrent access

### Secondary (MEDIUM confidence)
- [workmanager changelog](https://pub.dev/packages/workmanager/changelog) - Version history, V1 embedding removal in 0.6.0, federated architecture in 0.9.0
- [workmanager GitHub](https://github.com/fluttercommunity/flutter_workmanager) - Repository structure, example app patterns
- [GitHub Issue #588](https://github.com/fluttercommunity/flutter_workmanager/issues/588) - Flutter 3.29+ compatibility (resolved in 0.6.0+)
- [GitHub Issue #105](https://github.com/fluttercommunity/flutter_workmanager/issues/105) - iOS BGTaskSchedulerPermittedIdentifiers setup requirements

### Tertiary (LOW confidence)
- Web articles about workmanager usage patterns (multiple Medium posts, vibe-studio.ai articles) - Used for cross-verification only
- iOS BGTaskScheduler 30-second time limit - Based on Apple platform documentation via secondary sources. Needs validation during implementation.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - workmanager is the only viable package; Drift/Supabase already in codebase
- Architecture: HIGH - Background FlutterEngine isolation pattern is well-documented in Drift and workmanager ecosystems
- Dead letter UI: HIGH - Existing SyncQueueScreen code provides clear foundation; requirements are well-defined
- Pitfalls: HIGH - Identified from direct codebase analysis (non-retryable error bug) and official documentation (FlutterEngine isolation, iOS time limits)
- Background sync auth: MEDIUM - Supabase session restoration in background FlutterEngine needs implementation-time validation

**Research date:** 2026-02-18
**Valid until:** 2026-03-18 (30 days - stable domain, established packages)
