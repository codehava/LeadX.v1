import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/customer.dart';
import '../../../domain/entities/pipeline.dart';
import '../../providers/pipeline_providers.dart';
import '../../providers/sync_providers.dart';
import '../common/app_card.dart';
import '../common/sync_status_badge.dart';

/// Card widget for displaying customer in a list.
class CustomerCard extends ConsumerWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onLongPress,
    this.showSyncStatus = true,
  });

  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSyncStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pipelinesAsync = ref.watch(customerPipelinesProvider(customer.id));

    return AppCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar with initials
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  _getInitials(customer.name),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      customer.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Sync status badge
              if (showSyncStatus)
                _buildSyncBadge(context, ref, customer.id, customer.isPendingSync),
            ],
          ),
          const SizedBox(height: 12),
          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  customer.fullAddress,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Contact info (if available)
          if (customer.phone != null || customer.email != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (customer.phone != null) ...[
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    customer.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (customer.phone != null && customer.email != null)
                  const SizedBox(width: 16),
                if (customer.email != null) ...[
                  Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      customer.email!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
          // Status chip
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusChip(
                label: customer.isActive ? 'Aktif' : 'Tidak Aktif',
                color: customer.isActive ? Colors.green : Colors.grey,
              ),
              if (customer.industryName != null) ...[
                const SizedBox(width: 8),
                _StatusChip(
                  label: customer.industryName!,
                  color: colorScheme.secondary,
                ),
              ],
            ],
          ),
          // Pipeline stages section
          pipelinesAsync.when(
            data: (pipelines) {
              if (pipelines.isEmpty) return const SizedBox.shrink();
              final stageGroups = _groupPipelinesByStage(pipelines);
              return _buildPipelineStagesSection(context, stageGroups);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
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

  Widget _buildPipelineStagesSection(BuildContext context, List<_StageGroup> stageGroups) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Pipeline:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: stageGroups.map((group) => _StageCountBadge(group: group)).toList(),
        ),
      ],
    );
  }

  List<_StageGroup> _groupPipelinesByStage(List<Pipeline> pipelines) {
    final groupMap = <String, _StageGroup>{};

    for (final pipeline in pipelines) {
      final stageName = pipeline.stageName ?? 'Unknown';
      if (groupMap.containsKey(stageName)) {
        groupMap[stageName] = groupMap[stageName]!.copyWith(
          count: groupMap[stageName]!.count + 1,
        );
      } else {
        groupMap[stageName] = _StageGroup(
          stageName: stageName,
          count: 1,
          color: pipeline.stageColor,
          isWon: pipeline.stageIsWon ?? false,
          isFinal: pipeline.stageIsFinal ?? false,
          probability: pipeline.stageProbability ?? 0,
        );
      }
    }

    // Sort by probability (lower probability = earlier in funnel)
    final groups = groupMap.values.toList();
    groups.sort((a, b) => a.probability.compareTo(b.probability));
    return groups;
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

class _StageGroup {
  final String stageName;
  final int count;
  final String? color;
  final bool isWon;
  final bool isFinal;
  final int probability;

  const _StageGroup({
    required this.stageName,
    required this.count,
    this.color,
    this.isWon = false,
    this.isFinal = false,
    this.probability = 0,
  });

  _StageGroup copyWith({
    String? stageName,
    int? count,
    String? color,
    bool? isWon,
    bool? isFinal,
    int? probability,
  }) {
    return _StageGroup(
      stageName: stageName ?? this.stageName,
      count: count ?? this.count,
      color: color ?? this.color,
      isWon: isWon ?? this.isWon,
      isFinal: isFinal ?? this.isFinal,
      probability: probability ?? this.probability,
    );
  }
}

class _StageCountBadge extends StatelessWidget {
  const _StageCountBadge({required this.group});

  final _StageGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(group.color, theme.colorScheme.primary);

    // Determine icon based on stage type
    IconData? icon;
    var iconColor = color;
    if (group.isWon) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (group.isFinal && !group.isWon) {
      icon = Icons.cancel;
      iconColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(
            '${group.stageName}: ${group.count}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hexColor, Color fallback) {
    if (hexColor == null || hexColor.isEmpty) return fallback;
    try {
      var hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
