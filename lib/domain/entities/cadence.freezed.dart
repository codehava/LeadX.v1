// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cadence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CadenceScheduleConfig _$CadenceScheduleConfigFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceScheduleConfig.fromJson(json);
}

/// @nodoc
mixin _$CadenceScheduleConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get targetRole =>
      throw _privateConstructorUsedError; // RM, BH, BM, ROH
  String get facilitatorRole =>
      throw _privateConstructorUsedError; // BH, BM, ROH, DIRECTOR
  MeetingFrequency get frequency => throw _privateConstructorUsedError;
  int? get dayOfWeek =>
      throw _privateConstructorUsedError; // 0=Sunday, 6=Saturday (for weekly)
  int? get dayOfMonth =>
      throw _privateConstructorUsedError; // 1-31 (for monthly)
  String? get defaultTime => throw _privateConstructorUsedError; // HH:mm format
  int get durationMinutes => throw _privateConstructorUsedError;
  int get preMeetingHours =>
      throw _privateConstructorUsedError; // Hours before meeting for form deadline
  bool get isActive => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CadenceScheduleConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceScheduleConfigCopyWith<CadenceScheduleConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceScheduleConfigCopyWith<$Res> {
  factory $CadenceScheduleConfigCopyWith(
    CadenceScheduleConfig value,
    $Res Function(CadenceScheduleConfig) then,
  ) = _$CadenceScheduleConfigCopyWithImpl<$Res, CadenceScheduleConfig>;
  @useResult
  $Res call({
    String id,
    String name,
    String targetRole,
    String facilitatorRole,
    MeetingFrequency frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    String? defaultTime,
    int durationMinutes,
    int preMeetingHours,
    bool isActive,
    String? description,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CadenceScheduleConfigCopyWithImpl<
  $Res,
  $Val extends CadenceScheduleConfig
>
    implements $CadenceScheduleConfigCopyWith<$Res> {
  _$CadenceScheduleConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetRole = null,
    Object? facilitatorRole = null,
    Object? frequency = null,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = null,
    Object? preMeetingHours = null,
    Object? isActive = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            targetRole: null == targetRole
                ? _value.targetRole
                : targetRole // ignore: cast_nullable_to_non_nullable
                      as String,
            facilitatorRole: null == facilitatorRole
                ? _value.facilitatorRole
                : facilitatorRole // ignore: cast_nullable_to_non_nullable
                      as String,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as MeetingFrequency,
            dayOfWeek: freezed == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as int?,
            dayOfMonth: freezed == dayOfMonth
                ? _value.dayOfMonth
                : dayOfMonth // ignore: cast_nullable_to_non_nullable
                      as int?,
            defaultTime: freezed == defaultTime
                ? _value.defaultTime
                : defaultTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            preMeetingHours: null == preMeetingHours
                ? _value.preMeetingHours
                : preMeetingHours // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CadenceScheduleConfigImplCopyWith<$Res>
    implements $CadenceScheduleConfigCopyWith<$Res> {
  factory _$$CadenceScheduleConfigImplCopyWith(
    _$CadenceScheduleConfigImpl value,
    $Res Function(_$CadenceScheduleConfigImpl) then,
  ) = __$$CadenceScheduleConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String targetRole,
    String facilitatorRole,
    MeetingFrequency frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    String? defaultTime,
    int durationMinutes,
    int preMeetingHours,
    bool isActive,
    String? description,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CadenceScheduleConfigImplCopyWithImpl<$Res>
    extends
        _$CadenceScheduleConfigCopyWithImpl<$Res, _$CadenceScheduleConfigImpl>
    implements _$$CadenceScheduleConfigImplCopyWith<$Res> {
  __$$CadenceScheduleConfigImplCopyWithImpl(
    _$CadenceScheduleConfigImpl _value,
    $Res Function(_$CadenceScheduleConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetRole = null,
    Object? facilitatorRole = null,
    Object? frequency = null,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = null,
    Object? preMeetingHours = null,
    Object? isActive = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CadenceScheduleConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        targetRole: null == targetRole
            ? _value.targetRole
            : targetRole // ignore: cast_nullable_to_non_nullable
                  as String,
        facilitatorRole: null == facilitatorRole
            ? _value.facilitatorRole
            : facilitatorRole // ignore: cast_nullable_to_non_nullable
                  as String,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as MeetingFrequency,
        dayOfWeek: freezed == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as int?,
        dayOfMonth: freezed == dayOfMonth
            ? _value.dayOfMonth
            : dayOfMonth // ignore: cast_nullable_to_non_nullable
                  as int?,
        defaultTime: freezed == defaultTime
            ? _value.defaultTime
            : defaultTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        preMeetingHours: null == preMeetingHours
            ? _value.preMeetingHours
            : preMeetingHours // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
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
class _$CadenceScheduleConfigImpl extends _CadenceScheduleConfig {
  const _$CadenceScheduleConfigImpl({
    required this.id,
    required this.name,
    required this.targetRole,
    required this.facilitatorRole,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.defaultTime,
    this.durationMinutes = 60,
    this.preMeetingHours = 24,
    this.isActive = true,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$CadenceScheduleConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceScheduleConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String targetRole;
  // RM, BH, BM, ROH
  @override
  final String facilitatorRole;
  // BH, BM, ROH, DIRECTOR
  @override
  final MeetingFrequency frequency;
  @override
  final int? dayOfWeek;
  // 0=Sunday, 6=Saturday (for weekly)
  @override
  final int? dayOfMonth;
  // 1-31 (for monthly)
  @override
  final String? defaultTime;
  // HH:mm format
  @override
  @JsonKey()
  final int durationMinutes;
  @override
  @JsonKey()
  final int preMeetingHours;
  // Hours before meeting for form deadline
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? description;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CadenceScheduleConfig(id: $id, name: $name, targetRole: $targetRole, facilitatorRole: $facilitatorRole, frequency: $frequency, dayOfWeek: $dayOfWeek, dayOfMonth: $dayOfMonth, defaultTime: $defaultTime, durationMinutes: $durationMinutes, preMeetingHours: $preMeetingHours, isActive: $isActive, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceScheduleConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetRole, targetRole) ||
                other.targetRole == targetRole) &&
            (identical(other.facilitatorRole, facilitatorRole) ||
                other.facilitatorRole == facilitatorRole) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.defaultTime, defaultTime) ||
                other.defaultTime == defaultTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.preMeetingHours, preMeetingHours) ||
                other.preMeetingHours == preMeetingHours) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.description, description) ||
                other.description == description) &&
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
    targetRole,
    facilitatorRole,
    frequency,
    dayOfWeek,
    dayOfMonth,
    defaultTime,
    durationMinutes,
    preMeetingHours,
    isActive,
    description,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CadenceScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceScheduleConfigImplCopyWith<_$CadenceScheduleConfigImpl>
  get copyWith =>
      __$$CadenceScheduleConfigImplCopyWithImpl<_$CadenceScheduleConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceScheduleConfigImplToJson(this);
  }
}

abstract class _CadenceScheduleConfig extends CadenceScheduleConfig {
  const factory _CadenceScheduleConfig({
    required final String id,
    required final String name,
    required final String targetRole,
    required final String facilitatorRole,
    required final MeetingFrequency frequency,
    final int? dayOfWeek,
    final int? dayOfMonth,
    final String? defaultTime,
    final int durationMinutes,
    final int preMeetingHours,
    final bool isActive,
    final String? description,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CadenceScheduleConfigImpl;
  const _CadenceScheduleConfig._() : super._();

  factory _CadenceScheduleConfig.fromJson(Map<String, dynamic> json) =
      _$CadenceScheduleConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get targetRole; // RM, BH, BM, ROH
  @override
  String get facilitatorRole; // BH, BM, ROH, DIRECTOR
  @override
  MeetingFrequency get frequency;
  @override
  int? get dayOfWeek; // 0=Sunday, 6=Saturday (for weekly)
  @override
  int? get dayOfMonth; // 1-31 (for monthly)
  @override
  String? get defaultTime; // HH:mm format
  @override
  int get durationMinutes;
  @override
  int get preMeetingHours; // Hours before meeting for form deadline
  @override
  bool get isActive;
  @override
  String? get description;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CadenceScheduleConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceScheduleConfigImplCopyWith<_$CadenceScheduleConfigImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceMeeting _$CadenceMeetingFromJson(Map<String, dynamic> json) {
  return _CadenceMeeting.fromJson(json);
}

/// @nodoc
mixin _$CadenceMeeting {
  String get id => throw _privateConstructorUsedError;
  String get configId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  String get facilitatorId => throw _privateConstructorUsedError;
  MeetingStatus get status => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get meetingLink => throw _privateConstructorUsedError;
  String? get agenda => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Computed/joined fields
  String? get facilitatorName => throw _privateConstructorUsedError;
  String? get configName => throw _privateConstructorUsedError;
  int? get totalParticipants => throw _privateConstructorUsedError;
  int? get submittedFormCount => throw _privateConstructorUsedError;
  int? get presentCount =>
      throw _privateConstructorUsedError; // Config reference (for deadline calculation)
  int? get preMeetingHours => throw _privateConstructorUsedError;

  /// Serializes this CadenceMeeting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceMeeting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceMeetingCopyWith<CadenceMeeting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceMeetingCopyWith<$Res> {
  factory $CadenceMeetingCopyWith(
    CadenceMeeting value,
    $Res Function(CadenceMeeting) then,
  ) = _$CadenceMeetingCopyWithImpl<$Res, CadenceMeeting>;
  @useResult
  $Res call({
    String id,
    String configId,
    String title,
    DateTime scheduledAt,
    int durationMinutes,
    String facilitatorId,
    MeetingStatus status,
    String? location,
    String? meetingLink,
    String? agenda,
    String? notes,
    DateTime? startedAt,
    DateTime? completedAt,
    String createdBy,
    bool isPendingSync,
    DateTime createdAt,
    DateTime updatedAt,
    String? facilitatorName,
    String? configName,
    int? totalParticipants,
    int? submittedFormCount,
    int? presentCount,
    int? preMeetingHours,
  });
}

/// @nodoc
class _$CadenceMeetingCopyWithImpl<$Res, $Val extends CadenceMeeting>
    implements $CadenceMeetingCopyWith<$Res> {
  _$CadenceMeetingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceMeeting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? configId = null,
    Object? title = null,
    Object? scheduledAt = null,
    Object? durationMinutes = null,
    Object? facilitatorId = null,
    Object? status = null,
    Object? location = freezed,
    Object? meetingLink = freezed,
    Object? agenda = freezed,
    Object? notes = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdBy = null,
    Object? isPendingSync = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? facilitatorName = freezed,
    Object? configName = freezed,
    Object? totalParticipants = freezed,
    Object? submittedFormCount = freezed,
    Object? presentCount = freezed,
    Object? preMeetingHours = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            configId: null == configId
                ? _value.configId
                : configId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            facilitatorId: null == facilitatorId
                ? _value.facilitatorId
                : facilitatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MeetingStatus,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            meetingLink: freezed == meetingLink
                ? _value.meetingLink
                : meetingLink // ignore: cast_nullable_to_non_nullable
                      as String?,
            agenda: freezed == agenda
                ? _value.agenda
                : agenda // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            isPendingSync: null == isPendingSync
                ? _value.isPendingSync
                : isPendingSync // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            facilitatorName: freezed == facilitatorName
                ? _value.facilitatorName
                : facilitatorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            configName: freezed == configName
                ? _value.configName
                : configName // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalParticipants: freezed == totalParticipants
                ? _value.totalParticipants
                : totalParticipants // ignore: cast_nullable_to_non_nullable
                      as int?,
            submittedFormCount: freezed == submittedFormCount
                ? _value.submittedFormCount
                : submittedFormCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            presentCount: freezed == presentCount
                ? _value.presentCount
                : presentCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            preMeetingHours: freezed == preMeetingHours
                ? _value.preMeetingHours
                : preMeetingHours // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceMeetingImplCopyWith<$Res>
    implements $CadenceMeetingCopyWith<$Res> {
  factory _$$CadenceMeetingImplCopyWith(
    _$CadenceMeetingImpl value,
    $Res Function(_$CadenceMeetingImpl) then,
  ) = __$$CadenceMeetingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String configId,
    String title,
    DateTime scheduledAt,
    int durationMinutes,
    String facilitatorId,
    MeetingStatus status,
    String? location,
    String? meetingLink,
    String? agenda,
    String? notes,
    DateTime? startedAt,
    DateTime? completedAt,
    String createdBy,
    bool isPendingSync,
    DateTime createdAt,
    DateTime updatedAt,
    String? facilitatorName,
    String? configName,
    int? totalParticipants,
    int? submittedFormCount,
    int? presentCount,
    int? preMeetingHours,
  });
}

/// @nodoc
class __$$CadenceMeetingImplCopyWithImpl<$Res>
    extends _$CadenceMeetingCopyWithImpl<$Res, _$CadenceMeetingImpl>
    implements _$$CadenceMeetingImplCopyWith<$Res> {
  __$$CadenceMeetingImplCopyWithImpl(
    _$CadenceMeetingImpl _value,
    $Res Function(_$CadenceMeetingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceMeeting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? configId = null,
    Object? title = null,
    Object? scheduledAt = null,
    Object? durationMinutes = null,
    Object? facilitatorId = null,
    Object? status = null,
    Object? location = freezed,
    Object? meetingLink = freezed,
    Object? agenda = freezed,
    Object? notes = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdBy = null,
    Object? isPendingSync = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? facilitatorName = freezed,
    Object? configName = freezed,
    Object? totalParticipants = freezed,
    Object? submittedFormCount = freezed,
    Object? presentCount = freezed,
    Object? preMeetingHours = freezed,
  }) {
    return _then(
      _$CadenceMeetingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        configId: null == configId
            ? _value.configId
            : configId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        facilitatorId: null == facilitatorId
            ? _value.facilitatorId
            : facilitatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MeetingStatus,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        meetingLink: freezed == meetingLink
            ? _value.meetingLink
            : meetingLink // ignore: cast_nullable_to_non_nullable
                  as String?,
        agenda: freezed == agenda
            ? _value.agenda
            : agenda // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        isPendingSync: null == isPendingSync
            ? _value.isPendingSync
            : isPendingSync // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        facilitatorName: freezed == facilitatorName
            ? _value.facilitatorName
            : facilitatorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        configName: freezed == configName
            ? _value.configName
            : configName // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalParticipants: freezed == totalParticipants
            ? _value.totalParticipants
            : totalParticipants // ignore: cast_nullable_to_non_nullable
                  as int?,
        submittedFormCount: freezed == submittedFormCount
            ? _value.submittedFormCount
            : submittedFormCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        presentCount: freezed == presentCount
            ? _value.presentCount
            : presentCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        preMeetingHours: freezed == preMeetingHours
            ? _value.preMeetingHours
            : preMeetingHours // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceMeetingImpl extends _CadenceMeeting {
  const _$CadenceMeetingImpl({
    required this.id,
    required this.configId,
    required this.title,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.facilitatorId,
    this.status = MeetingStatus.scheduled,
    this.location,
    this.meetingLink,
    this.agenda,
    this.notes,
    this.startedAt,
    this.completedAt,
    required this.createdBy,
    this.isPendingSync = false,
    required this.createdAt,
    required this.updatedAt,
    this.facilitatorName,
    this.configName,
    this.totalParticipants,
    this.submittedFormCount,
    this.presentCount,
    this.preMeetingHours,
  }) : super._();

  factory _$CadenceMeetingImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceMeetingImplFromJson(json);

  @override
  final String id;
  @override
  final String configId;
  @override
  final String title;
  @override
  final DateTime scheduledAt;
  @override
  final int durationMinutes;
  @override
  final String facilitatorId;
  @override
  @JsonKey()
  final MeetingStatus status;
  @override
  final String? location;
  @override
  final String? meetingLink;
  @override
  final String? agenda;
  @override
  final String? notes;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String createdBy;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  // Computed/joined fields
  @override
  final String? facilitatorName;
  @override
  final String? configName;
  @override
  final int? totalParticipants;
  @override
  final int? submittedFormCount;
  @override
  final int? presentCount;
  // Config reference (for deadline calculation)
  @override
  final int? preMeetingHours;

  @override
  String toString() {
    return 'CadenceMeeting(id: $id, configId: $configId, title: $title, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, facilitatorId: $facilitatorId, status: $status, location: $location, meetingLink: $meetingLink, agenda: $agenda, notes: $notes, startedAt: $startedAt, completedAt: $completedAt, createdBy: $createdBy, isPendingSync: $isPendingSync, createdAt: $createdAt, updatedAt: $updatedAt, facilitatorName: $facilitatorName, configName: $configName, totalParticipants: $totalParticipants, submittedFormCount: $submittedFormCount, presentCount: $presentCount, preMeetingHours: $preMeetingHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceMeetingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.configId, configId) ||
                other.configId == configId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.facilitatorId, facilitatorId) ||
                other.facilitatorId == facilitatorId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.meetingLink, meetingLink) ||
                other.meetingLink == meetingLink) &&
            (identical(other.agenda, agenda) || other.agenda == agenda) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.facilitatorName, facilitatorName) ||
                other.facilitatorName == facilitatorName) &&
            (identical(other.configName, configName) ||
                other.configName == configName) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.submittedFormCount, submittedFormCount) ||
                other.submittedFormCount == submittedFormCount) &&
            (identical(other.presentCount, presentCount) ||
                other.presentCount == presentCount) &&
            (identical(other.preMeetingHours, preMeetingHours) ||
                other.preMeetingHours == preMeetingHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    configId,
    title,
    scheduledAt,
    durationMinutes,
    facilitatorId,
    status,
    location,
    meetingLink,
    agenda,
    notes,
    startedAt,
    completedAt,
    createdBy,
    isPendingSync,
    createdAt,
    updatedAt,
    facilitatorName,
    configName,
    totalParticipants,
    submittedFormCount,
    presentCount,
    preMeetingHours,
  ]);

  /// Create a copy of CadenceMeeting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceMeetingImplCopyWith<_$CadenceMeetingImpl> get copyWith =>
      __$$CadenceMeetingImplCopyWithImpl<_$CadenceMeetingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceMeetingImplToJson(this);
  }
}

abstract class _CadenceMeeting extends CadenceMeeting {
  const factory _CadenceMeeting({
    required final String id,
    required final String configId,
    required final String title,
    required final DateTime scheduledAt,
    required final int durationMinutes,
    required final String facilitatorId,
    final MeetingStatus status,
    final String? location,
    final String? meetingLink,
    final String? agenda,
    final String? notes,
    final DateTime? startedAt,
    final DateTime? completedAt,
    required final String createdBy,
    final bool isPendingSync,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? facilitatorName,
    final String? configName,
    final int? totalParticipants,
    final int? submittedFormCount,
    final int? presentCount,
    final int? preMeetingHours,
  }) = _$CadenceMeetingImpl;
  const _CadenceMeeting._() : super._();

  factory _CadenceMeeting.fromJson(Map<String, dynamic> json) =
      _$CadenceMeetingImpl.fromJson;

  @override
  String get id;
  @override
  String get configId;
  @override
  String get title;
  @override
  DateTime get scheduledAt;
  @override
  int get durationMinutes;
  @override
  String get facilitatorId;
  @override
  MeetingStatus get status;
  @override
  String? get location;
  @override
  String? get meetingLink;
  @override
  String? get agenda;
  @override
  String? get notes;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String get createdBy;
  @override
  bool get isPendingSync;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // Computed/joined fields
  @override
  String? get facilitatorName;
  @override
  String? get configName;
  @override
  int? get totalParticipants;
  @override
  int? get submittedFormCount;
  @override
  int? get presentCount; // Config reference (for deadline calculation)
  @override
  int? get preMeetingHours;

  /// Create a copy of CadenceMeeting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceMeetingImplCopyWith<_$CadenceMeetingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CadenceParticipant _$CadenceParticipantFromJson(Map<String, dynamic> json) {
  return _CadenceParticipant.fromJson(json);
}

/// @nodoc
mixin _$CadenceParticipant {
  String get id => throw _privateConstructorUsedError;
  String get meetingId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError; // Attendance
  AttendanceStatus get attendanceStatus => throw _privateConstructorUsedError;
  DateTime? get arrivedAt => throw _privateConstructorUsedError;
  String? get excusedReason => throw _privateConstructorUsedError;
  int? get attendanceScoreImpact => throw _privateConstructorUsedError;
  String? get markedBy => throw _privateConstructorUsedError;
  DateTime? get markedAt =>
      throw _privateConstructorUsedError; // Pre-meeting form (Q1-Q4)
  bool get preMeetingSubmitted => throw _privateConstructorUsedError;
  String? get q1PreviousCommitment =>
      throw _privateConstructorUsedError; // Auto-filled from last meeting's Q4
  CommitmentCompletionStatus? get q1CompletionStatus =>
      throw _privateConstructorUsedError;
  String? get q2WhatAchieved => throw _privateConstructorUsedError; // Required
  String? get q3Obstacles => throw _privateConstructorUsedError; // Optional
  String? get q4NextCommitment =>
      throw _privateConstructorUsedError; // Required
  DateTime? get formSubmittedAt => throw _privateConstructorUsedError;
  FormSubmissionStatus? get formSubmissionStatus =>
      throw _privateConstructorUsedError;
  int? get formScoreImpact =>
      throw _privateConstructorUsedError; // Host notes & feedback
  String? get hostNotes =>
      throw _privateConstructorUsedError; // Internal notes (not visible to participant)
  String? get feedbackText =>
      throw _privateConstructorUsedError; // Formal feedback visible to participant
  DateTime? get feedbackGivenAt => throw _privateConstructorUsedError;
  DateTime? get feedbackUpdatedAt => throw _privateConstructorUsedError; // Sync
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError; // Joined fields
  String? get userName => throw _privateConstructorUsedError;
  String? get userRole => throw _privateConstructorUsedError;

  /// Serializes this CadenceParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceParticipantCopyWith<CadenceParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceParticipantCopyWith<$Res> {
  factory $CadenceParticipantCopyWith(
    CadenceParticipant value,
    $Res Function(CadenceParticipant) then,
  ) = _$CadenceParticipantCopyWithImpl<$Res, CadenceParticipant>;
  @useResult
  $Res call({
    String id,
    String meetingId,
    String userId,
    AttendanceStatus attendanceStatus,
    DateTime? arrivedAt,
    String? excusedReason,
    int? attendanceScoreImpact,
    String? markedBy,
    DateTime? markedAt,
    bool preMeetingSubmitted,
    String? q1PreviousCommitment,
    CommitmentCompletionStatus? q1CompletionStatus,
    String? q2WhatAchieved,
    String? q3Obstacles,
    String? q4NextCommitment,
    DateTime? formSubmittedAt,
    FormSubmissionStatus? formSubmissionStatus,
    int? formScoreImpact,
    String? hostNotes,
    String? feedbackText,
    DateTime? feedbackGivenAt,
    DateTime? feedbackUpdatedAt,
    bool isPendingSync,
    DateTime? lastSyncAt,
    DateTime createdAt,
    DateTime updatedAt,
    String? userName,
    String? userRole,
  });
}

/// @nodoc
class _$CadenceParticipantCopyWithImpl<$Res, $Val extends CadenceParticipant>
    implements $CadenceParticipantCopyWith<$Res> {
  _$CadenceParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? meetingId = null,
    Object? userId = null,
    Object? attendanceStatus = null,
    Object? arrivedAt = freezed,
    Object? excusedReason = freezed,
    Object? attendanceScoreImpact = freezed,
    Object? markedBy = freezed,
    Object? markedAt = freezed,
    Object? preMeetingSubmitted = null,
    Object? q1PreviousCommitment = freezed,
    Object? q1CompletionStatus = freezed,
    Object? q2WhatAchieved = freezed,
    Object? q3Obstacles = freezed,
    Object? q4NextCommitment = freezed,
    Object? formSubmittedAt = freezed,
    Object? formSubmissionStatus = freezed,
    Object? formScoreImpact = freezed,
    Object? hostNotes = freezed,
    Object? feedbackText = freezed,
    Object? feedbackGivenAt = freezed,
    Object? feedbackUpdatedAt = freezed,
    Object? isPendingSync = null,
    Object? lastSyncAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userName = freezed,
    Object? userRole = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            meetingId: null == meetingId
                ? _value.meetingId
                : meetingId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            attendanceStatus: null == attendanceStatus
                ? _value.attendanceStatus
                : attendanceStatus // ignore: cast_nullable_to_non_nullable
                      as AttendanceStatus,
            arrivedAt: freezed == arrivedAt
                ? _value.arrivedAt
                : arrivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            excusedReason: freezed == excusedReason
                ? _value.excusedReason
                : excusedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            attendanceScoreImpact: freezed == attendanceScoreImpact
                ? _value.attendanceScoreImpact
                : attendanceScoreImpact // ignore: cast_nullable_to_non_nullable
                      as int?,
            markedBy: freezed == markedBy
                ? _value.markedBy
                : markedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            markedAt: freezed == markedAt
                ? _value.markedAt
                : markedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            preMeetingSubmitted: null == preMeetingSubmitted
                ? _value.preMeetingSubmitted
                : preMeetingSubmitted // ignore: cast_nullable_to_non_nullable
                      as bool,
            q1PreviousCommitment: freezed == q1PreviousCommitment
                ? _value.q1PreviousCommitment
                : q1PreviousCommitment // ignore: cast_nullable_to_non_nullable
                      as String?,
            q1CompletionStatus: freezed == q1CompletionStatus
                ? _value.q1CompletionStatus
                : q1CompletionStatus // ignore: cast_nullable_to_non_nullable
                      as CommitmentCompletionStatus?,
            q2WhatAchieved: freezed == q2WhatAchieved
                ? _value.q2WhatAchieved
                : q2WhatAchieved // ignore: cast_nullable_to_non_nullable
                      as String?,
            q3Obstacles: freezed == q3Obstacles
                ? _value.q3Obstacles
                : q3Obstacles // ignore: cast_nullable_to_non_nullable
                      as String?,
            q4NextCommitment: freezed == q4NextCommitment
                ? _value.q4NextCommitment
                : q4NextCommitment // ignore: cast_nullable_to_non_nullable
                      as String?,
            formSubmittedAt: freezed == formSubmittedAt
                ? _value.formSubmittedAt
                : formSubmittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            formSubmissionStatus: freezed == formSubmissionStatus
                ? _value.formSubmissionStatus
                : formSubmissionStatus // ignore: cast_nullable_to_non_nullable
                      as FormSubmissionStatus?,
            formScoreImpact: freezed == formScoreImpact
                ? _value.formScoreImpact
                : formScoreImpact // ignore: cast_nullable_to_non_nullable
                      as int?,
            hostNotes: freezed == hostNotes
                ? _value.hostNotes
                : hostNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            feedbackText: freezed == feedbackText
                ? _value.feedbackText
                : feedbackText // ignore: cast_nullable_to_non_nullable
                      as String?,
            feedbackGivenAt: freezed == feedbackGivenAt
                ? _value.feedbackGivenAt
                : feedbackGivenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            feedbackUpdatedAt: freezed == feedbackUpdatedAt
                ? _value.feedbackUpdatedAt
                : feedbackUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isPendingSync: null == isPendingSync
                ? _value.isPendingSync
                : isPendingSync // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSyncAt: freezed == lastSyncAt
                ? _value.lastSyncAt
                : lastSyncAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            userRole: freezed == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceParticipantImplCopyWith<$Res>
    implements $CadenceParticipantCopyWith<$Res> {
  factory _$$CadenceParticipantImplCopyWith(
    _$CadenceParticipantImpl value,
    $Res Function(_$CadenceParticipantImpl) then,
  ) = __$$CadenceParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String meetingId,
    String userId,
    AttendanceStatus attendanceStatus,
    DateTime? arrivedAt,
    String? excusedReason,
    int? attendanceScoreImpact,
    String? markedBy,
    DateTime? markedAt,
    bool preMeetingSubmitted,
    String? q1PreviousCommitment,
    CommitmentCompletionStatus? q1CompletionStatus,
    String? q2WhatAchieved,
    String? q3Obstacles,
    String? q4NextCommitment,
    DateTime? formSubmittedAt,
    FormSubmissionStatus? formSubmissionStatus,
    int? formScoreImpact,
    String? hostNotes,
    String? feedbackText,
    DateTime? feedbackGivenAt,
    DateTime? feedbackUpdatedAt,
    bool isPendingSync,
    DateTime? lastSyncAt,
    DateTime createdAt,
    DateTime updatedAt,
    String? userName,
    String? userRole,
  });
}

/// @nodoc
class __$$CadenceParticipantImplCopyWithImpl<$Res>
    extends _$CadenceParticipantCopyWithImpl<$Res, _$CadenceParticipantImpl>
    implements _$$CadenceParticipantImplCopyWith<$Res> {
  __$$CadenceParticipantImplCopyWithImpl(
    _$CadenceParticipantImpl _value,
    $Res Function(_$CadenceParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? meetingId = null,
    Object? userId = null,
    Object? attendanceStatus = null,
    Object? arrivedAt = freezed,
    Object? excusedReason = freezed,
    Object? attendanceScoreImpact = freezed,
    Object? markedBy = freezed,
    Object? markedAt = freezed,
    Object? preMeetingSubmitted = null,
    Object? q1PreviousCommitment = freezed,
    Object? q1CompletionStatus = freezed,
    Object? q2WhatAchieved = freezed,
    Object? q3Obstacles = freezed,
    Object? q4NextCommitment = freezed,
    Object? formSubmittedAt = freezed,
    Object? formSubmissionStatus = freezed,
    Object? formScoreImpact = freezed,
    Object? hostNotes = freezed,
    Object? feedbackText = freezed,
    Object? feedbackGivenAt = freezed,
    Object? feedbackUpdatedAt = freezed,
    Object? isPendingSync = null,
    Object? lastSyncAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userName = freezed,
    Object? userRole = freezed,
  }) {
    return _then(
      _$CadenceParticipantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        meetingId: null == meetingId
            ? _value.meetingId
            : meetingId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        attendanceStatus: null == attendanceStatus
            ? _value.attendanceStatus
            : attendanceStatus // ignore: cast_nullable_to_non_nullable
                  as AttendanceStatus,
        arrivedAt: freezed == arrivedAt
            ? _value.arrivedAt
            : arrivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        excusedReason: freezed == excusedReason
            ? _value.excusedReason
            : excusedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        attendanceScoreImpact: freezed == attendanceScoreImpact
            ? _value.attendanceScoreImpact
            : attendanceScoreImpact // ignore: cast_nullable_to_non_nullable
                  as int?,
        markedBy: freezed == markedBy
            ? _value.markedBy
            : markedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        markedAt: freezed == markedAt
            ? _value.markedAt
            : markedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        preMeetingSubmitted: null == preMeetingSubmitted
            ? _value.preMeetingSubmitted
            : preMeetingSubmitted // ignore: cast_nullable_to_non_nullable
                  as bool,
        q1PreviousCommitment: freezed == q1PreviousCommitment
            ? _value.q1PreviousCommitment
            : q1PreviousCommitment // ignore: cast_nullable_to_non_nullable
                  as String?,
        q1CompletionStatus: freezed == q1CompletionStatus
            ? _value.q1CompletionStatus
            : q1CompletionStatus // ignore: cast_nullable_to_non_nullable
                  as CommitmentCompletionStatus?,
        q2WhatAchieved: freezed == q2WhatAchieved
            ? _value.q2WhatAchieved
            : q2WhatAchieved // ignore: cast_nullable_to_non_nullable
                  as String?,
        q3Obstacles: freezed == q3Obstacles
            ? _value.q3Obstacles
            : q3Obstacles // ignore: cast_nullable_to_non_nullable
                  as String?,
        q4NextCommitment: freezed == q4NextCommitment
            ? _value.q4NextCommitment
            : q4NextCommitment // ignore: cast_nullable_to_non_nullable
                  as String?,
        formSubmittedAt: freezed == formSubmittedAt
            ? _value.formSubmittedAt
            : formSubmittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        formSubmissionStatus: freezed == formSubmissionStatus
            ? _value.formSubmissionStatus
            : formSubmissionStatus // ignore: cast_nullable_to_non_nullable
                  as FormSubmissionStatus?,
        formScoreImpact: freezed == formScoreImpact
            ? _value.formScoreImpact
            : formScoreImpact // ignore: cast_nullable_to_non_nullable
                  as int?,
        hostNotes: freezed == hostNotes
            ? _value.hostNotes
            : hostNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        feedbackText: freezed == feedbackText
            ? _value.feedbackText
            : feedbackText // ignore: cast_nullable_to_non_nullable
                  as String?,
        feedbackGivenAt: freezed == feedbackGivenAt
            ? _value.feedbackGivenAt
            : feedbackGivenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        feedbackUpdatedAt: freezed == feedbackUpdatedAt
            ? _value.feedbackUpdatedAt
            : feedbackUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isPendingSync: null == isPendingSync
            ? _value.isPendingSync
            : isPendingSync // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSyncAt: freezed == lastSyncAt
            ? _value.lastSyncAt
            : lastSyncAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        userRole: freezed == userRole
            ? _value.userRole
            : userRole // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceParticipantImpl extends _CadenceParticipant {
  const _$CadenceParticipantImpl({
    required this.id,
    required this.meetingId,
    required this.userId,
    this.attendanceStatus = AttendanceStatus.pending,
    this.arrivedAt,
    this.excusedReason,
    this.attendanceScoreImpact,
    this.markedBy,
    this.markedAt,
    this.preMeetingSubmitted = false,
    this.q1PreviousCommitment,
    this.q1CompletionStatus,
    this.q2WhatAchieved,
    this.q3Obstacles,
    this.q4NextCommitment,
    this.formSubmittedAt,
    this.formSubmissionStatus,
    this.formScoreImpact,
    this.hostNotes,
    this.feedbackText,
    this.feedbackGivenAt,
    this.feedbackUpdatedAt,
    this.isPendingSync = false,
    this.lastSyncAt,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userRole,
  }) : super._();

  factory _$CadenceParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceParticipantImplFromJson(json);

  @override
  final String id;
  @override
  final String meetingId;
  @override
  final String userId;
  // Attendance
  @override
  @JsonKey()
  final AttendanceStatus attendanceStatus;
  @override
  final DateTime? arrivedAt;
  @override
  final String? excusedReason;
  @override
  final int? attendanceScoreImpact;
  @override
  final String? markedBy;
  @override
  final DateTime? markedAt;
  // Pre-meeting form (Q1-Q4)
  @override
  @JsonKey()
  final bool preMeetingSubmitted;
  @override
  final String? q1PreviousCommitment;
  // Auto-filled from last meeting's Q4
  @override
  final CommitmentCompletionStatus? q1CompletionStatus;
  @override
  final String? q2WhatAchieved;
  // Required
  @override
  final String? q3Obstacles;
  // Optional
  @override
  final String? q4NextCommitment;
  // Required
  @override
  final DateTime? formSubmittedAt;
  @override
  final FormSubmissionStatus? formSubmissionStatus;
  @override
  final int? formScoreImpact;
  // Host notes & feedback
  @override
  final String? hostNotes;
  // Internal notes (not visible to participant)
  @override
  final String? feedbackText;
  // Formal feedback visible to participant
  @override
  final DateTime? feedbackGivenAt;
  @override
  final DateTime? feedbackUpdatedAt;
  // Sync
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime? lastSyncAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  // Joined fields
  @override
  final String? userName;
  @override
  final String? userRole;

  @override
  String toString() {
    return 'CadenceParticipant(id: $id, meetingId: $meetingId, userId: $userId, attendanceStatus: $attendanceStatus, arrivedAt: $arrivedAt, excusedReason: $excusedReason, attendanceScoreImpact: $attendanceScoreImpact, markedBy: $markedBy, markedAt: $markedAt, preMeetingSubmitted: $preMeetingSubmitted, q1PreviousCommitment: $q1PreviousCommitment, q1CompletionStatus: $q1CompletionStatus, q2WhatAchieved: $q2WhatAchieved, q3Obstacles: $q3Obstacles, q4NextCommitment: $q4NextCommitment, formSubmittedAt: $formSubmittedAt, formSubmissionStatus: $formSubmissionStatus, formScoreImpact: $formScoreImpact, hostNotes: $hostNotes, feedbackText: $feedbackText, feedbackGivenAt: $feedbackGivenAt, feedbackUpdatedAt: $feedbackUpdatedAt, isPendingSync: $isPendingSync, lastSyncAt: $lastSyncAt, createdAt: $createdAt, updatedAt: $updatedAt, userName: $userName, userRole: $userRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceParticipantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.arrivedAt, arrivedAt) ||
                other.arrivedAt == arrivedAt) &&
            (identical(other.excusedReason, excusedReason) ||
                other.excusedReason == excusedReason) &&
            (identical(other.attendanceScoreImpact, attendanceScoreImpact) ||
                other.attendanceScoreImpact == attendanceScoreImpact) &&
            (identical(other.markedBy, markedBy) ||
                other.markedBy == markedBy) &&
            (identical(other.markedAt, markedAt) ||
                other.markedAt == markedAt) &&
            (identical(other.preMeetingSubmitted, preMeetingSubmitted) ||
                other.preMeetingSubmitted == preMeetingSubmitted) &&
            (identical(other.q1PreviousCommitment, q1PreviousCommitment) ||
                other.q1PreviousCommitment == q1PreviousCommitment) &&
            (identical(other.q1CompletionStatus, q1CompletionStatus) ||
                other.q1CompletionStatus == q1CompletionStatus) &&
            (identical(other.q2WhatAchieved, q2WhatAchieved) ||
                other.q2WhatAchieved == q2WhatAchieved) &&
            (identical(other.q3Obstacles, q3Obstacles) ||
                other.q3Obstacles == q3Obstacles) &&
            (identical(other.q4NextCommitment, q4NextCommitment) ||
                other.q4NextCommitment == q4NextCommitment) &&
            (identical(other.formSubmittedAt, formSubmittedAt) ||
                other.formSubmittedAt == formSubmittedAt) &&
            (identical(other.formSubmissionStatus, formSubmissionStatus) ||
                other.formSubmissionStatus == formSubmissionStatus) &&
            (identical(other.formScoreImpact, formScoreImpact) ||
                other.formScoreImpact == formScoreImpact) &&
            (identical(other.hostNotes, hostNotes) ||
                other.hostNotes == hostNotes) &&
            (identical(other.feedbackText, feedbackText) ||
                other.feedbackText == feedbackText) &&
            (identical(other.feedbackGivenAt, feedbackGivenAt) ||
                other.feedbackGivenAt == feedbackGivenAt) &&
            (identical(other.feedbackUpdatedAt, feedbackUpdatedAt) ||
                other.feedbackUpdatedAt == feedbackUpdatedAt) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    meetingId,
    userId,
    attendanceStatus,
    arrivedAt,
    excusedReason,
    attendanceScoreImpact,
    markedBy,
    markedAt,
    preMeetingSubmitted,
    q1PreviousCommitment,
    q1CompletionStatus,
    q2WhatAchieved,
    q3Obstacles,
    q4NextCommitment,
    formSubmittedAt,
    formSubmissionStatus,
    formScoreImpact,
    hostNotes,
    feedbackText,
    feedbackGivenAt,
    feedbackUpdatedAt,
    isPendingSync,
    lastSyncAt,
    createdAt,
    updatedAt,
    userName,
    userRole,
  ]);

  /// Create a copy of CadenceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceParticipantImplCopyWith<_$CadenceParticipantImpl> get copyWith =>
      __$$CadenceParticipantImplCopyWithImpl<_$CadenceParticipantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceParticipantImplToJson(this);
  }
}

abstract class _CadenceParticipant extends CadenceParticipant {
  const factory _CadenceParticipant({
    required final String id,
    required final String meetingId,
    required final String userId,
    final AttendanceStatus attendanceStatus,
    final DateTime? arrivedAt,
    final String? excusedReason,
    final int? attendanceScoreImpact,
    final String? markedBy,
    final DateTime? markedAt,
    final bool preMeetingSubmitted,
    final String? q1PreviousCommitment,
    final CommitmentCompletionStatus? q1CompletionStatus,
    final String? q2WhatAchieved,
    final String? q3Obstacles,
    final String? q4NextCommitment,
    final DateTime? formSubmittedAt,
    final FormSubmissionStatus? formSubmissionStatus,
    final int? formScoreImpact,
    final String? hostNotes,
    final String? feedbackText,
    final DateTime? feedbackGivenAt,
    final DateTime? feedbackUpdatedAt,
    final bool isPendingSync,
    final DateTime? lastSyncAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? userName,
    final String? userRole,
  }) = _$CadenceParticipantImpl;
  const _CadenceParticipant._() : super._();

  factory _CadenceParticipant.fromJson(Map<String, dynamic> json) =
      _$CadenceParticipantImpl.fromJson;

  @override
  String get id;
  @override
  String get meetingId;
  @override
  String get userId; // Attendance
  @override
  AttendanceStatus get attendanceStatus;
  @override
  DateTime? get arrivedAt;
  @override
  String? get excusedReason;
  @override
  int? get attendanceScoreImpact;
  @override
  String? get markedBy;
  @override
  DateTime? get markedAt; // Pre-meeting form (Q1-Q4)
  @override
  bool get preMeetingSubmitted;
  @override
  String? get q1PreviousCommitment; // Auto-filled from last meeting's Q4
  @override
  CommitmentCompletionStatus? get q1CompletionStatus;
  @override
  String? get q2WhatAchieved; // Required
  @override
  String? get q3Obstacles; // Optional
  @override
  String? get q4NextCommitment; // Required
  @override
  DateTime? get formSubmittedAt;
  @override
  FormSubmissionStatus? get formSubmissionStatus;
  @override
  int? get formScoreImpact; // Host notes & feedback
  @override
  String? get hostNotes; // Internal notes (not visible to participant)
  @override
  String? get feedbackText; // Formal feedback visible to participant
  @override
  DateTime? get feedbackGivenAt;
  @override
  DateTime? get feedbackUpdatedAt; // Sync
  @override
  bool get isPendingSync;
  @override
  DateTime? get lastSyncAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // Joined fields
  @override
  String? get userName;
  @override
  String? get userRole;

  /// Create a copy of CadenceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceParticipantImplCopyWith<_$CadenceParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CadenceFormSubmission _$CadenceFormSubmissionFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceFormSubmission.fromJson(json);
}

/// @nodoc
mixin _$CadenceFormSubmission {
  String get participantId => throw _privateConstructorUsedError;
  CommitmentCompletionStatus? get q1CompletionStatus =>
      throw _privateConstructorUsedError;
  String get q2WhatAchieved => throw _privateConstructorUsedError;
  String? get q3Obstacles => throw _privateConstructorUsedError;
  String get q4NextCommitment => throw _privateConstructorUsedError;

  /// Serializes this CadenceFormSubmission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceFormSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceFormSubmissionCopyWith<CadenceFormSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceFormSubmissionCopyWith<$Res> {
  factory $CadenceFormSubmissionCopyWith(
    CadenceFormSubmission value,
    $Res Function(CadenceFormSubmission) then,
  ) = _$CadenceFormSubmissionCopyWithImpl<$Res, CadenceFormSubmission>;
  @useResult
  $Res call({
    String participantId,
    CommitmentCompletionStatus? q1CompletionStatus,
    String q2WhatAchieved,
    String? q3Obstacles,
    String q4NextCommitment,
  });
}

/// @nodoc
class _$CadenceFormSubmissionCopyWithImpl<
  $Res,
  $Val extends CadenceFormSubmission
>
    implements $CadenceFormSubmissionCopyWith<$Res> {
  _$CadenceFormSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceFormSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? q1CompletionStatus = freezed,
    Object? q2WhatAchieved = null,
    Object? q3Obstacles = freezed,
    Object? q4NextCommitment = null,
  }) {
    return _then(
      _value.copyWith(
            participantId: null == participantId
                ? _value.participantId
                : participantId // ignore: cast_nullable_to_non_nullable
                      as String,
            q1CompletionStatus: freezed == q1CompletionStatus
                ? _value.q1CompletionStatus
                : q1CompletionStatus // ignore: cast_nullable_to_non_nullable
                      as CommitmentCompletionStatus?,
            q2WhatAchieved: null == q2WhatAchieved
                ? _value.q2WhatAchieved
                : q2WhatAchieved // ignore: cast_nullable_to_non_nullable
                      as String,
            q3Obstacles: freezed == q3Obstacles
                ? _value.q3Obstacles
                : q3Obstacles // ignore: cast_nullable_to_non_nullable
                      as String?,
            q4NextCommitment: null == q4NextCommitment
                ? _value.q4NextCommitment
                : q4NextCommitment // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceFormSubmissionImplCopyWith<$Res>
    implements $CadenceFormSubmissionCopyWith<$Res> {
  factory _$$CadenceFormSubmissionImplCopyWith(
    _$CadenceFormSubmissionImpl value,
    $Res Function(_$CadenceFormSubmissionImpl) then,
  ) = __$$CadenceFormSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String participantId,
    CommitmentCompletionStatus? q1CompletionStatus,
    String q2WhatAchieved,
    String? q3Obstacles,
    String q4NextCommitment,
  });
}

/// @nodoc
class __$$CadenceFormSubmissionImplCopyWithImpl<$Res>
    extends
        _$CadenceFormSubmissionCopyWithImpl<$Res, _$CadenceFormSubmissionImpl>
    implements _$$CadenceFormSubmissionImplCopyWith<$Res> {
  __$$CadenceFormSubmissionImplCopyWithImpl(
    _$CadenceFormSubmissionImpl _value,
    $Res Function(_$CadenceFormSubmissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceFormSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? q1CompletionStatus = freezed,
    Object? q2WhatAchieved = null,
    Object? q3Obstacles = freezed,
    Object? q4NextCommitment = null,
  }) {
    return _then(
      _$CadenceFormSubmissionImpl(
        participantId: null == participantId
            ? _value.participantId
            : participantId // ignore: cast_nullable_to_non_nullable
                  as String,
        q1CompletionStatus: freezed == q1CompletionStatus
            ? _value.q1CompletionStatus
            : q1CompletionStatus // ignore: cast_nullable_to_non_nullable
                  as CommitmentCompletionStatus?,
        q2WhatAchieved: null == q2WhatAchieved
            ? _value.q2WhatAchieved
            : q2WhatAchieved // ignore: cast_nullable_to_non_nullable
                  as String,
        q3Obstacles: freezed == q3Obstacles
            ? _value.q3Obstacles
            : q3Obstacles // ignore: cast_nullable_to_non_nullable
                  as String?,
        q4NextCommitment: null == q4NextCommitment
            ? _value.q4NextCommitment
            : q4NextCommitment // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceFormSubmissionImpl implements _CadenceFormSubmission {
  const _$CadenceFormSubmissionImpl({
    required this.participantId,
    this.q1CompletionStatus,
    required this.q2WhatAchieved,
    this.q3Obstacles,
    required this.q4NextCommitment,
  });

  factory _$CadenceFormSubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceFormSubmissionImplFromJson(json);

  @override
  final String participantId;
  @override
  final CommitmentCompletionStatus? q1CompletionStatus;
  @override
  final String q2WhatAchieved;
  @override
  final String? q3Obstacles;
  @override
  final String q4NextCommitment;

  @override
  String toString() {
    return 'CadenceFormSubmission(participantId: $participantId, q1CompletionStatus: $q1CompletionStatus, q2WhatAchieved: $q2WhatAchieved, q3Obstacles: $q3Obstacles, q4NextCommitment: $q4NextCommitment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceFormSubmissionImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.q1CompletionStatus, q1CompletionStatus) ||
                other.q1CompletionStatus == q1CompletionStatus) &&
            (identical(other.q2WhatAchieved, q2WhatAchieved) ||
                other.q2WhatAchieved == q2WhatAchieved) &&
            (identical(other.q3Obstacles, q3Obstacles) ||
                other.q3Obstacles == q3Obstacles) &&
            (identical(other.q4NextCommitment, q4NextCommitment) ||
                other.q4NextCommitment == q4NextCommitment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    participantId,
    q1CompletionStatus,
    q2WhatAchieved,
    q3Obstacles,
    q4NextCommitment,
  );

  /// Create a copy of CadenceFormSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceFormSubmissionImplCopyWith<_$CadenceFormSubmissionImpl>
  get copyWith =>
      __$$CadenceFormSubmissionImplCopyWithImpl<_$CadenceFormSubmissionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceFormSubmissionImplToJson(this);
  }
}

abstract class _CadenceFormSubmission implements CadenceFormSubmission {
  const factory _CadenceFormSubmission({
    required final String participantId,
    final CommitmentCompletionStatus? q1CompletionStatus,
    required final String q2WhatAchieved,
    final String? q3Obstacles,
    required final String q4NextCommitment,
  }) = _$CadenceFormSubmissionImpl;

  factory _CadenceFormSubmission.fromJson(Map<String, dynamic> json) =
      _$CadenceFormSubmissionImpl.fromJson;

  @override
  String get participantId;
  @override
  CommitmentCompletionStatus? get q1CompletionStatus;
  @override
  String get q2WhatAchieved;
  @override
  String? get q3Obstacles;
  @override
  String get q4NextCommitment;

  /// Create a copy of CadenceFormSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceFormSubmissionImplCopyWith<_$CadenceFormSubmissionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceMeetingWithParticipants _$CadenceMeetingWithParticipantsFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceMeetingWithParticipants.fromJson(json);
}

/// @nodoc
mixin _$CadenceMeetingWithParticipants {
  CadenceMeeting get meeting => throw _privateConstructorUsedError;
  List<CadenceParticipant> get participants =>
      throw _privateConstructorUsedError;
  CadenceScheduleConfig? get config => throw _privateConstructorUsedError;

  /// Serializes this CadenceMeetingWithParticipants to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceMeetingWithParticipantsCopyWith<CadenceMeetingWithParticipants>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceMeetingWithParticipantsCopyWith<$Res> {
  factory $CadenceMeetingWithParticipantsCopyWith(
    CadenceMeetingWithParticipants value,
    $Res Function(CadenceMeetingWithParticipants) then,
  ) =
      _$CadenceMeetingWithParticipantsCopyWithImpl<
        $Res,
        CadenceMeetingWithParticipants
      >;
  @useResult
  $Res call({
    CadenceMeeting meeting,
    List<CadenceParticipant> participants,
    CadenceScheduleConfig? config,
  });

  $CadenceMeetingCopyWith<$Res> get meeting;
  $CadenceScheduleConfigCopyWith<$Res>? get config;
}

/// @nodoc
class _$CadenceMeetingWithParticipantsCopyWithImpl<
  $Res,
  $Val extends CadenceMeetingWithParticipants
>
    implements $CadenceMeetingWithParticipantsCopyWith<$Res> {
  _$CadenceMeetingWithParticipantsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meeting = null,
    Object? participants = null,
    Object? config = freezed,
  }) {
    return _then(
      _value.copyWith(
            meeting: null == meeting
                ? _value.meeting
                : meeting // ignore: cast_nullable_to_non_nullable
                      as CadenceMeeting,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<CadenceParticipant>,
            config: freezed == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as CadenceScheduleConfig?,
          )
          as $Val,
    );
  }

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CadenceMeetingCopyWith<$Res> get meeting {
    return $CadenceMeetingCopyWith<$Res>(_value.meeting, (value) {
      return _then(_value.copyWith(meeting: value) as $Val);
    });
  }

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CadenceScheduleConfigCopyWith<$Res>? get config {
    if (_value.config == null) {
      return null;
    }

    return $CadenceScheduleConfigCopyWith<$Res>(_value.config!, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CadenceMeetingWithParticipantsImplCopyWith<$Res>
    implements $CadenceMeetingWithParticipantsCopyWith<$Res> {
  factory _$$CadenceMeetingWithParticipantsImplCopyWith(
    _$CadenceMeetingWithParticipantsImpl value,
    $Res Function(_$CadenceMeetingWithParticipantsImpl) then,
  ) = __$$CadenceMeetingWithParticipantsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CadenceMeeting meeting,
    List<CadenceParticipant> participants,
    CadenceScheduleConfig? config,
  });

  @override
  $CadenceMeetingCopyWith<$Res> get meeting;
  @override
  $CadenceScheduleConfigCopyWith<$Res>? get config;
}

/// @nodoc
class __$$CadenceMeetingWithParticipantsImplCopyWithImpl<$Res>
    extends
        _$CadenceMeetingWithParticipantsCopyWithImpl<
          $Res,
          _$CadenceMeetingWithParticipantsImpl
        >
    implements _$$CadenceMeetingWithParticipantsImplCopyWith<$Res> {
  __$$CadenceMeetingWithParticipantsImplCopyWithImpl(
    _$CadenceMeetingWithParticipantsImpl _value,
    $Res Function(_$CadenceMeetingWithParticipantsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meeting = null,
    Object? participants = null,
    Object? config = freezed,
  }) {
    return _then(
      _$CadenceMeetingWithParticipantsImpl(
        meeting: null == meeting
            ? _value.meeting
            : meeting // ignore: cast_nullable_to_non_nullable
                  as CadenceMeeting,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<CadenceParticipant>,
        config: freezed == config
            ? _value.config
            : config // ignore: cast_nullable_to_non_nullable
                  as CadenceScheduleConfig?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceMeetingWithParticipantsImpl
    extends _CadenceMeetingWithParticipants {
  const _$CadenceMeetingWithParticipantsImpl({
    required this.meeting,
    required final List<CadenceParticipant> participants,
    this.config,
  }) : _participants = participants,
       super._();

  factory _$CadenceMeetingWithParticipantsImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CadenceMeetingWithParticipantsImplFromJson(json);

  @override
  final CadenceMeeting meeting;
  final List<CadenceParticipant> _participants;
  @override
  List<CadenceParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final CadenceScheduleConfig? config;

  @override
  String toString() {
    return 'CadenceMeetingWithParticipants(meeting: $meeting, participants: $participants, config: $config)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceMeetingWithParticipantsImpl &&
            (identical(other.meeting, meeting) || other.meeting == meeting) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            (identical(other.config, config) || other.config == config));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    meeting,
    const DeepCollectionEquality().hash(_participants),
    config,
  );

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceMeetingWithParticipantsImplCopyWith<
    _$CadenceMeetingWithParticipantsImpl
  >
  get copyWith =>
      __$$CadenceMeetingWithParticipantsImplCopyWithImpl<
        _$CadenceMeetingWithParticipantsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceMeetingWithParticipantsImplToJson(this);
  }
}

abstract class _CadenceMeetingWithParticipants
    extends CadenceMeetingWithParticipants {
  const factory _CadenceMeetingWithParticipants({
    required final CadenceMeeting meeting,
    required final List<CadenceParticipant> participants,
    final CadenceScheduleConfig? config,
  }) = _$CadenceMeetingWithParticipantsImpl;
  const _CadenceMeetingWithParticipants._() : super._();

  factory _CadenceMeetingWithParticipants.fromJson(Map<String, dynamic> json) =
      _$CadenceMeetingWithParticipantsImpl.fromJson;

  @override
  CadenceMeeting get meeting;
  @override
  List<CadenceParticipant> get participants;
  @override
  CadenceScheduleConfig? get config;

  /// Create a copy of CadenceMeetingWithParticipants
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceMeetingWithParticipantsImplCopyWith<
    _$CadenceMeetingWithParticipantsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
