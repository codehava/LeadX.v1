import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/scoring_entities.dart';

/// Card widget for displaying a leaderboard entry.
class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const LeaderboardCard({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isCurrentUser ? 2 : 0,
      color: isCurrentUser
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 40,
                child: _buildRank(theme),
              ),
              const SizedBox(width: 12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isCurrentUser ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.branchName != null)
                      Text(
                        entry.branchName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Scores
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.score.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(entry.score),
                        ),
                      ),
                      if (entry.rankChange != null && entry.rankChange != 0) ...[
                        const SizedBox(width: 4),
                        Icon(
                          entry.rankChange! > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: entry.rankChange! > 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMiniScore(
                        context,
                        'L',
                        entry.leadScore,
                        AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      _buildMiniScore(
                        context,
                        'G',
                        entry.lagScore,
                        AppColors.tertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRank(ThemeData theme) {
    final medal = entry.medal;
    if (medal != null) {
      return Text(
        medal,
        style: const TextStyle(fontSize: 24),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        entry.rank,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMiniScore(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.successLight;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.warningDark;
    return AppColors.error;
  }
}
