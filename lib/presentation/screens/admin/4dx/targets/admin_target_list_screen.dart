import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_names.dart';
import '../../../../../domain/entities/scoring_entities.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../providers/admin/admin_4dx_providers.dart';
import '../../../../providers/admin_user_providers.dart';
import '../../../../providers/auth_providers.dart';

/// Admin Target List Screen.
///
/// Displays a list of users with their target assignment status for a selected period.
/// Supports filtering by role and searching by name.
class AdminTargetListScreen extends ConsumerStatefulWidget {
  const AdminTargetListScreen({super.key});

  @override
  ConsumerState<AdminTargetListScreen> createState() =>
      _AdminTargetListScreenState();
}

class _AdminTargetListScreenState extends ConsumerState<AdminTargetListScreen> {
  ScoringPeriod? _selectedPeriod;
  String _filterRole = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final periodsAsync = ref.watch(allPeriodsProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final measuresAsync = ref.watch(allMeasuresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Target'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                // Period dropdown
                periodsAsync.when(
                  data: (periods) {
                    // Only show unlocked periods for editing
                    final editablePeriods =
                        periods.where((p) => p.isActive).toList();
                    if (editablePeriods.isEmpty) {
                      return const Text('Tidak ada periode tersedia');
                    }

                    // Auto-select current period
                    if (_selectedPeriod == null && editablePeriods.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _selectedPeriod = editablePeriods.firstWhere(
                            (p) => p.isCurrent,
                            orElse: () => editablePeriods.first,
                          );
                        });
                      });
                    }

                    return DropdownButtonFormField<ScoringPeriod>(
                      initialValue: _selectedPeriod,
                      decoration: InputDecoration(
                        labelText: 'Periode',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      isExpanded: true,
                      items: editablePeriods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Row(
                            children: [
                              Expanded(child: Text(period.name)),
                              if (period.isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Aktif',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (period.isLocked) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: colorScheme.error,
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (period) {
                        setState(() => _selectedPeriod = period);
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Gagal memuat periode'),
                ),
                const SizedBox(height: 12),

                // Locked period warning
                if (_selectedPeriod?.isLocked ?? false)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Periode ini terkunci. Target hanya bisa dilihat, tidak bisa diubah.',
                            style: TextStyle(
                                color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari pengguna...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Role filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Filter: '),
                      const SizedBox(width: 8),
                      _buildRoleChip('Semua', 'ALL'),
                      const SizedBox(width: 8),
                      _buildRoleChip('RM', 'RM'),
                      const SizedBox(width: 8),
                      _buildRoleChip('BH', 'BH'),
                      const SizedBox(width: 8),
                      _buildRoleChip('BM', 'BM'),
                      const SizedBox(width: 8),
                      _buildRoleChip('ROH', 'ROH'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _selectedPeriod == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pilih periode terlebih dahulu',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildUserList(usersAsync, measuresAsync, theme, colorScheme),
          ),

          // Bottom action: Apply Defaults to All
          if (_selectedPeriod != null && !_selectedPeriod!.isLocked)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Terapkan Default ke Semua Pengguna'),
                  onPressed: () => _applyDefaultsToAll(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, String role) {
    final theme = Theme.of(context);
    final isSelected = _filterRole == role;

    return InkWell(
      onTap: () => setState(() => _filterRole = role),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                isSelected ? Colors.white : theme.colorScheme.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(
    AsyncValue<List<User>> usersAsync,
    AsyncValue<List<MeasureDefinition>> measuresAsync,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final periodId = _selectedPeriod!.id;
    final targetsAsync = ref.watch(targetsForPeriodProvider(periodId));

    return usersAsync.when(
      data: (users) => measuresAsync.when(
        data: (measures) => targetsAsync.when(
          data: (targets) {
            final activeMeasures = measures.where((m) => m.isActive).length;

            // Filter users
            final filtered = users.where((u) {
              // Filter by role
              if (_filterRole != 'ALL') {
                if (u.role.name.toUpperCase() != _filterRole) return false;
              }
              // Filter by search
              if (_searchQuery.isNotEmpty) {
                return u.name.toLowerCase().contains(_searchQuery);
              }
              return true;
            }).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada pengguna yang cocok'
                          : 'Tidak ada pengguna',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allUsersProvider);
                ref.invalidate(targetsForPeriodProvider(periodId));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  final userTargets = targets
                      .where((t) => t.userId == user.id)
                      .length;

                  return _UserTargetCard(
                    user: user,
                    assignedCount: userTargets,
                    totalMeasures: activeMeasures,
                    isLocked: _selectedPeriod!.isLocked,
                    onTap: () => context.push(
                      RoutePaths.adminTargetForm
                          .replaceAll(':userId', user.id),
                      extra: _selectedPeriod,
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Gagal memuat target: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat measures: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Gagal memuat pengguna: $error')),
    );
  }

  Future<void> _applyDefaultsToAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terapkan Default ke Semua?'),
        content: const Text(
          'Target default dari setiap measure akan diterapkan ke semua pengguna '
          'untuk periode ini. Target yang sudah ada akan di-update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || _selectedPeriod == null) return;

    final users = await ref.read(allUsersProvider.future);
    final measures = await ref.read(allMeasuresProvider.future);
    final activeMeasures = measures.where((m) => m.isActive && m.defaultTarget > 0);

    if (activeMeasures.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada measure dengan target default')),
        );
      }
      return;
    }

    // Build measure targets map from defaults
    final measureTargets = {
      for (final m in activeMeasures) m.id: m.defaultTarget,
    };

    final currentUser = await ref.read(currentUserProvider.future);

    final success = await ref.read(targetAssignmentProvider.notifier).bulkAssignTargets(
      periodId: _selectedPeriod!.id,
      assignedBy: currentUser?.id ?? 'admin',
      userIds: users.map((u) => u.id).toList(),
      measureTargets: measureTargets,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Target default berhasil diterapkan ke ${users.length} pengguna'
                : 'Gagal menerapkan target default',
          ),
          backgroundColor: success ? null : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

/// Card for displaying user target assignment status.
class _UserTargetCard extends StatelessWidget {
  final User user;
  final int assignedCount;
  final int totalMeasures;
  final bool isLocked;
  final VoidCallback onTap;

  const _UserTargetCard({
    required this.user,
    required this.assignedCount,
    required this.totalMeasures,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isComplete = assignedCount >= totalMeasures && totalMeasures > 0;
    final hasPartial = assignedCount > 0 && !isComplete;

    return Card(
      elevation: 0,
      color: isComplete
          ? Colors.green.withValues(alpha: 0.05)
          : hasPartial
              ? Colors.orange.withValues(alpha: 0.05)
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getRoleColor(user.role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (user.branchId != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.business,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Branch: ${user.branchId!.substring(0, 8)}...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Target count badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.withValues(alpha: 0.1)
                          : hasPartial
                              ? Colors.orange.withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$assignedCount/$totalMeasures',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isComplete
                            ? Colors.green
                            : hasPartial
                                ? Colors.orange
                                : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? 'Lengkap'
                        : hasPartial
                            ? 'Sebagian'
                            : 'Belum ada',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isComplete
                          ? Colors.green
                          : hasPartial
                              ? Colors.orange
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
      case UserRole.admin:
        return Colors.purple;
      case UserRole.roh:
        return Colors.teal;
      case UserRole.bm:
        return Colors.blue;
      case UserRole.bh:
        return Colors.orange;
      case UserRole.rm:
        return Colors.green;
    }
  }
}
