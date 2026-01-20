import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import 'tabs/activities_tab.dart';
import 'tabs/customers_tab.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/profile_tab.dart';
import 'widgets/quick_add_sheet.dart';

/// Home screen with bottom navigation.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Show quick add menu for center button
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
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _handleSync() {
    // TODO: Implement actual sync
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
