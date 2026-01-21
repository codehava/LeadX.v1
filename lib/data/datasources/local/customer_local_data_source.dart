import 'package:drift/drift.dart';

import '../../database/app_database.dart';

/// Local data source for customer operations.
/// Handles all local database operations for customers.
class CustomerLocalDataSource {
  CustomerLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Read Operations
  // ==========================================

  /// Watch all non-deleted customers as a reactive stream.
  Stream<List<Customer>> watchAllCustomers() {
    final query = _db.select(_db.customers)
      ..where((c) => c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.watch();
  }

  /// Watch customers assigned to a specific RM.
  Stream<List<Customer>> watchCustomersByRm(String rmId) {
    final query = _db.select(_db.customers)
      ..where((c) => c.assignedRmId.equals(rmId) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.watch();
  }

  /// Get all non-deleted customers.
  Future<List<Customer>> getAllCustomers() async {
    final query = _db.select(_db.customers)
      ..where((c) => c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.get();
  }

  /// Get a specific customer by ID.
  Future<Customer?> getCustomerById(String id) async {
    final query = _db.select(_db.customers)
      ..where((c) => c.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Get a customer by code.
  Future<Customer?> getCustomerByCode(String code) async {
    final query = _db.select(_db.customers)
      ..where((c) => c.code.equals(code));
    return query.getSingleOrNull();
  }

  // ==========================================
  // Write Operations
  // ==========================================

  /// Insert a new customer.
  Future<void> insertCustomer(CustomersCompanion customer) =>
      _db.into(_db.customers).insert(customer);

  /// Update an existing customer.
  Future<void> updateCustomer(String id, CustomersCompanion customer) =>
      (_db.update(_db.customers)..where((c) => c.id.equals(id)))
          .write(customer);

  /// Soft delete a customer (set deletedAt).
  Future<void> softDeleteCustomer(String id) async {
    await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
      CustomersCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Hard delete a customer (permanent removal).
  Future<int> hardDeleteCustomer(String id) =>
      (_db.delete(_db.customers)..where((c) => c.id.equals(id))).go();

  // ==========================================
  // Search & Filter
  // ==========================================

  /// Search customers by name, code, or address.
  Future<List<Customer>> searchCustomers(String query) async {
    final searchPattern = '%${query.toLowerCase()}%';
    final selectQuery = _db.select(_db.customers)
      ..where((c) =>
          c.deletedAt.isNull() &
          (c.name.lower().like(searchPattern) |
              c.code.lower().like(searchPattern) |
              c.address.lower().like(searchPattern)))
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return selectQuery.get();
  }

  /// Get customers by assigned RM.
  Future<List<Customer>> getCustomersByAssignedRm(String rmId) async {
    final query = _db.select(_db.customers)
      ..where((c) => c.assignedRmId.equals(rmId) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.get();
  }

  /// Get customers that need to be synced.
  Future<List<Customer>> getPendingSyncCustomers() async {
    final query = _db.select(_db.customers)
      ..where((c) => c.isPendingSync.equals(true))
      ..orderBy([(c) => OrderingTerm.asc(c.updatedAt)]);
    return query.get();
  }

  /// Get active customers only.
  Future<List<Customer>> getActiveCustomers() async {
    final query = _db.select(_db.customers)
      ..where((c) => c.isActive.equals(true) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.get();
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Mark a customer as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
      CustomersCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Upsert multiple customers from remote sync.
  /// Uses conflict resolution to update existing records.
  Future<void> upsertCustomers(List<CustomersCompanion> customers) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.customers, customers);
    });
  }

  /// Get count of customers that need sync.
  Future<int> getPendingSyncCount() => _db.customers
      .count(where: (c) => c.isPendingSync.equals(true))
      .getSingle();

  /// Get the last sync timestamp for customers.
  Future<DateTime?> getLastSyncTimestamp() async {
    final query = _db.selectOnly(_db.customers)
      ..addColumns([_db.customers.lastSyncAt.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.customers.lastSyncAt.max());
  }

  // ==========================================
  // Statistics
  // ==========================================

  /// Get total count of customers.
  Future<int> getTotalCount() =>
      _db.customers.count(where: (c) => c.deletedAt.isNull()).getSingle();

  /// Get count of active customers.
  Future<int> getActiveCount() => _db.customers
      .count(where: (c) => c.isActive.equals(true) & c.deletedAt.isNull())
      .getSingle();
}
