// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scoring_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MeasureDefinition _$MeasureDefinitionFromJson(Map<String, dynamic> json) {
  return _MeasureDefinition.fromJson(json);
}

/// @nodoc
mixin _$MeasureDefinition {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get measureType =>
      throw _privateConstructorUsedError; // 'LEAD' or 'LAG'
  String get dataType =>
      throw _privateConstructorUsedError; // 'COUNT', 'SUM', 'PERCENTAGE'
  String? get unit => throw _privateConstructorUsedError;
  String? get calculationFormula => throw _privateConstructorUsedError;
  String? get sourceTable => throw _privateConstructorUsedError;
  String? get sourceCondition => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MeasureDefinition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeasureDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasureDefinitionCopyWith<MeasureDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasureDefinitionCopyWith<$Res> {
  factory $MeasureDefinitionCopyWith(
    MeasureDefinition value,
    $Res Function(MeasureDefinition) then,
  ) = _$MeasureDefinitionCopyWithImpl<$Res, MeasureDefinition>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    String measureType,
    String dataType,
    String? unit,
    String? calculationFormula,
    String? sourceTable,
    String? sourceCondition,
    bool isActive,
    int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$MeasureDefinitionCopyWithImpl<$Res, $Val extends MeasureDefinition>
    implements $MeasureDefinitionCopyWith<$Res> {
  _$MeasureDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasureDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? measureType = null,
    Object? dataType = null,
    Object? unit = freezed,
    Object? calculationFormula = freezed,
    Object? sourceTable = freezed,
    Object? sourceCondition = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            measureType: null == measureType
                ? _value.measureType
                : measureType // ignore: cast_nullable_to_non_nullable
                      as String,
            dataType: null == dataType
                ? _value.dataType
                : dataType // ignore: cast_nullable_to_non_nullable
                      as String,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            calculationFormula: freezed == calculationFormula
                ? _value.calculationFormula
                : calculationFormula // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceTable: freezed == sourceTable
                ? _value.sourceTable
                : sourceTable // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceCondition: freezed == sourceCondition
                ? _value.sourceCondition
                : sourceCondition // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$MeasureDefinitionImplCopyWith<$Res>
    implements $MeasureDefinitionCopyWith<$Res> {
  factory _$$MeasureDefinitionImplCopyWith(
    _$MeasureDefinitionImpl value,
    $Res Function(_$MeasureDefinitionImpl) then,
  ) = __$$MeasureDefinitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    String measureType,
    String dataType,
    String? unit,
    String? calculationFormula,
    String? sourceTable,
    String? sourceCondition,
    bool isActive,
    int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$MeasureDefinitionImplCopyWithImpl<$Res>
    extends _$MeasureDefinitionCopyWithImpl<$Res, _$MeasureDefinitionImpl>
    implements _$$MeasureDefinitionImplCopyWith<$Res> {
  __$$MeasureDefinitionImplCopyWithImpl(
    _$MeasureDefinitionImpl _value,
    $Res Function(_$MeasureDefinitionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasureDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? measureType = null,
    Object? dataType = null,
    Object? unit = freezed,
    Object? calculationFormula = freezed,
    Object? sourceTable = freezed,
    Object? sourceCondition = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$MeasureDefinitionImpl(
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
        measureType: null == measureType
            ? _value.measureType
            : measureType // ignore: cast_nullable_to_non_nullable
                  as String,
        dataType: null == dataType
            ? _value.dataType
            : dataType // ignore: cast_nullable_to_non_nullable
                  as String,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        calculationFormula: freezed == calculationFormula
            ? _value.calculationFormula
            : calculationFormula // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceTable: freezed == sourceTable
            ? _value.sourceTable
            : sourceTable // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceCondition: freezed == sourceCondition
            ? _value.sourceCondition
            : sourceCondition // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$MeasureDefinitionImpl implements _MeasureDefinition {
  const _$MeasureDefinitionImpl({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.measureType,
    required this.dataType,
    this.unit,
    this.calculationFormula,
    this.sourceTable,
    this.sourceCondition,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory _$MeasureDefinitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasureDefinitionImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String measureType;
  // 'LEAD' or 'LAG'
  @override
  final String dataType;
  // 'COUNT', 'SUM', 'PERCENTAGE'
  @override
  final String? unit;
  @override
  final String? calculationFormula;
  @override
  final String? sourceTable;
  @override
  final String? sourceCondition;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MeasureDefinition(id: $id, code: $code, name: $name, description: $description, measureType: $measureType, dataType: $dataType, unit: $unit, calculationFormula: $calculationFormula, sourceTable: $sourceTable, sourceCondition: $sourceCondition, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasureDefinitionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.measureType, measureType) ||
                other.measureType == measureType) &&
            (identical(other.dataType, dataType) ||
                other.dataType == dataType) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.calculationFormula, calculationFormula) ||
                other.calculationFormula == calculationFormula) &&
            (identical(other.sourceTable, sourceTable) ||
                other.sourceTable == sourceTable) &&
            (identical(other.sourceCondition, sourceCondition) ||
                other.sourceCondition == sourceCondition) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
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
    description,
    measureType,
    dataType,
    unit,
    calculationFormula,
    sourceTable,
    sourceCondition,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
  );

  /// Create a copy of MeasureDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasureDefinitionImplCopyWith<_$MeasureDefinitionImpl> get copyWith =>
      __$$MeasureDefinitionImplCopyWithImpl<_$MeasureDefinitionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasureDefinitionImplToJson(this);
  }
}

abstract class _MeasureDefinition implements MeasureDefinition {
  const factory _MeasureDefinition({
    required final String id,
    required final String code,
    required final String name,
    final String? description,
    required final String measureType,
    required final String dataType,
    final String? unit,
    final String? calculationFormula,
    final String? sourceTable,
    final String? sourceCondition,
    final bool isActive,
    final int sortOrder,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$MeasureDefinitionImpl;

  factory _MeasureDefinition.fromJson(Map<String, dynamic> json) =
      _$MeasureDefinitionImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get measureType; // 'LEAD' or 'LAG'
  @override
  String get dataType; // 'COUNT', 'SUM', 'PERCENTAGE'
  @override
  String? get unit;
  @override
  String? get calculationFormula;
  @override
  String? get sourceTable;
  @override
  String? get sourceCondition;
  @override
  bool get isActive;
  @override
  int get sortOrder;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of MeasureDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasureDefinitionImplCopyWith<_$MeasureDefinitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoringPeriod _$ScoringPeriodFromJson(Map<String, dynamic> json) {
  return _ScoringPeriod.fromJson(json);
}

/// @nodoc
mixin _$ScoringPeriod {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get periodType =>
      throw _privateConstructorUsedError; // 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  bool get isCurrent => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ScoringPeriod to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoringPeriodCopyWith<ScoringPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoringPeriodCopyWith<$Res> {
  factory $ScoringPeriodCopyWith(
    ScoringPeriod value,
    $Res Function(ScoringPeriod) then,
  ) = _$ScoringPeriodCopyWithImpl<$Res, ScoringPeriod>;
  @useResult
  $Res call({
    String id,
    String name,
    String periodType,
    DateTime startDate,
    DateTime endDate,
    bool isCurrent,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ScoringPeriodCopyWithImpl<$Res, $Val extends ScoringPeriod>
    implements $ScoringPeriodCopyWith<$Res> {
  _$ScoringPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? periodType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isCurrent = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            periodType: null == periodType
                ? _value.periodType
                : periodType // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isCurrent: null == isCurrent
                ? _value.isCurrent
                : isCurrent // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ScoringPeriodImplCopyWith<$Res>
    implements $ScoringPeriodCopyWith<$Res> {
  factory _$$ScoringPeriodImplCopyWith(
    _$ScoringPeriodImpl value,
    $Res Function(_$ScoringPeriodImpl) then,
  ) = __$$ScoringPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String periodType,
    DateTime startDate,
    DateTime endDate,
    bool isCurrent,
    bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ScoringPeriodImplCopyWithImpl<$Res>
    extends _$ScoringPeriodCopyWithImpl<$Res, _$ScoringPeriodImpl>
    implements _$$ScoringPeriodImplCopyWith<$Res> {
  __$$ScoringPeriodImplCopyWithImpl(
    _$ScoringPeriodImpl _value,
    $Res Function(_$ScoringPeriodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScoringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? periodType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isCurrent = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ScoringPeriodImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        periodType: null == periodType
            ? _value.periodType
            : periodType // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isCurrent: null == isCurrent
            ? _value.isCurrent
            : isCurrent // ignore: cast_nullable_to_non_nullable
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
class _$ScoringPeriodImpl implements _ScoringPeriod {
  const _$ScoringPeriodImpl({
    required this.id,
    required this.name,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory _$ScoringPeriodImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoringPeriodImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String periodType;
  // 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final bool isCurrent;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ScoringPeriod(id: $id, name: $name, periodType: $periodType, startDate: $startDate, endDate: $endDate, isCurrent: $isCurrent, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoringPeriodImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.periodType, periodType) ||
                other.periodType == periodType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
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
    name,
    periodType,
    startDate,
    endDate,
    isCurrent,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ScoringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoringPeriodImplCopyWith<_$ScoringPeriodImpl> get copyWith =>
      __$$ScoringPeriodImplCopyWithImpl<_$ScoringPeriodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoringPeriodImplToJson(this);
  }
}

abstract class _ScoringPeriod implements ScoringPeriod {
  const factory _ScoringPeriod({
    required final String id,
    required final String name,
    required final String periodType,
    required final DateTime startDate,
    required final DateTime endDate,
    final bool isCurrent,
    final bool isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ScoringPeriodImpl;

  factory _ScoringPeriod.fromJson(Map<String, dynamic> json) =
      _$ScoringPeriodImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get periodType; // 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  bool get isCurrent;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ScoringPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoringPeriodImplCopyWith<_$ScoringPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserTarget _$UserTargetFromJson(Map<String, dynamic> json) {
  return _UserTarget.fromJson(json);
}

/// @nodoc
mixin _$UserTarget {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get measureId => throw _privateConstructorUsedError;
  String get periodId => throw _privateConstructorUsedError;
  double get targetValue => throw _privateConstructorUsedError;
  String? get assignedBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Display fields (resolved from joins)
  String? get measureName => throw _privateConstructorUsedError;
  String? get measureType => throw _privateConstructorUsedError;
  String? get measureUnit => throw _privateConstructorUsedError;

  /// Serializes this UserTarget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserTargetCopyWith<UserTarget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserTargetCopyWith<$Res> {
  factory $UserTargetCopyWith(
    UserTarget value,
    $Res Function(UserTarget) then,
  ) = _$UserTargetCopyWithImpl<$Res, UserTarget>;
  @useResult
  $Res call({
    String id,
    String userId,
    String measureId,
    String periodId,
    double targetValue,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? measureName,
    String? measureType,
    String? measureUnit,
  });
}

/// @nodoc
class _$UserTargetCopyWithImpl<$Res, $Val extends UserTarget>
    implements $UserTargetCopyWith<$Res> {
  _$UserTargetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? measureId = null,
    Object? periodId = null,
    Object? targetValue = null,
    Object? assignedBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? measureName = freezed,
    Object? measureType = freezed,
    Object? measureUnit = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            measureId: null == measureId
                ? _value.measureId
                : measureId // ignore: cast_nullable_to_non_nullable
                      as String,
            periodId: null == periodId
                ? _value.periodId
                : periodId // ignore: cast_nullable_to_non_nullable
                      as String,
            targetValue: null == targetValue
                ? _value.targetValue
                : targetValue // ignore: cast_nullable_to_non_nullable
                      as double,
            assignedBy: freezed == assignedBy
                ? _value.assignedBy
                : assignedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            measureName: freezed == measureName
                ? _value.measureName
                : measureName // ignore: cast_nullable_to_non_nullable
                      as String?,
            measureType: freezed == measureType
                ? _value.measureType
                : measureType // ignore: cast_nullable_to_non_nullable
                      as String?,
            measureUnit: freezed == measureUnit
                ? _value.measureUnit
                : measureUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserTargetImplCopyWith<$Res>
    implements $UserTargetCopyWith<$Res> {
  factory _$$UserTargetImplCopyWith(
    _$UserTargetImpl value,
    $Res Function(_$UserTargetImpl) then,
  ) = __$$UserTargetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String measureId,
    String periodId,
    double targetValue,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? measureName,
    String? measureType,
    String? measureUnit,
  });
}

/// @nodoc
class __$$UserTargetImplCopyWithImpl<$Res>
    extends _$UserTargetCopyWithImpl<$Res, _$UserTargetImpl>
    implements _$$UserTargetImplCopyWith<$Res> {
  __$$UserTargetImplCopyWithImpl(
    _$UserTargetImpl _value,
    $Res Function(_$UserTargetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? measureId = null,
    Object? periodId = null,
    Object? targetValue = null,
    Object? assignedBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? measureName = freezed,
    Object? measureType = freezed,
    Object? measureUnit = freezed,
  }) {
    return _then(
      _$UserTargetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        measureId: null == measureId
            ? _value.measureId
            : measureId // ignore: cast_nullable_to_non_nullable
                  as String,
        periodId: null == periodId
            ? _value.periodId
            : periodId // ignore: cast_nullable_to_non_nullable
                  as String,
        targetValue: null == targetValue
            ? _value.targetValue
            : targetValue // ignore: cast_nullable_to_non_nullable
                  as double,
        assignedBy: freezed == assignedBy
            ? _value.assignedBy
            : assignedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        measureName: freezed == measureName
            ? _value.measureName
            : measureName // ignore: cast_nullable_to_non_nullable
                  as String?,
        measureType: freezed == measureType
            ? _value.measureType
            : measureType // ignore: cast_nullable_to_non_nullable
                  as String?,
        measureUnit: freezed == measureUnit
            ? _value.measureUnit
            : measureUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserTargetImpl implements _UserTarget {
  const _$UserTargetImpl({
    required this.id,
    required this.userId,
    required this.measureId,
    required this.periodId,
    required this.targetValue,
    this.assignedBy,
    this.createdAt,
    this.updatedAt,
    this.measureName,
    this.measureType,
    this.measureUnit,
  });

  factory _$UserTargetImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserTargetImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String measureId;
  @override
  final String periodId;
  @override
  final double targetValue;
  @override
  final String? assignedBy;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Display fields (resolved from joins)
  @override
  final String? measureName;
  @override
  final String? measureType;
  @override
  final String? measureUnit;

  @override
  String toString() {
    return 'UserTarget(id: $id, userId: $userId, measureId: $measureId, periodId: $periodId, targetValue: $targetValue, assignedBy: $assignedBy, createdAt: $createdAt, updatedAt: $updatedAt, measureName: $measureName, measureType: $measureType, measureUnit: $measureUnit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserTargetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.measureId, measureId) ||
                other.measureId == measureId) &&
            (identical(other.periodId, periodId) ||
                other.periodId == periodId) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.assignedBy, assignedBy) ||
                other.assignedBy == assignedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.measureName, measureName) ||
                other.measureName == measureName) &&
            (identical(other.measureType, measureType) ||
                other.measureType == measureType) &&
            (identical(other.measureUnit, measureUnit) ||
                other.measureUnit == measureUnit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    measureId,
    periodId,
    targetValue,
    assignedBy,
    createdAt,
    updatedAt,
    measureName,
    measureType,
    measureUnit,
  );

  /// Create a copy of UserTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserTargetImplCopyWith<_$UserTargetImpl> get copyWith =>
      __$$UserTargetImplCopyWithImpl<_$UserTargetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserTargetImplToJson(this);
  }
}

abstract class _UserTarget implements UserTarget {
  const factory _UserTarget({
    required final String id,
    required final String userId,
    required final String measureId,
    required final String periodId,
    required final double targetValue,
    final String? assignedBy,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? measureName,
    final String? measureType,
    final String? measureUnit,
  }) = _$UserTargetImpl;

  factory _UserTarget.fromJson(Map<String, dynamic> json) =
      _$UserTargetImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get measureId;
  @override
  String get periodId;
  @override
  double get targetValue;
  @override
  String? get assignedBy;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Display fields (resolved from joins)
  @override
  String? get measureName;
  @override
  String? get measureType;
  @override
  String? get measureUnit;

  /// Create a copy of UserTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserTargetImplCopyWith<_$UserTargetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserScore _$UserScoreFromJson(Map<String, dynamic> json) {
  return _UserScore.fromJson(json);
}

/// @nodoc
mixin _$UserScore {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get measureId => throw _privateConstructorUsedError;
  String get periodId => throw _privateConstructorUsedError;
  double get actualValue => throw _privateConstructorUsedError;
  double get targetValue => throw _privateConstructorUsedError;
  double? get percentage => throw _privateConstructorUsedError;
  DateTime? get calculatedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Display fields (resolved from joins)
  String? get measureName => throw _privateConstructorUsedError;
  String? get measureType => throw _privateConstructorUsedError;
  String? get measureUnit => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this UserScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserScoreCopyWith<UserScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserScoreCopyWith<$Res> {
  factory $UserScoreCopyWith(UserScore value, $Res Function(UserScore) then) =
      _$UserScoreCopyWithImpl<$Res, UserScore>;
  @useResult
  $Res call({
    String id,
    String userId,
    String measureId,
    String periodId,
    double actualValue,
    double targetValue,
    double? percentage,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? measureName,
    String? measureType,
    String? measureUnit,
    int sortOrder,
  });
}

/// @nodoc
class _$UserScoreCopyWithImpl<$Res, $Val extends UserScore>
    implements $UserScoreCopyWith<$Res> {
  _$UserScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? measureId = null,
    Object? periodId = null,
    Object? actualValue = null,
    Object? targetValue = null,
    Object? percentage = freezed,
    Object? calculatedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? measureName = freezed,
    Object? measureType = freezed,
    Object? measureUnit = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            measureId: null == measureId
                ? _value.measureId
                : measureId // ignore: cast_nullable_to_non_nullable
                      as String,
            periodId: null == periodId
                ? _value.periodId
                : periodId // ignore: cast_nullable_to_non_nullable
                      as String,
            actualValue: null == actualValue
                ? _value.actualValue
                : actualValue // ignore: cast_nullable_to_non_nullable
                      as double,
            targetValue: null == targetValue
                ? _value.targetValue
                : targetValue // ignore: cast_nullable_to_non_nullable
                      as double,
            percentage: freezed == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            calculatedAt: freezed == calculatedAt
                ? _value.calculatedAt
                : calculatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            measureName: freezed == measureName
                ? _value.measureName
                : measureName // ignore: cast_nullable_to_non_nullable
                      as String?,
            measureType: freezed == measureType
                ? _value.measureType
                : measureType // ignore: cast_nullable_to_non_nullable
                      as String?,
            measureUnit: freezed == measureUnit
                ? _value.measureUnit
                : measureUnit // ignore: cast_nullable_to_non_nullable
                      as String?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserScoreImplCopyWith<$Res>
    implements $UserScoreCopyWith<$Res> {
  factory _$$UserScoreImplCopyWith(
    _$UserScoreImpl value,
    $Res Function(_$UserScoreImpl) then,
  ) = __$$UserScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String measureId,
    String periodId,
    double actualValue,
    double targetValue,
    double? percentage,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? measureName,
    String? measureType,
    String? measureUnit,
    int sortOrder,
  });
}

/// @nodoc
class __$$UserScoreImplCopyWithImpl<$Res>
    extends _$UserScoreCopyWithImpl<$Res, _$UserScoreImpl>
    implements _$$UserScoreImplCopyWith<$Res> {
  __$$UserScoreImplCopyWithImpl(
    _$UserScoreImpl _value,
    $Res Function(_$UserScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? measureId = null,
    Object? periodId = null,
    Object? actualValue = null,
    Object? targetValue = null,
    Object? percentage = freezed,
    Object? calculatedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? measureName = freezed,
    Object? measureType = freezed,
    Object? measureUnit = freezed,
    Object? sortOrder = null,
  }) {
    return _then(
      _$UserScoreImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        measureId: null == measureId
            ? _value.measureId
            : measureId // ignore: cast_nullable_to_non_nullable
                  as String,
        periodId: null == periodId
            ? _value.periodId
            : periodId // ignore: cast_nullable_to_non_nullable
                  as String,
        actualValue: null == actualValue
            ? _value.actualValue
            : actualValue // ignore: cast_nullable_to_non_nullable
                  as double,
        targetValue: null == targetValue
            ? _value.targetValue
            : targetValue // ignore: cast_nullable_to_non_nullable
                  as double,
        percentage: freezed == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        calculatedAt: freezed == calculatedAt
            ? _value.calculatedAt
            : calculatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        measureName: freezed == measureName
            ? _value.measureName
            : measureName // ignore: cast_nullable_to_non_nullable
                  as String?,
        measureType: freezed == measureType
            ? _value.measureType
            : measureType // ignore: cast_nullable_to_non_nullable
                  as String?,
        measureUnit: freezed == measureUnit
            ? _value.measureUnit
            : measureUnit // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserScoreImpl extends _UserScore {
  const _$UserScoreImpl({
    required this.id,
    required this.userId,
    required this.measureId,
    required this.periodId,
    required this.actualValue,
    required this.targetValue,
    this.percentage,
    this.calculatedAt,
    this.createdAt,
    this.updatedAt,
    this.measureName,
    this.measureType,
    this.measureUnit,
    this.sortOrder = 0,
  }) : super._();

  factory _$UserScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserScoreImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String measureId;
  @override
  final String periodId;
  @override
  final double actualValue;
  @override
  final double targetValue;
  @override
  final double? percentage;
  @override
  final DateTime? calculatedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Display fields (resolved from joins)
  @override
  final String? measureName;
  @override
  final String? measureType;
  @override
  final String? measureUnit;
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'UserScore(id: $id, userId: $userId, measureId: $measureId, periodId: $periodId, actualValue: $actualValue, targetValue: $targetValue, percentage: $percentage, calculatedAt: $calculatedAt, createdAt: $createdAt, updatedAt: $updatedAt, measureName: $measureName, measureType: $measureType, measureUnit: $measureUnit, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserScoreImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.measureId, measureId) ||
                other.measureId == measureId) &&
            (identical(other.periodId, periodId) ||
                other.periodId == periodId) &&
            (identical(other.actualValue, actualValue) ||
                other.actualValue == actualValue) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.measureName, measureName) ||
                other.measureName == measureName) &&
            (identical(other.measureType, measureType) ||
                other.measureType == measureType) &&
            (identical(other.measureUnit, measureUnit) ||
                other.measureUnit == measureUnit) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    measureId,
    periodId,
    actualValue,
    targetValue,
    percentage,
    calculatedAt,
    createdAt,
    updatedAt,
    measureName,
    measureType,
    measureUnit,
    sortOrder,
  );

  /// Create a copy of UserScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserScoreImplCopyWith<_$UserScoreImpl> get copyWith =>
      __$$UserScoreImplCopyWithImpl<_$UserScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserScoreImplToJson(this);
  }
}

abstract class _UserScore extends UserScore {
  const factory _UserScore({
    required final String id,
    required final String userId,
    required final String measureId,
    required final String periodId,
    required final double actualValue,
    required final double targetValue,
    final double? percentage,
    final DateTime? calculatedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? measureName,
    final String? measureType,
    final String? measureUnit,
    final int sortOrder,
  }) = _$UserScoreImpl;
  const _UserScore._() : super._();

  factory _UserScore.fromJson(Map<String, dynamic> json) =
      _$UserScoreImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get measureId;
  @override
  String get periodId;
  @override
  double get actualValue;
  @override
  double get targetValue;
  @override
  double? get percentage;
  @override
  DateTime? get calculatedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Display fields (resolved from joins)
  @override
  String? get measureName;
  @override
  String? get measureType;
  @override
  String? get measureUnit;
  @override
  int get sortOrder;

  /// Create a copy of UserScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserScoreImplCopyWith<_$UserScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PeriodSummary _$PeriodSummaryFromJson(Map<String, dynamic> json) {
  return _PeriodSummary.fromJson(json);
}

/// @nodoc
mixin _$PeriodSummary {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get periodId => throw _privateConstructorUsedError;
  double get totalLeadScore => throw _privateConstructorUsedError;
  double get totalLagScore => throw _privateConstructorUsedError;
  double get compositeScore => throw _privateConstructorUsedError;
  int? get rank => throw _privateConstructorUsedError;
  int? get rankChange => throw _privateConstructorUsedError;
  DateTime? get calculatedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Display fields
  String? get userName => throw _privateConstructorUsedError;
  String? get periodName => throw _privateConstructorUsedError;

  /// Serializes this PeriodSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeriodSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeriodSummaryCopyWith<PeriodSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeriodSummaryCopyWith<$Res> {
  factory $PeriodSummaryCopyWith(
    PeriodSummary value,
    $Res Function(PeriodSummary) then,
  ) = _$PeriodSummaryCopyWithImpl<$Res, PeriodSummary>;
  @useResult
  $Res call({
    String id,
    String userId,
    String periodId,
    double totalLeadScore,
    double totalLagScore,
    double compositeScore,
    int? rank,
    int? rankChange,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? periodName,
  });
}

/// @nodoc
class _$PeriodSummaryCopyWithImpl<$Res, $Val extends PeriodSummary>
    implements $PeriodSummaryCopyWith<$Res> {
  _$PeriodSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeriodSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? periodId = null,
    Object? totalLeadScore = null,
    Object? totalLagScore = null,
    Object? compositeScore = null,
    Object? rank = freezed,
    Object? rankChange = freezed,
    Object? calculatedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? periodName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            periodId: null == periodId
                ? _value.periodId
                : periodId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalLeadScore: null == totalLeadScore
                ? _value.totalLeadScore
                : totalLeadScore // ignore: cast_nullable_to_non_nullable
                      as double,
            totalLagScore: null == totalLagScore
                ? _value.totalLagScore
                : totalLagScore // ignore: cast_nullable_to_non_nullable
                      as double,
            compositeScore: null == compositeScore
                ? _value.compositeScore
                : compositeScore // ignore: cast_nullable_to_non_nullable
                      as double,
            rank: freezed == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int?,
            rankChange: freezed == rankChange
                ? _value.rankChange
                : rankChange // ignore: cast_nullable_to_non_nullable
                      as int?,
            calculatedAt: freezed == calculatedAt
                ? _value.calculatedAt
                : calculatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            periodName: freezed == periodName
                ? _value.periodName
                : periodName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PeriodSummaryImplCopyWith<$Res>
    implements $PeriodSummaryCopyWith<$Res> {
  factory _$$PeriodSummaryImplCopyWith(
    _$PeriodSummaryImpl value,
    $Res Function(_$PeriodSummaryImpl) then,
  ) = __$$PeriodSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String periodId,
    double totalLeadScore,
    double totalLagScore,
    double compositeScore,
    int? rank,
    int? rankChange,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? periodName,
  });
}

/// @nodoc
class __$$PeriodSummaryImplCopyWithImpl<$Res>
    extends _$PeriodSummaryCopyWithImpl<$Res, _$PeriodSummaryImpl>
    implements _$$PeriodSummaryImplCopyWith<$Res> {
  __$$PeriodSummaryImplCopyWithImpl(
    _$PeriodSummaryImpl _value,
    $Res Function(_$PeriodSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeriodSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? periodId = null,
    Object? totalLeadScore = null,
    Object? totalLagScore = null,
    Object? compositeScore = null,
    Object? rank = freezed,
    Object? rankChange = freezed,
    Object? calculatedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? userName = freezed,
    Object? periodName = freezed,
  }) {
    return _then(
      _$PeriodSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        periodId: null == periodId
            ? _value.periodId
            : periodId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalLeadScore: null == totalLeadScore
            ? _value.totalLeadScore
            : totalLeadScore // ignore: cast_nullable_to_non_nullable
                  as double,
        totalLagScore: null == totalLagScore
            ? _value.totalLagScore
            : totalLagScore // ignore: cast_nullable_to_non_nullable
                  as double,
        compositeScore: null == compositeScore
            ? _value.compositeScore
            : compositeScore // ignore: cast_nullable_to_non_nullable
                  as double,
        rank: freezed == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int?,
        rankChange: freezed == rankChange
            ? _value.rankChange
            : rankChange // ignore: cast_nullable_to_non_nullable
                  as int?,
        calculatedAt: freezed == calculatedAt
            ? _value.calculatedAt
            : calculatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        periodName: freezed == periodName
            ? _value.periodName
            : periodName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PeriodSummaryImpl extends _PeriodSummary {
  const _$PeriodSummaryImpl({
    required this.id,
    required this.userId,
    required this.periodId,
    this.totalLeadScore = 0,
    this.totalLagScore = 0,
    this.compositeScore = 0,
    this.rank,
    this.rankChange,
    this.calculatedAt,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.periodName,
  }) : super._();

  factory _$PeriodSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeriodSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String periodId;
  @override
  @JsonKey()
  final double totalLeadScore;
  @override
  @JsonKey()
  final double totalLagScore;
  @override
  @JsonKey()
  final double compositeScore;
  @override
  final int? rank;
  @override
  final int? rankChange;
  @override
  final DateTime? calculatedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  // Display fields
  @override
  final String? userName;
  @override
  final String? periodName;

  @override
  String toString() {
    return 'PeriodSummary(id: $id, userId: $userId, periodId: $periodId, totalLeadScore: $totalLeadScore, totalLagScore: $totalLagScore, compositeScore: $compositeScore, rank: $rank, rankChange: $rankChange, calculatedAt: $calculatedAt, createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, periodName: $periodName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeriodSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.periodId, periodId) ||
                other.periodId == periodId) &&
            (identical(other.totalLeadScore, totalLeadScore) ||
                other.totalLeadScore == totalLeadScore) &&
            (identical(other.totalLagScore, totalLagScore) ||
                other.totalLagScore == totalLagScore) &&
            (identical(other.compositeScore, compositeScore) ||
                other.compositeScore == compositeScore) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.rankChange, rankChange) ||
                other.rankChange == rankChange) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.periodName, periodName) ||
                other.periodName == periodName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    periodId,
    totalLeadScore,
    totalLagScore,
    compositeScore,
    rank,
    rankChange,
    calculatedAt,
    createdAt,
    updatedAt,
    userName,
    periodName,
  );

  /// Create a copy of PeriodSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeriodSummaryImplCopyWith<_$PeriodSummaryImpl> get copyWith =>
      __$$PeriodSummaryImplCopyWithImpl<_$PeriodSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeriodSummaryImplToJson(this);
  }
}

abstract class _PeriodSummary extends PeriodSummary {
  const factory _PeriodSummary({
    required final String id,
    required final String userId,
    required final String periodId,
    final double totalLeadScore,
    final double totalLagScore,
    final double compositeScore,
    final int? rank,
    final int? rankChange,
    final DateTime? calculatedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? userName,
    final String? periodName,
  }) = _$PeriodSummaryImpl;
  const _PeriodSummary._() : super._();

  factory _PeriodSummary.fromJson(Map<String, dynamic> json) =
      _$PeriodSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get periodId;
  @override
  double get totalLeadScore;
  @override
  double get totalLagScore;
  @override
  double get compositeScore;
  @override
  int? get rank;
  @override
  int? get rankChange;
  @override
  DateTime? get calculatedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Display fields
  @override
  String? get userName;
  @override
  String? get periodName;

  /// Create a copy of PeriodSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeriodSummaryImplCopyWith<_$PeriodSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  String get id => throw _privateConstructorUsedError;
  String get rank => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  double get leadScore => throw _privateConstructorUsedError;
  double get lagScore => throw _privateConstructorUsedError;
  int? get rankChange => throw _privateConstructorUsedError;
  String? get branchName => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
    LeaderboardEntry value,
    $Res Function(LeaderboardEntry) then,
  ) = _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call({
    String id,
    String rank,
    String userId,
    String userName,
    double score,
    double leadScore,
    double lagScore,
    int? rankChange,
    String? branchName,
    String? profileImageUrl,
  });
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rank = null,
    Object? userId = null,
    Object? userName = null,
    Object? score = null,
    Object? leadScore = null,
    Object? lagScore = null,
    Object? rankChange = freezed,
    Object? branchName = freezed,
    Object? profileImageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            leadScore: null == leadScore
                ? _value.leadScore
                : leadScore // ignore: cast_nullable_to_non_nullable
                      as double,
            lagScore: null == lagScore
                ? _value.lagScore
                : lagScore // ignore: cast_nullable_to_non_nullable
                      as double,
            rankChange: freezed == rankChange
                ? _value.rankChange
                : rankChange // ignore: cast_nullable_to_non_nullable
                      as int?,
            branchName: freezed == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(
    _$LeaderboardEntryImpl value,
    $Res Function(_$LeaderboardEntryImpl) then,
  ) = __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String rank,
    String userId,
    String userName,
    double score,
    double leadScore,
    double lagScore,
    int? rankChange,
    String? branchName,
    String? profileImageUrl,
  });
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(
    _$LeaderboardEntryImpl _value,
    $Res Function(_$LeaderboardEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rank = null,
    Object? userId = null,
    Object? userName = null,
    Object? score = null,
    Object? leadScore = null,
    Object? lagScore = null,
    Object? rankChange = freezed,
    Object? branchName = freezed,
    Object? profileImageUrl = freezed,
  }) {
    return _then(
      _$LeaderboardEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        leadScore: null == leadScore
            ? _value.leadScore
            : leadScore // ignore: cast_nullable_to_non_nullable
                  as double,
        lagScore: null == lagScore
            ? _value.lagScore
            : lagScore // ignore: cast_nullable_to_non_nullable
                  as double,
        rankChange: freezed == rankChange
            ? _value.rankChange
            : rankChange // ignore: cast_nullable_to_non_nullable
                  as int?,
        branchName: freezed == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl extends _LeaderboardEntry {
  const _$LeaderboardEntryImpl({
    required this.id,
    required this.rank,
    required this.userId,
    required this.userName,
    required this.score,
    required this.leadScore,
    required this.lagScore,
    this.rankChange,
    this.branchName,
    this.profileImageUrl,
  }) : super._();

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String rank;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final double score;
  @override
  final double leadScore;
  @override
  final double lagScore;
  @override
  final int? rankChange;
  @override
  final String? branchName;
  @override
  final String? profileImageUrl;

  @override
  String toString() {
    return 'LeaderboardEntry(id: $id, rank: $rank, userId: $userId, userName: $userName, score: $score, leadScore: $leadScore, lagScore: $lagScore, rankChange: $rankChange, branchName: $branchName, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.leadScore, leadScore) ||
                other.leadScore == leadScore) &&
            (identical(other.lagScore, lagScore) ||
                other.lagScore == lagScore) &&
            (identical(other.rankChange, rankChange) ||
                other.rankChange == rankChange) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    rank,
    userId,
    userName,
    score,
    leadScore,
    lagScore,
    rankChange,
    branchName,
    profileImageUrl,
  );

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(this);
  }
}

abstract class _LeaderboardEntry extends LeaderboardEntry {
  const factory _LeaderboardEntry({
    required final String id,
    required final String rank,
    required final String userId,
    required final String userName,
    required final double score,
    required final double leadScore,
    required final double lagScore,
    final int? rankChange,
    final String? branchName,
    final String? profileImageUrl,
  }) = _$LeaderboardEntryImpl;
  const _LeaderboardEntry._() : super._();

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get rank;
  @override
  String get userId;
  @override
  String get userName;
  @override
  double get score;
  @override
  double get leadScore;
  @override
  double get lagScore;
  @override
  int? get rankChange;
  @override
  String? get branchName;
  @override
  String? get profileImageUrl;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  // Activities
  int get todayActivitiesCompleted => throw _privateConstructorUsedError;
  int get todayActivitiesTotal =>
      throw _privateConstructorUsedError; // Pipelines
  int get activePipelinesCount => throw _privateConstructorUsedError;
  double get totalPotentialPremium =>
      throw _privateConstructorUsedError; // Scoring
  double? get userScore => throw _privateConstructorUsedError;
  int? get userRank => throw _privateConstructorUsedError;
  int? get totalTeamMembers => throw _privateConstructorUsedError;
  int? get rankChange => throw _privateConstructorUsedError; // Weekly summary
  int get weeklyVisits => throw _privateConstructorUsedError;
  int get weeklyVisitsTarget => throw _privateConstructorUsedError;
  int get weeklyPipelinesWon => throw _privateConstructorUsedError;
  double get weeklyPremiumWon => throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
    DashboardStats value,
    $Res Function(DashboardStats) then,
  ) = _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call({
    int todayActivitiesCompleted,
    int todayActivitiesTotal,
    int activePipelinesCount,
    double totalPotentialPremium,
    double? userScore,
    int? userRank,
    int? totalTeamMembers,
    int? rankChange,
    int weeklyVisits,
    int weeklyVisitsTarget,
    int weeklyPipelinesWon,
    double weeklyPremiumWon,
  });
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayActivitiesCompleted = null,
    Object? todayActivitiesTotal = null,
    Object? activePipelinesCount = null,
    Object? totalPotentialPremium = null,
    Object? userScore = freezed,
    Object? userRank = freezed,
    Object? totalTeamMembers = freezed,
    Object? rankChange = freezed,
    Object? weeklyVisits = null,
    Object? weeklyVisitsTarget = null,
    Object? weeklyPipelinesWon = null,
    Object? weeklyPremiumWon = null,
  }) {
    return _then(
      _value.copyWith(
            todayActivitiesCompleted: null == todayActivitiesCompleted
                ? _value.todayActivitiesCompleted
                : todayActivitiesCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            todayActivitiesTotal: null == todayActivitiesTotal
                ? _value.todayActivitiesTotal
                : todayActivitiesTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            activePipelinesCount: null == activePipelinesCount
                ? _value.activePipelinesCount
                : activePipelinesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPotentialPremium: null == totalPotentialPremium
                ? _value.totalPotentialPremium
                : totalPotentialPremium // ignore: cast_nullable_to_non_nullable
                      as double,
            userScore: freezed == userScore
                ? _value.userScore
                : userScore // ignore: cast_nullable_to_non_nullable
                      as double?,
            userRank: freezed == userRank
                ? _value.userRank
                : userRank // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalTeamMembers: freezed == totalTeamMembers
                ? _value.totalTeamMembers
                : totalTeamMembers // ignore: cast_nullable_to_non_nullable
                      as int?,
            rankChange: freezed == rankChange
                ? _value.rankChange
                : rankChange // ignore: cast_nullable_to_non_nullable
                      as int?,
            weeklyVisits: null == weeklyVisits
                ? _value.weeklyVisits
                : weeklyVisits // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyVisitsTarget: null == weeklyVisitsTarget
                ? _value.weeklyVisitsTarget
                : weeklyVisitsTarget // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyPipelinesWon: null == weeklyPipelinesWon
                ? _value.weeklyPipelinesWon
                : weeklyPipelinesWon // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyPremiumWon: null == weeklyPremiumWon
                ? _value.weeklyPremiumWon
                : weeklyPremiumWon // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(
    _$DashboardStatsImpl value,
    $Res Function(_$DashboardStatsImpl) then,
  ) = __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int todayActivitiesCompleted,
    int todayActivitiesTotal,
    int activePipelinesCount,
    double totalPotentialPremium,
    double? userScore,
    int? userRank,
    int? totalTeamMembers,
    int? rankChange,
    int weeklyVisits,
    int weeklyVisitsTarget,
    int weeklyPipelinesWon,
    double weeklyPremiumWon,
  });
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
    _$DashboardStatsImpl _value,
    $Res Function(_$DashboardStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayActivitiesCompleted = null,
    Object? todayActivitiesTotal = null,
    Object? activePipelinesCount = null,
    Object? totalPotentialPremium = null,
    Object? userScore = freezed,
    Object? userRank = freezed,
    Object? totalTeamMembers = freezed,
    Object? rankChange = freezed,
    Object? weeklyVisits = null,
    Object? weeklyVisitsTarget = null,
    Object? weeklyPipelinesWon = null,
    Object? weeklyPremiumWon = null,
  }) {
    return _then(
      _$DashboardStatsImpl(
        todayActivitiesCompleted: null == todayActivitiesCompleted
            ? _value.todayActivitiesCompleted
            : todayActivitiesCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        todayActivitiesTotal: null == todayActivitiesTotal
            ? _value.todayActivitiesTotal
            : todayActivitiesTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        activePipelinesCount: null == activePipelinesCount
            ? _value.activePipelinesCount
            : activePipelinesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPotentialPremium: null == totalPotentialPremium
            ? _value.totalPotentialPremium
            : totalPotentialPremium // ignore: cast_nullable_to_non_nullable
                  as double,
        userScore: freezed == userScore
            ? _value.userScore
            : userScore // ignore: cast_nullable_to_non_nullable
                  as double?,
        userRank: freezed == userRank
            ? _value.userRank
            : userRank // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalTeamMembers: freezed == totalTeamMembers
            ? _value.totalTeamMembers
            : totalTeamMembers // ignore: cast_nullable_to_non_nullable
                  as int?,
        rankChange: freezed == rankChange
            ? _value.rankChange
            : rankChange // ignore: cast_nullable_to_non_nullable
                  as int?,
        weeklyVisits: null == weeklyVisits
            ? _value.weeklyVisits
            : weeklyVisits // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyVisitsTarget: null == weeklyVisitsTarget
            ? _value.weeklyVisitsTarget
            : weeklyVisitsTarget // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyPipelinesWon: null == weeklyPipelinesWon
            ? _value.weeklyPipelinesWon
            : weeklyPipelinesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyPremiumWon: null == weeklyPremiumWon
            ? _value.weeklyPremiumWon
            : weeklyPremiumWon // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl({
    this.todayActivitiesCompleted = 0,
    this.todayActivitiesTotal = 0,
    this.activePipelinesCount = 0,
    this.totalPotentialPremium = 0,
    this.userScore,
    this.userRank,
    this.totalTeamMembers,
    this.rankChange,
    this.weeklyVisits = 0,
    this.weeklyVisitsTarget = 0,
    this.weeklyPipelinesWon = 0,
    this.weeklyPremiumWon = 0,
  });

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  // Activities
  @override
  @JsonKey()
  final int todayActivitiesCompleted;
  @override
  @JsonKey()
  final int todayActivitiesTotal;
  // Pipelines
  @override
  @JsonKey()
  final int activePipelinesCount;
  @override
  @JsonKey()
  final double totalPotentialPremium;
  // Scoring
  @override
  final double? userScore;
  @override
  final int? userRank;
  @override
  final int? totalTeamMembers;
  @override
  final int? rankChange;
  // Weekly summary
  @override
  @JsonKey()
  final int weeklyVisits;
  @override
  @JsonKey()
  final int weeklyVisitsTarget;
  @override
  @JsonKey()
  final int weeklyPipelinesWon;
  @override
  @JsonKey()
  final double weeklyPremiumWon;

  @override
  String toString() {
    return 'DashboardStats(todayActivitiesCompleted: $todayActivitiesCompleted, todayActivitiesTotal: $todayActivitiesTotal, activePipelinesCount: $activePipelinesCount, totalPotentialPremium: $totalPotentialPremium, userScore: $userScore, userRank: $userRank, totalTeamMembers: $totalTeamMembers, rankChange: $rankChange, weeklyVisits: $weeklyVisits, weeklyVisitsTarget: $weeklyVisitsTarget, weeklyPipelinesWon: $weeklyPipelinesWon, weeklyPremiumWon: $weeklyPremiumWon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(
                  other.todayActivitiesCompleted,
                  todayActivitiesCompleted,
                ) ||
                other.todayActivitiesCompleted == todayActivitiesCompleted) &&
            (identical(other.todayActivitiesTotal, todayActivitiesTotal) ||
                other.todayActivitiesTotal == todayActivitiesTotal) &&
            (identical(other.activePipelinesCount, activePipelinesCount) ||
                other.activePipelinesCount == activePipelinesCount) &&
            (identical(other.totalPotentialPremium, totalPotentialPremium) ||
                other.totalPotentialPremium == totalPotentialPremium) &&
            (identical(other.userScore, userScore) ||
                other.userScore == userScore) &&
            (identical(other.userRank, userRank) ||
                other.userRank == userRank) &&
            (identical(other.totalTeamMembers, totalTeamMembers) ||
                other.totalTeamMembers == totalTeamMembers) &&
            (identical(other.rankChange, rankChange) ||
                other.rankChange == rankChange) &&
            (identical(other.weeklyVisits, weeklyVisits) ||
                other.weeklyVisits == weeklyVisits) &&
            (identical(other.weeklyVisitsTarget, weeklyVisitsTarget) ||
                other.weeklyVisitsTarget == weeklyVisitsTarget) &&
            (identical(other.weeklyPipelinesWon, weeklyPipelinesWon) ||
                other.weeklyPipelinesWon == weeklyPipelinesWon) &&
            (identical(other.weeklyPremiumWon, weeklyPremiumWon) ||
                other.weeklyPremiumWon == weeklyPremiumWon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    todayActivitiesCompleted,
    todayActivitiesTotal,
    activePipelinesCount,
    totalPotentialPremium,
    userScore,
    userRank,
    totalTeamMembers,
    rankChange,
    weeklyVisits,
    weeklyVisitsTarget,
    weeklyPipelinesWon,
    weeklyPremiumWon,
  );

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(this);
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats({
    final int todayActivitiesCompleted,
    final int todayActivitiesTotal,
    final int activePipelinesCount,
    final double totalPotentialPremium,
    final double? userScore,
    final int? userRank,
    final int? totalTeamMembers,
    final int? rankChange,
    final int weeklyVisits,
    final int weeklyVisitsTarget,
    final int weeklyPipelinesWon,
    final double weeklyPremiumWon,
  }) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  // Activities
  @override
  int get todayActivitiesCompleted;
  @override
  int get todayActivitiesTotal; // Pipelines
  @override
  int get activePipelinesCount;
  @override
  double get totalPotentialPremium; // Scoring
  @override
  double? get userScore;
  @override
  int? get userRank;
  @override
  int? get totalTeamMembers;
  @override
  int? get rankChange; // Weekly summary
  @override
  int get weeklyVisits;
  @override
  int get weeklyVisitsTarget;
  @override
  int get weeklyPipelinesWon;
  @override
  double get weeklyPremiumWon;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
