// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pipeline_referral.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PipelineReferral _$PipelineReferralFromJson(Map<String, dynamic> json) {
  return _PipelineReferral.fromJson(json);
}

/// @nodoc
mixin _$PipelineReferral {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError; // Customer Info
  String get customerId =>
      throw _privateConstructorUsedError; // Parties Involved
  String get referrerRmId => throw _privateConstructorUsedError;
  String get receiverRmId =>
      throw _privateConstructorUsedError; // Branch IDs (nullable for kanwil-level RMs)
  String? get referrerBranchId => throw _privateConstructorUsedError;
  String? get receiverBranchId =>
      throw _privateConstructorUsedError; // Regional Office IDs
  String? get referrerRegionalOfficeId => throw _privateConstructorUsedError;
  String? get receiverRegionalOfficeId =>
      throw _privateConstructorUsedError; // Approver type
  ApproverType get approverType =>
      throw _privateConstructorUsedError; // Referral Details
  String get reason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError; // Status
  ReferralStatus get status =>
      throw _privateConstructorUsedError; // Receiver Response
  DateTime? get receiverAcceptedAt => throw _privateConstructorUsedError;
  DateTime? get receiverRejectedAt => throw _privateConstructorUsedError;
  String? get receiverRejectReason => throw _privateConstructorUsedError;
  String? get receiverNotes =>
      throw _privateConstructorUsedError; // Manager Approval
  DateTime? get bmApprovedAt => throw _privateConstructorUsedError;
  String? get bmApprovedBy => throw _privateConstructorUsedError;
  DateTime? get bmRejectedAt => throw _privateConstructorUsedError;
  String? get bmRejectReason => throw _privateConstructorUsedError;
  String? get bmNotes => throw _privateConstructorUsedError; // Result
  bool get bonusCalculated => throw _privateConstructorUsedError;
  double? get bonusAmount => throw _privateConstructorUsedError; // Timestamps
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt =>
      throw _privateConstructorUsedError; // Lookup fields (populated from joined data)
  String? get customerName => throw _privateConstructorUsedError;
  String? get referrerRmName => throw _privateConstructorUsedError;
  String? get receiverRmName => throw _privateConstructorUsedError;
  String? get referrerBranchName => throw _privateConstructorUsedError;
  String? get receiverBranchName => throw _privateConstructorUsedError;
  String? get approverName => throw _privateConstructorUsedError;

  /// Serializes this PipelineReferral to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PipelineReferral
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PipelineReferralCopyWith<PipelineReferral> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PipelineReferralCopyWith<$Res> {
  factory $PipelineReferralCopyWith(
    PipelineReferral value,
    $Res Function(PipelineReferral) then,
  ) = _$PipelineReferralCopyWithImpl<$Res, PipelineReferral>;
  @useResult
  $Res call({
    String id,
    String code,
    String customerId,
    String referrerRmId,
    String receiverRmId,
    String? referrerBranchId,
    String? receiverBranchId,
    String? referrerRegionalOfficeId,
    String? receiverRegionalOfficeId,
    ApproverType approverType,
    String reason,
    String? notes,
    ReferralStatus status,
    DateTime? receiverAcceptedAt,
    DateTime? receiverRejectedAt,
    String? receiverRejectReason,
    String? receiverNotes,
    DateTime? bmApprovedAt,
    String? bmApprovedBy,
    DateTime? bmRejectedAt,
    String? bmRejectReason,
    String? bmNotes,
    bool bonusCalculated,
    double? bonusAmount,
    DateTime? expiresAt,
    DateTime? cancelledAt,
    String? cancelReason,
    bool isPendingSync,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastSyncAt,
    String? customerName,
    String? referrerRmName,
    String? receiverRmName,
    String? referrerBranchName,
    String? receiverBranchName,
    String? approverName,
  });
}

/// @nodoc
class _$PipelineReferralCopyWithImpl<$Res, $Val extends PipelineReferral>
    implements $PipelineReferralCopyWith<$Res> {
  _$PipelineReferralCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PipelineReferral
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
    Object? isPendingSync = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastSyncAt = freezed,
    Object? customerName = freezed,
    Object? referrerRmName = freezed,
    Object? receiverRmName = freezed,
    Object? referrerBranchName = freezed,
    Object? receiverBranchName = freezed,
    Object? approverName = freezed,
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
                      as ApproverType,
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
                      as ReferralStatus,
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
            lastSyncAt: freezed == lastSyncAt
                ? _value.lastSyncAt
                : lastSyncAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            referrerRmName: freezed == referrerRmName
                ? _value.referrerRmName
                : referrerRmName // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiverRmName: freezed == receiverRmName
                ? _value.receiverRmName
                : receiverRmName // ignore: cast_nullable_to_non_nullable
                      as String?,
            referrerBranchName: freezed == referrerBranchName
                ? _value.referrerBranchName
                : referrerBranchName // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiverBranchName: freezed == receiverBranchName
                ? _value.receiverBranchName
                : receiverBranchName // ignore: cast_nullable_to_non_nullable
                      as String?,
            approverName: freezed == approverName
                ? _value.approverName
                : approverName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PipelineReferralImplCopyWith<$Res>
    implements $PipelineReferralCopyWith<$Res> {
  factory _$$PipelineReferralImplCopyWith(
    _$PipelineReferralImpl value,
    $Res Function(_$PipelineReferralImpl) then,
  ) = __$$PipelineReferralImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String customerId,
    String referrerRmId,
    String receiverRmId,
    String? referrerBranchId,
    String? receiverBranchId,
    String? referrerRegionalOfficeId,
    String? receiverRegionalOfficeId,
    ApproverType approverType,
    String reason,
    String? notes,
    ReferralStatus status,
    DateTime? receiverAcceptedAt,
    DateTime? receiverRejectedAt,
    String? receiverRejectReason,
    String? receiverNotes,
    DateTime? bmApprovedAt,
    String? bmApprovedBy,
    DateTime? bmRejectedAt,
    String? bmRejectReason,
    String? bmNotes,
    bool bonusCalculated,
    double? bonusAmount,
    DateTime? expiresAt,
    DateTime? cancelledAt,
    String? cancelReason,
    bool isPendingSync,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? lastSyncAt,
    String? customerName,
    String? referrerRmName,
    String? receiverRmName,
    String? referrerBranchName,
    String? receiverBranchName,
    String? approverName,
  });
}

/// @nodoc
class __$$PipelineReferralImplCopyWithImpl<$Res>
    extends _$PipelineReferralCopyWithImpl<$Res, _$PipelineReferralImpl>
    implements _$$PipelineReferralImplCopyWith<$Res> {
  __$$PipelineReferralImplCopyWithImpl(
    _$PipelineReferralImpl _value,
    $Res Function(_$PipelineReferralImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PipelineReferral
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
    Object? isPendingSync = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastSyncAt = freezed,
    Object? customerName = freezed,
    Object? referrerRmName = freezed,
    Object? receiverRmName = freezed,
    Object? referrerBranchName = freezed,
    Object? receiverBranchName = freezed,
    Object? approverName = freezed,
  }) {
    return _then(
      _$PipelineReferralImpl(
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
                  as ApproverType,
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
                  as ReferralStatus,
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
        lastSyncAt: freezed == lastSyncAt
            ? _value.lastSyncAt
            : lastSyncAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        referrerRmName: freezed == referrerRmName
            ? _value.referrerRmName
            : referrerRmName // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiverRmName: freezed == receiverRmName
            ? _value.receiverRmName
            : receiverRmName // ignore: cast_nullable_to_non_nullable
                  as String?,
        referrerBranchName: freezed == referrerBranchName
            ? _value.referrerBranchName
            : referrerBranchName // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiverBranchName: freezed == receiverBranchName
            ? _value.receiverBranchName
            : receiverBranchName // ignore: cast_nullable_to_non_nullable
                  as String?,
        approverName: freezed == approverName
            ? _value.approverName
            : approverName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PipelineReferralImpl extends _PipelineReferral {
  const _$PipelineReferralImpl({
    required this.id,
    required this.code,
    required this.customerId,
    required this.referrerRmId,
    required this.receiverRmId,
    this.referrerBranchId,
    this.receiverBranchId,
    this.referrerRegionalOfficeId,
    this.receiverRegionalOfficeId,
    this.approverType = ApproverType.bm,
    required this.reason,
    this.notes,
    this.status = ReferralStatus.pendingReceiver,
    this.receiverAcceptedAt,
    this.receiverRejectedAt,
    this.receiverRejectReason,
    this.receiverNotes,
    this.bmApprovedAt,
    this.bmApprovedBy,
    this.bmRejectedAt,
    this.bmRejectReason,
    this.bmNotes,
    this.bonusCalculated = false,
    this.bonusAmount,
    this.expiresAt,
    this.cancelledAt,
    this.cancelReason,
    this.isPendingSync = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
    this.customerName,
    this.referrerRmName,
    this.receiverRmName,
    this.referrerBranchName,
    this.receiverBranchName,
    this.approverName,
  }) : super._();

  factory _$PipelineReferralImpl.fromJson(Map<String, dynamic> json) =>
      _$$PipelineReferralImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  // Customer Info
  @override
  final String customerId;
  // Parties Involved
  @override
  final String referrerRmId;
  @override
  final String receiverRmId;
  // Branch IDs (nullable for kanwil-level RMs)
  @override
  final String? referrerBranchId;
  @override
  final String? receiverBranchId;
  // Regional Office IDs
  @override
  final String? referrerRegionalOfficeId;
  @override
  final String? receiverRegionalOfficeId;
  // Approver type
  @override
  @JsonKey()
  final ApproverType approverType;
  // Referral Details
  @override
  final String reason;
  @override
  final String? notes;
  // Status
  @override
  @JsonKey()
  final ReferralStatus status;
  // Receiver Response
  @override
  final DateTime? receiverAcceptedAt;
  @override
  final DateTime? receiverRejectedAt;
  @override
  final String? receiverRejectReason;
  @override
  final String? receiverNotes;
  // Manager Approval
  @override
  final DateTime? bmApprovedAt;
  @override
  final String? bmApprovedBy;
  @override
  final DateTime? bmRejectedAt;
  @override
  final String? bmRejectReason;
  @override
  final String? bmNotes;
  // Result
  @override
  @JsonKey()
  final bool bonusCalculated;
  @override
  final double? bonusAmount;
  // Timestamps
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? cancelledAt;
  @override
  final String? cancelReason;
  @override
  @JsonKey()
  final bool isPendingSync;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? lastSyncAt;
  // Lookup fields (populated from joined data)
  @override
  final String? customerName;
  @override
  final String? referrerRmName;
  @override
  final String? receiverRmName;
  @override
  final String? referrerBranchName;
  @override
  final String? receiverBranchName;
  @override
  final String? approverName;

  @override
  String toString() {
    return 'PipelineReferral(id: $id, code: $code, customerId: $customerId, referrerRmId: $referrerRmId, receiverRmId: $receiverRmId, referrerBranchId: $referrerBranchId, receiverBranchId: $receiverBranchId, referrerRegionalOfficeId: $referrerRegionalOfficeId, receiverRegionalOfficeId: $receiverRegionalOfficeId, approverType: $approverType, reason: $reason, notes: $notes, status: $status, receiverAcceptedAt: $receiverAcceptedAt, receiverRejectedAt: $receiverRejectedAt, receiverRejectReason: $receiverRejectReason, receiverNotes: $receiverNotes, bmApprovedAt: $bmApprovedAt, bmApprovedBy: $bmApprovedBy, bmRejectedAt: $bmRejectedAt, bmRejectReason: $bmRejectReason, bmNotes: $bmNotes, bonusCalculated: $bonusCalculated, bonusAmount: $bonusAmount, expiresAt: $expiresAt, cancelledAt: $cancelledAt, cancelReason: $cancelReason, isPendingSync: $isPendingSync, createdAt: $createdAt, updatedAt: $updatedAt, lastSyncAt: $lastSyncAt, customerName: $customerName, referrerRmName: $referrerRmName, receiverRmName: $receiverRmName, referrerBranchName: $referrerBranchName, receiverBranchName: $receiverBranchName, approverName: $approverName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PipelineReferralImpl &&
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
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.referrerRmName, referrerRmName) ||
                other.referrerRmName == referrerRmName) &&
            (identical(other.receiverRmName, receiverRmName) ||
                other.receiverRmName == receiverRmName) &&
            (identical(other.referrerBranchName, referrerBranchName) ||
                other.referrerBranchName == referrerBranchName) &&
            (identical(other.receiverBranchName, receiverBranchName) ||
                other.receiverBranchName == receiverBranchName) &&
            (identical(other.approverName, approverName) ||
                other.approverName == approverName));
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
    isPendingSync,
    createdAt,
    updatedAt,
    lastSyncAt,
    customerName,
    referrerRmName,
    receiverRmName,
    referrerBranchName,
    receiverBranchName,
    approverName,
  ]);

  /// Create a copy of PipelineReferral
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PipelineReferralImplCopyWith<_$PipelineReferralImpl> get copyWith =>
      __$$PipelineReferralImplCopyWithImpl<_$PipelineReferralImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PipelineReferralImplToJson(this);
  }
}

abstract class _PipelineReferral extends PipelineReferral {
  const factory _PipelineReferral({
    required final String id,
    required final String code,
    required final String customerId,
    required final String referrerRmId,
    required final String receiverRmId,
    final String? referrerBranchId,
    final String? receiverBranchId,
    final String? referrerRegionalOfficeId,
    final String? receiverRegionalOfficeId,
    final ApproverType approverType,
    required final String reason,
    final String? notes,
    final ReferralStatus status,
    final DateTime? receiverAcceptedAt,
    final DateTime? receiverRejectedAt,
    final String? receiverRejectReason,
    final String? receiverNotes,
    final DateTime? bmApprovedAt,
    final String? bmApprovedBy,
    final DateTime? bmRejectedAt,
    final String? bmRejectReason,
    final String? bmNotes,
    final bool bonusCalculated,
    final double? bonusAmount,
    final DateTime? expiresAt,
    final DateTime? cancelledAt,
    final String? cancelReason,
    final bool isPendingSync,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? lastSyncAt,
    final String? customerName,
    final String? referrerRmName,
    final String? receiverRmName,
    final String? referrerBranchName,
    final String? receiverBranchName,
    final String? approverName,
  }) = _$PipelineReferralImpl;
  const _PipelineReferral._() : super._();

  factory _PipelineReferral.fromJson(Map<String, dynamic> json) =
      _$PipelineReferralImpl.fromJson;

  @override
  String get id;
  @override
  String get code; // Customer Info
  @override
  String get customerId; // Parties Involved
  @override
  String get referrerRmId;
  @override
  String get receiverRmId; // Branch IDs (nullable for kanwil-level RMs)
  @override
  String? get referrerBranchId;
  @override
  String? get receiverBranchId; // Regional Office IDs
  @override
  String? get referrerRegionalOfficeId;
  @override
  String? get receiverRegionalOfficeId; // Approver type
  @override
  ApproverType get approverType; // Referral Details
  @override
  String get reason;
  @override
  String? get notes; // Status
  @override
  ReferralStatus get status; // Receiver Response
  @override
  DateTime? get receiverAcceptedAt;
  @override
  DateTime? get receiverRejectedAt;
  @override
  String? get receiverRejectReason;
  @override
  String? get receiverNotes; // Manager Approval
  @override
  DateTime? get bmApprovedAt;
  @override
  String? get bmApprovedBy;
  @override
  DateTime? get bmRejectedAt;
  @override
  String? get bmRejectReason;
  @override
  String? get bmNotes; // Result
  @override
  bool get bonusCalculated;
  @override
  double? get bonusAmount; // Timestamps
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get cancelledAt;
  @override
  String? get cancelReason;
  @override
  bool get isPendingSync;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get lastSyncAt; // Lookup fields (populated from joined data)
  @override
  String? get customerName;
  @override
  String? get referrerRmName;
  @override
  String? get receiverRmName;
  @override
  String? get referrerBranchName;
  @override
  String? get receiverBranchName;
  @override
  String? get approverName;

  /// Create a copy of PipelineReferral
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PipelineReferralImplCopyWith<_$PipelineReferralImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApproverInfo _$ApproverInfoFromJson(Map<String, dynamic> json) {
  return _ApproverInfo.fromJson(json);
}

/// @nodoc
mixin _$ApproverInfo {
  String get approverId => throw _privateConstructorUsedError;
  ApproverType get approverType => throw _privateConstructorUsedError;
  String? get approverName => throw _privateConstructorUsedError;

  /// Serializes this ApproverInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApproverInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApproverInfoCopyWith<ApproverInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApproverInfoCopyWith<$Res> {
  factory $ApproverInfoCopyWith(
    ApproverInfo value,
    $Res Function(ApproverInfo) then,
  ) = _$ApproverInfoCopyWithImpl<$Res, ApproverInfo>;
  @useResult
  $Res call({
    String approverId,
    ApproverType approverType,
    String? approverName,
  });
}

/// @nodoc
class _$ApproverInfoCopyWithImpl<$Res, $Val extends ApproverInfo>
    implements $ApproverInfoCopyWith<$Res> {
  _$ApproverInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApproverInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? approverId = null,
    Object? approverType = null,
    Object? approverName = freezed,
  }) {
    return _then(
      _value.copyWith(
            approverId: null == approverId
                ? _value.approverId
                : approverId // ignore: cast_nullable_to_non_nullable
                      as String,
            approverType: null == approverType
                ? _value.approverType
                : approverType // ignore: cast_nullable_to_non_nullable
                      as ApproverType,
            approverName: freezed == approverName
                ? _value.approverName
                : approverName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApproverInfoImplCopyWith<$Res>
    implements $ApproverInfoCopyWith<$Res> {
  factory _$$ApproverInfoImplCopyWith(
    _$ApproverInfoImpl value,
    $Res Function(_$ApproverInfoImpl) then,
  ) = __$$ApproverInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String approverId,
    ApproverType approverType,
    String? approverName,
  });
}

/// @nodoc
class __$$ApproverInfoImplCopyWithImpl<$Res>
    extends _$ApproverInfoCopyWithImpl<$Res, _$ApproverInfoImpl>
    implements _$$ApproverInfoImplCopyWith<$Res> {
  __$$ApproverInfoImplCopyWithImpl(
    _$ApproverInfoImpl _value,
    $Res Function(_$ApproverInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApproverInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? approverId = null,
    Object? approverType = null,
    Object? approverName = freezed,
  }) {
    return _then(
      _$ApproverInfoImpl(
        approverId: null == approverId
            ? _value.approverId
            : approverId // ignore: cast_nullable_to_non_nullable
                  as String,
        approverType: null == approverType
            ? _value.approverType
            : approverType // ignore: cast_nullable_to_non_nullable
                  as ApproverType,
        approverName: freezed == approverName
            ? _value.approverName
            : approverName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApproverInfoImpl implements _ApproverInfo {
  const _$ApproverInfoImpl({
    required this.approverId,
    required this.approverType,
    this.approverName,
  });

  factory _$ApproverInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApproverInfoImplFromJson(json);

  @override
  final String approverId;
  @override
  final ApproverType approverType;
  @override
  final String? approverName;

  @override
  String toString() {
    return 'ApproverInfo(approverId: $approverId, approverType: $approverType, approverName: $approverName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApproverInfoImpl &&
            (identical(other.approverId, approverId) ||
                other.approverId == approverId) &&
            (identical(other.approverType, approverType) ||
                other.approverType == approverType) &&
            (identical(other.approverName, approverName) ||
                other.approverName == approverName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, approverId, approverType, approverName);

  /// Create a copy of ApproverInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApproverInfoImplCopyWith<_$ApproverInfoImpl> get copyWith =>
      __$$ApproverInfoImplCopyWithImpl<_$ApproverInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApproverInfoImplToJson(this);
  }
}

abstract class _ApproverInfo implements ApproverInfo {
  const factory _ApproverInfo({
    required final String approverId,
    required final ApproverType approverType,
    final String? approverName,
  }) = _$ApproverInfoImpl;

  factory _ApproverInfo.fromJson(Map<String, dynamic> json) =
      _$ApproverInfoImpl.fromJson;

  @override
  String get approverId;
  @override
  ApproverType get approverType;
  @override
  String? get approverName;

  /// Create a copy of ApproverInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApproverInfoImplCopyWith<_$ApproverInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
