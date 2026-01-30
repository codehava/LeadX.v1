import 'package:drift/drift.dart';

import 'scoring.dart';
import 'users.dart';

// ============================================
// WIG (WILDLY IMPORTANT GOALS) SYSTEM
// Discipline 1: Focus on the Wildly Important
// ============================================

/// WIGs - Wildly Important Goals
/// Format: "From [baseline] to [target] by [deadline]"
class Wigs extends Table {
  TextColumn get id => text()();

  // Basic info
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  // Hierarchy: COMPANY -> REGIONAL -> BRANCH -> TEAM
  TextColumn get level => text()(); // 'COMPANY', 'REGIONAL', 'BRANCH', 'TEAM'
  TextColumn get ownerId => text().references(Users, #id)();
  TextColumn get parentWigId => text().nullable()(); // For cascade from parent level

  // Measure link (optional - WIG can be linked to a specific measure)
  TextColumn get measureType => text().nullable()(); // 'LAG', 'LEAD'
  TextColumn get measureId => text().nullable().references(MeasureDefinitions, #id)();

  // WIG Statement: "From X to Y by When"
  RealColumn get baselineValue => real()(); // From X
  RealColumn get targetValue => real()(); // To Y
  RealColumn get currentValue => real().withDefault(const Constant(0))(); // Current progress

  // Timeline
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()(); // By When

  // Workflow: DRAFT -> PENDING_APPROVAL -> APPROVED/REJECTED -> ACTIVE -> COMPLETED/CANCELLED
  TextColumn get status =>
      text().withDefault(const Constant('DRAFT'))(); // DRAFT, PENDING_APPROVAL, APPROVED, REJECTED, ACTIVE, COMPLETED, CANCELLED
  DateTimeColumn get submittedAt => dateTime().nullable()();
  TextColumn get approvedBy => text().nullable().references(Users, #id)();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  TextColumn get rejectionReason => text().nullable()();

  // Progress tracking
  DateTimeColumn get lastProgressUpdate => dateTime().nullable()();
  RealColumn get progressPercentage => real().withDefault(const Constant(0))();

  // Timestamps
  TextColumn get createdBy => text().nullable().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// WIG Progress History - tracks progress over time
class WigProgress extends Table {
  TextColumn get id => text()();
  TextColumn get wigId => text().references(Wigs, #id)();
  DateTimeColumn get recordedDate => dateTime()();
  RealColumn get value => real()(); // Value at this point
  RealColumn get progressPercentage => real()(); // Calculated percentage
  TextColumn get status => text().nullable()(); // 'ON_TRACK', 'AT_RISK', 'OFF_TRACK'
  TextColumn get notes => text().nullable()();
  TextColumn get recordedBy => text().nullable().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
