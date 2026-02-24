import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/scoring_entities.dart';
import '../../../providers/admin/admin_scoring_summary_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/scoreboard_providers.dart';
import '../../../widgets/common/error_state.dart';
import '../../../widgets/scoreboard/period_selector.dart';

/// Scoring summary grid screen for admins and managers.
///
/// Shows users as rows, measures as columns, with actual/percentage per cell
/// and composite total score. Admin sees all users, managers see subordinates.
class ScoringSummaryScreen extends ConsumerStatefulWidget {
  const ScoringSummaryScreen({super.key});

  @override
  ConsumerState<ScoringSummaryScreen> createState() =>
      _ScoringSummaryScreenState();
}

class _ScoringSummaryScreenState extends ConsumerState<ScoringSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(scoringSummaryNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final periodsAsync = ref.watch(scoringPeriodsProvider);
    final isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Skor'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(scoringSummaryNotifierProvider.notifier).refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          _buildPeriodSelector(periodsAsync, summaryAsync),

          // Subtitle showing filter context
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              isAdmin ? 'Semua pengguna' : 'Tim Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          // Main content
          Expanded(
            child: summaryAsync.when(
              data: (state) {
                if (state.error != null) {
                  return AppErrorState.general(
                    title: 'Gagal memuat data',
                    message: state.error,
                    onRetry: () {
                      ref
                          .read(scoringSummaryNotifierProvider.notifier)
                          .refresh();
                    },
                  );
                }

                if (state.rows.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildGrid(context, state);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => AppErrorState.general(
                title: 'Gagal memuat data',
                message: error.toString(),
                onRetry: () {
                  ref.read(scoringSummaryNotifierProvider.notifier).refresh();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    AsyncValue<List<ScoringPeriod>> periodsAsync,
    AsyncValue<ScoringSummaryState> summaryAsync,
  ) {
    final selectedPeriod = summaryAsync.valueOrNull?.selectedPeriod;
    final currentPeriods =
        ref.watch(allCurrentPeriodsProvider).valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: periodsAsync.when(
          data: (periods) {
            if (periods.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tidak ada periode'),
              );
            }

            return PeriodSelector(
              selectedPeriod: selectedPeriod,
              allPeriods: periods,
              currentPeriods: currentPeriods,
              onChanged: (period) {
                if (period == null) {
                  ref
                      .read(scoringSummaryNotifierProvider.notifier)
                      .selectRunningPeriods();
                } else {
                  ref
                      .read(scoringSummaryNotifierProvider.notifier)
                      .selectPeriod(period);
                }
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Memuat periode...'),
          ),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Gagal memuat periode'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data skor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data skor akan muncul setelah periode penilaian dimulai.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ScoringSummaryState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final measures = state.measures;
    final rows = state.rows;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerHighest,
          ),
          columns: [
            // Rank column
            const DataColumn(
              label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // Name column
            const DataColumn(
              label:
                  Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // One column per measure
            ...measures.map((measure) => DataColumn(
                  label: Text(
                    measure.code.isNotEmpty ? measure.code : measure.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  tooltip: '${measure.name} (${measure.measureType})',
                )),
            // Total score column
            const DataColumn(
              label: Text('Total Skor',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              numeric: true,
            ),
          ],
          rows: rows.map((row) {
            return DataRow(
              cells: [
                // Rank
                DataCell(
                  Text(
                    row.rank?.toString() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                // Name and role
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        row.userName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (row.branchName != null)
                        Text(
                          row.branchName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Measure cells
                ...measures.map((measure) {
                  final cell = row.measureCells[measure.id];
                  if (cell == null) {
                    return const DataCell(
                      Text(
                        '\u2014',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return DataCell(
                    Text(
                      '${_formatNumber(cell.actualValue)} / ${cell.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _getPercentageColor(
                            cell.percentage, colorScheme),
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
                // Total Score
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTotalScoreColor(row.totalScore, colorScheme)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      row.totalScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            _getTotalScoreColor(row.totalScore, colorScheme),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Format a number for display (no decimals if whole, 1 decimal otherwise).
  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  /// Get color for percentage value.
  Color _getPercentageColor(double percentage, ColorScheme colorScheme) {
    if (percentage >= 100) return Colors.green.shade700;
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.amber.shade700;
    return colorScheme.error;
  }

  /// Get color for total score with green >= 75, amber >= 50, red < 50.
  Color _getTotalScoreColor(double score, ColorScheme colorScheme) {
    if (score >= 75) return Colors.green.shade700;
    if (score >= 50) return Colors.amber.shade700;
    return colorScheme.error;
  }
}
