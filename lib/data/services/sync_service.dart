import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/sync_errors.dart';
import '../../domain/entities/sync_models.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/sync_queue_local_data_source.dart';
import 'connectivity_service.dart';

/// Service for managing offline-first sync operations.
/// Handles the sync queue processing with retry logic and conflict resolution.
class SyncService {
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

    debugPrint('[SyncService] processQueue called, isSyncing=$_isSyncing, isConnected=${_connectivityService.isConnected}');

    if (_isSyncing) {
      debugPrint('[SyncService] Sync already in progress, returning');
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
      debugPrint('[SyncService] Device is offline (cached state), returning');
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
      debugPrint('[SyncService] Server is unreachable, returning');
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
      debugPrint('[SyncService] Found ${pendingItems.length} pending items to sync');
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
          debugPrint('[SyncService] Processing item: ${item.entityType}/${item.entityId} (${item.operation})');
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
          debugPrint('[SyncService] Successfully synced: ${item.entityType}/${item.entityId}');
        } on SyncError catch (syncError) {
          debugPrint('[SyncService] SyncError for ${item.entityType}/${item.entityId}: ${syncError.message} (retryable: ${syncError.isRetryable})');
          if (syncError.isRetryable) {
            await _syncQueueDataSource.incrementRetryCount(item.id);
          } else {
            await _syncQueueDataSource.markAsFailed(item.id, syncError.message);
          }
          errors.add('${item.entityType}/${item.entityId}: ${syncError.message}');
          failedCount++;
        } catch (e) {
          debugPrint('[SyncService] Unexpected error syncing ${item.entityType}/${item.entityId}: $e');
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
          await _supabaseClient.from(tableName).insert(payload);
        case 'update':
          await _supabaseClient
              .from(tableName)
              .update(payload)
              .eq('id', item.entityId);
        case 'delete':
          // Hard delete for tables without deleted_at column (e.g., customer_hvc_links)
          // Soft delete for others
          if (item.entityType == 'customerHvcLink') {
            await _supabaseClient.from(tableName).delete().eq('id', item.entityId);
          } else {
            await _supabaseClient.from(tableName).update({
              'deleted_at': DateTime.now().toIso8601String(),
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
        // KeyPersons table doesn't have lastSyncAt field
        await (_database.update(_database.keyPersons)
              ..where((k) => k.id.equals(entityId)))
            .write(const db.KeyPersonsCompanion(
              isPendingSync: Value(false),
            ));
      case 'pipeline':
        await (_database.update(_database.pipelines)
              ..where((p) => p.id.equals(entityId)))
            .write(db.PipelinesCompanion(
              isPendingSync: const Value(false),
              lastSyncAt: Value(syncedAt),
            ));
      case 'activity':
        // Activities table uses syncedAt instead of lastSyncAt
        await (_database.update(_database.activities)
              ..where((a) => a.id.equals(entityId)))
            .write(db.ActivitiesCompanion(
              isPendingSync: const Value(false),
              syncedAt: Value(syncedAt),
            ));
      case 'hvc':
        // Hvcs table doesn't have lastSyncAt field
        await (_database.update(_database.hvcs)
              ..where((h) => h.id.equals(entityId)))
            .write(const db.HvcsCompanion(
              isPendingSync: Value(false),
            ));
      case 'customerHvcLink':
        await (_database.update(_database.customerHvcLinks)
              ..where((l) => l.id.equals(entityId)))
            .write(const db.CustomerHvcLinksCompanion(
              isPendingSync: Value(false),
            ));
      case 'broker':
        await (_database.update(_database.brokers)
              ..where((b) => b.id.equals(entityId)))
            .write(const db.BrokersCompanion(
              isPendingSync: Value(false),
            ));
      case 'pipelineStageHistory':
        await (_database.update(_database.pipelineStageHistoryItems)
              ..where((h) => h.id.equals(entityId)))
            .write(const db.PipelineStageHistoryItemsCompanion(
              isPendingSync: Value(false),
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
              updatedAt: Value(syncedAt),
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
        debugPrint('[SyncService] Synced cadenceConfig: $entityId');
      default:
        debugPrint('[SyncService] Unknown entity type for marking synced: $entityType');
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
        debugPrint('[SyncService] Hard deleted customerHvcLink locally: $entityId');
      default:
        debugPrint('[SyncService] Unknown entity type for hard delete: $entityType');
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

  /// Trigger a manual sync.
  Future<SyncResult> triggerSync() => processQueue();

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

  /// Add an item to the sync queue.
  Future<int> queueOperation({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    // Check if there's already a pending operation for this entity
    final hasPending = await _syncQueueDataSource.hasPendingOperation(
      entityType.name,
      entityId,
    );

    if (hasPending && operation == SyncOperation.update) {
      // For updates, we can coalesce by removing the old operation
      await _syncQueueDataSource.removeOperation(entityType.name, entityId);
    }

    return _syncQueueDataSource.addToQueue(
      entityType: entityType.name,
      entityId: entityId,
      operation: operation.name,
      payload: jsonEncode(payload),
    );
  }

  /// Get the count of pending sync items.
  Stream<int> watchPendingCount() => _syncQueueDataSource.watchPendingCount();

  /// Get the current pending count.
  Future<int> getPendingCount() => _syncQueueDataSource.getPendingCount();

  /// Dispose resources.
  void dispose() {
    stopBackgroundSync();
    _stateController.close();
  }
}
