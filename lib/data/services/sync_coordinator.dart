import 'dart:async';

import '../../core/logging/app_logger.dart';
import '../../domain/entities/sync_models.dart';
import 'app_settings_service.dart';

/// Central sync coordination service with Completer-based lock.
///
/// Prevents concurrent sync execution across all entry points (initial sync,
/// manual sync, background sync, repository-triggered sync). Gates regular
/// sync until initial sync completes. Queues excess requests into a single
/// collapsed follow-up execution.
class SyncCoordinator {
  SyncCoordinator(this._appSettings);

  final AppSettingsService _appSettings;
  final _log = AppLogger.instance;

  /// Active sync completer (null = lock available).
  Completer<void>? _activeSyncCompleter;

  /// Whether a follow-up sync is queued (capped at 1, collapses multiples).
  bool _queuedSyncPending = false;

  /// In-memory cache of initial sync completion state.
  bool _initialSyncComplete = false;

  /// Timestamp when initial sync was completed (for cooldown check).
  DateTime? _initialSyncCompletedAt;

  /// Type of sync currently holding the lock.
  SyncType? _currentSyncType;

  /// When the lock was acquired (for timeout-based recovery).
  DateTime? _lockAcquiredAt;

  /// Maximum time a lock can be held before force-release.
  static const Duration _lockTimeout = Duration(minutes: 5);

  /// Cooldown after initial sync completes to prevent premature regular sync.
  static const Duration _cooldownDuration = Duration(seconds: 5);

  /// Whether initial sync has been completed.
  bool get isInitialSyncComplete => _initialSyncComplete;

  /// Whether the sync lock is currently held.
  bool get isLocked => _activeSyncCompleter != null;

  /// The type of sync currently holding the lock.
  SyncType? get currentSyncType => _currentSyncType;

  /// Whether a follow-up sync is queued.
  bool get hasQueuedSync => _queuedSyncPending;

  /// Initialize the coordinator by loading persisted state.
  ///
  /// Reads initial sync completion state from AppSettingsService and
  /// clears any stale lock from a previous session (app kill recovery).
  Future<void> initialize() async {
    _initialSyncComplete = await _appSettings.hasInitialSyncCompleted();
    _initialSyncCompletedAt = await _appSettings.getInitialSyncCompletedAt();

    // Startup lock recovery: clear stale lock from previous session
    final staleLockHolder = await _appSettings.getSyncLockHolder();
    if (staleLockHolder != null) {
      _log.warning(
        'sync.coordinator | Clearing stale lock from previous session (was: $staleLockHolder)',
      );
      await _appSettings.setSyncLockHolder(null);
    }
  }

  /// Attempt to acquire the sync lock.
  ///
  /// Returns `true` if the lock was acquired, `false` if rejected.
  /// When rejected, non-initial sync types are queued for a single
  /// follow-up execution.
  Future<bool> acquireLock({required SyncType type, bool skipInitialSyncChecks = false}) async {
    // If lock is currently held
    if (_activeSyncCompleter != null) {
      // Check for stale lock timeout recovery
      if (_lockAcquiredAt != null) {
        final elapsed = DateTime.now().difference(_lockAcquiredAt!);
        if (elapsed > _lockTimeout) {
          _log.warning(
            'sync.coordinator | Force-releasing stale lock held for ${elapsed.inSeconds}s (type: $_currentSyncType)',
          );
          _forceReleaseLock();
          // Fall through to acquire below
        } else {
          // Lock is held and not stale
          if (type == SyncType.initial) {
            _log.warning(
              'sync.coordinator | Rejected initial sync (lock held by $_currentSyncType)',
            );
            return false;
          }
          _queuedSyncPending = true;
          _log.debug(
            'sync.coordinator | Queued $type sync (lock held by $_currentSyncType)',
          );
          return false;
        }
      } else {
        // Lock held but no acquisition time (shouldn't happen, but handle gracefully)
        if (type == SyncType.initial) {
          _log.warning(
            'sync.coordinator | Rejected initial sync (lock held by $_currentSyncType)',
          );
          return false;
        }
        _queuedSyncPending = true;
        _log.debug(
          'sync.coordinator | Queued $type sync (lock held by $_currentSyncType)',
        );
        return false;
      }
    }

    // Gate regular sync until initial sync completes
    // (skipInitialSyncChecks=true is used by Phase 2/3 of the initial sync orchestration)
    if (!skipInitialSyncChecks && !_initialSyncComplete && type != SyncType.initial) {
      _log.debug(
        'sync.coordinator | Rejected $type sync (initial sync not complete)',
      );
      return false;
    }

    // Cooldown check after initial sync
    // (skipInitialSyncChecks=true bypasses this for Phase 2/3 of initial sync orchestration)
    if (!skipInitialSyncChecks && _initialSyncCompletedAt != null && type != SyncType.initial) {
      final elapsed = DateTime.now().difference(_initialSyncCompletedAt!);
      if (elapsed < _cooldownDuration) {
        final remainingMs =
            (_cooldownDuration - elapsed).inMilliseconds;
        _log.debug(
          'sync.coordinator | Rejected $type sync (cooldown active, ${remainingMs}ms left)',
        );
        return false;
      }
    }

    // Acquire the lock
    _activeSyncCompleter = Completer<void>();
    _currentSyncType = type;
    _lockAcquiredAt = DateTime.now();
    await _appSettings.setSyncLockHolder(type.name);
    _log.info('sync.coordinator | Acquired lock for $type');
    return true;
  }

  /// Release the sync lock.
  ///
  /// Completes the active completer and clears all lock state.
  /// Logs the duration the lock was held.
  void releaseLock() {
    final type = _currentSyncType;
    final acquiredAt = _lockAcquiredAt;
    final durationMs = acquiredAt != null
        ? DateTime.now().difference(acquiredAt).inMilliseconds
        : 0;

    if (_activeSyncCompleter != null && !_activeSyncCompleter!.isCompleted) {
      _activeSyncCompleter!.complete();
    }
    _activeSyncCompleter = null;
    _currentSyncType = null;
    _lockAcquiredAt = null;
    _appSettings.setSyncLockHolder(null);
    _log.info('sync.coordinator | Released lock for $type (held ${durationMs}ms)');
  }

  /// Mark initial sync as complete and start cooldown.
  Future<void> markInitialSyncComplete() async {
    _initialSyncComplete = true;
    _initialSyncCompletedAt = DateTime.now();
    await _appSettings.markInitialSyncCompleted();
    await _appSettings.setInitialSyncCompletedAt(DateTime.now().toUtc());
    _log.info('sync.coordinator | Initial sync marked complete');
  }

  /// Reset initial sync state (for schema migration detection or logout).
  void resetInitialSyncState() {
    _initialSyncComplete = false;
    _initialSyncCompletedAt = null;
    _log.info('sync.coordinator | Initial sync state reset');
  }

  /// Mark that a follow-up sync is pending.
  void setQueuedSyncPending() {
    _queuedSyncPending = true;
  }

  /// Consume the queued sync flag.
  ///
  /// Returns `true` if a sync was queued (and clears the flag),
  /// `false` otherwise.
  bool consumeQueuedSync() {
    if (_queuedSyncPending) {
      _queuedSyncPending = false;
      return true;
    }
    return false;
  }

  /// Force-release the lock without logging release message.
  /// Used internally for stale lock recovery.
  void _forceReleaseLock() {
    if (_activeSyncCompleter != null && !_activeSyncCompleter!.isCompleted) {
      _activeSyncCompleter!.complete();
    }
    _activeSyncCompleter = null;
    _currentSyncType = null;
    _lockAcquiredAt = null;
    _appSettings.setSyncLockHolder(null);
  }
}
