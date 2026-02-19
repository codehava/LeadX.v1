import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';

/// Local data source for notification settings.
///
/// Provides CRUD operations for the notification_settings table.
/// Notification settings are local-only (device preferences) - no sync to Supabase.
class NotificationSettingsLocalDataSource {
  final AppDatabase _db;

  NotificationSettingsLocalDataSource(this._db);

  /// Watch the notification settings row for a user.
  /// Returns a stream that emits null if no settings exist yet.
  Stream<NotificationSetting?> watchSettings(String userId) {
    return (_db.select(_db.notificationSettings)
          ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  /// Get current notification settings for a user.
  Future<NotificationSetting?> getSettings(String userId) {
    return (_db.select(_db.notificationSettings)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Insert or update notification settings.
  Future<void> upsertSettings(NotificationSettingsCompanion companion) async {
    await _db.into(_db.notificationSettings).insertOnConflictUpdate(companion);
  }

  /// Ensure default settings exist for a user.
  /// If no settings row exists, creates one with all booleans = true
  /// and reminderMinutesBefore = 30.
  Future<void> ensureDefaultSettings(String userId) async {
    final existing = await getSettings(userId);
    if (existing == null) {
      final id = const Uuid().v4();
      await _db.into(_db.notificationSettings).insert(
            NotificationSettingsCompanion.insert(
              id: id,
              userId: userId,
              updatedAt: DateTime.now(),
            ),
          );
    }
  }
}
