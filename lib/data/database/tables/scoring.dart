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
  TextColumn get dataType => text()(); // 'COUNT', 'SUM', 'PERCENTAGE'
  TextColumn get unit => text().nullable()(); // 'visits', 'IDR', '%'
  TextColumn get calculationFormula => text().nullable()(); // For computed measures
  TextColumn get sourceTable => text().nullable()(); // Auto-pull from table
  TextColumn get sourceCondition => text().nullable()(); // WHERE clause
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
  RealColumn get actualValue => real()();
  RealColumn get targetValue => real()();
  RealColumn get percentage => real().nullable()(); // (actual/target)*100
  DateTimeColumn get calculatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Period summary scores with ranking.
class PeriodSummaryScores extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get periodId => text().references(ScoringPeriods, #id)();
  RealColumn get totalLeadScore => real().withDefault(const Constant(0))();
  RealColumn get totalLagScore => real().withDefault(const Constant(0))();
  RealColumn get compositeScore => real().withDefault(const Constant(0))();
  IntColumn get rank => integer().nullable()();
  IntColumn get rankChange => integer().nullable()(); // +/- from previous period
  DateTimeColumn get calculatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
