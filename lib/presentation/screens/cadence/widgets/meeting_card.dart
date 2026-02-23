import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/cadence.dart';
import '../../../providers/sync_providers.dart';
import '../../../widgets/common/sync_status_badge.dart';

/// Card widget displaying a cadence meeting summary.
class MeetingCard extends ConsumerWidget {
  const MeetingCard({
    super.key,
    required this.meeting,
    this.showFormStatus = false,
    this.showFeedback = false,
    this.onTap,
  });

  final CadenceMeeting meeting;
  final bool showFormStatus;
  final bool showFeedback;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, d MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meeting.facilitatorName ?? 'Host',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSyncBadge(context, ref, meeting.id, meeting.isPendingSync),
                  const SizedBox(width: 8),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),

              // Date and time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(meeting.scheduledAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeFormat.format(meeting.scheduledAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              // Location (if available)
              if (meeting.location != null && meeting.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meeting.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Form status for upcoming meetings
              if (showFormStatus) ...[
                const Divider(height: 24),
                _buildFormStatusSection(context),
              ],

              // Stats for completed meetings
              if (meeting.status == MeetingStatus.completed) ...[
                const Divider(height: 24),
                _buildStatsSection(context),
              ],
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

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (meeting.status) {
      case MeetingStatus.scheduled:
        backgroundColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
        label = 'Scheduled';
        icon = Icons.event;
        break;
      case MeetingStatus.inProgress:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'In Progress';
        icon = Icons.play_circle_outline;
        break;
      case MeetingStatus.completed:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        label = 'Completed';
        icon = Icons.check_circle_outline;
        break;
      case MeetingStatus.cancelled:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormStatusSection(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final deadline = meeting.formDeadline;
    final isOverdue = now.isAfter(deadline);
    final timeRemaining = deadline.difference(now);

    // Check if form is submitted (this would come from participant data)
    // For now, show deadline information
    final statusColor = isOverdue ? AppColors.error : AppColors.warning;
    final statusIcon = isOverdue ? Icons.warning : Icons.edit_note;
    final statusText = isOverdue
        ? 'Form overdue'
        : timeRemaining.isNegative
            ? 'Submit your form'
            : 'Form due in ${_formatDuration(timeRemaining)}';

    return Row(
      children: [
        Icon(statusIcon, size: 18, color: statusColor),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final total = meeting.totalParticipants ?? 0;
    final present = meeting.presentCount ?? 0;
    final submitted = meeting.submittedFormCount ?? 0;

    return Row(
      children: [
        // Attendance count
        if (total > 0) ...[
          _buildStatChip(
            context,
            icon: Icons.people,
            label: '$present/$total',
            tooltip: 'Attendance',
          ),
          const SizedBox(width: 12),
        ],
        // Form submission count
        if (total > 0) ...[
          _buildStatChip(
            context,
            icon: Icons.assignment_turned_in,
            label: '$submitted/$total',
            tooltip: 'Forms submitted',
          ),
        ],
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return 'soon';
  }
}
