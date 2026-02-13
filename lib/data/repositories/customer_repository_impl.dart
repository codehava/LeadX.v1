import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/customer_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/customer_local_data_source.dart';
import '../datasources/local/key_person_local_data_source.dart';
import '../datasources/remote/customer_remote_data_source.dart';
import '../../core/logging/app_logger.dart';
import '../dtos/customer_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of CustomerRepository with offline-first pattern.
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl({
    required CustomerLocalDataSource localDataSource,
    required KeyPersonLocalDataSource keyPersonLocalDataSource,
    required CustomerRemoteDataSource remoteDataSource,
    required KeyPersonRemoteDataSource keyPersonRemoteDataSource,
    required SyncService syncService,
    required String currentUserId,
  })  : _localDataSource = localDataSource,
        _keyPersonLocalDataSource = keyPersonLocalDataSource,
        _remoteDataSource = remoteDataSource,
        _keyPersonRemoteDataSource = keyPersonRemoteDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId;

  final CustomerLocalDataSource _localDataSource;
  final KeyPersonLocalDataSource _keyPersonLocalDataSource;
  final CustomerRemoteDataSource _remoteDataSource;
  final KeyPersonRemoteDataSource _keyPersonRemoteDataSource;
  final SyncService _syncService;
  final String _currentUserId;
  final _log = AppLogger.instance;

  static const _uuid = Uuid();


  // ==========================================
  // Customer CRUD Operations
  // ==========================================

  @override
  Stream<List<domain.Customer>> watchAllCustomers() =>
      _localDataSource.watchAllCustomers().map(
            (customers) => customers.map(_mapToCustomer).toList(),
          );

  @override
  Stream<List<domain.Customer>> watchCustomersPaginated({
    required int limit,
    String? searchQuery,
  }) =>
      _localDataSource
          .watchCustomersPaginated(limit: limit, searchQuery: searchQuery)
          .map((customers) => customers.map(_mapToCustomer).toList());

  @override
  Future<int> getCustomerCount({String? searchQuery}) =>
      _localDataSource.getCustomerCount(searchQuery: searchQuery);

  @override
  Stream<domain.Customer?> watchCustomerById(String id) =>
      _localDataSource.watchCustomerById(id).map(
            (data) => data != null ? _mapToCustomer(data) : null,
          );

  @override
  Future<domain.Customer?> getCustomerById(String id) async {
    final data = await _localDataSource.getCustomerById(id);
    return data != null ? _mapToCustomer(data) : null;
  }

  @override
  Future<Either<Failure, domain.Customer>> createCustomer(
    CustomerCreateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();
      final code = _generateCustomerCode();

      final companion = db.CustomersCompanion.insert(
        id: id,
        code: code,
        name: dto.name,
        address: dto.address ?? '',
        provinceId: dto.provinceId,
        cityId: dto.cityId,
        postalCode: Value(dto.postalCode),
        latitude: Value(dto.latitude),
        longitude: Value(dto.longitude),
        phone: Value(dto.phone),
        email: Value(dto.email),
        website: Value(dto.website),
        companyTypeId: dto.companyTypeId,
        ownershipTypeId: dto.ownershipTypeId,
        industryId: dto.industryId,
        npwp: Value(dto.npwp),
        assignedRmId: dto.assignedRmId.isNotEmpty ? dto.assignedRmId : _currentUserId,
        imageUrl: Value(dto.imageUrl),
        notes: Value(dto.notes),
        createdBy: _currentUserId,
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Save locally first
      _log.debug('customer | Inserting customer locally: $id');
      await _localDataSource.insertCustomer(companion);

      // Queue for sync
      _log.debug('customer | Queueing customer for sync: $id');
      await _syncService.queueOperation(
        entityType: SyncEntityType.customer,
        entityId: id,
        operation: SyncOperation.create,
        payload: _createSyncPayload(id, code, dto, now),
      );
      _log.debug('customer | Customer queued successfully');

      // Trigger sync to upload immediately
      unawaited(_syncService.triggerSync());

      // Return the created customer
      final customer = await getCustomerById(id);
      return Right(customer!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to create customer: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.Customer>> updateCustomer(
    String id,
    CustomerUpdateDto dto,
  ) async {
    try {
      final now = DateTime.now();

      final companion = db.CustomersCompanion(
        name: dto.name != null ? Value(dto.name!) : const Value.absent(),
        address:
            dto.address != null ? Value(dto.address!) : const Value.absent(),
        provinceId: dto.provinceId != null
            ? Value(dto.provinceId!)
            : const Value.absent(),
        cityId:
            dto.cityId != null ? Value(dto.cityId!) : const Value.absent(),
        postalCode:
            dto.postalCode != null ? Value(dto.postalCode) : const Value.absent(),
        latitude:
            dto.latitude != null ? Value(dto.latitude) : const Value.absent(),
        longitude:
            dto.longitude != null ? Value(dto.longitude) : const Value.absent(),
        phone: dto.phone != null ? Value(dto.phone) : const Value.absent(),
        email: dto.email != null ? Value(dto.email) : const Value.absent(),
        website:
            dto.website != null ? Value(dto.website) : const Value.absent(),
        companyTypeId: dto.companyTypeId != null
            ? Value(dto.companyTypeId!)
            : const Value.absent(),
        ownershipTypeId: dto.ownershipTypeId != null
            ? Value(dto.ownershipTypeId!)
            : const Value.absent(),
        industryId: dto.industryId != null
            ? Value(dto.industryId!)
            : const Value.absent(),
        npwp: dto.npwp != null ? Value(dto.npwp) : const Value.absent(),
        assignedRmId: dto.assignedRmId != null
            ? Value(dto.assignedRmId!)
            : const Value.absent(),
        imageUrl:
            dto.imageUrl != null ? Value(dto.imageUrl) : const Value.absent(),
        notes: dto.notes != null ? Value(dto.notes) : const Value.absent(),
        isActive:
            dto.isActive != null ? Value(dto.isActive!) : const Value.absent(),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally first
      await _localDataSource.updateCustomer(id, companion);

      // Get updated data for sync payload
      final updated = await _localDataSource.getCustomerById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'Customer not found: $id'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.customer,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createUpdateSyncPayload(updated),
      );

      // Trigger sync to upload immediately
      unawaited(_syncService.triggerSync());

      return Right(_mapToCustomer(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update customer: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      // Soft delete locally
      await _localDataSource.softDeleteCustomer(id);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.customer,
        entityId: id,
        operation: SyncOperation.delete,
        payload: {'id': id},
      );

      // Trigger sync to upload immediately
      unawaited(_syncService.triggerSync());

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete customer: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Search & Filter
  // ==========================================

  @override
  Future<List<domain.Customer>> searchCustomers(String query) async {
    final results = await _localDataSource.searchCustomers(query);
    return results.map(_mapToCustomer).toList();
  }

  @override
  Future<List<domain.Customer>> getCustomersByAssignedRm(String rmId) async {
    final results = await _localDataSource.getCustomersByAssignedRm(rmId);
    return results.map(_mapToCustomer).toList();
  }

  @override
  Future<List<domain.Customer>> getPendingSyncCustomers() async {
    final results = await _localDataSource.getPendingSyncCustomers();
    return results.map(_mapToCustomer).toList();
  }

  // ==========================================
  // Key Person Operations
  // ==========================================

  @override
  Future<List<domain.KeyPerson>> getCustomerKeyPersons(
    String customerId,
  ) async {
    final results =
        await _keyPersonLocalDataSource.getKeyPersonsByCustomer(customerId);
    return results.map(_mapToKeyPerson).toList();
  }

  @override
  Stream<List<domain.KeyPerson>> watchCustomerKeyPersons(String customerId) =>
      _keyPersonLocalDataSource.watchKeyPersonsByCustomer(customerId).map(
            (keyPersons) => keyPersons.map(_mapToKeyPerson).toList(),
          );

  @override
  Stream<domain.KeyPerson?> watchPrimaryKeyPerson(String customerId) =>
      _keyPersonLocalDataSource.watchPrimaryKeyPerson(customerId).map(
            (data) => data != null ? _mapToKeyPerson(data) : null,
          );

  @override
  Future<Either<Failure, domain.KeyPerson>> addKeyPerson(
    KeyPersonDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();

      final companion = db.KeyPersonsCompanion.insert(
        id: id,
        ownerType: dto.ownerType,
        customerId: Value(dto.customerId),
        brokerId: Value(dto.brokerId),
        hvcId: Value(dto.hvcId),
        name: dto.name,
        position: Value(dto.position),
        department: Value(dto.department),
        phone: Value(dto.phone),
        email: Value(dto.email),
        isPrimary: Value(dto.isPrimary),
        notes: Value(dto.notes),
        createdBy: _currentUserId,
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // If setting as primary, clear other primaries first
      if (dto.isPrimary && dto.customerId != null) {
        await _keyPersonLocalDataSource.clearPrimaryForCustomer(dto.customerId!);
      }

      // Save locally
      await _keyPersonLocalDataSource.insertKeyPerson(companion);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.keyPerson,
        entityId: id,
        operation: SyncOperation.create,
        payload: _createKeyPersonSyncPayload(id, dto, now),
      );

      // Trigger sync to upload immediately
      unawaited(_syncService.triggerSync());

      final keyPerson = await _keyPersonLocalDataSource.getKeyPersonById(id);
      return Right(_mapToKeyPerson(keyPerson!));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to add key person: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.KeyPerson>> updateKeyPerson(
    String id,
    KeyPersonDto dto,
  ) async {
    try {
      final now = DateTime.now();

      // If setting as primary, clear other primaries first
      if (dto.isPrimary && dto.customerId != null) {
        await _keyPersonLocalDataSource.clearPrimaryForCustomer(dto.customerId!);
      }

      final companion = db.KeyPersonsCompanion(
        name: Value(dto.name),
        position: Value(dto.position),
        department: Value(dto.department),
        phone: Value(dto.phone),
        email: Value(dto.email),
        isPrimary: Value(dto.isPrimary),
        notes: Value(dto.notes),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      await _keyPersonLocalDataSource.updateKeyPerson(id, companion);

      // Queue for sync
      final updated = await _keyPersonLocalDataSource.getKeyPersonById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'Key person not found: $id'));
      }

      await _syncService.queueOperation(
        entityType: SyncEntityType.keyPerson,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createKeyPersonUpdateSyncPayload(updated),
      );

      // Trigger sync to upload immediately
      unawaited(_syncService.triggerSync());

      return Right(_mapToKeyPerson(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update key person: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteKeyPerson(String id) async {
    try {
      await _keyPersonLocalDataSource.softDeleteKeyPerson(id);

      await _syncService.queueOperation(
        entityType: SyncEntityType.keyPerson,
        entityId: id,
        operation: SyncOperation.delete,
        payload: {'id': id},
      );

      // Trigger sync to upload immediately
      unawaited(_syncService.triggerSync());

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete key person: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<domain.KeyPerson?> getPrimaryKeyPerson(String customerId) async {
    final data =
        await _keyPersonLocalDataSource.getPrimaryKeyPerson(customerId);
    return data != null ? _mapToKeyPerson(data) : null;
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  @override
  Future<Either<Failure, int>> syncFromRemote({DateTime? since}) async {
    try {
      _log.debug('customer | syncFromRemote called, currentUserId=$_currentUserId, since=$since');
      final remoteData = await _remoteDataSource.fetchCustomers(since: since);
      _log.debug('customer | fetchCustomers returned ${remoteData.length} records');

      if (remoteData.isEmpty) {
        _log.debug('customer | No customers returned from remote - check RLS policies if unexpected');
        return const Right(0);
      }

      final companions = remoteData.map((data) {
        // Handle potentially null fields - some customers may have null values
        // for fields that are required locally, so we provide empty defaults
        return db.CustomersCompanion(
          id: Value(data['id'] as String),
          code: Value(data['code'] as String),
          name: Value(data['name'] as String? ?? ''),
          address: Value(data['address'] as String? ?? ''),
          provinceId: Value(data['province_id'] as String? ?? ''),
          cityId: Value(data['city_id'] as String? ?? ''),
          postalCode: Value(data['postal_code'] as String?),
          latitude: Value((data['latitude'] as num?)?.toDouble()),
          longitude: Value((data['longitude'] as num?)?.toDouble()),
          phone: Value(data['phone'] as String?),
          email: Value(data['email'] as String?),
          website: Value(data['website'] as String?),
          companyTypeId: Value(data['company_type_id'] as String? ?? ''),
          ownershipTypeId: Value(data['ownership_type_id'] as String? ?? ''),
          industryId: Value(data['industry_id'] as String? ?? ''),
          npwp: Value(data['npwp'] as String?),
          assignedRmId: Value(data['assigned_rm_id'] as String? ?? ''),
          imageUrl: Value(data['image_url'] as String?),
          notes: Value(data['notes'] as String?),
          isActive: Value(data['is_active'] as bool? ?? true),
          createdBy: Value(data['created_by'] as String? ?? ''),
          isPendingSync: const Value(false),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          updatedAt: Value(DateTime.parse(data['updated_at'] as String)),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
          lastSyncAt: Value(DateTime.now()),
        );
      }).toList();

      await _localDataSource.upsertCustomers(companions);

      return Right(companions.length);
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to sync customers from remote: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, int>> syncKeyPersonsFromRemote({DateTime? since}) async {
    try {
      final remoteData = await _keyPersonRemoteDataSource.fetchKeyPersons(since: since);

      if (remoteData.isEmpty) {
        return const Right(0);
      }

      _log.debug('customer | Syncing ${remoteData.length} key persons from remote');

      final companions = remoteData.map((data) {
        return db.KeyPersonsCompanion(
          id: Value(data['id'] as String),
          ownerType: Value(data['owner_type'] as String),
          customerId: Value(data['customer_id'] as String?),
          brokerId: Value(data['broker_id'] as String?),
          hvcId: Value(data['hvc_id'] as String?),
          name: Value(data['name'] as String),
          position: Value(data['position'] as String?),
          department: Value(data['department'] as String?),
          phone: Value(data['phone'] as String?),
          email: Value(data['email'] as String?),
          isPrimary: Value(data['is_primary'] as bool? ?? false),
          isActive: Value(data['is_active'] as bool? ?? true),
          notes: Value(data['notes'] as String?),
          createdBy: Value(data['created_by'] as String),
          isPendingSync: const Value(false),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          updatedAt: Value(DateTime.parse(data['updated_at'] as String)),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
        );
      }).toList();

      await _keyPersonLocalDataSource.upsertKeyPersons(companions);

      return Right(companions.length);
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to sync key persons from remote: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<void> markAsSynced(String id, DateTime syncedAt) =>
      _localDataSource.markAsSynced(id, syncedAt);

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Generate a unique customer code.
  String _generateCustomerCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'CUS${timestamp.substring(timestamp.length - 8)}';
  }

  /// Map Drift Customer data to domain Customer entity.
  domain.Customer _mapToCustomer(db.Customer data) => domain.Customer(
        id: data.id,
        code: data.code,
        name: data.name,
        address: data.address,
        provinceId: data.provinceId,
        cityId: data.cityId,
        postalCode: data.postalCode,
        latitude: data.latitude,
        longitude: data.longitude,
        phone: data.phone,
        email: data.email,
        website: data.website,
        companyTypeId: data.companyTypeId,
        ownershipTypeId: data.ownershipTypeId,
        industryId: data.industryId,
        npwp: data.npwp,
        assignedRmId: data.assignedRmId,
        imageUrl: data.imageUrl,
        notes: data.notes,
        isActive: data.isActive,
        createdBy: data.createdBy,
        isPendingSync: data.isPendingSync,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        deletedAt: data.deletedAt,
        lastSyncAt: data.lastSyncAt,
      );

  /// Map Drift KeyPerson data to domain KeyPerson entity.
  domain.KeyPerson _mapToKeyPerson(db.KeyPerson data) => domain.KeyPerson(
        id: data.id,
        ownerType: domain.KeyPersonOwnerTypeExtension.fromString(data.ownerType),
        customerId: data.customerId,
        brokerId: data.brokerId,
        hvcId: data.hvcId,
        name: data.name,
        position: data.position,
        department: data.department,
        phone: data.phone,
        email: data.email,
        isPrimary: data.isPrimary,
        isActive: data.isActive,
        notes: data.notes,
        createdBy: data.createdBy,
        isPendingSync: data.isPendingSync,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        deletedAt: data.deletedAt,
      );

  /// Create sync payload for new customer.
  Map<String, dynamic> _createSyncPayload(
    String id,
    String code,
    CustomerCreateDto dto,
    DateTime now,
  ) =>
      {
        'id': id,
        'code': code,
        'name': dto.name,
        'address': dto.address,
        'province_id': dto.provinceId,
        'city_id': dto.cityId,
        'postal_code': dto.postalCode,
        'latitude': dto.latitude,
        'longitude': dto.longitude,
        'phone': dto.phone,
        'email': dto.email,
        'website': dto.website,
        'company_type_id': dto.companyTypeId,
        'ownership_type_id': dto.ownershipTypeId,
        'industry_id': dto.industryId,
        'npwp': dto.npwp,
        'assigned_rm_id': dto.assignedRmId.isNotEmpty ? dto.assignedRmId : _currentUserId,
        'image_url': dto.imageUrl,
        'notes': dto.notes,
        'is_active': true,
        'created_by': _currentUserId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

  /// Create sync payload for updated customer.
  Map<String, dynamic> _createUpdateSyncPayload(db.Customer data) => {
        'id': data.id,
        'code': data.code,
        'name': data.name,
        'address': data.address,
        'province_id': data.provinceId,
        'city_id': data.cityId,
        'postal_code': data.postalCode,
        'latitude': data.latitude,
        'longitude': data.longitude,
        'phone': data.phone,
        'email': data.email,
        'website': data.website,
        'company_type_id': data.companyTypeId,
        'ownership_type_id': data.ownershipTypeId,
        'industry_id': data.industryId,
        'npwp': data.npwp,
        'assigned_rm_id': data.assignedRmId,
        'image_url': data.imageUrl,
        'notes': data.notes,
        'is_active': data.isActive,
        'created_by': data.createdBy,
        'created_at': data.createdAt.toIso8601String(),
        'updated_at': data.updatedAt.toIso8601String(),
        'deleted_at': data.deletedAt?.toIso8601String(),
      };

  /// Create sync payload for new key person.
  Map<String, dynamic> _createKeyPersonSyncPayload(
    String id,
    KeyPersonDto dto,
    DateTime now,
  ) =>
      {
        'id': id,
        'owner_type': dto.ownerType,
        'customer_id': dto.customerId,
        'broker_id': dto.brokerId,
        'hvc_id': dto.hvcId,
        'name': dto.name,
        'position': dto.position,
        'department': dto.department,
        'phone': dto.phone,
        'email': dto.email,
        'is_primary': dto.isPrimary,
        'is_active': true,
        'notes': dto.notes,
        'created_by': _currentUserId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

  /// Create sync payload for updated key person.
  Map<String, dynamic> _createKeyPersonUpdateSyncPayload(db.KeyPerson data) => {
        'id': data.id,
        'owner_type': data.ownerType,
        'customer_id': data.customerId,
        'broker_id': data.brokerId,
        'hvc_id': data.hvcId,
        'name': data.name,
        'position': data.position,
        'department': data.department,
        'phone': data.phone,
        'email': data.email,
        'is_primary': data.isPrimary,
        'is_active': data.isActive,
        'notes': data.notes,
        'created_by': data.createdBy,
        'created_at': data.createdAt.toIso8601String(),
        'updated_at': data.updatedAt.toIso8601String(),
        'deleted_at': data.deletedAt?.toIso8601String(),
      };
}
