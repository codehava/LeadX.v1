import 'package:drift/drift.dart';

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
    await set(keyLastSyncAt, DateTime.now().toIso8601String());
    await delete(keyLastSyncedTableIndex);
    await delete(keySyncInProgress);
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

  /// Clear all settings (for logout).
  Future<void> clearAll() async {
    await _db.delete(_db.appSettings).go();
  }
}

