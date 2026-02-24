import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/period_type_helpers.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../providers/admin/admin_4dx_providers.dart';
import '../../providers/admin_user_providers.dart';
import '../../providers/scoreboard_providers.dart';
import '../../providers/team_target_providers.dart';

/// Team Target Form Screen.
///
/// Allows a manager to edit all measure targets for a specific subordinate.
/// Shows cascade hint (manager's own target) per measure.
/// Routes each measure's target to the correct period based on periodType.
class TeamTargetFormScreen extends ConsumerStatefulWidget {
  final String userId;
  /// The display period (used for header context); all current periods
  /// are fetched internally to route targets correctly.
  final ScoringPeriod period;

  const TeamTargetFormScreen({
    super.key,
    required this.userId,
    required this.period,
  });

  @override
  ConsumerState<TeamTargetFormScreen> createState() =>
      _TeamTargetFormScreenState();
}

class _TeamTargetFormScreenState extends ConsumerState<TeamTargetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  // Cached for AppBar "Default" button access
  List<UserTarget> _cachedManagerTargets = [];
  int _cachedSubordinateCount = 0;
  bool _hasUnlockedPeriod = false;

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
    final currentPeriodsAsync = ref.watch(allCurrentPeriodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: userAsync.when(
          data: (user) => Text('Target: ${user?.name ?? 'Bawahan'}'),
          loading: () => const Text('Target'),
          error: (_, _) => const Text('Target'),
        ),
        centerTitle: false,
        actions: [
          if (_hasUnlockedPeriod)
            TextButton(
              onPressed: _isSaving ? null : _applyCalculatedDefaults,
              child: const Text('Default'),
            ),
        ],
      ),
      body: measuresAsync.when(
        data: (measures) => currentPeriodsAsync.when(
          data: (currentPeriods) {
            // Build period type → period map from all current periods
            final periodByType = <String, ScoringPeriod>{};
            for (final p in currentPeriods) {
              periodByType[p.periodType] = p;
            }

            // Fall back to the passed-in period if no current periods found
            if (periodByType.isEmpty) {
              periodByType[widget.period.periodType] = widget.period;
            }

            return _buildFormContent(
              theme, colorScheme, measures, periodByType,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Gagal memuat periode: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal memuat measures: $error')),
      ),
    );
  }

  Widget _buildFormContent(
    ThemeData theme,
    ColorScheme colorScheme,
    List<MeasureDefinition> measures,
    Map<String, ScoringPeriod> periodByType,
  ) {
    final activeMeasures = measures.where((m) => m.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // Collect all period IDs we need targets for
    final periodIds = periodByType.values.map((p) => p.id).toSet();

    // Watch existing targets across ALL current periods
    final allExistingTargets = <UserTarget>[];
    final allManagerTargets = <UserTarget>[];
    var anyLoading = false;
    var anyError = false;

    for (final periodId in periodIds) {
      final targetsAsync =
          ref.watch(adminUserTargetsProvider(widget.userId, periodId));
      final managerAsync = ref.watch(managerOwnTargetsProvider(periodId));

      targetsAsync.when(
        data: (targets) => allExistingTargets.addAll(targets),
        loading: () => anyLoading = true,
        error: (_, _) => anyError = true,
      );
      managerAsync.when(
        data: (targets) => allManagerTargets.addAll(targets),
        loading: () => anyLoading = true,
        error: (_, _) => anyError = true,
      );
    }

    // Watch subordinate count for fair-split default calculation
    var subordinateCount = 0;
    final subordinatesAsync = ref.watch(mySubordinatesProvider);
    subordinatesAsync.when(
      data: (subs) => subordinateCount = subs.length,
      loading: () => anyLoading = true,
      error: (_, _) => anyError = true,
    );

    if (anyLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (anyError) {
      return const Center(child: Text('Gagal memuat target'));
    }

    // Filter measures to only those the manager has been assigned
    final managerMeasureIds =
        allManagerTargets.map((t) => t.measureId).toSet();
    final visibleMeasures = activeMeasures
        .where((m) => managerMeasureIds.contains(m.id))
        .toList();

    // Empty state when manager has no assigned measures
    if (visibleMeasures.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_late_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak Ada Measure Tersedia',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Anda belum memiliki target yang ditetapkan oleh atasan. '
                'Hubungi atasan Anda untuk mendapatkan target terlebih dahulu.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final leadMeasures =
        visibleMeasures.where((m) => m.measureType == 'LEAD').toList();
    final lagMeasures =
        visibleMeasures.where((m) => m.measureType == 'LAG').toList();

    // Initialize controllers with existing target values (with fair-split defaults)
    _initControllers(visibleMeasures, allExistingTargets, allManagerTargets, subordinateCount);

    // Check if ANY period is fully locked (per-period lock check)
    final anyUnlockedPeriod =
        periodByType.values.any((p) => !p.isLocked);

    // Cache for AppBar "Default" button
    _cachedManagerTargets = allManagerTargets;
    _cachedSubordinateCount = subordinateCount;
    _hasUnlockedPeriod = anyUnlockedPeriod;

    return Column(
      children: [
        // Period info header — show all current periods
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 20, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Periode Aktif',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: periodByType.entries.map((entry) {
                  final period = entry.value;
                  final typeColor = periodTypeColor(period.periodType);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${formatPeriodType(period.periodType)}: ${period.name}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (period.isLocked) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.lock,
                              size: 12, color: colorScheme.error),
                        ],
                      ],
                    ),
                  );
                }).toList(),
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
                        allExistingTargets,
                        allManagerTargets,
                        periodByType,
                        subordinateCount,
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
                        allExistingTargets,
                        allManagerTargets,
                        periodByType,
                        subordinateCount,
                      )),
                ],
              ],
            ),
          ),
        ),

        // Save button — only show if at least one period is unlocked
        if (anyUnlockedPeriod)
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
                label:
                    Text(_isSaving ? 'Menyimpan...' : 'Simpan Target'),
                onPressed: _isSaving
                    ? null
                    : () => _saveTargets(periodByType),
              ),
            ),
          ),
      ],
    );
  }

  void _initControllers(
    List<MeasureDefinition> measures,
    List<UserTarget> existingTargets,
    List<UserTarget> managerTargets,
    int subordinateCount,
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
              : _calculateDefault(measure, managerTargets, subordinateCount),
        );
      }
    }
  }

  String _calculateDefault(
    MeasureDefinition measure,
    List<UserTarget> managerTargets,
    int subordinateCount,
  ) {
    final effectiveCount = subordinateCount > 0 ? subordinateCount : 1;
    final managerTarget = managerTargets
        .where((t) => t.measureId == measure.id)
        .firstOrNull;
    if (managerTarget != null && managerTarget.targetValue > 0) {
      return _formatNumber(
          (managerTarget.targetValue / effectiveCount).floorToDouble());
    }
    if (measure.defaultTarget > 0) {
      return _formatNumber(
          (measure.defaultTarget / effectiveCount).floorToDouble());
    }
    return '';
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
    List<UserTarget> managerTargets,
    Map<String, ScoringPeriod> periodByType,
    int subordinateCount,
  ) {
    final controller = _controllers[measure.id];
    final existing = existingTargets
        .where((t) => t.measureId == measure.id)
        .firstOrNull;

    // Manager's own target for cascade hint
    final managerTarget = managerTargets
        .where((t) => t.measureId == measure.id)
        .firstOrNull;

    // Determine lock status based on the measure's own period
    final measurePeriodType = measure.periodType ?? 'WEEKLY';
    final matchingPeriod = periodByType[measurePeriodType];
    final isLocked = matchingPeriod?.isLocked ?? true;
    final typeColor = periodTypeColor(measurePeriodType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Measure code, name & period type badge
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
                // Period type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    formatPeriodType(measurePeriodType),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.lock, size: 14, color: colorScheme.error),
                ],
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

            // Cascade hint & status row
            Row(
              children: [
                if (managerTarget != null)
                  Text(
                    () {
                      final base = 'Target Anda: ${_formatNumber(managerTarget.targetValue)}';
                      if (subordinateCount > 1) {
                        final perSub = (managerTarget.targetValue / subordinateCount).floorToDouble();
                        return '$base (${_formatNumber(perSub)}/bawahan)';
                      }
                      return base;
                    }(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
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
                fillColor:
                    isLocked ? colorScheme.surfaceContainerHighest : null,
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

  Future<void> _applyCalculatedDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terapkan Default?'),
        content: const Text(
          'Semua field akan diisi dengan nilai target Anda dibagi jumlah bawahan. '
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
      if (controller != null) {
        final defaultValue = _calculateDefault(
          measure,
          _cachedManagerTargets,
          _cachedSubordinateCount,
        );
        if (defaultValue.isNotEmpty) {
          controller.text = defaultValue;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai default diterapkan')),
      );
    }
  }

  Future<void> _saveTargets(
    Map<String, ScoringPeriod> periodByType,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Get all active measures to map measureId → periodType
      final measures =
          ref.read(allMeasuresProvider).valueOrNull ?? <MeasureDefinition>[];
      final measurePeriodTypes = <String, String>{};
      for (final m in measures) {
        if (m.isActive) {
          measurePeriodTypes[m.id] = m.periodType ?? 'WEEKLY';
        }
      }

      // Group measure targets by their period type
      final targetsByPeriodId = <String, Map<String, double>>{};

      for (final entry in _controllers.entries) {
        final measureId = entry.key;
        final value = entry.value.text.trim();
        if (value.isEmpty) continue;

        final parsed = double.tryParse(value);
        if (parsed == null || parsed < 0) continue;

        final periodType = measurePeriodTypes[measureId] ?? 'WEEKLY';
        final period = periodByType[periodType];
        if (period == null) continue;

        // Skip locked periods
        if (period.isLocked) continue;

        targetsByPeriodId
            .putIfAbsent(period.id, () => {})
            [measureId] = parsed;
      }

      if (targetsByPeriodId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada target untuk disimpan')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      // Save targets per period using multi-period method
      final success = await ref
          .read(teamTargetAssignmentProvider.notifier)
          .saveSubordinateTargetsMultiPeriod(
            userId: widget.userId,
            targetsByPeriodId: targetsByPeriodId,
          );

      final totalMeasures =
          targetsByPeriodId.values.fold(0, (sum, m) => sum + m.length);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Target berhasil disimpan ($totalMeasures measures, ${targetsByPeriodId.length} periode)'
                  : 'Gagal menyimpan target',
            ),
            backgroundColor:
                success ? null : Theme.of(context).colorScheme.error,
          ),
        );
        if (success) Navigator.of(context).pop();
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
