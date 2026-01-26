import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/admin_user_providers.dart';

/// Screen displaying detailed information about a user.
///
/// Shows three tabs:
/// - Info: User profile details
/// - Subordinates: List of direct reports
/// - Audit Log: Change history (future)
class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userAsync = ref.watch(userByIdProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: userAsync.hasValue && userAsync.value != null
                ? () => context.push(
                      RoutePaths.adminUserEdit
                          .replaceFirst(':id', widget.userId),
                    )
                : null,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            enabled: !_isProcessing,
            onSelected: (value) => _handleMenuAction(value, userAsync.value),
            itemBuilder: (context) {
              final user = userAsync.value;
              return [
                PopupMenuItem(
                  value: (user?.isActive ?? false) ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        (user?.isActive ?? false)
                            ? Icons.block
                            : Icons.check_circle,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (user?.isActive ?? false)
                            ? 'Nonaktifkan'
                            : 'Aktifkan',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset_password',
                  child: Row(
                    children: [
                      Icon(Icons.key),
                      SizedBox(width: 8),
                      Text('Reset Password'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info', icon: Icon(Icons.info_outline)),
            Tab(text: 'Bawahan', icon: Icon(Icons.people_outline)),
            Tab(text: 'Riwayat', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pengguna tidak ditemukan',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(user: user),
              _SubordinatesTab(userId: widget.userId),
              _AuditLogTab(),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data pengguna',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(userByIdProvider(widget.userId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, User? user) async {
    if (user == null) return;

    switch (action) {
      case 'activate':
      case 'deactivate':
        await _handleToggleActive(user);
        break;
      case 'reset_password':
        await _handleResetPassword(user);
        break;
      case 'delete':
        await _handleDelete(user);
        break;
    }
  }

  Future<void> _handleToggleActive(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Nonaktifkan Pengguna' : 'Aktifkan Pengguna'),
        content: Text(
          user.isActive
              ? 'Apakah Anda yakin ingin menonaktifkan ${user.name}? '
                  'Pengguna tidak akan bisa login setelah dinonaktifkan.'
              : 'Apakah Anda yakin ingin mengaktifkan ${user.name}? '
                  'Pengguna akan bisa login kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(adminUserNotifierProvider.notifier);
      final success = user.isActive
          ? await notifier.deactivateUser(widget.userId)
          : await notifier.activateUser(widget.userId);

      if (!mounted) return;

      if (success) {
        ref.invalidate(userByIdProvider(widget.userId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? 'Pengguna berhasil dinonaktifkan'
                  : 'Pengguna berhasil diaktifkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengubah status pengguna'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleResetPassword(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'Apakah Anda yakin ingin me-reset password untuk ${user.name}? '
          'Password sementara baru akan dibuat dan pengguna harus mengubahnya saat login.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(adminUserNotifierProvider.notifier);
      final tempPassword =
          await notifier.generateTemporaryPassword(widget.userId);

      if (!mounted) return;

      if (tempPassword != null) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _PasswordDisplayDialog(
            userName: user.name,
            password: tempPassword,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat password sementara'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDelete(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${user.name}? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // TODO: Implement delete functionality when repository method is added
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur hapus pengguna belum diimplementasikan'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

/// Info tab displaying user profile details.
class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar and name
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: user.isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: user.isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                child: user.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          width: 96,
                          height: 96,
                          errorBuilder: (context, error, stackTrace) => Text(
                            user.initials,
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                      )
                    : Text(
                        user.initials,
                        style: theme.textTheme.headlineMedium,
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (!user.isActive) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Nonaktif',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Details section
        _DetailCard(
          title: 'Informasi Kontak',
          children: [
            _DetailRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            if (user.phone != null)
              _DetailRow(
                icon: Icons.phone,
                label: 'Telepon',
                value: user.phone!,
              ),
          ],
        ),
        const SizedBox(height: 16),

        _DetailCard(
          title: 'Informasi Pekerjaan',
          children: [
            _DetailRow(
              icon: Icons.badge,
              label: 'NIP',
              value: user.nip ?? '-',
            ),
            _DetailRow(
              icon: Icons.work,
              label: 'Role',
              value: user.role.displayName,
            ),
            _DetailRow(
              icon: Icons.business,
              label: 'Cabang',
              value: user.branchId ?? '-',
            ),
            _DetailRow(
              icon: Icons.location_city,
              label: 'Kantor Regional',
              value: user.regionalOfficeId ?? '-',
            ),
            _DetailRow(
              icon: Icons.supervisor_account,
              label: 'Atasan',
              value: user.parentId ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 16),

        _DetailCard(
          title: 'Informasi Sistem',
          children: [
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Dibuat',
              value: dateFormat.format(user.createdAt),
            ),
            _DetailRow(
              icon: Icons.update,
              label: 'Diperbarui',
              value: dateFormat.format(user.updatedAt),
            ),
            if (user.lastLoginAt != null)
              _DetailRow(
                icon: Icons.login,
                label: 'Login Terakhir',
                value: dateFormat.format(user.lastLoginAt!),
              ),
          ],
        ),
      ],
    );
  }
}

/// Subordinates tab showing direct reports.
class _SubordinatesTab extends ConsumerWidget {
  const _SubordinatesTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subordinatesAsync = ref.watch(userSubordinatesProvider(userId));

    return subordinatesAsync.when(
      data: (subordinates) {
        if (subordinates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada bawahan',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pengguna ini belum memiliki bawahan langsung',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: subordinates.length,
          itemBuilder: (context, index) {
            final subordinate = subordinates[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: subordinate.isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: subordinate.isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                child: subordinate.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          subordinate.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Text(subordinate.initials),
                        ),
                      )
                    : Text(subordinate.initials),
              ),
              title: Text(subordinate.name),
              subtitle: Text(subordinate.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subordinate.role.shortName,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              onTap: () => context.push(
                RoutePaths.adminUserDetail
                    .replaceFirst(':id', subordinate.id),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data bawahan',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Audit log tab (placeholder for future implementation).
class _AuditLogTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Riwayat Perubahan',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Fitur riwayat perubahan akan segera tersedia',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card container for detail sections.
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Row displaying a single detail field.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog displaying temporary password after reset.
class _PasswordDisplayDialog extends StatelessWidget {
  const _PasswordDisplayDialog({
    required this.userName,
    required this.password,
  });

  final String userName;
  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.key, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Password Sementara'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password untuk $userName telah di-reset.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    password,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Salin password',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: password));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password disalin'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PENTING: Sampaikan password ini kepada pengguna. '
            'Password ini hanya ditampilkan sekali dan pengguna '
            'akan diminta mengubahnya saat login pertama.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
