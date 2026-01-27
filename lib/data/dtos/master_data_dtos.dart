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
// ORGANIZATION DTOs
// ============================================

@freezed
class RegionalOfficeDto with _$RegionalOfficeDto {
  const factory RegionalOfficeDto({
    required String id,
    required String code,
    required String name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RegionalOfficeDto;

  factory RegionalOfficeDto.fromJson(Map<String, dynamic> json) =>
      _$RegionalOfficeDtoFromJson(json);
}

@freezed
class BranchDto with _$BranchDto {
  const factory BranchDto({
    required String id,
    required String code,
    required String name,
    required String regionalOfficeId,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BranchDto;

  factory BranchDto.fromJson(Map<String, dynamic> json) =>
      _$BranchDtoFromJson(json);
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

@freezed
class LobCreateDto with _$LobCreateDto {
  const factory LobCreateDto({
    required String cobId,
    required String code,
    required String name,
    String? description,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
  }) = _LobCreateDto;

  factory LobCreateDto.fromJson(Map<String, dynamic> json) =>
      _$LobCreateDtoFromJson(json);
}

@freezed
class PipelineStatusCreateDto with _$PipelineStatusCreateDto {
  const factory PipelineStatusCreateDto({
    required String stageId,
    required String code,
    required String name,
    String? description,
    required int sequence,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
  }) = _PipelineStatusCreateDto;

  factory PipelineStatusCreateDto.fromJson(Map<String, dynamic> json) =>
      _$PipelineStatusCreateDtoFromJson(json);
}

@freezed
class HvcDto with _$HvcDto {
  const factory HvcDto({
    required String id,
    required String code,
    required String name,
    required String typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
    required bool isActive,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HvcDto;

  factory HvcDto.fromJson(Map<String, dynamic> json) =>
      _$HvcDtoFromJson(json);
}

@freezed
class HvcCreateDto with _$HvcCreateDto {
  const factory HvcCreateDto({
    required String code,
    required String name,
    required String typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
    @Default(true) bool isActive,
  }) = _HvcCreateDto;

  factory HvcCreateDto.fromJson(Map<String, dynamic> json) =>
      _$HvcCreateDtoFromJson(json);
}

@freezed
class BrokerDto with _$BrokerDto {
  const factory BrokerDto({
    required String id,
    required String code,
    required String name,
    String? licenseNumber,
    String? address,
    String? provinceId,
    String? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    double? commissionRate,
    String? imageUrl,
    String? notes,
    required bool isActive,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BrokerDto;

  factory BrokerDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerDtoFromJson(json);
}

@freezed
class BrokerCreateDto with _$BrokerCreateDto {
  const factory BrokerCreateDto({
    required String code,
    required String name,
    String? licenseNumber,
    String? address,
    String? provinceId,
    String? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    double? commissionRate,
    String? imageUrl,
    String? notes,
    @Default(true) bool isActive,
  }) = _BrokerCreateDto;

  factory BrokerCreateDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerCreateDtoFromJson(json);
}
