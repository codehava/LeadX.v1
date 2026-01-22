// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hvc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HvcType _$HvcTypeFromJson(Map<String, dynamic> json) {
  return _HvcType.fromJson(json);
}

/// @nodoc
mixin _$HvcType {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this HvcType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HvcType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvcTypeCopyWith<HvcType> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvcTypeCopyWith<$Res> {
  factory $HvcTypeCopyWith(HvcType value, $Res Function(HvcType) then) =
      _$HvcTypeCopyWithImpl<$Res, HvcType>;
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
class _$HvcTypeCopyWithImpl<$Res, $Val extends HvcType>
    implements $HvcTypeCopyWith<$Res> {
  _$HvcTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HvcType
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
abstract class _$$HvcTypeImplCopyWith<$Res> implements $HvcTypeCopyWith<$Res> {
  factory _$$HvcTypeImplCopyWith(
    _$HvcTypeImpl value,
    $Res Function(_$HvcTypeImpl) then,
  ) = __$$HvcTypeImplCopyWithImpl<$Res>;
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
class __$$HvcTypeImplCopyWithImpl<$Res>
    extends _$HvcTypeCopyWithImpl<$Res, _$HvcTypeImpl>
    implements _$$HvcTypeImplCopyWith<$Res> {
  __$$HvcTypeImplCopyWithImpl(
    _$HvcTypeImpl _value,
    $Res Function(_$HvcTypeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HvcType
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
      _$HvcTypeImpl(
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
class _$HvcTypeImpl implements _HvcType {
  const _$HvcTypeImpl({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory _$HvcTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvcTypeImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'HvcType(id: $id, code: $code, name: $name, description: $description, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvcTypeImpl &&
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

  /// Create a copy of HvcType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvcTypeImplCopyWith<_$HvcTypeImpl> get copyWith =>
      __$$HvcTypeImplCopyWithImpl<_$HvcTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HvcTypeImplToJson(this);
  }
}

abstract class _HvcType implements HvcType {
  const factory _HvcType({
    required final String id,
    required final String code,
    required final String name,
    final String? description,
    final int sortOrder,
    final bool isActive,
  }) = _$HvcTypeImpl;

  factory _HvcType.fromJson(Map<String, dynamic> json) = _$HvcTypeImpl.fromJson;

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

  /// Create a copy of HvcType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvcTypeImplCopyWith<_$HvcTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Hvc _$HvcFromJson(Map<String, dynamic> json) {
  return _Hvc.fromJson(json);
}

/// @nodoc
mixin _$Hvc {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get typeId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int get radiusMeters => throw _privateConstructorUsedError;
  double? get potentialValue => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt =>
      throw _privateConstructorUsedError; // Lookup fields (populated from joined data)
  String? get typeName => throw _privateConstructorUsedError;

  /// Serializes this Hvc to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Hvc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvcCopyWith<Hvc> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvcCopyWith<$Res> {
  factory $HvcCopyWith(Hvc value, $Res Function(Hvc) then) =
      _$HvcCopyWithImpl<$Res, Hvc>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String typeId,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int radiusMeters,
    double? potentialValue,
    String? imageUrl,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    String? typeName,
  });
}

/// @nodoc
class _$HvcCopyWithImpl<$Res, $Val extends Hvc> implements $HvcCopyWith<$Res> {
  _$HvcCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hvc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? typeId = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radiusMeters = null,
    Object? potentialValue = freezed,
    Object? imageUrl = freezed,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
    Object? lastSyncAt = freezed,
    Object? typeName = freezed,
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
            typeId: null == typeId
                ? _value.typeId
                : typeId // ignore: cast_nullable_to_non_nullable
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
            radiusMeters: null == radiusMeters
                ? _value.radiusMeters
                : radiusMeters // ignore: cast_nullable_to_non_nullable
                      as int,
            potentialValue: freezed == potentialValue
                ? _value.potentialValue
                : potentialValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
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
            lastSyncAt: freezed == lastSyncAt
                ? _value.lastSyncAt
                : lastSyncAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            typeName: freezed == typeName
                ? _value.typeName
                : typeName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HvcImplCopyWith<$Res> implements $HvcCopyWith<$Res> {
  factory _$$HvcImplCopyWith(_$HvcImpl value, $Res Function(_$HvcImpl) then) =
      __$$HvcImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String typeId,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int radiusMeters,
    double? potentialValue,
    String? imageUrl,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    String? typeName,
  });
}

/// @nodoc
class __$$HvcImplCopyWithImpl<$Res> extends _$HvcCopyWithImpl<$Res, _$HvcImpl>
    implements _$$HvcImplCopyWith<$Res> {
  __$$HvcImplCopyWithImpl(_$HvcImpl _value, $Res Function(_$HvcImpl) _then)
    : super(_value, _then);

  /// Create a copy of Hvc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? typeId = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? description = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? radiusMeters = null,
    Object? potentialValue = freezed,
    Object? imageUrl = freezed,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
    Object? lastSyncAt = freezed,
    Object? typeName = freezed,
  }) {
    return _then(
      _$HvcImpl(
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
        typeId: null == typeId
            ? _value.typeId
            : typeId // ignore: cast_nullable_to_non_nullable
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
        radiusMeters: null == radiusMeters
            ? _value.radiusMeters
            : radiusMeters // ignore: cast_nullable_to_non_nullable
                  as int,
        potentialValue: freezed == potentialValue
            ? _value.potentialValue
            : potentialValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
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
        lastSyncAt: freezed == lastSyncAt
            ? _value.lastSyncAt
            : lastSyncAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        typeName: freezed == typeName
            ? _value.typeName
            : typeName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HvcImpl extends _Hvc {
  const _$HvcImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.typeId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.radiusMeters = 500,
    this.potentialValue,
    this.imageUrl,
    this.isActive = true,
    this.isPendingSync = false,
    this.deletedAt,
    this.lastSyncAt,
    this.typeName,
  }) : super._();

  factory _$HvcImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvcImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String typeId;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? description;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final int radiusMeters;
  @override
  final double? potentialValue;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? lastSyncAt;
  // Lookup fields (populated from joined data)
  @override
  final String? typeName;

  @override
  String toString() {
    return 'Hvc(id: $id, code: $code, name: $name, typeId: $typeId, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, address: $address, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, potentialValue: $potentialValue, imageUrl: $imageUrl, isActive: $isActive, isPendingSync: $isPendingSync, deletedAt: $deletedAt, lastSyncAt: $lastSyncAt, typeName: $typeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvcImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.typeId, typeId) || other.typeId == typeId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
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
                other.isActive == isActive) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.typeName, typeName) ||
                other.typeName == typeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    code,
    name,
    typeId,
    createdBy,
    createdAt,
    updatedAt,
    description,
    address,
    latitude,
    longitude,
    radiusMeters,
    potentialValue,
    imageUrl,
    isActive,
    isPendingSync,
    deletedAt,
    lastSyncAt,
    typeName,
  ]);

  /// Create a copy of Hvc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvcImplCopyWith<_$HvcImpl> get copyWith =>
      __$$HvcImplCopyWithImpl<_$HvcImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HvcImplToJson(this);
  }
}

abstract class _Hvc extends Hvc {
  const factory _Hvc({
    required final String id,
    required final String code,
    required final String name,
    required final String typeId,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? description,
    final String? address,
    final double? latitude,
    final double? longitude,
    final int radiusMeters,
    final double? potentialValue,
    final String? imageUrl,
    final bool isActive,
    final bool isPendingSync,
    final DateTime? deletedAt,
    final DateTime? lastSyncAt,
    final String? typeName,
  }) = _$HvcImpl;
  const _Hvc._() : super._();

  factory _Hvc.fromJson(Map<String, dynamic> json) = _$HvcImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String get typeId;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get description;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int get radiusMeters;
  @override
  double? get potentialValue;
  @override
  String? get imageUrl;
  @override
  bool get isActive;
  @override
  bool get isPendingSync;
  @override
  DateTime? get deletedAt;
  @override
  DateTime? get lastSyncAt; // Lookup fields (populated from joined data)
  @override
  String? get typeName;

  /// Create a copy of Hvc
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvcImplCopyWith<_$HvcImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerHvcLink _$CustomerHvcLinkFromJson(Map<String, dynamic> json) {
  return _CustomerHvcLink.fromJson(json);
}

/// @nodoc
mixin _$CustomerHvcLink {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get hvcId => throw _privateConstructorUsedError;
  String get relationshipType => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // Lookup fields
  String? get customerName => throw _privateConstructorUsedError;
  String? get customerCode => throw _privateConstructorUsedError;
  String? get hvcName => throw _privateConstructorUsedError;
  String? get hvcCode => throw _privateConstructorUsedError;

  /// Serializes this CustomerHvcLink to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerHvcLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerHvcLinkCopyWith<CustomerHvcLink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerHvcLinkCopyWith<$Res> {
  factory $CustomerHvcLinkCopyWith(
    CustomerHvcLink value,
    $Res Function(CustomerHvcLink) then,
  ) = _$CustomerHvcLinkCopyWithImpl<$Res, CustomerHvcLink>;
  @useResult
  $Res call({
    String id,
    String customerId,
    String hvcId,
    String relationshipType,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
    String? customerName,
    String? customerCode,
    String? hvcName,
    String? hvcCode,
  });
}

/// @nodoc
class _$CustomerHvcLinkCopyWithImpl<$Res, $Val extends CustomerHvcLink>
    implements $CustomerHvcLinkCopyWith<$Res> {
  _$CustomerHvcLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerHvcLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? hvcId = null,
    Object? relationshipType = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
    Object? customerName = freezed,
    Object? customerCode = freezed,
    Object? hvcName = freezed,
    Object? hvcCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
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
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerCode: freezed == customerCode
                ? _value.customerCode
                : customerCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            hvcName: freezed == hvcName
                ? _value.hvcName
                : hvcName // ignore: cast_nullable_to_non_nullable
                      as String?,
            hvcCode: freezed == hvcCode
                ? _value.hvcCode
                : hvcCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerHvcLinkImplCopyWith<$Res>
    implements $CustomerHvcLinkCopyWith<$Res> {
  factory _$$CustomerHvcLinkImplCopyWith(
    _$CustomerHvcLinkImpl value,
    $Res Function(_$CustomerHvcLinkImpl) then,
  ) = __$$CustomerHvcLinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerId,
    String hvcId,
    String relationshipType,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
    String? customerName,
    String? customerCode,
    String? hvcName,
    String? hvcCode,
  });
}

/// @nodoc
class __$$CustomerHvcLinkImplCopyWithImpl<$Res>
    extends _$CustomerHvcLinkCopyWithImpl<$Res, _$CustomerHvcLinkImpl>
    implements _$$CustomerHvcLinkImplCopyWith<$Res> {
  __$$CustomerHvcLinkImplCopyWithImpl(
    _$CustomerHvcLinkImpl _value,
    $Res Function(_$CustomerHvcLinkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerHvcLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? hvcId = null,
    Object? relationshipType = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
    Object? customerName = freezed,
    Object? customerCode = freezed,
    Object? hvcName = freezed,
    Object? hvcCode = freezed,
  }) {
    return _then(
      _$CustomerHvcLinkImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
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
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerCode: freezed == customerCode
            ? _value.customerCode
            : customerCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        hvcName: freezed == hvcName
            ? _value.hvcName
            : hvcName // ignore: cast_nullable_to_non_nullable
                  as String?,
        hvcCode: freezed == hvcCode
            ? _value.hvcCode
            : hvcCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerHvcLinkImpl extends _CustomerHvcLink {
  const _$CustomerHvcLinkImpl({
    required this.id,
    required this.customerId,
    required this.hvcId,
    required this.relationshipType,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isPendingSync = false,
    this.deletedAt,
    this.customerName,
    this.customerCode,
    this.hvcName,
    this.hvcCode,
  }) : super._();

  factory _$CustomerHvcLinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerHvcLinkImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String hvcId;
  @override
  final String relationshipType;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime? deletedAt;
  // Lookup fields
  @override
  final String? customerName;
  @override
  final String? customerCode;
  @override
  final String? hvcName;
  @override
  final String? hvcCode;

  @override
  String toString() {
    return 'CustomerHvcLink(id: $id, customerId: $customerId, hvcId: $hvcId, relationshipType: $relationshipType, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, isPendingSync: $isPendingSync, deletedAt: $deletedAt, customerName: $customerName, customerCode: $customerCode, hvcName: $hvcName, hvcCode: $hvcCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerHvcLinkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.relationshipType, relationshipType) ||
                other.relationshipType == relationshipType) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerCode, customerCode) ||
                other.customerCode == customerCode) &&
            (identical(other.hvcName, hvcName) || other.hvcName == hvcName) &&
            (identical(other.hvcCode, hvcCode) || other.hvcCode == hvcCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerId,
    hvcId,
    relationshipType,
    createdBy,
    createdAt,
    updatedAt,
    isActive,
    isPendingSync,
    deletedAt,
    customerName,
    customerCode,
    hvcName,
    hvcCode,
  );

  /// Create a copy of CustomerHvcLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerHvcLinkImplCopyWith<_$CustomerHvcLinkImpl> get copyWith =>
      __$$CustomerHvcLinkImplCopyWithImpl<_$CustomerHvcLinkImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerHvcLinkImplToJson(this);
  }
}

abstract class _CustomerHvcLink extends CustomerHvcLink {
  const factory _CustomerHvcLink({
    required final String id,
    required final String customerId,
    required final String hvcId,
    required final String relationshipType,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final bool isActive,
    final bool isPendingSync,
    final DateTime? deletedAt,
    final String? customerName,
    final String? customerCode,
    final String? hvcName,
    final String? hvcCode,
  }) = _$CustomerHvcLinkImpl;
  const _CustomerHvcLink._() : super._();

  factory _CustomerHvcLink.fromJson(Map<String, dynamic> json) =
      _$CustomerHvcLinkImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  String get hvcId;
  @override
  String get relationshipType;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isActive;
  @override
  bool get isPendingSync;
  @override
  DateTime? get deletedAt; // Lookup fields
  @override
  String? get customerName;
  @override
  String? get customerCode;
  @override
  String? get hvcName;
  @override
  String? get hvcCode;

  /// Create a copy of CustomerHvcLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerHvcLinkImplCopyWith<_$CustomerHvcLinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HvcWithDetails _$HvcWithDetailsFromJson(Map<String, dynamic> json) {
  return _HvcWithDetails.fromJson(json);
}

/// @nodoc
mixin _$HvcWithDetails {
  Hvc get hvc => throw _privateConstructorUsedError;
  List<CustomerHvcLink> get linkedCustomers =>
      throw _privateConstructorUsedError;
  int get keyPersonsCount => throw _privateConstructorUsedError;

  /// Serializes this HvcWithDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HvcWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvcWithDetailsCopyWith<HvcWithDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvcWithDetailsCopyWith<$Res> {
  factory $HvcWithDetailsCopyWith(
    HvcWithDetails value,
    $Res Function(HvcWithDetails) then,
  ) = _$HvcWithDetailsCopyWithImpl<$Res, HvcWithDetails>;
  @useResult
  $Res call({
    Hvc hvc,
    List<CustomerHvcLink> linkedCustomers,
    int keyPersonsCount,
  });

  $HvcCopyWith<$Res> get hvc;
}

/// @nodoc
class _$HvcWithDetailsCopyWithImpl<$Res, $Val extends HvcWithDetails>
    implements $HvcWithDetailsCopyWith<$Res> {
  _$HvcWithDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HvcWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hvc = null,
    Object? linkedCustomers = null,
    Object? keyPersonsCount = null,
  }) {
    return _then(
      _value.copyWith(
            hvc: null == hvc
                ? _value.hvc
                : hvc // ignore: cast_nullable_to_non_nullable
                      as Hvc,
            linkedCustomers: null == linkedCustomers
                ? _value.linkedCustomers
                : linkedCustomers // ignore: cast_nullable_to_non_nullable
                      as List<CustomerHvcLink>,
            keyPersonsCount: null == keyPersonsCount
                ? _value.keyPersonsCount
                : keyPersonsCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of HvcWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HvcCopyWith<$Res> get hvc {
    return $HvcCopyWith<$Res>(_value.hvc, (value) {
      return _then(_value.copyWith(hvc: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HvcWithDetailsImplCopyWith<$Res>
    implements $HvcWithDetailsCopyWith<$Res> {
  factory _$$HvcWithDetailsImplCopyWith(
    _$HvcWithDetailsImpl value,
    $Res Function(_$HvcWithDetailsImpl) then,
  ) = __$$HvcWithDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Hvc hvc,
    List<CustomerHvcLink> linkedCustomers,
    int keyPersonsCount,
  });

  @override
  $HvcCopyWith<$Res> get hvc;
}

/// @nodoc
class __$$HvcWithDetailsImplCopyWithImpl<$Res>
    extends _$HvcWithDetailsCopyWithImpl<$Res, _$HvcWithDetailsImpl>
    implements _$$HvcWithDetailsImplCopyWith<$Res> {
  __$$HvcWithDetailsImplCopyWithImpl(
    _$HvcWithDetailsImpl _value,
    $Res Function(_$HvcWithDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HvcWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hvc = null,
    Object? linkedCustomers = null,
    Object? keyPersonsCount = null,
  }) {
    return _then(
      _$HvcWithDetailsImpl(
        hvc: null == hvc
            ? _value.hvc
            : hvc // ignore: cast_nullable_to_non_nullable
                  as Hvc,
        linkedCustomers: null == linkedCustomers
            ? _value._linkedCustomers
            : linkedCustomers // ignore: cast_nullable_to_non_nullable
                  as List<CustomerHvcLink>,
        keyPersonsCount: null == keyPersonsCount
            ? _value.keyPersonsCount
            : keyPersonsCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HvcWithDetailsImpl extends _HvcWithDetails {
  const _$HvcWithDetailsImpl({
    required this.hvc,
    final List<CustomerHvcLink> linkedCustomers = const [],
    this.keyPersonsCount = 0,
  }) : _linkedCustomers = linkedCustomers,
       super._();

  factory _$HvcWithDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvcWithDetailsImplFromJson(json);

  @override
  final Hvc hvc;
  final List<CustomerHvcLink> _linkedCustomers;
  @override
  @JsonKey()
  List<CustomerHvcLink> get linkedCustomers {
    if (_linkedCustomers is EqualUnmodifiableListView) return _linkedCustomers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_linkedCustomers);
  }

  @override
  @JsonKey()
  final int keyPersonsCount;

  @override
  String toString() {
    return 'HvcWithDetails(hvc: $hvc, linkedCustomers: $linkedCustomers, keyPersonsCount: $keyPersonsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvcWithDetailsImpl &&
            (identical(other.hvc, hvc) || other.hvc == hvc) &&
            const DeepCollectionEquality().equals(
              other._linkedCustomers,
              _linkedCustomers,
            ) &&
            (identical(other.keyPersonsCount, keyPersonsCount) ||
                other.keyPersonsCount == keyPersonsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hvc,
    const DeepCollectionEquality().hash(_linkedCustomers),
    keyPersonsCount,
  );

  /// Create a copy of HvcWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvcWithDetailsImplCopyWith<_$HvcWithDetailsImpl> get copyWith =>
      __$$HvcWithDetailsImplCopyWithImpl<_$HvcWithDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HvcWithDetailsImplToJson(this);
  }
}

abstract class _HvcWithDetails extends HvcWithDetails {
  const factory _HvcWithDetails({
    required final Hvc hvc,
    final List<CustomerHvcLink> linkedCustomers,
    final int keyPersonsCount,
  }) = _$HvcWithDetailsImpl;
  const _HvcWithDetails._() : super._();

  factory _HvcWithDetails.fromJson(Map<String, dynamic> json) =
      _$HvcWithDetailsImpl.fromJson;

  @override
  Hvc get hvc;
  @override
  List<CustomerHvcLink> get linkedCustomers;
  @override
  int get keyPersonsCount;

  /// Create a copy of HvcWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvcWithDetailsImplCopyWith<_$HvcWithDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
