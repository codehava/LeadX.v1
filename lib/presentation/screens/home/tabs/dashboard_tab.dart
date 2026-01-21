import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/activity.dart';
import '../../../providers/activity_providers.dart';
import '../widgets/stat_card.dart';

/// Dashboard tab showing today's summary and activities.
class DashboardTab extends ConsumerWidget {
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onHvcTap;
  final VoidCallback? onBrokerTap;
  final VoidCallback? onScoreboardTap;
  final VoidCallback? onCadenceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  const DashboardTab({
    super.key,
    this.onNotificationsTap,
    this.onSyncTap,
    this.onHvcTap,
    this.onBrokerTap,
    this.onScoreboardTap,
    this.onCadenceTap,
    this.onSettingsTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch today's activities
    final todayActivitiesAsync = ref.watch(todayActivitiesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayActivitiesProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang! 👋',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hari ini adalah waktu yang tepat untuk closing!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row - with real activity count
          todayActivitiesAsync.when(
            data: (activities) {
              final completed =
                  activities.where((a) => a.isCompleted).length;
              final total = activities.length;
              return Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Aktivitas Hari Ini',
                      value: '$completed/$total',
                      icon: Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: StatCard(
                      label: 'Pipeline Aktif',
                      value: '12',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: StatCard(
                      label: 'Ranking',
                      value: '#5',
                      icon: Icons.emoji_events,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Aktivitas Hari Ini',
                    value: '-',
                    icon: Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Pipeline Aktif',
                    value: '12',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Ranking',
                    value: '#5',
                    icon: Icons.emoji_events,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
            error: (_, __) => const Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Aktivitas Hari Ini',
                    value: '0/0',
                    icon: Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Pipeline Aktif',
                    value: '12',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Ranking',
                    value: '#5',
                    icon: Icons.emoji_events,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's activities section header with Calendar button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Hari Ini',
                style: theme.textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  context.go('/home/activity/calendar');
                },
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text('Lihat Kalender'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Today's activities list - real data
          todayActivitiesAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada aktivitas hari ini',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            context.go('/home/activities/create');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Jadwalkan Aktivitas'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: activities.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DashboardActivityCard(
                      activity: activity,
                      onTap: () {
                        context.go('/home/activities/${activity.id}');
                      },
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat aktivitas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () {
                          // TODO: Show immediate activity sheet
                          context.go('/home/activities/create?immediate=true');
                        },
                        icon: const Icon(Icons.flash_on, size: 18),
                        label: const Text('Log Aktivitas'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          context.go('/home/activities/create');
                        },
                        icon: const Icon(Icons.event, size: 18),
                        label: const Text('Jadwalkan'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          context.go('/home/activity/calendar');
                        },
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text('Kalender'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple activity card for dashboard display.
class _DashboardActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const _DashboardActivityCard({
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withValues(alpha: 0.1),
          child: Icon(_getTypeIcon(), color: _getStatusColor()),
        ),
        title: Text(
          activity.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatTime(activity.scheduledDatetime)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            activity.statusText,
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
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
