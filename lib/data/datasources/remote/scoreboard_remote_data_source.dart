import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/date_time_utils.dart';
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

  /// Fetch all measure definitions (including inactive) for admin.
  Future<List<MeasureDefinition>> fetchAllMeasureDefinitions() async {
    final response = await _supabase
        .from('measure_definitions')
        .select()
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

  /// Fetch the current display period (shortest granularity among current periods).
  Future<ScoringPeriod?> fetchCurrentPeriod() async {
    final response = await _supabase
        .from('scoring_periods')
        .select()
        .eq('is_current', true);

    final periods = (response as List)
        .map((json) => _mapToScoringPeriod(json as Map<String, dynamic>))
        .toList();

    if (periods.isEmpty) return null;

    // Sort by granularity priority: WEEKLY < MONTHLY < QUARTERLY < YEARLY
    periods.sort((a, b) =>
        _periodTypePriority(a.periodType)
            .compareTo(_periodTypePriority(b.periodType)));

    return periods.first;
  }

  /// Fetch all current periods (one per period_type).
  Future<List<ScoringPeriod>> fetchAllCurrentPeriods() async {
    final response = await _supabase
        .from('scoring_periods')
        .select()
        .eq('is_current', true);

    return (response as List)
        .map((json) => _mapToScoringPeriod(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch user scores across all current periods.
  ///
  /// Returns scores where period_id matches any current period,
  /// joined with measure_definitions for name/type/unit.
  Future<List<UserScore>> fetchUserScoresForCurrentPeriods(
      String userId) async {
    // First get all current period IDs
    final currentPeriods = await fetchAllCurrentPeriods();
    if (currentPeriods.isEmpty) return [];

    final periodIds = currentPeriods.map((p) => p.id).toList();

    // Only fetch scores for measures the user is assigned to
    final assignedMeasureIds =
        await _getAssignedMeasureIds(userId, periodIds);
    if (assignedMeasureIds.isEmpty) return [];

    final response = await _supabase
        .from('user_scores')
        .select('''
          *,
          measure_definitions!inner(name, measure_type, unit, sort_order)
        ''')
        .eq('user_id', userId)
        .inFilter('period_id', periodIds)
        .inFilter('measure_id', assignedMeasureIds.toList());

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
        targetValue: (jsonMap['target_value'] as num?)?.toDouble() ?? 0,
        assignedBy: jsonMap['assigned_by'] as String?,
        createdAt: jsonMap['assigned_at'] != null
            ? DateTime.parse(jsonMap['assigned_at'] as String)
            : null,
        updatedAt: jsonMap['updated_at'] != null
            ? DateTime.parse(jsonMap['updated_at'] as String)
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
    // Only fetch scores for measures the user is assigned to
    final assignedMeasureIds =
        await _getAssignedMeasureIds(userId, [periodId]);
    if (assignedMeasureIds.isEmpty) return [];

    final response = await _supabase
        .from('user_scores')
        .select('''
          *,
          measure_definitions!inner(name, measure_type, unit, sort_order)
        ''')
        .eq('user_id', userId)
        .eq('period_id', periodId)
        .inFilter('measure_id', assignedMeasureIds.toList());

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
        .order('calculated_at', ascending: false)
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
        rankChange: jsonMap['rank_change'] as int?,
        branchName: branch?['name'] as String?,
      );
    }).toList();
  }

  /// Fetch leaderboard with filters for dedicated leaderboard screen.
  Future<List<LeaderboardEntry>> fetchLeaderboardWithFilters(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
    String? searchQuery,
    int limit = 100,
  }) async {
    dynamic query = _supabase
        .from('user_score_aggregates')
        .select('''
          *,
          users!inner(id, name, branch_id, regional_office_id, branches(name))
        ''')
        .eq('period_id', periodId);

    // Apply filters
    if (branchId != null) {
      query = query.eq('users.branch_id', branchId);
    }
    if (regionalOfficeId != null) {
      query = query.eq('users.regional_office_id', regionalOfficeId);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('users.name', '%${searchQuery.trim()}%');
    }

    query = query.order('rank').limit(limit);

    final response = await query;

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
        rankChange: jsonMap['rank_change'] as int?,
        branchName: branch?['name'] as String?,
      );
    }).toList();
  }

  /// Fetch leaderboard via RPC with dynamic ranking within filter context.
  Future<List<LeaderboardEntry>> fetchFilteredLeaderboardRpc(
    String periodId, {
    String? role,
    String? branchId,
    String? regionalOfficeId,
  }) async {
    final response = await _supabase.rpc(
      'get_filtered_leaderboard',
      params: {
        'p_period_id': periodId,
        if (role != null) 'p_role': role,
        if (branchId != null) 'p_branch_id': branchId,
        if (regionalOfficeId != null) 'p_regional_office_id': regionalOfficeId,
      },
    );
    return (response as List).map((json) {
      final jsonMap = json as Map<String, dynamic>;
      return LeaderboardEntry(
        id: '${jsonMap['user_id']}_$periodId',
        rank: (jsonMap['rank'] as int? ?? 0).toString(),
        userId: jsonMap['user_id'] as String? ?? '',
        userName: jsonMap['user_name'] as String? ?? 'Unknown',
        score: (jsonMap['total_score'] as num?)?.toDouble() ?? 0,
        leadScore: (jsonMap['lead_score'] as num?)?.toDouble() ?? 0,
        lagScore: (jsonMap['lag_score'] as num?)?.toDouble() ?? 0,
        rankChange: jsonMap['rank_change'] as int?,
        branchName: jsonMap['branch_name'] as String?,
      );
    }).toList();
  }

  /// Fetch user's rank in a period.
  Future<int?> fetchUserRank(String userId, String periodId) async {
    final summary = await fetchUserPeriodSummary(userId, periodId);
    return summary?.rank;
  }

  // ============================================
  // TEAM SUMMARY
  // ============================================

  /// Fetch team summary for branch or region.
  Future<TeamSummary?> fetchTeamSummary(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
  }) async {
    // Query user_score_aggregates to calculate team averages
    dynamic query = _supabase
        .from('user_score_aggregates')
        .select('''
          *,
          users!inner(id, branch_id, regional_office_id, branches(id, name))
        ''')
        .eq('period_id', periodId);

    // Apply filters
    if (branchId != null) {
      query = query.eq('users.branch_id', branchId);
    }
    if (regionalOfficeId != null) {
      query = query.eq('users.regional_office_id', regionalOfficeId);
    }

    final response = await query;
    final data = response as List;

    if (data.isEmpty) return null;

    // Calculate team aggregates
    double totalScore = 0;
    double totalLeadScore = 0;
    double totalLagScore = 0;
    final count = data.length;

    for (final entry in data) {
      final jsonMap = entry as Map<String, dynamic>;
      totalScore += (jsonMap['total_score'] as num?)?.toDouble() ?? 0;
      totalLeadScore += (jsonMap['lead_score'] as num?)?.toDouble() ?? 0;
      totalLagScore += (jsonMap['lag_score'] as num?)?.toDouble() ?? 0;
    }

    // Get branch/region name from first user
    final firstUser = data.first['users'] as Map<String, dynamic>?;
    final branch = firstUser?['branches'] as Map<String, dynamic>?;

    return TeamSummary(
      id: '${periodId}_${branchId ?? regionalOfficeId ?? 'all'}',
      periodId: periodId,
      branchId: branchId,
      regionalOfficeId: regionalOfficeId,
      branchName: branch?['name'] as String?,
      averageScore: count > 0 ? totalScore / count : 0,
      averageLeadScore: count > 0 ? totalLeadScore / count : 0,
      averageLagScore: count > 0 ? totalLagScore / count : 0,
      teamMembersCount: count,
      // TODO: Team rank and score change would require additional queries
      // to compare across teams and periods
    );
  }

  // ============================================
  // ADMIN: TARGET MANAGEMENT
  // ============================================

  /// Fetch all targets for a specific period (Admin).
  Future<List<UserTarget>> fetchTargetsForPeriod(String periodId) async {
    final response = await _supabase
        .from('user_targets')
        .select('''
          *,
          measure_definitions!inner(name, measure_type, unit),
          users!user_targets_user_id_fkey!inner(name)
        ''')
        .eq('period_id', periodId);

    return (response as List).map((json) {
      final jsonMap = json as Map<String, dynamic>;
      final measure = jsonMap['measure_definitions'] as Map<String, dynamic>?;
      return UserTarget(
        id: jsonMap['id'] as String,
        userId: jsonMap['user_id'] as String,
        measureId: jsonMap['measure_id'] as String,
        periodId: jsonMap['period_id'] as String,
        targetValue: (jsonMap['target_value'] as num?)?.toDouble() ?? 0,
        assignedBy: jsonMap['assigned_by'] as String?,
        createdAt: jsonMap['assigned_at'] != null
            ? DateTime.parse(jsonMap['assigned_at'] as String)
            : null,
        updatedAt: jsonMap['updated_at'] != null
            ? DateTime.parse(jsonMap['updated_at'] as String)
            : null,
        measureName: measure?['name'] as String?,
        measureType: measure?['measure_type'] as String?,
        measureUnit: measure?['unit'] as String?,
      );
    }).toList();
  }

  /// Upsert a single user target (Admin).
  Future<UserTarget> upsertUserTarget({
    required String userId,
    required String measureId,
    required String periodId,
    required double targetValue,
    required String assignedBy,
  }) async {
    final response = await _supabase
        .from('user_targets')
        .upsert(
          {
            'user_id': userId,
            'measure_id': measureId,
            'period_id': periodId,
            'target_value': targetValue,
            'assigned_by': assignedBy,
            'assigned_at': DateTime.now().toUtcIso8601(),
          },
          onConflict: 'user_id,measure_id,period_id',
        )
        .select('''
          *,
          measure_definitions!inner(name, measure_type, unit)
        ''')
        .single();

    final measure =
        response['measure_definitions'] as Map<String, dynamic>?;
    return UserTarget(
      id: response['id'] as String,
      userId: response['user_id'] as String,
      measureId: response['measure_id'] as String,
      periodId: response['period_id'] as String,
      targetValue: (response['target_value'] as num?)?.toDouble() ?? 0,
      assignedBy: response['assigned_by'] as String?,
      createdAt: response['assigned_at'] != null
          ? DateTime.parse(response['assigned_at'] as String)
          : null,
      updatedAt: response['updated_at'] != null
          ? DateTime.parse(response['updated_at'] as String)
          : null,
      measureName: measure?['name'] as String?,
      measureType: measure?['measure_type'] as String?,
      measureUnit: measure?['unit'] as String?,
    );
  }

  /// Bulk upsert user targets (Admin).
  ///
  /// Returns the number of rows upserted for verification.
  Future<int> bulkUpsertUserTargets({
    required String periodId,
    required String assignedBy,
    required List<Map<String, dynamic>> targets,
  }) async {
    final now = DateTime.now().toUtcIso8601();
    final rows = targets.map((t) => {
          'user_id': t['userId'],
          'measure_id': t['measureId'],
          'period_id': periodId,
          'target_value': t['targetValue'],
          'assigned_by': assignedBy,
          'assigned_at': now,
        }).toList();

    final response = await _supabase
        .from('user_targets')
        .upsert(rows, onConflict: 'user_id,measure_id,period_id')
        .select('id');

    return (response as List).length;
  }

  /// Delete a user target (Admin).
  Future<void> deleteUserTarget(String targetId) async {
    await _supabase.from('user_targets').delete().eq('id', targetId);
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
  // ADMIN: MEASURE MANAGEMENT
  // ============================================

  /// Create a new measure definition (Admin only).
  Future<MeasureDefinition> createMeasureDefinition(
      Map<String, dynamic> data) async {
    final response = await _supabase
        .from('measure_definitions')
        .insert(data)
        .select()
        .single();

    return _mapToMeasureDefinition(response);
  }

  /// Update an existing measure definition (Admin only).
  Future<MeasureDefinition> updateMeasureDefinition(
      String id, Map<String, dynamic> data) async {
    final response = await _supabase
        .from('measure_definitions')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return _mapToMeasureDefinition(response);
  }

  /// Soft delete a measure definition (Admin only).
  Future<void> deleteMeasureDefinition(String id) async {
    await _supabase
        .from('measure_definitions')
        .update({'is_active': false})
        .eq('id', id);
  }

  // ============================================
  // ADMIN: PERIOD MANAGEMENT
  // ============================================

  /// Create a new scoring period (Admin only).
  Future<ScoringPeriod> createScoringPeriod(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('scoring_periods')
        .insert(data)
        .select()
        .single();

    return _mapToScoringPeriod(response);
  }

  /// Update an existing scoring period (Admin only).
  Future<ScoringPeriod> updateScoringPeriod(
      String id, Map<String, dynamic> data) async {
    final response = await _supabase
        .from('scoring_periods')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return _mapToScoringPeriod(response);
  }

  /// Delete a scoring period (Admin only).
  Future<void> deleteScoringPeriod(String id) async {
    await _supabase.from('scoring_periods').delete().eq('id', id);
  }

  /// Lock a scoring period (Admin only).
  Future<ScoringPeriod> lockPeriod(String id) async {
    final response = await _supabase
        .from('scoring_periods')
        .update({'is_locked': true})
        .eq('id', id)
        .select()
        .single();

    return _mapToScoringPeriod(response);
  }

  /// Set a period as current (Admin only).
  ///
  /// Only unsets is_current for periods of the same period_type,
  /// allowing multiple current periods (one per type).
  Future<void> setCurrentPeriod(String id) async {
    // Fetch the target period's period_type
    final targetPeriod = await _supabase
        .from('scoring_periods')
        .select('period_type')
        .eq('id', id)
        .single();

    final periodType = targetPeriod['period_type'] as String;

    // Unset is_current only for same period_type
    await _supabase
        .from('scoring_periods')
        .update({'is_current': false})
        .eq('period_type', periodType)
        .neq('id', id);

    // Set the selected period as current
    await _supabase
        .from('scoring_periods')
        .update({'is_current': true})
        .eq('id', id);
  }

  // ============================================
  // SCORING SUMMARY (Admin/Manager Grid)
  // ============================================

  /// Fetch scoring summary data for all users (admin) or subordinates (manager).
  /// Returns a cross-join of users, measures, and their scores for a given period.
  Future<List<Map<String, dynamic>>> fetchScoringSummaryData(
    String periodId, {
    String? supervisorUserId, // If non-null, filter to subordinates only
  }) async {
    // Step 1: Get all active measure definitions (columns for the grid)
    await fetchMeasureDefinitions();

    // Step 2: Get user_score_aggregates for the period (for composite scores)
    dynamic aggregateQuery = _supabase
        .from('user_score_aggregates')
        .select(
            '*, users!inner(id, name, role, branch_id, is_active, branches(name))')
        .eq('period_id', periodId)
        .eq('users.is_active', true);

    if (supervisorUserId != null) {
      // Filter to subordinates only (manager view)
      final hierarchyResponse = await _supabase
          .from('user_hierarchy')
          .select('descendant_id')
          .eq('ancestor_id', supervisorUserId)
          .gt('depth', 0);

      final subordinateIds = (hierarchyResponse as List)
          .map((h) => (h as Map<String, dynamic>)['descendant_id'] as String)
          .toList();

      if (subordinateIds.isEmpty) return [];

      aggregateQuery = aggregateQuery.inFilter('user_id', subordinateIds);
    }

    final aggregates = await aggregateQuery;

    // Step 3: Get all user_scores for the period with measure info
    final userIds = (aggregates as List)
        .map((a) => (a as Map<String, dynamic>)['user_id'] as String)
        .toList();

    if (userIds.isEmpty) return [];

    final scoresResponse = await _supabase
        .from('user_scores')
        .select('user_id, measure_id, actual_value, percentage, score')
        .eq('period_id', periodId)
        .inFilter('user_id', userIds);

    // For multi-period: also fetch scores from other current periods
    final allCurrentPeriods = await fetchAllCurrentPeriods();
    final otherPeriodIds = allCurrentPeriods
        .where((p) => p.id != periodId)
        .map((p) => p.id)
        .toList();

    var additionalScores = <dynamic>[];
    if (otherPeriodIds.isNotEmpty) {
      additionalScores = await _supabase
          .from('user_scores')
          .select('user_id, measure_id, actual_value, percentage, score')
          .inFilter('period_id', otherPeriodIds)
          .inFilter('user_id', userIds);
    }

    // Combine all scores
    final allScores = [...(scoresResponse as List), ...additionalScores];

    // Step 4: Build the grid data structure
    final rows = <Map<String, dynamic>>[];

    for (final aggregate in aggregates) {
      final agg = aggregate as Map<String, dynamic>;
      final userId = agg['user_id'] as String;
      final user = agg['users'] as Map<String, dynamic>;
      final branch = user['branches'] as Map<String, dynamic>?;

      // Build measure cells for this user
      final measureCells = <String, Map<String, dynamic>>{};
      for (final score in allScores) {
        final s = score as Map<String, dynamic>;
        if (s['user_id'] == userId) {
          measureCells[s['measure_id'] as String] = {
            'actual_value': (s['actual_value'] as num?)?.toDouble() ?? 0,
            'percentage': (s['percentage'] as num?)?.toDouble() ?? 0,
            'score': (s['score'] as num?)?.toDouble() ?? 0,
          };
        }
      }

      rows.add({
        'user_id': userId,
        'user_name': user['name'] as String? ?? 'Unknown',
        'role': user['role'] as String? ?? '',
        'branch_name': branch?['name'] as String?,
        'total_score': (agg['total_score'] as num?)?.toDouble() ?? 0,
        'lead_score': (agg['lead_score'] as num?)?.toDouble() ?? 0,
        'lag_score': (agg['lag_score'] as num?)?.toDouble() ?? 0,
        'rank': agg['rank'] as int?,
        'measure_cells': measureCells,
      });
    }

    // Sort by rank (nulls last), then by total_score descending
    rows.sort((a, b) {
      final rankA = a['rank'] as int? ?? 9999;
      final rankB = b['rank'] as int? ?? 9999;
      if (rankA != rankB) return rankA.compareTo(rankB);
      return ((b['total_score'] as double) - (a['total_score'] as double))
          .sign
          .toInt();
    });

    return rows;
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Get the set of measure IDs assigned to a user across given periods.
  Future<Set<String>> _getAssignedMeasureIds(
      String userId, List<String> periodIds) async {
    final response = await _supabase
        .from('user_targets')
        .select('measure_id')
        .eq('user_id', userId)
        .inFilter('period_id', periodIds);
    return (response as List)
        .map((json) => (json as Map<String, dynamic>)['measure_id'] as String)
        .toSet();
  }

  // ============================================
  // MAPPERS
  // ============================================

  /// Returns priority for period type sorting (lower = shorter granularity).
  int _periodTypePriority(String periodType) {
    switch (periodType) {
      case 'WEEKLY':
        return 1;
      case 'MONTHLY':
        return 2;
      case 'QUARTERLY':
        return 3;
      case 'YEARLY':
        return 4;
      default:
        return 5;
    }
  }

  MeasureDefinition _mapToMeasureDefinition(Map<String, dynamic> json) {
    return MeasureDefinition(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      measureType: json['measure_type'] as String,
      dataType: json['data_type'] as String,
      unit: json['unit'] as String?,
      sourceTable: json['source_table'] as String?,
      sourceCondition: json['source_condition'] as String?,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      defaultTarget: (json['default_target'] as num?)?.toDouble() ?? 0,
      periodType: json['period_type'] as String?,
      templateType: json['template_type'] as String?,
      templateConfig: json['template_config'] as Map<String, dynamic>?,
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
      isLocked: (json['is_locked'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
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
      bonusPoints: (json['bonus_points'] as num?)?.toDouble() ?? 0,
      penaltyPoints: (json['penalty_points'] as num?)?.toDouble() ?? 0,
      rank: json['rank'] as int?,
      rankChange: json['rank_change'] as int?,
      calculatedAt: json['calculated_at'] != null
          ? DateTime.parse(json['calculated_at'] as String)
          : null,
      userName: user?['name'] as String?,
      periodName: period?['name'] as String?,
    );
  }
}
