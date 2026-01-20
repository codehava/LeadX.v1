import 'package:flutter/material.dart';

/// Drawer widget for the home screen navigation.
class HomeDrawer extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onHvcTap;
  final VoidCallback? onBrokerTap;
  final VoidCallback? onScoreboardTap;
  final VoidCallback? onCadenceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;

  const HomeDrawer({
    super.key,
    required this.userName,
    required this.userRole,
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
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.onPrimary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userRole,
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('HVC'),
            onTap: onHvcTap,
          ),
          ListTile(
            leading: const Icon(Icons.handshake),
            title: const Text('Broker'),
            onTap: onBrokerTap,
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Scoreboard'),
            onTap: onScoreboardTap,
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('Cadence'),
            onTap: onCadenceTap,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: onSettingsTap,
          ),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text('Logout', style: TextStyle(color: colorScheme.error)),
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}
