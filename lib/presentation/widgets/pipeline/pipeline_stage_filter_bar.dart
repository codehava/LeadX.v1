import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/dtos/master_data_dtos.dart';
import '../../../domain/entities/pipeline.dart';

/// Horizontally scrollable chip bar for filtering pipelines by stage.
///
/// Shows an "All" chip plus one chip per stage that has pipelines,
/// each displaying a count badge. Stages are sorted by [sequence].
class PipelineStageFilterBar extends StatelessWidget {
  const PipelineStageFilterBar({
    super.key,
    required this.pipelines,
    required this.stages,
    required this.selectedStageId,
    required this.onStageSelected,
  });

  /// Full unfiltered pipeline list (used for count computation).
  final List<Pipeline> pipelines;

  /// All active pipeline stages (for ordering and colors).
  final List<PipelineStageDto> stages;

  /// Currently selected stage ID, or null for "all".
  final String? selectedStageId;

  /// Called when a stage chip is tapped. Pass null for "all".
  final ValueChanged<String?> onStageSelected;

  @override
  Widget build(BuildContext context) {
    // Count pipelines per stage
    final stageCounts = <String, int>{};
    for (final pipeline in pipelines) {
      stageCounts[pipeline.stageId] =
          (stageCounts[pipeline.stageId] ?? 0) + 1;
    }

    // Filter stages to only those with pipelines, sorted by sequence
    final visibleStages = stages
        .where((s) => (stageCounts[s.id] ?? 0) > 0)
        .toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "All" chip
          _StageChip(
            label: 'Semua (${pipelines.length})',
            color: AppColors.primary,
            selected: selectedStageId == null,
            onSelected: () => onStageSelected(null),
          ),
          const SizedBox(width: 8),
          // Per-stage chips
          for (final stage in visibleStages) ...[
            _StageChip(
              label: '${stage.name} (${stageCounts[stage.id]})',
              color: _parseHexColor(stage.color),
              selected: selectedStageId == stage.id,
              onSelected: () => onStageSelected(stage.id),
            ),
            if (stage != visibleStages.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Color _parseHexColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return AppColors.primary;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : Theme.of(context).colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? color : Theme.of(context).colorScheme.outline,
      ),
      showCheckmark: false,
    );
  }
}
