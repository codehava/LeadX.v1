import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/cadence.dart';
import '../../providers/auth_providers.dart';
import '../../providers/cadence_providers.dart';
import 'widgets/participant_card.dart';

/// Detail screen for a cadence meeting.
/// Shows different views for participants vs hosts.
class CadenceDetailScreen extends ConsumerWidget {
  const CadenceDetailScreen({
    super.key,
    required this.meetingId,
  });

  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meetingAsync = ref.watch(cadenceMeetingProvider(meetingId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return meetingAsync.when(
      data: (meeting) {
        if (meeting == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Meeting')),
            body: const Center(child: Text('Meeting not found')),
          );
        }

        final isHost = currentUser?.id == meeting.facilitatorId;

        return Scaffold(
          appBar: AppBar(
            title: Text(meeting.title),
            actions: [
              if (isHost && meeting.status == MeetingStatus.scheduled)
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Start Meeting',
                  onPressed: () => _startMeeting(context, ref, meetingId),
                ),
              if (isHost && meeting.status == MeetingStatus.inProgress)
                IconButton(
                  icon: const Icon(Icons.stop),
                  tooltip: 'End Meeting',
                  onPressed: () => _endMeeting(context, ref, meetingId),
                ),
            ],
          ),
          body: isHost
              ? _HostDetailView(meetingId: meetingId, meeting: meeting)
              : _ParticipantDetailView(meetingId: meetingId, meeting: meeting),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Meeting')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Meeting')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(cadenceMeetingProvider(meetingId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startMeeting(BuildContext context, WidgetRef ref, String id) async {
    final result = await ref.read(cadenceRepositoryProvider).startMeeting(id);
    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start meeting: ${failure.message}')),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting started')),
          );
        }
      },
    );
  }

  Future<void> _endMeeting(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Meeting'),
        content: const Text('Are you sure you want to end this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Meeting'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(cadenceRepositoryProvider).endMeeting(id);
    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to end meeting: ${failure.message}')),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting ended')),
          );
        }
      },
    );
  }
}

/// Host view of meeting detail - shows all participants and controls.
class _HostDetailView extends ConsumerWidget {
  const _HostDetailView({
    required this.meetingId,
    required this.meeting,
  });

  final String meetingId;
  final CadenceMeeting meeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final participantsAsync = ref.watch(meetingParticipantsProvider(meetingId));
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Meeting info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(meeting.scheduledAt),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format(meeting.scheduledAt)} (${meeting.durationMinutes} min)',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
                if (meeting.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 18, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meeting.location!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Participants section
        Text(
          'Participants',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        participantsAsync.when(
          data: (participants) {
            if (participants.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No participants',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: participants.map((participant) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ParticipantCard(
                    participant: participant,
                    isHost: true,
                    meetingStatus: meeting.status,
                    onMarkAttendance: meeting.status == MeetingStatus.inProgress
                        ? () => _showAttendanceSheet(context, ref, participant)
                        : null,
                    onViewForm: participant.preMeetingSubmitted
                        ? () => _showFormDetail(context, participant)
                        : null,
                    onGiveFeedback: meeting.status == MeetingStatus.completed
                        ? () => _showFeedbackSheet(context, ref, participant)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error loading participants: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (meeting.status) {
      case MeetingStatus.scheduled:
        backgroundColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
        label = 'Scheduled';
      case MeetingStatus.inProgress:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = 'In Progress';
      case MeetingStatus.completed:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Completed';
      case MeetingStatus.cancelled:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAttendanceSheet(
    BuildContext context,
    WidgetRef ref,
    CadenceParticipant participant,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AttendanceSheet(
        participant: participant,
        onMarkAttendance: (status, reason) async {
          final result = await ref.read(cadenceRepositoryProvider).markAttendance(
            participantId: participant.id,
            status: status,
            excusedReason: reason,
          );
          result.fold(
            (failure) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${failure.message}')),
                );
              }
            },
            (_) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance marked')),
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showFormDetail(BuildContext context, CadenceParticipant participant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _FormDetailSheet(
          participant: participant,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showFeedbackSheet(
    BuildContext context,
    WidgetRef ref,
    CadenceParticipant participant,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _FeedbackSheet(
          participant: participant,
          onSaveFeedback: (feedback) async {
            final result = await ref.read(cadenceRepositoryProvider).saveFeedback(
              participantId: participant.id,
              feedbackText: feedback,
            );
            result.fold(
              (failure) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${failure.message}')),
                  );
                }
              },
              (_) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback saved')),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

/// Participant view of meeting detail - shows own participation and form.
class _ParticipantDetailView extends ConsumerWidget {
  const _ParticipantDetailView({
    required this.meetingId,
    required this.meeting,
  });

  final String meetingId;
  final CadenceMeeting meeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final participationAsync = ref.watch(myParticipationProvider(meetingId));
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Meeting info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hosted by ${meeting.facilitatorName ?? "Manager"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(dateFormat.format(meeting.scheduledAt)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormat.format(meeting.scheduledAt)} (${meeting.durationMinutes} min)',
                    ),
                  ],
                ),
                if (meeting.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 18, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(child: Text(meeting.location!)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Participation status
        participationAsync.when(
          data: (participation) {
            if (participation == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('You are not a participant in this meeting'),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form status section
                _buildFormSection(context, ref, participation),
                const SizedBox(height: 16),

                // Attendance section
                if (meeting.status != MeetingStatus.scheduled)
                  _buildAttendanceSection(context, participation),

                // Feedback section (after meeting)
                if (meeting.status == MeetingStatus.completed &&
                    participation.hasFeedback) ...[
                  const SizedBox(height: 16),
                  _buildFeedbackSection(context, participation),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    WidgetRef ref,
    CadenceParticipant participation,
  ) {
    final theme = Theme.of(context);
    final canSubmitForm = meeting.status == MeetingStatus.scheduled ||
        meeting.status == MeetingStatus.inProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  participation.preMeetingSubmitted
                      ? Icons.check_circle
                      : Icons.edit_note,
                  color: participation.preMeetingSubmitted
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pre-Meeting Form',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (participation.preMeetingSubmitted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      participation.formStatusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!participation.preMeetingSubmitted) ...[
              Text(
                'Submit your form before the meeting',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deadline: ${DateFormat('d MMM, HH:mm').format(meeting.formDeadline)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: meeting.isFormDeadlinePassed
                      ? AppColors.error
                      : theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 12),
              if (canSubmitForm)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/home/cadence/$meetingId/form',
                      extra: participation,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Submit Form'),
                  ),
                ),
            ] else ...[
              // Show submitted form summary
              _buildFormSummary(context, participation),
              if (canSubmitForm) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/home/cadence/$meetingId/form',
                      extra: participation,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Form'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormSummary(BuildContext context, CadenceParticipant participation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (participation.q1PreviousCommitment != null) ...[
          _buildFormField(
            context,
            'Q1: Previous Commitment',
            participation.q1PreviousCommitment!,
            status: participation.q1CompletionStatusText,
          ),
          const SizedBox(height: 12),
        ],
        _buildFormField(
          context,
          'Q2: What I Achieved',
          participation.q2WhatAchieved ?? '-',
        ),
        const SizedBox(height: 12),
        if (participation.q3Obstacles != null &&
            participation.q3Obstacles!.isNotEmpty) ...[
          _buildFormField(
            context,
            'Q3: Obstacles',
            participation.q3Obstacles!,
          ),
          const SizedBox(height: 12),
        ],
        _buildFormField(
          context,
          'Q4: Next Commitment',
          participation.q4NextCommitment ?? '-',
        ),
      ],
    );
  }

  Widget _buildFormField(
    BuildContext context,
    String label,
    String value, {
    String? status,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildAttendanceSection(
    BuildContext context,
    CadenceParticipant participation,
  ) {
    final theme = Theme.of(context);

    Color statusColor;
    switch (participation.attendanceStatus) {
      case AttendanceStatus.present:
        statusColor = AppColors.success;
      case AttendanceStatus.late:
        statusColor = AppColors.warning;
      case AttendanceStatus.excused:
        statusColor = AppColors.info;
      case AttendanceStatus.absent:
        statusColor = AppColors.error;
      case AttendanceStatus.pending:
        statusColor = theme.colorScheme.outline;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.how_to_reg, color: statusColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  participation.attendanceStatusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (participation.attendanceScoreImpact != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (participation.attendanceScoreImpact! >= 0
                          ? AppColors.success
                          : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${participation.attendanceScoreImpact! >= 0 ? '+' : ''}${participation.attendanceScoreImpact}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: participation.attendanceScoreImpact! >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
    BuildContext context,
    CadenceParticipant participation,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.feedback, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Feedback from Host',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              participation.feedbackText!,
              style: theme.textTheme.bodyMedium,
            ),
            if (participation.feedbackGivenAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Given on ${DateFormat('d MMM yyyy').format(participation.feedbackGivenAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for marking attendance.
class _AttendanceSheet extends StatefulWidget {
  const _AttendanceSheet({
    required this.participant,
    required this.onMarkAttendance,
  });

  final CadenceParticipant participant;
  final Future<void> Function(AttendanceStatus status, String? reason) onMarkAttendance;

  @override
  State<_AttendanceSheet> createState() => _AttendanceSheetState();
}

class _AttendanceSheetState extends State<_AttendanceSheet> {
  AttendanceStatus? _selectedStatus;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mark Attendance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.participant.userName ?? 'Participant',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusChip(AttendanceStatus.present, 'Present', AppColors.success),
              _buildStatusChip(AttendanceStatus.late, 'Late', AppColors.warning),
              _buildStatusChip(AttendanceStatus.excused, 'Excused', AppColors.info),
              _buildStatusChip(AttendanceStatus.absent, 'Absent', AppColors.error),
            ],
          ),
          if (_selectedStatus == AttendanceStatus.excused) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for excuse',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedStatus == null || _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await widget.onMarkAttendance(
                        _selectedStatus!,
                        _selectedStatus == AttendanceStatus.excused
                            ? _reasonController.text
                            : null,
                      );
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Mark Attendance'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AttendanceStatus status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = selected ? status : null);
      },
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }
}

/// Bottom sheet for viewing form details.
class _FormDetailSheet extends StatelessWidget {
  const _FormDetailSheet({
    required this.participant,
    required this.scrollController,
  });

  final CadenceParticipant participant;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            participant.userName ?? 'Participant',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Form submitted ${participant.formStatusText.toLowerCase()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 32),

          if (participant.q1PreviousCommitment != null) ...[
            _buildSection(
              context,
              'Q1: Previous Commitment',
              participant.q1PreviousCommitment!,
              badge: participant.q1CompletionStatusText,
            ),
            const SizedBox(height: 16),
          ],

          _buildSection(
            context,
            'Q2: What I Achieved',
            participant.q2WhatAchieved ?? '-',
          ),
          const SizedBox(height: 16),

          if (participant.q3Obstacles != null &&
              participant.q3Obstacles!.isNotEmpty) ...[
            _buildSection(
              context,
              'Q3: Obstacles',
              participant.q3Obstacles!,
            ),
            const SizedBox(height: 16),
          ],

          _buildSection(
            context,
            'Q4: Next Commitment',
            participant.q4NextCommitment ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String label,
    String content, {
    String? badge,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

/// Bottom sheet for giving feedback.
class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({
    required this.participant,
    required this.onSaveFeedback,
  });

  final CadenceParticipant participant;
  final Future<void> Function(String feedback) onSaveFeedback;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  late TextEditingController _controller;
  bool _isLoading = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.participant.feedbackText);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback for ${widget.participant.userName ?? "Participant"}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Feedback',
              hintText: 'Enter your feedback for this participant...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: (value) {
              final hasText = value.isNotEmpty;
              if (hasText != _hasText) {
                setState(() => _hasText = hasText);
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading || !_hasText
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await widget.onSaveFeedback(_controller.text);
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Feedback'),
            ),
          ),
        ],
      ),
    );
  }
}
