import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/period_type_helpers.dart';
import '../../data/database/app_database.dart' show AppDatabase;
import '../../data/datasources/local/scoreboard_local_data_source.dart';
import '../../data/datasources/remote/scoreboard_remote_data_source.dart';
import '../../data/repositories/scoreboard_repository_impl.dart';
import '../../domain/entities/scoring_entities.dart';
import '../../domain/repositories/scoreboard_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

part 'scoreboard_providers.g.dart';

// ============================================
// DATA SOURCES
// ============================================

@riverpod
ScoreboardLocalDataSource scoreboardLocalDataSource(ref) {
  // ignore: argument_type_not_assignable
  final db = ref.watch(appDatabaseProvider);
  // ignore: argument_type_not_assignable
  return ScoreboardLocalDataSource(db);
}

@riverpod
ScoreboardRemoteDataSource scoreboardRemoteDataSource(ref) {
  // ignore: argument_type_not_assignable
  final supabase = ref.watch(supabaseClientProvider);
  // ignore: argument_type_not_assignable
  return ScoreboardRemoteDataSource(supabase);
}

// ============================================
// REPOSITORY
// ============================================

@riverpod
ScoreboardRepository scoreboardRepository(ref) {
  // ignore: argument_type_not_assignable
  final localDataSource = ref.watch(scoreboardLocalDataSourceProvider);
  // ignore: argument_type_not_assignable
  final remoteDataSource = ref.watch(scoreboardRemoteDataSourceProvider);
  // ignore: argument_type_not_assignable
  final connectivityService = ref.watch(connectivityServiceProvider);

  // ignore: argument_type_not_assignable
  return ScoreboardRepositoryImpl(
    // ignore: argument_type_not_assignable
    localDataSource: localDataSource,
    // ignore: argument_type_not_assignable
    remoteDataSource: remoteDataSource,
    // ignore: argument_type_not_assignable
    connectivityService: connectivityService,
  );
}

// ============================================
// SCORING PERIODS
// ============================================

/// Get all scoring periods.
@riverpod
Future<List<ScoringPeriod>> scoringPeriods(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getScoringPeriods();
}

/// Get the current scoring period.
@riverpod
Future<ScoringPeriod?> currentPeriod(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getCurrentPeriod();
}

// ============================================
// MEASURE DEFINITIONS
// ============================================

/// Get all measure definitions.
@riverpod
Future<List<MeasureDefinition>> measureDefinitions(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getMeasureDefinitions();
}

/// Get lead measure definitions.
@riverpod
Future<List<MeasureDefinition>> leadMeasures(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getMeasureDefinitionsByType('LEAD');
}

/// Get lag measure definitions.
@riverpod
Future<List<MeasureDefinition>> lagMeasures(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getMeasureDefinitionsByType('LAG');
}

// ============================================
// USER SCORES
// ============================================

/// Get user scores for a period.
@riverpod
Future<List<UserScore>> userScores(
  ref,
  String userId,
  String periodId,
) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserScores(userId, periodId);
}

/// Get user's lead scores.
@riverpod
Future<List<UserScore>> userLeadScores(
  ref,
  String userId,
  String periodId,
) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserScoresByType(userId, periodId, 'LEAD');
}

/// Get user's lag scores.
@riverpod
Future<List<UserScore>> userLagScores(
  ref,
  String userId,
  String periodId,
) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserScoresByType(userId, periodId, 'LAG');
}

// ============================================
// USER TARGETS
// ============================================

/// Get user targets for a period.
@riverpod
Future<List<UserTarget>> userTargets(
  ref,
  String userId,
  String periodId,
) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserTargets(userId, periodId);
}

// ============================================
// PERIOD SUMMARY
// ============================================

/// Get user's period summary.
@riverpod
Future<PeriodSummary?> userPeriodSummary(
  ref,
  String userId,
  String periodId,
) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserPeriodSummary(userId, periodId);
}

/// Get current user's period summary for current period.
@riverpod
Future<PeriodSummary?> currentUserPeriodSummary(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  final currentUser = await ref.watch(currentUserProvider.future);
  final currentPeriodData = await ref.watch(currentPeriodProvider.future);

  if (currentUser == null || currentPeriodData == null) return null;

  // ignore: return_of_invalid_type
  return repository.getUserPeriodSummary(currentUser.id, currentPeriodData.id);
}

// ============================================
// LEADERBOARD
// ============================================

/// Get leaderboard for a period.
@riverpod
Future<List<LeaderboardEntry>> leaderboard(
  ref,
  String periodId, {
  int limit = 10,
}) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getLeaderboard(periodId, limit: limit);
}

/// Get leaderboard for current period.
@riverpod
Future<List<LeaderboardEntry>> currentPeriodLeaderboard(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  final currentPeriodData = await ref.watch(currentPeriodProvider.future);

  if (currentPeriodData == null) return [];

  // ignore: return_of_invalid_type
  return repository.getLeaderboard(currentPeriodData.id);
}

// ============================================
// DASHBOARD STATS
// ============================================

/// Get dashboard statistics for current user.
@riverpod
Future<DashboardStats> dashboardStats(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) {
    return const DashboardStats();
  }

  // ignore: return_of_invalid_type
  return repository.getDashboardStats(currentUser.id);
}

// ============================================
// SCOREBOARD NOTIFIER
// ============================================

/// Scores grouped by period type for the multi-period view.
class PeriodSection {
  final ScoringPeriod period;
  final List<UserScore> leadScores;
  final List<UserScore> lagScores;

  const PeriodSection({
    required this.period,
    this.leadScores = const [],
    this.lagScores = const [],
  });

  /// Whether this section has any scores to display.
  bool get hasScores => leadScores.isNotEmpty || lagScores.isNotEmpty;

  /// Average percentage across all scores in this section.
  double get sectionScore {
    final allScores = [...leadScores, ...lagScores];
    if (allScores.isEmpty) return 0;
    final totalPct = allScores.fold<double>(
      0, (sum, s) => sum + s.calculatedPercentage);
    return totalPct / allScores.length;
  }
}

/// State for the scoreboard screen.
class ScoreboardState {
  final ScoringPeriod? selectedPeriod;
  final List<ScoringPeriod> periods;
  final List<PeriodSection> periodSections;
  final bool isMultiPeriodView;
  final PeriodSummary? userSummary;
  final List<UserScore> leadScores;
  final List<UserScore> lagScores;
  final List<LeaderboardEntry> leaderboard;
  final bool isLoading;
  final String? error;

  const ScoreboardState({
    this.selectedPeriod,
    this.periods = const [],
    this.periodSections = const [],
    this.isMultiPeriodView = false,
    this.userSummary,
    this.leadScores = const [],
    this.lagScores = const [],
    this.leaderboard = const [],
    this.isLoading = false,
    this.error,
  });

  ScoreboardState copyWith({
    ScoringPeriod? selectedPeriod,
    bool clearSelectedPeriod = false,
    List<ScoringPeriod>? periods,
    List<PeriodSection>? periodSections,
    bool? isMultiPeriodView,
    PeriodSummary? userSummary,
    List<UserScore>? leadScores,
    List<UserScore>? lagScores,
    List<LeaderboardEntry>? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return ScoreboardState(
      selectedPeriod: clearSelectedPeriod
          ? null
          : (selectedPeriod ?? this.selectedPeriod),
      periods: periods ?? this.periods,
      periodSections: periodSections ?? this.periodSections,
      isMultiPeriodView: isMultiPeriodView ?? this.isMultiPeriodView,
      userSummary: userSummary ?? this.userSummary,
      leadScores: leadScores ?? this.leadScores,
      lagScores: lagScores ?? this.lagScores,
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class ScoreboardNotifier extends _$ScoreboardNotifier {
  @override
  Future<ScoreboardState> build() async {
    final repository = ref.watch(scoreboardRepositoryProvider);
    final currentUser = await ref.watch(currentUserProvider.future);

    if (currentUser == null) {
      return const ScoreboardState(error: 'User not found');
    }

    try {
      final periods = await repository.getScoringPeriods();
      final displayPeriod = await repository.getCurrentPeriod();

      if (displayPeriod == null) {
        return ScoreboardState(periods: periods, error: 'No active period');
      }

      final multiPeriodState = await _loadMultiPeriodView(
        repository, currentUser.id, displayPeriod);

      return multiPeriodState.copyWith(
        clearSelectedPeriod: true, // null = "Periode Berjalan"
        periods: periods,
      );
    } catch (e) {
      return ScoreboardState(error: e.toString());
    }
  }

  /// Load multi-period (aggregate) view data. Returns a ScoreboardState with
  /// isMultiPeriodView=true and selectedPeriod=displayPeriod (caller may clear it).
  Future<ScoreboardState> _loadMultiPeriodView(
    ScoreboardRepository repository,
    String userId,
    ScoringPeriod displayPeriod,
  ) async {
    final userSummary = await repository.getUserPeriodSummary(
      userId, displayPeriod.id);
    final leaderboardData = await repository.getLeaderboard(displayPeriod.id);

    final currentPeriods = await repository.getAllCurrentPeriods();
    final allScores =
        await repository.getUserScoresForCurrentPeriods(userId);

    final periodSections =
        _buildPeriodSections(allScores, currentPeriods, displayPeriod);

    final leadScores =
        allScores.where((s) => s.measureType == 'LEAD').toList();
    final lagScores =
        allScores.where((s) => s.measureType == 'LAG').toList();

    return ScoreboardState(
      selectedPeriod: displayPeriod,
      periodSections: periodSections,
      isMultiPeriodView: true,
      userSummary: userSummary,
      leadScores: leadScores,
      lagScores: lagScores,
      leaderboard: leaderboardData,
    );
  }

  /// Build period sections grouped by period type from current periods.
  List<PeriodSection> _buildPeriodSections(
    List<UserScore> allScores,
    List<ScoringPeriod> currentPeriods,
    ScoringPeriod displayPeriod,
  ) {
    // Map periodId → periodType from current periods
    final periodIdToType = <String, String>{};
    final periodIdToPeriod = <String, ScoringPeriod>{};
    for (final p in currentPeriods) {
      periodIdToType[p.id] = p.periodType;
      periodIdToPeriod[p.id] = p;
    }

    // Group scores by period type
    final scoresByType = <String, List<UserScore>>{};
    for (final score in allScores) {
      final periodType =
          periodIdToType[score.periodId] ?? displayPeriod.periodType;
      scoresByType.putIfAbsent(periodType, () => []).add(score);
    }

    // Build sections, skip empty ones
    final sections = <PeriodSection>[];
    for (final entry in scoresByType.entries) {
      final periodType = entry.key;
      final scores = entry.value;

      // Find the matching current period for this type
      final period = currentPeriods.firstWhere(
        (p) => p.periodType == periodType,
        orElse: () => displayPeriod,
      );

      final leadScores =
          scores.where((s) => s.measureType == 'LEAD').toList();
      final lagScores =
          scores.where((s) => s.measureType == 'LAG').toList();

      if (leadScores.isNotEmpty || lagScores.isNotEmpty) {
        sections.add(PeriodSection(
          period: period,
          leadScores: leadScores,
          lagScores: lagScores,
        ));
      }
    }

    // Sort by period type priority (WEEKLY first)
    sections.sort((a, b) => periodTypePriority(a.period.periodType)
        .compareTo(periodTypePriority(b.period.periodType)));

    return sections;
  }

  /// Switch to "Periode Berjalan" (multi-period aggregate) view.
  Future<void> selectRunningPeriods() async {
    final repository = ref.read(scoreboardRepositoryProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) return;

    state = AsyncData(state.valueOrNull?.copyWith(isLoading: true) ??
        const ScoreboardState(isLoading: true));

    try {
      final displayPeriod = await repository.getCurrentPeriod();
      if (displayPeriod == null) return;

      final multiPeriodState = await _loadMultiPeriodView(
        repository, currentUser.id, displayPeriod);

      state = AsyncData(multiPeriodState.copyWith(
        clearSelectedPeriod: true, // null = "Periode Berjalan"
        periods: state.valueOrNull?.periods ?? [],
      ));
    } catch (e) {
      state = AsyncData(state.valueOrNull?.copyWith(
            isLoading: false,
            error: e.toString(),
          ) ??
          ScoreboardState(error: e.toString()));
    }
  }

  /// Change the selected period to a specific historical or individual period.
  Future<void> selectPeriod(ScoringPeriod period) async {
    final repository = ref.read(scoreboardRepositoryProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) return;

    state = AsyncData(state.valueOrNull?.copyWith(isLoading: true) ??
        const ScoreboardState(isLoading: true));

    try {
      final userSummary = await repository.getUserPeriodSummary(
        currentUser.id,
        period.id,
      );

      final leaderboardData = await repository.getLeaderboard(period.id);

      // For historical periods, show flat lead/lag view
      final leadScores = await repository.getUserScoresByType(
        currentUser.id,
        period.id,
        'LEAD',
      );
      final lagScores = await repository.getUserScoresByType(
        currentUser.id,
        period.id,
        'LAG',
      );

      state = AsyncData(ScoreboardState(
        selectedPeriod: period,
        periods: state.valueOrNull?.periods ?? [],
        periodSections: const [],
        isMultiPeriodView: false,
        userSummary: userSummary,
        leadScores: leadScores,
        lagScores: lagScores,
        leaderboard: leaderboardData,
      ));
    } catch (e) {
      state = AsyncData(state.valueOrNull?.copyWith(
            isLoading: false,
            error: e.toString(),
          ) ??
          ScoreboardState(error: e.toString()));
    }
  }

  /// Refresh scoreboard data.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ============================================
// ALL CURRENT PERIODS
// ============================================

/// Get all current periods (one per period_type).
@riverpod
Future<List<ScoringPeriod>> allCurrentPeriods(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getAllCurrentPeriods();
}

// ============================================
// SCORE UPDATE PENDING
// ============================================

/// Check if any pending sync queue items exist for scoring-relevant entities.
/// Shows "score update pending" hint on scoreboard when true.
@riverpod
Stream<bool> isScoreUpdatePending(ref) {
  // ignore: argument_type_not_assignable
  final db = ref.watch(appDatabaseProvider) as AppDatabase;
  // Watch sync queue for pending items that affect scoring
  // Separate where() calls are AND-ed by Drift; avoids needing drift import for & operator
  final query = db.select(db.syncQueueItems);
  query.where((t) => t.entityType.isIn(['activity', 'pipeline', 'customer']));
  query.where((t) => t.status.equals('pending'));
  // ignore: return_of_invalid_type
  return query.watch().map((items) => items.isNotEmpty);
}

// ============================================
// LEADERBOARD FILTER
// ============================================

/// Filter mode for leaderboard.
enum LeaderboardFilterMode {
  all,
  branch,
  region,
}

/// State for leaderboard filters.
class LeaderboardFilter {
  final ScoringPeriod? selectedPeriod;
  final LeaderboardFilterMode filterMode;
  final String? selectedBranchId;
  final String? selectedRegionalOfficeId;
  final String? selectedRole;
  final String searchQuery;

  const LeaderboardFilter({
    this.selectedPeriod,
    this.filterMode = LeaderboardFilterMode.all,
    this.selectedBranchId,
    this.selectedRegionalOfficeId,
    this.selectedRole,
    this.searchQuery = '',
  });

  LeaderboardFilter copyWith({
    ScoringPeriod? selectedPeriod,
    bool clearSelectedPeriod = false,
    LeaderboardFilterMode? filterMode,
    String? selectedBranchId,
    String? selectedRegionalOfficeId,
    String? selectedRole,
    String? searchQuery,
    bool clearRole = false,
  }) {
    return LeaderboardFilter(
      selectedPeriod: clearSelectedPeriod
          ? null
          : (selectedPeriod ?? this.selectedPeriod),
      filterMode: filterMode ?? this.filterMode,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      selectedRegionalOfficeId:
          selectedRegionalOfficeId ?? this.selectedRegionalOfficeId,
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for managing leaderboard filter state.
@riverpod
class LeaderboardFilterNotifier extends _$LeaderboardFilterNotifier {
  @override
  LeaderboardFilter build() => const LeaderboardFilter();

  /// Select a specific period.
  void selectPeriod(ScoringPeriod period) {
    state = state.copyWith(selectedPeriod: period);
  }

  /// Select "Periode Berjalan" (null = resolve to display period for query).
  void selectRunningPeriods() {
    state = state.copyWith(clearSelectedPeriod: true);
  }

  /// Set filter mode and update corresponding IDs.
  Future<void> setFilterMode(LeaderboardFilterMode mode) async {
    if (mode == LeaderboardFilterMode.branch) {
      // Get user's branch
      final user = await ref.read(currentUserProvider.future);
      state = state.copyWith(
        filterMode: mode,
        selectedBranchId: user?.branchId,
        selectedRegionalOfficeId: null,
      );
    } else if (mode == LeaderboardFilterMode.region) {
      // Get user's region
      final user = await ref.read(currentUserProvider.future);
      state = state.copyWith(
        filterMode: mode,
        selectedBranchId: null,
        selectedRegionalOfficeId: user?.regionalOfficeId,
      );
    } else {
      state = state.copyWith(
        filterMode: mode,
        selectedBranchId: null,
        selectedRegionalOfficeId: null,
      );
    }
  }

  /// Set role filter.
  void setRole(String? role) {
    state = state.copyWith(selectedRole: role, clearRole: role == null);
  }

  /// Set search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Reset filters to default.
  void reset() {
    state = const LeaderboardFilter();
  }
}

/// Get filtered leaderboard based on current filter state.
@riverpod
Future<List<LeaderboardEntry>> filteredLeaderboard(
  ref,
  String periodId, {
  String? branchId,
  String? regionalOfficeId,
  String? searchQuery,
  String? role,
}) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);

  // Use RPC method when role filter is active for dynamic ranking
  if (role != null) {
    // ignore: return_of_invalid_type
    return repository.getFilteredLeaderboardRpc(
      periodId,
      role: role,
      branchId: branchId,
      regionalOfficeId: regionalOfficeId,
    );
  }

  // Existing behavior for non-role filters
  // ignore: return_of_invalid_type
  return repository.getLeaderboardWithFilters(
    periodId,
    branchId: branchId,
    regionalOfficeId: regionalOfficeId,
    searchQuery: searchQuery,
    limit: 100,
  );
}

/// Get team summary for branch or region.
@riverpod
Future<TeamSummary?> teamSummary(
  ref,
  String periodId, {
  String? branchId,
  String? regionalOfficeId,
}) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getTeamSummary(
    periodId,
    branchId: branchId,
    regionalOfficeId: regionalOfficeId,
  );
}
