import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/master_data_dtos.dart';
import '../../../domain/entities/pipeline.dart';

/// A hero summary section showing pipeline statistics.
///
/// Displays total pipeline count, potensi premi, realisasi premi,
/// and a breakdown of pipelines per stage with colored indicators.
class PipelineSummaryHero extends StatelessWidget {
  const PipelineSummaryHero({
    super.key,
    required this.pipelines,
    required this.stages,
  });

  final List<Pipeline> pipelines;
  final List<PipelineStageDto> stages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Compute aggregates
    final totalCount = pipelines.length;
    var totalPotensi = 0.0;
    var totalRealisasi = 0.0;
    final stageCounts = <String, int>{};

    for (final p in pipelines) {
      totalPotensi += p.potentialPremium;
      if (p.isWon && p.finalPremium != null) {
        totalRealisasi += p.finalPremium!;
      }
      stageCounts[p.stageId] = (stageCounts[p.stageId] ?? 0) + 1;
    }

    // Build ordered stage entries (only those with pipelines)
    final visibleStages = stages
        .where((s) => (stageCounts[s.id] ?? 0) > 0)
        .toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan Pipeline',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.description_outlined,
                    label: 'Pipeline',
                    value: totalCount.toString(),
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.trending_up,
                    label: 'Potensi Premi',
                    value: _formatCurrency(totalPotensi),
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.check_circle_outline,
                    label: 'Realisasi Premi',
                    value: _formatCurrency(totalRealisasi),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            // Stage breakdown
            if (visibleStages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                height: 1,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: visibleStages.map((stage) {
                  final count = stageCounts[stage.id] ?? 0;
                  final color = _parseHexColor(stage.color);
                  return _StageBadge(
                    label: stage.name,
                    count: count,
                    color: color,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}Jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}Rb';
    } else if (value == 0) {
      return 'Rp 0';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  static Color _parseHexColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return AppColors.primary;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label ($count)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
