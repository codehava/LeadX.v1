// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) {
  return _AuditLog.fromJson(json);
}

/// @nodoc
mixin _$AuditLog {
  String get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get userEmail => throw _privateConstructorUsedError;
  String get action =>
      throw _privateConstructorUsedError; // INSERT, UPDATE, DELETE
  String get targetTable => throw _privateConstructorUsedError;
  String get targetId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get oldValues => throw _privateConstructorUsedError;
  Map<String, dynamic>? get newValues => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get userAgent => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Resolved display names
  String? get userName => throw _privateConstructorUsedError;

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogCopyWith<AuditLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogCopyWith<$Res> {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) then) =
      _$AuditLogCopyWithImpl<$Res, AuditLog>;
  @useResult
  $Res call({
    String id,
    String? userId,
    String? userEmail,
    String action,
    String targetTable,
    String targetId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? userAgent,
    DateTime createdAt,
    String? userName,
  });
}

/// @nodoc
class _$AuditLogCopyWithImpl<$Res, $Val extends AuditLog>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? userEmail = freezed,
    Object? action = null,
    Object? targetTable = null,
    Object? targetId = null,
    Object? oldValues = freezed,
    Object? newValues = freezed,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? createdAt = null,
    Object? userName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            userEmail: freezed == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            targetTable: null == targetTable
                ? _value.targetTable
                : targetTable // ignore: cast_nullable_to_non_nullable
                      as String,
            targetId: null == targetId
                ? _value.targetId
                : targetId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldValues: freezed == oldValues
                ? _value.oldValues
                : oldValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newValues: freezed == newValues
                ? _value.newValues
                : newValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            userAgent: freezed == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditLogImplCopyWith<$Res>
    implements $AuditLogCopyWith<$Res> {
  factory _$$AuditLogImplCopyWith(
    _$AuditLogImpl value,
    $Res Function(_$AuditLogImpl) then,
  ) = __$$AuditLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? userId,
    String? userEmail,
    String action,
    String targetTable,
    String targetId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    String? ipAddress,
    String? userAgent,
    DateTime createdAt,
    String? userName,
  });
}

/// @nodoc
class __$$AuditLogImplCopyWithImpl<$Res>
    extends _$AuditLogCopyWithImpl<$Res, _$AuditLogImpl>
    implements _$$AuditLogImplCopyWith<$Res> {
  __$$AuditLogImplCopyWithImpl(
    _$AuditLogImpl _value,
    $Res Function(_$AuditLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? userEmail = freezed,
    Object? action = null,
    Object? targetTable = null,
    Object? targetId = null,
    Object? oldValues = freezed,
    Object? newValues = freezed,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? createdAt = null,
    Object? userName = freezed,
  }) {
    return _then(
      _$AuditLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userEmail: freezed == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        targetTable: null == targetTable
            ? _value.targetTable
            : targetTable // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: null == targetId
            ? _value.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldValues: freezed == oldValues
            ? _value._oldValues
            : oldValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newValues: freezed == newValues
            ? _value._newValues
            : newValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        userAgent: freezed == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogImpl extends _AuditLog {
  const _$AuditLogImpl({
    required this.id,
    this.userId,
    this.userEmail,
    required this.action,
    required this.targetTable,
    required this.targetId,
    final Map<String, dynamic>? oldValues,
    final Map<String, dynamic>? newValues,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    this.userName,
  }) : _oldValues = oldValues,
       _newValues = newValues,
       super._();

  factory _$AuditLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogImplFromJson(json);

  @override
  final String id;
  @override
  final String? userId;
  @override
  final String? userEmail;
  @override
  final String action;
  // INSERT, UPDATE, DELETE
  @override
  final String targetTable;
  @override
  final String targetId;
  final Map<String, dynamic>? _oldValues;
  @override
  Map<String, dynamic>? get oldValues {
    final value = _oldValues;
    if (value == null) return null;
    if (_oldValues is EqualUnmodifiableMapView) return _oldValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValues;
  @override
  Map<String, dynamic>? get newValues {
    final value = _newValues;
    if (value == null) return null;
    if (_newValues is EqualUnmodifiableMapView) return _newValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? ipAddress;
  @override
  final String? userAgent;
  @override
  final DateTime createdAt;
  // Resolved display names
  @override
  final String? userName;

  @override
  String toString() {
    return 'AuditLog(id: $id, userId: $userId, userEmail: $userEmail, action: $action, targetTable: $targetTable, targetId: $targetId, oldValues: $oldValues, newValues: $newValues, ipAddress: $ipAddress, userAgent: $userAgent, createdAt: $createdAt, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.targetTable, targetTable) ||
                other.targetTable == targetTable) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            const DeepCollectionEquality().equals(
              other._oldValues,
              _oldValues,
            ) &&
            const DeepCollectionEquality().equals(
              other._newValues,
              _newValues,
            ) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userEmail,
    action,
    targetTable,
    targetId,
    const DeepCollectionEquality().hash(_oldValues),
    const DeepCollectionEquality().hash(_newValues),
    ipAddress,
    userAgent,
    createdAt,
    userName,
  );

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      __$$AuditLogImplCopyWithImpl<_$AuditLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogImplToJson(this);
  }
}

abstract class _AuditLog extends AuditLog {
  const factory _AuditLog({
    required final String id,
    final String? userId,
    final String? userEmail,
    required final String action,
    required final String targetTable,
    required final String targetId,
    final Map<String, dynamic>? oldValues,
    final Map<String, dynamic>? newValues,
    final String? ipAddress,
    final String? userAgent,
    required final DateTime createdAt,
    final String? userName,
  }) = _$AuditLogImpl;
  const _AuditLog._() : super._();

  factory _AuditLog.fromJson(Map<String, dynamic> json) =
      _$AuditLogImpl.fromJson;

  @override
  String get id;
  @override
  String? get userId;
  @override
  String? get userEmail;
  @override
  String get action; // INSERT, UPDATE, DELETE
  @override
  String get targetTable;
  @override
  String get targetId;
  @override
  Map<String, dynamic>? get oldValues;
  @override
  Map<String, dynamic>? get newValues;
  @override
  String? get ipAddress;
  @override
  String? get userAgent;
  @override
  DateTime get createdAt; // Resolved display names
  @override
  String? get userName;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PipelineStageHistory _$PipelineStageHistoryFromJson(Map<String, dynamic> json) {
  return _PipelineStageHistory.fromJson(json);
}

/// @nodoc
mixin _$PipelineStageHistory {
  String get id => throw _privateConstructorUsedError;
  String get pipelineId => throw _privateConstructorUsedError;
  String? get fromStageId => throw _privateConstructorUsedError;
  String get toStageId => throw _privateConstructorUsedError;
  String? get fromStatusId => throw _privateConstructorUsedError;
  String? get toStatusId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get changedBy => throw _privateConstructorUsedError;
  DateTime get changedAt => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Resolved names for display
  String? get fromStageName => throw _privateConstructorUsedError;
  String? get toStageName => throw _privateConstructorUsedError;
  String? get fromStatusName => throw _privateConstructorUsedError;
  String? get toStatusName => throw _privateConstructorUsedError;
  String? get changedByName => throw _privateConstructorUsedError;
  String? get fromStageColor => throw _privateConstructorUsedError;
  String? get toStageColor => throw _privateConstructorUsedError;

  /// Serializes this PipelineStageHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineStageHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineStageHistoryCopyWith<PipelineStageHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineStageHistoryCopyWith<$Res> {
  factory $PipelineStageHistoryCopyWith(
    PipelineStageHistory value,
    $Res Function(PipelineStageHistory) then,
  ) = _$PipelineStageHistoryCopyWithImpl<$Res, PipelineStageHistory>;
  @useResult
  $Res call({
    String id,
    String pipelineId,
    String? fromStageId,
    String toStageId,
    String? fromStatusId,
    String? toStatusId,
    String? notes,
    String? changedBy,
    DateTime changedAt,
    double? latitude,
    double? longitude,
    String? fromStageName,
    String? toStageName,
    String? fromStatusName,
    String? toStatusName,
    String? changedByName,
    String? fromStageColor,
    String? toStageColor,
  });
}

/// @nodoc
class _$PipelineStageHistoryCopyWithImpl<
  $Res,
  $Val extends PipelineStageHistory
>
    implements $PipelineStageHistoryCopyWith<$Res> {
  _$PipelineStageHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineStageHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pipelineId = null,
    Object? fromStageId = freezed,
    Object? toStageId = null,
    Object? fromStatusId = freezed,
    Object? toStatusId = freezed,
    Object? notes = freezed,
    Object? changedBy = freezed,
    Object? changedAt = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? fromStageName = freezed,
    Object? toStageName = freezed,
    Object? fromStatusName = freezed,
    Object? toStatusName = freezed,
    Object? changedByName = freezed,
    Object? fromStageColor = freezed,
    Object? toStageColor = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pipelineId: null == pipelineId
                ? _value.pipelineId
                : pipelineId // ignore: cast_nullable_to_non_nullable
                      as String,
            fromStageId: freezed == fromStageId
                ? _value.fromStageId
                : fromStageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            toStageId: null == toStageId
                ? _value.toStageId
                : toStageId // ignore: cast_nullable_to_non_nullable
                      as String,
            fromStatusId: freezed == fromStatusId
                ? _value.fromStatusId
                : fromStatusId // ignore: cast_nullable_to_non_nullable
                      as String?,
            toStatusId: freezed == toStatusId
                ? _value.toStatusId
                : toStatusId // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            changedBy: freezed == changedBy
                ? _value.changedBy
                : changedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            changedAt: null == changedAt
                ? _value.changedAt
                : changedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            fromStageName: freezed == fromStageName
                ? _value.fromStageName
                : fromStageName // ignore: cast_nullable_to_non_nullable
                      as String?,
            toStageName: freezed == toStageName
                ? _value.toStageName
                : toStageName // ignore: cast_nullable_to_non_nullable
                      as String?,
            fromStatusName: freezed == fromStatusName
                ? _value.fromStatusName
                : fromStatusName // ignore: cast_nullable_to_non_nullable
                      as String?,
            toStatusName: freezed == toStatusName
                ? _value.toStatusName
                : toStatusName // ignore: cast_nullable_to_non_nullable
                      as String?,
            changedByName: freezed == changedByName
                ? _value.changedByName
                : changedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            fromStageColor: freezed == fromStageColor
                ? _value.fromStageColor
                : fromStageColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            toStageColor: freezed == toStageColor
                ? _value.toStageColor
                : toStageColor // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineStageHistoryImplCopyWith<$Res>
    implements $PipelineStageHistoryCopyWith<$Res> {
  factory _$$PipelineStageHistoryImplCopyWith(
    _$PipelineStageHistoryImpl value,
    $Res Function(_$PipelineStageHistoryImpl) then,
  ) = __$$PipelineStageHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String pipelineId,
    String? fromStageId,
    String toStageId,
    String? fromStatusId,
    String? toStatusId,
    String? notes,
    String? changedBy,
    DateTime changedAt,
    double? latitude,
    double? longitude,
    String? fromStageName,
    String? toStageName,
    String? fromStatusName,
    String? toStatusName,
    String? changedByName,
    String? fromStageColor,
    String? toStageColor,
  });
}

/// @nodoc
class __$$PipelineStageHistoryImplCopyWithImpl<$Res>
    extends _$PipelineStageHistoryCopyWithImpl<$Res, _$PipelineStageHistoryImpl>
    implements _$$PipelineStageHistoryImplCopyWith<$Res> {
  __$$PipelineStageHistoryImplCopyWithImpl(
    _$PipelineStageHistoryImpl _value,
    $Res Function(_$PipelineStageHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineStageHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pipelineId = null,
    Object? fromStageId = freezed,
    Object? toStageId = null,
    Object? fromStatusId = freezed,
    Object? toStatusId = freezed,
    Object? notes = freezed,
    Object? changedBy = freezed,
    Object? changedAt = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? fromStageName = freezed,
    Object? toStageName = freezed,
    Object? fromStatusName = freezed,
    Object? toStatusName = freezed,
    Object? changedByName = freezed,
    Object? fromStageColor = freezed,
    Object? toStageColor = freezed,
  }) {
    return _then(
      _$PipelineStageHistoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pipelineId: null == pipelineId
            ? _value.pipelineId
            : pipelineId // ignore: cast_nullable_to_non_nullable
                  as String,
        fromStageId: freezed == fromStageId
            ? _value.fromStageId
            : fromStageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        toStageId: null == toStageId
            ? _value.toStageId
            : toStageId // ignore: cast_nullable_to_non_nullable
                  as String,
        fromStatusId: freezed == fromStatusId
            ? _value.fromStatusId
            : fromStatusId // ignore: cast_nullable_to_non_nullable
                  as String?,
        toStatusId: freezed == toStatusId
            ? _value.toStatusId
            : toStatusId // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        changedBy: freezed == changedBy
            ? _value.changedBy
            : changedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        changedAt: null == changedAt
            ? _value.changedAt
            : changedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        fromStageName: freezed == fromStageName
            ? _value.fromStageName
            : fromStageName // ignore: cast_nullable_to_non_nullable
                  as String?,
        toStageName: freezed == toStageName
            ? _value.toStageName
            : toStageName // ignore: cast_nullable_to_non_nullable
                  as String?,
        fromStatusName: freezed == fromStatusName
            ? _value.fromStatusName
            : fromStatusName // ignore: cast_nullable_to_non_nullable
                  as String?,
        toStatusName: freezed == toStatusName
            ? _value.toStatusName
            : toStatusName // ignore: cast_nullable_to_non_nullable
                  as String?,
        changedByName: freezed == changedByName
            ? _value.changedByName
            : changedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        fromStageColor: freezed == fromStageColor
            ? _value.fromStageColor
            : fromStageColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        toStageColor: freezed == toStageColor
            ? _value.toStageColor
            : toStageColor // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineStageHistoryImpl extends _PipelineStageHistory {
  const _$PipelineStageHistoryImpl({
    required this.id,
    required this.pipelineId,
    this.fromStageId,
    required this.toStageId,
    this.fromStatusId,
    this.toStatusId,
    this.notes,
    this.changedBy,
    required this.changedAt,
    this.latitude,
    this.longitude,
    this.fromStageName,
    this.toStageName,
    this.fromStatusName,
    this.toStatusName,
    this.changedByName,
    this.fromStageColor,
    this.toStageColor,
  }) : super._();

  factory _$PipelineStageHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineStageHistoryImplFromJson(json);

  @override
  final String id;
  @override
  final String pipelineId;
  @override
  final String? fromStageId;
  @override
  final String toStageId;
  @override
  final String? fromStatusId;
  @override
  final String? toStatusId;
  @override
  final String? notes;
  @override
  final String? changedBy;
  @override
  final DateTime changedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;
  // Resolved names for display
  @override
  final String? fromStageName;
  @override
  final String? toStageName;
  @override
  final String? fromStatusName;
  @override
  final String? toStatusName;
  @override
  final String? changedByName;
  @override
  final String? fromStageColor;
  @override
  final String? toStageColor;

  @override
  String toString() {
    return 'PipelineStageHistory(id: $id, pipelineId: $pipelineId, fromStageId: $fromStageId, toStageId: $toStageId, fromStatusId: $fromStatusId, toStatusId: $toStatusId, notes: $notes, changedBy: $changedBy, changedAt: $changedAt, latitude: $latitude, longitude: $longitude, fromStageName: $fromStageName, toStageName: $toStageName, fromStatusName: $fromStatusName, toStatusName: $toStatusName, changedByName: $changedByName, fromStageColor: $fromStageColor, toStageColor: $toStageColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineStageHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pipelineId, pipelineId) ||
                other.pipelineId == pipelineId) &&
            (identical(other.fromStageId, fromStageId) ||
                other.fromStageId == fromStageId) &&
            (identical(other.toStageId, toStageId) ||
                other.toStageId == toStageId) &&
            (identical(other.fromStatusId, fromStatusId) ||
                other.fromStatusId == fromStatusId) &&
            (identical(other.toStatusId, toStatusId) ||
                other.toStatusId == toStatusId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.changedBy, changedBy) ||
                other.changedBy == changedBy) &&
            (identical(other.changedAt, changedAt) ||
                other.changedAt == changedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.fromStageName, fromStageName) ||
                other.fromStageName == fromStageName) &&
            (identical(other.toStageName, toStageName) ||
                other.toStageName == toStageName) &&
            (identical(other.fromStatusName, fromStatusName) ||
                other.fromStatusName == fromStatusName) &&
            (identical(other.toStatusName, toStatusName) ||
                other.toStatusName == toStatusName) &&
            (identical(other.changedByName, changedByName) ||
                other.changedByName == changedByName) &&
            (identical(other.fromStageColor, fromStageColor) ||
                other.fromStageColor == fromStageColor) &&
            (identical(other.toStageColor, toStageColor) ||
                other.toStageColor == toStageColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pipelineId,
    fromStageId,
    toStageId,
    fromStatusId,
    toStatusId,
    notes,
    changedBy,
    changedAt,
    latitude,
    longitude,
    fromStageName,
    toStageName,
    fromStatusName,
    toStatusName,
    changedByName,
    fromStageColor,
    toStageColor,
  );

  /// Create a copy of PipelineStageHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineStageHistoryImplCopyWith<_$PipelineStageHistoryImpl>
  get copyWith =>
      __$$PipelineStageHistoryImplCopyWithImpl<_$PipelineStageHistoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineStageHistoryImplToJson(this);
  }
}

abstract class _PipelineStageHistory extends PipelineStageHistory {
  const factory _PipelineStageHistory({
    required final String id,
    required final String pipelineId,
    final String? fromStageId,
    required final String toStageId,
    final String? fromStatusId,
    final String? toStatusId,
    final String? notes,
    final String? changedBy,
    required final DateTime changedAt,
    final double? latitude,
    final double? longitude,
    final String? fromStageName,
    final String? toStageName,
    final String? fromStatusName,
    final String? toStatusName,
    final String? changedByName,
    final String? fromStageColor,
    final String? toStageColor,
  }) = _$PipelineStageHistoryImpl;
  const _PipelineStageHistory._() : super._();

  factory _PipelineStageHistory.fromJson(Map<String, dynamic> json) =
      _$PipelineStageHistoryImpl.fromJson;

  @override
  String get id;
  @override
  String get pipelineId;
  @override
  String? get fromStageId;
  @override
  String get toStageId;
  @override
  String? get fromStatusId;
  @override
  String? get toStatusId;
  @override
  String? get notes;
  @override
  String? get changedBy;
  @override
  DateTime get changedAt;
  @override
  double? get latitude;
  @override
  double? get longitude; // Resolved names for display
  @override
  String? get fromStageName;
  @override
  String? get toStageName;
  @override
  String? get fromStatusName;
  @override
  String? get toStatusName;
  @override
  String? get changedByName;
  @override
  String? get fromStageColor;
  @override
  String? get toStageColor;

  /// Create a copy of PipelineStageHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineStageHistoryImplCopyWith<_$PipelineStageHistoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
