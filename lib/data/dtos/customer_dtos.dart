import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_dtos.freezed.dart';
part 'customer_dtos.g.dart';

/// DTO for creating a new customer.
@freezed
class CustomerCreateDto with _$CustomerCreateDto {
  const factory CustomerCreateDto({
    required String name,
    String? address,
    required String provinceId,
    required String cityId,
    required String companyTypeId,
    required String ownershipTypeId,
    required String industryId,
    required String assignedRmId,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    String? imageUrl,
    String? notes,
  }) = _CustomerCreateDto;

  factory CustomerCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerCreateDtoFromJson(json);
}

/// DTO for updating an existing customer.
@freezed
class CustomerUpdateDto with _$CustomerUpdateDto {
  const factory CustomerUpdateDto({
    String? name,
    String? address,
    String? provinceId,
    String? cityId,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? companyTypeId,
    String? ownershipTypeId,
    String? industryId,
    String? npwp,
    String? assignedRmId,
    String? imageUrl,
    String? notes,
    bool? isActive,
  }) = _CustomerUpdateDto;

  factory CustomerUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerUpdateDtoFromJson(json);
}

/// DTO for syncing customer data with Supabase.
@freezed
class CustomerSyncDto with _$CustomerSyncDto {
  const factory CustomerSyncDto({
    required String id,
    required String code,
    required String name,
    String? address,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: 'province_id') required String provinceId,
    @JsonKey(name: 'city_id') required String cityId,
    @JsonKey(name: 'company_type_id') required String companyTypeId,
    @JsonKey(name: 'ownership_type_id') required String ownershipTypeId,
    @JsonKey(name: 'industry_id') required String industryId,
    @JsonKey(name: 'assigned_rm_id') required String assignedRmId,
    @JsonKey(name: 'postal_code') String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _CustomerSyncDto;

  factory CustomerSyncDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerSyncDtoFromJson(json);
}

/// DTO for key person operations.
@freezed
class KeyPersonDto with _$KeyPersonDto {
  const factory KeyPersonDto({
    required String ownerType,
    required String name,
    String? id,
    String? customerId,
    String? brokerId,
    String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    @Default(false) bool isPrimary,
    String? notes,
  }) = _KeyPersonDto;

  factory KeyPersonDto.fromJson(Map<String, dynamic> json) =>
      _$KeyPersonDtoFromJson(json);
}

/// DTO for syncing key person data with Supabase.
@freezed
class KeyPersonSyncDto with _$KeyPersonSyncDto {
  const factory KeyPersonSyncDto({
    required String id,
    required String name,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @JsonKey(name: 'owner_type') required String ownerType,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'broker_id') String? brokerId,
    @JsonKey(name: 'hvc_id') String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    String? notes,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _KeyPersonSyncDto;

  factory KeyPersonSyncDto.fromJson(Map<String, dynamic> json) =>
      _$KeyPersonSyncDtoFromJson(json);
}
