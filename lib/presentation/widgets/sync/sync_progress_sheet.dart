import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logging/app_logger.dart';
import '../../../data/services/initial_sync_service.dart';
import '../../providers/sync_providers.dart';

/// Bottom sheet showing sync progress during initial sync.
/// Supports auto-retry with backoff and cancel-and-logout after exhausting retries.
class SyncProgressSheet extends ConsumerStatefulWidget {
  const SyncProgressSheet({super.key});

  /// Track if sync sheet is currently showing to prevent duplicates.
  static bool _isShowing = false;

  /// Show the sync progress sheet.
  /// Returns true if sync completed successfully, false if failed or cancelled.
  /// Returns immediately with false if already showing to prevent duplicate syncs.
  static Future<bool> show(BuildContext context) async {
    // Prevent showing multiple times (race condition between LoginScreen and HomeScreen)
    if (_isShowing) {
      AppLogger.instance.debug('ui.sync | Already showing, skipping duplicate call');
      return false;
    }

    _isShowing = true;
    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const SyncProgressSheet(),
      );
      return result ?? false;
    } finally {
      _isShowing = false;
    }
  }

  @override
  ConsumerState<SyncProgressSheet> createState() => _SyncProgressSheetState();
}

class _SyncProgressSheetState extends ConsumerState<SyncProgressSheet> {
  static const _retryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 15),
  ];
  static const _maxRetries = 3;

  InitialSyncProgress? _progress;
  bool _isComplete = false;
  String? _error;
  int _retryAttempt = 0;
  bool _showCancelButton = false;
  String? _retryMessage;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _startSyncWithRetry();
  }

  /// Run the sync with auto-retry and backoff.
  Future<void> _startSyncWithRetry() async {
    AppLogger.instance.info('ui.sync | Starting initial sync with retry...');

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      _retryAttempt = attempt + 1;

      if (attempt > 0) {
        // Show retry countdown message
        final delay = _retryDelays[attempt - 1];
        if (mounted) {
          setState(() {
            _retryMessage = 'Mencoba ulang dalam ${delay.inSeconds} detik... (percobaan $_retryAttempt/$_maxRetries)';
            _isComplete = false;
            _error = null;
          });
        }
        AppLogger.instance.info('ui.sync | Retry attempt $_retryAttempt/$_maxRetries after ${delay.inSeconds}s delay');
        await Future.delayed(delay);

        if (!mounted) return;

        setState(() {
          _retryMessage = null;
        });
      }

      final success = await _performSingleSyncAttempt();

      if (success) {
        AppLogger.instance.info('ui.sync | Sync succeeded on attempt $_retryAttempt');
        if (mounted) {
          setState(() {
            _isComplete = true;
            _error = null;
            _showCancelButton = false;
          });
        }
        return;
      }

      AppLogger.instance.warning('ui.sync | Sync failed on attempt $_retryAttempt/$_maxRetries');
    }

    // All retries exhausted
    AppLogger.instance.error('ui.sync | Sync failed after $_maxRetries attempts');
    if (mounted) {
      setState(() {
        _isComplete = true;
        _showCancelButton = true;
        _error = 'Sinkronisasi gagal setelah $_maxRetries percobaan';
      });
    }
  }

  /// Perform a single sync attempt. Returns true on success, false on failure.
  Future<bool> _performSingleSyncAttempt() async {
    try {
      final initialSyncService = ref.read(initialSyncServiceProvider);

      // Listen to progress updates
      initialSyncService.progressStream.listen((progress) {
        AppLogger.instance.debug('ui.sync | Progress: ${progress.message} (${progress.percentage}%)');
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      });

      // Phase 1: Sync master data
      final result = await initialSyncService.performInitialSync(
        onProgress: (progress) {
          // Also handle via callback
        },
      );

      AppLogger.instance.info('ui.sync | Master data sync result: success=${result.success}, processed=${result.processedCount}, errors=${result.errors}');

      if (!result.success && result.errors.isNotEmpty) {
        if (mounted) {
          setState(() {
            _error = result.errors.first;
          });
        }
        return false;
      }

      // Phase 2: Delta sync for transactional tables
      if (mounted) {
        setState(() {
          _progress = InitialSyncProgress(
            currentTable: 'delta_sync',
            currentTableIndex: 1,
            totalTables: 1,
            currentPage: 0,
            totalRows: 0,
            percentage: 90,
            message: 'Mengunduh data transaksional...',
          );
        });
      }

      AppLogger.instance.info('ui.sync | Starting delta sync...');
      try {
        final deltaResult = await initialSyncService.performDeltaSync();
        AppLogger.instance.info('ui.sync | Delta sync result: success=${deltaResult.success}, processed=${deltaResult.processedCount}, errors=${deltaResult.errors}');
      } catch (e) {
        AppLogger.instance.warning('ui.sync | Delta sync error: $e');
        // Don't fail the whole sync for delta sync errors - they can retry later
      }

      // Phase 3: Pull user data (customers, pipelines, activities)
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

      AppLogger.instance.info('ui.sync | Starting user data pull...');
      try {
        await ref.read(syncNotifierProvider.notifier).triggerSync(calledFromInitialSync: true);
        AppLogger.instance.info('ui.sync | User data pull complete');
      } catch (e) {
        AppLogger.instance.warning('ui.sync | User data pull error: $e');
        // Don't fail the whole sync for user data errors - they can retry later
      }

      // Mark initial sync complete AFTER all three phases (Phase 1 master data,
      // Phase 2 delta sync, Phase 3 user data pull). This ensures the 5-second
      // cooldown in SyncCoordinator only starts after the full sequence finishes,
      // not between phases. See sync_coordinator.dart _cooldownDuration.
      final coordinator = ref.read(syncCoordinatorProvider);
      await coordinator.markInitialSyncComplete();
      AppLogger.instance.info('ui.sync | All phases complete — initial sync marked done, cooldown started');

      return true;
    } catch (e, stackTrace) {
      AppLogger.instance.error('ui.sync | Unexpected sync error: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      return false;
    }
  }

  /// Handle cancel and logout: clear auth session, preserve local data, pop with false.
  Future<void> _handleCancelAndLogout() async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    AppLogger.instance.info('ui.sync | Cancel and logout: clearing auth session, preserving local data');

    try {
      await Supabase.instance.client.auth.signOut();
      AppLogger.instance.info('ui.sync | Cancel and logout: auth cleared, local data preserved');
    } catch (e) {
      AppLogger.instance.warning('ui.sync | Cancel and logout: signOut error (proceeding anyway): $e');
    }

    if (mounted) {
      Navigator.pop(context, false);
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

          // Retry message (shown between retries)
          if (_retryMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _retryMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Retry count info (shown after all retries exhausted)
          if (_isComplete && _error != null && _showCancelButton) ...[
            const SizedBox(height: 8),
            Text(
              'Percobaan: $_retryAttempt/$_maxRetries',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),

          // Progress bar
          if (!_isComplete && _progress != null && _retryMessage == null) ...[
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
          if (!_isComplete && _progress != null && _progress!.currentTable.isNotEmpty && _retryMessage == null) ...[
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

          // Buttons
          if (_isComplete && _error == null)
            // Success: show "Lanjutkan" button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lanjutkan'),
              ),
            ),

          if (_isComplete && _error != null && _showCancelButton)
            // All retries exhausted: show "Batalkan & Keluar" button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isCancelling ? null : _handleCancelAndLogout,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Batalkan & Keluar'),
              ),
            ),

          if (_isComplete && _error != null && !_showCancelButton)
            // Error but not all retries exhausted (shouldn't normally happen, but safety)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tutup'),
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
      error: (_, _) => const SizedBox.shrink(),
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
