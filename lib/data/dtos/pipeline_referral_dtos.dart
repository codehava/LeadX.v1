import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline_referral_dtos.freezed.dart';
part 'pipeline_referral_dtos.g.dart';

/// DTO for creating a new pipeline referral.
/// Note: This is an online-only operation - requires network to search receiver RM.
@freezed
class PipelineReferralCreateDto with _$PipelineReferralCreateDto {
  const factory PipelineReferralCreateDto({
    required String customerId,
    required String receiverRmId,
    required String reason,
    String? notes,
  }) = _PipelineReferralCreateDto;

  factory PipelineReferralCreateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralCreateDtoFromJson(json);
}

/// DTO for receiver accepting a referral.
@freezed
class PipelineReferralAcceptDto with _$PipelineReferralAcceptDto {
  const factory PipelineReferralAcceptDto({
    String? notes,
  }) = _PipelineReferralAcceptDto;

  factory PipelineReferralAcceptDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralAcceptDtoFromJson(json);
}

/// DTO for receiver rejecting a referral.
@freezed
class PipelineReferralRejectDto with _$PipelineReferralRejectDto {
  const factory PipelineReferralRejectDto({
    required String reason,
  }) = _PipelineReferralRejectDto;

  factory PipelineReferralRejectDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralRejectDtoFromJson(json);
}

/// DTO for manager approving a referral.
@freezed
class PipelineReferralApprovalDto with _$PipelineReferralApprovalDto {
  const factory PipelineReferralApprovalDto({
    String? notes,
  }) = _PipelineReferralApprovalDto;

  factory PipelineReferralApprovalDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralApprovalDtoFromJson(json);
}

/// DTO for manager rejecting a referral.
@freezed
class PipelineReferralManagerRejectDto with _$PipelineReferralManagerRejectDto {
  const factory PipelineReferralManagerRejectDto({
    required String reason,
  }) = _PipelineReferralManagerRejectDto;

  factory PipelineReferralManagerRejectDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralManagerRejectDtoFromJson(json);
}

/// DTO for referrer cancelling a referral.
@freezed
class PipelineReferralCancelDto with _$PipelineReferralCancelDto {
  const factory PipelineReferralCancelDto({
    required String reason,
  }) = _PipelineReferralCancelDto;

  factory PipelineReferralCancelDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralCancelDtoFromJson(json);
}

/// DTO for syncing referral data with Supabase.
@freezed
class PipelineReferralSyncDto with _$PipelineReferralSyncDto {
  const factory PipelineReferralSyncDto({
    required String id,
    required String code,

    // Customer Info
    @JsonKey(name: 'customer_id') required String customerId,

    // Parties
    @JsonKey(name: 'referrer_rm_id') required String referrerRmId,
    @JsonKey(name: 'receiver_rm_id') required String receiverRmId,

    // Branch IDs (nullable for kanwil-level RMs)
    @JsonKey(name: 'referrer_branch_id') String? referrerBranchId,
    @JsonKey(name: 'receiver_branch_id') String? receiverBranchId,

    // Regional Office IDs
    @JsonKey(name: 'referrer_regional_office_id') String? referrerRegionalOfficeId,
    @JsonKey(name: 'receiver_regional_office_id') String? receiverRegionalOfficeId,

    // Approver Type
    @JsonKey(name: 'approver_type') @Default('BM') String approverType,

    // Referral Details
    required String reason,
    String? notes,

    // Status
    @Default('PENDING_RECEIVER') String status,

    // Receiver Response
    @JsonKey(name: 'receiver_accepted_at') DateTime? receiverAcceptedAt,
    @JsonKey(name: 'receiver_rejected_at') DateTime? receiverRejectedAt,
    @JsonKey(name: 'receiver_reject_reason') String? receiverRejectReason,
    @JsonKey(name: 'receiver_notes') String? receiverNotes,

    // Manager Approval
    @JsonKey(name: 'bm_approved_at') DateTime? bmApprovedAt,
    @JsonKey(name: 'bm_approved_by') String? bmApprovedBy,
    @JsonKey(name: 'bm_rejected_at') DateTime? bmRejectedAt,
    @JsonKey(name: 'bm_reject_reason') String? bmRejectReason,
    @JsonKey(name: 'bm_notes') String? bmNotes,

    // Result
    @JsonKey(name: 'bonus_calculated') @Default(false) bool bonusCalculated,
    @JsonKey(name: 'bonus_amount') double? bonusAmount,

    // Timestamps
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PipelineReferralSyncDto;

  factory PipelineReferralSyncDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralSyncDtoFromJson(json);
}
