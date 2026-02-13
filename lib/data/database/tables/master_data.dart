import 'package:drift/drift.dart';

import 'users.dart';

// ============================================
// GEOGRAPHY
// ============================================

/// Provinces table.
class Provinces extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cities table.
class Cities extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get provinceId => text().references(Provinces, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// COMPANY CLASSIFICATIONS
// ============================================

/// Company types (PT, CV, UD, Perorangan, etc).
class CompanyTypes extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ownership types (BUMN, Swasta, BUMD, Asing, etc).
class OwnershipTypes extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Industries / sectors.
class Industries extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// PRODUCT CLASSIFICATIONS
// ============================================

/// Class of Business (COB) - Surety Bond, General Insurance, etc.
class Cobs extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Line of Business (LOB) - subcategory of COB.
class Lobs extends Table {
  TextColumn get id => text()();
  TextColumn get cobId => text().references(Cobs, #id)();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// PIPELINE CLASSIFICATIONS
// ============================================

/// Pipeline stages with probability (P3, P2, P1, Accepted, Declined).
class PipelineStages extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get probability => integer()(); // 0-100
  IntColumn get sequence => integer()(); // Display order
  TextColumn get color => text().nullable()(); // UI color hex
  BoolColumn get isFinal => boolean().withDefault(const Constant(false))();
  BoolColumn get isWon => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pipeline statuses per stage.
class PipelineStatuses extends Table {
  TextColumn get id => text()();
  TextColumn get stageId => text().references(PipelineStages, #id)();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sequence => integer()(); // Order within stage
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// ACTIVITY CLASSIFICATIONS
// ============================================

/// Activity types with configuration.
class ActivityTypes extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get requireLocation => boolean().withDefault(const Constant(false))();
  BoolColumn get requirePhoto => boolean().withDefault(const Constant(false))();
  BoolColumn get requireNotes => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lead sources.
class LeadSources extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  BoolColumn get requiresReferrer => boolean().withDefault(const Constant(false))();
  BoolColumn get requiresBroker => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Decline reasons for lost pipelines.
class DeclineReasons extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// HVC & BROKER
// ============================================

/// HVC types (Industrial Estate, Bank, BUMN Group, etc).
class HvcTypes extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// High Value Customers.
class Hvcs extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get typeId => text().references(HvcTypes, #id)();
  TextColumn get description => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get radiusMeters => integer().withDefault(const Constant(500))(); // Geofence
  RealColumn get potentialValue => real().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  // No FK constraint - user may see HVC via customer link where creator is outside their hierarchy
  TextColumn get createdBy => text()();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Customer-HVC links (many-to-many).
class CustomerHvcLinks extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get hvcId => text().references(Hvcs, #id)();
  TextColumn get relationshipType => text()(); // HOLDING/SUBSIDIARY/AFFILIATE/JV/TENANT/MEMBER/SUPPLIER/CONTRACTOR/DISTRIBUTOR
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get createdBy => text().references(Users, #id)();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Brokers / Agents.
class Brokers extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get licenseNumber => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get provinceId => text().nullable().references(Provinces, #id)();
  TextColumn get cityId => text().nullable().references(Cities, #id)();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  RealColumn get commissionRate => real().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  // No FK constraint - user may see broker via customer link where creator is outside their hierarchy
  TextColumn get createdBy => text()();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

