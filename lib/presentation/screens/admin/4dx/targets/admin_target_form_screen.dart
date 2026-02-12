import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/entities/scoring_entities.dart';
import '../../../../providers/admin/admin_4dx_providers.dart';
import '../../../../providers/admin_user_providers.dart';
import '../../../../providers/auth_providers.dart';

/// Admin Target Form Screen.
///
/// Allows editing all measure targets for a specific user in a specific period.
/// Groups measures by LEAD/LAG with editable target fields.
class AdminTargetFormScreen extends ConsumerStatefulWidget {
  final String userId;
  final ScoringPeriod period;

  const AdminTargetFormScreen({
    super.key,
    required this.userId,
    required this.period,
  });

  @override
  ConsumerState<AdminTargetFormScreen> createState() =>
      _AdminTargetFormScreenState();
}

class _AdminTargetFormScreenState extends ConsumerState<AdminTargetFormScreen> {
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
    final userAsync = ref.watch(userByIdProvider(widget.userId));
    final measuresAsync = ref.watch(allMeasuresProvider);
    final targetsAsync =
        ref.watch(adminUserTargetsProvider(widget.userId, widget.period.id));
    final isLocked = widget.period.isLocked;

    return Scaffold(
      appBar: AppBar(
        title: userAsync.when(
          data: (user) => Text('Target: ${user?.name ?? 'Pengguna'}'),
          loading: () => const Text('Target'),
          error: (_, _) => const Text('Target'),
        ),
        centerTitle: false,
        actions: [
          if (!isLocked)
            TextButton(
              onPressed: _isSaving ? null : _applyDefaults,
              child: const Text('Default'),
            ),
        ],
      ),
      body: measuresAsync.when(
        data: (measures) => targetsAsync.when(
          data: (existingTargets) {
            final activeMeasures =
                measures.where((m) => m.isActive).toList()
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            final leadMeasures = activeMeasures
                .where((m) => m.measureType == 'LEAD')
                .toList();
            final lagMeasures = activeMeasures
                .where((m) => m.measureType == 'LAG')
                .toList();

            // Initialize controllers with existing target values
            _initControllers(activeMeasures, existingTargets);

            return Column(
              children: [
                // Period info header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 20, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        widget.period.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock,
                                  size: 14,
                                  color: colorScheme.onErrorContainer),
                              const SizedBox(width: 4),
                              Text(
                                'Read Only',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Form
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // LEAD Measures Section
                        if (leadMeasures.isNotEmpty) ...[
                          _buildSectionHeader(
                            theme,
                            'LEAD Measures (60%)',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          ...leadMeasures.map((m) => _buildMeasureField(
                                theme,
                                colorScheme,
                                m,
                                existingTargets,
                                isLocked,
                              )),
                          const SizedBox(height: 24),
                        ],

                        // LAG Measures Section
                        if (lagMeasures.isNotEmpty) ...[
                          _buildSectionHeader(
                            theme,
                            'LAG Measures (40%)',
                            Icons.flag,
                            Colors.purple,
                          ),
                          const SizedBox(height: 8),
                          ...lagMeasures.map((m) => _buildMeasureField(
                                theme,
                                colorScheme,
                                m,
                                existingTargets,
                                isLocked,
                              )),
                        ],
                      ],
                    ),
                  ),
                ),

                // Save button
                if (!isLocked)
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
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Target'),
                        onPressed: _isSaving ? null : _saveTargets,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Gagal memuat target: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat measures: $error')),
      ),
    );
  }

  void _initControllers(
    List<MeasureDefinition> measures,
    List<UserTarget> existingTargets,
  ) {
    for (final measure in measures) {
      if (!_controllers.containsKey(measure.id)) {
        final existing = existingTargets
            .where((t) => t.measureId == measure.id)
            .firstOrNull;
        _controllers[measure.id] = TextEditingController(
          text: existing != null
              ? existing.targetValue.toStringAsFixed(
                  existing.targetValue == existing.targetValue.roundToDouble()
                      ? 0
                      : 1,
                )
              : '',
        );
      }
    }
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasureField(
    ThemeData theme,
    ColorScheme colorScheme,
    MeasureDefinition measure,
    List<UserTarget> existingTargets,
    bool isLocked,
  ) {
    final controller = _controllers[measure.id];
    final existing = existingTargets
        .where((t) => t.measureId == measure.id)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Measure code & name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    measure.code,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    measure.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Default value and unit info
            Row(
              children: [
                Text(
                  'Default: ${_formatNumber(measure.defaultTarget)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (measure.unit != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Unit: ${measure.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (existing != null) ...[
                  const Spacer(),
                  Text(
                    'Ditetapkan',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Target value input
            TextFormField(
              controller: controller,
              readOnly: isLocked,
              decoration: InputDecoration(
                labelText: 'Target Value',
                hintText: 'Masukkan target...',
                suffixText: measure.unit,
                border: const OutlineInputBorder(),
                filled: isLocked,
                fillColor: isLocked
                    ? colorScheme.surfaceContainerHighest
                    : null,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
          ],
        ),
      ),
    );
  }

  Future<void> _saveTargets() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final currentUser = await ref.read(currentUserProvider.future);
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada target untuk disimpan')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final success =
          await ref.read(targetAssignmentProvider.notifier).saveUserTargets(
                userId: widget.userId,
                periodId: widget.period.id,
                assignedBy: currentUser?.id ?? 'admin',
                measureTargets: measureTargets,
              );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Target berhasil disimpan (${measureTargets.length} measures)'
                  : 'Gagal menyimpan target',
            ),
            backgroundColor: success ? null : Theme.of(context).colorScheme.error,
          ),
        );
        if (success) Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _applyDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terapkan Default?'),
        content: const Text(
          'Semua field akan diisi dengan nilai default dari setiap measure. '
          'Nilai yang sudah diisi akan ditimpa.',
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

    if (confirmed != true) return;

    final measures = await ref.read(allMeasuresProvider.future);
    for (final measure in measures.where((m) => m.isActive)) {
      final controller = _controllers[measure.id];
      if (controller != null && measure.defaultTarget > 0) {
        controller.text = _formatNumber(measure.defaultTarget);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai default diterapkan')),
      );
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
