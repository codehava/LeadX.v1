import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/audit_log_entity.dart';
import 'stage_history_card.dart';

/// A vertical timeline widget for displaying pipeline stage history.
/// 
/// Shows stage transitions in chronological order with a visual timeline.
class StageHistoryTimeline extends StatelessWidget {
  final List<PipelineStageHistory> history;
  final bool isLoading;
  final String? emptyMessage;
  final VoidCallback? onRefresh;

  const StageHistoryTimeline({
    super.key,
    required this.history,
    this.isLoading = false,
    this.emptyMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && history.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (history.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final isFirst = index == 0;
          final isLast = index == history.length - 1;
          
          return _buildTimelineItem(
            context,
            item,
            isFirst: isFirst,
            isLast: isLast,
          );
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
            Icons.timeline_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? 'Belum ada riwayat perubahan stage',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    PipelineStageHistory item, {
    required bool isFirst,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 16,
                    color: colorScheme.outlineVariant,
                  )
                else
                  const SizedBox(height: 16),
                
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                
                // Bottom line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Card
          Expanded(
            child: StageHistoryCard(history: item),
          ),
        ],
      ),
    );
  }
}
