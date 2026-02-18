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

  /// Get retryable items: pending or failed status with retry count less than max.
  /// Excludes dead_letter items to prevent reprocessing non-retryable errors.
  Future<List<SyncQueueItem>> getRetryableItems({int maxRetries = 5}) async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) =>
          t.retryCount.isSmallerThanValue(maxRetries) &
          (t.status.equals('pending') | t.status.equals('failed')))
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
          status: const Value('failed'),
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

  /// Reset retry count and status for an item (to retry dead letter/failed items).
  /// Also resets status back to 'pending' so getRetryableItems() picks it up.
  /// Note: The entity's isPendingSync flag does NOT need to be set here because
  /// it is already true -- it was set when the queue item was first created and
  /// is only cleared by _markEntityAsSynced on successful sync.
  Future<void> resetRetryCount(int id) async {
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(const SyncQueueItemsCompanion(
          retryCount: Value(0),
          lastError: Value(null),
          status: Value('pending'),
        ));
  }

  // ============================================
  // DEAD LETTER MANAGEMENT
  // ============================================

  /// Mark a sync item as dead letter (non-retryable error or exhausted retries).
  Future<void> markAsDeadLetter(int id, String error) async {
    await (_db.update(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .write(SyncQueueItemsCompanion(
          status: const Value('dead_letter'),
          lastError: Value(error),
          lastAttemptAt: Value(DateTime.now()),
        ));
  }

  /// Watch count of dead letter items as a reactive Drift stream.
  Stream<int> watchDeadLetterCount() {
    return (_db.selectOnly(_db.syncQueueItems)
          ..addColumns([_db.syncQueueItems.id.count()])
          ..where(_db.syncQueueItems.status.equals('dead_letter')))
        .map((row) => row.read(_db.syncQueueItems.id.count()) ?? 0)
        .watchSingle();
  }

  /// Get all dead letter items ordered by most recent attempt first.
  Future<List<SyncQueueItem>> getDeadLetterItems() async {
    final query = _db.select(_db.syncQueueItems)
      ..where((t) => t.status.equals('dead_letter'))
      ..orderBy([(t) => OrderingTerm.desc(t.lastAttemptAt)]);
    return query.get();
  }

  /// Discard a dead letter item by removing it from the queue.
  /// The caller (SyncService) handles clearing isPendingSync on the entity.
  Future<void> discardDeadLetterItem(int id) async {
    await (_db.delete(_db.syncQueueItems)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ============================================
  // PRUNING
  // ============================================

  /// Safety net: prune orphaned items that somehow have no valid status
  /// and are older than [completedRetention].
  /// Completed items are already deleted on success via markAsCompleted(),
  /// so this only catches items in an unexpected state (e.g., no status after crash).
  Future<int> pruneOldItems({
    required Duration completedRetention,
  }) async {
    final cutoff = DateTime.now().subtract(completedRetention);
    return (_db.delete(_db.syncQueueItems)
          ..where((t) =>
              t.createdAt.isSmallerThanValue(cutoff) &
              t.status.isNotIn(const ['pending', 'failed', 'dead_letter'])))
        .go();
  }

  /// Prune dead letter items that have expired (older than [expiry]).
  /// Default expiry is 30 days per locked decision.
  Future<int> pruneExpiredDeadLetters({
    Duration expiry = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(expiry);
    return (_db.delete(_db.syncQueueItems)
          ..where((t) =>
              t.status.equals('dead_letter') &
              t.lastAttemptAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Prune sync conflicts older than [olderThan].
  /// Default is 30 days to keep the conflict audit table manageable.
  Future<int> pruneSyncConflicts({
    Duration olderThan = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(olderThan);
    return (_db.delete(_db.syncConflicts)
          ..where((t) => t.detectedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  // ============================================
  // CONFLICT LOGGING
  // ============================================

  /// Insert a conflict record into the sync_conflicts audit table.
  Future<int> insertConflict({
    required String entityType,
    required String entityId,
    required String localPayload,
    required String serverPayload,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String winner,
    String resolution = 'lww',
  }) async {
    return _db.into(_db.syncConflicts).insert(
      SyncConflictsCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        localPayload: localPayload,
        serverPayload: serverPayload,
        localUpdatedAt: localUpdatedAt,
        serverUpdatedAt: serverUpdatedAt,
        winner: winner,
        resolution: Value(resolution),
        detectedAt: DateTime.now(),
      ),
    );
  }

  /// Watch count of conflicts detected in the last [days] days.
  Stream<int> watchRecentConflictCount({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.selectOnly(_db.syncConflicts)
          ..addColumns([_db.syncConflicts.id.count()])
          ..where(_db.syncConflicts.detectedAt.isBiggerOrEqualValue(cutoff)))
        .map((row) => row.read(_db.syncConflicts.id.count()) ?? 0)
        .watchSingle();
  }

  /// Get recent conflicts list (for future UI display).
  Future<List<SyncConflict>> getRecentConflicts({
    int days = 7,
    int limit = 50,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.syncConflicts)
          ..where((t) => t.detectedAt.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)])
          ..limit(limit))
        .get();
  }
}
