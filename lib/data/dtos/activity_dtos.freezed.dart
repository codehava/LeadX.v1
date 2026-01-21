// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActivityCreateDto _$ActivityCreateDtoFromJson(Map<String, dynamic> json) {
  return _ActivityCreateDto.fromJson(json);
}

/// @nodoc
mixin _$ActivityCreateDto {
  String get objectType =>
      throw _privateConstructorUsedError; // CUSTOMER, HVC, BROKER
  String get activityTypeId => throw _privateConstructorUsedError;
  DateTime get scheduledDatetime => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get hvcId => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get notes =>
      throw _privateConstructorUsedError; // GPS data captured when creating (for audit log)
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this ActivityCreateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCreateDtoCopyWith<ActivityCreateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCreateDtoCopyWith<$Res> {
  factory $ActivityCreateDtoCopyWith(
    ActivityCreateDto value,
    $Res Function(ActivityCreateDto) then,
  ) = _$ActivityCreateDtoCopyWithImpl<$Res, ActivityCreateDto>;
  @useResult
  $Res call({
    String objectType,
    String activityTypeId,
    DateTime scheduledDatetime,
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? summary,
    String? notes,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class _$ActivityCreateDtoCopyWithImpl<$Res, $Val extends ActivityCreateDto>
    implements $ActivityCreateDtoCopyWith<$Res> {
  _$ActivityCreateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? objectType = null,
    Object? activityTypeId = null,
    Object? scheduledDatetime = null,
    Object? customerId = freezed,
    Object? hvcId = freezed,
    Object? brokerId = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            objectType: null == objectType
                ? _value.objectType
                : objectType // ignore: cast_nullable_to_non_nullable
                      as String,
            activityTypeId: null == activityTypeId
                ? _value.activityTypeId
                : activityTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledDatetime: null == scheduledDatetime
                ? _value.scheduledDatetime
                : scheduledDatetime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hvcId: freezed == hvcId
                ? _value.hvcId
                : hvcId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityCreateDtoImplCopyWith<$Res>
    implements $ActivityCreateDtoCopyWith<$Res> {
  factory _$$ActivityCreateDtoImplCopyWith(
    _$ActivityCreateDtoImpl value,
    $Res Function(_$ActivityCreateDtoImpl) then,
  ) = __$$ActivityCreateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String objectType,
    String activityTypeId,
    DateTime scheduledDatetime,
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? summary,
    String? notes,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class __$$ActivityCreateDtoImplCopyWithImpl<$Res>
    extends _$ActivityCreateDtoCopyWithImpl<$Res, _$ActivityCreateDtoImpl>
    implements _$$ActivityCreateDtoImplCopyWith<$Res> {
  __$$ActivityCreateDtoImplCopyWithImpl(
    _$ActivityCreateDtoImpl _value,
    $Res Function(_$ActivityCreateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? objectType = null,
    Object? activityTypeId = null,
    Object? scheduledDatetime = null,
    Object? customerId = freezed,
    Object? hvcId = freezed,
    Object? brokerId = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$ActivityCreateDtoImpl(
        objectType: null == objectType
            ? _value.objectType
            : objectType // ignore: cast_nullable_to_non_nullable
                  as String,
        activityTypeId: null == activityTypeId
            ? _value.activityTypeId
            : activityTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledDatetime: null == scheduledDatetime
            ? _value.scheduledDatetime
            : scheduledDatetime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hvcId: freezed == hvcId
            ? _value.hvcId
            : hvcId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityCreateDtoImpl implements _ActivityCreateDto {
  const _$ActivityCreateDtoImpl({
    required this.objectType,
    required this.activityTypeId,
    required this.scheduledDatetime,
    this.customerId,
    this.hvcId,
    this.brokerId,
    this.summary,
    this.notes,
    this.latitude,
    this.longitude,
  });

  factory _$ActivityCreateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityCreateDtoImplFromJson(json);

  @override
  final String objectType;
  // CUSTOMER, HVC, BROKER
  @override
  final String activityTypeId;
  @override
  final DateTime scheduledDatetime;
  @override
  final String? customerId;
  @override
  final String? hvcId;
  @override
  final String? brokerId;
  @override
  final String? summary;
  @override
  final String? notes;
  // GPS data captured when creating (for audit log)
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'ActivityCreateDto(objectType: $objectType, activityTypeId: $activityTypeId, scheduledDatetime: $scheduledDatetime, customerId: $customerId, hvcId: $hvcId, brokerId: $brokerId, summary: $summary, notes: $notes, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityCreateDtoImpl &&
            (identical(other.objectType, objectType) ||
                other.objectType == objectType) &&
            (identical(other.activityTypeId, activityTypeId) ||
                other.activityTypeId == activityTypeId) &&
            (identical(other.scheduledDatetime, scheduledDatetime) ||
                other.scheduledDatetime == scheduledDatetime) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    objectType,
    activityTypeId,
    scheduledDatetime,
    customerId,
    hvcId,
    brokerId,
    summary,
    notes,
    latitude,
    longitude,
  );

  /// Create a copy of ActivityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityCreateDtoImplCopyWith<_$ActivityCreateDtoImpl> get copyWith =>
      __$$ActivityCreateDtoImplCopyWithImpl<_$ActivityCreateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityCreateDtoImplToJson(this);
  }
}

abstract class _ActivityCreateDto implements ActivityCreateDto {
  const factory _ActivityCreateDto({
    required final String objectType,
    required final String activityTypeId,
    required final DateTime scheduledDatetime,
    final String? customerId,
    final String? hvcId,
    final String? brokerId,
    final String? summary,
    final String? notes,
    final double? latitude,
    final double? longitude,
  }) = _$ActivityCreateDtoImpl;

  factory _ActivityCreateDto.fromJson(Map<String, dynamic> json) =
      _$ActivityCreateDtoImpl.fromJson;

  @override
  String get objectType; // CUSTOMER, HVC, BROKER
  @override
  String get activityTypeId;
  @override
  DateTime get scheduledDatetime;
  @override
  String? get customerId;
  @override
  String? get hvcId;
  @override
  String? get brokerId;
  @override
  String? get summary;
  @override
  String? get notes; // GPS data captured when creating (for audit log)
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of ActivityCreateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityCreateDtoImplCopyWith<_$ActivityCreateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImmediateActivityDto _$ImmediateActivityDtoFromJson(Map<String, dynamic> json) {
  return _ImmediateActivityDto.fromJson(json);
}

/// @nodoc
mixin _$ImmediateActivityDto {
  String get objectType =>
      throw _privateConstructorUsedError; // CUSTOMER, HVC, BROKER
  String get activityTypeId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get hvcId => throw _privateConstructorUsedError;
  String? get brokerId => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get notes =>
      throw _privateConstructorUsedError; // GPS data captured at time of logging
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double? get locationAccuracy => throw _privateConstructorUsedError;
  double? get distanceFromTarget => throw _privateConstructorUsedError;
  bool get isLocationOverride => throw _privateConstructorUsedError;
  String? get overrideReason => throw _privateConstructorUsedError;

  /// Serializes this ImmediateActivityDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImmediateActivityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImmediateActivityDtoCopyWith<ImmediateActivityDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImmediateActivityDtoCopyWith<$Res> {
  factory $ImmediateActivityDtoCopyWith(
    ImmediateActivityDto value,
    $Res Function(ImmediateActivityDto) then,
  ) = _$ImmediateActivityDtoCopyWithImpl<$Res, ImmediateActivityDto>;
  @useResult
  $Res call({
    String objectType,
    String activityTypeId,
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? summary,
    String? notes,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    bool isLocationOverride,
    String? overrideReason,
  });
}

/// @nodoc
class _$ImmediateActivityDtoCopyWithImpl<
  $Res,
  $Val extends ImmediateActivityDto
>
    implements $ImmediateActivityDtoCopyWith<$Res> {
  _$ImmediateActivityDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImmediateActivityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? objectType = null,
    Object? activityTypeId = null,
    Object? customerId = freezed,
    Object? hvcId = freezed,
    Object? brokerId = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationAccuracy = freezed,
    Object? distanceFromTarget = freezed,
    Object? isLocationOverride = null,
    Object? overrideReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            objectType: null == objectType
                ? _value.objectType
                : objectType // ignore: cast_nullable_to_non_nullable
                      as String,
            activityTypeId: null == activityTypeId
                ? _value.activityTypeId
                : activityTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hvcId: freezed == hvcId
                ? _value.hvcId
                : hvcId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            locationAccuracy: freezed == locationAccuracy
                ? _value.locationAccuracy
                : locationAccuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            distanceFromTarget: freezed == distanceFromTarget
                ? _value.distanceFromTarget
                : distanceFromTarget // ignore: cast_nullable_to_non_nullable
                      as double?,
            isLocationOverride: null == isLocationOverride
                ? _value.isLocationOverride
                : isLocationOverride // ignore: cast_nullable_to_non_nullable
                      as bool,
            overrideReason: freezed == overrideReason
                ? _value.overrideReason
                : overrideReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImmediateActivityDtoImplCopyWith<$Res>
    implements $ImmediateActivityDtoCopyWith<$Res> {
  factory _$$ImmediateActivityDtoImplCopyWith(
    _$ImmediateActivityDtoImpl value,
    $Res Function(_$ImmediateActivityDtoImpl) then,
  ) = __$$ImmediateActivityDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String objectType,
    String activityTypeId,
    String? customerId,
    String? hvcId,
    String? brokerId,
    String? summary,
    String? notes,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    bool isLocationOverride,
    String? overrideReason,
  });
}

/// @nodoc
class __$$ImmediateActivityDtoImplCopyWithImpl<$Res>
    extends _$ImmediateActivityDtoCopyWithImpl<$Res, _$ImmediateActivityDtoImpl>
    implements _$$ImmediateActivityDtoImplCopyWith<$Res> {
  __$$ImmediateActivityDtoImplCopyWithImpl(
    _$ImmediateActivityDtoImpl _value,
    $Res Function(_$ImmediateActivityDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImmediateActivityDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? objectType = null,
    Object? activityTypeId = null,
    Object? customerId = freezed,
    Object? hvcId = freezed,
    Object? brokerId = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationAccuracy = freezed,
    Object? distanceFromTarget = freezed,
    Object? isLocationOverride = null,
    Object? overrideReason = freezed,
  }) {
    return _then(
      _$ImmediateActivityDtoImpl(
        objectType: null == objectType
            ? _value.objectType
            : objectType // ignore: cast_nullable_to_non_nullable
                  as String,
        activityTypeId: null == activityTypeId
            ? _value.activityTypeId
            : activityTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hvcId: freezed == hvcId
            ? _value.hvcId
            : hvcId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        locationAccuracy: freezed == locationAccuracy
            ? _value.locationAccuracy
            : locationAccuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        distanceFromTarget: freezed == distanceFromTarget
            ? _value.distanceFromTarget
            : distanceFromTarget // ignore: cast_nullable_to_non_nullable
                  as double?,
        isLocationOverride: null == isLocationOverride
            ? _value.isLocationOverride
            : isLocationOverride // ignore: cast_nullable_to_non_nullable
                  as bool,
        overrideReason: freezed == overrideReason
            ? _value.overrideReason
            : overrideReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImmediateActivityDtoImpl implements _ImmediateActivityDto {
  const _$ImmediateActivityDtoImpl({
    required this.objectType,
    required this.activityTypeId,
    this.customerId,
    this.hvcId,
    this.brokerId,
    this.summary,
    this.notes,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.distanceFromTarget,
    this.isLocationOverride = false,
    this.overrideReason,
  });

  factory _$ImmediateActivityDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImmediateActivityDtoImplFromJson(json);

  @override
  final String objectType;
  // CUSTOMER, HVC, BROKER
  @override
  final String activityTypeId;
  @override
  final String? customerId;
  @override
  final String? hvcId;
  @override
  final String? brokerId;
  @override
  final String? summary;
  @override
  final String? notes;
  // GPS data captured at time of logging
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double? locationAccuracy;
  @override
  final double? distanceFromTarget;
  @override
  @JsonKey()
  final bool isLocationOverride;
  @override
  final String? overrideReason;

  @override
  String toString() {
    return 'ImmediateActivityDto(objectType: $objectType, activityTypeId: $activityTypeId, customerId: $customerId, hvcId: $hvcId, brokerId: $brokerId, summary: $summary, notes: $notes, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, distanceFromTarget: $distanceFromTarget, isLocationOverride: $isLocationOverride, overrideReason: $overrideReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImmediateActivityDtoImpl &&
            (identical(other.objectType, objectType) ||
                other.objectType == objectType) &&
            (identical(other.activityTypeId, activityTypeId) ||
                other.activityTypeId == activityTypeId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationAccuracy, locationAccuracy) ||
                other.locationAccuracy == locationAccuracy) &&
            (identical(other.distanceFromTarget, distanceFromTarget) ||
                other.distanceFromTarget == distanceFromTarget) &&
            (identical(other.isLocationOverride, isLocationOverride) ||
                other.isLocationOverride == isLocationOverride) &&
            (identical(other.overrideReason, overrideReason) ||
                other.overrideReason == overrideReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    objectType,
    activityTypeId,
    customerId,
    hvcId,
    brokerId,
    summary,
    notes,
    latitude,
    longitude,
    locationAccuracy,
    distanceFromTarget,
    isLocationOverride,
    overrideReason,
  );

  /// Create a copy of ImmediateActivityDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImmediateActivityDtoImplCopyWith<_$ImmediateActivityDtoImpl>
  get copyWith =>
      __$$ImmediateActivityDtoImplCopyWithImpl<_$ImmediateActivityDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ImmediateActivityDtoImplToJson(this);
  }
}

abstract class _ImmediateActivityDto implements ImmediateActivityDto {
  const factory _ImmediateActivityDto({
    required final String objectType,
    required final String activityTypeId,
    final String? customerId,
    final String? hvcId,
    final String? brokerId,
    final String? summary,
    final String? notes,
    final double? latitude,
    final double? longitude,
    final double? locationAccuracy,
    final double? distanceFromTarget,
    final bool isLocationOverride,
    final String? overrideReason,
  }) = _$ImmediateActivityDtoImpl;

  factory _ImmediateActivityDto.fromJson(Map<String, dynamic> json) =
      _$ImmediateActivityDtoImpl.fromJson;

  @override
  String get objectType; // CUSTOMER, HVC, BROKER
  @override
  String get activityTypeId;
  @override
  String? get customerId;
  @override
  String? get hvcId;
  @override
  String? get brokerId;
  @override
  String? get summary;
  @override
  String? get notes; // GPS data captured at time of logging
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double? get locationAccuracy;
  @override
  double? get distanceFromTarget;
  @override
  bool get isLocationOverride;
  @override
  String? get overrideReason;

  /// Create a copy of ImmediateActivityDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImmediateActivityDtoImplCopyWith<_$ImmediateActivityDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ActivityExecutionDto _$ActivityExecutionDtoFromJson(Map<String, dynamic> json) {
  return _ActivityExecutionDto.fromJson(json);
}

/// @nodoc
mixin _$ActivityExecutionDto {
  // GPS data
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double? get locationAccuracy => throw _privateConstructorUsedError;
  double? get distanceFromTarget => throw _privateConstructorUsedError;
  bool get isLocationOverride => throw _privateConstructorUsedError;
  String? get overrideReason =>
      throw _privateConstructorUsedError; // Execution notes
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ActivityExecutionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityExecutionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityExecutionDtoCopyWith<ActivityExecutionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityExecutionDtoCopyWith<$Res> {
  factory $ActivityExecutionDtoCopyWith(
    ActivityExecutionDto value,
    $Res Function(ActivityExecutionDto) then,
  ) = _$ActivityExecutionDtoCopyWithImpl<$Res, ActivityExecutionDto>;
  @useResult
  $Res call({
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    bool isLocationOverride,
    String? overrideReason,
    String? notes,
  });
}

/// @nodoc
class _$ActivityExecutionDtoCopyWithImpl<
  $Res,
  $Val extends ActivityExecutionDto
>
    implements $ActivityExecutionDtoCopyWith<$Res> {
  _$ActivityExecutionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityExecutionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationAccuracy = freezed,
    Object? distanceFromTarget = freezed,
    Object? isLocationOverride = null,
    Object? overrideReason = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            locationAccuracy: freezed == locationAccuracy
                ? _value.locationAccuracy
                : locationAccuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            distanceFromTarget: freezed == distanceFromTarget
                ? _value.distanceFromTarget
                : distanceFromTarget // ignore: cast_nullable_to_non_nullable
                      as double?,
            isLocationOverride: null == isLocationOverride
                ? _value.isLocationOverride
                : isLocationOverride // ignore: cast_nullable_to_non_nullable
                      as bool,
            overrideReason: freezed == overrideReason
                ? _value.overrideReason
                : overrideReason // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$ActivityExecutionDtoImplCopyWith<$Res>
    implements $ActivityExecutionDtoCopyWith<$Res> {
  factory _$$ActivityExecutionDtoImplCopyWith(
    _$ActivityExecutionDtoImpl value,
    $Res Function(_$ActivityExecutionDtoImpl) then,
  ) = __$$ActivityExecutionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    double? distanceFromTarget,
    bool isLocationOverride,
    String? overrideReason,
    String? notes,
  });
}

/// @nodoc
class __$$ActivityExecutionDtoImplCopyWithImpl<$Res>
    extends _$ActivityExecutionDtoCopyWithImpl<$Res, _$ActivityExecutionDtoImpl>
    implements _$$ActivityExecutionDtoImplCopyWith<$Res> {
  __$$ActivityExecutionDtoImplCopyWithImpl(
    _$ActivityExecutionDtoImpl _value,
    $Res Function(_$ActivityExecutionDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityExecutionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationAccuracy = freezed,
    Object? distanceFromTarget = freezed,
    Object? isLocationOverride = null,
    Object? overrideReason = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$ActivityExecutionDtoImpl(
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        locationAccuracy: freezed == locationAccuracy
            ? _value.locationAccuracy
            : locationAccuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        distanceFromTarget: freezed == distanceFromTarget
            ? _value.distanceFromTarget
            : distanceFromTarget // ignore: cast_nullable_to_non_nullable
                  as double?,
        isLocationOverride: null == isLocationOverride
            ? _value.isLocationOverride
            : isLocationOverride // ignore: cast_nullable_to_non_nullable
                  as bool,
        overrideReason: freezed == overrideReason
            ? _value.overrideReason
            : overrideReason // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$ActivityExecutionDtoImpl implements _ActivityExecutionDto {
  const _$ActivityExecutionDtoImpl({
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.distanceFromTarget,
    this.isLocationOverride = false,
    this.overrideReason,
    this.notes,
  });

  factory _$ActivityExecutionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityExecutionDtoImplFromJson(json);

  // GPS data
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double? locationAccuracy;
  @override
  final double? distanceFromTarget;
  @override
  @JsonKey()
  final bool isLocationOverride;
  @override
  final String? overrideReason;
  // Execution notes
  @override
  final String? notes;

  @override
  String toString() {
    return 'ActivityExecutionDto(latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, distanceFromTarget: $distanceFromTarget, isLocationOverride: $isLocationOverride, overrideReason: $overrideReason, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityExecutionDtoImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationAccuracy, locationAccuracy) ||
                other.locationAccuracy == locationAccuracy) &&
            (identical(other.distanceFromTarget, distanceFromTarget) ||
                other.distanceFromTarget == distanceFromTarget) &&
            (identical(other.isLocationOverride, isLocationOverride) ||
                other.isLocationOverride == isLocationOverride) &&
            (identical(other.overrideReason, overrideReason) ||
                other.overrideReason == overrideReason) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latitude,
    longitude,
    locationAccuracy,
    distanceFromTarget,
    isLocationOverride,
    overrideReason,
    notes,
  );

  /// Create a copy of ActivityExecutionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityExecutionDtoImplCopyWith<_$ActivityExecutionDtoImpl>
  get copyWith =>
      __$$ActivityExecutionDtoImplCopyWithImpl<_$ActivityExecutionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityExecutionDtoImplToJson(this);
  }
}

abstract class _ActivityExecutionDto implements ActivityExecutionDto {
  const factory _ActivityExecutionDto({
    final double? latitude,
    final double? longitude,
    final double? locationAccuracy,
    final double? distanceFromTarget,
    final bool isLocationOverride,
    final String? overrideReason,
    final String? notes,
  }) = _$ActivityExecutionDtoImpl;

  factory _ActivityExecutionDto.fromJson(Map<String, dynamic> json) =
      _$ActivityExecutionDtoImpl.fromJson;

  // GPS data
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double? get locationAccuracy;
  @override
  double? get distanceFromTarget;
  @override
  bool get isLocationOverride;
  @override
  String? get overrideReason; // Execution notes
  @override
  String? get notes;

  /// Create a copy of ActivityExecutionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityExecutionDtoImplCopyWith<_$ActivityExecutionDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ActivityRescheduleDto _$ActivityRescheduleDtoFromJson(
  Map<String, dynamic> json,
) {
  return _ActivityRescheduleDto.fromJson(json);
}

/// @nodoc
mixin _$ActivityRescheduleDto {
  DateTime get newScheduledDatetime => throw _privateConstructorUsedError;
  String get reason =>
      throw _privateConstructorUsedError; // GPS data captured when rescheduling (for audit log)
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this ActivityRescheduleDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityRescheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityRescheduleDtoCopyWith<ActivityRescheduleDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityRescheduleDtoCopyWith<$Res> {
  factory $ActivityRescheduleDtoCopyWith(
    ActivityRescheduleDto value,
    $Res Function(ActivityRescheduleDto) then,
  ) = _$ActivityRescheduleDtoCopyWithImpl<$Res, ActivityRescheduleDto>;
  @useResult
  $Res call({
    DateTime newScheduledDatetime,
    String reason,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class _$ActivityRescheduleDtoCopyWithImpl<
  $Res,
  $Val extends ActivityRescheduleDto
>
    implements $ActivityRescheduleDtoCopyWith<$Res> {
  _$ActivityRescheduleDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityRescheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? newScheduledDatetime = null,
    Object? reason = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            newScheduledDatetime: null == newScheduledDatetime
                ? _value.newScheduledDatetime
                : newScheduledDatetime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityRescheduleDtoImplCopyWith<$Res>
    implements $ActivityRescheduleDtoCopyWith<$Res> {
  factory _$$ActivityRescheduleDtoImplCopyWith(
    _$ActivityRescheduleDtoImpl value,
    $Res Function(_$ActivityRescheduleDtoImpl) then,
  ) = __$$ActivityRescheduleDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime newScheduledDatetime,
    String reason,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class __$$ActivityRescheduleDtoImplCopyWithImpl<$Res>
    extends
        _$ActivityRescheduleDtoCopyWithImpl<$Res, _$ActivityRescheduleDtoImpl>
    implements _$$ActivityRescheduleDtoImplCopyWith<$Res> {
  __$$ActivityRescheduleDtoImplCopyWithImpl(
    _$ActivityRescheduleDtoImpl _value,
    $Res Function(_$ActivityRescheduleDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityRescheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? newScheduledDatetime = null,
    Object? reason = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$ActivityRescheduleDtoImpl(
        newScheduledDatetime: null == newScheduledDatetime
            ? _value.newScheduledDatetime
            : newScheduledDatetime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityRescheduleDtoImpl implements _ActivityRescheduleDto {
  const _$ActivityRescheduleDtoImpl({
    required this.newScheduledDatetime,
    required this.reason,
    this.latitude,
    this.longitude,
  });

  factory _$ActivityRescheduleDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityRescheduleDtoImplFromJson(json);

  @override
  final DateTime newScheduledDatetime;
  @override
  final String reason;
  // GPS data captured when rescheduling (for audit log)
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'ActivityRescheduleDto(newScheduledDatetime: $newScheduledDatetime, reason: $reason, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityRescheduleDtoImpl &&
            (identical(other.newScheduledDatetime, newScheduledDatetime) ||
                other.newScheduledDatetime == newScheduledDatetime) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    newScheduledDatetime,
    reason,
    latitude,
    longitude,
  );

  /// Create a copy of ActivityRescheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityRescheduleDtoImplCopyWith<_$ActivityRescheduleDtoImpl>
  get copyWith =>
      __$$ActivityRescheduleDtoImplCopyWithImpl<_$ActivityRescheduleDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityRescheduleDtoImplToJson(this);
  }
}

abstract class _ActivityRescheduleDto implements ActivityRescheduleDto {
  const factory _ActivityRescheduleDto({
    required final DateTime newScheduledDatetime,
    required final String reason,
    final double? latitude,
    final double? longitude,
  }) = _$ActivityRescheduleDtoImpl;

  factory _ActivityRescheduleDto.fromJson(Map<String, dynamic> json) =
      _$ActivityRescheduleDtoImpl.fromJson;

  @override
  DateTime get newScheduledDatetime;
  @override
  String get reason; // GPS data captured when rescheduling (for audit log)
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of ActivityRescheduleDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityRescheduleDtoImplCopyWith<_$ActivityRescheduleDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ActivitySyncDto _$ActivitySyncDtoFromJson(Map<String, dynamic> json) {
  return _ActivitySyncDto.fromJson(json);
}

/// @nodoc
mixin _$ActivitySyncDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'object_type')
  String get objectType => throw _privateConstructorUsedError;
  @JsonKey(name: 'activity_type_id')
  String get activityTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_datetime')
  DateTime get scheduledDatetime => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'hvc_id')
  String? get hvcId => throw _privateConstructorUsedError;
  @JsonKey(name: 'broker_id')
  String? get brokerId => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_immediate')
  bool get isImmediate => throw _privateConstructorUsedError;
  @JsonKey(name: 'executed_at')
  DateTime? get executedAt => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_accuracy')
  double? get locationAccuracy => throw _privateConstructorUsedError;
  @JsonKey(name: 'distance_from_target')
  double? get distanceFromTarget => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_location_override')
  bool get isLocationOverride => throw _privateConstructorUsedError;
  @JsonKey(name: 'override_reason')
  String? get overrideReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'rescheduled_from_id')
  String? get rescheduledFromId => throw _privateConstructorUsedError;
  @JsonKey(name: 'rescheduled_to_id')
  String? get rescheduledToId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancel_reason')
  String? get cancelReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this ActivitySyncDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivitySyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivitySyncDtoCopyWith<ActivitySyncDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivitySyncDtoCopyWith<$Res> {
  factory $ActivitySyncDtoCopyWith(
    ActivitySyncDto value,
    $Res Function(ActivitySyncDto) then,
  ) = _$ActivitySyncDtoCopyWithImpl<$Res, ActivitySyncDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'created_by') String createdBy,
    @JsonKey(name: 'object_type') String objectType,
    @JsonKey(name: 'activity_type_id') String activityTypeId,
    @JsonKey(name: 'scheduled_datetime') DateTime scheduledDatetime,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'hvc_id') String? hvcId,
    @JsonKey(name: 'broker_id') String? brokerId,
    String? summary,
    String? notes,
    @JsonKey(name: 'is_immediate') bool isImmediate,
    @JsonKey(name: 'executed_at') DateTime? executedAt,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'location_accuracy') double? locationAccuracy,
    @JsonKey(name: 'distance_from_target') double? distanceFromTarget,
    @JsonKey(name: 'is_location_override') bool isLocationOverride,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'rescheduled_from_id') String? rescheduledFromId,
    @JsonKey(name: 'rescheduled_to_id') String? rescheduledToId,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class _$ActivitySyncDtoCopyWithImpl<$Res, $Val extends ActivitySyncDto>
    implements $ActivitySyncDtoCopyWith<$Res> {
  _$ActivitySyncDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivitySyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdBy = null,
    Object? objectType = null,
    Object? activityTypeId = null,
    Object? scheduledDatetime = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customerId = freezed,
    Object? hvcId = freezed,
    Object? brokerId = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? isImmediate = null,
    Object? executedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationAccuracy = freezed,
    Object? distanceFromTarget = freezed,
    Object? isLocationOverride = null,
    Object? overrideReason = freezed,
    Object? rescheduledFromId = freezed,
    Object? rescheduledToId = freezed,
    Object? cancelledAt = freezed,
    Object? cancelReason = freezed,
    Object? deletedAt = freezed,
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
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            objectType: null == objectType
                ? _value.objectType
                : objectType // ignore: cast_nullable_to_non_nullable
                      as String,
            activityTypeId: null == activityTypeId
                ? _value.activityTypeId
                : activityTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            scheduledDatetime: null == scheduledDatetime
                ? _value.scheduledDatetime
                : scheduledDatetime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
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
            hvcId: freezed == hvcId
                ? _value.hvcId
                : hvcId // ignore: cast_nullable_to_non_nullable
                      as String?,
            brokerId: freezed == brokerId
                ? _value.brokerId
                : brokerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            summary: freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            isImmediate: null == isImmediate
                ? _value.isImmediate
                : isImmediate // ignore: cast_nullable_to_non_nullable
                      as bool,
            executedAt: freezed == executedAt
                ? _value.executedAt
                : executedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            locationAccuracy: freezed == locationAccuracy
                ? _value.locationAccuracy
                : locationAccuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            distanceFromTarget: freezed == distanceFromTarget
                ? _value.distanceFromTarget
                : distanceFromTarget // ignore: cast_nullable_to_non_nullable
                      as double?,
            isLocationOverride: null == isLocationOverride
                ? _value.isLocationOverride
                : isLocationOverride // ignore: cast_nullable_to_non_nullable
                      as bool,
            overrideReason: freezed == overrideReason
                ? _value.overrideReason
                : overrideReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            rescheduledFromId: freezed == rescheduledFromId
                ? _value.rescheduledFromId
                : rescheduledFromId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rescheduledToId: freezed == rescheduledToId
                ? _value.rescheduledToId
                : rescheduledToId // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelReason: freezed == cancelReason
                ? _value.cancelReason
                : cancelReason // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$ActivitySyncDtoImplCopyWith<$Res>
    implements $ActivitySyncDtoCopyWith<$Res> {
  factory _$$ActivitySyncDtoImplCopyWith(
    _$ActivitySyncDtoImpl value,
    $Res Function(_$ActivitySyncDtoImpl) then,
  ) = __$$ActivitySyncDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'created_by') String createdBy,
    @JsonKey(name: 'object_type') String objectType,
    @JsonKey(name: 'activity_type_id') String activityTypeId,
    @JsonKey(name: 'scheduled_datetime') DateTime scheduledDatetime,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'hvc_id') String? hvcId,
    @JsonKey(name: 'broker_id') String? brokerId,
    String? summary,
    String? notes,
    @JsonKey(name: 'is_immediate') bool isImmediate,
    @JsonKey(name: 'executed_at') DateTime? executedAt,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'location_accuracy') double? locationAccuracy,
    @JsonKey(name: 'distance_from_target') double? distanceFromTarget,
    @JsonKey(name: 'is_location_override') bool isLocationOverride,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'rescheduled_from_id') String? rescheduledFromId,
    @JsonKey(name: 'rescheduled_to_id') String? rescheduledToId,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  });
}

/// @nodoc
class __$$ActivitySyncDtoImplCopyWithImpl<$Res>
    extends _$ActivitySyncDtoCopyWithImpl<$Res, _$ActivitySyncDtoImpl>
    implements _$$ActivitySyncDtoImplCopyWith<$Res> {
  __$$ActivitySyncDtoImplCopyWithImpl(
    _$ActivitySyncDtoImpl _value,
    $Res Function(_$ActivitySyncDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivitySyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? createdBy = null,
    Object? objectType = null,
    Object? activityTypeId = null,
    Object? scheduledDatetime = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? customerId = freezed,
    Object? hvcId = freezed,
    Object? brokerId = freezed,
    Object? summary = freezed,
    Object? notes = freezed,
    Object? isImmediate = null,
    Object? executedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationAccuracy = freezed,
    Object? distanceFromTarget = freezed,
    Object? isLocationOverride = null,
    Object? overrideReason = freezed,
    Object? rescheduledFromId = freezed,
    Object? rescheduledToId = freezed,
    Object? cancelledAt = freezed,
    Object? cancelReason = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$ActivitySyncDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        objectType: null == objectType
            ? _value.objectType
            : objectType // ignore: cast_nullable_to_non_nullable
                  as String,
        activityTypeId: null == activityTypeId
            ? _value.activityTypeId
            : activityTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        scheduledDatetime: null == scheduledDatetime
            ? _value.scheduledDatetime
            : scheduledDatetime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
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
        hvcId: freezed == hvcId
            ? _value.hvcId
            : hvcId // ignore: cast_nullable_to_non_nullable
                  as String?,
        brokerId: freezed == brokerId
            ? _value.brokerId
            : brokerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        summary: freezed == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        isImmediate: null == isImmediate
            ? _value.isImmediate
            : isImmediate // ignore: cast_nullable_to_non_nullable
                  as bool,
        executedAt: freezed == executedAt
            ? _value.executedAt
            : executedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        locationAccuracy: freezed == locationAccuracy
            ? _value.locationAccuracy
            : locationAccuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        distanceFromTarget: freezed == distanceFromTarget
            ? _value.distanceFromTarget
            : distanceFromTarget // ignore: cast_nullable_to_non_nullable
                  as double?,
        isLocationOverride: null == isLocationOverride
            ? _value.isLocationOverride
            : isLocationOverride // ignore: cast_nullable_to_non_nullable
                  as bool,
        overrideReason: freezed == overrideReason
            ? _value.overrideReason
            : overrideReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        rescheduledFromId: freezed == rescheduledFromId
            ? _value.rescheduledFromId
            : rescheduledFromId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rescheduledToId: freezed == rescheduledToId
            ? _value.rescheduledToId
            : rescheduledToId // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelReason: freezed == cancelReason
            ? _value.cancelReason
            : cancelReason // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$ActivitySyncDtoImpl implements _ActivitySyncDto {
  const _$ActivitySyncDtoImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'created_by') required this.createdBy,
    @JsonKey(name: 'object_type') required this.objectType,
    @JsonKey(name: 'activity_type_id') required this.activityTypeId,
    @JsonKey(name: 'scheduled_datetime') required this.scheduledDatetime,
    required this.status,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'customer_id') this.customerId,
    @JsonKey(name: 'hvc_id') this.hvcId,
    @JsonKey(name: 'broker_id') this.brokerId,
    this.summary,
    this.notes,
    @JsonKey(name: 'is_immediate') this.isImmediate = false,
    @JsonKey(name: 'executed_at') this.executedAt,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'location_accuracy') this.locationAccuracy,
    @JsonKey(name: 'distance_from_target') this.distanceFromTarget,
    @JsonKey(name: 'is_location_override') this.isLocationOverride = false,
    @JsonKey(name: 'override_reason') this.overrideReason,
    @JsonKey(name: 'rescheduled_from_id') this.rescheduledFromId,
    @JsonKey(name: 'rescheduled_to_id') this.rescheduledToId,
    @JsonKey(name: 'cancelled_at') this.cancelledAt,
    @JsonKey(name: 'cancel_reason') this.cancelReason,
    @JsonKey(name: 'deleted_at') this.deletedAt,
  });

  factory _$ActivitySyncDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivitySyncDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'object_type')
  final String objectType;
  @override
  @JsonKey(name: 'activity_type_id')
  final String activityTypeId;
  @override
  @JsonKey(name: 'scheduled_datetime')
  final DateTime scheduledDatetime;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'hvc_id')
  final String? hvcId;
  @override
  @JsonKey(name: 'broker_id')
  final String? brokerId;
  @override
  final String? summary;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'is_immediate')
  final bool isImmediate;
  @override
  @JsonKey(name: 'executed_at')
  final DateTime? executedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'location_accuracy')
  final double? locationAccuracy;
  @override
  @JsonKey(name: 'distance_from_target')
  final double? distanceFromTarget;
  @override
  @JsonKey(name: 'is_location_override')
  final bool isLocationOverride;
  @override
  @JsonKey(name: 'override_reason')
  final String? overrideReason;
  @override
  @JsonKey(name: 'rescheduled_from_id')
  final String? rescheduledFromId;
  @override
  @JsonKey(name: 'rescheduled_to_id')
  final String? rescheduledToId;
  @override
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @override
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;
  @override
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'ActivitySyncDto(id: $id, userId: $userId, createdBy: $createdBy, objectType: $objectType, activityTypeId: $activityTypeId, scheduledDatetime: $scheduledDatetime, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, customerId: $customerId, hvcId: $hvcId, brokerId: $brokerId, summary: $summary, notes: $notes, isImmediate: $isImmediate, executedAt: $executedAt, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, distanceFromTarget: $distanceFromTarget, isLocationOverride: $isLocationOverride, overrideReason: $overrideReason, rescheduledFromId: $rescheduledFromId, rescheduledToId: $rescheduledToId, cancelledAt: $cancelledAt, cancelReason: $cancelReason, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivitySyncDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.objectType, objectType) ||
                other.objectType == objectType) &&
            (identical(other.activityTypeId, activityTypeId) ||
                other.activityTypeId == activityTypeId) &&
            (identical(other.scheduledDatetime, scheduledDatetime) ||
                other.scheduledDatetime == scheduledDatetime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.hvcId, hvcId) || other.hvcId == hvcId) &&
            (identical(other.brokerId, brokerId) ||
                other.brokerId == brokerId) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isImmediate, isImmediate) ||
                other.isImmediate == isImmediate) &&
            (identical(other.executedAt, executedAt) ||
                other.executedAt == executedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationAccuracy, locationAccuracy) ||
                other.locationAccuracy == locationAccuracy) &&
            (identical(other.distanceFromTarget, distanceFromTarget) ||
                other.distanceFromTarget == distanceFromTarget) &&
            (identical(other.isLocationOverride, isLocationOverride) ||
                other.isLocationOverride == isLocationOverride) &&
            (identical(other.overrideReason, overrideReason) ||
                other.overrideReason == overrideReason) &&
            (identical(other.rescheduledFromId, rescheduledFromId) ||
                other.rescheduledFromId == rescheduledFromId) &&
            (identical(other.rescheduledToId, rescheduledToId) ||
                other.rescheduledToId == rescheduledToId) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    createdBy,
    objectType,
    activityTypeId,
    scheduledDatetime,
    status,
    createdAt,
    updatedAt,
    customerId,
    hvcId,
    brokerId,
    summary,
    notes,
    isImmediate,
    executedAt,
    latitude,
    longitude,
    locationAccuracy,
    distanceFromTarget,
    isLocationOverride,
    overrideReason,
    rescheduledFromId,
    rescheduledToId,
    cancelledAt,
    cancelReason,
    deletedAt,
  ]);

  /// Create a copy of ActivitySyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivitySyncDtoImplCopyWith<_$ActivitySyncDtoImpl> get copyWith =>
      __$$ActivitySyncDtoImplCopyWithImpl<_$ActivitySyncDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivitySyncDtoImplToJson(this);
  }
}

abstract class _ActivitySyncDto implements ActivitySyncDto {
  const factory _ActivitySyncDto({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'created_by') required final String createdBy,
    @JsonKey(name: 'object_type') required final String objectType,
    @JsonKey(name: 'activity_type_id') required final String activityTypeId,
    @JsonKey(name: 'scheduled_datetime')
    required final DateTime scheduledDatetime,
    required final String status,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    @JsonKey(name: 'customer_id') final String? customerId,
    @JsonKey(name: 'hvc_id') final String? hvcId,
    @JsonKey(name: 'broker_id') final String? brokerId,
    final String? summary,
    final String? notes,
    @JsonKey(name: 'is_immediate') final bool isImmediate,
    @JsonKey(name: 'executed_at') final DateTime? executedAt,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'location_accuracy') final double? locationAccuracy,
    @JsonKey(name: 'distance_from_target') final double? distanceFromTarget,
    @JsonKey(name: 'is_location_override') final bool isLocationOverride,
    @JsonKey(name: 'override_reason') final String? overrideReason,
    @JsonKey(name: 'rescheduled_from_id') final String? rescheduledFromId,
    @JsonKey(name: 'rescheduled_to_id') final String? rescheduledToId,
    @JsonKey(name: 'cancelled_at') final DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') final String? cancelReason,
    @JsonKey(name: 'deleted_at') final DateTime? deletedAt,
  }) = _$ActivitySyncDtoImpl;

  factory _ActivitySyncDto.fromJson(Map<String, dynamic> json) =
      _$ActivitySyncDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'object_type')
  String get objectType;
  @override
  @JsonKey(name: 'activity_type_id')
  String get activityTypeId;
  @override
  @JsonKey(name: 'scheduled_datetime')
  DateTime get scheduledDatetime;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @override
  @JsonKey(name: 'hvc_id')
  String? get hvcId;
  @override
  @JsonKey(name: 'broker_id')
  String? get brokerId;
  @override
  String? get summary;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'is_immediate')
  bool get isImmediate;
  @override
  @JsonKey(name: 'executed_at')
  DateTime? get executedAt;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'location_accuracy')
  double? get locationAccuracy;
  @override
  @JsonKey(name: 'distance_from_target')
  double? get distanceFromTarget;
  @override
  @JsonKey(name: 'is_location_override')
  bool get isLocationOverride;
  @override
  @JsonKey(name: 'override_reason')
  String? get overrideReason;
  @override
  @JsonKey(name: 'rescheduled_from_id')
  String? get rescheduledFromId;
  @override
  @JsonKey(name: 'rescheduled_to_id')
  String? get rescheduledToId;
  @override
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt;
  @override
  @JsonKey(name: 'cancel_reason')
  String? get cancelReason;
  @override
  @JsonKey(name: 'deleted_at')
  DateTime? get deletedAt;

  /// Create a copy of ActivitySyncDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivitySyncDtoImplCopyWith<_$ActivitySyncDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityPhotoSyncDto _$ActivityPhotoSyncDtoFromJson(Map<String, dynamic> json) {
  return _ActivityPhotoSyncDto.fromJson(json);
}

/// @nodoc
mixin _$ActivityPhotoSyncDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'activity_id')
  String get activityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'taken_at')
  DateTime? get takenAt => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this ActivityPhotoSyncDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityPhotoSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityPhotoSyncDtoCopyWith<ActivityPhotoSyncDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityPhotoSyncDtoCopyWith<$Res> {
  factory $ActivityPhotoSyncDtoCopyWith(
    ActivityPhotoSyncDto value,
    $Res Function(ActivityPhotoSyncDto) then,
  ) = _$ActivityPhotoSyncDtoCopyWithImpl<$Res, ActivityPhotoSyncDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'activity_id') String activityId,
    @JsonKey(name: 'photo_url') String photoUrl,
    @JsonKey(name: 'created_at') DateTime createdAt,
    String? caption,
    @JsonKey(name: 'taken_at') DateTime? takenAt,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class _$ActivityPhotoSyncDtoCopyWithImpl<
  $Res,
  $Val extends ActivityPhotoSyncDto
>
    implements $ActivityPhotoSyncDtoCopyWith<$Res> {
  _$ActivityPhotoSyncDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityPhotoSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? photoUrl = null,
    Object? createdAt = null,
    Object? caption = freezed,
    Object? takenAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            activityId: null == activityId
                ? _value.activityId
                : activityId // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
            takenAt: freezed == takenAt
                ? _value.takenAt
                : takenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityPhotoSyncDtoImplCopyWith<$Res>
    implements $ActivityPhotoSyncDtoCopyWith<$Res> {
  factory _$$ActivityPhotoSyncDtoImplCopyWith(
    _$ActivityPhotoSyncDtoImpl value,
    $Res Function(_$ActivityPhotoSyncDtoImpl) then,
  ) = __$$ActivityPhotoSyncDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'activity_id') String activityId,
    @JsonKey(name: 'photo_url') String photoUrl,
    @JsonKey(name: 'created_at') DateTime createdAt,
    String? caption,
    @JsonKey(name: 'taken_at') DateTime? takenAt,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class __$$ActivityPhotoSyncDtoImplCopyWithImpl<$Res>
    extends _$ActivityPhotoSyncDtoCopyWithImpl<$Res, _$ActivityPhotoSyncDtoImpl>
    implements _$$ActivityPhotoSyncDtoImplCopyWith<$Res> {
  __$$ActivityPhotoSyncDtoImplCopyWithImpl(
    _$ActivityPhotoSyncDtoImpl _value,
    $Res Function(_$ActivityPhotoSyncDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityPhotoSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? photoUrl = null,
    Object? createdAt = null,
    Object? caption = freezed,
    Object? takenAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$ActivityPhotoSyncDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        activityId: null == activityId
            ? _value.activityId
            : activityId // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: null == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
        takenAt: freezed == takenAt
            ? _value.takenAt
            : takenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityPhotoSyncDtoImpl implements _ActivityPhotoSyncDto {
  const _$ActivityPhotoSyncDtoImpl({
    required this.id,
    @JsonKey(name: 'activity_id') required this.activityId,
    @JsonKey(name: 'photo_url') required this.photoUrl,
    @JsonKey(name: 'created_at') required this.createdAt,
    this.caption,
    @JsonKey(name: 'taken_at') this.takenAt,
    this.latitude,
    this.longitude,
  });

  factory _$ActivityPhotoSyncDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityPhotoSyncDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'activity_id')
  final String activityId;
  @override
  @JsonKey(name: 'photo_url')
  final String photoUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final String? caption;
  @override
  @JsonKey(name: 'taken_at')
  final DateTime? takenAt;
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'ActivityPhotoSyncDto(id: $id, activityId: $activityId, photoUrl: $photoUrl, createdAt: $createdAt, caption: $caption, takenAt: $takenAt, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityPhotoSyncDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    activityId,
    photoUrl,
    createdAt,
    caption,
    takenAt,
    latitude,
    longitude,
  );

  /// Create a copy of ActivityPhotoSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityPhotoSyncDtoImplCopyWith<_$ActivityPhotoSyncDtoImpl>
  get copyWith =>
      __$$ActivityPhotoSyncDtoImplCopyWithImpl<_$ActivityPhotoSyncDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityPhotoSyncDtoImplToJson(this);
  }
}

abstract class _ActivityPhotoSyncDto implements ActivityPhotoSyncDto {
  const factory _ActivityPhotoSyncDto({
    required final String id,
    @JsonKey(name: 'activity_id') required final String activityId,
    @JsonKey(name: 'photo_url') required final String photoUrl,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    final String? caption,
    @JsonKey(name: 'taken_at') final DateTime? takenAt,
    final double? latitude,
    final double? longitude,
  }) = _$ActivityPhotoSyncDtoImpl;

  factory _ActivityPhotoSyncDto.fromJson(Map<String, dynamic> json) =
      _$ActivityPhotoSyncDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'activity_id')
  String get activityId;
  @override
  @JsonKey(name: 'photo_url')
  String get photoUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  String? get caption;
  @override
  @JsonKey(name: 'taken_at')
  DateTime? get takenAt;
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of ActivityPhotoSyncDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityPhotoSyncDtoImplCopyWith<_$ActivityPhotoSyncDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
