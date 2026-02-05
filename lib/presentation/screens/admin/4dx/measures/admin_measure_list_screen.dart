import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/route_names.dart';
import '../../../../../domain/entities/scoring_entities.dart';
import '../../../../providers/admin/admin_4dx_providers.dart';

/// Admin Measure List Screen.
///
/// Displays all measure definitions (LEAD & LAG) with:
/// - Filter by measure type (ALL/LEAD/LAG)
/// - Sort by sort_order
/// - Enable/disable measures
/// - Navigate to create/edit screens
class AdminMeasureListScreen extends ConsumerStatefulWidget {
  const AdminMeasureListScreen({super.key});

  @override
  ConsumerState<AdminMeasureListScreen> createState() =>
      _AdminMeasureListScreenState();
}

class _AdminMeasureListScreenState
    extends ConsumerState<AdminMeasureListScreen> {
  String _filterType = 'ALL'; // 'ALL', 'LEAD', 'LAG'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final measuresAsync = ref.watch(allMeasuresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Measures'),
        centerTitle: false,
        actions: [
          // Create new measure button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Measure',
            onPressed: () => context.push(RoutePaths.adminMeasureCreate),
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
                    hintText: 'Cari measure...',
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
                Row(
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
                      label: 'LEAD (60%)',
                      isSelected: _filterType == 'LEAD',
                      color: Colors.orange,
                      onTap: () => setState(() => _filterType = 'LEAD'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'LAG (40%)',
                      isSelected: _filterType == 'LAG',
                      color: Colors.purple,
                      onTap: () => setState(() => _filterType = 'LAG'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Measures List
          Expanded(
            child: measuresAsync.when(
              data: (measures) {
                // Apply filters
                final filtered = measures.where((m) {
                  if (_filterType != 'ALL' && m.measureType != _filterType) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    return m.name.toLowerCase().contains(_searchQuery) ||
                        m.code.toLowerCase().contains(_searchQuery);
                  }
                  return true;
                }).toList();

                // Sort by sort_order
                filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada measure yang cocok'
                              : 'Belum ada measure',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                    final measure = filtered[index];
                    return _MeasureCard(
                      measure: measure,
                      onTap: () => context.push(
                        RoutePaths.adminMeasureEdit.replaceAll(':id', measure.id),
                      ),
                      onToggleActive: () async {
                        await _toggleMeasureActive(measure);
                      },
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
                      'Gagal memuat measures',
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

  Future<void> _toggleMeasureActive(MeasureDefinition measure) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(measure.isActive ? 'Nonaktifkan Measure?' : 'Aktifkan Measure?'),
        content: Text(
          measure.isActive
              ? 'Measure ini akan disembunyikan dari pengguna dan tidak akan digunakan dalam perhitungan score.'
              : 'Measure ini akan ditampilkan ke pengguna dan digunakan dalam perhitungan score.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(measure.isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(measureFormProvider.notifier).updateMeasure(
            measure.id,
            isActive: !measure.isActive,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              measure.isActive
                  ? 'Measure berhasil dinonaktifkan'
                  : 'Measure berhasil diaktifkan',
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

/// Measure card widget.
class _MeasureCard extends StatelessWidget {
  final MeasureDefinition measure;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;

  const _MeasureCard({
    required this.measure,
    required this.onTap,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine color based on measure type
    final typeColor = measure.measureType == 'LEAD'
        ? Colors.orange
        : Colors.purple;

    return Card(
      elevation: measure.isActive ? 1 : 0,
      color: measure.isActive
          ? null
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type badge + Active status
              Row(
                children: [
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
                      measure.measureType == 'LEAD' ? 'LEAD 60%' : 'LAG 40%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!measure.isActive)
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
                  const Spacer(),
                  // Active/Inactive toggle
                  IconButton(
                    icon: Icon(
                      measure.isActive
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: measure.isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    tooltip: measure.isActive ? 'Nonaktifkan' : 'Aktifkan',
                    onPressed: onToggleActive,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Code
              Text(
                measure.code,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Name
              Text(
                measure.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: measure.isActive
                      ? null
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (measure.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  measure.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Details row
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _DetailChip(
                    icon: Icons.flag,
                    label: 'Target: ${measure.defaultTarget.toStringAsFixed(0)}',
                  ),
                  _DetailChip(
                    icon: Icons.balance,
                    label: 'Weight: ${measure.weight}',
                  ),
                  _DetailChip(
                    icon: Icons.calendar_today,
                    label: measure.periodType ?? 'WEEKLY',
                  ),
                  if (measure.templateType != null)
                    _DetailChip(
                      icon: Icons.category,
                      label: _formatTemplateType(measure.templateType!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTemplateType(String templateType) {
    switch (templateType) {
      case 'activity_count':
        return 'Activity Count';
      case 'pipeline_count':
        return 'Pipeline Count';
      case 'pipeline_revenue':
        return 'Pipeline Revenue';
      case 'pipeline_conversion':
        return 'Conversion Rate';
      case 'stage_milestone':
        return 'Stage Milestone';
      case 'customer_acquisition':
        return 'Customer Acquisition';
      default:
        return templateType;
    }
  }
}

/// Detail chip widget for displaying measure metadata.
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
