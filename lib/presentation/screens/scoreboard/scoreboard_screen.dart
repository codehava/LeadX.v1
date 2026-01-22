import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../providers/scoreboard_providers.dart';
import '../../widgets/scoreboard/leaderboard_card.dart';
import '../../widgets/scoreboard/measure_progress_bar.dart';
import '../../widgets/scoreboard/score_gauge.dart';
import '../../providers/auth_providers.dart';

/// Main scoreboard screen showing personal scores and team leaderboard.
class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scoreboardAsync = ref.watch(scoreboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(scoreboardNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: scoreboardAsync.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.read(scoreboardNotifierProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ScoreboardState state,
  ) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider).value;

    if (state.error != null && state.userSummary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No scoring data available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scoring periods have not been configured yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(scoreboardNotifierProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          if (state.periods.isNotEmpty) ...[
            _buildPeriodSelector(context, ref, state),
            const SizedBox(height: 24),
          ],

          // Personal score card
          _buildPersonalScoreCard(context, state),
          const SizedBox(height: 24),

          // Lead measures section
          if (state.leadScores.isNotEmpty) ...[
            _buildMeasuresSection(
              context,
              'Lead Measures (60%)',
              state.leadScores,
              AppColors.info,
            ),
            const SizedBox(height: 24),
          ],

          // Lag measures section
          if (state.lagScores.isNotEmpty) ...[
            _buildMeasuresSection(
              context,
              'Lag Measures (40%)',
              state.lagScores,
              AppColors.tertiary,
            ),
            const SizedBox(height: 24),
          ],

          // Leaderboard section
          if (state.leaderboard.isNotEmpty) ...[
            Text(
              'Team Leaderboard',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...state.leaderboard.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LeaderboardCard(
                  entry: entry,
                  isCurrentUser: entry.userId == currentUser?.id,
                ),
              );
            }),
          ],

          // Empty state for leaderboard
          if (state.leaderboard.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No team data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    ScoreboardState state,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<ScoringPeriod>(
                value: state.selectedPeriod,
                isExpanded: true,
                underline: const SizedBox(),
                items: state.periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(
                      period.name,
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }).toList(),
                onChanged: (period) {
                  if (period != null) {
                    ref
                        .read(scoreboardNotifierProvider.notifier)
                        .selectPeriod(period);
                  }
                },
              ),
            ),
            if (state.selectedPeriod?.isCurrent == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalScoreCard(BuildContext context, ScoreboardState state) {
    final theme = Theme.of(context);
    final summary = state.userSummary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'My Score',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ScoreGauge(
              score: summary?.compositeScore ?? 0,
              rank: summary?.rank,
              totalMembers:
                  state.leaderboard.isNotEmpty ? state.leaderboard.length : null,
              rankChange: summary?.rankChange,
            ),
            const SizedBox(height: 16),
            // Status label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(summary?.compositeScore ?? 0)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                summary?.statusLabel ?? 'No data',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _getStatusColor(summary?.compositeScore ?? 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lead/Lag breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreChip(
                  context,
                  'Lead',
                  summary?.totalLeadScore ?? 0,
                  AppColors.info,
                ),
                const SizedBox(width: 16),
                _buildScoreChip(
                  context,
                  'Lag',
                  summary?.totalLagScore ?? 0,
                  AppColors.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasuresSection(
    BuildContext context,
    String title,
    List<UserScore> scores,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...scores.asMap().entries.map((entry) {
              final score = entry.value;
              final isLast = entry.key == scores.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: MeasureProgressBar(
                  measureName: score.measureName ?? 'Unknown',
                  actualValue: score.actualValue,
                  targetValue: score.targetValue,
                  unit: score.measureUnit,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.successLight;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.warningDark;
    return AppColors.error;
  }
}
