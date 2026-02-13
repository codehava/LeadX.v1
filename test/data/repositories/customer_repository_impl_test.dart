import 'dart:async';

import 'package:dartz/dartz.dart';
// Hide drift's isNull/isNotNull to avoid conflict with flutter_test matchers
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:leadx_crm/core/errors/failures.dart';
import 'package:leadx_crm/data/database/app_database.dart' as db;
import 'package:leadx_crm/data/datasources/local/customer_local_data_source.dart';
import 'package:leadx_crm/data/datasources/local/key_person_local_data_source.dart';
import 'package:leadx_crm/data/datasources/remote/customer_remote_data_source.dart';
import 'package:leadx_crm/data/dtos/customer_dtos.dart';
import 'package:leadx_crm/data/repositories/customer_repository_impl.dart';
import 'package:leadx_crm/data/services/sync_service.dart';
import 'package:leadx_crm/domain/entities/sync_models.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  CustomerLocalDataSource,
  KeyPersonLocalDataSource,
  CustomerRemoteDataSource,
  KeyPersonRemoteDataSource,
  SyncService,
  db.AppDatabase,
])
import 'customer_repository_impl_test.mocks.dart';

/// Helper to create a test SyncResult
SyncResult createTestSyncResult({
  bool success = true,
  int processedCount = 1,
  int successCount = 1,
  int failedCount = 0,
}) {
  return SyncResult(
    success: success,
    processedCount: processedCount,
    successCount: successCount,
    failedCount: failedCount,
    errors: [],
    syncedAt: DateTime.now(),
  );
}

void main() {
  late CustomerRepositoryImpl repository;
  late MockCustomerLocalDataSource mockLocalDataSource;
  late MockKeyPersonLocalDataSource mockKeyPersonLocalDataSource;
  late MockCustomerRemoteDataSource mockRemoteDataSource;
  late MockKeyPersonRemoteDataSource mockKeyPersonRemoteDataSource;
  late MockSyncService mockSyncService;
  late MockAppDatabase mockDatabase;

  const testUserId = 'test-user-id';
  final testNow = DateTime(2026, 1, 21);

  // Sample test customer data from Drift
  db.Customer createTestDbCustomer({
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
    return db.Customer(
      id: id,
      code: code,
      name: name,
      address: address,
      provinceId: provinceId,
      cityId: cityId,
      postalCode: '12345',
      latitude: -6.175,
      longitude: 106.827,
      phone: '+6281234567890',
      email: 'test@company.com',
      website: 'www.company.com',
      companyTypeId: companyTypeId,
      ownershipTypeId: ownershipTypeId,
      industryId: industryId,
      npwp: '12.345.678.9-012.345',
      assignedRmId: assignedRmId,
      imageUrl: null,
      notes: 'Test notes',
      isActive: true,
      createdBy: testUserId,
      isPendingSync: isPendingSync,
      createdAt: testNow,
      updatedAt: testNow,
      deletedAt: null,
      lastSyncAt: null,
    );
  }

  CustomerCreateDto createTestDto({
    String name = 'Test Company',
    String address = '123 Test Street',
  }) {
    return CustomerCreateDto(
      name: name,
      address: address,
      provinceId: 'province-1',
      cityId: 'city-1',
      companyTypeId: 'type-1',
      ownershipTypeId: 'ownership-1',
      industryId: 'industry-1',
      assignedRmId: testUserId,
      phone: '+6281234567890',
      email: 'test@company.com',
    );
  }

  setUp(() {
    mockLocalDataSource = MockCustomerLocalDataSource();
    mockKeyPersonLocalDataSource = MockKeyPersonLocalDataSource();
    mockRemoteDataSource = MockCustomerRemoteDataSource();
    mockKeyPersonRemoteDataSource = MockKeyPersonRemoteDataSource();
    mockSyncService = MockSyncService();
    mockDatabase = MockAppDatabase();

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
      syncService: mockSyncService,
      currentUserId: testUserId,
      database: mockDatabase,
    );
  });

  group('CustomerRepositoryImpl', () {
    // ==========================================
    // CRUD Operations Tests
    // ==========================================

    group('getCustomerById', () {
      test('returns Customer when found', () async {
        // Arrange
        final testDbCustomer = createTestDbCustomer();
        when(mockLocalDataSource.getCustomerById('customer-1'))
            .thenAnswer((_) async => testDbCustomer);

        // Act
        final result = await repository.getCustomerById('customer-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'customer-1');
        expect(result.name, 'Test Company');
        expect(result.code, 'CUS12345678');
        verify(mockLocalDataSource.getCustomerById('customer-1')).called(1);
      });

      test('returns null when not found', () async {
        // Arrange
        when(mockLocalDataSource.getCustomerById('non-existent'))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCustomerById('non-existent');

        // Assert
        expect(result, isNull);
        verify(mockLocalDataSource.getCustomerById('non-existent')).called(1);
      });
    });

    group('createCustomer', () {
      test('returns Customer on successful create', () async {
        // Arrange
        final dto = createTestDto();
        final testDbCustomer = createTestDbCustomer(isPendingSync: true);

        when(mockLocalDataSource.insertCustomer(any)).thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createTestSyncResult());
        when(mockLocalDataSource.getCustomerById(any))
            .thenAnswer((_) async => testDbCustomer);

        // Act
        final result = await repository.createCustomer(dto);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (customer) {
            expect(customer.name, 'Test Company');
            expect(customer.address, '123 Test Street');
          },
        );
        verify(mockLocalDataSource.insertCustomer(any)).called(1);
        verify(mockSyncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: anyNamed('entityId'),
          operation: SyncOperation.create,
          payload: anyNamed('payload'),
        )).called(1);
        verify(mockSyncService.triggerSync()).called(1);
      });

      test('returns DatabaseFailure when insert fails', () async {
        // Arrange
        final dto = createTestDto();
        when(mockLocalDataSource.insertCustomer(any))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.createCustomer(dto);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('Failed to create customer'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('updateCustomer', () {
      test('returns updated Customer on success', () async {
        // Arrange
        const id = 'customer-1';
        final dto = const CustomerUpdateDto(name: 'Updated Company');
        final updatedDbCustomer = createTestDbCustomer(
          name: 'Updated Company',
          isPendingSync: true,
        );

        when(mockLocalDataSource.updateCustomer(id, any))
            .thenAnswer((_) async {});
        when(mockLocalDataSource.getCustomerById(id))
            .thenAnswer((_) async => updatedDbCustomer);
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createTestSyncResult());

        // Act
        final result = await repository.updateCustomer(id, dto);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (customer) {
            expect(customer.name, 'Updated Company');
          },
        );
        verify(mockLocalDataSource.updateCustomer(id, any)).called(1);
        verify(mockSyncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: id,
          operation: SyncOperation.update,
          payload: anyNamed('payload'),
        )).called(1);
      });

      test('returns NotFoundFailure when customer not found', () async {
        // Arrange
        const id = 'non-existent';
        final dto = const CustomerUpdateDto(name: 'Updated Company');

        when(mockLocalDataSource.updateCustomer(id, any))
            .thenAnswer((_) async {});
        when(mockLocalDataSource.getCustomerById(id))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.updateCustomer(id, dto);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NotFoundFailure>());
            expect(failure.message, contains('Customer not found'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('deleteCustomer', () {
      test('returns Right(null) on successful soft delete', () async {
        // Arrange
        const id = 'customer-1';
        when(mockLocalDataSource.softDeleteCustomer(id))
            .thenAnswer((_) async {});
        when(mockSyncService.queueOperation(
          entityType: anyNamed('entityType'),
          entityId: anyNamed('entityId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async => 1);
        when(mockSyncService.triggerSync())
            .thenAnswer((_) async => createTestSyncResult());

        // Act
        final result = await repository.deleteCustomer(id);

        // Assert
        expect(result.isRight(), true);
        verify(mockLocalDataSource.softDeleteCustomer(id)).called(1);
        verify(mockSyncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: id,
          operation: SyncOperation.delete,
          payload: anyNamed('payload'),
        )).called(1);
      });

      test('returns DatabaseFailure when delete fails', () async {
        // Arrange
        const id = 'customer-1';
        when(mockLocalDataSource.softDeleteCustomer(id))
            .thenThrow(Exception('Delete error'));

        // Act
        final result = await repository.deleteCustomer(id);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('Failed to delete customer'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    // ==========================================
    // Search Functionality Tests
    // ==========================================

    group('searchCustomers', () {
      test('returns list of matching customers', () async {
        // Arrange
        final customer1 = createTestDbCustomer(id: 'cust-1', name: 'ABC Corp');
        final customer2 = createTestDbCustomer(id: 'cust-2', name: 'ABC Inc');

        when(mockLocalDataSource.searchCustomers('ABC'))
            .thenAnswer((_) async => [customer1, customer2]);

        // Act
        final results = await repository.searchCustomers('ABC');

        // Assert
        expect(results.length, 2);
        expect(results[0].name, 'ABC Corp');
        expect(results[1].name, 'ABC Inc');
        verify(mockLocalDataSource.searchCustomers('ABC')).called(1);
      });

      test('returns empty list when no matches', () async {
        // Arrange
        when(mockLocalDataSource.searchCustomers('XYZ'))
            .thenAnswer((_) async => []);

        // Act
        final results = await repository.searchCustomers('XYZ');

        // Assert
        expect(results, isEmpty);
        verify(mockLocalDataSource.searchCustomers('XYZ')).called(1);
      });
    });

    group('getCustomersByAssignedRm', () {
      test('returns customers assigned to specific RM', () async {
        // Arrange
        final customer1 = createTestDbCustomer(
          id: 'cust-1',
          assignedRmId: 'rm-1',
        );
        final customer2 = createTestDbCustomer(
          id: 'cust-2',
          assignedRmId: 'rm-1',
        );

        when(mockLocalDataSource.getCustomersByAssignedRm('rm-1'))
            .thenAnswer((_) async => [customer1, customer2]);

        // Act
        final results = await repository.getCustomersByAssignedRm('rm-1');

        // Assert
        expect(results.length, 2);
        expect(results[0].assignedRmId, 'rm-1');
        verify(mockLocalDataSource.getCustomersByAssignedRm('rm-1')).called(1);
      });
    });

    // ==========================================
    // Offline Queue Behavior Tests
    // ==========================================

    group('getPendingSyncCustomers', () {
      test('returns customers pending sync', () async {
        // Arrange
        final customer1 = createTestDbCustomer(
          id: 'cust-1',
          isPendingSync: true,
        );
        final customer2 = createTestDbCustomer(
          id: 'cust-2',
          isPendingSync: true,
        );

        when(mockLocalDataSource.getPendingSyncCustomers())
            .thenAnswer((_) async => [customer1, customer2]);

        // Act
        final results = await repository.getPendingSyncCustomers();

        // Assert
        expect(results.length, 2);
        expect(results[0].isPendingSync, true);
        verify(mockLocalDataSource.getPendingSyncCustomers()).called(1);
      });
    });

    group('watchAllCustomers', () {
      test('returns stream of customers', () async {
        // Arrange
        final customer1 = createTestDbCustomer(id: 'cust-1');
        final customer2 = createTestDbCustomer(id: 'cust-2');

        when(mockLocalDataSource.watchAllCustomers()).thenAnswer(
          (_) => Stream.value([customer1, customer2]),
        );

        // Act
        final stream = repository.watchAllCustomers();
        final results = await stream.first;

        // Assert
        expect(results.length, 2);
        verify(mockLocalDataSource.watchAllCustomers()).called(1);
      });
    });

    // ==========================================
    // Sync From Remote Tests
    // ==========================================

    group('syncFromRemote', () {
      test('returns count of synced customers', () async {
        // Arrange
        final remoteData = [
          {
            'id': 'remote-1',
            'code': 'CUS001',
            'name': 'Remote Company',
            'address': '456 Remote St',
            'province_id': 'prov-1',
            'city_id': 'city-1',
            'company_type_id': 'type-1',
            'ownership_type_id': 'own-1',
            'industry_id': 'ind-1',
            'assigned_rm_id': 'rm-1',
            'created_by': 'user-1',
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          },
        ];

        when(mockRemoteDataSource.fetchCustomers(since: anyNamed('since')))
            .thenAnswer((_) async => remoteData);
        when(mockLocalDataSource.upsertCustomers(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.syncFromRemote();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (count) => expect(count, 1),
        );
        verify(mockRemoteDataSource.fetchCustomers(since: anyNamed('since')))
            .called(1);
        verify(mockLocalDataSource.upsertCustomers(any)).called(1);
      });

      test('returns 0 when no remote data', () async {
        // Arrange
        when(mockRemoteDataSource.fetchCustomers(since: anyNamed('since')))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.syncFromRemote();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right'),
          (count) => expect(count, 0),
        );
        verifyNever(mockLocalDataSource.upsertCustomers(any));
      });

      test('returns SyncFailure when fetch fails', () async {
        // Arrange
        when(mockRemoteDataSource.fetchCustomers(since: anyNamed('since')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.syncFromRemote();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<SyncFailure>());
            expect(
                failure.message, contains('Failed to sync customers from remote'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    // ==========================================
    // Mark As Synced Tests
    // ==========================================

    group('markAsSynced', () {
      test('calls local data source markAsSynced', () async {
        // Arrange
        final syncedAt = DateTime.now();
        when(mockLocalDataSource.markAsSynced('customer-1', syncedAt))
            .thenAnswer((_) async {});

        // Act
        await repository.markAsSynced('customer-1', syncedAt);

        // Assert
        verify(mockLocalDataSource.markAsSynced('customer-1', syncedAt))
            .called(1);
      });
    });
  });
}
