import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline_dtos.freezed.dart';
part 'pipeline_dtos.g.dart';

/// DTO for creating a new pipeline.
@freezed
class PipelineCreateDto with _$PipelineCreateDto {
  const factory PipelineCreateDto({
    required String customerId,
    required String cobId,
    required String lobId,
    required String leadSourceId,
    required double potentialPremium,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    DateTime? expectedCloseDate,
    @Default(false) bool isTender,
    String? notes,
  }) = _PipelineCreateDto;

  factory PipelineCreateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineCreateDtoFromJson(json);
}

/// DTO for updating an existing pipeline.
@freezed
class PipelineUpdateDto with _$PipelineUpdateDto {
  const factory PipelineUpdateDto({
    String? cobId,
    String? lobId,
    String? leadSourceId,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    double? potentialPremium,
    DateTime? expectedCloseDate,
    bool? isTender,
    String? notes,
  }) = _PipelineUpdateDto;

  factory PipelineUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineUpdateDtoFromJson(json);
}

/// DTO for updating pipeline stage (stage transition).
/// This is for moving a pipeline from one stage to another.
@freezed
class PipelineStageUpdateDto with _$PipelineStageUpdateDto {
  const factory PipelineStageUpdateDto({
    required String stageId,
    String? notes,
    // For Won stage
    double? finalPremium,
    String? policyNumber,
    // For Lost stage
    String? declineReason,
  }) = _PipelineStageUpdateDto;

  factory PipelineStageUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineStageUpdateDtoFromJson(json);
}

/// DTO for updating pipeline status within the current stage.
/// This is for changing the status without changing the stage.
@freezed
class PipelineStatusUpdateDto with _$PipelineStatusUpdateDto {
  const factory PipelineStatusUpdateDto({
    required String statusId,
    String? notes,
  }) = _PipelineStatusUpdateDto;

  factory PipelineStatusUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineStatusUpdateDtoFromJson(json);
}

/// DTO for syncing pipeline data with Supabase.
@freezed
class PipelineSyncDto with _$PipelineSyncDto {
  const factory PipelineSyncDto({
    required String id,
    required String code,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'stage_id') required String stageId,
    @JsonKey(name: 'status_id') required String statusId,
    @JsonKey(name: 'cob_id') required String cobId,
    @JsonKey(name: 'lob_id') required String lobId,
    @JsonKey(name: 'lead_source_id') required String leadSourceId,
    @JsonKey(name: 'assigned_rm_id') required String assignedRmId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'potential_premium') required double potentialPremium,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'broker_id') String? brokerId,
    @JsonKey(name: 'broker_pic_id') String? brokerPicId,
    @JsonKey(name: 'customer_contact_id') String? customerContactId,
    double? tsi,
    @JsonKey(name: 'final_premium') double? finalPremium,
    @JsonKey(name: 'weighted_value') double? weightedValue,
    @JsonKey(name: 'expected_close_date') DateTime? expectedCloseDate,
    @JsonKey(name: 'policy_number') String? policyNumber,
    @JsonKey(name: 'decline_reason') String? declineReason,
    String? notes,
    @JsonKey(name: 'is_tender') @Default(false) bool isTender,
    @JsonKey(name: 'referred_by_user_id') String? referredByUserId,
    @JsonKey(name: 'referral_id') String? referralId,
    @JsonKey(name: 'scored_to_user_id') String? scoredToUserId,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _PipelineSyncDto;

  factory PipelineSyncDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineSyncDtoFromJson(json);
}
