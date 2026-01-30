import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline_referral.freezed.dart';
part 'pipeline_referral.g.dart';

/// Referral status enum matching database CHECK constraint.
@JsonEnum(alwaysCreate: true)
enum ReferralStatus {
  @JsonValue('PENDING_RECEIVER')
  pendingReceiver,
  @JsonValue('RECEIVER_ACCEPTED')
  receiverAccepted,
  @JsonValue('RECEIVER_REJECTED')
  receiverRejected,
  @JsonValue('PENDING_BM')
  pendingBm,
  @JsonValue('BM_APPROVED')
  bmApproved,
  @JsonValue('BM_REJECTED')
  bmRejected,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

/// Extension methods for ReferralStatus.
extension ReferralStatusX on ReferralStatus {
  /// Get display name for the status.
  String get displayName {
    switch (this) {
      case ReferralStatus.pendingReceiver:
        return 'Menunggu Penerima';
      case ReferralStatus.receiverAccepted:
        return 'Diterima, Menunggu Approval';
      case ReferralStatus.receiverRejected:
        return 'Ditolak Penerima';
      case ReferralStatus.pendingBm:
        return 'Menunggu Approval Manager';
      case ReferralStatus.bmApproved:
        return 'Disetujui';
      case ReferralStatus.bmRejected:
        return 'Ditolak Manager';
      case ReferralStatus.completed:
        return 'Selesai';
      case ReferralStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  /// Check if this is an end state (no further actions possible).
  bool get isEndState {
    return this == ReferralStatus.receiverRejected ||
        this == ReferralStatus.bmRejected ||
        this == ReferralStatus.completed ||
        this == ReferralStatus.cancelled;
  }

  /// Check if referral is still actionable.
  bool get isActionable => !isEndState;

  /// Check if referral was successful.
  bool get isSuccessful => this == ReferralStatus.completed;

  /// Get string value for database.
  String get value {
    switch (this) {
      case ReferralStatus.pendingReceiver:
        return 'PENDING_RECEIVER';
      case ReferralStatus.receiverAccepted:
        return 'RECEIVER_ACCEPTED';
      case ReferralStatus.receiverRejected:
        return 'RECEIVER_REJECTED';
      case ReferralStatus.pendingBm:
        return 'PENDING_BM';
      case ReferralStatus.bmApproved:
        return 'BM_APPROVED';
      case ReferralStatus.bmRejected:
        return 'BM_REJECTED';
      case ReferralStatus.completed:
        return 'COMPLETED';
      case ReferralStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Parse from string value.
  static ReferralStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING_RECEIVER':
        return ReferralStatus.pendingReceiver;
      case 'RECEIVER_ACCEPTED':
        return ReferralStatus.receiverAccepted;
      case 'RECEIVER_REJECTED':
        return ReferralStatus.receiverRejected;
      case 'PENDING_BM':
        return ReferralStatus.pendingBm;
      case 'BM_APPROVED':
        return ReferralStatus.bmApproved;
      case 'BM_REJECTED':
        return ReferralStatus.bmRejected;
      case 'COMPLETED':
        return ReferralStatus.completed;
      case 'CANCELLED':
        return ReferralStatus.cancelled;
      default:
        return ReferralStatus.pendingReceiver;
    }
  }
}

/// Approver type enum - any role besides RM can be an approver.
@JsonEnum(alwaysCreate: true)
enum ApproverType {
  @JsonValue('BH')
  bh,
  @JsonValue('BM')
  bm,
  @JsonValue('ROH')
  roh,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('SUPERADMIN')
  superadmin,
}

/// Extension methods for ApproverType.
extension ApproverTypeX on ApproverType {
  /// Get display name.
  String get displayName {
    switch (this) {
      case ApproverType.bh:
        return 'Business Head';
      case ApproverType.bm:
        return 'Branch Manager';
      case ApproverType.roh:
        return 'Regional Office Head';
      case ApproverType.admin:
        return 'Admin';
      case ApproverType.superadmin:
        return 'Super Admin';
    }
  }

  /// Get short display name.
  String get shortName {
    switch (this) {
      case ApproverType.bh:
        return 'BH';
      case ApproverType.bm:
        return 'BM';
      case ApproverType.roh:
        return 'ROH';
      case ApproverType.admin:
        return 'Admin';
      case ApproverType.superadmin:
        return 'Superadmin';
    }
  }

  /// Get string value for database.
  String get value {
    switch (this) {
      case ApproverType.bh:
        return 'BH';
      case ApproverType.bm:
        return 'BM';
      case ApproverType.roh:
        return 'ROH';
      case ApproverType.admin:
        return 'ADMIN';
      case ApproverType.superadmin:
        return 'SUPERADMIN';
    }
  }

  /// Parse from string value.
  static ApproverType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ROH':
        return ApproverType.roh;
      case 'BH':
        return ApproverType.bh;
      case 'ADMIN':
        return ApproverType.admin;
      case 'SUPERADMIN':
        return ApproverType.superadmin;
      case 'BM':
      default:
        return ApproverType.bm;
    }
  }
}

/// Pipeline referral domain entity.
/// Represents a request to transfer a customer from one RM to another.
/// Note: This is an online-only operation - customer transfers require network.
@freezed
class PipelineReferral with _$PipelineReferral {
  const factory PipelineReferral({
    required String id,
    required String code,

    // Customer Info
    required String customerId,

    // Parties Involved
    required String referrerRmId,
    required String receiverRmId,

    // Branch IDs (nullable for kanwil-level RMs)
    String? referrerBranchId,
    String? receiverBranchId,

    // Regional Office IDs
    String? referrerRegionalOfficeId,
    String? receiverRegionalOfficeId,

    // Approver type
    @Default(ApproverType.bm) ApproverType approverType,

    // Referral Details
    required String reason,
    String? notes,

    // Status
    @Default(ReferralStatus.pendingReceiver) ReferralStatus status,

    // Receiver Response
    DateTime? receiverAcceptedAt,
    DateTime? receiverRejectedAt,
    String? receiverRejectReason,
    String? receiverNotes,

    // Manager Approval
    DateTime? bmApprovedAt,
    String? bmApprovedBy,
    DateTime? bmRejectedAt,
    String? bmRejectReason,
    String? bmNotes,

    // Result
    @Default(false) bool bonusCalculated,
    double? bonusAmount,

    // Timestamps
    DateTime? expiresAt,
    DateTime? cancelledAt,
    String? cancelReason,
    @Default(false) bool isPendingSync,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastSyncAt,

    // Lookup fields (populated from joined data)
    String? customerName,
    String? referrerRmName,
    String? receiverRmName,
    String? referrerBranchName,
    String? receiverBranchName,
    String? approverName,
  }) = _PipelineReferral;

  const PipelineReferral._();

  factory PipelineReferral.fromJson(Map<String, dynamic> json) =>
      _$PipelineReferralFromJson(json);

  /// Check if current user is the referrer.
  bool isReferrer(String userId) => referrerRmId == userId;

  /// Check if current user is the receiver.
  bool isReceiver(String userId) => receiverRmId == userId;

  /// Check if current user is the approver.
  bool isApprover(String userId) => bmApprovedBy == userId;

  /// Check if referral can be accepted (by receiver).
  bool get canBeAccepted => status == ReferralStatus.pendingReceiver;

  /// Check if referral can be rejected (by receiver).
  bool get canBeRejected => status == ReferralStatus.pendingReceiver;

  /// Check if referral can be approved (by manager).
  bool get canBeApproved => status == ReferralStatus.receiverAccepted;

  /// Check if referral can be cancelled (by referrer).
  bool get canBeCancelled =>
      status == ReferralStatus.pendingReceiver ||
      status == ReferralStatus.receiverAccepted;

  /// Check if referral is waiting for receiver response.
  bool get isWaitingReceiver => status == ReferralStatus.pendingReceiver;

  /// Check if referral is waiting for manager approval.
  bool get isWaitingApproval => status == ReferralStatus.receiverAccepted;

  /// Check if referral needs sync.
  bool get needsSync => isPendingSync;

  /// Get formatted bonus amount.
  String get formattedBonusAmount =>
      bonusAmount != null ? _formatCurrency(bonusAmount!) : '-';

  /// Get transfer display string (From -> To).
  String get transferDisplay {
    final from = referrerRmName ?? 'Unknown';
    final to = receiverRmName ?? 'Unknown';
    return '$from → $to';
  }

  /// Helper to format currency.
  String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}Rb';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }
}

/// Result of approver lookup operation.
@freezed
class ApproverInfo with _$ApproverInfo {
  const factory ApproverInfo({
    required String approverId,
    required ApproverType approverType,
    String? approverName,
  }) = _ApproverInfo;

  factory ApproverInfo.fromJson(Map<String, dynamic> json) =>
      _$ApproverInfoFromJson(json);
}
