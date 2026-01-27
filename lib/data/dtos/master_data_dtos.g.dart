// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_data_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProvinceDtoImpl _$$ProvinceDtoImplFromJson(Map<String, dynamic> json) =>
    _$ProvinceDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$ProvinceDtoImplToJson(_$ProvinceDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'isActive': instance.isActive,
    };

_$CityDtoImpl _$$CityDtoImplFromJson(Map<String, dynamic> json) =>
    _$CityDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      provinceId: json['provinceId'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$CityDtoImplToJson(_$CityDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'provinceId': instance.provinceId,
      'isActive': instance.isActive,
    };

_$CompanyTypeDtoImpl _$$CompanyTypeDtoImplFromJson(Map<String, dynamic> json) =>
    _$CompanyTypeDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$CompanyTypeDtoImplToJson(
  _$CompanyTypeDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$OwnershipTypeDtoImpl _$$OwnershipTypeDtoImplFromJson(
  Map<String, dynamic> json,
) => _$OwnershipTypeDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$$OwnershipTypeDtoImplToJson(
  _$OwnershipTypeDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$IndustryDtoImpl _$$IndustryDtoImplFromJson(Map<String, dynamic> json) =>
    _$IndustryDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$IndustryDtoImplToJson(_$IndustryDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

_$CobDtoImpl _$$CobDtoImplFromJson(Map<String, dynamic> json) => _$CobDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$$CobDtoImplToJson(_$CobDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

_$LobDtoImpl _$$LobDtoImplFromJson(Map<String, dynamic> json) => _$LobDtoImpl(
  id: json['id'] as String,
  cobId: json['cobId'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$$LobDtoImplToJson(_$LobDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cobId': instance.cobId,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

_$PipelineStageDtoImpl _$$PipelineStageDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStageDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  probability: (json['probability'] as num).toInt(),
  sequence: (json['sequence'] as num).toInt(),
  color: json['color'] as String?,
  isFinal: json['isFinal'] as bool,
  isWon: json['isWon'] as bool,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$PipelineStageDtoImplToJson(
  _$PipelineStageDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'probability': instance.probability,
  'sequence': instance.sequence,
  'color': instance.color,
  'isFinal': instance.isFinal,
  'isWon': instance.isWon,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$PipelineStatusDtoImpl _$$PipelineStatusDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStatusDtoImpl(
  id: json['id'] as String,
  stageId: json['stageId'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  sequence: (json['sequence'] as num).toInt(),
  isDefault: json['isDefault'] as bool,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$PipelineStatusDtoImplToJson(
  _$PipelineStatusDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'stageId': instance.stageId,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'sequence': instance.sequence,
  'isDefault': instance.isDefault,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$ActivityTypeDtoImpl _$$ActivityTypeDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ActivityTypeDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  requireLocation: json['requireLocation'] as bool,
  requirePhoto: json['requirePhoto'] as bool,
  requireNotes: json['requireNotes'] as bool,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$$ActivityTypeDtoImplToJson(
  _$ActivityTypeDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'icon': instance.icon,
  'color': instance.color,
  'requireLocation': instance.requireLocation,
  'requirePhoto': instance.requirePhoto,
  'requireNotes': instance.requireNotes,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$LeadSourceDtoImpl _$$LeadSourceDtoImplFromJson(Map<String, dynamic> json) =>
    _$LeadSourceDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      requiresReferrer: json['requiresReferrer'] as bool,
      requiresBroker: json['requiresBroker'] as bool,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$LeadSourceDtoImplToJson(_$LeadSourceDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'requiresReferrer': instance.requiresReferrer,
      'requiresBroker': instance.requiresBroker,
      'isActive': instance.isActive,
    };

_$DeclineReasonDtoImpl _$$DeclineReasonDtoImplFromJson(
  Map<String, dynamic> json,
) => _$DeclineReasonDtoImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$$DeclineReasonDtoImplToJson(
  _$DeclineReasonDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$HvcTypeDtoImpl _$$HvcTypeDtoImplFromJson(Map<String, dynamic> json) =>
    _$HvcTypeDtoImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$HvcTypeDtoImplToJson(_$HvcTypeDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

_$ProvinceCreateDtoImpl _$$ProvinceCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ProvinceCreateDtoImpl(
  code: json['code'] as String,
  name: json['name'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$ProvinceCreateDtoImplToJson(
  _$ProvinceCreateDtoImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'isActive': instance.isActive,
};

_$CityCreateDtoImpl _$$CityCreateDtoImplFromJson(Map<String, dynamic> json) =>
    _$CityCreateDtoImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      provinceId: json['provinceId'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$CityCreateDtoImplToJson(_$CityCreateDtoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'provinceId': instance.provinceId,
      'isActive': instance.isActive,
    };

_$CompanyTypeCreateDtoImpl _$$CompanyTypeCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CompanyTypeCreateDtoImpl(
  code: json['code'] as String,
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$CompanyTypeCreateDtoImplToJson(
  _$CompanyTypeCreateDtoImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$IndustryCreateDtoImpl _$$IndustryCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$IndustryCreateDtoImpl(
  code: json['code'] as String,
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$IndustryCreateDtoImplToJson(
  _$IndustryCreateDtoImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};

_$PipelineStageCreateDtoImpl _$$PipelineStageCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PipelineStageCreateDtoImpl(
  code: json['code'] as String,
  name: json['name'] as String,
  probability: (json['probability'] as num).toInt(),
  sequence: (json['sequence'] as num).toInt(),
  color: json['color'] as String?,
  isFinal: json['isFinal'] as bool? ?? false,
  isWon: json['isWon'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$$PipelineStageCreateDtoImplToJson(
  _$PipelineStageCreateDtoImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'probability': instance.probability,
  'sequence': instance.sequence,
  'color': instance.color,
  'isFinal': instance.isFinal,
  'isWon': instance.isWon,
  'isActive': instance.isActive,
};
