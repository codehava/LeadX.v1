import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Progress bar for displaying measure progress.
class MeasureProgressBar extends StatelessWidget {
  final String measureName;
  final double actualValue;
  final double targetValue;
  final String? unit;
  final bool showPercentage;

  const MeasureProgressBar({
    super.key,
    required this.measureName,
    required this.actualValue,
    required this.targetValue,
    this.unit,
    this.showPercentage = true,
  });

  double get percentage {
    if (targetValue == 0) return 0;
    return (actualValue / targetValue) * 100;
  }

  bool get isTargetMet => percentage >= 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                measureName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatValue(actualValue),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  '/${_formatValue(targetValue)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showPercentage) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        // Status label
        Row(
          children: [
            if (isTargetMet) ...[
              Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                percentage > 100 ? 'Exceeded!' : 'Target met',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ] else ...[
              Icon(
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Need ${_formatValue(targetValue - actualValue)} more',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 80) return AppColors.successLight;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _formatValue(double value) {
    if (unit == 'IDR') {
      if (value >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      }
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      }
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
    }

    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
