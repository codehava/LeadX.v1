import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart' hide User;
import '../../data/datasources/local/notification_settings_local_data_source.dart';
import 'auth_providers.dart';
import 'database_provider.dart';

/// Provider for the notification settings local data source.
final notificationSettingsLocalDataSourceProvider =
    Provider<NotificationSettingsLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationSettingsLocalDataSource(db);
});

/// StreamProvider that watches notification settings for the current user.
///
/// On first access, ensures default settings exist (all enabled, 30 min reminder).
/// Returns null while loading or if no user is authenticated.
final notificationSettingsProvider =
    StreamProvider<NotificationSetting?>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield null;
    return;
  }

  final localDataSource =
      ref.watch(notificationSettingsLocalDataSourceProvider);

  // Ensure default settings exist on first access
  await localDataSource.ensureDefaultSettings(user.id);

  // Watch the settings stream
  yield* localDataSource.watchSettings(user.id);
});

/// Notifier for updating individual notification settings.
///
/// Each method updates a single field in the notification_settings table.
/// Changes persist immediately to the local Drift database.
/// No sync queuing - notification settings are local-only device preferences.
class NotificationSettingsNotifier {
  final NotificationSettingsLocalDataSource _localDataSource;
  final String _userId;

  NotificationSettingsNotifier(this._localDataSource, this._userId);

  Future<void> updatePushEnabled({required bool value}) async {
    await _updateField(pushEnabled: Value(value));
  }

  Future<void> updateEmailEnabled({required bool value}) async {
    await _updateField(emailEnabled: Value(value));
  }

  Future<void> updateActivityReminders({required bool value}) async {
    await _updateField(activityReminders: Value(value));
  }

  Future<void> updatePipelineUpdates({required bool value}) async {
    await _updateField(pipelineUpdates: Value(value));
  }

  Future<void> updateReferralNotifications({required bool value}) async {
    await _updateField(referralNotifications: Value(value));
  }

  Future<void> updateCadenceReminders({required bool value}) async {
    await _updateField(cadenceReminders: Value(value));
  }

  Future<void> updateSystemNotifications({required bool value}) async {
    await _updateField(systemNotifications: Value(value));
  }

  Future<void> updateReminderMinutesBefore({required int value}) async {
    await _updateField(reminderMinutesBefore: Value(value));
  }

  /// Helper to update a single field plus updatedAt timestamp.
  Future<void> _updateField({
    Value<bool> pushEnabled = const Value.absent(),
    Value<bool> emailEnabled = const Value.absent(),
    Value<bool> activityReminders = const Value.absent(),
    Value<bool> pipelineUpdates = const Value.absent(),
    Value<bool> referralNotifications = const Value.absent(),
    Value<bool> cadenceReminders = const Value.absent(),
    Value<bool> systemNotifications = const Value.absent(),
    Value<int> reminderMinutesBefore = const Value.absent(),
  }) async {
    final current = await _localDataSource.getSettings(_userId);
    if (current == null) return;

    final companion = NotificationSettingsCompanion(
      id: Value(current.id),
      userId: Value(_userId),
      pushEnabled: pushEnabled,
      emailEnabled: emailEnabled,
      activityReminders: activityReminders,
      pipelineUpdates: pipelineUpdates,
      referralNotifications: referralNotifications,
      cadenceReminders: cadenceReminders,
      systemNotifications: systemNotifications,
      reminderMinutesBefore: reminderMinutesBefore,
      updatedAt: Value(DateTime.now()),
    );
    await _localDataSource.upsertSettings(companion);
  }
}

/// Provider for the NotificationSettingsNotifier.
///
/// Requires an authenticated user. Returns null if no user is logged in.
final notificationSettingsNotifierProvider =
    FutureProvider<NotificationSettingsNotifier?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;

  final localDataSource =
      ref.watch(notificationSettingsLocalDataSourceProvider);
  return NotificationSettingsNotifier(localDataSource, user.id);
});
