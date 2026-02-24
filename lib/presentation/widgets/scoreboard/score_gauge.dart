import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Circular gauge widget for displaying score.
class ScoreGauge extends StatelessWidget {
  final double score;
  final int? rank;
  final int? totalMembers;
  final int? rankChange;
  final double size;

  const ScoreGauge({
    super.key,
    required this.score,
    this.rank,
    this.totalMembers,
    this.rankChange,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
              Text(
                'SCORE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (rank != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_getMedal(rank!) != null) ...[
                      Text(_getMedal(rank!)!),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '#$rank${totalMembers != null ? '/$totalMembers' : ''}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (rankChange != null && rankChange != 0) ...[
                      const SizedBox(width: 4),
                      Icon(
                        rankChange! > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: rankChange! > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.successLight;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.warningDark;
    return AppColors.error;
  }

  String? _getMedal(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return null;
  }
}
