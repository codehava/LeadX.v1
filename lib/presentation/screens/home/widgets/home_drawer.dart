import 'package:flutter/material.dart';

/// Drawer widget for the home screen navigation.
/// Provides organized sections for main features, tools, and settings.
class HomeDrawer extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onHvcTap;
  final VoidCallback? onBrokerTap;
  final VoidCallback? onScoreboardTap;
  final VoidCallback? onCadenceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogoutTap;
  // New callbacks for additional items
  final VoidCallback? onPipelinesTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onTargetsTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onHelpTap;
  // Admin callbacks
  final VoidCallback? onAdminPanelTap;
  final bool isAdmin;

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
    this.onPipelinesTap,
    this.onReportsTap,
    this.onTargetsTap,
    this.onNotificationsTap,
    this.onHelpTap,
    this.onAdminPanelTap,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ============================================
          // USER HEADER
          // ============================================
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
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

          // ============================================
          // ACCOUNT MANAGEMENT
          // ============================================
          _buildSectionHeader(context, 'AKUN'),
          _buildDrawerItem(
            context,
            icon: Icons.business,
            title: 'HVC (High Value Customer)',
            subtitle: 'Kelola pelanggan bernilai tinggi',
            onTap: onHvcTap,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.handshake,
            title: 'Broker',
            subtitle: 'Kelola broker dan mitra',
            onTap: onBrokerTap,
          ),

          const Divider(height: 8),

          // ============================================
          // 4DX & PERFORMANCE
          // ============================================
          _buildSectionHeader(context, '4DX & PERFORMA'),
          _buildDrawerItem(
            context,
            icon: Icons.leaderboard,
            title: 'Scoreboard',
            subtitle: 'Lihat skor dan peringkat',
            onTap: onScoreboardTap,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.track_changes,
            title: 'Target',
            subtitle: 'Kelola target WIG dan lead measures',
            onTap: onTargetsTap,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.groups,
            title: 'Cadence',
            subtitle: 'Jadwal pertemuan akuntabilitas',
            onTap: onCadenceTap,
          ),

          const Divider(height: 8),

          // ============================================
          // TOOLS & UTILITIES
          // ============================================
          _buildSectionHeader(context, 'TOOLS'),
          _buildDrawerItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Reports',
            subtitle: 'Laporan dan analitik',
            onTap: onReportsTap,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Pengaturan notifikasi',
            onTap: onNotificationsTap,
          ),

          // ============================================
          // ADMIN SECTION (only visible for admins)
          // ============================================
          if (isAdmin) ...[
            const Divider(height: 8),
            _buildSectionHeader(context, 'ADMIN'),
            _buildDrawerItem(
              context,
              icon: Icons.admin_panel_settings,
              title: 'Admin Panel',
              subtitle: 'Kelola pengguna dan master data',
              onTap: onAdminPanelTap,
              iconColor: colorScheme.tertiary,
            ),
          ],

          const Divider(height: 8),

          // ============================================
          // SETTINGS & LOGOUT
          // ============================================
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: onSettingsTap,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline,
            title: 'Bantuan',
            onTap: onHelpTap,
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            iconColor: colorScheme.error,
            textColor: colorScheme.error,
            onTap: onLogoutTap,
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
