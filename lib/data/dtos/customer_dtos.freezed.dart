// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerCreateDto _$CustomerCreateDtoFromJson(Map<String, dynamic> json) {
  return _CustomerCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CustomerCreateDto {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get provinceId => throw _privateConstructorUsedError;
  String get cityId => throw _privateConstructorUsedError;
  String get companyTypeId => throw _privateConstructorUsedError;
  String get ownershipTypeId => throw _privateConstructorUsedError;
  String get industryId => throw _privateConstructorUsedError;
  String get assignedRmId => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get npwp => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this CustomerCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCreateDtoCopyWith<CustomerCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCreateDtoCopyWith<$Res> {
  factory $CustomerCreateDtoCopyWith(
    CustomerCreateDto value,
    $Res Function(CustomerCreateDto) then,
  ) = _$CustomerCreateDtoCopyWithImpl<$Res, CustomerCreateDto>;
  @useResult
  $Res call({
    String name,
    String address,
    String provinceId,
    String cityId,
    String companyTypeId,
    String ownershipTypeId,
    String industryId,
    String assignedRmId,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    String? imageUrl,
    String? notes,
  });
}

/// @nodoc
class _$CustomerCreateDtoCopyWithImpl<$Res, $Val extends CustomerCreateDto>
    implements $CustomerCreateDtoCopyWith<$Res> {
  _$CustomerCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? provinceId = null,
    Object? cityId = null,
    Object? companyTypeId = null,
    Object? ownershipTypeId = null,
    Object? industryId = null,
    Object? assignedRmId = null,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? npwp = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            provinceId: null == provinceId
                ? _value.provinceId
                : provinceId // ignore: cast_nullable_to_non_nullable
                      as String,
            cityId: null == cityId
                ? _value.cityId
                : cityId // ignore: cast_nullable_to_non_nullable
                      as String,
            companyTypeId: null == companyTypeId
                ? _value.companyTypeId
                : companyTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            ownershipTypeId: null == ownershipTypeId
                ? _value.ownershipTypeId
                : ownershipTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            industryId: null == industryId
                ? _value.industryId
                : industryId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedRmId: null == assignedRmId
                ? _value.assignedRmId
                : assignedRmId // ignore: cast_nullable_to_non_nullable
                      as String,
            postalCode: freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            npwp: freezed == npwp
                ? _value.npwp
                : npwp // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$CustomerCreateDtoImplCopyWith<$Res>
    implements $CustomerCreateDtoCopyWith<$Res> {
  factory _$$CustomerCreateDtoImplCopyWith(
    _$CustomerCreateDtoImpl value,
    $Res Function(_$CustomerCreateDtoImpl) then,
  ) = __$$CustomerCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String address,
    String provinceId,
    String cityId,
    String companyTypeId,
    String ownershipTypeId,
    String industryId,
    String assignedRmId,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    String? imageUrl,
    String? notes,
  });
}

/// @nodoc
class __$$CustomerCreateDtoImplCopyWithImpl<$Res>
    extends _$CustomerCreateDtoCopyWithImpl<$Res, _$CustomerCreateDtoImpl>
    implements _$$CustomerCreateDtoImplCopyWith<$Res> {
  __$$CustomerCreateDtoImplCopyWithImpl(
    _$CustomerCreateDtoImpl _value,
    $Res Function(_$CustomerCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? provinceId = null,
    Object? cityId = null,
    Object? companyTypeId = null,
    Object? ownershipTypeId = null,
    Object? industryId = null,
    Object? assignedRmId = null,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? npwp = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$CustomerCreateDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        provinceId: null == provinceId
            ? _value.provinceId
            : provinceId // ignore: cast_nullable_to_non_nullable
                  as String,
        cityId: null == cityId
            ? _value.cityId
            : cityId // ignore: cast_nullable_to_non_nullable
                  as String,
        companyTypeId: null == companyTypeId
            ? _value.companyTypeId
            : companyTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        ownershipTypeId: null == ownershipTypeId
            ? _value.ownershipTypeId
            : ownershipTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        industryId: null == industryId
            ? _value.industryId
            : industryId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedRmId: null == assignedRmId
            ? _value.assignedRmId
            : assignedRmId // ignore: cast_nullable_to_non_nullable
                  as String,
        postalCode: freezed == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        npwp: freezed == npwp
            ? _value.npwp
            : npwp // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$CustomerCreateDtoImpl implements _CustomerCreateDto {
  const _$CustomerCreateDtoImpl({
    required this.name,
    required this.address,
    required this.provinceId,
    required this.cityId,
    required this.companyTypeId,
    required this.ownershipTypeId,
    required this.industryId,
    required this.assignedRmId,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.npwp,
    this.imageUrl,
    this.notes,
  });

  factory _$CustomerCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerCreateDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final String provinceId;
  @override
  final String cityId;
  @override
  final String companyTypeId;
  @override
  final String ownershipTypeId;
  @override
  final String industryId;
  @override
  final String assignedRmId;
  @override
  final String? postalCode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? website;
  @override
  final String? npwp;
  @override
  final String? imageUrl;
  @override
  final String? notes;

  @override
  String toString() {
    return 'CustomerCreateDto(name: $name, address: $address, provinceId: $provinceId, cityId: $cityId, companyTypeId: $companyTypeId, ownershipTypeId: $ownershipTypeId, industryId: $industryId, assignedRmId: $assignedRmId, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, phone: $phone, email: $email, website: $website, npwp: $npwp, imageUrl: $imageUrl, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerCreateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            (identical(other.companyTypeId, companyTypeId) ||
                other.companyTypeId == companyTypeId) &&
            (identical(other.ownershipTypeId, ownershipTypeId) ||
                other.ownershipTypeId == ownershipTypeId) &&
            (identical(other.industryId, industryId) ||
                other.industryId == industryId) &&
            (identical(other.assignedRmId, assignedRmId) ||
                other.assignedRmId == assignedRmId) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.npwp, npwp) || other.npwp == npwp) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    address,
    provinceId,
    cityId,
    companyTypeId,
    ownershipTypeId,
    industryId,
    assignedRmId,
    postalCode,
    latitude,
    longitude,
    phone,
    email,
    website,
    npwp,
    imageUrl,
    notes,
  );

  /// Create a copy of CustomerCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerCreateDtoImplCopyWith<_$CustomerCreateDtoImpl> get copyWith =>
      __$$CustomerCreateDtoImplCopyWithImpl<_$CustomerCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerCreateDtoImplToJson(this);
  }
}

abstract class _CustomerCreateDto implements CustomerCreateDto {
  const factory _CustomerCreateDto({
    required final String name,
    required final String address,
    required final String provinceId,
    required final String cityId,
    required final String companyTypeId,
    required final String ownershipTypeId,
    required final String industryId,
    required final String assignedRmId,
    final String? postalCode,
    final double? latitude,
    final double? longitude,
    final String? phone,
    final String? email,
    final String? website,
    final String? npwp,
    final String? imageUrl,
    final String? notes,
  }) = _$CustomerCreateDtoImpl;

  factory _CustomerCreateDto.fromJson(Map<String, dynamic> json) =
      _$CustomerCreateDtoImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String get provinceId;
  @override
  String get cityId;
  @override
  String get companyTypeId;
  @override
  String get ownershipTypeId;
  @override
  String get industryId;
  @override
  String get assignedRmId;
  @override
  String? get postalCode;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get website;
  @override
  String? get npwp;
  @override
  String? get imageUrl;
  @override
  String? get notes;

  /// Create a copy of CustomerCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerCreateDtoImplCopyWith<_$CustomerCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerUpdateDto _$CustomerUpdateDtoFromJson(Map<String, dynamic> json) {
  return _CustomerUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$CustomerUpdateDto {
  String? get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get provinceId => throw _privateConstructorUsedError;
  String? get cityId => throw _privateConstructorUsedError;
  String? get postalCode => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get companyTypeId => throw _privateConstructorUsedError;
  String? get ownershipTypeId => throw _privateConstructorUsedError;
  String? get industryId => throw _privateConstructorUsedError;
  String? get npwp => throw _privateConstructorUsedError;
  String? get assignedRmId => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this CustomerUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerUpdateDtoCopyWith<CustomerUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerUpdateDtoCopyWith<$Res> {
  factory $CustomerUpdateDtoCopyWith(
    CustomerUpdateDto value,
    $Res Function(CustomerUpdateDto) then,
  ) = _$CustomerUpdateDtoCopyWithImpl<$Res, CustomerUpdateDto>;
  @useResult
  $Res call({
    String? name,
    String? address,
    String? provinceId,
    String? cityId,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? companyTypeId,
    String? ownershipTypeId,
    String? industryId,
    String? npwp,
    String? assignedRmId,
    String? imageUrl,
    String? notes,
    bool? isActive,
  });
}

/// @nodoc
class _$CustomerUpdateDtoCopyWithImpl<$Res, $Val extends CustomerUpdateDto>
    implements $CustomerUpdateDtoCopyWith<$Res> {
  _$CustomerUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? address = freezed,
    Object? provinceId = freezed,
    Object? cityId = freezed,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? companyTypeId = freezed,
    Object? ownershipTypeId = freezed,
    Object? industryId = freezed,
    Object? npwp = freezed,
    Object? assignedRmId = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            provinceId: freezed == provinceId
                ? _value.provinceId
                : provinceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            cityId: freezed == cityId
                ? _value.cityId
                : cityId // ignore: cast_nullable_to_non_nullable
                      as String?,
            postalCode: freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            companyTypeId: freezed == companyTypeId
                ? _value.companyTypeId
                : companyTypeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            ownershipTypeId: freezed == ownershipTypeId
                ? _value.ownershipTypeId
                : ownershipTypeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            industryId: freezed == industryId
                ? _value.industryId
                : industryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            npwp: freezed == npwp
                ? _value.npwp
                : npwp // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedRmId: freezed == assignedRmId
                ? _value.assignedRmId
                : assignedRmId // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CustomerUpdateDtoImplCopyWith<$Res>
    implements $CustomerUpdateDtoCopyWith<$Res> {
  factory _$$CustomerUpdateDtoImplCopyWith(
    _$CustomerUpdateDtoImpl value,
    $Res Function(_$CustomerUpdateDtoImpl) then,
  ) = __$$CustomerUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? address,
    String? provinceId,
    String? cityId,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? companyTypeId,
    String? ownershipTypeId,
    String? industryId,
    String? npwp,
    String? assignedRmId,
    String? imageUrl,
    String? notes,
    bool? isActive,
  });
}

/// @nodoc
class __$$CustomerUpdateDtoImplCopyWithImpl<$Res>
    extends _$CustomerUpdateDtoCopyWithImpl<$Res, _$CustomerUpdateDtoImpl>
    implements _$$CustomerUpdateDtoImplCopyWith<$Res> {
  __$$CustomerUpdateDtoImplCopyWithImpl(
    _$CustomerUpdateDtoImpl _value,
    $Res Function(_$CustomerUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? address = freezed,
    Object? provinceId = freezed,
    Object? cityId = freezed,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? companyTypeId = freezed,
    Object? ownershipTypeId = freezed,
    Object? industryId = freezed,
    Object? npwp = freezed,
    Object? assignedRmId = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _$CustomerUpdateDtoImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        provinceId: freezed == provinceId
            ? _value.provinceId
            : provinceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        cityId: freezed == cityId
            ? _value.cityId
            : cityId // ignore: cast_nullable_to_non_nullable
                  as String?,
        postalCode: freezed == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        companyTypeId: freezed == companyTypeId
            ? _value.companyTypeId
            : companyTypeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        ownershipTypeId: freezed == ownershipTypeId
            ? _value.ownershipTypeId
            : ownershipTypeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        industryId: freezed == industryId
            ? _value.industryId
            : industryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        npwp: freezed == npwp
            ? _value.npwp
            : npwp // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedRmId: freezed == assignedRmId
            ? _value.assignedRmId
            : assignedRmId // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$CustomerUpdateDtoImpl implements _CustomerUpdateDto {
  const _$CustomerUpdateDtoImpl({
    this.name,
    this.address,
    this.provinceId,
    this.cityId,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.companyTypeId,
    this.ownershipTypeId,
    this.industryId,
    this.npwp,
    this.assignedRmId,
    this.imageUrl,
    this.notes,
    this.isActive,
  });

  factory _$CustomerUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerUpdateDtoImplFromJson(json);

  @override
  final String? name;
  @override
  final String? address;
  @override
  final String? provinceId;
  @override
  final String? cityId;
  @override
  final String? postalCode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? website;
  @override
  final String? companyTypeId;
  @override
  final String? ownershipTypeId;
  @override
  final String? industryId;
  @override
  final String? npwp;
  @override
  final String? assignedRmId;
  @override
  final String? imageUrl;
  @override
  final String? notes;
  @override
  final bool? isActive;

  @override
  String toString() {
    return 'CustomerUpdateDto(name: $name, address: $address, provinceId: $provinceId, cityId: $cityId, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, phone: $phone, email: $email, website: $website, companyTypeId: $companyTypeId, ownershipTypeId: $ownershipTypeId, industryId: $industryId, npwp: $npwp, assignedRmId: $assignedRmId, imageUrl: $imageUrl, notes: $notes, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerUpdateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.companyTypeId, companyTypeId) ||
                other.companyTypeId == companyTypeId) &&
            (identical(other.ownershipTypeId, ownershipTypeId) ||
                other.ownershipTypeId == ownershipTypeId) &&
            (identical(other.industryId, industryId) ||
                other.industryId == industryId) &&
            (identical(other.npwp, npwp) || other.npwp == npwp) &&
            (identical(other.assignedRmId, assignedRmId) ||
                other.assignedRmId == assignedRmId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    address,
    provinceId,
    cityId,
    postalCode,
    latitude,
    longitude,
    phone,
    email,
    website,
    companyTypeId,
    ownershipTypeId,
    industryId,
    npwp,
    assignedRmId,
    imageUrl,
    notes,
    isActive,
  );

  /// Create a copy of CustomerUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerUpdateDtoImplCopyWith<_$CustomerUpdateDtoImpl> get copyWith =>
      __$$CustomerUpdateDtoImplCopyWithImpl<_$CustomerUpdateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerUpdateDtoImplToJson(this);
  }
}

abstract class _CustomerUpdateDto implements CustomerUpdateDto {
  const factory _CustomerUpdateDto({
    final String? name,
    final String? address,
    final String? provinceId,
    final String? cityId,
    final String? postalCode,
    final double? latitude,
    final double? longitude,
    final String? phone,
    final String? email,
    final String? website,
    final String? companyTypeId,
    final String? ownershipTypeId,
    final String? industryId,
    final String? npwp,
    final String? assignedRmId,
    final String? imageUrl,
    final String? notes,
    final bool? isActive,
  }) = _$CustomerUpdateDtoImpl;

  factory _CustomerUpdateDto.fromJson(Map<String, dynamic> json) =
      _$CustomerUpdateDtoImpl.fromJson;

  @override
  String? get name;
  @override
  String? get address;
  @override
  String? get provinceId;
  @override
  String? get cityId;
  @override
  String? get postalCode;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get website;
  @override
  String? get companyTypeId;
  @override
  String? get ownershipTypeId;
  @override
  String? get industryId;
  @override
  String? get npwp;
  @override
  String? get assignedRmId;
  @override
  String? get imageUrl;
  @override
  String? get notes;
  @override
  bool? get isActive;

  /// Create a copy of CustomerUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerUpdateDtoImplCopyWith<_$CustomerUpdateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerSyncDto _$CustomerSyncDtoFromJson(Map<String, dynamic> json) {
  return _CustomerSyncDto.fromJson(json);
}

/// @nodoc
mixin _$CustomerSyncDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'province_id')
  String get provinceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'city_id')
  String get cityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_type_id')
  String get companyTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ownership_type_id')
  String get ownershipTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'industry_id')
  String get industryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_rm_id')
  String get assignedRmId => throw _privateConstructorUsedError;
  @JsonKey(name: 'postal_code')
  String? get postalCode => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get npwp => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this CustomerSyncDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerSyncDtoCopyWith<CustomerSyncDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerSyncDtoCopyWith<$Res> {
  factory $CustomerSyncDtoCopyWith(
    CustomerSyncDto value,
    $Res Function(CustomerSyncDto) then,
  ) = _$CustomerSyncDtoCopyWithImpl<$Res, CustomerSyncDto>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String address,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    @JsonKey(name: 'province_id') String provinceId,
    @JsonKey(name: 'city_id') String cityId,
    @JsonKey(name: 'company_type_id') String companyTypeId,
    @JsonKey(name: 'ownership_type_id') String ownershipTypeId,
    @JsonKey(name: 'industry_id') String industryId,
    @JsonKey(name: 'assigned_rm_id') String assignedRmId,
    @JsonKey(name: 'postal_code') String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class _$CustomerSyncDtoCopyWithImpl<$Res, $Val extends CustomerSyncDto>
    implements $CustomerSyncDtoCopyWith<$Res> {
  _$CustomerSyncDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? address = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? provinceId = null,
    Object? cityId = null,
    Object? companyTypeId = null,
    Object? ownershipTypeId = null,
    Object? industryId = null,
    Object? assignedRmId = null,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? npwp = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? deletedAt = freezed,
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
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            provinceId: null == provinceId
                ? _value.provinceId
                : provinceId // ignore: cast_nullable_to_non_nullable
                      as String,
            cityId: null == cityId
                ? _value.cityId
                : cityId // ignore: cast_nullable_to_non_nullable
                      as String,
            companyTypeId: null == companyTypeId
                ? _value.companyTypeId
                : companyTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            ownershipTypeId: null == ownershipTypeId
                ? _value.ownershipTypeId
                : ownershipTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            industryId: null == industryId
                ? _value.industryId
                : industryId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedRmId: null == assignedRmId
                ? _value.assignedRmId
                : assignedRmId // ignore: cast_nullable_to_non_nullable
                      as String,
            postalCode: freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            npwp: freezed == npwp
                ? _value.npwp
                : npwp // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerSyncDtoImplCopyWith<$Res>
    implements $CustomerSyncDtoCopyWith<$Res> {
  factory _$$CustomerSyncDtoImplCopyWith(
    _$CustomerSyncDtoImpl value,
    $Res Function(_$CustomerSyncDtoImpl) then,
  ) = __$$CustomerSyncDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String address,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    @JsonKey(name: 'province_id') String provinceId,
    @JsonKey(name: 'city_id') String cityId,
    @JsonKey(name: 'company_type_id') String companyTypeId,
    @JsonKey(name: 'ownership_type_id') String ownershipTypeId,
    @JsonKey(name: 'industry_id') String industryId,
    @JsonKey(name: 'assigned_rm_id') String assignedRmId,
    @JsonKey(name: 'postal_code') String? postalCode,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    String? npwp,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class __$$CustomerSyncDtoImplCopyWithImpl<$Res>
    extends _$CustomerSyncDtoCopyWithImpl<$Res, _$CustomerSyncDtoImpl>
    implements _$$CustomerSyncDtoImplCopyWith<$Res> {
  __$$CustomerSyncDtoImplCopyWithImpl(
    _$CustomerSyncDtoImpl _value,
    $Res Function(_$CustomerSyncDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? address = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? provinceId = null,
    Object? cityId = null,
    Object? companyTypeId = null,
    Object? ownershipTypeId = null,
    Object? industryId = null,
    Object? assignedRmId = null,
    Object? postalCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? npwp = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$CustomerSyncDtoImpl(
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
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        provinceId: null == provinceId
            ? _value.provinceId
            : provinceId // ignore: cast_nullable_to_non_nullable
                  as String,
        cityId: null == cityId
            ? _value.cityId
            : cityId // ignore: cast_nullable_to_non_nullable
                  as String,
        companyTypeId: null == companyTypeId
            ? _value.companyTypeId
            : companyTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        ownershipTypeId: null == ownershipTypeId
            ? _value.ownershipTypeId
            : ownershipTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        industryId: null == industryId
            ? _value.industryId
            : industryId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedRmId: null == assignedRmId
            ? _value.assignedRmId
            : assignedRmId // ignore: cast_nullable_to_non_nullable
                  as String,
        postalCode: freezed == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        npwp: freezed == npwp
            ? _value.npwp
            : npwp // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerSyncDtoImpl implements _CustomerSyncDto {
  const _$CustomerSyncDtoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    @JsonKey(name: 'province_id') required this.provinceId,
    @JsonKey(name: 'city_id') required this.cityId,
    @JsonKey(name: 'company_type_id') required this.companyTypeId,
    @JsonKey(name: 'ownership_type_id') required this.ownershipTypeId,
    @JsonKey(name: 'industry_id') required this.industryId,
    @JsonKey(name: 'assigned_rm_id') required this.assignedRmId,
    @JsonKey(name: 'postal_code') this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.npwp,
    @JsonKey(name: 'image_url') this.imageUrl,
    this.notes,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'deleted_at') this.deletedAt,
  });

  factory _$CustomerSyncDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerSyncDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String address;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'province_id')
  final String provinceId;
  @override
  @JsonKey(name: 'city_id')
  final String cityId;
  @override
  @JsonKey(name: 'company_type_id')
  final String companyTypeId;
  @override
  @JsonKey(name: 'ownership_type_id')
  final String ownershipTypeId;
  @override
  @JsonKey(name: 'industry_id')
  final String industryId;
  @override
  @JsonKey(name: 'assigned_rm_id')
  final String assignedRmId;
  @override
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? website;
  @override
  final String? npwp;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'CustomerSyncDto(id: $id, code: $code, name: $name, address: $address, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, provinceId: $provinceId, cityId: $cityId, companyTypeId: $companyTypeId, ownershipTypeId: $ownershipTypeId, industryId: $industryId, assignedRmId: $assignedRmId, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, phone: $phone, email: $email, website: $website, npwp: $npwp, imageUrl: $imageUrl, notes: $notes, isActive: $isActive, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerSyncDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            (identical(other.companyTypeId, companyTypeId) ||
                other.companyTypeId == companyTypeId) &&
            (identical(other.ownershipTypeId, ownershipTypeId) ||
                other.ownershipTypeId == ownershipTypeId) &&
            (identical(other.industryId, industryId) ||
                other.industryId == industryId) &&
            (identical(other.assignedRmId, assignedRmId) ||
                other.assignedRmId == assignedRmId) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.npwp, npwp) || other.npwp == npwp) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    code,
    name,
    address,
    createdBy,
    createdAt,
    updatedAt,
    provinceId,
    cityId,
    companyTypeId,
    ownershipTypeId,
    industryId,
    assignedRmId,
    postalCode,
    latitude,
    longitude,
    phone,
    email,
    website,
    npwp,
    imageUrl,
    notes,
    isActive,
    deletedAt,
  ]);

  /// Create a copy of CustomerSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerSyncDtoImplCopyWith<_$CustomerSyncDtoImpl> get copyWith =>
      __$$CustomerSyncDtoImplCopyWithImpl<_$CustomerSyncDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerSyncDtoImplToJson(this);
  }
}

abstract class _CustomerSyncDto implements CustomerSyncDto {
  const factory _CustomerSyncDto({
    required final String id,
    required final String code,
    required final String name,
    required final String address,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @JsonKey(name: 'province_id') required final String provinceId,
    @JsonKey(name: 'city_id') required final String cityId,
    @JsonKey(name: 'company_type_id') required final String companyTypeId,
    @JsonKey(name: 'ownership_type_id') required final String ownershipTypeId,
    @JsonKey(name: 'industry_id') required final String industryId,
    @JsonKey(name: 'assigned_rm_id') required final String assignedRmId,
    @JsonKey(name: 'postal_code') final String? postalCode,
    final double? latitude,
    final double? longitude,
    final String? phone,
    final String? email,
    final String? website,
    final String? npwp,
    @JsonKey(name: 'image_url') final String? imageUrl,
    final String? notes,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
  }) = _$CustomerSyncDtoImpl;

  factory _CustomerSyncDto.fromJson(Map<String, dynamic> json) =
      _$CustomerSyncDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String get address;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'province_id')
  String get provinceId;
  @override
  @JsonKey(name: 'city_id')
  String get cityId;
  @override
  @JsonKey(name: 'company_type_id')
  String get companyTypeId;
  @override
  @JsonKey(name: 'ownership_type_id')
  String get ownershipTypeId;
  @override
  @JsonKey(name: 'industry_id')
  String get industryId;
  @override
  @JsonKey(name: 'assigned_rm_id')
  String get assignedRmId;
  @override
  @JsonKey(name: 'postal_code')
  String? get postalCode;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get website;
  @override
  String? get npwp;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt;

  /// Create a copy of CustomerSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerSyncDtoImplCopyWith<_$CustomerSyncDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KeyPersonDto _$KeyPersonDtoFromJson(Map<String, dynamic> json) {
  return _KeyPersonDto.fromJson(json);
}

/// @nodoc
mixin _$KeyPersonDto {
  String get ownerType => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get hvcId => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this KeyPersonDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KeyPersonDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyPersonDtoCopyWith<KeyPersonDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyPersonDtoCopyWith<$Res> {
  factory $KeyPersonDtoCopyWith(
    KeyPersonDto value,
    $Res Function(KeyPersonDto) then,
  ) = _$KeyPersonDtoCopyWithImpl<$Res, KeyPersonDto>;
  @useResult
  $Res call({
    String ownerType,
    String name,
    String? id,
    String? customerId,
    String? brokerId,
    String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    bool isPrimary,
    String? notes,
  });
}

/// @nodoc
class _$KeyPersonDtoCopyWithImpl<$Res, $Val extends KeyPersonDto>
    implements $KeyPersonDtoCopyWith<$Res> {
  _$KeyPersonDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyPersonDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ownerType = null,
    Object? name = null,
    Object? id = freezed,
    Object? customerId = freezed,
    Object? brokerId = freezed,
    Object? hvcId = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isPrimary = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            ownerType: null == ownerType
                ? _value.ownerType
                : ownerType // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hvcId: freezed == hvcId
                ? _value.hvcId
                : hvcId // ignore: cast_nullable_to_non_nullable
                      as String?,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as String?,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$KeyPersonDtoImplCopyWith<$Res>
    implements $KeyPersonDtoCopyWith<$Res> {
  factory _$$KeyPersonDtoImplCopyWith(
    _$KeyPersonDtoImpl value,
    $Res Function(_$KeyPersonDtoImpl) then,
  ) = __$$KeyPersonDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ownerType,
    String name,
    String? id,
    String? customerId,
    String? brokerId,
    String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    bool isPrimary,
    String? notes,
  });
}

/// @nodoc
class __$$KeyPersonDtoImplCopyWithImpl<$Res>
    extends _$KeyPersonDtoCopyWithImpl<$Res, _$KeyPersonDtoImpl>
    implements _$$KeyPersonDtoImplCopyWith<$Res> {
  __$$KeyPersonDtoImplCopyWithImpl(
    _$KeyPersonDtoImpl _value,
    $Res Function(_$KeyPersonDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeyPersonDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ownerType = null,
    Object? name = null,
    Object? id = freezed,
    Object? customerId = freezed,
    Object? brokerId = freezed,
    Object? hvcId = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isPrimary = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$KeyPersonDtoImpl(
        ownerType: null == ownerType
            ? _value.ownerType
            : ownerType // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hvcId: freezed == hvcId
            ? _value.hvcId
            : hvcId // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as String?,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$KeyPersonDtoImpl implements _KeyPersonDto {
  const _$KeyPersonDtoImpl({
    required this.ownerType,
    required this.name,
    this.id,
    this.customerId,
    this.brokerId,
    this.hvcId,
    this.position,
    this.department,
    this.phone,
    this.email,
    this.isPrimary = false,
    this.notes,
  });

  factory _$KeyPersonDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeyPersonDtoImplFromJson(json);

  @override
  final String ownerType;
  @override
  final String name;
  @override
  final String? id;
  @override
  final String? customerId;
  @override
  final String? brokerId;
  @override
  final String? hvcId;
  @override
  final String? position;
  @override
  final String? department;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey()
  final bool isPrimary;
  @override
  final String? notes;

  @override
  String toString() {
    return 'KeyPersonDto(ownerType: $ownerType, name: $name, id: $id, customerId: $customerId, brokerId: $brokerId, hvcId: $hvcId, position: $position, department: $department, phone: $phone, email: $email, isPrimary: $isPrimary, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyPersonDtoImpl &&
            (identical(other.ownerType, ownerType) ||
                other.ownerType == ownerType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ownerType,
    name,
    id,
    customerId,
    brokerId,
    hvcId,
    position,
    department,
    phone,
    email,
    isPrimary,
    notes,
  );

  /// Create a copy of KeyPersonDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyPersonDtoImplCopyWith<_$KeyPersonDtoImpl> get copyWith =>
      __$$KeyPersonDtoImplCopyWithImpl<_$KeyPersonDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeyPersonDtoImplToJson(this);
  }
}

abstract class _KeyPersonDto implements KeyPersonDto {
  const factory _KeyPersonDto({
    required final String ownerType,
    required final String name,
    final String? id,
    final String? customerId,
    final String? brokerId,
    final String? hvcId,
    final String? position,
    final String? department,
    final String? phone,
    final String? email,
    final bool isPrimary,
    final String? notes,
  }) = _$KeyPersonDtoImpl;

  factory _KeyPersonDto.fromJson(Map<String, dynamic> json) =
      _$KeyPersonDtoImpl.fromJson;

  @override
  String get ownerType;
  @override
  String get name;
  @override
  String? get id;
  @override
  String? get customerId;
  @override
  String? get brokerId;
  @override
  String? get hvcId;
  @override
  String? get position;
  @override
  String? get department;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  bool get isPrimary;
  @override
  String? get notes;

  /// Create a copy of KeyPersonDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyPersonDtoImplCopyWith<_$KeyPersonDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KeyPersonSyncDto _$KeyPersonSyncDtoFromJson(Map<String, dynamic> json) {
  return _KeyPersonSyncDto.fromJson(json);
}

/// @nodoc
mixin _$KeyPersonSyncDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_type')
  String get ownerType => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'broker_id')
  String? get brokerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'hvc_id')
  String? get hvcId => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool get isPrimary => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this KeyPersonSyncDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KeyPersonSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyPersonSyncDtoCopyWith<KeyPersonSyncDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyPersonSyncDtoCopyWith<$Res> {
  factory $KeyPersonSyncDtoCopyWith(
    KeyPersonSyncDto value,
    $Res Function(KeyPersonSyncDto) then,
  ) = _$KeyPersonSyncDtoCopyWithImpl<$Res, KeyPersonSyncDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    @JsonKey(name: 'owner_type') String ownerType,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'broker_id') String? brokerId,
    @JsonKey(name: 'hvc_id') String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    @JsonKey(name: 'is_primary') bool isPrimary,
    @JsonKey(name: 'is_active') bool isActive,
    String? notes,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class _$KeyPersonSyncDtoCopyWithImpl<$Res, $Val extends KeyPersonSyncDto>
    implements $KeyPersonSyncDtoCopyWith<$Res> {
  _$KeyPersonSyncDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyPersonSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerType = null,
    Object? customerId = freezed,
    Object? brokerId = freezed,
    Object? hvcId = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isPrimary = null,
    Object? isActive = null,
    Object? notes = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ownerType: null == ownerType
                ? _value.ownerType
                : ownerType // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hvcId: freezed == hvcId
                ? _value.hvcId
                : hvcId // ignore: cast_nullable_to_non_nullable
                      as String?,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as String?,
            department: freezed == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeyPersonSyncDtoImplCopyWith<$Res>
    implements $KeyPersonSyncDtoCopyWith<$Res> {
  factory _$$KeyPersonSyncDtoImplCopyWith(
    _$KeyPersonSyncDtoImpl value,
    $Res Function(_$KeyPersonSyncDtoImpl) then,
  ) = __$$KeyPersonSyncDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    @JsonKey(name: 'owner_type') String ownerType,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'broker_id') String? brokerId,
    @JsonKey(name: 'hvc_id') String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    @JsonKey(name: 'is_primary') bool isPrimary,
    @JsonKey(name: 'is_active') bool isActive,
    String? notes,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class __$$KeyPersonSyncDtoImplCopyWithImpl<$Res>
    extends _$KeyPersonSyncDtoCopyWithImpl<$Res, _$KeyPersonSyncDtoImpl>
    implements _$$KeyPersonSyncDtoImplCopyWith<$Res> {
  __$$KeyPersonSyncDtoImplCopyWithImpl(
    _$KeyPersonSyncDtoImpl _value,
    $Res Function(_$KeyPersonSyncDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeyPersonSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerType = null,
    Object? customerId = freezed,
    Object? brokerId = freezed,
    Object? hvcId = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isPrimary = null,
    Object? isActive = null,
    Object? notes = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$KeyPersonSyncDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ownerType: null == ownerType
            ? _value.ownerType
            : ownerType // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hvcId: freezed == hvcId
            ? _value.hvcId
            : hvcId // ignore: cast_nullable_to_non_nullable
                  as String?,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as String?,
        department: freezed == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KeyPersonSyncDtoImpl implements _KeyPersonSyncDto {
  const _$KeyPersonSyncDtoImpl({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    @JsonKey(name: 'owner_type') required this.ownerType,
    @JsonKey(name: 'customer_id') this.customerId,
    @JsonKey(name: 'broker_id') this.brokerId,
    @JsonKey(name: 'hvc_id') this.hvcId,
    this.position,
    this.department,
    this.phone,
    this.email,
    @JsonKey(name: 'is_primary') this.isPrimary = false,
    @JsonKey(name: 'is_active') this.isActive = true,
    this.notes,
    @JsonKey(name: 'deleted_at') this.deletedAt,
  });

  factory _$KeyPersonSyncDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeyPersonSyncDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'owner_type')
  final String ownerType;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'broker_id')
  final String? brokerId;
  @override
  @JsonKey(name: 'hvc_id')
  final String? hvcId;
  @override
  final String? position;
  @override
  final String? department;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'KeyPersonSyncDto(id: $id, name: $name, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, ownerType: $ownerType, customerId: $customerId, brokerId: $brokerId, hvcId: $hvcId, position: $position, department: $department, phone: $phone, email: $email, isPrimary: $isPrimary, isActive: $isActive, notes: $notes, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyPersonSyncDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.ownerType, ownerType) ||
                other.ownerType == ownerType) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    createdBy,
    createdAt,
    updatedAt,
    ownerType,
    customerId,
    brokerId,
    hvcId,
    position,
    department,
    phone,
    email,
    isPrimary,
    isActive,
    notes,
    deletedAt,
  );

  /// Create a copy of KeyPersonSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyPersonSyncDtoImplCopyWith<_$KeyPersonSyncDtoImpl> get copyWith =>
      __$$KeyPersonSyncDtoImplCopyWithImpl<_$KeyPersonSyncDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KeyPersonSyncDtoImplToJson(this);
  }
}

abstract class _KeyPersonSyncDto implements KeyPersonSyncDto {
  const factory _KeyPersonSyncDto({
    required final String id,
    required final String name,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @JsonKey(name: 'owner_type') required final String ownerType,
    @JsonKey(name: 'customer_id') final String? customerId,
    @JsonKey(name: 'broker_id') final String? brokerId,
    @JsonKey(name: 'hvc_id') final String? hvcId,
    final String? position,
    final String? department,
    final String? phone,
    final String? email,
    @JsonKey(name: 'is_primary') final bool isPrimary,
    @JsonKey(name: 'is_active') final bool isActive,
    final String? notes,
    @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
  }) = _$KeyPersonSyncDtoImpl;

  factory _KeyPersonSyncDto.fromJson(Map<String, dynamic> json) =
      _$KeyPersonSyncDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'owner_type')
  String get ownerType;
  @override
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @override
  @JsonKey(name: 'broker_id')
  String? get brokerId;
  @override
  @JsonKey(name: 'hvc_id')
  String? get hvcId;
  @override
  String? get position;
  @override
  String? get department;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  @JsonKey(name: 'is_primary')
  bool get isPrimary;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt;

  /// Create a copy of KeyPersonSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyPersonSyncDtoImplCopyWith<_$KeyPersonSyncDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
