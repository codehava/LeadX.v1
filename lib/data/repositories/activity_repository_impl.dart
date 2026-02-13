import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/logging/app_logger.dart';
import '../../core/utils/date_time_utils.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/activity.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/activity_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/activity_local_data_source.dart';
import '../datasources/remote/activity_remote_data_source.dart';
import '../dtos/activity_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of ActivityRepository with offline-first pattern.
class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl({
    required ActivityLocalDataSource localDataSource,
    required ActivityRemoteDataSource remoteDataSource,
    required SyncService syncService,
    required String currentUserId,
    required db.AppDatabase database,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId,
        _database = database;

  final ActivityLocalDataSource _localDataSource;
  final ActivityRemoteDataSource _remoteDataSource;
  final SyncService _syncService;
  final String _currentUserId;
  final db.AppDatabase _database;
  final _uuid = const Uuid();
  final _log = AppLogger.instance;

  // Lookup caches for efficient name resolution
  Map<String, String>? _activityTypeNameCache;
  Map<String, String>? _activityTypeIconCache;
  Map<String, String>? _activityTypeColorCache;
  Map<String, String>? _customerNameCache;
  Map<String, String>? _hvcNameCache;
  Map<String, String>? _brokerNameCache;
  Map<String, String>? _keyPersonNameCache;

  // ==========================================
  // Watch Operations
  // ==========================================

  @override
  Stream<List<domain.Activity>> watchUserActivities(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _localDataSource
        .watchUserActivities(userId, startDate, endDate)
        .asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToActivity).toList();
    });
  }

  @override
  Stream<List<domain.Activity>> watchCustomerActivities(String customerId) {
    return _localDataSource.watchCustomerActivities(customerId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToActivity).toList();
    });
  }

  @override
  Stream<List<domain.Activity>> watchHvcActivities(String hvcId) {
    return _localDataSource.watchHvcActivities(hvcId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToActivity).toList();
    });
  }

  @override
  Stream<List<domain.Activity>> watchBrokerActivities(String brokerId) {
    return _localDataSource.watchBrokerActivities(brokerId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToActivity).toList();
    });
  }

  @override
  Stream<List<domain.Activity>> watchTodayActivities(String userId) {
    return _localDataSource.watchTodayActivities(userId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToActivity).toList();
    });
  }

  @override
  Stream<domain.Activity?> watchActivityById(String id) {
    return _localDataSource.watchActivityById(id).asyncMap((data) async {
      if (data == null) return null;
      await _ensureCachesLoaded();
      return _mapToActivity(data);
    });
  }

  @override
  Stream<domain.ActivityWithDetails?> watchActivityWithDetails(String id) {
    // Combine activity, photos, and audit logs streams into a single reactive stream
    return _localDataSource.watchActivityById(id).asyncMap((data) async {
      if (data == null) return null;
      await _ensureCachesLoaded();

      final activity = _mapToActivity(data);
      final typeData = await _localDataSource.getActivityTypeById(data.activityTypeId);
      final photos = await _localDataSource.getActivityPhotos(id);
      final logs = await _localDataSource.getAuditLogs(id);

      return domain.ActivityWithDetails(
        activity: activity,
        activityType: typeData != null ? _mapToActivityType(typeData) : null,
        photos: photos.map(_mapToActivityPhoto).toList(),
        auditLogs: logs.map(_mapToAuditLog).toList(),
      );
    });
  }

  // ==========================================
  // Get Operations
  // ==========================================

  @override
  Future<domain.Activity?> getActivityById(String id) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getActivityById(id);
    return data != null ? _mapToActivity(data) : null;
  }

  @override
  Future<domain.ActivityWithDetails?> getActivityWithDetails(String id) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getActivityById(id);
    if (data == null) return null;

    final activity = _mapToActivity(data);
    final typeData = await _localDataSource.getActivityTypeById(data.activityTypeId);
    final photos = await _localDataSource.getActivityPhotos(id);
    final logs = await _localDataSource.getAuditLogs(id);
    
    // Debug logging for photos
    _log.debug('activity | getActivityWithDetails($id): Found ${photos.length} photos');
    for (final p in photos) {
      _log.debug('activity | Photo id=${p.id}, photoUrl=${p.photoUrl}, localPath=${p.localPath}');
    }

    return domain.ActivityWithDetails(
      activity: activity,
      activityType: typeData != null ? _mapToActivityType(typeData) : null,
      photos: photos.map(_mapToActivityPhoto).toList(),
      auditLogs: logs.map(_mapToAuditLog).toList(),
    );
  }

  @override
  Future<List<domain.Activity>> getUserActivities(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getUserActivities(userId, startDate, endDate);
    return data.map(_mapToActivity).toList();
  }

  @override
  Future<List<domain.Activity>> getOverdueActivities(String userId) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getOverdueActivities(userId);
    return data.map(_mapToActivity).toList();
  }

  // ==========================================
  // Create Operations
  // ==========================================

  @override
  Future<Either<Failure, domain.Activity>> createActivity(
    ActivityCreateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();

      final companion = db.ActivitiesCompanion.insert(
        id: id,
        userId: _currentUserId,
        createdBy: _currentUserId,
        objectType: dto.objectType,
        activityTypeId: dto.activityTypeId,
        scheduledDatetime: dto.scheduledDatetime,
        customerId: Value(dto.customerId),
        hvcId: Value(dto.hvcId),
        brokerId: Value(dto.brokerId),
        summary: Value(dto.summary),
        notes: Value(dto.notes),
        status: const Value('PLANNED'),
        isImmediate: const Value(false),
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Save locally, create audit log, and queue for sync atomically
      await _database.transaction(() async {
        await _localDataSource.insertActivity(companion);

        // Insert audit log for creation
        await _insertAuditLog(
          activityId: id,
          action: 'CREATED',
          newStatus: 'PLANNED',
          latitude: dto.latitude,
          longitude: dto.longitude,
        );

        // Queue for sync
        await _syncService.queueOperation(
          entityType: SyncEntityType.activity,
          entityId: id,
          operation: SyncOperation.create,
          payload: _createSyncPayload(id, dto, now),
        );
      });

      // Trigger sync if online (outside transaction)
      _syncService.triggerSync();

      // Return the created activity
      final activity = await getActivityById(id);
      return Right(activity!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to create activity: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.Activity>> createImmediateActivity(
    ImmediateActivityDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();

      final companion = db.ActivitiesCompanion.insert(
        id: id,
        userId: _currentUserId,
        createdBy: _currentUserId,
        objectType: dto.objectType,
        activityTypeId: dto.activityTypeId,
        scheduledDatetime: now,
        customerId: Value(dto.customerId),
        hvcId: Value(dto.hvcId),
        brokerId: Value(dto.brokerId),
        summary: Value(dto.summary),
        notes: Value(dto.notes),
        status: const Value('COMPLETED'),
        isImmediate: const Value(true),
        executedAt: Value(now),
        latitude: Value(dto.latitude),
        longitude: Value(dto.longitude),
        locationAccuracy: Value(dto.locationAccuracy),
        distanceFromTarget: Value(dto.distanceFromTarget),
        isLocationOverride: Value(dto.isLocationOverride),
        overrideReason: Value(dto.overrideReason),
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Save locally, create audit log, and queue for sync atomically
      await _database.transaction(() async {
        await _localDataSource.insertActivity(companion);

        // Insert audit log
        await _insertAuditLog(
          activityId: id,
          action: 'CREATED',
          newStatus: 'COMPLETED',
          latitude: dto.latitude,
          longitude: dto.longitude,
          notes: 'Immediate activity',
        );

        // Queue for sync
        await _syncService.queueOperation(
          entityType: SyncEntityType.activity,
          entityId: id,
          operation: SyncOperation.create,
          payload: _createImmediateSyncPayload(id, dto, now),
        );
      });

      // Trigger sync if online (outside transaction)
      _syncService.triggerSync();

      final activity = await getActivityById(id);
      return Right(activity!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to create immediate activity: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Update Operations
  // ==========================================

  @override
  Future<Either<Failure, domain.Activity>> executeActivity(
    String id,
    ActivityExecutionDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final existing = await _localDataSource.getActivityById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Activity not found: $id'));
      }

      if (existing.status != 'PLANNED' && existing.status != 'OVERDUE') {
        return Left(ValidationFailure(
          message: 'Activity cannot be executed in status: ${existing.status}',
        ));
      }

      final companion = db.ActivitiesCompanion(
        status: const Value('COMPLETED'),
        executedAt: Value(now),
        latitude: Value(dto.latitude),
        longitude: Value(dto.longitude),
        locationAccuracy: Value(dto.locationAccuracy),
        distanceFromTarget: Value(dto.distanceFromTarget),
        isLocationOverride: Value(dto.isLocationOverride),
        overrideReason: dto.isLocationOverride ? Value(dto.overrideReason) : const Value.absent(),
        notes: dto.notes != null ? Value(dto.notes) : const Value.absent(),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally, create audit log, and queue for sync atomically
      final updated = await _database.transaction(() async {
        await _localDataSource.updateActivity(id, companion);

        // Insert audit log
        await _insertAuditLog(
          activityId: id,
          action: dto.isLocationOverride ? 'GPS_OVERRIDE' : 'EXECUTED',
          oldStatus: existing.status,
          newStatus: 'COMPLETED',
          latitude: dto.latitude,
          longitude: dto.longitude,
          notes: dto.overrideReason,
        );

        // Get updated data for sync payload (inside transaction)
        final data = await _localDataSource.getActivityById(id);
        if (data == null) {
          throw Exception('Activity not found: $id');
        }

        await _syncService.queueOperation(
          entityType: SyncEntityType.activity,
          entityId: id,
          operation: SyncOperation.update,
          payload: _createUpdateSyncPayload(data),
        );

        return data;
      });

      // Trigger sync if online (outside transaction)
      _syncService.triggerSync();

      return Right(_mapToActivity(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to execute activity: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.Activity>> rescheduleActivity(
    String id,
    ActivityRescheduleDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final existing = await _localDataSource.getActivityById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Activity not found: $id'));
      }

      if (existing.status != 'PLANNED' && existing.status != 'OVERDUE') {
        return Left(ValidationFailure(
          message: 'Activity cannot be rescheduled in status: ${existing.status}',
        ));
      }

      // Create new rescheduled activity
      final newId = _uuid.v4();
      final newCompanion = db.ActivitiesCompanion.insert(
        id: newId,
        userId: existing.userId,
        createdBy: _currentUserId,
        objectType: existing.objectType,
        activityTypeId: existing.activityTypeId,
        scheduledDatetime: dto.newScheduledDatetime,
        customerId: Value(existing.customerId),
        hvcId: Value(existing.hvcId),
        brokerId: Value(existing.brokerId),
        summary: Value(existing.summary),
        notes: Value(existing.notes),
        status: const Value('PLANNED'),
        isImmediate: const Value(false),
        rescheduledFromId: Value(id),
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Update original activity to RESCHEDULED
      final updateCompanion = db.ActivitiesCompanion(
        status: const Value('RESCHEDULED'),
        rescheduledToId: Value(newId),
        notes: Value('Rescheduled: ${dto.reason}'),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Create new activity, update original, audit log, and queue all atomically
      await _database.transaction(() async {
        await _localDataSource.insertActivity(newCompanion);
        await _localDataSource.updateActivity(id, updateCompanion);

        // Insert audit log
        await _insertAuditLog(
          activityId: id,
          action: 'RESCHEDULED',
          oldStatus: existing.status,
          newStatus: 'RESCHEDULED',
          notes: dto.reason,
          latitude: dto.latitude,
          longitude: dto.longitude,
        );

        // Queue CREATE for the NEW rescheduled activity FIRST
        // This ensures the new activity exists on remote before we reference it
        final newActivity = await _localDataSource.getActivityById(newId);
        if (newActivity != null) {
          await _syncService.queueOperation(
            entityType: SyncEntityType.activity,
            entityId: newId,
            operation: SyncOperation.create,
            payload: _createUpdateSyncPayload(newActivity),
          );
        }

        // Then queue UPDATE for original activity with rescheduled_to_id
        await _syncService.queueOperation(
          entityType: SyncEntityType.activity,
          entityId: id,
          operation: SyncOperation.update,
          payload: _createRescheduleSyncPayload(id, newId, 'RESCHEDULED', dto.reason, now),
        );
      });

      // Trigger sync if online (outside transaction)
      _syncService.triggerSync();

      // Return the new activity
      final activity = await getActivityById(newId);
      return Right(activity!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to reschedule activity: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> cancelActivity(String id, String reason, {double? latitude, double? longitude}) async {
    try {
      final now = DateTime.now();
      final existing = await _localDataSource.getActivityById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Activity not found: $id'));
      }

      if (existing.status != 'PLANNED' && existing.status != 'OVERDUE') {
        return Left(ValidationFailure(
          message: 'Activity cannot be cancelled in status: ${existing.status}',
        ));
      }

      final companion = db.ActivitiesCompanion(
        status: const Value('CANCELLED'),
        cancelledAt: Value(now),
        cancelReason: Value(reason),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally, create audit log, and queue for sync atomically
      await _database.transaction(() async {
        await _localDataSource.updateActivity(id, companion);

        // Insert audit log
        await _insertAuditLog(
          activityId: id,
          action: 'CANCELLED',
          oldStatus: existing.status,
          newStatus: 'CANCELLED',
          notes: reason,
          latitude: latitude,
          longitude: longitude,
        );

        // Queue for sync
        await _syncService.queueOperation(
          entityType: SyncEntityType.activity,
          entityId: id,
          operation: SyncOperation.update,
          payload: {
            'id': id,
            'status': 'CANCELLED',
            'cancelled_at': now.toUtcIso8601(),
            'cancel_reason': reason,
            'updated_at': now.toUtcIso8601(),
          },
        );
      });

      // Trigger sync if online (outside transaction)
      _syncService.triggerSync();

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to cancel activity: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Photo Operations
  // ==========================================

  @override
  Future<List<domain.ActivityPhoto>> getActivityPhotos(String activityId) async {
    final photos = await _localDataSource.getActivityPhotos(activityId);
    return photos.map(_mapToActivityPhoto).toList();
  }

  @override
  Future<Either<Failure, domain.ActivityPhoto>> addPhoto(
    String activityId,
    String localPath, {
    String? caption,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();

      final companion = db.ActivityPhotosCompanion.insert(
        id: id,
        activityId: activityId,
        photoUrl: '', // Will be updated after upload
        localPath: Value(localPath),
        caption: Value(caption),
        takenAt: Value(now),
        latitude: Value(latitude),
        longitude: Value(longitude),
        isPendingUpload: const Value(true),
        createdAt: now,
      );

      await _localDataSource.insertPhoto(companion);

      // Insert audit log
      await _insertAuditLog(
        activityId: activityId,
        action: 'PHOTO_ADDED',
        notes: caption,
        latitude: latitude,
        longitude: longitude,
      );

      final photo = (await _localDataSource.getActivityPhotos(activityId))
          .firstWhere((p) => p.id == id);

      return Right(_mapToActivityPhoto(photo));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to add photo: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deletePhoto(String photoId) async {
    try {
      // Get photo first to find activityId for audit log
      final photo = await _localDataSource.getPhotoById(photoId);
      
      if (photo != null) {
        // Insert audit log BEFORE deletion
        await _insertAuditLog(
          activityId: photo.activityId,
          action: 'PHOTO_REMOVED',
          notes: 'Photo deleted: ${photo.photoUrl.isNotEmpty ? photo.photoUrl : photo.localPath ?? photoId}',
        );
      }
      
      await _localDataSource.deletePhoto(photoId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete photo: $e',
        originalError: e,
      ));
    }
  }

  /// Add photo from URL (for web uploads that are already in cloud storage).
  /// This inserts directly with photoUrl set and isPendingUpload = false.
  Future<Either<Failure, domain.ActivityPhoto>> addPhotoFromUrl(
    String activityId,
    String photoId,
    String photoUrl, {
    String? caption,
    double? latitude,
    double? longitude,
    DateTime? takenAt,
  }) async {
    try {
      final now = DateTime.now();

      final companion = db.ActivityPhotosCompanion.insert(
        id: photoId,
        activityId: activityId,
        photoUrl: photoUrl,
        localPath: const Value(null), // No local path for web
        caption: Value(caption),
        takenAt: Value(takenAt ?? now),
        latitude: Value(latitude),
        longitude: Value(longitude),
        isPendingUpload: const Value(false), // Already uploaded
        createdAt: now,
      );

      await _localDataSource.insertPhoto(companion);

      // Insert audit log
      await _insertAuditLog(
        activityId: activityId,
        action: 'PHOTO_ADDED',
        notes: caption,
        latitude: latitude,
        longitude: longitude,
      );

      final photo = (await _localDataSource.getActivityPhotos(activityId))
          .firstWhere((p) => p.id == photoId);

      return Right(_mapToActivityPhoto(photo));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to add photo from URL: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Audit Log Operations
  // ==========================================

  @override
  Future<List<domain.ActivityAuditLog>> getActivityAuditLogs(String activityId) async {
    final logs = await _localDataSource.getAuditLogs(activityId);
    return logs.map(_mapToAuditLog).toList();
  }

  // ==========================================
  // Master Data Operations
  // ==========================================

  @override
  Future<List<domain.ActivityType>> getActivityTypes() async {
    final types = await _localDataSource.getActivityTypes();
    return types.map(_mapToActivityType).toList();
  }

  @override
  Future<domain.ActivityType?> getActivityTypeById(String id) async {
    final type = await _localDataSource.getActivityTypeById(id);
    return type != null ? _mapToActivityType(type) : null;
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  @override
  Future<void> syncFromRemote({DateTime? since}) async {
    try {
      final remoteData = await _remoteDataSource.fetchActivities(since: since);

      if (remoteData.isEmpty) {
        _log.debug('activity | No activities to sync from remote');
        return;
      }

      _log.debug('activity | Syncing ${remoteData.length} activities from remote');

      final companions = remoteData.map((data) {
        // Handle potentially null fields with defaults
        return db.ActivitiesCompanion(
          id: Value(data['id'] as String),
          userId: Value(data['user_id'] as String? ?? ''),
          createdBy: Value(data['created_by'] as String? ?? ''),
          objectType: Value(data['object_type'] as String? ?? 'CUSTOMER'),
          activityTypeId: Value(data['activity_type_id'] as String? ?? ''),
          scheduledDatetime: Value(DateTime.parse(data['scheduled_datetime'] as String)),
          customerId: Value(data['customer_id'] as String?),
          hvcId: Value(data['hvc_id'] as String?),
          brokerId: Value(data['broker_id'] as String?),
          summary: Value(data['summary'] as String?),
          notes: Value(data['notes'] as String?),
          status: Value(data['status'] as String? ?? 'PLANNED'),
          isImmediate: Value(data['is_immediate'] as bool? ?? false),
          executedAt: data['executed_at'] != null
              ? Value(DateTime.parse(data['executed_at'] as String))
              : const Value(null),
          latitude: Value((data['latitude'] as num?)?.toDouble()),
          longitude: Value((data['longitude'] as num?)?.toDouble()),
          locationAccuracy: Value((data['location_accuracy'] as num?)?.toDouble()),
          distanceFromTarget: Value((data['distance_from_target'] as num?)?.toDouble()),
          isLocationOverride: Value(data['is_location_override'] as bool? ?? false),
          overrideReason: Value(data['override_reason'] as String?),
          rescheduledFromId: Value(data['rescheduled_from_id'] as String?),
          rescheduledToId: Value(data['rescheduled_to_id'] as String?),
          cancelledAt: data['cancelled_at'] != null
              ? Value(DateTime.parse(data['cancelled_at'] as String))
              : const Value(null),
          cancelReason: Value(data['cancel_reason'] as String?),
          isPendingSync: const Value(false),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          updatedAt: Value(DateTime.parse(data['updated_at'] as String)),
          lastSyncAt: Value(DateTime.now()),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
        );
      }).toList();

      await _localDataSource.upsertActivities(companions);
      _log.debug('activity | Successfully synced ${companions.length} activities');
    } catch (e) {
      _log.error('activity | Error syncing from remote: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncPhotosFromRemote() async {
    try {
      _log.debug('activity | Starting photo sync from remote');

      // Get all activity IDs from local database
      final activities = await _localDataSource.getAllActivities();

      int photoCount = 0;
      for (final activity in activities) {
        try {
          // Fetch photos for this activity from remote
          final remotePhotos = await _remoteDataSource.fetchActivityPhotos(activity.id);

          if (remotePhotos.isEmpty) continue;

          // Insert photos into local database
          for (final photoData in remotePhotos) {
            final companion = db.ActivityPhotosCompanion.insert(
              id: photoData['id'] as String,
              activityId: photoData['activity_id'] as String,
              photoUrl: photoData['photo_url'] as String,
              localPath: const Value(null), // No local path for synced photos
              caption: Value(photoData['caption'] as String?),
              takenAt: photoData['taken_at'] != null
                  ? Value(DateTime.parse(photoData['taken_at'] as String))
                  : const Value(null),
              latitude: Value(photoData['latitude'] as double?),
              longitude: Value(photoData['longitude'] as double?),
              isPendingUpload: const Value(false), // Already uploaded
              createdAt: DateTime.parse(photoData['created_at'] as String),
            );

            await _localDataSource.insertPhoto(companion);
            photoCount++;
          }
        } catch (e) {
          _log.error('activity | Error syncing photos for activity ${activity.id}: $e');
          // Continue with next activity
        }
      }

      _log.debug('activity | Synced $photoCount photos from remote');
    } catch (e) {
      _log.error('activity | Error syncing photos from remote: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsSynced(String id, DateTime syncedAt) =>
      _localDataSource.markAsSynced(id, syncedAt);

  @override
  Future<List<domain.Activity>> getPendingSyncActivities() async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getPendingSyncActivities();
    return data.map(_mapToActivity).toList();
  }

  @override
  Future<void> syncPendingPhotos() async {
    try {
      final pendingPhotos = await _localDataSource.getPendingUploadPhotos();
      
      if (pendingPhotos.isEmpty) {
        _log.debug('activity | No pending photos to upload');
        return;
      }

      _log.debug('activity | Uploading ${pendingPhotos.length} pending photos');

      for (final photo in pendingPhotos) {
        try {
          // Skip if no local path
          if (photo.localPath == null || photo.localPath!.isEmpty) {
            _log.debug('activity | Skipping photo ${photo.id}: no local path');
            continue;
          }

          // Upload to Supabase Storage
          final photoUrl = await _remoteDataSource.uploadPhoto(
            photo.activityId,
            photo.localPath!,
            photo.id,
          );

          // Create photo record in remote database
          await _remoteDataSource.createPhotoRecord({
            'id': photo.id,
            'activity_id': photo.activityId,
            'photo_url': photoUrl,
            'caption': photo.caption,
            'taken_at': photo.takenAt?.toUtcIso8601(),
            'latitude': photo.latitude,
            'longitude': photo.longitude,
            'created_at': photo.createdAt.toUtcIso8601(),
          });

          // Mark as uploaded locally
          await _localDataSource.markPhotoAsUploaded(photo.id, photoUrl);

          _log.debug('activity | Uploaded photo ${photo.id} -> $photoUrl');
        } catch (e) {
          _log.error('activity | Failed to upload photo ${photo.id}: $e');
          // Continue with next photo, don't fail entire batch
        }
      }

      _log.debug('activity | Photo sync completed');
    } catch (e) {
      _log.error('activity | Error syncing photos: $e');
      rethrow;
    }
  }

  // ==========================================
  // Statistics
  // ==========================================

  @override
  Future<int> getCountByStatus(String userId, String status) =>
      _localDataSource.getCountByStatus(userId, status);

  @override
  Future<int> getCompletedCountInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) =>
      _localDataSource.getCompletedCountInRange(userId, startDate, endDate);

  @override
  Future<void> syncPendingAuditLogs() async {
    try {
      final pendingLogs = await _localDataSource.getPendingSyncAuditLogs();
      if (pendingLogs.isEmpty) return;
      
      _log.debug('activity | Found ${pendingLogs.length} pending audit logs to sync');
      
      // Get list of synced activities (not pending sync)
      final syncedActivities = <String>{};
      for (final log in pendingLogs) {
        final activity = await _localDataSource.getActivityById(log.activityId);
        if (activity != null && !activity.isPendingSync) {
          syncedActivities.add(log.activityId);
        }
      }
      
      // Filter logs to only include those for synced activities
      final logsToSync = pendingLogs.where((l) => syncedActivities.contains(l.activityId)).toList();
      if (logsToSync.isEmpty) {
        _log.debug('activity | No audit logs ready to sync (activities not yet synced)');
        return;
      }
      
      _log.debug('activity | Syncing ${logsToSync.length} audit logs');
      
      final syncedIds = <String>[];
      for (final log in logsToSync) {
        try {
          await _remoteDataSource.createAuditLog({
            'id': log.id,
            'activity_id': log.activityId,
            'action': log.action,
            'old_status': log.oldStatus,
            'new_status': log.newStatus,
            'latitude': log.latitude,
            'longitude': log.longitude,
            'performed_by': log.performedBy,
            'performed_at': log.performedAt.toUtcIso8601(),
            'notes': log.notes,
            'created_at': log.performedAt.toUtcIso8601(),
          });
          syncedIds.add(log.id);
        } catch (e) {
          _log.error('activity | Failed to sync audit log ${log.id}: $e');
          // Continue with other logs
        }
      }
      
      // Mark synced logs
      if (syncedIds.isNotEmpty) {
        await _localDataSource.markAuditLogsAsSynced(syncedIds);
        _log.debug('activity | Marked ${syncedIds.length} audit logs as synced');
      }
    } catch (e) {
      _log.error('activity | Error syncing audit logs: $e');
    }
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  Future<void> _ensureCachesLoaded() async {
    if (_activityTypeNameCache == null) {
      final types = await _localDataSource.getActivityTypes();
      _log.debug('activity | Loading activity type cache: found ${types.length} types');
      for (final t in types) {
        _log.debug('activity | Type: ${t.id} -> ${t.name}');
      }
      _activityTypeNameCache = {for (final t in types) t.id: t.name};
      _activityTypeIconCache = {for (final t in types) t.id: t.icon ?? ''};
      _activityTypeColorCache = {for (final t in types) t.id: t.color ?? ''};
    }

    // Load customer name cache
    if (_customerNameCache == null) {
      final customers = await (_database.select(_database.customers)
        ..where((c) => c.deletedAt.isNull())).get();
      _customerNameCache = {for (final c in customers) c.id: c.name};
      _log.debug('activity | Loaded ${_customerNameCache!.length} customer names');
    }

    // Load HVC name cache
    if (_hvcNameCache == null) {
      final hvcs = await (_database.select(_database.hvcs)
        ..where((h) => h.deletedAt.isNull())).get();
      _hvcNameCache = {for (final h in hvcs) h.id: h.name};
      _log.debug('activity | Loaded ${_hvcNameCache!.length} HVC names');
    }

    // Load broker name cache
    if (_brokerNameCache == null) {
      final brokers = await (_database.select(_database.brokers)
        ..where((b) => b.deletedAt.isNull())).get();
      _brokerNameCache = {for (final b in brokers) b.id: b.name};
      _log.debug('activity | Loaded ${_brokerNameCache!.length} broker names');
    }

    // Load key person name cache
    if (_keyPersonNameCache == null) {
      final keyPersons = await (_database.select(_database.keyPersons)
        ..where((k) => k.deletedAt.isNull())).get();
      _keyPersonNameCache = {for (final k in keyPersons) k.id: k.name};
      _log.debug('activity | Loaded ${_keyPersonNameCache!.length} key person names');
    }
  }

  @override
  void invalidateCaches() {
    _activityTypeNameCache = null;
    _activityTypeIconCache = null;
    _activityTypeColorCache = null;
    _customerNameCache = null;
    _hvcNameCache = null;
    _brokerNameCache = null;
    _keyPersonNameCache = null;
    _log.debug('activity | Activity caches invalidated');
  }

  Future<void> _insertAuditLog({
    required String activityId,
    required String action,
    String? oldStatus,
    String? newStatus,
    double? latitude,
    double? longitude,
    String? notes,
    bool syncToRemote = false, // Only sync if activity is already on remote
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    
    final companion = db.ActivityAuditLogsCompanion.insert(
      id: id,
      activityId: activityId,
      action: action,
      oldStatus: Value(oldStatus),
      newStatus: Value(newStatus),
      latitude: Value(latitude),
      longitude: Value(longitude),
      performedBy: _currentUserId,
      performedAt: now,
      notes: Value(notes),
    );
    
    // Insert locally first (offline-first)
    await _localDataSource.insertAuditLog(companion);
    
    // Only attempt remote sync if explicitly requested (activity already exists on remote)
    if (syncToRemote) {
      try {
        await _remoteDataSource.createAuditLog({
          'id': id,
          'activity_id': activityId,
          'action': action,
          'old_status': oldStatus,
          'new_status': newStatus,
          'latitude': latitude,
          'longitude': longitude,
          'performed_by': _currentUserId,
          'performed_at': now.toUtcIso8601(),
          'notes': notes,
          'created_at': now.toUtcIso8601(),
        });
        _log.debug('activity | Audit log synced to remote: $action');
      } catch (e) {
        // Remote sync failed - log locally is still valid
        _log.error('activity | Failed to sync audit log to remote: $e');
      }
    }
  }

  domain.Activity _mapToActivity(db.Activity data) {
    // Resolve object name based on object type
    String? objectName;
    if (data.objectType == 'CUSTOMER' && data.customerId != null) {
      objectName = _customerNameCache?[data.customerId!];
    } else if (data.objectType == 'HVC' && data.hvcId != null) {
      objectName = _hvcNameCache?[data.hvcId!];
    } else if (data.objectType == 'BROKER' && data.brokerId != null) {
      objectName = _brokerNameCache?[data.brokerId!];
    }

    // Resolve key person name
    String? keyPersonName;
    if (data.keyPersonId != null) {
      keyPersonName = _keyPersonNameCache?[data.keyPersonId!];
    }

    return domain.Activity(
      id: data.id,
      userId: data.userId,
      createdBy: data.createdBy,
      objectType: _parseObjectType(data.objectType),
      activityTypeId: data.activityTypeId,
      scheduledDatetime: data.scheduledDatetime,
      status: _parseStatus(data.status),
      customerId: data.customerId,
      hvcId: data.hvcId,
      brokerId: data.brokerId,
      keyPersonId: data.keyPersonId,
      summary: data.summary,
      notes: data.notes,
      isImmediate: data.isImmediate,
      executedAt: data.executedAt,
      latitude: data.latitude,
      longitude: data.longitude,
      locationAccuracy: data.locationAccuracy,
      distanceFromTarget: data.distanceFromTarget,
      isLocationOverride: data.isLocationOverride,
      overrideReason: data.overrideReason,
      rescheduledFromId: data.rescheduledFromId,
      rescheduledToId: data.rescheduledToId,
      cancelledAt: data.cancelledAt,
      cancelReason: data.cancelReason,
      isPendingSync: data.isPendingSync,
      lastSyncAt: data.lastSyncAt,
      deletedAt: data.deletedAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      // Lookup fields
      activityTypeName: _activityTypeNameCache?[data.activityTypeId],
      activityTypeIcon: _activityTypeIconCache?[data.activityTypeId],
      activityTypeColor: _activityTypeColorCache?[data.activityTypeId],
      objectName: objectName,
      keyPersonName: keyPersonName,
    );
  }

  domain.ActivityObjectType _parseObjectType(String value) {
    switch (value) {
      case 'CUSTOMER':
        return domain.ActivityObjectType.customer;
      case 'HVC':
        return domain.ActivityObjectType.hvc;
      case 'BROKER':
        return domain.ActivityObjectType.broker;
      default:
        return domain.ActivityObjectType.customer;
    }
  }

  domain.ActivityStatus _parseStatus(String value) {
    switch (value) {
      case 'PLANNED':
        return domain.ActivityStatus.planned;
      case 'IN_PROGRESS':
        return domain.ActivityStatus.inProgress;
      case 'COMPLETED':
        return domain.ActivityStatus.completed;
      case 'CANCELLED':
        return domain.ActivityStatus.cancelled;
      case 'RESCHEDULED':
        return domain.ActivityStatus.rescheduled;
      case 'OVERDUE':
        return domain.ActivityStatus.overdue;
      default:
        return domain.ActivityStatus.planned;
    }
  }

  domain.ActivityType _mapToActivityType(db.ActivityType data) =>
      domain.ActivityType(
        id: data.id,
        code: data.code,
        name: data.name,
        icon: data.icon,
        color: data.color,
        requireLocation: data.requireLocation,
        requirePhoto: data.requirePhoto,
        requireNotes: data.requireNotes,
        sortOrder: data.sortOrder,
        isActive: data.isActive,
      );

  domain.ActivityPhoto _mapToActivityPhoto(db.ActivityPhoto data) =>
      domain.ActivityPhoto(
        id: data.id,
        activityId: data.activityId,
        photoUrl: data.photoUrl,
        localPath: data.localPath,
        caption: data.caption,
        takenAt: data.takenAt,
        latitude: data.latitude,
        longitude: data.longitude,
        isPendingUpload: data.isPendingUpload,
        createdAt: data.createdAt,
      );

  domain.ActivityAuditLog _mapToAuditLog(db.ActivityAuditLog data) =>
      domain.ActivityAuditLog(
        id: data.id,
        activityId: data.activityId,
        action: data.action,
        oldStatus: data.oldStatus,
        newStatus: data.newStatus,
        oldValues: data.oldValues,
        newValues: data.newValues,
        changedFields: data.changedFields,
        latitude: data.latitude,
        longitude: data.longitude,
        deviceInfo: data.deviceInfo,
        performedBy: data.performedBy,
        performedAt: data.performedAt,
        notes: data.notes,
      );

  Map<String, dynamic> _createSyncPayload(
    String id,
    ActivityCreateDto dto,
    DateTime now,
  ) {
    return {
      'id': id,
      'user_id': _currentUserId,
      'created_by': _currentUserId,
      'object_type': dto.objectType,
      'activity_type_id': dto.activityTypeId,
      'scheduled_datetime': dto.scheduledDatetime.toUtcIso8601(),
      'customer_id': dto.customerId,
      'hvc_id': dto.hvcId,
      'broker_id': dto.brokerId,
      'summary': dto.summary,
      'notes': dto.notes,
      'status': 'PLANNED',
      'is_immediate': false,
      'created_at': now.toUtcIso8601(),
      'updated_at': now.toUtcIso8601(),
    };
  }

  Map<String, dynamic> _createImmediateSyncPayload(
    String id,
    ImmediateActivityDto dto,
    DateTime now,
  ) {
    return {
      'id': id,
      'user_id': _currentUserId,
      'created_by': _currentUserId,
      'object_type': dto.objectType,
      'activity_type_id': dto.activityTypeId,
      'scheduled_datetime': now.toUtcIso8601(),
      'customer_id': dto.customerId,
      'hvc_id': dto.hvcId,
      'broker_id': dto.brokerId,
      'summary': dto.summary,
      'notes': dto.notes,
      'status': 'COMPLETED',
      'is_immediate': true,
      'executed_at': now.toUtcIso8601(),
      'latitude': dto.latitude,
      'longitude': dto.longitude,
      'location_accuracy': dto.locationAccuracy,
      'distance_from_target': dto.distanceFromTarget,
      'is_location_override': dto.isLocationOverride,
      'override_reason': dto.overrideReason,
      'created_at': now.toUtcIso8601(),
      'updated_at': now.toUtcIso8601(),
    };
  }

  Map<String, dynamic> _createUpdateSyncPayload(db.Activity data) {
    return {
      'id': data.id,
      'user_id': data.userId,
      'created_by': data.createdBy,
      'object_type': data.objectType,
      'activity_type_id': data.activityTypeId,
      'scheduled_datetime': data.scheduledDatetime.toUtcIso8601(),
      'customer_id': data.customerId,
      'hvc_id': data.hvcId,
      'broker_id': data.brokerId,
      'summary': data.summary,
      'notes': data.notes,
      'status': data.status,
      'is_immediate': data.isImmediate,
      'executed_at': data.executedAt?.toUtcIso8601(),
      'latitude': data.latitude,
      'longitude': data.longitude,
      'location_accuracy': data.locationAccuracy,
      'distance_from_target': data.distanceFromTarget,
      'is_location_override': data.isLocationOverride,
      'override_reason': data.overrideReason,
      'rescheduled_from_id': data.rescheduledFromId,
      'rescheduled_to_id': data.rescheduledToId,
      'cancelled_at': data.cancelledAt?.toUtcIso8601(),
      'cancel_reason': data.cancelReason,
      'created_at': data.createdAt.toUtcIso8601(),
      'updated_at': data.updatedAt.toUtcIso8601(),
      'deleted_at': data.deletedAt?.toUtcIso8601(),
    };
  }

  Map<String, dynamic> _createRescheduleSyncPayload(
    String id,
    String newId,
    String status,
    String reason,
    DateTime now,
  ) {
    return {
      'id': id,
      'status': status,
      'rescheduled_to_id': newId,
      'notes': 'Rescheduled: $reason',
      'updated_at': now.toUtcIso8601(),
    };
  }
}
