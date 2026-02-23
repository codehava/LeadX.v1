import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/admin_user_providers.dart';

/// Screen displaying list of all users with search and filters.
class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final _searchController = TextEditingController();
  UserRole? _selectedRole;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showDeleted = ref.watch(showDeletedUsersProvider);

    final usersAsync = _selectedRole != null
        ? ref.watch(usersByRoleProvider(_selectedRole!))
        : ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        actions: [
          IconButton(
            icon: Icon(
              showDeleted ? Icons.person_off : Icons.person_off_outlined,
              color: showDeleted ? colorScheme.primary : null,
            ),
            tooltip: showDeleted
                ? 'Sembunyikan pengguna dihapus'
                : 'Tampilkan pengguna dihapus',
            onPressed: () {
              ref.read(showDeletedUsersProvider.notifier).state = !showDeleted;
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama, email, atau NIP...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.adminUserCreate),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pengguna'),
      ),
      body: Column(
        children: [
          // Role filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: _selectedRole == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRole = null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...UserRole.values.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(role.shortName),
                      selected: _selectedRole == role,
                      onSelected: (selected) {
                        setState(() => _selectedRole = selected ? role : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // User list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Apply search filter
                final filteredUsers = _searchQuery.isEmpty
                    ? users
                    : users.where((user) {
                        final query = _searchQuery.toLowerCase();
                        return user.name.toLowerCase().contains(query) ||
                            user.email.toLowerCase().contains(query) ||
                            (user.nip?.toLowerCase().contains(query) ?? false);
                      }).toList();

                if (filteredUsers.isEmpty) {
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
                          'Tidak ada pengguna',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _UserListItem(user: user);
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
                      'Gagal memuat pengguna',
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
            ),
          ),
        ],
      ),
    );
  }
}

/// List item widget for displaying a user.
class _UserListItem extends StatelessWidget {
  const _UserListItem({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDeleted = user.isDeleted;

    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive && !isDeleted
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          foregroundColor: user.isActive && !isDeleted
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          child: user.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Text(user.initials),
                  ),
                )
              : Text(user.initials),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isDeleted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Dihapus',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ] else if (!user.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Nonaktif',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildBadge(
                  context,
                  user.role.shortName,
                  _getRoleColor(colorScheme, user.role),
                ),
                if (user.nip != null)
                  _buildBadge(
                    context,
                    user.nip!,
                    colorScheme.secondaryContainer,
                  ),
              ],
            ),
          ],
        ),
        onTap: () => context.push(
          RoutePaths.adminUserDetail.replaceFirst(':id', user.id),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall,
      ),
    );
  }

  Color _getRoleColor(ColorScheme colorScheme, UserRole role) {
    switch (role) {
      case UserRole.superadmin:
      case UserRole.admin:
        return colorScheme.tertiaryContainer;
      case UserRole.roh:
        return colorScheme.primaryContainer;
      case UserRole.bm:
      case UserRole.bh:
        return colorScheme.secondaryContainer;
      case UserRole.rm:
        return colorScheme.surfaceContainerHighest;
    }
  }
}
