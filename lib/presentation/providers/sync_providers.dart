import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/customer_local_data_source.dart';
import '../../data/datasources/local/key_person_local_data_source.dart';
import '../../data/datasources/local/pipeline_local_data_source.dart';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../data/datasources/remote/customer_remote_data_source.dart';
import '../../data/datasources/remote/pipeline_remote_data_source.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/pipeline_repository_impl.dart';
import '../../data/services/app_settings_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/initial_sync_service.dart';
import '../../data/services/sync_service.dart';
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/pipeline_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'master_data_providers.dart';

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
  final database = ref.watch(databaseProvider);

  final service = SyncService(
    syncQueueDataSource: syncQueueDataSource,
    connectivityService: connectivityService,
    supabaseClient: supabase,
    database: database,
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

/// Notifier for triggering bidirectional sync operations.
/// Performs push (local → remote) then pull (remote → local).
class SyncNotifier extends StateNotifier<AsyncValue<SyncResult?>> {
  SyncNotifier(
    this._syncService,
    this._customerRepository,
    this._pipelineRepository,
    this._connectivityService,
  ) : super(const AsyncValue.data(null));

  final SyncService _syncService;
  final CustomerRepository _customerRepository;
  final PipelineRepository _pipelineRepository;
  final ConnectivityService _connectivityService;

  /// Trigger a bidirectional sync: push pending changes, then pull new data.
  Future<void> triggerSync() async {
    if (!_connectivityService.isConnected) {
      state = AsyncValue.error('Device is offline', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Step 1: Push - upload local changes to Supabase
      print('[SyncNotifier] Starting push sync...');
      final pushResult = await _syncService.triggerSync();
      print('[SyncNotifier] Push sync complete: ${pushResult.successCount} uploaded');

      // Step 2: Pull - download changes from Supabase
      print('[SyncNotifier] Starting pull sync...');
      await _pullFromRemote();
      print('[SyncNotifier] Pull sync complete');

      state = AsyncValue.data(pushResult);
    } catch (e, st) {
      print('[SyncNotifier] Sync error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Pull data from Supabase to local database.
  Future<void> _pullFromRemote() async {
    // Pull customers
    try {
      final customerResult = await _customerRepository.syncFromRemote();
      customerResult.fold(
        (failure) => print('[SyncNotifier] Customer pull failed: ${failure.message}'),
        (count) => print('[SyncNotifier] Pulled $count customers'),
      );
    } catch (e) {
      print('[SyncNotifier] Customer pull error: $e');
    }

    // Pull key persons
    try {
      final keyPersonResult = await _customerRepository.syncKeyPersonsFromRemote();
      keyPersonResult.fold(
        (failure) => print('[SyncNotifier] Key person pull failed: ${failure.message}'),
        (count) => print('[SyncNotifier] Pulled $count key persons'),
      );
    } catch (e) {
      print('[SyncNotifier] Key person pull error: $e');
    }

    // Pull pipelines
    try {
      await _pipelineRepository.syncFromRemote();
    } catch (e) {
      print('[SyncNotifier] Pipeline pull error: $e');
    }
  }

  /// Check if sync is currently in progress.
  bool get isSyncing => _syncService.isSyncing;

  /// Get the current sync state.
  SyncState get currentState => _syncService.currentState;
}

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

/// Provider for the sync notifier with bidirectional sync support.
/// Note: Uses late imports to avoid circular dependencies.
final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, AsyncValue<SyncResult?>>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  // Import repositories lazily to avoid circular dependencies
  // These are defined in customer_providers.dart and pipeline_providers.dart
  final customerRepository = ref.watch(_customerRepositoryProvider);
  final pipelineRepository = ref.watch(_pipelineRepositoryProvider);
  
  return SyncNotifier(
    syncService,
    customerRepository,
    pipelineRepository,
    connectivityService,
  );
});

/// Late-bound provider for customer repository to avoid circular imports.
final _customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  // Lazy import to get the actual implementation
  final localDataSource = ref.watch(_customerLocalDataSourceProvider);
  final keyPersonLocalDataSource = ref.watch(_keyPersonLocalDataSourceProvider);
  final remoteDataSource = ref.watch(_customerRemoteDataSourceProvider);
  final keyPersonRemoteDataSource = ref.watch(_keyPersonRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  
  return CustomerRepositoryImpl(
    localDataSource: localDataSource,
    keyPersonLocalDataSource: keyPersonLocalDataSource,
    remoteDataSource: remoteDataSource,
    keyPersonRemoteDataSource: keyPersonRemoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
  );
});

/// Late-bound provider for pipeline repository to avoid circular imports.
final _pipelineRepositoryProvider = Provider<PipelineRepository>((ref) {
  final localDataSource = ref.watch(_pipelineLocalDataSourceProvider);
  final masterDataSource = ref.watch(masterDataLocalDataSourceProvider);
  final remoteDataSource = ref.watch(_pipelineRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  
  return PipelineRepositoryImpl(
    localDataSource: localDataSource,
    masterDataSource: masterDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
  );
});

// Local data source providers (duplicated here to avoid circular imports)
final _customerLocalDataSourceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerLocalDataSource(db);
});

final _keyPersonLocalDataSourceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return KeyPersonLocalDataSource(db);
});

final _customerRemoteDataSourceProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CustomerRemoteDataSource(supabase);
});

final _keyPersonRemoteDataSourceProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return KeyPersonRemoteDataSource(supabase);
});

final _pipelineLocalDataSourceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return PipelineLocalDataSource(db);
});

final _pipelineRemoteDataSourceProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PipelineRemoteDataSource(supabase);
});
