// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hvc_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HvcCreateDto _$HvcCreateDtoFromJson(Map<String, dynamic> json) {
  return _HvcCreateDto.fromJson(json);
}

/// @nodoc
mixin _$HvcCreateDto {
  String get name => throw _privateConstructorUsedError;
  String get typeId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int? get radiusMeters => throw _privateConstructorUsedError;
  double? get potentialValue => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this HvcCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HvcCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvcCreateDtoCopyWith<HvcCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvcCreateDtoCopyWith<$Res> {
  factory $HvcCreateDtoCopyWith(
    HvcCreateDto value,
    $Res Function(HvcCreateDto) then,
  ) = _$HvcCreateDtoCopyWithImpl<$Res, HvcCreateDto>;
  @useResult
  $Res call({
    String name,
    String typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
  });
}

/// @nodoc
class _$HvcCreateDtoCopyWithImpl<$Res, $Val extends HvcCreateDto>
    implements $HvcCreateDtoCopyWith<$Res> {
  _$HvcCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HvcCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? typeId = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radiusMeters = freezed,
    Object? potentialValue = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            typeId: null == typeId
                ? _value.typeId
                : typeId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            radiusMeters: freezed == radiusMeters
                ? _value.radiusMeters
                : radiusMeters // ignore: cast_nullable_to_non_nullable
                      as int?,
            potentialValue: freezed == potentialValue
                ? _value.potentialValue
                : potentialValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HvcCreateDtoImplCopyWith<$Res>
    implements $HvcCreateDtoCopyWith<$Res> {
  factory _$$HvcCreateDtoImplCopyWith(
    _$HvcCreateDtoImpl value,
    $Res Function(_$HvcCreateDtoImpl) then,
  ) = __$$HvcCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
  });
}

/// @nodoc
class __$$HvcCreateDtoImplCopyWithImpl<$Res>
    extends _$HvcCreateDtoCopyWithImpl<$Res, _$HvcCreateDtoImpl>
    implements _$$HvcCreateDtoImplCopyWith<$Res> {
  __$$HvcCreateDtoImplCopyWithImpl(
    _$HvcCreateDtoImpl _value,
    $Res Function(_$HvcCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HvcCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? typeId = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radiusMeters = freezed,
    Object? potentialValue = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$HvcCreateDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        typeId: null == typeId
            ? _value.typeId
            : typeId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        radiusMeters: freezed == radiusMeters
            ? _value.radiusMeters
            : radiusMeters // ignore: cast_nullable_to_non_nullable
                  as int?,
        potentialValue: freezed == potentialValue
            ? _value.potentialValue
            : potentialValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HvcCreateDtoImpl implements _HvcCreateDto {
  const _$HvcCreateDtoImpl({
    required this.name,
    required this.typeId,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.potentialValue,
    this.imageUrl,
  });

  factory _$HvcCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvcCreateDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String typeId;
  @override
  final String? description;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final int? radiusMeters;
  @override
  final double? potentialValue;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'HvcCreateDto(name: $name, typeId: $typeId, description: $description, address: $address, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, potentialValue: $potentialValue, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvcCreateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.typeId, typeId) || other.typeId == typeId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters) &&
            (identical(other.potentialValue, potentialValue) ||
                other.potentialValue == potentialValue) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    typeId,
    description,
    address,
    latitude,
    longitude,
    radiusMeters,
    potentialValue,
    imageUrl,
  );

  /// Create a copy of HvcCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvcCreateDtoImplCopyWith<_$HvcCreateDtoImpl> get copyWith =>
      __$$HvcCreateDtoImplCopyWithImpl<_$HvcCreateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HvcCreateDtoImplToJson(this);
  }
}

abstract class _HvcCreateDto implements HvcCreateDto {
  const factory _HvcCreateDto({
    required final String name,
    required final String typeId,
    final String? description,
    final String? address,
    final double? latitude,
    final double? longitude,
    final int? radiusMeters,
    final double? potentialValue,
    final String? imageUrl,
  }) = _$HvcCreateDtoImpl;

  factory _HvcCreateDto.fromJson(Map<String, dynamic> json) =
      _$HvcCreateDtoImpl.fromJson;

  @override
  String get name;
  @override
  String get typeId;
  @override
  String? get description;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int? get radiusMeters;
  @override
  double? get potentialValue;
  @override
  String? get imageUrl;

  /// Create a copy of HvcCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvcCreateDtoImplCopyWith<_$HvcCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HvcUpdateDto _$HvcUpdateDtoFromJson(Map<String, dynamic> json) {
  return _HvcUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$HvcUpdateDto {
  String? get name => throw _privateConstructorUsedError;
  String? get typeId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int? get radiusMeters => throw _privateConstructorUsedError;
  double? get potentialValue => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this HvcUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HvcUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvcUpdateDtoCopyWith<HvcUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvcUpdateDtoCopyWith<$Res> {
  factory $HvcUpdateDtoCopyWith(
    HvcUpdateDto value,
    $Res Function(HvcUpdateDto) then,
  ) = _$HvcUpdateDtoCopyWithImpl<$Res, HvcUpdateDto>;
  @useResult
  $Res call({
    String? name,
    String? typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
    bool? isActive,
  });
}

/// @nodoc
class _$HvcUpdateDtoCopyWithImpl<$Res, $Val extends HvcUpdateDto>
    implements $HvcUpdateDtoCopyWith<$Res> {
  _$HvcUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HvcUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? typeId = freezed,
    Object? description = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radiusMeters = freezed,
    Object? potentialValue = freezed,
    Object? imageUrl = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeId: freezed == typeId
                ? _value.typeId
                : typeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            radiusMeters: freezed == radiusMeters
                ? _value.radiusMeters
                : radiusMeters // ignore: cast_nullable_to_non_nullable
                      as int?,
            potentialValue: freezed == potentialValue
                ? _value.potentialValue
                : potentialValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HvcUpdateDtoImplCopyWith<$Res>
    implements $HvcUpdateDtoCopyWith<$Res> {
  factory _$$HvcUpdateDtoImplCopyWith(
    _$HvcUpdateDtoImpl value,
    $Res Function(_$HvcUpdateDtoImpl) then,
  ) = __$$HvcUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? typeId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    double? potentialValue,
    String? imageUrl,
    bool? isActive,
  });
}

/// @nodoc
class __$$HvcUpdateDtoImplCopyWithImpl<$Res>
    extends _$HvcUpdateDtoCopyWithImpl<$Res, _$HvcUpdateDtoImpl>
    implements _$$HvcUpdateDtoImplCopyWith<$Res> {
  __$$HvcUpdateDtoImplCopyWithImpl(
    _$HvcUpdateDtoImpl _value,
    $Res Function(_$HvcUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HvcUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? typeId = freezed,
    Object? description = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radiusMeters = freezed,
    Object? potentialValue = freezed,
    Object? imageUrl = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _$HvcUpdateDtoImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeId: freezed == typeId
            ? _value.typeId
            : typeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        radiusMeters: freezed == radiusMeters
            ? _value.radiusMeters
            : radiusMeters // ignore: cast_nullable_to_non_nullable
                  as int?,
        potentialValue: freezed == potentialValue
            ? _value.potentialValue
            : potentialValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HvcUpdateDtoImpl implements _HvcUpdateDto {
  const _$HvcUpdateDtoImpl({
    this.name,
    this.typeId,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.potentialValue,
    this.imageUrl,
    this.isActive,
  });

  factory _$HvcUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvcUpdateDtoImplFromJson(json);

  @override
  final String? name;
  @override
  final String? typeId;
  @override
  final String? description;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final int? radiusMeters;
  @override
  final double? potentialValue;
  @override
  final String? imageUrl;
  @override
  final bool? isActive;

  @override
  String toString() {
    return 'HvcUpdateDto(name: $name, typeId: $typeId, description: $description, address: $address, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, potentialValue: $potentialValue, imageUrl: $imageUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvcUpdateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.typeId, typeId) || other.typeId == typeId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters) &&
            (identical(other.potentialValue, potentialValue) ||
                other.potentialValue == potentialValue) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    typeId,
    description,
    address,
    latitude,
    longitude,
    radiusMeters,
    potentialValue,
    imageUrl,
    isActive,
  );

  /// Create a copy of HvcUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvcUpdateDtoImplCopyWith<_$HvcUpdateDtoImpl> get copyWith =>
      __$$HvcUpdateDtoImplCopyWithImpl<_$HvcUpdateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HvcUpdateDtoImplToJson(this);
  }
}

abstract class _HvcUpdateDto implements HvcUpdateDto {
  const factory _HvcUpdateDto({
    final String? name,
    final String? typeId,
    final String? description,
    final String? address,
    final double? latitude,
    final double? longitude,
    final int? radiusMeters,
    final double? potentialValue,
    final String? imageUrl,
    final bool? isActive,
  }) = _$HvcUpdateDtoImpl;

  factory _HvcUpdateDto.fromJson(Map<String, dynamic> json) =
      _$HvcUpdateDtoImpl.fromJson;

  @override
  String? get name;
  @override
  String? get typeId;
  @override
  String? get description;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int? get radiusMeters;
  @override
  double? get potentialValue;
  @override
  String? get imageUrl;
  @override
  bool? get isActive;

  /// Create a copy of HvcUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvcUpdateDtoImplCopyWith<_$HvcUpdateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerHvcLinkDto _$CustomerHvcLinkDtoFromJson(Map<String, dynamic> json) {
  return _CustomerHvcLinkDto.fromJson(json);
}

/// @nodoc
mixin _$CustomerHvcLinkDto {
  String get customerId => throw _privateConstructorUsedError;
  String get hvcId => throw _privateConstructorUsedError;
  String get relationshipType => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this CustomerHvcLinkDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerHvcLinkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerHvcLinkDtoCopyWith<CustomerHvcLinkDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerHvcLinkDtoCopyWith<$Res> {
  factory $CustomerHvcLinkDtoCopyWith(
    CustomerHvcLinkDto value,
    $Res Function(CustomerHvcLinkDto) then,
  ) = _$CustomerHvcLinkDtoCopyWithImpl<$Res, CustomerHvcLinkDto>;
  @useResult
  $Res call({
    String customerId,
    String hvcId,
    String relationshipType,
    String? notes,
  });
}

/// @nodoc
class _$CustomerHvcLinkDtoCopyWithImpl<$Res, $Val extends CustomerHvcLinkDto>
    implements $CustomerHvcLinkDtoCopyWith<$Res> {
  _$CustomerHvcLinkDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerHvcLinkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? hvcId = null,
    Object? relationshipType = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            hvcId: null == hvcId
                ? _value.hvcId
                : hvcId // ignore: cast_nullable_to_non_nullable
                      as String,
            relationshipType: null == relationshipType
                ? _value.relationshipType
                : relationshipType // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerHvcLinkDtoImplCopyWith<$Res>
    implements $CustomerHvcLinkDtoCopyWith<$Res> {
  factory _$$CustomerHvcLinkDtoImplCopyWith(
    _$CustomerHvcLinkDtoImpl value,
    $Res Function(_$CustomerHvcLinkDtoImpl) then,
  ) = __$$CustomerHvcLinkDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customerId,
    String hvcId,
    String relationshipType,
    String? notes,
  });
}

/// @nodoc
class __$$CustomerHvcLinkDtoImplCopyWithImpl<$Res>
    extends _$CustomerHvcLinkDtoCopyWithImpl<$Res, _$CustomerHvcLinkDtoImpl>
    implements _$$CustomerHvcLinkDtoImplCopyWith<$Res> {
  __$$CustomerHvcLinkDtoImplCopyWithImpl(
    _$CustomerHvcLinkDtoImpl _value,
    $Res Function(_$CustomerHvcLinkDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerHvcLinkDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? hvcId = null,
    Object? relationshipType = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$CustomerHvcLinkDtoImpl(
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        hvcId: null == hvcId
            ? _value.hvcId
            : hvcId // ignore: cast_nullable_to_non_nullable
                  as String,
        relationshipType: null == relationshipType
            ? _value.relationshipType
            : relationshipType // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerHvcLinkDtoImpl implements _CustomerHvcLinkDto {
  const _$CustomerHvcLinkDtoImpl({
    required this.customerId,
    required this.hvcId,
    required this.relationshipType,
    this.notes,
  });

  factory _$CustomerHvcLinkDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerHvcLinkDtoImplFromJson(json);

  @override
  final String customerId;
  @override
  final String hvcId;
  @override
  final String relationshipType;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CustomerHvcLinkDto(customerId: $customerId, hvcId: $hvcId, relationshipType: $relationshipType, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerHvcLinkDtoImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.relationshipType, relationshipType) ||
                other.relationshipType == relationshipType) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, customerId, hvcId, relationshipType, notes);

  /// Create a copy of CustomerHvcLinkDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerHvcLinkDtoImplCopyWith<_$CustomerHvcLinkDtoImpl> get copyWith =>
      __$$CustomerHvcLinkDtoImplCopyWithImpl<_$CustomerHvcLinkDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerHvcLinkDtoImplToJson(this);
  }
}

abstract class _CustomerHvcLinkDto implements CustomerHvcLinkDto {
  const factory _CustomerHvcLinkDto({
    required final String customerId,
    required final String hvcId,
    required final String relationshipType,
    final String? notes,
  }) = _$CustomerHvcLinkDtoImpl;

  factory _CustomerHvcLinkDto.fromJson(Map<String, dynamic> json) =
      _$CustomerHvcLinkDtoImpl.fromJson;

  @override
  String get customerId;
  @override
  String get hvcId;
  @override
  String get relationshipType;
  @override
  String? get notes;

  /// Create a copy of CustomerHvcLinkDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerHvcLinkDtoImplCopyWith<_$CustomerHvcLinkDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
