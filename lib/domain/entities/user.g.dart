// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  nip: json['nip'] as String?,
  phone: json['phone'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  parentId: json['parentId'] as String?,
  branchId: json['branchId'] as String?,
  regionalOfficeId: json['regionalOfficeId'] as String?,
  photoUrl: json['photoUrl'] as String?,
  isActive: json['isActive'] as bool,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'nip': instance.nip,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'parentId': instance.parentId,
      'branchId': instance.branchId,
      'regionalOfficeId': instance.regionalOfficeId,
      'photoUrl': instance.photoUrl,
      'isActive': instance.isActive,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.superadmin: 'SUPERADMIN',
  UserRole.admin: 'ADMIN',
  UserRole.roh: 'ROH',
  UserRole.bm: 'BM',
  UserRole.bh: 'BH',
  UserRole.rm: 'RM',
};
