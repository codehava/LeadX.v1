// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'master_data_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProvinceDto _$ProvinceDtoFromJson(Map<String, dynamic> json) {
  return _ProvinceDto.fromJson(json);
}

/// @nodoc
mixin _$ProvinceDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ProvinceDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProvinceDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProvinceDtoCopyWith<ProvinceDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProvinceDtoCopyWith<$Res> {
  factory $ProvinceDtoCopyWith(
    ProvinceDto value,
    $Res Function(ProvinceDto) then,
  ) = _$ProvinceDtoCopyWithImpl<$Res, ProvinceDto>;
  @useResult
  $Res call({String id, String code, String name, bool isActive});
}

/// @nodoc
class _$ProvinceDtoCopyWithImpl<$Res, $Val extends ProvinceDto>
    implements $ProvinceDtoCopyWith<$Res> {
  _$ProvinceDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProvinceDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProvinceDtoImplCopyWith<$Res>
    implements $ProvinceDtoCopyWith<$Res> {
  factory _$$ProvinceDtoImplCopyWith(
    _$ProvinceDtoImpl value,
    $Res Function(_$ProvinceDtoImpl) then,
  ) = __$$ProvinceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String code, String name, bool isActive});
}

/// @nodoc
class __$$ProvinceDtoImplCopyWithImpl<$Res>
    extends _$ProvinceDtoCopyWithImpl<$Res, _$ProvinceDtoImpl>
    implements _$$ProvinceDtoImplCopyWith<$Res> {
  __$$ProvinceDtoImplCopyWithImpl(
    _$ProvinceDtoImpl _value,
    $Res Function(_$ProvinceDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProvinceDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? isActive = null,
  }) {
    return _then(
      _$ProvinceDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProvinceDtoImpl implements _ProvinceDto {
  const _$ProvinceDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory _$ProvinceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProvinceDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'ProvinceDto(id: $id, code: $code, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProvinceDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, code, name, isActive);

  /// Create a copy of ProvinceDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProvinceDtoImplCopyWith<_$ProvinceDtoImpl> get copyWith =>
      __$$ProvinceDtoImplCopyWithImpl<_$ProvinceDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProvinceDtoImplToJson(this);
  }
}

abstract class _ProvinceDto implements ProvinceDto {
  const factory _ProvinceDto({
    required final String id,
    required final String code,
    required final String name,
    required final bool isActive,
  }) = _$ProvinceDtoImpl;

  factory _ProvinceDto.fromJson(Map<String, dynamic> json) =
      _$ProvinceDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  bool get isActive;

  /// Create a copy of ProvinceDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProvinceDtoImplCopyWith<_$ProvinceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CityDto _$CityDtoFromJson(Map<String, dynamic> json) {
  return _CityDto.fromJson(json);
}

/// @nodoc
mixin _$CityDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get provinceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CityDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CityDtoCopyWith<CityDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityDtoCopyWith<$Res> {
  factory $CityDtoCopyWith(CityDto value, $Res Function(CityDto) then) =
      _$CityDtoCopyWithImpl<$Res, CityDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String provinceId,
    bool isActive,
  });
}

/// @nodoc
class _$CityDtoCopyWithImpl<$Res, $Val extends CityDto>
    implements $CityDtoCopyWith<$Res> {
  _$CityDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? provinceId = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            provinceId: null == provinceId
                ? _value.provinceId
                : provinceId // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CityDtoImplCopyWith<$Res> implements $CityDtoCopyWith<$Res> {
  factory _$$CityDtoImplCopyWith(
    _$CityDtoImpl value,
    $Res Function(_$CityDtoImpl) then,
  ) = __$$CityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String provinceId,
    bool isActive,
  });
}

/// @nodoc
class __$$CityDtoImplCopyWithImpl<$Res>
    extends _$CityDtoCopyWithImpl<$Res, _$CityDtoImpl>
    implements _$$CityDtoImplCopyWith<$Res> {
  __$$CityDtoImplCopyWithImpl(
    _$CityDtoImpl _value,
    $Res Function(_$CityDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? provinceId = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CityDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        provinceId: null == provinceId
            ? _value.provinceId
            : provinceId // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CityDtoImpl implements _CityDto {
  const _$CityDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.provinceId,
    required this.isActive,
  });

  factory _$CityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String provinceId;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'CityDto(id: $id, code: $code, name: $name, provinceId: $provinceId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, name, provinceId, isActive);

  /// Create a copy of CityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CityDtoImplCopyWith<_$CityDtoImpl> get copyWith =>
      __$$CityDtoImplCopyWithImpl<_$CityDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityDtoImplToJson(this);
  }
}

abstract class _CityDto implements CityDto {
  const factory _CityDto({
    required final String id,
    required final String code,
    required final String name,
    required final String provinceId,
    required final bool isActive,
  }) = _$CityDtoImpl;

  factory _CityDto.fromJson(Map<String, dynamic> json) = _$CityDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String get provinceId;
  @override
  bool get isActive;

  /// Create a copy of CityDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CityDtoImplCopyWith<_$CityDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompanyTypeDto _$CompanyTypeDtoFromJson(Map<String, dynamic> json) {
  return _CompanyTypeDto.fromJson(json);
}

/// @nodoc
mixin _$CompanyTypeDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CompanyTypeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanyTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyTypeDtoCopyWith<CompanyTypeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyTypeDtoCopyWith<$Res> {
  factory $CompanyTypeDtoCopyWith(
    CompanyTypeDto value,
    $Res Function(CompanyTypeDto) then,
  ) = _$CompanyTypeDtoCopyWithImpl<$Res, CompanyTypeDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$CompanyTypeDtoCopyWithImpl<$Res, $Val extends CompanyTypeDto>
    implements $CompanyTypeDtoCopyWith<$Res> {
  _$CompanyTypeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanyTypeDtoImplCopyWith<$Res>
    implements $CompanyTypeDtoCopyWith<$Res> {
  factory _$$CompanyTypeDtoImplCopyWith(
    _$CompanyTypeDtoImpl value,
    $Res Function(_$CompanyTypeDtoImpl) then,
  ) = __$$CompanyTypeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$CompanyTypeDtoImplCopyWithImpl<$Res>
    extends _$CompanyTypeDtoCopyWithImpl<$Res, _$CompanyTypeDtoImpl>
    implements _$$CompanyTypeDtoImplCopyWith<$Res> {
  __$$CompanyTypeDtoImplCopyWithImpl(
    _$CompanyTypeDtoImpl _value,
    $Res Function(_$CompanyTypeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanyTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CompanyTypeDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyTypeDtoImpl implements _CompanyTypeDto {
  const _$CompanyTypeDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$CompanyTypeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyTypeDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'CompanyTypeDto(id: $id, code: $code, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyTypeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, name, sortOrder, isActive);

  /// Create a copy of CompanyTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyTypeDtoImplCopyWith<_$CompanyTypeDtoImpl> get copyWith =>
      __$$CompanyTypeDtoImplCopyWithImpl<_$CompanyTypeDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyTypeDtoImplToJson(this);
  }
}

abstract class _CompanyTypeDto implements CompanyTypeDto {
  const factory _CompanyTypeDto({
    required final String id,
    required final String code,
    required final String name,
    required final int sortOrder,
    required final bool isActive,
  }) = _$CompanyTypeDtoImpl;

  factory _CompanyTypeDto.fromJson(Map<String, dynamic> json) =
      _$CompanyTypeDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of CompanyTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyTypeDtoImplCopyWith<_$CompanyTypeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OwnershipTypeDto _$OwnershipTypeDtoFromJson(Map<String, dynamic> json) {
  return _OwnershipTypeDto.fromJson(json);
}

/// @nodoc
mixin _$OwnershipTypeDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this OwnershipTypeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OwnershipTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OwnershipTypeDtoCopyWith<OwnershipTypeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OwnershipTypeDtoCopyWith<$Res> {
  factory $OwnershipTypeDtoCopyWith(
    OwnershipTypeDto value,
    $Res Function(OwnershipTypeDto) then,
  ) = _$OwnershipTypeDtoCopyWithImpl<$Res, OwnershipTypeDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$OwnershipTypeDtoCopyWithImpl<$Res, $Val extends OwnershipTypeDto>
    implements $OwnershipTypeDtoCopyWith<$Res> {
  _$OwnershipTypeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OwnershipTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OwnershipTypeDtoImplCopyWith<$Res>
    implements $OwnershipTypeDtoCopyWith<$Res> {
  factory _$$OwnershipTypeDtoImplCopyWith(
    _$OwnershipTypeDtoImpl value,
    $Res Function(_$OwnershipTypeDtoImpl) then,
  ) = __$$OwnershipTypeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$OwnershipTypeDtoImplCopyWithImpl<$Res>
    extends _$OwnershipTypeDtoCopyWithImpl<$Res, _$OwnershipTypeDtoImpl>
    implements _$$OwnershipTypeDtoImplCopyWith<$Res> {
  __$$OwnershipTypeDtoImplCopyWithImpl(
    _$OwnershipTypeDtoImpl _value,
    $Res Function(_$OwnershipTypeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OwnershipTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$OwnershipTypeDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OwnershipTypeDtoImpl implements _OwnershipTypeDto {
  const _$OwnershipTypeDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$OwnershipTypeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$OwnershipTypeDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'OwnershipTypeDto(id: $id, code: $code, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OwnershipTypeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, name, sortOrder, isActive);

  /// Create a copy of OwnershipTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OwnershipTypeDtoImplCopyWith<_$OwnershipTypeDtoImpl> get copyWith =>
      __$$OwnershipTypeDtoImplCopyWithImpl<_$OwnershipTypeDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OwnershipTypeDtoImplToJson(this);
  }
}

abstract class _OwnershipTypeDto implements OwnershipTypeDto {
  const factory _OwnershipTypeDto({
    required final String id,
    required final String code,
    required final String name,
    required final int sortOrder,
    required final bool isActive,
  }) = _$OwnershipTypeDtoImpl;

  factory _OwnershipTypeDto.fromJson(Map<String, dynamic> json) =
      _$OwnershipTypeDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of OwnershipTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OwnershipTypeDtoImplCopyWith<_$OwnershipTypeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IndustryDto _$IndustryDtoFromJson(Map<String, dynamic> json) {
  return _IndustryDto.fromJson(json);
}

/// @nodoc
mixin _$IndustryDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this IndustryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IndustryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IndustryDtoCopyWith<IndustryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndustryDtoCopyWith<$Res> {
  factory $IndustryDtoCopyWith(
    IndustryDto value,
    $Res Function(IndustryDto) then,
  ) = _$IndustryDtoCopyWithImpl<$Res, IndustryDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$IndustryDtoCopyWithImpl<$Res, $Val extends IndustryDto>
    implements $IndustryDtoCopyWith<$Res> {
  _$IndustryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IndustryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IndustryDtoImplCopyWith<$Res>
    implements $IndustryDtoCopyWith<$Res> {
  factory _$$IndustryDtoImplCopyWith(
    _$IndustryDtoImpl value,
    $Res Function(_$IndustryDtoImpl) then,
  ) = __$$IndustryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$IndustryDtoImplCopyWithImpl<$Res>
    extends _$IndustryDtoCopyWithImpl<$Res, _$IndustryDtoImpl>
    implements _$$IndustryDtoImplCopyWith<$Res> {
  __$$IndustryDtoImplCopyWithImpl(
    _$IndustryDtoImpl _value,
    $Res Function(_$IndustryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IndustryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$IndustryDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IndustryDtoImpl implements _IndustryDto {
  const _$IndustryDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$IndustryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$IndustryDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'IndustryDto(id: $id, code: $code, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndustryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, name, sortOrder, isActive);

  /// Create a copy of IndustryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndustryDtoImplCopyWith<_$IndustryDtoImpl> get copyWith =>
      __$$IndustryDtoImplCopyWithImpl<_$IndustryDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IndustryDtoImplToJson(this);
  }
}

abstract class _IndustryDto implements IndustryDto {
  const factory _IndustryDto({
    required final String id,
    required final String code,
    required final String name,
    required final int sortOrder,
    required final bool isActive,
  }) = _$IndustryDtoImpl;

  factory _IndustryDto.fromJson(Map<String, dynamic> json) =
      _$IndustryDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of IndustryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndustryDtoImplCopyWith<_$IndustryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CobDto _$CobDtoFromJson(Map<String, dynamic> json) {
  return _CobDto.fromJson(json);
}

/// @nodoc
mixin _$CobDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CobDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CobDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CobDtoCopyWith<CobDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CobDtoCopyWith<$Res> {
  factory $CobDtoCopyWith(CobDto value, $Res Function(CobDto) then) =
      _$CobDtoCopyWithImpl<$Res, CobDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$CobDtoCopyWithImpl<$Res, $Val extends CobDto>
    implements $CobDtoCopyWith<$Res> {
  _$CobDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CobDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CobDtoImplCopyWith<$Res> implements $CobDtoCopyWith<$Res> {
  factory _$$CobDtoImplCopyWith(
    _$CobDtoImpl value,
    $Res Function(_$CobDtoImpl) then,
  ) = __$$CobDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$CobDtoImplCopyWithImpl<$Res>
    extends _$CobDtoCopyWithImpl<$Res, _$CobDtoImpl>
    implements _$$CobDtoImplCopyWith<$Res> {
  __$$CobDtoImplCopyWithImpl(
    _$CobDtoImpl _value,
    $Res Function(_$CobDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CobDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CobDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CobDtoImpl implements _CobDto {
  const _$CobDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$CobDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CobDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'CobDto(id: $id, code: $code, name: $name, description: $description, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CobDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    description,
    sortOrder,
    isActive,
  );

  /// Create a copy of CobDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CobDtoImplCopyWith<_$CobDtoImpl> get copyWith =>
      __$$CobDtoImplCopyWithImpl<_$CobDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CobDtoImplToJson(this);
  }
}

abstract class _CobDto implements CobDto {
  const factory _CobDto({
    required final String id,
    required final String code,
    required final String name,
    final String? description,
    required final int sortOrder,
    required final bool isActive,
  }) = _$CobDtoImpl;

  factory _CobDto.fromJson(Map<String, dynamic> json) = _$CobDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of CobDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CobDtoImplCopyWith<_$CobDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LobDto _$LobDtoFromJson(Map<String, dynamic> json) {
  return _LobDto.fromJson(json);
}

/// @nodoc
mixin _$LobDto {
  String get id => throw _privateConstructorUsedError;
  String get cobId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this LobDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LobDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LobDtoCopyWith<LobDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LobDtoCopyWith<$Res> {
  factory $LobDtoCopyWith(LobDto value, $Res Function(LobDto) then) =
      _$LobDtoCopyWithImpl<$Res, LobDto>;
  @useResult
  $Res call({
    String id,
    String cobId,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$LobDtoCopyWithImpl<$Res, $Val extends LobDto>
    implements $LobDtoCopyWith<$Res> {
  _$LobDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LobDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cobId = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            cobId: null == cobId
                ? _value.cobId
                : cobId // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LobDtoImplCopyWith<$Res> implements $LobDtoCopyWith<$Res> {
  factory _$$LobDtoImplCopyWith(
    _$LobDtoImpl value,
    $Res Function(_$LobDtoImpl) then,
  ) = __$$LobDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String cobId,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$LobDtoImplCopyWithImpl<$Res>
    extends _$LobDtoCopyWithImpl<$Res, _$LobDtoImpl>
    implements _$$LobDtoImplCopyWith<$Res> {
  __$$LobDtoImplCopyWithImpl(
    _$LobDtoImpl _value,
    $Res Function(_$LobDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LobDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cobId = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$LobDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        cobId: null == cobId
            ? _value.cobId
            : cobId // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LobDtoImpl implements _LobDto {
  const _$LobDtoImpl({
    required this.id,
    required this.cobId,
    required this.code,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$LobDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LobDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String cobId;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'LobDto(id: $id, cobId: $cobId, code: $code, name: $name, description: $description, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LobDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cobId, cobId) || other.cobId == cobId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    cobId,
    code,
    name,
    description,
    sortOrder,
    isActive,
  );

  /// Create a copy of LobDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LobDtoImplCopyWith<_$LobDtoImpl> get copyWith =>
      __$$LobDtoImplCopyWithImpl<_$LobDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LobDtoImplToJson(this);
  }
}

abstract class _LobDto implements LobDto {
  const factory _LobDto({
    required final String id,
    required final String cobId,
    required final String code,
    required final String name,
    final String? description,
    required final int sortOrder,
    required final bool isActive,
  }) = _$LobDtoImpl;

  factory _LobDto.fromJson(Map<String, dynamic> json) = _$LobDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get cobId;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of LobDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LobDtoImplCopyWith<_$LobDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineStageDto _$PipelineStageDtoFromJson(Map<String, dynamic> json) {
  return _PipelineStageDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineStageDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get probability => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  bool get isFinal => throw _privateConstructorUsedError;
  bool get isWon => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PipelineStageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStageDtoCopyWith<PipelineStageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStageDtoCopyWith<$Res> {
  factory $PipelineStageDtoCopyWith(
    PipelineStageDto value,
    $Res Function(PipelineStageDto) then,
  ) = _$PipelineStageDtoCopyWithImpl<$Res, PipelineStageDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int probability,
    int sequence,
    String? color,
    bool isFinal,
    bool isWon,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PipelineStageDtoCopyWithImpl<$Res, $Val extends PipelineStageDto>
    implements $PipelineStageDtoCopyWith<$Res> {
  _$PipelineStageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? probability = null,
    Object? sequence = null,
    Object? color = freezed,
    Object? isFinal = null,
    Object? isWon = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            probability: null == probability
                ? _value.probability
                : probability // ignore: cast_nullable_to_non_nullable
                      as int,
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFinal: null == isFinal
                ? _value.isFinal
                : isFinal // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWon: null == isWon
                ? _value.isWon
                : isWon // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineStageDtoImplCopyWith<$Res>
    implements $PipelineStageDtoCopyWith<$Res> {
  factory _$$PipelineStageDtoImplCopyWith(
    _$PipelineStageDtoImpl value,
    $Res Function(_$PipelineStageDtoImpl) then,
  ) = __$$PipelineStageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int probability,
    int sequence,
    String? color,
    bool isFinal,
    bool isWon,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PipelineStageDtoImplCopyWithImpl<$Res>
    extends _$PipelineStageDtoCopyWithImpl<$Res, _$PipelineStageDtoImpl>
    implements _$$PipelineStageDtoImplCopyWith<$Res> {
  __$$PipelineStageDtoImplCopyWithImpl(
    _$PipelineStageDtoImpl _value,
    $Res Function(_$PipelineStageDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? probability = null,
    Object? sequence = null,
    Object? color = freezed,
    Object? isFinal = null,
    Object? isWon = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PipelineStageDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        probability: null == probability
            ? _value.probability
            : probability // ignore: cast_nullable_to_non_nullable
                  as int,
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFinal: null == isFinal
            ? _value.isFinal
            : isFinal // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWon: null == isWon
            ? _value.isWon
            : isWon // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineStageDtoImpl implements _PipelineStageDto {
  const _$PipelineStageDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.probability,
    required this.sequence,
    this.color,
    required this.isFinal,
    required this.isWon,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory _$PipelineStageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStageDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final int probability;
  @override
  final int sequence;
  @override
  final String? color;
  @override
  final bool isFinal;
  @override
  final bool isWon;
  @override
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PipelineStageDto(id: $id, code: $code, name: $name, probability: $probability, sequence: $sequence, color: $color, isFinal: $isFinal, isWon: $isWon, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isFinal, isFinal) || other.isFinal == isFinal) &&
            (identical(other.isWon, isWon) || other.isWon == isWon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    probability,
    sequence,
    color,
    isFinal,
    isWon,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of PipelineStageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStageDtoImplCopyWith<_$PipelineStageDtoImpl> get copyWith =>
      __$$PipelineStageDtoImplCopyWithImpl<_$PipelineStageDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStageDtoImplToJson(this);
  }
}

abstract class _PipelineStageDto implements PipelineStageDto {
  const factory _PipelineStageDto({
    required final String id,
    required final String code,
    required final String name,
    required final int probability,
    required final int sequence,
    final String? color,
    required final bool isFinal,
    required final bool isWon,
    required final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$PipelineStageDtoImpl;

  factory _PipelineStageDto.fromJson(Map<String, dynamic> json) =
      _$PipelineStageDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  int get probability;
  @override
  int get sequence;
  @override
  String? get color;
  @override
  bool get isFinal;
  @override
  bool get isWon;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PipelineStageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStageDtoImplCopyWith<_$PipelineStageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineStatusDto _$PipelineStatusDtoFromJson(Map<String, dynamic> json) {
  return _PipelineStatusDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineStatusDto {
  String get id => throw _privateConstructorUsedError;
  String get stageId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PipelineStatusDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStatusDtoCopyWith<PipelineStatusDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStatusDtoCopyWith<$Res> {
  factory $PipelineStatusDtoCopyWith(
    PipelineStatusDto value,
    $Res Function(PipelineStatusDto) then,
  ) = _$PipelineStatusDtoCopyWithImpl<$Res, PipelineStatusDto>;
  @useResult
  $Res call({
    String id,
    String stageId,
    String code,
    String name,
    String? description,
    int sequence,
    bool isDefault,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PipelineStatusDtoCopyWithImpl<$Res, $Val extends PipelineStatusDto>
    implements $PipelineStatusDtoCopyWith<$Res> {
  _$PipelineStatusDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stageId = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sequence = null,
    Object? isDefault = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            stageId: null == stageId
                ? _value.stageId
                : stageId // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineStatusDtoImplCopyWith<$Res>
    implements $PipelineStatusDtoCopyWith<$Res> {
  factory _$$PipelineStatusDtoImplCopyWith(
    _$PipelineStatusDtoImpl value,
    $Res Function(_$PipelineStatusDtoImpl) then,
  ) = __$$PipelineStatusDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stageId,
    String code,
    String name,
    String? description,
    int sequence,
    bool isDefault,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PipelineStatusDtoImplCopyWithImpl<$Res>
    extends _$PipelineStatusDtoCopyWithImpl<$Res, _$PipelineStatusDtoImpl>
    implements _$$PipelineStatusDtoImplCopyWith<$Res> {
  __$$PipelineStatusDtoImplCopyWithImpl(
    _$PipelineStatusDtoImpl _value,
    $Res Function(_$PipelineStatusDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stageId = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sequence = null,
    Object? isDefault = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PipelineStatusDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        stageId: null == stageId
            ? _value.stageId
            : stageId // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineStatusDtoImpl implements _PipelineStatusDto {
  const _$PipelineStatusDtoImpl({
    required this.id,
    required this.stageId,
    required this.code,
    required this.name,
    this.description,
    required this.sequence,
    required this.isDefault,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory _$PipelineStatusDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStatusDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String stageId;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int sequence;
  @override
  final bool isDefault;
  @override
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PipelineStatusDto(id: $id, stageId: $stageId, code: $code, name: $name, description: $description, sequence: $sequence, isDefault: $isDefault, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStatusDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stageId,
    code,
    name,
    description,
    sequence,
    isDefault,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of PipelineStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStatusDtoImplCopyWith<_$PipelineStatusDtoImpl> get copyWith =>
      __$$PipelineStatusDtoImplCopyWithImpl<_$PipelineStatusDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStatusDtoImplToJson(this);
  }
}

abstract class _PipelineStatusDto implements PipelineStatusDto {
  const factory _PipelineStatusDto({
    required final String id,
    required final String stageId,
    required final String code,
    required final String name,
    final String? description,
    required final int sequence,
    required final bool isDefault,
    required final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$PipelineStatusDtoImpl;

  factory _PipelineStatusDto.fromJson(Map<String, dynamic> json) =
      _$PipelineStatusDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get stageId;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get sequence;
  @override
  bool get isDefault;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PipelineStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStatusDtoImplCopyWith<_$PipelineStatusDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityTypeDto _$ActivityTypeDtoFromJson(Map<String, dynamic> json) {
  return _ActivityTypeDto.fromJson(json);
}

/// @nodoc
mixin _$ActivityTypeDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  bool get requireLocation => throw _privateConstructorUsedError;
  bool get requirePhoto => throw _privateConstructorUsedError;
  bool get requireNotes => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ActivityTypeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityTypeDtoCopyWith<ActivityTypeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityTypeDtoCopyWith<$Res> {
  factory $ActivityTypeDtoCopyWith(
    ActivityTypeDto value,
    $Res Function(ActivityTypeDto) then,
  ) = _$ActivityTypeDtoCopyWithImpl<$Res, ActivityTypeDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? icon,
    String? color,
    bool requireLocation,
    bool requirePhoto,
    bool requireNotes,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$ActivityTypeDtoCopyWithImpl<$Res, $Val extends ActivityTypeDto>
    implements $ActivityTypeDtoCopyWith<$Res> {
  _$ActivityTypeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? icon = freezed,
    Object? color = freezed,
    Object? requireLocation = null,
    Object? requirePhoto = null,
    Object? requireNotes = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            requireLocation: null == requireLocation
                ? _value.requireLocation
                : requireLocation // ignore: cast_nullable_to_non_nullable
                      as bool,
            requirePhoto: null == requirePhoto
                ? _value.requirePhoto
                : requirePhoto // ignore: cast_nullable_to_non_nullable
                      as bool,
            requireNotes: null == requireNotes
                ? _value.requireNotes
                : requireNotes // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityTypeDtoImplCopyWith<$Res>
    implements $ActivityTypeDtoCopyWith<$Res> {
  factory _$$ActivityTypeDtoImplCopyWith(
    _$ActivityTypeDtoImpl value,
    $Res Function(_$ActivityTypeDtoImpl) then,
  ) = __$$ActivityTypeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? icon,
    String? color,
    bool requireLocation,
    bool requirePhoto,
    bool requireNotes,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$ActivityTypeDtoImplCopyWithImpl<$Res>
    extends _$ActivityTypeDtoCopyWithImpl<$Res, _$ActivityTypeDtoImpl>
    implements _$$ActivityTypeDtoImplCopyWith<$Res> {
  __$$ActivityTypeDtoImplCopyWithImpl(
    _$ActivityTypeDtoImpl _value,
    $Res Function(_$ActivityTypeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? icon = freezed,
    Object? color = freezed,
    Object? requireLocation = null,
    Object? requirePhoto = null,
    Object? requireNotes = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$ActivityTypeDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        requireLocation: null == requireLocation
            ? _value.requireLocation
            : requireLocation // ignore: cast_nullable_to_non_nullable
                  as bool,
        requirePhoto: null == requirePhoto
            ? _value.requirePhoto
            : requirePhoto // ignore: cast_nullable_to_non_nullable
                  as bool,
        requireNotes: null == requireNotes
            ? _value.requireNotes
            : requireNotes // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityTypeDtoImpl implements _ActivityTypeDto {
  const _$ActivityTypeDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    this.icon,
    this.color,
    required this.requireLocation,
    required this.requirePhoto,
    required this.requireNotes,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$ActivityTypeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityTypeDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? icon;
  @override
  final String? color;
  @override
  final bool requireLocation;
  @override
  final bool requirePhoto;
  @override
  final bool requireNotes;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'ActivityTypeDto(id: $id, code: $code, name: $name, icon: $icon, color: $color, requireLocation: $requireLocation, requirePhoto: $requirePhoto, requireNotes: $requireNotes, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityTypeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.requireLocation, requireLocation) ||
                other.requireLocation == requireLocation) &&
            (identical(other.requirePhoto, requirePhoto) ||
                other.requirePhoto == requirePhoto) &&
            (identical(other.requireNotes, requireNotes) ||
                other.requireNotes == requireNotes) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    icon,
    color,
    requireLocation,
    requirePhoto,
    requireNotes,
    sortOrder,
    isActive,
  );

  /// Create a copy of ActivityTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityTypeDtoImplCopyWith<_$ActivityTypeDtoImpl> get copyWith =>
      __$$ActivityTypeDtoImplCopyWithImpl<_$ActivityTypeDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityTypeDtoImplToJson(this);
  }
}

abstract class _ActivityTypeDto implements ActivityTypeDto {
  const factory _ActivityTypeDto({
    required final String id,
    required final String code,
    required final String name,
    final String? icon,
    final String? color,
    required final bool requireLocation,
    required final bool requirePhoto,
    required final bool requireNotes,
    required final int sortOrder,
    required final bool isActive,
  }) = _$ActivityTypeDtoImpl;

  factory _ActivityTypeDto.fromJson(Map<String, dynamic> json) =
      _$ActivityTypeDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get icon;
  @override
  String? get color;
  @override
  bool get requireLocation;
  @override
  bool get requirePhoto;
  @override
  bool get requireNotes;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of ActivityTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityTypeDtoImplCopyWith<_$ActivityTypeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeadSourceDto _$LeadSourceDtoFromJson(Map<String, dynamic> json) {
  return _LeadSourceDto.fromJson(json);
}

/// @nodoc
mixin _$LeadSourceDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get requiresReferrer => throw _privateConstructorUsedError;
  bool get requiresBroker => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this LeadSourceDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadSourceDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadSourceDtoCopyWith<LeadSourceDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadSourceDtoCopyWith<$Res> {
  factory $LeadSourceDtoCopyWith(
    LeadSourceDto value,
    $Res Function(LeadSourceDto) then,
  ) = _$LeadSourceDtoCopyWithImpl<$Res, LeadSourceDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    bool requiresReferrer,
    bool requiresBroker,
    bool isActive,
  });
}

/// @nodoc
class _$LeadSourceDtoCopyWithImpl<$Res, $Val extends LeadSourceDto>
    implements $LeadSourceDtoCopyWith<$Res> {
  _$LeadSourceDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadSourceDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? requiresReferrer = null,
    Object? requiresBroker = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            requiresReferrer: null == requiresReferrer
                ? _value.requiresReferrer
                : requiresReferrer // ignore: cast_nullable_to_non_nullable
                      as bool,
            requiresBroker: null == requiresBroker
                ? _value.requiresBroker
                : requiresBroker // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadSourceDtoImplCopyWith<$Res>
    implements $LeadSourceDtoCopyWith<$Res> {
  factory _$$LeadSourceDtoImplCopyWith(
    _$LeadSourceDtoImpl value,
    $Res Function(_$LeadSourceDtoImpl) then,
  ) = __$$LeadSourceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    bool requiresReferrer,
    bool requiresBroker,
    bool isActive,
  });
}

/// @nodoc
class __$$LeadSourceDtoImplCopyWithImpl<$Res>
    extends _$LeadSourceDtoCopyWithImpl<$Res, _$LeadSourceDtoImpl>
    implements _$$LeadSourceDtoImplCopyWith<$Res> {
  __$$LeadSourceDtoImplCopyWithImpl(
    _$LeadSourceDtoImpl _value,
    $Res Function(_$LeadSourceDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadSourceDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? requiresReferrer = null,
    Object? requiresBroker = null,
    Object? isActive = null,
  }) {
    return _then(
      _$LeadSourceDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        requiresReferrer: null == requiresReferrer
            ? _value.requiresReferrer
            : requiresReferrer // ignore: cast_nullable_to_non_nullable
                  as bool,
        requiresBroker: null == requiresBroker
            ? _value.requiresBroker
            : requiresBroker // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadSourceDtoImpl implements _LeadSourceDto {
  const _$LeadSourceDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.requiresReferrer,
    required this.requiresBroker,
    required this.isActive,
  });

  factory _$LeadSourceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadSourceDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final bool requiresReferrer;
  @override
  final bool requiresBroker;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'LeadSourceDto(id: $id, code: $code, name: $name, requiresReferrer: $requiresReferrer, requiresBroker: $requiresBroker, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadSourceDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.requiresReferrer, requiresReferrer) ||
                other.requiresReferrer == requiresReferrer) &&
            (identical(other.requiresBroker, requiresBroker) ||
                other.requiresBroker == requiresBroker) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    requiresReferrer,
    requiresBroker,
    isActive,
  );

  /// Create a copy of LeadSourceDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadSourceDtoImplCopyWith<_$LeadSourceDtoImpl> get copyWith =>
      __$$LeadSourceDtoImplCopyWithImpl<_$LeadSourceDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadSourceDtoImplToJson(this);
  }
}

abstract class _LeadSourceDto implements LeadSourceDto {
  const factory _LeadSourceDto({
    required final String id,
    required final String code,
    required final String name,
    required final bool requiresReferrer,
    required final bool requiresBroker,
    required final bool isActive,
  }) = _$LeadSourceDtoImpl;

  factory _LeadSourceDto.fromJson(Map<String, dynamic> json) =
      _$LeadSourceDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  bool get requiresReferrer;
  @override
  bool get requiresBroker;
  @override
  bool get isActive;

  /// Create a copy of LeadSourceDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadSourceDtoImplCopyWith<_$LeadSourceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeclineReasonDto _$DeclineReasonDtoFromJson(Map<String, dynamic> json) {
  return _DeclineReasonDto.fromJson(json);
}

/// @nodoc
mixin _$DeclineReasonDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this DeclineReasonDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeclineReasonDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeclineReasonDtoCopyWith<DeclineReasonDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeclineReasonDtoCopyWith<$Res> {
  factory $DeclineReasonDtoCopyWith(
    DeclineReasonDto value,
    $Res Function(DeclineReasonDto) then,
  ) = _$DeclineReasonDtoCopyWithImpl<$Res, DeclineReasonDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$DeclineReasonDtoCopyWithImpl<$Res, $Val extends DeclineReasonDto>
    implements $DeclineReasonDtoCopyWith<$Res> {
  _$DeclineReasonDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeclineReasonDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeclineReasonDtoImplCopyWith<$Res>
    implements $DeclineReasonDtoCopyWith<$Res> {
  factory _$$DeclineReasonDtoImplCopyWith(
    _$DeclineReasonDtoImpl value,
    $Res Function(_$DeclineReasonDtoImpl) then,
  ) = __$$DeclineReasonDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$DeclineReasonDtoImplCopyWithImpl<$Res>
    extends _$DeclineReasonDtoCopyWithImpl<$Res, _$DeclineReasonDtoImpl>
    implements _$$DeclineReasonDtoImplCopyWith<$Res> {
  __$$DeclineReasonDtoImplCopyWithImpl(
    _$DeclineReasonDtoImpl _value,
    $Res Function(_$DeclineReasonDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeclineReasonDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$DeclineReasonDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeclineReasonDtoImpl implements _DeclineReasonDto {
  const _$DeclineReasonDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$DeclineReasonDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeclineReasonDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'DeclineReasonDto(id: $id, code: $code, name: $name, description: $description, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeclineReasonDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    description,
    sortOrder,
    isActive,
  );

  /// Create a copy of DeclineReasonDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeclineReasonDtoImplCopyWith<_$DeclineReasonDtoImpl> get copyWith =>
      __$$DeclineReasonDtoImplCopyWithImpl<_$DeclineReasonDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DeclineReasonDtoImplToJson(this);
  }
}

abstract class _DeclineReasonDto implements DeclineReasonDto {
  const factory _DeclineReasonDto({
    required final String id,
    required final String code,
    required final String name,
    final String? description,
    required final int sortOrder,
    required final bool isActive,
  }) = _$DeclineReasonDtoImpl;

  factory _DeclineReasonDto.fromJson(Map<String, dynamic> json) =
      _$DeclineReasonDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of DeclineReasonDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeclineReasonDtoImplCopyWith<_$DeclineReasonDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HvcTypeDto _$HvcTypeDtoFromJson(Map<String, dynamic> json) {
  return _HvcTypeDto.fromJson(json);
}

/// @nodoc
mixin _$HvcTypeDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this HvcTypeDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HvcTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvcTypeDtoCopyWith<HvcTypeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvcTypeDtoCopyWith<$Res> {
  factory $HvcTypeDtoCopyWith(
    HvcTypeDto value,
    $Res Function(HvcTypeDto) then,
  ) = _$HvcTypeDtoCopyWithImpl<$Res, HvcTypeDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class _$HvcTypeDtoCopyWithImpl<$Res, $Val extends HvcTypeDto>
    implements $HvcTypeDtoCopyWith<$Res> {
  _$HvcTypeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HvcTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HvcTypeDtoImplCopyWith<$Res>
    implements $HvcTypeDtoCopyWith<$Res> {
  factory _$$HvcTypeDtoImplCopyWith(
    _$HvcTypeDtoImpl value,
    $Res Function(_$HvcTypeDtoImpl) then,
  ) = __$$HvcTypeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    int sortOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$HvcTypeDtoImplCopyWithImpl<$Res>
    extends _$HvcTypeDtoCopyWithImpl<$Res, _$HvcTypeDtoImpl>
    implements _$$HvcTypeDtoImplCopyWith<$Res> {
  __$$HvcTypeDtoImplCopyWithImpl(
    _$HvcTypeDtoImpl _value,
    $Res Function(_$HvcTypeDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HvcTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$HvcTypeDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HvcTypeDtoImpl implements _HvcTypeDto {
  const _$HvcTypeDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory _$HvcTypeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvcTypeDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'HvcTypeDto(id: $id, code: $code, name: $name, description: $description, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvcTypeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    description,
    sortOrder,
    isActive,
  );

  /// Create a copy of HvcTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvcTypeDtoImplCopyWith<_$HvcTypeDtoImpl> get copyWith =>
      __$$HvcTypeDtoImplCopyWithImpl<_$HvcTypeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HvcTypeDtoImplToJson(this);
  }
}

abstract class _HvcTypeDto implements HvcTypeDto {
  const factory _HvcTypeDto({
    required final String id,
    required final String code,
    required final String name,
    final String? description,
    required final int sortOrder,
    required final bool isActive,
  }) = _$HvcTypeDtoImpl;

  factory _HvcTypeDto.fromJson(Map<String, dynamic> json) =
      _$HvcTypeDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of HvcTypeDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvcTypeDtoImplCopyWith<_$HvcTypeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProvinceCreateDto _$ProvinceCreateDtoFromJson(Map<String, dynamic> json) {
  return _ProvinceCreateDto.fromJson(json);
}

/// @nodoc
mixin _$ProvinceCreateDto {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ProvinceCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProvinceCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProvinceCreateDtoCopyWith<ProvinceCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProvinceCreateDtoCopyWith<$Res> {
  factory $ProvinceCreateDtoCopyWith(
    ProvinceCreateDto value,
    $Res Function(ProvinceCreateDto) then,
  ) = _$ProvinceCreateDtoCopyWithImpl<$Res, ProvinceCreateDto>;
  @useResult
  $Res call({String code, String name, bool isActive});
}

/// @nodoc
class _$ProvinceCreateDtoCopyWithImpl<$Res, $Val extends ProvinceCreateDto>
    implements $ProvinceCreateDtoCopyWith<$Res> {
  _$ProvinceCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProvinceCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProvinceCreateDtoImplCopyWith<$Res>
    implements $ProvinceCreateDtoCopyWith<$Res> {
  factory _$$ProvinceCreateDtoImplCopyWith(
    _$ProvinceCreateDtoImpl value,
    $Res Function(_$ProvinceCreateDtoImpl) then,
  ) = __$$ProvinceCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, bool isActive});
}

/// @nodoc
class __$$ProvinceCreateDtoImplCopyWithImpl<$Res>
    extends _$ProvinceCreateDtoCopyWithImpl<$Res, _$ProvinceCreateDtoImpl>
    implements _$$ProvinceCreateDtoImplCopyWith<$Res> {
  __$$ProvinceCreateDtoImplCopyWithImpl(
    _$ProvinceCreateDtoImpl _value,
    $Res Function(_$ProvinceCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProvinceCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? isActive = null,
  }) {
    return _then(
      _$ProvinceCreateDtoImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProvinceCreateDtoImpl implements _ProvinceCreateDto {
  const _$ProvinceCreateDtoImpl({
    required this.code,
    required this.name,
    this.isActive = true,
  });

  factory _$ProvinceCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProvinceCreateDtoImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'ProvinceCreateDto(code: $code, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProvinceCreateDtoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, isActive);

  /// Create a copy of ProvinceCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProvinceCreateDtoImplCopyWith<_$ProvinceCreateDtoImpl> get copyWith =>
      __$$ProvinceCreateDtoImplCopyWithImpl<_$ProvinceCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProvinceCreateDtoImplToJson(this);
  }
}

abstract class _ProvinceCreateDto implements ProvinceCreateDto {
  const factory _ProvinceCreateDto({
    required final String code,
    required final String name,
    final bool isActive,
  }) = _$ProvinceCreateDtoImpl;

  factory _ProvinceCreateDto.fromJson(Map<String, dynamic> json) =
      _$ProvinceCreateDtoImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  bool get isActive;

  /// Create a copy of ProvinceCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProvinceCreateDtoImplCopyWith<_$ProvinceCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CityCreateDto _$CityCreateDtoFromJson(Map<String, dynamic> json) {
  return _CityCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CityCreateDto {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get provinceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CityCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CityCreateDtoCopyWith<CityCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityCreateDtoCopyWith<$Res> {
  factory $CityCreateDtoCopyWith(
    CityCreateDto value,
    $Res Function(CityCreateDto) then,
  ) = _$CityCreateDtoCopyWithImpl<$Res, CityCreateDto>;
  @useResult
  $Res call({String code, String name, String provinceId, bool isActive});
}

/// @nodoc
class _$CityCreateDtoCopyWithImpl<$Res, $Val extends CityCreateDto>
    implements $CityCreateDtoCopyWith<$Res> {
  _$CityCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? provinceId = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            provinceId: null == provinceId
                ? _value.provinceId
                : provinceId // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CityCreateDtoImplCopyWith<$Res>
    implements $CityCreateDtoCopyWith<$Res> {
  factory _$$CityCreateDtoImplCopyWith(
    _$CityCreateDtoImpl value,
    $Res Function(_$CityCreateDtoImpl) then,
  ) = __$$CityCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, String provinceId, bool isActive});
}

/// @nodoc
class __$$CityCreateDtoImplCopyWithImpl<$Res>
    extends _$CityCreateDtoCopyWithImpl<$Res, _$CityCreateDtoImpl>
    implements _$$CityCreateDtoImplCopyWith<$Res> {
  __$$CityCreateDtoImplCopyWithImpl(
    _$CityCreateDtoImpl _value,
    $Res Function(_$CityCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? provinceId = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CityCreateDtoImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        provinceId: null == provinceId
            ? _value.provinceId
            : provinceId // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CityCreateDtoImpl implements _CityCreateDto {
  const _$CityCreateDtoImpl({
    required this.code,
    required this.name,
    required this.provinceId,
    this.isActive = true,
  });

  factory _$CityCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityCreateDtoImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final String provinceId;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'CityCreateDto(code: $code, name: $name, provinceId: $provinceId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityCreateDtoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, code, name, provinceId, isActive);

  /// Create a copy of CityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CityCreateDtoImplCopyWith<_$CityCreateDtoImpl> get copyWith =>
      __$$CityCreateDtoImplCopyWithImpl<_$CityCreateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityCreateDtoImplToJson(this);
  }
}

abstract class _CityCreateDto implements CityCreateDto {
  const factory _CityCreateDto({
    required final String code,
    required final String name,
    required final String provinceId,
    final bool isActive,
  }) = _$CityCreateDtoImpl;

  factory _CityCreateDto.fromJson(Map<String, dynamic> json) =
      _$CityCreateDtoImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  String get provinceId;
  @override
  bool get isActive;

  /// Create a copy of CityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CityCreateDtoImplCopyWith<_$CityCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompanyTypeCreateDto _$CompanyTypeCreateDtoFromJson(Map<String, dynamic> json) {
  return _CompanyTypeCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CompanyTypeCreateDto {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CompanyTypeCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanyTypeCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyTypeCreateDtoCopyWith<CompanyTypeCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyTypeCreateDtoCopyWith<$Res> {
  factory $CompanyTypeCreateDtoCopyWith(
    CompanyTypeCreateDto value,
    $Res Function(CompanyTypeCreateDto) then,
  ) = _$CompanyTypeCreateDtoCopyWithImpl<$Res, CompanyTypeCreateDto>;
  @useResult
  $Res call({String code, String name, int sortOrder, bool isActive});
}

/// @nodoc
class _$CompanyTypeCreateDtoCopyWithImpl<
  $Res,
  $Val extends CompanyTypeCreateDto
>
    implements $CompanyTypeCreateDtoCopyWith<$Res> {
  _$CompanyTypeCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyTypeCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanyTypeCreateDtoImplCopyWith<$Res>
    implements $CompanyTypeCreateDtoCopyWith<$Res> {
  factory _$$CompanyTypeCreateDtoImplCopyWith(
    _$CompanyTypeCreateDtoImpl value,
    $Res Function(_$CompanyTypeCreateDtoImpl) then,
  ) = __$$CompanyTypeCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, int sortOrder, bool isActive});
}

/// @nodoc
class __$$CompanyTypeCreateDtoImplCopyWithImpl<$Res>
    extends _$CompanyTypeCreateDtoCopyWithImpl<$Res, _$CompanyTypeCreateDtoImpl>
    implements _$$CompanyTypeCreateDtoImplCopyWith<$Res> {
  __$$CompanyTypeCreateDtoImplCopyWithImpl(
    _$CompanyTypeCreateDtoImpl _value,
    $Res Function(_$CompanyTypeCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanyTypeCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CompanyTypeCreateDtoImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyTypeCreateDtoImpl implements _CompanyTypeCreateDto {
  const _$CompanyTypeCreateDtoImpl({
    required this.code,
    required this.name,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory _$CompanyTypeCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyTypeCreateDtoImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'CompanyTypeCreateDto(code: $code, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyTypeCreateDtoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, sortOrder, isActive);

  /// Create a copy of CompanyTypeCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyTypeCreateDtoImplCopyWith<_$CompanyTypeCreateDtoImpl>
  get copyWith =>
      __$$CompanyTypeCreateDtoImplCopyWithImpl<_$CompanyTypeCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyTypeCreateDtoImplToJson(this);
  }
}

abstract class _CompanyTypeCreateDto implements CompanyTypeCreateDto {
  const factory _CompanyTypeCreateDto({
    required final String code,
    required final String name,
    final int sortOrder,
    final bool isActive,
  }) = _$CompanyTypeCreateDtoImpl;

  factory _CompanyTypeCreateDto.fromJson(Map<String, dynamic> json) =
      _$CompanyTypeCreateDtoImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of CompanyTypeCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyTypeCreateDtoImplCopyWith<_$CompanyTypeCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

IndustryCreateDto _$IndustryCreateDtoFromJson(Map<String, dynamic> json) {
  return _IndustryCreateDto.fromJson(json);
}

/// @nodoc
mixin _$IndustryCreateDto {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this IndustryCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IndustryCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IndustryCreateDtoCopyWith<IndustryCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndustryCreateDtoCopyWith<$Res> {
  factory $IndustryCreateDtoCopyWith(
    IndustryCreateDto value,
    $Res Function(IndustryCreateDto) then,
  ) = _$IndustryCreateDtoCopyWithImpl<$Res, IndustryCreateDto>;
  @useResult
  $Res call({String code, String name, int sortOrder, bool isActive});
}

/// @nodoc
class _$IndustryCreateDtoCopyWithImpl<$Res, $Val extends IndustryCreateDto>
    implements $IndustryCreateDtoCopyWith<$Res> {
  _$IndustryCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IndustryCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IndustryCreateDtoImplCopyWith<$Res>
    implements $IndustryCreateDtoCopyWith<$Res> {
  factory _$$IndustryCreateDtoImplCopyWith(
    _$IndustryCreateDtoImpl value,
    $Res Function(_$IndustryCreateDtoImpl) then,
  ) = __$$IndustryCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, int sortOrder, bool isActive});
}

/// @nodoc
class __$$IndustryCreateDtoImplCopyWithImpl<$Res>
    extends _$IndustryCreateDtoCopyWithImpl<$Res, _$IndustryCreateDtoImpl>
    implements _$$IndustryCreateDtoImplCopyWith<$Res> {
  __$$IndustryCreateDtoImplCopyWithImpl(
    _$IndustryCreateDtoImpl _value,
    $Res Function(_$IndustryCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IndustryCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$IndustryCreateDtoImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IndustryCreateDtoImpl implements _IndustryCreateDto {
  const _$IndustryCreateDtoImpl({
    required this.code,
    required this.name,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory _$IndustryCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$IndustryCreateDtoImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'IndustryCreateDto(code: $code, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndustryCreateDtoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, sortOrder, isActive);

  /// Create a copy of IndustryCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndustryCreateDtoImplCopyWith<_$IndustryCreateDtoImpl> get copyWith =>
      __$$IndustryCreateDtoImplCopyWithImpl<_$IndustryCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IndustryCreateDtoImplToJson(this);
  }
}

abstract class _IndustryCreateDto implements IndustryCreateDto {
  const factory _IndustryCreateDto({
    required final String code,
    required final String name,
    final int sortOrder,
    final bool isActive,
  }) = _$IndustryCreateDtoImpl;

  factory _IndustryCreateDto.fromJson(Map<String, dynamic> json) =
      _$IndustryCreateDtoImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of IndustryCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndustryCreateDtoImplCopyWith<_$IndustryCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineStageCreateDto _$PipelineStageCreateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineStageCreateDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineStageCreateDto {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get probability => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  bool get isFinal => throw _privateConstructorUsedError;
  bool get isWon => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this PipelineStageCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStageCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStageCreateDtoCopyWith<PipelineStageCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStageCreateDtoCopyWith<$Res> {
  factory $PipelineStageCreateDtoCopyWith(
    PipelineStageCreateDto value,
    $Res Function(PipelineStageCreateDto) then,
  ) = _$PipelineStageCreateDtoCopyWithImpl<$Res, PipelineStageCreateDto>;
  @useResult
  $Res call({
    String code,
    String name,
    int probability,
    int sequence,
    String? color,
    bool isFinal,
    bool isWon,
    bool isActive,
  });
}

/// @nodoc
class _$PipelineStageCreateDtoCopyWithImpl<
  $Res,
  $Val extends PipelineStageCreateDto
>
    implements $PipelineStageCreateDtoCopyWith<$Res> {
  _$PipelineStageCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStageCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? probability = null,
    Object? sequence = null,
    Object? color = freezed,
    Object? isFinal = null,
    Object? isWon = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            probability: null == probability
                ? _value.probability
                : probability // ignore: cast_nullable_to_non_nullable
                      as int,
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFinal: null == isFinal
                ? _value.isFinal
                : isFinal // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWon: null == isWon
                ? _value.isWon
                : isWon // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineStageCreateDtoImplCopyWith<$Res>
    implements $PipelineStageCreateDtoCopyWith<$Res> {
  factory _$$PipelineStageCreateDtoImplCopyWith(
    _$PipelineStageCreateDtoImpl value,
    $Res Function(_$PipelineStageCreateDtoImpl) then,
  ) = __$$PipelineStageCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String name,
    int probability,
    int sequence,
    String? color,
    bool isFinal,
    bool isWon,
    bool isActive,
  });
}

/// @nodoc
class __$$PipelineStageCreateDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineStageCreateDtoCopyWithImpl<$Res, _$PipelineStageCreateDtoImpl>
    implements _$$PipelineStageCreateDtoImplCopyWith<$Res> {
  __$$PipelineStageCreateDtoImplCopyWithImpl(
    _$PipelineStageCreateDtoImpl _value,
    $Res Function(_$PipelineStageCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStageCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? probability = null,
    Object? sequence = null,
    Object? color = freezed,
    Object? isFinal = null,
    Object? isWon = null,
    Object? isActive = null,
  }) {
    return _then(
      _$PipelineStageCreateDtoImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        probability: null == probability
            ? _value.probability
            : probability // ignore: cast_nullable_to_non_nullable
                  as int,
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFinal: null == isFinal
            ? _value.isFinal
            : isFinal // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWon: null == isWon
            ? _value.isWon
            : isWon // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineStageCreateDtoImpl implements _PipelineStageCreateDto {
  const _$PipelineStageCreateDtoImpl({
    required this.code,
    required this.name,
    required this.probability,
    required this.sequence,
    this.color,
    this.isFinal = false,
    this.isWon = false,
    this.isActive = true,
  });

  factory _$PipelineStageCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStageCreateDtoImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final int probability;
  @override
  final int sequence;
  @override
  final String? color;
  @override
  @JsonKey()
  final bool isFinal;
  @override
  @JsonKey()
  final bool isWon;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'PipelineStageCreateDto(code: $code, name: $name, probability: $probability, sequence: $sequence, color: $color, isFinal: $isFinal, isWon: $isWon, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStageCreateDtoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isFinal, isFinal) || other.isFinal == isFinal) &&
            (identical(other.isWon, isWon) || other.isWon == isWon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    name,
    probability,
    sequence,
    color,
    isFinal,
    isWon,
    isActive,
  );

  /// Create a copy of PipelineStageCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStageCreateDtoImplCopyWith<_$PipelineStageCreateDtoImpl>
  get copyWith =>
      __$$PipelineStageCreateDtoImplCopyWithImpl<_$PipelineStageCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStageCreateDtoImplToJson(this);
  }
}

abstract class _PipelineStageCreateDto implements PipelineStageCreateDto {
  const factory _PipelineStageCreateDto({
    required final String code,
    required final String name,
    required final int probability,
    required final int sequence,
    final String? color,
    final bool isFinal,
    final bool isWon,
    final bool isActive,
  }) = _$PipelineStageCreateDtoImpl;

  factory _PipelineStageCreateDto.fromJson(Map<String, dynamic> json) =
      _$PipelineStageCreateDtoImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  int get probability;
  @override
  int get sequence;
  @override
  String? get color;
  @override
  bool get isFinal;
  @override
  bool get isWon;
  @override
  bool get isActive;

  /// Create a copy of PipelineStageCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStageCreateDtoImplCopyWith<_$PipelineStageCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
