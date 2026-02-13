import '../../core/errors/result.dart';
import '../../data/dtos/pipeline_dtos.dart';
import '../entities/pipeline.dart';

/// Repository interface for pipeline operations.
abstract class PipelineRepository {
  // ==========================================
  // Pipeline CRUD Operations
  // ==========================================

  /// Watch all pipelines (reactive stream).
  /// Returns pipelines assigned to current user based on hierarchy.
  Stream<List<Pipeline>> watchAllPipelines();

  /// Watch pipelines with pagination support (reactive stream).
  /// Returns up to [limit] pipelines, optionally filtered by [searchQuery].
  Stream<List<Pipeline>> watchPipelinesPaginated({
    required int limit,
    String? searchQuery,
  });

  /// Get total count of pipelines, optionally filtered by [searchQuery].
  /// Used for pagination "hasMore" calculation.
  Future<int> getPipelineCount({String? searchQuery});

  /// Watch pipelines for a specific customer.
  Stream<List<Pipeline>> watchCustomerPipelines(String customerId);

  /// Watch a specific pipeline by ID (reactive stream).
  Stream<Pipeline?> watchPipelineById(String id);

  /// Watch pipelines where the broker is the source (reactive stream).
  Stream<List<Pipeline>> watchBrokerPipelines(String brokerId);

  /// Get a specific pipeline by ID.
  Future<Pipeline?> getPipelineById(String id);

  /// Create a new pipeline.
  /// Saves locally first, then queues for sync.
  Future<Result<Pipeline>> createPipeline(PipelineCreateDto dto);

  /// Update an existing pipeline.
  /// Updates locally first, then queues for sync.
  Future<Result<Pipeline>> updatePipeline(
    String id,
    PipelineUpdateDto dto,
  );

  /// Update pipeline stage (stage transition).
  /// Handles weighted value calculation and final stage logic.
  /// Automatically assigns the default status for the new stage.
  Future<Result<Pipeline>> updatePipelineStage(
    String id,
    PipelineStageUpdateDto dto,
  );

  /// Update pipeline status within the current stage.
  /// Does not change the stage, only the status.
  Future<Result<Pipeline>> updatePipelineStatus(
    String id,
    PipelineStatusUpdateDto dto,
  );

  /// Soft delete a pipeline.
  /// Marks as deleted locally, then queues for sync.
  Future<Result<void>> deletePipeline(String id);

  // ==========================================
  // Search & Filter
  // ==========================================

  /// Search pipelines by code.
  Future<List<Pipeline>> searchPipelines(String query);

  /// Get pipelines for a customer.
  Future<List<Pipeline>> getCustomerPipelines(String customerId);

  /// Get pipelines where the broker is the source (brokerId).
  Future<List<Pipeline>> getBrokerPipelines(String brokerId);

  /// Get pipelines that need to be synced.
  Future<List<Pipeline>> getPendingSyncPipelines();

  // ==========================================
  // Master Data Operations
  // ==========================================

  /// Get all pipeline stages.
  Future<List<PipelineStageInfo>> getPipelineStages();

  /// Get pipeline statuses for a specific stage.
  Future<List<PipelineStatusInfo>> getPipelineStatuses(String stageId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync pipelines from remote to local.
  /// Uses incremental sync based on updatedAt timestamp.
  Future<void> syncFromRemote({DateTime? since});

  /// Mark a pipeline as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt);
}
