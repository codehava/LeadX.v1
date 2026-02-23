import 'package:drift/drift.dart';

/// Users table - stores user accounts.
/// Extends Supabase auth.users
class Users extends Table {
  TextColumn get id => text()(); // FK → auth.users(id)
  TextColumn get email => text().unique()();
  TextColumn get name => text()();
  TextColumn get nip => text().nullable()(); // Employee ID
  TextColumn get phone => text().nullable()();
  TextColumn get role => text()(); // SUPERADMIN/ADMIN/ROH/BM/BH/RM
  TextColumn get parentId => text().nullable().references(Users, #id)(); // Direct supervisor
  TextColumn get branchId => text().nullable().references(Branches, #id)();
  TextColumn get regionalOfficeId => text().nullable().references(RegionalOffices, #id)();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User hierarchy closure table for efficient subordinate queries.
/// Usage: Query all subordinates without recursive query.
class UserHierarchy extends Table {
  TextColumn get ancestorId => text().references(Users, #id)();
  TextColumn get descendantId => text().references(Users, #id)();
  IntColumn get depth => integer()(); // 0=self, 1=direct child, 2=grandchild...

  @override
  Set<Column> get primaryKey => {ancestorId, descendantId};
}

/// Regional offices (Kantor Wilayah).
class RegionalOffices extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Branch offices (Kantor Cabang).
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get regionalOfficeId => text().references(RegionalOffices, #id)();
  TextColumn get address => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
