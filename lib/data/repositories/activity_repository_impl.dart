import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId;

  final ActivityLocalDataSource _localDataSource;
  final ActivityRemoteDataSource _remoteDataSource;
  final SyncService _syncService;
  final String _currentUserId;
  final _uuid = const Uuid();

  // Lookup caches for efficient name resolution
  Map<String, String>? _activityTypeNameCache;
  Map<String, String>? _activityTypeIconCache;
  Map<String, String>? _activityTypeColorCache;

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
    debugPrint('[ActivityRepo] getActivityWithDetails($id): Found ${photos.length} photos');
    for (final p in photos) {
      debugPrint('[ActivityRepo] Photo id=${p.id}, photoUrl=${p.photoUrl}, localPath=${p.localPath}');
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

      // Save locally first
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

      // Trigger sync if online
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

      // Save locally first
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

      // Trigger sync if online
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

      // Update locally first
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

      // Get updated data for sync payload
      final updated = await _localDataSource.getActivityById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'Activity not found: $id'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.activity,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createUpdateSyncPayload(updated),
      );

      // Trigger sync if online
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

      await _localDataSource.insertActivity(newCompanion);

      // Update original activity to RESCHEDULED
      final updateCompanion = db.ActivitiesCompanion(
        status: const Value('RESCHEDULED'),
        rescheduledToId: Value(newId),
        notes: Value('Rescheduled: ${dto.reason}'),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      await _localDataSource.updateActivity(id, updateCompanion);

      // Insert audit logs
      await _insertAuditLog(
        activityId: id,
        action: 'RESCHEDULED',
        oldStatus: existing.status,
        newStatus: 'RESCHEDULED',
        notes: dto.reason,
        latitude: dto.latitude,
        longitude: dto.longitude,
      );

      // Queue both for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.activity,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createRescheduleSyncPayload(id, newId, 'RESCHEDULED', dto.reason, now),
      );

      // Trigger sync if online
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
          'cancelled_at': now.toIso8601String(),
          'cancel_reason': reason,
          'updated_at': now.toIso8601String(),
        },
      );

      // Trigger sync if online
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
        print('[ActivityRepo] No activities to sync from remote');
        return;
      }

      print('[ActivityRepo] Syncing ${remoteData.length} activities from remote');

      final companions = remoteData.map((data) {
        return db.ActivitiesCompanion(
          id: Value(data['id'] as String),
          userId: Value(data['user_id'] as String),
          createdBy: Value(data['created_by'] as String),
          objectType: Value(data['object_type'] as String),
          activityTypeId: Value(data['activity_type_id'] as String),
          scheduledDatetime: Value(DateTime.parse(data['scheduled_datetime'] as String)),
          customerId: Value(data['customer_id'] as String?),
          hvcId: Value(data['hvc_id'] as String?),
          brokerId: Value(data['broker_id'] as String?),
          summary: Value(data['summary'] as String?),
          notes: Value(data['notes'] as String?),
          status: Value(data['status'] as String),
          isImmediate: Value(data['is_immediate'] as bool? ?? false),
          executedAt: data['executed_at'] != null
              ? Value(DateTime.parse(data['executed_at'] as String))
              : const Value(null),
          latitude: Value(data['latitude'] as double?),
          longitude: Value(data['longitude'] as double?),
          locationAccuracy: Value(data['location_accuracy'] as double?),
          distanceFromTarget: Value(data['distance_from_target'] as double?),
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
          syncedAt: Value(DateTime.now()),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
        );
      }).toList();

      await _localDataSource.upsertActivities(companions);
      print('[ActivityRepo] Successfully synced ${companions.length} activities');
    } catch (e) {
      print('[ActivityRepo] Error syncing from remote: $e');
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
        print('[ActivityRepo] No pending photos to upload');
        return;
      }

      print('[ActivityRepo] Uploading ${pendingPhotos.length} pending photos');

      for (final photo in pendingPhotos) {
        try {
          // Skip if no local path
          if (photo.localPath == null || photo.localPath!.isEmpty) {
            print('[ActivityRepo] Skipping photo ${photo.id}: no local path');
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
            'taken_at': photo.takenAt?.toIso8601String(),
            'latitude': photo.latitude,
            'longitude': photo.longitude,
            'created_at': photo.createdAt.toIso8601String(),
          });

          // Mark as uploaded locally
          await _localDataSource.markPhotoAsUploaded(photo.id, photoUrl);

          print('[ActivityRepo] Uploaded photo ${photo.id} -> $photoUrl');
        } catch (e) {
          print('[ActivityRepo] Failed to upload photo ${photo.id}: $e');
          // Continue with next photo, don't fail entire batch
        }
      }

      print('[ActivityRepo] Photo sync completed');
    } catch (e) {
      print('[ActivityRepo] Error syncing photos: $e');
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
      
      debugPrint('[ActivityRepo] Found ${pendingLogs.length} pending audit logs to sync');
      
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
        debugPrint('[ActivityRepo] No audit logs ready to sync (activities not yet synced)');
        return;
      }
      
      debugPrint('[ActivityRepo] Syncing ${logsToSync.length} audit logs');
      
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
            'performed_at': log.performedAt.toIso8601String(),
            'notes': log.notes,
            'created_at': log.performedAt.toIso8601String(),
          });
          syncedIds.add(log.id);
        } catch (e) {
          debugPrint('[ActivityRepo] Failed to sync audit log ${log.id}: $e');
          // Continue with other logs
        }
      }
      
      // Mark synced logs
      if (syncedIds.isNotEmpty) {
        await _localDataSource.markAuditLogsAsSynced(syncedIds);
        debugPrint('[ActivityRepo] Marked ${syncedIds.length} audit logs as synced');
      }
    } catch (e) {
      debugPrint('[ActivityRepo] Error syncing audit logs: $e');
    }
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  Future<void> _ensureCachesLoaded() async {
    if (_activityTypeNameCache == null) {
      final types = await _localDataSource.getActivityTypes();
      debugPrint('[ActivityRepo] Loading activity type cache: found ${types.length} types');
      for (final t in types) {
        debugPrint('[ActivityRepo] Type: ${t.id} -> ${t.name}');
      }
      _activityTypeNameCache = {for (final t in types) t.id: t.name};
      _activityTypeIconCache = {for (final t in types) t.id: t.icon ?? ''};
      _activityTypeColorCache = {for (final t in types) t.id: t.color ?? ''};
    }
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
          'performed_at': now.toIso8601String(),
          'notes': notes,
          'created_at': now.toIso8601String(),
        });
        debugPrint('[ActivityRepo] Audit log synced to remote: $action');
      } catch (e) {
        // Remote sync failed - log locally is still valid
        debugPrint('[ActivityRepo] Failed to sync audit log to remote: $e');
      }
    }
  }

  domain.Activity _mapToActivity(db.Activity data) => domain.Activity(
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
        syncedAt: data.syncedAt,
        deletedAt: data.deletedAt,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        // Lookup fields
        activityTypeName: _activityTypeNameCache?[data.activityTypeId],
        activityTypeIcon: _activityTypeIconCache?[data.activityTypeId],
        activityTypeColor: _activityTypeColorCache?[data.activityTypeId],
      );

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
      'scheduled_datetime': dto.scheduledDatetime.toIso8601String(),
      'customer_id': dto.customerId,
      'hvc_id': dto.hvcId,
      'broker_id': dto.brokerId,
      'summary': dto.summary,
      'notes': dto.notes,
      'status': 'PLANNED',
      'is_immediate': false,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
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
      'scheduled_datetime': now.toIso8601String(),
      'customer_id': dto.customerId,
      'hvc_id': dto.hvcId,
      'broker_id': dto.brokerId,
      'summary': dto.summary,
      'notes': dto.notes,
      'status': 'COMPLETED',
      'is_immediate': true,
      'executed_at': now.toIso8601String(),
      'latitude': dto.latitude,
      'longitude': dto.longitude,
      'location_accuracy': dto.locationAccuracy,
      'distance_from_target': dto.distanceFromTarget,
      'is_location_override': dto.isLocationOverride,
      'override_reason': dto.overrideReason,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  Map<String, dynamic> _createUpdateSyncPayload(db.Activity data) {
    return {
      'id': data.id,
      'user_id': data.userId,
      'created_by': data.createdBy,
      'object_type': data.objectType,
      'activity_type_id': data.activityTypeId,
      'scheduled_datetime': data.scheduledDatetime.toIso8601String(),
      'customer_id': data.customerId,
      'hvc_id': data.hvcId,
      'broker_id': data.brokerId,
      'summary': data.summary,
      'notes': data.notes,
      'status': data.status,
      'is_immediate': data.isImmediate,
      'executed_at': data.executedAt?.toIso8601String(),
      'latitude': data.latitude,
      'longitude': data.longitude,
      'location_accuracy': data.locationAccuracy,
      'distance_from_target': data.distanceFromTarget,
      'is_location_override': data.isLocationOverride,
      'override_reason': data.overrideReason,
      'rescheduled_from_id': data.rescheduledFromId,
      'rescheduled_to_id': data.rescheduledToId,
      'cancelled_at': data.cancelledAt?.toIso8601String(),
      'cancel_reason': data.cancelReason,
      'created_at': data.createdAt.toIso8601String(),
      'updated_at': data.updatedAt.toIso8601String(),
      'deleted_at': data.deletedAt?.toIso8601String(),
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
      'updated_at': now.toIso8601String(),
    };
  }
}
