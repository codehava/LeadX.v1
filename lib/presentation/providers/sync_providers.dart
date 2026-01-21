import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/master_data_local_data_source.dart';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../data/services/app_settings_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/initial_sync_service.dart';
import '../../data/services/sync_service.dart';
import '../../domain/entities/sync_models.dart';
import 'auth_providers.dart';
import 'database_provider.dart';

/// Provider for app settings service.
final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  final db = ref.watch(databaseProvider);
  return AppSettingsService(db);
});

/// Provider for the connectivity service.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final service = ConnectivityService(supabaseClient: supabase);
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for the sync queue data source.
final syncQueueDataSourceProvider = Provider<SyncQueueLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncQueueLocalDataSource(db);
});

/// Provider for the sync service.
final syncServiceProvider = Provider<SyncService>((ref) {
  final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);

  final service = SyncService(
    syncQueueDataSource: syncQueueDataSource,
    connectivityService: connectivityService,
    supabaseClient: supabase,
  );

  ref.onDispose(service.dispose);
  return service;
});

/// Provider for the current sync state stream.
final syncStateStreamProvider = StreamProvider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStateStream;
});

/// Provider for the count of pending sync items.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.watchPendingCount();
});

/// Provider for the current connectivity status.
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isConnected;
});

/// Provider for watching connectivity changes.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

/// Initialize sync-related services.
Future<void> initializeSyncServices(ProviderContainer container) async {
  final connectivityService = container.read(connectivityServiceProvider);
  await connectivityService.initialize();

  final syncService = container.read(syncServiceProvider);
  syncService.startBackgroundSync();
}

/// Notifier for triggering sync operations.
class SyncNotifier extends StateNotifier<AsyncValue<SyncResult?>> {
  SyncNotifier(this._syncService) : super(const AsyncValue.data(null));

  final SyncService _syncService;

  /// Trigger a manual sync.
  Future<void> triggerSync() async {
    state = const AsyncValue.loading();
    try {
      final result = await _syncService.triggerSync();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Check if sync is currently in progress.
  bool get isSyncing => _syncService.isSyncing;

  /// Get the current sync state.
  SyncState get currentState => _syncService.currentState;
}

/// Provider for the sync notifier.
final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, AsyncValue<SyncResult?>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});

/// Provider for the master data local data source.
final masterDataLocalDataSourceProvider = Provider<MasterDataLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return MasterDataLocalDataSource(db);
});

/// Provider for the initial sync service.
final initialSyncServiceProvider = Provider<InitialSyncService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final db = ref.watch(databaseProvider);
  final masterDataSource = ref.watch(masterDataLocalDataSourceProvider);
  final appSettings = ref.watch(appSettingsServiceProvider);

  final service = InitialSyncService(
    supabaseClient: supabase,
    database: db,
    masterDataSource: masterDataSource,
    appSettingsService: appSettings,
  );

  ref.onDispose(service.dispose);
  return service;
});

/// Provider for current sync state (for UI).
final syncStateProvider = StreamProvider<SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStateStream;
});
