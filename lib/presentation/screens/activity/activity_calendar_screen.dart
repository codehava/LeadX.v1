import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';

/// Activity calendar screen for viewing activities in calendar/list view.
class ActivityCalendarScreen extends ConsumerWidget {
  const ActivityCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final viewMode = ref.watch(calendarViewModeProvider);

    // Get start/end of selected month for activity query
    final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);

    final activitiesAsync = ref.watch(
      userActivitiesProvider((startDate: startOfMonth, endDate: endOfMonth)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Aktivitas'),
        actions: [
          PopupMenuButton<CalendarViewMode>(
            initialValue: viewMode,
            onSelected: (mode) {
              ref.read(calendarViewModeProvider.notifier).state = mode;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarViewMode.day,
                child: Text('Harian'),
              ),
              const PopupMenuItem(
                value: CalendarViewMode.week,
                child: Text('Mingguan'),
              ),
              const PopupMenuItem(
                value: CalendarViewMode.month,
                child: Text('Bulanan'),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.view_module),
            ),
          ),
        ],
      ),
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
                    ref.read(selectedDateProvider.notifier).state =
                        DateTime(selectedDate.year, selectedDate.month - 1, 1);
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _formatMonthYear(selectedDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        DateTime(selectedDate.year, selectedDate.month + 1, 1);
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Simple date picker row
          SizedBox(
            height: 80,
            child: _buildWeekView(
              context, 
              ref, 
              selectedDate, 
              activitiesAsync.valueOrNull,
            ),
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

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userActivitiesProvider((startDate: startOfMonth, endDate: endOfMonth)));
                  },
                  child: dayActivities.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dayActivities.length,
                          itemBuilder: (context, index) {
                            final activity = dayActivities[index];
                            return _ActivityListTile(
                              activity: activity,
                              onTap: () {
                                context.go('/home/activities/${activity.id}');
                              },
                            );
                          },
                        ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/home/activities/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, WidgetRef ref, DateTime selectedDate, [List<Activity>? activities]) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // Get the week containing the selected date
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    
    // Count activities per day
    Map<int, int> activityCountByDay = {};
    if (activities != null) {
      for (final activity in activities) {
        final day = activity.scheduledDatetime.day;
        activityCountByDay[day] = (activityCountByDay[day] ?? 0) + 1;
      }
    }
    
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
        final activityCount = activityCountByDay[date.day] ?? 0;

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
                  // Activity indicator dots
                  const SizedBox(height: 2),
                  if (activityCount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < (activityCount > 3 ? 3 : activityCount); i++)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : AppColors.primary,
                            ),
                          ),
                      ],
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
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

  const _ActivityListTile({
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withValues(alpha: 0.2),
          child: Icon(
            _getTypeIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        title: Text(
          activity.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(activity.scheduledDatetime),
              style: theme.textTheme.bodySmall,
            ),
            if (activity.objectName != null)
              Text(
                activity.objectName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Container(
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
        isThreeLine: activity.objectName != null,
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
