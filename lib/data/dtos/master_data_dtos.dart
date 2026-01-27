import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_data_dtos.freezed.dart';
part 'master_data_dtos.g.dart';

// ============================================
// GEOGRAPHY DTOs
// ============================================

@freezed
class ProvinceDto with _$ProvinceDto {
  const factory ProvinceDto({
    required String id,
    required String code,
    required String name,
    required bool isActive,
  }) = _ProvinceDto;

  factory ProvinceDto.fromJson(Map<String, dynamic> json) =>
      _$ProvinceDtoFromJson(json);
}

@freezed
class CityDto with _$CityDto {
  const factory CityDto({
    required String id,
    required String code,
    required String name,
    required String provinceId,
    required bool isActive,
  }) = _CityDto;

  factory CityDto.fromJson(Map<String, dynamic> json) =>
      _$CityDtoFromJson(json);
}

// ============================================
// COMPANY CLASSIFICATION DTOs
// ============================================

@freezed
class CompanyTypeDto with _$CompanyTypeDto {
  const factory CompanyTypeDto({
    required String id,
    required String code,
    required String name,
    required int sortOrder,
    required bool isActive,
  }) = _CompanyTypeDto;

  factory CompanyTypeDto.fromJson(Map<String, dynamic> json) =>
      _$CompanyTypeDtoFromJson(json);
}

@freezed
class OwnershipTypeDto with _$OwnershipTypeDto {
  const factory OwnershipTypeDto({
    required String id,
    required String code,
    required String name,
    required int sortOrder,
    required bool isActive,
  }) = _OwnershipTypeDto;

  factory OwnershipTypeDto.fromJson(Map<String, dynamic> json) =>
      _$OwnershipTypeDtoFromJson(json);
}

@freezed
class IndustryDto with _$IndustryDto {
  const factory IndustryDto({
    required String id,
    required String code,
    required String name,
    required int sortOrder,
    required bool isActive,
  }) = _IndustryDto;

  factory IndustryDto.fromJson(Map<String, dynamic> json) =>
      _$IndustryDtoFromJson(json);
}

// ============================================
// PRODUCT CLASSIFICATION DTOs
// ============================================

@freezed
class CobDto with _$CobDto {
  const factory CobDto({
    required String id,
    required String code,
    required String name,
    String? description,
    required int sortOrder,
    required bool isActive,
  }) = _CobDto;

  factory CobDto.fromJson(Map<String, dynamic> json) =>
      _$CobDtoFromJson(json);
}

@freezed
class LobDto with _$LobDto {
  const factory LobDto({
    required String id,
    required String cobId,
    required String code,
    required String name,
    String? description,
    required int sortOrder,
    required bool isActive,
  }) = _LobDto;

  factory LobDto.fromJson(Map<String, dynamic> json) =>
      _$LobDtoFromJson(json);
}

// ============================================
// PIPELINE CLASSIFICATION DTOs
// ============================================

@freezed
class PipelineStageDto with _$PipelineStageDto {
  const factory PipelineStageDto({
    required String id,
    required String code,
    required String name,
    required int probability,
    required int sequence,
    String? color,
    required bool isFinal,
    required bool isWon,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PipelineStageDto;

  factory PipelineStageDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineStageDtoFromJson(json);
}

@freezed
class PipelineStatusDto with _$PipelineStatusDto {
  const factory PipelineStatusDto({
    required String id,
    required String stageId,
    required String code,
    required String name,
    String? description,
    required int sequence,
    required bool isDefault,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PipelineStatusDto;

  factory PipelineStatusDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineStatusDtoFromJson(json);
}

// ============================================
// ACTIVITY CLASSIFICATION DTOs
// ============================================

@freezed
class ActivityTypeDto with _$ActivityTypeDto {
  const factory ActivityTypeDto({
    required String id,
    required String code,
    required String name,
    String? icon,
    String? color,
    required bool requireLocation,
    required bool requirePhoto,
    required bool requireNotes,
    required int sortOrder,
    required bool isActive,
  }) = _ActivityTypeDto;

  factory ActivityTypeDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityTypeDtoFromJson(json);
}

@freezed
class LeadSourceDto with _$LeadSourceDto {
  const factory LeadSourceDto({
    required String id,
    required String code,
    required String name,
    required bool requiresReferrer,
    required bool requiresBroker,
    required bool isActive,
  }) = _LeadSourceDto;

  factory LeadSourceDto.fromJson(Map<String, dynamic> json) =>
      _$LeadSourceDtoFromJson(json);
}

@freezed
class DeclineReasonDto with _$DeclineReasonDto {
  const factory DeclineReasonDto({
    required String id,
    required String code,
    required String name,
    String? description,
    required int sortOrder,
    required bool isActive,
  }) = _DeclineReasonDto;

  factory DeclineReasonDto.fromJson(Map<String, dynamic> json) =>
      _$DeclineReasonDtoFromJson(json);
}

// ============================================
// HVC DTOs
// ============================================

@freezed
class HvcTypeDto with _$HvcTypeDto {
  const factory HvcTypeDto({
    required String id,
    required String code,
    required String name,
    String? description,
    required int sortOrder,
    required bool isActive,
  }) = _HvcTypeDto;

  factory HvcTypeDto.fromJson(Map<String, dynamic> json) =>
      _$HvcTypeDtoFromJson(json);
}

// ============================================
// CREATE/UPDATE DTOs (for admin CRUD)
// ============================================

@freezed
class ProvinceCreateDto with _$ProvinceCreateDto {
  const factory ProvinceCreateDto({
    required String code,
    required String name,
    @Default(true) bool isActive,
  }) = _ProvinceCreateDto;

  factory ProvinceCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ProvinceCreateDtoFromJson(json);
}

@freezed
class CityCreateDto with _$CityCreateDto {
  const factory CityCreateDto({
    required String code,
    required String name,
    required String provinceId,
    @Default(true) bool isActive,
  }) = _CityCreateDto;

  factory CityCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CityCreateDtoFromJson(json);
}

@freezed
class CompanyTypeCreateDto with _$CompanyTypeCreateDto {
  const factory CompanyTypeCreateDto({
    required String code,
    required String name,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _CompanyTypeCreateDto;

  factory CompanyTypeCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CompanyTypeCreateDtoFromJson(json);
}

@freezed
class IndustryCreateDto with _$IndustryCreateDto {
  const factory IndustryCreateDto({
    required String code,
    required String name,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _IndustryCreateDto;

  factory IndustryCreateDto.fromJson(Map<String, dynamic> json) =>
      _$IndustryCreateDtoFromJson(json);
}

@freezed
class PipelineStageCreateDto with _$PipelineStageCreateDto {
  const factory PipelineStageCreateDto({
    required String code,
    required String name,
    required int probability,
    required int sequence,
    String? color,
    @Default(false) bool isFinal,
    @Default(false) bool isWon,
    @Default(true) bool isActive,
  }) = _PipelineStageCreateDto;

  factory PipelineStageCreateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineStageCreateDtoFromJson(json);
}
