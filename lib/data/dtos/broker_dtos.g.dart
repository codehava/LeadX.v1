// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broker_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrokerCreateDtoImpl _$$BrokerCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$BrokerCreateDtoImpl(
  name: json['name'] as String,
  licenseNumber: json['licenseNumber'] as String?,
  address: json['address'] as String?,
  provinceId: json['provinceId'] as String?,
  cityId: json['cityId'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  commissionRate: (json['commissionRate'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$BrokerCreateDtoImplToJson(
  _$BrokerCreateDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'licenseNumber': instance.licenseNumber,
  'address': instance.address,
  'provinceId': instance.provinceId,
  'cityId': instance.cityId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'commissionRate': instance.commissionRate,
  'notes': instance.notes,
};

_$BrokerUpdateDtoImpl _$$BrokerUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$BrokerUpdateDtoImpl(
  name: json['name'] as String?,
  licenseNumber: json['licenseNumber'] as String?,
  address: json['address'] as String?,
  provinceId: json['provinceId'] as String?,
  cityId: json['cityId'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  commissionRate: (json['commissionRate'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$BrokerUpdateDtoImplToJson(
  _$BrokerUpdateDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'licenseNumber': instance.licenseNumber,
  'address': instance.address,
  'provinceId': instance.provinceId,
  'cityId': instance.cityId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'commissionRate': instance.commissionRate,
  'notes': instance.notes,
};
