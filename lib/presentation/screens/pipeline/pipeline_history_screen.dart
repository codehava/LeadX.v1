import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/history_log_providers.dart';
import '../../providers/pipeline_providers.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/history/stage_history_timeline.dart';

/// Screen for displaying pipeline stage history.
class PipelineHistoryScreen extends ConsumerWidget {
  const PipelineHistoryScreen({
    super.key,
    required this.pipelineId,
  });

  final String pipelineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(pipelineDetailProvider(pipelineId));
    final historyAsync = ref.watch(
      pipelineStageHistoryProvider(
        PipelineStageHistoryParams(pipelineId: pipelineId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: pipelineAsync.when(
          data: (pipeline) => Text('Riwayat ${pipeline?.code ?? ''}'),
          loading: () => const Text('Riwayat Pipeline'),
          error: (_, _) => const Text('Riwayat Pipeline'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshHistory(ref),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) => StageHistoryTimeline(
          history: history,
          emptyMessage: 'Belum ada riwayat perubahan stage',
          onRefresh: () => _refreshHistory(ref),
        ),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Gagal memuat riwayat'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _refreshHistory(ref),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshHistory(WidgetRef ref) {
    ref.invalidate(
      pipelineStageHistoryProvider(
        PipelineStageHistoryParams(pipelineId: pipelineId, forceRefresh: true),
      ),
    );
  }
}
