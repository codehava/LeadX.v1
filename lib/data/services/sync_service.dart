import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

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
  })  : _syncQueueDataSource = syncQueueDataSource,
        _connectivityService = connectivityService,
        _supabaseClient = supabaseClient;

  final SyncQueueLocalDataSource _syncQueueDataSource;
  final ConnectivityService _connectivityService;
  final SupabaseClient _supabaseClient;

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

  /// Stream of sync state changes.
  Stream<SyncState> get syncStateStream => _stateController.stream;

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
    if (_isSyncing) {
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        errors: ['Sync already in progress'],
        syncedAt: DateTime.now(),
      );
    }

    // Check connectivity
    if (!_connectivityService.isConnected) {
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

    _isSyncing = true;
    final errors = <String>[];
    var successCount = 0;
    var failedCount = 0;

    try {
      // Get all pending items that can be retried
      final pendingItems = await _syncQueueDataSource.getRetryableItems(
        maxRetries: maxRetries,
      );

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
          await _processItem(item);
          await _syncQueueDataSource.markAsCompleted(item.id);
          successCount++;
        } catch (e) {
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

      _updateState(
        success ? SyncState.success(result: result) : const SyncState.idle(),
      );

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
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final tableName = _getTableName(item.entityType);

    switch (item.operation) {
      case 'create':
        await _supabaseClient.from(tableName).insert(payload);
      case 'update':
        await _supabaseClient
            .from(tableName)
            .update(payload)
            .eq('id', item.entityId);
      case 'delete':
        // Soft delete - update deleted_at
        await _supabaseClient.from(tableName).update({
          'deleted_at': DateTime.now().toIso8601String(),
        }).eq('id', item.entityId);
      default:
        throw ArgumentError('Unknown operation: ${item.operation}');
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
    _backgroundSyncTimer = Timer.periodic(interval, (_) {
      if (_connectivityService.isConnected && !_isSyncing) {
        processQueue();
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
