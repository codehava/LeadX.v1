import '../../core/errors/result.dart';
import '../../data/dtos/activity_dtos.dart';
import '../entities/activity.dart';

/// Repository interface for activity operations.
abstract class ActivityRepository {
  // ==========================================
  // Watch Operations (Reactive Streams)
  // ==========================================

  /// Watch activities for a user within a date range.
  Stream<List<Activity>> watchUserActivities(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Watch activities for a specific customer.
  Stream<List<Activity>> watchCustomerActivities(String customerId);

  /// Watch activities for a specific HVC.
  Stream<List<Activity>> watchHvcActivities(String hvcId);

  /// Watch activities for a specific broker.
  Stream<List<Activity>> watchBrokerActivities(String brokerId);

  /// Watch today's activities for a user.
  Stream<List<Activity>> watchTodayActivities(String userId);

  // ==========================================
  // Watch Operations (Single Entity)
  // ==========================================

  /// Watch a specific activity by ID (reactive stream).
  Stream<Activity?> watchActivityById(String id);

  /// Watch activity with full details (type, photos, audit logs) (reactive stream).
  Stream<ActivityWithDetails?> watchActivityWithDetails(String id);

  // ==========================================
  // Get Operations
  // ==========================================

  /// Get a specific activity by ID.
  Future<Activity?> getActivityById(String id);

  /// Get activity with full details (type, photos, audit logs).
  Future<ActivityWithDetails?> getActivityWithDetails(String id);

  /// Get activities for a user within a date range.
  Future<List<Activity>> getUserActivities(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get overdue activities for a user.
  Future<List<Activity>> getOverdueActivities(String userId);

  // ==========================================
  // Create Operations
  // ==========================================

  /// Create a new scheduled activity.
  /// Saves locally first, then queues for sync.
  Future<Result<Activity>> createActivity(ActivityCreateDto dto);

  /// Create an immediate (instant) activity.
  /// The activity is created with COMPLETED status and GPS data.
  Future<Result<Activity>> createImmediateActivity(
    ImmediateActivityDto dto,
  );

  // ==========================================
  // Update Operations
  // ==========================================

  /// Update an existing activity.
  /// Saves locally first, then queues for sync.
  Future<Result<Activity>> updateActivity(String id, ActivityUpdateDto dto);

  /// Execute a planned activity.
  /// Marks the activity as COMPLETED with GPS data.
  Future<Result<Activity>> executeActivity(
    String id,
    ActivityExecutionDto dto,
  );

  /// Reschedule an activity.
  /// Creates a new activity with the new datetime and links to original.
  Future<Result<Activity>> rescheduleActivity(
    String id,
    ActivityRescheduleDto dto,
  );

  /// Cancel an activity.
  Future<Result<void>> cancelActivity(String id, String reason, {double? latitude, double? longitude});

  // ==========================================
  // Photo Operations
  // ==========================================

  /// Get photos for an activity.
  Future<List<ActivityPhoto>> getActivityPhotos(String activityId);

  /// Add a photo to an activity.
  /// Saves locally first, then queues for upload.
  Future<Result<ActivityPhoto>> addPhoto(
    String activityId,
    String localPath, {
    String? caption,
    double? latitude,
    double? longitude,
  });

  /// Delete a photo.
  Future<Result<void>> deletePhoto(String photoId);

  /// Add photo from URL (for web uploads that are already in cloud storage).
  /// This inserts directly with photoUrl set and isPendingUpload = false.
  Future<Result<ActivityPhoto>> addPhotoFromUrl(
    String activityId,
    String photoId,
    String photoUrl, {
    String? caption,
    double? latitude,
    double? longitude,
    DateTime? takenAt,
  });

  // ==========================================
  // Audit Log Operations
  // ==========================================

  /// Get audit logs for an activity.
  Future<List<ActivityAuditLog>> getActivityAuditLogs(String activityId);

  // ==========================================
  // Master Data Operations
  // ==========================================

  /// Get all activity types.
  Future<List<ActivityType>> getActivityTypes();

  /// Get a specific activity type by ID.
  Future<ActivityType?> getActivityTypeById(String id);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync activities from remote to local.
  /// Uses incremental sync based on updatedAt timestamp.
  Future<void> syncFromRemote({DateTime? since});

  /// Sync pending photos to Supabase Storage.
  /// Uploads photos with isPendingUpload=true, creates DB records, marks as uploaded.
  Future<void> syncPendingPhotos();

  /// Sync pending audit logs to Supabase.
  /// Only syncs logs for activities that have already been synced (are on remote).
  Future<void> syncPendingAuditLogs();

  /// Sync activity photos from remote to local database.
  /// Fetches photos for all activities and stores them locally.
  Future<void> syncPhotosFromRemote();

  /// Invalidate activity type caches to force reload.
  /// Call this after syncing new activity types.
  void invalidateCaches();

  /// Mark an activity as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt);

  /// Get activities pending sync.
  Future<List<Activity>> getPendingSyncActivities();

  // ==========================================
  // Statistics
  // ==========================================

  /// Get count of activities by status for a user.
  Future<int> getCountByStatus(String userId, String status);

  /// Get count of completed activities in a date range.
  Future<int> getCompletedCountInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
