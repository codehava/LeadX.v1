import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../providers/settings_providers.dart';
import '../../providers/sync_providers.dart';

/// Settings screen for theme and app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Tampilan'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema Aplikasi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Terang'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Gelap'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Sistem'),
                        icon: Icon(Icons.settings_suggest_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref.read(themeModeNotifierProvider.notifier).setThemeMode(newSelection.first);
                    },
                    showSelectedIcon: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih tema yang sesuai dengan preferensi Anda',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // App Settings Section
          _buildSectionHeader(context, 'Aplikasi'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Pengaturan Notifikasi'),
                  subtitle: const Text('Atur preferensi notifikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to notification settings when implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengaturan notifikasi akan segera hadir'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSyncListTile(context, ref),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'Tentang'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.info_outlined),
              title: const Text('Tentang Aplikasi'),
              subtitle: const Text('Versi, lisensi, dan informasi lainnya'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.pushNamed(RouteNames.about);
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSyncListTile(BuildContext context, WidgetRef ref) {
    final dlCount = ref.watch(deadLetterCountProvider);
    final lastSync = ref.watch(lastSyncTimestampProvider);
    final count = dlCount.valueOrNull ?? 0;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.sync_outlined),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: const Text('Sinkronisasi'),
      subtitle: Text(_formatLastSync(lastSync.valueOrNull)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push('/home/sync-queue');
      },
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

/// Format a last sync timestamp into a user-friendly Indonesian relative string.
String _formatLastSync(DateTime? lastSync) {
  if (lastSync == null) return 'Belum pernah sinkronisasi';
  final diff = DateTime.now().difference(lastSync);
  if (diff.inMinutes < 1) return 'Terakhir sinkronisasi: baru saja';
  if (diff.inMinutes < 60) {
    return 'Terakhir sinkronisasi: ${diff.inMinutes} menit lalu';
  }
  if (diff.inHours < 24) {
    return 'Terakhir sinkronisasi: ${diff.inHours} jam lalu';
  }
  return 'Terakhir sinkronisasi: ${diff.inDays} hari lalu';
}
