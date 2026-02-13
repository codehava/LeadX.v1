import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/date_time_utils.dart';
import '../../../domain/entities/audit_log_entity.dart';

/// Remote data source for fetching audit logs and history from Supabase.
/// 
/// This is a read-only data source - audit logs are created by database triggers,
/// not by the application.
class HistoryLogRemoteDataSource {
  final SupabaseClient _supabase;

  HistoryLogRemoteDataSource(this._supabase);

  // ============================================
  // AUDIT LOGS
  // ============================================

  /// Fetch entity history from audit_logs table.
  ///
  /// [targetTable] - The table name (e.g., 'customers', 'pipelines')
  /// [targetId] - The entity ID to fetch history for
  /// [since] - Optional timestamp to fetch only newer entries
  Future<List<AuditLog>> fetchEntityHistory(
    String targetTable,
    String targetId, {
    DateTime? since,
  }) async {
    var query = _supabase
        .from('audit_logs')
        .select('''
          *,
          users!audit_logs_user_id_fkey(name)
        ''')
        .eq('target_table', targetTable)
        .eq('target_id', targetId);

    if (since != null) {
      query = query.gte('created_at', since.toUtcIso8601());
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((json) => _mapToAuditLog(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all audit logs for multiple entities (admin use).
  Future<List<AuditLog>> fetchAuditLogs({
    String? targetTable,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _supabase
        .from('audit_logs')
        .select('''
          *,
          users!audit_logs_user_id_fkey(name)
        ''');

    if (targetTable != null) {
      query = query.eq('target_table', targetTable);
    }
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    if (startDate != null) {
      query = query.gte('created_at', startDate.toUtcIso8601());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toUtcIso8601());
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => _mapToAuditLog(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // PIPELINE STAGE HISTORY
  // ============================================

  /// Fetch pipeline stage history with resolved stage/status names.
  Future<List<PipelineStageHistory>> fetchPipelineStageHistory(
    String pipelineId,
  ) async {
    final response = await _supabase
        .from('pipeline_stage_history')
        .select('''
          *,
          from_stage:pipeline_stages!pipeline_stage_history_from_stage_id_fkey(name, color),
          to_stage:pipeline_stages!pipeline_stage_history_to_stage_id_fkey(name, color),
          from_status:pipeline_statuses!pipeline_stage_history_from_status_id_fkey(name),
          to_status:pipeline_statuses!pipeline_stage_history_to_status_id_fkey(name),
          changed_by_user:users!pipeline_stage_history_changed_by_fkey(name)
        ''')
        .eq('pipeline_id', pipelineId)
        .order('changed_at', ascending: false);

    return (response as List)
        .map((json) => _mapToPipelineStageHistory(json as Map<String, dynamic>))
        .toList();
  }

  // ============================================
  // MAPPERS
  // ============================================

  AuditLog _mapToAuditLog(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;

    return AuditLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String?,
      action: json['action'] as String,
      targetTable: json['target_table'] as String,
      targetId: json['target_id'] as String,
      oldValues: json['old_values'] != null
          ? Map<String, dynamic>.from(json['old_values'] as Map)
          : null,
      newValues: json['new_values'] != null
          ? Map<String, dynamic>.from(json['new_values'] as Map)
          : null,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['name'] as String?,
    );
  }

  PipelineStageHistory _mapToPipelineStageHistory(Map<String, dynamic> json) {
    final fromStage = json['from_stage'] as Map<String, dynamic>?;
    final toStage = json['to_stage'] as Map<String, dynamic>?;
    final fromStatus = json['from_status'] as Map<String, dynamic>?;
    final toStatus = json['to_status'] as Map<String, dynamic>?;
    final changedByUser = json['changed_by_user'] as Map<String, dynamic>?;

    return PipelineStageHistory(
      id: json['id'] as String,
      pipelineId: json['pipeline_id'] as String,
      fromStageId: json['from_stage_id'] as String?,
      toStageId: (json['to_stage_id'] as String?) ?? '',
      fromStatusId: json['from_status_id'] as String?,
      toStatusId: json['to_status_id'] as String?,
      notes: json['notes'] as String?,
      changedBy: json['changed_by'] as String?,
      changedAt: DateTime.parse(json['changed_at'] as String? ?? DateTime.now().toUtcIso8601()),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      fromStageName: fromStage?['name'] as String?,
      toStageName: toStage?['name'] as String?,
      fromStatusName: fromStatus?['name'] as String?,
      toStatusName: toStatus?['name'] as String?,
      changedByName: changedByUser?['name'] as String?,
      fromStageColor: fromStage?['color'] as String?,
      toStageColor: toStage?['color'] as String?,
    );
  }
}
