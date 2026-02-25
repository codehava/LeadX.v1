import '../../core/logging/app_logger.dart';
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
  final _log = AppLogger.instance;

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
    // Always try remote first — measures are managed server-side by admins
    if (_connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchMeasureDefinitions();
        await _localDataSource.upsertMeasureDefinitions(remoteData);
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for measure definitions, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getMeasureDefinitions();
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
    // Always try remote first — periods are managed server-side by admins
    if (_connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchScoringPeriods();
        await _localDataSource.upsertScoringPeriods(remoteData);
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for scoring periods, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getScoringPeriods();
  }

  @override
  Future<ScoringPeriod?> getCurrentPeriod() async {
    // Always try remote first — periods are managed server-side by admins
    if (_connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchCurrentPeriod();
        if (remoteData != null) {
          await _localDataSource.upsertScoringPeriods([remoteData]);
        }
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for current period, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getCurrentPeriod();
  }

  @override
  Future<List<ScoringPeriod>> getAllCurrentPeriods() async {
    // Always try remote first — periods are managed server-side by admins
    if (_connectivityService.isConnected) {
      try {
        final remoteData = await _remoteDataSource.fetchAllCurrentPeriods();
        if (remoteData.isNotEmpty) {
          await _localDataSource.upsertScoringPeriods(remoteData);
        }
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for all current periods, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getAllCurrentPeriods();
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
    // Always try remote first — targets are assigned server-side by managers
    if (_connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserTargets(userId, periodId);
        try {
          await _localDataSource.upsertUserTargets(remoteData);
        } catch (cacheError) {
          _log.warning('scoreboard | Failed to cache user targets locally: $cacheError');
        }
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for user targets, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getUserTargets(userId, periodId);
  }

  // ============================================
  // USER SCORES
  // ============================================

  @override
  Future<List<UserScore>> getUserScores(String userId, String periodId) async {
    // Always try remote first — scores are computed server-side by cron
    if (_connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserScores(userId, periodId);
        try {
          await _localDataSource.upsertUserScores(remoteData);
        } catch (cacheError) {
          _log.warning('scoreboard | Failed to cache user scores locally: $cacheError');
        }
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for user scores, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getUserScores(userId, periodId);
  }

  @override
  Future<List<UserScore>> getUserScoresByType(
    String userId,
    String periodId,
    String measureType,
  ) async {
    return _localDataSource.getUserScoresByType(userId, periodId, measureType);
  }

  @override
  Future<List<UserScore>> getUserScoresForCurrentPeriods(
      String userId) async {
    // Always try remote first — scores are computed server-side by cron
    if (_connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserScoresForCurrentPeriods(userId);
        try {
          await _localDataSource.upsertUserScores(remoteData);
        } catch (cacheError) {
          _log.warning('scoreboard | Failed to cache user scores (current periods) locally: $cacheError');
        }
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for user scores (current periods), falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getUserScoresForCurrentPeriods(userId);
  }

  // ============================================
  // PERIOD SUMMARY & LEADERBOARD
  // ============================================

  @override
  Future<PeriodSummary?> getUserPeriodSummary(
      String userId, String periodId) async {
    // Always try remote first — summaries are computed server-side by cron
    if (_connectivityService.isConnected) {
      try {
        final remoteData =
            await _remoteDataSource.fetchUserPeriodSummary(userId, periodId);
        if (remoteData != null) {
          try {
            await _localDataSource.upsertPeriodSummaries([remoteData]);
          } catch (cacheError) {
            _log.warning('scoreboard | Failed to cache user period summary locally: $cacheError');
          }
        }
        return remoteData;
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for user period summary, falling back to local: $e');
      }
    }

    // Offline or remote failed: use local cache
    return _localDataSource.getUserPeriodSummary(userId, periodId);
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
    if (_connectivityService.isConnected) {
      try {
        return await _remoteDataSource.fetchLeaderboard(periodId, limit: limit);
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for leaderboard, falling back to local: $e');
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
  Future<List<LeaderboardEntry>> getLeaderboardWithFilters(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
    String? searchQuery,
    int limit = 100,
  }) async {
    // Always try remote for leaderboard as it needs to be current
    if (_connectivityService.isConnected) {
      try {
        return await _remoteDataSource.fetchLeaderboardWithFilters(
          periodId,
          branchId: branchId,
          regionalOfficeId: regionalOfficeId,
          searchQuery: searchQuery,
          limit: limit,
        );
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for filtered leaderboard, falling back to local: $e');
      }
    }

    // Fallback to local data (basic leaderboard, filters not supported offline)
    final localData = await _localDataSource.getLeaderboard(periodId, limit: limit);
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
  Future<List<LeaderboardEntry>> getFilteredLeaderboardRpc(
    String periodId, {
    String? role,
    String? branchId,
    String? regionalOfficeId,
  }) async {
    final isOnline = _connectivityService.isConnected;
    if (isOnline) {
      try {
        return await _remoteDataSource.fetchFilteredLeaderboardRpc(
          periodId,
          role: role,
          branchId: branchId,
          regionalOfficeId: regionalOfficeId,
        );
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for filtered leaderboard RPC, falling back to local: $e');
      }
    }
    // Offline fallback: use existing filter method (no dynamic ranking)
    return getLeaderboardWithFilters(
      periodId,
      branchId: branchId,
      regionalOfficeId: regionalOfficeId,
    );
  }

  @override
  Future<TeamSummary?> getTeamSummary(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
  }) async {
    // Always try remote for team summary as it needs to be current
    if (_connectivityService.isConnected) {
      try {
        return await _remoteDataSource.fetchTeamSummary(
          periodId,
          branchId: branchId,
          regionalOfficeId: regionalOfficeId,
        );
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for team summary: $e');
        return null;
      }
    }
    return null;
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
    if (_connectivityService.isConnected) {
      try {
        return await _remoteDataSource.fetchDashboardStats(userId);
      } catch (e) {
        _log.warning('scoreboard | Remote fetch failed for dashboard stats, falling back to local: $e');
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
    if (!_connectivityService.isConnected) return;

    await syncMeasureDefinitions();
    await syncScoringPeriods();
  }

  @override
  Future<void> syncMeasureDefinitions() async {
    if (!_connectivityService.isConnected) return;

    try {
      final remoteData = await _remoteDataSource.fetchMeasureDefinitions();
      await _localDataSource.upsertMeasureDefinitions(remoteData);
    } catch (e) {
      _log.error('scoreboard | Failed to sync measure definitions: $e');
    }
  }

  @override
  Future<void> syncScoringPeriods() async {
    if (!_connectivityService.isConnected) return;

    try {
      final remoteData = await _remoteDataSource.fetchScoringPeriods();
      await _localDataSource.upsertScoringPeriods(remoteData);
    } catch (e) {
      _log.error('scoreboard | Failed to sync scoring periods: $e');
    }
  }

  @override
  Future<void> syncUserScores(String userId) async {
    if (!_connectivityService.isConnected) return;

    // Ensure FK dependencies (measure_definitions, scoring_periods) exist locally
    await syncScoringData();

    // Fetch all current periods (one per period_type)
    final currentPeriods = await _remoteDataSource.fetchAllCurrentPeriods();
    if (currentPeriods.isEmpty) return;

    try {
      // Sync targets, scores, and summary for each current period
      for (final period in currentPeriods) {
        final targets =
            await _remoteDataSource.fetchUserTargets(userId, period.id);
        await _localDataSource.upsertUserTargets(targets);

        final scores =
            await _remoteDataSource.fetchUserScores(userId, period.id);
        await _localDataSource.upsertUserScores(scores);

        final summary = await _remoteDataSource.fetchUserPeriodSummary(
            userId, period.id);
        if (summary != null) {
          await _localDataSource.upsertPeriodSummaries([summary]);
        }
      }
    } catch (e) {
      _log.error('scoreboard | Failed to sync user scores: $e');
    }
  }
}
