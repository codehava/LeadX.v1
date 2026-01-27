import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/dtos/master_data_dtos.dart';

/// Repository for master data CRUD operations (admin only).
///
/// This is a generic repository that handles all master data entity types.
/// Master data is managed directly through Supabase (no sync queue).
abstract class AdminMasterDataRepository {
  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all entities of a specific type (including inactive).
  Future<List<dynamic>> getAllEntities(String tableName, {bool includeInactive = false});

  /// Get a single entity by ID.
  Future<dynamic> getEntity(String tableName, String id);

  /// Search entities by name.
  Future<List<dynamic>> searchEntities(String tableName, String query);

  /// Get entities with pagination.
  Future<List<dynamic>> getEntitiesPaginated(
    String tableName, {
    required int offset,
    required int limit,
    bool includeInactive = false,
  });

  // ============================================
  // CREATE OPERATIONS
  // ============================================

  /// Create a new entity (generic).
  Future<Either<Failure, Map<String, dynamic>>> createEntity(
    String tableName,
    Map<String, dynamic> data,
  );

  /// Create province.
  Future<Either<Failure, ProvinceDto>> createProvince(ProvinceCreateDto dto);

  /// Create city.
  Future<Either<Failure, CityDto>> createCity(CityCreateDto dto);

  /// Create company type.
  Future<Either<Failure, CompanyTypeDto>> createCompanyType(CompanyTypeCreateDto dto);

  /// Create industry.
  Future<Either<Failure, IndustryDto>> createIndustry(IndustryCreateDto dto);

  /// Create pipeline stage.
  Future<Either<Failure, PipelineStageDto>> createPipelineStage(
    PipelineStageCreateDto dto,
  );

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update an existing entity (generic).
  Future<Either<Failure, Map<String, dynamic>>> updateEntity(
    String tableName,
    String id,
    Map<String, dynamic> data,
  );

  /// Bulk update activate/deactivate status.
  Future<Either<Failure, void>> bulkToggleActive(
    String tableName,
    List<String> ids, {
    required bool isActive,
  });

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Soft delete an entity (sets deleted_at timestamp).
  Future<Either<Failure, void>> softDeleteEntity(String tableName, String id);

  /// Hard delete an entity (only for non-critical master data).
  Future<Either<Failure, void>> hardDeleteEntity(String tableName, String id);

  /// Soft delete a regional office with dependency validation.
  /// Prevents deletion if active branches exist.
  Future<Either<Failure, void>> softDeleteRegionalOffice(String id);

  /// Soft delete a branch with dependency validation.
  /// Prevents deletion if active users are assigned.
  Future<Either<Failure, void>> softDeleteBranch(String id);

  // ============================================
  // ACTIVATION/DEACTIVATION
  // ============================================

  /// Activate an entity.
  Future<Either<Failure, void>> activateEntity(String tableName, String id);

  /// Deactivate an entity.
  Future<Either<Failure, void>> deactivateEntity(String tableName, String id);

  // ============================================
  // VALIDATION
  // ============================================

  /// Check if code already exists (for unique code fields).
  Future<bool> codeExists(String tableName, String code, {String? excludeId});

  /// Validate dependencies before deletion (e.g., cities before deleting province).
  Future<Either<Failure, void>> validateDelete(String tableName, String id);
}
