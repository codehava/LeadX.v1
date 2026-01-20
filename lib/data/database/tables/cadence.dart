import 'package:drift/drift.dart';

import 'users.dart';

// ============================================
// CADENCE MEETING SYSTEM
// ============================================

/// Cadence schedule configuration per level.
class CadenceScheduleConfig extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get targetRole => text()(); // Role that attends: RM, BH, BM, ROH
  TextColumn get facilitatorRole => text()(); // Role that facilitates
  TextColumn get frequency => text()(); // 'DAILY', 'WEEKLY', 'MONTHLY'
  IntColumn get dayOfWeek => integer().nullable()(); // 0-6 for weekly
  IntColumn get dayOfMonth => integer().nullable()(); // 1-31 for monthly
  TextColumn get defaultTime => text().nullable()(); // HH:mm format
  IntColumn get durationMinutes => integer().withDefault(const Constant(60))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cadence meeting instances.
class CadenceMeetings extends Table {
  TextColumn get id => text()();
  TextColumn get configId => text().references(CadenceScheduleConfig, #id)();
  TextColumn get title => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get facilitatorId => text().references(Users, #id)();
  TextColumn get status => text().withDefault(const Constant('SCHEDULED'))(); // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
  TextColumn get location => text().nullable()();
  TextColumn get meetingLink => text().nullable()();
  TextColumn get agenda => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get createdBy => text().references(Users, #id)();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cadence meeting participants with pre-meeting form.
class CadenceParticipants extends Table {
  TextColumn get id => text()();
  TextColumn get meetingId => text().references(CadenceMeetings, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get role => text()(); // 'FACILITATOR', 'PARTICIPANT', 'OBSERVER'
  TextColumn get attendanceStatus => text().withDefault(const Constant('PENDING'))(); // PENDING, CONFIRMED, ATTENDED, ABSENT
  
  // Pre-meeting form (WIG commitment)
  TextColumn get preMeetingCommitment => text().nullable()(); // What they commit to achieve
  TextColumn get previousCommitmentStatus => text().nullable()(); // COMPLETED, PARTIAL, NOT_DONE
  TextColumn get blockers => text().nullable()();
  
  // Post-meeting updates
  TextColumn get postMeetingNotes => text().nullable()();
  TextColumn get nextCommitment => text().nullable()();
  
  DateTimeColumn get formSubmittedAt => dateTime().nullable()();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
