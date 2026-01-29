// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_referral_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PipelineReferralCreateDtoImpl _$$PipelineReferralCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralCreateDtoImpl(
  customerId: json['customerId'] as String,
  receiverRmId: json['receiverRmId'] as String,
  reason: json['reason'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$PipelineReferralCreateDtoImplToJson(
  _$PipelineReferralCreateDtoImpl instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'receiverRmId': instance.receiverRmId,
  'reason': instance.reason,
  'notes': instance.notes,
};

_$PipelineReferralAcceptDtoImpl _$$PipelineReferralAcceptDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralAcceptDtoImpl(notes: json['notes'] as String?);

Map<String, dynamic> _$$PipelineReferralAcceptDtoImplToJson(
  _$PipelineReferralAcceptDtoImpl instance,
) => <String, dynamic>{'notes': instance.notes};

_$PipelineReferralRejectDtoImpl _$$PipelineReferralRejectDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralRejectDtoImpl(reason: json['reason'] as String);

Map<String, dynamic> _$$PipelineReferralRejectDtoImplToJson(
  _$PipelineReferralRejectDtoImpl instance,
) => <String, dynamic>{'reason': instance.reason};

_$PipelineReferralApprovalDtoImpl _$$PipelineReferralApprovalDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralApprovalDtoImpl(notes: json['notes'] as String?);

Map<String, dynamic> _$$PipelineReferralApprovalDtoImplToJson(
  _$PipelineReferralApprovalDtoImpl instance,
) => <String, dynamic>{'notes': instance.notes};

_$PipelineReferralManagerRejectDtoImpl
_$$PipelineReferralManagerRejectDtoImplFromJson(Map<String, dynamic> json) =>
    _$PipelineReferralManagerRejectDtoImpl(reason: json['reason'] as String);

Map<String, dynamic> _$$PipelineReferralManagerRejectDtoImplToJson(
  _$PipelineReferralManagerRejectDtoImpl instance,
) => <String, dynamic>{'reason': instance.reason};

_$PipelineReferralCancelDtoImpl _$$PipelineReferralCancelDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralCancelDtoImpl(reason: json['reason'] as String);

Map<String, dynamic> _$$PipelineReferralCancelDtoImplToJson(
  _$PipelineReferralCancelDtoImpl instance,
) => <String, dynamic>{'reason': instance.reason};

_$PipelineReferralSyncDtoImpl _$$PipelineReferralSyncDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralSyncDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  customerId: json['customer_id'] as String,
  referrerRmId: json['referrer_rm_id'] as String,
  receiverRmId: json['receiver_rm_id'] as String,
  referrerBranchId: json['referrer_branch_id'] as String?,
  receiverBranchId: json['receiver_branch_id'] as String?,
  referrerRegionalOfficeId: json['referrer_regional_office_id'] as String?,
  receiverRegionalOfficeId: json['receiver_regional_office_id'] as String?,
  approverType: json['approver_type'] as String? ?? 'BM',
  reason: json['reason'] as String,
  notes: json['notes'] as String?,
  status: json['status'] as String? ?? 'PENDING_RECEIVER',
  receiverAcceptedAt: json['receiver_accepted_at'] == null
      ? null
      : DateTime.parse(json['receiver_accepted_at'] as String),
  receiverRejectedAt: json['receiver_rejected_at'] == null
      ? null
      : DateTime.parse(json['receiver_rejected_at'] as String),
  receiverRejectReason: json['receiver_reject_reason'] as String?,
  receiverNotes: json['receiver_notes'] as String?,
  bmApprovedAt: json['bm_approved_at'] == null
      ? null
      : DateTime.parse(json['bm_approved_at'] as String),
  bmApprovedBy: json['bm_approved_by'] as String?,
  bmRejectedAt: json['bm_rejected_at'] == null
      ? null
      : DateTime.parse(json['bm_rejected_at'] as String),
  bmRejectReason: json['bm_reject_reason'] as String?,
  bmNotes: json['bm_notes'] as String?,
  bonusCalculated: json['bonus_calculated'] as bool? ?? false,
  bonusAmount: (json['bonus_amount'] as num?)?.toDouble(),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  cancelReason: json['cancel_reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$PipelineReferralSyncDtoImplToJson(
  _$PipelineReferralSyncDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'customer_id': instance.customerId,
  'referrer_rm_id': instance.referrerRmId,
  'receiver_rm_id': instance.receiverRmId,
  'referrer_branch_id': instance.referrerBranchId,
  'receiver_branch_id': instance.receiverBranchId,
  'referrer_regional_office_id': instance.referrerRegionalOfficeId,
  'receiver_regional_office_id': instance.receiverRegionalOfficeId,
  'approver_type': instance.approverType,
  'reason': instance.reason,
  'notes': instance.notes,
  'status': instance.status,
  'receiver_accepted_at': instance.receiverAcceptedAt?.toIso8601String(),
  'receiver_rejected_at': instance.receiverRejectedAt?.toIso8601String(),
  'receiver_reject_reason': instance.receiverRejectReason,
  'receiver_notes': instance.receiverNotes,
  'bm_approved_at': instance.bmApprovedAt?.toIso8601String(),
  'bm_approved_by': instance.bmApprovedBy,
  'bm_rejected_at': instance.bmRejectedAt?.toIso8601String(),
  'bm_reject_reason': instance.bmRejectReason,
  'bm_notes': instance.bmNotes,
  'bonus_calculated': instance.bonusCalculated,
  'bonus_amount': instance.bonusAmount,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'cancel_reason': instance.cancelReason,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
