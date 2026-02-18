import 'package:drift/drift.dart';

import '../../core/utils/date_time_utils.dart';
import '../database/app_database.dart';

/// Service for managing app settings stored in local database.
class AppSettingsService {
  AppSettingsService(this._db);

  final AppDatabase _db;

  /// Key for initial sync completed flag.
  static const String keyInitialSyncCompleted = 'initial_sync_completed';

  /// Key for last sync timestamp.
  static const String keyLastSyncAt = 'last_sync_at';

  /// Key for current user ID.
  static const String keyCurrentUserId = 'current_user_id';

  /// Key for last synced table index (for resume).
  static const String keyLastSyncedTableIndex = 'last_synced_table_index';

  /// Key for sync in progress flag.
  static const String keySyncInProgress = 'sync_in_progress';

  /// Key for theme mode preference.
  static const String keyThemeMode = 'theme_mode';

  /// Key for initial sync completed timestamp (ISO 8601).
  static const String keyInitialSyncCompletedAt = 'initial_sync_completed_at';

  /// Key for persisted sync lock holder (for crash recovery).
  static const String keySyncLockHolder = 'sync_lock_holder';

  /// Get a setting value by key.
  Future<String?> get(String key) async {
    final setting = await (_db.select(_db.appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return setting?.value;
  }

  /// Set a setting value.
  Future<void> set(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Delete a setting.
  Future<void> delete(String key) async {
    await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
  }

  /// Check if initial sync has been completed.
  Future<bool> hasInitialSyncCompleted() async {
    final value = await get(keyInitialSyncCompleted);
    return value == 'true';
  }

  /// Mark initial sync as completed.
  Future<void> markInitialSyncCompleted() async {
    await set(keyInitialSyncCompleted, 'true');
    await set(keyLastSyncAt, DateTime.now().toUtcIso8601());
    await delete(keyLastSyncedTableIndex);
    await delete(keySyncInProgress);
    await setInitialSyncCompletedAt(DateTime.now().toUtc());
  }

  /// Get the timestamp when initial sync was completed.
  Future<DateTime?> getInitialSyncCompletedAt() async {
    final value = await get(keyInitialSyncCompletedAt);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Set the timestamp when initial sync was completed.
  Future<void> setInitialSyncCompletedAt(DateTime timestamp) async {
    await set(keyInitialSyncCompletedAt, timestamp.toUtcIso8601());
  }

  /// Get the current sync lock holder (for crash recovery).
  Future<String?> getSyncLockHolder() async {
    return get(keySyncLockHolder);
  }

  /// Set or clear the sync lock holder.
  /// Pass null to clear (delete) the key.
  Future<void> setSyncLockHolder(String? holder) async {
    if (holder == null) {
      await delete(keySyncLockHolder);
    } else {
      await set(keySyncLockHolder, holder);
    }
  }

  /// Get last sync timestamp.
  Future<DateTime?> getLastSyncAt() async {
    final value = await get(keyLastSyncAt);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  // ========================================
  // RESUME SYNC METHODS
  // ========================================

  /// Get the index to resume sync from (0 = start from beginning).
  Future<int> getResumeSyncIndex() async {
    final value = await get(keyLastSyncedTableIndex);
    if (value == null) return 0;
    return int.tryParse(value) ?? 0;
  }

  /// Mark a table as synced (for resume tracking).
  Future<void> markTableSynced(int tableIndex) async {
    await set(keyLastSyncedTableIndex, tableIndex.toString());
  }

  /// Mark sync as started.
  Future<void> markSyncStarted() async {
    await set(keySyncInProgress, 'true');
  }

  /// Check if there's an interrupted sync to resume.
  Future<bool> hasInterruptedSync() async {
    final inProgress = await get(keySyncInProgress);
    if (inProgress != 'true') return false;

    final completed = await hasInitialSyncCompleted();
    return !completed;
  }

  // ========================================
  // PER-TABLE DELTA SYNC TIMESTAMPS
  // ========================================

  /// Key prefix for per-table sync timestamps.
  static const String _keyTableSyncPrefix = 'table_sync_at_';

  /// Get the last sync timestamp for a specific table.
  /// Returns null if the table has never been synced (triggers full sync).
  Future<DateTime?> getTableLastSyncAt(String tableName) async {
    final value = await get('$_keyTableSyncPrefix$tableName');
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Set the last sync timestamp for a specific table.
  Future<void> setTableLastSyncAt(String tableName, DateTime timestamp) async {
    await set('$_keyTableSyncPrefix$tableName', timestamp.toUtcIso8601());
  }

  /// Clear the sync timestamp for a specific table (forces full re-sync).
  Future<void> clearTableSyncAt(String tableName) async {
    await delete('$_keyTableSyncPrefix$tableName');
  }

  /// Clear all table sync timestamps (for logout or full reset).
  Future<void> clearAllTableSyncTimestamps() async {
    final settings = await _db.select(_db.appSettings).get();
    for (final setting in settings) {
      if (setting.key.startsWith(_keyTableSyncPrefix)) {
        await delete(setting.key);
      }
    }
  }

  /// Clear all settings (for logout).
  Future<void> clearAll() async {
    await _db.delete(_db.appSettings).go();
  }
}

