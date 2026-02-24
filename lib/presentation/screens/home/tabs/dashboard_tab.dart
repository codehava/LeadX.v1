import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_last_sync.dart';
import '../../../../domain/entities/activity.dart';
import '../../../../core/utils/period_type_helpers.dart';
import '../../../providers/activity_providers.dart';
import '../../../providers/pipeline_providers.dart';
import '../../../providers/scoreboard_providers.dart';
import '../../../providers/sync_providers.dart';
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
    
    // Watch pipelines and scoreboard
    final pipelinesAsync = ref.watch(pipelineListStreamProvider);
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);

    // Watch last sync timestamp for staleness display
    final lastSyncAsync = ref.watch(lastSyncTimestampProvider);

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
                  const SizedBox(height: 8),
                  // Last synced timestamp with staleness warning
                  lastSyncAsync.when(
                    data: (lastSync) {
                      final text = formatLastSync(lastSync);
                      final isStale = lastSync != null &&
                          DateTime.now().difference(lastSync) >
                              const Duration(hours: 1);

                      return Row(
                        children: [
                          Icon(
                            Icons.sync,
                            size: 14,
                            color: isStale
                                ? Colors.orange.shade700
                                : theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            text,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: isStale
                                  ? Colors.orange.shade700
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
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
                  Expanded(
                    child: pipelinesAsync.when(
                      data: (pipelines) => StatCard(
                        label: 'Pipeline Aktif',
                        value: '${pipelines.length}',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                      loading: () => const StatCard(
                        label: 'Pipeline Aktif',
                        value: '-',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                      error: (_, _) => const StatCard(
                        label: 'Pipeline Aktif',
                        value: '0',
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dashboardStatsAsync.when(
                      data: (stats) {
                        final periodAsync = ref.watch(currentPeriodProvider);
                        final periodLabel = periodAsync.whenOrNull(
                          data: (p) => p != null
                              ? formatPeriodType(p.periodType)
                              : null,
                        );
                        return StatCard(
                          label: periodLabel != null
                              ? 'Ranking $periodLabel'
                              : 'Ranking',
                          value: stats.userRank != null ? '#${stats.userRank}' : '-',
                          icon: Icons.emoji_events,
                          color: AppColors.tertiary,
                          onTap: () => context.go('/home/scoreboard'),
                        );
                      },
                      loading: () => const StatCard(
                        label: 'Ranking',
                        value: '-',
                        icon: Icons.emoji_events,
                        color: AppColors.tertiary,
                      ),
                      error: (_, _) => StatCard(
                        label: 'Ranking',
                        value: '-',
                        icon: Icons.emoji_events,
                        color: AppColors.tertiary,
                        onTap: () => context.go('/home/scoreboard'),
                      ),
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
            error: (_, _) => const Row(
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Access to Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Lainnya',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _QuickAccessItem(
                        icon: Icons.star,
                        label: 'HVC',
                        color: AppColors.tertiary,
                        onTap: onHvcTap ?? () => context.go('/home/hvcs'),
                      ),
                      _QuickAccessItem(
                        icon: Icons.handshake,
                        label: 'Broker',
                        color: AppColors.info,
                        onTap: onBrokerTap ?? () => context.go('/home/brokers'),
                      ),
                      _QuickAccessItem(
                        icon: Icons.leaderboard,
                        label: 'Scoreboard',
                        color: AppColors.success,
                        onTap: onScoreboardTap ?? () => context.go('/home/scoreboard'),
                      ),
                      _QuickAccessItem(
                        icon: Icons.groups,
                        label: 'Cadence',
                        color: AppColors.warning,
                        onTap: onCadenceTap ?? () => context.go('/home/cadence'),
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

/// Quick access item for feature navigation.
class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
