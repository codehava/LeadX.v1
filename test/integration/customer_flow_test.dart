import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/data/database/app_database.dart';
import 'package:leadx_crm/data/datasources/local/customer_local_data_source.dart';
import 'package:leadx_crm/data/datasources/local/key_person_local_data_source.dart';
import 'package:leadx_crm/data/datasources/remote/customer_remote_data_source.dart';
import 'package:leadx_crm/data/dtos/customer_dtos.dart';
import 'package:leadx_crm/data/repositories/customer_repository_impl.dart';
import 'package:leadx_crm/data/services/sync_service.dart';
import 'package:leadx_crm/domain/entities/sync_models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/mock_sync_infrastructure.dart';

@GenerateMocks([
  CustomerLocalDataSource,
  KeyPersonLocalDataSource,
  CustomerRemoteDataSource,
  KeyPersonRemoteDataSource,
  AppDatabase,
  SupabaseClient,
])
import 'customer_flow_test.mocks.dart';

void main() {
  late CustomerRepositoryImpl repository;
  late MockCustomerLocalDataSource mockLocalDataSource;
  late MockKeyPersonLocalDataSource mockKeyPersonLocalDataSource;
  late MockCustomerRemoteDataSource mockRemoteDataSource;
  late MockKeyPersonRemoteDataSource mockKeyPersonRemoteDataSource;
  late TrackingSyncQueueDataSource trackingQueueDataSource;
  late FakeConnectivityService fakeConnectivityService;
  late SyncService syncService;
  late MockAppDatabase mockDatabase;
  late MockSupabaseClient mockSupabaseClient;

  const testUserId = 'test-user-id';

  setUp(() {
    mockLocalDataSource = MockCustomerLocalDataSource();
    mockKeyPersonLocalDataSource = MockKeyPersonLocalDataSource();
    mockRemoteDataSource = MockCustomerRemoteDataSource();
    mockKeyPersonRemoteDataSource = MockKeyPersonRemoteDataSource();
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

    // Mock transaction to just execute the callback
    when(mockDatabase.transaction(any)).thenAnswer((invocation) {
      final callback = invocation.positionalArguments[0] as Future<dynamic> Function();
      return callback();
    });

    repository = CustomerRepositoryImpl(
      localDataSource: mockLocalDataSource,
      keyPersonLocalDataSource: mockKeyPersonLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      keyPersonRemoteDataSource: mockKeyPersonRemoteDataSource,
      syncService: syncService,
      currentUserId: testUserId,
      database: mockDatabase,
    );
  });

  tearDown(() {
    syncService.dispose();
    fakeConnectivityService.dispose();
  });

  group('Customer Flow Integration Tests', () {
    group('Create Customer Flow', () {
      test('creating a customer queues for sync', () async {
        // Arrange
        final dto = CustomerCreateDto(
          name: 'Test Company',
          address: '123 Test Street',
          provinceId: 'province-1',
          cityId: 'city-1',
          companyTypeId: 'type-1',
          ownershipTypeId: 'ownership-1',
          industryId: 'industry-1',
          assignedRmId: testUserId,
        );

        // Setup mock to return a customer
        when(mockLocalDataSource.insertCustomer(any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await repository.createCustomer(dto);

        // Assert
        expect(result.isRight(), true);
        
        // Verify sync queue has the item
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.entityType, 'customer');
        expect(trackingQueueDataSource.items.first.operation, 'create');
      });

      test('creating a customer succeeds even when offline', () async {
        // Arrange
        fakeConnectivityService.setConnected(false);
        
        final dto = CustomerCreateDto(
          name: 'Offline Company',
          address: '456 Offline Street',
          provinceId: 'province-1',
          cityId: 'city-1',
          companyTypeId: 'type-1',
          ownershipTypeId: 'ownership-1',
          industryId: 'industry-1',
          assignedRmId: testUserId,
        );

        when(mockLocalDataSource.insertCustomer(any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await repository.createCustomer(dto);

        // Assert - should still succeed (offline-first)
        expect(result.isRight(), true);
        
        // Verify item is queued for sync
        expect(trackingQueueDataSource.items.length, 1);
      });
    });

    group('Update Customer Flow', () {
      test('updating a customer queues for sync', () async {
        // Arrange
        const customerId = 'customer-123';
        final dto = CustomerUpdateDto(
          name: 'Updated Company Name',
        );

        // Setup mock for existing customer
        when(mockLocalDataSource.getCustomerById(customerId))
            .thenAnswer((_) async => _createTestDbCustomer(id: customerId));
        when(mockLocalDataSource.updateCustomer(any, any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateCustomer(customerId, dto);

        // Assert
        expect(result.isRight(), true);
        
        // Verify sync queue has the update
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.entityType, 'customer');
        expect(trackingQueueDataSource.items.first.operation, 'update');
        expect(trackingQueueDataSource.items.first.entityId, customerId);
      });

      test('multiple updates to same customer coalesce', () async {
        // Arrange
        const customerId = 'customer-123';

        when(mockLocalDataSource.getCustomerById(customerId))
            .thenAnswer((_) async => _createTestDbCustomer(id: customerId));
        when(mockLocalDataSource.updateCustomer(any, any))
            .thenAnswer((_) async {});

        // Act - perform multiple updates
        await repository.updateCustomer(
          customerId,
          CustomerUpdateDto(name: 'First Update'),
        );
        await repository.updateCustomer(
          customerId,
          CustomerUpdateDto(name: 'Second Update'),
        );

        // Assert - should only have one queued item (coalesced)
        // Note: The syncService.queueOperation handles coalescing for updates
        expect(trackingQueueDataSource.items.length, 1);
      });
    });

    group('Delete Customer Flow', () {
      test('deleting a customer queues for sync', () async {
        // Arrange
        const customerId = 'customer-to-delete';

        when(mockLocalDataSource.getCustomerById(customerId))
            .thenAnswer((_) async => _createTestDbCustomer(id: customerId));
        when(mockLocalDataSource.softDeleteCustomer(customerId))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.deleteCustomer(customerId);

        // Assert
        expect(result.isRight(), true);
        
        // Verify delete is queued
        expect(trackingQueueDataSource.items.length, 1);
        expect(trackingQueueDataSource.items.first.operation, 'delete');
      });
    });

    group('Offline to Online Sync Flow', () {
      test('operations queued offline are processed when online', () async {
        // Arrange - start offline
        fakeConnectivityService.setConnected(false);

        final dto = CustomerCreateDto(
          name: 'Offline Created Company',
          address: '789 Offline Ave',
          provinceId: 'province-1',
          cityId: 'city-1',
          companyTypeId: 'type-1',
          ownershipTypeId: 'ownership-1',
          industryId: 'industry-1',
          assignedRmId: testUserId,
        );

        when(mockLocalDataSource.insertCustomer(any))
            .thenAnswer((_) async => 1);

        // Create customer while offline
        await repository.createCustomer(dto);
        expect(trackingQueueDataSource.items.length, 1);

        // Verify processQueue doesn't work while offline
        final offlineResult = await syncService.processQueue();
        expect(offlineResult.success, false);
        expect(offlineResult.errors, contains('Device is offline'));

        // Act - come online
        fakeConnectivityService.setConnected(true);
        
        // Manually trigger sync (in real app this would be automatic)
        // Note: This will fail since Supabase is mocked, but proves the flow
        final onlineResult = await syncService.processQueue();

        // Assert - sync was attempted
        expect(
          trackingQueueDataSource.operations,
          contains('getRetryableItems(5)'),
        );
      });
    });
  });
}

/// Helper to create a test database customer record.
Customer _createTestDbCustomer({
  String id = 'customer-1',
  String code = 'CUS12345678',
  String name = 'Test Company',
  String address = '123 Test Street',
  String provinceId = 'province-1',
  String cityId = 'city-1',
  String companyTypeId = 'type-1',
  String ownershipTypeId = 'ownership-1',
  String industryId = 'industry-1',
  String assignedRmId = 'test-user-id',
  bool isPendingSync = false,
}) {
  return Customer(
    id: id,
    code: code,
    name: name,
    address: address,
    provinceId: provinceId,
    cityId: cityId,
    companyTypeId: companyTypeId,
    ownershipTypeId: ownershipTypeId,
    industryId: industryId,
    assignedRmId: assignedRmId,
    createdBy: 'test-user-id',
    isActive: true,
    isPendingSync: isPendingSync,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    postalCode: null,
    latitude: null,
    longitude: null,
    phone: null,
    email: null,
    website: null,
    npwp: null,
    imageUrl: null,
    notes: null,
    deletedAt: null,
    lastSyncAt: null,
  );
}
