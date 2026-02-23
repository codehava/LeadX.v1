import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/broker.dart';
import '../../providers/sync_providers.dart';
import '../common/sync_status_badge.dart';

/// Card widget for displaying broker information in lists.
class BrokerCard extends ConsumerWidget {
  const BrokerCard({
    super.key,
    required this.broker,
    this.pipelineCount = 0,
    this.onTap,
  });

  final Broker broker;
  final int pipelineCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and sync status
              Row(
                children: [
                  // Broker icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.handshake_outlined,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Broker info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          broker.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Sync status
                  _buildSyncBadge(context, ref, broker.id, broker.isPendingSync),
                ],
              ),
              const SizedBox(height: 12),
              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Code chip
                  _InfoChip(
                    icon: Icons.tag,
                    label: broker.code,
                  ),
                  // Commission rate chip
                  if (broker.commissionRate != null)
                    _InfoChip(
                      icon: Icons.percent,
                      label: broker.formattedCommissionRate,
                      color: AppColors.success,
                    ),
                  // Pipeline count chip
                  _InfoChip(
                    icon: Icons.trending_up,
                    label: '$pipelineCount Pipeline',
                    color: pipelineCount > 0
                        ? AppColors.primary
                        : theme.colorScheme.outline,
                  ),
                  // License chip
                  if (broker.licenseNumber != null &&
                      broker.licenseNumber!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.badge_outlined,
                      label: broker.licenseNumber!,
                    ),
                ],
              ),
            ],
          ),
        ),
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
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
