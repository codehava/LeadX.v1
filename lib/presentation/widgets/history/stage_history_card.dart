import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/audit_log_entity.dart';

/// A card widget for displaying pipeline stage history entries.
/// 
/// Shows stage transitions with colored badges and optional GPS indicator.
class StageHistoryCard extends StatelessWidget {
  final PipelineStageHistory history;
  final VoidCallback? onTap;

  const StageHistoryCard({
    super.key,
    required this.history,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stage transition row
              Row(
                children: [
                  // From stage badge
                  if (history.fromStageName != null) ...[
                    _buildStageBadge(
                      context,
                      history.fromStageName!,
                      history.fromStageColor,
                      isFrom: true,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Icon(
                      Icons.add_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Baru',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                  ],
                  // To stage badge
                  _buildStageBadge(
                    context,
                    history.toStageName ?? 'Unknown',
                    history.toStageColor,
                    isFrom: false,
                  ),
                  const Spacer(),
                  // GPS indicator
                  if (history.hasGpsData)
                    Tooltip(
                      message: 'Lokasi tercatat',
                      child: Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                    ),
                ],
              ),
              
              // Status transition (if present)
              if (history.fromStatusName != null ||
                  history.toStatusName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Status: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (history.fromStatusName != null)
                      Text(
                        history.fromStatusName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (history.fromStatusName != null &&
                        history.toStatusName != null)
                      Text(
                        ' → ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (history.toStatusName != null)
                      Text(
                        history.toStatusName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
              
              // Notes (if present)
              if (history.notes != null && history.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          history.notes!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              // Footer: User and timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        history.changedByName ?? 'Sistem',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(history.changedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildStageBadge(
    BuildContext context,
    String stageName,
    String? colorHex, {
    required bool isFrom,
  }) {
    Color badgeColor;
    
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        // Parse hex color (e.g., "#FF5733" or "FF5733")
        final hex = colorHex.replaceFirst('#', '');
        badgeColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        badgeColor = isFrom ? Colors.grey : Colors.blue;
      }
    } else {
      badgeColor = isFrom ? Colors.grey : Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(isFrom ? 51 : 204),
        borderRadius: BorderRadius.circular(12),
        border: isFrom
            ? Border.all(color: badgeColor.withAlpha(102))
            : null,
      ),
      child: Text(
        stageName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isFrom ? badgeColor : Colors.white,
        ),
      ),
    );
  }
}
