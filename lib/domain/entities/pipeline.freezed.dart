// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PipelineStageInfo _$PipelineStageInfoFromJson(Map<String, dynamic> json) {
  return _PipelineStageInfo.fromJson(json);
}

/// @nodoc
mixin _$PipelineStageInfo {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get probability => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  bool get isFinal => throw _privateConstructorUsedError;
  bool get isWon => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this PipelineStageInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStageInfoCopyWith<PipelineStageInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStageInfoCopyWith<$Res> {
  factory $PipelineStageInfoCopyWith(
    PipelineStageInfo value,
    $Res Function(PipelineStageInfo) then,
  ) = _$PipelineStageInfoCopyWithImpl<$Res, PipelineStageInfo>;
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
  });
}

/// @nodoc
class _$PipelineStageInfoCopyWithImpl<$Res, $Val extends PipelineStageInfo>
    implements $PipelineStageInfoCopyWith<$Res> {
  _$PipelineStageInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStageInfo
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineStageInfoImplCopyWith<$Res>
    implements $PipelineStageInfoCopyWith<$Res> {
  factory _$$PipelineStageInfoImplCopyWith(
    _$PipelineStageInfoImpl value,
    $Res Function(_$PipelineStageInfoImpl) then,
  ) = __$$PipelineStageInfoImplCopyWithImpl<$Res>;
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
  });
}

/// @nodoc
class __$$PipelineStageInfoImplCopyWithImpl<$Res>
    extends _$PipelineStageInfoCopyWithImpl<$Res, _$PipelineStageInfoImpl>
    implements _$$PipelineStageInfoImplCopyWith<$Res> {
  __$$PipelineStageInfoImplCopyWithImpl(
    _$PipelineStageInfoImpl _value,
    $Res Function(_$PipelineStageInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStageInfo
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
  }) {
    return _then(
      _$PipelineStageInfoImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineStageInfoImpl implements _PipelineStageInfo {
  const _$PipelineStageInfoImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.probability,
    required this.sequence,
    this.color,
    this.isFinal = false,
    this.isWon = false,
    this.isActive = true,
  });

  factory _$PipelineStageInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStageInfoImplFromJson(json);

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
    return 'PipelineStageInfo(id: $id, code: $code, name: $name, probability: $probability, sequence: $sequence, color: $color, isFinal: $isFinal, isWon: $isWon, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStageInfoImpl &&
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
                other.isActive == isActive));
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
  );

  /// Create a copy of PipelineStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStageInfoImplCopyWith<_$PipelineStageInfoImpl> get copyWith =>
      __$$PipelineStageInfoImplCopyWithImpl<_$PipelineStageInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStageInfoImplToJson(this);
  }
}

abstract class _PipelineStageInfo implements PipelineStageInfo {
  const factory _PipelineStageInfo({
    required final String id,
    required final String code,
    required final String name,
    required final int probability,
    required final int sequence,
    final String? color,
    final bool isFinal,
    final bool isWon,
    final bool isActive,
  }) = _$PipelineStageInfoImpl;

  factory _PipelineStageInfo.fromJson(Map<String, dynamic> json) =
      _$PipelineStageInfoImpl.fromJson;

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

  /// Create a copy of PipelineStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStageInfoImplCopyWith<_$PipelineStageInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineStatusInfo _$PipelineStatusInfoFromJson(Map<String, dynamic> json) {
  return _PipelineStatusInfo.fromJson(json);
}

/// @nodoc
mixin _$PipelineStatusInfo {
  String get id => throw _privateConstructorUsedError;
  String get stageId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this PipelineStatusInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStatusInfoCopyWith<PipelineStatusInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStatusInfoCopyWith<$Res> {
  factory $PipelineStatusInfoCopyWith(
    PipelineStatusInfo value,
    $Res Function(PipelineStatusInfo) then,
  ) = _$PipelineStatusInfoCopyWithImpl<$Res, PipelineStatusInfo>;
  @useResult
  $Res call({
    String id,
    String stageId,
    String code,
    String name,
    int sequence,
    String? description,
    bool isDefault,
    bool isActive,
  });
}

/// @nodoc
class _$PipelineStatusInfoCopyWithImpl<$Res, $Val extends PipelineStatusInfo>
    implements $PipelineStatusInfoCopyWith<$Res> {
  _$PipelineStatusInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stageId = null,
    Object? code = null,
    Object? name = null,
    Object? sequence = null,
    Object? description = freezed,
    Object? isDefault = null,
    Object? isActive = null,
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
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PipelineStatusInfoImplCopyWith<$Res>
    implements $PipelineStatusInfoCopyWith<$Res> {
  factory _$$PipelineStatusInfoImplCopyWith(
    _$PipelineStatusInfoImpl value,
    $Res Function(_$PipelineStatusInfoImpl) then,
  ) = __$$PipelineStatusInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stageId,
    String code,
    String name,
    int sequence,
    String? description,
    bool isDefault,
    bool isActive,
  });
}

/// @nodoc
class __$$PipelineStatusInfoImplCopyWithImpl<$Res>
    extends _$PipelineStatusInfoCopyWithImpl<$Res, _$PipelineStatusInfoImpl>
    implements _$$PipelineStatusInfoImplCopyWith<$Res> {
  __$$PipelineStatusInfoImplCopyWithImpl(
    _$PipelineStatusInfoImpl _value,
    $Res Function(_$PipelineStatusInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stageId = null,
    Object? code = null,
    Object? name = null,
    Object? sequence = null,
    Object? description = freezed,
    Object? isDefault = null,
    Object? isActive = null,
  }) {
    return _then(
      _$PipelineStatusInfoImpl(
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
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
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
class _$PipelineStatusInfoImpl implements _PipelineStatusInfo {
  const _$PipelineStatusInfoImpl({
    required this.id,
    required this.stageId,
    required this.code,
    required this.name,
    required this.sequence,
    this.description,
    this.isDefault = false,
    this.isActive = true,
  });

  factory _$PipelineStatusInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStatusInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String stageId;
  @override
  final String code;
  @override
  final String name;
  @override
  final int sequence;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'PipelineStatusInfo(id: $id, stageId: $stageId, code: $code, name: $name, sequence: $sequence, description: $description, isDefault: $isDefault, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStatusInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stageId,
    code,
    name,
    sequence,
    description,
    isDefault,
    isActive,
  );

  /// Create a copy of PipelineStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStatusInfoImplCopyWith<_$PipelineStatusInfoImpl> get copyWith =>
      __$$PipelineStatusInfoImplCopyWithImpl<_$PipelineStatusInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStatusInfoImplToJson(this);
  }
}

abstract class _PipelineStatusInfo implements PipelineStatusInfo {
  const factory _PipelineStatusInfo({
    required final String id,
    required final String stageId,
    required final String code,
    required final String name,
    required final int sequence,
    final String? description,
    final bool isDefault,
    final bool isActive,
  }) = _$PipelineStatusInfoImpl;

  factory _PipelineStatusInfo.fromJson(Map<String, dynamic> json) =
      _$PipelineStatusInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get stageId;
  @override
  String get code;
  @override
  String get name;
  @override
  int get sequence;
  @override
  String? get description;
  @override
  bool get isDefault;
  @override
  bool get isActive;

  /// Create a copy of PipelineStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStatusInfoImplCopyWith<_$PipelineStatusInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pipeline _$PipelineFromJson(Map<String, dynamic> json) {
  return _Pipeline.fromJson(json);
}

/// @nodoc
mixin _$Pipeline {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get stageId => throw _privateConstructorUsedError;
  String get statusId => throw _privateConstructorUsedError;
  String get cobId => throw _privateConstructorUsedError;
  String get lobId => throw _privateConstructorUsedError;
  String get leadSourceId => throw _privateConstructorUsedError;
  String get assignedRmId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  double get potentialPremium => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get brokerPicId => throw _privateConstructorUsedError;
  String? get customerContactId => throw _privateConstructorUsedError;
  double? get tsi => throw _privateConstructorUsedError;
  double? get finalPremium => throw _privateConstructorUsedError;
  double? get weightedValue => throw _privateConstructorUsedError;
  DateTime? get expectedCloseDate => throw _privateConstructorUsedError;
  String? get policyNumber => throw _privateConstructorUsedError;
  String? get declineReason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isTender => throw _privateConstructorUsedError;
  String? get referredByUserId => throw _privateConstructorUsedError;
  String? get referralId => throw _privateConstructorUsedError;

  /// User who receives 4DX lag measure credit. Set at win time, never changes.
  String? get scoredToUserId => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt =>
      throw _privateConstructorUsedError; // Lookup fields (populated from joined data)
  String? get customerName => throw _privateConstructorUsedError;
  String? get stageName => throw _privateConstructorUsedError;
  String? get stageColor => throw _privateConstructorUsedError;
  int? get stageProbability => throw _privateConstructorUsedError;
  bool? get stageIsFinal => throw _privateConstructorUsedError;
  bool? get stageIsWon => throw _privateConstructorUsedError;
  String? get statusName => throw _privateConstructorUsedError;
  String? get cobName => throw _privateConstructorUsedError;
  String? get lobName => throw _privateConstructorUsedError;
  String? get leadSourceName => throw _privateConstructorUsedError;
  String? get brokerName => throw _privateConstructorUsedError;
  String? get assignedRmName => throw _privateConstructorUsedError;

  /// Display name for user who receives scoring credit.
  String? get scoredToUserName => throw _privateConstructorUsedError;

  /// Serializes this Pipeline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineCopyWith<Pipeline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineCopyWith<$Res> {
  factory $PipelineCopyWith(Pipeline value, $Res Function(Pipeline) then) =
      _$PipelineCopyWithImpl<$Res, Pipeline>;
  @useResult
  $Res call({
    String id,
    String code,
    String customerId,
    String stageId,
    String statusId,
    String cobId,
    String lobId,
    String leadSourceId,
    String assignedRmId,
    String createdBy,
    double potentialPremium,
    DateTime createdAt,
    DateTime updatedAt,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    double? finalPremium,
    double? weightedValue,
    DateTime? expectedCloseDate,
    String? policyNumber,
    String? declineReason,
    String? notes,
    bool isTender,
    String? referredByUserId,
    String? referralId,
    String? scoredToUserId,
    bool isPendingSync,
    DateTime? closedAt,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    String? customerName,
    String? stageName,
    String? stageColor,
    int? stageProbability,
    bool? stageIsFinal,
    bool? stageIsWon,
    String? statusName,
    String? cobName,
    String? lobName,
    String? leadSourceName,
    String? brokerName,
    String? assignedRmName,
    String? scoredToUserName,
  });
}

/// @nodoc
class _$PipelineCopyWithImpl<$Res, $Val extends Pipeline>
    implements $PipelineCopyWith<$Res> {
  _$PipelineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pipeline
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
    Object? scoredToUserId = freezed,
    Object? isPendingSync = null,
    Object? closedAt = freezed,
    Object? deletedAt = freezed,
    Object? lastSyncAt = freezed,
    Object? customerName = freezed,
    Object? stageName = freezed,
    Object? stageColor = freezed,
    Object? stageProbability = freezed,
    Object? stageIsFinal = freezed,
    Object? stageIsWon = freezed,
    Object? statusName = freezed,
    Object? cobName = freezed,
    Object? lobName = freezed,
    Object? leadSourceName = freezed,
    Object? brokerName = freezed,
    Object? assignedRmName = freezed,
    Object? scoredToUserName = freezed,
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
            scoredToUserId: freezed == scoredToUserId
                ? _value.scoredToUserId
                : scoredToUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPendingSync: null == isPendingSync
                ? _value.isPendingSync
                : isPendingSync // ignore: cast_nullable_to_non_nullable
                      as bool,
            closedAt: freezed == closedAt
                ? _value.closedAt
                : closedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastSyncAt: freezed == lastSyncAt
                ? _value.lastSyncAt
                : lastSyncAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            stageName: freezed == stageName
                ? _value.stageName
                : stageName // ignore: cast_nullable_to_non_nullable
                      as String?,
            stageColor: freezed == stageColor
                ? _value.stageColor
                : stageColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            stageProbability: freezed == stageProbability
                ? _value.stageProbability
                : stageProbability // ignore: cast_nullable_to_non_nullable
                      as int?,
            stageIsFinal: freezed == stageIsFinal
                ? _value.stageIsFinal
                : stageIsFinal // ignore: cast_nullable_to_non_nullable
                      as bool?,
            stageIsWon: freezed == stageIsWon
                ? _value.stageIsWon
                : stageIsWon // ignore: cast_nullable_to_non_nullable
                      as bool?,
            statusName: freezed == statusName
                ? _value.statusName
                : statusName // ignore: cast_nullable_to_non_nullable
                      as String?,
            cobName: freezed == cobName
                ? _value.cobName
                : cobName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lobName: freezed == lobName
                ? _value.lobName
                : lobName // ignore: cast_nullable_to_non_nullable
                      as String?,
            leadSourceName: freezed == leadSourceName
                ? _value.leadSourceName
                : leadSourceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerName: freezed == brokerName
                ? _value.brokerName
                : brokerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedRmName: freezed == assignedRmName
                ? _value.assignedRmName
                : assignedRmName // ignore: cast_nullable_to_non_nullable
                      as String?,
            scoredToUserName: freezed == scoredToUserName
                ? _value.scoredToUserName
                : scoredToUserName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineImplCopyWith<$Res>
    implements $PipelineCopyWith<$Res> {
  factory _$$PipelineImplCopyWith(
    _$PipelineImpl value,
    $Res Function(_$PipelineImpl) then,
  ) = __$$PipelineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String customerId,
    String stageId,
    String statusId,
    String cobId,
    String lobId,
    String leadSourceId,
    String assignedRmId,
    String createdBy,
    double potentialPremium,
    DateTime createdAt,
    DateTime updatedAt,
    String? brokerId,
    String? brokerPicId,
    String? customerContactId,
    double? tsi,
    double? finalPremium,
    double? weightedValue,
    DateTime? expectedCloseDate,
    String? policyNumber,
    String? declineReason,
    String? notes,
    bool isTender,
    String? referredByUserId,
    String? referralId,
    String? scoredToUserId,
    bool isPendingSync,
    DateTime? closedAt,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    String? customerName,
    String? stageName,
    String? stageColor,
    int? stageProbability,
    bool? stageIsFinal,
    bool? stageIsWon,
    String? statusName,
    String? cobName,
    String? lobName,
    String? leadSourceName,
    String? brokerName,
    String? assignedRmName,
    String? scoredToUserName,
  });
}

/// @nodoc
class __$$PipelineImplCopyWithImpl<$Res>
    extends _$PipelineCopyWithImpl<$Res, _$PipelineImpl>
    implements _$$PipelineImplCopyWith<$Res> {
  __$$PipelineImplCopyWithImpl(
    _$PipelineImpl _value,
    $Res Function(_$PipelineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Pipeline
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
    Object? scoredToUserId = freezed,
    Object? isPendingSync = null,
    Object? closedAt = freezed,
    Object? deletedAt = freezed,
    Object? lastSyncAt = freezed,
    Object? customerName = freezed,
    Object? stageName = freezed,
    Object? stageColor = freezed,
    Object? stageProbability = freezed,
    Object? stageIsFinal = freezed,
    Object? stageIsWon = freezed,
    Object? statusName = freezed,
    Object? cobName = freezed,
    Object? lobName = freezed,
    Object? leadSourceName = freezed,
    Object? brokerName = freezed,
    Object? assignedRmName = freezed,
    Object? scoredToUserName = freezed,
  }) {
    return _then(
      _$PipelineImpl(
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
        scoredToUserId: freezed == scoredToUserId
            ? _value.scoredToUserId
            : scoredToUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPendingSync: null == isPendingSync
            ? _value.isPendingSync
            : isPendingSync // ignore: cast_nullable_to_non_nullable
                  as bool,
        closedAt: freezed == closedAt
            ? _value.closedAt
            : closedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastSyncAt: freezed == lastSyncAt
            ? _value.lastSyncAt
            : lastSyncAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        stageName: freezed == stageName
            ? _value.stageName
            : stageName // ignore: cast_nullable_to_non_nullable
                  as String?,
        stageColor: freezed == stageColor
            ? _value.stageColor
            : stageColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        stageProbability: freezed == stageProbability
            ? _value.stageProbability
            : stageProbability // ignore: cast_nullable_to_non_nullable
                  as int?,
        stageIsFinal: freezed == stageIsFinal
            ? _value.stageIsFinal
            : stageIsFinal // ignore: cast_nullable_to_non_nullable
                  as bool?,
        stageIsWon: freezed == stageIsWon
            ? _value.stageIsWon
            : stageIsWon // ignore: cast_nullable_to_non_nullable
                  as bool?,
        statusName: freezed == statusName
            ? _value.statusName
            : statusName // ignore: cast_nullable_to_non_nullable
                  as String?,
        cobName: freezed == cobName
            ? _value.cobName
            : cobName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lobName: freezed == lobName
            ? _value.lobName
            : lobName // ignore: cast_nullable_to_non_nullable
                  as String?,
        leadSourceName: freezed == leadSourceName
            ? _value.leadSourceName
            : leadSourceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerName: freezed == brokerName
            ? _value.brokerName
            : brokerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedRmName: freezed == assignedRmName
            ? _value.assignedRmName
            : assignedRmName // ignore: cast_nullable_to_non_nullable
                  as String?,
        scoredToUserName: freezed == scoredToUserName
            ? _value.scoredToUserName
            : scoredToUserName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineImpl extends _Pipeline {
  const _$PipelineImpl({
    required this.id,
    required this.code,
    required this.customerId,
    required this.stageId,
    required this.statusId,
    required this.cobId,
    required this.lobId,
    required this.leadSourceId,
    required this.assignedRmId,
    required this.createdBy,
    required this.potentialPremium,
    required this.createdAt,
    required this.updatedAt,
    this.brokerId,
    this.brokerPicId,
    this.customerContactId,
    this.tsi,
    this.finalPremium,
    this.weightedValue,
    this.expectedCloseDate,
    this.policyNumber,
    this.declineReason,
    this.notes,
    this.isTender = false,
    this.referredByUserId,
    this.referralId,
    this.scoredToUserId,
    this.isPendingSync = false,
    this.closedAt,
    this.deletedAt,
    this.lastSyncAt,
    this.customerName,
    this.stageName,
    this.stageColor,
    this.stageProbability,
    this.stageIsFinal,
    this.stageIsWon,
    this.statusName,
    this.cobName,
    this.lobName,
    this.leadSourceName,
    this.brokerName,
    this.assignedRmName,
    this.scoredToUserName,
  }) : super._();

  factory _$PipelineImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String customerId;
  @override
  final String stageId;
  @override
  final String statusId;
  @override
  final String cobId;
  @override
  final String lobId;
  @override
  final String leadSourceId;
  @override
  final String assignedRmId;
  @override
  final String createdBy;
  @override
  final double potentialPremium;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? brokerId;
  @override
  final String? brokerPicId;
  @override
  final String? customerContactId;
  @override
  final double? tsi;
  @override
  final double? finalPremium;
  @override
  final double? weightedValue;
  @override
  final DateTime? expectedCloseDate;
  @override
  final String? policyNumber;
  @override
  final String? declineReason;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isTender;
  @override
  final String? referredByUserId;
  @override
  final String? referralId;

  /// User who receives 4DX lag measure credit. Set at win time, never changes.
  @override
  final String? scoredToUserId;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime? closedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? lastSyncAt;
  // Lookup fields (populated from joined data)
  @override
  final String? customerName;
  @override
  final String? stageName;
  @override
  final String? stageColor;
  @override
  final int? stageProbability;
  @override
  final bool? stageIsFinal;
  @override
  final bool? stageIsWon;
  @override
  final String? statusName;
  @override
  final String? cobName;
  @override
  final String? lobName;
  @override
  final String? leadSourceName;
  @override
  final String? brokerName;
  @override
  final String? assignedRmName;

  /// Display name for user who receives scoring credit.
  @override
  final String? scoredToUserName;

  @override
  String toString() {
    return 'Pipeline(id: $id, code: $code, customerId: $customerId, stageId: $stageId, statusId: $statusId, cobId: $cobId, lobId: $lobId, leadSourceId: $leadSourceId, assignedRmId: $assignedRmId, createdBy: $createdBy, potentialPremium: $potentialPremium, createdAt: $createdAt, updatedAt: $updatedAt, brokerId: $brokerId, brokerPicId: $brokerPicId, customerContactId: $customerContactId, tsi: $tsi, finalPremium: $finalPremium, weightedValue: $weightedValue, expectedCloseDate: $expectedCloseDate, policyNumber: $policyNumber, declineReason: $declineReason, notes: $notes, isTender: $isTender, referredByUserId: $referredByUserId, referralId: $referralId, scoredToUserId: $scoredToUserId, isPendingSync: $isPendingSync, closedAt: $closedAt, deletedAt: $deletedAt, lastSyncAt: $lastSyncAt, customerName: $customerName, stageName: $stageName, stageColor: $stageColor, stageProbability: $stageProbability, stageIsFinal: $stageIsFinal, stageIsWon: $stageIsWon, statusName: $statusName, cobName: $cobName, lobName: $lobName, leadSourceName: $leadSourceName, brokerName: $brokerName, assignedRmName: $assignedRmName, scoredToUserName: $scoredToUserName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineImpl &&
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
            (identical(other.scoredToUserId, scoredToUserId) ||
                other.scoredToUserId == scoredToUserId) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.stageName, stageName) ||
                other.stageName == stageName) &&
            (identical(other.stageColor, stageColor) ||
                other.stageColor == stageColor) &&
            (identical(other.stageProbability, stageProbability) ||
                other.stageProbability == stageProbability) &&
            (identical(other.stageIsFinal, stageIsFinal) ||
                other.stageIsFinal == stageIsFinal) &&
            (identical(other.stageIsWon, stageIsWon) ||
                other.stageIsWon == stageIsWon) &&
            (identical(other.statusName, statusName) ||
                other.statusName == statusName) &&
            (identical(other.cobName, cobName) || other.cobName == cobName) &&
            (identical(other.lobName, lobName) || other.lobName == lobName) &&
            (identical(other.leadSourceName, leadSourceName) ||
                other.leadSourceName == leadSourceName) &&
            (identical(other.brokerName, brokerName) ||
                other.brokerName == brokerName) &&
            (identical(other.assignedRmName, assignedRmName) ||
                other.assignedRmName == assignedRmName) &&
            (identical(other.scoredToUserName, scoredToUserName) ||
                other.scoredToUserName == scoredToUserName));
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
    scoredToUserId,
    isPendingSync,
    closedAt,
    deletedAt,
    lastSyncAt,
    customerName,
    stageName,
    stageColor,
    stageProbability,
    stageIsFinal,
    stageIsWon,
    statusName,
    cobName,
    lobName,
    leadSourceName,
    brokerName,
    assignedRmName,
    scoredToUserName,
  ]);

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineImplCopyWith<_$PipelineImpl> get copyWith =>
      __$$PipelineImplCopyWithImpl<_$PipelineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineImplToJson(this);
  }
}

abstract class _Pipeline extends Pipeline {
  const factory _Pipeline({
    required final String id,
    required final String code,
    required final String customerId,
    required final String stageId,
    required final String statusId,
    required final String cobId,
    required final String lobId,
    required final String leadSourceId,
    required final String assignedRmId,
    required final String createdBy,
    required final double potentialPremium,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? brokerId,
    final String? brokerPicId,
    final String? customerContactId,
    final double? tsi,
    final double? finalPremium,
    final double? weightedValue,
    final DateTime? expectedCloseDate,
    final String? policyNumber,
    final String? declineReason,
    final String? notes,
    final bool isTender,
    final String? referredByUserId,
    final String? referralId,
    final String? scoredToUserId,
    final bool isPendingSync,
    final DateTime? closedAt,
    final DateTime? deletedAt,
    final DateTime? lastSyncAt,
    final String? customerName,
    final String? stageName,
    final String? stageColor,
    final int? stageProbability,
    final bool? stageIsFinal,
    final bool? stageIsWon,
    final String? statusName,
    final String? cobName,
    final String? lobName,
    final String? leadSourceName,
    final String? brokerName,
    final String? assignedRmName,
    final String? scoredToUserName,
  }) = _$PipelineImpl;
  const _Pipeline._() : super._();

  factory _Pipeline.fromJson(Map<String, dynamic> json) =
      _$PipelineImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get customerId;
  @override
  String get stageId;
  @override
  String get statusId;
  @override
  String get cobId;
  @override
  String get lobId;
  @override
  String get leadSourceId;
  @override
  String get assignedRmId;
  @override
  String get createdBy;
  @override
  double get potentialPremium;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get brokerId;
  @override
  String? get brokerPicId;
  @override
  String? get customerContactId;
  @override
  double? get tsi;
  @override
  double? get finalPremium;
  @override
  double? get weightedValue;
  @override
  DateTime? get expectedCloseDate;
  @override
  String? get policyNumber;
  @override
  String? get declineReason;
  @override
  String? get notes;
  @override
  bool get isTender;
  @override
  String? get referredByUserId;
  @override
  String? get referralId;

  /// User who receives 4DX lag measure credit. Set at win time, never changes.
  @override
  String? get scoredToUserId;
  @override
  bool get isPendingSync;
  @override
  DateTime? get closedAt;
  @override
  DateTime? get deletedAt;
  @override
  DateTime? get lastSyncAt; // Lookup fields (populated from joined data)
  @override
  String? get customerName;
  @override
  String? get stageName;
  @override
  String? get stageColor;
  @override
  int? get stageProbability;
  @override
  bool? get stageIsFinal;
  @override
  bool? get stageIsWon;
  @override
  String? get statusName;
  @override
  String? get cobName;
  @override
  String? get lobName;
  @override
  String? get leadSourceName;
  @override
  String? get brokerName;
  @override
  String? get assignedRmName;

  /// Display name for user who receives scoring credit.
  @override
  String? get scoredToUserName;

  /// Create a copy of Pipeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineImplCopyWith<_$PipelineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineWithDetails _$PipelineWithDetailsFromJson(Map<String, dynamic> json) {
  return _PipelineWithDetails.fromJson(json);
}

/// @nodoc
mixin _$PipelineWithDetails {
  Pipeline get pipeline => throw _privateConstructorUsedError;
  PipelineStageInfo? get stage => throw _privateConstructorUsedError;
  PipelineStatusInfo? get status => throw _privateConstructorUsedError;

  /// Serializes this PipelineWithDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineWithDetailsCopyWith<PipelineWithDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineWithDetailsCopyWith<$Res> {
  factory $PipelineWithDetailsCopyWith(
    PipelineWithDetails value,
    $Res Function(PipelineWithDetails) then,
  ) = _$PipelineWithDetailsCopyWithImpl<$Res, PipelineWithDetails>;
  @useResult
  $Res call({
    Pipeline pipeline,
    PipelineStageInfo? stage,
    PipelineStatusInfo? status,
  });

  $PipelineCopyWith<$Res> get pipeline;
  $PipelineStageInfoCopyWith<$Res>? get stage;
  $PipelineStatusInfoCopyWith<$Res>? get status;
}

/// @nodoc
class _$PipelineWithDetailsCopyWithImpl<$Res, $Val extends PipelineWithDetails>
    implements $PipelineWithDetailsCopyWith<$Res> {
  _$PipelineWithDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pipeline = null,
    Object? stage = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            pipeline: null == pipeline
                ? _value.pipeline
                : pipeline // ignore: cast_nullable_to_non_nullable
                      as Pipeline,
            stage: freezed == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as PipelineStageInfo?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PipelineStatusInfo?,
          )
          as $Val,
    );
  }

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineCopyWith<$Res> get pipeline {
    return $PipelineCopyWith<$Res>(_value.pipeline, (value) {
      return _then(_value.copyWith(pipeline: value) as $Val);
    });
  }

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineStageInfoCopyWith<$Res>? get stage {
    if (_value.stage == null) {
      return null;
    }

    return $PipelineStageInfoCopyWith<$Res>(_value.stage!, (value) {
      return _then(_value.copyWith(stage: value) as $Val);
    });
  }

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PipelineStatusInfoCopyWith<$Res>? get status {
    if (_value.status == null) {
      return null;
    }

    return $PipelineStatusInfoCopyWith<$Res>(_value.status!, (value) {
      return _then(_value.copyWith(status: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PipelineWithDetailsImplCopyWith<$Res>
    implements $PipelineWithDetailsCopyWith<$Res> {
  factory _$$PipelineWithDetailsImplCopyWith(
    _$PipelineWithDetailsImpl value,
    $Res Function(_$PipelineWithDetailsImpl) then,
  ) = __$$PipelineWithDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Pipeline pipeline,
    PipelineStageInfo? stage,
    PipelineStatusInfo? status,
  });

  @override
  $PipelineCopyWith<$Res> get pipeline;
  @override
  $PipelineStageInfoCopyWith<$Res>? get stage;
  @override
  $PipelineStatusInfoCopyWith<$Res>? get status;
}

/// @nodoc
class __$$PipelineWithDetailsImplCopyWithImpl<$Res>
    extends _$PipelineWithDetailsCopyWithImpl<$Res, _$PipelineWithDetailsImpl>
    implements _$$PipelineWithDetailsImplCopyWith<$Res> {
  __$$PipelineWithDetailsImplCopyWithImpl(
    _$PipelineWithDetailsImpl _value,
    $Res Function(_$PipelineWithDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pipeline = null,
    Object? stage = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$PipelineWithDetailsImpl(
        pipeline: null == pipeline
            ? _value.pipeline
            : pipeline // ignore: cast_nullable_to_non_nullable
                  as Pipeline,
        stage: freezed == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as PipelineStageInfo?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PipelineStatusInfo?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineWithDetailsImpl extends _PipelineWithDetails {
  const _$PipelineWithDetailsImpl({
    required this.pipeline,
    this.stage,
    this.status,
  }) : super._();

  factory _$PipelineWithDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineWithDetailsImplFromJson(json);

  @override
  final Pipeline pipeline;
  @override
  final PipelineStageInfo? stage;
  @override
  final PipelineStatusInfo? status;

  @override
  String toString() {
    return 'PipelineWithDetails(pipeline: $pipeline, stage: $stage, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineWithDetailsImpl &&
            (identical(other.pipeline, pipeline) ||
                other.pipeline == pipeline) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pipeline, stage, status);

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineWithDetailsImplCopyWith<_$PipelineWithDetailsImpl> get copyWith =>
      __$$PipelineWithDetailsImplCopyWithImpl<_$PipelineWithDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineWithDetailsImplToJson(this);
  }
}

abstract class _PipelineWithDetails extends PipelineWithDetails {
  const factory _PipelineWithDetails({
    required final Pipeline pipeline,
    final PipelineStageInfo? stage,
    final PipelineStatusInfo? status,
  }) = _$PipelineWithDetailsImpl;
  const _PipelineWithDetails._() : super._();

  factory _PipelineWithDetails.fromJson(Map<String, dynamic> json) =
      _$PipelineWithDetailsImpl.fromJson;

  @override
  Pipeline get pipeline;
  @override
  PipelineStageInfo? get stage;
  @override
  PipelineStatusInfo? get status;

  /// Create a copy of PipelineWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineWithDetailsImplCopyWith<_$PipelineWithDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
