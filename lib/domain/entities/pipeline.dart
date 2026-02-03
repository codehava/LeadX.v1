import 'package:freezed_annotation/freezed_annotation.dart';

part 'pipeline.freezed.dart';
part 'pipeline.g.dart';

/// Pipeline stage information for UI display.
@freezed
class PipelineStageInfo with _$PipelineStageInfo {
  const factory PipelineStageInfo({
    required String id,
    required String code,
    required String name,
    required int probability,
    required int sequence,
    String? color,
    @Default(false) bool isFinal,
    @Default(false) bool isWon,
    @Default(true) bool isActive,
  }) = _PipelineStageInfo;

  factory PipelineStageInfo.fromJson(Map<String, dynamic> json) =>
      _$PipelineStageInfoFromJson(json);
}

/// Pipeline status information for UI display.
@freezed
class PipelineStatusInfo with _$PipelineStatusInfo {
  const factory PipelineStatusInfo({
    required String id,
    required String stageId,
    required String code,
    required String name,
    required int sequence,
    String? description,
    @Default(false) bool isDefault,
    @Default(true) bool isActive,
  }) = _PipelineStatusInfo;

  factory PipelineStatusInfo.fromJson(Map<String, dynamic> json) =>
      _$PipelineStatusInfoFromJson(json);
}

/// Pipeline domain entity representing a sales opportunity.
@freezed
class Pipeline with _$Pipeline {
  const factory Pipeline({
    required String id,
    required String code,
    required String customerId,
    required String stageId,
    required String statusId,
    required String cobId,
    required String lobId,
    required String leadSourceId,
    required String assignedRmId,
    required String createdBy,
    required double potentialPremium,
    required DateTime createdAt,
    required DateTime updatedAt,
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
    @Default(false) bool isTender,
    String? referredByUserId,
    String? referralId,
    /// User who receives 4DX lag measure credit. Set at win time, never changes.
    String? scoredToUserId,
    @Default(false) bool isPendingSync,
    DateTime? closedAt,
    DateTime? deletedAt,
    DateTime? lastSyncAt,
    // Lookup fields (populated from joined data)
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
    /// Display name for user who receives scoring credit.
    String? scoredToUserName,
  }) = _Pipeline;

  const Pipeline._();

  factory Pipeline.fromJson(Map<String, dynamic> json) =>
      _$PipelineFromJson(json);

  /// Check if pipeline needs to be synced.
  bool get needsSync => isPendingSync;

  /// Check if pipeline is won.
  bool get isWon => stageIsWon ?? false;

  /// Check if pipeline is lost (closed but not won).
  bool get isLost => (stageIsFinal ?? false) && !(stageIsWon ?? false);

  /// Check if pipeline is closed (won or lost).
  bool get isClosed => stageIsFinal ?? false;

  /// Check if pipeline is soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Get display name (customer name or code fallback).
  String get displayName => customerName ?? code;

  /// Get formatted potential premium.
  String get formattedPotentialPremium => _formatCurrency(potentialPremium);

  /// Get formatted final premium.
  String get formattedFinalPremium =>
      finalPremium != null ? _formatCurrency(finalPremium!) : '-';

  /// Get formatted TSI.
  String get formattedTsi => tsi != null ? _formatCurrency(tsi!) : '-';

  /// Get formatted weighted value.
  String get formattedWeightedValue =>
      weightedValue != null ? _formatCurrency(weightedValue!) : '-';

  /// Get COB/LOB display string.
  String get cobLobDisplay {
    final cob = cobName ?? 'Unknown COB';
    final lob = lobName ?? 'Unknown LOB';
    return '$cob / $lob';
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

/// Pipeline with full details for detail screen.
@freezed
class PipelineWithDetails with _$PipelineWithDetails {
  const factory PipelineWithDetails({
    required Pipeline pipeline,
    PipelineStageInfo? stage,
    PipelineStatusInfo? status,
  }) = _PipelineWithDetails;

  const PipelineWithDetails._();

  factory PipelineWithDetails.fromJson(Map<String, dynamic> json) =>
      _$PipelineWithDetailsFromJson(json);
}
