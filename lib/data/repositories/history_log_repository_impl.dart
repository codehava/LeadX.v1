import '../../domain/entities/audit_log_entity.dart';
import '../../domain/repositories/history_log_repository.dart';
import '../datasources/local/history_log_local_data_source.dart';
import '../datasources/remote/history_log_remote_data_source.dart';
import '../services/connectivity_service.dart';

/// Implementation of [HistoryLogRepository] with offline-first approach.
/// 
/// Fetches data from Supabase on-demand and caches locally for offline access.
class HistoryLogRepositoryImpl implements HistoryLogRepository {
  final HistoryLogRemoteDataSource _remoteDataSource;
  final HistoryLogLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  HistoryLogRepositoryImpl({
    required HistoryLogRemoteDataSource remoteDataSource,
    required HistoryLogLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  // ============================================
  // ENTITY HISTORY
  // ============================================

  @override
  Future<List<AuditLog>> getEntityHistory(
    String targetTable,
    String targetId, {
    bool forceRefresh = false,
  }) async {
    // Check if we're online
    final isOnline = _connectivityService.isConnected;

    // If online and force refresh, fetch from remote
    if (isOnline && forceRefresh) {
      return _fetchAndCacheEntityHistory(targetTable, targetId);
    }

    // Try to get from cache first
    final hasCache = await _localDataSource.hasEntityHistoryCache(
      targetTable,
      targetId,
    );

    if (hasCache && !forceRefresh) {
      // Return cached data
      return _localDataSource.getCachedEntityHistory(
        targetTable,
        targetId,
      );
    }

    // No cache, try to fetch from remote
    if (isOnline) {
      return _fetchAndCacheEntityHistory(targetTable, targetId);
    }

    // Offline with no cache - return empty list
    return [];
  }

  Future<List<AuditLog>> _fetchAndCacheEntityHistory(
    String targetTable,
    String targetId,
  ) async {
    try {
      final logs = await _remoteDataSource.fetchEntityHistory(
        targetTable,
        targetId,
      );

      // Cache the results
      await _localDataSource.cacheAuditLogs(logs);

      return logs;
    } catch (e) {
      // On error, try to return cached data if available
      final cached = await _localDataSource.getCachedEntityHistory(
        targetTable,
        targetId,
      );
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  // ============================================
  // PIPELINE STAGE HISTORY
  // ============================================

  @override
  Future<List<PipelineStageHistory>> getPipelineStageHistory(
    String pipelineId, {
    bool forceRefresh = false,
  }) async {
    // Check if we're online
    final isOnline = _connectivityService.isConnected;

    // If online and force refresh, fetch from remote
    if (isOnline && forceRefresh) {
      return _fetchAndCachePipelineStageHistory(pipelineId);
    }

    // Try to get from cache first
    final hasCache =
        await _localDataSource.hasPipelineStageHistoryCache(pipelineId);

    if (hasCache && !forceRefresh) {
      // Return cached data
      return _localDataSource.getCachedPipelineStageHistory(pipelineId);
    }

    // No cache, try to fetch from remote
    if (isOnline) {
      return _fetchAndCachePipelineStageHistory(pipelineId);
    }

    // Offline with no cache - return empty list
    return [];
  }

  Future<List<PipelineStageHistory>> _fetchAndCachePipelineStageHistory(
    String pipelineId,
  ) async {
    try {
      final history =
          await _remoteDataSource.fetchPipelineStageHistory(pipelineId);

      // Cache the results
      await _localDataSource.cachePipelineStageHistory(history);

      return history;
    } catch (e) {
      // On error, try to return cached data if available
      final cached =
          await _localDataSource.getCachedPipelineStageHistory(pipelineId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  @override
  Future<void> invalidateEntityCache(
    String targetTable,
    String targetId,
  ) async {
    await _localDataSource.clearCachedEntityHistory(targetTable, targetId);
  }

  @override
  Future<void> invalidatePipelineStageHistoryCache(String pipelineId) async {
    await _localDataSource.clearCachedPipelineStageHistory(pipelineId);
  }
}
