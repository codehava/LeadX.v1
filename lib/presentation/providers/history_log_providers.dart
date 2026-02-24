import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/local/history_log_local_data_source.dart';
import '../../data/datasources/remote/history_log_remote_data_source.dart';
import '../../data/repositories/history_log_repository_impl.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/repositories/history_log_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

part 'history_log_providers.g.dart';

// ============================================
// DATA SOURCES
// ============================================

@riverpod
HistoryLogRemoteDataSource historyLogRemoteDataSource(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return HistoryLogRemoteDataSource(supabase);
}

@riverpod
HistoryLogLocalDataSource historyLogLocalDataSource(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryLogLocalDataSource(db);
}

// ============================================
// REPOSITORY
// ============================================

@riverpod
HistoryLogRepository historyLogRepository(Ref ref) {
  return HistoryLogRepositoryImpl(
    remoteDataSource: ref.watch(historyLogRemoteDataSourceProvider),
    localDataSource: ref.watch(historyLogLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
}

// ============================================
// ENTITY HISTORY PROVIDER
// ============================================

/// Parameters for entity history provider.
class EntityHistoryParams {
  final String targetTable;
  final String targetId;
  final bool forceRefresh;

  const EntityHistoryParams({
    required this.targetTable,
    required this.targetId,
    this.forceRefresh = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityHistoryParams &&
          runtimeType == other.runtimeType &&
          targetTable == other.targetTable &&
          targetId == other.targetId &&
          forceRefresh == other.forceRefresh;

  @override
  int get hashCode =>
      targetTable.hashCode ^ targetId.hashCode ^ forceRefresh.hashCode;
}

@riverpod
Future<List<AuditLog>> entityHistory(
  Ref ref,
  EntityHistoryParams params,
) async {
  final repository = ref.watch(historyLogRepositoryProvider);
  return repository.getEntityHistory(
    params.targetTable,
    params.targetId,
    forceRefresh: params.forceRefresh,
  );
}

// ============================================
// PIPELINE STAGE HISTORY PROVIDER
// ============================================

/// Parameters for pipeline stage history provider.
class PipelineStageHistoryParams {
  final String pipelineId;
  final bool forceRefresh;

  const PipelineStageHistoryParams({
    required this.pipelineId,
    this.forceRefresh = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineStageHistoryParams &&
          runtimeType == other.runtimeType &&
          pipelineId == other.pipelineId &&
          forceRefresh == other.forceRefresh;

  @override
  int get hashCode => pipelineId.hashCode ^ forceRefresh.hashCode;
}

@riverpod
Future<List<PipelineStageHistory>> pipelineStageHistory(
  Ref ref,
  PipelineStageHistoryParams params,
) async {
  final repository = ref.watch(historyLogRepositoryProvider);
  return repository.getPipelineStageHistory(
    params.pipelineId,
    forceRefresh: params.forceRefresh,
  );
}

// ============================================
// CONVENIENCE PROVIDERS
// ============================================

/// Get customer history by ID.
@riverpod
Future<List<AuditLog>> customerHistory(
  Ref ref,
  String customerId,
) async {
  final repository = ref.watch(historyLogRepositoryProvider);
  return repository.getEntityHistory('customers', customerId);
}

/// Get pipeline audit history by ID.
@riverpod
Future<List<AuditLog>> pipelineAuditHistory(
  Ref ref,
  String pipelineId,
) async {
  final repository = ref.watch(historyLogRepositoryProvider);
  return repository.getEntityHistory('pipelines', pipelineId);
}
