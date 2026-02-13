import '../entities/scoring_entities.dart';

/// Repository interface for 4DX Scoreboard data.
abstract class ScoreboardRepository {
  // ============================================
  // MEASURE DEFINITIONS
  // ============================================

  /// Get all active measure definitions.
  Future<List<MeasureDefinition>> getMeasureDefinitions();

  /// Get measure definitions by type (LEAD or LAG).
  Future<List<MeasureDefinition>> getMeasureDefinitionsByType(String measureType);

  // ============================================
  // SCORING PERIODS
  // ============================================

  /// Get all scoring periods.
  Future<List<ScoringPeriod>> getScoringPeriods();

  /// Get the current display period (shortest granularity).
  Future<ScoringPeriod?> getCurrentPeriod();

  /// Get all current periods (one per period_type).
  Future<List<ScoringPeriod>> getAllCurrentPeriods();

  /// Get scoring period by ID.
  Future<ScoringPeriod?> getScoringPeriodById(String periodId);

  // ============================================
  // USER TARGETS
  // ============================================

  /// Get user targets for a specific period.
  Future<List<UserTarget>> getUserTargets(String userId, String periodId);

  // ============================================
  // USER SCORES
  // ============================================

  /// Get user scores for a specific period.
  Future<List<UserScore>> getUserScores(String userId, String periodId);

  /// Get user scores by measure type (LEAD or LAG).
  Future<List<UserScore>> getUserScoresByType(
    String userId,
    String periodId,
    String measureType,
  );

  /// Get user scores across all current periods.
  Future<List<UserScore>> getUserScoresForCurrentPeriods(String userId);

  // ============================================
  // PERIOD SUMMARY & LEADERBOARD
  // ============================================

  /// Get user's period summary.
  Future<PeriodSummary?> getUserPeriodSummary(String userId, String periodId);

  /// Get user's rank in a period.
  Future<int?> getUserRank(String userId, String periodId);

  /// Get leaderboard for a period.
  Future<List<LeaderboardEntry>> getLeaderboard(String periodId, {int limit = 10});

  /// Get leaderboard with filters for dedicated leaderboard screen.
  Future<List<LeaderboardEntry>> getLeaderboardWithFilters(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
    String? searchQuery,
    int limit = 100,
  });

  /// Get team summary for branch or region.
  Future<TeamSummary?> getTeamSummary(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
  });

  /// Get total team members count.
  Future<int> getTeamMembersCount(String periodId);

  // ============================================
  // DASHBOARD
  // ============================================

  /// Get aggregated dashboard statistics.
  Future<DashboardStats> getDashboardStats(String userId);

  // ============================================
  // SYNC
  // ============================================

  /// Sync all scoring data from remote.
  Future<void> syncScoringData();

  /// Sync measure definitions from remote.
  Future<void> syncMeasureDefinitions();

  /// Sync scoring periods from remote.
  Future<void> syncScoringPeriods();

  /// Sync user scores and summaries from remote.
  Future<void> syncUserScores(String userId);
}
