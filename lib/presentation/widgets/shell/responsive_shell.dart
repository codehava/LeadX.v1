import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/sync_providers.dart';
import '../../screens/home/widgets/home_drawer.dart';
import '../common/sync_status_badge.dart';
import '../sync/sync_progress_sheet.dart';
import '../layout/responsive_layout.dart';

/// Responsive shell that provides navigation based on screen size.
/// - Mobile: Bottom Navigation
/// - Tablet: Navigation Rail
/// - Desktop: Sidebar
class ResponsiveShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const ResponsiveShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends ConsumerState<ResponsiveShell> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: RoutePaths.home,
    ),
    _NavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Customer',
      route: RoutePaths.home, // Customer tab
    ),
    _NavItem(
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Add',
      route: '', // Special: opens quick add sheet
    ),
    _NavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Activity',
      route: RoutePaths.home, // Activity tab
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: RoutePaths.profile,
    ),
  ];

  @override
  void didUpdateWidget(covariant ResponsiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final route = widget.currentRoute;
    if (route.contains('/profile')) {
      _selectedIndex = 4;
    } else if (route.contains('/activities')) {
      _selectedIndex = 3;
    } else if (route.contains('/customers')) {
      _selectedIndex = 1;
    } else {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  /// Mobile: Scaffold with bottom navigation
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Tablet: Row with navigation rail
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          _buildNavigationRail(context),
          const VerticalDivider(width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  /// Desktop: Row with sidebar
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _buildDesktopTopBar(context),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('LeadX CRM'),
      actions: [
        // Sync progress indicator (shows when syncing)
        const SyncProgressIndicator(),
        // Sync status badge with tap to sync
        _buildSyncButton(context),
        // Notifications
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () => context.push(RoutePaths.notifications),
        ),
      ],
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);
    final syncNotifier = ref.watch(syncNotifierProvider);

    // Use the stream value if available, otherwise fall back to synchronous check.
    // The stream only emits on CHANGES, so initial state needs the sync check.
    final isConnected = connectivityAsync.valueOrNull ?? connectivityService.isConnected;

    SyncStatus status;
    if (!isConnected) {
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      type: BottomNavigationBarType.fixed,
      items: _navItems
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              ))
          .toList(),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onNavTap,
      labelType: NavigationRailLabelType.all,
      leading: FloatingActionButton(
        heroTag: 'shell_nav_rail_fab',
        elevation: 0,
        onPressed: () => _showQuickAddSheet(context),
        child: const Icon(Icons.add),
      ),
      destinations: _navItems
          .where((item) => item.label != 'Add') // Exclude Add from rail
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final width = context.screenWidth >= Breakpoints.widescreen ? 280.0 : 256.0;
    // TODO: Get actual admin status from auth provider
    const bool isAdmin = false;

    return Container(
      width: width,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Branded header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer,
                          ],
                        ),
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
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // MAIN NAVIGATION
                _buildSectionHeader(context, 'MAIN'),
                _buildSidebarItem(context, Icons.home, 'Dashboard', 0),
                _buildSidebarItem(context, Icons.people, 'Customers', 1),
                _buildSidebarItem(context, Icons.calendar_today, 'Activities', 2),
                _buildSidebarItem(context, Icons.person, 'Profile', 3),

                // ACCOUNT MANAGEMENT
                const SizedBox(height: 8),
                _buildSectionHeader(context, 'AKUN'),
                _buildSidebarItem(context, Icons.business, 'HVC', -1,
                    onTap: () => context.push(RoutePaths.hvc)),
                _buildSidebarItem(context, Icons.handshake, 'Broker', -1,
                    onTap: () => context.push(RoutePaths.brokers)),

                // 4DX & PERFORMANCE
                const SizedBox(height: 8),
                _buildSectionHeader(context, '4DX & PERFORMA'),
                _buildSidebarItem(context, Icons.leaderboard, 'Scoreboard', -1,
                    onTap: () => context.push(RoutePaths.scoreboard)),
                _buildSidebarItem(context, Icons.track_changes, 'Targets', -1,
                    onTap: () => context.push(RoutePaths.targets)),
                _buildSidebarItem(context, Icons.groups, 'Cadence', -1,
                    onTap: () => context.push(RoutePaths.cadence)),

                // TOOLS
                const SizedBox(height: 8),
                _buildSectionHeader(context, 'TOOLS'),
                _buildSidebarItem(context, Icons.analytics_outlined, 'Reports', -1,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reports coming soon')),
                      );
                    }),
                _buildSidebarItem(context, Icons.notifications_outlined, 'Notifikasi', -1,
                    onTap: () => context.push(RoutePaths.notifications)),

                // ADMIN (only visible for admins)
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  _buildSectionHeader(context, 'ADMIN'),
                  _buildSidebarItem(context, Icons.admin_panel_settings, 'Admin Panel', -1,
                      onTap: () => context.push(RoutePaths.admin)),
                ],

                // SETTINGS
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildSidebarItem(context, Icons.settings, 'Pengaturan', -1,
                    onTap: () => context.push(RoutePaths.settings)),
                _buildSidebarItem(context, Icons.help_outline, 'Bantuan', -1,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & FAQ coming soon')),
                      );
                    }),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = index >= 0 && _selectedIndex == index;

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
      onTap: onTap ?? () => _onNavTap(index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
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
          _buildSyncButton(context),
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

  Widget _buildDrawer(BuildContext context) {
    // TODO: Get actual user info from auth provider
    return HomeDrawer(
      userName: 'User Name',
      userRole: 'Relationship Manager',
      isAdmin: false, // TODO: Get from user role
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
      onTargetsTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.targets);
      },
      onCadenceTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.cadence);
      },
      onReportsTap: () {
        Navigator.pop(context);
        // TODO: Add reports route when available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reports coming soon')),
        );
      },
      onNotificationsTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.notifications);
      },
      onSettingsTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.settings);
      },
      onHelpTap: () {
        Navigator.pop(context);
        // TODO: Add help route when available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help & FAQ coming soon')),
        );
      },
      onAdminPanelTap: () {
        Navigator.pop(context);
        context.push(RoutePaths.admin);
      },
      onLogoutTap: () {
        Navigator.pop(context);
        context.go(RoutePaths.login);
      },
    );
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Add button - show quick add sheet
      _showQuickAddSheet(context);
      return;
    }

    setState(() => _selectedIndex = index);

    // For now, just update index. In real implementation,
    // this should use StatefulShellRoute for proper tab persistence.
    // TODO: Implement proper tab navigation with go_router
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('New Customer'),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.customerCreate);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_chart),
              title: const Text('New Pipeline'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to pipeline create
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('New Activity'),
              onTap: () {
                Navigator.pop(context);
                context.push(RoutePaths.activityCreate);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
