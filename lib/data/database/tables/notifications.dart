import 'package:drift/drift.dart';

import 'users.dart';

// ============================================
// NOTIFICATIONS
// ============================================

/// User notifications.
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get type => text()(); // ACTIVITY_REMINDER, PIPELINE_UPDATE, REFERRAL, CADENCE, SYSTEM, etc.
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get data => text().nullable()(); // JSON payload
  TextColumn get actionType => text().nullable()(); // NAVIGATE, OPEN_URL, etc.
  TextColumn get actionTarget => text().nullable()(); // Route or URL
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Notification settings per user.
class NotificationSettings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().unique().references(Users, #id)();
  BoolColumn get pushEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get emailEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get activityReminders => boolean().withDefault(const Constant(true))();
  BoolColumn get pipelineUpdates => boolean().withDefault(const Constant(true))();
  BoolColumn get referralNotifications => boolean().withDefault(const Constant(true))();
  BoolColumn get cadenceReminders => boolean().withDefault(const Constant(true))();
  BoolColumn get systemNotifications => boolean().withDefault(const Constant(true))();
  IntColumn get reminderMinutesBefore => integer().withDefault(const Constant(30))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// ANNOUNCEMENTS
// ============================================

/// System announcements.
class Announcements extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get type => text().withDefault(const Constant('INFO'))(); // INFO, WARNING, IMPORTANT
  TextColumn get targetRoles => text().nullable()(); // JSON array of roles, null = all
  TextColumn get targetBranches => text().nullable()(); // JSON array of branch IDs, null = all
  DateTimeColumn get publishAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get createdBy => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Announcement read status per user.
class AnnouncementReads extends Table {
  TextColumn get id => text()();
  TextColumn get announcementId => text().references(Announcements, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
