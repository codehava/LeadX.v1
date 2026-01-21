// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityTypeImpl _$$ActivityTypeImplFromJson(Map<String, dynamic> json) =>
    _$ActivityTypeImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      requireLocation: json['requireLocation'] as bool? ?? false,
      requirePhoto: json['requirePhoto'] as bool? ?? false,
      requireNotes: json['requireNotes'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$ActivityTypeImplToJson(_$ActivityTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'requireLocation': instance.requireLocation,
      'requirePhoto': instance.requirePhoto,
      'requireNotes': instance.requireNotes,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

_$ActivityImpl _$$ActivityImplFromJson(Map<String, dynamic> json) =>
    _$ActivityImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdBy: json['createdBy'] as String,
      objectType: $enumDecode(_$ActivityObjectTypeEnumMap, json['objectType']),
      activityTypeId: json['activityTypeId'] as String,
      scheduledDatetime: DateTime.parse(json['scheduledDatetime'] as String),
      status: $enumDecode(_$ActivityStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customerId: json['customerId'] as String?,
      hvcId: json['hvcId'] as String?,
      brokerId: json['brokerId'] as String?,
      summary: json['summary'] as String?,
      notes: json['notes'] as String?,
      isImmediate: json['isImmediate'] as bool? ?? false,
      executedAt: json['executedAt'] == null
          ? null
          : DateTime.parse(json['executedAt'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble(),
      distanceFromTarget: (json['distanceFromTarget'] as num?)?.toDouble(),
      isLocationOverride: json['isLocationOverride'] as bool? ?? false,
      overrideReason: json['overrideReason'] as String?,
      rescheduledFromId: json['rescheduledFromId'] as String?,
      rescheduledToId: json['rescheduledToId'] as String?,
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancelReason: json['cancelReason'] as String?,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      activityTypeName: json['activityTypeName'] as String?,
      activityTypeIcon: json['activityTypeIcon'] as String?,
      activityTypeColor: json['activityTypeColor'] as String?,
      objectName: json['objectName'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$ActivityImplToJson(_$ActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdBy': instance.createdBy,
      'objectType': _$ActivityObjectTypeEnumMap[instance.objectType]!,
      'activityTypeId': instance.activityTypeId,
      'scheduledDatetime': instance.scheduledDatetime.toIso8601String(),
      'status': _$ActivityStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customerId': instance.customerId,
      'hvcId': instance.hvcId,
      'brokerId': instance.brokerId,
      'summary': instance.summary,
      'notes': instance.notes,
      'isImmediate': instance.isImmediate,
      'executedAt': instance.executedAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationAccuracy': instance.locationAccuracy,
      'distanceFromTarget': instance.distanceFromTarget,
      'isLocationOverride': instance.isLocationOverride,
      'overrideReason': instance.overrideReason,
      'rescheduledFromId': instance.rescheduledFromId,
      'rescheduledToId': instance.rescheduledToId,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancelReason': instance.cancelReason,
      'isPendingSync': instance.isPendingSync,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'activityTypeName': instance.activityTypeName,
      'activityTypeIcon': instance.activityTypeIcon,
      'activityTypeColor': instance.activityTypeColor,
      'objectName': instance.objectName,
      'userName': instance.userName,
    };

const _$ActivityObjectTypeEnumMap = {
  ActivityObjectType.customer: 'CUSTOMER',
  ActivityObjectType.hvc: 'HVC',
  ActivityObjectType.broker: 'BROKER',
};

const _$ActivityStatusEnumMap = {
  ActivityStatus.planned: 'PLANNED',
  ActivityStatus.inProgress: 'IN_PROGRESS',
  ActivityStatus.completed: 'COMPLETED',
  ActivityStatus.cancelled: 'CANCELLED',
  ActivityStatus.rescheduled: 'RESCHEDULED',
  ActivityStatus.overdue: 'OVERDUE',
};

_$ActivityPhotoImpl _$$ActivityPhotoImplFromJson(Map<String, dynamic> json) =>
    _$ActivityPhotoImpl(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      photoUrl: json['photoUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      localPath: json['localPath'] as String?,
      caption: json['caption'] as String?,
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPendingUpload: json['isPendingUpload'] as bool? ?? true,
    );

Map<String, dynamic> _$$ActivityPhotoImplToJson(_$ActivityPhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityId': instance.activityId,
      'photoUrl': instance.photoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'localPath': instance.localPath,
      'caption': instance.caption,
      'takenAt': instance.takenAt?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isPendingUpload': instance.isPendingUpload,
    };

_$ActivityAuditLogImpl _$$ActivityAuditLogImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityAuditLogImpl(
  id: json['id'] as String,
  activityId: json['activityId'] as String,
  action: json['action'] as String,
  performedBy: json['performedBy'] as String,
  performedAt: DateTime.parse(json['performedAt'] as String),
  oldStatus: json['oldStatus'] as String?,
  newStatus: json['newStatus'] as String?,
  oldValues: json['oldValues'] as String?,
  newValues: json['newValues'] as String?,
  changedFields: json['changedFields'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  deviceInfo: json['deviceInfo'] as String?,
  notes: json['notes'] as String?,
  performedByName: json['performedByName'] as String?,
);

Map<String, dynamic> _$$ActivityAuditLogImplToJson(
  _$ActivityAuditLogImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'activityId': instance.activityId,
  'action': instance.action,
  'performedBy': instance.performedBy,
  'performedAt': instance.performedAt.toIso8601String(),
  'oldStatus': instance.oldStatus,
  'newStatus': instance.newStatus,
  'oldValues': instance.oldValues,
  'newValues': instance.newValues,
  'changedFields': instance.changedFields,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'deviceInfo': instance.deviceInfo,
  'notes': instance.notes,
  'performedByName': instance.performedByName,
};

_$ActivityWithDetailsImpl _$$ActivityWithDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityWithDetailsImpl(
  activity: Activity.fromJson(json['activity'] as Map<String, dynamic>),
  activityType: json['activityType'] == null
      ? null
      : ActivityType.fromJson(json['activityType'] as Map<String, dynamic>),
  photos: (json['photos'] as List<dynamic>?)
      ?.map((e) => ActivityPhoto.fromJson(e as Map<String, dynamic>))
      .toList(),
  auditLogs: (json['auditLogs'] as List<dynamic>?)
      ?.map((e) => ActivityAuditLog.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ActivityWithDetailsImplToJson(
  _$ActivityWithDetailsImpl instance,
) => <String, dynamic>{
  'activity': instance.activity,
  'activityType': instance.activityType,
  'photos': instance.photos,
  'auditLogs': instance.auditLogs,
};
