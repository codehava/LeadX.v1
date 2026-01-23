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
      _selectedIndex = 3;
    } else if (route.contains('/activities')) {
      _selectedIndex = 2;
    } else if (route.contains('/customers')) {
      _selectedIndex = 1;
    } else if (route.contains('/hvcs') || route.contains('/brokers') || 
               route.contains('/scoreboard') || route.contains('/cadence')) {
      // These are sidebar items, not main nav items
      // Set to -1 so no bottom nav item is highlighted
      _selectedIndex = -1;
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
    final theme = Theme.of(context);
    
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
        const SizedBox(width: 4),
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => context.go(RoutePaths.profile),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: const Text('U', style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
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
      currentIndex: _selectedIndex >= 0 ? _selectedIndex : 0,
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
    final theme = Theme.of(context);
    
    // selectedIndex now directly matches _navItems since there's no "Add" button
    // Home(0), Customer(1), Activity(2), Profile(3)
    final effectiveIndex = _selectedIndex < 0 ? 0 : _selectedIndex;
    
    // Build a fully scrollable custom navigation rail
    return Container(
      width: 80,
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Main navigation destinations
                ..._navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = effectiveIndex == index;
                  
                  return _buildRailDestination(
                    context,
                    icon: isSelected ? item.activeIcon : item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => _onNavTap(index),
                  );
                }),
                const SizedBox(height: 16),
                const Divider(),
                // Additional menu items
                _buildRailTrailingItem(
                  context,
                  icon: Icons.business,
                  label: 'HVC',
                  isSelected: widget.currentRoute.contains('/hvcs'),
                  onTap: () => context.go(RoutePaths.hvc),
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.handshake,
                  label: 'Broker',
                  isSelected: widget.currentRoute.contains('/brokers'),
                  onTap: () => context.go(RoutePaths.brokers),
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.leaderboard,
                  label: 'Score',
                  isSelected: widget.currentRoute.contains('/scoreboard'),
                  onTap: () => context.push(RoutePaths.scoreboard),
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.track_changes,
                  label: 'Targets',
                  isSelected: widget.currentRoute.contains('/targets'),
                  onTap: () => context.push(RoutePaths.targets),
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.groups,
                  label: 'Cadence',
                  isSelected: widget.currentRoute.contains('/cadence'),
                  onTap: () => context.push(RoutePaths.cadence),
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.analytics_outlined,
                  label: 'Reports',
                  isSelected: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reports coming soon')),
                    );
                  },
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  isSelected: widget.currentRoute.contains('/notifications'),
                  onTap: () => context.push(RoutePaths.notifications),
                ),
                const Spacer(),
                const Divider(),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.help_outline,
                  label: 'Help',
                  isSelected: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & FAQ coming soon')),
                    );
                  },
                ),
                _buildRailTrailingItem(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: widget.currentRoute.contains('/settings'),
                  onTap: () => context.push(RoutePaths.settings),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget for main NavigationRail destinations (matching Material Design style)
  Widget _buildRailDestination(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? theme.colorScheme.onSecondaryContainer : color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? theme.colorScheme.onSecondaryContainer : color,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for NavigationRail trailing items
  Widget _buildRailTrailingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: isSelected
              ? BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
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
                // Profile is accessed via top bar avatar in desktop mode

                // ACCOUNT MANAGEMENT
                const SizedBox(height: 8),
                _buildSectionHeader(context, 'AKUN'),
                _buildSidebarItem(context, Icons.business, 'HVC', -1,
                    routePattern: '/hvcs',
                    onTap: () => context.go(RoutePaths.hvc)),
                _buildSidebarItem(context, Icons.handshake, 'Broker', -1,
                    routePattern: '/brokers',
                    onTap: () => context.go(RoutePaths.brokers)),

                // 4DX & PERFORMANCE
                const SizedBox(height: 8),
                _buildSectionHeader(context, '4DX & PERFORMA'),
                _buildSidebarItem(context, Icons.leaderboard, 'Scoreboard', -1,
                    routePattern: '/scoreboard',
                    onTap: () => context.push(RoutePaths.scoreboard)),
                _buildSidebarItem(context, Icons.track_changes, 'Targets', -1,
                    routePattern: '/targets',
                    onTap: () => context.push(RoutePaths.targets)),
                _buildSidebarItem(context, Icons.groups, 'Cadence', -1,
                    routePattern: '/cadence',
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
    String? routePattern,
  }) {
    final theme = Theme.of(context);
    // For main nav items (index >= 0), use selectedIndex
    // For sidebar-only items (index == -1), check route pattern
    final isSelected = index >= 0 
        ? _selectedIndex == index
        : routePattern != null && widget.currentRoute.contains(routePattern);

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
          // Profile avatar with tap feedback
          Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go(RoutePaths.profile),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary,
                child: const Text('U', style: TextStyle(color: Colors.white)),
              ),
            ),
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
    // Navigate to actual routes (matching HomeScreen behavior)
    // Indices: Home(0), Customer(1), Activity(2), Profile(3)
    switch (index) {
      case 0:
        context.go(RoutePaths.home);
        break;
      case 1:
        context.go(RoutePaths.customers);
        break;
      case 2:
        context.go(RoutePaths.activities);
        break;
      case 3:
        context.go(RoutePaths.profile);
        break;
    }
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
