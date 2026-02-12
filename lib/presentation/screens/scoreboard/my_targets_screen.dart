import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../providers/auth_providers.dart';
import '../../providers/scoreboard_providers.dart';

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
  ScoringPeriod? _selectedPeriod;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(currentUserProvider).value;
    final periodsAsync = ref.watch(scoringPeriodsProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Target Saya')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Saya'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Period selector
          _buildPeriodSelector(periodsAsync, theme, colorScheme),

          // Targets list
          Expanded(
            child: _selectedPeriod == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'Pilih periode',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildTargetsContent(
                    currentUser.id, _selectedPeriod!, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    AsyncValue<List<ScoringPeriod>> periodsAsync,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return periodsAsync.when(
      data: (periods) {
        if (periods.isEmpty) return const SizedBox.shrink();

        // Auto-select current period
        if (_selectedPeriod == null && periods.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedPeriod = periods.firstWhere(
                (p) => p.isCurrent,
                orElse: () => periods.first,
              );
            });
          });
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<ScoringPeriod>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: periods.map((period) {
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
                        setState(() => _selectedPeriod = period);
                      }
                    },
                  ),
                ),
                if (_selectedPeriod?.isCurrent ?? false)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Aktif',
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
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTargetsContent(
    String userId,
    ScoringPeriod period,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final targetsAsync = ref.watch(userTargetsProvider(userId, period.id));
    final scoresAsync = ref.watch(userScoresProvider(userId, period.id));

    return targetsAsync.when(
      data: (targets) => scoresAsync.when(
        data: (scores) {
          if (targets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.track_changes,
                      size: 64, color: colorScheme.outline),
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

          // Group by measure type
          final leadTargets =
              targets.where((t) => t.measureType == 'LEAD').toList();
          final lagTargets =
              targets.where((t) => t.measureType == 'LAG').toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userTargetsProvider(userId, period.id));
              ref.invalidate(userScoresProvider(userId, period.id));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                _buildSummaryCard(theme, colorScheme, targets, scores),
                const SizedBox(height: 24),

                // LEAD Targets
                if (leadTargets.isNotEmpty) ...[
                  _buildSectionHeader(
                    theme,
                    'LEAD Measures (60%)',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  ...leadTargets.map(
                      (t) => _buildTargetCard(theme, colorScheme, t, scores)),
                  const SizedBox(height: 24),
                ],

                // LAG Targets
                if (lagTargets.isNotEmpty) ...[
                  _buildSectionHeader(
                    theme,
                    'LAG Measures (40%)',
                    Icons.flag,
                    Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  ...lagTargets.map(
                      (t) => _buildTargetCard(theme, colorScheme, t, scores)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
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
