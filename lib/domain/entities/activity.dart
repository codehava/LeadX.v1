import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// Activity object type - which entity the activity is associated with.
enum ActivityObjectType {
  @JsonValue('CUSTOMER')
  customer,
  @JsonValue('HVC')
  hvc,
  @JsonValue('BROKER')
  broker,
}

/// Activity status indicating current state.
enum ActivityStatus {
  @JsonValue('PLANNED')
  planned,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('RESCHEDULED')
  rescheduled,
  @JsonValue('OVERDUE')
  overdue,
}

/// Activity type information from master data.
@freezed
class ActivityType with _$ActivityType {
  const factory ActivityType({
    required String id,
    required String code,
    required String name,
    String? icon,
    String? color,
    @Default(false) bool requireLocation,
    @Default(false) bool requirePhoto,
    @Default(false) bool requireNotes,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _ActivityType;

  factory ActivityType.fromJson(Map<String, dynamic> json) =>
      _$ActivityTypeFromJson(json);
}

/// Activity domain entity representing a scheduled or immediate activity.
@freezed
class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String userId,
    required String createdBy,
    required ActivityObjectType objectType,
    required String activityTypeId,
    required DateTime scheduledDatetime,
    required ActivityStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Object references (one of these based on objectType)
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? keyPersonId,
    // Activity details
    String? summary,
    String? notes,
    @Default(false) bool isImmediate,
    // Execution details
    DateTime? executedAt,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    @Default(false) bool isLocationOverride,
    String? overrideReason,
    // Rescheduling
    String? rescheduledFromId,
    String? rescheduledToId,
    // Cancellation
    DateTime? cancelledAt,
    String? cancelReason,
    // Sync status
    @Default(false) bool isPendingSync,
    DateTime? syncedAt,
    DateTime? deletedAt,
    // Lookup fields (populated from joined data)
    String? activityTypeName,
    String? activityTypeIcon,
    String? activityTypeColor,
    String? objectName, // Customer/HVC/Broker name
    String? keyPersonName, // Key person/PIC name
    String? userName, // Activity owner name
  }) = _Activity;

  const Activity._();

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  /// Check if activity needs to be synced.
  bool get needsSync => isPendingSync;

  /// Check if activity is soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Check if activity is completed.
  bool get isCompleted => status == ActivityStatus.completed;

  /// Check if activity is planned and can be executed.
  bool get canExecute => status == ActivityStatus.planned;

  /// Check if activity can be rescheduled.
  bool get canReschedule =>
      status == ActivityStatus.planned || status == ActivityStatus.overdue;

  /// Check if activity can be cancelled.
  bool get canCancel =>
      status == ActivityStatus.planned || status == ActivityStatus.overdue;

  /// Check if activity was executed with valid GPS.
  bool get hasValidGps =>
      latitude != null && longitude != null && !isLocationOverride;

  /// Get object ID based on object type.
  String? get objectId {
    switch (objectType) {
      case ActivityObjectType.customer:
        return customerId;
      case ActivityObjectType.hvc:
        return hvcId;
      case ActivityObjectType.broker:
        return brokerId;
    }
  }

  /// Get display name for the activity.
  String get displayName => activityTypeName ?? 'Activity';

  /// Get status display text.
  String get statusText {
    switch (status) {
      case ActivityStatus.planned:
        return 'Planned';
      case ActivityStatus.inProgress:
        return 'In Progress';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
      case ActivityStatus.rescheduled:
        return 'Rescheduled';
      case ActivityStatus.overdue:
        return 'Overdue';
    }
  }

  /// Get status color for UI.
  String get statusColor {
    switch (status) {
      case ActivityStatus.planned:
        return '#2196F3'; // Blue
      case ActivityStatus.inProgress:
        return '#FF9800'; // Orange
      case ActivityStatus.completed:
        return '#4CAF50'; // Green
      case ActivityStatus.cancelled:
        return '#9E9E9E'; // Grey
      case ActivityStatus.rescheduled:
        return '#9C27B0'; // Purple
      case ActivityStatus.overdue:
        return '#F44336'; // Red
    }
  }
}

/// Activity photo for proof of visit.
@freezed
class ActivityPhoto with _$ActivityPhoto {
  const factory ActivityPhoto({
    required String id,
    required String activityId,
    required String photoUrl,
    required DateTime createdAt,
    String? localPath,
    String? caption,
    DateTime? takenAt,
    double? latitude,
    double? longitude,
    @Default(true) bool isPendingUpload,
  }) = _ActivityPhoto;

  const ActivityPhoto._();

  factory ActivityPhoto.fromJson(Map<String, dynamic> json) =>
      _$ActivityPhotoFromJson(json);

  /// Check if photo needs to be uploaded.
  bool get needsUpload => isPendingUpload;

  /// Check if photo has geotag.
  bool get hasGeotag => latitude != null && longitude != null;
}

/// Activity audit log for tracking changes.
@freezed
class ActivityAuditLog with _$ActivityAuditLog {
  const factory ActivityAuditLog({
    required String id,
    required String activityId,
    required String action,
    required String performedBy,
    required DateTime performedAt,
    String? oldStatus,
    String? newStatus,
    String? oldValues, // JSON string
    String? newValues, // JSON string
    String? changedFields, // JSON array
    double? latitude,
    double? longitude,
    String? deviceInfo, // JSON string
    String? notes,
    // Lookup
    String? performedByName,
  }) = _ActivityAuditLog;

  const ActivityAuditLog._();

  factory ActivityAuditLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityAuditLogFromJson(json);

  /// Get action display text.
  String get actionText {
    switch (action) {
      case 'CREATED':
        return 'Created';
      case 'STATUS_CHANGED':
        return 'Status Changed';
      case 'EXECUTED':
        return 'Executed';
      case 'RESCHEDULED':
        return 'Rescheduled';
      case 'CANCELLED':
        return 'Cancelled';
      case 'EDITED':
        return 'Edited';
      case 'PHOTO_ADDED':
        return 'Photo Added';
      case 'PHOTO_REMOVED':
        return 'Photo Removed';
      case 'GPS_OVERRIDE':
        return 'GPS Override';
      case 'SYNCED':
        return 'Synced';
      default:
        return action;
    }
  }
}

/// Activity with full details for detail screen.
@freezed
class ActivityWithDetails with _$ActivityWithDetails {
  const factory ActivityWithDetails({
    required Activity activity,
    ActivityType? activityType,
    List<ActivityPhoto>? photos,
    List<ActivityAuditLog>? auditLogs,
  }) = _ActivityWithDetails;

  const ActivityWithDetails._();

  factory ActivityWithDetails.fromJson(Map<String, dynamic> json) =>
      _$ActivityWithDetailsFromJson(json);
}
