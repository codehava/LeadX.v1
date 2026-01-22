import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/scoring_entities.dart';

/// Remote data source for 4DX scoring data from Supabase.
class ScoreboardRemoteDataSource {
  final SupabaseClient _supabase;

  ScoreboardRemoteDataSource(this._supabase);

  // ============================================
  // MEASURE DEFINITIONS
  // ============================================

  /// Fetch all active measure definitions.
  Future<List<MeasureDefinition>> fetchMeasureDefinitions() async {
    final response = await _supabase
        .from('measure_definitions')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return (response as List)
        .map((json) => _mapToMeasureDefinition(json))
        .toList();
  }

  // ============================================
  // SCORING PERIODS
  // ============================================

  /// Fetch all scoring periods.
  Future<List<ScoringPeriod>> fetchScoringPeriods() async {
    final response = await _supabase
        .from('scoring_periods')
        .select()
        .order('start_date', ascending: false);

    return (response as List)
        .map((json) => _mapToScoringPeriod(json))
        .toList();
  }

  /// Fetch the current scoring period.
  Future<ScoringPeriod?> fetchCurrentPeriod() async {
    final response = await _supabase
        .from('scoring_periods')
        .select()
        .eq('is_current', true)
        .maybeSingle();

    if (response == null) return null;
    return _mapToScoringPeriod(response);
  }

  // ============================================
  // USER TARGETS
  // ============================================

  /// Fetch user targets for a specific period.
  Future<List<UserTarget>> fetchUserTargets(
      String userId, String periodId) async {
    final response = await _supabase
        .from('user_targets')
        .select('''
          *,
          measure_definitions!inner(name, measure_type, unit)
        ''')
        .eq('user_id', userId)
        .eq('period_id', periodId);

    return (response as List).map((json) {
      final measure = json['measure_definitions'];
      return UserTarget(
        id: json['id'],
        userId: json['user_id'],
        measureId: json['measure_id'],
        periodId: json['period_id'],
        targetValue: (json['target_value'] as num).toDouble(),
        assignedBy: json['assigned_by'],
        createdAt: json['assigned_at'] != null
            ? DateTime.parse(json['assigned_at'])
            : null,
        measureName: measure?['name'],
        measureType: measure?['measure_type'],
        measureUnit: measure?['unit'],
      );
    }).toList();
  }

  // ============================================
  // USER SCORES
  // ============================================

  /// Fetch user scores for a specific period.
  Future<List<UserScore>> fetchUserScores(
      String userId, String periodId) async {
    final response = await _supabase
        .from('user_scores')
        .select('''
          *,
          measure_definitions!inner(name, measure_type, unit, sort_order)
        ''')
        .eq('user_id', userId)
        .eq('period_id', periodId);

    return (response as List).map((json) {
      final measure = json['measure_definitions'];
      return UserScore(
        id: json['id'],
        userId: json['user_id'],
        measureId: json['measure_id'],
        periodId: json['period_id'],
        actualValue: (json['actual_value'] as num).toDouble(),
        targetValue: (measure?['target_value'] as num?)?.toDouble() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble(),
        calculatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        measureName: measure?['name'],
        measureType: measure?['measure_type'],
        measureUnit: measure?['unit'],
        sortOrder: measure?['sort_order'] ?? 0,
      );
    }).toList();
  }

  // ============================================
  // PERIOD SUMMARY SCORES
  // ============================================

  /// Fetch user's period summary.
  Future<PeriodSummary?> fetchUserPeriodSummary(
      String userId, String periodId) async {
    final response = await _supabase
        .from('user_score_snapshots')
        .select('''
          *,
          users!inner(name),
          scoring_periods!inner(name)
        ''')
        .eq('user_id', userId)
        .eq('period_id', periodId)
        .order('snapshot_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return _mapToPeriodSummaryFromSnapshot(response);
  }

  /// Fetch leaderboard for a period.
  Future<List<LeaderboardEntry>> fetchLeaderboard(
    String periodId, {
    int limit = 10,
  }) async {
    final response = await _supabase
        .from('user_score_snapshots')
        .select('''
          *,
          users!inner(id, name, branch_id, branches(name))
        ''')
        .eq('period_id', periodId)
        .order('rank')
        .limit(limit);

    return (response as List).map((json) {
      final user = json['users'];
      final branch = user?['branches'];
      return LeaderboardEntry(
        id: json['id'],
        rank: (json['rank'] ?? 0).toString(),
        userId: user?['id'] ?? '',
        userName: user?['name'] ?? 'Unknown',
        score: (json['total_score'] as num?)?.toDouble() ?? 0,
        leadScore: (json['lead_score'] as num?)?.toDouble() ?? 0,
        lagScore: (json['lag_score'] as num?)?.toDouble() ?? 0,
        rankChange: null, // Would need previous period comparison
        branchName: branch?['name'],
      );
    }).toList();
  }

  /// Fetch user's rank in a period.
  Future<int?> fetchUserRank(String userId, String periodId) async {
    final summary = await fetchUserPeriodSummary(userId, periodId);
    return summary?.rank;
  }

  // ============================================
  // DASHBOARD STATS
  // ============================================

  /// Fetch dashboard statistics for the current user.
  Future<DashboardStats> fetchDashboardStats(String userId) async {
    // Get current period
    final currentPeriod = await fetchCurrentPeriod();
    if (currentPeriod == null) {
      return const DashboardStats();
    }

    // Get user's period summary
    final summary =
        await fetchUserPeriodSummary(userId, currentPeriod.id);

    // Get active pipelines count
    final pipelineResponse = await _supabase
        .from('pipelines')
        .select('id')
        .eq('assigned_rm_id', userId)
        .eq('is_deleted', false);

    final pipelinesCount = (pipelineResponse as List).length;

    // Get team members count for rank context
    final teamCountResponse = await _supabase
        .from('user_score_snapshots')
        .select('id')
        .eq('period_id', currentPeriod.id);

    final teamMembersCount = (teamCountResponse as List).length;

    return DashboardStats(
      activePipelinesCount: pipelinesCount,
      userScore: summary?.compositeScore,
      userRank: summary?.rank,
      totalTeamMembers: teamMembersCount,
      rankChange: summary?.rankChange,
    );
  }

  // ============================================
  // MAPPERS
  // ============================================

  MeasureDefinition _mapToMeasureDefinition(Map<String, dynamic> json) {
    return MeasureDefinition(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      measureType: json['measure_type'],
      dataType: json['unit'] ?? 'COUNT', // Map unit to dataType
      unit: json['unit'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  ScoringPeriod _mapToScoringPeriod(Map<String, dynamic> json) {
    return ScoringPeriod(
      id: json['id'],
      name: json['name'],
      periodType: json['period_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isCurrent: json['is_current'] ?? false,
      isActive: json['is_locked'] != true, // Invert is_locked to isActive
      createdAt:
          json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt:
          json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  PeriodSummary _mapToPeriodSummaryFromSnapshot(Map<String, dynamic> json) {
    final user = json['users'];
    final period = json['scoring_periods'];
    return PeriodSummary(
      id: json['id'],
      userId: json['user_id'],
      periodId: json['period_id'],
      totalLeadScore: (json['lead_score'] as num?)?.toDouble() ?? 0,
      totalLagScore: (json['lag_score'] as num?)?.toDouble() ?? 0,
      compositeScore: (json['total_score'] as num?)?.toDouble() ?? 0,
      rank: json['rank'],
      calculatedAt: json['snapshot_at'] != null
          ? DateTime.parse(json['snapshot_at'])
          : null,
      userName: user?['name'],
      periodName: period?['name'],
    );
  }
}
