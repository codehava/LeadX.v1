import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/activity_card.dart';
import '../widgets/home_drawer.dart';
import '../widgets/stat_card.dart';

/// Dashboard tab showing today's summary and activities.
class DashboardTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LeadX CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: onNotificationsTap,
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync',
            onPressed: () {
              onSyncTap?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing...')),
              );
            },
          ),
        ],
      ),
      drawer: HomeDrawer(
        userName: 'User Name', // TODO: Get from auth state
        userRole: 'Relationship Manager',
        onHvcTap: () {
          Navigator.pop(context);
          onHvcTap?.call();
        },
        onBrokerTap: () {
          Navigator.pop(context);
          onBrokerTap?.call();
        },
        onScoreboardTap: () {
          Navigator.pop(context);
          onScoreboardTap?.call();
        },
        onCadenceTap: () {
          Navigator.pop(context);
          onCadenceTap?.call();
        },
        onSettingsTap: () {
          Navigator.pop(context);
          onSettingsTap?.call();
        },
        onLogoutTap: () {
          Navigator.pop(context);
          onLogoutTap?.call();
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
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

            // Stats row
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Aktivitas Hari Ini',
                    value: '3/5',
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
            const SizedBox(height: 24),

            // Today's activities section
            Text(
              'Aktivitas Hari Ini',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            const ActivityCard(
              title: 'Visit PT ABC Indonesia',
              time: '09:00',
              icon: Icons.location_on,
              statusColor: AppColors.activityCompleted,
              status: 'Selesai',
            ),
            const SizedBox(height: 8),
            const ActivityCard(
              title: 'Call PT XYZ Manufacturing',
              time: '11:00',
              icon: Icons.phone,
              statusColor: AppColors.activityPlanned,
              status: 'Dijadwalkan',
            ),
            const SizedBox(height: 8),
            const ActivityCard(
              title: 'Meeting PT 123 Corp',
              time: '14:00',
              icon: Icons.people,
              statusColor: AppColors.activityOverdue,
              status: 'Terlambat',
            ),
          ],
        ),
      ),
    );
  }
}
