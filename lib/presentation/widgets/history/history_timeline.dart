import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/audit_log_entity.dart';
import 'history_log_card.dart';

/// A vertical timeline widget for displaying history log entries.
/// 
/// Groups entries by date and supports lazy loading.
class HistoryTimeline extends StatelessWidget {
  final List<AuditLog> logs;
  final bool isLoading;
  final String? emptyMessage;
  final VoidCallback? onRefresh;

  const HistoryTimeline({
    super.key,
    required this.logs,
    this.isLoading = false,
    this.emptyMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && logs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (logs.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group logs by date
    final groupedLogs = _groupByDate(logs);
    
    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: groupedLogs.length,
        itemBuilder: (context, index) {
          final dateGroup = groupedLogs[index];
          return _buildDateSection(context, dateGroup);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? 'Belum ada riwayat perubahan',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, _DateGroup dateGroup) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDateHeader(dateGroup.date),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ],
          ),
        ),
        // Log cards for this date
        ...dateGroup.logs.map((log) => HistoryLogCard(log: log)),
      ],
    );
  }

  List<_DateGroup> _groupByDate(List<AuditLog> logs) {
    final grouped = <String, List<AuditLog>>{};
    
    for (final log in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }
    
    return grouped.entries
        .map((e) => _DateGroup(
              date: DateTime.parse(e.key),
              logs: e.value,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari Ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else if (date.year == now.year) {
      return DateFormat('d MMMM', 'id_ID').format(date);
    } else {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    }
  }
}

class _DateGroup {
  final DateTime date;
  final List<AuditLog> logs;

  _DateGroup({required this.date, required this.logs});
}
