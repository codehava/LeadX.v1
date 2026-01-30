// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PipelineReferralImpl _$$PipelineReferralImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineReferralImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  customerId: json['customerId'] as String,
  referrerRmId: json['referrerRmId'] as String,
  receiverRmId: json['receiverRmId'] as String,
  referrerBranchId: json['referrerBranchId'] as String?,
  receiverBranchId: json['receiverBranchId'] as String?,
  referrerRegionalOfficeId: json['referrerRegionalOfficeId'] as String?,
  receiverRegionalOfficeId: json['receiverRegionalOfficeId'] as String?,
  approverType:
      $enumDecodeNullable(_$ApproverTypeEnumMap, json['approverType']) ??
      ApproverType.bm,
  reason: json['reason'] as String,
  notes: json['notes'] as String?,
  status:
      $enumDecodeNullable(_$ReferralStatusEnumMap, json['status']) ??
      ReferralStatus.pendingReceiver,
  receiverAcceptedAt: json['receiverAcceptedAt'] == null
      ? null
      : DateTime.parse(json['receiverAcceptedAt'] as String),
  receiverRejectedAt: json['receiverRejectedAt'] == null
      ? null
      : DateTime.parse(json['receiverRejectedAt'] as String),
  receiverRejectReason: json['receiverRejectReason'] as String?,
  receiverNotes: json['receiverNotes'] as String?,
  bmApprovedAt: json['bmApprovedAt'] == null
      ? null
      : DateTime.parse(json['bmApprovedAt'] as String),
  bmApprovedBy: json['bmApprovedBy'] as String?,
  bmRejectedAt: json['bmRejectedAt'] == null
      ? null
      : DateTime.parse(json['bmRejectedAt'] as String),
  bmRejectReason: json['bmRejectReason'] as String?,
  bmNotes: json['bmNotes'] as String?,
  bonusCalculated: json['bonusCalculated'] as bool? ?? false,
  bonusAmount: (json['bonusAmount'] as num?)?.toDouble(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  cancelReason: json['cancelReason'] as String?,
  isPendingSync: json['isPendingSync'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastSyncAt: json['lastSyncAt'] == null
      ? null
      : DateTime.parse(json['lastSyncAt'] as String),
  customerName: json['customerName'] as String?,
  referrerRmName: json['referrerRmName'] as String?,
  receiverRmName: json['receiverRmName'] as String?,
  referrerBranchName: json['referrerBranchName'] as String?,
  receiverBranchName: json['receiverBranchName'] as String?,
  approverName: json['approverName'] as String?,
);

Map<String, dynamic> _$$PipelineReferralImplToJson(
  _$PipelineReferralImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'customerId': instance.customerId,
  'referrerRmId': instance.referrerRmId,
  'receiverRmId': instance.receiverRmId,
  'referrerBranchId': instance.referrerBranchId,
  'receiverBranchId': instance.receiverBranchId,
  'referrerRegionalOfficeId': instance.referrerRegionalOfficeId,
  'receiverRegionalOfficeId': instance.receiverRegionalOfficeId,
  'approverType': _$ApproverTypeEnumMap[instance.approverType]!,
  'reason': instance.reason,
  'notes': instance.notes,
  'status': _$ReferralStatusEnumMap[instance.status]!,
  'receiverAcceptedAt': instance.receiverAcceptedAt?.toIso8601String(),
  'receiverRejectedAt': instance.receiverRejectedAt?.toIso8601String(),
  'receiverRejectReason': instance.receiverRejectReason,
  'receiverNotes': instance.receiverNotes,
  'bmApprovedAt': instance.bmApprovedAt?.toIso8601String(),
  'bmApprovedBy': instance.bmApprovedBy,
  'bmRejectedAt': instance.bmRejectedAt?.toIso8601String(),
  'bmRejectReason': instance.bmRejectReason,
  'bmNotes': instance.bmNotes,
  'bonusCalculated': instance.bonusCalculated,
  'bonusAmount': instance.bonusAmount,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'cancelReason': instance.cancelReason,
  'isPendingSync': instance.isPendingSync,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
  'customerName': instance.customerName,
  'referrerRmName': instance.referrerRmName,
  'receiverRmName': instance.receiverRmName,
  'referrerBranchName': instance.referrerBranchName,
  'receiverBranchName': instance.receiverBranchName,
  'approverName': instance.approverName,
};

const _$ApproverTypeEnumMap = {
  ApproverType.bh: 'BH',
  ApproverType.bm: 'BM',
  ApproverType.roh: 'ROH',
  ApproverType.admin: 'ADMIN',
  ApproverType.superadmin: 'SUPERADMIN',
};

const _$ReferralStatusEnumMap = {
  ReferralStatus.pendingReceiver: 'PENDING_RECEIVER',
  ReferralStatus.receiverAccepted: 'RECEIVER_ACCEPTED',
  ReferralStatus.receiverRejected: 'RECEIVER_REJECTED',
  ReferralStatus.pendingBm: 'PENDING_BM',
  ReferralStatus.bmApproved: 'BM_APPROVED',
  ReferralStatus.bmRejected: 'BM_REJECTED',
  ReferralStatus.completed: 'COMPLETED',
  ReferralStatus.cancelled: 'CANCELLED',
};

_$ApproverInfoImpl _$$ApproverInfoImplFromJson(Map<String, dynamic> json) =>
    _$ApproverInfoImpl(
      approverId: json['approverId'] as String,
      approverType: $enumDecode(_$ApproverTypeEnumMap, json['approverType']),
      approverName: json['approverName'] as String?,
    );

Map<String, dynamic> _$$ApproverInfoImplToJson(_$ApproverInfoImpl instance) =>
    <String, dynamic>{
      'approverId': instance.approverId,
      'approverType': _$ApproverTypeEnumMap[instance.approverType]!,
      'approverName': instance.approverName,
    };
