import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/sync_providers.dart';
import '../common/sync_status_badge.dart';

/// Card widget for displaying activity information in lists.
class ActivityCard extends ConsumerWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onExecute,
    this.showObjectName = true,
    this.compact = false,
  });

  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onExecute;
  final bool showObjectName;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: compact
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: compact
              ? const EdgeInsets.all(12)
              : const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref, theme),
              if (!compact) const SizedBox(height: 8),
              _buildContent(theme),
              if (activity.canExecute && onExecute != null && !compact)
                _buildActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Row(
      children: [
        // Activity type icon
        Container(
          width: compact ? 32 : 40,
          height: compact ? 32 : 40,
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: compact ? 18 : 22,
          ),
        ),
        const SizedBox(width: 12),
        // Activity type name and object
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.displayName,
                style: compact
                    ? theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )
                    : theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
              ),
              if (showObjectName && activity.objectName != null)
                Text(
                  activity.objectName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (showObjectName && activity.keyPersonName != null)
                Text(
                  'PIC: ${activity.keyPersonName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Sync status badge
        _buildSyncBadge(context, ref, activity.id, activity.isPendingSync),
        const SizedBox(width: 8),
        // Status badge
        _buildStatusBadge(theme),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Row(
      children: [
        // Scheduled datetime
        Icon(
          Icons.access_time,
          size: 16,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(activity.scheduledDatetime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        // GPS indicator
        if (activity.hasValidGps) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.gps_fixed,
            size: 16,
            color: AppColors.success,
          ),
        ],
        // Immediate badge
        if (activity.isImmediate) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Immediate',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ],
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

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        activity.statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (activity.canExecute)
            FilledButton.icon(
              onPressed: onExecute,
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Execute'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (activity.status) {
      case ActivityStatus.planned:
        return AppColors.info;
      case ActivityStatus.inProgress:
        return AppColors.warning;
      case ActivityStatus.completed:
        return AppColors.success;
      case ActivityStatus.cancelled:
        return AppColors.activityCancelled;
      case ActivityStatus.rescheduled:
        return AppColors.primary;
      case ActivityStatus.overdue:
        return AppColors.error;
    }
  }

  Color _getTypeColor() {
    // Use activity type color if available, otherwise use primary
    if (activity.activityTypeColor != null &&
        activity.activityTypeColor!.isNotEmpty) {
      try {
        return Color(
          int.parse(activity.activityTypeColor!.replaceFirst('#', ''), radix: 16) +
              0xFF000000,
        );
      } catch (_) {}
    }
    return AppColors.primary;
  }

  IconData _getTypeIcon() {
    // Map activity type icon string to IconData
    final iconName = activity.activityTypeIcon?.toLowerCase() ?? '';
    switch (iconName) {
      case 'visit':
      case 'place':
      case 'location':
        return Icons.place;
      case 'call':
      case 'phone':
        return Icons.phone;
      case 'meeting':
      case 'people':
        return Icons.people;
      case 'email':
      case 'mail':
        return Icons.email;
      case 'presentation':
      case 'slideshow':
        return Icons.slideshow;
      case 'quotation':
      case 'request_quote':
        return Icons.request_quote;
      case 'contract':
      case 'description':
        return Icons.description;
      default:
        return Icons.event;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (dtDate == today) {
      dateStr = 'Today';
    } else if (dtDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else if (dtDate.isBefore(today)) {
      final diff = today.difference(dtDate).inDays;
      dateStr = '$diff days ago';
    } else {
      dateStr = '${dt.day}/${dt.month}';
    }

    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }
}
