// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'broker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Broker _$BrokerFromJson(Map<String, dynamic> json) {
  return _Broker.fromJson(json);
}

/// @nodoc
mixin _$Broker {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get licenseNumber => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get provinceId => throw _privateConstructorUsedError;
  String? get cityId => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  double? get commissionRate => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // Lookup fields (populated from joined data)
  String? get provinceName => throw _privateConstructorUsedError;
  String? get cityName => throw _privateConstructorUsedError;

  /// Serializes this Broker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Broker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrokerCopyWith<Broker> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrokerCopyWith<$Res> {
  factory $BrokerCopyWith(Broker value, $Res Function(Broker) then) =
      _$BrokerCopyWithImpl<$Res, Broker>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? licenseNumber,
    String? address,
    String? provinceId,
    String? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    double? commissionRate,
    String? imageUrl,
    String? notes,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
    String? provinceName,
    String? cityName,
  });
}

/// @nodoc
class _$BrokerCopyWithImpl<$Res, $Val extends Broker>
    implements $BrokerCopyWith<$Res> {
  _$BrokerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Broker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? licenseNumber = freezed,
    Object? address = freezed,
    Object? provinceId = freezed,
    Object? cityId = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? commissionRate = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
    Object? provinceName = freezed,
    Object? cityName = freezed,
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
            licenseNumber: freezed == licenseNumber
                ? _value.licenseNumber
                : licenseNumber // ignore: cast_nullable_to_non_nullable
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
            commissionRate: freezed == commissionRate
                ? _value.commissionRate
                : commissionRate // ignore: cast_nullable_to_non_nullable
                      as double?,
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
            isPendingSync: null == isPendingSync
                ? _value.isPendingSync
                : isPendingSync // ignore: cast_nullable_to_non_nullable
                      as bool,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            provinceName: freezed == provinceName
                ? _value.provinceName
                : provinceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            cityName: freezed == cityName
                ? _value.cityName
                : cityName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BrokerImplCopyWith<$Res> implements $BrokerCopyWith<$Res> {
  factory _$$BrokerImplCopyWith(
    _$BrokerImpl value,
    $Res Function(_$BrokerImpl) then,
  ) = __$$BrokerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? licenseNumber,
    String? address,
    String? provinceId,
    String? cityId,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    double? commissionRate,
    String? imageUrl,
    String? notes,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
    String? provinceName,
    String? cityName,
  });
}

/// @nodoc
class __$$BrokerImplCopyWithImpl<$Res>
    extends _$BrokerCopyWithImpl<$Res, _$BrokerImpl>
    implements _$$BrokerImplCopyWith<$Res> {
  __$$BrokerImplCopyWithImpl(
    _$BrokerImpl _value,
    $Res Function(_$BrokerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Broker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? licenseNumber = freezed,
    Object? address = freezed,
    Object? provinceId = freezed,
    Object? cityId = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? commissionRate = freezed,
    Object? imageUrl = freezed,
    Object? notes = freezed,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
    Object? provinceName = freezed,
    Object? cityName = freezed,
  }) {
    return _then(
      _$BrokerImpl(
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
        licenseNumber: freezed == licenseNumber
            ? _value.licenseNumber
            : licenseNumber // ignore: cast_nullable_to_non_nullable
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
        commissionRate: freezed == commissionRate
            ? _value.commissionRate
            : commissionRate // ignore: cast_nullable_to_non_nullable
                  as double?,
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
        isPendingSync: null == isPendingSync
            ? _value.isPendingSync
            : isPendingSync // ignore: cast_nullable_to_non_nullable
                  as bool,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        provinceName: freezed == provinceName
            ? _value.provinceName
            : provinceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        cityName: freezed == cityName
            ? _value.cityName
            : cityName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BrokerImpl extends _Broker {
  const _$BrokerImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.licenseNumber,
    this.address,
    this.provinceId,
    this.cityId,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.commissionRate,
    this.imageUrl,
    this.notes,
    this.isActive = true,
    this.isPendingSync = false,
    this.deletedAt,
    this.provinceName,
    this.cityName,
  }) : super._();

  factory _$BrokerImpl.fromJson(Map<String, dynamic> json) =>
      _$$BrokerImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? licenseNumber;
  @override
  final String? address;
  @override
  final String? provinceId;
  @override
  final String? cityId;
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
  final double? commissionRate;
  @override
  final String? imageUrl;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime? deletedAt;
  // Lookup fields (populated from joined data)
  @override
  final String? provinceName;
  @override
  final String? cityName;

  @override
  String toString() {
    return 'Broker(id: $id, code: $code, name: $name, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, licenseNumber: $licenseNumber, address: $address, provinceId: $provinceId, cityId: $cityId, latitude: $latitude, longitude: $longitude, phone: $phone, email: $email, website: $website, commissionRate: $commissionRate, imageUrl: $imageUrl, notes: $notes, isActive: $isActive, isPendingSync: $isPendingSync, deletedAt: $deletedAt, provinceName: $provinceName, cityName: $cityName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrokerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.provinceId, provinceId) ||
                other.provinceId == provinceId) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.provinceName, provinceName) ||
                other.provinceName == provinceName) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    code,
    name,
    createdBy,
    createdAt,
    updatedAt,
    licenseNumber,
    address,
    provinceId,
    cityId,
    latitude,
    longitude,
    phone,
    email,
    website,
    commissionRate,
    imageUrl,
    notes,
    isActive,
    isPendingSync,
    deletedAt,
    provinceName,
    cityName,
  ]);

  /// Create a copy of Broker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrokerImplCopyWith<_$BrokerImpl> get copyWith =>
      __$$BrokerImplCopyWithImpl<_$BrokerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BrokerImplToJson(this);
  }
}

abstract class _Broker extends Broker {
  const factory _Broker({
    required final String id,
    required final String code,
    required final String name,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? licenseNumber,
    final String? address,
    final String? provinceId,
    final String? cityId,
    final double? latitude,
    final double? longitude,
    final String? phone,
    final String? email,
    final String? website,
    final double? commissionRate,
    final String? imageUrl,
    final String? notes,
    final bool isActive,
    final bool isPendingSync,
    final DateTime? deletedAt,
    final String? provinceName,
    final String? cityName,
  }) = _$BrokerImpl;
  const _Broker._() : super._();

  factory _Broker.fromJson(Map<String, dynamic> json) = _$BrokerImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get licenseNumber;
  @override
  String? get address;
  @override
  String? get provinceId;
  @override
  String? get cityId;
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
  double? get commissionRate;
  @override
  String? get imageUrl;
  @override
  String? get notes;
  @override
  bool get isActive;
  @override
  bool get isPendingSync;
  @override
  DateTime? get deletedAt; // Lookup fields (populated from joined data)
  @override
  String? get provinceName;
  @override
  String? get cityName;

  /// Create a copy of Broker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrokerImplCopyWith<_$BrokerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BrokerWithDetails _$BrokerWithDetailsFromJson(Map<String, dynamic> json) {
  return _BrokerWithDetails.fromJson(json);
}

/// @nodoc
mixin _$BrokerWithDetails {
  Broker get broker => throw _privateConstructorUsedError;
  int get keyPersonsCount => throw _privateConstructorUsedError;
  int get pipelineCount => throw _privateConstructorUsedError;

  /// Serializes this BrokerWithDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BrokerWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrokerWithDetailsCopyWith<BrokerWithDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrokerWithDetailsCopyWith<$Res> {
  factory $BrokerWithDetailsCopyWith(
    BrokerWithDetails value,
    $Res Function(BrokerWithDetails) then,
  ) = _$BrokerWithDetailsCopyWithImpl<$Res, BrokerWithDetails>;
  @useResult
  $Res call({Broker broker, int keyPersonsCount, int pipelineCount});

  $BrokerCopyWith<$Res> get broker;
}

/// @nodoc
class _$BrokerWithDetailsCopyWithImpl<$Res, $Val extends BrokerWithDetails>
    implements $BrokerWithDetailsCopyWith<$Res> {
  _$BrokerWithDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BrokerWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? broker = null,
    Object? keyPersonsCount = null,
    Object? pipelineCount = null,
  }) {
    return _then(
      _value.copyWith(
            broker: null == broker
                ? _value.broker
                : broker // ignore: cast_nullable_to_non_nullable
                      as Broker,
            keyPersonsCount: null == keyPersonsCount
                ? _value.keyPersonsCount
                : keyPersonsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pipelineCount: null == pipelineCount
                ? _value.pipelineCount
                : pipelineCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of BrokerWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BrokerCopyWith<$Res> get broker {
    return $BrokerCopyWith<$Res>(_value.broker, (value) {
      return _then(_value.copyWith(broker: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BrokerWithDetailsImplCopyWith<$Res>
    implements $BrokerWithDetailsCopyWith<$Res> {
  factory _$$BrokerWithDetailsImplCopyWith(
    _$BrokerWithDetailsImpl value,
    $Res Function(_$BrokerWithDetailsImpl) then,
  ) = __$$BrokerWithDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Broker broker, int keyPersonsCount, int pipelineCount});

  @override
  $BrokerCopyWith<$Res> get broker;
}

/// @nodoc
class __$$BrokerWithDetailsImplCopyWithImpl<$Res>
    extends _$BrokerWithDetailsCopyWithImpl<$Res, _$BrokerWithDetailsImpl>
    implements _$$BrokerWithDetailsImplCopyWith<$Res> {
  __$$BrokerWithDetailsImplCopyWithImpl(
    _$BrokerWithDetailsImpl _value,
    $Res Function(_$BrokerWithDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BrokerWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? broker = null,
    Object? keyPersonsCount = null,
    Object? pipelineCount = null,
  }) {
    return _then(
      _$BrokerWithDetailsImpl(
        broker: null == broker
            ? _value.broker
            : broker // ignore: cast_nullable_to_non_nullable
                  as Broker,
        keyPersonsCount: null == keyPersonsCount
            ? _value.keyPersonsCount
            : keyPersonsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pipelineCount: null == pipelineCount
            ? _value.pipelineCount
            : pipelineCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BrokerWithDetailsImpl extends _BrokerWithDetails {
  const _$BrokerWithDetailsImpl({
    required this.broker,
    this.keyPersonsCount = 0,
    this.pipelineCount = 0,
  }) : super._();

  factory _$BrokerWithDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BrokerWithDetailsImplFromJson(json);

  @override
  final Broker broker;
  @override
  @JsonKey()
  final int keyPersonsCount;
  @override
  @JsonKey()
  final int pipelineCount;

  @override
  String toString() {
    return 'BrokerWithDetails(broker: $broker, keyPersonsCount: $keyPersonsCount, pipelineCount: $pipelineCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrokerWithDetailsImpl &&
            (identical(other.broker, broker) || other.broker == broker) &&
            (identical(other.keyPersonsCount, keyPersonsCount) ||
                other.keyPersonsCount == keyPersonsCount) &&
            (identical(other.pipelineCount, pipelineCount) ||
                other.pipelineCount == pipelineCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, broker, keyPersonsCount, pipelineCount);

  /// Create a copy of BrokerWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrokerWithDetailsImplCopyWith<_$BrokerWithDetailsImpl> get copyWith =>
      __$$BrokerWithDetailsImplCopyWithImpl<_$BrokerWithDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BrokerWithDetailsImplToJson(this);
  }
}

abstract class _BrokerWithDetails extends BrokerWithDetails {
  const factory _BrokerWithDetails({
    required final Broker broker,
    final int keyPersonsCount,
    final int pipelineCount,
  }) = _$BrokerWithDetailsImpl;
  const _BrokerWithDetails._() : super._();

  factory _BrokerWithDetails.fromJson(Map<String, dynamic> json) =
      _$BrokerWithDetailsImpl.fromJson;

  @override
  Broker get broker;
  @override
  int get keyPersonsCount;
  @override
  int get pipelineCount;

  /// Create a copy of BrokerWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrokerWithDetailsImplCopyWith<_$BrokerWithDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
