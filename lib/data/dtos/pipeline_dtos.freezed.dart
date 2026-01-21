// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PipelineCreateDto _$PipelineCreateDtoFromJson(Map<String, dynamic> json) {
  return _PipelineCreateDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineCreateDto {
  String get customerId => throw _privateConstructorUsedError;
  String get cobId => throw _privateConstructorUsedError;
  String get lobId => throw _privateConstructorUsedError;
  String get leadSourceId => throw _privateConstructorUsedError;
  double get potentialPremium => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get brokerPicId => throw _privateConstructorUsedError;
  String? get customerContactId => throw _privateConstructorUsedError;
  double? get tsi => throw _privateConstructorUsedError;
  DateTime? get expectedCloseDate => throw _privateConstructorUsedError;
  bool get isTender => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PipelineCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineCreateDtoCopyWith<PipelineCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineCreateDtoCopyWith<$Res> {
  factory $PipelineCreateDtoCopyWith(
    PipelineCreateDto value,
    $Res Function(PipelineCreateDto) then,
  ) = _$PipelineCreateDtoCopyWithImpl<$Res, PipelineCreateDto>;
  @useResult
  $Res call({
    String customerId,
    String cobId,
    String lobId,
    String leadSourceId,
    double potentialPremium,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    DateTime? expectedCloseDate,
    bool isTender,
    String? notes,
  });
}

/// @nodoc
class _$PipelineCreateDtoCopyWithImpl<$Res, $Val extends PipelineCreateDto>
    implements $PipelineCreateDtoCopyWith<$Res> {
  _$PipelineCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? cobId = null,
    Object? lobId = null,
    Object? leadSourceId = null,
    Object? potentialPremium = null,
    Object? brokerId = freezed,
    Object? brokerPicId = freezed,
    Object? customerContactId = freezed,
    Object? tsi = freezed,
    Object? expectedCloseDate = freezed,
    Object? isTender = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            cobId: null == cobId
                ? _value.cobId
                : cobId // ignore: cast_nullable_to_non_nullable
                      as String,
            lobId: null == lobId
                ? _value.lobId
                : lobId // ignore: cast_nullable_to_non_nullable
                      as String,
            leadSourceId: null == leadSourceId
                ? _value.leadSourceId
                : leadSourceId // ignore: cast_nullable_to_non_nullable
                      as String,
            potentialPremium: null == potentialPremium
                ? _value.potentialPremium
                : potentialPremium // ignore: cast_nullable_to_non_nullable
                      as double,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerPicId: freezed == brokerPicId
                ? _value.brokerPicId
                : brokerPicId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerContactId: freezed == customerContactId
                ? _value.customerContactId
                : customerContactId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tsi: freezed == tsi
                ? _value.tsi
                : tsi // ignore: cast_nullable_to_non_nullable
                      as double?,
            expectedCloseDate: freezed == expectedCloseDate
                ? _value.expectedCloseDate
                : expectedCloseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isTender: null == isTender
                ? _value.isTender
                : isTender // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PipelineCreateDtoImplCopyWith<$Res>
    implements $PipelineCreateDtoCopyWith<$Res> {
  factory _$$PipelineCreateDtoImplCopyWith(
    _$PipelineCreateDtoImpl value,
    $Res Function(_$PipelineCreateDtoImpl) then,
  ) = __$$PipelineCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customerId,
    String cobId,
    String lobId,
    String leadSourceId,
    double potentialPremium,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    DateTime? expectedCloseDate,
    bool isTender,
    String? notes,
  });
}

/// @nodoc
class __$$PipelineCreateDtoImplCopyWithImpl<$Res>
    extends _$PipelineCreateDtoCopyWithImpl<$Res, _$PipelineCreateDtoImpl>
    implements _$$PipelineCreateDtoImplCopyWith<$Res> {
  __$$PipelineCreateDtoImplCopyWithImpl(
    _$PipelineCreateDtoImpl _value,
    $Res Function(_$PipelineCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerId = null,
    Object? cobId = null,
    Object? lobId = null,
    Object? leadSourceId = null,
    Object? potentialPremium = null,
    Object? brokerId = freezed,
    Object? brokerPicId = freezed,
    Object? customerContactId = freezed,
    Object? tsi = freezed,
    Object? expectedCloseDate = freezed,
    Object? isTender = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$PipelineCreateDtoImpl(
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        cobId: null == cobId
            ? _value.cobId
            : cobId // ignore: cast_nullable_to_non_nullable
                  as String,
        lobId: null == lobId
            ? _value.lobId
            : lobId // ignore: cast_nullable_to_non_nullable
                  as String,
        leadSourceId: null == leadSourceId
            ? _value.leadSourceId
            : leadSourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        potentialPremium: null == potentialPremium
            ? _value.potentialPremium
            : potentialPremium // ignore: cast_nullable_to_non_nullable
                  as double,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerPicId: freezed == brokerPicId
            ? _value.brokerPicId
            : brokerPicId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerContactId: freezed == customerContactId
            ? _value.customerContactId
            : customerContactId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tsi: freezed == tsi
            ? _value.tsi
            : tsi // ignore: cast_nullable_to_non_nullable
                  as double?,
        expectedCloseDate: freezed == expectedCloseDate
            ? _value.expectedCloseDate
            : expectedCloseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isTender: null == isTender
            ? _value.isTender
            : isTender // ignore: cast_nullable_to_non_nullable
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
class _$PipelineCreateDtoImpl implements _PipelineCreateDto {
  const _$PipelineCreateDtoImpl({
    required this.customerId,
    required this.cobId,
    required this.lobId,
    required this.leadSourceId,
    required this.potentialPremium,
    this.brokerId,
    this.brokerPicId,
    this.customerContactId,
    this.tsi,
    this.expectedCloseDate,
    this.isTender = false,
    this.notes,
  });

  factory _$PipelineCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineCreateDtoImplFromJson(json);

  @override
  final String customerId;
  @override
  final String cobId;
  @override
  final String lobId;
  @override
  final String leadSourceId;
  @override
  final double potentialPremium;
  @override
  final String? brokerId;
  @override
  final String? brokerPicId;
  @override
  final String? customerContactId;
  @override
  final double? tsi;
  @override
  final DateTime? expectedCloseDate;
  @override
  @JsonKey()
  final bool isTender;
  @override
  final String? notes;

  @override
  String toString() {
    return 'PipelineCreateDto(customerId: $customerId, cobId: $cobId, lobId: $lobId, leadSourceId: $leadSourceId, potentialPremium: $potentialPremium, brokerId: $brokerId, brokerPicId: $brokerPicId, customerContactId: $customerContactId, tsi: $tsi, expectedCloseDate: $expectedCloseDate, isTender: $isTender, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineCreateDtoImpl &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.cobId, cobId) || other.cobId == cobId) &&
            (identical(other.lobId, lobId) || other.lobId == lobId) &&
            (identical(other.leadSourceId, leadSourceId) ||
                other.leadSourceId == leadSourceId) &&
            (identical(other.potentialPremium, potentialPremium) ||
                other.potentialPremium == potentialPremium) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.brokerPicId, brokerPicId) ||
                other.brokerPicId == brokerPicId) &&
            (identical(other.customerContactId, customerContactId) ||
                other.customerContactId == customerContactId) &&
            (identical(other.tsi, tsi) || other.tsi == tsi) &&
            (identical(other.expectedCloseDate, expectedCloseDate) ||
                other.expectedCloseDate == expectedCloseDate) &&
            (identical(other.isTender, isTender) ||
                other.isTender == isTender) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerId,
    cobId,
    lobId,
    leadSourceId,
    potentialPremium,
    brokerId,
    brokerPicId,
    customerContactId,
    tsi,
    expectedCloseDate,
    isTender,
    notes,
  );

  /// Create a copy of PipelineCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineCreateDtoImplCopyWith<_$PipelineCreateDtoImpl> get copyWith =>
      __$$PipelineCreateDtoImplCopyWithImpl<_$PipelineCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineCreateDtoImplToJson(this);
  }
}

abstract class _PipelineCreateDto implements PipelineCreateDto {
  const factory _PipelineCreateDto({
    required final String customerId,
    required final String cobId,
    required final String lobId,
    required final String leadSourceId,
    required final double potentialPremium,
    final String? brokerId,
    final String? brokerPicId,
    final String? customerContactId,
    final double? tsi,
    final DateTime? expectedCloseDate,
    final bool isTender,
    final String? notes,
  }) = _$PipelineCreateDtoImpl;

  factory _PipelineCreateDto.fromJson(Map<String, dynamic> json) =
      _$PipelineCreateDtoImpl.fromJson;

  @override
  String get customerId;
  @override
  String get cobId;
  @override
  String get lobId;
  @override
  String get leadSourceId;
  @override
  double get potentialPremium;
  @override
  String? get brokerId;
  @override
  String? get brokerPicId;
  @override
  String? get customerContactId;
  @override
  double? get tsi;
  @override
  DateTime? get expectedCloseDate;
  @override
  bool get isTender;
  @override
  String? get notes;

  /// Create a copy of PipelineCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineCreateDtoImplCopyWith<_$PipelineCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineUpdateDto _$PipelineUpdateDtoFromJson(Map<String, dynamic> json) {
  return _PipelineUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineUpdateDto {
  String? get cobId => throw _privateConstructorUsedError;
  String? get lobId => throw _privateConstructorUsedError;
  String? get leadSourceId => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get brokerPicId => throw _privateConstructorUsedError;
  String? get customerContactId => throw _privateConstructorUsedError;
  double? get tsi => throw _privateConstructorUsedError;
  double? get potentialPremium => throw _privateConstructorUsedError;
  DateTime? get expectedCloseDate => throw _privateConstructorUsedError;
  bool? get isTender => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PipelineUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineUpdateDtoCopyWith<PipelineUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineUpdateDtoCopyWith<$Res> {
  factory $PipelineUpdateDtoCopyWith(
    PipelineUpdateDto value,
    $Res Function(PipelineUpdateDto) then,
  ) = _$PipelineUpdateDtoCopyWithImpl<$Res, PipelineUpdateDto>;
  @useResult
  $Res call({
    String? cobId,
    String? lobId,
    String? leadSourceId,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    double? potentialPremium,
    DateTime? expectedCloseDate,
    bool? isTender,
    String? notes,
  });
}

/// @nodoc
class _$PipelineUpdateDtoCopyWithImpl<$Res, $Val extends PipelineUpdateDto>
    implements $PipelineUpdateDtoCopyWith<$Res> {
  _$PipelineUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cobId = freezed,
    Object? lobId = freezed,
    Object? leadSourceId = freezed,
    Object? brokerId = freezed,
    Object? brokerPicId = freezed,
    Object? customerContactId = freezed,
    Object? tsi = freezed,
    Object? potentialPremium = freezed,
    Object? expectedCloseDate = freezed,
    Object? isTender = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            cobId: freezed == cobId
                ? _value.cobId
                : cobId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lobId: freezed == lobId
                ? _value.lobId
                : lobId // ignore: cast_nullable_to_non_nullable
                      as String?,
            leadSourceId: freezed == leadSourceId
                ? _value.leadSourceId
                : leadSourceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerPicId: freezed == brokerPicId
                ? _value.brokerPicId
                : brokerPicId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerContactId: freezed == customerContactId
                ? _value.customerContactId
                : customerContactId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tsi: freezed == tsi
                ? _value.tsi
                : tsi // ignore: cast_nullable_to_non_nullable
                      as double?,
            potentialPremium: freezed == potentialPremium
                ? _value.potentialPremium
                : potentialPremium // ignore: cast_nullable_to_non_nullable
                      as double?,
            expectedCloseDate: freezed == expectedCloseDate
                ? _value.expectedCloseDate
                : expectedCloseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isTender: freezed == isTender
                ? _value.isTender
                : isTender // ignore: cast_nullable_to_non_nullable
                      as bool?,
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
abstract class _$$PipelineUpdateDtoImplCopyWith<$Res>
    implements $PipelineUpdateDtoCopyWith<$Res> {
  factory _$$PipelineUpdateDtoImplCopyWith(
    _$PipelineUpdateDtoImpl value,
    $Res Function(_$PipelineUpdateDtoImpl) then,
  ) = __$$PipelineUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? cobId,
    String? lobId,
    String? leadSourceId,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    double? potentialPremium,
    DateTime? expectedCloseDate,
    bool? isTender,
    String? notes,
  });
}

/// @nodoc
class __$$PipelineUpdateDtoImplCopyWithImpl<$Res>
    extends _$PipelineUpdateDtoCopyWithImpl<$Res, _$PipelineUpdateDtoImpl>
    implements _$$PipelineUpdateDtoImplCopyWith<$Res> {
  __$$PipelineUpdateDtoImplCopyWithImpl(
    _$PipelineUpdateDtoImpl _value,
    $Res Function(_$PipelineUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cobId = freezed,
    Object? lobId = freezed,
    Object? leadSourceId = freezed,
    Object? brokerId = freezed,
    Object? brokerPicId = freezed,
    Object? customerContactId = freezed,
    Object? tsi = freezed,
    Object? potentialPremium = freezed,
    Object? expectedCloseDate = freezed,
    Object? isTender = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$PipelineUpdateDtoImpl(
        cobId: freezed == cobId
            ? _value.cobId
            : cobId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lobId: freezed == lobId
            ? _value.lobId
            : lobId // ignore: cast_nullable_to_non_nullable
                  as String?,
        leadSourceId: freezed == leadSourceId
            ? _value.leadSourceId
            : leadSourceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerPicId: freezed == brokerPicId
            ? _value.brokerPicId
            : brokerPicId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerContactId: freezed == customerContactId
            ? _value.customerContactId
            : customerContactId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tsi: freezed == tsi
            ? _value.tsi
            : tsi // ignore: cast_nullable_to_non_nullable
                  as double?,
        potentialPremium: freezed == potentialPremium
            ? _value.potentialPremium
            : potentialPremium // ignore: cast_nullable_to_non_nullable
                  as double?,
        expectedCloseDate: freezed == expectedCloseDate
            ? _value.expectedCloseDate
            : expectedCloseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isTender: freezed == isTender
            ? _value.isTender
            : isTender // ignore: cast_nullable_to_non_nullable
                  as bool?,
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
class _$PipelineUpdateDtoImpl implements _PipelineUpdateDto {
  const _$PipelineUpdateDtoImpl({
    this.cobId,
    this.lobId,
    this.leadSourceId,
    this.brokerId,
    this.brokerPicId,
    this.customerContactId,
    this.tsi,
    this.potentialPremium,
    this.expectedCloseDate,
    this.isTender,
    this.notes,
  });

  factory _$PipelineUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineUpdateDtoImplFromJson(json);

  @override
  final String? cobId;
  @override
  final String? lobId;
  @override
  final String? leadSourceId;
  @override
  final String? brokerId;
  @override
  final String? brokerPicId;
  @override
  final String? customerContactId;
  @override
  final double? tsi;
  @override
  final double? potentialPremium;
  @override
  final DateTime? expectedCloseDate;
  @override
  final bool? isTender;
  @override
  final String? notes;

  @override
  String toString() {
    return 'PipelineUpdateDto(cobId: $cobId, lobId: $lobId, leadSourceId: $leadSourceId, brokerId: $brokerId, brokerPicId: $brokerPicId, customerContactId: $customerContactId, tsi: $tsi, potentialPremium: $potentialPremium, expectedCloseDate: $expectedCloseDate, isTender: $isTender, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineUpdateDtoImpl &&
            (identical(other.cobId, cobId) || other.cobId == cobId) &&
            (identical(other.lobId, lobId) || other.lobId == lobId) &&
            (identical(other.leadSourceId, leadSourceId) ||
                other.leadSourceId == leadSourceId) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.brokerPicId, brokerPicId) ||
                other.brokerPicId == brokerPicId) &&
            (identical(other.customerContactId, customerContactId) ||
                other.customerContactId == customerContactId) &&
            (identical(other.tsi, tsi) || other.tsi == tsi) &&
            (identical(other.potentialPremium, potentialPremium) ||
                other.potentialPremium == potentialPremium) &&
            (identical(other.expectedCloseDate, expectedCloseDate) ||
                other.expectedCloseDate == expectedCloseDate) &&
            (identical(other.isTender, isTender) ||
                other.isTender == isTender) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cobId,
    lobId,
    leadSourceId,
    brokerId,
    brokerPicId,
    customerContactId,
    tsi,
    potentialPremium,
    expectedCloseDate,
    isTender,
    notes,
  );

  /// Create a copy of PipelineUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineUpdateDtoImplCopyWith<_$PipelineUpdateDtoImpl> get copyWith =>
      __$$PipelineUpdateDtoImplCopyWithImpl<_$PipelineUpdateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineUpdateDtoImplToJson(this);
  }
}

abstract class _PipelineUpdateDto implements PipelineUpdateDto {
  const factory _PipelineUpdateDto({
    final String? cobId,
    final String? lobId,
    final String? leadSourceId,
    final String? brokerId,
    final String? brokerPicId,
    final String? customerContactId,
    final double? tsi,
    final double? potentialPremium,
    final DateTime? expectedCloseDate,
    final bool? isTender,
    final String? notes,
  }) = _$PipelineUpdateDtoImpl;

  factory _PipelineUpdateDto.fromJson(Map<String, dynamic> json) =
      _$PipelineUpdateDtoImpl.fromJson;

  @override
  String? get cobId;
  @override
  String? get lobId;
  @override
  String? get leadSourceId;
  @override
  String? get brokerId;
  @override
  String? get brokerPicId;
  @override
  String? get customerContactId;
  @override
  double? get tsi;
  @override
  double? get potentialPremium;
  @override
  DateTime? get expectedCloseDate;
  @override
  bool? get isTender;
  @override
  String? get notes;

  /// Create a copy of PipelineUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineUpdateDtoImplCopyWith<_$PipelineUpdateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineStageUpdateDto _$PipelineStageUpdateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineStageUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineStageUpdateDto {
  String get stageId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError; // For Won stage
  double? get finalPremium => throw _privateConstructorUsedError;
  String? get policyNumber =>
      throw _privateConstructorUsedError; // For Lost stage
  String? get declineReason => throw _privateConstructorUsedError;

  /// Serializes this PipelineStageUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStageUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStageUpdateDtoCopyWith<PipelineStageUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStageUpdateDtoCopyWith<$Res> {
  factory $PipelineStageUpdateDtoCopyWith(
    PipelineStageUpdateDto value,
    $Res Function(PipelineStageUpdateDto) then,
  ) = _$PipelineStageUpdateDtoCopyWithImpl<$Res, PipelineStageUpdateDto>;
  @useResult
  $Res call({
    String stageId,
    String? notes,
    double? finalPremium,
    String? policyNumber,
    String? declineReason,
  });
}

/// @nodoc
class _$PipelineStageUpdateDtoCopyWithImpl<
  $Res,
  $Val extends PipelineStageUpdateDto
>
    implements $PipelineStageUpdateDtoCopyWith<$Res> {
  _$PipelineStageUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStageUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageId = null,
    Object? notes = freezed,
    Object? finalPremium = freezed,
    Object? policyNumber = freezed,
    Object? declineReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            stageId: null == stageId
                ? _value.stageId
                : stageId // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            finalPremium: freezed == finalPremium
                ? _value.finalPremium
                : finalPremium // ignore: cast_nullable_to_non_nullable
                      as double?,
            policyNumber: freezed == policyNumber
                ? _value.policyNumber
                : policyNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            declineReason: freezed == declineReason
                ? _value.declineReason
                : declineReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineStageUpdateDtoImplCopyWith<$Res>
    implements $PipelineStageUpdateDtoCopyWith<$Res> {
  factory _$$PipelineStageUpdateDtoImplCopyWith(
    _$PipelineStageUpdateDtoImpl value,
    $Res Function(_$PipelineStageUpdateDtoImpl) then,
  ) = __$$PipelineStageUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String stageId,
    String? notes,
    double? finalPremium,
    String? policyNumber,
    String? declineReason,
  });
}

/// @nodoc
class __$$PipelineStageUpdateDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineStageUpdateDtoCopyWithImpl<$Res, _$PipelineStageUpdateDtoImpl>
    implements _$$PipelineStageUpdateDtoImplCopyWith<$Res> {
  __$$PipelineStageUpdateDtoImplCopyWithImpl(
    _$PipelineStageUpdateDtoImpl _value,
    $Res Function(_$PipelineStageUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStageUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageId = null,
    Object? notes = freezed,
    Object? finalPremium = freezed,
    Object? policyNumber = freezed,
    Object? declineReason = freezed,
  }) {
    return _then(
      _$PipelineStageUpdateDtoImpl(
        stageId: null == stageId
            ? _value.stageId
            : stageId // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        finalPremium: freezed == finalPremium
            ? _value.finalPremium
            : finalPremium // ignore: cast_nullable_to_non_nullable
                  as double?,
        policyNumber: freezed == policyNumber
            ? _value.policyNumber
            : policyNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        declineReason: freezed == declineReason
            ? _value.declineReason
            : declineReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineStageUpdateDtoImpl implements _PipelineStageUpdateDto {
  const _$PipelineStageUpdateDtoImpl({
    required this.stageId,
    this.notes,
    this.finalPremium,
    this.policyNumber,
    this.declineReason,
  });

  factory _$PipelineStageUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStageUpdateDtoImplFromJson(json);

  @override
  final String stageId;
  @override
  final String? notes;
  // For Won stage
  @override
  final double? finalPremium;
  @override
  final String? policyNumber;
  // For Lost stage
  @override
  final String? declineReason;

  @override
  String toString() {
    return 'PipelineStageUpdateDto(stageId: $stageId, notes: $notes, finalPremium: $finalPremium, policyNumber: $policyNumber, declineReason: $declineReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStageUpdateDtoImpl &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.finalPremium, finalPremium) ||
                other.finalPremium == finalPremium) &&
            (identical(other.policyNumber, policyNumber) ||
                other.policyNumber == policyNumber) &&
            (identical(other.declineReason, declineReason) ||
                other.declineReason == declineReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stageId,
    notes,
    finalPremium,
    policyNumber,
    declineReason,
  );

  /// Create a copy of PipelineStageUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStageUpdateDtoImplCopyWith<_$PipelineStageUpdateDtoImpl>
  get copyWith =>
      __$$PipelineStageUpdateDtoImplCopyWithImpl<_$PipelineStageUpdateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStageUpdateDtoImplToJson(this);
  }
}

abstract class _PipelineStageUpdateDto implements PipelineStageUpdateDto {
  const factory _PipelineStageUpdateDto({
    required final String stageId,
    final String? notes,
    final double? finalPremium,
    final String? policyNumber,
    final String? declineReason,
  }) = _$PipelineStageUpdateDtoImpl;

  factory _PipelineStageUpdateDto.fromJson(Map<String, dynamic> json) =
      _$PipelineStageUpdateDtoImpl.fromJson;

  @override
  String get stageId;
  @override
  String? get notes; // For Won stage
  @override
  double? get finalPremium;
  @override
  String? get policyNumber; // For Lost stage
  @override
  String? get declineReason;

  /// Create a copy of PipelineStageUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStageUpdateDtoImplCopyWith<_$PipelineStageUpdateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineStatusUpdateDto _$PipelineStatusUpdateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _PipelineStatusUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineStatusUpdateDto {
  String get statusId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PipelineStatusUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStatusUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStatusUpdateDtoCopyWith<PipelineStatusUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStatusUpdateDtoCopyWith<$Res> {
  factory $PipelineStatusUpdateDtoCopyWith(
    PipelineStatusUpdateDto value,
    $Res Function(PipelineStatusUpdateDto) then,
  ) = _$PipelineStatusUpdateDtoCopyWithImpl<$Res, PipelineStatusUpdateDto>;
  @useResult
  $Res call({String statusId, String? notes});
}

/// @nodoc
class _$PipelineStatusUpdateDtoCopyWithImpl<
  $Res,
  $Val extends PipelineStatusUpdateDto
>
    implements $PipelineStatusUpdateDtoCopyWith<$Res> {
  _$PipelineStatusUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStatusUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? statusId = null, Object? notes = freezed}) {
    return _then(
      _value.copyWith(
            statusId: null == statusId
                ? _value.statusId
                : statusId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PipelineStatusUpdateDtoImplCopyWith<$Res>
    implements $PipelineStatusUpdateDtoCopyWith<$Res> {
  factory _$$PipelineStatusUpdateDtoImplCopyWith(
    _$PipelineStatusUpdateDtoImpl value,
    $Res Function(_$PipelineStatusUpdateDtoImpl) then,
  ) = __$$PipelineStatusUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String statusId, String? notes});
}

/// @nodoc
class __$$PipelineStatusUpdateDtoImplCopyWithImpl<$Res>
    extends
        _$PipelineStatusUpdateDtoCopyWithImpl<
          $Res,
          _$PipelineStatusUpdateDtoImpl
        >
    implements _$$PipelineStatusUpdateDtoImplCopyWith<$Res> {
  __$$PipelineStatusUpdateDtoImplCopyWithImpl(
    _$PipelineStatusUpdateDtoImpl _value,
    $Res Function(_$PipelineStatusUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStatusUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? statusId = null, Object? notes = freezed}) {
    return _then(
      _$PipelineStatusUpdateDtoImpl(
        statusId: null == statusId
            ? _value.statusId
            : statusId // ignore: cast_nullable_to_non_nullable
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
class _$PipelineStatusUpdateDtoImpl implements _PipelineStatusUpdateDto {
  const _$PipelineStatusUpdateDtoImpl({required this.statusId, this.notes});

  factory _$PipelineStatusUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStatusUpdateDtoImplFromJson(json);

  @override
  final String statusId;
  @override
  final String? notes;

  @override
  String toString() {
    return 'PipelineStatusUpdateDto(statusId: $statusId, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStatusUpdateDtoImpl &&
            (identical(other.statusId, statusId) ||
                other.statusId == statusId) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, statusId, notes);

  /// Create a copy of PipelineStatusUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStatusUpdateDtoImplCopyWith<_$PipelineStatusUpdateDtoImpl>
  get copyWith =>
      __$$PipelineStatusUpdateDtoImplCopyWithImpl<
        _$PipelineStatusUpdateDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStatusUpdateDtoImplToJson(this);
  }
}

abstract class _PipelineStatusUpdateDto implements PipelineStatusUpdateDto {
  const factory _PipelineStatusUpdateDto({
    required final String statusId,
    final String? notes,
  }) = _$PipelineStatusUpdateDtoImpl;

  factory _PipelineStatusUpdateDto.fromJson(Map<String, dynamic> json) =
      _$PipelineStatusUpdateDtoImpl.fromJson;

  @override
  String get statusId;
  @override
  String? get notes;

  /// Create a copy of PipelineStatusUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStatusUpdateDtoImplCopyWith<_$PipelineStatusUpdateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PipelineSyncDto _$PipelineSyncDtoFromJson(Map<String, dynamic> json) {
  return _PipelineSyncDto.fromJson(json);
}

/// @nodoc
mixin _$PipelineSyncDto {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'stage_id')
  String get stageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'status_id')
  String get statusId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cob_id')
  String get cobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lob_id')
  String get lobId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lead_source_id')
  String get leadSourceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_rm_id')
  String get assignedRmId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'potential_premium')
  double get potentialPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'broker_id')
  String? get brokerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'broker_pic_id')
  String? get brokerPicId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_contact_id')
  String? get customerContactId => throw _privateConstructorUsedError;
  double? get tsi => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_premium')
  double? get finalPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'weighted_value')
  double? get weightedValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'expected_close_date')
  DateTime? get expectedCloseDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_number')
  String? get policyNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'decline_reason')
  String? get declineReason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_tender')
  bool get isTender => throw _privateConstructorUsedError;
  @JsonKey(name: 'referred_by_user_id')
  String? get referredByUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'referral_id')
  String? get referralId => throw _privateConstructorUsedError;
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this PipelineSyncDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineSyncDtoCopyWith<PipelineSyncDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineSyncDtoCopyWith<$Res> {
  factory $PipelineSyncDtoCopyWith(
    PipelineSyncDto value,
    $Res Function(PipelineSyncDto) then,
  ) = _$PipelineSyncDtoCopyWithImpl<$Res, PipelineSyncDto>;
  @useResult
  $Res call({
    String id,
    String code,
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'stage_id') String stageId,
    @JsonKey(name: 'status_id') String statusId,
    @JsonKey(name: 'cob_id') String cobId,
    @JsonKey(name: 'lob_id') String lobId,
    @JsonKey(name: 'lead_source_id') String leadSourceId,
    @JsonKey(name: 'assigned_rm_id') String assignedRmId,
    @JsonKey(name: 'created_by') String createdBy,
    @JsonKey(name: 'potential_premium') double potentialPremium,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'broker_id') String? brokerId,
    @JsonKey(name: 'broker_pic_id') String? brokerPicId,
    @JsonKey(name: 'customer_contact_id') String? customerContactId,
    double? tsi,
    @JsonKey(name: 'final_premium') double? finalPremium,
    @JsonKey(name: 'weighted_value') double? weightedValue,
    @JsonKey(name: 'expected_close_date') DateTime? expectedCloseDate,
    @JsonKey(name: 'policy_number') String? policyNumber,
    @JsonKey(name: 'decline_reason') String? declineReason,
    String? notes,
    @JsonKey(name: 'is_tender') bool isTender,
    @JsonKey(name: 'referred_by_user_id') String? referredByUserId,
    @JsonKey(name: 'referral_id') String? referralId,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class _$PipelineSyncDtoCopyWithImpl<$Res, $Val extends PipelineSyncDto>
    implements $PipelineSyncDtoCopyWith<$Res> {
  _$PipelineSyncDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? customerId = null,
    Object? stageId = null,
    Object? statusId = null,
    Object? cobId = null,
    Object? lobId = null,
    Object? leadSourceId = null,
    Object? assignedRmId = null,
    Object? createdBy = null,
    Object? potentialPremium = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? brokerId = freezed,
    Object? brokerPicId = freezed,
    Object? customerContactId = freezed,
    Object? tsi = freezed,
    Object? finalPremium = freezed,
    Object? weightedValue = freezed,
    Object? expectedCloseDate = freezed,
    Object? policyNumber = freezed,
    Object? declineReason = freezed,
    Object? notes = freezed,
    Object? isTender = null,
    Object? referredByUserId = freezed,
    Object? referralId = freezed,
    Object? closedAt = freezed,
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
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            stageId: null == stageId
                ? _value.stageId
                : stageId // ignore: cast_nullable_to_non_nullable
                      as String,
            statusId: null == statusId
                ? _value.statusId
                : statusId // ignore: cast_nullable_to_non_nullable
                      as String,
            cobId: null == cobId
                ? _value.cobId
                : cobId // ignore: cast_nullable_to_non_nullable
                      as String,
            lobId: null == lobId
                ? _value.lobId
                : lobId // ignore: cast_nullable_to_non_nullable
                      as String,
            leadSourceId: null == leadSourceId
                ? _value.leadSourceId
                : leadSourceId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedRmId: null == assignedRmId
                ? _value.assignedRmId
                : assignedRmId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            potentialPremium: null == potentialPremium
                ? _value.potentialPremium
                : potentialPremium // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerPicId: freezed == brokerPicId
                ? _value.brokerPicId
                : brokerPicId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerContactId: freezed == customerContactId
                ? _value.customerContactId
                : customerContactId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tsi: freezed == tsi
                ? _value.tsi
                : tsi // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalPremium: freezed == finalPremium
                ? _value.finalPremium
                : finalPremium // ignore: cast_nullable_to_non_nullable
                      as double?,
            weightedValue: freezed == weightedValue
                ? _value.weightedValue
                : weightedValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            expectedCloseDate: freezed == expectedCloseDate
                ? _value.expectedCloseDate
                : expectedCloseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            policyNumber: freezed == policyNumber
                ? _value.policyNumber
                : policyNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            declineReason: freezed == declineReason
                ? _value.declineReason
                : declineReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            isTender: null == isTender
                ? _value.isTender
                : isTender // ignore: cast_nullable_to_non_nullable
                      as bool,
            referredByUserId: freezed == referredByUserId
                ? _value.referredByUserId
                : referredByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            referralId: freezed == referralId
                ? _value.referralId
                : referralId // ignore: cast_nullable_to_non_nullable
                      as String?,
            closedAt: freezed == closedAt
                ? _value.closedAt
                : closedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$PipelineSyncDtoImplCopyWith<$Res>
    implements $PipelineSyncDtoCopyWith<$Res> {
  factory _$$PipelineSyncDtoImplCopyWith(
    _$PipelineSyncDtoImpl value,
    $Res Function(_$PipelineSyncDtoImpl) then,
  ) = __$$PipelineSyncDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    @JsonKey(name: 'customer_id') String customerId,
    @JsonKey(name: 'stage_id') String stageId,
    @JsonKey(name: 'status_id') String statusId,
    @JsonKey(name: 'cob_id') String cobId,
    @JsonKey(name: 'lob_id') String lobId,
    @JsonKey(name: 'lead_source_id') String leadSourceId,
    @JsonKey(name: 'assigned_rm_id') String assignedRmId,
    @JsonKey(name: 'created_by') String createdBy,
    @JsonKey(name: 'potential_premium') double potentialPremium,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'broker_id') String? brokerId,
    @JsonKey(name: 'broker_pic_id') String? brokerPicId,
    @JsonKey(name: 'customer_contact_id') String? customerContactId,
    double? tsi,
    @JsonKey(name: 'final_premium') double? finalPremium,
    @JsonKey(name: 'weighted_value') double? weightedValue,
    @JsonKey(name: 'expected_close_date') DateTime? expectedCloseDate,
    @JsonKey(name: 'policy_number') String? policyNumber,
    @JsonKey(name: 'decline_reason') String? declineReason,
    String? notes,
    @JsonKey(name: 'is_tender') bool isTender,
    @JsonKey(name: 'referred_by_user_id') String? referredByUserId,
    @JsonKey(name: 'referral_id') String? referralId,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class __$$PipelineSyncDtoImplCopyWithImpl<$Res>
    extends _$PipelineSyncDtoCopyWithImpl<$Res, _$PipelineSyncDtoImpl>
    implements _$$PipelineSyncDtoImplCopyWith<$Res> {
  __$$PipelineSyncDtoImplCopyWithImpl(
    _$PipelineSyncDtoImpl _value,
    $Res Function(_$PipelineSyncDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? customerId = null,
    Object? stageId = null,
    Object? statusId = null,
    Object? cobId = null,
    Object? lobId = null,
    Object? leadSourceId = null,
    Object? assignedRmId = null,
    Object? createdBy = null,
    Object? potentialPremium = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? brokerId = freezed,
    Object? brokerPicId = freezed,
    Object? customerContactId = freezed,
    Object? tsi = freezed,
    Object? finalPremium = freezed,
    Object? weightedValue = freezed,
    Object? expectedCloseDate = freezed,
    Object? policyNumber = freezed,
    Object? declineReason = freezed,
    Object? notes = freezed,
    Object? isTender = null,
    Object? referredByUserId = freezed,
    Object? referralId = freezed,
    Object? closedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$PipelineSyncDtoImpl(
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
        stageId: null == stageId
            ? _value.stageId
            : stageId // ignore: cast_nullable_to_non_nullable
                  as String,
        statusId: null == statusId
            ? _value.statusId
            : statusId // ignore: cast_nullable_to_non_nullable
                  as String,
        cobId: null == cobId
            ? _value.cobId
            : cobId // ignore: cast_nullable_to_non_nullable
                  as String,
        lobId: null == lobId
            ? _value.lobId
            : lobId // ignore: cast_nullable_to_non_nullable
                  as String,
        leadSourceId: null == leadSourceId
            ? _value.leadSourceId
            : leadSourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedRmId: null == assignedRmId
            ? _value.assignedRmId
            : assignedRmId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        potentialPremium: null == potentialPremium
            ? _value.potentialPremium
            : potentialPremium // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerPicId: freezed == brokerPicId
            ? _value.brokerPicId
            : brokerPicId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerContactId: freezed == customerContactId
            ? _value.customerContactId
            : customerContactId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tsi: freezed == tsi
            ? _value.tsi
            : tsi // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalPremium: freezed == finalPremium
            ? _value.finalPremium
            : finalPremium // ignore: cast_nullable_to_non_nullable
                  as double?,
        weightedValue: freezed == weightedValue
            ? _value.weightedValue
            : weightedValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        expectedCloseDate: freezed == expectedCloseDate
            ? _value.expectedCloseDate
            : expectedCloseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        policyNumber: freezed == policyNumber
            ? _value.policyNumber
            : policyNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        declineReason: freezed == declineReason
            ? _value.declineReason
            : declineReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        isTender: null == isTender
            ? _value.isTender
            : isTender // ignore: cast_nullable_to_non_nullable
                  as bool,
        referredByUserId: freezed == referredByUserId
            ? _value.referredByUserId
            : referredByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        referralId: freezed == referralId
            ? _value.referralId
            : referralId // ignore: cast_nullable_to_non_nullable
                  as String?,
        closedAt: freezed == closedAt
            ? _value.closedAt
            : closedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$PipelineSyncDtoImpl implements _PipelineSyncDto {
  const _$PipelineSyncDtoImpl({
    required this.id,
    required this.code,
    @JsonKey(name: 'customer_id') required this.customerId,
    @JsonKey(name: 'stage_id') required this.stageId,
    @JsonKey(name: 'status_id') required this.statusId,
    @JsonKey(name: 'cob_id') required this.cobId,
    @JsonKey(name: 'lob_id') required this.lobId,
    @JsonKey(name: 'lead_source_id') required this.leadSourceId,
    @JsonKey(name: 'assigned_rm_id') required this.assignedRmId,
    @JsonKey(name: 'created_by') required this.createdBy,
    @JsonKey(name: 'potential_premium') required this.potentialPremium,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'broker_id') this.brokerId,
    @JsonKey(name: 'broker_pic_id') this.brokerPicId,
    @JsonKey(name: 'customer_contact_id') this.customerContactId,
    this.tsi,
    @JsonKey(name: 'final_premium') this.finalPremium,
    @JsonKey(name: 'weighted_value') this.weightedValue,
    @JsonKey(name: 'expected_close_date') this.expectedCloseDate,
    @JsonKey(name: 'policy_number') this.policyNumber,
    @JsonKey(name: 'decline_reason') this.declineReason,
    this.notes,
    @JsonKey(name: 'is_tender') this.isTender = false,
    @JsonKey(name: 'referred_by_user_id') this.referredByUserId,
    @JsonKey(name: 'referral_id') this.referralId,
    @JsonKey(name: 'closed_at') this.closedAt,
    @JsonKey(name: 'deleted_at') this.deletedAt,
  });

  factory _$PipelineSyncDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineSyncDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'stage_id')
  final String stageId;
  @override
  @JsonKey(name: 'status_id')
  final String statusId;
  @override
  @JsonKey(name: 'cob_id')
  final String cobId;
  @override
  @JsonKey(name: 'lob_id')
  final String lobId;
  @override
  @JsonKey(name: 'lead_source_id')
  final String leadSourceId;
  @override
  @JsonKey(name: 'assigned_rm_id')
  final String assignedRmId;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'potential_premium')
  final double potentialPremium;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'broker_id')
  final String? brokerId;
  @override
  @JsonKey(name: 'broker_pic_id')
  final String? brokerPicId;
  @override
  @JsonKey(name: 'customer_contact_id')
  final String? customerContactId;
  @override
  final double? tsi;
  @override
  @JsonKey(name: 'final_premium')
  final double? finalPremium;
  @override
  @JsonKey(name: 'weighted_value')
  final double? weightedValue;
  @override
  @JsonKey(name: 'expected_close_date')
  final DateTime? expectedCloseDate;
  @override
  @JsonKey(name: 'policy_number')
  final String? policyNumber;
  @override
  @JsonKey(name: 'decline_reason')
  final String? declineReason;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'is_tender')
  final bool isTender;
  @override
  @JsonKey(name: 'referred_by_user_id')
  final String? referredByUserId;
  @override
  @JsonKey(name: 'referral_id')
  final String? referralId;
  @override
  @JsonKey(name: 'closed_at')
  final DateTime? closedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'PipelineSyncDto(id: $id, code: $code, customerId: $customerId, stageId: $stageId, statusId: $statusId, cobId: $cobId, lobId: $lobId, leadSourceId: $leadSourceId, assignedRmId: $assignedRmId, createdBy: $createdBy, potentialPremium: $potentialPremium, createdAt: $createdAt, updatedAt: $updatedAt, brokerId: $brokerId, brokerPicId: $brokerPicId, customerContactId: $customerContactId, tsi: $tsi, finalPremium: $finalPremium, weightedValue: $weightedValue, expectedCloseDate: $expectedCloseDate, policyNumber: $policyNumber, declineReason: $declineReason, notes: $notes, isTender: $isTender, referredByUserId: $referredByUserId, referralId: $referralId, closedAt: $closedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineSyncDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.statusId, statusId) ||
                other.statusId == statusId) &&
            (identical(other.cobId, cobId) || other.cobId == cobId) &&
            (identical(other.lobId, lobId) || other.lobId == lobId) &&
            (identical(other.leadSourceId, leadSourceId) ||
                other.leadSourceId == leadSourceId) &&
            (identical(other.assignedRmId, assignedRmId) ||
                other.assignedRmId == assignedRmId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.potentialPremium, potentialPremium) ||
                other.potentialPremium == potentialPremium) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.brokerPicId, brokerPicId) ||
                other.brokerPicId == brokerPicId) &&
            (identical(other.customerContactId, customerContactId) ||
                other.customerContactId == customerContactId) &&
            (identical(other.tsi, tsi) || other.tsi == tsi) &&
            (identical(other.finalPremium, finalPremium) ||
                other.finalPremium == finalPremium) &&
            (identical(other.weightedValue, weightedValue) ||
                other.weightedValue == weightedValue) &&
            (identical(other.expectedCloseDate, expectedCloseDate) ||
                other.expectedCloseDate == expectedCloseDate) &&
            (identical(other.policyNumber, policyNumber) ||
                other.policyNumber == policyNumber) &&
            (identical(other.declineReason, declineReason) ||
                other.declineReason == declineReason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isTender, isTender) ||
                other.isTender == isTender) &&
            (identical(other.referredByUserId, referredByUserId) ||
                other.referredByUserId == referredByUserId) &&
            (identical(other.referralId, referralId) ||
                other.referralId == referralId) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    code,
    customerId,
    stageId,
    statusId,
    cobId,
    lobId,
    leadSourceId,
    assignedRmId,
    createdBy,
    potentialPremium,
    createdAt,
    updatedAt,
    brokerId,
    brokerPicId,
    customerContactId,
    tsi,
    finalPremium,
    weightedValue,
    expectedCloseDate,
    policyNumber,
    declineReason,
    notes,
    isTender,
    referredByUserId,
    referralId,
    closedAt,
    deletedAt,
  ]);

  /// Create a copy of PipelineSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineSyncDtoImplCopyWith<_$PipelineSyncDtoImpl> get copyWith =>
      __$$PipelineSyncDtoImplCopyWithImpl<_$PipelineSyncDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineSyncDtoImplToJson(this);
  }
}

abstract class _PipelineSyncDto implements PipelineSyncDto {
  const factory _PipelineSyncDto({
    required final String id,
    required final String code,
    @JsonKey(name: 'customer_id') required final String customerId,
    @JsonKey(name: 'stage_id') required final String stageId,
    @JsonKey(name: 'status_id') required final String statusId,
    @JsonKey(name: 'cob_id') required final String cobId,
    @JsonKey(name: 'lob_id') required final String lobId,
    @JsonKey(name: 'lead_source_id') required final String leadSourceId,
    @JsonKey(name: 'assigned_rm_id') required final String assignedRmId,
    @JsonKey(name: 'created_by') required final String createdBy,
    @JsonKey(name: 'potential_premium') required final double potentialPremium,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'broker_id') final String? brokerId,
    @JsonKey(name: 'broker_pic_id') final String? brokerPicId,
    @JsonKey(name: 'customer_contact_id') final String? customerContactId,
    final double? tsi,
    @JsonKey(name: 'final_premium') final double? finalPremium,
    @JsonKey(name: 'weighted_value') final double? weightedValue,
    @JsonKey(name: 'expected_close_date') final DateTime? expectedCloseDate,
    @JsonKey(name: 'policy_number') final String? policyNumber,
    @JsonKey(name: 'decline_reason') final String? declineReason,
    final String? notes,
    @JsonKey(name: 'is_tender') final bool isTender,
    @JsonKey(name: 'referred_by_user_id') final String? referredByUserId,
    @JsonKey(name: 'referral_id') final String? referralId,
    @JsonKey(name: 'closed_at') final DateTime? closedAt,
    @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
  }) = _$PipelineSyncDtoImpl;

  factory _PipelineSyncDto.fromJson(Map<String, dynamic> json) =
      _$PipelineSyncDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  @JsonKey(name: 'stage_id')
  String get stageId;
  @override
  @JsonKey(name: 'status_id')
  String get statusId;
  @override
  @JsonKey(name: 'cob_id')
  String get cobId;
  @override
  @JsonKey(name: 'lob_id')
  String get lobId;
  @override
  @JsonKey(name: 'lead_source_id')
  String get leadSourceId;
  @override
  @JsonKey(name: 'assigned_rm_id')
  String get assignedRmId;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'potential_premium')
  double get potentialPremium;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'broker_id')
  String? get brokerId;
  @override
  @JsonKey(name: 'broker_pic_id')
  String? get brokerPicId;
  @override
  @JsonKey(name: 'customer_contact_id')
  String? get customerContactId;
  @override
  double? get tsi;
  @override
  @JsonKey(name: 'final_premium')
  double? get finalPremium;
  @override
  @JsonKey(name: 'weighted_value')
  double? get weightedValue;
  @override
  @JsonKey(name: 'expected_close_date')
  DateTime? get expectedCloseDate;
  @override
  @JsonKey(name: 'policy_number')
  String? get policyNumber;
  @override
  @JsonKey(name: 'decline_reason')
  String? get declineReason;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'is_tender')
  bool get isTender;
  @override
  @JsonKey(name: 'referred_by_user_id')
  String? get referredByUserId;
  @override
  @JsonKey(name: 'referral_id')
  String? get referralId;
  @override
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt;

  /// Create a copy of PipelineSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineSyncDtoImplCopyWith<_$PipelineSyncDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
