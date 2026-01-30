import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/cadence.dart';
import '../../providers/cadence_providers.dart';

/// Screen for submitting pre-meeting form (Q1-Q4).
class CadenceFormScreen extends ConsumerStatefulWidget {
  const CadenceFormScreen({
    super.key,
    required this.meetingId,
    this.participation,
  });

  final String meetingId;
  final CadenceParticipant? participation;

  @override
  ConsumerState<CadenceFormScreen> createState() => _CadenceFormScreenState();
}

class _CadenceFormScreenState extends ConsumerState<CadenceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _q2Controller;
  late TextEditingController _q3Controller;
  late TextEditingController _q4Controller;

  CommitmentCompletionStatus? _q1Status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.participation;
    _q2Controller = TextEditingController(text: p?.q2WhatAchieved ?? '');
    _q3Controller = TextEditingController(text: p?.q3Obstacles ?? '');
    _q4Controller = TextEditingController(text: p?.q4NextCommitment ?? '');
    _q1Status = p?.q1CompletionStatus;
  }

  @override
  void dispose() {
    _q2Controller.dispose();
    _q3Controller.dispose();
    _q4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meetingAsync = ref.watch(cadenceMeetingProvider(widget.meetingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Meeting Form'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: meetingAsync.when(
        data: (meeting) {
          if (meeting == null) {
            return const Center(child: Text('Meeting not found'));
          }

          return _buildForm(context, meeting);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Form'),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CadenceMeeting meeting) {
    final theme = Theme.of(context);
    final deadline = meeting.formDeadline;
    final isOverdue = DateTime.now().isAfter(deadline);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Deadline warning
          if (isOverdue)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Form deadline has passed. Submitting now will affect your score.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Deadline: ${DateFormat('d MMM yyyy, HH:mm').format(deadline)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          // Q1: Previous Commitment Status
          if (widget.participation?.q1PreviousCommitment != null) ...[
            _buildSectionTitle(context, 'Q1: Previous Commitment'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.participation!.q1PreviousCommitment!,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Did you complete this commitment?',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildQ1Chip(
                          context,
                          CommitmentCompletionStatus.completed,
                          'Completed',
                          AppColors.success,
                        ),
                        _buildQ1Chip(
                          context,
                          CommitmentCompletionStatus.partial,
                          'Partial',
                          AppColors.warning,
                        ),
                        _buildQ1Chip(
                          context,
                          CommitmentCompletionStatus.notDone,
                          'Not Done',
                          AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Q2: What I Achieved
          _buildSectionTitle(context, 'Q2: What I Achieved *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _q2Controller,
            decoration: const InputDecoration(
              hintText: 'Describe your achievements since the last meeting...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe what you achieved';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Q3: Obstacles
          _buildSectionTitle(context, 'Q3: Obstacles (Optional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _q3Controller,
            decoration: const InputDecoration(
              hintText: 'Describe any obstacles you encountered...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Q4: Next Commitment
          _buildSectionTitle(context, 'Q4: Next Commitment *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _q4Controller,
            decoration: const InputDecoration(
              hintText: 'What will you commit to for the next period?',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe your next commitment';
              }
              return null;
            },
          ),
          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQ1Chip(
    BuildContext context,
    CommitmentCompletionStatus status,
    String label,
    Color color,
  ) {
    final isSelected = _q1Status == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _q1Status = selected ? status : null);
      },
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.participation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit: participation not found')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final submission = CadenceFormSubmission(
      participantId: widget.participation!.id,
      q1CompletionStatus: _q1Status,
      q2WhatAchieved: _q2Controller.text.trim(),
      q3Obstacles: _q3Controller.text.trim().isEmpty
          ? null
          : _q3Controller.text.trim(),
      q4NextCommitment: _q4Controller.text.trim(),
    );

    final result = await ref
        .read(cadenceRepositoryProvider)
        .submitPreMeetingForm(submission);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully')),
        );
        context.pop();
      },
    );
  }

  Future<void> _saveDraft() async {
    if (widget.participation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save: participation not found')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final submission = CadenceFormSubmission(
      participantId: widget.participation!.id,
      q1CompletionStatus: _q1Status,
      q2WhatAchieved: _q2Controller.text.trim(),
      q3Obstacles: _q3Controller.text.trim().isEmpty
          ? null
          : _q3Controller.text.trim(),
      q4NextCommitment: _q4Controller.text.trim(),
    );

    final result = await ref
        .read(cadenceRepositoryProvider)
        .saveFormDraft(submission);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved')),
        );
      },
    );
  }
}
