import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/sync/sync_progress_sheet.dart';
import 'tabs/activities_tab.dart';
import 'tabs/customers_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';

/// Home screen content that displays the main tabs.
/// Navigation shell is provided by ResponsiveShell in the router.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.initialTab = 0});

  /// Initial tab index: 0=Dashboard, 1=Customers, 2=Activities, 3=Profile
  final int initialTab;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check if initial sync is needed (for cases when login screen was bypassed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSync();
    });
  }

  /// Check if initial sync has been completed, if not show sync progress sheet.
  /// This is a backup check for cases when login screen was bypassed (e.g., token refresh).
  Future<void> _checkInitialSync() async {
    final appSettings = ref.read(appSettingsServiceProvider);
    final hasInitialSynced = await appSettings.hasInitialSyncCompleted();

    debugPrint('[HomeScreen] Checking initial sync: hasInitialSynced=$hasInitialSynced');

    if (!hasInitialSynced && mounted) {
      // Double-check with a small delay to allow LoginScreen's markInitialSyncCompleted to persist
      await Future.delayed(const Duration(milliseconds: 100));
      final stillNotSynced = !await appSettings.hasInitialSyncCompleted();

      if (stillNotSynced && mounted) {
        debugPrint('[HomeScreen] Initial sync not completed, showing SyncProgressSheet');
        await SyncProgressSheet.show(context);
        // Only mark completed if SyncProgressSheet actually ran (not skipped due to _isShowing)
        final nowSynced = await appSettings.hasInitialSyncCompleted();
        if (!nowSynced) {
          await appSettings.markInitialSyncCompleted();
          debugPrint('[HomeScreen] Initial sync completed and marked');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map initialTab to content
    // 0=Dashboard, 1=Customers, 2=Activities, 3=Profile
    switch (widget.initialTab) {
      case 1:
        return const CustomersTab();
      case 2:
        return const ActivitiesTab();
      case 3:
        return const ProfileTab();
      case 0:
      default:
        return DashboardTab(
          onNotificationsTap: () => context.push(RoutePaths.notifications),
          onSyncTap: () => ref.read(syncNotifierProvider.notifier).triggerSync(),
          onHvcTap: () => context.push(RoutePaths.hvc),
          onBrokerTap: () => context.push(RoutePaths.brokers),
          onScoreboardTap: () => context.push(RoutePaths.scoreboard),
          onCadenceTap: () => context.push(RoutePaths.cadence),
          onSettingsTap: () => context.push(RoutePaths.settings),
          onLogoutTap: () => context.go(RoutePaths.login),
        );
    }
  }
}
