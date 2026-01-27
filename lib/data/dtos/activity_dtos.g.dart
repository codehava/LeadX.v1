// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityCreateDtoImpl _$$ActivityCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityCreateDtoImpl(
  objectType: json['objectType'] as String,
  activityTypeId: json['activityTypeId'] as String,
  scheduledDatetime: DateTime.parse(json['scheduledDatetime'] as String),
  customerId: json['customerId'] as String?,
  hvcId: json['hvcId'] as String?,
  brokerId: json['brokerId'] as String?,
  keyPersonId: json['keyPersonId'] as String?,
  summary: json['summary'] as String?,
  notes: json['notes'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$ActivityCreateDtoImplToJson(
  _$ActivityCreateDtoImpl instance,
) => <String, dynamic>{
  'objectType': instance.objectType,
  'activityTypeId': instance.activityTypeId,
  'scheduledDatetime': instance.scheduledDatetime.toIso8601String(),
  'customerId': instance.customerId,
  'hvcId': instance.hvcId,
  'brokerId': instance.brokerId,
  'keyPersonId': instance.keyPersonId,
  'summary': instance.summary,
  'notes': instance.notes,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$ImmediateActivityDtoImpl _$$ImmediateActivityDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ImmediateActivityDtoImpl(
  objectType: json['objectType'] as String,
  activityTypeId: json['activityTypeId'] as String,
  customerId: json['customerId'] as String?,
  hvcId: json['hvcId'] as String?,
  brokerId: json['brokerId'] as String?,
  keyPersonId: json['keyPersonId'] as String?,
  summary: json['summary'] as String?,
  notes: json['notes'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble(),
  distanceFromTarget: (json['distanceFromTarget'] as num?)?.toDouble(),
  isLocationOverride: json['isLocationOverride'] as bool? ?? false,
  overrideReason: json['overrideReason'] as String?,
);

Map<String, dynamic> _$$ImmediateActivityDtoImplToJson(
  _$ImmediateActivityDtoImpl instance,
) => <String, dynamic>{
  'objectType': instance.objectType,
  'activityTypeId': instance.activityTypeId,
  'customerId': instance.customerId,
  'hvcId': instance.hvcId,
  'brokerId': instance.brokerId,
  'keyPersonId': instance.keyPersonId,
  'summary': instance.summary,
  'notes': instance.notes,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'locationAccuracy': instance.locationAccuracy,
  'distanceFromTarget': instance.distanceFromTarget,
  'isLocationOverride': instance.isLocationOverride,
  'overrideReason': instance.overrideReason,
};

_$ActivityExecutionDtoImpl _$$ActivityExecutionDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityExecutionDtoImpl(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble(),
  distanceFromTarget: (json['distanceFromTarget'] as num?)?.toDouble(),
  isLocationOverride: json['isLocationOverride'] as bool? ?? false,
  overrideReason: json['overrideReason'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$ActivityExecutionDtoImplToJson(
  _$ActivityExecutionDtoImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'locationAccuracy': instance.locationAccuracy,
  'distanceFromTarget': instance.distanceFromTarget,
  'isLocationOverride': instance.isLocationOverride,
  'overrideReason': instance.overrideReason,
  'notes': instance.notes,
};

_$ActivityRescheduleDtoImpl _$$ActivityRescheduleDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityRescheduleDtoImpl(
  newScheduledDatetime: DateTime.parse(json['newScheduledDatetime'] as String),
  reason: json['reason'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$ActivityRescheduleDtoImplToJson(
  _$ActivityRescheduleDtoImpl instance,
) => <String, dynamic>{
  'newScheduledDatetime': instance.newScheduledDatetime.toIso8601String(),
  'reason': instance.reason,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$ActivitySyncDtoImpl _$$ActivitySyncDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ActivitySyncDtoImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  createdBy: json['created_by'] as String,
  objectType: json['object_type'] as String,
  activityTypeId: json['activity_type_id'] as String,
  scheduledDatetime: DateTime.parse(json['scheduled_datetime'] as String),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  customerId: json['customer_id'] as String?,
  hvcId: json['hvc_id'] as String?,
  brokerId: json['broker_id'] as String?,
  summary: json['summary'] as String?,
  notes: json['notes'] as String?,
  isImmediate: json['is_immediate'] as bool? ?? false,
  executedAt: json['executed_at'] == null
      ? null
      : DateTime.parse(json['executed_at'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  locationAccuracy: (json['location_accuracy'] as num?)?.toDouble(),
  distanceFromTarget: (json['distance_from_target'] as num?)?.toDouble(),
  isLocationOverride: json['is_location_override'] as bool? ?? false,
  overrideReason: json['override_reason'] as String?,
  rescheduledFromId: json['rescheduled_from_id'] as String?,
  rescheduledToId: json['rescheduled_to_id'] as String?,
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  cancelReason: json['cancel_reason'] as String?,
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$$ActivitySyncDtoImplToJson(
  _$ActivitySyncDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'created_by': instance.createdBy,
  'object_type': instance.objectType,
  'activity_type_id': instance.activityTypeId,
  'scheduled_datetime': instance.scheduledDatetime.toIso8601String(),
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'customer_id': instance.customerId,
  'hvc_id': instance.hvcId,
  'broker_id': instance.brokerId,
  'summary': instance.summary,
  'notes': instance.notes,
  'is_immediate': instance.isImmediate,
  'executed_at': instance.executedAt?.toIso8601String(),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'location_accuracy': instance.locationAccuracy,
  'distance_from_target': instance.distanceFromTarget,
  'is_location_override': instance.isLocationOverride,
  'override_reason': instance.overrideReason,
  'rescheduled_from_id': instance.rescheduledFromId,
  'rescheduled_to_id': instance.rescheduledToId,
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'cancel_reason': instance.cancelReason,
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_$ActivityPhotoSyncDtoImpl _$$ActivityPhotoSyncDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityPhotoSyncDtoImpl(
  id: json['id'] as String,
  activityId: json['activity_id'] as String,
  photoUrl: json['photo_url'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  caption: json['caption'] as String?,
  takenAt: json['taken_at'] == null
      ? null
      : DateTime.parse(json['taken_at'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$ActivityPhotoSyncDtoImplToJson(
  _$ActivityPhotoSyncDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'activity_id': instance.activityId,
  'photo_url': instance.photoUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'caption': instance.caption,
  'taken_at': instance.takenAt?.toIso8601String(),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
