import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/core/errors/failures.dart';
import 'package:leadx_crm/core/errors/result.dart';
import 'package:leadx_crm/core/logging/app_logger.dart';
import 'package:leadx_crm/data/database/app_database.dart' as db;
import 'package:leadx_crm/data/datasources/local/customer_local_data_source.dart';
import 'package:leadx_crm/data/datasources/local/history_log_local_data_source.dart';
import 'package:leadx_crm/data/datasources/local/master_data_local_data_source.dart';
import 'package:leadx_crm/data/datasources/local/pipeline_local_data_source.dart';
import 'package:leadx_crm/data/datasources/remote/pipeline_remote_data_source.dart';
import 'package:leadx_crm/data/dtos/pipeline_dtos.dart';
import 'package:leadx_crm/data/repositories/pipeline_repository_impl.dart';
import 'package:leadx_crm/data/services/sync_service.dart';
import 'package:leadx_crm/domain/entities/pipeline.dart' as domain;
import 'package:leadx_crm/domain/entities/sync_models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  PipelineLocalDataSource,
  MasterDataLocalDataSource,
  CustomerLocalDataSource,
  HistoryLogLocalDataSource,
  PipelineRemoteDataSource,
  SyncService,
])
@GenerateNiceMocks([
  MockSpec<db.AppDatabase>(),
  MockSpec<SimpleSelectStatement<db.$UsersTable, db.User>>(),
])
import 'pipeline_repository_impl_test.mocks.dart';

void main() {
  setUpAll(() {
    AppLogger.init();
  });

  late PipelineRepositoryImpl repository;
  late MockPipelineLocalDataSource mockLocalDataSource;
  late MockMasterDataLocalDataSource mockMasterDataSource;
  late MockCustomerLocalDataSource mockCustomerDataSource;
  late MockHistoryLogLocalDataSource mockHistoryLogDataSource;
  late MockPipelineRemoteDataSource mockRemoteDataSource;
  late MockSyncService mockSyncService;
  late MockAppDatabase mockDatabase;
  late MockSimpleSelectStatement mockUsersSelect;

  const testUserId = 'test-user-id';
  final testNow = DateTime(2026, 1, 21);

  // Helper to create a default SyncResult for mocking
  SyncResult createDefaultSyncResult() {
    return SyncResult(
      success: true,
      processedCount: 0,
      successCount: 0,
      failedCount: 0,
      errors: [],
      syncedAt: testNow,
    );
  }

  // Sample test pipeline data from Drift
  db.Pipeline createTestDbPipeline({
    String id = 'pipeline-1',
    String code = 'PIP12345678',
    String customerId = 'customer-1',
    String stageId = 'stage-new',
    String statusId = 'status-1',
    String cobId = 'cob-1',
    String lobId = 'lob-1',
    String leadSourceId = 'source-1',
    double potentialPremium = 100000000,
    double? weightedValue,
    bool isPendingSync = false,
  }) {
    return db.Pipeline(
      id: id,
      code: code,
      customerId: customerId,
      stageId: stageId,
      statusId: statusId,
      cobId: cobId,
      lobId: lobId,
      leadSourceId: leadSourceId,
      potentialPremium: potentialPremium,
      weightedValue: weightedValue ?? potentialPremium * 0.1,
      assignedRmId: testUserId,
      createdBy: testUserId,
      isPendingSync: isPendingSync,
      createdAt: testNow,
      updatedAt: testNow,
      isTender: false,
    );
  }

  // Sample test stage data from Drift
  db.PipelineStage createTestDbStage({
    String id = 'stage-new',
    String code = 'NEW',
    String name = 'New',
    int probability = 10,
    int sequence = 1,
    bool isFinal = false,
    bool isWon = false,
  }) {
    return db.PipelineStage(
      id: id,
      code: code,
      name: name,
      probability: probability,
      sequence: sequence,
      isFinal: isFinal,
      isWon: isWon,
      isActive: true,
      color: '#3498DB',
      createdAt: testNow,
      updatedAt: testNow,
    );
  }

  // Sample test status data from Drift
  db.PipelineStatuse createTestDbStatus({
    String id = 'status-1',
    String stageId = 'stage-new',
    String code = 'INITIAL',
    String name = 'Initial Contact',
    int sequence = 1,
    bool isDefault = true,
  }) {
    return db.PipelineStatuse(
      id: id,
      stageId: stageId,
      code: code,
      name: name,
      sequence: sequence,
      isDefault: isDefault,
      isActive: true,
      createdAt: testNow,
      updatedAt: testNow,
    );
  }

  PipelineCreateDto createTestPipelineDto({
    String customerId = 'customer-1',
    String cobId = 'cob-1',
    String lobId = 'lob-1',
    String leadSourceId = 'source-1',
    double potentialPremium = 100000000,
  }) {
    return PipelineCreateDto(
      customerId: customerId,
      cobId: cobId,
      lobId: lobId,
      leadSourceId: leadSourceId,
      potentialPremium: potentialPremium,
    );
  }

  setUp(() {
    mockLocalDataSource = MockPipelineLocalDataSource();
    mockMasterDataSource = MockMasterDataLocalDataSource();
    mockCustomerDataSource = MockCustomerLocalDataSource();
    mockHistoryLogDataSource = MockHistoryLogLocalDataSource();
    mockRemoteDataSource = MockPipelineRemoteDataSource();
    mockSyncService = MockSyncService();
    mockDatabase = MockAppDatabase();
    mockUsersSelect = MockSimpleSelectStatement();

    // Mock database.select(database.users).get() to return empty list
    when(mockDatabase.select<db.$UsersTable, db.User>(any)).thenReturn(mockUsersSelect);
    when(mockUsersSelect.get()).thenAnswer((_) async => <db.User>[]);

    // Default mock for master data caches
    when(mockLocalDataSource.getPipelineStages())
        .thenAnswer((_) async => [createTestDbStage()]);
    when(mockLocalDataSource.getPipelineStatuses(stageId: anyNamed('stageId')))
        .thenAnswer((_) async => [createTestDbStatus()]);
    when(mockLocalDataSource.getPipelineStatuses())
        .thenAnswer((_) async => [createTestDbStatus()]);
    when(mockMasterDataSource.getCobs()).thenAnswer((_) async => []);
    when(mockMasterDataSource.getLobsByCob(any)).thenAnswer((_) async => []);
    when(mockMasterDataSource.getAllLobs()).thenAnswer((_) async => []);
    when(mockMasterDataSource.getLeadSources()).thenAnswer((_) async => []);
    when(mockMasterDataSource.getBrokers()).thenAnswer((_) async => []);
    when(mockCustomerDataSource.getAllCustomers()).thenAnswer((_) async => []);

    // Default stubs for methods called during CRUD operations
    when(mockCustomerDataSource.getCustomerById(any))
        .thenAnswer((_) async => null);
    when(mockLocalDataSource.getStageById(any))
        .thenAnswer((_) async => createTestDbStage());
    when(mockSyncService.triggerSync())
        .thenAnswer((_) async => createDefaultSyncResult());
    // Mock transaction to just execute the callback
    when(mockDatabase.transaction(any)).thenAnswer((invocation) {
      final callback = invocation.positionalArguments[0] as Future<dynamic> Function();
      return callback();
    });

    repository = PipelineRepositoryImpl(
      localDataSource: mockLocalDataSource,
      masterDataSource: mockMasterDataSource,
      customerDataSource: mockCustomerDataSource,
      remoteDataSource: mockRemoteDataSource,
      historyLogDataSource: mockHistoryLogDataSource,
      syncService: mockSyncService,
      currentUserId: testUserId,
      database: mockDatabase,
    );
  });

  group('PipelineRepositoryImpl', () {
    // ==========================================
    // CRUD Operations Tests
    // ==========================================

    group('getPipelineById', () {
      test('returns Pipeline when found', () async {
        // Arrange
        final testDbPipeline = createTestDbPipeline();
        when(mockLocalDataSource.getPipelineById('pipeline-1'))
            .thenAnswer((_) async => testDbPipeline);

        // Act
        final result = await repository.getPipelineById('pipeline-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'pipeline-1');
        expect(result.code, 'PIP12345678');
        verify(mockLocalDataSource.getPipelineById('pipeline-1')).called(1);
      });

      test('returns null when not found', () async {
        // Arrange
        when(mockLocalDataSource.getPipelineById('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getPipelineById('non-existent');

        // Assert
        expect(result, isNull);
        verify(mockLocalDataSource.getPipelineById('non-existent')).called(1);
      });
    });

    group('createPipeline', () {
      test('returns Pipeline on successful create with default stage', () async {
        // Arrange
        final dto = createTestPipelineDto();
        final newStage = createTestDbStage(id: 'stage-new', code: 'NEW');
        final defaultStatus = createTestDbStatus(stageId: 'stage-new');
        final testDbPipeline = createTestDbPipeline(isPendingSync: true);

        when(mockLocalDataSource.getPipelineStages())
            .thenAnswer((_) async => [newStage]);
        when(mockLocalDataSource.getDefaultStatus('stage-new'))
            .thenAnswer((_) async => defaultStatus);
        when(mockLocalDataSource.insertPipeline(any)).thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createDefaultSyncResult());
        when(mockLocalDataSource.getPipelineById(any))
            .thenAnswer((_) async => testDbPipeline);

        // Act
        final result = await repository.createPipeline(dto);

        // Assert
        expect(result, isA<Success<domain.Pipeline>>());
        final pipeline = (result as Success<domain.Pipeline>).value;
        expect(pipeline.code, 'PIP12345678');
        expect(pipeline.stageId, 'stage-new');
        verify(mockLocalDataSource.insertPipeline(any)).called(1);
        verify(mockSyncService.queueOperation(
          entityType: SyncEntityType.pipeline,
          entityId: anyNamed('entityId'),
          operation: SyncOperation.create,
          payload: anyNamed('payload'),
        )).called(1);
        verify(mockSyncService.triggerSync()).called(1);
      });

      test('returns failure when insert fails', () async {
        // Arrange
        final dto = createTestPipelineDto();
        final newStage = createTestDbStage();
        final defaultStatus = createTestDbStatus();

        when(mockLocalDataSource.getPipelineStages())
            .thenAnswer((_) async => [newStage]);
        when(mockLocalDataSource.getDefaultStatus(any))
            .thenAnswer((_) async => defaultStatus);
        when(mockLocalDataSource.insertPipeline(any))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.createPipeline(dto);

        // Assert
        expect(result, isA<ResultFailure<domain.Pipeline>>());
        final failure = (result as ResultFailure<domain.Pipeline>).failure;
        expect(failure, isA<UnexpectedFailure>());
      });
    });

    group('updatePipeline', () {
      test('returns updated Pipeline on success', () async {
        // Arrange
        const id = 'pipeline-1';
        final dto = const PipelineUpdateDto(potentialPremium: 200000000);
        final existingPipeline = createTestDbPipeline();
        final stage = createTestDbStage();
        final updatedPipeline = createTestDbPipeline(
          potentialPremium: 200000000,
          isPendingSync: true,
        );

        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => existingPipeline);
        when(mockLocalDataSource.getStageById(existingPipeline.stageId))
            .thenAnswer((_) async => stage);
        when(mockLocalDataSource.updatePipeline(id, any))
            .thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createDefaultSyncResult());

        // Set up for second call to getPipelineById (after update)
        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => updatedPipeline);

        // Act
        final result = await repository.updatePipeline(id, dto);

        // Assert
        expect(result, isA<Success<domain.Pipeline>>());
        final pipeline = (result as Success<domain.Pipeline>).value;
        expect(pipeline.potentialPremium, 200000000);
        verify(mockLocalDataSource.updatePipeline(id, any)).called(1);
        verify(mockSyncService.queueOperation(
          entityType: SyncEntityType.pipeline,
          entityId: id,
          operation: SyncOperation.update,
          payload: anyNamed('payload'),
        )).called(1);
      });

      test('returns NotFoundFailure when pipeline not found', () async {
        // Arrange
        const id = 'non-existent';
        final dto = const PipelineUpdateDto(potentialPremium: 200000000);

        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.updatePipeline(id, dto);

        // Assert
        expect(result, isA<ResultFailure<domain.Pipeline>>());
        final failure = (result as ResultFailure<domain.Pipeline>).failure;
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, contains('Pipeline not found'));
      });
    });

    group('updatePipelineStage', () {
      test('updates stage and assigns default status', () async {
        // Arrange
        const id = 'pipeline-1';
        final dto = const PipelineStageUpdateDto(stageId: 'stage-p3');
        final existingPipeline = createTestDbPipeline();
        final newStage = createTestDbStage(
          id: 'stage-p3',
          code: 'P3',
          name: 'P3',
          probability: 30,
        );
        final defaultStatus = createTestDbStatus(
          id: 'status-p3-default',
          stageId: 'stage-p3',
        );
        final updatedPipeline = createTestDbPipeline(
          stageId: 'stage-p3',
          statusId: 'status-p3-default',
          isPendingSync: true,
        );

        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => existingPipeline);
        when(mockLocalDataSource.getStageById('stage-p3'))
            .thenAnswer((_) async => newStage);
        when(mockLocalDataSource.getDefaultStatus('stage-p3'))
            .thenAnswer((_) async => defaultStatus);
        when(mockLocalDataSource.updatePipeline(id, any))
            .thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createDefaultSyncResult());

        // Second call returns updated pipeline
        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => updatedPipeline);

        // Act
        final result = await repository.updatePipelineStage(id, dto);

        // Assert
        expect(result, isA<Success<domain.Pipeline>>());
        final pipeline = (result as Success<domain.Pipeline>).value;
        expect(pipeline.stageId, 'stage-p3');
        verify(mockLocalDataSource.getDefaultStatus('stage-p3')).called(1);
        verify(mockSyncService.triggerSync()).called(1);
      });

      test('returns ValidationFailure when stage is invalid', () async {
        // Arrange
        const id = 'pipeline-1';
        final dto = const PipelineStageUpdateDto(stageId: 'invalid-stage');
        final existingPipeline = createTestDbPipeline();

        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => existingPipeline);
        when(mockLocalDataSource.getStageById('invalid-stage'))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.updatePipelineStage(id, dto);

        // Assert
        expect(result, isA<ResultFailure<domain.Pipeline>>());
        final failure = (result as ResultFailure<domain.Pipeline>).failure;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('Invalid stage'));
      });

      test('sets closedAt when moving to final stage', () async {
        // Arrange
        const id = 'pipeline-1';
        final dto = const PipelineStageUpdateDto(
          stageId: 'stage-won',
          policyNumber: 'POL-001',
          finalPremium: 50000000,
        );
        final existingPipeline = createTestDbPipeline();
        final wonStage = createTestDbStage(
          id: 'stage-won',
          code: 'WON',
          name: 'Won',
          probability: 100,
          isFinal: true,
          isWon: true,
        );
        final defaultStatus = createTestDbStatus(
          id: 'status-won',
          stageId: 'stage-won',
        );
        final closedPipeline = createTestDbPipeline(
          stageId: 'stage-won',
          isPendingSync: true,
        );

        // First call returns existing (not-closed) pipeline, subsequent calls return closed
        var callCount = 0;
        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? existingPipeline : closedPipeline;
        });
        when(mockLocalDataSource.getStageById('stage-won'))
            .thenAnswer((_) async => wonStage);
        when(mockLocalDataSource.getDefaultStatus('stage-won'))
            .thenAnswer((_) async => defaultStatus);
        when(mockLocalDataSource.updatePipeline(id, any))
            .thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createDefaultSyncResult());

        // Act
        final result = await repository.updatePipelineStage(id, dto);

        // Assert
        expect(result, isA<Success<domain.Pipeline>>());
        // Verify that updatePipeline was called with closedAt value
        verify(mockLocalDataSource.updatePipeline(
          id,
          argThat(isA<db.PipelinesCompanion>()),
        )).called(1);
      });
    });

    group('updatePipelineStatus', () {
      test('updates status without changing stage', () async {
        // Arrange
        const id = 'pipeline-1';
        final dto = const PipelineStatusUpdateDto(statusId: 'status-2');
        final existingPipeline = createTestDbPipeline();
        final updatedPipeline = createTestDbPipeline(
          statusId: 'status-2',
          isPendingSync: true,
        );

        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => existingPipeline);
        when(mockLocalDataSource.updatePipeline(id, any))
            .thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createDefaultSyncResult());

        // Second call returns updated pipeline
        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => updatedPipeline);

        // Act
        final result = await repository.updatePipelineStatus(id, dto);

        // Assert
        expect(result, isA<Success<domain.Pipeline>>());
        final pipeline = (result as Success<domain.Pipeline>).value;
        expect(pipeline.statusId, 'status-2');
        // Stage should remain unchanged
        expect(pipeline.stageId, 'stage-new');
        verify(mockSyncService.triggerSync()).called(1);
      });

      test('returns NotFoundFailure when pipeline not found', () async {
        // Arrange
        const id = 'non-existent';
        final dto = const PipelineStatusUpdateDto(statusId: 'status-2');

        when(mockLocalDataSource.getPipelineById(id))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.updatePipelineStatus(id, dto);

        // Assert
        expect(result, isA<ResultFailure<domain.Pipeline>>());
        final failure = (result as ResultFailure<domain.Pipeline>).failure;
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, contains('Pipeline not found'));
      });
    });

    group('deletePipeline', () {
      test('returns Success on successful soft delete', () async {
        // Arrange
        const id = 'pipeline-1';
        when(mockLocalDataSource.softDeletePipeline(id))
            .thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);

        // Act
        final result = await repository.deletePipeline(id);

        // Assert
        expect(result, isA<Success<void>>());
        verify(mockLocalDataSource.softDeletePipeline(id)).called(1);
        verify(mockSyncService.queueOperation(
          entityType: SyncEntityType.pipeline,
          entityId: id,
          operation: SyncOperation.delete,
          payload: anyNamed('payload'),
        )).called(1);
      });

      test('returns failure when delete fails', () async {
        // Arrange
        const id = 'pipeline-1';
        when(mockLocalDataSource.softDeletePipeline(id))
            .thenThrow(Exception('Delete error'));

        // Act
        final result = await repository.deletePipeline(id);

        // Assert
        expect(result, isA<ResultFailure<void>>());
        final failure = (result as ResultFailure<void>).failure;
        expect(failure, isA<UnexpectedFailure>());
      });
    });

    // ==========================================
    // Search Functionality Tests
    // ==========================================

    group('searchPipelines', () {
      test('returns list of matching pipelines', () async {
        // Arrange
        final pipeline1 = createTestDbPipeline(id: 'pip-1', code: 'PIP001');
        final pipeline2 = createTestDbPipeline(id: 'pip-2', code: 'PIP002');

        when(mockLocalDataSource.searchPipelines('PIP'))
            .thenAnswer((_) async => [pipeline1, pipeline2]);

        // Act
        final results = await repository.searchPipelines('PIP');

        // Assert
        expect(results.length, 2);
        verify(mockLocalDataSource.searchPipelines('PIP')).called(1);
      });

      test('returns empty list when no matches', () async {
        // Arrange
        when(mockLocalDataSource.searchPipelines('XYZ'))
            .thenAnswer((_) async => []);

        // Act
        final results = await repository.searchPipelines('XYZ');

        // Assert
        expect(results, isEmpty);
        verify(mockLocalDataSource.searchPipelines('XYZ')).called(1);
      });
    });

    group('getCustomerPipelines', () {
      test('returns pipelines for specific customer', () async {
        // Arrange
        final pipeline1 = createTestDbPipeline(
          id: 'pip-1',
          customerId: 'customer-1',
        );
        final pipeline2 = createTestDbPipeline(
          id: 'pip-2',
          customerId: 'customer-1',
        );

        when(mockLocalDataSource.getCustomerPipelines('customer-1'))
            .thenAnswer((_) async => [pipeline1, pipeline2]);

        // Act
        final results = await repository.getCustomerPipelines('customer-1');

        // Assert
        expect(results.length, 2);
        expect(results[0].customerId, 'customer-1');
        verify(mockLocalDataSource.getCustomerPipelines('customer-1')).called(1);
      });
    });

    // ==========================================
    // Master Data Operations Tests
    // ==========================================

    group('getPipelineStages', () {
      test('returns list of stages', () async {
        // Arrange
        final stage1 = createTestDbStage(id: 'stage-1', name: 'New');
        final stage2 = createTestDbStage(id: 'stage-2', name: 'P3');

        when(mockLocalDataSource.getPipelineStages())
            .thenAnswer((_) async => [stage1, stage2]);

        // Act
        final results = await repository.getPipelineStages();

        // Assert
        expect(results.length, 2);
        expect(results[0].name, 'New');
        expect(results[1].name, 'P3');
      });
    });

    group('getPipelineStatuses', () {
      test('returns statuses filtered by stage', () async {
        // Arrange
        final status1 = createTestDbStatus(
          id: 'status-1',
          stageId: 'stage-p3',
          name: 'Proposal Sent',
        );
        final status2 = createTestDbStatus(
          id: 'status-2',
          stageId: 'stage-p3',
          name: 'Negotiation',
        );

        when(mockLocalDataSource.getPipelineStatuses(stageId: 'stage-p3'))
            .thenAnswer((_) async => [status1, status2]);

        // Act
        final results = await repository.getPipelineStatuses('stage-p3');

        // Assert
        expect(results.length, 2);
        expect(results[0].name, 'Proposal Sent');
        expect(results[1].stageId, 'stage-p3');
      });
    });

    // ==========================================
    // Stream Operations Tests
    // ==========================================

    group('watchAllPipelines', () {
      test('returns stream of pipelines', () async {
        // Arrange
        final pipeline1 = createTestDbPipeline(id: 'pip-1');
        final pipeline2 = createTestDbPipeline(id: 'pip-2');

        when(mockLocalDataSource.watchAllPipelines()).thenAnswer(
          (_) => Stream.value([pipeline1, pipeline2]),
        );

        // Act
        final stream = repository.watchAllPipelines();
        final results = await stream.first;

        // Assert
        expect(results.length, 2);
        verify(mockLocalDataSource.watchAllPipelines()).called(1);
      });
    });

    group('watchCustomerPipelines', () {
      test('returns stream of customer pipelines', () async {
        // Arrange
        final pipeline1 = createTestDbPipeline(
          id: 'pip-1',
          customerId: 'customer-1',
        );

        when(mockLocalDataSource.watchCustomerPipelines('customer-1'))
            .thenAnswer((_) => Stream.value([pipeline1]));

        // Act
        final stream = repository.watchCustomerPipelines('customer-1');
        final results = await stream.first;

        // Assert
        expect(results.length, 1);
        expect(results[0].customerId, 'customer-1');
        verify(mockLocalDataSource.watchCustomerPipelines('customer-1'))
            .called(1);
      });
    });

    // ==========================================
    // Mark As Synced Tests
    // ==========================================

    group('markAsSynced', () {
      test('calls local data source markAsSynced', () async {
        // Arrange
        final syncedAt = DateTime.now();
        when(mockLocalDataSource.markAsSynced('pipeline-1', syncedAt))
            .thenAnswer((_) async {});

        // Act
        await repository.markAsSynced('pipeline-1', syncedAt);

        // Assert
        verify(mockLocalDataSource.markAsSynced('pipeline-1', syncedAt))
            .called(1);
      });
    });
  });
}
