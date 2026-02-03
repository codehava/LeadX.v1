import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/activity_local_data_source.dart';
import '../../data/datasources/local/customer_local_data_source.dart';
import '../../data/datasources/local/history_log_local_data_source.dart';
import '../../data/datasources/local/key_person_local_data_source.dart';
import '../../data/datasources/local/pipeline_local_data_source.dart';
import '../../data/datasources/local/sync_queue_local_data_source.dart';
import '../../data/datasources/remote/activity_remote_data_source.dart';
import '../../data/datasources/remote/customer_remote_data_source.dart';
import '../../data/datasources/remote/pipeline_remote_data_source.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/pipeline_repository_impl.dart';
import '../../data/services/app_settings_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/initial_sync_service.dart';
import '../../data/services/sync_service.dart';
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/repositories/broker_repository.dart';
import '../../domain/repositories/cadence_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/hvc_repository.dart';
import '../../domain/repositories/pipeline_repository.dart';
import '../../data/repositories/pipeline_referral_repository_impl.dart';
import '../../domain/repositories/pipeline_referral_repository.dart';
import 'auth_providers.dart';
import 'broker_providers.dart';
import 'cadence_providers.dart';
import 'database_provider.dart';
import 'hvc_providers.dart';
import 'master_data_providers.dart';
import 'pipeline_referral_providers.dart';

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
    this._ref,
    this._syncService,
    this._customerRepository,
    this._pipelineRepository,
    this._activityRepository,
    this._hvcRepository,
    this._brokerRepository,
    this._cadenceRepository,
    this._pipelineReferralRepository,
    this._connectivityService,
  ) : super(const AsyncValue.data(null));

  final Ref _ref;
  final SyncService _syncService;
  final CustomerRepository _customerRepository;
  final PipelineRepository _pipelineRepository;
  final ActivityRepository _activityRepository;
  final HvcRepository _hvcRepository;
  final BrokerRepository _brokerRepository;
  final CadenceRepository _cadenceRepository;
  final PipelineReferralRepository _pipelineReferralRepository;
  final ConnectivityService _connectivityService;

  /// Trigger a bidirectional sync: push pending changes, then pull new data.
  Future<void> triggerSync() async {
    // Ensure connectivity service is initialized (important for mobile)
    await _connectivityService.ensureInitialized();

    if (!_connectivityService.isConnected) {
      state = AsyncValue.error('Device is offline', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Step 1: Push - upload local changes to Supabase
      debugPrint('[SyncNotifier] Starting push sync...');
      final pushResult = await _syncService.triggerSync();
      debugPrint('[SyncNotifier] Push sync complete: ${pushResult.successCount} uploaded');

      // Step 2: Sync pending photos to Supabase Storage
      debugPrint('[SyncNotifier] Starting photo sync...');
      await _syncPhotos();
      debugPrint('[SyncNotifier] Photo sync complete');

      // Step 3: Sync pending audit logs (after activities are synced)
      debugPrint('[SyncNotifier] Starting audit log sync...');
      await _syncAuditLogs();
      debugPrint('[SyncNotifier] Audit log sync complete');

      // Step 4: Pull - download changes from Supabase
      debugPrint('[SyncNotifier] Starting pull sync...');
      await _pullFromRemote();
      debugPrint('[SyncNotifier] Pull sync complete');

      state = AsyncValue.data(pushResult);
    } catch (e, st) {
      debugPrint('[SyncNotifier] Sync error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Sync pending photos to Supabase Storage.
  Future<void> _syncPhotos() async {
    try {
      await _activityRepository.syncPendingPhotos();
    } catch (e) {
      debugPrint('[SyncNotifier] Photo sync error: $e');
    }
  }

  /// Sync pending audit logs to Supabase.
  Future<void> _syncAuditLogs() async {
    try {
      await _activityRepository.syncPendingAuditLogs();
    } catch (e) {
      debugPrint('[SyncNotifier] Audit log sync error: $e');
    }
  }

  /// Pull data from Supabase to local database.
  Future<void> _pullFromRemote() async {
    debugPrint('[SyncNotifier] Starting _pullFromRemote...');

    // Pull customers
    try {
      debugPrint('[SyncNotifier] Calling customerRepository.syncFromRemote...');
      final customerResult = await _customerRepository.syncFromRemote();
      customerResult.fold(
        (failure) => debugPrint('[SyncNotifier] Customer pull failed: ${failure.message}'),
        (count) => debugPrint('[SyncNotifier] Pulled $count customers'),
      );
    } catch (e, st) {
      debugPrint('[SyncNotifier] Customer pull error: $e');
      debugPrint('[SyncNotifier] Stack trace: $st');
    }

    // Pull key persons
    try {
      final keyPersonResult = await _customerRepository.syncKeyPersonsFromRemote();
      keyPersonResult.fold(
        (failure) => debugPrint('[SyncNotifier] Key person pull failed: ${failure.message}'),
        (count) => debugPrint('[SyncNotifier] Pulled $count key persons'),
      );
    } catch (e) {
      debugPrint('[SyncNotifier] Key person pull error: $e');
    }

    // Pull pipelines
    try {
      // Invalidate caches BEFORE sync to ensure fresh lookup values during mapping
      final pipelineRepo = _pipelineRepository;
      if (pipelineRepo is PipelineRepositoryImpl) {
        pipelineRepo.invalidateCaches();
      }
      await _pipelineRepository.syncFromRemote();
    } catch (e) {
      debugPrint('[SyncNotifier] Pipeline pull error: $e');
    }

    // Pull activities
    try {
      // Invalidate caches BEFORE sync to ensure fresh lookup values during mapping
      _activityRepository.invalidateCaches();
      await _activityRepository.syncFromRemote();

      // Sync activity photos from remote
      await _activityRepository.syncPhotosFromRemote();
    } catch (e) {
      debugPrint('[SyncNotifier] Activity pull error: $e');
    }

    // Pull HVCs
    try {
      final hvcResult = await _hvcRepository.syncFromRemote();
      hvcResult.fold(
        (failure) => debugPrint('[SyncNotifier] HVC pull failed: ${failure.message}'),
        (count) => debugPrint('[SyncNotifier] Pulled $count HVCs'),
      );
    } catch (e) {
      debugPrint('[SyncNotifier] HVC pull error: $e');
    }

    // Pull HVC-Customer links
    try {
      final hvcLinkResult = await _hvcRepository.syncLinksFromRemote();
      hvcLinkResult.fold(
        (failure) => debugPrint('[SyncNotifier] HVC link pull failed: ${failure.message}'),
        (count) => debugPrint('[SyncNotifier] Pulled $count HVC-Customer links'),
      );
    } catch (e) {
      debugPrint('[SyncNotifier] HVC link pull error: $e');
    }

    // Pull Brokers
    try {
      final brokerResult = await _brokerRepository.syncFromRemote();
      brokerResult.fold(
        (failure) => debugPrint('[SyncNotifier] Broker pull failed: ${failure.message}'),
        (count) => debugPrint('[SyncNotifier] Pulled $count brokers'),
      );
    } catch (e) {
      debugPrint('[SyncNotifier] Broker pull error: $e');
    }

    // Pull Cadence configs and meetings
    try {
      await _cadenceRepository.syncFromRemote();
      debugPrint('[SyncNotifier] Pulled cadence data');
    } catch (e) {
      debugPrint('[SyncNotifier] Cadence pull error: $e');
    }

    // Pull Pipeline Referrals
    try {
      // Invalidate caches BEFORE sync to ensure fresh lookup values during mapping
      _pipelineReferralRepository.invalidateCaches();
      await _pipelineReferralRepository.syncFromRemote();
      debugPrint('[SyncNotifier] Pulled pipeline referral data');
    } catch (e) {
      debugPrint('[SyncNotifier] Pipeline referral pull error: $e');
    }

    // Step 5: Invalidate all data providers to refresh UI
    await _invalidateDataProviders();
  }

  /// Refresh auth data after sync completion.
  /// Note: List/detail providers no longer need invalidation - Drift streams auto-update.
  Future<void> _invalidateDataProviders() async {
    debugPrint('[SyncNotifier] Refreshing auth data after sync...');

    // Refresh current user to pick up any profile changes from sync
    // This is the only invalidation needed - all other providers are StreamProviders
    // that automatically update when their underlying Drift tables change.
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.refreshCurrentUser();
      _ref.invalidate(currentUserProvider);
    } catch (e) {
      debugPrint('[SyncNotifier] Error refreshing current user: $e');
    }

    debugPrint('[SyncNotifier] Auth data refreshed');
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
  final customerRepository = ref.watch(_customerRepositoryProvider);
  final pipelineRepository = ref.watch(_pipelineRepositoryProvider);
  final activityRepository = ref.watch(_activityRepositoryProvider);
  final hvcRepository = ref.watch(hvcRepositoryProvider);
  final brokerRepository = ref.watch(brokerRepositoryProvider);
  final cadenceRepository = ref.watch(cadenceRepositoryProvider);
  final pipelineReferralRepository = ref.watch(_pipelineReferralRepositoryProvider);

  return SyncNotifier(
    ref,
    syncService,
    customerRepository,
    pipelineRepository,
    activityRepository,
    hvcRepository,
    brokerRepository,
    cadenceRepository,
    pipelineReferralRepository,
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
  final customerDataSource = ref.watch(_customerLocalDataSourceProvider);
  final remoteDataSource = ref.watch(_pipelineRemoteDataSourceProvider);
  final historyLogDataSource = ref.watch(_historyLogLocalDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final database = ref.watch(databaseProvider);

  return PipelineRepositoryImpl(
    localDataSource: localDataSource,
    masterDataSource: masterDataSource,
    customerDataSource: customerDataSource,
    remoteDataSource: remoteDataSource,
    historyLogDataSource: historyLogDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
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

final _historyLogLocalDataSourceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return HistoryLogLocalDataSource(db);
});

/// Late-bound provider for activity repository to avoid circular imports.
final _activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final localDataSource = ref.watch(_activityLocalDataSourceProvider);
  final remoteDataSource = ref.watch(_activityRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final database = ref.watch(databaseProvider);

  return ActivityRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
  );
});

final _activityLocalDataSourceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  return ActivityLocalDataSource(db);
});

final _activityRemoteDataSourceProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ActivityRemoteDataSource(supabase);
});

/// Late-bound provider for pipeline referral repository to avoid circular imports.
final _pipelineReferralRepositoryProvider = Provider<PipelineReferralRepository>((ref) {
  final localDataSource = ref.watch(pipelineReferralLocalDataSourceProvider);
  final remoteDataSource = ref.watch(pipelineReferralRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final database = ref.watch(databaseProvider);

  return PipelineReferralRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    currentUserRole: currentUser?.role.name.toUpperCase() ?? '',
    database: database,
  );
});

