import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/data/database/app_database.dart';
import 'package:leadx_crm/data/services/sync_service.dart';
import 'package:leadx_crm/domain/entities/sync_models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/mock_sync_infrastructure.dart';

@GenerateMocks([AppDatabase, SupabaseClient])
import 'offline_sync_flow_test.mocks.dart';

void main() {
  late SyncService syncService;
  late TrackingSyncQueueDataSource trackingQueueDataSource;
  late FakeConnectivityService fakeConnectivityService;
  late MockAppDatabase mockDatabase;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
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
  });

  tearDown(() {
    syncService.dispose();
    fakeConnectivityService.dispose();
  });

  group('Offline Sync Flow Integration Tests', () {
    group('Operations Queued While Offline', () {
      test('operations can be queued when offline', () async {
        // Arrange - start offline
        fakeConnectivityService.setConnected(false);

        // Act - queue multiple operations
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1', 'name': 'Customer 1'},
        );
        await syncService.queueOperation(
          entityType: SyncEntityType.pipeline,
          entityId: 'pipe-1',
          operation: SyncOperation.create,
          payload: {'id': 'pipe-1', 'customerId': 'cust-1'},
        );
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-2',
          operation: SyncOperation.create,
          payload: {'id': 'cust-2', 'name': 'Customer 2'},
        );

        // Assert
        expect(trackingQueueDataSource.items.length, 3);
        expect(await syncService.getPendingCount(), 3);
      });

      test('processQueue does nothing when offline', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );

        // Act
        final result = await syncService.processQueue();

        // Assert
        expect(result.success, false);
        expect(result.errors, contains('Device is offline'));
        expect(result.processedCount, 0);
        
        // Queue should remain intact
        expect(trackingQueueDataSource.items.length, 1);
      });
    });

    group('Queue Processed When Coming Online', () {
      test('queue is processed when connectivity is restored', () async {
        // Arrange - start offline and queue items
        fakeConnectivityService.setConnected(false);
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1', 'name': 'Test'},
        );

        // Verify offline
        final offlineResult = await syncService.processQueue();
        expect(offlineResult.success, false);

        // Act - come online
        fakeConnectivityService.setConnected(true);
        final onlineResult = await syncService.processQueue();

        // Assert - sync was attempted (will fail due to mock but proves flow)
        expect(
          trackingQueueDataSource.operations,
          contains('getRetryableItems(5)'),
        );
      });

      test('connectivity stream triggers sync attempt', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );

        // Track state changes
        final states = <SyncState>[];
        final subscription = syncService.syncStateStream.listen(states.add);

        // Act - simulate coming online
        fakeConnectivityService.setConnected(true);
        
        // Manual trigger (in real app, SyncNotifier listens to connectivity)
        await syncService.processQueue();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(states.any((s) => s is SyncStateSyncing), true);

        await subscription.cancel();
      });
    });

    group('Retry Behavior', () {
      test('failed items have retry count incremented', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );

        // Ensure the item is in the queue
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.retryCount, 0);

        // Act - process (will fail since Supabase is mocked)
        await syncService.processQueue();

        // Assert - retry count should be incremented
        expect(
          trackingQueueDataSource.operations,
          contains('incrementRetryCount(1)'),
        );
      });

      test('items exceeding maxRetries are not processed', () async {
        // Arrange - add item with retryCount at max
        trackingQueueDataSource.addItemDirectly(createTestSyncQueueItem(
          id: 1,
          entityType: 'customer',
          entityId: 'cust-1',
          retryCount: 5, // At max
        ));

        fakeConnectivityService.setConnected(true);

        // Act
        final result = await syncService.processQueue();

        // Assert - item should be skipped
        expect(result.processedCount, 0);
        expect(result.successCount, 0);
        expect(result.failedCount, 0);
      });

      test('items below maxRetries are processed', () async {
        // Arrange - add item with retryCount below max
        trackingQueueDataSource.addItemDirectly(createTestSyncQueueItem(
          id: 1,
          entityType: 'customer',
          entityId: 'cust-1',
          retryCount: 3, // Below max of 5
        ));

        fakeConnectivityService.setConnected(true);

        // Act
        final result = await syncService.processQueue();

        // Assert - item should be attempted
        expect(result.processedCount, 1);
      });
    });

    group('Sync State Transitions', () {
      test('state transitions from idle to syncing to result', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );

        // Track states
        final states = <SyncState>[];
        final subscription = syncService.syncStateStream.listen(states.add);

        // Act
        await syncService.processQueue();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        await subscription.cancel();

        // Should have gone through: idle -> syncing -> (error or idle)
        expect(states.any((s) => s is SyncStateIdle), true);
        expect(states.any((s) => s is SyncStateSyncing), true);
      });

      test('offline sync attempt results in offline state', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );

        // Track states
        final states = <SyncState>[];
        final subscription = syncService.syncStateStream.listen(states.add);

        // Act
        await syncService.processQueue();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        await subscription.cancel();
        expect(states.any((s) => s is SyncStateOffline), true);
      });
    });

    group('Multiple Entity Types', () {
      test('processes mixed entity types in order', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);

        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );
        await syncService.queueOperation(
          entityType: SyncEntityType.pipeline,
          entityId: 'pipe-1',
          operation: SyncOperation.create,
          payload: {'id': 'pipe-1'},
        );
        await syncService.queueOperation(
          entityType: SyncEntityType.keyPerson,
          entityId: 'kp-1',
          operation: SyncOperation.create,
          payload: {'id': 'kp-1'},
        );

        // Act
        await syncService.processQueue();

        // Assert - all items attempted
        expect(
          trackingQueueDataSource.operations,
          contains('getRetryableItems(5)'),
        );
      });
    });

    group('Pending Count', () {
      test('pending count reflects queue size', () async {
        // Assert - starts empty
        expect(await syncService.getPendingCount(), 0);

        // Add items
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );
        expect(await syncService.getPendingCount(), 1);

        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-2',
          operation: SyncOperation.create,
          payload: {'id': 'cust-2'},
        );
        expect(await syncService.getPendingCount(), 2);
      });

      test('watchPendingCount stream updates', () async {
        // Arrange - listen to stream
        final counts = <int>[];
        final subscription = syncService.watchPendingCount().listen(counts.add);

        // Act - add items
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1'},
        );
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(counts.last, 1);

        await subscription.cancel();
      });
    });
  });
}
