import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/pipeline.dart';
import '../../providers/sync_providers.dart';
import '../common/app_card.dart';
import '../common/sync_status_badge.dart';

/// Card widget for displaying pipeline in a list.
class PipelineCard extends ConsumerWidget {
  const PipelineCard({
    super.key,
    required this.pipeline,
    this.onTap,
    this.onLongPress,
    this.showSyncStatus = true,
    this.showCustomerName = false,
  });

  final Pipeline pipeline;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSyncStatus;
  final bool showCustomerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Parse stage color or use default
    final stageColor = _parseColor(pipeline.stageColor) ?? colorScheme.primary;

    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with COB/LOB and Stage badge
          Row(
            children: [
              // COB/LOB icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_center_outlined,
                  size: 20,
                  color: stageColor,
                ),
              ),
              const SizedBox(width: 12),
              // COB/LOB and Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pipeline.cobLobDisplay,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      pipeline.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Stage badge
              _StageBadge(
                stageName: pipeline.stageName ?? 'Unknown',
                color: stageColor,
                isWon: pipeline.isWon,
                isLost: pipeline.isLost,
              ),
              // Sync status badge
              if (showSyncStatus) ...[
                const SizedBox(width: 8),
                _buildSyncBadge(context, ref, pipeline.id, pipeline.isPendingSync),
              ],
            ],
          ),
          
          // Customer name (if showing from global view)
          if (showCustomerName && pipeline.customerName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    pipeline.customerName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Premium and Details row
          Row(
            children: [
              // Potential Premium
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potensi Premi',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      pipeline.formattedPotentialPremium,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status
              if (pipeline.statusName != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        pipeline.statusName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // Expected close date and tender badge
          const SizedBox(height: 12),
          Row(
            children: [
              // Expected close date
              if (pipeline.expectedCloseDate != null) ...[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(pipeline.expectedCloseDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Tender badge
              if (pipeline.isTender)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.gavel,
                        size: 12,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tender',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              // Final premium (if won)
              if (pipeline.isWon && pipeline.finalPremium != null)
                Text(
                  'Final: ${pipeline.formattedFinalPremium}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncBadge(BuildContext context, WidgetRef ref, String entityId, bool isPendingSync) {
    final statusMap = ref.watch(syncQueueEntityStatusMapProvider);
    final queueStatus = statusMap.valueOrNull?[entityId];

    if (queueStatus == null) {
      if (isPendingSync) {
        return const SyncStatusBadge(status: SyncStatus.pending);
      }
      return const SizedBox.shrink();
    }

    final syncStatus = switch (queueStatus) {
      SyncQueueEntityStatus.pending => SyncStatus.pending,
      SyncQueueEntityStatus.failed => SyncStatus.failed,
      SyncQueueEntityStatus.deadLetter => SyncStatus.deadLetter,
      SyncQueueEntityStatus.none => null,
    };

    if (syncStatus == null) return const SizedBox.shrink();

    final badge = SyncStatusBadge(status: syncStatus);

    if (queueStatus == SyncQueueEntityStatus.failed ||
        queueStatus == SyncQueueEntityStatus.deadLetter) {
      return GestureDetector(
        onTap: () => context.push('/home/sync-queue?entityId=$entityId'),
        child: badge,
      );
    }

    return badge;
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Stage badge widget with color coding.
class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.stageName,
    required this.color,
    this.isWon = false,
    this.isLost = false,
  });

  final String stageName;
  final Color color;
  final bool isWon;
  final bool isLost;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isWon
        ? Colors.green
        : isLost
            ? Colors.red
            : color;

    final icon = isWon
        ? Icons.check_circle
        : isLost
            ? Icons.cancel
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 4),
          ],
          Text(
            stageName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
