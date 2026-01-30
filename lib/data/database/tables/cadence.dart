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
  IntColumn get preMeetingHours => integer().withDefault(const Constant(24))(); // Hours before meeting for form deadline
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

/// Cadence meeting participants - combined table for attendance, form submission, and feedback.
/// This is the single source of truth for all participant data per meeting.
class CadenceParticipants extends Table {
  TextColumn get id => text()();
  TextColumn get meetingId => text().references(CadenceMeetings, #id)();
  TextColumn get userId => text().references(Users, #id)();

  // ============================================
  // ATTENDANCE (marked during meeting by host)
  // ============================================
  /// Status: PENDING, PRESENT, LATE, EXCUSED, ABSENT
  TextColumn get attendanceStatus => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get arrivedAt => dateTime().nullable()();
  TextColumn get excusedReason => text().nullable()();
  IntColumn get attendanceScoreImpact => integer().nullable()(); // +3 present, +1 late, 0 excused, -5 absent
  TextColumn get markedBy => text().nullable()(); // Host who marked attendance
  DateTimeColumn get markedAt => dateTime().nullable()();

  // ============================================
  // PRE-MEETING FORM (Q1-Q4, submitted before meeting)
  // ============================================
  BoolColumn get preMeetingSubmitted => boolean().withDefault(const Constant(false))();
  /// Q1: Previous commitment (auto-filled from last meeting's Q4)
  TextColumn get q1PreviousCommitment => text().nullable()();
  /// Q1: Status of previous commitment
  TextColumn get q1CompletionStatus => text().nullable()(); // COMPLETED, PARTIAL, NOT_DONE
  /// Q2: What was achieved this period (required)
  TextColumn get q2WhatAchieved => text().nullable()();
  /// Q3: Obstacles/blockers faced (optional)
  TextColumn get q3Obstacles => text().nullable()();
  /// Q4: Commitment for next period (required)
  TextColumn get q4NextCommitment => text().nullable()();
  DateTimeColumn get formSubmittedAt => dateTime().nullable()();
  /// Status: ON_TIME, LATE, VERY_LATE, NOT_SUBMITTED
  TextColumn get formSubmissionStatus => text().nullable()();
  IntColumn get formScoreImpact => integer().nullable()(); // +2 on-time, 0 late, -1 very late, -3 not submitted

  // ============================================
  // HOST NOTES & FEEDBACK (during/after meeting)
  // ============================================
  /// Internal notes by host (not visible to participant)
  TextColumn get hostNotes => text().nullable()();
  /// Formal feedback visible to participant
  TextColumn get feedbackText => text().nullable()();
  DateTimeColumn get feedbackGivenAt => dateTime().nullable()();
  DateTimeColumn get feedbackUpdatedAt => dateTime().nullable()();

  // ============================================
  // SYNC
  // ============================================
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
