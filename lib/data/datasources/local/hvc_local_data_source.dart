import 'package:drift/drift.dart';

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';

/// Local data source for HVC operations.
class HvcLocalDataSource {
  HvcLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // HVC CRUD Operations
  // ==========================================

  /// Watch all active HVCs as a stream.
  Stream<List<Hvc>> watchAllHvcs() {
    return (_db.select(_db.hvcs)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Watch HVCs with pagination support.
  /// Returns a reactive stream limited to [limit] items.
  /// Optionally filters by [searchQuery] on name or code.
  Stream<List<Hvc>> watchHvcsPaginated({
    required int limit,
    String? searchQuery,
  }) {
    var query = _db.select(_db.hvcs)..where((t) => t.deletedAt.isNull());

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

  /// Get count of HVCs, optionally filtered by search query.
  /// Used for pagination "hasMore" calculation.
  Future<int> getHvcCount({String? searchQuery}) async {
    if (searchQuery == null || searchQuery.isEmpty) {
      return _db.hvcs.count(where: (t) => t.deletedAt.isNull()).getSingle();
    }

    final pattern = '%${searchQuery.toLowerCase()}%';
    return _db.hvcs
        .count(
          where: (t) =>
              t.deletedAt.isNull() &
              (t.name.lower().like(pattern) | t.code.lower().like(pattern)),
        )
        .getSingle();
  }

  /// Get all active HVCs.
  Future<List<Hvc>> getAllHvcs() async {
    return (_db.select(_db.hvcs)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Get a single HVC by ID.
  Future<Hvc?> getHvcById(String id) async {
    return (_db.select(_db.hvcs)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watch a single HVC by ID as a reactive stream.
  Stream<Hvc?> watchHvcById(String id) {
    return (_db.select(_db.hvcs)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Insert a new HVC.
  Future<void> insertHvc(HvcsCompanion hvc) async {
    await _db.into(_db.hvcs).insert(hvc);
  }

  /// Update an existing HVC.
  Future<void> updateHvc(String id, HvcsCompanion companion) async {
    await (_db.update(_db.hvcs)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  /// Soft delete an HVC.
  Future<void> softDeleteHvc(String id) async {
    await (_db.update(_db.hvcs)..where((t) => t.id.equals(id))).write(
      HvcsCompanion(
        deletedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Search HVCs by name or code.
  Future<List<Hvc>> searchHvcs(String query) async {
    final pattern = '%$query%';
    return (_db.select(_db.hvcs)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.name.like(pattern) | t.code.like(pattern)))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Get HVCs pending sync.
  Future<List<Hvc>> getPendingSyncHvcs() async {
    return (_db.select(_db.hvcs)..where((t) => t.isPendingSync.equals(true)))
        .get();
  }

  /// Mark HVC as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.hvcs)..where((t) => t.id.equals(id))).write(
      HvcsCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Batch upsert HVCs from remote.
  /// Skips records where local copy has isPendingSync=true (pending local changes).
  Future<void> upsertHvcs(List<HvcsCompanion> hvcs) async {
    if (hvcs.isEmpty) return;

    // Get IDs of records with pending local changes
    final pendingIds = await (_db.selectOnly(_db.hvcs)
          ..addColumns([_db.hvcs.id])
          ..where(_db.hvcs.isPendingSync.equals(true)))
        .map((row) => row.read(_db.hvcs.id)!)
        .get();

    final pendingIdSet = pendingIds.toSet();

    // Filter out records that have pending local changes
    final safeToUpsert = hvcs.where((h) {
      final id = h.id.value;
      return !pendingIdSet.contains(id);
    }).toList();

    if (safeToUpsert.length < hvcs.length) {
      final skipped = hvcs.length - safeToUpsert.length;
      AppLogger.instance.debug(
        'sync.pull | Skipped $skipped HVCs with pending local changes',
      );
    }

    if (safeToUpsert.isEmpty) return;

    await _db.batch((batch) {
      for (final hvc in safeToUpsert) {
        batch.insert(_db.hvcs, hvc, mode: InsertMode.insertOrReplace);
      }
    });
  }

  // ==========================================
  // HVC Type Operations (Master Data)
  // ==========================================

  /// Get all active HVC types.
  Future<List<HvcType>> getHvcTypes() async {
    return (_db.select(_db.hvcTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Get a single HVC type by ID.
  Future<HvcType?> getHvcTypeById(String id) async {
    return (_db.select(_db.hvcTypes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // ==========================================
  // Customer-HVC Link Operations
  // ==========================================

  /// Watch all links for a specific HVC.
  Stream<List<CustomerHvcLink>> watchLinkedCustomers(String hvcId) {
    return (_db.select(_db.customerHvcLinks)
          ..where((t) => t.hvcId.equals(hvcId) & t.deletedAt.isNull()))
        .watch();
  }

  /// Get all linked customers for an HVC.
  Future<List<CustomerHvcLink>> getLinkedCustomers(String hvcId) async {
    return (_db.select(_db.customerHvcLinks)
          ..where((t) => t.hvcId.equals(hvcId) & t.deletedAt.isNull()))
        .get();
  }

  /// Get all HVCs linked to a customer.
  Future<List<CustomerHvcLink>> getCustomerHvcs(String customerId) async {
    return (_db.select(_db.customerHvcLinks)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull()))
        .get();
  }

  /// Watch all HVCs linked to a customer.
  Stream<List<CustomerHvcLink>> watchCustomerHvcs(String customerId) {
    return (_db.select(_db.customerHvcLinks)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull()))
        .watch();
  }

  /// Insert a new customer-HVC link.
  Future<void> insertCustomerHvcLink(CustomerHvcLinksCompanion link) async {
    await _db.into(_db.customerHvcLinks).insert(link);
  }

  /// Get a link by ID.
  Future<CustomerHvcLink?> getCustomerHvcLinkById(String id) async {
    return (_db.select(_db.customerHvcLinks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Soft delete a customer-HVC link.
  Future<void> deleteCustomerHvcLink(String id) async {
    await (_db.update(_db.customerHvcLinks)..where((t) => t.id.equals(id)))
        .write(
      CustomerHvcLinksCompanion(
        deletedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Check if link exists between customer and HVC.
  Future<bool> linkExists(String customerId, String hvcId) async {
    final link = await (_db.select(_db.customerHvcLinks)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.hvcId.equals(hvcId) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
    return link != null;
  }

  /// Batch upsert customer-HVC links from remote.
  /// Skips records where local copy has isPendingSync=true (pending local changes).
  Future<void> upsertCustomerHvcLinks(
      List<CustomerHvcLinksCompanion> links) async {
    if (links.isEmpty) return;

    // Get IDs of records with pending local changes
    final pendingIds = await (_db.selectOnly(_db.customerHvcLinks)
          ..addColumns([_db.customerHvcLinks.id])
          ..where(_db.customerHvcLinks.isPendingSync.equals(true)))
        .map((row) => row.read(_db.customerHvcLinks.id)!)
        .get();

    final pendingIdSet = pendingIds.toSet();

    // Filter out records that have pending local changes
    final safeToUpsert = links.where((l) {
      final id = l.id.value;
      return !pendingIdSet.contains(id);
    }).toList();

    if (safeToUpsert.length < links.length) {
      final skipped = links.length - safeToUpsert.length;
      AppLogger.instance.debug(
        'sync.pull | Skipped $skipped customer-HVC links with pending local changes',
      );
    }

    if (safeToUpsert.isEmpty) return;

    await _db.batch((batch) {
      for (final link in safeToUpsert) {
        batch.insert(_db.customerHvcLinks, link, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Get links pending sync.
  Future<List<CustomerHvcLink>> getPendingSyncLinks() async {
    return (_db.select(_db.customerHvcLinks)
          ..where((t) => t.isPendingSync.equals(true)))
        .get();
  }

  /// Mark link as synced.
  Future<void> markLinkAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.customerHvcLinks)..where((t) => t.id.equals(id)))
        .write(
      CustomerHvcLinksCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Get linked customer count for an HVC.
  Future<int> getLinkedCustomerCount(String hvcId) async {
    final count = await (_db.select(_db.customerHvcLinks)
          ..where((t) => t.hvcId.equals(hvcId) & t.deletedAt.isNull()))
        .get();
    return count.length;
  }
}
