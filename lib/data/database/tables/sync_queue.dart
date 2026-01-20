import 'package:drift/drift.dart';

import 'users.dart';

// ============================================
// SYSTEM TABLES
// ============================================

/// Sync queue for offline-first operations.
class SyncQueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // customer, pipeline, activity, etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // create, update, delete
  TextColumn get payload => text()(); // JSON payload
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  String get tableName => 'sync_queue';
}

/// System-wide audit log.
class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get targetTable => text()(); // Renamed from tableName to avoid override
  TextColumn get recordId => text()();
  TextColumn get action => text()(); // CREATE, UPDATE, DELETE
  TextColumn get oldValues => text().nullable()(); // JSON
  TextColumn get newValues => text().nullable()(); // JSON
  TextColumn get changedBy => text().nullable().references(Users, #id)();
  DateTimeColumn get changedAt => dateTime()();
  TextColumn get ipAddress => text().nullable()();
  TextColumn get userAgent => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// App settings / key-value store.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
