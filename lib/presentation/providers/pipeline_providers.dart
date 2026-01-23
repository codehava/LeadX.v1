import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/pipeline_local_data_source.dart';
import '../../data/datasources/remote/pipeline_remote_data_source.dart';
import '../../data/dtos/pipeline_dtos.dart';
import '../../data/repositories/pipeline_repository_impl.dart';
import '../../domain/entities/pipeline.dart' as domain;
import 'auth_providers.dart';
import 'customer_providers.dart';
import 'database_provider.dart';
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
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final database = ref.watch(databaseProvider);

  return PipelineRepositoryImpl(
    localDataSource: localDataSource,
    masterDataSource: masterDataSource,
    customerDataSource: customerDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
  );
});

// ==========================================
// Stream Providers
// ==========================================

/// Provider for watching all pipelines as a reactive stream.
final pipelineListStreamProvider =
    StreamProvider<List<domain.Pipeline>>((ref) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchAllPipelines();
});

/// Provider for watching pipelines for a specific customer.
final customerPipelinesProvider =
    StreamProvider.family<List<domain.Pipeline>, String>((ref, customerId) {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.watchCustomerPipelines(customerId);
});

/// Provider for fetching pipelines where a broker is the source.
final brokerPipelinesProvider =
    FutureProvider.family<List<domain.Pipeline>, String>((ref, brokerId) async {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.getBrokerPipelines(brokerId);
});

// ==========================================
// Detail Providers
// ==========================================

/// Provider for fetching a specific pipeline by ID.
final pipelineDetailProvider =
    FutureProvider.family<domain.Pipeline?, String>((ref, id) async {
  final repository = ref.watch(pipelineRepositoryProvider);
  return repository.getPipelineById(id);
});

// ==========================================
// Master Data Providers
// ==========================================

/// Provider for pipeline stages.
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
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (pipeline) => state = state.copyWith(
        isLoading: false,
        savedPipeline: pipeline,
      ),
    );
  }

  /// Update an existing pipeline.
  Future<void> updatePipeline(String id, PipelineUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePipeline(id, dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (pipeline) => state = state.copyWith(
        isLoading: false,
        savedPipeline: pipeline,
      ),
    );
  }

  /// Update pipeline stage.
  Future<void> updateStage(String id, PipelineStageUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePipelineStage(id, dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (pipeline) => state = state.copyWith(
        isLoading: false,
        savedPipeline: pipeline,
      ),
    );
  }

  /// Update pipeline status within the current stage.
  Future<void> updateStatus(String id, PipelineStatusUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updatePipelineStatus(id, dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (pipeline) => state = state.copyWith(
        isLoading: false,
        savedPipeline: pipeline,
      ),
    );
  }

  /// Delete a pipeline.
  Future<bool> deletePipeline(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.deletePipeline(id);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
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
