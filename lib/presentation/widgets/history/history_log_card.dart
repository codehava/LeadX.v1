import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/audit_log_entity.dart';

/// A card widget for displaying a single audit log entry.
class HistoryLogCard extends StatefulWidget {
  final AuditLog log;
  final VoidCallback? onTap;

  const HistoryLogCard({
    super.key,
    required this.log,
    this.onTap,
  });

  @override
  State<HistoryLogCard> createState() => _HistoryLogCardState();
}

class _HistoryLogCardState extends State<HistoryLogCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
          widget.onTap?.call();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  _buildActionIcon(colorScheme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.log.actionLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.log.userName ?? widget.log.userEmail ?? 'Sistem',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(widget.log.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        DateFormat('HH:mm').format(widget.log.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              // Changes summary (always visible)
              if (widget.log.changedFields.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildChangesSummary(theme, colorScheme),
              ],

              // Expanded details
              if (_isExpanded && widget.log.changedFields.isNotEmpty) ...[
                const Divider(height: 16),
                _buildChangesDetails(theme, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(ColorScheme colorScheme) {
    IconData icon;
    Color backgroundColor;
    Color iconColor;

    switch (widget.log.action) {
      case 'INSERT':
        icon = Icons.add_circle_outline;
        backgroundColor = Colors.green.withAlpha(25);
        iconColor = Colors.green;
        break;
      case 'UPDATE':
        icon = Icons.edit_outlined;
        backgroundColor = Colors.blue.withAlpha(25);
        iconColor = Colors.blue;
        break;
      case 'DELETE':
        icon = Icons.delete_outline;
        backgroundColor = Colors.red.withAlpha(25);
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.history;
        backgroundColor = colorScheme.surfaceContainerHighest;
        iconColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildChangesSummary(ThemeData theme, ColorScheme colorScheme) {
    final changes = widget.log.changedFields;
    final displayCount = changes.length > 3 ? 3 : changes.length;
    final fieldNames = changes.take(displayCount).map((c) => c.displayName).join(', ');
    final moreCount = changes.length - displayCount;

    return Text(
      moreCount > 0
          ? '$fieldNames +$moreCount perubahan lainnya'
          : fieldNames,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildChangesDetails(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.log.changedFields.map((change) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  change.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (change.oldValue != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatValue(change.oldValue),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade700,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (change.newValue != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatValue(change.newValue),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is bool) return value ? 'Ya' : 'Tidak';
    if (value is num) {
      // Format as currency if it's a large number (likely premium)
      if (value > 1000) {
        return NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(value);
      }
      return value.toString();
    }
    final str = value.toString();
    // Truncate long strings
    if (str.length > 50) {
      return '${str.substring(0, 50)}...';
    }
    return str;
  }
}
