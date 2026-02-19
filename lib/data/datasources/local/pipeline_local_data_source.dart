import 'package:drift/drift.dart';

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';

/// Local data source for pipeline operations.
/// Handles all local database operations for pipelines.
class PipelineLocalDataSource {
  PipelineLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Read Operations
  // ==========================================

  /// Watch all non-deleted pipelines as a reactive stream.
  Stream<List<Pipeline>> watchAllPipelines() {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.watch();
  }

  /// Watch pipelines with pagination support.
  /// Returns a reactive stream limited to [limit] items.
  /// Optionally filters by [searchQuery] on code.
  Stream<List<Pipeline>> watchPipelinesPaginated({
    required int limit,
    String? searchQuery,
  }) {
    var query = _db.select(_db.pipelines)..where((p) => p.deletedAt.isNull());

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final pattern = '%${searchQuery.toLowerCase()}%';
      query = query..where((p) => p.code.lower().like(pattern));
    }

    query = query
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
      ..limit(limit);

    return query.watch();
  }

  /// Get count of pipelines, optionally filtered by search query.
  /// Used for pagination "hasMore" calculation.
  Future<int> getPipelineCount({String? searchQuery}) async {
    if (searchQuery == null || searchQuery.isEmpty) {
      return _db.pipelines
          .count(where: (p) => p.deletedAt.isNull())
          .getSingle();
    }

    final pattern = '%${searchQuery.toLowerCase()}%';
    return _db.pipelines
        .count(
          where: (p) => p.deletedAt.isNull() & p.code.lower().like(pattern),
        )
        .getSingle();
  }

  /// Watch pipelines for a specific customer.
  Stream<List<Pipeline>> watchCustomerPipelines(String customerId) {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.customerId.equals(customerId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.watch();
  }

  /// Watch pipelines by stage.
  Stream<List<Pipeline>> watchPipelinesByStage(String stageId) {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.stageId.equals(stageId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.watch();
  }

  /// Get all non-deleted pipelines.
  Future<List<Pipeline>> getAllPipelines() async {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.get();
  }

  /// Get a specific pipeline by ID.
  Future<Pipeline?> getPipelineById(String id) async {
    final query = _db.select(_db.pipelines)..where((p) => p.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Watch a specific pipeline by ID as a reactive stream.
  Stream<Pipeline?> watchPipelineById(String id) {
    final query = _db.select(_db.pipelines)..where((p) => p.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Watch pipelines where the broker is the source.
  Stream<List<Pipeline>> watchBrokerPipelines(String brokerId) {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.brokerId.equals(brokerId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.watch();
  }

  /// Get a pipeline by code.
  Future<Pipeline?> getPipelineByCode(String code) async {
    final query = _db.select(_db.pipelines)..where((p) => p.code.equals(code));
    return query.getSingleOrNull();
  }

  /// Get pipelines for a specific customer.
  Future<List<Pipeline>> getCustomerPipelines(String customerId) async {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.customerId.equals(customerId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.get();
  }

  // ==========================================
  // Write Operations
  // ==========================================

  /// Insert a new pipeline.
  Future<void> insertPipeline(PipelinesCompanion pipeline) =>
      _db.into(_db.pipelines).insert(pipeline);

  /// Update an existing pipeline.
  Future<void> updatePipeline(String id, PipelinesCompanion pipeline) =>
      (_db.update(_db.pipelines)..where((p) => p.id.equals(id))).write(pipeline);

  /// Soft delete a pipeline (set deletedAt).
  Future<void> softDeletePipeline(String id) async {
    await (_db.update(_db.pipelines)..where((p) => p.id.equals(id))).write(
      PipelinesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Batch soft-delete all pipelines belonging to a customer.
  /// Used for cascade deletion when a customer is deleted.
  Future<void> softDeleteByCustomerId(String customerId) async {
    final now = DateTime.now();
    await (_db.update(_db.pipelines)
          ..where(
              (p) => p.customerId.equals(customerId) & p.deletedAt.isNull()))
        .write(
      PipelinesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Hard delete a pipeline (permanent removal).
  Future<int> hardDeletePipeline(String id) =>
      (_db.delete(_db.pipelines)..where((p) => p.id.equals(id))).go();

  // ==========================================
  // Search & Filter
  // ==========================================

  /// Search pipelines by code.
  Future<List<Pipeline>> searchPipelines(String query) async {
    final searchPattern = '%${query.toLowerCase()}%';
    final selectQuery = _db.select(_db.pipelines)
      ..where((p) =>
          p.deletedAt.isNull() & p.code.lower().like(searchPattern))
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return selectQuery.get();
  }

  /// Get pipelines by assigned RM.
  Future<List<Pipeline>> getPipelinesByAssignedRm(String rmId) async {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.assignedRmId.equals(rmId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.get();
  }

  /// Get pipelines by stage.
  Future<List<Pipeline>> getPipelinesByStage(String stageId) async {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.stageId.equals(stageId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.get();
  }

  /// Get pipelines where the broker is the source.
  Future<List<Pipeline>> getBrokerPipelines(String brokerId) async {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.brokerId.equals(brokerId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.get();
  }

  /// Get pipelines that need to be synced.
  Future<List<Pipeline>> getPendingSyncPipelines() async {
    final query = _db.select(_db.pipelines)
      ..where((p) => p.isPendingSync.equals(true))
      ..orderBy([(p) => OrderingTerm.asc(p.updatedAt)]);
    return query.get();
  }

  // ==========================================
  // Master Data Operations
  // ==========================================

  /// Get all active pipeline stages ordered by sequence.
  Future<List<PipelineStage>> getPipelineStages() async {
    final query = _db.select(_db.pipelineStages)
      ..where((s) => s.isActive.equals(true))
      ..orderBy([(s) => OrderingTerm.asc(s.sequence)]);
    return query.get();
  }

  /// Get pipeline statuses for a specific stage.
  Future<List<PipelineStatuse>> getPipelineStatuses({String? stageId}) async {
    var query = _db.select(_db.pipelineStatuses)
      ..where((s) => s.isActive.equals(true))
      ..orderBy([(s) => OrderingTerm.asc(s.sequence)]);

    if (stageId != null) {
      query = _db.select(_db.pipelineStatuses)
        ..where((s) => s.isActive.equals(true) & s.stageId.equals(stageId))
        ..orderBy([(s) => OrderingTerm.asc(s.sequence)]);
    }

    return query.get();
  }

  /// Get a specific stage by ID.
  Future<PipelineStage?> getStageById(String id) async {
    final query = _db.select(_db.pipelineStages)
      ..where((s) => s.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Get default status for a stage.
  Future<PipelineStatuse?> getDefaultStatus(String stageId) async {
    final query = _db.select(_db.pipelineStatuses)
      ..where((s) =>
          s.stageId.equals(stageId) &
          s.isActive.equals(true) &
          s.isDefault.equals(true));
    return query.getSingleOrNull();
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Mark a pipeline as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.pipelines)..where((p) => p.id.equals(id))).write(
      PipelinesCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Upsert multiple pipelines from remote sync.
  /// Skips records where local copy has isPendingSync=true (pending local changes).
  Future<void> upsertPipelines(List<PipelinesCompanion> pipelines) async {
    if (pipelines.isEmpty) return;

    // Get IDs of records with pending local changes
    final pendingIds = await (_db.selectOnly(_db.pipelines)
          ..addColumns([_db.pipelines.id])
          ..where(_db.pipelines.isPendingSync.equals(true)))
        .map((row) => row.read(_db.pipelines.id)!)
        .get();

    final pendingIdSet = pendingIds.toSet();

    // Filter out records that have pending local changes
    final safeToUpsert = pipelines.where((p) {
      final id = p.id.value;
      return !pendingIdSet.contains(id);
    }).toList();

    if (safeToUpsert.length < pipelines.length) {
      final skipped = pipelines.length - safeToUpsert.length;
      AppLogger.instance.debug(
        'sync.pull | Skipped $skipped pipelines with pending local changes',
      );
    }

    if (safeToUpsert.isEmpty) return;

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.pipelines, safeToUpsert);
    });
  }

  /// Get count of pipelines that need sync.
  Future<int> getPendingSyncCount() => _db.pipelines
      .count(where: (p) => p.isPendingSync.equals(true))
      .getSingle();

  /// Get the last sync timestamp for pipelines.
  Future<DateTime?> getLastSyncTimestamp() async {
    final query = _db.selectOnly(_db.pipelines)
      ..addColumns([_db.pipelines.lastSyncAt.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.pipelines.lastSyncAt.max());
  }

  // ==========================================
  // Statistics
  // ==========================================

  /// Get total count of pipelines.
  Future<int> getTotalCount() =>
      _db.pipelines.count(where: (p) => p.deletedAt.isNull()).getSingle();

  /// Get count of pipelines by stage.
  Future<int> getCountByStage(String stageId) => _db.pipelines
      .count(where: (p) => p.stageId.equals(stageId) & p.deletedAt.isNull())
      .getSingle();

  /// Get count of pipelines for a customer.
  Future<int> getCustomerPipelineCount(String customerId) => _db.pipelines
      .count(
          where: (p) =>
              p.customerId.equals(customerId) & p.deletedAt.isNull())
      .getSingle();
}
