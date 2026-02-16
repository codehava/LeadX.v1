import 'package:drift/drift.dart';

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';

/// Local data source for Broker operations.
class BrokerLocalDataSource {
  BrokerLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Broker CRUD Operations
  // ==========================================

  /// Watch all active brokers as a stream.
  Stream<List<Broker>> watchAllBrokers() {
    return (_db.select(_db.brokers)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Watch brokers with pagination support.
  /// Returns a reactive stream limited to [limit] items.
  /// Optionally filters by [searchQuery] on name or code.
  Stream<List<Broker>> watchBrokersPaginated({
    required int limit,
    String? searchQuery,
  }) {
    var query = _db.select(_db.brokers)..where((t) => t.deletedAt.isNull());

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final pattern = '%${searchQuery.toLowerCase()}%';
      query = query
        ..where((t) =>
            t.name.lower().like(pattern) | t.code.lower().like(pattern));
    }

    query = query
      ..orderBy([(t) => OrderingTerm(expression: t.name)])
      ..limit(limit);

    return query.watch();
  }

  /// Get count of brokers, optionally filtered by search query.
  /// Used for pagination "hasMore" calculation.
  Future<int> getBrokerCount({String? searchQuery}) async {
    if (searchQuery == null || searchQuery.isEmpty) {
      return _db.brokers.count(where: (t) => t.deletedAt.isNull()).getSingle();
    }

    final pattern = '%${searchQuery.toLowerCase()}%';
    return _db.brokers
        .count(
          where: (t) =>
              t.deletedAt.isNull() &
              (t.name.lower().like(pattern) | t.code.lower().like(pattern)),
        )
        .getSingle();
  }

  /// Get all active brokers.
  Future<List<Broker>> getAllBrokers() async {
    return (_db.select(_db.brokers)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Get a single broker by ID.
  Future<Broker?> getBrokerById(String id) async {
    return (_db.select(_db.brokers)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watch a single broker by ID as a reactive stream.
  Stream<Broker?> watchBrokerById(String id) {
    return (_db.select(_db.brokers)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Watch pipeline count for a broker.
  Stream<int> watchBrokerPipelineCount(String brokerId) {
    return (_db.select(_db.pipelines)
          ..where((t) => t.brokerId.equals(brokerId) & t.deletedAt.isNull()))
        .watch()
        .map((list) => list.length);
  }

  /// Insert a new broker.
  Future<void> insertBroker(BrokersCompanion broker) async {
    await _db.into(_db.brokers).insert(broker);
  }

  /// Update an existing broker.
  Future<void> updateBroker(String id, BrokersCompanion companion) async {
    await (_db.update(_db.brokers)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// Soft delete a broker.
  Future<void> softDeleteBroker(String id) async {
    await (_db.update(_db.brokers)..where((t) => t.id.equals(id))).write(
      BrokersCompanion(
        deletedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Search brokers by name or code.
  Future<List<Broker>> searchBrokers(String query) async {
    final pattern = '%$query%';
    return (_db.select(_db.brokers)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.name.like(pattern) |
                  t.code.like(pattern)))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Get brokers pending sync.
  Future<List<Broker>> getPendingSyncBrokers() async {
    return (_db.select(_db.brokers)..where((t) => t.isPendingSync.equals(true)))
        .get();
  }

  /// Mark broker as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.brokers)..where((t) => t.id.equals(id))).write(
      BrokersCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Batch upsert brokers from remote.
  /// Skips records where local copy has isPendingSync=true (pending local changes).
  Future<void> upsertBrokers(List<BrokersCompanion> brokers) async {
    if (brokers.isEmpty) return;

    // Get IDs of records with pending local changes
    final pendingIds = await (_db.selectOnly(_db.brokers)
          ..addColumns([_db.brokers.id])
          ..where(_db.brokers.isPendingSync.equals(true)))
        .map((row) => row.read(_db.brokers.id)!)
        .get();

    final pendingIdSet = pendingIds.toSet();

    // Filter out records that have pending local changes
    final safeToUpsert = brokers.where((b) {
      final id = b.id.value;
      return !pendingIdSet.contains(id);
    }).toList();

    if (safeToUpsert.length < brokers.length) {
      final skipped = brokers.length - safeToUpsert.length;
      AppLogger.instance.debug(
        'sync.pull | Skipped $skipped brokers with pending local changes',
      );
    }

    if (safeToUpsert.isEmpty) return;

    await _db.batch((batch) {
      for (final broker in safeToUpsert) {
        batch.insert(_db.brokers, broker, mode: InsertMode.insertOrReplace);
      }
    });
  }

  // ==========================================
  // Key Person Operations (via broker_id)
  // ==========================================

  /// Get key persons for a broker.
  Future<List<KeyPerson>> getBrokerKeyPersons(String brokerId) async {
    return (_db.select(_db.keyPersons)
          ..where((t) =>
              t.brokerId.equals(brokerId) &
              t.ownerType.equals('BROKER') &
              t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPrimary),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Watch key persons for a broker.
  Stream<List<KeyPerson>> watchBrokerKeyPersons(String brokerId) {
    return (_db.select(_db.keyPersons)
          ..where((t) =>
              t.brokerId.equals(brokerId) &
              t.ownerType.equals('BROKER') &
              t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.isPrimary),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Get key person count for a broker.
  Future<int> getBrokerKeyPersonCount(String brokerId) async {
    final count = await (_db.select(_db.keyPersons)
          ..where((t) =>
              t.brokerId.equals(brokerId) &
              t.ownerType.equals('BROKER') &
              t.deletedAt.isNull()))
        .get();
    return count.length;
  }

  // ==========================================
  // Pipeline Operations (via broker_id)
  // ==========================================

  /// Get pipelines associated with a broker.
  Future<List<Pipeline>> getBrokerPipelines(String brokerId) async {
    return (_db.select(_db.pipelines)
          ..where(
              (t) => t.brokerId.equals(brokerId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  /// Get pipeline count for a broker.
  Future<int> getBrokerPipelineCount(String brokerId) async {
    final count = await (_db.select(_db.pipelines)
          ..where(
              (t) => t.brokerId.equals(brokerId) & t.deletedAt.isNull()))
        .get();
    return count.length;
  }
}
