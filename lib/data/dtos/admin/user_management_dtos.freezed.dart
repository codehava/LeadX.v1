// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_management_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserCreateDto _$UserCreateDtoFromJson(Map<String, dynamic> json) {
  return _UserCreateDto.fromJson(json);
}

/// @nodoc
mixin _$UserCreateDto {
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nip => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get parentId =>
      throw _privateConstructorUsedError; // Supervisor user ID
  String? get branchId => throw _privateConstructorUsedError;
  String? get regionalOfficeId => throw _privateConstructorUsedError;

  /// Serializes this UserCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCreateDtoCopyWith<UserCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCreateDtoCopyWith<$Res> {
  factory $UserCreateDtoCopyWith(
    UserCreateDto value,
    $Res Function(UserCreateDto) then,
  ) = _$UserCreateDtoCopyWithImpl<$Res, UserCreateDto>;
  @useResult
  $Res call({
    String email,
    String name,
    String nip,
    UserRole role,
    String? phone,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
  });
}

/// @nodoc
class _$UserCreateDtoCopyWithImpl<$Res, $Val extends UserCreateDto>
    implements $UserCreateDtoCopyWith<$Res> {
  _$UserCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? name = null,
    Object? nip = null,
    Object? role = null,
    Object? phone = freezed,
    Object? parentId = freezed,
    Object? branchId = freezed,
    Object? regionalOfficeId = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            nip: null == nip
                ? _value.nip
                : nip // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            regionalOfficeId: freezed == regionalOfficeId
                ? _value.regionalOfficeId
                : regionalOfficeId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserCreateDtoImplCopyWith<$Res>
    implements $UserCreateDtoCopyWith<$Res> {
  factory _$$UserCreateDtoImplCopyWith(
    _$UserCreateDtoImpl value,
    $Res Function(_$UserCreateDtoImpl) then,
  ) = __$$UserCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String email,
    String name,
    String nip,
    UserRole role,
    String? phone,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
  });
}

/// @nodoc
class __$$UserCreateDtoImplCopyWithImpl<$Res>
    extends _$UserCreateDtoCopyWithImpl<$Res, _$UserCreateDtoImpl>
    implements _$$UserCreateDtoImplCopyWith<$Res> {
  __$$UserCreateDtoImplCopyWithImpl(
    _$UserCreateDtoImpl _value,
    $Res Function(_$UserCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? name = null,
    Object? nip = null,
    Object? role = null,
    Object? phone = freezed,
    Object? parentId = freezed,
    Object? branchId = freezed,
    Object? regionalOfficeId = freezed,
  }) {
    return _then(
      _$UserCreateDtoImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        nip: null == nip
            ? _value.nip
            : nip // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        regionalOfficeId: freezed == regionalOfficeId
            ? _value.regionalOfficeId
            : regionalOfficeId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserCreateDtoImpl implements _UserCreateDto {
  const _$UserCreateDtoImpl({
    required this.email,
    required this.name,
    required this.nip,
    required this.role,
    this.phone,
    this.parentId,
    this.branchId,
    this.regionalOfficeId,
  });

  factory _$UserCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserCreateDtoImplFromJson(json);

  @override
  final String email;
  @override
  final String name;
  @override
  final String nip;
  @override
  final UserRole role;
  @override
  final String? phone;
  @override
  final String? parentId;
  // Supervisor user ID
  @override
  final String? branchId;
  @override
  final String? regionalOfficeId;

  @override
  String toString() {
    return 'UserCreateDto(email: $email, name: $name, nip: $nip, role: $role, phone: $phone, parentId: $parentId, branchId: $branchId, regionalOfficeId: $regionalOfficeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserCreateDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nip, nip) || other.nip == nip) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.regionalOfficeId, regionalOfficeId) ||
                other.regionalOfficeId == regionalOfficeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    name,
    nip,
    role,
    phone,
    parentId,
    branchId,
    regionalOfficeId,
  );

  /// Create a copy of UserCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserCreateDtoImplCopyWith<_$UserCreateDtoImpl> get copyWith =>
      __$$UserCreateDtoImplCopyWithImpl<_$UserCreateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserCreateDtoImplToJson(this);
  }
}

abstract class _UserCreateDto implements UserCreateDto {
  const factory _UserCreateDto({
    required final String email,
    required final String name,
    required final String nip,
    required final UserRole role,
    final String? phone,
    final String? parentId,
    final String? branchId,
    final String? regionalOfficeId,
  }) = _$UserCreateDtoImpl;

  factory _UserCreateDto.fromJson(Map<String, dynamic> json) =
      _$UserCreateDtoImpl.fromJson;

  @override
  String get email;
  @override
  String get name;
  @override
  String get nip;
  @override
  UserRole get role;
  @override
  String? get phone;
  @override
  String? get parentId; // Supervisor user ID
  @override
  String? get branchId;
  @override
  String? get regionalOfficeId;

  /// Create a copy of UserCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserCreateDtoImplCopyWith<_$UserCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserUpdateDto _$UserUpdateDtoFromJson(Map<String, dynamic> json) {
  return _UserUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$UserUpdateDto {
  String? get name => throw _privateConstructorUsedError;
  String? get nip => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  UserRole? get role => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get branchId => throw _privateConstructorUsedError;
  String? get regionalOfficeId => throw _privateConstructorUsedError;

  /// Serializes this UserUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserUpdateDtoCopyWith<UserUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserUpdateDtoCopyWith<$Res> {
  factory $UserUpdateDtoCopyWith(
    UserUpdateDto value,
    $Res Function(UserUpdateDto) then,
  ) = _$UserUpdateDtoCopyWithImpl<$Res, UserUpdateDto>;
  @useResult
  $Res call({
    String? name,
    String? nip,
    String? phone,
    UserRole? role,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
  });
}

/// @nodoc
class _$UserUpdateDtoCopyWithImpl<$Res, $Val extends UserUpdateDto>
    implements $UserUpdateDtoCopyWith<$Res> {
  _$UserUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? nip = freezed,
    Object? phone = freezed,
    Object? role = freezed,
    Object? parentId = freezed,
    Object? branchId = freezed,
    Object? regionalOfficeId = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            nip: freezed == nip
                ? _value.nip
                : nip // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            regionalOfficeId: freezed == regionalOfficeId
                ? _value.regionalOfficeId
                : regionalOfficeId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserUpdateDtoImplCopyWith<$Res>
    implements $UserUpdateDtoCopyWith<$Res> {
  factory _$$UserUpdateDtoImplCopyWith(
    _$UserUpdateDtoImpl value,
    $Res Function(_$UserUpdateDtoImpl) then,
  ) = __$$UserUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? nip,
    String? phone,
    UserRole? role,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
  });
}

/// @nodoc
class __$$UserUpdateDtoImplCopyWithImpl<$Res>
    extends _$UserUpdateDtoCopyWithImpl<$Res, _$UserUpdateDtoImpl>
    implements _$$UserUpdateDtoImplCopyWith<$Res> {
  __$$UserUpdateDtoImplCopyWithImpl(
    _$UserUpdateDtoImpl _value,
    $Res Function(_$UserUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? nip = freezed,
    Object? phone = freezed,
    Object? role = freezed,
    Object? parentId = freezed,
    Object? branchId = freezed,
    Object? regionalOfficeId = freezed,
  }) {
    return _then(
      _$UserUpdateDtoImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        nip: freezed == nip
            ? _value.nip
            : nip // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        regionalOfficeId: freezed == regionalOfficeId
            ? _value.regionalOfficeId
            : regionalOfficeId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserUpdateDtoImpl implements _UserUpdateDto {
  const _$UserUpdateDtoImpl({
    this.name,
    this.nip,
    this.phone,
    this.role,
    this.parentId,
    this.branchId,
    this.regionalOfficeId,
  });

  factory _$UserUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserUpdateDtoImplFromJson(json);

  @override
  final String? name;
  @override
  final String? nip;
  @override
  final String? phone;
  @override
  final UserRole? role;
  @override
  final String? parentId;
  @override
  final String? branchId;
  @override
  final String? regionalOfficeId;

  @override
  String toString() {
    return 'UserUpdateDto(name: $name, nip: $nip, phone: $phone, role: $role, parentId: $parentId, branchId: $branchId, regionalOfficeId: $regionalOfficeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserUpdateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nip, nip) || other.nip == nip) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.regionalOfficeId, regionalOfficeId) ||
                other.regionalOfficeId == regionalOfficeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    nip,
    phone,
    role,
    parentId,
    branchId,
    regionalOfficeId,
  );

  /// Create a copy of UserUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserUpdateDtoImplCopyWith<_$UserUpdateDtoImpl> get copyWith =>
      __$$UserUpdateDtoImplCopyWithImpl<_$UserUpdateDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserUpdateDtoImplToJson(this);
  }
}

abstract class _UserUpdateDto implements UserUpdateDto {
  const factory _UserUpdateDto({
    final String? name,
    final String? nip,
    final String? phone,
    final UserRole? role,
    final String? parentId,
    final String? branchId,
    final String? regionalOfficeId,
  }) = _$UserUpdateDtoImpl;

  factory _UserUpdateDto.fromJson(Map<String, dynamic> json) =
      _$UserUpdateDtoImpl.fromJson;

  @override
  String? get name;
  @override
  String? get nip;
  @override
  String? get phone;
  @override
  UserRole? get role;
  @override
  String? get parentId;
  @override
  String? get branchId;
  @override
  String? get regionalOfficeId;

  /// Create a copy of UserUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserUpdateDtoImplCopyWith<_$UserUpdateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserCreateResult _$UserCreateResultFromJson(Map<String, dynamic> json) {
  return _UserCreateResult.fromJson(json);
}

/// @nodoc
mixin _$UserCreateResult {
  User get user => throw _privateConstructorUsedError;
  String get temporaryPassword => throw _privateConstructorUsedError;

  /// Serializes this UserCreateResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCreateResultCopyWith<UserCreateResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCreateResultCopyWith<$Res> {
  factory $UserCreateResultCopyWith(
    UserCreateResult value,
    $Res Function(UserCreateResult) then,
  ) = _$UserCreateResultCopyWithImpl<$Res, UserCreateResult>;
  @useResult
  $Res call({User user, String temporaryPassword});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$UserCreateResultCopyWithImpl<$Res, $Val extends UserCreateResult>
    implements $UserCreateResultCopyWith<$Res> {
  _$UserCreateResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? temporaryPassword = null}) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            temporaryPassword: null == temporaryPassword
                ? _value.temporaryPassword
                : temporaryPassword // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of UserCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserCreateResultImplCopyWith<$Res>
    implements $UserCreateResultCopyWith<$Res> {
  factory _$$UserCreateResultImplCopyWith(
    _$UserCreateResultImpl value,
    $Res Function(_$UserCreateResultImpl) then,
  ) = __$$UserCreateResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({User user, String temporaryPassword});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$UserCreateResultImplCopyWithImpl<$Res>
    extends _$UserCreateResultCopyWithImpl<$Res, _$UserCreateResultImpl>
    implements _$$UserCreateResultImplCopyWith<$Res> {
  __$$UserCreateResultImplCopyWithImpl(
    _$UserCreateResultImpl _value,
    $Res Function(_$UserCreateResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = null, Object? temporaryPassword = null}) {
    return _then(
      _$UserCreateResultImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        temporaryPassword: null == temporaryPassword
            ? _value.temporaryPassword
            : temporaryPassword // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserCreateResultImpl implements _UserCreateResult {
  const _$UserCreateResultImpl({
    required this.user,
    required this.temporaryPassword,
  });

  factory _$UserCreateResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserCreateResultImplFromJson(json);

  @override
  final User user;
  @override
  final String temporaryPassword;

  @override
  String toString() {
    return 'UserCreateResult(user: $user, temporaryPassword: $temporaryPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserCreateResultImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.temporaryPassword, temporaryPassword) ||
                other.temporaryPassword == temporaryPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user, temporaryPassword);

  /// Create a copy of UserCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserCreateResultImplCopyWith<_$UserCreateResultImpl> get copyWith =>
      __$$UserCreateResultImplCopyWithImpl<_$UserCreateResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserCreateResultImplToJson(this);
  }
}

abstract class _UserCreateResult implements UserCreateResult {
  const factory _UserCreateResult({
    required final User user,
    required final String temporaryPassword,
  }) = _$UserCreateResultImpl;

  factory _UserCreateResult.fromJson(Map<String, dynamic> json) =
      _$UserCreateResultImpl.fromJson;

  @override
  User get user;
  @override
  String get temporaryPassword;

  /// Create a copy of UserCreateResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserCreateResultImplCopyWith<_$UserCreateResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
