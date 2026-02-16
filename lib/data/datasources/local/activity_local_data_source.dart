import 'package:drift/drift.dart';

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';

/// Local data source for activity operations.
/// Handles all local database operations for activities.
class ActivityLocalDataSource {
  ActivityLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Read Operations - Watch
  // ==========================================

  /// Watch all non-deleted activities as a reactive stream.
  Stream<List<Activity>> watchAllActivities() {
    final query = _db.select(_db.activities)
      ..where((a) => a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.watch();
  }

  /// Watch activities for a specific user within a date range.
  Stream<List<Activity>> watchUserActivities(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.userId.equals(userId) &
          a.deletedAt.isNull() &
          a.scheduledDatetime.isBiggerOrEqualValue(startDate) &
          a.scheduledDatetime.isSmallerOrEqualValue(endDate))
      ..orderBy([(a) => OrderingTerm.asc(a.scheduledDatetime)]);
    return query.watch();
  }

  /// Watch activities for a specific customer.
  Stream<List<Activity>> watchCustomerActivities(String customerId) {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.customerId.equals(customerId) &
          a.objectType.equals('CUSTOMER') &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.watch();
  }

  /// Watch activities for a specific HVC.
  Stream<List<Activity>> watchHvcActivities(String hvcId) {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.hvcId.equals(hvcId) &
          a.objectType.equals('HVC') &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.watch();
  }

  /// Watch activities for a specific broker.
  Stream<List<Activity>> watchBrokerActivities(String brokerId) {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.brokerId.equals(brokerId) &
          a.objectType.equals('BROKER') &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.watch();
  }

  /// Watch today's activities for a user.
  Stream<List<Activity>> watchTodayActivities(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return watchUserActivities(userId, startOfDay, endOfDay);
  }

  // ==========================================
  // Read Operations - Get
  // ==========================================

  /// Get all non-deleted activities.
  Future<List<Activity>> getAllActivities() async {
    final query = _db.select(_db.activities)
      ..where((a) => a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.get();
  }

  /// Get a specific activity by ID.
  Future<Activity?> getActivityById(String id) async {
    final query = _db.select(_db.activities)..where((a) => a.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Watch a specific activity by ID as a reactive stream.
  Stream<Activity?> watchActivityById(String id) {
    final query = _db.select(_db.activities)..where((a) => a.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Watch photos for an activity as a reactive stream.
  Stream<List<ActivityPhoto>> watchActivityPhotos(String activityId) {
    final query = _db.select(_db.activityPhotos)
      ..where((p) => p.activityId.equals(activityId))
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.watch();
  }

  /// Watch audit logs for an activity as a reactive stream.
  Stream<List<ActivityAuditLog>> watchAuditLogs(String activityId) {
    final query = _db.select(_db.activityAuditLogs)
      ..where((l) => l.activityId.equals(activityId))
      ..orderBy([(l) => OrderingTerm.desc(l.performedAt)]);
    return query.watch();
  }

  /// Get activities for a specific user within a date range.
  Future<List<Activity>> getUserActivities(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.userId.equals(userId) &
          a.deletedAt.isNull() &
          a.scheduledDatetime.isBiggerOrEqualValue(startDate) &
          a.scheduledDatetime.isSmallerOrEqualValue(endDate))
      ..orderBy([(a) => OrderingTerm.asc(a.scheduledDatetime)]);
    return query.get();
  }

  /// Get activities for a specific customer.
  Future<List<Activity>> getCustomerActivities(String customerId) async {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.customerId.equals(customerId) &
          a.objectType.equals('CUSTOMER') &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.get();
  }

  /// Get activities for a specific HVC.
  Future<List<Activity>> getHvcActivities(String hvcId) async {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.hvcId.equals(hvcId) & a.objectType.equals('HVC') & a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.get();
  }

  /// Get activities for a specific broker.
  Future<List<Activity>> getBrokerActivities(String brokerId) async {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.brokerId.equals(brokerId) &
          a.objectType.equals('BROKER') &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.desc(a.scheduledDatetime)]);
    return query.get();
  }

  /// Get activities by status.
  Future<List<Activity>> getActivitiesByStatus(String userId, String status) async {
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.userId.equals(userId) &
          a.status.equals(status) &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.asc(a.scheduledDatetime)]);
    return query.get();
  }

  /// Get overdue activities (planned activities past scheduled time).
  Future<List<Activity>> getOverdueActivities(String userId) async {
    final now = DateTime.now();
    final query = _db.select(_db.activities)
      ..where((a) =>
          a.userId.equals(userId) &
          a.status.equals('PLANNED') &
          a.scheduledDatetime.isSmallerThanValue(now) &
          a.deletedAt.isNull())
      ..orderBy([(a) => OrderingTerm.asc(a.scheduledDatetime)]);
    return query.get();
  }

  // ==========================================
  // Write Operations
  // ==========================================

  /// Insert a new activity.
  Future<void> insertActivity(ActivitiesCompanion activity) =>
      _db.into(_db.activities).insert(activity);

  /// Update an existing activity.
  Future<void> updateActivity(String id, ActivitiesCompanion activity) =>
      (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(activity);

  /// Soft delete an activity (set deletedAt).
  Future<void> softDeleteActivity(String id) async {
    await (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(
      ActivitiesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
      ),
    );
  }

  /// Hard delete an activity (permanent removal).
  Future<int> hardDeleteActivity(String id) =>
      (_db.delete(_db.activities)..where((a) => a.id.equals(id))).go();

  // ==========================================
  // Photo Operations
  // ==========================================

  /// Get photos for an activity.
  Future<List<ActivityPhoto>> getActivityPhotos(String activityId) async {
    final query = _db.select(_db.activityPhotos)
      ..where((p) => p.activityId.equals(activityId))
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);
    return query.get();
  }

  /// Get a specific photo by ID.
  Future<ActivityPhoto?> getPhotoById(String id) async {
    final query = _db.select(_db.activityPhotos)
      ..where((p) => p.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Insert a new activity photo or replace if exists.
  Future<void> insertPhoto(ActivityPhotosCompanion photo) =>
      _db.into(_db.activityPhotos).insert(
        photo,
        mode: InsertMode.insertOrReplace,
      );

  /// Update a photo.
  Future<void> updatePhoto(String id, ActivityPhotosCompanion photo) =>
      (_db.update(_db.activityPhotos)..where((p) => p.id.equals(id))).write(photo);

  /// Delete a photo.
  Future<int> deletePhoto(String id) =>
      (_db.delete(_db.activityPhotos)..where((p) => p.id.equals(id))).go();

  /// Get photos pending upload.
  Future<List<ActivityPhoto>> getPendingUploadPhotos() async {
    final query = _db.select(_db.activityPhotos)
      ..where((p) => p.isPendingUpload.equals(true));
    return query.get();
  }

  /// Mark photo as uploaded.
  Future<void> markPhotoAsUploaded(String id, String photoUrl) async {
    await (_db.update(_db.activityPhotos)..where((p) => p.id.equals(id))).write(
      ActivityPhotosCompanion(
        photoUrl: Value(photoUrl),
        isPendingUpload: const Value(false),
      ),
    );
  }

  // ==========================================
  // Audit Log Operations
  // ==========================================

  /// Insert an audit log entry.
  Future<void> insertAuditLog(ActivityAuditLogsCompanion log) =>
      _db.into(_db.activityAuditLogs).insert(log);

  /// Get audit logs for an activity.
  Future<List<ActivityAuditLog>> getAuditLogs(String activityId) async {
    final query = _db.select(_db.activityAuditLogs)
      ..where((l) => l.activityId.equals(activityId))
      ..orderBy([(l) => OrderingTerm.desc(l.performedAt)]);
    return query.get();
  }

  /// Get audit logs that haven't been synced yet.
  Future<List<ActivityAuditLog>> getPendingSyncAuditLogs() async {
    final query = _db.select(_db.activityAuditLogs)
      ..where((l) => l.isSynced.equals(false))
      ..orderBy([(l) => OrderingTerm.asc(l.performedAt)]);
    return query.get();
  }

  /// Get unsynced audit logs for a specific activity.
  Future<List<ActivityAuditLog>> getPendingSyncAuditLogsForActivity(String activityId) async {
    final query = _db.select(_db.activityAuditLogs)
      ..where((l) => l.activityId.equals(activityId) & l.isSynced.equals(false))
      ..orderBy([(l) => OrderingTerm.asc(l.performedAt)]);
    return query.get();
  }

  /// Mark an audit log as synced.
  Future<void> markAuditLogAsSynced(String id) =>
      (_db.update(_db.activityAuditLogs)..where((l) => l.id.equals(id)))
          .write(const ActivityAuditLogsCompanion(isSynced: Value(true)));

  /// Mark multiple audit logs as synced.
  Future<void> markAuditLogsAsSynced(List<String> ids) async {
    await (_db.update(_db.activityAuditLogs)
          ..where((l) => l.id.isIn(ids)))
        .write(const ActivityAuditLogsCompanion(isSynced: Value(true)));
  }

  // ==========================================
  // Master Data Operations
  // ==========================================

  /// Get all active activity types.
  Future<List<ActivityType>> getActivityTypes() async {
    final query = _db.select(_db.activityTypes)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.get();
  }

  /// Get a specific activity type by ID.
  Future<ActivityType?> getActivityTypeById(String id) async {
    final query = _db.select(_db.activityTypes)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Mark an activity as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(
      ActivitiesCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Get activities that need to be synced.
  Future<List<Activity>> getPendingSyncActivities() async {
    final query = _db.select(_db.activities)
      ..where((a) => a.isPendingSync.equals(true))
      ..orderBy([(a) => OrderingTerm.asc(a.updatedAt)]);
    return query.get();
  }

  /// Upsert multiple activities from remote sync.
  /// Skips records where local copy has isPendingSync=true (pending local changes).
  Future<void> upsertActivities(List<ActivitiesCompanion> activities) async {
    if (activities.isEmpty) return;

    // Get IDs of records with pending local changes
    final pendingIds = await (_db.selectOnly(_db.activities)
          ..addColumns([_db.activities.id])
          ..where(_db.activities.isPendingSync.equals(true)))
        .map((row) => row.read(_db.activities.id)!)
        .get();

    final pendingIdSet = pendingIds.toSet();

    // Filter out records that have pending local changes
    final safeToUpsert = activities.where((a) {
      final id = a.id.value;
      return !pendingIdSet.contains(id);
    }).toList();

    if (safeToUpsert.length < activities.length) {
      final skipped = activities.length - safeToUpsert.length;
      AppLogger.instance.debug(
        'sync.pull | Skipped $skipped activities with pending local changes',
      );
    }

    if (safeToUpsert.isEmpty) return;

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.activities, safeToUpsert);
    });
  }

  /// Get count of activities that need sync.
  Future<int> getPendingSyncCount() => _db.activities
      .count(where: (a) => a.isPendingSync.equals(true))
      .getSingle();

  /// Get the last sync timestamp for activities.
  Future<DateTime?> getLastSyncTimestamp() async {
    final query = _db.selectOnly(_db.activities)
      ..addColumns([_db.activities.lastSyncAt.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(_db.activities.lastSyncAt.max());
  }

  // ==========================================
  // Statistics
  // ==========================================

  /// Get total count of activities.
  Future<int> getTotalCount() =>
      _db.activities.count(where: (a) => a.deletedAt.isNull()).getSingle();

  /// Get count of activities by status.
  Future<int> getCountByStatus(String userId, String status) => _db.activities
      .count(where: (a) =>
          a.userId.equals(userId) &
          a.status.equals(status) &
          a.deletedAt.isNull())
      .getSingle();

  /// Get count of activities for a customer.
  Future<int> getCustomerActivityCount(String customerId) => _db.activities
      .count(where: (a) =>
          a.customerId.equals(customerId) &
          a.objectType.equals('CUSTOMER') &
          a.deletedAt.isNull())
      .getSingle();

  /// Get count of completed activities in a date range.
  Future<int> getCompletedCountInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) =>
      _db.activities
          .count(where: (a) =>
              a.userId.equals(userId) &
              a.status.equals('COMPLETED') &
              a.executedAt.isBiggerOrEqualValue(startDate) &
              a.executedAt.isSmallerOrEqualValue(endDate) &
              a.deletedAt.isNull())
          .getSingle();
}
