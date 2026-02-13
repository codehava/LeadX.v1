import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/result.dart';
import '../../data/datasources/local/pipeline_local_data_source.dart';
import '../../data/datasources/remote/pipeline_remote_data_source.dart';
import '../../data/dtos/pipeline_dtos.dart';
import '../../data/repositories/pipeline_repository_impl.dart';
import '../../domain/entities/pipeline.dart' as domain;
import 'auth_providers.dart';
import 'customer_providers.dart';
import 'database_provider.dart';
import 'history_log_providers.dart';
import 'master_data_providers.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for the pipeline local data source.
final pipelineLocalDataSourceProvider = Provider<PipelineLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return PipelineLocalDataSource(db);
});

/// Provider for the pipeline remote data source.
final pipelineRemoteDataSourceProvider =
    Provider<PipelineRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PipelineRemoteDataSource(supabase);
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the pipeline repository.
final pipelineRepositoryProvider = Provider<PipelineRepositoryImpl>((ref) {
  final localDataSource = ref.watch(pipelineLocalDataSourceProvider);
  final masterDataSource = ref.watch(masterDataLocalDataSourceProvider);
  final customerDataSource = ref.watch(customerLocalDataSourceProvider);
  final remoteDataSource = ref.watch(pipelineRemoteDataSourceProvider);
  final historyLogDataSource = ref.watch(historyLogLocalDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final database = ref.watch(databaseProvider);

  return PipelineRepositoryImpl(
    localDataSource: localDataSource,
    masterDataSource: masterDataSource,
    customerDataSource: customerDataSource,
    remoteDataSource: remoteDataSource,
    historyLogDataSource: historyLogDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
  );
});

// ==========================================
// Stream Providers
// ==========================================

/// Default page size for pipeline pagination.
const pipelinePageSize = 25;

/// Provider for watching all pipelines as a reactive stream.
/// @deprecated Use [paginatedPipelinesProvider] for lazy loading.
final pipelineListStreamProvider =
    StreamProvider<List<domain.Pipeline>>((ref) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchAllPipelines();
});

// ==========================================
// Paginated Pipeline Providers
// ==========================================

/// State provider for pipeline list pagination limit.
/// Increment this to load more items.
final pipelineLimitProvider = StateProvider<int>((ref) => pipelinePageSize);

/// Provider for watching pipelines with pagination (reactive stream).
/// Handles both list and search - pass null for full list or search query.
final paginatedPipelinesProvider =
    StreamProvider.family<List<domain.Pipeline>, String?>((ref, searchQuery) {
  final limit = ref.watch(pipelineLimitProvider);
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchPipelinesPaginated(limit: limit, searchQuery: searchQuery);
});

/// Provider for total pipeline count (for "hasMore" calculation).
/// Pass search query to get filtered count.
final pipelineTotalCountProvider =
    FutureProvider.family<int, String?>((ref, searchQuery) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.getPipelineCount(searchQuery: searchQuery);
});

/// Provider for watching pipelines for a specific customer.
final customerPipelinesProvider =
    StreamProvider.family<List<domain.Pipeline>, String>((ref, customerId) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchCustomerPipelines(customerId);
});

/// Provider for watching pipelines where a broker is the source (reactive stream).
final brokerPipelinesProvider =
    StreamProvider.family<List<domain.Pipeline>, String>((ref, brokerId) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchBrokerPipelines(brokerId);
});

// ==========================================
// Detail Providers
// ==========================================

/// Provider for watching a specific pipeline by ID (reactive stream).
final pipelineDetailProvider =
    StreamProvider.family<domain.Pipeline?, String>((ref, id) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchPipelineById(id);
});

// ==========================================
// Master Data Providers
// ==========================================

/// @deprecated Use [pipelineStagesStreamProvider] from master_data_providers instead.
/// Returns DTOs for better separation of concerns.
final pipelineStagesProvider =
    FutureProvider<List<domain.PipelineStageInfo>>((ref) async {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.getPipelineStages();
});

/// Provider for pipeline statuses filtered by stage.
final pipelineStatusesByStageProvider = FutureProvider.family<
    List<domain.PipelineStatusInfo>, String>((ref, stageId) async {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.getPipelineStatuses(stageId);
});

// ==========================================
// Form Notifiers
// ==========================================

/// State for pipeline form.
class PipelineFormState {
  PipelineFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedPipeline,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.Pipeline? savedPipeline;

  PipelineFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.Pipeline? savedPipeline,
  }) {
    return PipelineFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      savedPipeline: savedPipeline ?? this.savedPipeline,
    );
  }
}

/// Notifier for pipeline form operations.
class PipelineFormNotifier extends StateNotifier<PipelineFormState> {
  PipelineFormNotifier(this._repository) : super(PipelineFormState());

  final PipelineRepositoryImpl _repository;

  /// Create a new pipeline.
  Future<void> createPipeline(PipelineCreateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createPipeline(dto);
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedPipeline: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Update an existing pipeline.
  Future<void> updatePipeline(String id, PipelineUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePipeline(id, dto);
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedPipeline: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Update pipeline stage.
  Future<void> updateStage(String id, PipelineStageUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePipelineStage(id, dto);
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedPipeline: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Update pipeline status within the current stage.
  Future<void> updateStatus(String id, PipelineStatusUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePipelineStatus(id, dto);
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedPipeline: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Delete a pipeline.
  Future<bool> deletePipeline(String id, {String? customerId, String? brokerId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.deletePipeline(id);
    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Reset form state.
  void reset() {
    state = PipelineFormState();
  }
}

/// Provider for pipeline form notifier.
final pipelineFormNotifierProvider =
    StateNotifierProvider.autoDispose<PipelineFormNotifier, PipelineFormState>(
        (ref) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return PipelineFormNotifier(repository);
});
