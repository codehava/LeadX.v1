import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/hvc.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/hvc_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/customer_local_data_source.dart';
import '../datasources/local/hvc_local_data_source.dart';
import '../datasources/local/key_person_local_data_source.dart';
import '../datasources/remote/hvc_remote_data_source.dart';
import '../dtos/hvc_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of HvcRepository with offline-first pattern.
class HvcRepositoryImpl implements HvcRepository {
  HvcRepositoryImpl({
    required HvcLocalDataSource localDataSource,
    required HvcRemoteDataSource remoteDataSource,
    required KeyPersonLocalDataSource keyPersonLocalDataSource,
    required CustomerLocalDataSource customerLocalDataSource,
    required SyncService syncService,
    required String currentUserId,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _keyPersonLocalDataSource = keyPersonLocalDataSource,
        _customerLocalDataSource = customerLocalDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId;

  final HvcLocalDataSource _localDataSource;
  final HvcRemoteDataSource _remoteDataSource;
  final KeyPersonLocalDataSource _keyPersonLocalDataSource;
  final CustomerLocalDataSource _customerLocalDataSource;
  final SyncService _syncService;
  final String _currentUserId;

  static const _uuid = Uuid();

  // ==========================================
  // HVC CRUD Operations
  // ==========================================

  @override
  Stream<List<domain.Hvc>> watchAllHvcs() =>
      _localDataSource.watchAllHvcs().map(
            (hvcs) => hvcs.map(_mapToHvc).toList(),
          );

  @override
  Stream<List<domain.Hvc>> watchHvcsPaginated({
    required int limit,
    String? searchQuery,
  }) =>
      _localDataSource
          .watchHvcsPaginated(limit: limit, searchQuery: searchQuery)
          .map((hvcs) => hvcs.map(_mapToHvc).toList());

  @override
  Future<int> getHvcCount({String? searchQuery}) =>
      _localDataSource.getHvcCount(searchQuery: searchQuery);

  @override
  Stream<domain.Hvc?> watchHvcById(String id) =>
      _localDataSource.watchHvcById(id).asyncMap((data) async {
        if (data == null) return null;
        final hvcType = await _localDataSource.getHvcTypeById(data.typeId);
        return _mapToHvc(data, typeName: hvcType?.name);
      });

  @override
  Future<List<domain.Hvc>> getAllHvcs() async {
    final hvcs = await _localDataSource.getAllHvcs();
    return hvcs.map(_mapToHvc).toList();
  }

  @override
  Future<domain.Hvc?> getHvcById(String id) async {
    final data = await _localDataSource.getHvcById(id);
    if (data == null) return null;

    // Get type name for lookup
    final hvcType = await _localDataSource.getHvcTypeById(data.typeId);
    return _mapToHvc(data, typeName: hvcType?.name);
  }

  @override
  Future<Either<Failure, domain.Hvc>> createHvc(HvcCreateDto dto) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();
      final code = _generateHvcCode();

      final companion = db.HvcsCompanion.insert(
        id: id,
        code: code,
        name: dto.name,
        typeId: dto.typeId,
        description: Value(dto.description),
        address: Value(dto.address),
        latitude: Value(dto.latitude),
        longitude: Value(dto.longitude),
        radiusMeters: Value(dto.radiusMeters ?? 500),
        potentialValue: Value(dto.potentialValue),
        imageUrl: Value(dto.imageUrl),
        createdBy: _currentUserId,
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Save locally first
      await _localDataSource.insertHvc(companion);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.hvc,
        entityId: id,
        operation: SyncOperation.create,
        payload: _createHvcSyncPayload(id, code, dto, now),
      );

      // Trigger sync in background
      unawaited(_syncService.triggerSync());

      // Return created HVC
      final hvc = await getHvcById(id);
      return Right(hvc!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to create HVC: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.Hvc>> updateHvc(
      String id, HvcUpdateDto dto) async {
    try {
      final now = DateTime.now();

      final companion = db.HvcsCompanion(
        name: dto.name != null ? Value(dto.name!) : const Value.absent(),
        typeId: dto.typeId != null ? Value(dto.typeId!) : const Value.absent(),
        description: dto.description != null
            ? Value(dto.description)
            : const Value.absent(),
        address:
            dto.address != null ? Value(dto.address) : const Value.absent(),
        latitude:
            dto.latitude != null ? Value(dto.latitude) : const Value.absent(),
        longitude:
            dto.longitude != null ? Value(dto.longitude) : const Value.absent(),
        radiusMeters: dto.radiusMeters != null
            ? Value(dto.radiusMeters!)
            : const Value.absent(),
        potentialValue: dto.potentialValue != null
            ? Value(dto.potentialValue)
            : const Value.absent(),
        imageUrl:
            dto.imageUrl != null ? Value(dto.imageUrl) : const Value.absent(),
        isActive:
            dto.isActive != null ? Value(dto.isActive!) : const Value.absent(),
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      );

      // Update locally first
      await _localDataSource.updateHvc(id, companion);

      // Get updated data for sync
      final updated = await _localDataSource.getHvcById(id);
      if (updated == null) {
        return Left(NotFoundFailure(message: 'HVC not found: $id'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.hvc,
        entityId: id,
        operation: SyncOperation.update,
        payload: _createHvcUpdateSyncPayload(updated),
      );

      // Trigger sync in background
      unawaited(_syncService.triggerSync());

      return Right(_mapToHvc(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update HVC: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHvc(String id) async {
    try {
      // Soft delete locally
      await _localDataSource.softDeleteHvc(id);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.hvc,
        entityId: id,
        operation: SyncOperation.delete,
        payload: {'id': id},
      );

      // Trigger sync in background
      unawaited(_syncService.triggerSync());

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete HVC: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<List<domain.Hvc>> searchHvcs(String query) async {
    final results = await _localDataSource.searchHvcs(query);
    return results.map(_mapToHvc).toList();
  }

  // ==========================================
  // HVC Type Operations
  // ==========================================

  @override
  Future<List<domain.HvcType>> getHvcTypes() async {
    final types = await _localDataSource.getHvcTypes();
    return types
        .map((t) => domain.HvcType(
              id: t.id,
              code: t.code,
              name: t.name,
              description: t.description,
              sortOrder: t.sortOrder,
              isActive: t.isActive,
            ))
        .toList();
  }

  // ==========================================
  // Key Person Operations
  // ==========================================

  @override
  Future<List<domain.KeyPerson>> getHvcKeyPersons(String hvcId) async {
    final results = await _keyPersonLocalDataSource.getKeyPersonsByHvc(hvcId);
    return results.map(_mapToKeyPerson).toList();
  }

  @override
  Stream<List<domain.KeyPerson>> watchHvcKeyPersons(String hvcId) =>
      _keyPersonLocalDataSource.watchKeyPersonsByHvc(hvcId).map(
            (keyPersons) => keyPersons.map(_mapToKeyPerson).toList(),
          );

  // ==========================================
  // Customer-HVC Link Operations
  // ==========================================

  @override
  Stream<List<domain.CustomerHvcLink>> watchLinkedCustomers(String hvcId) =>
      _localDataSource.watchLinkedCustomers(hvcId).asyncMap(
        (links) => _enrichLinksWithCustomerData(links),
      );

  @override
  Future<List<domain.CustomerHvcLink>> getLinkedCustomers(String hvcId) async {
    final links = await _localDataSource.getLinkedCustomers(hvcId);
    return _enrichLinksWithCustomerData(links);
  }

  /// Enrich links with customer names by looking up from customer table.
  Future<List<domain.CustomerHvcLink>> _enrichLinksWithCustomerData(
      List<db.CustomerHvcLink> links) async {
    final enrichedLinks = <domain.CustomerHvcLink>[];
    for (final link in links) {
      final customer =
          await _customerLocalDataSource.getCustomerById(link.customerId);
      enrichedLinks.add(_mapToCustomerHvcLink(
        link,
        customerName: customer?.name,
        customerCode: customer?.code,
      ));
    }
    return enrichedLinks;
  }

  @override
  Stream<List<domain.CustomerHvcLink>> watchCustomerHvcs(String customerId) =>
      _localDataSource.watchCustomerHvcs(customerId).map(
            (links) => links.map(_mapToCustomerHvcLink).toList(),
          );

  @override
  Future<List<domain.CustomerHvcLink>> getCustomerHvcs(
      String customerId) async {
    final links = await _localDataSource.getCustomerHvcs(customerId);
    return links.map(_mapToCustomerHvcLink).toList();
  }

  @override
  Future<Either<Failure, domain.CustomerHvcLink>> linkCustomerToHvc(
      CustomerHvcLinkDto dto) async {
    try {
      // Check if link already exists
      final exists =
          await _localDataSource.linkExists(dto.customerId, dto.hvcId);
      if (exists) {
        return Left(ValidationFailure(
            message: 'Customer is already linked to this HVC'));
      }

      final now = DateTime.now();
      final id = _uuid.v4();

      final companion = db.CustomerHvcLinksCompanion.insert(
        id: id,
        customerId: dto.customerId,
        hvcId: dto.hvcId,
        relationshipType: dto.relationshipType,
        createdBy: _currentUserId,
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      );

      // Save locally first
      await _localDataSource.insertCustomerHvcLink(companion);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.customerHvcLink,
        entityId: id,
        operation: SyncOperation.create,
        payload: _createLinkSyncPayload(id, dto, now),
      );

      // Trigger sync in background
      unawaited(_syncService.triggerSync());

      // Return created link
      final link = await _localDataSource.getCustomerHvcLinkById(id);
      return Right(_mapToCustomerHvcLink(link!));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to link customer to HVC: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> unlinkCustomerFromHvc(String linkId) async {
    try {
      // Soft delete locally
      await _localDataSource.deleteCustomerHvcLink(linkId);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.customerHvcLink,
        entityId: linkId,
        operation: SyncOperation.delete,
        payload: {'id': linkId},
      );

      // Trigger sync in background
      unawaited(_syncService.triggerSync());

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to unlink customer from HVC: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  @override
  Future<Either<Failure, int>> syncFromRemote({DateTime? since}) async {
    try {
      final remoteData = await _remoteDataSource.fetchHvcs(since: since);

      if (remoteData.isEmpty) {
        return const Right(0);
      }

      final companions = remoteData.map((data) {
        return db.HvcsCompanion(
          id: Value(data['id'] as String),
          code: Value(data['code'] as String),
          name: Value(data['name'] as String),
          typeId: Value(data['type_id'] as String),
          description: Value(data['description'] as String?),
          address: Value(data['address'] as String?),
          latitude: Value((data['latitude'] as num?)?.toDouble()),
          longitude: Value((data['longitude'] as num?)?.toDouble()),
          radiusMeters: Value(data['radius_meters'] as int? ?? 500),
          potentialValue: Value((data['potential_value'] as num?)?.toDouble()),
          imageUrl: Value(data['image_url'] as String?),
          isActive: Value(data['is_active'] as bool? ?? true),
          createdBy: Value(data['created_by'] as String),
          isPendingSync: const Value(false),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          updatedAt: Value(DateTime.parse(data['updated_at'] as String)),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
        );
      }).toList();

      await _localDataSource.upsertHvcs(companions);

      return Right(companions.length);
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to sync HVCs from remote: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, int>> syncLinksFromRemote({DateTime? since}) async {
    try {
      final remoteData =
          await _remoteDataSource.fetchCustomerHvcLinks(since: since);

      if (remoteData.isEmpty) {
        return const Right(0);
      }

      final companions = remoteData.map((data) {
        // Map from Supabase schema fields to local Drift table fields
        // Supabase uses: linked_at, linked_by
        // Local table has: createdAt, createdBy, isActive, updatedAt
        final linkedAt = DateTime.parse(data['linked_at'] as String);
        return db.CustomerHvcLinksCompanion(
          id: Value(data['id'] as String),
          customerId: Value(data['customer_id'] as String),
          hvcId: Value(data['hvc_id'] as String),
          relationshipType: Value(data['relationship_type'] as String),
          isActive: const Value(true),
          createdBy: Value(data['linked_by'] as String),
          isPendingSync: const Value(false),
          createdAt: Value(linkedAt),
          updatedAt: Value(linkedAt),
          deletedAt: data['deleted_at'] != null
              ? Value(DateTime.parse(data['deleted_at'] as String))
              : const Value(null),
        );
      }).toList();

      await _localDataSource.upsertCustomerHvcLinks(companions);

      return Right(companions.length);
    } catch (e) {
      return Left(SyncFailure(
        message: 'Failed to sync customer-HVC links from remote: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  /// Generate a unique HVC code.
  String _generateHvcCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'HVC${timestamp.substring(timestamp.length - 8)}';
  }

  /// Map Drift Hvc data to domain Hvc entity.
  domain.Hvc _mapToHvc(db.Hvc data, {String? typeName}) => domain.Hvc(
        id: data.id,
        code: data.code,
        name: data.name,
        typeId: data.typeId,
        description: data.description,
        address: data.address,
        latitude: data.latitude,
        longitude: data.longitude,
        radiusMeters: data.radiusMeters,
        potentialValue: data.potentialValue,
        imageUrl: data.imageUrl,
        isActive: data.isActive,
        createdBy: data.createdBy,
        isPendingSync: data.isPendingSync,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        deletedAt: data.deletedAt,
        typeName: typeName,
      );

  /// Map Drift CustomerHvcLink to domain entity.
  domain.CustomerHvcLink _mapToCustomerHvcLink(
    db.CustomerHvcLink data, {
    String? customerName,
    String? customerCode,
  }) =>
      domain.CustomerHvcLink(
        id: data.id,
        customerId: data.customerId,
        hvcId: data.hvcId,
        relationshipType: data.relationshipType,
        isActive: data.isActive,
        createdBy: data.createdBy,
        isPendingSync: data.isPendingSync,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        deletedAt: data.deletedAt,
        customerName: customerName,
        customerCode: customerCode,
      );

  /// Map Drift KeyPerson to domain entity.
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

  /// Create sync payload for new HVC.
  Map<String, dynamic> _createHvcSyncPayload(
    String id,
    String code,
    HvcCreateDto dto,
    DateTime now,
  ) =>
      {
        'id': id,
        'code': code,
        'name': dto.name,
        'type_id': dto.typeId,
        'description': dto.description,
        'address': dto.address,
        'latitude': dto.latitude,
        'longitude': dto.longitude,
        'radius_meters': dto.radiusMeters ?? 500,
        'potential_value': dto.potentialValue,
        'image_url': dto.imageUrl,
        'is_active': true,
        'created_by': _currentUserId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

  /// Create sync payload for updated HVC.
  Map<String, dynamic> _createHvcUpdateSyncPayload(db.Hvc data) => {
        'id': data.id,
        'code': data.code,
        'name': data.name,
        'type_id': data.typeId,
        'description': data.description,
        'address': data.address,
        'latitude': data.latitude,
        'longitude': data.longitude,
        'radius_meters': data.radiusMeters,
        'potential_value': data.potentialValue,
        'image_url': data.imageUrl,
        'is_active': data.isActive,
        'created_by': data.createdBy,
        'created_at': data.createdAt.toIso8601String(),
        'updated_at': data.updatedAt.toIso8601String(),
        'deleted_at': data.deletedAt?.toIso8601String(),
      };

  /// Create sync payload for customer-HVC link.
  /// Note: Supabase schema uses linked_at/linked_by instead of created_at/created_by
  Map<String, dynamic> _createLinkSyncPayload(
    String id,
    CustomerHvcLinkDto dto,
    DateTime now,
  ) =>
      {
        'id': id,
        'customer_id': dto.customerId,
        'hvc_id': dto.hvcId,
        'relationship_type': dto.relationshipType,
        'linked_by': _currentUserId,
        'linked_at': now.toIso8601String(),
      };
}
