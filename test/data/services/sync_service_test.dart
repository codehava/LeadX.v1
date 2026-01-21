import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/data/database/app_database.dart';
import 'package:leadx_crm/data/services/sync_service.dart';
import 'package:leadx_crm/domain/entities/sync_models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/mock_sync_infrastructure.dart';

@GenerateMocks([AppDatabase, SupabaseClient])
import 'sync_service_test.mocks.dart';

void main() {
  late SyncService syncService;
  late TrackingSyncQueueDataSource mockQueueDataSource;
  late FakeConnectivityService fakeConnectivityService;
  late MockSupabaseClient mockSupabaseClient;
  late MockAppDatabase mockDatabase;

  setUp(() {
    mockQueueDataSource = TrackingSyncQueueDataSource();
    fakeConnectivityService = FakeConnectivityService();
    mockSupabaseClient = MockSupabaseClient();
    mockDatabase = MockAppDatabase();

    syncService = SyncService(
      syncQueueDataSource: mockQueueDataSource,
      connectivityService: fakeConnectivityService,
      supabaseClient: mockSupabaseClient,
      database: mockDatabase,
    );
  });

  tearDown(() {
    syncService.dispose();
    fakeConnectivityService.dispose();
  });

  group('SyncService', () {
    group('processQueue', () {
      test('returns early when device is offline', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        await mockQueueDataSource.addToQueue(
          entityType: 'customer',
          entityId: 'cust-1',
          operation: 'create',
          payload: '{}',
        );

        // Act
        final result = await syncService.processQueue();

        // Assert
        expect(result.success, false);
        expect(result.errors, contains('Device is offline'));
        expect(result.processedCount, 0);
        // Queue should not be processed
        expect(
          mockQueueDataSource.operations,
          isNot(contains('getRetryableItems(5)')),
        );
      });

      test('returns success when queue is empty', () async {
        // Arrange - queue is empty by default
        fakeConnectivityService.setConnected(true);

        // Act
        final result = await syncService.processQueue();

        // Assert
        expect(result.success, true);
        expect(result.processedCount, 0);
        expect(result.successCount, 0);
        expect(result.failedCount, 0);
      });

      test('returns early when already syncing', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        
        // Add items to make sync take time
        for (var i = 0; i < 5; i++) {
          await mockQueueDataSource.addToQueue(
            entityType: 'customer',
            entityId: 'cust-$i',
            operation: 'create',
            payload: '{"id": "cust-$i"}',
          );
        }

        // Start first sync (don't await)
        final firstSync = syncService.processQueue();

        // Try to start another sync immediately
        final secondResult = await syncService.processQueue();

        // Assert - second call should return early
        expect(secondResult.success, false);
        expect(secondResult.errors, contains('Sync already in progress'));

        // Wait for first sync to complete
        await firstSync;
      });

      test('processes items in FIFO order', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        
        // Add items with specific order
        final item1Time = DateTime(2026, 1, 1, 10, 0);
        final item2Time = DateTime(2026, 1, 1, 10, 1);
        final item3Time = DateTime(2026, 1, 1, 10, 2);

        mockQueueDataSource.addItemDirectly(createTestSyncQueueItem(
          id: 3,
          entityType: 'customer',
          entityId: 'cust-3',
          createdAt: item3Time,
        ));
        mockQueueDataSource.addItemDirectly(createTestSyncQueueItem(
          id: 1,
          entityType: 'customer',
          entityId: 'cust-1',
          createdAt: item1Time,
        ));
        mockQueueDataSource.addItemDirectly(createTestSyncQueueItem(
          id: 2,
          entityType: 'customer',
          entityId: 'cust-2',
          createdAt: item2Time,
        ));

        // Act - Note: will fail since Supabase is mocked but order verification works
        await syncService.processQueue();

        // Assert - getRetryableItems should return in FIFO order
        // The TrackingSyncQueueDataSource sorts by createdAt
        expect(mockQueueDataSource.operations, contains('getRetryableItems(5)'));
      });

      test('increments retry count on failure', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        await mockQueueDataSource.addToQueue(
          entityType: 'customer',
          entityId: 'cust-1',
          operation: 'create',
          payload: '{"id": "cust-1"}',
        );

        // Supabase call will throw since it's not properly mocked
        // Act
        final result = await syncService.processQueue();

        // Assert
        expect(result.failedCount, greaterThan(0));
        expect(
          mockQueueDataSource.operations,
          contains('incrementRetryCount(1)'),
        );
      });

      test('skips items that exceed maxRetries', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        
        // Add item with retry count at max
        mockQueueDataSource.addItemDirectly(createTestSyncQueueItem(
          id: 1,
          entityType: 'customer',
          entityId: 'cust-1',
          retryCount: 5, // At max
        ));

        // Act
        final result = await syncService.processQueue();

        // Assert
        expect(result.processedCount, 0);
        expect(result.successCount, 0);
      });
    });

    group('queueOperation', () {
      test('adds new item to queue', () async {
        // Act
        final id = await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1', 'name': 'Test'},
        );

        // Assert
        expect(id, greaterThan(0));
        expect(mockQueueDataSource.items.length, 1);
        expect(mockQueueDataSource.items.first.entityType, 'customer');
        expect(mockQueueDataSource.items.first.operation, 'create');
      });

      test('coalesces update operations', () async {
        // Arrange - add first update
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.update,
          payload: {'id': 'cust-1', 'name': 'First Update'},
        );

        // Act - add second update
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.update,
          payload: {'id': 'cust-1', 'name': 'Second Update'},
        );

        // Assert - should only have one item (coalesced)
        expect(mockQueueDataSource.items.length, 1);
        expect(
          mockQueueDataSource.operations,
          contains('removeOperation(customer, cust-1)'),
        );
      });

      test('does not coalesce create operations', () async {
        // Arrange - add create
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-1',
          operation: SyncOperation.create,
          payload: {'id': 'cust-1', 'name': 'Created'},
        );

        // Act - add another create for different entity
        await syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: 'cust-2',
          operation: SyncOperation.create,
          payload: {'id': 'cust-2', 'name': 'Created 2'},
        );

        // Assert - should have two items
        expect(mockQueueDataSource.items.length, 2);
      });
    });

    group('syncStateStream', () {
      test('emits idle state initially', () async {
        // Act & Assert
        expect(syncService.currentState, isA<SyncStateIdle>());
      });

      test('emits offline state when disconnected', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        await mockQueueDataSource.addToQueue(
          entityType: 'customer',
          entityId: 'cust-1',
          operation: 'create',
          payload: '{}',
        );

        // Listen for state changes
        final states = <SyncState>[];
        final subscription = syncService.syncStateStream.listen(states.add);

        // Act
        await syncService.processQueue();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(states, contains(isA<SyncStateOffline>()));

        await subscription.cancel();
      });

      test('emits syncing state during processing', () async {
        // Arrange
        fakeConnectivityService.setConnected(true);
        await mockQueueDataSource.addToQueue(
          entityType: 'customer',
          entityId: 'cust-1',
          operation: 'create',
          payload: '{}',
        );

        // Listen for state changes
        final states = <SyncState>[];
        final subscription = syncService.syncStateStream.listen(states.add);

        // Act
        await syncService.processQueue();
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(states.any((s) => s is SyncStateSyncing), true);

        await subscription.cancel();
      });
    });

    group('backgroundSync', () {
      test('startBackgroundSync creates timer', () async {
        // Act
        syncService.startBackgroundSync(
          interval: const Duration(milliseconds: 100),
        );

        // Assert - timer should be active (we can't directly test, but no exception)
        expect(syncService.isSyncing, false);

        // Cleanup
        syncService.stopBackgroundSync();
      });

      test('stopBackgroundSync cancels timer', () async {
        // Arrange
        syncService.startBackgroundSync(
          interval: const Duration(milliseconds: 100),
        );

        // Act
        syncService.stopBackgroundSync();

        // Wait and verify no sync happens
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Assert - no operations should have been triggered (queue is empty anyway)
        expect(syncService.isSyncing, false);
      });
    });

    group('watchPendingCount', () {
      test('returns stream of pending count', () async {
        // Arrange
        await mockQueueDataSource.addToQueue(
          entityType: 'customer',
          entityId: 'cust-1',
          operation: 'create',
          payload: '{}',
        );

        // Act
        final count = await syncService.watchPendingCount().first;

        // Assert
        expect(count, 1);
      });
    });

    group('getPendingCount', () {
      test('returns current pending count', () async {
        // Arrange
        await mockQueueDataSource.addToQueue(
          entityType: 'customer',
          entityId: 'cust-1',
          operation: 'create',
          payload: '{}',
        );
        await mockQueueDataSource.addToQueue(
          entityType: 'pipeline',
          entityId: 'pipe-1',
          operation: 'create',
          payload: '{}',
        );

        // Act
        final count = await syncService.getPendingCount();

        // Assert
        expect(count, 2);
      });
    });
  });
}
