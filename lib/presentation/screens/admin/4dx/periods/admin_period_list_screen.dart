import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_names.dart';
import '../../../../../core/utils/period_type_helpers.dart';
import '../../../../../domain/entities/scoring_entities.dart';
import '../../../../providers/admin/admin_4dx_providers.dart';

/// Admin Period List Screen.
///
/// Displays all scoring periods with:
/// - Filter by period type (ALL/WEEKLY/MONTHLY/QUARTERLY)
/// - Search by period name
/// - Set as current, lock, toggle active
/// - Navigate to create/edit screens
/// - Generate periods in bulk
class AdminPeriodListScreen extends ConsumerStatefulWidget {
  const AdminPeriodListScreen({super.key});

  @override
  ConsumerState<AdminPeriodListScreen> createState() =>
      _AdminPeriodListScreenState();
}

class _AdminPeriodListScreenState
    extends ConsumerState<AdminPeriodListScreen> {
  String _filterType = 'ALL'; // 'ALL', 'WEEKLY', 'MONTHLY', 'QUARTERLY'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final periodsAsync = ref.watch(allPeriodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Periode'),
        centerTitle: false,
        actions: [
          // Generate periods button
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate Periode',
            onPressed: () => _showGenerateDialog(),
          ),
          // Create new period button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Periode',
            onPressed: () => context.push(RoutePaths.adminPeriodCreate),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari periode...',
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

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Filter: '),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Semua',
                        isSelected: _filterType == 'ALL',
                        onTap: () => setState(() => _filterType = 'ALL'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Mingguan',
                        isSelected: _filterType == 'WEEKLY',
                        color: Colors.blue,
                        onTap: () => setState(() => _filterType = 'WEEKLY'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Bulanan',
                        isSelected: _filterType == 'MONTHLY',
                        color: Colors.green,
                        onTap: () => setState(() => _filterType = 'MONTHLY'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Kuartalan',
                        isSelected: _filterType == 'QUARTERLY',
                        color: Colors.orange,
                        onTap: () => setState(() => _filterType = 'QUARTERLY'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Periods List
          Expanded(
            child: periodsAsync.when(
              data: (periods) {
                // Apply filters
                final filtered = periods.where((p) {
                  if (_filterType != 'ALL' && p.periodType != _filterType) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    return p.name.toLowerCase().contains(_searchQuery);
                  }
                  return true;
                }).toList();

                // Sort: current first, then by start date descending
                filtered.sort((a, b) {
                  if (a.isCurrent && !b.isCurrent) return -1;
                  if (!a.isCurrent && b.isCurrent) return 1;
                  return b.startDate.compareTo(a.startDate);
                });

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada periode yang cocok'
                              : 'Belum ada periode',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tekan + untuk membuat periode baru',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final period = filtered[index];
                    return _PeriodCard(
                      period: period,
                      onTap: () => context.push(
                        RoutePaths.adminPeriodEdit
                            .replaceAll(':id', period.id),
                      ),
                      onSetCurrent: () => _setCurrentPeriod(period),
                      onLock: () => _lockPeriod(period),
                      onToggleActive: () => _togglePeriodActive(period),
                      onDelete: () => _deletePeriod(period),
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
                      'Gagal memuat periode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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

  Future<void> _setCurrentPeriod(ScoringPeriod period) async {
    if (period.isCurrent) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Periode Aktif?'),
        content: Text(
          'Periode "${period.name}" akan dijadikan periode aktif saat ini. '
          'Hanya periode ${formatPeriodType(period.periodType)} lain yang akan dinonaktifkan. '
          'Periode aktif dengan tipe berbeda tidak terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Set Aktif'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(periodFormProvider.notifier).setCurrentPeriod(period.id);
      ref.invalidate(allPeriodsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Periode "${period.name}" sekarang aktif'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _lockPeriod(ScoringPeriod period) async {
    if (period.isLocked) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kunci Periode?'),
        content: Text(
          'Periode "${period.name}" akan dikunci. '
          'Setelah dikunci, score tidak bisa diubah lagi. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kunci'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(periodFormProvider.notifier).lockPeriod(period.id);
      ref.invalidate(allPeriodsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Periode "${period.name}" telah dikunci'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _togglePeriodActive(ScoringPeriod period) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            period.isActive ? 'Nonaktifkan Periode?' : 'Aktifkan Periode?'),
        content: Text(
          period.isActive
              ? 'Periode ini akan disembunyikan dan tidak digunakan dalam penilaian.'
              : 'Periode ini akan ditampilkan dan digunakan dalam penilaian.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(period.isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(periodFormProvider.notifier).updatePeriod(
            period.id,
            isActive: !period.isActive,
          );
      ref.invalidate(allPeriodsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              period.isActive
                  ? 'Periode berhasil dinonaktifkan'
                  : 'Periode berhasil diaktifkan',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePeriod(ScoringPeriod period) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Periode?'),
        content: Text(
          'Periode "${period.name}" akan dihapus secara permanen. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(periodFormProvider.notifier).deletePeriod(period.id);
      ref.invalidate(allPeriodsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Periode "${period.name}" telah dihapus'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showGenerateDialog() async {
    var periodType = 'WEEKLY';
    var startDate = DateTime.now();
    var count = 4;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate Periode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: periodType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Periode',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'WEEKLY', child: Text('Mingguan')),
                  DropdownMenuItem(
                      value: 'MONTHLY', child: Text('Bulanan')),
                  DropdownMenuItem(
                      value: 'QUARTERLY', child: Text('Kuartalan')),
                ],
                onChanged: (value) {
                  setDialogState(() => periodType = value!);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Mulai'),
                subtitle: Text(
                  '${startDate.day}/${startDate.month}/${startDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setDialogState(() => startDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: count.toString(),
                decoration: const InputDecoration(
                  labelText: 'Jumlah Periode',
                  border: OutlineInputBorder(),
                  helperText: 'Minimal 1, maksimal 52 periode',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final num = int.tryParse(value ?? '');
                  if (num == null || num <= 0) {
                    return 'Harus angka positif';
                  }
                  if (num > 52) {
                    return 'Maksimal 52 periode';
                  }
                  return null;
                },
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0 && parsed <= 52) {
                    count = parsed;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    try {
      await ref.read(periodFormProvider.notifier).generatePeriods(
            periodType: periodType,
            startDate: startDate,
            count: count,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count periode berhasil di-generate'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Filter chip widget.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: chipColor,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Period card widget.
class _PeriodCard extends StatelessWidget {
  final ScoringPeriod period;
  final VoidCallback onTap;
  final VoidCallback onSetCurrent;
  final VoidCallback onLock;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _PeriodCard({
    required this.period,
    required this.onTap,
    required this.onSetCurrent,
    required this.onLock,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine period type color
    final typeColor = periodTypeColor(period.periodType);

    return Card(
      elevation: period.isActive ? 1 : 0,
      color: period.isCurrent
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : period.isActive
              ? null
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: period.isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type badge + Status badges
              Row(
                children: [
                  // Period type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      formatPeriodType(period.periodType),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Current badge
                  if (period.isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AKTIF',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (period.isLocked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LOCKED',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (!period.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NONAKTIF',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Popup menu for actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'current':
                          onSetCurrent();
                          break;
                        case 'lock':
                          onLock();
                          break;
                        case 'toggle':
                          onToggleActive();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!period.isCurrent)
                        const PopupMenuItem(
                          value: 'current',
                          child: ListTile(
                            leading: Icon(Icons.star),
                            title: Text('Set Aktif'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      if (!period.isLocked)
                        const PopupMenuItem(
                          value: 'lock',
                          child: ListTile(
                            leading: Icon(Icons.lock),
                            title: Text('Kunci'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: ListTile(
                          leading: Icon(
                            period.isActive
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          title: Text(
                            period.isActive ? 'Nonaktifkan' : 'Aktifkan',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (!period.isLocked && !period.isCurrent)
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            title: Text(
                              'Hapus',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Period name
              Text(
                period.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: period.isActive
                      ? null
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Date range
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(period.startDate)} - ${_formatDate(period.endDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
