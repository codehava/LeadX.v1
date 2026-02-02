import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/activity.dart';
import '../../../providers/activity_providers.dart';
import '../../activity/activity_execution_sheet.dart';
import '../../activity/immediate_activity_sheet.dart';

/// Activities tab showing activity calendar and list.
class ActivitiesTab extends ConsumerStatefulWidget {
  const ActivitiesTab({super.key});

  @override
  ConsumerState<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends ConsumerState<ActivitiesTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);

    // Get start/end of selected month for activity query
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);

    final activitiesAsync = ref.watch(
      userActivitiesProvider((startDate: startOfMonth, endDate: endOfMonth)),
    );

    return Scaffold(
      body: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate to previous week
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 7));
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Text(
                    _formatMonthYear(selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Navigate to next week
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 7));
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Week view date picker
          SizedBox(
            height: 80,
            child: _buildWeekView(context, ref, selectedDate),
          ),

          const Divider(),

          // Activities list
          Expanded(
            child: activitiesAsync.when(
              data: (activities) {
                // Filter to selected date
                final dayActivities = activities.where((a) {
                  final d = a.scheduledDatetime;
                  return d.year == selectedDate.year &&
                      d.month == selectedDate.month &&
                      d.day == selectedDate.day;
                }).toList();

                if (dayActivities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada aktivitas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () =>
                              context.push(RoutePaths.activityCreate),
                          icon: const Icon(Icons.add),
                          label: const Text('Jadwalkan Aktivitas'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userActivitiesProvider(
                        (startDate: startOfMonth, endDate: endOfMonth)));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayActivities.length,
                    itemBuilder: (context, index) {
                      final activity = dayActivities[index];
                      return _ActivityListTile(
                        activity: activity,
                        onTap: () {
                          context.push('/home/activities/${activity.id}');
                        },
                        onExecute: activity.canExecute
                            ? () => _executeActivity(activity)
                            : null,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error: $e'),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(userActivitiesProvider(
                          (startDate: startOfMonth, endDate: endOfMonth))),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'activities_tab_immediate_fab',
            onPressed: _showImmediateSheet,
            backgroundColor: AppColors.tertiary,
            tooltip: 'Log Aktivitas Sekarang',
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'activities_tab_schedule_fab',
            onPressed: () => context.push(RoutePaths.activityCreate),
            tooltip: 'Jadwalkan Aktivitas',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(
      BuildContext context, WidgetRef ref, DateTime selectedDate) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    // Get the week containing the selected date
    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected = date.day == selectedDate.day &&
            date.month == selectedDate.month &&
            date.year == selectedDate.year;
        final isToday = date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
            },
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primaryContainer
                        : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                              ? theme.colorScheme.primary
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  void _showImmediateSheet() {
    // Navigate to activity form with immediate=true
    context.push('${RoutePaths.activityCreate}?immediate=true');
  }

  void _executeActivity(Activity activity) {
    ActivityExecutionSheet.show(
      context,
      activity: activity,
    );
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Activity list tile for calendar view.
class _ActivityListTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final VoidCallback? onExecute;

  const _ActivityListTile({
    required this.activity,
    required this.onTap,
    this.onExecute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor().withValues(alpha: 0.2),
                child: Icon(
                  _getTypeIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatTime(activity.scheduledDatetime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (activity.objectName != null) ...[
                          Text(
                            ' • ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              activity.objectName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.statusText,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onExecute != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onExecute,
                  icon: const Icon(Icons.play_circle_fill),
                  color: AppColors.success,
                  tooltip: 'Eksekusi',
                ),
              ],
            ],
          ),
        ),
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

  IconData _getTypeIcon() {
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
      default:
        return Icons.event;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Sheet for selecting object type for activity creation.
/// For immediate activities, navigates to object search then shows ImmediateActivitySheet.
/// For scheduled activities, navigates to activity create form with object type pre-selected.
class _ObjectSelectorSheet extends ConsumerStatefulWidget {
  final bool isImmediate;
  
  const _ObjectSelectorSheet({this.isImmediate = false});

  @override
  ConsumerState<_ObjectSelectorSheet> createState() =>
      _ObjectSelectorSheetState();
}

class _ObjectSelectorSheetState extends ConsumerState<_ObjectSelectorSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImmediate = widget.isImmediate;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
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
                        isImmediate ? 'Log Aktivitas Sekarang' : 'Jadwalkan Aktivitas',
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

              // Info for immediate mode
              if (isImmediate)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: AppColors.info.withValues(alpha: 0.1),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pilih tipe objek, lalu pilih objek spesifik untuk log aktivitas segera.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const Divider(),

              // Object type options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ObjectTypeCard(
                      icon: Icons.business,
                      title: 'Customer',
                      subtitle: isImmediate 
                          ? 'Pilih customer untuk log aktivitas' 
                          : 'Jadwalkan aktivitas untuk customer',
                      onTap: () {
                        Navigator.pop(context);
                        if (isImmediate) {
                          // Navigate to customers list - user can tap a customer then use immediate sheet
                          context.push('/home/customers');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih customer, lalu gunakan tombol flash untuk log aktivitas'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          context.push(
                              '${RoutePaths.activityCreate}?objectType=CUSTOMER');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _ObjectTypeCard(
                      icon: Icons.star,
                      title: 'HVC',
                      subtitle: isImmediate 
                          ? 'Pilih HVC untuk log aktivitas' 
                          : 'Jadwalkan aktivitas untuk High Value Customer',
                      onTap: () {
                        Navigator.pop(context);
                        if (isImmediate) {
                          // Navigate to HVC list
                          context.push('/home/hvc');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih HVC, lalu gunakan tombol flash untuk log aktivitas'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          context.push('${RoutePaths.activityCreate}?objectType=HVC');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _ObjectTypeCard(
                      icon: Icons.handshake,
                      title: 'Broker',
                      subtitle: isImmediate 
                          ? 'Pilih broker untuk log aktivitas' 
                          : 'Jadwalkan aktivitas untuk Broker',
                      onTap: () {
                        Navigator.pop(context);
                        if (isImmediate) {
                          // Navigate to brokers list
                          context.push('/home/brokers');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih broker, lalu gunakan tombol flash untuk log aktivitas'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else {
                          context.push(
                              '${RoutePaths.activityCreate}?objectType=BROKER');
                        }
                      },
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
}

class _ObjectTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ObjectTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
