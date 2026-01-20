import 'package:drift/drift.dart';

import 'users.dart';

/// Customers table - main customer data.
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // Auto-generated
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get provinceId => text()();
  TextColumn get cityId => text()();
  TextColumn get postalCode => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get companyTypeId => text()();
  TextColumn get ownershipTypeId => text()();
  TextColumn get industryId => text()();
  TextColumn get npwp => text().nullable()();
  TextColumn get assignedRmId => text().references(Users, #id)();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get notes => text().nullable()();
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

/// Unified key persons for Customer, Broker, HVC.
class KeyPersons extends Table {
  TextColumn get id => text()();
  TextColumn get ownerType => text()(); // 'CUSTOMER'/'BROKER'/'HVC'
  TextColumn get customerId => text().nullable()(); // If owner_type = CUSTOMER
  TextColumn get brokerId => text().nullable()(); // If owner_type = BROKER
  TextColumn get hvcId => text().nullable()(); // If owner_type = HVC
  TextColumn get name => text()();
  TextColumn get position => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().references(Users, #id)();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
