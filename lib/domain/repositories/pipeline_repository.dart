import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
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

  /// Watch pipelines for a specific customer.
  Stream<List<Pipeline>> watchCustomerPipelines(String customerId);

  /// Get a specific pipeline by ID.
  Future<Pipeline?> getPipelineById(String id);

  /// Create a new pipeline.
  /// Saves locally first, then queues for sync.
  Future<Either<Failure, Pipeline>> createPipeline(PipelineCreateDto dto);

  /// Update an existing pipeline.
  /// Updates locally first, then queues for sync.
  Future<Either<Failure, Pipeline>> updatePipeline(
    String id,
    PipelineUpdateDto dto,
  );

  /// Update pipeline stage (stage transition).
  /// Handles weighted value calculation and final stage logic.
  /// Automatically assigns the default status for the new stage.
  Future<Either<Failure, Pipeline>> updatePipelineStage(
    String id,
    PipelineStageUpdateDto dto,
  );

  /// Update pipeline status within the current stage.
  /// Does not change the stage, only the status.
  Future<Either<Failure, Pipeline>> updatePipelineStatus(
    String id,
    PipelineStatusUpdateDto dto,
  );

  /// Soft delete a pipeline.
  /// Marks as deleted locally, then queues for sync.
  Future<Either<Failure, void>> deletePipeline(String id);

  // ==========================================
  // Search & Filter
  // ==========================================

  /// Search pipelines by code.
  Future<List<Pipeline>> searchPipelines(String query);

  /// Get pipelines for a customer.
  Future<List<Pipeline>> getCustomerPipelines(String customerId);

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
