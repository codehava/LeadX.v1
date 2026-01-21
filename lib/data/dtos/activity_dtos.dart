import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_dtos.freezed.dart';
part 'activity_dtos.g.dart';

/// DTO for creating a scheduled activity.
@freezed
class ActivityCreateDto with _$ActivityCreateDto {
  const factory ActivityCreateDto({
    required String objectType, // CUSTOMER, HVC, BROKER
    required String activityTypeId,
    required DateTime scheduledDatetime,
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? summary,
    String? notes,
    // GPS data captured when creating (for audit log)
    double? latitude,
    double? longitude,
  }) = _ActivityCreateDto;

  factory ActivityCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityCreateDtoFromJson(json);
}

/// DTO for creating an immediate (instant) activity.
@freezed
class ImmediateActivityDto with _$ImmediateActivityDto {
  const factory ImmediateActivityDto({
    required String objectType, // CUSTOMER, HVC, BROKER
    required String activityTypeId,
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? summary,
    String? notes,
    // GPS data captured at time of logging
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    @Default(false) bool isLocationOverride,
    String? overrideReason,
  }) = _ImmediateActivityDto;

  factory ImmediateActivityDto.fromJson(Map<String, dynamic> json) =>
      _$ImmediateActivityDtoFromJson(json);
}

/// DTO for executing a planned activity.
@freezed
class ActivityExecutionDto with _$ActivityExecutionDto {
  const factory ActivityExecutionDto({
    // GPS data
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    @Default(false) bool isLocationOverride,
    String? overrideReason,
    // Execution notes
    String? notes,
  }) = _ActivityExecutionDto;

  factory ActivityExecutionDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityExecutionDtoFromJson(json);
}

/// DTO for rescheduling an activity.
@freezed
class ActivityRescheduleDto with _$ActivityRescheduleDto {
  const factory ActivityRescheduleDto({
    required DateTime newScheduledDatetime,
    required String reason,
    // GPS data captured when rescheduling (for audit log)
    double? latitude,
    double? longitude,
  }) = _ActivityRescheduleDto;

  factory ActivityRescheduleDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityRescheduleDtoFromJson(json);
}

/// DTO for syncing activity data with Supabase.
@freezed
class ActivitySyncDto with _$ActivitySyncDto {
  const factory ActivitySyncDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'object_type') required String objectType,
    @JsonKey(name: 'activity_type_id') required String activityTypeId,
    @JsonKey(name: 'scheduled_datetime') required DateTime scheduledDatetime,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'hvc_id') String? hvcId,
    @JsonKey(name: 'broker_id') String? brokerId,
    String? summary,
    String? notes,
    @JsonKey(name: 'is_immediate') @Default(false) bool isImmediate,
    @JsonKey(name: 'executed_at') DateTime? executedAt,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'location_accuracy') double? locationAccuracy,
    @JsonKey(name: 'distance_from_target') double? distanceFromTarget,
    @JsonKey(name: 'is_location_override') @Default(false) bool isLocationOverride,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'rescheduled_from_id') String? rescheduledFromId,
    @JsonKey(name: 'rescheduled_to_id') String? rescheduledToId,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _ActivitySyncDto;

  factory ActivitySyncDto.fromJson(Map<String, dynamic> json) =>
      _$ActivitySyncDtoFromJson(json);
}

/// DTO for syncing activity photo with Supabase.
@freezed
class ActivityPhotoSyncDto with _$ActivityPhotoSyncDto {
  const factory ActivityPhotoSyncDto({
    required String id,
    @JsonKey(name: 'activity_id') required String activityId,
    @JsonKey(name: 'photo_url') required String photoUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? caption,
    @JsonKey(name: 'taken_at') DateTime? takenAt,
    double? latitude,
    double? longitude,
  }) = _ActivityPhotoSyncDto;

  factory ActivityPhotoSyncDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityPhotoSyncDtoFromJson(json);
}
