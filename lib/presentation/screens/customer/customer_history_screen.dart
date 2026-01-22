import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/customer_providers.dart';
import '../../providers/history_log_providers.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/history/history_timeline.dart';

/// Screen for displaying customer change history.
class CustomerHistoryScreen extends ConsumerWidget {
  const CustomerHistoryScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final historyAsync = ref.watch(customerHistoryProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        title: customerAsync.when(
          data: (customer) => Text('Riwayat ${customer?.name ?? ''}'),
          loading: () => const Text('Riwayat Customer'),
          error: (_, __) => const Text('Riwayat Customer'),
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
        data: (history) => HistoryTimeline(
          logs: history,
          emptyMessage: 'Belum ada riwayat perubahan',
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
    ref.invalidate(customerHistoryProvider(customerId));
  }
}
