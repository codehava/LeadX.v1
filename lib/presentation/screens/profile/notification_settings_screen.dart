import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notification_settings_providers.dart';
import '../../widgets/common/error_state.dart';

/// Notification settings screen with toggle UI for 7 notification categories
/// and a reminder time dropdown.
///
/// All settings persist immediately to local Drift database.
/// No save button needed -- changes are applied on toggle.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState.general(
          message: error.toString(),
        ),
        data: (settings) {
          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // General Section
              _buildSectionHeader(context, 'Umum'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Push Notification'),
                      subtitle:
                          const Text('Terima notifikasi push di perangkat'),
                      value: settings.pushEnabled,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updatePushEnabled(value: value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Email Notification'),
                      subtitle:
                          const Text('Terima notifikasi melalui email'),
                      value: settings.emailEnabled,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updateEmailEnabled(value: value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories Section
              _buildSectionHeader(context, 'Kategori'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Pengingat Aktivitas'),
                      subtitle: const Text(
                          'Pengingat sebelum aktivitas terjadwal'),
                      value: settings.activityReminders,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updateActivityReminders(value: value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Update Pipeline'),
                      subtitle: const Text(
                          'Perubahan status dan tahapan pipeline'),
                      value: settings.pipelineUpdates,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updatePipelineUpdates(value: value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Notifikasi Referral'),
                      subtitle: const Text(
                          'Status persetujuan dan update referral'),
                      value: settings.referralNotifications,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updateReferralNotifications(value: value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Pengingat Cadence'),
                      subtitle: const Text(
                          'Jadwal pertemuan cadence mingguan'),
                      value: settings.cadenceReminders,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updateCadenceReminders(value: value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Notifikasi Sistem'),
                      subtitle: const Text(
                          'Pembaruan sistem dan maintenance'),
                      value: settings.systemNotifications,
                      onChanged: (value) async {
                        final notifier = await ref.read(
                            notificationSettingsNotifierProvider.future);
                        await notifier?.updateSystemNotifications(value: value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Timing Section
              _buildSectionHeader(context, 'Waktu Pengingat'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  title: const Text('Pengingat Sebelum Aktivitas'),
                  subtitle: Text(
                      '${settings.reminderMinutesBefore} menit sebelum'),
                  trailing: PopupMenuButton<int>(
                    initialValue: settings.reminderMinutesBefore,
                    onSelected: (value) async {
                      final notifier = await ref.read(
                          notificationSettingsNotifierProvider.future);
                      await notifier?.updateReminderMinutesBefore(value: value);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 5, child: Text('5 menit')),
                      PopupMenuItem(value: 10, child: Text('10 menit')),
                      PopupMenuItem(value: 15, child: Text('15 menit')),
                      PopupMenuItem(value: 30, child: Text('30 menit')),
                      PopupMenuItem(value: 60, child: Text('60 menit')),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
