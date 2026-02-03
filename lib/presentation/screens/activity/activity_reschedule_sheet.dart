import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/activity_dtos.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';

/// Bottom sheet for rescheduling an activity.
class ActivityRescheduleSheet extends ConsumerStatefulWidget {
  final Activity activity;
  final VoidCallback? onSuccess;

  const ActivityRescheduleSheet({
    super.key,
    required this.activity,
    this.onSuccess,
  });

  /// Show the reschedule sheet as a modal bottom sheet.
  static Future<Activity?> show(
    BuildContext context, {
    required Activity activity,
  }) {
    return showModalBottomSheet<Activity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ActivityRescheduleSheet(activity: activity),
    );
  }

  @override
  ConsumerState<ActivityRescheduleSheet> createState() =>
      _ActivityRescheduleSheetState();
}

class _ActivityRescheduleSheetState
    extends ConsumerState<ActivityRescheduleSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to same time tomorrow
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      widget.activity.scheduledDatetime.hour,
      widget.activity.scheduledDatetime.minute,
    );
    _selectedTime = TimeOfDay(
      hour: widget.activity.scheduledDatetime.hour,
      minute: widget.activity.scheduledDatetime.minute,
    );
    // Listen to reason text changes to update button state
    _reasonController.addListener(_onReasonChanged);
  }

  void _onReasonChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onReasonChanged);
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(activityFormNotifierProvider);

    // Listen for successful reschedule
    ref.listen<ActivityFormState>(activityFormNotifierProvider, (prev, next) {
      if (prev?.savedActivity == null && next.savedActivity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktivitas berhasil dijadwalkan ulang'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(next.savedActivity);
        widget.onSuccess?.call();
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Jadwalkan Ulang',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Original activity info
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.event, color: AppColors.info),
                        title: Text(widget.activity.displayName),
                        subtitle: Text(
                          'Jadwal awal: ${_formatDateTime(widget.activity.scheduledDatetime)}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // New date selection
                    Text(
                      'Jadwal Baru',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text(_formatDate(_selectedDate)),
                              onTap: () => _selectDate(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.access_time),
                              title: Text(_formatTime(_selectedTime)),
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reason (required)
                    TextFormField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: 'Alasan Reschedule *',
                        hintText: 'Mengapa aktivitas dijadwalkan ulang?',
                        border: const OutlineInputBorder(),
                        helperText: _reasonController.text.isEmpty
                            ? 'Isi alasan untuk mengaktifkan tombol'
                            : null,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    FilledButton.icon(
                      onPressed: _reasonController.text.isNotEmpty &&
                              !formState.isLoading
                          ? _submitReschedule
                          : null,
                      icon: formState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.schedule),
                      label: Text(formState.isLoading
                          ? 'Menyimpan...'
                          : 'Jadwalkan Ulang'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),

                    if (formState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          formState.errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitReschedule() {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan reschedule wajib diisi'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final newDatetime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final dto = ActivityRescheduleDto(
      newScheduledDatetime: newDatetime,
      reason: _reasonController.text,
    );

    ref
        .read(activityFormNotifierProvider.notifier)
        .rescheduleActivity(widget.activity.id, dto);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == tomorrow) {
      return 'Besok';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
