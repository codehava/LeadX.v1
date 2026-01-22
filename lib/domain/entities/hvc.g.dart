// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hvc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HvcTypeImpl _$$HvcTypeImplFromJson(Map<String, dynamic> json) =>
    _$HvcTypeImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$HvcTypeImplToJson(_$HvcTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

_$HvcImpl _$$HvcImplFromJson(Map<String, dynamic> json) => _$HvcImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  typeId: json['typeId'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  description: json['description'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  radiusMeters: (json['radiusMeters'] as num?)?.toInt() ?? 500,
  potentialValue: (json['potentialValue'] as num?)?.toDouble(),
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isPendingSync: json['isPendingSync'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  lastSyncAt: json['lastSyncAt'] == null
      ? null
      : DateTime.parse(json['lastSyncAt'] as String),
  typeName: json['typeName'] as String?,
);

Map<String, dynamic> _$$HvcImplToJson(_$HvcImpl instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'typeId': instance.typeId,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'description': instance.description,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'radiusMeters': instance.radiusMeters,
  'potentialValue': instance.potentialValue,
  'imageUrl': instance.imageUrl,
  'isActive': instance.isActive,
  'isPendingSync': instance.isPendingSync,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
  'typeName': instance.typeName,
};

_$CustomerHvcLinkImpl _$$CustomerHvcLinkImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerHvcLinkImpl(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  hvcId: json['hvcId'] as String,
  relationshipType: json['relationshipType'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  isPendingSync: json['isPendingSync'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  customerName: json['customerName'] as String?,
  customerCode: json['customerCode'] as String?,
  hvcName: json['hvcName'] as String?,
  hvcCode: json['hvcCode'] as String?,
);

Map<String, dynamic> _$$CustomerHvcLinkImplToJson(
  _$CustomerHvcLinkImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'hvcId': instance.hvcId,
  'relationshipType': instance.relationshipType,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
  'isPendingSync': instance.isPendingSync,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'customerName': instance.customerName,
  'customerCode': instance.customerCode,
  'hvcName': instance.hvcName,
  'hvcCode': instance.hvcCode,
};

_$HvcWithDetailsImpl _$$HvcWithDetailsImplFromJson(Map<String, dynamic> json) =>
    _$HvcWithDetailsImpl(
      hvc: Hvc.fromJson(json['hvc'] as Map<String, dynamic>),
      linkedCustomers:
          (json['linkedCustomers'] as List<dynamic>?)
              ?.map((e) => CustomerHvcLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keyPersonsCount: (json['keyPersonsCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HvcWithDetailsImplToJson(
  _$HvcWithDetailsImpl instance,
) => <String, dynamic>{
  'hvc': instance.hvc,
  'linkedCustomers': instance.linkedCustomers,
  'keyPersonsCount': instance.keyPersonsCount,
};
