// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogImpl _$$AuditLogImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      userEmail: json['userEmail'] as String?,
      action: json['action'] as String,
      targetTable: json['targetTable'] as String,
      targetId: json['targetId'] as String,
      oldValues: json['oldValues'] as Map<String, dynamic>?,
      newValues: json['newValues'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$AuditLogImplToJson(_$AuditLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userEmail': instance.userEmail,
      'action': instance.action,
      'targetTable': instance.targetTable,
      'targetId': instance.targetId,
      'oldValues': instance.oldValues,
      'newValues': instance.newValues,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'createdAt': instance.createdAt.toIso8601String(),
      'userName': instance.userName,
    };

_$PipelineStageHistoryImpl _$$PipelineStageHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStageHistoryImpl(
  id: json['id'] as String,
  pipelineId: json['pipelineId'] as String,
  fromStageId: json['fromStageId'] as String?,
  toStageId: json['toStageId'] as String,
  fromStatusId: json['fromStatusId'] as String?,
  toStatusId: json['toStatusId'] as String?,
  notes: json['notes'] as String?,
  changedBy: json['changedBy'] as String?,
  changedAt: DateTime.parse(json['changedAt'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  fromStageName: json['fromStageName'] as String?,
  toStageName: json['toStageName'] as String?,
  fromStatusName: json['fromStatusName'] as String?,
  toStatusName: json['toStatusName'] as String?,
  changedByName: json['changedByName'] as String?,
  fromStageColor: json['fromStageColor'] as String?,
  toStageColor: json['toStageColor'] as String?,
);

Map<String, dynamic> _$$PipelineStageHistoryImplToJson(
  _$PipelineStageHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'pipelineId': instance.pipelineId,
  'fromStageId': instance.fromStageId,
  'toStageId': instance.toStageId,
  'fromStatusId': instance.fromStatusId,
  'toStatusId': instance.toStatusId,
  'notes': instance.notes,
  'changedBy': instance.changedBy,
  'changedAt': instance.changedAt.toIso8601String(),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'fromStageName': instance.fromStageName,
  'toStageName': instance.toStageName,
  'fromStatusName': instance.fromStatusName,
  'toStatusName': instance.toStatusName,
  'changedByName': instance.changedByName,
  'fromStageColor': instance.fromStageColor,
  'toStageColor': instance.toStageColor,
};
