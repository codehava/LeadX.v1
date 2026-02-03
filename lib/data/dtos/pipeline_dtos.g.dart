// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PipelineCreateDtoImpl _$$PipelineCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineCreateDtoImpl(
  customerId: json['customerId'] as String,
  cobId: json['cobId'] as String,
  lobId: json['lobId'] as String,
  leadSourceId: json['leadSourceId'] as String,
  potentialPremium: (json['potentialPremium'] as num).toDouble(),
  brokerId: json['brokerId'] as String?,
  brokerPicId: json['brokerPicId'] as String?,
  customerContactId: json['customerContactId'] as String?,
  tsi: (json['tsi'] as num?)?.toDouble(),
  expectedCloseDate: json['expectedCloseDate'] == null
      ? null
      : DateTime.parse(json['expectedCloseDate'] as String),
  isTender: json['isTender'] as bool? ?? false,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$PipelineCreateDtoImplToJson(
  _$PipelineCreateDtoImpl instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'cobId': instance.cobId,
  'lobId': instance.lobId,
  'leadSourceId': instance.leadSourceId,
  'potentialPremium': instance.potentialPremium,
  'brokerId': instance.brokerId,
  'brokerPicId': instance.brokerPicId,
  'customerContactId': instance.customerContactId,
  'tsi': instance.tsi,
  'expectedCloseDate': instance.expectedCloseDate?.toIso8601String(),
  'isTender': instance.isTender,
  'notes': instance.notes,
};

_$PipelineUpdateDtoImpl _$$PipelineUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineUpdateDtoImpl(
  cobId: json['cobId'] as String?,
  lobId: json['lobId'] as String?,
  leadSourceId: json['leadSourceId'] as String?,
  brokerId: json['brokerId'] as String?,
  brokerPicId: json['brokerPicId'] as String?,
  customerContactId: json['customerContactId'] as String?,
  tsi: (json['tsi'] as num?)?.toDouble(),
  potentialPremium: (json['potentialPremium'] as num?)?.toDouble(),
  expectedCloseDate: json['expectedCloseDate'] == null
      ? null
      : DateTime.parse(json['expectedCloseDate'] as String),
  isTender: json['isTender'] as bool?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$PipelineUpdateDtoImplToJson(
  _$PipelineUpdateDtoImpl instance,
) => <String, dynamic>{
  'cobId': instance.cobId,
  'lobId': instance.lobId,
  'leadSourceId': instance.leadSourceId,
  'brokerId': instance.brokerId,
  'brokerPicId': instance.brokerPicId,
  'customerContactId': instance.customerContactId,
  'tsi': instance.tsi,
  'potentialPremium': instance.potentialPremium,
  'expectedCloseDate': instance.expectedCloseDate?.toIso8601String(),
  'isTender': instance.isTender,
  'notes': instance.notes,
};

_$PipelineStageUpdateDtoImpl _$$PipelineStageUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStageUpdateDtoImpl(
  stageId: json['stageId'] as String,
  notes: json['notes'] as String?,
  finalPremium: (json['finalPremium'] as num?)?.toDouble(),
  policyNumber: json['policyNumber'] as String?,
  declineReason: json['declineReason'] as String?,
);

Map<String, dynamic> _$$PipelineStageUpdateDtoImplToJson(
  _$PipelineStageUpdateDtoImpl instance,
) => <String, dynamic>{
  'stageId': instance.stageId,
  'notes': instance.notes,
  'finalPremium': instance.finalPremium,
  'policyNumber': instance.policyNumber,
  'declineReason': instance.declineReason,
};

_$PipelineStatusUpdateDtoImpl _$$PipelineStatusUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStatusUpdateDtoImpl(
  statusId: json['statusId'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$PipelineStatusUpdateDtoImplToJson(
  _$PipelineStatusUpdateDtoImpl instance,
) => <String, dynamic>{'statusId': instance.statusId, 'notes': instance.notes};

_$PipelineSyncDtoImpl _$$PipelineSyncDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineSyncDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  customerId: json['customer_id'] as String,
  stageId: json['stage_id'] as String,
  statusId: json['status_id'] as String,
  cobId: json['cob_id'] as String,
  lobId: json['lob_id'] as String,
  leadSourceId: json['lead_source_id'] as String,
  assignedRmId: json['assigned_rm_id'] as String,
  createdBy: json['created_by'] as String,
  potentialPremium: (json['potential_premium'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  brokerId: json['broker_id'] as String?,
  brokerPicId: json['broker_pic_id'] as String?,
  customerContactId: json['customer_contact_id'] as String?,
  tsi: (json['tsi'] as num?)?.toDouble(),
  finalPremium: (json['final_premium'] as num?)?.toDouble(),
  weightedValue: (json['weighted_value'] as num?)?.toDouble(),
  expectedCloseDate: json['expected_close_date'] == null
      ? null
      : DateTime.parse(json['expected_close_date'] as String),
  policyNumber: json['policy_number'] as String?,
  declineReason: json['decline_reason'] as String?,
  notes: json['notes'] as String?,
  isTender: json['is_tender'] as bool? ?? false,
  referredByUserId: json['referred_by_user_id'] as String?,
  referralId: json['referral_id'] as String?,
  scoredToUserId: json['scored_to_user_id'] as String?,
  closedAt: json['closed_at'] == null
      ? null
      : DateTime.parse(json['closed_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$$PipelineSyncDtoImplToJson(
  _$PipelineSyncDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'customer_id': instance.customerId,
  'stage_id': instance.stageId,
  'status_id': instance.statusId,
  'cob_id': instance.cobId,
  'lob_id': instance.lobId,
  'lead_source_id': instance.leadSourceId,
  'assigned_rm_id': instance.assignedRmId,
  'created_by': instance.createdBy,
  'potential_premium': instance.potentialPremium,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'broker_id': instance.brokerId,
  'broker_pic_id': instance.brokerPicId,
  'customer_contact_id': instance.customerContactId,
  'tsi': instance.tsi,
  'final_premium': instance.finalPremium,
  'weighted_value': instance.weightedValue,
  'expected_close_date': instance.expectedCloseDate?.toIso8601String(),
  'policy_number': instance.policyNumber,
  'decline_reason': instance.declineReason,
  'notes': instance.notes,
  'is_tender': instance.isTender,
  'referred_by_user_id': instance.referredByUserId,
  'referral_id': instance.referralId,
  'scored_to_user_id': instance.scoredToUserId,
  'closed_at': instance.closedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
