import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoring_entities.freezed.dart';
part 'scoring_entities.g.dart';

// ============================================
// 4DX SCORING ENTITIES
// ============================================

/// Measure definition (lead & lag measures).
@freezed
class MeasureDefinition with _$MeasureDefinition {
  const factory MeasureDefinition({
    required String id,
    required String code,
    required String name,
    String? description,
    required String measureType, // 'LEAD' or 'LAG'
    required String dataType, // 'COUNT', 'SUM', 'PERCENTAGE'
    String? unit,
    String? calculationFormula,
    String? sourceTable,
    String? sourceCondition,
    @Default(1.0) double weight, // Scoring weight
    @Default(0) double defaultTarget, // Default target value
    String? periodType, // 'WEEKLY', 'MONTHLY', 'QUARTERLY'
    String? templateType, // Template used (activity_count, pipeline_count, etc.)
    Map<String, dynamic>? templateConfig, // Original template selections for editing
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MeasureDefinition;

  factory MeasureDefinition.fromJson(Map<String, dynamic> json) =>
      _$MeasureDefinitionFromJson(json);
}

/// Scoring period (weekly, monthly, quarterly).
@freezed
class ScoringPeriod with _$ScoringPeriod {
  const factory ScoringPeriod({
    required String id,
    required String name,
    required String periodType, // 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool isCurrent,
    @Default(false) bool isLocked, // Locked periods cannot be modified
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ScoringPeriod;

  factory ScoringPeriod.fromJson(Map<String, dynamic> json) =>
      _$ScoringPeriodFromJson(json);
}

/// User target for a specific period and measure.
@freezed
class UserTarget with _$UserTarget {
  const factory UserTarget({
    required String id,
    required String userId,
    required String measureId,
    required String periodId,
    required double targetValue,
    String? assignedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Display fields (resolved from joins)
    String? measureName,
    String? measureType,
    String? measureUnit,
  }) = _UserTarget;

  factory UserTarget.fromJson(Map<String, dynamic> json) =>
      _$UserTargetFromJson(json);
}

/// User score (actual value) for a specific period and measure.
@freezed
class UserScore with _$UserScore {
  const UserScore._();

  const factory UserScore({
    required String id,
    required String userId,
    required String measureId,
    required String periodId,
    required double actualValue,
    required double targetValue,
    double? percentage,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Display fields (resolved from joins)
    String? measureName,
    String? measureType,
    String? measureUnit,
    @Default(0) int sortOrder,
  }) = _UserScore;

  factory UserScore.fromJson(Map<String, dynamic> json) =>
      _$UserScoreFromJson(json);

  /// Calculate percentage if not provided.
  double get calculatedPercentage {
    if (percentage != null) return percentage!;
    if (targetValue == 0) return 0;
    return (actualValue / targetValue) * 100;
  }

  /// Check if target is met.
  bool get isTargetMet => calculatedPercentage >= 100;

  /// Get status color indicator.
  String get statusLabel {
    final pct = calculatedPercentage;
    if (pct >= 100) return 'Target Met';
    if (pct >= 80) return 'Almost There';
    if (pct >= 60) return 'Needs Work';
    return 'Critical';
  }
}

/// Period summary score with ranking.
@freezed
class PeriodSummary with _$PeriodSummary {
  const PeriodSummary._();

  const factory PeriodSummary({
    required String id,
    required String userId,
    required String periodId,
    @Default(0) double totalLeadScore,
    @Default(0) double totalLagScore,
    @Default(0) double compositeScore,
    @Default(0) double bonusPoints,
    @Default(0) double penaltyPoints,
    int? rank,
    int? rankChange,
    DateTime? calculatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Display fields
    String? userName,
    String? periodName,
  }) = _PeriodSummary;

  factory PeriodSummary.fromJson(Map<String, dynamic> json) =>
      _$PeriodSummaryFromJson(json);

  /// Get trend indicator.
  String get trendIndicator {
    if (rankChange == null) return '─';
    if (rankChange! > 0) return '↑';
    if (rankChange! < 0) return '↓';
    return '─';
  }

  /// Get status based on composite score.
  String get statusLabel {
    if (compositeScore >= 90) return 'Excellent';
    if (compositeScore >= 75) return 'On Track';
    if (compositeScore >= 60) return 'Needs Attention';
    if (compositeScore >= 40) return 'At Risk';
    return 'Critical';
  }

  /// Get net adjustment (bonuses - penalties).
  double get netAdjustment => bonusPoints - penaltyPoints;

  /// Check if there are any bonuses or penalties.
  bool get hasAdjustments => bonusPoints > 0 || penaltyPoints > 0;
}

/// Leaderboard entry for display.
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const LeaderboardEntry._();

  const factory LeaderboardEntry({
    required String id,
    required String rank,
    required String userId,
    required String userName,
    required double score,
    required double leadScore,
    required double lagScore,
    int? rankChange,
    String? branchName,
    String? profileImageUrl,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  /// Get medal for top 3.
  String? get medal {
    if (rank == '1') return '🥇';
    if (rank == '2') return '🥈';
    if (rank == '3') return '🥉';
    return null;
  }

  /// Get trend indicator.
  String get trendIndicator {
    if (rankChange == null) return '─';
    if (rankChange! > 0) return '↑';
    if (rankChange! < 0) return '↓';
    return '─';
  }

  /// Get status label based on score.
  String get statusLabel {
    if (score >= 90) return 'Top Performer';
    if (score >= 75) return 'On Track';
    if (score >= 60) return 'Needs Attention';
    if (score >= 40) return 'At Risk';
    return 'Critical';
  }
}

/// Dashboard statistics aggregation.
@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    // Activities
    @Default(0) int todayActivitiesCompleted,
    @Default(0) int todayActivitiesTotal,
    // Pipelines
    @Default(0) int activePipelinesCount,
    @Default(0) double totalPotentialPremium,
    // Scoring
    double? userScore,
    int? userRank,
    int? totalTeamMembers,
    int? rankChange,
    // Weekly summary
    @Default(0) int weeklyVisits,
    @Default(0) int weeklyVisitsTarget,
    @Default(0) int weeklyPipelinesWon,
    @Default(0) double weeklyPremiumWon,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}

/// Team summary statistics for Branch Heads/Managers.
@freezed
class TeamSummary with _$TeamSummary {
  const TeamSummary._();

  const factory TeamSummary({
    required String id,
    required String periodId,
    String? branchId,
    String? regionalOfficeId,
    String? branchName,
    String? regionalOfficeName,
    @Default(0) double averageScore,
    @Default(0) double averageLeadScore,
    @Default(0) double averageLagScore,
    int? teamRank,
    int? totalTeams,
    @Default(0) int teamMembersCount,
    double? scoreChange,
    int? rankChange,
    DateTime? calculatedAt,
  }) = _TeamSummary;

  factory TeamSummary.fromJson(Map<String, dynamic> json) =>
      _$TeamSummaryFromJson(json);

  /// Get trend indicator.
  String get trendIndicator {
    if (scoreChange == null) return '─';
    if (scoreChange! > 0) return '↑';
    if (scoreChange! < 0) return '↓';
    return '─';
  }

  /// Get formatted score change.
  String get scoreChangeText {
    if (scoreChange == null) return '';
    final change = scoreChange!.abs();
    return scoreChange! >= 0 ? '+$change' : '-$change';
  }

  /// Get status label based on average score.
  String get statusLabel {
    if (averageScore >= 90) return 'Excellent';
    if (averageScore >= 75) return 'Good';
    if (averageScore >= 60) return 'Fair';
    if (averageScore >= 40) return 'Needs Improvement';
    return 'Critical';
  }
}
