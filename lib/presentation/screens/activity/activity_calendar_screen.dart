import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/hvc_providers.dart';
import 'activity_execution_sheet.dart';

/// Full-screen activity calendar with month view.
/// Tapping a day shows a bottom sheet with that day's activities.
class ActivityCalendarScreen extends ConsumerStatefulWidget {
  const ActivityCalendarScreen({super.key});

  @override
  ConsumerState<ActivityCalendarScreen> createState() =>
      _ActivityCalendarScreenState();
}

class _ActivityCalendarScreenState extends ConsumerState<ActivityCalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get start/end of current month for activity query
    final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final endOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);

    final activitiesAsync = ref.watch(
      userActivitiesProvider((startDate: startOfMonth, endDate: endOfMonth)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Aktivitas'),
      ),
      body: Column(
        children: [
          // Month navigation header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                GestureDetector(
                  onTap: () => _selectMonth(context),
                  child: Text(
                    _formatMonthYear(_currentMonth),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Day of week headers
          _buildDayHeaders(theme),

          const Divider(height: 1),

          // Calendar grid
          Expanded(
            child: activitiesAsync.when(
              data: (activities) => _buildCalendarGrid(
                context,
                theme,
                activities,
              ),
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

  Widget _buildDayHeaders(ThemeData theme) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: days.map((day) {
          final isWeekend = day == 'Sab' || day == 'Min';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? theme.colorScheme.error.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    ThemeData theme,
    List<Activity> activities,
  ) {
    final today = DateTime.now();
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Monday = 1, Sunday = 7 in Dart
    // We want Monday as first day, so offset is (weekday - 1)
    final firstWeekday = firstDayOfMonth.weekday;
    final leadingEmptyDays = firstWeekday - 1;

    // Count activities per day
    final activitiesByDay = <int, List<Activity>>{};
    for (final activity in activities) {
      final d = activity.scheduledDatetime;
      if (d.month == _currentMonth.month && d.year == _currentMonth.year) {
        activitiesByDay.putIfAbsent(d.day, () => []).add(activity);
      }
    }

    // Total cells needed (leading empty + days in month)
    final totalCells = leadingEmptyDays + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: rowCount * 7,
      itemBuilder: (context, index) {
        final dayNumber = index - leadingEmptyDays + 1;

        // Empty cell for leading days or trailing days
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final isToday = date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;
        final isWeekend = date.weekday == 6 || date.weekday == 7;
        final dayActivities = activitiesByDay[dayNumber] ?? [];
        final activityCount = dayActivities.length;

        return _CalendarDayCell(
          day: dayNumber,
          isToday: isToday,
          isWeekend: isWeekend,
          activityCount: activityCount,
          activities: dayActivities,
          onTap: () => _showDayActivities(context, date, dayActivities),
        );
      },
    );
  }

  void _showDayActivities(
    BuildContext context,
    DateTime date,
    List<Activity> activities,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DayActivitiesSheet(
        date: date,
        activities: activities,
        onActivityTap: (activity) {
          Navigator.pop(context);
          context.push('/home/activities/${activity.id}');
        },
        onExecute: (activity) {
          Navigator.pop(context);
          _executeActivity(activity);
        },
      ),
    );
  }

  void _executeActivity(Activity activity) {
    double? targetLat;
    double? targetLon;

    switch (activity.objectType) {
      case ActivityObjectType.customer:
        if (activity.customerId != null) {
          final customer =
              ref.read(customerDetailProvider(activity.customerId!)).value;
          targetLat = customer?.latitude;
          targetLon = customer?.longitude;
        }
        break;
      case ActivityObjectType.broker:
        if (activity.brokerId != null) {
          final broker =
              ref.read(brokerDetailProvider(activity.brokerId!)).value;
          targetLat = broker?.latitude;
          targetLon = broker?.longitude;
        }
        break;
      case ActivityObjectType.hvc:
        if (activity.hvcId != null) {
          final hvc = ref.read(hvcDetailProvider(activity.hvcId!)).value;
          targetLat = hvc?.latitude;
          targetLon = hvc?.longitude;
        }
        break;
    }

    ActivityExecutionSheet.show(
      context,
      activity: activity,
      targetLat: targetLat,
      targetLon: targetLon,
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month);
      });
    }
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
}

/// Calendar day cell widget.
class _CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isWeekend;
  final int activityCount;
  final List<Activity> activities;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.isToday,
    required this.isWeekend,
    required this.activityCount,
    required this.activities,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status colors for the day
    Color? statusIndicatorColor;
    if (activities.isNotEmpty) {
      final hasOverdue =
          activities.any((a) => a.status == ActivityStatus.overdue);
      final hasPlanned =
          activities.any((a) => a.status == ActivityStatus.planned);
      final allCompleted =
          activities.every((a) => a.status == ActivityStatus.completed);

      if (hasOverdue) {
        statusIndicatorColor = AppColors.error;
      } else if (allCompleted) {
        statusIndicatorColor = AppColors.success;
      } else if (hasPlanned) {
        statusIndicatorColor = AppColors.info;
      }
    }

    return Material(
      color: isToday
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isWeekend
                      ? theme.colorScheme.error.withValues(alpha: 0.8)
                      : isToday
                          ? theme.colorScheme.primary
                          : null,
                ),
              ),
              const SizedBox(height: 4),
              if (activityCount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < (activityCount > 3 ? 3 : activityCount); i++)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusIndicatorColor ?? AppColors.primary,
                        ),
                      ),
                    if (activityCount > 3)
                      Text(
                        '+',
                        style: TextStyle(
                          fontSize: 10,
                          color: statusIndicatorColor ?? AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet showing activities for a selected day.
class _DayActivitiesSheet extends StatelessWidget {
  final DateTime date;
  final List<Activity> activities;
  final ValueChanged<Activity> onActivityTap;
  final ValueChanged<Activity> onExecute;

  const _DayActivitiesSheet({
    required this.date,
    required this.activities,
    required this.onActivityTap,
    required this.onExecute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatFullDate(date),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${activities.length} aktivitas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Activities list
              Expanded(
                child: activities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 48,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada aktivitas',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return _ActivityListTile(
                            activity: activity,
                            onTap: () => onActivityTap(activity),
                            onExecute:
                                activity.canExecute ? () => onExecute(activity) : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatFullDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
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
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

/// Activity list tile for the day activities sheet.
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
