import 'package:freezed_annotation/freezed_annotation.dart';

part 'broker_dtos.freezed.dart';
part 'broker_dtos.g.dart';

/// DTO for creating a new Broker.
@freezed
class BrokerCreateDto with _$BrokerCreateDto {
  const factory BrokerCreateDto({
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
    String? notes,
  }) = _BrokerCreateDto;

  factory BrokerCreateDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerCreateDtoFromJson(json);
}

/// DTO for updating an existing Broker.
@freezed
class BrokerUpdateDto with _$BrokerUpdateDto {
  const factory BrokerUpdateDto({
    String? name,
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
    String? notes,
  }) = _BrokerUpdateDto;

  factory BrokerUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$BrokerUpdateDtoFromJson(json);
}
