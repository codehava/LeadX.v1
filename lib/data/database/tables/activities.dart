import 'package:drift/drift.dart';

import 'customers.dart';
import 'pipelines.dart';
import 'users.dart';

/// Unified activities table (scheduled + immediate).
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)(); // Activity owner
  TextColumn get createdBy => text().references(Users, #id)();
  TextColumn get objectType => text()(); // 'CUSTOMER'/'HVC'/'BROKER'/'PIPELINE'
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get hvcId => text().nullable()(); // If object_type = HVC
  TextColumn get brokerId => text().nullable()(); // If object_type = BROKER
  TextColumn get pipelineId => text().nullable().references(Pipelines, #id)();
  TextColumn get keyPersonId => text().nullable()(); // Key person associated with activity
  TextColumn get activityTypeId => text()();
  TextColumn get summary => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get scheduledDatetime => dateTime()();
  BoolColumn get isImmediate => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('PLANNED'))(); // PLANNED/IN_PROGRESS/COMPLETED/CANCELLED/RESCHEDULED/OVERDUE
  DateTimeColumn get executedAt => dateTime().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get locationAccuracy => real().nullable()(); // GPS accuracy in meters
  RealColumn get distanceFromTarget => real().nullable()();
  BoolColumn get isLocationOverride => boolean().withDefault(const Constant(false))();
  TextColumn get overrideReason => text().nullable()();
  TextColumn get rescheduledFromId => text().nullable()(); // Original activity
  TextColumn get rescheduledToId => text().nullable()(); // New activity
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelReason => text().nullable()();
  BoolColumn get isPendingSync => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Activity photos for proof of visit.
class ActivityPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text().references(Activities, #id)();
  TextColumn get photoUrl => text()(); // Supabase Storage URL
  TextColumn get localPath => text().nullable()(); // Local path for offline
  TextColumn get caption => text().nullable()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  BoolColumn get isPendingUpload => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Activity audit logs - history for every change.
class ActivityAuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text().references(Activities, #id)();
  TextColumn get action => text()(); // CREATED/STATUS_CHANGED/EXECUTED/RESCHEDULED/CANCELLED/EDITED/PHOTO_ADDED/PHOTO_REMOVED/GPS_OVERRIDE/SYNCED
  TextColumn get oldStatus => text().nullable()();
  TextColumn get newStatus => text().nullable()();
  TextColumn get oldValues => text().nullable()(); // JSON
  TextColumn get newValues => text().nullable()(); // JSON
  TextColumn get changedFields => text().nullable()(); // JSON array
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get deviceInfo => text().nullable()(); // JSON
  TextColumn get performedBy => text().references(Users, #id)();
  DateTimeColumn get performedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // For sync tracking

  @override
  Set<Column> get primaryKey => {id};
}
