import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_models.freezed.dart';
part 'sync_models.g.dart';

/// Represents the type of sync operation.
enum SyncOperation { create, update, delete }

/// Represents the status of a sync operation.
enum SyncStatus { pending, inProgress, completed, failed }

/// Represents the entity types that can be synced.
enum SyncEntityType { customer, keyPerson, pipeline, activity, hvc, broker }

/// Represents an item in the sync queue.
@freezed
class SyncQueueItem with _$SyncQueueItem {
  const factory SyncQueueItem({
    required String id,
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    @Default(SyncStatus.pending) SyncStatus status,
    @Default(0) int retryCount,
    String? errorMessage,
    DateTime? syncedAt,
  }) = _SyncQueueItem;

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);
}

/// Represents the result of a sync operation.
@freezed
class SyncResult with _$SyncResult {
  const factory SyncResult({
    required bool success,
    required int processedCount,
    required int successCount,
    required int failedCount,
    required List<String> errors,
    required DateTime syncedAt,
  }) = _SyncResult;

  factory SyncResult.fromJson(Map<String, dynamic> json) =>
      _$SyncResultFromJson(json);
}

/// Represents the current state of synchronization for UI.
@freezed
sealed class SyncState with _$SyncState {
  /// No sync in progress
  const factory SyncState.idle() = SyncStateIdle;

  /// Sync is in progress
  const factory SyncState.syncing({
    required int total,
    required int current,
    String? currentEntity,
  }) = SyncStateSyncing;

  /// Sync completed successfully
  const factory SyncState.success({
    required SyncResult result,
  }) = SyncStateSuccess;

  /// Sync failed with error
  const factory SyncState.error({
    required String message,
    Object? error,
  }) = SyncStateError;

  /// Device is offline
  const factory SyncState.offline() = SyncStateOffline;
}
