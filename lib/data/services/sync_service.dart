import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/sync_errors.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/sync_models.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/sync_queue_local_data_source.dart';
import 'connectivity_service.dart';

/// Service for managing offline-first sync operations.
/// Handles the sync queue processing with retry logic and conflict resolution.
class SyncService {
  final _log = AppLogger.instance;

  SyncService({
    required SyncQueueLocalDataSource syncQueueDataSource,
    required ConnectivityService connectivityService,
    required SupabaseClient supabaseClient,
    required db.AppDatabase database,
  })  : _syncQueueDataSource = syncQueueDataSource,
        _connectivityService = connectivityService,
        _supabaseClient = supabaseClient,
        _database = database;

  final SyncQueueLocalDataSource _syncQueueDataSource;
  final ConnectivityService _connectivityService;
  final SupabaseClient _supabaseClient;
  final db.AppDatabase _database;

  /// Controller for sync state changes.
  final StreamController<SyncState> _stateController =
      StreamController<SyncState>.broadcast();

  /// Current sync state.
  SyncState _currentState = const SyncState.idle();

  /// Timer for background sync.
  Timer? _backgroundSyncTimer;

  /// Debounce timer for triggerSync() calls.
  Timer? _debounceTimer;

  /// Completer for the pending debounced sync operation.
  Completer<SyncResult>? _pendingSyncCompleter;

  /// Whether sync is currently in progress.
  bool _isSyncing = false;

  /// Maximum retry attempts before giving up.
  static const int maxRetries = 5;

  /// Base delay for exponential backoff (in milliseconds).
  static const int baseDelayMs = 1000;

  /// Stream of sync state changes. Starts with current state.
  Stream<SyncState> get syncStateStream async* {
    yield _currentState;
    yield* _stateController.stream;
  }

  /// Current sync state.
  SyncState get currentState => _currentState;

  /// Whether sync is currently in progress.
  bool get isSyncing => _isSyncing;

  /// Update and broadcast the current state.
  void _updateState(SyncState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Process all pending items in the sync queue.
  Future<SyncResult> processQueue() async {
    // Ensure connectivity service is initialized (important for mobile)
    await _connectivityService.ensureInitialized();

    _log.info('sync.queue | processQueue called, isSyncing=$_isSyncing, isConnected=${_connectivityService.isConnected}');

    if (_isSyncing) {
      _log.debug('sync.queue | Sync already in progress, returning');
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        errors: ['Sync already in progress'],
        syncedAt: DateTime.now(),
      );
    }

    // Check connectivity - first the cached state
    if (!_connectivityService.isConnected) {
      _log.debug('sync.queue | Device is offline (cached state), returning');
      _updateState(const SyncState.offline());
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        errors: ['Device is offline'],
        syncedAt: DateTime.now(),
      );
    }

    // Verify server is actually reachable before attempting sync
    final isReachable = await _connectivityService.checkServerReachability();
    if (!isReachable) {
      _log.debug('sync.queue | Server is unreachable, returning');
      _updateState(const SyncState.offline());
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        errors: ['Server is unreachable'],
        syncedAt: DateTime.now(),
      );
    }

    _isSyncing = true;
    final errors = <String>[];
    var successCount = 0;
    var failedCount = 0;

    try {
      // Get all pending items that can be retried
      final pendingItems = await _syncQueueDataSource.getRetryableItems(
        maxRetries: maxRetries,
      );

      // Debug: Log pending items
      _log.info('sync.queue | Found ${pendingItems.length} pending items to sync');
      if (pendingItems.isEmpty) {
        _updateState(const SyncState.idle());
        return SyncResult(
          success: true,
          processedCount: 0,
          successCount: 0,
          failedCount: 0,
          errors: [],
          syncedAt: DateTime.now(),
        );
      }

      _updateState(SyncState.syncing(
        total: pendingItems.length,
        current: 0,
      ));

      for (var i = 0; i < pendingItems.length; i++) {
        final item = pendingItems[i];

        _updateState(SyncState.syncing(
          total: pendingItems.length,
          current: i + 1,
          currentEntity: item.entityType,
        ));

        try {
          _log.debug('sync.push | Processing: ${item.entityType}/${item.entityId} (${item.operation})');
          await _processItem(item);
          await _syncQueueDataSource.markAsCompleted(item.id);
          
          // For delete operations on hard-delete entities, remove from local DB
          if (item.operation == 'delete' && item.entityType == 'customerHvcLink') {
            await _hardDeleteLocal(item.entityType, item.entityId);
          } else {
            // Mark the entity as synced in local database
            await _markEntityAsSynced(item.entityType, item.entityId);
          }
          
          successCount++;
          _log.debug('sync.push | Synced: ${item.entityType}/${item.entityId}');
        } on SyncError catch (syncError) {
          _log.error('sync.push | SyncError: ${item.entityType}/${item.entityId}: ${syncError.message} (retryable: ${syncError.isRetryable})', syncError);
          if (syncError.isRetryable) {
            await _syncQueueDataSource.incrementRetryCount(item.id);
          } else {
            await _syncQueueDataSource.markAsFailed(item.id, syncError.message);
          }
          errors.add('${item.entityType}/${item.entityId}: ${syncError.message}');
          failedCount++;
        } catch (e) {
          _log.error('sync.push | Unexpected error: ${item.entityType}/${item.entityId}', e);
          await _syncQueueDataSource.incrementRetryCount(item.id);
          await _syncQueueDataSource.markAsFailed(item.id, e.toString());
          errors.add('${item.entityType}/${item.entityId}: $e');
          failedCount++;
        }
      }

      final success = failedCount == 0;
      final result = SyncResult(
        success: success,
        processedCount: pendingItems.length,
        successCount: successCount,
        failedCount: failedCount,
        errors: errors,
        syncedAt: DateTime.now(),
      );

      // Update state based on success and current connectivity
      if (success) {
        _updateState(SyncState.success(result: result));
      } else if (!_connectivityService.isConnected) {
        _updateState(const SyncState.offline());
      } else {
        _updateState(const SyncState.idle());
      }

      return result;
    } catch (e) {
      _updateState(SyncState.error(message: e.toString(), error: e));
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: successCount,
        failedCount: failedCount,
        errors: [...errors, e.toString()],
        syncedAt: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single sync queue item.
  Future<void> _processItem(db.SyncQueueItem item) async {
    // Parse payload with error handling
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(item.payload) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw FormatException(
        'Invalid JSON payload for ${item.entityType}/${item.entityId}: $e',
      );
    }

    final tableName = _getTableName(item.entityType);

    try {
      switch (item.operation) {
        case 'create':
          // Idempotent: upsert handles retry-after-timeout gracefully
          await _supabaseClient.from(tableName).upsert(payload);
        case 'update':
          // Extract version guard metadata (added by repositories when queueing updates)
          final serverUpdatedAt = payload.remove('_server_updated_at') as String?;

          if (serverUpdatedAt != null) {
            // Optimistic locking: only update if server record hasn't changed
            final result = await _supabaseClient
                .from(tableName)
                .update(payload)
                .eq('id', item.entityId)
                .eq('updated_at', serverUpdatedAt)
                .select();

            if ((result as List).isEmpty) {
              // Version guard failed - conflict detected, resolve via LWW
              await _resolveConflict(item, payload, tableName);
            }
          } else {
            // No version guard (legacy queue items or create+update coalesced)
            await _supabaseClient
                .from(tableName)
                .update(payload)
                .eq('id', item.entityId);
          }
        case 'delete':
          // Hard delete for tables without deleted_at column (e.g., customer_hvc_links)
          // Soft delete for others
          if (item.entityType == 'customerHvcLink') {
            await _supabaseClient.from(tableName).delete().eq('id', item.entityId);
          } else {
            await _supabaseClient.from(tableName).update({
              'deleted_at': DateTime.now().toUtcIso8601(),
            }).eq('id', item.entityId);
          }
        default:
          throw ArgumentError('Unknown operation: ${item.operation}');
      }
    } on SocketException catch (e, st) {
      throw NetworkSyncError(
        message: 'Network unreachable',
        originalError: e,
        stackTrace: st,
        entityType: item.entityType,
        entityId: item.entityId,
      );
    } on TimeoutException catch (e, st) {
      throw TimeoutSyncError(
        message: 'Request timed out',
        originalError: e,
        stackTrace: st,
        entityType: item.entityType,
        entityId: item.entityId,
      );
    } on PostgrestException catch (e, st) {
      final code = int.tryParse(e.code ?? '') ?? 0;
      if (code == 401 || e.code == 'PGRST301') {
        throw AuthSyncError(
          message: 'Authentication failed: ${e.message}',
          originalError: e,
          stackTrace: st,
          entityType: item.entityType,
          entityId: item.entityId,
        );
      } else if (code == 409) {
        throw ConflictSyncError(
          message: 'Conflict: ${e.message}',
          originalError: e,
          stackTrace: st,
          entityType: item.entityType,
          entityId: item.entityId,
        );
      } else if (code >= 400 && code < 500) {
        throw ValidationSyncError(
          message: 'Validation error: ${e.message}',
          details: e.details is Map<String, dynamic>
              ? Map<String, dynamic>.from(e.details as Map<dynamic, dynamic>)
              : null,
          originalError: e,
          stackTrace: st,
          entityType: item.entityType,
          entityId: item.entityId,
        );
      } else {
        throw ServerSyncError(
          statusCode: code,
          message: 'Server error: ${e.message}',
          originalError: e,
          stackTrace: st,
          entityType: item.entityType,
          entityId: item.entityId,
        );
      }
    }
  }

  /// Resolve a sync conflict using Last-Write-Wins (LWW) strategy.
  /// Fetches server record, compares timestamps, logs conflict, and applies winner.
  /// This method resolves the conflict internally - it does NOT throw.
  /// Only throws if resolution itself fails (can't fetch server, can't write).
  Future<void> _resolveConflict(
    db.SyncQueueItem item,
    Map<String, dynamic> localPayload,
    String tableName,
  ) async {
    _log.warning('sync.push | Conflict detected for ${item.entityType}/${item.entityId}');

    // Fetch current server state
    final serverRecord = await _supabaseClient
        .from(tableName)
        .select()
        .eq('id', item.entityId)
        .maybeSingle();

    if (serverRecord == null) {
      // Record deleted on server - log and treat as server wins
      _log.warning('sync.push | Server record deleted during conflict: ${item.entityId}');
      await _syncQueueDataSource.insertConflict(
        entityType: item.entityType,
        entityId: item.entityId,
        localPayload: jsonEncode(localPayload),
        serverPayload: '{}',
        localUpdatedAt: DateTime.tryParse(localPayload['updated_at'] as String? ?? '') ?? DateTime.now(),
        serverUpdatedAt: DateTime.now(),
        winner: 'server',
        resolution: 'server_deleted',
      );
      return;
    }

    final serverUpdatedAtStr = serverRecord['updated_at'] as String;
    final localUpdatedAtStr = localPayload['updated_at'] as String;
    final serverUpdatedAt = DateTime.parse(serverUpdatedAtStr);
    final localUpdatedAt = DateTime.parse(localUpdatedAtStr);
    final winner = localUpdatedAt.isAfter(serverUpdatedAt) ? 'local' : 'server';

    // Log conflict to audit table regardless of winner
    await _syncQueueDataSource.insertConflict(
      entityType: item.entityType,
      entityId: item.entityId,
      localPayload: jsonEncode(localPayload),
      serverPayload: jsonEncode(serverRecord),
      localUpdatedAt: localUpdatedAt,
      serverUpdatedAt: serverUpdatedAt,
      winner: winner,
    );

    if (winner == 'local') {
      // Local wins - force push without version guard
      await _supabaseClient
          .from(tableName)
          .update(localPayload)
          .eq('id', item.entityId);
      _log.info('sync.push | Conflict resolved: LOCAL wins for ${item.entityType}/${item.entityId}');
    } else {
      // Server wins - apply server data to local DB
      await _applyServerDataLocally(item.entityType, item.entityId, serverRecord);
      _log.info('sync.push | Conflict resolved: SERVER wins for ${item.entityType}/${item.entityId}');
    }
  }

  /// Apply server record to local database when server wins a conflict.
  Future<void> _applyServerDataLocally(
    String entityType,
    String entityId,
    Map<String, dynamic> serverRecord,
  ) async {
    // Mark as not pending sync (server data is authoritative)
    // and set lastSyncAt to now
    final syncedAt = DateTime.now();

    switch (entityType) {
      case 'customer':
        await (_database.update(_database.customers)
              ..where((c) => c.id.equals(entityId)))
            .write(db.CustomersCompanion(
              name: Value(serverRecord['name'] as String? ?? ''),
              address: Value(serverRecord['address'] as String? ?? ''),
              provinceId: Value(serverRecord['province_id'] as String? ?? ''),
              cityId: Value(serverRecord['city_id'] as String? ?? ''),
              postalCode: Value(serverRecord['postal_code'] as String?),
              latitude: Value((serverRecord['latitude'] as num?)?.toDouble()),
              longitude: Value((serverRecord['longitude'] as num?)?.toDouble()),
              phone: Value(serverRecord['phone'] as String?),
              email: Value(serverRecord['email'] as String?),
              website: Value(serverRecord['website'] as String?),
              companyTypeId: Value(serverRecord['company_type_id'] as String? ?? ''),
              ownershipTypeId: Value(serverRecord['ownership_type_id'] as String? ?? ''),
              industryId: Value(serverRecord['industry_id'] as String? ?? ''),
              npwp: Value(serverRecord['npwp'] as String?),
              assignedRmId: Value(serverRecord['assigned_rm_id'] as String? ?? ''),
              imageUrl: Value(serverRecord['image_url'] as String?),
              notes: Value(serverRecord['notes'] as String?),
              isActive: Value(serverRecord['is_active'] as bool? ?? true),
              updatedAt: Value(DateTime.parse(serverRecord['updated_at'] as String)),
              deletedAt: serverRecord['deleted_at'] != null
                  ? Value(DateTime.parse(serverRecord['deleted_at'] as String))
                  : const Value(null),
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));

      case 'pipeline':
        await (_database.update(_database.pipelines)
              ..where((p) => p.id.equals(entityId)))
            .write(db.PipelinesCompanion(
              customerId: Value(serverRecord['customer_id'] as String? ?? ''),
              stageId: Value(serverRecord['stage_id'] as String? ?? ''),
              statusId: Value(serverRecord['status_id'] as String? ?? ''),
              cobId: Value(serverRecord['cob_id'] as String? ?? ''),
              lobId: Value(serverRecord['lob_id'] as String? ?? ''),
              leadSourceId: Value(serverRecord['lead_source_id'] as String? ?? ''),
              brokerId: Value(serverRecord['broker_id'] as String?),
              brokerPicId: Value(serverRecord['broker_pic_id'] as String?),
              customerContactId: Value(serverRecord['customer_contact_id'] as String?),
              tsi: Value((serverRecord['tsi'] as num?)?.toDouble()),
              potentialPremium: Value((serverRecord['potential_premium'] as num?)?.toDouble() ?? 0),
              finalPremium: Value((serverRecord['final_premium'] as num?)?.toDouble()),
              weightedValue: Value((serverRecord['weighted_value'] as num?)?.toDouble()),
              expectedCloseDate: serverRecord['expected_close_date'] != null
                  ? Value(DateTime.parse(serverRecord['expected_close_date'] as String))
                  : const Value(null),
              policyNumber: Value(serverRecord['policy_number'] as String?),
              declineReason: Value(serverRecord['decline_reason'] as String?),
              notes: Value(serverRecord['notes'] as String?),
              isTender: Value(serverRecord['is_tender'] as bool? ?? false),
              assignedRmId: Value(serverRecord['assigned_rm_id'] as String? ?? ''),
              closedAt: serverRecord['closed_at'] != null
                  ? Value(DateTime.parse(serverRecord['closed_at'] as String))
                  : const Value(null),
              updatedAt: Value(DateTime.parse(serverRecord['updated_at'] as String)),
              deletedAt: serverRecord['deleted_at'] != null
                  ? Value(DateTime.parse(serverRecord['deleted_at'] as String))
                  : const Value(null),
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));

      case 'activity':
        await (_database.update(_database.activities)
              ..where((a) => a.id.equals(entityId)))
            .write(db.ActivitiesCompanion(
              status: Value(serverRecord['status'] as String? ?? ''),
              summary: Value(serverRecord['summary'] as String?),
              notes: Value(serverRecord['notes'] as String?),
              scheduledDatetime: Value(DateTime.parse(serverRecord['scheduled_datetime'] as String)),
              executedAt: serverRecord['executed_at'] != null
                  ? Value(DateTime.parse(serverRecord['executed_at'] as String))
                  : const Value(null),
              latitude: Value((serverRecord['latitude'] as num?)?.toDouble()),
              longitude: Value((serverRecord['longitude'] as num?)?.toDouble()),
              locationAccuracy: Value((serverRecord['location_accuracy'] as num?)?.toDouble()),
              distanceFromTarget: Value((serverRecord['distance_from_target'] as num?)?.toDouble()),
              cancelledAt: serverRecord['cancelled_at'] != null
                  ? Value(DateTime.parse(serverRecord['cancelled_at'] as String))
                  : const Value(null),
              cancelReason: Value(serverRecord['cancel_reason'] as String?),
              updatedAt: Value(DateTime.parse(serverRecord['updated_at'] as String)),
              deletedAt: serverRecord['deleted_at'] != null
                  ? Value(DateTime.parse(serverRecord['deleted_at'] as String))
                  : const Value(null),
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));

      default:
        // Secondary entities (keyPerson, hvc, broker, cadenceMeeting, pipelineReferral):
        // Full field-level LWW is not implemented here. The conflict is still
        // logged to sync_conflicts (by _resolveConflict above), and we mark the
        // local record as synced. The next pull cycle will apply the server's
        // authoritative data for these entity types.
        _log.warning('sync.push | Applying server data for $entityType/$entityId with basic sync metadata only');
        await _markEntityAsSynced(entityType, entityId);
    }
  }

  /// Mark an entity as synced in local database (set isPendingSync = false).
  Future<void> _markEntityAsSynced(String entityType, String entityId) async {
    final syncedAt = DateTime.now();
    
    switch (entityType) {
      case 'customer':
        await (_database.update(_database.customers)
              ..where((c) => c.id.equals(entityId)))
            .write(db.CustomersCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'keyPerson':
        await (_database.update(_database.keyPersons)
              ..where((k) => k.id.equals(entityId)))
            .write(db.KeyPersonsCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'pipeline':
        await (_database.update(_database.pipelines)
              ..where((p) => p.id.equals(entityId)))
            .write(db.PipelinesCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'activity':
        await (_database.update(_database.activities)
              ..where((a) => a.id.equals(entityId)))
            .write(db.ActivitiesCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'hvc':
        await (_database.update(_database.hvcs)
              ..where((h) => h.id.equals(entityId)))
            .write(db.HvcsCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'customerHvcLink':
        await (_database.update(_database.customerHvcLinks)
              ..where((l) => l.id.equals(entityId)))
            .write(db.CustomerHvcLinksCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'broker':
        await (_database.update(_database.brokers)
              ..where((b) => b.id.equals(entityId)))
            .write(db.BrokersCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'pipelineStageHistory':
        await (_database.update(_database.pipelineStageHistoryItems)
              ..where((h) => h.id.equals(entityId)))
            .write(db.PipelineStageHistoryItemsCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'pipelineReferral':
        await (_database.update(_database.pipelineReferrals)
              ..where((r) => r.id.equals(entityId)))
            .write(db.PipelineReferralsCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'cadenceMeeting':
        await (_database.update(_database.cadenceMeetings)
              ..where((m) => m.id.equals(entityId)))
            .write(db.CadenceMeetingsCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'cadenceParticipant':
        await (_database.update(_database.cadenceParticipants)
              ..where((p) => p.id.equals(entityId)))
            .write(db.CadenceParticipantsCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'cadenceConfig':
        // CadenceScheduleConfig doesn't have isPendingSync column
        // Just log success - the sync queue completion handles the tracking
        _log.debug('sync.push | Synced cadenceConfig: $entityId');
      default:
        _log.warning('sync.push | Unknown entity type for marking synced: $entityType');
    }
  }

  /// Hard delete entity from local database after successful remote delete.
  /// Used for entities that don't support soft delete in remote (e.g., customer_hvc_links).
  Future<void> _hardDeleteLocal(String entityType, String entityId) async {
    switch (entityType) {
      case 'customerHvcLink':
        await (_database.delete(_database.customerHvcLinks)
              ..where((l) => l.id.equals(entityId)))
            .go();
        _log.debug('sync.push | Hard deleted customerHvcLink locally: $entityId');
      default:
        _log.warning('sync.push | Unknown entity type for hard delete: $entityType');
    }
  }

  /// Get table name from entity type.
  String _getTableName(String entityType) {
    switch (entityType) {
      case 'customer':
        return 'customers';
      case 'keyPerson':
        return 'key_persons';
      case 'pipeline':
        return 'pipelines';
      case 'activity':
        return 'activities';
      case 'hvc':
        return 'hvcs';
      case 'broker':
        return 'brokers';
      case 'customerHvcLink':
        return 'customer_hvc_links';
      case 'pipelineStageHistory':
        return 'pipeline_stage_history';
      case 'pipelineReferral':
        return 'pipeline_referrals';
      case 'cadenceMeeting':
        return 'cadence_meetings';
      case 'cadenceParticipant':
        return 'cadence_participants';
      case 'cadenceConfig':
        return 'cadence_schedule_config';
      default:
        throw ArgumentError('Unknown entity type: $entityType');
    }
  }

  /// Trigger sync with 500ms debounce window.
  /// Multiple calls within the window result in a single processQueue().
  /// Returns a Future that completes when the batched sync finishes.
  Future<SyncResult> triggerSync() {
    _debounceTimer?.cancel();

    if (_pendingSyncCompleter == null || _pendingSyncCompleter!.isCompleted) {
      _pendingSyncCompleter = Completer<SyncResult>();
    }

    final completer = _pendingSyncCompleter!;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final result = await processQueue();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  /// Start background sync with the specified interval.
  void startBackgroundSync({
    Duration interval = const Duration(minutes: 5),
  }) {
    stopBackgroundSync();
    _backgroundSyncTimer = Timer.periodic(interval, (_) async {
      // Ensure connectivity is initialized before checking status
      await _connectivityService.ensureInitialized();
      if (_connectivityService.isConnected && !_isSyncing) {
        unawaited(processQueue());
      }
    });
  }

  /// Stop background sync.
  void stopBackgroundSync() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = null;
  }

  /// Add an item to the sync queue with intelligent coalescing.
  ///
  /// Coalescing rules (applied atomically within a transaction):
  /// - create + update → keep create, replace payload with latest
  /// - create + delete → remove both (entity never reached server)
  /// - update + update → replace with latest update
  /// - update + delete → replace with delete
  Future<int> queueOperation({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    return _database.transaction(() async {
      // Find existing pending operation for this entity
      final existing = await _syncQueueDataSource.getPendingItemForEntity(
        entityType.name,
        entityId,
      );

      if (existing == null) {
        // No existing operation, simply add to queue
        _log.debug(
            'sync.queue | Queued ${operation.name} for ${entityType.name}/$entityId');
        return _syncQueueDataSource.addToQueue(
          entityType: entityType.name,
          entityId: entityId,
          operation: operation.name,
          payload: jsonEncode(payload),
        );
      }

      // Apply coalescing rules
      switch ((existing.operation, operation.name)) {
        case ('create', 'update'):
          // Keep create operation, update payload to latest state
          await _syncQueueDataSource.updatePayload(
              existing.id, jsonEncode(payload));
          _log.debug(
              'sync.queue | Coalesced create+update for ${entityType.name}/$entityId');
          return existing.id;

        case ('create', 'delete'):
          // Cancel both -- entity never reached server
          await _syncQueueDataSource.removeOperation(
              entityType.name, entityId);
          _log.debug(
              'sync.queue | Coalesced create+delete for ${entityType.name}/$entityId');
          return -1;

        case ('update', 'update'):
          // Replace with latest update
          await _syncQueueDataSource.removeOperation(
              entityType.name, entityId);
          _log.debug(
              'sync.queue | Coalesced update+update for ${entityType.name}/$entityId');
          return _syncQueueDataSource.addToQueue(
            entityType: entityType.name,
            entityId: entityId,
            operation: operation.name,
            payload: jsonEncode(payload),
          );

        case ('update', 'delete'):
          // Delete supersedes update
          await _syncQueueDataSource.removeOperation(
              entityType.name, entityId);
          _log.debug(
              'sync.queue | Coalesced update+delete for ${entityType.name}/$entityId');
          return _syncQueueDataSource.addToQueue(
            entityType: entityType.name,
            entityId: entityId,
            operation: operation.name,
            payload: jsonEncode(payload),
          );

        default:
          // Unexpected combination (e.g., delete+create), log warning and add anyway
          _log.warning(
              'sync.queue | Unexpected coalesce: ${existing.operation}+${operation.name} for ${entityType.name}/$entityId');
          return _syncQueueDataSource.addToQueue(
            entityType: entityType.name,
            entityId: entityId,
            operation: operation.name,
            payload: jsonEncode(payload),
          );
      }
    });
  }

  /// Get the count of pending sync items.
  Stream<int> watchPendingCount() => _syncQueueDataSource.watchPendingCount();

  /// Get the current pending count.
  Future<int> getPendingCount() => _syncQueueDataSource.getPendingCount();

  /// Dispose resources.
  void dispose() {
    _debounceTimer?.cancel();
    if (_pendingSyncCompleter != null && !_pendingSyncCompleter!.isCompleted) {
      _pendingSyncCompleter!.completeError(
        StateError('SyncService disposed while sync was pending'),
      );
    }
    stopBackgroundSync();
    _stateController.close();
  }
}
