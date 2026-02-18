import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/sync_error_translator.dart';
import '../../../data/database/app_database.dart' as db;
import '../../../data/services/sync_service.dart';
import '../../providers/sync_providers.dart';

/// Production-ready sync queue screen with dead letter prominence.
/// Shows permanently failed sync items with translated Indonesian error messages,
/// and allows retry/discard actions.
class SyncQueueScreen extends ConsumerStatefulWidget {
  const SyncQueueScreen({super.key});

  @override
  ConsumerState<SyncQueueScreen> createState() => _SyncQueueScreenState();
}

class _SyncQueueScreenState extends ConsumerState<SyncQueueScreen> {
  /// Filter: 'gagal' shows failed+dead_letter, 'semua' shows all.
  String _filter = 'gagal';

  /// Key to force FutureBuilder rebuild.
  int _rebuildKey = 0;

  void _rebuild() {
    setState(() {
      _rebuildKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
    final syncService = ref.watch(syncServiceProvider);
    final conflictCount = ref.watch(conflictCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinkronisasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sinkronkan Sekarang',
            onPressed: () => _triggerSync(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Conflict count banner
          conflictCount.when(
            data: (count) => count > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: theme.colorScheme.tertiaryContainer,
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$count konflik terdeteksi dalam 7 hari terakhir',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Filter toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'gagal',
                  label: Text('Gagal'),
                  icon: Icon(Icons.error_outline, size: 18),
                ),
                ButtonSegment(
                  value: 'semua',
                  label: Text('Semua'),
                  icon: Icon(Icons.list, size: 18),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _filter = newSelection.first;
                  _rebuildKey++;
                });
              },
              showSelectedIcon: false,
            ),
          ),

          // Queue items
          Expanded(
            child: FutureBuilder<List<db.SyncQueueItem>>(
              key: ValueKey('$_filter-$_rebuildKey'),
              future: _filter == 'gagal'
                  ? syncQueueDataSource.getFailedAndDeadLetterItems()
                  : syncQueueDataSource.getAllItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Terjadi kesalahan: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_done,
                          size: 64,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Semua data tersinkronisasi',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filter == 'gagal'
                              ? 'Tidak ada item gagal'
                              : 'Tidak ada item di antrian',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Check if there are any dead letter items for bulk retry
                final hasDeadLetters = items.any(
                    (item) => item.status == 'dead_letter');

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(syncNotifierProvider.notifier)
                        .triggerSync();
                    _rebuild();
                  },
                  child: Column(
                    children: [
                      // Bulk retry button
                      if (hasDeadLetters)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _bulkRetryAll(
                                  context, ref, items),
                              icon: const Icon(Icons.replay, size: 18),
                              label: const Text('Coba Ulang Semua'),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              _SyncQueueItemCard(
                            item: items[index],
                            onRetry: () =>
                                _retryItem(context, ref, items[index]),
                            onDiscard: () => _discardItem(
                                context, ref, syncService, items[index]),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSync(BuildContext context, WidgetRef ref) async {
    final syncNotifier = ref.read(syncNotifierProvider.notifier);
    await syncNotifier.triggerSync();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sinkronisasi dimulai...')),
      );
    }
    _rebuild();
  }

  Future<void> _retryItem(
      BuildContext context, WidgetRef ref, db.SyncQueueItem item) async {
    final syncQueue = ref.read(syncQueueDataSourceProvider);
    await syncQueue.resetRetryCount(item.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item akan dicoba ulang')),
      );
    }
    _rebuild();
  }

  Future<void> _discardItem(BuildContext context, WidgetRef ref,
      SyncService syncService, db.SyncQueueItem item) async {
    // Build confirmation message based on operation type
    final String confirmMessage;
    switch (item.operation) {
      case 'create':
        confirmMessage =
            'Item ini belum pernah disinkronkan ke server. Data akan tetap ada di perangkat Anda tetapi tidak terlihat oleh pengguna lain.';
      case 'update':
        confirmMessage =
            'Server akan menyimpan versi lama dari data ini.';
      case 'delete':
        confirmMessage =
            'Penghapusan dibatalkan. Data tetap ada di perangkat dan server.';
      default:
        confirmMessage = 'Item ini akan dihapus dari antrian sinkronisasi.';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buang Item?'),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Buang'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await syncService.discardDeadLetterItem(item);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item dihapus dari antrian')),
        );
      }
      _rebuild();
    }
  }

  Future<void> _bulkRetryAll(BuildContext context, WidgetRef ref,
      List<db.SyncQueueItem> items) async {
    final syncQueue = ref.read(syncQueueDataSourceProvider);
    var count = 0;
    for (final item in items) {
      if (item.status == 'dead_letter' || item.status == 'failed') {
        await syncQueue.resetRetryCount(item.id);
        count++;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count item akan dicoba ulang')),
      );
    }

    // Trigger sync after bulk retry (fire-and-forget)
    unawaited(ref.read(syncNotifierProvider.notifier).triggerSync());
    _rebuild();
  }
}

class _SyncQueueItemCard extends StatelessWidget {
  const _SyncQueueItemCard({
    required this.item,
    required this.onRetry,
    required this.onDiscard,
  });

  final db.SyncQueueItem item;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  /// Map status string to Indonesian display label.
  String get _statusLabel => switch (item.status) {
        'dead_letter' => 'GAGAL PERMANEN',
        'failed' => 'GAGAL',
        'pending' => 'MENUNGGU',
        _ => item.status.toUpperCase(),
      };

  /// Map status string to color.
  Color get _statusColor => switch (item.status) {
        'dead_letter' => Colors.red.shade700,
        'failed' => Colors.orange.shade700,
        'pending' => Colors.blue,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeadLetterOrFailed =
        item.status == 'dead_letter' || item.status == 'failed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _buildStatusIcon(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SyncErrorTranslator.entityTypeName(item.entityType),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              SyncErrorTranslator.operationName(
                                  item.operation),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Percobaan: ${item.retryCount}/5',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(theme),
              ],
            ),

            // Error message (translated)
            if (item.lastError != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  SyncErrorTranslator.translate(item.lastError),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],

            // Timestamp
            const SizedBox(height: 8),
            Text(
              _formatDateTime(item.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // Expandable entity ID (for power users)
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  'Detail',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                children: [
                  _InfoRow(label: 'Entity ID', value: item.entityId),
                  _InfoRow(label: 'Tipe', value: item.entityType),
                  _InfoRow(label: 'Operasi', value: item.operation),
                  if (item.lastError != null)
                    _InfoRow(label: 'Error', value: item.lastError!),
                ],
              ),
            ),

            // Action buttons for failed/dead_letter items
            if (isDeadLetterOrFailed) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba Ulang'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDiscard,
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade600),
                      label: Text(
                        'Buang',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    final (IconData icon, Color color) = switch (item.status) {
      'dead_letter' => (Icons.error, Colors.red.shade700),
      'failed' => (Icons.warning_amber, Colors.orange.shade700),
      'pending' => (Icons.schedule, Colors.blue),
      _ => (Icons.help_outline, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        _statusLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
