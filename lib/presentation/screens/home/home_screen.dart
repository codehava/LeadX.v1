import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/common/sync_status_badge.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../widgets/sync/sync_progress_sheet.dart';
import '../sync/sync_queue_screen.dart';
import 'tabs/activities_tab.dart';
import 'tabs/customers_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';
import 'widgets/home_drawer.dart';
import 'widgets/quick_add_sheet.dart';

/// Home screen with responsive navigation.
/// - Mobile: Bottom Navigation
/// - Tablet: Navigation Rail
/// - Desktop: Sidebar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.initialTab = 0});

  /// Initial tab index: 0=Dashboard, 1=Customers, 3=Activities, 4=Profile
  final int initialTab;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    // Check if initial sync is needed (for cases when login screen was bypassed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSync();
    });
  }

  /// Check if initial sync has been completed, if not show sync progress sheet.
  Future<void> _checkInitialSync() async {
    final appSettings = ref.read(appSettingsServiceProvider);
    final hasInitialSynced = await appSettings.hasInitialSyncCompleted();
    
    print('[HomeScreen] Checking initial sync: hasInitialSynced=$hasInitialSynced');
    
    if (!hasInitialSynced && mounted) {
      print('[HomeScreen] Initial sync not completed, showing SyncProgressSheet');
      await SyncProgressSheet.show(context);
      await appSettings.markInitialSyncCompleted();
      print('[HomeScreen] Initial sync completed and marked');
    }
  }

  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavigationItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Customers',
    ),
    _NavigationItem(
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Add',
    ),
    _NavigationItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Activities',
    ),
    _NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  Widget _buildContent() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        DashboardTab(
          onNotificationsTap: () => context.push(RoutePaths.notifications),
          onSyncTap: _handleSync,
          onHvcTap: () => context.push(RoutePaths.hvc),
          onBrokerTap: () => context.push(RoutePaths.brokers),
          onScoreboardTap: () => context.push(RoutePaths.scoreboard),
          onCadenceTap: () => context.push(RoutePaths.cadence),
          onSettingsTap: () => context.push(RoutePaths.settings),
          onLogoutTap: _handleLogout,
        ),
        const CustomersTab(),
        const SizedBox.shrink(), // Placeholder for Add button
        const ActivitiesTab(),
        const ProfileTab(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  /// Mobile: Bottom Navigation
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Tablet: Navigation Rail
  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildNavigationRail(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// Desktop: Sidebar
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _buildDesktopTopBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('LeadX CRM'),
      actions: [
        // Sync progress indicator (shows when syncing)
        const SyncProgressIndicator(),
        // Sync status badge with tap to sync
        _buildSyncButton(),
        // Debug: View sync queue
        IconButton(
          icon: const Icon(Icons.bug_report_outlined),
          tooltip: 'Debug: View Sync Queue',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SyncQueueScreen()),
          ),
        ),
        // Notifications
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () => context.push(RoutePaths.notifications),
        ),
      ],
    );
  }

  Widget _buildSyncButton() {
    final isConnected = ref.watch(connectivityStreamProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);
    final syncNotifier = ref.watch(syncNotifierProvider);

    SyncStatus status;
    if (!(isConnected.value ?? true)) {
      status = SyncStatus.offline;
    } else if (syncNotifier.isLoading) {
      status = SyncStatus.pending;
    } else if ((pendingCount.value ?? 0) > 0) {
      status = SyncStatus.pending;
    } else {
      status = SyncStatus.synced;
    }

    return Stack(
      children: [
        GestureDetector(
          onLongPress: () async {
            // Long press = force re-sync master data
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Re-sync Master Data?'),
                content: const Text(
                  'Ini akan mengunduh ulang semua data master (provinsi, kota, tipe perusahaan, dll) dari server.\n\n'
                  'Gunakan jika dropdown tidak menampilkan data.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Re-sync'),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              await SyncProgressSheet.show(context);
            }
          },
          child: IconButton(
            icon: SyncStatusBadge(status: status),
            tooltip: 'Sync (tahan untuk re-sync master data)',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sinkronisasi dimulai...'),
                  duration: Duration(seconds: 1),
                ),
              );
              await ref.read(syncNotifierProvider.notifier).triggerSync();
              if (context.mounted) {
                final result = ref.read(syncNotifierProvider).value;
                if (result != null) {
                  final message = result.success
                      ? result.processedCount > 0
                          ? 'Sinkronisasi selesai: ${result.successCount} item berhasil'
                          : 'Tidak ada item untuk disinkronkan'
                      : 'Sinkronisasi gagal: ${result.errors.firstOrNull ?? "Unknown error"}';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: result.success ? null : Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
        // Badge for pending count
        if ((pendingCount.value ?? 0) > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${pendingCount.value}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      items: _navigationItems
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              ))
          .toList(),
    );
  }

  Widget _buildNavigationRail() {
    // Filter out Add button for rail, use FAB instead
    final railItems = _navigationItems
        .where((item) => item.label != 'Add')
        .toList();
    
    // Adjust index for rail (skip Add button at index 2)
    int railIndex = _currentIndex;
    if (_currentIndex > 2) railIndex = _currentIndex - 1;
    if (_currentIndex == 2) railIndex = 0; // Default to home if on Add

    return NavigationRail(
      selectedIndex: railIndex,
      onDestinationSelected: (index) {
        // Convert rail index back to full index
        int fullIndex = index;
        if (index >= 2) fullIndex = index + 1;
        _onTabTapped(fullIndex);
      },
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FloatingActionButton(
          heroTag: 'home_nav_rail_fab',
          elevation: 0,
          onPressed: _showQuickAddSheet,
          child: const Icon(Icons.add),
        ),
      ),
      destinations: railItems
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    final width = context.screenWidth >= Breakpoints.widescreen ? 280.0 : 256.0;

    return Container(
      width: width,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Branded header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_graph,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LeadX CRM',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'AI-Powered CRM',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(Icons.home, 'Dashboard', 0),
                _buildSidebarItem(Icons.people, 'Customers', 1),
                _buildSidebarItem(Icons.calendar_today, 'Activities', 3),
                _buildSidebarItem(Icons.person, 'Profile', 4),
                const Divider(height: 16),
                _buildSidebarItem(Icons.business, 'HVC', -1,
                    onTap: () => context.push(RoutePaths.hvc)),
                _buildSidebarItem(Icons.handshake, 'Broker', -1,
                    onTap: () => context.push(RoutePaths.brokers)),
                _buildSidebarItem(Icons.leaderboard, 'Scoreboard', -1,
                    onTap: () => context.push(RoutePaths.scoreboard)),
                _buildSidebarItem(Icons.groups, 'Cadence', -1,
                    onTap: () => context.push(RoutePaths.cadence)),
                const Divider(height: 16),
                _buildSidebarItem(Icons.settings, 'Settings', -1,
                    onTap: () => context.push(RoutePaths.settings)),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '© 2025 LeadX',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = index >= 0 && _currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      selected: isSelected,
      onTap: onTap ?? () => _onTabTapped(index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
    );
  }

  Widget _buildDesktopTopBar() {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search customers, pipelines...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Actions
          const SyncProgressIndicator(),
          const SizedBox(width: 8),
          _buildSyncButton(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RoutePaths.notifications),
          ),
          const SizedBox(width: 8),
          // Profile
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary,
            child: const Text('U', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return HomeDrawer(
      userName: 'User Name',
      userRole: 'Relationship Manager',
      onHvcTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.hvc);
      },
      onBrokerTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.brokers);
      },
      onScoreboardTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.scoreboard);
      },
      onCadenceTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.cadence);
      },
      onSettingsTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.settings);
      },
      onLogoutTap: () {
        Navigator.pop(context);
        _handleLogout();
      },
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _showQuickAddSheet();
    } else {
      // Navigate to actual routes to update browser URL
      switch (index) {
        case 0:
          context.go(RoutePaths.home);
          break;
        case 1:
          context.go(RoutePaths.customers);
          break;
        case 3:
          context.go(RoutePaths.activities);
          break;
        case 4:
          context.go(RoutePaths.profile);
          break;
      }
    }
  }

  void _showQuickAddSheet() {
    QuickAddSheet.show(
      context,
      onNewCustomer: () => context.push(RoutePaths.customerCreate),
      onNewPipeline: () {
        // TODO: Navigate to pipeline create (needs customer selection)
      },
      onNewActivity: () => context.push(RoutePaths.activityCreate),
      onImmediateActivity: () {
        // TODO: Show immediate activity dialog
      },
    );
  }

  void _handleSync() {
    ref.read(syncNotifierProvider.notifier).triggerSync();
  }

  void _handleLogout() {
    // TODO: Implement actual logout
    context.go(RoutePaths.login);
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
