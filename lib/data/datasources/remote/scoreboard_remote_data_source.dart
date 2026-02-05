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
        .map((json) => _mapToMeasureDefinition(json as Map<String, dynamic>))
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
        .map((json) => _mapToScoringPeriod(json as Map<String, dynamic>))
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
      final jsonMap = json as Map<String, dynamic>;
      final measure = jsonMap['measure_definitions'] as Map<String, dynamic>?;
      return UserTarget(
        id: jsonMap['id'] as String,
        userId: jsonMap['user_id'] as String,
        measureId: jsonMap['measure_id'] as String,
        periodId: jsonMap['period_id'] as String,
        targetValue: (jsonMap['target_value'] as num).toDouble(),
        assignedBy: jsonMap['assigned_by'] as String?,
        createdAt: jsonMap['assigned_at'] != null
            ? DateTime.parse(jsonMap['assigned_at'] as String)
            : null,
        measureName: measure?['name'] as String?,
        measureType: measure?['measure_type'] as String?,
        measureUnit: measure?['unit'] as String?,
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
      final jsonMap = json as Map<String, dynamic>;
      final measure = jsonMap['measure_definitions'] as Map<String, dynamic>?;
      return UserScore(
        id: jsonMap['id'] as String,
        userId: jsonMap['user_id'] as String,
        measureId: jsonMap['measure_id'] as String,
        periodId: jsonMap['period_id'] as String,
        actualValue: (jsonMap['actual_value'] as num).toDouble(),
        targetValue: (measure?['target_value'] as num?)?.toDouble() ?? 0,
        percentage: (jsonMap['percentage'] as num?)?.toDouble(),
        calculatedAt: jsonMap['updated_at'] != null
            ? DateTime.parse(jsonMap['updated_at'] as String)
            : null,
        measureName: measure?['name'] as String?,
        measureType: measure?['measure_type'] as String?,
        measureUnit: measure?['unit'] as String?,
        sortOrder: (measure?['sort_order'] as int?) ?? 0,
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
        .from('user_score_aggregates')
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
        .from('user_score_aggregates')
        .select('''
          *,
          users!inner(id, name, branch_id, branches(name))
        ''')
        .eq('period_id', periodId)
        .order('rank')
        .limit(limit);

    return (response as List).map((json) {
      final jsonMap = json as Map<String, dynamic>;
      final user = jsonMap['users'] as Map<String, dynamic>?;
      final branch = user?['branches'] as Map<String, dynamic>?;
      return LeaderboardEntry(
        id: jsonMap['id'] as String,
        rank: (jsonMap['rank'] as int? ?? 0).toString(),
        userId: user?['id'] as String? ?? '',
        userName: user?['name'] as String? ?? 'Unknown',
        score: (jsonMap['total_score'] as num?)?.toDouble() ?? 0,
        leadScore: (jsonMap['lead_score'] as num?)?.toDouble() ?? 0,
        lagScore: (jsonMap['lag_score'] as num?)?.toDouble() ?? 0,
        rankChange: null, // Would need previous period comparison
        branchName: branch?['name'] as String?,
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
        .from('user_score_aggregates')
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
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      measureType: json['measure_type'] as String,
      dataType: (json['unit'] as String?) ?? 'COUNT', // Map unit to dataType
      unit: json['unit'] as String?,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  ScoringPeriod _mapToScoringPeriod(Map<String, dynamic> json) {
    return ScoringPeriod(
      id: json['id'] as String,
      name: json['name'] as String,
      periodType: json['period_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isCurrent: (json['is_current'] as bool?) ?? false,
      isActive: (json['is_locked'] as bool?) != true, // Invert is_locked to isActive
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  PeriodSummary _mapToPeriodSummaryFromSnapshot(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    final period = json['scoring_periods'] as Map<String, dynamic>?;
    return PeriodSummary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      periodId: json['period_id'] as String,
      totalLeadScore: (json['lead_score'] as num?)?.toDouble() ?? 0,
      totalLagScore: (json['lag_score'] as num?)?.toDouble() ?? 0,
      compositeScore: (json['total_score'] as num?)?.toDouble() ?? 0,
      rank: json['rank'] as int?,
      calculatedAt: json['snapshot_at'] != null
          ? DateTime.parse(json['snapshot_at'] as String)
          : null,
      userName: user?['name'] as String?,
      periodName: period?['name'] as String?,
    );
  }
}
