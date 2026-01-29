// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline_referral_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PipelineReferralCreateDto _$PipelineReferralCreateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralCreateDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralCreateDto {
  String get customerId => throw _privateConstructorUsedError;
  String get receiverRmId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralCreateDtoCopyWith<PipelineReferralCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralCreateDtoCopyWith<$Res> {
  factory $PipelineReferralCreateDtoCopyWith(
    PipelineReferralCreateDto value,
    $Res Function(PipelineReferralCreateDto) then,
  ) = _$PipelineReferralCreateDtoCopyWithImpl<$Res, PipelineReferralCreateDto>;
  @useResult
  $Res call({
    String customerId,
    String receiverRmId,
    String reason,
    String? notes,
  });
}

/// @nodoc
class _$PipelineReferralCreateDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralCreateDto
>
    implements $PipelineReferralCreateDtoCopyWith<$Res> {
  _$PipelineReferralCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? receiverRmId = null,
    Object? reason = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverRmId: null == receiverRmId
                ? _value.receiverRmId
                : receiverRmId // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PipelineReferralCreateDtoImplCopyWith<$Res>
    implements $PipelineReferralCreateDtoCopyWith<$Res> {
  factory _$$PipelineReferralCreateDtoImplCopyWith(
    _$PipelineReferralCreateDtoImpl value,
    $Res Function(_$PipelineReferralCreateDtoImpl) then,
  ) = __$$PipelineReferralCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customerId,
    String receiverRmId,
    String reason,
    String? notes,
  });
}

/// @nodoc
class __$$PipelineReferralCreateDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralCreateDtoCopyWithImpl<
          $Res,
          _$PipelineReferralCreateDtoImpl
        >
    implements _$$PipelineReferralCreateDtoImplCopyWith<$Res> {
  __$$PipelineReferralCreateDtoImplCopyWithImpl(
    _$PipelineReferralCreateDtoImpl _value,
    $Res Function(_$PipelineReferralCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? receiverRmId = null,
    Object? reason = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$PipelineReferralCreateDtoImpl(
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverRmId: null == receiverRmId
            ? _value.receiverRmId
            : receiverRmId // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
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
class _$PipelineReferralCreateDtoImpl implements _PipelineReferralCreateDto {
  const _$PipelineReferralCreateDtoImpl({
    required this.customerId,
    required this.receiverRmId,
    required this.reason,
    this.notes,
  });

  factory _$PipelineReferralCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineReferralCreateDtoImplFromJson(json);

  @override
  final String customerId;
  @override
  final String receiverRmId;
  @override
  final String reason;
  @override
  final String? notes;

  @override
  String toString() {
    return 'PipelineReferralCreateDto(customerId: $customerId, receiverRmId: $receiverRmId, reason: $reason, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralCreateDtoImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.receiverRmId, receiverRmId) ||
                other.receiverRmId == receiverRmId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, customerId, receiverRmId, reason, notes);

  /// Create a copy of PipelineReferralCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralCreateDtoImplCopyWith<_$PipelineReferralCreateDtoImpl>
  get copyWith =>
      __$$PipelineReferralCreateDtoImplCopyWithImpl<
        _$PipelineReferralCreateDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralCreateDtoImplToJson(this);
  }
}

abstract class _PipelineReferralCreateDto implements PipelineReferralCreateDto {
  const factory _PipelineReferralCreateDto({
    required final String customerId,
    required final String receiverRmId,
    required final String reason,
    final String? notes,
  }) = _$PipelineReferralCreateDtoImpl;

  factory _PipelineReferralCreateDto.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralCreateDtoImpl.fromJson;

  @override
  String get customerId;
  @override
  String get receiverRmId;
  @override
  String get reason;
  @override
  String? get notes;

  /// Create a copy of PipelineReferralCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralCreateDtoImplCopyWith<_$PipelineReferralCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineReferralAcceptDto _$PipelineReferralAcceptDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralAcceptDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralAcceptDto {
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralAcceptDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralAcceptDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralAcceptDtoCopyWith<PipelineReferralAcceptDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralAcceptDtoCopyWith<$Res> {
  factory $PipelineReferralAcceptDtoCopyWith(
    PipelineReferralAcceptDto value,
    $Res Function(PipelineReferralAcceptDto) then,
  ) = _$PipelineReferralAcceptDtoCopyWithImpl<$Res, PipelineReferralAcceptDto>;
  @useResult
  $Res call({String? notes});
}

/// @nodoc
class _$PipelineReferralAcceptDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralAcceptDto
>
    implements $PipelineReferralAcceptDtoCopyWith<$Res> {
  _$PipelineReferralAcceptDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralAcceptDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? notes = freezed}) {
    return _then(
      _value.copyWith(
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
abstract class _$$PipelineReferralAcceptDtoImplCopyWith<$Res>
    implements $PipelineReferralAcceptDtoCopyWith<$Res> {
  factory _$$PipelineReferralAcceptDtoImplCopyWith(
    _$PipelineReferralAcceptDtoImpl value,
    $Res Function(_$PipelineReferralAcceptDtoImpl) then,
  ) = __$$PipelineReferralAcceptDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? notes});
}

/// @nodoc
class __$$PipelineReferralAcceptDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralAcceptDtoCopyWithImpl<
          $Res,
          _$PipelineReferralAcceptDtoImpl
        >
    implements _$$PipelineReferralAcceptDtoImplCopyWith<$Res> {
  __$$PipelineReferralAcceptDtoImplCopyWithImpl(
    _$PipelineReferralAcceptDtoImpl _value,
    $Res Function(_$PipelineReferralAcceptDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralAcceptDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? notes = freezed}) {
    return _then(
      _$PipelineReferralAcceptDtoImpl(
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
class _$PipelineReferralAcceptDtoImpl implements _PipelineReferralAcceptDto {
  const _$PipelineReferralAcceptDtoImpl({this.notes});

  factory _$PipelineReferralAcceptDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineReferralAcceptDtoImplFromJson(json);

  @override
  final String? notes;

  @override
  String toString() {
    return 'PipelineReferralAcceptDto(notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralAcceptDtoImpl &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, notes);

  /// Create a copy of PipelineReferralAcceptDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralAcceptDtoImplCopyWith<_$PipelineReferralAcceptDtoImpl>
  get copyWith =>
      __$$PipelineReferralAcceptDtoImplCopyWithImpl<
        _$PipelineReferralAcceptDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralAcceptDtoImplToJson(this);
  }
}

abstract class _PipelineReferralAcceptDto implements PipelineReferralAcceptDto {
  const factory _PipelineReferralAcceptDto({final String? notes}) =
      _$PipelineReferralAcceptDtoImpl;

  factory _PipelineReferralAcceptDto.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralAcceptDtoImpl.fromJson;

  @override
  String? get notes;

  /// Create a copy of PipelineReferralAcceptDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralAcceptDtoImplCopyWith<_$PipelineReferralAcceptDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineReferralRejectDto _$PipelineReferralRejectDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralRejectDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralRejectDto {
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralRejectDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralRejectDtoCopyWith<PipelineReferralRejectDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralRejectDtoCopyWith<$Res> {
  factory $PipelineReferralRejectDtoCopyWith(
    PipelineReferralRejectDto value,
    $Res Function(PipelineReferralRejectDto) then,
  ) = _$PipelineReferralRejectDtoCopyWithImpl<$Res, PipelineReferralRejectDto>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class _$PipelineReferralRejectDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralRejectDto
>
    implements $PipelineReferralRejectDtoCopyWith<$Res> {
  _$PipelineReferralRejectDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _value.copyWith(
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineReferralRejectDtoImplCopyWith<$Res>
    implements $PipelineReferralRejectDtoCopyWith<$Res> {
  factory _$$PipelineReferralRejectDtoImplCopyWith(
    _$PipelineReferralRejectDtoImpl value,
    $Res Function(_$PipelineReferralRejectDtoImpl) then,
  ) = __$$PipelineReferralRejectDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$PipelineReferralRejectDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralRejectDtoCopyWithImpl<
          $Res,
          _$PipelineReferralRejectDtoImpl
        >
    implements _$$PipelineReferralRejectDtoImplCopyWith<$Res> {
  __$$PipelineReferralRejectDtoImplCopyWithImpl(
    _$PipelineReferralRejectDtoImpl _value,
    $Res Function(_$PipelineReferralRejectDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$PipelineReferralRejectDtoImpl(
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineReferralRejectDtoImpl implements _PipelineReferralRejectDto {
  const _$PipelineReferralRejectDtoImpl({required this.reason});

  factory _$PipelineReferralRejectDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineReferralRejectDtoImplFromJson(json);

  @override
  final String reason;

  @override
  String toString() {
    return 'PipelineReferralRejectDto(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralRejectDtoImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of PipelineReferralRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralRejectDtoImplCopyWith<_$PipelineReferralRejectDtoImpl>
  get copyWith =>
      __$$PipelineReferralRejectDtoImplCopyWithImpl<
        _$PipelineReferralRejectDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralRejectDtoImplToJson(this);
  }
}

abstract class _PipelineReferralRejectDto implements PipelineReferralRejectDto {
  const factory _PipelineReferralRejectDto({required final String reason}) =
      _$PipelineReferralRejectDtoImpl;

  factory _PipelineReferralRejectDto.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralRejectDtoImpl.fromJson;

  @override
  String get reason;

  /// Create a copy of PipelineReferralRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralRejectDtoImplCopyWith<_$PipelineReferralRejectDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineReferralApprovalDto _$PipelineReferralApprovalDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralApprovalDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralApprovalDto {
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralApprovalDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralApprovalDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralApprovalDtoCopyWith<PipelineReferralApprovalDto>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralApprovalDtoCopyWith<$Res> {
  factory $PipelineReferralApprovalDtoCopyWith(
    PipelineReferralApprovalDto value,
    $Res Function(PipelineReferralApprovalDto) then,
  ) =
      _$PipelineReferralApprovalDtoCopyWithImpl<
        $Res,
        PipelineReferralApprovalDto
      >;
  @useResult
  $Res call({String? notes});
}

/// @nodoc
class _$PipelineReferralApprovalDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralApprovalDto
>
    implements $PipelineReferralApprovalDtoCopyWith<$Res> {
  _$PipelineReferralApprovalDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralApprovalDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? notes = freezed}) {
    return _then(
      _value.copyWith(
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
abstract class _$$PipelineReferralApprovalDtoImplCopyWith<$Res>
    implements $PipelineReferralApprovalDtoCopyWith<$Res> {
  factory _$$PipelineReferralApprovalDtoImplCopyWith(
    _$PipelineReferralApprovalDtoImpl value,
    $Res Function(_$PipelineReferralApprovalDtoImpl) then,
  ) = __$$PipelineReferralApprovalDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? notes});
}

/// @nodoc
class __$$PipelineReferralApprovalDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralApprovalDtoCopyWithImpl<
          $Res,
          _$PipelineReferralApprovalDtoImpl
        >
    implements _$$PipelineReferralApprovalDtoImplCopyWith<$Res> {
  __$$PipelineReferralApprovalDtoImplCopyWithImpl(
    _$PipelineReferralApprovalDtoImpl _value,
    $Res Function(_$PipelineReferralApprovalDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralApprovalDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? notes = freezed}) {
    return _then(
      _$PipelineReferralApprovalDtoImpl(
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
class _$PipelineReferralApprovalDtoImpl
    implements _PipelineReferralApprovalDto {
  const _$PipelineReferralApprovalDtoImpl({this.notes});

  factory _$PipelineReferralApprovalDtoImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PipelineReferralApprovalDtoImplFromJson(json);

  @override
  final String? notes;

  @override
  String toString() {
    return 'PipelineReferralApprovalDto(notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralApprovalDtoImpl &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, notes);

  /// Create a copy of PipelineReferralApprovalDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralApprovalDtoImplCopyWith<_$PipelineReferralApprovalDtoImpl>
  get copyWith =>
      __$$PipelineReferralApprovalDtoImplCopyWithImpl<
        _$PipelineReferralApprovalDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralApprovalDtoImplToJson(this);
  }
}

abstract class _PipelineReferralApprovalDto
    implements PipelineReferralApprovalDto {
  const factory _PipelineReferralApprovalDto({final String? notes}) =
      _$PipelineReferralApprovalDtoImpl;

  factory _PipelineReferralApprovalDto.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralApprovalDtoImpl.fromJson;

  @override
  String? get notes;

  /// Create a copy of PipelineReferralApprovalDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralApprovalDtoImplCopyWith<_$PipelineReferralApprovalDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineReferralManagerRejectDto _$PipelineReferralManagerRejectDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralManagerRejectDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralManagerRejectDto {
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralManagerRejectDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralManagerRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralManagerRejectDtoCopyWith<PipelineReferralManagerRejectDto>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralManagerRejectDtoCopyWith<$Res> {
  factory $PipelineReferralManagerRejectDtoCopyWith(
    PipelineReferralManagerRejectDto value,
    $Res Function(PipelineReferralManagerRejectDto) then,
  ) =
      _$PipelineReferralManagerRejectDtoCopyWithImpl<
        $Res,
        PipelineReferralManagerRejectDto
      >;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class _$PipelineReferralManagerRejectDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralManagerRejectDto
>
    implements $PipelineReferralManagerRejectDtoCopyWith<$Res> {
  _$PipelineReferralManagerRejectDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralManagerRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _value.copyWith(
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineReferralManagerRejectDtoImplCopyWith<$Res>
    implements $PipelineReferralManagerRejectDtoCopyWith<$Res> {
  factory _$$PipelineReferralManagerRejectDtoImplCopyWith(
    _$PipelineReferralManagerRejectDtoImpl value,
    $Res Function(_$PipelineReferralManagerRejectDtoImpl) then,
  ) = __$$PipelineReferralManagerRejectDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$PipelineReferralManagerRejectDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralManagerRejectDtoCopyWithImpl<
          $Res,
          _$PipelineReferralManagerRejectDtoImpl
        >
    implements _$$PipelineReferralManagerRejectDtoImplCopyWith<$Res> {
  __$$PipelineReferralManagerRejectDtoImplCopyWithImpl(
    _$PipelineReferralManagerRejectDtoImpl _value,
    $Res Function(_$PipelineReferralManagerRejectDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralManagerRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$PipelineReferralManagerRejectDtoImpl(
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineReferralManagerRejectDtoImpl
    implements _PipelineReferralManagerRejectDto {
  const _$PipelineReferralManagerRejectDtoImpl({required this.reason});

  factory _$PipelineReferralManagerRejectDtoImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PipelineReferralManagerRejectDtoImplFromJson(json);

  @override
  final String reason;

  @override
  String toString() {
    return 'PipelineReferralManagerRejectDto(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralManagerRejectDtoImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of PipelineReferralManagerRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralManagerRejectDtoImplCopyWith<
    _$PipelineReferralManagerRejectDtoImpl
  >
  get copyWith =>
      __$$PipelineReferralManagerRejectDtoImplCopyWithImpl<
        _$PipelineReferralManagerRejectDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralManagerRejectDtoImplToJson(this);
  }
}

abstract class _PipelineReferralManagerRejectDto
    implements PipelineReferralManagerRejectDto {
  const factory _PipelineReferralManagerRejectDto({
    required final String reason,
  }) = _$PipelineReferralManagerRejectDtoImpl;

  factory _PipelineReferralManagerRejectDto.fromJson(
    Map<String, dynamic> json,
  ) = _$PipelineReferralManagerRejectDtoImpl.fromJson;

  @override
  String get reason;

  /// Create a copy of PipelineReferralManagerRejectDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralManagerRejectDtoImplCopyWith<
    _$PipelineReferralManagerRejectDtoImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

PipelineReferralCancelDto _$PipelineReferralCancelDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralCancelDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralCancelDto {
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralCancelDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralCancelDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralCancelDtoCopyWith<PipelineReferralCancelDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralCancelDtoCopyWith<$Res> {
  factory $PipelineReferralCancelDtoCopyWith(
    PipelineReferralCancelDto value,
    $Res Function(PipelineReferralCancelDto) then,
  ) = _$PipelineReferralCancelDtoCopyWithImpl<$Res, PipelineReferralCancelDto>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class _$PipelineReferralCancelDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralCancelDto
>
    implements $PipelineReferralCancelDtoCopyWith<$Res> {
  _$PipelineReferralCancelDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralCancelDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _value.copyWith(
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineReferralCancelDtoImplCopyWith<$Res>
    implements $PipelineReferralCancelDtoCopyWith<$Res> {
  factory _$$PipelineReferralCancelDtoImplCopyWith(
    _$PipelineReferralCancelDtoImpl value,
    $Res Function(_$PipelineReferralCancelDtoImpl) then,
  ) = __$$PipelineReferralCancelDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$PipelineReferralCancelDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralCancelDtoCopyWithImpl<
          $Res,
          _$PipelineReferralCancelDtoImpl
        >
    implements _$$PipelineReferralCancelDtoImplCopyWith<$Res> {
  __$$PipelineReferralCancelDtoImplCopyWithImpl(
    _$PipelineReferralCancelDtoImpl _value,
    $Res Function(_$PipelineReferralCancelDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralCancelDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$PipelineReferralCancelDtoImpl(
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineReferralCancelDtoImpl implements _PipelineReferralCancelDto {
  const _$PipelineReferralCancelDtoImpl({required this.reason});

  factory _$PipelineReferralCancelDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineReferralCancelDtoImplFromJson(json);

  @override
  final String reason;

  @override
  String toString() {
    return 'PipelineReferralCancelDto(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralCancelDtoImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of PipelineReferralCancelDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralCancelDtoImplCopyWith<_$PipelineReferralCancelDtoImpl>
  get copyWith =>
      __$$PipelineReferralCancelDtoImplCopyWithImpl<
        _$PipelineReferralCancelDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralCancelDtoImplToJson(this);
  }
}

abstract class _PipelineReferralCancelDto implements PipelineReferralCancelDto {
  const factory _PipelineReferralCancelDto({required final String reason}) =
      _$PipelineReferralCancelDtoImpl;

  factory _PipelineReferralCancelDto.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralCancelDtoImpl.fromJson;

  @override
  String get reason;

  /// Create a copy of PipelineReferralCancelDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralCancelDtoImplCopyWith<_$PipelineReferralCancelDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineReferralSyncDto _$PipelineReferralSyncDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineReferralSyncDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferralSyncDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError; // Customer Info
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError; // Parties
  @JsonKey(name: 'referrer_rm_id')
  String get referrerRmId => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_rm_id')
  String get receiverRmId => throw _privateConstructorUsedError; // Branch IDs (nullable for kanwil-level RMs)
  @JsonKey(name: 'referrer_branch_id')
  String? get referrerBranchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_branch_id')
  String? get receiverBranchId => throw _privateConstructorUsedError; // Regional Office IDs
  @JsonKey(name: 'referrer_regional_office_id')
  String? get referrerRegionalOfficeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_regional_office_id')
  String? get receiverRegionalOfficeId => throw _privateConstructorUsedError; // Approver Type
  @JsonKey(name: 'approver_type')
  String get approverType => throw _privateConstructorUsedError; // Referral Details
  String get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError; // Status
  String get status => throw _privateConstructorUsedError; // Receiver Response
  @JsonKey(name: 'receiver_accepted_at')
  DateTime? get receiverAcceptedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_rejected_at')
  DateTime? get receiverRejectedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_reject_reason')
  String? get receiverRejectReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_notes')
  String? get receiverNotes => throw _privateConstructorUsedError; // Manager Approval
  @JsonKey(name: 'bm_approved_at')
  DateTime? get bmApprovedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'bm_approved_by')
  String? get bmApprovedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'bm_rejected_at')
  DateTime? get bmRejectedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'bm_reject_reason')
  String? get bmRejectReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'bm_notes')
  String? get bmNotes => throw _privateConstructorUsedError; // Result
  @JsonKey(name: 'bonus_calculated')
  bool get bonusCalculated => throw _privateConstructorUsedError;
  @JsonKey(name: 'bonus_amount')
  double? get bonusAmount => throw _privateConstructorUsedError; // Timestamps
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancel_reason')
  String? get cancelReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferralSyncDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferralSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralSyncDtoCopyWith<PipelineReferralSyncDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralSyncDtoCopyWith<$Res> {
  factory $PipelineReferralSyncDtoCopyWith(
    PipelineReferralSyncDto value,
    $Res Function(PipelineReferralSyncDto) then,
  ) = _$PipelineReferralSyncDtoCopyWithImpl<$Res, PipelineReferralSyncDto>;
  @useResult
  $Res call({
    String id,
    String code,
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'referrer_rm_id') String referrerRmId,
    @JsonKey(name: 'receiver_rm_id') String receiverRmId,
    @JsonKey(name: 'referrer_branch_id') String? referrerBranchId,
    @JsonKey(name: 'receiver_branch_id') String? receiverBranchId,
    @JsonKey(name: 'referrer_regional_office_id')
    String? referrerRegionalOfficeId,
    @JsonKey(name: 'receiver_regional_office_id')
    String? receiverRegionalOfficeId,
    @JsonKey(name: 'approver_type') String approverType,
    String reason,
    String? notes,
    String status,
    @JsonKey(name: 'receiver_accepted_at') DateTime? receiverAcceptedAt,
    @JsonKey(name: 'receiver_rejected_at') DateTime? receiverRejectedAt,
    @JsonKey(name: 'receiver_reject_reason') String? receiverRejectReason,
    @JsonKey(name: 'receiver_notes') String? receiverNotes,
    @JsonKey(name: 'bm_approved_at') DateTime? bmApprovedAt,
    @JsonKey(name: 'bm_approved_by') String? bmApprovedBy,
    @JsonKey(name: 'bm_rejected_at') DateTime? bmRejectedAt,
    @JsonKey(name: 'bm_reject_reason') String? bmRejectReason,
    @JsonKey(name: 'bm_notes') String? bmNotes,
    @JsonKey(name: 'bonus_calculated') bool bonusCalculated,
    @JsonKey(name: 'bonus_amount') double? bonusAmount,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$PipelineReferralSyncDtoCopyWithImpl<
  $Res,
  $Val extends PipelineReferralSyncDto
>
    implements $PipelineReferralSyncDtoCopyWith<$Res> {
  _$PipelineReferralSyncDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferralSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? customerId = null,
    Object? referrerRmId = null,
    Object? receiverRmId = null,
    Object? referrerBranchId = freezed,
    Object? receiverBranchId = freezed,
    Object? referrerRegionalOfficeId = freezed,
    Object? receiverRegionalOfficeId = freezed,
    Object? approverType = null,
    Object? reason = null,
    Object? notes = freezed,
    Object? status = null,
    Object? receiverAcceptedAt = freezed,
    Object? receiverRejectedAt = freezed,
    Object? receiverRejectReason = freezed,
    Object? receiverNotes = freezed,
    Object? bmApprovedAt = freezed,
    Object? bmApprovedBy = freezed,
    Object? bmRejectedAt = freezed,
    Object? bmRejectReason = freezed,
    Object? bmNotes = freezed,
    Object? bonusCalculated = null,
    Object? bonusAmount = freezed,
    Object? expiresAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancelReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            referrerRmId: null == referrerRmId
                ? _value.referrerRmId
                : referrerRmId // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverRmId: null == receiverRmId
                ? _value.receiverRmId
                : receiverRmId // ignore: cast_nullable_to_non_nullable
                      as String,
            referrerBranchId: freezed == referrerBranchId
                ? _value.referrerBranchId
                : referrerBranchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiverBranchId: freezed == receiverBranchId
                ? _value.receiverBranchId
                : receiverBranchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            referrerRegionalOfficeId: freezed == referrerRegionalOfficeId
                ? _value.referrerRegionalOfficeId
                : referrerRegionalOfficeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiverRegionalOfficeId: freezed == receiverRegionalOfficeId
                ? _value.receiverRegionalOfficeId
                : receiverRegionalOfficeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            approverType: null == approverType
                ? _value.approverType
                : approverType // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverAcceptedAt: freezed == receiverAcceptedAt
                ? _value.receiverAcceptedAt
                : receiverAcceptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            receiverRejectedAt: freezed == receiverRejectedAt
                ? _value.receiverRejectedAt
                : receiverRejectedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            receiverRejectReason: freezed == receiverRejectReason
                ? _value.receiverRejectReason
                : receiverRejectReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiverNotes: freezed == receiverNotes
                ? _value.receiverNotes
                : receiverNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            bmApprovedAt: freezed == bmApprovedAt
                ? _value.bmApprovedAt
                : bmApprovedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            bmApprovedBy: freezed == bmApprovedBy
                ? _value.bmApprovedBy
                : bmApprovedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            bmRejectedAt: freezed == bmRejectedAt
                ? _value.bmRejectedAt
                : bmRejectedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            bmRejectReason: freezed == bmRejectReason
                ? _value.bmRejectReason
                : bmRejectReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            bmNotes: freezed == bmNotes
                ? _value.bmNotes
                : bmNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            bonusCalculated: null == bonusCalculated
                ? _value.bonusCalculated
                : bonusCalculated // ignore: cast_nullable_to_non_nullable
                      as bool,
            bonusAmount: freezed == bonusAmount
                ? _value.bonusAmount
                : bonusAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelReason: freezed == cancelReason
                ? _value.cancelReason
                : cancelReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineReferralSyncDtoImplCopyWith<$Res>
    implements $PipelineReferralSyncDtoCopyWith<$Res> {
  factory _$$PipelineReferralSyncDtoImplCopyWith(
    _$PipelineReferralSyncDtoImpl value,
    $Res Function(_$PipelineReferralSyncDtoImpl) then,
  ) = __$$PipelineReferralSyncDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'referrer_rm_id') String referrerRmId,
    @JsonKey(name: 'receiver_rm_id') String receiverRmId,
    @JsonKey(name: 'referrer_branch_id') String? referrerBranchId,
    @JsonKey(name: 'receiver_branch_id') String? receiverBranchId,
    @JsonKey(name: 'referrer_regional_office_id')
    String? referrerRegionalOfficeId,
    @JsonKey(name: 'receiver_regional_office_id')
    String? receiverRegionalOfficeId,
    @JsonKey(name: 'approver_type') String approverType,
    String reason,
    String? notes,
    String status,
    @JsonKey(name: 'receiver_accepted_at') DateTime? receiverAcceptedAt,
    @JsonKey(name: 'receiver_rejected_at') DateTime? receiverRejectedAt,
    @JsonKey(name: 'receiver_reject_reason') String? receiverRejectReason,
    @JsonKey(name: 'receiver_notes') String? receiverNotes,
    @JsonKey(name: 'bm_approved_at') DateTime? bmApprovedAt,
    @JsonKey(name: 'bm_approved_by') String? bmApprovedBy,
    @JsonKey(name: 'bm_rejected_at') DateTime? bmRejectedAt,
    @JsonKey(name: 'bm_reject_reason') String? bmRejectReason,
    @JsonKey(name: 'bm_notes') String? bmNotes,
    @JsonKey(name: 'bonus_calculated') bool bonusCalculated,
    @JsonKey(name: 'bonus_amount') double? bonusAmount,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$PipelineReferralSyncDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineReferralSyncDtoCopyWithImpl<
          $Res,
          _$PipelineReferralSyncDtoImpl
        >
    implements _$$PipelineReferralSyncDtoImplCopyWith<$Res> {
  __$$PipelineReferralSyncDtoImplCopyWithImpl(
    _$PipelineReferralSyncDtoImpl _value,
    $Res Function(_$PipelineReferralSyncDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferralSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? customerId = null,
    Object? referrerRmId = null,
    Object? receiverRmId = null,
    Object? referrerBranchId = freezed,
    Object? receiverBranchId = freezed,
    Object? referrerRegionalOfficeId = freezed,
    Object? receiverRegionalOfficeId = freezed,
    Object? approverType = null,
    Object? reason = null,
    Object? notes = freezed,
    Object? status = null,
    Object? receiverAcceptedAt = freezed,
    Object? receiverRejectedAt = freezed,
    Object? receiverRejectReason = freezed,
    Object? receiverNotes = freezed,
    Object? bmApprovedAt = freezed,
    Object? bmApprovedBy = freezed,
    Object? bmRejectedAt = freezed,
    Object? bmRejectReason = freezed,
    Object? bmNotes = freezed,
    Object? bonusCalculated = null,
    Object? bonusAmount = freezed,
    Object? expiresAt = freezed,
    Object? cancelledAt = freezed,
    Object? cancelReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$PipelineReferralSyncDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        referrerRmId: null == referrerRmId
            ? _value.referrerRmId
            : referrerRmId // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverRmId: null == receiverRmId
            ? _value.receiverRmId
            : receiverRmId // ignore: cast_nullable_to_non_nullable
                  as String,
        referrerBranchId: freezed == referrerBranchId
            ? _value.referrerBranchId
            : referrerBranchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiverBranchId: freezed == receiverBranchId
            ? _value.receiverBranchId
            : receiverBranchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        referrerRegionalOfficeId: freezed == referrerRegionalOfficeId
            ? _value.referrerRegionalOfficeId
            : referrerRegionalOfficeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiverRegionalOfficeId: freezed == receiverRegionalOfficeId
            ? _value.receiverRegionalOfficeId
            : receiverRegionalOfficeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        approverType: null == approverType
            ? _value.approverType
            : approverType // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverAcceptedAt: freezed == receiverAcceptedAt
            ? _value.receiverAcceptedAt
            : receiverAcceptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        receiverRejectedAt: freezed == receiverRejectedAt
            ? _value.receiverRejectedAt
            : receiverRejectedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        receiverRejectReason: freezed == receiverRejectReason
            ? _value.receiverRejectReason
            : receiverRejectReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiverNotes: freezed == receiverNotes
            ? _value.receiverNotes
            : receiverNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        bmApprovedAt: freezed == bmApprovedAt
            ? _value.bmApprovedAt
            : bmApprovedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        bmApprovedBy: freezed == bmApprovedBy
            ? _value.bmApprovedBy
            : bmApprovedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        bmRejectedAt: freezed == bmRejectedAt
            ? _value.bmRejectedAt
            : bmRejectedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        bmRejectReason: freezed == bmRejectReason
            ? _value.bmRejectReason
            : bmRejectReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        bmNotes: freezed == bmNotes
            ? _value.bmNotes
            : bmNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        bonusCalculated: null == bonusCalculated
            ? _value.bonusCalculated
            : bonusCalculated // ignore: cast_nullable_to_non_nullable
                  as bool,
        bonusAmount: freezed == bonusAmount
            ? _value.bonusAmount
            : bonusAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelReason: freezed == cancelReason
            ? _value.cancelReason
            : cancelReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineReferralSyncDtoImpl implements _PipelineReferralSyncDto {
  const _$PipelineReferralSyncDtoImpl({
    required this.id,
    required this.code,
    @JsonKey(name: 'customer_id') required this.customerId,
    @JsonKey(name: 'referrer_rm_id') required this.referrerRmId,
    @JsonKey(name: 'receiver_rm_id') required this.receiverRmId,
    @JsonKey(name: 'referrer_branch_id') this.referrerBranchId,
    @JsonKey(name: 'receiver_branch_id') this.receiverBranchId,
    @JsonKey(name: 'referrer_regional_office_id') this.referrerRegionalOfficeId,
    @JsonKey(name: 'receiver_regional_office_id') this.receiverRegionalOfficeId,
    @JsonKey(name: 'approver_type') this.approverType = 'BM',
    required this.reason,
    this.notes,
    this.status = 'PENDING_RECEIVER',
    @JsonKey(name: 'receiver_accepted_at') this.receiverAcceptedAt,
    @JsonKey(name: 'receiver_rejected_at') this.receiverRejectedAt,
    @JsonKey(name: 'receiver_reject_reason') this.receiverRejectReason,
    @JsonKey(name: 'receiver_notes') this.receiverNotes,
    @JsonKey(name: 'bm_approved_at') this.bmApprovedAt,
    @JsonKey(name: 'bm_approved_by') this.bmApprovedBy,
    @JsonKey(name: 'bm_rejected_at') this.bmRejectedAt,
    @JsonKey(name: 'bm_reject_reason') this.bmRejectReason,
    @JsonKey(name: 'bm_notes') this.bmNotes,
    @JsonKey(name: 'bonus_calculated') this.bonusCalculated = false,
    @JsonKey(name: 'bonus_amount') this.bonusAmount,
    @JsonKey(name: 'expires_at') this.expiresAt,
    @JsonKey(name: 'cancelled_at') this.cancelledAt,
    @JsonKey(name: 'cancel_reason') this.cancelReason,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$PipelineReferralSyncDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineReferralSyncDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  // Customer Info
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  // Parties
  @override
  @JsonKey(name: 'referrer_rm_id')
  final String referrerRmId;
  @override
  @JsonKey(name: 'receiver_rm_id')
  final String receiverRmId;
  // Branch IDs (nullable for kanwil-level RMs)
  @override
  @JsonKey(name: 'referrer_branch_id')
  final String? referrerBranchId;
  @override
  @JsonKey(name: 'receiver_branch_id')
  final String? receiverBranchId;
  // Regional Office IDs
  @override
  @JsonKey(name: 'referrer_regional_office_id')
  final String? referrerRegionalOfficeId;
  @override
  @JsonKey(name: 'receiver_regional_office_id')
  final String? receiverRegionalOfficeId;
  // Approver Type
  @override
  @JsonKey(name: 'approver_type')
  final String approverType;
  // Referral Details
  @override
  final String reason;
  @override
  final String? notes;
  // Status
  @override
  @JsonKey()
  final String status;
  // Receiver Response
  @override
  @JsonKey(name: 'receiver_accepted_at')
  final DateTime? receiverAcceptedAt;
  @override
  @JsonKey(name: 'receiver_rejected_at')
  final DateTime? receiverRejectedAt;
  @override
  @JsonKey(name: 'receiver_reject_reason')
  final String? receiverRejectReason;
  @override
  @JsonKey(name: 'receiver_notes')
  final String? receiverNotes;
  // Manager Approval
  @override
  @JsonKey(name: 'bm_approved_at')
  final DateTime? bmApprovedAt;
  @override
  @JsonKey(name: 'bm_approved_by')
  final String? bmApprovedBy;
  @override
  @JsonKey(name: 'bm_rejected_at')
  final DateTime? bmRejectedAt;
  @override
  @JsonKey(name: 'bm_reject_reason')
  final String? bmRejectReason;
  @override
  @JsonKey(name: 'bm_notes')
  final String? bmNotes;
  // Result
  @override
  @JsonKey(name: 'bonus_calculated')
  final bool bonusCalculated;
  @override
  @JsonKey(name: 'bonus_amount')
  final double? bonusAmount;
  // Timestamps
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @override
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @override
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PipelineReferralSyncDto(id: $id, code: $code, customerId: $customerId, referrerRmId: $referrerRmId, receiverRmId: $receiverRmId, referrerBranchId: $referrerBranchId, receiverBranchId: $receiverBranchId, referrerRegionalOfficeId: $referrerRegionalOfficeId, receiverRegionalOfficeId: $receiverRegionalOfficeId, approverType: $approverType, reason: $reason, notes: $notes, status: $status, receiverAcceptedAt: $receiverAcceptedAt, receiverRejectedAt: $receiverRejectedAt, receiverRejectReason: $receiverRejectReason, receiverNotes: $receiverNotes, bmApprovedAt: $bmApprovedAt, bmApprovedBy: $bmApprovedBy, bmRejectedAt: $bmRejectedAt, bmRejectReason: $bmRejectReason, bmNotes: $bmNotes, bonusCalculated: $bonusCalculated, bonusAmount: $bonusAmount, expiresAt: $expiresAt, cancelledAt: $cancelledAt, cancelReason: $cancelReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralSyncDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.referrerRmId, referrerRmId) ||
                other.referrerRmId == referrerRmId) &&
            (identical(other.receiverRmId, receiverRmId) ||
                other.receiverRmId == receiverRmId) &&
            (identical(other.referrerBranchId, referrerBranchId) ||
                other.referrerBranchId == referrerBranchId) &&
            (identical(other.receiverBranchId, receiverBranchId) ||
                other.receiverBranchId == receiverBranchId) &&
            (identical(
                  other.referrerRegionalOfficeId,
                  referrerRegionalOfficeId,
                ) ||
                other.referrerRegionalOfficeId == referrerRegionalOfficeId) &&
            (identical(
                  other.receiverRegionalOfficeId,
                  receiverRegionalOfficeId,
                ) ||
                other.receiverRegionalOfficeId == receiverRegionalOfficeId) &&
            (identical(other.approverType, approverType) ||
                other.approverType == approverType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.receiverAcceptedAt, receiverAcceptedAt) ||
                other.receiverAcceptedAt == receiverAcceptedAt) &&
            (identical(other.receiverRejectedAt, receiverRejectedAt) ||
                other.receiverRejectedAt == receiverRejectedAt) &&
            (identical(other.receiverRejectReason, receiverRejectReason) ||
                other.receiverRejectReason == receiverRejectReason) &&
            (identical(other.receiverNotes, receiverNotes) ||
                other.receiverNotes == receiverNotes) &&
            (identical(other.bmApprovedAt, bmApprovedAt) ||
                other.bmApprovedAt == bmApprovedAt) &&
            (identical(other.bmApprovedBy, bmApprovedBy) ||
                other.bmApprovedBy == bmApprovedBy) &&
            (identical(other.bmRejectedAt, bmRejectedAt) ||
                other.bmRejectedAt == bmRejectedAt) &&
            (identical(other.bmRejectReason, bmRejectReason) ||
                other.bmRejectReason == bmRejectReason) &&
            (identical(other.bmNotes, bmNotes) || other.bmNotes == bmNotes) &&
            (identical(other.bonusCalculated, bonusCalculated) ||
                other.bonusCalculated == bonusCalculated) &&
            (identical(other.bonusAmount, bonusAmount) ||
                other.bonusAmount == bonusAmount) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    code,
    customerId,
    referrerRmId,
    receiverRmId,
    referrerBranchId,
    receiverBranchId,
    referrerRegionalOfficeId,
    receiverRegionalOfficeId,
    approverType,
    reason,
    notes,
    status,
    receiverAcceptedAt,
    receiverRejectedAt,
    receiverRejectReason,
    receiverNotes,
    bmApprovedAt,
    bmApprovedBy,
    bmRejectedAt,
    bmRejectReason,
    bmNotes,
    bonusCalculated,
    bonusAmount,
    expiresAt,
    cancelledAt,
    cancelReason,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of PipelineReferralSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralSyncDtoImplCopyWith<_$PipelineReferralSyncDtoImpl>
  get copyWith =>
      __$$PipelineReferralSyncDtoImplCopyWithImpl<
        _$PipelineReferralSyncDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralSyncDtoImplToJson(this);
  }
}

abstract class _PipelineReferralSyncDto implements PipelineReferralSyncDto {
  const factory _PipelineReferralSyncDto({
    required final String id,
    required final String code,
    @JsonKey(name: 'customer_id') required final String customerId,
    @JsonKey(name: 'referrer_rm_id') required final String referrerRmId,
    @JsonKey(name: 'receiver_rm_id') required final String receiverRmId,
    @JsonKey(name: 'referrer_branch_id') final String? referrerBranchId,
    @JsonKey(name: 'receiver_branch_id') final String? receiverBranchId,
    @JsonKey(name: 'referrer_regional_office_id')
    final String? referrerRegionalOfficeId,
    @JsonKey(name: 'receiver_regional_office_id')
    final String? receiverRegionalOfficeId,
    @JsonKey(name: 'approver_type') final String approverType,
    required final String reason,
    final String? notes,
    final String status,
    @JsonKey(name: 'receiver_accepted_at') final DateTime? receiverAcceptedAt,
    @JsonKey(name: 'receiver_rejected_at') final DateTime? receiverRejectedAt,
    @JsonKey(name: 'receiver_reject_reason') final String? receiverRejectReason,
    @JsonKey(name: 'receiver_notes') final String? receiverNotes,
    @JsonKey(name: 'bm_approved_at') final DateTime? bmApprovedAt,
    @JsonKey(name: 'bm_approved_by') final String? bmApprovedBy,
    @JsonKey(name: 'bm_rejected_at') final DateTime? bmRejectedAt,
    @JsonKey(name: 'bm_reject_reason') final String? bmRejectReason,
    @JsonKey(name: 'bm_notes') final String? bmNotes,
    @JsonKey(name: 'bonus_calculated') final bool bonusCalculated,
    @JsonKey(name: 'bonus_amount') final double? bonusAmount,
    @JsonKey(name: 'expires_at') final DateTime? expiresAt,
    @JsonKey(name: 'cancelled_at') final DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') final String? cancelReason,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$PipelineReferralSyncDtoImpl;

  factory _PipelineReferralSyncDto.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralSyncDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code; // Customer Info
  @override
  @JsonKey(name: 'customer_id')
  String get customerId; // Parties
  @override
  @JsonKey(name: 'referrer_rm_id')
  String get referrerRmId;
  @override
  @JsonKey(name: 'receiver_rm_id')
  String get receiverRmId; // Branch IDs (nullable for kanwil-level RMs)
  @override
  @JsonKey(name: 'referrer_branch_id')
  String? get referrerBranchId;
  @override
  @JsonKey(name: 'receiver_branch_id')
  String? get receiverBranchId; // Regional Office IDs
  @override
  @JsonKey(name: 'referrer_regional_office_id')
  String? get referrerRegionalOfficeId;
  @override
  @JsonKey(name: 'receiver_regional_office_id')
  String? get receiverRegionalOfficeId; // Approver Type
  @override
  @JsonKey(name: 'approver_type')
  String get approverType; // Referral Details
  @override
  String get reason;
  @override
  String? get notes; // Status
  @override
  String get status; // Receiver Response
  @override
  @JsonKey(name: 'receiver_accepted_at')
  DateTime? get receiverAcceptedAt;
  @override
  @JsonKey(name: 'receiver_rejected_at')
  DateTime? get receiverRejectedAt;
  @override
  @JsonKey(name: 'receiver_reject_reason')
  String? get receiverRejectReason;
  @override
  @JsonKey(name: 'receiver_notes')
  String? get receiverNotes; // Manager Approval
  @override
  @JsonKey(name: 'bm_approved_at')
  DateTime? get bmApprovedAt;
  @override
  @JsonKey(name: 'bm_approved_by')
  String? get bmApprovedBy;
  @override
  @JsonKey(name: 'bm_rejected_at')
  DateTime? get bmRejectedAt;
  @override
  @JsonKey(name: 'bm_reject_reason')
  String? get bmRejectReason;
  @override
  @JsonKey(name: 'bm_notes')
  String? get bmNotes; // Result
  @override
  @JsonKey(name: 'bonus_calculated')
  bool get bonusCalculated;
  @override
  @JsonKey(name: 'bonus_amount')
  double? get bonusAmount; // Timestamps
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;
  @override
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt;
  @override
  @JsonKey(name: 'cancel_reason')
  String? get cancelReason;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of PipelineReferralSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralSyncDtoImplCopyWith<_$PipelineReferralSyncDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
