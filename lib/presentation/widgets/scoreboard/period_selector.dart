import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/period_type_helpers.dart';
import '../../../domain/entities/scoring_entities.dart';

/// Reusable period selector widget.
///
/// Tappable row that opens a modal bottom sheet with periods grouped by type.
/// When [selectedPeriod] is null, "Periode Berjalan" (aggregate mode) is selected.
/// Each screen wraps this widget in its own container (Card, InputDecorator, etc.).
class PeriodSelector extends StatelessWidget {
  /// Currently selected period. Null = "Periode Berjalan" (aggregate all current).
  final ScoringPeriod? selectedPeriod;

  /// All available periods for selection.
  final List<ScoringPeriod> allPeriods;

  /// Current active periods (one per period type). Used for the "Periode Berjalan" subtitle.
  final List<ScoringPeriod> currentPeriods;

  /// Callback when a period is selected. Null value = "Periode Berjalan" selected.
  final ValueChanged<ScoringPeriod?> onChanged;

  /// Whether to show the "Periode Berjalan" option at the top. Default true.
  /// Set to false for screens that require a specific single period (e.g. admin target editing).
  final bool showActivePeriodOption;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.allPeriods,
    required this.currentPeriods,
    required this.onChanged,
    this.showActivePeriodOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine display text
    final isActivePeriodMode = selectedPeriod == null && showActivePeriodOption;

    final String displayText;
    if (isActivePeriodMode) {
      displayText = 'Periode Berjalan';
    } else if (selectedPeriod != null) {
      displayText = selectedPeriod!.name;
    } else {
      displayText = 'Pilih periode';
    }

    return InkWell(
      onTap: () => _showPeriodSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayText,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (isActivePeriodMode && currentPeriods.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatRunningPeriodsSummary(currentPeriods),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isActivePeriodMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Berjalan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (selectedPeriod?.isCurrent ?? false)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Berjalan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodSheet(BuildContext context) {
    final theme = Theme.of(context);

    // Group periods by type
    final grouped = <String, List<ScoringPeriod>>{};
    for (final period in allPeriods) {
      grouped.putIfAbsent(period.periodType, () => []).add(period);
    }

    // Sort group keys by priority
    final sortedTypes = grouped.keys.toList()
      ..sort((a, b) => periodTypePriority(a).compareTo(periodTypePriority(b)));

    // Determine if "Periode Aktif" should be shown
    final showActive = showActivePeriodOption && currentPeriods.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Pilih Periode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // List
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // "Periode Berjalan" option
                      if (showActive) ...[
                        _buildSectionHeader(context, 'Periode Berjalan'),
                        ListTile(
                          leading: const Icon(Icons.all_inclusive),
                          title: const Text('Periode Berjalan'),
                          subtitle: Text(
                            formatRunningPeriodsSummary(currentPeriods),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: selectedPeriod == null,
                          selectedTileColor:
                              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          trailing: selectedPeriod == null
                              ? Icon(Icons.check, color: theme.colorScheme.primary)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onChanged(null);
                          },
                        ),
                        const Divider(height: 1),
                      ],

                      // Grouped periods
                      ...sortedTypes.expand((periodType) {
                        final periods = grouped[periodType]!;
                        final typeColor = periodTypeColor(periodType);
                        return [
                          _buildSectionHeader(
                            context,
                            formatPeriodType(periodType),
                            color: typeColor,
                          ),
                          ...periods.map((period) {
                            final isSelected =
                                selectedPeriod?.id == period.id;
                            final isArchived = !period.isActive;
                            return ListTile(
                              title: Text(
                                period.name,
                                style: isArchived
                                    ? theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                      )
                                    : null,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isArchived)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Arsip',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (period.isCurrent)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Berjalan',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (period.isLocked)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  if (isSelected)
                                    Icon(Icons.check,
                                        color: theme.colorScheme.primary),
                                ],
                              ),
                              selected: isSelected,
                              selectedTileColor: theme
                                  .colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              onTap: () {
                                Navigator.pop(context);
                                onChanged(period);
                              },
                            );
                          }),
                        ];
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: color ?? theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
