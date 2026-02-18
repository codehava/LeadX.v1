import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';
import '../datasources/local/sync_queue_local_data_source.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';

/// Unique task name for WorkManager registration.
const _backgroundSyncTaskName = 'leadx-background-sync';
const _backgroundSyncTaskTag = 'backgroundSync';

/// Top-level callback for WorkManager.
/// MUST be a top-level function (not a class method) because it runs
/// in a separate FlutterEngine with no access to the foreground app's state.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Skip on web -- WorkManager is mobile-only
    if (kIsWeb) return true;

    try {
      // 1. Load environment variables
      await dotenv.load(fileName: '.env');

      // 2. Initialize Supabase independently (separate FlutterEngine)
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );

      // 3. Check if we have a valid auth session
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        // No auth session available -- user needs to open app and login.
        // Return true (success) so WorkManager doesn't retry immediately.
        return true;
      }

      // 4. Open database independently (not shared with foreground)
      // Do NOT run migrations from background -- if schema is outdated,
      // skip and let the foreground handle migration on next app open.
      final db = AppDatabase();

      try {
        // 5. Check if background sync is enabled by user
        final setting = await (db.select(db.appSettings)
              ..where((t) => t.key.equals('background_sync_enabled')))
            .getSingleOrNull();
        if (setting?.value == 'false') {
          await db.close();
          return true; // Skip -- disabled by user
        }

        // 6. Create minimal dependencies for sync
        final syncQueueDs = SyncQueueLocalDataSource(db);
        final connectivityService = ConnectivityService(
          supabaseClient: Supabase.instance.client,
        );
        await connectivityService.initialize();

        // Check connectivity before proceeding
        if (!connectivityService.isConnected) {
          connectivityService.dispose();
          await db.close();
          return true; // Don't retry -- will run again on next periodic schedule
        }

        final syncService = SyncService(
          syncQueueDataSource: syncQueueDs,
          connectivityService: connectivityService,
          supabaseClient: Supabase.instance.client,
          database: db,
        );

        // 7. Process queue (PUSH ONLY -- no pull in background)
        // Push is fast and bounded by queue size.
        // Pull involves 10+ tables and risks exceeding iOS 30-second limit.
        await syncService.processQueue();

        // 8. Cleanup
        connectivityService.dispose();
        syncService.dispose();
      } finally {
        await db.close();
      }

      return true; // Success
    } catch (e) {
      // Return true so WorkManager doesn't retry aggressively.
      // The periodic schedule will try again on the next interval.
      return true;
    }
  });
}

/// Service for managing background sync registration.
class BackgroundSyncService {
  /// Initialize WorkManager with the callback dispatcher.
  /// Call once during app startup.
  static Future<void> initialize() async {
    if (kIsWeb) return; // WorkManager is mobile-only

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: !kReleaseMode,
    );
  }

  /// Register periodic background sync task.
  /// Minimum interval is 15 minutes (enforced by both Android and iOS).
  /// Uses ExistingPeriodicWorkPolicy.update to prevent duplicate registrations.
  static Future<void> registerPeriodicSync() async {
    if (kIsWeb) return;

    await Workmanager().registerPeriodicTask(
      _backgroundSyncTaskName,
      _backgroundSyncTaskTag,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
  }

  /// Cancel background sync (when user disables the toggle).
  static Future<void> cancelPeriodicSync() async {
    if (kIsWeb) return;

    await Workmanager().cancelByUniqueName(_backgroundSyncTaskName);
  }
}
