// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrokerImpl _$$BrokerImplFromJson(Map<String, dynamic> json) => _$BrokerImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
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
  imageUrl: json['imageUrl'] as String?,
  notes: json['notes'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isPendingSync: json['isPendingSync'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  provinceName: json['provinceName'] as String?,
  cityName: json['cityName'] as String?,
);

Map<String, dynamic> _$$BrokerImplToJson(_$BrokerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
      'imageUrl': instance.imageUrl,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'isPendingSync': instance.isPendingSync,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'provinceName': instance.provinceName,
      'cityName': instance.cityName,
    };

_$BrokerWithDetailsImpl _$$BrokerWithDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$BrokerWithDetailsImpl(
  broker: Broker.fromJson(json['broker'] as Map<String, dynamic>),
  keyPersonsCount: (json['keyPersonsCount'] as num?)?.toInt() ?? 0,
  pipelineCount: (json['pipelineCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$BrokerWithDetailsImplToJson(
  _$BrokerWithDetailsImpl instance,
) => <String, dynamic>{
  'broker': instance.broker,
  'keyPersonsCount': instance.keyPersonsCount,
  'pipelineCount': instance.pipelineCount,
};
