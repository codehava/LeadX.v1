// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerCreateDtoImpl _$$CustomerCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerCreateDtoImpl(
  name: json['name'] as String,
  address: json['address'] as String,
  provinceId: json['provinceId'] as String,
  cityId: json['cityId'] as String,
  companyTypeId: json['companyTypeId'] as String,
  ownershipTypeId: json['ownershipTypeId'] as String,
  industryId: json['industryId'] as String,
  assignedRmId: json['assignedRmId'] as String,
  postalCode: json['postalCode'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  npwp: json['npwp'] as String?,
  imageUrl: json['imageUrl'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$CustomerCreateDtoImplToJson(
  _$CustomerCreateDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'provinceId': instance.provinceId,
  'cityId': instance.cityId,
  'companyTypeId': instance.companyTypeId,
  'ownershipTypeId': instance.ownershipTypeId,
  'industryId': instance.industryId,
  'assignedRmId': instance.assignedRmId,
  'postalCode': instance.postalCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'npwp': instance.npwp,
  'imageUrl': instance.imageUrl,
  'notes': instance.notes,
};

_$CustomerUpdateDtoImpl _$$CustomerUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerUpdateDtoImpl(
  name: json['name'] as String?,
  address: json['address'] as String?,
  provinceId: json['provinceId'] as String?,
  cityId: json['cityId'] as String?,
  postalCode: json['postalCode'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  companyTypeId: json['companyTypeId'] as String?,
  ownershipTypeId: json['ownershipTypeId'] as String?,
  industryId: json['industryId'] as String?,
  npwp: json['npwp'] as String?,
  assignedRmId: json['assignedRmId'] as String?,
  imageUrl: json['imageUrl'] as String?,
  notes: json['notes'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$$CustomerUpdateDtoImplToJson(
  _$CustomerUpdateDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'provinceId': instance.provinceId,
  'cityId': instance.cityId,
  'postalCode': instance.postalCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'companyTypeId': instance.companyTypeId,
  'ownershipTypeId': instance.ownershipTypeId,
  'industryId': instance.industryId,
  'npwp': instance.npwp,
  'assignedRmId': instance.assignedRmId,
  'imageUrl': instance.imageUrl,
  'notes': instance.notes,
  'isActive': instance.isActive,
};

_$CustomerSyncDtoImpl _$$CustomerSyncDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerSyncDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  provinceId: json['province_id'] as String,
  cityId: json['city_id'] as String,
  companyTypeId: json['company_type_id'] as String,
  ownershipTypeId: json['ownership_type_id'] as String,
  industryId: json['industry_id'] as String,
  assignedRmId: json['assigned_rm_id'] as String,
  postalCode: json['postal_code'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  npwp: json['npwp'] as String?,
  imageUrl: json['image_url'] as String?,
  notes: json['notes'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$$CustomerSyncDtoImplToJson(
  _$CustomerSyncDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'address': instance.address,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'province_id': instance.provinceId,
  'city_id': instance.cityId,
  'company_type_id': instance.companyTypeId,
  'ownership_type_id': instance.ownershipTypeId,
  'industry_id': instance.industryId,
  'assigned_rm_id': instance.assignedRmId,
  'postal_code': instance.postalCode,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'npwp': instance.npwp,
  'image_url': instance.imageUrl,
  'notes': instance.notes,
  'is_active': instance.isActive,
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_$KeyPersonDtoImpl _$$KeyPersonDtoImplFromJson(Map<String, dynamic> json) =>
    _$KeyPersonDtoImpl(
      ownerType: json['ownerType'] as String,
      name: json['name'] as String,
      id: json['id'] as String?,
      customerId: json['customerId'] as String?,
      brokerId: json['brokerId'] as String?,
      hvcId: json['hvcId'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$KeyPersonDtoImplToJson(_$KeyPersonDtoImpl instance) =>
    <String, dynamic>{
      'ownerType': instance.ownerType,
      'name': instance.name,
      'id': instance.id,
      'customerId': instance.customerId,
      'brokerId': instance.brokerId,
      'hvcId': instance.hvcId,
      'position': instance.position,
      'department': instance.department,
      'phone': instance.phone,
      'email': instance.email,
      'isPrimary': instance.isPrimary,
      'notes': instance.notes,
    };

_$KeyPersonSyncDtoImpl _$$KeyPersonSyncDtoImplFromJson(
  Map<String, dynamic> json,
) => _$KeyPersonSyncDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  ownerType: json['owner_type'] as String,
  customerId: json['customer_id'] as String?,
  brokerId: json['broker_id'] as String?,
  hvcId: json['hvc_id'] as String?,
  position: json['position'] as String?,
  department: json['department'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  isPrimary: json['is_primary'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  notes: json['notes'] as String?,
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$$KeyPersonSyncDtoImplToJson(
  _$KeyPersonSyncDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'owner_type': instance.ownerType,
  'customer_id': instance.customerId,
  'broker_id': instance.brokerId,
  'hvc_id': instance.hvcId,
  'position': instance.position,
  'department': instance.department,
  'phone': instance.phone,
  'email': instance.email,
  'is_primary': instance.isPrimary,
  'is_active': instance.isActive,
  'notes': instance.notes,
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
