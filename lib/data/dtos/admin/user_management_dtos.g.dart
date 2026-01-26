// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserCreateDtoImpl _$$UserCreateDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserCreateDtoImpl(
      email: json['email'] as String,
      name: json['name'] as String,
      nip: json['nip'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      phone: json['phone'] as String?,
      parentId: json['parentId'] as String?,
      branchId: json['branchId'] as String?,
      regionalOfficeId: json['regionalOfficeId'] as String?,
    );

Map<String, dynamic> _$$UserCreateDtoImplToJson(_$UserCreateDtoImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'nip': instance.nip,
      'role': _$UserRoleEnumMap[instance.role]!,
      'phone': instance.phone,
      'parentId': instance.parentId,
      'branchId': instance.branchId,
      'regionalOfficeId': instance.regionalOfficeId,
    };

const _$UserRoleEnumMap = {
  UserRole.superadmin: 'SUPERADMIN',
  UserRole.admin: 'ADMIN',
  UserRole.roh: 'ROH',
  UserRole.bm: 'BM',
  UserRole.bh: 'BH',
  UserRole.rm: 'RM',
};

_$UserUpdateDtoImpl _$$UserUpdateDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserUpdateDtoImpl(
      name: json['name'] as String?,
      nip: json['nip'] as String?,
      phone: json['phone'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      parentId: json['parentId'] as String?,
      branchId: json['branchId'] as String?,
      regionalOfficeId: json['regionalOfficeId'] as String?,
    );

Map<String, dynamic> _$$UserUpdateDtoImplToJson(_$UserUpdateDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nip': instance.nip,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role],
      'parentId': instance.parentId,
      'branchId': instance.branchId,
      'regionalOfficeId': instance.regionalOfficeId,
    };

_$UserCreateResultImpl _$$UserCreateResultImplFromJson(
  Map<String, dynamic> json,
) => _$UserCreateResultImpl(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  temporaryPassword: json['temporaryPassword'] as String,
);

Map<String, dynamic> _$$UserCreateResultImplToJson(
  _$UserCreateResultImpl instance,
) => <String, dynamic>{
  'user': instance.user,
  'temporaryPassword': instance.temporaryPassword,
};
