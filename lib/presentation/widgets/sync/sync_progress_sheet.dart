import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/initial_sync_service.dart';
import '../../providers/sync_providers.dart';

/// Bottom sheet showing sync progress during initial sync.
class SyncProgressSheet extends ConsumerStatefulWidget {
  const SyncProgressSheet({super.key});

  /// Show the sync progress sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SyncProgressSheet(),
    );
  }

  @override
  ConsumerState<SyncProgressSheet> createState() => _SyncProgressSheetState();
}

class _SyncProgressSheetState extends ConsumerState<SyncProgressSheet> {
  InitialSyncProgress? _progress;
  bool _isComplete = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startSync();
  }

  Future<void> _startSync() async {
    print('[SyncProgressSheet] Starting initial sync...');
    final initialSyncService = ref.read(initialSyncServiceProvider);
    
    // Listen to progress updates
    initialSyncService.progressStream.listen((progress) {
      print('[SyncProgressSheet] Progress: ${progress.message} (${progress.percentage}%)');
      if (mounted) {
        setState(() {
          _progress = progress;
          // Don't mark complete yet - we still need to pull user data
        });
      }
    });

    // Phase 1: Sync master data
    final result = await initialSyncService.performInitialSync(
      onProgress: (progress) {
        // Also handle via callback
      },
    );

    print('[SyncProgressSheet] Master data sync result: success=${result.success}, processed=${result.processedCount}, errors=${result.errors}');

    if (!result.success && result.errors.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isComplete = true;
          _error = result.errors.first;
        });
      }
      return;
    }

    // Phase 2: Pull user data (customers, pipelines, activities)
    if (mounted) {
      setState(() {
        _progress = InitialSyncProgress(
          currentTable: 'user_data',
          currentTableIndex: 1,
          totalTables: 1,
          currentPage: 0,
          totalRows: 0,
          percentage: 95,
          message: 'Mengunduh data pengguna...',
        );
      });
    }

    print('[SyncProgressSheet] Starting user data pull...');
    try {
      await ref.read(syncNotifierProvider.notifier).triggerSync();
      print('[SyncProgressSheet] User data pull complete');
    } catch (e) {
      print('[SyncProgressSheet] User data pull error: $e');
      // Don't fail the whole sync for user data errors - they can retry later
    }

    if (mounted) {
      setState(() {
        _isComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isComplete
                  ? (_error != null ? Colors.red : Colors.green).withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: _isComplete
                ? Icon(
                    _error != null ? Icons.error_outline : Icons.check_circle,
                    size: 48,
                    color: _error != null ? Colors.red : Colors.green,
                  )
                : SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            _isComplete
                ? (_error != null ? 'Sinkronisasi Gagal' : 'Sinkronisasi Selesai')
                : 'Sinkronisasi Data',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            _error ?? _progress?.message ?? 'Mempersiapkan...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Progress bar
          if (!_isComplete && _progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress!.percentage / 100,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_progress!.currentTableIndex}/${_progress!.totalTables} tabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          // Table list (showing current progress)
          if (!_isComplete && _progress != null && _progress!.currentTable.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _progress!.currentTable,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Close button (only when complete)
          if (_isComplete)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_error != null ? 'Tutup' : 'Lanjutkan'),
              ),
            ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Compact sync status widget for app bar.
class SyncProgressIndicator extends ConsumerWidget {
  const SyncProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) => state.when(
        idle: () => const SizedBox.shrink(),
        syncing: (total, current, currentEntity) => _buildSyncingIndicator(context, current, total),
        success: (result) => const SizedBox.shrink(),
        error: (message, error) => _buildErrorIndicator(context, message),
        offline: () => _buildOfflineIndicator(context),
      ),
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSyncingIndicator(BuildContext context, int progress, int total) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: total > 0 ? progress / total : null,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$progress/$total',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorIndicator(BuildContext context, String message) {
    return IconButton(
      icon: const Icon(Icons.sync_problem, color: Colors.orange),
      tooltip: message,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    return const Tooltip(
      message: 'Offline - Perubahan akan disinkronkan saat online',
      child: Icon(Icons.cloud_off, size: 20),
    );
  }
}
