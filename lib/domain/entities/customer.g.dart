// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      provinceId: json['provinceId'] as String,
      cityId: json['cityId'] as String,
      companyTypeId: json['companyTypeId'] as String,
      ownershipTypeId: json['ownershipTypeId'] as String,
      industryId: json['industryId'] as String,
      assignedRmId: json['assignedRmId'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      postalCode: json['postalCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      npwp: json['npwp'] as String?,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      provinceName: json['provinceName'] as String?,
      cityName: json['cityName'] as String?,
      companyTypeName: json['companyTypeName'] as String?,
      ownershipTypeName: json['ownershipTypeName'] as String?,
      industryName: json['industryName'] as String?,
      assignedRmName: json['assignedRmName'] as String?,
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'address': instance.address,
      'provinceId': instance.provinceId,
      'cityId': instance.cityId,
      'companyTypeId': instance.companyTypeId,
      'ownershipTypeId': instance.ownershipTypeId,
      'industryId': instance.industryId,
      'assignedRmId': instance.assignedRmId,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'postalCode': instance.postalCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'npwp': instance.npwp,
      'imageUrl': instance.imageUrl,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'isPendingSync': instance.isPendingSync,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'provinceName': instance.provinceName,
      'cityName': instance.cityName,
      'companyTypeName': instance.companyTypeName,
      'ownershipTypeName': instance.ownershipTypeName,
      'industryName': instance.industryName,
      'assignedRmName': instance.assignedRmName,
    };

_$KeyPersonSummaryImpl _$$KeyPersonSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$KeyPersonSummaryImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  position: json['position'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  isPrimary: json['isPrimary'] as bool? ?? false,
);

Map<String, dynamic> _$$KeyPersonSummaryImplToJson(
  _$KeyPersonSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'position': instance.position,
  'phone': instance.phone,
  'email': instance.email,
  'isPrimary': instance.isPrimary,
};

_$CustomerWithKeyPersonsImpl _$$CustomerWithKeyPersonsImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerWithKeyPersonsImpl(
  customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
  keyPersons: (json['keyPersons'] as List<dynamic>)
      .map((e) => KeyPersonSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CustomerWithKeyPersonsImplToJson(
  _$CustomerWithKeyPersonsImpl instance,
) => <String, dynamic>{
  'customer': instance.customer,
  'keyPersons': instance.keyPersons,
};
