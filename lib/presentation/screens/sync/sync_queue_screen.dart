import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart' as db;
import '../../providers/sync_providers.dart';

/// Debug screen for viewing and managing sync queue items.
/// This screen is intended for development/debugging purposes.
class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
    final conflictCount = ref.watch(conflictCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Queue (Debug)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Trigger Sync',
            onPressed: () => _triggerSync(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Completed',
            onPressed: () => _clearCompleted(context, ref),
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
                          '$count conflict${count == 1 ? '' : 's'} detected in last 7 days',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Sync queue items
          Expanded(
            child: FutureBuilder<List<db.SyncQueueItem>>(
        future: syncQueueDataSource.getAllItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
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
                    'Tidak ada item pending di queue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return; // Just rebuild
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => _SyncQueueItemCard(
                item: items[index],
                onRetry: () => _retryItem(context, ref, items[index]),
              ),
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
        const SnackBar(content: Text('Sync triggered')),
      );
    }
  }

  Future<void> _clearCompleted(BuildContext context, WidgetRef ref) async {
    final syncQueue = ref.read(syncQueueDataSourceProvider);
    await syncQueue.clearCompletedItems();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completed items cleared')),
      );
    }
  }

  Future<void> _retryItem(BuildContext context, WidgetRef ref, db.SyncQueueItem item) async {
    final syncQueue = ref.read(syncQueueDataSourceProvider);
    await syncQueue.resetRetryCount(item.id);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item reset for retry')),
      );
    }
  }
}

class _SyncQueueItemCard extends StatelessWidget {
  const _SyncQueueItemCard({
    required this.item,
    required this.onRetry,
  });

  final db.SyncQueueItem item;
  final VoidCallback onRetry;

  /// Derive status from retry count and error.
  String get _status {
    if (item.lastError != null && item.retryCount >= 5) {
      return 'FAILED';
    } else if (item.lastError != null) {
      return 'RETRY';
    }
    return 'PENDING';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                        item.entityType,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.operation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(theme),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Entity ID
            _InfoRow(label: 'Entity ID', value: item.entityId),
            
            // Created At
            _InfoRow(
              label: 'Created',
              value: _formatDateTime(item.createdAt),
            ),
            
            // Retry Count
            _InfoRow(
              label: 'Retries',
              value: '${item.retryCount}',
            ),

            // Error Message
            if (item.lastError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.lastError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],

            // Retry button for failed items
            if (item.lastError != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    IconData icon;
    Color color;

    switch (_status) {
      case 'PENDING':
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case 'RETRY':
        icon = Icons.sync;
        color = theme.colorScheme.primary;
        break;
      case 'FAILED':
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

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
    Color color;
    switch (_status) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'RETRY':
        color = theme.colorScheme.primary;
        break;
      case 'FAILED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
