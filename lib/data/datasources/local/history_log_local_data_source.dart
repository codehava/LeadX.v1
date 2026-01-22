import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../domain/entities/audit_log_entity.dart' as entity;
import '../../database/app_database.dart' hide AuditLog;

/// Local data source for caching history log data.
/// 
/// Provides offline access to previously fetched audit logs and pipeline stage history.
class HistoryLogLocalDataSource {
  final AppDatabase _db;

  HistoryLogLocalDataSource(this._db);

  // ============================================
  // AUDIT LOG CACHE
  // ============================================

  /// Get cached audit logs for an entity.
  Future<List<entity.AuditLog>> getCachedEntityHistory(
    String targetTable,
    String targetId,
  ) async {
    final results = await (_db.select(_db.auditLogCache)
          ..where((t) => t.targetTable.equals(targetTable))
          ..where((t) => t.targetId.equals(targetId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    return results.map((row) => _mapToCachedAuditLog(row)).toList();
  }

  /// Cache audit logs for offline access.
  Future<void> cacheAuditLogs(List<entity.AuditLog> logs) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.auditLogCache,
        logs.map((log) => AuditLogCacheCompanion.insert(
              id: log.id,
              userId: Value(log.userId),
              userEmail: Value(log.userEmail),
              action: log.action,
              targetTable: log.targetTable,
              targetId: log.targetId,
              oldValues: Value(log.oldValues != null
                  ? jsonEncode(log.oldValues)
                  : null),
              newValues: Value(log.newValues != null
                  ? jsonEncode(log.newValues)
                  : null),
              ipAddress: Value(log.ipAddress),
              userAgent: Value(log.userAgent),
              createdAt: log.createdAt,
              cachedAt: now,
            )),
      );
    });
  }

  /// Clear cached audit logs for an entity.
  Future<void> clearCachedEntityHistory(
    String targetTable,
    String targetId,
  ) async {
    await (_db.delete(_db.auditLogCache)
          ..where((t) => t.targetTable.equals(targetTable))
          ..where((t) => t.targetId.equals(targetId)))
        .go();
  }

  // ============================================
  // PIPELINE STAGE HISTORY CACHE
  // ============================================

  /// Get cached pipeline stage history.
  Future<List<entity.PipelineStageHistory>> getCachedPipelineStageHistory(
    String pipelineId,
  ) async {
    final results = await (_db.select(_db.pipelineStageHistoryItems)
          ..where((t) => t.pipelineId.equals(pipelineId))
          ..orderBy([(t) => OrderingTerm.desc(t.changedAt)]))
        .get();

    return results.map((row) => _mapToCachedPipelineStageHistory(row)).toList();
  }

  /// Cache pipeline stage history for offline access.
  Future<void> cachePipelineStageHistory(
    List<entity.PipelineStageHistory> history,
  ) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.pipelineStageHistoryItems,
        history.map((h) => PipelineStageHistoryItemsCompanion.insert(
              id: h.id,
              pipelineId: h.pipelineId,
              fromStageId: Value(h.fromStageId),
              toStageId: h.toStageId,
              fromStatusId: Value(h.fromStatusId),
              toStatusId: Value(h.toStatusId),
              notes: Value(h.notes),
              changedBy: Value(h.changedBy),
              changedAt: h.changedAt,
              latitude: Value(h.latitude),
              longitude: Value(h.longitude),
              cachedAt: now,
            )),
      );
    });
  }

  /// Clear cached pipeline stage history.
  Future<void> clearCachedPipelineStageHistory(String pipelineId) async {
    await (_db.delete(_db.pipelineStageHistoryItems)
          ..where((t) => t.pipelineId.equals(pipelineId)))
        .go();
  }

  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  /// Check if cache exists for an entity.
  Future<bool> hasEntityHistoryCache(
    String targetTable,
    String targetId,
  ) async {
    final count = await (_db.select(_db.auditLogCache)
          ..where((t) => t.targetTable.equals(targetTable))
          ..where((t) => t.targetId.equals(targetId)))
        .get();
    return count.isNotEmpty;
  }

  /// Check if cache exists for pipeline stage history.
  Future<bool> hasPipelineStageHistoryCache(String pipelineId) async {
    final count = await (_db.select(_db.pipelineStageHistoryItems)
          ..where((t) => t.pipelineId.equals(pipelineId)))
        .get();
    return count.isNotEmpty;
  }

  /// Clear all history cache (for maintenance).
  Future<void> clearAllCache() async {
    await _db.delete(_db.auditLogCache).go();
    await _db.delete(_db.pipelineStageHistoryItems).go();
  }

  // ============================================
  // MAPPERS
  // ============================================

  entity.AuditLog _mapToCachedAuditLog(AuditLogCacheData row) {
    return entity.AuditLog(
      id: row.id,
      userId: row.userId,
      userEmail: row.userEmail,
      action: row.action,
      targetTable: row.targetTable,
      targetId: row.targetId,
      oldValues: row.oldValues != null
          ? jsonDecode(row.oldValues!) as Map<String, dynamic>
          : null,
      newValues: row.newValues != null
          ? jsonDecode(row.newValues!) as Map<String, dynamic>
          : null,
      ipAddress: row.ipAddress,
      userAgent: row.userAgent,
      createdAt: row.createdAt,
    );
  }

  entity.PipelineStageHistory _mapToCachedPipelineStageHistory(
    PipelineStageHistoryItem row,
  ) {
    return entity.PipelineStageHistory(
      id: row.id,
      pipelineId: row.pipelineId,
      fromStageId: row.fromStageId,
      toStageId: row.toStageId,
      fromStatusId: row.fromStatusId,
      toStatusId: row.toStatusId,
      notes: row.notes,
      changedBy: row.changedBy,
      changedAt: row.changedAt,
      latitude: row.latitude,
      longitude: row.longitude,
      // Note: Resolved names are not cached, would need a separate join
    );
  }
}
