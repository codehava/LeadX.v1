import 'package:drift/drift.dart';

import 'users.dart';

// ============================================
// 4DX SCORING SYSTEM
// ============================================

/// Measure definitions (lead & lag measures).
class MeasureDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get measureType => text()(); // 'LEAD' or 'LAG'
  TextColumn get dataType =>
      text().withDefault(const Constant('COUNT'))(); // 'COUNT', 'SUM', 'PERCENTAGE'
  TextColumn get unit => text()(); // 'visits', 'IDR', '%'
  TextColumn get calculationMethod => text().nullable()();
  TextColumn get calculationFormula => text().nullable()(); // For computed measures
  TextColumn get sourceTable =>
      text().nullable()(); // Auto-pull from table (activities, pipelines, customers)
  TextColumn get sourceCondition => text().nullable()(); // WHERE clause
  RealColumn get weight =>
      real().withDefault(const Constant(1.0))(); // Scoring weight (60% lead, 40% lag)
  RealColumn get defaultTarget => real().nullable()(); // Default target value
  TextColumn get periodType =>
      text().withDefault(const Constant('WEEKLY'))(); // 'WEEKLY', 'MONTHLY', 'QUARTERLY'
  TextColumn get templateType => text().nullable()(); // Template used (activity_count, pipeline_count, etc.)
  TextColumn get templateConfig => text().nullable()(); // JSON config for template (stored as JSON string)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Scoring periods (weekly, monthly, quarterly).
class ScoringPeriods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get periodType => text()(); // 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))(); // Locked periods prevent changes
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User targets per period per measure.
class UserTargets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get measureId => text().references(MeasureDefinitions, #id)();
  TextColumn get periodId => text().references(ScoringPeriods, #id)();
  RealColumn get targetValue => real()();
  TextColumn get assignedBy => text().references(Users, #id)();
  DateTimeColumn get assignedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User scores (actual) per period per measure.
class UserScores extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get measureId => text().references(MeasureDefinitions, #id)();
  TextColumn get periodId => text().references(ScoringPeriods, #id)();
  RealColumn get targetValue => real()(); // Denormalized for efficiency
  RealColumn get actualValue => real().withDefault(const Constant(0))();
  RealColumn get percentage =>
      real().withDefault(const Constant(0))(); // (actual/target)*100, capped at 150
  RealColumn get score => real().withDefault(const Constant(0))(); // Weighted score
  IntColumn get rank => integer().nullable()();
  DateTimeColumn get calculatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User score aggregates - real-time aggregated scores per period with ranking.
/// Maps to user_score_aggregates in PostgreSQL (renamed from user_score_snapshots).
@DataClassName('UserScoreAggregate')
class UserScoreAggregates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get periodId => text().references(ScoringPeriods, #id)();
  RealColumn get leadScore =>
      real().withDefault(const Constant(0))(); // Average of lead measure achievements (60%)
  RealColumn get lagScore =>
      real().withDefault(const Constant(0))(); // Average of lag measure achievements (40%)
  RealColumn get bonusPoints =>
      real().withDefault(const Constant(0))(); // Cadence, immediate logging, etc.
  RealColumn get penaltyPoints =>
      real().withDefault(const Constant(0))(); // Absences, late submissions, etc.
  RealColumn get totalScore =>
      real().withDefault(const Constant(0))(); // (lead*0.6 + lag*0.4) + bonus - penalty
  IntColumn get rank => integer().nullable()();
  IntColumn get rankChange => integer().nullable()(); // +/- from previous period
  DateTimeColumn get calculatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
