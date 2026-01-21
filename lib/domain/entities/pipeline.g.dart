// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PipelineStageInfoImpl _$$PipelineStageInfoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStageInfoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  probability: (json['probability'] as num).toInt(),
  sequence: (json['sequence'] as num).toInt(),
  color: json['color'] as String?,
  isFinal: json['isFinal'] as bool? ?? false,
  isWon: json['isWon'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$PipelineStageInfoImplToJson(
  _$PipelineStageInfoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'probability': instance.probability,
  'sequence': instance.sequence,
  'color': instance.color,
  'isFinal': instance.isFinal,
  'isWon': instance.isWon,
  'isActive': instance.isActive,
};

_$PipelineStatusInfoImpl _$$PipelineStatusInfoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStatusInfoImpl(
  id: json['id'] as String,
  stageId: json['stageId'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  sequence: (json['sequence'] as num).toInt(),
  description: json['description'] as String?,
  isDefault: json['isDefault'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$PipelineStatusInfoImplToJson(
  _$PipelineStatusInfoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'stageId': instance.stageId,
  'code': instance.code,
  'name': instance.name,
  'sequence': instance.sequence,
  'description': instance.description,
  'isDefault': instance.isDefault,
  'isActive': instance.isActive,
};

_$PipelineImpl _$$PipelineImplFromJson(Map<String, dynamic> json) =>
    _$PipelineImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      customerId: json['customerId'] as String,
      stageId: json['stageId'] as String,
      statusId: json['statusId'] as String,
      cobId: json['cobId'] as String,
      lobId: json['lobId'] as String,
      leadSourceId: json['leadSourceId'] as String,
      assignedRmId: json['assignedRmId'] as String,
      createdBy: json['createdBy'] as String,
      potentialPremium: (json['potentialPremium'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      brokerId: json['brokerId'] as String?,
      brokerPicId: json['brokerPicId'] as String?,
      customerContactId: json['customerContactId'] as String?,
      tsi: (json['tsi'] as num?)?.toDouble(),
      finalPremium: (json['finalPremium'] as num?)?.toDouble(),
      weightedValue: (json['weightedValue'] as num?)?.toDouble(),
      expectedCloseDate: json['expectedCloseDate'] == null
          ? null
          : DateTime.parse(json['expectedCloseDate'] as String),
      policyNumber: json['policyNumber'] as String?,
      declineReason: json['declineReason'] as String?,
      notes: json['notes'] as String?,
      isTender: json['isTender'] as bool? ?? false,
      referredByUserId: json['referredByUserId'] as String?,
      referralId: json['referralId'] as String?,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      customerName: json['customerName'] as String?,
      stageName: json['stageName'] as String?,
      stageColor: json['stageColor'] as String?,
      stageProbability: (json['stageProbability'] as num?)?.toInt(),
      stageIsFinal: json['stageIsFinal'] as bool?,
      stageIsWon: json['stageIsWon'] as bool?,
      statusName: json['statusName'] as String?,
      cobName: json['cobName'] as String?,
      lobName: json['lobName'] as String?,
      leadSourceName: json['leadSourceName'] as String?,
      brokerName: json['brokerName'] as String?,
      assignedRmName: json['assignedRmName'] as String?,
    );

Map<String, dynamic> _$$PipelineImplToJson(_$PipelineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'customerId': instance.customerId,
      'stageId': instance.stageId,
      'statusId': instance.statusId,
      'cobId': instance.cobId,
      'lobId': instance.lobId,
      'leadSourceId': instance.leadSourceId,
      'assignedRmId': instance.assignedRmId,
      'createdBy': instance.createdBy,
      'potentialPremium': instance.potentialPremium,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'brokerId': instance.brokerId,
      'brokerPicId': instance.brokerPicId,
      'customerContactId': instance.customerContactId,
      'tsi': instance.tsi,
      'finalPremium': instance.finalPremium,
      'weightedValue': instance.weightedValue,
      'expectedCloseDate': instance.expectedCloseDate?.toIso8601String(),
      'policyNumber': instance.policyNumber,
      'declineReason': instance.declineReason,
      'notes': instance.notes,
      'isTender': instance.isTender,
      'referredByUserId': instance.referredByUserId,
      'referralId': instance.referralId,
      'isPendingSync': instance.isPendingSync,
      'closedAt': instance.closedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'customerName': instance.customerName,
      'stageName': instance.stageName,
      'stageColor': instance.stageColor,
      'stageProbability': instance.stageProbability,
      'stageIsFinal': instance.stageIsFinal,
      'stageIsWon': instance.stageIsWon,
      'statusName': instance.statusName,
      'cobName': instance.cobName,
      'lobName': instance.lobName,
      'leadSourceName': instance.leadSourceName,
      'brokerName': instance.brokerName,
      'assignedRmName': instance.assignedRmName,
    };

_$PipelineWithDetailsImpl _$$PipelineWithDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineWithDetailsImpl(
  pipeline: Pipeline.fromJson(json['pipeline'] as Map<String, dynamic>),
  stage: json['stage'] == null
      ? null
      : PipelineStageInfo.fromJson(json['stage'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : PipelineStatusInfo.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$PipelineWithDetailsImplToJson(
  _$PipelineWithDetailsImpl instance,
) => <String, dynamic>{
  'pipeline': instance.pipeline,
  'stage': instance.stage,
  'status': instance.status,
};
