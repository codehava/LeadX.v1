import '../../core/errors/result.dart';
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
  Future<Result<Map<String, dynamic>>> createEntity(
    String tableName,
    Map<String, dynamic> data,
  );

  /// Create province.
  Future<Result<ProvinceDto>> createProvince(ProvinceCreateDto dto);

  /// Create city.
  Future<Result<CityDto>> createCity(CityCreateDto dto);

  /// Create company type.
  Future<Result<CompanyTypeDto>> createCompanyType(CompanyTypeCreateDto dto);

  /// Create industry.
  Future<Result<IndustryDto>> createIndustry(IndustryCreateDto dto);

  /// Create pipeline stage.
  Future<Result<PipelineStageDto>> createPipelineStage(
    PipelineStageCreateDto dto,
  );

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update an existing entity (generic).
  Future<Result<Map<String, dynamic>>> updateEntity(
    String tableName,
    String id,
    Map<String, dynamic> data,
  );

  /// Bulk update activate/deactivate status.
  Future<Result<void>> bulkToggleActive(
    String tableName,
    List<String> ids, {
    required bool isActive,
  });

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Soft delete an entity (sets deleted_at timestamp).
  Future<Result<void>> softDeleteEntity(String tableName, String id);

  /// Hard delete an entity (only for non-critical master data).
  Future<Result<void>> hardDeleteEntity(String tableName, String id);

  /// Soft delete a regional office with dependency validation.
  /// Prevents deletion if active branches exist.
  Future<Result<void>> softDeleteRegionalOffice(String id);

  /// Soft delete a branch with dependency validation.
  /// Prevents deletion if active users are assigned.
  Future<Result<void>> softDeleteBranch(String id);

  // ============================================
  // ACTIVATION/DEACTIVATION
  // ============================================

  /// Activate an entity.
  Future<Result<void>> activateEntity(String tableName, String id);

  /// Deactivate an entity.
  Future<Result<void>> deactivateEntity(String tableName, String id);

  // ============================================
  // VALIDATION
  // ============================================

  /// Check if code already exists (for unique code fields).
  Future<bool> codeExists(String tableName, String code, {String? excludeId});

  /// Validate dependencies before deletion (e.g., cities before deleting province).
  Future<Result<void>> validateDelete(String tableName, String id);
}
