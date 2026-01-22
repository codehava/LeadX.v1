// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hvc_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HvcCreateDtoImpl _$$HvcCreateDtoImplFromJson(Map<String, dynamic> json) =>
    _$HvcCreateDtoImpl(
      name: json['name'] as String,
      typeId: json['typeId'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toInt(),
      potentialValue: (json['potentialValue'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$HvcCreateDtoImplToJson(_$HvcCreateDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'typeId': instance.typeId,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'potentialValue': instance.potentialValue,
      'imageUrl': instance.imageUrl,
    };

_$HvcUpdateDtoImpl _$$HvcUpdateDtoImplFromJson(Map<String, dynamic> json) =>
    _$HvcUpdateDtoImpl(
      name: json['name'] as String?,
      typeId: json['typeId'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toInt(),
      potentialValue: (json['potentialValue'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$$HvcUpdateDtoImplToJson(_$HvcUpdateDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'typeId': instance.typeId,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'potentialValue': instance.potentialValue,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
    };

_$CustomerHvcLinkDtoImpl _$$CustomerHvcLinkDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerHvcLinkDtoImpl(
  customerId: json['customerId'] as String,
  hvcId: json['hvcId'] as String,
  relationshipType: json['relationshipType'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$CustomerHvcLinkDtoImplToJson(
  _$CustomerHvcLinkDtoImpl instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'hvcId': instance.hvcId,
  'relationshipType': instance.relationshipType,
  'notes': instance.notes,
};
