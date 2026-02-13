import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/logging/app_logger.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/pipeline.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/pipeline_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/customer_local_data_source.dart';
import '../datasources/local/history_log_local_data_source.dart';
import '../datasources/local/master_data_local_data_source.dart';
import '../datasources/local/pipeline_local_data_source.dart';
import '../datasources/remote/pipeline_remote_data_source.dart';
import '../dtos/master_data_dtos.dart';
import '../dtos/pipeline_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of PipelineRepository with offline-first pattern.
class PipelineRepositoryImpl implements PipelineRepository {
  PipelineRepositoryImpl({
    required PipelineLocalDataSource localDataSource,
    required MasterDataLocalDataSource masterDataSource,
    required CustomerLocalDataSource customerDataSource,
    required PipelineRemoteDataSource remoteDataSource,
    required HistoryLogLocalDataSource historyLogDataSource,
    required SyncService syncService,
    required String currentUserId,
    required db.AppDatabase database,
  })  : _localDataSource = localDataSource,
        _masterDataSource = masterDataSource,
        _customerDataSource = customerDataSource,
        _remoteDataSource = remoteDataSource,
        _historyLogDataSource = historyLogDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId,
        _database = database;

  final PipelineLocalDataSource _localDataSource;
  final MasterDataLocalDataSource _masterDataSource;
  final CustomerLocalDataSource _customerDataSource;
  final PipelineRemoteDataSource _remoteDataSource;
  final HistoryLogLocalDataSource _historyLogDataSource;
  final SyncService _syncService;
  final String _currentUserId;
  final db.AppDatabase _database;
  final _uuid = const Uuid();
  final _log = AppLogger.instance;

  // Lookup caches for efficient name resolution
  Map<String, String>? _stageNameCache;
  Map<String, String>? _stageColorCache;
  Map<String, int>? _stageProbabilityCache;
  Map<String, bool>? _stageIsFinalCache;
  Map<String, bool>? _stageIsWonCache;
  Map<String, String>? _statusNameCache;
  Map<String, String>? _cobNameCache;
  Map<String, String>? _lobNameCache;
  Map<String, String>? _leadSourceNameCache;
  Map<String, String>? _brokerNameCache;
  Map<String, String>? _customerNameCache;
  Map<String, String>? _userNameCache;

  // ==========================================
  // Stream Operations
  // ==========================================

  /// Watch all non-deleted pipelines as a reactive stream.
  @override
  Stream<List<domain.Pipeline>> watchAllPipelines() {
    return _localDataSource.watchAllPipelines().asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToPipeline).toList();
    });
  }

  @override
  Stream<List<domain.Pipeline>> watchPipelinesPaginated({
    required int limit,
    String? searchQuery,
  }) {
    return _localDataSource
        .watchPipelinesPaginated(limit: limit, searchQuery: searchQuery)
        .asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToPipeline).toList();
    });
  }

  @override
  Future<int> getPipelineCount({String? searchQuery}) =>
      _localDataSource.getPipelineCount(searchQuery: searchQuery);

  /// Watch pipelines for a specific customer.
  @override
  Stream<List<domain.Pipeline>> watchCustomerPipelines(String customerId) {
    return _localDataSource.watchCustomerPipelines(customerId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToPipeline).toList();
    });
  }

  /// Watch a specific pipeline by ID.
  @override
  Stream<domain.Pipeline?> watchPipelineById(String id) {
    return _localDataSource.watchPipelineById(id).asyncMap((data) async {
      if (data == null) return null;
      await _ensureCachesLoaded();
      return _mapToPipeline(data);
    });
  }

  /// Watch pipelines where the broker is the source.
  @override
  Stream<List<domain.Pipeline>> watchBrokerPipelines(String brokerId) {
    return _localDataSource.watchBrokerPipelines(brokerId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToPipeline).toList();
    });
  }

  // ==========================================
  // Read Operations
  // ==========================================

  /// Get a specific pipeline by ID.
  @override
  Future<domain.Pipeline?> getPipelineById(String id) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getPipelineById(id);
    return data != null ? _mapToPipeline(data) : null;
  }

  /// Search pipelines by code.
  @override
  Future<List<domain.Pipeline>> searchPipelines(String query) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.searchPipelines(query);
    return data.map(_mapToPipeline).toList();
  }

  /// Get pipelines for a customer.
  @override
  Future<List<domain.Pipeline>> getCustomerPipelines(String customerId) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getCustomerPipelines(customerId);
    return data.map(_mapToPipeline).toList();
  }

  /// Get pipelines where the broker is the source.
  @override
  Future<List<domain.Pipeline>> getBrokerPipelines(String brokerId) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getBrokerPipelines(brokerId);
    return data.map(_mapToPipeline).toList();
  }

  /// Get pipelines that need to be synced.
  @override
  Future<List<domain.Pipeline>> getPendingSyncPipelines() async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getPendingSyncPipelines();
    return data.map(_mapToPipeline).toList();
  }

  // ==========================================
  // Create Operation
  // ==========================================

  /// Create a new pipeline.
  @override
  Future<Either<Failure, domain.Pipeline>> createPipeline(
    PipelineCreateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();
      final code = _generatePipelineCode();

      // Get default stage and status (NEW)
      final stages = await _localDataSource.getPipelineStages();
      final newStage = stages.firstWhere(
        (s) => s.code == 'NEW',
        orElse: () => stages.first,
      );
      final defaultStatus = await _localDataSource.getDefaultStatus(newStage.id);

      // Calculate weighted value
      final stageProbability = newStage.probability;
      final weightedValue = dto.potentialPremium * (stageProbability / 100);

      // Get the customer's assigned RM to set as pipeline's assigned RM
      // This ensures the customer's owner can see pipelines for their customers
      final customer = await _customerDataSource.getCustomerById(dto.customerId);
      final assignedRmId = customer?.assignedRmId ?? _currentUserId;

      final companion = db.PipelinesCompanion.insert(
        id: id,
        code: code,
        customerId: dto.customerId,
        stageId: newStage.id,
        statusId: defaultStatus?.id ?? '',
        cobId: dto.cobId,
        lobId: dto.lobId,
        leadSourceId: dto.leadSourceId,
        brokerId: Value(dto.brokerId),
        brokerPicId: Value(dto.brokerPicId),
        customerContactId: Value(dto.customerContactId),
        tsi: Value(dto.tsi),
        potentialPremium: dto.potentialPremium,
        weightedValue: Value(weightedValue),
        expectedCloseDate: Value(dto.expectedCloseDate),
        isTender: Value(dto.isTender),
        notes: Value(dto.notes),
        assignedRmId: assignedRmId,
        createdBy: _currentUserId,
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Save locally first
      await _localDataSource.insertPipeline(companion);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.pipeline,
        entityId: id,
        operation: SyncOperation.create,
        payload: _createSyncPayload(
          id: id,
          code: code,
          dto: dto,
          stageId: newStage.id,
          statusId: defaultStatus?.id ?? '',
          weightedValue: weightedValue,
          now: now,
          assignedRmId: assignedRmId,
        ),
      );

      // Trigger sync if online (non-blocking)
      _syncService.triggerSync();

      // Return the created pipeline
      final pipeline = await getPipelineById(id);
      return Right(pipeline!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to create pipeline: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Update Operations
  // ==========================================

  /// Update an existing pipeline.
  @override
  Future<Either<Failure, domain.Pipeline>> updatePipeline(
    String id,
    PipelineUpdateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final existing = await _localDataSource.getPipelineById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Pipeline not found: $id'));
      }

      // Check if pipeline is already closed
      final currentStage = await _localDataSource.getStageById(existing.stageId);
      if (currentStage != null && currentStage.isFinal) {
        return Left(ValidationFailure(
          message: 'Pipeline sudah ditutup dan tidak dapat diubah',
        ));
      }

      // Calculate new weighted value if potential premium changed
      double? weightedValue;
      if (dto.potentialPremium != null) {
        final stage = await _localDataSource.getStageById(existing.stageId);
        if (stage != null) {
          weightedValue = dto.potentialPremium! * (stage.probability / 100);
        }
      }

      final companion = db.PipelinesCompanion(
        cobId: dto.cobId != null ? Value(dto.cobId!) : const Value.absent(),
        lobId: dto.lobId != null ? Value(dto.lobId!) : const Value.absent(),
        leadSourceId: dto.leadSourceId != null
            ? Value(dto.leadSourceId!)
            : const Value.absent(),
        brokerId: dto.brokerId != null ? Value(dto.brokerId) : const Value.absent(),
        brokerPicId:
            dto.brokerPicId != null ? Value(dto.brokerPicId) : const Value.absent(),
        customerContactId: dto.customerContactId != null
            ? Value(dto.customerContactId)
            : const Value.absent(),
        tsi: dto.tsi != null ? Value(dto.tsi) : const Value.absent(),
        potentialPremium: dto.potentialPremium != null
            ? Value(dto.potentialPremium!)
            : const Value.absent(),
        weightedValue:
            weightedValue != null ? Value(weightedValue) : const Value.absent(),
        expectedCloseDate: dto.expectedCloseDate != null
            ? Value(dto.expectedCloseDate)
            : const Value.absent(),
        isTender:
            dto.isTender != null ? Value(dto.isTender!) : const Value.absent(),
        notes: dto.notes != null ? Value(dto.notes) : const Value.absent(),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally first
      await _localDataSource.updatePipeline(id, companion);

      // Get updated data for sync payload
      final updated = await _localDataSource.getPipelineById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'Pipeline not found: $id'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.pipeline,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createUpdateSyncPayload(updated),
      );

      // Trigger sync if online (non-blocking)
      _syncService.triggerSync();

      return Right(_mapToPipeline(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update pipeline: $e',
        originalError: e,
      ));
    }
  }

  /// Update pipeline stage (stage transition).
  /// Automatically assigns the default status for the new stage.
  /// Creates a local history entry for offline stage changes.
  @override
  Future<Either<Failure, domain.Pipeline>> updatePipelineStage(
    String id,
    PipelineStageUpdateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final existing = await _localDataSource.getPipelineById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Pipeline not found: $id'));
      }

      // Check if pipeline is already closed
      final currentStage = await _localDataSource.getStageById(existing.stageId);
      if (currentStage != null && currentStage.isFinal) {
        return Left(ValidationFailure(
          message: 'Pipeline sudah ditutup dan tidak dapat diubah',
        ));
      }

      // Get stage info to check if it's final
      final stage = await _localDataSource.getStageById(dto.stageId);
      if (stage == null) {
        return Left(ValidationFailure(message: 'Invalid stage: ${dto.stageId}'));
      }

      // Validate required fields for final stages
      if (stage.isFinal && stage.isWon) {
        if (dto.policyNumber == null || dto.policyNumber!.isEmpty) {
          return Left(ValidationFailure(
            message: 'Nomor polis wajib diisi untuk stage ini',
          ));
        }
        if (dto.finalPremium == null || dto.finalPremium! <= 0) {
          return Left(ValidationFailure(
            message: 'Premi final wajib diisi untuk stage ini',
          ));
        }
      }
      if (stage.isFinal && !stage.isWon) {
        if (dto.declineReason == null || dto.declineReason!.isEmpty) {
          return Left(ValidationFailure(
            message: 'Alasan penolakan wajib diisi untuk stage ini',
          ));
        }
      }

      // Get default status for the new stage
      final defaultStatus = await _localDataSource.getDefaultStatus(dto.stageId);
      final statusId = defaultStatus?.id ?? '';

      // Calculate new weighted value
      final weightedValue =
          existing.potentialPremium * (stage.probability / 100);

      // Determine closedAt
      DateTime? closedAt;
      if (stage.isFinal) {
        closedAt = now;
      }

      // Check if stage actually changed (for history tracking)
      final stageChanged = existing.stageId != dto.stageId;

      final companion = db.PipelinesCompanion(
        stageId: Value(dto.stageId),
        statusId: Value(statusId),
        weightedValue: Value(weightedValue),
        notes: dto.notes != null ? Value(dto.notes) : const Value.absent(),
        finalPremium: dto.finalPremium != null
            ? Value(dto.finalPremium)
            : const Value.absent(),
        policyNumber: dto.policyNumber != null
            ? Value(dto.policyNumber)
            : const Value.absent(),
        declineReason: dto.declineReason != null
            ? Value(dto.declineReason)
            : const Value.absent(),
        closedAt: closedAt != null ? Value(closedAt) : const Value.absent(),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally first
      await _localDataSource.updatePipeline(id, companion);

      // Get updated data for sync payload
      final updated = await _localDataSource.getPipelineById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'Pipeline not found: $id'));
      }

      // Create local history entry if stage changed
      // Each history entry has its own unique ID, so they won't be coalesced
      if (stageChanged) {
        final historyId = _uuid.v4();
        await _historyLogDataSource.insertLocalHistoryEntry(
          id: historyId,
          pipelineId: id,
          fromStageId: existing.stageId,
          toStageId: dto.stageId,
          fromStatusId: existing.statusId,
          toStatusId: statusId,
          notes: dto.notes,
          changedBy: _currentUserId,
          changedAt: now,
        );

        // Queue history entry for sync (CREATE operation with unique ID)
        await _syncService.queueOperation(
          entityType: SyncEntityType.pipelineStageHistory,
          entityId: historyId,
          operation: SyncOperation.create,
          payload: {
            'id': historyId,
            'pipeline_id': id,
            'from_stage_id': _sanitizeUuid(existing.stageId),
            'to_stage_id': dto.stageId,
            'from_status_id': _sanitizeUuid(existing.statusId),
            'to_status_id': _sanitizeUuid(statusId),
            'notes': dto.notes,
            'changed_by': _currentUserId,
            'changed_at': now.toIso8601String(),
          },
        );
      }

      // Queue pipeline update for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.pipeline,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createUpdateSyncPayload(updated),
      );

      // Trigger sync if online (non-blocking)
      _syncService.triggerSync();

      return Right(_mapToPipeline(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update pipeline stage: $e',
        originalError: e,
      ));
    }
  }

  /// Update pipeline status within the current stage.
  /// Does not change the stage, only the status.
  @override
  Future<Either<Failure, domain.Pipeline>> updatePipelineStatus(
    String id,
    PipelineStatusUpdateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final existing = await _localDataSource.getPipelineById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Pipeline not found: $id'));
      }

      // Check if pipeline is already closed
      final currentStage = await _localDataSource.getStageById(existing.stageId);
      if (currentStage != null && currentStage.isFinal) {
        return Left(ValidationFailure(
          message: 'Pipeline sudah ditutup dan tidak dapat diubah',
        ));
      }

      final companion = db.PipelinesCompanion(
        statusId: Value(dto.statusId),
        notes: dto.notes != null ? Value(dto.notes) : const Value.absent(),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally first
      await _localDataSource.updatePipeline(id, companion);

      // Get updated data for sync payload
      final updated = await _localDataSource.getPipelineById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'Pipeline not found: $id'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.pipeline,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createUpdateSyncPayload(updated),
      );

      // Trigger sync if online (non-blocking)
      _syncService.triggerSync();

      return Right(_mapToPipeline(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update pipeline status: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Delete Operation
  // ==========================================

  /// Soft delete a pipeline.
  @override
  Future<Either<Failure, void>> deletePipeline(String id) async {
    try {
      await _localDataSource.softDeletePipeline(id);

      await _syncService.queueOperation(
        entityType: SyncEntityType.pipeline,
        entityId: id,
        operation: SyncOperation.delete,
        payload: {'id': id},
      );

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete pipeline: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Master Data Operations
  // ==========================================

  /// Get all pipeline stages.
  @override
  Future<List<domain.PipelineStageInfo>> getPipelineStages() async {
    final stages = await _localDataSource.getPipelineStages();
    return stages.map(_mapToStageInfo).toList();
  }

  /// Get pipeline statuses for a specific stage.
  @override
  Future<List<domain.PipelineStatusInfo>> getPipelineStatuses(
      String stageId) async {
    final statuses = await _localDataSource.getPipelineStatuses(stageId: stageId);
    return statuses.map(_mapToStatusInfo).toList();
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync pipelines from remote server.
  @override
  Future<void> syncFromRemote({DateTime? since}) async {
    try {
      final remoteData = await _remoteDataSource.fetchPipelines(since: since);
      
      if (remoteData.isEmpty) {
        _log.debug('pipeline | No pipelines to sync from remote');
        return;
      }

      _log.debug('pipeline | Syncing ${remoteData.length} pipelines from remote');

      final companions = remoteData.map((data) {
        return db.PipelinesCompanion(
          id: Value(data['id'] as String),
          code: Value(data['code'] as String),
          customerId: Value(data['customer_id'] as String),
          stageId: Value(data['stage_id'] as String? ?? ''),
          statusId: Value(data['status_id'] as String? ?? ''),
          cobId: Value(data['cob_id'] as String? ?? ''),
          lobId: Value(data['lob_id'] as String? ?? ''),
          leadSourceId: Value(data['lead_source_id'] as String? ?? ''),
          brokerId: Value(data['broker_id'] as String?),
          brokerPicId: Value(data['broker_pic_id'] as String?),
          customerContactId: Value(data['customer_contact_id'] as String?),
          tsi: Value((data['tsi'] as num?)?.toDouble()),
          potentialPremium: Value((data['potential_premium'] as num?)?.toDouble() ?? 0.0),
          finalPremium: Value((data['final_premium'] as num?)?.toDouble()),
          weightedValue: Value((data['weighted_value'] as num?)?.toDouble()),
          expectedCloseDate: data['expected_close_date'] != null
              ? Value(DateTime.parse(data['expected_close_date'] as String))
              : const Value(null),
          policyNumber: Value(data['policy_number'] as String?),
          declineReason: Value(data['decline_reason'] as String?),
          notes: Value(data['notes'] as String?),
          isTender: Value(data['is_tender'] as bool? ?? false),
          referredByUserId: Value(data['referred_by_user_id'] as String?),
          referralId: Value(data['referral_id'] as String?),
          scoredToUserId: Value(data['scored_to_user_id'] as String?),
          assignedRmId: Value(data['assigned_rm_id'] as String? ?? ''),
          createdBy: Value(data['created_by'] as String? ?? ''),
          isPendingSync: const Value(false),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          updatedAt: Value(DateTime.parse(data['updated_at'] as String)),
          closedAt: data['closed_at'] != null
              ? Value(DateTime.parse(data['closed_at'] as String))
              : const Value(null),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
          lastSyncAt: Value(DateTime.now()),
        );
      }).toList();

      await _localDataSource.upsertPipelines(companions);
      _log.debug('pipeline | Successfully synced ${companions.length} pipelines');
    } catch (e) {
      _log.error('pipeline | Error syncing from remote: $e');
      rethrow;
    }
  }

  /// Mark a pipeline as synced.
  @override
  Future<void> markAsSynced(String id, DateTime syncedAt) =>
      _localDataSource.markAsSynced(id, syncedAt);

  // ==========================================
  // Private Helpers
  // ==========================================

  /// Generate a unique pipeline code.
  String _generatePipelineCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'PIP${timestamp.substring(timestamp.length - 8)}';
  }

  /// Initialize lookup caches from master data.
  Future<void> _ensureCachesLoaded() async {
    if (_stageNameCache == null) {
      final stages = await _localDataSource.getPipelineStages();
      _stageNameCache = {for (final s in stages) s.id: s.name};
      _stageColorCache = {for (final s in stages) s.id: s.color ?? ''};
      _stageProbabilityCache = {for (final s in stages) s.id: s.probability};
      _stageIsFinalCache = {for (final s in stages) s.id: s.isFinal};
      _stageIsWonCache = {for (final s in stages) s.id: s.isWon};
      _log.debug('pipeline | Loaded ${stages.length} stages');
    }
    if (_statusNameCache == null) {
      final statuses = await _localDataSource.getPipelineStatuses();
      _statusNameCache = {for (final s in statuses) s.id: s.name};
      _log.debug('pipeline | Loaded ${statuses.length} statuses');
    }
    if (_cobNameCache == null) {
      final cobs = await _masterDataSource.getCobs();
      _cobNameCache = {for (final c in cobs) c.id: c.name};
      _log.debug('pipeline | Loaded ${cobs.length} COBs');
    }
    if (_lobNameCache == null) {
      // Get all LOBs by not filtering by COB
      final allLobs = await _getAllLobs();
      _lobNameCache = {for (final l in allLobs) l.id: l.name};
      _log.debug('pipeline | Loaded ${allLobs.length} LOBs');
    }
    if (_leadSourceNameCache == null) {
      final sources = await _masterDataSource.getLeadSources();
      _leadSourceNameCache = {for (final s in sources) s.id: s.name};
      _log.debug('pipeline | Loaded ${sources.length} lead sources');
    }
    if (_brokerNameCache == null) {
      final brokers = await _masterDataSource.getBrokers();
      _brokerNameCache = {for (final b in brokers) b.id: b.name};
      _log.debug('pipeline | Loaded ${brokers.length} brokers');
    }
    if (_customerNameCache == null) {
      final customers = await _customerDataSource.getAllCustomers();
      _customerNameCache = {for (final c in customers) c.id: c.name};
      _log.debug('pipeline | Loaded ${customers.length} customers');
    }
    if (_userNameCache == null) {
      final users = await _database.select(_database.users).get();
      _userNameCache = {for (final u in users) u.id: u.name};
      _log.debug('pipeline | Loaded ${users.length} users');
    }
  }

  /// Invalidate all caches (call after sync to refresh lookups).
  void invalidateCaches() {
    _stageNameCache = null;
    _stageColorCache = null;
    _stageProbabilityCache = null;
    _stageIsFinalCache = null;
    _stageIsWonCache = null;
    _statusNameCache = null;
    _cobNameCache = null;
    _lobNameCache = null;
    _leadSourceNameCache = null;
    _brokerNameCache = null;
    _customerNameCache = null;
    _userNameCache = null;
    _log.debug('pipeline | Caches invalidated');
  }

  /// Get all LOBs from database.
  Future<List<LobDto>> _getAllLobs() async {
    return _masterDataSource.getAllLobs();
  }

  /// Map Drift Pipeline data to domain Pipeline entity with resolved lookups.
  domain.Pipeline _mapToPipeline(db.Pipeline data) => domain.Pipeline(
        id: data.id,
        code: data.code,
        customerId: data.customerId,
        stageId: data.stageId,
        statusId: data.statusId,
        cobId: data.cobId,
        lobId: data.lobId,
        leadSourceId: data.leadSourceId,
        brokerId: data.brokerId,
        brokerPicId: data.brokerPicId,
        customerContactId: data.customerContactId,
        tsi: data.tsi,
        potentialPremium: data.potentialPremium,
        finalPremium: data.finalPremium,
        weightedValue: data.weightedValue,
        expectedCloseDate: data.expectedCloseDate,
        policyNumber: data.policyNumber,
        declineReason: data.declineReason,
        notes: data.notes,
        isTender: data.isTender,
        referredByUserId: data.referredByUserId,
        referralId: data.referralId,
        scoredToUserId: data.scoredToUserId,
        assignedRmId: data.assignedRmId,
        createdBy: data.createdBy,
        isPendingSync: data.isPendingSync,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        closedAt: data.closedAt,
        deletedAt: data.deletedAt,
        lastSyncAt: data.lastSyncAt,
        // Lookup fields - resolved from caches
        stageName: _stageNameCache?[data.stageId],
        stageColor: _stageColorCache?[data.stageId],
        stageProbability: _stageProbabilityCache?[data.stageId],
        stageIsFinal: _stageIsFinalCache?[data.stageId],
        stageIsWon: _stageIsWonCache?[data.stageId],
        statusName: _statusNameCache?[data.statusId],
        cobName: _cobNameCache?[data.cobId],
        lobName: _lobNameCache?[data.lobId],
        leadSourceName: _leadSourceNameCache?[data.leadSourceId],
        brokerName: data.brokerId == null ? null : _brokerNameCache?[data.brokerId],
        customerName: _customerNameCache?[data.customerId],
        assignedRmName: _userNameCache?[data.assignedRmId],
        scoredToUserName: _userNameCache?[data.scoredToUserId],
      );

  /// Map Drift PipelineStage to domain PipelineStageInfo.
  domain.PipelineStageInfo _mapToStageInfo(db.PipelineStage data) =>
      domain.PipelineStageInfo(
        id: data.id,
        code: data.code,
        name: data.name,
        probability: data.probability,
        sequence: data.sequence,
        color: data.color,
        isFinal: data.isFinal,
        isWon: data.isWon,
        isActive: data.isActive,
      );

  /// Map Drift PipelineStatus to domain PipelineStatusInfo.
  domain.PipelineStatusInfo _mapToStatusInfo(db.PipelineStatuse data) =>
      domain.PipelineStatusInfo(
        id: data.id,
        stageId: data.stageId,
        code: data.code,
        name: data.name,
        sequence: data.sequence,
        description: data.description,
        isDefault: data.isDefault,
        isActive: data.isActive,
      );

  /// Sanitize empty strings to null for UUID fields.
  /// PostgreSQL rejects empty strings for UUID type columns.
  String? _sanitizeUuid(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Create sync payload for new pipeline.
  Map<String, dynamic> _createSyncPayload({
    required String id,
    required String code,
    required PipelineCreateDto dto,
    required String stageId,
    required String statusId,
    required double weightedValue,
    required DateTime now,
    required String assignedRmId,
  }) {
    return {
      'id': id,
      'code': code,
      'customer_id': dto.customerId,
      'stage_id': _sanitizeUuid(stageId),
      'status_id': _sanitizeUuid(statusId),
      'cob_id': dto.cobId,
      'lob_id': dto.lobId,
      'lead_source_id': dto.leadSourceId,
      'broker_id': _sanitizeUuid(dto.brokerId),
      'broker_pic_id': _sanitizeUuid(dto.brokerPicId),
      'customer_contact_id': _sanitizeUuid(dto.customerContactId),
      'tsi': dto.tsi,
      'potential_premium': dto.potentialPremium,
      'weighted_value': weightedValue,
      'expected_close_date': dto.expectedCloseDate?.toIso8601String(),
      'is_tender': dto.isTender,
      'notes': _sanitizeUuid(dto.notes),
      'assigned_rm_id': assignedRmId,
      'created_by': _currentUserId,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// Create sync payload for updated pipeline.
  Map<String, dynamic> _createUpdateSyncPayload(db.Pipeline data) {
    return {
      'id': data.id,
      'code': data.code,
      'customer_id': data.customerId,
      'stage_id': _sanitizeUuid(data.stageId),
      'status_id': _sanitizeUuid(data.statusId),
      'cob_id': data.cobId,
      'lob_id': data.lobId,
      'lead_source_id': data.leadSourceId,
      'broker_id': _sanitizeUuid(data.brokerId),
      'broker_pic_id': _sanitizeUuid(data.brokerPicId),
      'customer_contact_id': _sanitizeUuid(data.customerContactId),
      'tsi': data.tsi,
      'potential_premium': data.potentialPremium,
      'final_premium': data.finalPremium,
      'weighted_value': data.weightedValue,
      'expected_close_date': data.expectedCloseDate?.toIso8601String(),
      'policy_number': _sanitizeUuid(data.policyNumber),
      'decline_reason': _sanitizeUuid(data.declineReason),
      'is_tender': data.isTender,
      'notes': _sanitizeUuid(data.notes),
      'referred_by_user_id': _sanitizeUuid(data.referredByUserId),
      'referral_id': _sanitizeUuid(data.referralId),
      'scored_to_user_id': _sanitizeUuid(data.scoredToUserId),
      'assigned_rm_id': data.assignedRmId,
      'created_by': data.createdBy,
      'created_at': data.createdAt.toIso8601String(),
      'updated_at': data.updatedAt.toIso8601String(),
      'closed_at': data.closedAt?.toIso8601String(),
      'deleted_at': data.deletedAt?.toIso8601String(),
    };
  }
}
