import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';

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
import '../../data/services/sync_coordinator.dart';
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

/// Provider for the sync coordinator (central lock for all sync operations).
final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final appSettings = ref.watch(appSettingsServiceProvider);
  return SyncCoordinator(appSettings);
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
  final coordinator = ref.watch(syncCoordinatorProvider);

  final service = SyncService(
    syncQueueDataSource: syncQueueDataSource,
    connectivityService: connectivityService,
    supabaseClient: supabase,
    database: database,
    coordinator: coordinator,
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

/// Provider for the count of recent sync conflicts (last 7 days).
/// Used by sync status UI to show conflict activity.
final conflictCountProvider = StreamProvider<int>((ref) {
  final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
  return syncQueueDataSource.watchRecentConflictCount();
});

/// Provider for the count of dead letter items in the sync queue.
/// Used by sync status UI to show items that need manual intervention.
final deadLetterCountProvider = StreamProvider<int>((ref) {
  final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
  return syncQueueDataSource.watchDeadLetterCount();
});

/// Provider for the last sync timestamp.
/// Uses the maximum timestamp across ALL synced tables for accurate global staleness.
final lastSyncTimestampProvider = FutureProvider<DateTime?>((ref) async {
  // Re-evaluate whenever sync state changes
  ref.watch(syncNotifierProvider);
  final appSettings = ref.watch(appSettingsServiceProvider);
  return appSettings.getGlobalLastSyncAt();
});

/// Per-entity sync queue status for card badge display.
/// Index order matters -- higher index = worse status (used for priority).
enum SyncQueueEntityStatus {
  none,       // No queue entry (synced)
  pending,    // status == 'pending'
  failed,     // status == 'failed' (retryCount < 5)
  deadLetter, // status == 'dead_letter' (retryCount >= 5)
}

/// Batch provider for per-entity sync queue status.
/// Watches the entire sync queue table (typically 0-50 items) and produces
/// a Map<String, SyncQueueEntityStatus> keyed by entityId.
/// Cards do O(1) lookups instead of N individual queries.
final syncQueueEntityStatusMapProvider =
    StreamProvider<Map<String, SyncQueueEntityStatus>>((ref) {
  final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
  return syncQueueDataSource.watchAllItems().map((items) {
    final map = <String, SyncQueueEntityStatus>{};
    for (final item in items) {
      final status = switch (item.status) {
        'dead_letter' => SyncQueueEntityStatus.deadLetter,
        'failed' => SyncQueueEntityStatus.failed,
        _ => SyncQueueEntityStatus.pending,
      };
      // Keep the worst status per entity (deadLetter > failed > pending)
      final existing = map[item.entityId];
      if (existing == null || status.index > existing.index) {
        map[item.entityId] = status;
      }
    }
    return map;
  });
});

/// Provider for background sync enabled setting.
/// Defaults to false (off) when no setting exists.
final backgroundSyncEnabledProvider = FutureProvider<bool>((ref) async {
  final appSettings = ref.watch(appSettingsServiceProvider);
  final value = await appSettings.get('background_sync_enabled');
  return value == 'true'; // Default false if not set
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

  // Initialize the coordinator: load persisted state and recover stale locks.
  // Must happen BEFORE startBackgroundSync so the coordinator is ready.
  final coordinator = container.read(syncCoordinatorProvider);
  await coordinator.initialize();

  // TODO(Phase 6): Schema migration detection for re-triggering initial sync
  // When schemaVersion at initial sync time < current schemaVersion AND
  // new migration includes sync-relevant tables, reset initial sync flag.

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
    this._appSettingsService,
    this._coordinator,
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
  final AppSettingsService _appSettingsService;
  final SyncCoordinator _coordinator;

  /// Read since timestamp with 30s safety margin to avoid missing records.
  Future<DateTime?> _getSafeSince(String tableName) async {
    final since = await _appSettingsService.getTableLastSyncAt(tableName);
    if (since == null) return null;
    return since.subtract(const Duration(seconds: 30));
  }

  /// Trigger a bidirectional sync: push pending changes, then pull new data.
  /// Acquires the coordinator lock before execution and releases it after.
  /// If lock is held, the sync is queued for a single follow-up execution.
  Future<void> triggerSync({bool calledFromInitialSync = false}) async {
    // Ensure connectivity service is initialized (important for mobile)
    await _connectivityService.ensureInitialized();

    if (!_connectivityService.isConnected) {
      state = AsyncValue.error('Device is offline', StackTrace.current);
      return;
    }

    // Attempt to acquire the coordinator lock
    // skipInitialSyncChecks: Phase 3 of initial sync calls triggerSync before
    // markInitialSyncComplete() runs, so the coordinator gate and cooldown must be bypassed.
    final acquired = await _coordinator.acquireLock(
      type: SyncType.manual,
      skipInitialSyncChecks: calledFromInitialSync,
    );
    if (!acquired) {
      AppLogger.instance.info('sync.coordinator | Manual sync queued (lock held)');
      // Don't set error state -- the sync is queued, not failed
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Step 1: Push - upload local changes to Supabase (bypass debounce for manual sync)
      AppLogger.instance.debug('sync.queue | Starting push sync...');
      final pushResult = await _syncService.processQueue();
      AppLogger.instance.debug('sync.queue | Push sync complete: ${pushResult.successCount} uploaded');

      // Step 2: Sync pending photos to Supabase Storage
      AppLogger.instance.debug('sync.queue | Starting photo sync...');
      await _syncPhotos();
      AppLogger.instance.debug('sync.queue | Photo sync complete');

      // Step 3: Sync pending audit logs (after activities are synced)
      AppLogger.instance.debug('sync.queue | Starting audit log sync...');
      await _syncAuditLogs();
      AppLogger.instance.debug('sync.queue | Audit log sync complete');

      // Step 4: Pull - download changes from Supabase
      AppLogger.instance.debug('sync.queue | Starting pull sync...');
      await _pullFromRemote();
      AppLogger.instance.debug('sync.queue | Pull sync complete');

      state = AsyncValue.data(pushResult);
    } catch (e, st) {
      AppLogger.instance.error('sync.queue | Sync error: $e');
      state = AsyncValue.error(e, st);
    } finally {
      _coordinator.releaseLock();

      // Execute queued sync if pending (collapse multiple into one)
      if (_coordinator.consumeQueuedSync()) {
        AppLogger.instance.info('sync.coordinator | Executing queued sync');
        // Small delay to avoid tight loop
        await Future.delayed(const Duration(milliseconds: 200));
        // Recursive call -- safe because lock is released
        await triggerSync();
      }
    }
  }

  /// Sync pending photos to Supabase Storage.
  Future<void> _syncPhotos() async {
    try {
      await _activityRepository.syncPendingPhotos();
    } catch (e) {
      AppLogger.instance.error('sync.queue | Photo sync error: $e');
    }
  }

  /// Sync pending audit logs to Supabase.
  Future<void> _syncAuditLogs() async {
    try {
      await _activityRepository.syncPendingAuditLogs();
    } catch (e) {
      AppLogger.instance.error('sync.queue | Audit log sync error: $e');
    }
  }

  /// Pull data from Supabase to local database with incremental timestamps.
  Future<void> _pullFromRemote() async {
    AppLogger.instance.debug('sync.pull | Starting _pullFromRemote...');

    // Pull customers
    try {
      final customerSince = await _getSafeSince('customers');
      AppLogger.instance.debug('sync.pull | Pulling customers (since: $customerSince)...');
      final customerResult = await _customerRepository.syncFromRemote(since: customerSince);
      switch (customerResult) {
        case Success(:final value):
          AppLogger.instance.debug('sync.pull | Pulled $value customers');
          _appSettingsService.setTableLastSyncAt('customers', DateTime.now().toUtc());
        case ResultFailure(:final failure):
          AppLogger.instance.warning('sync.pull | Customer pull failed: ${failure.message}');
      }
    } catch (e, st) {
      AppLogger.instance.error('sync.pull | Customer pull error: $e');
      AppLogger.instance.debug('sync.pull | Stack trace: $st');
    }

    // Pull key persons
    try {
      final keyPersonSince = await _getSafeSince('key_persons');
      AppLogger.instance.debug('sync.pull | Pulling key persons (since: $keyPersonSince)...');
      final keyPersonResult = await _customerRepository.syncKeyPersonsFromRemote(since: keyPersonSince);
      switch (keyPersonResult) {
        case Success(:final value):
          AppLogger.instance.debug('sync.pull | Pulled $value key persons');
          _appSettingsService.setTableLastSyncAt('key_persons', DateTime.now().toUtc());
        case ResultFailure(:final failure):
          AppLogger.instance.warning('sync.pull | Key person pull failed: ${failure.message}');
      }
    } catch (e) {
      AppLogger.instance.error('sync.pull | Key person pull error: $e');
    }

    // Pull pipelines
    try {
      final pipelineSince = await _getSafeSince('pipelines');
      AppLogger.instance.debug('sync.pull | Pulling pipelines (since: $pipelineSince)...');
      // Invalidate caches BEFORE sync to ensure fresh lookup values during mapping
      final pipelineRepo = _pipelineRepository;
      if (pipelineRepo is PipelineRepositoryImpl) {
        pipelineRepo.invalidateCaches();
      }
      await _pipelineRepository.syncFromRemote(since: pipelineSince);
      _appSettingsService.setTableLastSyncAt('pipelines', DateTime.now().toUtc());
    } catch (e) {
      AppLogger.instance.error('sync.pull | Pipeline pull error: $e');
    }

    // Pull activities
    try {
      final activitySince = await _getSafeSince('activities');
      AppLogger.instance.debug('sync.pull | Pulling activities (since: $activitySince)...');
      // Invalidate caches BEFORE sync to ensure fresh lookup values during mapping
      _activityRepository.invalidateCaches();
      await _activityRepository.syncFromRemote(since: activitySince);
      _appSettingsService.setTableLastSyncAt('activities', DateTime.now().toUtc());

      // Sync activity photos from remote (no since timestamp needed)
      await _activityRepository.syncPhotosFromRemote();
    } catch (e) {
      AppLogger.instance.error('sync.pull | Activity pull error: $e');
    }

    // Pull HVCs
    try {
      final hvcSince = await _getSafeSince('hvcs');
      AppLogger.instance.debug('sync.pull | Pulling HVCs (since: $hvcSince)...');
      final hvcResult = await _hvcRepository.syncFromRemote(since: hvcSince);
      switch (hvcResult) {
        case Success(:final value):
          AppLogger.instance.debug('sync.pull | Pulled $value HVCs');
          _appSettingsService.setTableLastSyncAt('hvcs', DateTime.now().toUtc());
        case ResultFailure(:final failure):
          AppLogger.instance.warning('sync.pull | HVC pull failed: ${failure.message}');
      }
    } catch (e) {
      AppLogger.instance.error('sync.pull | HVC pull error: $e');
    }

    // Pull HVC-Customer links
    try {
      final hvcLinkSince = await _getSafeSince('customer_hvc_links');
      AppLogger.instance.debug('sync.pull | Pulling HVC links (since: $hvcLinkSince)...');
      final hvcLinkResult = await _hvcRepository.syncLinksFromRemote(since: hvcLinkSince);
      switch (hvcLinkResult) {
        case Success(:final value):
          AppLogger.instance.debug('sync.pull | Pulled $value HVC-Customer links');
          _appSettingsService.setTableLastSyncAt('customer_hvc_links', DateTime.now().toUtc());
        case ResultFailure(:final failure):
          AppLogger.instance.warning('sync.pull | HVC link pull failed: ${failure.message}');
      }
    } catch (e) {
      AppLogger.instance.error('sync.pull | HVC link pull error: $e');
    }

    // Pull Brokers
    try {
      final brokerSince = await _getSafeSince('brokers');
      AppLogger.instance.debug('sync.pull | Pulling brokers (since: $brokerSince)...');
      final brokerResult = await _brokerRepository.syncFromRemote(since: brokerSince);
      switch (brokerResult) {
        case Success(:final value):
          AppLogger.instance.debug('sync.pull | Pulled $value brokers');
          _appSettingsService.setTableLastSyncAt('brokers', DateTime.now().toUtc());
        case ResultFailure(:final failure):
          AppLogger.instance.warning('sync.pull | Broker pull failed: ${failure.message}');
      }
    } catch (e) {
      AppLogger.instance.error('sync.pull | Broker pull error: $e');
    }

    // Pull Cadence configs and meetings
    try {
      final cadenceSince = await _getSafeSince('cadence_meetings');
      AppLogger.instance.debug('sync.pull | Pulling cadence data (since: $cadenceSince)...');
      await _cadenceRepository.syncFromRemote(since: cadenceSince);
      _appSettingsService.setTableLastSyncAt('cadence_meetings', DateTime.now().toUtc());
      AppLogger.instance.debug('sync.pull | Pulled cadence data');
    } catch (e) {
      AppLogger.instance.error('sync.pull | Cadence pull error: $e');
    }

    // Pull Pipeline Referrals
    try {
      final referralSince = await _getSafeSince('pipeline_referrals');
      AppLogger.instance.debug('sync.pull | Pulling pipeline referrals (since: $referralSince)...');
      // Invalidate caches BEFORE sync to ensure fresh lookup values during mapping
      _pipelineReferralRepository.invalidateCaches();
      await _pipelineReferralRepository.syncFromRemote(since: referralSince);
      _appSettingsService.setTableLastSyncAt('pipeline_referrals', DateTime.now().toUtc());
      AppLogger.instance.debug('sync.pull | Pulled pipeline referral data');
    } catch (e) {
      AppLogger.instance.error('sync.pull | Pipeline referral pull error: $e');
    }

    // Step 5: Invalidate all data providers to refresh UI
    await _invalidateDataProviders();
  }

  /// Refresh auth data after sync completion.
  /// Note: List/detail providers no longer need invalidation - Drift streams auto-update.
  Future<void> _invalidateDataProviders() async {
    AppLogger.instance.debug('sync.queue | Refreshing auth data after sync...');

    // Refresh current user to pick up any profile changes from sync
    // This is the only invalidation needed - all other providers are StreamProviders
    // that automatically update when their underlying Drift tables change.
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.refreshCurrentUser();
      _ref.invalidate(currentUserProvider);
    } catch (e) {
      AppLogger.instance.error('sync.pull | Error refreshing current user: $e');
    }

    AppLogger.instance.debug('sync.queue | Auth data refreshed');
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
  final coordinator = ref.watch(syncCoordinatorProvider);

  final service = InitialSyncService(
    supabaseClient: supabase,
    database: db,
    masterDataSource: masterDataSource,
    appSettingsService: appSettings,
    coordinator: coordinator,
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
  final appSettings = ref.watch(appSettingsServiceProvider);
  final coordinator = ref.watch(syncCoordinatorProvider);

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
    appSettings,
    coordinator,
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
  final database = ref.watch(databaseProvider);

  final pipelineLocalDataSource = ref.watch(_pipelineLocalDataSourceProvider);
  final activityLocalDataSource = ref.watch(_activityLocalDataSourceProvider);

  return CustomerRepositoryImpl(
    localDataSource: localDataSource,
    keyPersonLocalDataSource: keyPersonLocalDataSource,
    pipelineLocalDataSource: pipelineLocalDataSource,
    activityLocalDataSource: activityLocalDataSource,
    remoteDataSource: remoteDataSource,
    keyPersonRemoteDataSource: keyPersonRemoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
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

