import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/scoring_entities.dart';
import '../scoreboard_providers.dart';
import '../auth_providers.dart';

part 'admin_scoring_summary_providers.g.dart';

/// Data model for a scoring summary row (one per user).
class ScoringSummaryRow {
  final String userId;
  final String userName;
  final String role;
  final String? branchName;
  final double totalScore;
  final double leadScore;
  final double lagScore;
  final int? rank;
  final Map<String, ScoringSummaryCell> measureCells;

  const ScoringSummaryRow({
    required this.userId,
    required this.userName,
    required this.role,
    this.branchName,
    required this.totalScore,
    required this.leadScore,
    required this.lagScore,
    this.rank,
    required this.measureCells,
  });
}

/// Data for a single cell in the scoring summary grid.
class ScoringSummaryCell {
  final double actualValue;
  final double percentage;
  final double score;

  const ScoringSummaryCell({
    required this.actualValue,
    required this.percentage,
    required this.score,
  });
}

/// State for the scoring summary screen.
class ScoringSummaryState {
  final List<ScoringSummaryRow> rows;
  final List<MeasureDefinition> measures;
  final ScoringPeriod? selectedPeriod;
  final bool isLoading;
  final String? error;

  const ScoringSummaryState({
    this.rows = const [],
    this.measures = const [],
    this.selectedPeriod,
    this.isLoading = false,
    this.error,
  });
}

/// Provider for scoring summary grid data.
@riverpod
class ScoringSummaryNotifier extends _$ScoringSummaryNotifier {
  /// Track the user-selected period. Null means "use server's current period".
  ScoringPeriod? _selectedPeriod;

  @override
  Future<ScoringSummaryState> build() async {
    final remoteDS = ref.watch(scoreboardRemoteDataSourceProvider);
    final currentUser = await ref.watch(currentUserProvider.future);

    if (currentUser == null) {
      return const ScoringSummaryState(error: 'User not found');
    }

    try {
      // Get measures for columns
      final measures = await remoteDS.fetchMeasureDefinitions();

      // Use selected period if set, otherwise fetch current from server
      ScoringPeriod? activePeriod = _selectedPeriod;
      if (activePeriod == null) {
        activePeriod = await remoteDS.fetchCurrentPeriod();
        if (activePeriod == null) {
          return ScoringSummaryState(
            measures: measures,
            error: 'Tidak ada periode aktif',
          );
        }
      }

      // Determine if user is admin or manager
      final isAdmin = currentUser.isAdmin;
      final supervisorId = isAdmin ? null : currentUser.id;

      // Fetch grid data
      final rawData = await remoteDS.fetchScoringSummaryData(
        activePeriod.id,
        supervisorUserId: supervisorId,
      );

      // Map to ScoringSummaryRow
      final rows = rawData.map((row) {
        final measureCellsRaw =
            row['measure_cells'] as Map<String, Map<String, dynamic>>;
        final measureCells = measureCellsRaw.map((measureId, cell) {
          return MapEntry(
            measureId,
            ScoringSummaryCell(
              actualValue: cell['actual_value'] as double,
              percentage: cell['percentage'] as double,
              score: cell['score'] as double,
            ),
          );
        });

        return ScoringSummaryRow(
          userId: row['user_id'] as String,
          userName: row['user_name'] as String,
          role: row['role'] as String,
          branchName: row['branch_name'] as String?,
          totalScore: row['total_score'] as double,
          leadScore: row['lead_score'] as double,
          lagScore: row['lag_score'] as double,
          rank: row['rank'] as int?,
          measureCells: measureCells,
        );
      }).toList();

      return ScoringSummaryState(
        rows: rows,
        measures: measures,
        selectedPeriod: activePeriod,
      );
    } catch (e) {
      return ScoringSummaryState(error: e.toString());
    }
  }

  /// Change selected period and reload data.
  Future<void> selectPeriod(ScoringPeriod period) async {
    _selectedPeriod = period;
    ref.invalidateSelf();
  }

  /// Select "Periode Aktif" — reset to null so build() resolves to current period.
  Future<void> selectActivePeriods() async {
    _selectedPeriod = null;
    ref.invalidateSelf();
  }

  /// Refresh data (re-fetches with current period selection preserved).
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
