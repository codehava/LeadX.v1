import 'package:drift/drift.dart';

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';

/// Local data source for key person operations.
/// Handles all local database operations for key persons.
class KeyPersonLocalDataSource {
  KeyPersonLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Read Operations
  // ==========================================

  /// Get all key persons for a customer.
  Future<List<KeyPerson>> getKeyPersonsByCustomer(String customerId) async {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.customerId.equals(customerId) &
          kp.ownerType.equals('CUSTOMER') &
          kp.deletedAt.isNull())
      ..orderBy([
        (kp) => OrderingTerm.desc(kp.isPrimary),
        (kp) => OrderingTerm.asc(kp.name),
      ]);
    return query.get();
  }

  /// Watch all key persons for a customer as a reactive stream.
  Stream<List<KeyPerson>> watchKeyPersonsByCustomer(String customerId) {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.customerId.equals(customerId) &
          kp.ownerType.equals('CUSTOMER') &
          kp.deletedAt.isNull())
      ..orderBy([
        (kp) => OrderingTerm.desc(kp.isPrimary),
        (kp) => OrderingTerm.asc(kp.name),
      ]);
    return query.watch();
  }

  /// Get all key persons for an HVC.
  Future<List<KeyPerson>> getKeyPersonsByHvc(String hvcId) async {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.hvcId.equals(hvcId) &
          kp.ownerType.equals('HVC') &
          kp.deletedAt.isNull())
      ..orderBy([
        (kp) => OrderingTerm.desc(kp.isPrimary),
        (kp) => OrderingTerm.asc(kp.name),
      ]);
    return query.get();
  }

  /// Watch all key persons for an HVC as a reactive stream.
  Stream<List<KeyPerson>> watchKeyPersonsByHvc(String hvcId) {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.hvcId.equals(hvcId) &
          kp.ownerType.equals('HVC') &
          kp.deletedAt.isNull())
      ..orderBy([
        (kp) => OrderingTerm.desc(kp.isPrimary),
        (kp) => OrderingTerm.asc(kp.name),
      ]);
    return query.watch();
  }

  /// Get all key persons for a broker.
  Future<List<KeyPerson>> getKeyPersonsByBroker(String brokerId) async {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.brokerId.equals(brokerId) &
          kp.ownerType.equals('BROKER') &
          kp.deletedAt.isNull())
      ..orderBy([
        (kp) => OrderingTerm.desc(kp.isPrimary),
        (kp) => OrderingTerm.asc(kp.name),
      ]);
    return query.get();
  }

  /// Get a specific key person by ID.
  Future<KeyPerson?> getKeyPersonById(String id) async {
    final query = _db.select(_db.keyPersons)
      ..where((kp) => kp.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Get the primary key person for a customer.
  Future<KeyPerson?> getPrimaryKeyPerson(String customerId) async {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.customerId.equals(customerId) &
          kp.ownerType.equals('CUSTOMER') &
          kp.isPrimary.equals(true) &
          kp.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  /// Watch the primary key person for a customer as a reactive stream.
  Stream<KeyPerson?> watchPrimaryKeyPerson(String customerId) {
    final query = _db.select(_db.keyPersons)
      ..where((kp) =>
          kp.customerId.equals(customerId) &
          kp.ownerType.equals('CUSTOMER') &
          kp.isPrimary.equals(true) &
          kp.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  // ==========================================
  // Write Operations
  // ==========================================

  /// Insert a new key person.
  Future<void> insertKeyPerson(KeyPersonsCompanion keyPerson) =>
      _db.into(_db.keyPersons).insert(keyPerson);

  /// Update an existing key person.
  Future<void> updateKeyPerson(String id, KeyPersonsCompanion keyPerson) =>
      (_db.update(_db.keyPersons)..where((kp) => kp.id.equals(id)))
          .write(keyPerson);

  /// Soft delete a key person.
  Future<void> softDeleteKeyPerson(String id) async {
    await (_db.update(_db.keyPersons)..where((kp) => kp.id.equals(id))).write(
      KeyPersonsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Batch soft-delete all key persons belonging to a customer.
  /// Used for cascade deletion when a customer is deleted.
  Future<void> softDeleteByCustomerId(String customerId) async {
    final now = DateTime.now();
    await (_db.update(_db.keyPersons)
          ..where((kp) =>
              kp.customerId.equals(customerId) & kp.deletedAt.isNull()))
        .write(
      KeyPersonsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Hard delete a key person.
  Future<int> hardDeleteKeyPerson(String id) =>
      (_db.delete(_db.keyPersons)..where((kp) => kp.id.equals(id))).go();

  /// Clear primary flag for all key persons of a customer.
  /// Used when setting a new primary key person.
  Future<void> clearPrimaryForCustomer(String customerId) async {
    await (_db.update(_db.keyPersons)
          ..where((kp) =>
              kp.customerId.equals(customerId) &
              kp.ownerType.equals('CUSTOMER')))
        .write(const KeyPersonsCompanion(
          isPrimary: Value(false),
        ));
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Get key persons that need to be synced.
  Future<List<KeyPerson>> getPendingSyncKeyPersons() async {
    final query = _db.select(_db.keyPersons)
      ..where((kp) => kp.isPendingSync.equals(true))
      ..orderBy([(kp) => OrderingTerm.asc(kp.updatedAt)]);
    return query.get();
  }

  /// Mark a key person as synced.
  Future<void> markAsSynced(String id) async {
    await (_db.update(_db.keyPersons)..where((kp) => kp.id.equals(id))).write(
      const KeyPersonsCompanion(
        isPendingSync: Value(false),
      ),
    );
  }

  /// Upsert multiple key persons from remote sync.
  /// Skips records where local copy has isPendingSync=true (pending local changes).
  Future<void> upsertKeyPersons(List<KeyPersonsCompanion> keyPersons) async {
    if (keyPersons.isEmpty) return;

    // Get IDs of records with pending local changes
    final pendingIds = await (_db.selectOnly(_db.keyPersons)
          ..addColumns([_db.keyPersons.id])
          ..where(_db.keyPersons.isPendingSync.equals(true)))
        .map((row) => row.read(_db.keyPersons.id)!)
        .get();

    final pendingIdSet = pendingIds.toSet();

    // Filter out records that have pending local changes
    final safeToUpsert = keyPersons.where((kp) {
      final id = kp.id.value;
      return !pendingIdSet.contains(id);
    }).toList();

    if (safeToUpsert.length < keyPersons.length) {
      final skipped = keyPersons.length - safeToUpsert.length;
      AppLogger.instance.debug(
        'sync.pull | Skipped $skipped key persons with pending local changes',
      );
    }

    if (safeToUpsert.isEmpty) return;

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.keyPersons, safeToUpsert);
    });
  }
}
