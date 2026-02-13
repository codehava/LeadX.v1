import 'package:drift/drift.dart';

import '../../database/app_database.dart';

/// Local data source for sync queue operations.
/// Manages the FIFO queue of pending sync operations.
class SyncQueueLocalDataSource {
  SyncQueueLocalDataSource(this._db);

  final AppDatabase _db;

  /// Get all pending sync items ordered by creation time (FIFO).
  Future<List<SyncQueueItem>> getPendingItems() async {
    final query = _db.select(_db.syncQueueItems)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  /// Get pending items with retry count less than max.
  Future<List<SyncQueueItem>> getRetryableItems({int maxRetries = 5}) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) => t.retryCount.isSmallerThanValue(maxRetries))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  /// Add a new item to the sync queue.
  /// Returns the ID of the inserted item.
  Future<int> addToQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) async {
    final companion = SyncQueueItemsCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    );
    return _db.into(_db.syncQueueItems).insert(companion);
  }

  /// Mark a sync item as completed and remove it from the queue.
  Future<void> markAsCompleted(int id) async {
    await (_db.delete(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Mark a sync item as failed with an error message.
  Future<void> markAsFailed(int id, String error) async {
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(SyncQueueItemsCompanion(
          lastError: Value(error),
          lastAttemptAt: Value(DateTime.now()),
        ));
  }

  /// Increment the retry count for a sync item.
  Future<void> incrementRetryCount(int id) async {
    final item = await (_db.select(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (item != null) {
      await (_db.update(_db.syncQueueItems)
            ..where((t) => t.id.equals(id)))
          .write(SyncQueueItemsCompanion(
            retryCount: Value(item.retryCount + 1),
            lastAttemptAt: Value(DateTime.now()),
          ));
    }
  }

  /// Clear all completed items (those that were successfully synced).
  /// Optionally filter by age.
  Future<int> clearCompletedItems({DateTime? olderThan}) async {
    // Since we delete completed items immediately, this is mainly for cleanup
    // of failed items that exceeded retry count
    if (olderThan != null) {
      return (_db.delete(_db.syncQueueItems)
            ..where((t) => t.createdAt.isSmallerThanValue(olderThan)))
          .go();
    }
    return 0;
  }

  /// Clear all items from the queue (for testing/reset).
  Future<int> clearAll() => _db.delete(_db.syncQueueItems).go();

  /// Watch the count of pending sync items.
  Stream<int> watchPendingCount() => _db.syncQueueItems.count().watchSingle();

  /// Get count of pending sync items.
  Future<int> getPendingCount() => _db.syncQueueItems.count().getSingle();

  /// Get items by entity type.
  Future<List<SyncQueueItem>> getItemsByEntityType(String entityType) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) => t.entityType.equals(entityType))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  /// Get a specific sync item by ID.
  Future<SyncQueueItem?> getItemById(int id) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Get the pending sync queue item for a specific entity.
  /// Returns null if no pending operation exists.
  Future<SyncQueueItem?> getPendingItemForEntity(
    String entityType,
    String entityId,
  ) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) =>
          t.entityType.equals(entityType) & t.entityId.equals(entityId));
    return query.getSingleOrNull();
  }

  /// Check if an entity already has a pending sync operation.
  Future<bool> hasPendingOperation(String entityType, String entityId) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) =>
          t.entityType.equals(entityType) & t.entityId.equals(entityId));
    final results = await query.get();
    return results.isNotEmpty;
  }

  /// Update payload for an existing queue item.
  /// Useful for coalescing multiple updates to the same entity.
  Future<void> updatePayload(int id, String payload) async {
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(SyncQueueItemsCompanion(
          payload: Value(payload),
        ));
  }

  /// Remove a specific operation for an entity.
  /// Used when a newer operation supersedes an older one.
  Future<int> removeOperation(String entityType, String entityId) =>
      (_db.delete(_db.syncQueueItems)
            ..where((t) =>
                t.entityType.equals(entityType) & t.entityId.equals(entityId)))
          .go();

  /// Get all items in the queue (for debug screen).
  Future<List<SyncQueueItem>> getAllItems() async {
    final query = _db.select(_db.syncQueueItems)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  /// Reset retry count for an item (to retry failed items).
  Future<void> resetRetryCount(int id) async {
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(const SyncQueueItemsCompanion(
          retryCount: Value(0),
          lastError: Value(null),
        ));
  }
}
