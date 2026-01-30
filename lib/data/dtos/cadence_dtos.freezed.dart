// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cadence_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CadenceScheduleConfigDto _$CadenceScheduleConfigDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceScheduleConfigDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceScheduleConfigDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_role')
  String get targetRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'facilitator_role')
  String get facilitatorRole => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_time')
  String? get defaultTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'pre_meeting_hours')
  int get preMeetingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CadenceScheduleConfigDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceScheduleConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceScheduleConfigDtoCopyWith<CadenceScheduleConfigDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceScheduleConfigDtoCopyWith<$Res> {
  factory $CadenceScheduleConfigDtoCopyWith(
    CadenceScheduleConfigDto value,
    $Res Function(CadenceScheduleConfigDto) then,
  ) = _$CadenceScheduleConfigDtoCopyWithImpl<$Res, CadenceScheduleConfigDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'target_role') String targetRole,
    @JsonKey(name: 'facilitator_role') String facilitatorRole,
    String frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int preMeetingHours,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CadenceScheduleConfigDtoCopyWithImpl<
  $Res,
  $Val extends CadenceScheduleConfigDto
>
    implements $CadenceScheduleConfigDtoCopyWith<$Res> {
  _$CadenceScheduleConfigDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceScheduleConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? targetRole = null,
    Object? facilitatorRole = null,
    Object? frequency = null,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = null,
    Object? preMeetingHours = null,
    Object? isActive = null,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
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
                      as String,
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
abstract class _$$CadenceScheduleConfigDtoImplCopyWith<$Res>
    implements $CadenceScheduleConfigDtoCopyWith<$Res> {
  factory _$$CadenceScheduleConfigDtoImplCopyWith(
    _$CadenceScheduleConfigDtoImpl value,
    $Res Function(_$CadenceScheduleConfigDtoImpl) then,
  ) = __$$CadenceScheduleConfigDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'target_role') String targetRole,
    @JsonKey(name: 'facilitator_role') String facilitatorRole,
    String frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int preMeetingHours,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CadenceScheduleConfigDtoImplCopyWithImpl<$Res>
    extends
        _$CadenceScheduleConfigDtoCopyWithImpl<
          $Res,
          _$CadenceScheduleConfigDtoImpl
        >
    implements _$$CadenceScheduleConfigDtoImplCopyWith<$Res> {
  __$$CadenceScheduleConfigDtoImplCopyWithImpl(
    _$CadenceScheduleConfigDtoImpl _value,
    $Res Function(_$CadenceScheduleConfigDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceScheduleConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? targetRole = null,
    Object? facilitatorRole = null,
    Object? frequency = null,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = null,
    Object? preMeetingHours = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CadenceScheduleConfigDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
                  as String,
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
class _$CadenceScheduleConfigDtoImpl implements _CadenceScheduleConfigDto {
  const _$CadenceScheduleConfigDtoImpl({
    required this.id,
    required this.name,
    this.description,
    @JsonKey(name: 'target_role') required this.targetRole,
    @JsonKey(name: 'facilitator_role') required this.facilitatorRole,
    required this.frequency,
    @JsonKey(name: 'day_of_week') this.dayOfWeek,
    @JsonKey(name: 'day_of_month') this.dayOfMonth,
    @JsonKey(name: 'default_time') this.defaultTime,
    @JsonKey(name: 'duration_minutes') this.durationMinutes = 60,
    @JsonKey(name: 'pre_meeting_hours') this.preMeetingHours = 24,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$CadenceScheduleConfigDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceScheduleConfigDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'target_role')
  final String targetRole;
  @override
  @JsonKey(name: 'facilitator_role')
  final String facilitatorRole;
  @override
  final String frequency;
  @override
  @JsonKey(name: 'day_of_week')
  final int? dayOfWeek;
  @override
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;
  @override
  @JsonKey(name: 'default_time')
  final String? defaultTime;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'pre_meeting_hours')
  final int preMeetingHours;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CadenceScheduleConfigDto(id: $id, name: $name, description: $description, targetRole: $targetRole, facilitatorRole: $facilitatorRole, frequency: $frequency, dayOfWeek: $dayOfWeek, dayOfMonth: $dayOfMonth, defaultTime: $defaultTime, durationMinutes: $durationMinutes, preMeetingHours: $preMeetingHours, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceScheduleConfigDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
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
    description,
    targetRole,
    facilitatorRole,
    frequency,
    dayOfWeek,
    dayOfMonth,
    defaultTime,
    durationMinutes,
    preMeetingHours,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CadenceScheduleConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceScheduleConfigDtoImplCopyWith<_$CadenceScheduleConfigDtoImpl>
  get copyWith =>
      __$$CadenceScheduleConfigDtoImplCopyWithImpl<
        _$CadenceScheduleConfigDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceScheduleConfigDtoImplToJson(this);
  }
}

abstract class _CadenceScheduleConfigDto implements CadenceScheduleConfigDto {
  const factory _CadenceScheduleConfigDto({
    required final String id,
    required final String name,
    final String? description,
    @JsonKey(name: 'target_role') required final String targetRole,
    @JsonKey(name: 'facilitator_role') required final String facilitatorRole,
    required final String frequency,
    @JsonKey(name: 'day_of_week') final int? dayOfWeek,
    @JsonKey(name: 'day_of_month') final int? dayOfMonth,
    @JsonKey(name: 'default_time') final String? defaultTime,
    @JsonKey(name: 'duration_minutes') final int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') final int preMeetingHours,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CadenceScheduleConfigDtoImpl;

  factory _CadenceScheduleConfigDto.fromJson(Map<String, dynamic> json) =
      _$CadenceScheduleConfigDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'target_role')
  String get targetRole;
  @override
  @JsonKey(name: 'facilitator_role')
  String get facilitatorRole;
  @override
  String get frequency;
  @override
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek;
  @override
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth;
  @override
  @JsonKey(name: 'default_time')
  String? get defaultTime;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'pre_meeting_hours')
  int get preMeetingHours;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CadenceScheduleConfigDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceScheduleConfigDtoImplCopyWith<_$CadenceScheduleConfigDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceMeetingDto _$CadenceMeetingDtoFromJson(Map<String, dynamic> json) {
  return _CadenceMeetingDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceMeetingDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'config_id')
  String get configId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_at')
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'facilitator_id')
  String get facilitatorId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'meeting_link')
  String? get meetingLink => throw _privateConstructorUsedError;
  String? get agenda => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_pending_sync')
  bool get isPendingSync => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CadenceMeetingDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceMeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceMeetingDtoCopyWith<CadenceMeetingDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceMeetingDtoCopyWith<$Res> {
  factory $CadenceMeetingDtoCopyWith(
    CadenceMeetingDto value,
    $Res Function(CadenceMeetingDto) then,
  ) = _$CadenceMeetingDtoCopyWithImpl<$Res, CadenceMeetingDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'config_id') String configId,
    String title,
    @JsonKey(name: 'scheduled_at') DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'facilitator_id') String facilitatorId,
    String status,
    String? location,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    String? agenda,
    String? notes,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_by') String createdBy,
    @JsonKey(name: 'is_pending_sync') bool isPendingSync,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CadenceMeetingDtoCopyWithImpl<$Res, $Val extends CadenceMeetingDto>
    implements $CadenceMeetingDtoCopyWith<$Res> {
  _$CadenceMeetingDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceMeetingDto
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
                      as String,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceMeetingDtoImplCopyWith<$Res>
    implements $CadenceMeetingDtoCopyWith<$Res> {
  factory _$$CadenceMeetingDtoImplCopyWith(
    _$CadenceMeetingDtoImpl value,
    $Res Function(_$CadenceMeetingDtoImpl) then,
  ) = __$$CadenceMeetingDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'config_id') String configId,
    String title,
    @JsonKey(name: 'scheduled_at') DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'facilitator_id') String facilitatorId,
    String status,
    String? location,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    String? agenda,
    String? notes,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_by') String createdBy,
    @JsonKey(name: 'is_pending_sync') bool isPendingSync,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CadenceMeetingDtoImplCopyWithImpl<$Res>
    extends _$CadenceMeetingDtoCopyWithImpl<$Res, _$CadenceMeetingDtoImpl>
    implements _$$CadenceMeetingDtoImplCopyWith<$Res> {
  __$$CadenceMeetingDtoImplCopyWithImpl(
    _$CadenceMeetingDtoImpl _value,
    $Res Function(_$CadenceMeetingDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceMeetingDto
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
  }) {
    return _then(
      _$CadenceMeetingDtoImpl(
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
                  as String,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceMeetingDtoImpl implements _CadenceMeetingDto {
  const _$CadenceMeetingDtoImpl({
    required this.id,
    @JsonKey(name: 'config_id') required this.configId,
    required this.title,
    @JsonKey(name: 'scheduled_at') required this.scheduledAt,
    @JsonKey(name: 'duration_minutes') required this.durationMinutes,
    @JsonKey(name: 'facilitator_id') required this.facilitatorId,
    this.status = 'SCHEDULED',
    this.location,
    @JsonKey(name: 'meeting_link') this.meetingLink,
    this.agenda,
    this.notes,
    @JsonKey(name: 'started_at') this.startedAt,
    @JsonKey(name: 'completed_at') this.completedAt,
    @JsonKey(name: 'created_by') required this.createdBy,
    @JsonKey(name: 'is_pending_sync') this.isPendingSync = false,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$CadenceMeetingDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceMeetingDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'config_id')
  final String configId;
  @override
  final String title;
  @override
  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'facilitator_id')
  final String facilitatorId;
  @override
  @JsonKey()
  final String status;
  @override
  final String? location;
  @override
  @JsonKey(name: 'meeting_link')
  final String? meetingLink;
  @override
  final String? agenda;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'is_pending_sync')
  final bool isPendingSync;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CadenceMeetingDto(id: $id, configId: $configId, title: $title, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, facilitatorId: $facilitatorId, status: $status, location: $location, meetingLink: $meetingLink, agenda: $agenda, notes: $notes, startedAt: $startedAt, completedAt: $completedAt, createdBy: $createdBy, isPendingSync: $isPendingSync, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceMeetingDtoImpl &&
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
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
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
  );

  /// Create a copy of CadenceMeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceMeetingDtoImplCopyWith<_$CadenceMeetingDtoImpl> get copyWith =>
      __$$CadenceMeetingDtoImplCopyWithImpl<_$CadenceMeetingDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceMeetingDtoImplToJson(this);
  }
}

abstract class _CadenceMeetingDto implements CadenceMeetingDto {
  const factory _CadenceMeetingDto({
    required final String id,
    @JsonKey(name: 'config_id') required final String configId,
    required final String title,
    @JsonKey(name: 'scheduled_at') required final DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') required final int durationMinutes,
    @JsonKey(name: 'facilitator_id') required final String facilitatorId,
    final String status,
    final String? location,
    @JsonKey(name: 'meeting_link') final String? meetingLink,
    final String? agenda,
    final String? notes,
    @JsonKey(name: 'started_at') final DateTime? startedAt,
    @JsonKey(name: 'completed_at') final DateTime? completedAt,
    @JsonKey(name: 'created_by') required final String createdBy,
    @JsonKey(name: 'is_pending_sync') final bool isPendingSync,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CadenceMeetingDtoImpl;

  factory _CadenceMeetingDto.fromJson(Map<String, dynamic> json) =
      _$CadenceMeetingDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'config_id')
  String get configId;
  @override
  String get title;
  @override
  @JsonKey(name: 'scheduled_at')
  DateTime get scheduledAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'facilitator_id')
  String get facilitatorId;
  @override
  String get status;
  @override
  String? get location;
  @override
  @JsonKey(name: 'meeting_link')
  String? get meetingLink;
  @override
  String? get agenda;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'is_pending_sync')
  bool get isPendingSync;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CadenceMeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceMeetingDtoImplCopyWith<_$CadenceMeetingDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CadenceParticipantDto _$CadenceParticipantDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceParticipantDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceParticipantDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'meeting_id')
  String get meetingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError; // Attendance
  @JsonKey(name: 'attendance_status')
  String get attendanceStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'arrived_at')
  DateTime? get arrivedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'excused_reason')
  String? get excusedReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'attendance_score_impact')
  int? get attendanceScoreImpact => throw _privateConstructorUsedError;
  @JsonKey(name: 'marked_by')
  String? get markedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'marked_at')
  DateTime? get markedAt => throw _privateConstructorUsedError; // Pre-meeting form
  @JsonKey(name: 'pre_meeting_submitted')
  bool get preMeetingSubmitted => throw _privateConstructorUsedError;
  @JsonKey(name: 'q1_previous_commitment')
  String? get q1PreviousCommitment => throw _privateConstructorUsedError;
  @JsonKey(name: 'q1_completion_status')
  String? get q1CompletionStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'q2_what_achieved')
  String? get q2WhatAchieved => throw _privateConstructorUsedError;
  @JsonKey(name: 'q3_obstacles')
  String? get q3Obstacles => throw _privateConstructorUsedError;
  @JsonKey(name: 'q4_next_commitment')
  String? get q4NextCommitment => throw _privateConstructorUsedError;
  @JsonKey(name: 'form_submitted_at')
  DateTime? get formSubmittedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'form_submission_status')
  String? get formSubmissionStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'form_score_impact')
  int? get formScoreImpact => throw _privateConstructorUsedError; // Feedback
  @JsonKey(name: 'host_notes')
  String? get hostNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'feedback_text')
  String? get feedbackText => throw _privateConstructorUsedError;
  @JsonKey(name: 'feedback_given_at')
  DateTime? get feedbackGivenAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'feedback_updated_at')
  DateTime? get feedbackUpdatedAt => throw _privateConstructorUsedError; // Sync
  @JsonKey(name: 'is_pending_sync')
  bool get isPendingSync => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_sync_at')
  DateTime? get lastSyncAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CadenceParticipantDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceParticipantDtoCopyWith<CadenceParticipantDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceParticipantDtoCopyWith<$Res> {
  factory $CadenceParticipantDtoCopyWith(
    CadenceParticipantDto value,
    $Res Function(CadenceParticipantDto) then,
  ) = _$CadenceParticipantDtoCopyWithImpl<$Res, CadenceParticipantDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'meeting_id') String meetingId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'attendance_status') String attendanceStatus,
    @JsonKey(name: 'arrived_at') DateTime? arrivedAt,
    @JsonKey(name: 'excused_reason') String? excusedReason,
    @JsonKey(name: 'attendance_score_impact') int? attendanceScoreImpact,
    @JsonKey(name: 'marked_by') String? markedBy,
    @JsonKey(name: 'marked_at') DateTime? markedAt,
    @JsonKey(name: 'pre_meeting_submitted') bool preMeetingSubmitted,
    @JsonKey(name: 'q1_previous_commitment') String? q1PreviousCommitment,
    @JsonKey(name: 'q1_completion_status') String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') String? q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') String? q4NextCommitment,
    @JsonKey(name: 'form_submitted_at') DateTime? formSubmittedAt,
    @JsonKey(name: 'form_submission_status') String? formSubmissionStatus,
    @JsonKey(name: 'form_score_impact') int? formScoreImpact,
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
    @JsonKey(name: 'feedback_given_at') DateTime? feedbackGivenAt,
    @JsonKey(name: 'feedback_updated_at') DateTime? feedbackUpdatedAt,
    @JsonKey(name: 'is_pending_sync') bool isPendingSync,
    @JsonKey(name: 'last_sync_at') DateTime? lastSyncAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CadenceParticipantDtoCopyWithImpl<
  $Res,
  $Val extends CadenceParticipantDto
>
    implements $CadenceParticipantDtoCopyWith<$Res> {
  _$CadenceParticipantDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceParticipantDto
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
                      as String,
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
                      as String?,
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
                      as String?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceParticipantDtoImplCopyWith<$Res>
    implements $CadenceParticipantDtoCopyWith<$Res> {
  factory _$$CadenceParticipantDtoImplCopyWith(
    _$CadenceParticipantDtoImpl value,
    $Res Function(_$CadenceParticipantDtoImpl) then,
  ) = __$$CadenceParticipantDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'meeting_id') String meetingId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'attendance_status') String attendanceStatus,
    @JsonKey(name: 'arrived_at') DateTime? arrivedAt,
    @JsonKey(name: 'excused_reason') String? excusedReason,
    @JsonKey(name: 'attendance_score_impact') int? attendanceScoreImpact,
    @JsonKey(name: 'marked_by') String? markedBy,
    @JsonKey(name: 'marked_at') DateTime? markedAt,
    @JsonKey(name: 'pre_meeting_submitted') bool preMeetingSubmitted,
    @JsonKey(name: 'q1_previous_commitment') String? q1PreviousCommitment,
    @JsonKey(name: 'q1_completion_status') String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') String? q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') String? q4NextCommitment,
    @JsonKey(name: 'form_submitted_at') DateTime? formSubmittedAt,
    @JsonKey(name: 'form_submission_status') String? formSubmissionStatus,
    @JsonKey(name: 'form_score_impact') int? formScoreImpact,
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
    @JsonKey(name: 'feedback_given_at') DateTime? feedbackGivenAt,
    @JsonKey(name: 'feedback_updated_at') DateTime? feedbackUpdatedAt,
    @JsonKey(name: 'is_pending_sync') bool isPendingSync,
    @JsonKey(name: 'last_sync_at') DateTime? lastSyncAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CadenceParticipantDtoImplCopyWithImpl<$Res>
    extends
        _$CadenceParticipantDtoCopyWithImpl<$Res, _$CadenceParticipantDtoImpl>
    implements _$$CadenceParticipantDtoImplCopyWith<$Res> {
  __$$CadenceParticipantDtoImplCopyWithImpl(
    _$CadenceParticipantDtoImpl _value,
    $Res Function(_$CadenceParticipantDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceParticipantDto
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
  }) {
    return _then(
      _$CadenceParticipantDtoImpl(
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
                  as String,
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
                  as String?,
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
                  as String?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceParticipantDtoImpl implements _CadenceParticipantDto {
  const _$CadenceParticipantDtoImpl({
    required this.id,
    @JsonKey(name: 'meeting_id') required this.meetingId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'attendance_status') this.attendanceStatus = 'PENDING',
    @JsonKey(name: 'arrived_at') this.arrivedAt,
    @JsonKey(name: 'excused_reason') this.excusedReason,
    @JsonKey(name: 'attendance_score_impact') this.attendanceScoreImpact,
    @JsonKey(name: 'marked_by') this.markedBy,
    @JsonKey(name: 'marked_at') this.markedAt,
    @JsonKey(name: 'pre_meeting_submitted') this.preMeetingSubmitted = false,
    @JsonKey(name: 'q1_previous_commitment') this.q1PreviousCommitment,
    @JsonKey(name: 'q1_completion_status') this.q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') this.q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') this.q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') this.q4NextCommitment,
    @JsonKey(name: 'form_submitted_at') this.formSubmittedAt,
    @JsonKey(name: 'form_submission_status') this.formSubmissionStatus,
    @JsonKey(name: 'form_score_impact') this.formScoreImpact,
    @JsonKey(name: 'host_notes') this.hostNotes,
    @JsonKey(name: 'feedback_text') this.feedbackText,
    @JsonKey(name: 'feedback_given_at') this.feedbackGivenAt,
    @JsonKey(name: 'feedback_updated_at') this.feedbackUpdatedAt,
    @JsonKey(name: 'is_pending_sync') this.isPendingSync = false,
    @JsonKey(name: 'last_sync_at') this.lastSyncAt,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$CadenceParticipantDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceParticipantDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'meeting_id')
  final String meetingId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  // Attendance
  @override
  @JsonKey(name: 'attendance_status')
  final String attendanceStatus;
  @override
  @JsonKey(name: 'arrived_at')
  final DateTime? arrivedAt;
  @override
  @JsonKey(name: 'excused_reason')
  final String? excusedReason;
  @override
  @JsonKey(name: 'attendance_score_impact')
  final int? attendanceScoreImpact;
  @override
  @JsonKey(name: 'marked_by')
  final String? markedBy;
  @override
  @JsonKey(name: 'marked_at')
  final DateTime? markedAt;
  // Pre-meeting form
  @override
  @JsonKey(name: 'pre_meeting_submitted')
  final bool preMeetingSubmitted;
  @override
  @JsonKey(name: 'q1_previous_commitment')
  final String? q1PreviousCommitment;
  @override
  @JsonKey(name: 'q1_completion_status')
  final String? q1CompletionStatus;
  @override
  @JsonKey(name: 'q2_what_achieved')
  final String? q2WhatAchieved;
  @override
  @JsonKey(name: 'q3_obstacles')
  final String? q3Obstacles;
  @override
  @JsonKey(name: 'q4_next_commitment')
  final String? q4NextCommitment;
  @override
  @JsonKey(name: 'form_submitted_at')
  final DateTime? formSubmittedAt;
  @override
  @JsonKey(name: 'form_submission_status')
  final String? formSubmissionStatus;
  @override
  @JsonKey(name: 'form_score_impact')
  final int? formScoreImpact;
  // Feedback
  @override
  @JsonKey(name: 'host_notes')
  final String? hostNotes;
  @override
  @JsonKey(name: 'feedback_text')
  final String? feedbackText;
  @override
  @JsonKey(name: 'feedback_given_at')
  final DateTime? feedbackGivenAt;
  @override
  @JsonKey(name: 'feedback_updated_at')
  final DateTime? feedbackUpdatedAt;
  // Sync
  @override
  @JsonKey(name: 'is_pending_sync')
  final bool isPendingSync;
  @override
  @JsonKey(name: 'last_sync_at')
  final DateTime? lastSyncAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CadenceParticipantDto(id: $id, meetingId: $meetingId, userId: $userId, attendanceStatus: $attendanceStatus, arrivedAt: $arrivedAt, excusedReason: $excusedReason, attendanceScoreImpact: $attendanceScoreImpact, markedBy: $markedBy, markedAt: $markedAt, preMeetingSubmitted: $preMeetingSubmitted, q1PreviousCommitment: $q1PreviousCommitment, q1CompletionStatus: $q1CompletionStatus, q2WhatAchieved: $q2WhatAchieved, q3Obstacles: $q3Obstacles, q4NextCommitment: $q4NextCommitment, formSubmittedAt: $formSubmittedAt, formSubmissionStatus: $formSubmissionStatus, formScoreImpact: $formScoreImpact, hostNotes: $hostNotes, feedbackText: $feedbackText, feedbackGivenAt: $feedbackGivenAt, feedbackUpdatedAt: $feedbackUpdatedAt, isPendingSync: $isPendingSync, lastSyncAt: $lastSyncAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceParticipantDtoImpl &&
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
                other.updatedAt == updatedAt));
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
  ]);

  /// Create a copy of CadenceParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceParticipantDtoImplCopyWith<_$CadenceParticipantDtoImpl>
  get copyWith =>
      __$$CadenceParticipantDtoImplCopyWithImpl<_$CadenceParticipantDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceParticipantDtoImplToJson(this);
  }
}

abstract class _CadenceParticipantDto implements CadenceParticipantDto {
  const factory _CadenceParticipantDto({
    required final String id,
    @JsonKey(name: 'meeting_id') required final String meetingId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'attendance_status') final String attendanceStatus,
    @JsonKey(name: 'arrived_at') final DateTime? arrivedAt,
    @JsonKey(name: 'excused_reason') final String? excusedReason,
    @JsonKey(name: 'attendance_score_impact') final int? attendanceScoreImpact,
    @JsonKey(name: 'marked_by') final String? markedBy,
    @JsonKey(name: 'marked_at') final DateTime? markedAt,
    @JsonKey(name: 'pre_meeting_submitted') final bool preMeetingSubmitted,
    @JsonKey(name: 'q1_previous_commitment') final String? q1PreviousCommitment,
    @JsonKey(name: 'q1_completion_status') final String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') final String? q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') final String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') final String? q4NextCommitment,
    @JsonKey(name: 'form_submitted_at') final DateTime? formSubmittedAt,
    @JsonKey(name: 'form_submission_status') final String? formSubmissionStatus,
    @JsonKey(name: 'form_score_impact') final int? formScoreImpact,
    @JsonKey(name: 'host_notes') final String? hostNotes,
    @JsonKey(name: 'feedback_text') final String? feedbackText,
    @JsonKey(name: 'feedback_given_at') final DateTime? feedbackGivenAt,
    @JsonKey(name: 'feedback_updated_at') final DateTime? feedbackUpdatedAt,
    @JsonKey(name: 'is_pending_sync') final bool isPendingSync,
    @JsonKey(name: 'last_sync_at') final DateTime? lastSyncAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CadenceParticipantDtoImpl;

  factory _CadenceParticipantDto.fromJson(Map<String, dynamic> json) =
      _$CadenceParticipantDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'meeting_id')
  String get meetingId;
  @override
  @JsonKey(name: 'user_id')
  String get userId; // Attendance
  @override
  @JsonKey(name: 'attendance_status')
  String get attendanceStatus;
  @override
  @JsonKey(name: 'arrived_at')
  DateTime? get arrivedAt;
  @override
  @JsonKey(name: 'excused_reason')
  String? get excusedReason;
  @override
  @JsonKey(name: 'attendance_score_impact')
  int? get attendanceScoreImpact;
  @override
  @JsonKey(name: 'marked_by')
  String? get markedBy;
  @override
  @JsonKey(name: 'marked_at')
  DateTime? get markedAt; // Pre-meeting form
  @override
  @JsonKey(name: 'pre_meeting_submitted')
  bool get preMeetingSubmitted;
  @override
  @JsonKey(name: 'q1_previous_commitment')
  String? get q1PreviousCommitment;
  @override
  @JsonKey(name: 'q1_completion_status')
  String? get q1CompletionStatus;
  @override
  @JsonKey(name: 'q2_what_achieved')
  String? get q2WhatAchieved;
  @override
  @JsonKey(name: 'q3_obstacles')
  String? get q3Obstacles;
  @override
  @JsonKey(name: 'q4_next_commitment')
  String? get q4NextCommitment;
  @override
  @JsonKey(name: 'form_submitted_at')
  DateTime? get formSubmittedAt;
  @override
  @JsonKey(name: 'form_submission_status')
  String? get formSubmissionStatus;
  @override
  @JsonKey(name: 'form_score_impact')
  int? get formScoreImpact; // Feedback
  @override
  @JsonKey(name: 'host_notes')
  String? get hostNotes;
  @override
  @JsonKey(name: 'feedback_text')
  String? get feedbackText;
  @override
  @JsonKey(name: 'feedback_given_at')
  DateTime? get feedbackGivenAt;
  @override
  @JsonKey(name: 'feedback_updated_at')
  DateTime? get feedbackUpdatedAt; // Sync
  @override
  @JsonKey(name: 'is_pending_sync')
  bool get isPendingSync;
  @override
  @JsonKey(name: 'last_sync_at')
  DateTime? get lastSyncAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CadenceParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceParticipantDtoImplCopyWith<_$CadenceParticipantDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceFormCreateDto _$CadenceFormCreateDtoFromJson(Map<String, dynamic> json) {
  return _CadenceFormCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceFormCreateDto {
  @JsonKey(name: 'q1_completion_status')
  String? get q1CompletionStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'q2_what_achieved')
  String get q2WhatAchieved => throw _privateConstructorUsedError;
  @JsonKey(name: 'q3_obstacles')
  String? get q3Obstacles => throw _privateConstructorUsedError;
  @JsonKey(name: 'q4_next_commitment')
  String get q4NextCommitment => throw _privateConstructorUsedError;

  /// Serializes this CadenceFormCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceFormCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceFormCreateDtoCopyWith<CadenceFormCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceFormCreateDtoCopyWith<$Res> {
  factory $CadenceFormCreateDtoCopyWith(
    CadenceFormCreateDto value,
    $Res Function(CadenceFormCreateDto) then,
  ) = _$CadenceFormCreateDtoCopyWithImpl<$Res, CadenceFormCreateDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'q1_completion_status') String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') String q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') String q4NextCommitment,
  });
}

/// @nodoc
class _$CadenceFormCreateDtoCopyWithImpl<
  $Res,
  $Val extends CadenceFormCreateDto
>
    implements $CadenceFormCreateDtoCopyWith<$Res> {
  _$CadenceFormCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceFormCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? q1CompletionStatus = freezed,
    Object? q2WhatAchieved = null,
    Object? q3Obstacles = freezed,
    Object? q4NextCommitment = null,
  }) {
    return _then(
      _value.copyWith(
            q1CompletionStatus: freezed == q1CompletionStatus
                ? _value.q1CompletionStatus
                : q1CompletionStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$CadenceFormCreateDtoImplCopyWith<$Res>
    implements $CadenceFormCreateDtoCopyWith<$Res> {
  factory _$$CadenceFormCreateDtoImplCopyWith(
    _$CadenceFormCreateDtoImpl value,
    $Res Function(_$CadenceFormCreateDtoImpl) then,
  ) = __$$CadenceFormCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'q1_completion_status') String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') String q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') String q4NextCommitment,
  });
}

/// @nodoc
class __$$CadenceFormCreateDtoImplCopyWithImpl<$Res>
    extends _$CadenceFormCreateDtoCopyWithImpl<$Res, _$CadenceFormCreateDtoImpl>
    implements _$$CadenceFormCreateDtoImplCopyWith<$Res> {
  __$$CadenceFormCreateDtoImplCopyWithImpl(
    _$CadenceFormCreateDtoImpl _value,
    $Res Function(_$CadenceFormCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceFormCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? q1CompletionStatus = freezed,
    Object? q2WhatAchieved = null,
    Object? q3Obstacles = freezed,
    Object? q4NextCommitment = null,
  }) {
    return _then(
      _$CadenceFormCreateDtoImpl(
        q1CompletionStatus: freezed == q1CompletionStatus
            ? _value.q1CompletionStatus
            : q1CompletionStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$CadenceFormCreateDtoImpl implements _CadenceFormCreateDto {
  const _$CadenceFormCreateDtoImpl({
    @JsonKey(name: 'q1_completion_status') this.q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') required this.q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') this.q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') required this.q4NextCommitment,
  });

  factory _$CadenceFormCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceFormCreateDtoImplFromJson(json);

  @override
  @JsonKey(name: 'q1_completion_status')
  final String? q1CompletionStatus;
  @override
  @JsonKey(name: 'q2_what_achieved')
  final String q2WhatAchieved;
  @override
  @JsonKey(name: 'q3_obstacles')
  final String? q3Obstacles;
  @override
  @JsonKey(name: 'q4_next_commitment')
  final String q4NextCommitment;

  @override
  String toString() {
    return 'CadenceFormCreateDto(q1CompletionStatus: $q1CompletionStatus, q2WhatAchieved: $q2WhatAchieved, q3Obstacles: $q3Obstacles, q4NextCommitment: $q4NextCommitment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceFormCreateDtoImpl &&
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
    q1CompletionStatus,
    q2WhatAchieved,
    q3Obstacles,
    q4NextCommitment,
  );

  /// Create a copy of CadenceFormCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceFormCreateDtoImplCopyWith<_$CadenceFormCreateDtoImpl>
  get copyWith =>
      __$$CadenceFormCreateDtoImplCopyWithImpl<_$CadenceFormCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceFormCreateDtoImplToJson(this);
  }
}

abstract class _CadenceFormCreateDto implements CadenceFormCreateDto {
  const factory _CadenceFormCreateDto({
    @JsonKey(name: 'q1_completion_status') final String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') required final String q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') final String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') required final String q4NextCommitment,
  }) = _$CadenceFormCreateDtoImpl;

  factory _CadenceFormCreateDto.fromJson(Map<String, dynamic> json) =
      _$CadenceFormCreateDtoImpl.fromJson;

  @override
  @JsonKey(name: 'q1_completion_status')
  String? get q1CompletionStatus;
  @override
  @JsonKey(name: 'q2_what_achieved')
  String get q2WhatAchieved;
  @override
  @JsonKey(name: 'q3_obstacles')
  String? get q3Obstacles;
  @override
  @JsonKey(name: 'q4_next_commitment')
  String get q4NextCommitment;

  /// Create a copy of CadenceFormCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceFormCreateDtoImplCopyWith<_$CadenceFormCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AttendanceUpdateDto _$AttendanceUpdateDtoFromJson(Map<String, dynamic> json) {
  return _AttendanceUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$AttendanceUpdateDto {
  @JsonKey(name: 'attendance_status')
  String get attendanceStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'excused_reason')
  String? get excusedReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'arrived_at')
  DateTime? get arrivedAt => throw _privateConstructorUsedError;

  /// Serializes this AttendanceUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceUpdateDtoCopyWith<AttendanceUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceUpdateDtoCopyWith<$Res> {
  factory $AttendanceUpdateDtoCopyWith(
    AttendanceUpdateDto value,
    $Res Function(AttendanceUpdateDto) then,
  ) = _$AttendanceUpdateDtoCopyWithImpl<$Res, AttendanceUpdateDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'attendance_status') String attendanceStatus,
    @JsonKey(name: 'excused_reason') String? excusedReason,
    @JsonKey(name: 'arrived_at') DateTime? arrivedAt,
  });
}

/// @nodoc
class _$AttendanceUpdateDtoCopyWithImpl<$Res, $Val extends AttendanceUpdateDto>
    implements $AttendanceUpdateDtoCopyWith<$Res> {
  _$AttendanceUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attendanceStatus = null,
    Object? excusedReason = freezed,
    Object? arrivedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            attendanceStatus: null == attendanceStatus
                ? _value.attendanceStatus
                : attendanceStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            excusedReason: freezed == excusedReason
                ? _value.excusedReason
                : excusedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            arrivedAt: freezed == arrivedAt
                ? _value.arrivedAt
                : arrivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceUpdateDtoImplCopyWith<$Res>
    implements $AttendanceUpdateDtoCopyWith<$Res> {
  factory _$$AttendanceUpdateDtoImplCopyWith(
    _$AttendanceUpdateDtoImpl value,
    $Res Function(_$AttendanceUpdateDtoImpl) then,
  ) = __$$AttendanceUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'attendance_status') String attendanceStatus,
    @JsonKey(name: 'excused_reason') String? excusedReason,
    @JsonKey(name: 'arrived_at') DateTime? arrivedAt,
  });
}

/// @nodoc
class __$$AttendanceUpdateDtoImplCopyWithImpl<$Res>
    extends _$AttendanceUpdateDtoCopyWithImpl<$Res, _$AttendanceUpdateDtoImpl>
    implements _$$AttendanceUpdateDtoImplCopyWith<$Res> {
  __$$AttendanceUpdateDtoImplCopyWithImpl(
    _$AttendanceUpdateDtoImpl _value,
    $Res Function(_$AttendanceUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attendanceStatus = null,
    Object? excusedReason = freezed,
    Object? arrivedAt = freezed,
  }) {
    return _then(
      _$AttendanceUpdateDtoImpl(
        attendanceStatus: null == attendanceStatus
            ? _value.attendanceStatus
            : attendanceStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        excusedReason: freezed == excusedReason
            ? _value.excusedReason
            : excusedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        arrivedAt: freezed == arrivedAt
            ? _value.arrivedAt
            : arrivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceUpdateDtoImpl implements _AttendanceUpdateDto {
  const _$AttendanceUpdateDtoImpl({
    @JsonKey(name: 'attendance_status') required this.attendanceStatus,
    @JsonKey(name: 'excused_reason') this.excusedReason,
    @JsonKey(name: 'arrived_at') this.arrivedAt,
  });

  factory _$AttendanceUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceUpdateDtoImplFromJson(json);

  @override
  @JsonKey(name: 'attendance_status')
  final String attendanceStatus;
  @override
  @JsonKey(name: 'excused_reason')
  final String? excusedReason;
  @override
  @JsonKey(name: 'arrived_at')
  final DateTime? arrivedAt;

  @override
  String toString() {
    return 'AttendanceUpdateDto(attendanceStatus: $attendanceStatus, excusedReason: $excusedReason, arrivedAt: $arrivedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceUpdateDtoImpl &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.excusedReason, excusedReason) ||
                other.excusedReason == excusedReason) &&
            (identical(other.arrivedAt, arrivedAt) ||
                other.arrivedAt == arrivedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, attendanceStatus, excusedReason, arrivedAt);

  /// Create a copy of AttendanceUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceUpdateDtoImplCopyWith<_$AttendanceUpdateDtoImpl> get copyWith =>
      __$$AttendanceUpdateDtoImplCopyWithImpl<_$AttendanceUpdateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceUpdateDtoImplToJson(this);
  }
}

abstract class _AttendanceUpdateDto implements AttendanceUpdateDto {
  const factory _AttendanceUpdateDto({
    @JsonKey(name: 'attendance_status') required final String attendanceStatus,
    @JsonKey(name: 'excused_reason') final String? excusedReason,
    @JsonKey(name: 'arrived_at') final DateTime? arrivedAt,
  }) = _$AttendanceUpdateDtoImpl;

  factory _AttendanceUpdateDto.fromJson(Map<String, dynamic> json) =
      _$AttendanceUpdateDtoImpl.fromJson;

  @override
  @JsonKey(name: 'attendance_status')
  String get attendanceStatus;
  @override
  @JsonKey(name: 'excused_reason')
  String? get excusedReason;
  @override
  @JsonKey(name: 'arrived_at')
  DateTime? get arrivedAt;

  /// Create a copy of AttendanceUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceUpdateDtoImplCopyWith<_$AttendanceUpdateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedbackUpdateDto _$FeedbackUpdateDtoFromJson(Map<String, dynamic> json) {
  return _FeedbackUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$FeedbackUpdateDto {
  @JsonKey(name: 'host_notes')
  String? get hostNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'feedback_text')
  String? get feedbackText => throw _privateConstructorUsedError;

  /// Serializes this FeedbackUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedbackUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedbackUpdateDtoCopyWith<FeedbackUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedbackUpdateDtoCopyWith<$Res> {
  factory $FeedbackUpdateDtoCopyWith(
    FeedbackUpdateDto value,
    $Res Function(FeedbackUpdateDto) then,
  ) = _$FeedbackUpdateDtoCopyWithImpl<$Res, FeedbackUpdateDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
  });
}

/// @nodoc
class _$FeedbackUpdateDtoCopyWithImpl<$Res, $Val extends FeedbackUpdateDto>
    implements $FeedbackUpdateDtoCopyWith<$Res> {
  _$FeedbackUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedbackUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hostNotes = freezed, Object? feedbackText = freezed}) {
    return _then(
      _value.copyWith(
            hostNotes: freezed == hostNotes
                ? _value.hostNotes
                : hostNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            feedbackText: freezed == feedbackText
                ? _value.feedbackText
                : feedbackText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeedbackUpdateDtoImplCopyWith<$Res>
    implements $FeedbackUpdateDtoCopyWith<$Res> {
  factory _$$FeedbackUpdateDtoImplCopyWith(
    _$FeedbackUpdateDtoImpl value,
    $Res Function(_$FeedbackUpdateDtoImpl) then,
  ) = __$$FeedbackUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
  });
}

/// @nodoc
class __$$FeedbackUpdateDtoImplCopyWithImpl<$Res>
    extends _$FeedbackUpdateDtoCopyWithImpl<$Res, _$FeedbackUpdateDtoImpl>
    implements _$$FeedbackUpdateDtoImplCopyWith<$Res> {
  __$$FeedbackUpdateDtoImplCopyWithImpl(
    _$FeedbackUpdateDtoImpl _value,
    $Res Function(_$FeedbackUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedbackUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hostNotes = freezed, Object? feedbackText = freezed}) {
    return _then(
      _$FeedbackUpdateDtoImpl(
        hostNotes: freezed == hostNotes
            ? _value.hostNotes
            : hostNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        feedbackText: freezed == feedbackText
            ? _value.feedbackText
            : feedbackText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedbackUpdateDtoImpl implements _FeedbackUpdateDto {
  const _$FeedbackUpdateDtoImpl({
    @JsonKey(name: 'host_notes') this.hostNotes,
    @JsonKey(name: 'feedback_text') this.feedbackText,
  });

  factory _$FeedbackUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedbackUpdateDtoImplFromJson(json);

  @override
  @JsonKey(name: 'host_notes')
  final String? hostNotes;
  @override
  @JsonKey(name: 'feedback_text')
  final String? feedbackText;

  @override
  String toString() {
    return 'FeedbackUpdateDto(hostNotes: $hostNotes, feedbackText: $feedbackText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedbackUpdateDtoImpl &&
            (identical(other.hostNotes, hostNotes) ||
                other.hostNotes == hostNotes) &&
            (identical(other.feedbackText, feedbackText) ||
                other.feedbackText == feedbackText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hostNotes, feedbackText);

  /// Create a copy of FeedbackUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedbackUpdateDtoImplCopyWith<_$FeedbackUpdateDtoImpl> get copyWith =>
      __$$FeedbackUpdateDtoImplCopyWithImpl<_$FeedbackUpdateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedbackUpdateDtoImplToJson(this);
  }
}

abstract class _FeedbackUpdateDto implements FeedbackUpdateDto {
  const factory _FeedbackUpdateDto({
    @JsonKey(name: 'host_notes') final String? hostNotes,
    @JsonKey(name: 'feedback_text') final String? feedbackText,
  }) = _$FeedbackUpdateDtoImpl;

  factory _FeedbackUpdateDto.fromJson(Map<String, dynamic> json) =
      _$FeedbackUpdateDtoImpl.fromJson;

  @override
  @JsonKey(name: 'host_notes')
  String? get hostNotes;
  @override
  @JsonKey(name: 'feedback_text')
  String? get feedbackText;

  /// Create a copy of FeedbackUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedbackUpdateDtoImplCopyWith<_$FeedbackUpdateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CadenceMeetingCreateDto _$CadenceMeetingCreateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceMeetingCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceMeetingCreateDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'config_id')
  String get configId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_at')
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'facilitator_id')
  String get facilitatorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'meeting_link')
  String? get meetingLink => throw _privateConstructorUsedError;
  String? get agenda => throw _privateConstructorUsedError;

  /// Serializes this CadenceMeetingCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceMeetingCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceMeetingCreateDtoCopyWith<CadenceMeetingCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceMeetingCreateDtoCopyWith<$Res> {
  factory $CadenceMeetingCreateDtoCopyWith(
    CadenceMeetingCreateDto value,
    $Res Function(CadenceMeetingCreateDto) then,
  ) = _$CadenceMeetingCreateDtoCopyWithImpl<$Res, CadenceMeetingCreateDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'config_id') String configId,
    String title,
    @JsonKey(name: 'scheduled_at') DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'facilitator_id') String facilitatorId,
    @JsonKey(name: 'created_by') String createdBy,
    String? location,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    String? agenda,
  });
}

/// @nodoc
class _$CadenceMeetingCreateDtoCopyWithImpl<
  $Res,
  $Val extends CadenceMeetingCreateDto
>
    implements $CadenceMeetingCreateDtoCopyWith<$Res> {
  _$CadenceMeetingCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceMeetingCreateDto
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
    Object? createdBy = null,
    Object? location = freezed,
    Object? meetingLink = freezed,
    Object? agenda = freezed,
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
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceMeetingCreateDtoImplCopyWith<$Res>
    implements $CadenceMeetingCreateDtoCopyWith<$Res> {
  factory _$$CadenceMeetingCreateDtoImplCopyWith(
    _$CadenceMeetingCreateDtoImpl value,
    $Res Function(_$CadenceMeetingCreateDtoImpl) then,
  ) = __$$CadenceMeetingCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'config_id') String configId,
    String title,
    @JsonKey(name: 'scheduled_at') DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'facilitator_id') String facilitatorId,
    @JsonKey(name: 'created_by') String createdBy,
    String? location,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    String? agenda,
  });
}

/// @nodoc
class __$$CadenceMeetingCreateDtoImplCopyWithImpl<$Res>
    extends
        _$CadenceMeetingCreateDtoCopyWithImpl<
          $Res,
          _$CadenceMeetingCreateDtoImpl
        >
    implements _$$CadenceMeetingCreateDtoImplCopyWith<$Res> {
  __$$CadenceMeetingCreateDtoImplCopyWithImpl(
    _$CadenceMeetingCreateDtoImpl _value,
    $Res Function(_$CadenceMeetingCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceMeetingCreateDto
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
    Object? createdBy = null,
    Object? location = freezed,
    Object? meetingLink = freezed,
    Object? agenda = freezed,
  }) {
    return _then(
      _$CadenceMeetingCreateDtoImpl(
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
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceMeetingCreateDtoImpl implements _CadenceMeetingCreateDto {
  const _$CadenceMeetingCreateDtoImpl({
    required this.id,
    @JsonKey(name: 'config_id') required this.configId,
    required this.title,
    @JsonKey(name: 'scheduled_at') required this.scheduledAt,
    @JsonKey(name: 'duration_minutes') required this.durationMinutes,
    @JsonKey(name: 'facilitator_id') required this.facilitatorId,
    @JsonKey(name: 'created_by') required this.createdBy,
    this.location,
    @JsonKey(name: 'meeting_link') this.meetingLink,
    this.agenda,
  });

  factory _$CadenceMeetingCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceMeetingCreateDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'config_id')
  final String configId;
  @override
  final String title;
  @override
  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'facilitator_id')
  final String facilitatorId;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  final String? location;
  @override
  @JsonKey(name: 'meeting_link')
  final String? meetingLink;
  @override
  final String? agenda;

  @override
  String toString() {
    return 'CadenceMeetingCreateDto(id: $id, configId: $configId, title: $title, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, facilitatorId: $facilitatorId, createdBy: $createdBy, location: $location, meetingLink: $meetingLink, agenda: $agenda)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceMeetingCreateDtoImpl &&
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
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.meetingLink, meetingLink) ||
                other.meetingLink == meetingLink) &&
            (identical(other.agenda, agenda) || other.agenda == agenda));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    configId,
    title,
    scheduledAt,
    durationMinutes,
    facilitatorId,
    createdBy,
    location,
    meetingLink,
    agenda,
  );

  /// Create a copy of CadenceMeetingCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceMeetingCreateDtoImplCopyWith<_$CadenceMeetingCreateDtoImpl>
  get copyWith =>
      __$$CadenceMeetingCreateDtoImplCopyWithImpl<
        _$CadenceMeetingCreateDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceMeetingCreateDtoImplToJson(this);
  }
}

abstract class _CadenceMeetingCreateDto implements CadenceMeetingCreateDto {
  const factory _CadenceMeetingCreateDto({
    required final String id,
    @JsonKey(name: 'config_id') required final String configId,
    required final String title,
    @JsonKey(name: 'scheduled_at') required final DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') required final int durationMinutes,
    @JsonKey(name: 'facilitator_id') required final String facilitatorId,
    @JsonKey(name: 'created_by') required final String createdBy,
    final String? location,
    @JsonKey(name: 'meeting_link') final String? meetingLink,
    final String? agenda,
  }) = _$CadenceMeetingCreateDtoImpl;

  factory _CadenceMeetingCreateDto.fromJson(Map<String, dynamic> json) =
      _$CadenceMeetingCreateDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'config_id')
  String get configId;
  @override
  String get title;
  @override
  @JsonKey(name: 'scheduled_at')
  DateTime get scheduledAt;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'facilitator_id')
  String get facilitatorId;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  String? get location;
  @override
  @JsonKey(name: 'meeting_link')
  String? get meetingLink;
  @override
  String? get agenda;

  /// Create a copy of CadenceMeetingCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceMeetingCreateDtoImplCopyWith<_$CadenceMeetingCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceParticipantCreateDto _$CadenceParticipantCreateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceParticipantCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceParticipantCreateDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'meeting_id')
  String get meetingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'q1_previous_commitment')
  String? get q1PreviousCommitment => throw _privateConstructorUsedError;

  /// Serializes this CadenceParticipantCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceParticipantCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceParticipantCreateDtoCopyWith<CadenceParticipantCreateDto>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceParticipantCreateDtoCopyWith<$Res> {
  factory $CadenceParticipantCreateDtoCopyWith(
    CadenceParticipantCreateDto value,
    $Res Function(CadenceParticipantCreateDto) then,
  ) =
      _$CadenceParticipantCreateDtoCopyWithImpl<
        $Res,
        CadenceParticipantCreateDto
      >;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'meeting_id') String meetingId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'q1_previous_commitment') String? q1PreviousCommitment,
  });
}

/// @nodoc
class _$CadenceParticipantCreateDtoCopyWithImpl<
  $Res,
  $Val extends CadenceParticipantCreateDto
>
    implements $CadenceParticipantCreateDtoCopyWith<$Res> {
  _$CadenceParticipantCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceParticipantCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? meetingId = null,
    Object? userId = null,
    Object? q1PreviousCommitment = freezed,
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
            q1PreviousCommitment: freezed == q1PreviousCommitment
                ? _value.q1PreviousCommitment
                : q1PreviousCommitment // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceParticipantCreateDtoImplCopyWith<$Res>
    implements $CadenceParticipantCreateDtoCopyWith<$Res> {
  factory _$$CadenceParticipantCreateDtoImplCopyWith(
    _$CadenceParticipantCreateDtoImpl value,
    $Res Function(_$CadenceParticipantCreateDtoImpl) then,
  ) = __$$CadenceParticipantCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'meeting_id') String meetingId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'q1_previous_commitment') String? q1PreviousCommitment,
  });
}

/// @nodoc
class __$$CadenceParticipantCreateDtoImplCopyWithImpl<$Res>
    extends
        _$CadenceParticipantCreateDtoCopyWithImpl<
          $Res,
          _$CadenceParticipantCreateDtoImpl
        >
    implements _$$CadenceParticipantCreateDtoImplCopyWith<$Res> {
  __$$CadenceParticipantCreateDtoImplCopyWithImpl(
    _$CadenceParticipantCreateDtoImpl _value,
    $Res Function(_$CadenceParticipantCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceParticipantCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? meetingId = null,
    Object? userId = null,
    Object? q1PreviousCommitment = freezed,
  }) {
    return _then(
      _$CadenceParticipantCreateDtoImpl(
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
        q1PreviousCommitment: freezed == q1PreviousCommitment
            ? _value.q1PreviousCommitment
            : q1PreviousCommitment // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceParticipantCreateDtoImpl
    implements _CadenceParticipantCreateDto {
  const _$CadenceParticipantCreateDtoImpl({
    required this.id,
    @JsonKey(name: 'meeting_id') required this.meetingId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'q1_previous_commitment') this.q1PreviousCommitment,
  });

  factory _$CadenceParticipantCreateDtoImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CadenceParticipantCreateDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'meeting_id')
  final String meetingId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'q1_previous_commitment')
  final String? q1PreviousCommitment;

  @override
  String toString() {
    return 'CadenceParticipantCreateDto(id: $id, meetingId: $meetingId, userId: $userId, q1PreviousCommitment: $q1PreviousCommitment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceParticipantCreateDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.q1PreviousCommitment, q1PreviousCommitment) ||
                other.q1PreviousCommitment == q1PreviousCommitment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, meetingId, userId, q1PreviousCommitment);

  /// Create a copy of CadenceParticipantCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceParticipantCreateDtoImplCopyWith<_$CadenceParticipantCreateDtoImpl>
  get copyWith =>
      __$$CadenceParticipantCreateDtoImplCopyWithImpl<
        _$CadenceParticipantCreateDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceParticipantCreateDtoImplToJson(this);
  }
}

abstract class _CadenceParticipantCreateDto
    implements CadenceParticipantCreateDto {
  const factory _CadenceParticipantCreateDto({
    required final String id,
    @JsonKey(name: 'meeting_id') required final String meetingId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'q1_previous_commitment') final String? q1PreviousCommitment,
  }) = _$CadenceParticipantCreateDtoImpl;

  factory _CadenceParticipantCreateDto.fromJson(Map<String, dynamic> json) =
      _$CadenceParticipantCreateDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'meeting_id')
  String get meetingId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'q1_previous_commitment')
  String? get q1PreviousCommitment;

  /// Create a copy of CadenceParticipantCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceParticipantCreateDtoImplCopyWith<_$CadenceParticipantCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceConfigCreateDto _$CadenceConfigCreateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceConfigCreateDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceConfigCreateDto {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_role')
  String get targetRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'facilitator_role')
  String get facilitatorRole => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_time')
  String? get defaultTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'pre_meeting_hours')
  int get preMeetingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CadenceConfigCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceConfigCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceConfigCreateDtoCopyWith<CadenceConfigCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceConfigCreateDtoCopyWith<$Res> {
  factory $CadenceConfigCreateDtoCopyWith(
    CadenceConfigCreateDto value,
    $Res Function(CadenceConfigCreateDto) then,
  ) = _$CadenceConfigCreateDtoCopyWithImpl<$Res, CadenceConfigCreateDto>;
  @useResult
  $Res call({
    String name,
    String? description,
    @JsonKey(name: 'target_role') String targetRole,
    @JsonKey(name: 'facilitator_role') String facilitatorRole,
    String frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int preMeetingHours,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class _$CadenceConfigCreateDtoCopyWithImpl<
  $Res,
  $Val extends CadenceConfigCreateDto
>
    implements $CadenceConfigCreateDtoCopyWith<$Res> {
  _$CadenceConfigCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceConfigCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? targetRole = null,
    Object? facilitatorRole = null,
    Object? frequency = null,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = null,
    Object? preMeetingHours = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
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
                      as String,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CadenceConfigCreateDtoImplCopyWith<$Res>
    implements $CadenceConfigCreateDtoCopyWith<$Res> {
  factory _$$CadenceConfigCreateDtoImplCopyWith(
    _$CadenceConfigCreateDtoImpl value,
    $Res Function(_$CadenceConfigCreateDtoImpl) then,
  ) = __$$CadenceConfigCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? description,
    @JsonKey(name: 'target_role') String targetRole,
    @JsonKey(name: 'facilitator_role') String facilitatorRole,
    String frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int preMeetingHours,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class __$$CadenceConfigCreateDtoImplCopyWithImpl<$Res>
    extends
        _$CadenceConfigCreateDtoCopyWithImpl<$Res, _$CadenceConfigCreateDtoImpl>
    implements _$$CadenceConfigCreateDtoImplCopyWith<$Res> {
  __$$CadenceConfigCreateDtoImplCopyWithImpl(
    _$CadenceConfigCreateDtoImpl _value,
    $Res Function(_$CadenceConfigCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceConfigCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? targetRole = null,
    Object? facilitatorRole = null,
    Object? frequency = null,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = null,
    Object? preMeetingHours = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CadenceConfigCreateDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
                  as String,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CadenceConfigCreateDtoImpl implements _CadenceConfigCreateDto {
  const _$CadenceConfigCreateDtoImpl({
    required this.name,
    this.description,
    @JsonKey(name: 'target_role') required this.targetRole,
    @JsonKey(name: 'facilitator_role') required this.facilitatorRole,
    required this.frequency,
    @JsonKey(name: 'day_of_week') this.dayOfWeek,
    @JsonKey(name: 'day_of_month') this.dayOfMonth,
    @JsonKey(name: 'default_time') this.defaultTime,
    @JsonKey(name: 'duration_minutes') this.durationMinutes = 60,
    @JsonKey(name: 'pre_meeting_hours') this.preMeetingHours = 24,
    @JsonKey(name: 'is_active') this.isActive = true,
  });

  factory _$CadenceConfigCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceConfigCreateDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'target_role')
  final String targetRole;
  @override
  @JsonKey(name: 'facilitator_role')
  final String facilitatorRole;
  @override
  final String frequency;
  @override
  @JsonKey(name: 'day_of_week')
  final int? dayOfWeek;
  @override
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;
  @override
  @JsonKey(name: 'default_time')
  final String? defaultTime;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'pre_meeting_hours')
  final int preMeetingHours;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'CadenceConfigCreateDto(name: $name, description: $description, targetRole: $targetRole, facilitatorRole: $facilitatorRole, frequency: $frequency, dayOfWeek: $dayOfWeek, dayOfMonth: $dayOfMonth, defaultTime: $defaultTime, durationMinutes: $durationMinutes, preMeetingHours: $preMeetingHours, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceConfigCreateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
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
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    targetRole,
    facilitatorRole,
    frequency,
    dayOfWeek,
    dayOfMonth,
    defaultTime,
    durationMinutes,
    preMeetingHours,
    isActive,
  );

  /// Create a copy of CadenceConfigCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceConfigCreateDtoImplCopyWith<_$CadenceConfigCreateDtoImpl>
  get copyWith =>
      __$$CadenceConfigCreateDtoImplCopyWithImpl<_$CadenceConfigCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceConfigCreateDtoImplToJson(this);
  }
}

abstract class _CadenceConfigCreateDto implements CadenceConfigCreateDto {
  const factory _CadenceConfigCreateDto({
    required final String name,
    final String? description,
    @JsonKey(name: 'target_role') required final String targetRole,
    @JsonKey(name: 'facilitator_role') required final String facilitatorRole,
    required final String frequency,
    @JsonKey(name: 'day_of_week') final int? dayOfWeek,
    @JsonKey(name: 'day_of_month') final int? dayOfMonth,
    @JsonKey(name: 'default_time') final String? defaultTime,
    @JsonKey(name: 'duration_minutes') final int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') final int preMeetingHours,
    @JsonKey(name: 'is_active') final bool isActive,
  }) = _$CadenceConfigCreateDtoImpl;

  factory _CadenceConfigCreateDto.fromJson(Map<String, dynamic> json) =
      _$CadenceConfigCreateDtoImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'target_role')
  String get targetRole;
  @override
  @JsonKey(name: 'facilitator_role')
  String get facilitatorRole;
  @override
  String get frequency;
  @override
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek;
  @override
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth;
  @override
  @JsonKey(name: 'default_time')
  String? get defaultTime;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'pre_meeting_hours')
  int get preMeetingHours;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of CadenceConfigCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceConfigCreateDtoImplCopyWith<_$CadenceConfigCreateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CadenceConfigUpdateDto _$CadenceConfigUpdateDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CadenceConfigUpdateDto.fromJson(json);
}

/// @nodoc
mixin _$CadenceConfigUpdateDto {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_role')
  String? get targetRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'facilitator_role')
  String? get facilitatorRole => throw _privateConstructorUsedError;
  String? get frequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_time')
  String? get defaultTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'pre_meeting_hours')
  int? get preMeetingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this CadenceConfigUpdateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CadenceConfigUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CadenceConfigUpdateDtoCopyWith<CadenceConfigUpdateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CadenceConfigUpdateDtoCopyWith<$Res> {
  factory $CadenceConfigUpdateDtoCopyWith(
    CadenceConfigUpdateDto value,
    $Res Function(CadenceConfigUpdateDto) then,
  ) = _$CadenceConfigUpdateDtoCopyWithImpl<$Res, CadenceConfigUpdateDto>;
  @useResult
  $Res call({
    String? name,
    String? description,
    @JsonKey(name: 'target_role') String? targetRole,
    @JsonKey(name: 'facilitator_role') String? facilitatorRole,
    String? frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int? preMeetingHours,
    @JsonKey(name: 'is_active') bool? isActive,
  });
}

/// @nodoc
class _$CadenceConfigUpdateDtoCopyWithImpl<
  $Res,
  $Val extends CadenceConfigUpdateDto
>
    implements $CadenceConfigUpdateDtoCopyWith<$Res> {
  _$CadenceConfigUpdateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CadenceConfigUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? targetRole = freezed,
    Object? facilitatorRole = freezed,
    Object? frequency = freezed,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = freezed,
    Object? preMeetingHours = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetRole: freezed == targetRole
                ? _value.targetRole
                : targetRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            facilitatorRole: freezed == facilitatorRole
                ? _value.facilitatorRole
                : facilitatorRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            frequency: freezed == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            preMeetingHours: freezed == preMeetingHours
                ? _value.preMeetingHours
                : preMeetingHours // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$CadenceConfigUpdateDtoImplCopyWith<$Res>
    implements $CadenceConfigUpdateDtoCopyWith<$Res> {
  factory _$$CadenceConfigUpdateDtoImplCopyWith(
    _$CadenceConfigUpdateDtoImpl value,
    $Res Function(_$CadenceConfigUpdateDtoImpl) then,
  ) = __$$CadenceConfigUpdateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? description,
    @JsonKey(name: 'target_role') String? targetRole,
    @JsonKey(name: 'facilitator_role') String? facilitatorRole,
    String? frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int? preMeetingHours,
    @JsonKey(name: 'is_active') bool? isActive,
  });
}

/// @nodoc
class __$$CadenceConfigUpdateDtoImplCopyWithImpl<$Res>
    extends
        _$CadenceConfigUpdateDtoCopyWithImpl<$Res, _$CadenceConfigUpdateDtoImpl>
    implements _$$CadenceConfigUpdateDtoImplCopyWith<$Res> {
  __$$CadenceConfigUpdateDtoImplCopyWithImpl(
    _$CadenceConfigUpdateDtoImpl _value,
    $Res Function(_$CadenceConfigUpdateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CadenceConfigUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? targetRole = freezed,
    Object? facilitatorRole = freezed,
    Object? frequency = freezed,
    Object? dayOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? defaultTime = freezed,
    Object? durationMinutes = freezed,
    Object? preMeetingHours = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _$CadenceConfigUpdateDtoImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetRole: freezed == targetRole
            ? _value.targetRole
            : targetRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        facilitatorRole: freezed == facilitatorRole
            ? _value.facilitatorRole
            : facilitatorRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        frequency: freezed == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        preMeetingHours: freezed == preMeetingHours
            ? _value.preMeetingHours
            : preMeetingHours // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$CadenceConfigUpdateDtoImpl implements _CadenceConfigUpdateDto {
  const _$CadenceConfigUpdateDtoImpl({
    this.name,
    this.description,
    @JsonKey(name: 'target_role') this.targetRole,
    @JsonKey(name: 'facilitator_role') this.facilitatorRole,
    this.frequency,
    @JsonKey(name: 'day_of_week') this.dayOfWeek,
    @JsonKey(name: 'day_of_month') this.dayOfMonth,
    @JsonKey(name: 'default_time') this.defaultTime,
    @JsonKey(name: 'duration_minutes') this.durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') this.preMeetingHours,
    @JsonKey(name: 'is_active') this.isActive,
  });

  factory _$CadenceConfigUpdateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CadenceConfigUpdateDtoImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'target_role')
  final String? targetRole;
  @override
  @JsonKey(name: 'facilitator_role')
  final String? facilitatorRole;
  @override
  final String? frequency;
  @override
  @JsonKey(name: 'day_of_week')
  final int? dayOfWeek;
  @override
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;
  @override
  @JsonKey(name: 'default_time')
  final String? defaultTime;
  @override
  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;
  @override
  @JsonKey(name: 'pre_meeting_hours')
  final int? preMeetingHours;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;

  @override
  String toString() {
    return 'CadenceConfigUpdateDto(name: $name, description: $description, targetRole: $targetRole, facilitatorRole: $facilitatorRole, frequency: $frequency, dayOfWeek: $dayOfWeek, dayOfMonth: $dayOfMonth, defaultTime: $defaultTime, durationMinutes: $durationMinutes, preMeetingHours: $preMeetingHours, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CadenceConfigUpdateDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
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
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    targetRole,
    facilitatorRole,
    frequency,
    dayOfWeek,
    dayOfMonth,
    defaultTime,
    durationMinutes,
    preMeetingHours,
    isActive,
  );

  /// Create a copy of CadenceConfigUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CadenceConfigUpdateDtoImplCopyWith<_$CadenceConfigUpdateDtoImpl>
  get copyWith =>
      __$$CadenceConfigUpdateDtoImplCopyWithImpl<_$CadenceConfigUpdateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CadenceConfigUpdateDtoImplToJson(this);
  }
}

abstract class _CadenceConfigUpdateDto implements CadenceConfigUpdateDto {
  const factory _CadenceConfigUpdateDto({
    final String? name,
    final String? description,
    @JsonKey(name: 'target_role') final String? targetRole,
    @JsonKey(name: 'facilitator_role') final String? facilitatorRole,
    final String? frequency,
    @JsonKey(name: 'day_of_week') final int? dayOfWeek,
    @JsonKey(name: 'day_of_month') final int? dayOfMonth,
    @JsonKey(name: 'default_time') final String? defaultTime,
    @JsonKey(name: 'duration_minutes') final int? durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') final int? preMeetingHours,
    @JsonKey(name: 'is_active') final bool? isActive,
  }) = _$CadenceConfigUpdateDtoImpl;

  factory _CadenceConfigUpdateDto.fromJson(Map<String, dynamic> json) =
      _$CadenceConfigUpdateDtoImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'target_role')
  String? get targetRole;
  @override
  @JsonKey(name: 'facilitator_role')
  String? get facilitatorRole;
  @override
  String? get frequency;
  @override
  @JsonKey(name: 'day_of_week')
  int? get dayOfWeek;
  @override
  @JsonKey(name: 'day_of_month')
  int? get dayOfMonth;
  @override
  @JsonKey(name: 'default_time')
  String? get defaultTime;
  @override
  @JsonKey(name: 'duration_minutes')
  int? get durationMinutes;
  @override
  @JsonKey(name: 'pre_meeting_hours')
  int? get preMeetingHours;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;

  /// Create a copy of CadenceConfigUpdateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CadenceConfigUpdateDtoImplCopyWith<_$CadenceConfigUpdateDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
