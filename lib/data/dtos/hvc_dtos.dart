import 'package:freezed_annotation/freezed_annotation.dart';

part 'hvc_dtos.freezed.dart';
part 'hvc_dtos.g.dart';

/// DTO for creating a new HVC.
@freezed
class HvcCreateDto with _$HvcCreateDto {
  const factory HvcCreateDto({
    required String name,
    required String typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
  }) = _HvcCreateDto;

  factory HvcCreateDto.fromJson(Map<String, dynamic> json) =>
      _$HvcCreateDtoFromJson(json);
}

/// DTO for updating an existing HVC.
@freezed
class HvcUpdateDto with _$HvcUpdateDto {
  const factory HvcUpdateDto({
    String? name,
    String? typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
    bool? isActive,
  }) = _HvcUpdateDto;

  factory HvcUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$HvcUpdateDtoFromJson(json);
}

/// DTO for creating a customer-HVC link.
@freezed
class CustomerHvcLinkDto with _$CustomerHvcLinkDto {
  const factory CustomerHvcLinkDto({
    required String customerId,
    required String hvcId,
    required String relationshipType,
    String? notes,
  }) = _CustomerHvcLinkDto;

  factory CustomerHvcLinkDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerHvcLinkDtoFromJson(json);
}
