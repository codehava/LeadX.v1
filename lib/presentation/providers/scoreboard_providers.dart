import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/local/scoreboard_local_data_source.dart';
import '../../data/datasources/remote/scoreboard_remote_data_source.dart';
import '../../data/repositories/scoreboard_repository_impl.dart';
import '../../data/services/connectivity_service.dart';
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

/// State for the scoreboard screen.
class ScoreboardState {
  final ScoringPeriod? selectedPeriod;
  final List<ScoringPeriod> periods;
  final PeriodSummary? userSummary;
  final List<UserScore> leadScores;
  final List<UserScore> lagScores;
  final List<LeaderboardEntry> leaderboard;
  final bool isLoading;
  final String? error;

  const ScoreboardState({
    this.selectedPeriod,
    this.periods = const [],
    this.userSummary,
    this.leadScores = const [],
    this.lagScores = const [],
    this.leaderboard = const [],
    this.isLoading = false,
    this.error,
  });

  ScoreboardState copyWith({
    ScoringPeriod? selectedPeriod,
    List<ScoringPeriod>? periods,
    PeriodSummary? userSummary,
    List<UserScore>? leadScores,
    List<UserScore>? lagScores,
    List<LeaderboardEntry>? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return ScoreboardState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      periods: periods ?? this.periods,
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
      // Load periods
      final periods = await repository.getScoringPeriods();
      final currentPeriodData = await repository.getCurrentPeriod();

      if (currentPeriodData == null) {
        return ScoreboardState(periods: periods, error: 'No active period');
      }

      // Load scores and leaderboard for current period
      final userSummary = await repository.getUserPeriodSummary(
        currentUser.id,
        currentPeriodData.id,
      );
      final leadScores = await repository.getUserScoresByType(
        currentUser.id,
        currentPeriodData.id,
        'LEAD',
      );
      final lagScores = await repository.getUserScoresByType(
        currentUser.id,
        currentPeriodData.id,
        'LAG',
      );
      final leaderboardData =
          await repository.getLeaderboard(currentPeriodData.id);

      return ScoreboardState(
        selectedPeriod: currentPeriodData,
        periods: periods,
        userSummary: userSummary,
        leadScores: leadScores,
        lagScores: lagScores,
        leaderboard: leaderboardData,
      );
    } catch (e) {
      return ScoreboardState(error: e.toString());
    }
  }

  /// Change the selected period.
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
      final leaderboardData = await repository.getLeaderboard(period.id);

      state = AsyncData(ScoreboardState(
        selectedPeriod: period,
        periods: state.valueOrNull?.periods ?? [],
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
  final String searchQuery;

  const LeaderboardFilter({
    this.selectedPeriod,
    this.filterMode = LeaderboardFilterMode.all,
    this.selectedBranchId,
    this.selectedRegionalOfficeId,
    this.searchQuery = '',
  });

  LeaderboardFilter copyWith({
    ScoringPeriod? selectedPeriod,
    LeaderboardFilterMode? filterMode,
    String? selectedBranchId,
    String? selectedRegionalOfficeId,
    String? searchQuery,
  }) {
    return LeaderboardFilter(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      filterMode: filterMode ?? this.filterMode,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      selectedRegionalOfficeId:
          selectedRegionalOfficeId ?? this.selectedRegionalOfficeId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for managing leaderboard filter state.
@riverpod
class LeaderboardFilterNotifier extends _$LeaderboardFilterNotifier {
  @override
  LeaderboardFilter build() => const LeaderboardFilter();

  /// Select a period.
  void selectPeriod(ScoringPeriod period) {
    state = state.copyWith(selectedPeriod: period);
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
}) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(scoreboardRepositoryProvider);
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
