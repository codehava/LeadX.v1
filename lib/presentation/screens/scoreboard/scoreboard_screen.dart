import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/period_type_helpers.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../../config/routes/route_names.dart';
import '../../providers/scoreboard_providers.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/scoreboard/leaderboard_card.dart';
import '../../widgets/scoreboard/measure_progress_bar.dart';
import '../../widgets/scoreboard/score_gauge.dart';
import '../../providers/auth_providers.dart';

/// Main scoreboard screen showing personal scores and team leaderboard.
class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        error: (error, _) => AppErrorState.general(
          message: error.toString(),
          onRetry: () {
            ref.read(scoreboardNotifierProvider.notifier).refresh();
          },
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
            const SizedBox(height: 16),
          ],

          // Historical period banner
          if (!state.isMultiPeriodView &&
              state.selectedPeriod != null &&
              !(state.selectedPeriod!.isCurrent)) ...[
            _buildHistoricalBanner(context, ref, state),
            const SizedBox(height: 16),
          ],

          // Score update pending indicator
          _buildScorePendingIndicator(context, ref),

          // Personal score card
          _buildPersonalScoreCard(context, state),
          const SizedBox(height: 24),

          // Measures display — conditional on multi-period view
          if (state.isMultiPeriodView) ...[
            // Multi-period grouped sections
            ...state.periodSections.expand((section) => [
                  _buildPeriodSectionCard(context, section),
                  const SizedBox(height: 24),
                ]),
          ] else ...[
            // Historical flat view
            if (state.leadScores.isNotEmpty) ...[
              _buildMeasuresSection(
                context,
                'Lead Measures (60%)',
                state.leadScores,
                AppColors.info,
              ),
              const SizedBox(height: 24),
            ],
            if (state.lagScores.isNotEmpty) ...[
              _buildMeasuresSection(
                context,
                'Lag Measures (40%)',
                state.lagScores,
                AppColors.tertiary,
              ),
              const SizedBox(height: 24),
            ],
          ],

          // Bonuses & Penalties section
          if (state.userSummary?.hasAdjustments ?? false) ...[
            _buildBonusesPenaltiesSection(context, state.userSummary!),
            const SizedBox(height: 24),
          ],

          // Leaderboard section
          if (state.leaderboard.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Leaderboard',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_full, size: 16),
                  label: const Text('View All'),
                  onPressed: () => context.pushNamed(RouteNames.leaderboard),
                ),
              ],
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

  /// Banner shown when viewing a historical (non-current) period.
  Widget _buildHistoricalBanner(
    BuildContext context,
    WidgetRef ref,
    ScoreboardState state,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Melihat periode: ${state.selectedPeriod!.name}  ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Return to current (multi-period) view by selecting a current period
              final currentPeriods =
                  state.periods.where((p) => p.isCurrent).toList();
              if (currentPeriods.isNotEmpty) {
                currentPeriods.sort((a, b) => periodTypePriority(a.periodType)
                    .compareTo(periodTypePriority(b.periodType)));
                ref
                    .read(scoreboardNotifierProvider.notifier)
                    .selectPeriod(currentPeriods.first);
              }
            },
            child: Text(
              'Kembali ke periode aktif',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePendingIndicator(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isScorePendingAsync = ref.watch(isScoreUpdatePendingProvider);
    return isScorePendingAsync.when(
      data: (isPending) {
        if (!isPending) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.sync, size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Skor sedang diperbarui oleh server...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPersonalScoreCard(BuildContext context, ScoreboardState state) {
    final theme = Theme.of(context);
    final summary = state.userSummary;
    final periodTypeLabel = state.selectedPeriod != null
        ? formatPeriodType(state.selectedPeriod!.periodType)
        : null;

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
            if (periodTypeLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                'Skor Periode $periodTypeLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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

  /// Build a card for a single period section in multi-period view.
  Widget _buildPeriodSectionCard(BuildContext context, PeriodSection section) {
    final theme = Theme.of(context);
    final typeColor = periodTypeColor(section.period.periodType);
    final typeLabel = formatPeriodType(section.period.periodType);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header bar with section score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  typeLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '— ${section.period.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (section.hasScores)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${section.sectionScore.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lead measures
                if (section.leadScores.isNotEmpty) ...[
                  _buildMeasureGroupHeader(
                      context, 'Lead Measures (60%)', AppColors.info),
                  const SizedBox(height: 12),
                  ...section.leadScores.asMap().entries.map((entry) {
                    final score = entry.value;
                    final isLast = entry.key == section.leadScores.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(
                            RouteNames.measureDetail,
                            pathParameters: {'measureId': score.measureId},
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: MeasureProgressBar(
                          measureName: score.measureName ?? 'Unknown',
                          actualValue: score.actualValue,
                          targetValue: score.targetValue,
                          unit: score.measureUnit,
                        ),
                      ),
                    );
                  }),
                ],

                // Spacing between lead and lag
                if (section.leadScores.isNotEmpty &&
                    section.lagScores.isNotEmpty)
                  const SizedBox(height: 20),

                // Lag measures
                if (section.lagScores.isNotEmpty) ...[
                  _buildMeasureGroupHeader(
                      context, 'Lag Measures (40%)', AppColors.tertiary),
                  const SizedBox(height: 12),
                  ...section.lagScores.asMap().entries.map((entry) {
                    final score = entry.value;
                    final isLast = entry.key == section.lagScores.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(
                            RouteNames.measureDetail,
                            pathParameters: {'measureId': score.measureId},
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: MeasureProgressBar(
                          measureName: score.measureName ?? 'Unknown',
                          actualValue: score.actualValue,
                          targetValue: score.targetValue,
                          unit: score.measureUnit,
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small header for lead/lag group within a period section.
  Widget _buildMeasureGroupHeader(
    BuildContext context,
    String title,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Flat measures section for historical (single-period) view.
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
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      RouteNames.measureDetail,
                      pathParameters: {'measureId': score.measureId},
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: MeasureProgressBar(
                    measureName: score.measureName ?? 'Unknown',
                    actualValue: score.actualValue,
                    targetValue: score.targetValue,
                    unit: score.measureUnit,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusesPenaltiesSection(
    BuildContext context,
    PeriodSummary summary,
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
                    color: summary.netAdjustment >= 0
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Bonuses & Penalties',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bonuses
            if (summary.bonusPoints > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text('Bonus Points',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  Text(
                    '+${summary.bonusPoints.toStringAsFixed(1)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Penalties
            if (summary.penaltyPoints > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.remove_circle,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text('Penalty Points',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  Text(
                    '-${summary.penaltyPoints.toStringAsFixed(1)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Divider
            const Divider(),
            const SizedBox(height: 12),

            // Net adjustment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Adjustment',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  summary.netAdjustment >= 0
                      ? '+${summary.netAdjustment.toStringAsFixed(1)}'
                      : summary.netAdjustment.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: summary.netAdjustment >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
