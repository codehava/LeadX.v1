import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/period_type_helpers.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../providers/auth_providers.dart';
import '../../providers/scoreboard_providers.dart';
import '../../widgets/scoreboard/period_selector.dart';

/// User-facing "My Targets" screen.
///
/// Shows the current user's assigned targets with progress bars
/// comparing actual scores against target values. Read-only.
class MyTargetsScreen extends ConsumerStatefulWidget {
  const MyTargetsScreen({super.key});

  @override
  ConsumerState<MyTargetsScreen> createState() => _MyTargetsScreenState();
}

class _MyTargetsScreenState extends ConsumerState<MyTargetsScreen> {
  /// null = "Periode Aktif" (multi-period aggregate mode).
  ScoringPeriod? _selectedPeriod;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(currentUserProvider).value;
    final periodsAsync = ref.watch(scoringPeriodsProvider);
    final currentPeriodsAsync = ref.watch(allCurrentPeriodsProvider);
    final currentPeriods = currentPeriodsAsync.valueOrNull ?? [];

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Target Saya')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Auto-init: default to null (Periode Aktif) if current periods exist
    if (!_initialized) {
      periodsAsync.whenData((periods) {
        if (periods.isNotEmpty && !_initialized) {
          _initialized = true;
          // _selectedPeriod stays null = "Periode Aktif"
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Saya'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Period selector
          periodsAsync.when(
            data: (periods) {
              if (periods.isEmpty) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.all(16),
                child: PeriodSelector(
                  selectedPeriod: _selectedPeriod,
                  allPeriods: periods,
                  currentPeriods: currentPeriods,
                  onChanged: (period) {
                    setState(() => _selectedPeriod = period);
                  },
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Targets list
          Expanded(
            child: _buildTargetsContent(
                currentUser.id, _selectedPeriod, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsContent(
    String userId,
    ScoringPeriod? period,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // null = "Periode Aktif" → multi-period view
    if (period == null) {
      final currentPeriodAsync = ref.watch(currentPeriodProvider);
      final displayPeriod = currentPeriodAsync.valueOrNull;
      if (displayPeriod == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildMultiPeriodTargets(userId, displayPeriod, theme, colorScheme);
    }

    // Current individual period → also multi-period
    if (period.isCurrent) {
      return _buildMultiPeriodTargets(userId, period, theme, colorScheme);
    }

    // Historical: single-period flat view
    final targetsAsync = ref.watch(userTargetsProvider(userId, period.id));
    final scoresAsync = ref.watch(userScoresProvider(userId, period.id));

    return targetsAsync.when(
      data: (targets) => scoresAsync.when(
        data: (scores) =>
            _buildTargetsList(userId, targets, scores, theme, colorScheme, null),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildMultiPeriodTargets(
    String userId,
    ScoringPeriod displayPeriod,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final currentPeriodsAsync = ref.watch(allCurrentPeriodsProvider);

    return currentPeriodsAsync.when(
      data: (currentPeriods) {
        // Collect targets and scores across all current periods
        final allTargets = <UserTarget>[];
        final allScores = <UserScore>[];
        var anyLoading = false;

        // Map periodId → period for grouping
        final periodById = <String, ScoringPeriod>{};
        for (final p in currentPeriods) {
          periodById[p.id] = p;
        }

        for (final p in currentPeriods) {
          final tAsync = ref.watch(userTargetsProvider(userId, p.id));
          final sAsync = ref.watch(userScoresProvider(userId, p.id));
          tAsync.when(
            data: (t) => allTargets.addAll(t),
            loading: () => anyLoading = true,
            error: (_, _) {},
          );
          sAsync.when(
            data: (s) => allScores.addAll(s),
            loading: () => anyLoading = true,
            error: (_, _) {},
          );
        }

        if (anyLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildTargetsList(
          userId, allTargets, allScores, theme, colorScheme, currentPeriods,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildTargetsList(
    String userId,
    List<UserTarget> targets,
    List<UserScore> scores,
    ThemeData theme,
    ColorScheme colorScheme,
    List<ScoringPeriod>? currentPeriods,
  ) {
    if (targets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Belum ada target yang ditetapkan',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungi atasan Anda untuk penetapan target',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // If multi-period, group by period type
    final hasMultiplePeriodTypes = currentPeriods != null &&
        currentPeriods.map((p) => p.periodType).toSet().length > 1;

    if (hasMultiplePeriodTypes) {
      // Build period type → targets map
      final periodById = <String, ScoringPeriod>{};
      for (final p in currentPeriods) {
        periodById[p.id] = p;
      }

      final grouped = <String, List<UserTarget>>{};
      for (final t in targets) {
        final period = periodById[t.periodId];
        final pType = period?.periodType ?? 'WEEKLY';
        grouped.putIfAbsent(pType, () => []).add(t);
      }

      final sortedTypes = grouped.keys.toList()
        ..sort((a, b) => periodTypePriority(a).compareTo(periodTypePriority(b)));

      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allCurrentPeriodsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(theme, colorScheme, targets, scores),
            const SizedBox(height: 24),
            ...sortedTypes.expand((pType) {
              final typeTargets = grouped[pType]!;
              final typeColor = periodTypeColor(pType);
              final period = currentPeriods.firstWhere(
                (p) => p.periodType == pType,
                orElse: () => currentPeriods.first,
              );
              final leadTargets =
                  typeTargets.where((t) => t.measureType == 'LEAD').toList();
              final lagTargets =
                  typeTargets.where((t) => t.measureType == 'LAG').toList();

              return [
                // Period type header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: typeColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${formatPeriodType(pType)} — ${period.name}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: typeColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (leadTargets.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'LEAD (60%)',
                      Icons.trending_up, Colors.orange),
                  const SizedBox(height: 8),
                  ...leadTargets.map(
                      (t) => _buildTargetCard(theme, colorScheme, t, scores)),
                  const SizedBox(height: 16),
                ],
                if (lagTargets.isNotEmpty) ...[
                  _buildSectionHeader(
                      theme, 'LAG (40%)', Icons.flag, Colors.purple),
                  const SizedBox(height: 8),
                  ...lagTargets.map(
                      (t) => _buildTargetCard(theme, colorScheme, t, scores)),
                ],
                const SizedBox(height: 24),
              ];
            }),
          ],
        ),
      );
    }

    // Single period type — flat view
    final leadTargets =
        targets.where((t) => t.measureType == 'LEAD').toList();
    final lagTargets =
        targets.where((t) => t.measureType == 'LAG').toList();

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedPeriod != null) {
          ref.invalidate(
              userTargetsProvider(userId, _selectedPeriod!.id));
          ref.invalidate(
              userScoresProvider(userId, _selectedPeriod!.id));
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(theme, colorScheme, targets, scores),
          const SizedBox(height: 24),
          if (leadTargets.isNotEmpty) ...[
            _buildSectionHeader(
                theme, 'LEAD Measures (60%)', Icons.trending_up, Colors.orange),
            const SizedBox(height: 8),
            ...leadTargets.map(
                (t) => _buildTargetCard(theme, colorScheme, t, scores)),
            const SizedBox(height: 24),
          ],
          if (lagTargets.isNotEmpty) ...[
            _buildSectionHeader(
                theme, 'LAG Measures (40%)', Icons.flag, Colors.purple),
            const SizedBox(height: 8),
            ...lagTargets.map(
                (t) => _buildTargetCard(theme, colorScheme, t, scores)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    ColorScheme colorScheme,
    List<UserTarget> targets,
    List<UserScore> scores,
  ) {
    var metCount = 0;
    for (final target in targets) {
      final score = scores
          .where((s) => s.measureId == target.measureId)
          .firstOrNull;
      if (score != null && target.targetValue > 0) {
        final pct = (score.actualValue / target.targetValue) * 100;
        if (pct >= 100) metCount++;
      }
    }

    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Target',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$metCount dari ${targets.length} target tercapai',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: metCount == targets.length && targets.isNotEmpty
                  ? AppColors.success
                  : colorScheme.primary,
              child: Text(
                '${targets.isNotEmpty ? ((metCount / targets.length) * 100).toInt() : 0}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCard(
    ThemeData theme,
    ColorScheme colorScheme,
    UserTarget target,
    List<UserScore> scores,
  ) {
    final score = scores
        .where((s) => s.measureId == target.measureId)
        .firstOrNull;

    final actual = score?.actualValue ?? 0;
    final targetVal = target.targetValue;
    final percentage = targetVal > 0 ? (actual / targetVal) * 100 : 0.0;
    final progressRatio = (percentage / 100).clamp(0.0, 1.0);

    // Color based on percentage
    final Color progressColor;
    if (percentage >= 100) {
      progressColor = AppColors.success;
    } else if (percentage >= 60) {
      progressColor = Colors.orange;
    } else {
      progressColor = colorScheme.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Measure name
            Text(
              target.measureName ?? 'Measure',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Target value
            Text(
              'Target: ${_formatValue(targetVal)} ${target.measureUnit ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 8,
                backgroundColor: progressColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatValue(actual)} / ${_formatValue(targetVal)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
