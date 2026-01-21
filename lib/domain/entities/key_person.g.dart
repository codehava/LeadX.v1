// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KeyPersonImpl _$$KeyPersonImplFromJson(Map<String, dynamic> json) =>
    _$KeyPersonImpl(
      id: json['id'] as String,
      ownerType: $enumDecode(_$KeyPersonOwnerTypeEnumMap, json['ownerType']),
      name: json['name'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customerId: json['customerId'] as String?,
      brokerId: json['brokerId'] as String?,
      hvcId: json['hvcId'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$$KeyPersonImplToJson(_$KeyPersonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerType': _$KeyPersonOwnerTypeEnumMap[instance.ownerType]!,
      'name': instance.name,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customerId': instance.customerId,
      'brokerId': instance.brokerId,
      'hvcId': instance.hvcId,
      'position': instance.position,
      'department': instance.department,
      'phone': instance.phone,
      'email': instance.email,
      'notes': instance.notes,
      'isPrimary': instance.isPrimary,
      'isActive': instance.isActive,
      'isPendingSync': instance.isPendingSync,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$KeyPersonOwnerTypeEnumMap = {
  KeyPersonOwnerType.customer: 'customer',
  KeyPersonOwnerType.hvc: 'hvc',
  KeyPersonOwnerType.broker: 'broker',
};
