import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/data/database/app_database.dart';
import 'package:leadx_crm/data/datasources/local/master_data_local_data_source.dart';
import 'package:leadx_crm/data/datasources/local/pipeline_local_data_source.dart';
import 'package:leadx_crm/data/datasources/remote/pipeline_remote_data_source.dart';
import 'package:leadx_crm/data/dtos/pipeline_dtos.dart';
import 'package:leadx_crm/data/repositories/pipeline_repository_impl.dart';
import 'package:leadx_crm/data/services/sync_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/mock_sync_infrastructure.dart';

@GenerateMocks([
  PipelineLocalDataSource,
  MasterDataLocalDataSource,
  PipelineRemoteDataSource,
  AppDatabase,
  SupabaseClient,
])
import 'pipeline_flow_test.mocks.dart';

void main() {
  late PipelineRepositoryImpl repository;
  late MockPipelineLocalDataSource mockLocalDataSource;
  late MockMasterDataLocalDataSource mockMasterDataSource;
  late MockPipelineRemoteDataSource mockRemoteDataSource;
  late TrackingSyncQueueDataSource trackingQueueDataSource;
  late FakeConnectivityService fakeConnectivityService;
  late SyncService syncService;
  late MockAppDatabase mockDatabase;
  late MockSupabaseClient mockSupabaseClient;

  const testUserId = 'test-user-id';

  setUp(() {
    mockLocalDataSource = MockPipelineLocalDataSource();
    mockMasterDataSource = MockMasterDataLocalDataSource();
    mockRemoteDataSource = MockPipelineRemoteDataSource();
    trackingQueueDataSource = TrackingSyncQueueDataSource();
    fakeConnectivityService = FakeConnectivityService();
    mockDatabase = MockAppDatabase();
    mockSupabaseClient = MockSupabaseClient();

    syncService = SyncService(
      syncQueueDataSource: trackingQueueDataSource,
      connectivityService: fakeConnectivityService,
      supabaseClient: mockSupabaseClient,
      database: mockDatabase,
    );

    repository = PipelineRepositoryImpl(
      localDataSource: mockLocalDataSource,
      masterDataSource: mockMasterDataSource,
      remoteDataSource: mockRemoteDataSource,
      syncService: syncService,
      currentUserId: testUserId,
    );
  });

  tearDown(() {
    syncService.dispose();
    fakeConnectivityService.dispose();
  });

  group('Pipeline Flow Integration Tests', () {
    group('Create Pipeline Flow', () {
      test('creating a pipeline queues for sync', () async {
        // Arrange
        final dto = PipelineCreateDto(
          customerId: 'customer-1',
          cobId: 'cob-1',
          lobId: 'lob-1',
          leadSourceId: 'source-1',
          potentialPremium: 100000000,
        );

        // Setup mocks for stage and status
        when(mockMasterDataSource.getAllPipelineStages())
            .thenAnswer((_) async => [_createTestDbStage()]);
        when(mockMasterDataSource.getPipelineStatusesByStage(any))
            .thenAnswer((_) async => [_createTestDbStatus()]);
        when(mockLocalDataSource.insertPipeline(any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await repository.createPipeline(dto);

        // Assert
        expect(result.isRight(), true);
        
        // Verify sync queue has the item
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.entityType, 'pipeline');
        expect(trackingQueueDataSource.items.first.operation, 'create');
      });

      test('creating a pipeline succeeds even when offline', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        
        final dto = PipelineCreateDto(
          customerId: 'customer-1',
          cobId: 'cob-1',
          lobId: 'lob-1',
          leadSourceId: 'source-1',
          potentialPremium: 50000000,
        );

        when(mockMasterDataSource.getAllPipelineStages())
            .thenAnswer((_) async => [_createTestDbStage()]);
        when(mockMasterDataSource.getPipelineStatusesByStage(any))
            .thenAnswer((_) async => [_createTestDbStatus()]);
        when(mockLocalDataSource.insertPipeline(any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await repository.createPipeline(dto);

        // Assert - should still succeed (offline-first)
        expect(result.isRight(), true);
        
        // Verify item is queued for sync
        expect(trackingQueueDataSource.items.length, 1);
      });
    });

    group('Update Pipeline Stage Flow', () {
      test('updating pipeline stage queues for sync', () async {
        // Arrange
        const pipelineId = 'pipeline-123';
        final dto = PipelineStageUpdateDto(
          stageId: 'stage-p3',
        );

        // Setup mocks
        when(mockLocalDataSource.getPipelineById(pipelineId))
            .thenAnswer((_) async => _createTestDbPipeline(id: pipelineId));
        when(mockMasterDataSource.getAllPipelineStages())
            .thenAnswer((_) async => [
              _createTestDbStage(id: 'stage-new', code: 'NEW', probability: 10),
              _createTestDbStage(id: 'stage-p3', code: 'P3', probability: 25),
            ]);
        when(mockMasterDataSource.getPipelineStatusesByStage('stage-p3'))
            .thenAnswer((_) async => [_createTestDbStatus(stageId: 'stage-p3')]);
        when(mockLocalDataSource.updatePipeline(any))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.updatePipelineStage(pipelineId, dto);

        // Assert
        expect(result.isRight(), true);
        
        // Verify sync queue has the update
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.entityType, 'pipeline');
        expect(trackingQueueDataSource.items.first.operation, 'update');
        expect(trackingQueueDataSource.items.first.entityId, pipelineId);
      });

      test('updating to Won stage requires finalPremium', () async {
        // Arrange
        const pipelineId = 'pipeline-123';
        final dto = PipelineStageUpdateDto(
          stageId: 'stage-won',
          finalPremium: 95000000,
          policyNumber: 'POL-001',
        );

        when(mockLocalDataSource.getPipelineById(pipelineId))
            .thenAnswer((_) async => _createTestDbPipeline(id: pipelineId));
        when(mockMasterDataSource.getAllPipelineStages())
            .thenAnswer((_) async => [
              _createTestDbStage(id: 'stage-new', code: 'NEW'),
              _createTestDbStage(
                id: 'stage-won',
                code: 'WON',
                isFinal: true,
                isWon: true,
                probability: 100,
              ),
            ]);
        when(mockMasterDataSource.getPipelineStatusesByStage('stage-won'))
            .thenAnswer((_) async => [
              _createTestDbStatus(stageId: 'stage-won', code: 'CLOSED'),
            ]);
        when(mockLocalDataSource.updatePipeline(any))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.updatePipelineStage(pipelineId, dto);

        // Assert
        expect(result.isRight(), true);
        expect(trackingQueueDataSource.items.length, 1);
      });
    });

    group('Update Pipeline Status Flow', () {
      test('updating pipeline status queues for sync', () async {
        // Arrange
        const pipelineId = 'pipeline-123';
        final dto = PipelineStatusUpdateDto(
          statusId: 'status-2',
        );

        when(mockLocalDataSource.getPipelineById(pipelineId))
            .thenAnswer((_) async => _createTestDbPipeline(id: pipelineId));
        when(mockLocalDataSource.updatePipeline(any))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.updatePipelineStatus(pipelineId, dto);

        // Assert
        expect(result.isRight(), true);
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.operation, 'update');
      });
    });

    group('Delete Pipeline Flow', () {
      test('deleting a pipeline queues for sync', () async {
        // Arrange
        const pipelineId = 'pipeline-to-delete';

        when(mockLocalDataSource.getPipelineById(pipelineId))
            .thenAnswer((_) async => _createTestDbPipeline(id: pipelineId));
        when(mockLocalDataSource.softDeletePipeline(pipelineId))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.deletePipeline(pipelineId);

        // Assert
        expect(result.isRight(), true);
        
        // Verify delete is queued
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.operation, 'delete');
      });
    });
  });
}

/// Helper to create a test database pipeline record.
Pipeline _createTestDbPipeline({
  String id = 'pipeline-1',
  String code = 'PIP12345678',
  String customerId = 'customer-1',
  String stageId = 'stage-new',
  String statusId = 'status-1',
  String cobId = 'cob-1',
  String lobId = 'lob-1',
  String leadSourceId = 'source-1',
  double potentialPremium = 100000000,
  bool isPendingSync = false,
}) {
  return Pipeline(
    id: id,
    code: code,
    customerId: customerId,
    stageId: stageId,
    statusId: statusId,
    cobId: cobId,
    lobId: lobId,
    leadSourceId: leadSourceId,
    assignedRmId: 'test-user-id',
    createdBy: 'test-user-id',
    potentialPremium: potentialPremium,
    weightedValue: potentialPremium * 0.1,
    isPendingSync: isPendingSync,
    isTender: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    brokerId: null,
    brokerPicId: null,
    customerContactId: null,
    tsi: null,
    finalPremium: null,
    expectedCloseDate: null,
    policyNumber: null,
    declineReason: null,
    notes: null,
    referredByUserId: null,
    referralId: null,
    closedAt: null,
    deletedAt: null,
    lastSyncAt: null,
  );
}

/// Helper to create a test pipeline stage.
PipelineStage _createTestDbStage({
  String id = 'stage-new',
  String code = 'NEW',
  String name = 'New',
  int probability = 10,
  int sequence = 1,
  bool isFinal = false,
  bool isWon = false,
}) {
  return PipelineStage(
    id: id,
    code: code,
    name: name,
    probability: probability,
    sequence: sequence,
    isFinal: isFinal,
    isWon: isWon,
    isActive: true,
    color: '#4CAF50',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: null,
  );
}

/// Helper to create a test pipeline status.
PipelineStatuse _createTestDbStatus({
  String id = 'status-1',
  String stageId = 'stage-new',
  String code = 'INITIAL',
  String name = 'Initial Contact',
  int sequence = 1,
  bool isDefault = true,
}) {
  return PipelineStatuse(
    id: id,
    stageId: stageId,
    code: code,
    name: name,
    sequence: sequence,
    isDefault: isDefault,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    description: null,
  );
}
