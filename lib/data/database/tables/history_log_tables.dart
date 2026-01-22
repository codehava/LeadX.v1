import 'package:drift/drift.dart';

// ============================================
// PIPELINE STAGE HISTORY TABLE (Local Cache)
// ============================================

/// Local cache for pipeline stage history entries.
/// This table stores data fetched from Supabase for offline viewing.
class PipelineStageHistoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get pipelineId => text()();
  TextColumn get fromStageId => text().nullable()();
  TextColumn get toStageId => text()();
  TextColumn get fromStatusId => text().nullable()();
  TextColumn get toStatusId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get changedBy => text().nullable()();
  DateTimeColumn get changedAt => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  // Cache metadata
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'pipeline_stage_history_cache';
}

// ============================================
// AUDIT LOG CACHE TABLE (Optional)
// ============================================

/// Local cache for audit log entries.
/// This table stores data fetched from Supabase for offline viewing.
class AuditLogCache extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get userEmail => text().nullable()();
  TextColumn get action => text()(); // INSERT, UPDATE, DELETE
  TextColumn get targetTable => text()();
  TextColumn get targetId => text()();
  TextColumn get oldValues => text().nullable()(); // JSON string
  TextColumn get newValues => text().nullable()(); // JSON string
  TextColumn get ipAddress => text().nullable()();
  TextColumn get userAgent => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  // Cache metadata
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'audit_log_cache';
}
