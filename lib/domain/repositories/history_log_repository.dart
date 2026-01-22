import '../entities/audit_log_entity.dart';

/// Repository interface for accessing history logs.
/// 
/// This repository fetches audit data on-demand (lazy loading)
/// from Supabase and caches it locally for offline access.
abstract class HistoryLogRepository {
  /// Get entity change history.
  /// 
  /// [targetTable] - The table name (e.g., 'customers', 'pipelines')
  /// [targetId] - The entity ID to fetch history for
  /// [forceRefresh] - If true, bypass cache and fetch from remote
  Future<List<AuditLog>> getEntityHistory(
    String targetTable,
    String targetId, {
    bool forceRefresh = false,
  });

  /// Get pipeline stage transition history.
  /// 
  /// Includes resolved stage/status names and GPS data if available.
  Future<List<PipelineStageHistory>> getPipelineStageHistory(
    String pipelineId, {
    bool forceRefresh = false,
  });

  /// Invalidate cache for an entity.
  /// 
  /// Should be called when an entity is updated to ensure
  /// the next fetch gets fresh data.
  Future<void> invalidateEntityCache(String targetTable, String targetId);

  /// Invalidate cache for pipeline stage history.
  Future<void> invalidatePipelineStageHistoryCache(String pipelineId);
}
