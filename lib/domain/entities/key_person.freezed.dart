// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KeyPerson _$KeyPersonFromJson(Map<String, dynamic> json) {
  return _KeyPerson.fromJson(json);
}

/// @nodoc
mixin _$KeyPerson {
  String get id => throw _privateConstructorUsedError;
  KeyPersonOwnerType get ownerType => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get hvcId => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  String? get department => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this KeyPerson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KeyPerson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyPersonCopyWith<KeyPerson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyPersonCopyWith<$Res> {
  factory $KeyPersonCopyWith(KeyPerson value, $Res Function(KeyPerson) then) =
      _$KeyPersonCopyWithImpl<$Res, KeyPerson>;
  @useResult
  $Res call({
    String id,
    KeyPersonOwnerType ownerType,
    String name,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? customerId,
    String? brokerId,
    String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    String? notes,
    bool isPrimary,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$KeyPersonCopyWithImpl<$Res, $Val extends KeyPerson>
    implements $KeyPersonCopyWith<$Res> {
  _$KeyPersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyPerson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerType = null,
    Object? name = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customerId = freezed,
    Object? brokerId = freezed,
    Object? hvcId = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? notes = freezed,
    Object? isPrimary = null,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerType: null == ownerType
                ? _value.ownerType
                : ownerType // ignore: cast_nullable_to_non_nullable
                      as KeyPersonOwnerType,
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
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeyPersonImplCopyWith<$Res>
    implements $KeyPersonCopyWith<$Res> {
  factory _$$KeyPersonImplCopyWith(
    _$KeyPersonImpl value,
    $Res Function(_$KeyPersonImpl) then,
  ) = __$$KeyPersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    KeyPersonOwnerType ownerType,
    String name,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? customerId,
    String? brokerId,
    String? hvcId,
    String? position,
    String? department,
    String? phone,
    String? email,
    String? notes,
    bool isPrimary,
    bool isActive,
    bool isPendingSync,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$KeyPersonImplCopyWithImpl<$Res>
    extends _$KeyPersonCopyWithImpl<$Res, _$KeyPersonImpl>
    implements _$$KeyPersonImplCopyWith<$Res> {
  __$$KeyPersonImplCopyWithImpl(
    _$KeyPersonImpl _value,
    $Res Function(_$KeyPersonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeyPerson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerType = null,
    Object? name = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customerId = freezed,
    Object? brokerId = freezed,
    Object? hvcId = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? notes = freezed,
    Object? isPrimary = null,
    Object? isActive = null,
    Object? isPendingSync = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$KeyPersonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerType: null == ownerType
            ? _value.ownerType
            : ownerType // ignore: cast_nullable_to_non_nullable
                  as KeyPersonOwnerType,
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
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KeyPersonImpl extends _KeyPerson {
  const _$KeyPersonImpl({
    required this.id,
    required this.ownerType,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.customerId,
    this.brokerId,
    this.hvcId,
    this.position,
    this.department,
    this.phone,
    this.email,
    this.notes,
    this.isPrimary = false,
    this.isActive = true,
    this.isPendingSync = false,
    this.deletedAt,
  }) : super._();

  factory _$KeyPersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeyPersonImplFromJson(json);

  @override
  final String id;
  @override
  final KeyPersonOwnerType ownerType;
  @override
  final String name;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
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
  final String? notes;
  @override
  @JsonKey()
  final bool isPrimary;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'KeyPerson(id: $id, ownerType: $ownerType, name: $name, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, customerId: $customerId, brokerId: $brokerId, hvcId: $hvcId, position: $position, department: $department, phone: $phone, email: $email, notes: $notes, isPrimary: $isPrimary, isActive: $isActive, isPendingSync: $isPendingSync, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyPersonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerType, ownerType) ||
                other.ownerType == ownerType) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
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
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ownerType,
    name,
    createdBy,
    createdAt,
    updatedAt,
    customerId,
    brokerId,
    hvcId,
    position,
    department,
    phone,
    email,
    notes,
    isPrimary,
    isActive,
    isPendingSync,
    deletedAt,
  );

  /// Create a copy of KeyPerson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyPersonImplCopyWith<_$KeyPersonImpl> get copyWith =>
      __$$KeyPersonImplCopyWithImpl<_$KeyPersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeyPersonImplToJson(this);
  }
}

abstract class _KeyPerson extends KeyPerson {
  const factory _KeyPerson({
    required final String id,
    required final KeyPersonOwnerType ownerType,
    required final String name,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? customerId,
    final String? brokerId,
    final String? hvcId,
    final String? position,
    final String? department,
    final String? phone,
    final String? email,
    final String? notes,
    final bool isPrimary,
    final bool isActive,
    final bool isPendingSync,
    final DateTime? deletedAt,
  }) = _$KeyPersonImpl;
  const _KeyPerson._() : super._();

  factory _KeyPerson.fromJson(Map<String, dynamic> json) =
      _$KeyPersonImpl.fromJson;

  @override
  String get id;
  @override
  KeyPersonOwnerType get ownerType;
  @override
  String get name;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
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
  String? get notes;
  @override
  bool get isPrimary;
  @override
  bool get isActive;
  @override
  bool get isPendingSync;
  @override
  DateTime? get deletedAt;

  /// Create a copy of KeyPerson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyPersonImplCopyWith<_$KeyPersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
