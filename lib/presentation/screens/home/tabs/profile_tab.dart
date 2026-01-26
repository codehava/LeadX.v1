import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/auth_providers.dart';

/// Profile tab showing user profile.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: false,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar with tap feedback and edit badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Material(
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => context.pushNamed(RouteNames.editProfile),
                                customBorder: const CircleBorder(),
                                splashColor: colorScheme.primary.withOpacity(0.3),
                                highlightColor: colorScheme.primary.withOpacity(0.1),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: colorScheme.primaryContainer,
                                  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                                      ? Text(
                                          user.initials,
                                          style: theme.textTheme.headlineMedium?.copyWith(
                                            color: colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            // Edit badge indicator
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.surface, width: 2),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Role Badge
                        Chip(
                          label: Text(user.role.displayName),
                          backgroundColor: colorScheme.secondaryContainer,
                          labelStyle: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),

                        if (user.phone != null && user.phone!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.phone!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                _buildActionSection(
                  context: context,
                  title: 'Akun',
                  children: [
                    _buildActionTile(
                      context: context,
                      icon: Icons.edit_outlined,
                      title: 'Edit Profil',
                      onTap: () => context.pushNamed(RouteNames.editProfile),
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      context: context,
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      onTap: () => context.pushNamed(RouteNames.changePassword),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Settings Actions
                _buildActionSection(
                  context: context,
                  title: 'Pengaturan',
                  children: [
                    _buildActionTile(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      onTap: () => context.goNamed(RouteNames.settings),
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'Tentang',
                      onTap: () => context.pushNamed(RouteNames.about),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat profil',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(loginNotifierProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
