import 'package:drift/drift.dart';

import '../../database/app_database.dart';

/// Local data source for pipeline referral operations.
/// Handles all local database operations for pipeline referrals.
class PipelineReferralLocalDataSource {
  PipelineReferralLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Read Operations
  // ==========================================

  /// Watch all referrals as a reactive stream.
  Stream<List<PipelineReferral>> watchAllReferrals() {
    final query = _db.select(_db.pipelineReferrals)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.watch();
  }

  /// Watch referrals sent by a user (outbound).
  Stream<List<PipelineReferral>> watchByReferrer(String userId) {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.referrerRmId.equals(userId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.watch();
  }

  /// Watch referrals received by a user (inbound).
  Stream<List<PipelineReferral>> watchByReceiver(String userId) {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.receiverRmId.equals(userId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.watch();
  }

  /// Watch referrals pending approval by a manager.
  /// A referral needs manager approval when status is RECEIVER_ACCEPTED.
  /// The manager must be determined by checking user hierarchy.
  Stream<List<PipelineReferral>> watchPendingApprovals() {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.status.equals('RECEIVER_ACCEPTED'))
      ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]);
    return query.watch();
  }

  /// Get all referrals.
  Future<List<PipelineReferral>> getAllReferrals() async {
    final query = _db.select(_db.pipelineReferrals)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }

  /// Get a specific referral by ID.
  Future<PipelineReferral?> getReferralById(String id) async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Watch a specific referral by ID as a reactive stream.
  Stream<PipelineReferral?> watchReferralById(String id) {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Get a referral by code.
  Future<PipelineReferral?> getReferralByCode(String code) async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.code.equals(code));
    return query.getSingleOrNull();
  }

  /// Get referrals sent by a user (outbound).
  Future<List<PipelineReferral>> getByReferrer(String userId) async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.referrerRmId.equals(userId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }

  /// Get referrals received by a user (inbound).
  Future<List<PipelineReferral>> getByReceiver(String userId) async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.receiverRmId.equals(userId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }

  /// Get referrals pending approval (RECEIVER_ACCEPTED status).
  Future<List<PipelineReferral>> getPendingApprovals() async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.status.equals('RECEIVER_ACCEPTED'))
      ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]);
    return query.get();
  }

  /// Get referrals by status.
  Future<List<PipelineReferral>> getByStatus(String status) async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.status.equals(status))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }

  /// Get referrals for a specific customer.
  Future<List<PipelineReferral>> getByCustomer(String customerId) async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.customerId.equals(customerId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }

  // ==========================================
  // Write Operations
  // ==========================================

  /// Insert a new referral.
  Future<void> insertReferral(PipelineReferralsCompanion referral) =>
      _db.into(_db.pipelineReferrals).insert(referral);

  /// Update an existing referral.
  Future<void> updateReferral(String id, PipelineReferralsCompanion referral) =>
      (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
          .write(referral);

  /// Update referral status.
  Future<void> updateStatus(String id, String status) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Mark referral as accepted by receiver.
  Future<void> markReceiverAccepted(String id, String? notes) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        status: const Value('RECEIVER_ACCEPTED'),
        receiverAcceptedAt: Value(DateTime.now()),
        receiverNotes: Value(notes),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Mark referral as rejected by receiver.
  Future<void> markReceiverRejected(String id, String reason) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        status: const Value('RECEIVER_REJECTED'),
        receiverRejectedAt: Value(DateTime.now()),
        receiverRejectReason: Value(reason),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Mark referral as approved by manager (BM/ROH).
  Future<void> markManagerApproved(
    String id,
    String approverId,
    String? notes,
  ) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        status: const Value('BM_APPROVED'),
        bmApprovedAt: Value(DateTime.now()),
        bmApprovedBy: Value(approverId),
        bmNotes: Value(notes),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Mark referral as rejected by manager (BM/ROH).
  Future<void> markManagerRejected(
    String id,
    String approverId,
    String reason,
  ) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        status: const Value('BM_REJECTED'),
        bmRejectedAt: Value(DateTime.now()),
        bmApprovedBy: Value(approverId),
        bmRejectReason: Value(reason),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Mark referral as cancelled by referrer.
  Future<void> markCancelled(String id, String reason) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        status: const Value('CANCELLED'),
        cancelledAt: Value(DateTime.now()),
        cancelReason: Value(reason),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Hard delete a referral (permanent removal).
  Future<int> hardDeleteReferral(String id) =>
      (_db.delete(_db.pipelineReferrals)..where((r) => r.id.equals(id))).go();

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Get referrals that need to be synced.
  Future<List<PipelineReferral>> getPendingSyncReferrals() async {
    final query = _db.select(_db.pipelineReferrals)
      ..where((r) => r.isPendingSync.equals(true))
      ..orderBy([(r) => OrderingTerm.asc(r.updatedAt)]);
    return query.get();
  }

  /// Mark a referral as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.pipelineReferrals)..where((r) => r.id.equals(id)))
        .write(
      PipelineReferralsCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Upsert multiple referrals from remote sync.
  Future<void> upsertReferrals(
    List<PipelineReferralsCompanion> referrals,
  ) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.pipelineReferrals, referrals);
    });
  }

  /// Get count of referrals that need sync.
  Future<int> getPendingSyncCount() => _db.pipelineReferrals
      .count(where: (r) => r.isPendingSync.equals(true))
      .getSingle();

  /// Get the last sync timestamp for referrals.
  Future<DateTime?> getLastSyncTimestamp() async {
    final query = _db.selectOnly(_db.pipelineReferrals)
      ..addColumns([_db.pipelineReferrals.lastSyncAt.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.pipelineReferrals.lastSyncAt.max());
  }

  // ==========================================
  // Statistics
  // ==========================================

  /// Get total count of referrals.
  Future<int> getTotalCount() => _db.pipelineReferrals.count().getSingle();

  /// Get count of referrals by status.
  Future<int> getCountByStatus(String status) => _db.pipelineReferrals
      .count(where: (r) => r.status.equals(status))
      .getSingle();

  /// Get count of inbound referrals pending action for a user.
  Future<int> getPendingInboundCount(String userId) => _db.pipelineReferrals
      .count(
        where: (r) =>
            r.receiverRmId.equals(userId) &
            r.status.equals('PENDING_RECEIVER'),
      )
      .getSingle();

  /// Get count of referrals pending approval (for managers).
  Future<int> getPendingApprovalCount() => _db.pipelineReferrals
      .count(where: (r) => r.status.equals('RECEIVER_ACCEPTED'))
      .getSingle();
}
