import 'package:flutter/material.dart';

import '../../../domain/entities/pipeline.dart';

/// A Kanban-style board view for pipelines grouped by stage.
class PipelineKanbanBoard extends StatelessWidget {
  const PipelineKanbanBoard({
    super.key,
    required this.pipelines,
    required this.onPipelineTap,
  });

  final List<Pipeline> pipelines;
  final void Function(Pipeline) onPipelineTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Group pipelines by stage
    final pipelinesByStage = <String, List<Pipeline>>{};
    final stageOrder = <String>[]; // To maintain stage order
    
    for (final pipeline in pipelines) {
      final stageName = pipeline.stageName ?? 'Unknown';
      if (!pipelinesByStage.containsKey(stageName)) {
        pipelinesByStage[stageName] = [];
        stageOrder.add(stageName);
      }
      pipelinesByStage[stageName]!.add(pipeline);
    }

    // Sort stages by probability (descending - highest probability first)
    stageOrder.sort((a, b) {
      final aProb = pipelinesByStage[a]?.first.stageProbability ?? 0;
      final bProb = pipelinesByStage[b]?.first.stageProbability ?? 0;
      return bProb.compareTo(aProb);
    });

    if (stageOrder.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pipeline',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: stageOrder.length,
      itemBuilder: (context, index) {
        final stageName = stageOrder[index];
        final stagePipelines = pipelinesByStage[stageName]!;
        final stageColor = _parseColor(stagePipelines.first.stageColor);
        final probability = stagePipelines.first.stageProbability ?? 0;

        return _KanbanColumn(
          stageName: stageName,
          probability: probability,
          stageColor: stageColor ?? theme.colorScheme.primary,
          pipelines: stagePipelines,
          onPipelineTap: onPipelineTap,
        );
      },
    );
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.stageName,
    required this.probability,
    required this.stageColor,
    required this.pipelines,
    required this.onPipelineTap,
  });

  final String stageName;
  final int probability;
  final Color stageColor;
  final List<Pipeline> pipelines;
  final void Function(Pipeline) onPipelineTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Column Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stageColor.withAlpha(30),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: stageColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stageName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stageColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stageColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$probability%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: stageColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pipelines.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Pipeline Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: pipelines.length,
                itemBuilder: (context, index) {
                  final pipeline = pipelines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _KanbanCard(
                      pipeline: pipeline,
                      onTap: () => onPipelineTap(pipeline),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact card for Kanban view.
class _KanbanCard extends StatelessWidget {
  const _KanbanCard({
    required this.pipeline,
    required this.onTap,
  });

  final Pipeline pipeline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Code & Status
              Row(
                children: [
                  Text(
                    pipeline.code,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (pipeline.isPendingSync)
                    Icon(
                      Icons.cloud_queue,
                      size: 14,
                      color: theme.colorScheme.tertiary,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Customer Name
              Text(
                pipeline.customerName ?? 'Unknown',
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // COB/LOB
              Text(
                '${pipeline.cobName ?? '-'} / ${pipeline.lobName ?? '-'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Premium
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pipeline.formattedPotentialPremium,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Status badges
              if (pipeline.isWon || pipeline.isLost) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pipeline.isWon
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    pipeline.isWon ? 'WON' : 'LOST',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: pipeline.isWon
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
