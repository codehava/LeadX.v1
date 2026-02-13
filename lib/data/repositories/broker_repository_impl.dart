import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/broker.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/broker_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/broker_local_data_source.dart';
import '../datasources/remote/broker_remote_data_source.dart';
import '../dtos/broker_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of BrokerRepository with offline-first pattern.
class BrokerRepositoryImpl implements BrokerRepository {
  BrokerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncService,
    required this.currentUserId,
    required db.AppDatabase database,
  }) : _database = database;

  final BrokerLocalDataSource localDataSource;
  final BrokerRemoteDataSource remoteDataSource;
  final SyncService syncService;
  final String currentUserId;
  final db.AppDatabase _database;

  // ==========================================
  // Broker CRUD Operations
  // ==========================================

  @override
  Stream<List<domain.Broker>> watchAllBrokers() {
    return localDataSource.watchAllBrokers().map(
          (list) => list.map((data) => _mapToBroker(data)).toList(),
        );
  }

  @override
  Stream<List<domain.Broker>> watchBrokersPaginated({
    required int limit,
    String? searchQuery,
  }) {
    return localDataSource
        .watchBrokersPaginated(limit: limit, searchQuery: searchQuery)
        .map((list) => list.map((data) => _mapToBroker(data)).toList());
  }

  @override
  Future<int> getBrokerCount({String? searchQuery}) {
    return localDataSource.getBrokerCount(searchQuery: searchQuery);
  }

  @override
  Stream<domain.Broker?> watchBrokerById(String id) {
    return localDataSource.watchBrokerById(id).map(
          (data) => data != null ? _mapToBroker(data) : null,
        );
  }

  @override
  Future<List<domain.Broker>> getAllBrokers() async {
    final list = await localDataSource.getAllBrokers();
    return list.map((data) => _mapToBroker(data)).toList();
  }

  @override
  Future<domain.Broker?> getBrokerById(String id) async {
    final data = await localDataSource.getBrokerById(id);
    if (data == null) return null;
    return _mapToBroker(data);
  }

  @override
  Future<Either<Failure, domain.Broker>> createBroker(
      BrokerCreateDto dto) async {
    try {
      final id = const Uuid().v4();
      final code = await _generateBrokerCode();
      final now = DateTime.now();

      // Insert locally and queue for sync atomically
      await _database.transaction(() async {
        await localDataSource.insertBroker(
          db.BrokersCompanion(
            id: Value(id),
            code: Value(code),
            name: Value(dto.name),
            licenseNumber: Value(dto.licenseNumber),
            address: Value(dto.address),
            provinceId: Value(dto.provinceId),
            cityId: Value(dto.cityId),
            latitude: Value(dto.latitude),
            longitude: Value(dto.longitude),
            phone: Value(dto.phone),
            email: Value(dto.email),
            website: Value(dto.website),
            commissionRate: Value(dto.commissionRate),
            notes: Value(dto.notes),
            isActive: const Value(true),
            isPendingSync: const Value(true),
            createdBy: Value(currentUserId),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        await syncService.queueOperation(
          entityType: SyncEntityType.broker,
          entityId: id,
          operation: SyncOperation.create,
          payload: _createBrokerSyncPayload(id, code, dto, now),
        );
      });

      // Trigger sync in background (outside transaction)
      unawaited(syncService.triggerSync());

      // Get the created broker
      final created = await localDataSource.getBrokerById(id);
      return Right(_mapToBroker(created!));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to create broker: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Broker>> updateBroker(
      String id, BrokerUpdateDto dto) async {
    try {
      final now = DateTime.now();

      // Update locally and queue for sync atomically
      late final db.Broker updated;
      await _database.transaction(() async {
        await localDataSource.updateBroker(
          id,
          db.BrokersCompanion(
            name: dto.name != null ? Value(dto.name!) : const Value.absent(),
            licenseNumber: Value(dto.licenseNumber),
            address: Value(dto.address),
            provinceId: Value(dto.provinceId),
            cityId: Value(dto.cityId),
            latitude: Value(dto.latitude),
            longitude: Value(dto.longitude),
            phone: Value(dto.phone),
            email: Value(dto.email),
            website: Value(dto.website),
            commissionRate: Value(dto.commissionRate),
            notes: Value(dto.notes),
            isPendingSync: const Value(true),
            updatedAt: Value(now),
          ),
        );

        final result = await localDataSource.getBrokerById(id);
        if (result == null) {
          throw Exception('Broker not found after update');
        }
        updated = result;

        await syncService.queueOperation(
          entityType: SyncEntityType.broker,
          entityId: id,
          operation: SyncOperation.update,
          payload: _createBrokerUpdateSyncPayload(updated),
        );
      });

      // Trigger sync in background (outside transaction)
      unawaited(syncService.triggerSync());

      return Right(_mapToBroker(updated));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update broker: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBroker(String id) async {
    try {
      // Soft delete and queue for sync atomically
      await _database.transaction(() async {
        await localDataSource.softDeleteBroker(id);

        await syncService.queueOperation(
          entityType: SyncEntityType.broker,
          entityId: id,
          operation: SyncOperation.delete,
          payload: {
            'id': id,
            'deleted_at': DateTime.now().toIso8601String(),
          },
        );
      });

      // Trigger sync in background (outside transaction)
      unawaited(syncService.triggerSync());

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete broker: $e'));
    }
  }

  @override
  Future<List<domain.Broker>> searchBrokers(String query) async {
    final list = await localDataSource.searchBrokers(query);
    return list.map((data) => _mapToBroker(data)).toList();
  }

  // ==========================================
  // Key Person Operations
  // ==========================================

  @override
  Future<List<domain.KeyPerson>> getBrokerKeyPersons(String brokerId) async {
    final list = await localDataSource.getBrokerKeyPersons(brokerId);
    return list.map((data) => _mapToKeyPerson(data)).toList();
  }

  @override
  Stream<List<domain.KeyPerson>> watchBrokerKeyPersons(String brokerId) {
    return localDataSource.watchBrokerKeyPersons(brokerId).map(
          (list) => list.map((data) => _mapToKeyPerson(data)).toList(),
        );
  }

  // ==========================================
  // Pipeline Operations
  // ==========================================

  @override
  Future<int> getBrokerPipelineCount(String brokerId) async {
    return localDataSource.getBrokerPipelineCount(brokerId);
  }

  @override
  Stream<int> watchBrokerPipelineCount(String brokerId) {
    return localDataSource.watchBrokerPipelineCount(brokerId);
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  @override
  Future<Either<Failure, int>> syncFromRemote({DateTime? since}) async {
    try {
      final data = await remoteDataSource.fetchBrokers(since: since);

      if (data.isEmpty) return const Right(0);

      final companions = data.map((json) => _mapJsonToCompanion(json)).toList();
      await localDataSource.upsertBrokers(companions);

      return Right(companions.length);
    } catch (e) {
      return Left(SyncFailure(message: 'Failed to sync brokers: $e'));
    }
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  Future<String> _generateBrokerCode() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'BRK${timestamp.substring(timestamp.length - 6)}';
  }

  domain.Broker _mapToBroker(db.Broker data) {
    return domain.Broker(
      id: data.id,
      code: data.code,
      name: data.name,
      licenseNumber: data.licenseNumber,
      address: data.address,
      provinceId: data.provinceId,
      cityId: data.cityId,
      latitude: data.latitude,
      longitude: data.longitude,
      phone: data.phone,
      email: data.email,
      website: data.website,
      commissionRate: data.commissionRate,
      imageUrl: data.imageUrl,
      notes: data.notes,
      isActive: data.isActive,
      isPendingSync: data.isPendingSync,
      createdBy: data.createdBy,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  domain.KeyPerson _mapToKeyPerson(db.KeyPerson data) {
    return domain.KeyPerson(
      id: data.id,
      ownerType: domain.KeyPersonOwnerType.values.firstWhere(
        (e) => e.name.toUpperCase() == data.ownerType.toUpperCase(),
        orElse: () => domain.KeyPersonOwnerType.customer,
      ),
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
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  db.BrokersCompanion _mapJsonToCompanion(Map<String, dynamic> json) {
    return db.BrokersCompanion(
      id: Value(json['id'] as String),
      code: Value(json['code'] as String),
      name: Value(json['name'] as String),
      licenseNumber: Value(json['license_number'] as String?),
      address: Value(json['address'] as String?),
      provinceId: Value(json['province_id'] as String?),
      cityId: Value(json['city_id'] as String?),
      latitude: Value(json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null),
      longitude: Value(json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null),
      phone: Value(json['phone'] as String?),
      email: Value(json['email'] as String?),
      website: Value(json['website'] as String?),
      commissionRate: Value(json['commission_rate'] != null
          ? (json['commission_rate'] as num).toDouble()
          : null),
      imageUrl: Value(json['image_url'] as String?),
      notes: Value(json['notes'] as String?),
      isActive: Value(json['is_active'] as bool? ?? true),
      isPendingSync: const Value(false),
      createdBy: Value(json['created_by'] as String),
      createdAt: Value(DateTime.parse(json['created_at'] as String)),
      updatedAt: Value(DateTime.parse(json['updated_at'] as String)),
      deletedAt: Value(json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null),
    );
  }

  Map<String, dynamic> _createBrokerSyncPayload(
    String id,
    String code,
    BrokerCreateDto dto,
    DateTime now,
  ) {
    return {
      'id': id,
      'code': code,
      'name': dto.name,
      'license_number': dto.licenseNumber,
      'address': dto.address,
      'province_id': dto.provinceId,
      'city_id': dto.cityId,
      'latitude': dto.latitude,
      'longitude': dto.longitude,
      'phone': dto.phone,
      'email': dto.email,
      'website': dto.website,
      'commission_rate': dto.commissionRate,
      'notes': dto.notes,
      'is_active': true,
      'created_by': currentUserId,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  Map<String, dynamic> _createBrokerUpdateSyncPayload(db.Broker data) {
    return {
      'id': data.id,
      'code': data.code,
      'name': data.name,
      'license_number': data.licenseNumber,
      'address': data.address,
      'province_id': data.provinceId,
      'city_id': data.cityId,
      'latitude': data.latitude,
      'longitude': data.longitude,
      'phone': data.phone,
      'email': data.email,
      'website': data.website,
      'commission_rate': data.commissionRate,
      'notes': data.notes,
      'is_active': data.isActive,
      'updated_at': data.updatedAt.toIso8601String(),
    };
  }
}
