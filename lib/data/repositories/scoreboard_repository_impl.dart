import 'package:flutter/foundation.dart';

import '../../domain/entities/scoring_entities.dart';
import '../../domain/repositories/scoreboard_repository.dart';
import '../datasources/local/scoreboard_local_data_source.dart';
import '../datasources/remote/scoreboard_remote_data_source.dart';
import '../services/connectivity_service.dart';

/// Implementation of [ScoreboardRepository] with offline-first approach.
class ScoreboardRepositoryImpl implements ScoreboardRepository {
  final ScoreboardLocalDataSource _localDataSource;
  final ScoreboardRemoteDataSource _remoteDataSource;
  final ConnectivityService _connectivityService;

  ScoreboardRepositoryImpl({
    required ScoreboardLocalDataSource localDataSource,
    required ScoreboardRemoteDataSource remoteDataSource,
    required ConnectivityService connectivityService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _connectivityService = connectivityService;

  // ============================================
  // MEASURE DEFINITIONS
  // ============================================

  @override
  Future<List<MeasureDefinition>> getMeasureDefinitions() async {
    // Try local first
    final localData = await _localDataSource.getMeasureDefinitions();
    if (localData.isNotEmpty) {
      return localData;
    }

    // Fallback to remote if local is empty and online
    if (await _connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchMeasureDefinitions();
        await _localDataSource.upsertMeasureDefinitions(remoteData);
        return remoteData;
      } catch (e) {
        // Return empty if remote fails
        return [];
      }
    }

    return [];
  }

  @override
  Future<List<MeasureDefinition>> getMeasureDefinitionsByType(
      String measureType) async {
    return _localDataSource.getMeasureDefinitionsByType(measureType);
  }

  // ============================================
  // SCORING PERIODS
  // ============================================

  @override
  Future<List<ScoringPeriod>> getScoringPeriods() async {
    // Try local first
    final localData = await _localDataSource.getScoringPeriods();
    if (localData.isNotEmpty) {
      return localData;
    }

    // Fallback to remote
    if (await _connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchScoringPeriods();
        await _localDataSource.upsertScoringPeriods(remoteData);
        return remoteData;
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  @override
  Future<ScoringPeriod?> getCurrentPeriod() async {
    // Try local first
    final localData = await _localDataSource.getCurrentPeriod();
    if (localData != null) {
      return localData;
    }

    // Fallback to remote
    if (await _connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchCurrentPeriod();
        if (remoteData != null) {
          await _localDataSource.upsertScoringPeriods([remoteData]);
        }
        return remoteData;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  @override
  Future<ScoringPeriod?> getScoringPeriodById(String periodId) async {
    return _localDataSource.getScoringPeriodById(periodId);
  }

  // ============================================
  // USER TARGETS
  // ============================================

  @override
  Future<List<UserTarget>> getUserTargets(
      String userId, String periodId) async {
    // Try local first
    final localData = await _localDataSource.getUserTargets(userId, periodId);
    if (localData.isNotEmpty) {
      return localData;
    }

    // Fallback to remote
    if (await _connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserTargets(userId, periodId);
        await _localDataSource.upsertUserTargets(remoteData);
        return remoteData;
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  // ============================================
  // USER SCORES
  // ============================================

  @override
  Future<List<UserScore>> getUserScores(String userId, String periodId) async {
    // Try local first
    final localData = await _localDataSource.getUserScores(userId, periodId);
    if (localData.isNotEmpty) {
      return localData;
    }

    // Fallback to remote
    if (await _connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserScores(userId, periodId);
        await _localDataSource.upsertUserScores(remoteData);
        return remoteData;
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  @override
  Future<List<UserScore>> getUserScoresByType(
    String userId,
    String periodId,
    String measureType,
  ) async {
    return _localDataSource.getUserScoresByType(userId, periodId, measureType);
  }

  // ============================================
  // PERIOD SUMMARY & LEADERBOARD
  // ============================================

  @override
  Future<PeriodSummary?> getUserPeriodSummary(
      String userId, String periodId) async {
    // Try local first
    final localData =
        await _localDataSource.getUserPeriodSummary(userId, periodId);
    if (localData != null) {
      return localData;
    }

    // Fallback to remote
    if (await _connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserPeriodSummary(userId, periodId);
        if (remoteData != null) {
          await _localDataSource.upsertPeriodSummaries([remoteData]);
        }
        return remoteData;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  @override
  Future<int?> getUserRank(String userId, String periodId) async {
    final summary = await getUserPeriodSummary(userId, periodId);
    return summary?.rank;
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String periodId,
      {int limit = 10}) async {
    // Always try remote for leaderboard as it needs to be current
    if (await _connectivityService.isConnected) {
      try {
        return await _remoteDataSource.fetchLeaderboard(periodId, limit: limit);
      } catch (e) {
        // Fallback to local
      }
    }

    // Fallback to local (convert PeriodSummary to LeaderboardEntry)
    final localData =
        await _localDataSource.getLeaderboard(periodId, limit: limit);
    return localData.map((summary) {
      return LeaderboardEntry(
        id: summary.id,
        rank: (summary.rank ?? 0).toString(),
        userId: summary.userId,
        userName: summary.userName ?? 'Unknown',
        score: summary.compositeScore,
        leadScore: summary.totalLeadScore,
        lagScore: summary.totalLagScore,
        rankChange: summary.rankChange,
      );
    }).toList();
  }

  @override
  Future<int> getTeamMembersCount(String periodId) async {
    return _localDataSource.getTeamMembersCount(periodId);
  }

  // ============================================
  // DASHBOARD
  // ============================================

  @override
  Future<DashboardStats> getDashboardStats(String userId) async {
    // Try remote first if online
    if (await _connectivityService.isConnected) {
      try {
        return await _remoteDataSource.fetchDashboardStats(userId);
      } catch (e) {
        // Fallback to local aggregation
      }
    }

    // Local aggregation
    final currentPeriod = await getCurrentPeriod();
    if (currentPeriod == null) {
      return const DashboardStats();
    }

    final summary =
        await getUserPeriodSummary(userId, currentPeriod.id);
    final teamCount = await getTeamMembersCount(currentPeriod.id);

    return DashboardStats(
      userScore: summary?.compositeScore,
      userRank: summary?.rank,
      totalTeamMembers: teamCount,
      rankChange: summary?.rankChange,
    );
  }

  // ============================================
  // SYNC
  // ============================================

  @override
  Future<void> syncScoringData() async {
    if (!await _connectivityService.isConnected) return;

    await syncMeasureDefinitions();
    await syncScoringPeriods();
  }

  @override
  Future<void> syncMeasureDefinitions() async {
    if (!await _connectivityService.isConnected) return;

    try {
      final remoteData = await _remoteDataSource.fetchMeasureDefinitions();
      await _localDataSource.upsertMeasureDefinitions(remoteData);
    } catch (e) {
      debugPrint('[ScoreboardRepo] Failed to sync measure definitions: $e');
    }
  }

  @override
  Future<void> syncScoringPeriods() async {
    if (!await _connectivityService.isConnected) return;

    try {
      final remoteData = await _remoteDataSource.fetchScoringPeriods();
      await _localDataSource.upsertScoringPeriods(remoteData);
    } catch (e) {
      debugPrint('[ScoreboardRepo] Failed to sync scoring periods: $e');
    }
  }

  @override
  Future<void> syncUserScores(String userId) async {
    if (!await _connectivityService.isConnected) return;

    final currentPeriod = await _remoteDataSource.fetchCurrentPeriod();
    if (currentPeriod == null) return;

    try {
      // Sync targets
      final targets =
          await _remoteDataSource.fetchUserTargets(userId, currentPeriod.id);
      await _localDataSource.upsertUserTargets(targets);

      // Sync scores
      final scores =
          await _remoteDataSource.fetchUserScores(userId, currentPeriod.id);
      await _localDataSource.upsertUserScores(scores);

      // Sync period summary
      final summary = await _remoteDataSource.fetchUserPeriodSummary(
          userId, currentPeriod.id);
      if (summary != null) {
        await _localDataSource.upsertPeriodSummaries([summary]);
      }
    } catch (e) {
      debugPrint('[ScoreboardRepo] Failed to sync user scores: $e');
    }
  }
}
