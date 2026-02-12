import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/entities/scoring_entities.dart';
import '../../../../providers/admin/admin_4dx_providers.dart';
import '../../../../providers/auth_providers.dart';

/// Dialog for bulk assigning targets to multiple users at once.
///
/// Displays a form with all active measures where admin can set target values
/// that will be applied to all selected users for the given period.
class AdminBulkAssignDialog extends ConsumerStatefulWidget {
  final List<String> selectedUserIds;
  final ScoringPeriod period;

  const AdminBulkAssignDialog({
    super.key,
    required this.selectedUserIds,
    required this.period,
  });

  @override
  ConsumerState<AdminBulkAssignDialog> createState() =>
      _AdminBulkAssignDialogState();
}

class _AdminBulkAssignDialogState
    extends ConsumerState<AdminBulkAssignDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final measuresAsync = ref.watch(allMeasuresProvider);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bulk Assign Target'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Info header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.selectedUserIds.length} pengguna dipilih',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Periode: ${widget.period.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Measure fields
            Expanded(
              child: measuresAsync.when(
                data: (measures) {
                  final activeMeasures =
                      measures.where((m) => m.isActive).toList()
                        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  // Initialize controllers
                  for (final measure in activeMeasures) {
                    _controllers.putIfAbsent(
                      measure.id,
                      () => TextEditingController(),
                    );
                  }

                  final leadMeasures = activeMeasures
                      .where((m) => m.measureType == 'LEAD')
                      .toList();
                  final lagMeasures = activeMeasures
                      .where((m) => m.measureType == 'LAG')
                      .toList();

                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (leadMeasures.isNotEmpty) ...[
                          _buildSectionHeader(
                              theme, 'LEAD Measures', Colors.orange),
                          const SizedBox(height: 8),
                          ...leadMeasures
                              .map((m) => _buildMeasureField(theme, m)),
                          const SizedBox(height: 16),
                        ],
                        if (lagMeasures.isNotEmpty) ...[
                          _buildSectionHeader(
                              theme, 'LAG Measures', Colors.purple),
                          const SizedBox(height: 8),
                          ...lagMeasures
                              .map((m) => _buildMeasureField(theme, m)),
                        ],
                      ],
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Gagal memuat measures: $error')),
              ),
            ),

            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _useDefaults,
                      child: const Text('Gunakan Default'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.group_add),
                      label: Text(_isSaving ? 'Menyimpan...' : 'Assign'),
                      onPressed: _isSaving ? null : _assignTargets,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, Color color) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildMeasureField(ThemeData theme, MeasureDefinition measure) {
    final controller = _controllers[measure.id]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '${measure.code} - ${measure.name}',
          hintText: 'Default: ${_formatNumber(measure.defaultTarget)}',
          suffixText: measure.unit,
          border: const OutlineInputBorder(),
          helperText: 'Weight: ${measure.weight}',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final parsed = double.tryParse(value);
            if (parsed == null) return 'Harus berupa angka';
            if (parsed < 0) return 'Tidak boleh negatif';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _useDefaults() async {
    final measures = await ref.read(allMeasuresProvider.future);
    for (final measure in measures.where((m) => m.isActive)) {
      final controller = _controllers[measure.id];
      if (controller != null && measure.defaultTarget > 0) {
        controller.text = _formatNumber(measure.defaultTarget);
      }
    }
  }

  Future<void> _assignTargets() async {
    if (!_formKey.currentState!.validate()) return;

    final measureTargets = <String, double>{};
    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        final parsed = double.tryParse(value);
        if (parsed != null && parsed >= 0) {
          measureTargets[entry.key] = parsed;
        }
      }
    }

    if (measureTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan minimal satu target')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUser = await ref.read(currentUserProvider.future);

      final success =
          await ref.read(targetAssignmentProvider.notifier).bulkAssignTargets(
                periodId: widget.period.id,
                assignedBy: currentUser?.id ?? 'admin',
                userIds: widget.selectedUserIds,
                measureTargets: measureTargets,
              );

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Target berhasil diterapkan ke ${widget.selectedUserIds.length} pengguna',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal menerapkan target'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
