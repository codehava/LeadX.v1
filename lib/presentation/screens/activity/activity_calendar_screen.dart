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

    // Get start/end of 31-day range for activity query (15 days before today to 15 days after)
    final today = DateTime.now();
    final startOfRange = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 15));
    final endOfRange = DateTime(today.year, today.month, today.day, 23, 59, 59).add(const Duration(days: 15));

    final activitiesAsync = ref.watch(
      userActivitiesProvider((startDate: startOfRange, endDate: endOfRange)),
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
                    // Navigate to previous week
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 7));
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      ref.read(selectedDateProvider.notifier).state = picked;
                    }
                  },
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
                    ref.invalidate(userActivitiesProvider((startDate: startOfRange, endDate: endOfRange)));
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
    
    // 31 days view: 15 days before today + today + 15 days after
    const totalDays = 31;
    const todayIndex = 15; // Today is at index 15 (0-indexed, center of 31 days)
    final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: todayIndex));
    
    // Count activities per day (using date string as key for cross-month support)
    Map<String, int> activityCountByDate = {};
    if (activities != null) {
      for (final activity in activities) {
        final d = activity.scheduledDatetime;
        final key = '${d.year}-${d.month}-${d.day}';
        activityCountByDate[key] = (activityCountByDate[key] ?? 0) + 1;
      }
    }
    
    return _ScrollableDayPicker(
      totalDays: totalDays,
      todayIndex: todayIndex,
      startDate: startDate,
      selectedDate: selectedDate,
      today: today,
      activityCountByDate: activityCountByDate,
      onDateSelected: (date) {
        ref.read(selectedDateProvider.notifier).state = date;
      },
      getDayName: _getDayName,
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

/// Scrollable day picker widget with 31 days centered on today.
class _ScrollableDayPicker extends StatefulWidget {
  final int totalDays;
  final int todayIndex;
  final DateTime startDate;
  final DateTime selectedDate;
  final DateTime today;
  final Map<String, int> activityCountByDate;
  final ValueChanged<DateTime> onDateSelected;
  final String Function(int) getDayName;

  const _ScrollableDayPicker({
    required this.totalDays,
    required this.todayIndex,
    required this.startDate,
    required this.selectedDate,
    required this.today,
    required this.activityCountByDate,
    required this.onDateSelected,
    required this.getDayName,
  });

  @override
  State<_ScrollableDayPicker> createState() => _ScrollableDayPickerState();
}

class _ScrollableDayPickerState extends State<_ScrollableDayPicker> {
  late ScrollController _scrollController;
  static const double _itemWidth = 56.0; // 48 width + 8 padding

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    if (!_scrollController.hasClients) return;
    
    // Calculate the offset to center today
    final viewportWidth = _scrollController.position.viewportDimension;
    final todayOffset = widget.todayIndex * _itemWidth;
    final centeredOffset = todayOffset - (viewportWidth / 2) + (_itemWidth / 2);
    
    _scrollController.jumpTo(
      centeredOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.totalDays,
      itemBuilder: (context, index) {
        final date = widget.startDate.add(Duration(days: index));
        final isSelected = date.day == widget.selectedDate.day &&
            date.month == widget.selectedDate.month &&
            date.year == widget.selectedDate.year;
        final isToday = date.day == widget.today.day &&
            date.month == widget.today.month &&
            date.year == widget.today.year;
        final dateKey = '${date.year}-${date.month}-${date.day}';
        final activityCount = widget.activityCountByDate[dateKey] ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () {
              widget.onDateSelected(date);
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
                    widget.getDayName(date.weekday),
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
}
