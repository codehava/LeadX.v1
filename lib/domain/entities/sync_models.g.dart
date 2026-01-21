// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncQueueItemImpl _$$SyncQueueItemImplFromJson(Map<String, dynamic> json) =>
    _$SyncQueueItemImpl(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: $enumDecode(_$SyncOperationEnumMap, json['operation']),
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['status']) ??
          SyncStatus.pending,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$$SyncQueueItemImplToJson(_$SyncQueueItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'operation': _$SyncOperationEnumMap[instance.operation]!,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$SyncStatusEnumMap[instance.status]!,
      'retryCount': instance.retryCount,
      'errorMessage': instance.errorMessage,
      'syncedAt': instance.syncedAt?.toIso8601String(),
    };

const _$SyncOperationEnumMap = {
  SyncOperation.create: 'create',
  SyncOperation.update: 'update',
  SyncOperation.delete: 'delete',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.inProgress: 'inProgress',
  SyncStatus.completed: 'completed',
  SyncStatus.failed: 'failed',
};

_$SyncResultImpl _$$SyncResultImplFromJson(Map<String, dynamic> json) =>
    _$SyncResultImpl(
      success: json['success'] as bool,
      processedCount: (json['processedCount'] as num).toInt(),
      successCount: (json['successCount'] as num).toInt(),
      failedCount: (json['failedCount'] as num).toInt(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      syncedAt: DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$$SyncResultImplToJson(_$SyncResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'processedCount': instance.processedCount,
      'successCount': instance.successCount,
      'failedCount': instance.failedCount,
      'errors': instance.errors,
      'syncedAt': instance.syncedAt.toIso8601String(),
    };
