import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/cadence.dart';

/// Card widget displaying a cadence meeting participant.
class ParticipantCard extends StatelessWidget {
  const ParticipantCard({
    super.key,
    required this.participant,
    this.isHost = false,
    this.meetingStatus = MeetingStatus.scheduled,
    this.onMarkAttendance,
    this.onViewForm,
    this.onGiveFeedback,
  });

  final CadenceParticipant participant;
  final bool isHost;
  final MeetingStatus meetingStatus;
  final VoidCallback? onMarkAttendance;
  final VoidCallback? onViewForm;
  final VoidCallback? onGiveFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _getInitials(participant.userName ?? 'U'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.userName ?? 'Unknown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (participant.userRole != null)
                        Text(
                          participant.userRole!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),

                // Attendance badge
                _buildAttendanceBadge(context),
              ],
            ),

            // Status row
            const SizedBox(height: 12),
            Row(
              children: [
                // Form status
                _buildStatusChip(
                  context,
                  icon: participant.preMeetingSubmitted
                      ? Icons.check_circle
                      : Icons.pending,
                  label: participant.preMeetingSubmitted ? 'Form' : 'No form',
                  color: participant.preMeetingSubmitted
                      ? AppColors.success
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),

                // Score impact (if marked)
                if (participant.totalScoreImpact != 0)
                  _buildScoreChip(context, participant.totalScoreImpact),

                const Spacer(),

                // Action buttons
                if (isHost) ...[
                  if (onViewForm != null && participant.preMeetingSubmitted)
                    IconButton(
                      icon: const Icon(Icons.description_outlined),
                      tooltip: 'View Form',
                      onPressed: onViewForm,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onMarkAttendance != null)
                    IconButton(
                      icon: const Icon(Icons.how_to_reg),
                      tooltip: 'Mark Attendance',
                      onPressed: onMarkAttendance,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onGiveFeedback != null)
                    IconButton(
                      icon: Icon(
                        participant.hasFeedback
                            ? Icons.feedback
                            : Icons.feedback_outlined,
                      ),
                      tooltip: participant.hasFeedback
                          ? 'Edit Feedback'
                          : 'Give Feedback',
                      onPressed: onGiveFeedback,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ],
            ),

            // Feedback preview (for host view)
            if (isHost && participant.hasFeedback) ...[
              const Divider(height: 16),
              Text(
                'Feedback:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                participant.feedbackText!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBadge(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (participant.attendanceStatus) {
      case AttendanceStatus.present:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Present';
        icon = Icons.check;
      case AttendanceStatus.late:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = 'Late';
        icon = Icons.schedule;
      case AttendanceStatus.excused:
        backgroundColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
        label = 'Excused';
        icon = Icons.info_outline;
      case AttendanceStatus.absent:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Absent';
        icon = Icons.close;
      case AttendanceStatus.pending:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        label = 'Pending';
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildStatusChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(BuildContext context, int score) {
    final theme = Theme.of(context);
    final isPositive = score >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${isPositive ? '+' : ''}$score pts',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
