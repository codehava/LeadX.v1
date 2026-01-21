// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SyncQueueItem _$SyncQueueItemFromJson(Map<String, dynamic> json) {
  return _SyncQueueItem.fromJson(json);
}

/// @nodoc
mixin _$SyncQueueItem {
  String get id => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  SyncOperation get operation => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  SyncStatus get status => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;

  /// Serializes this SyncQueueItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncQueueItemCopyWith<SyncQueueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncQueueItemCopyWith<$Res> {
  factory $SyncQueueItemCopyWith(
    SyncQueueItem value,
    $Res Function(SyncQueueItem) then,
  ) = _$SyncQueueItemCopyWithImpl<$Res, SyncQueueItem>;
  @useResult
  $Res call({
    String id,
    String entityType,
    String entityId,
    SyncOperation operation,
    Map<String, dynamic> payload,
    DateTime createdAt,
    SyncStatus status,
    int retryCount,
    String? errorMessage,
    DateTime? syncedAt,
  });
}

/// @nodoc
class _$SyncQueueItemCopyWithImpl<$Res, $Val extends SyncQueueItem>
    implements $SyncQueueItemCopyWith<$Res> {
  _$SyncQueueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? operation = null,
    Object? payload = null,
    Object? createdAt = null,
    Object? status = null,
    Object? retryCount = null,
    Object? errorMessage = freezed,
    Object? syncedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            entityType: null == entityType
                ? _value.entityType
                : entityType // ignore: cast_nullable_to_non_nullable
                      as String,
            entityId: null == entityId
                ? _value.entityId
                : entityId // ignore: cast_nullable_to_non_nullable
                      as String,
            operation: null == operation
                ? _value.operation
                : operation // ignore: cast_nullable_to_non_nullable
                      as SyncOperation,
            payload: null == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SyncStatus,
            retryCount: null == retryCount
                ? _value.retryCount
                : retryCount // ignore: cast_nullable_to_non_nullable
                      as int,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            syncedAt: freezed == syncedAt
                ? _value.syncedAt
                : syncedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncQueueItemImplCopyWith<$Res>
    implements $SyncQueueItemCopyWith<$Res> {
  factory _$$SyncQueueItemImplCopyWith(
    _$SyncQueueItemImpl value,
    $Res Function(_$SyncQueueItemImpl) then,
  ) = __$$SyncQueueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String entityType,
    String entityId,
    SyncOperation operation,
    Map<String, dynamic> payload,
    DateTime createdAt,
    SyncStatus status,
    int retryCount,
    String? errorMessage,
    DateTime? syncedAt,
  });
}

/// @nodoc
class __$$SyncQueueItemImplCopyWithImpl<$Res>
    extends _$SyncQueueItemCopyWithImpl<$Res, _$SyncQueueItemImpl>
    implements _$$SyncQueueItemImplCopyWith<$Res> {
  __$$SyncQueueItemImplCopyWithImpl(
    _$SyncQueueItemImpl _value,
    $Res Function(_$SyncQueueItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? operation = null,
    Object? payload = null,
    Object? createdAt = null,
    Object? status = null,
    Object? retryCount = null,
    Object? errorMessage = freezed,
    Object? syncedAt = freezed,
  }) {
    return _then(
      _$SyncQueueItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        entityType: null == entityType
            ? _value.entityType
            : entityType // ignore: cast_nullable_to_non_nullable
                  as String,
        entityId: null == entityId
            ? _value.entityId
            : entityId // ignore: cast_nullable_to_non_nullable
                  as String,
        operation: null == operation
            ? _value.operation
            : operation // ignore: cast_nullable_to_non_nullable
                  as SyncOperation,
        payload: null == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SyncStatus,
        retryCount: null == retryCount
            ? _value.retryCount
            : retryCount // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        syncedAt: freezed == syncedAt
            ? _value.syncedAt
            : syncedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncQueueItemImpl implements _SyncQueueItem {
  const _$SyncQueueItemImpl({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required final Map<String, dynamic> payload,
    required this.createdAt,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
    this.syncedAt,
  }) : _payload = payload;

  factory _$SyncQueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncQueueItemImplFromJson(json);

  @override
  final String id;
  @override
  final String entityType;
  @override
  final String entityId;
  @override
  final SyncOperation operation;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final SyncStatus status;
  @override
  @JsonKey()
  final int retryCount;
  @override
  final String? errorMessage;
  @override
  final DateTime? syncedAt;

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, entityType: $entityType, entityId: $entityId, operation: $operation, payload: $payload, createdAt: $createdAt, status: $status, retryCount: $retryCount, errorMessage: $errorMessage, syncedAt: $syncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncQueueItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.operation, operation) ||
                other.operation == operation) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    entityType,
    entityId,
    operation,
    const DeepCollectionEquality().hash(_payload),
    createdAt,
    status,
    retryCount,
    errorMessage,
    syncedAt,
  );

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncQueueItemImplCopyWith<_$SyncQueueItemImpl> get copyWith =>
      __$$SyncQueueItemImplCopyWithImpl<_$SyncQueueItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncQueueItemImplToJson(this);
  }
}

abstract class _SyncQueueItem implements SyncQueueItem {
  const factory _SyncQueueItem({
    required final String id,
    required final String entityType,
    required final String entityId,
    required final SyncOperation operation,
    required final Map<String, dynamic> payload,
    required final DateTime createdAt,
    final SyncStatus status,
    final int retryCount,
    final String? errorMessage,
    final DateTime? syncedAt,
  }) = _$SyncQueueItemImpl;

  factory _SyncQueueItem.fromJson(Map<String, dynamic> json) =
      _$SyncQueueItemImpl.fromJson;

  @override
  String get id;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  SyncOperation get operation;
  @override
  Map<String, dynamic> get payload;
  @override
  DateTime get createdAt;
  @override
  SyncStatus get status;
  @override
  int get retryCount;
  @override
  String? get errorMessage;
  @override
  DateTime? get syncedAt;

  /// Create a copy of SyncQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncQueueItemImplCopyWith<_$SyncQueueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncResult _$SyncResultFromJson(Map<String, dynamic> json) {
  return _SyncResult.fromJson(json);
}

/// @nodoc
mixin _$SyncResult {
  bool get success => throw _privateConstructorUsedError;
  int get processedCount => throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failedCount => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  DateTime get syncedAt => throw _privateConstructorUsedError;

  /// Serializes this SyncResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncResultCopyWith<SyncResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncResultCopyWith<$Res> {
  factory $SyncResultCopyWith(
    SyncResult value,
    $Res Function(SyncResult) then,
  ) = _$SyncResultCopyWithImpl<$Res, SyncResult>;
  @useResult
  $Res call({
    bool success,
    int processedCount,
    int successCount,
    int failedCount,
    List<String> errors,
    DateTime syncedAt,
  });
}

/// @nodoc
class _$SyncResultCopyWithImpl<$Res, $Val extends SyncResult>
    implements $SyncResultCopyWith<$Res> {
  _$SyncResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? processedCount = null,
    Object? successCount = null,
    Object? failedCount = null,
    Object? errors = null,
    Object? syncedAt = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            processedCount: null == processedCount
                ? _value.processedCount
                : processedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            successCount: null == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failedCount: null == failedCount
                ? _value.failedCount
                : failedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            syncedAt: null == syncedAt
                ? _value.syncedAt
                : syncedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncResultImplCopyWith<$Res>
    implements $SyncResultCopyWith<$Res> {
  factory _$$SyncResultImplCopyWith(
    _$SyncResultImpl value,
    $Res Function(_$SyncResultImpl) then,
  ) = __$$SyncResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    int processedCount,
    int successCount,
    int failedCount,
    List<String> errors,
    DateTime syncedAt,
  });
}

/// @nodoc
class __$$SyncResultImplCopyWithImpl<$Res>
    extends _$SyncResultCopyWithImpl<$Res, _$SyncResultImpl>
    implements _$$SyncResultImplCopyWith<$Res> {
  __$$SyncResultImplCopyWithImpl(
    _$SyncResultImpl _value,
    $Res Function(_$SyncResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? processedCount = null,
    Object? successCount = null,
    Object? failedCount = null,
    Object? errors = null,
    Object? syncedAt = null,
  }) {
    return _then(
      _$SyncResultImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        processedCount: null == processedCount
            ? _value.processedCount
            : processedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        successCount: null == successCount
            ? _value.successCount
            : successCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failedCount: null == failedCount
            ? _value.failedCount
            : failedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        syncedAt: null == syncedAt
            ? _value.syncedAt
            : syncedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncResultImpl implements _SyncResult {
  const _$SyncResultImpl({
    required this.success,
    required this.processedCount,
    required this.successCount,
    required this.failedCount,
    required final List<String> errors,
    required this.syncedAt,
  }) : _errors = errors;

  factory _$SyncResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncResultImplFromJson(json);

  @override
  final bool success;
  @override
  final int processedCount;
  @override
  final int successCount;
  @override
  final int failedCount;
  final List<String> _errors;
  @override
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  final DateTime syncedAt;

  @override
  String toString() {
    return 'SyncResult(success: $success, processedCount: $processedCount, successCount: $successCount, failedCount: $failedCount, errors: $errors, syncedAt: $syncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.processedCount, processedCount) ||
                other.processedCount == processedCount) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    processedCount,
    successCount,
    failedCount,
    const DeepCollectionEquality().hash(_errors),
    syncedAt,
  );

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncResultImplCopyWith<_$SyncResultImpl> get copyWith =>
      __$$SyncResultImplCopyWithImpl<_$SyncResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncResultImplToJson(this);
  }
}

abstract class _SyncResult implements SyncResult {
  const factory _SyncResult({
    required final bool success,
    required final int processedCount,
    required final int successCount,
    required final int failedCount,
    required final List<String> errors,
    required final DateTime syncedAt,
  }) = _$SyncResultImpl;

  factory _SyncResult.fromJson(Map<String, dynamic> json) =
      _$SyncResultImpl.fromJson;

  @override
  bool get success;
  @override
  int get processedCount;
  @override
  int get successCount;
  @override
  int get failedCount;
  @override
  List<String> get errors;
  @override
  DateTime get syncedAt;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncResultImplCopyWith<_$SyncResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SyncState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(int total, int current, String? currentEntity)
    syncing,
    required TResult Function(SyncResult result) success,
    required TResult Function(String message, Object? error) error,
    required TResult Function() offline,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(int total, int current, String? currentEntity)? syncing,
    TResult? Function(SyncResult result)? success,
    TResult? Function(String message, Object? error)? error,
    TResult? Function()? offline,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(int total, int current, String? currentEntity)? syncing,
    TResult Function(SyncResult result)? success,
    TResult Function(String message, Object? error)? error,
    TResult Function()? offline,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStateIdle value) idle,
    required TResult Function(SyncStateSyncing value) syncing,
    required TResult Function(SyncStateSuccess value) success,
    required TResult Function(SyncStateError value) error,
    required TResult Function(SyncStateOffline value) offline,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStateIdle value)? idle,
    TResult? Function(SyncStateSyncing value)? syncing,
    TResult? Function(SyncStateSuccess value)? success,
    TResult? Function(SyncStateError value)? error,
    TResult? Function(SyncStateOffline value)? offline,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStateIdle value)? idle,
    TResult Function(SyncStateSyncing value)? syncing,
    TResult Function(SyncStateSuccess value)? success,
    TResult Function(SyncStateError value)? error,
    TResult Function(SyncStateOffline value)? offline,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStateCopyWith<$Res> {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) then) =
      _$SyncStateCopyWithImpl<$Res, SyncState>;
}

/// @nodoc
class _$SyncStateCopyWithImpl<$Res, $Val extends SyncState>
    implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SyncStateIdleImplCopyWith<$Res> {
  factory _$$SyncStateIdleImplCopyWith(
    _$SyncStateIdleImpl value,
    $Res Function(_$SyncStateIdleImpl) then,
  ) = __$$SyncStateIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncStateIdleImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateIdleImpl>
    implements _$$SyncStateIdleImplCopyWith<$Res> {
  __$$SyncStateIdleImplCopyWithImpl(
    _$SyncStateIdleImpl _value,
    $Res Function(_$SyncStateIdleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SyncStateIdleImpl implements SyncStateIdle {
  const _$SyncStateIdleImpl();

  @override
  String toString() {
    return 'SyncState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncStateIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(int total, int current, String? currentEntity)
    syncing,
    required TResult Function(SyncResult result) success,
    required TResult Function(String message, Object? error) error,
    required TResult Function() offline,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(int total, int current, String? currentEntity)? syncing,
    TResult? Function(SyncResult result)? success,
    TResult? Function(String message, Object? error)? error,
    TResult? Function()? offline,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(int total, int current, String? currentEntity)? syncing,
    TResult Function(SyncResult result)? success,
    TResult Function(String message, Object? error)? error,
    TResult Function()? offline,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStateIdle value) idle,
    required TResult Function(SyncStateSyncing value) syncing,
    required TResult Function(SyncStateSuccess value) success,
    required TResult Function(SyncStateError value) error,
    required TResult Function(SyncStateOffline value) offline,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStateIdle value)? idle,
    TResult? Function(SyncStateSyncing value)? syncing,
    TResult? Function(SyncStateSuccess value)? success,
    TResult? Function(SyncStateError value)? error,
    TResult? Function(SyncStateOffline value)? offline,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStateIdle value)? idle,
    TResult Function(SyncStateSyncing value)? syncing,
    TResult Function(SyncStateSuccess value)? success,
    TResult Function(SyncStateError value)? error,
    TResult Function(SyncStateOffline value)? offline,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class SyncStateIdle implements SyncState {
  const factory SyncStateIdle() = _$SyncStateIdleImpl;
}

/// @nodoc
abstract class _$$SyncStateSyncingImplCopyWith<$Res> {
  factory _$$SyncStateSyncingImplCopyWith(
    _$SyncStateSyncingImpl value,
    $Res Function(_$SyncStateSyncingImpl) then,
  ) = __$$SyncStateSyncingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int total, int current, String? currentEntity});
}

/// @nodoc
class __$$SyncStateSyncingImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateSyncingImpl>
    implements _$$SyncStateSyncingImplCopyWith<$Res> {
  __$$SyncStateSyncingImplCopyWithImpl(
    _$SyncStateSyncingImpl _value,
    $Res Function(_$SyncStateSyncingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? current = null,
    Object? currentEntity = freezed,
  }) {
    return _then(
      _$SyncStateSyncingImpl(
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        current: null == current
            ? _value.current
            : current // ignore: cast_nullable_to_non_nullable
                  as int,
        currentEntity: freezed == currentEntity
            ? _value.currentEntity
            : currentEntity // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SyncStateSyncingImpl implements SyncStateSyncing {
  const _$SyncStateSyncingImpl({
    required this.total,
    required this.current,
    this.currentEntity,
  });

  @override
  final int total;
  @override
  final int current;
  @override
  final String? currentEntity;

  @override
  String toString() {
    return 'SyncState.syncing(total: $total, current: $current, currentEntity: $currentEntity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStateSyncingImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.currentEntity, currentEntity) ||
                other.currentEntity == currentEntity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, total, current, currentEntity);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStateSyncingImplCopyWith<_$SyncStateSyncingImpl> get copyWith =>
      __$$SyncStateSyncingImplCopyWithImpl<_$SyncStateSyncingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(int total, int current, String? currentEntity)
    syncing,
    required TResult Function(SyncResult result) success,
    required TResult Function(String message, Object? error) error,
    required TResult Function() offline,
  }) {
    return syncing(total, current, currentEntity);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(int total, int current, String? currentEntity)? syncing,
    TResult? Function(SyncResult result)? success,
    TResult? Function(String message, Object? error)? error,
    TResult? Function()? offline,
  }) {
    return syncing?.call(total, current, currentEntity);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(int total, int current, String? currentEntity)? syncing,
    TResult Function(SyncResult result)? success,
    TResult Function(String message, Object? error)? error,
    TResult Function()? offline,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing(total, current, currentEntity);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStateIdle value) idle,
    required TResult Function(SyncStateSyncing value) syncing,
    required TResult Function(SyncStateSuccess value) success,
    required TResult Function(SyncStateError value) error,
    required TResult Function(SyncStateOffline value) offline,
  }) {
    return syncing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStateIdle value)? idle,
    TResult? Function(SyncStateSyncing value)? syncing,
    TResult? Function(SyncStateSuccess value)? success,
    TResult? Function(SyncStateError value)? error,
    TResult? Function(SyncStateOffline value)? offline,
  }) {
    return syncing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStateIdle value)? idle,
    TResult Function(SyncStateSyncing value)? syncing,
    TResult Function(SyncStateSuccess value)? success,
    TResult Function(SyncStateError value)? error,
    TResult Function(SyncStateOffline value)? offline,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing(this);
    }
    return orElse();
  }
}

abstract class SyncStateSyncing implements SyncState {
  const factory SyncStateSyncing({
    required final int total,
    required final int current,
    final String? currentEntity,
  }) = _$SyncStateSyncingImpl;

  int get total;
  int get current;
  String? get currentEntity;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncStateSyncingImplCopyWith<_$SyncStateSyncingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncStateSuccessImplCopyWith<$Res> {
  factory _$$SyncStateSuccessImplCopyWith(
    _$SyncStateSuccessImpl value,
    $Res Function(_$SyncStateSuccessImpl) then,
  ) = __$$SyncStateSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SyncResult result});

  $SyncResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$SyncStateSuccessImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateSuccessImpl>
    implements _$$SyncStateSuccessImplCopyWith<$Res> {
  __$$SyncStateSuccessImplCopyWithImpl(
    _$SyncStateSuccessImpl _value,
    $Res Function(_$SyncStateSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? result = null}) {
    return _then(
      _$SyncStateSuccessImpl(
        result: null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as SyncResult,
      ),
    );
  }

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SyncResultCopyWith<$Res> get result {
    return $SyncResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$SyncStateSuccessImpl implements SyncStateSuccess {
  const _$SyncStateSuccessImpl({required this.result});

  @override
  final SyncResult result;

  @override
  String toString() {
    return 'SyncState.success(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStateSuccessImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStateSuccessImplCopyWith<_$SyncStateSuccessImpl> get copyWith =>
      __$$SyncStateSuccessImplCopyWithImpl<_$SyncStateSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(int total, int current, String? currentEntity)
    syncing,
    required TResult Function(SyncResult result) success,
    required TResult Function(String message, Object? error) error,
    required TResult Function() offline,
  }) {
    return success(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(int total, int current, String? currentEntity)? syncing,
    TResult? Function(SyncResult result)? success,
    TResult? Function(String message, Object? error)? error,
    TResult? Function()? offline,
  }) {
    return success?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(int total, int current, String? currentEntity)? syncing,
    TResult Function(SyncResult result)? success,
    TResult Function(String message, Object? error)? error,
    TResult Function()? offline,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStateIdle value) idle,
    required TResult Function(SyncStateSyncing value) syncing,
    required TResult Function(SyncStateSuccess value) success,
    required TResult Function(SyncStateError value) error,
    required TResult Function(SyncStateOffline value) offline,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStateIdle value)? idle,
    TResult? Function(SyncStateSyncing value)? syncing,
    TResult? Function(SyncStateSuccess value)? success,
    TResult? Function(SyncStateError value)? error,
    TResult? Function(SyncStateOffline value)? offline,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStateIdle value)? idle,
    TResult Function(SyncStateSyncing value)? syncing,
    TResult Function(SyncStateSuccess value)? success,
    TResult Function(SyncStateError value)? error,
    TResult Function(SyncStateOffline value)? offline,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class SyncStateSuccess implements SyncState {
  const factory SyncStateSuccess({required final SyncResult result}) =
      _$SyncStateSuccessImpl;

  SyncResult get result;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncStateSuccessImplCopyWith<_$SyncStateSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncStateErrorImplCopyWith<$Res> {
  factory _$$SyncStateErrorImplCopyWith(
    _$SyncStateErrorImpl value,
    $Res Function(_$SyncStateErrorImpl) then,
  ) = __$$SyncStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, Object? error});
}

/// @nodoc
class __$$SyncStateErrorImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateErrorImpl>
    implements _$$SyncStateErrorImplCopyWith<$Res> {
  __$$SyncStateErrorImplCopyWithImpl(
    _$SyncStateErrorImpl _value,
    $Res Function(_$SyncStateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? error = freezed}) {
    return _then(
      _$SyncStateErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        error: freezed == error ? _value.error : error,
      ),
    );
  }
}

/// @nodoc

class _$SyncStateErrorImpl implements SyncStateError {
  const _$SyncStateErrorImpl({required this.message, this.error});

  @override
  final String message;
  @override
  final Object? error;

  @override
  String toString() {
    return 'SyncState.error(message: $message, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStateErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(error),
  );

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStateErrorImplCopyWith<_$SyncStateErrorImpl> get copyWith =>
      __$$SyncStateErrorImplCopyWithImpl<_$SyncStateErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(int total, int current, String? currentEntity)
    syncing,
    required TResult Function(SyncResult result) success,
    required TResult Function(String message, Object? error) error,
    required TResult Function() offline,
  }) {
    return error(message, this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(int total, int current, String? currentEntity)? syncing,
    TResult? Function(SyncResult result)? success,
    TResult? Function(String message, Object? error)? error,
    TResult? Function()? offline,
  }) {
    return error?.call(message, this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(int total, int current, String? currentEntity)? syncing,
    TResult Function(SyncResult result)? success,
    TResult Function(String message, Object? error)? error,
    TResult Function()? offline,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStateIdle value) idle,
    required TResult Function(SyncStateSyncing value) syncing,
    required TResult Function(SyncStateSuccess value) success,
    required TResult Function(SyncStateError value) error,
    required TResult Function(SyncStateOffline value) offline,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStateIdle value)? idle,
    TResult? Function(SyncStateSyncing value)? syncing,
    TResult? Function(SyncStateSuccess value)? success,
    TResult? Function(SyncStateError value)? error,
    TResult? Function(SyncStateOffline value)? offline,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStateIdle value)? idle,
    TResult Function(SyncStateSyncing value)? syncing,
    TResult Function(SyncStateSuccess value)? success,
    TResult Function(SyncStateError value)? error,
    TResult Function(SyncStateOffline value)? offline,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class SyncStateError implements SyncState {
  const factory SyncStateError({
    required final String message,
    final Object? error,
  }) = _$SyncStateErrorImpl;

  String get message;
  Object? get error;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncStateErrorImplCopyWith<_$SyncStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncStateOfflineImplCopyWith<$Res> {
  factory _$$SyncStateOfflineImplCopyWith(
    _$SyncStateOfflineImpl value,
    $Res Function(_$SyncStateOfflineImpl) then,
  ) = __$$SyncStateOfflineImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SyncStateOfflineImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateOfflineImpl>
    implements _$$SyncStateOfflineImplCopyWith<$Res> {
  __$$SyncStateOfflineImplCopyWithImpl(
    _$SyncStateOfflineImpl _value,
    $Res Function(_$SyncStateOfflineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SyncStateOfflineImpl implements SyncStateOffline {
  const _$SyncStateOfflineImpl();

  @override
  String toString() {
    return 'SyncState.offline()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SyncStateOfflineImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(int total, int current, String? currentEntity)
    syncing,
    required TResult Function(SyncResult result) success,
    required TResult Function(String message, Object? error) error,
    required TResult Function() offline,
  }) {
    return offline();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(int total, int current, String? currentEntity)? syncing,
    TResult? Function(SyncResult result)? success,
    TResult? Function(String message, Object? error)? error,
    TResult? Function()? offline,
  }) {
    return offline?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(int total, int current, String? currentEntity)? syncing,
    TResult Function(SyncResult result)? success,
    TResult Function(String message, Object? error)? error,
    TResult Function()? offline,
    required TResult orElse(),
  }) {
    if (offline != null) {
      return offline();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SyncStateIdle value) idle,
    required TResult Function(SyncStateSyncing value) syncing,
    required TResult Function(SyncStateSuccess value) success,
    required TResult Function(SyncStateError value) error,
    required TResult Function(SyncStateOffline value) offline,
  }) {
    return offline(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SyncStateIdle value)? idle,
    TResult? Function(SyncStateSyncing value)? syncing,
    TResult? Function(SyncStateSuccess value)? success,
    TResult? Function(SyncStateError value)? error,
    TResult? Function(SyncStateOffline value)? offline,
  }) {
    return offline?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SyncStateIdle value)? idle,
    TResult Function(SyncStateSyncing value)? syncing,
    TResult Function(SyncStateSuccess value)? success,
    TResult Function(SyncStateError value)? error,
    TResult Function(SyncStateOffline value)? offline,
    required TResult orElse(),
  }) {
    if (offline != null) {
      return offline(this);
    }
    return orElse();
  }
}

abstract class SyncStateOffline implements SyncState {
  const factory SyncStateOffline() = _$SyncStateOfflineImpl;
}
