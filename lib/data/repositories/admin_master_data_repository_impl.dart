import '../../core/errors/exception_mapper.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../data/datasources/remote/admin_master_data_remote_data_source.dart';
import '../../data/dtos/master_data_dtos.dart';
import '../../domain/repositories/admin_master_data_repository.dart';

/// Implementation of AdminMasterDataRepository.
class AdminMasterDataRepositoryImpl implements AdminMasterDataRepository {
  final AdminMasterDataRemoteDataSource _remoteDataSource;

  AdminMasterDataRepositoryImpl({required AdminMasterDataRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  // ============================================
  // READ OPERATIONS
  // ============================================

  @override
  Future<List<dynamic>> getAllEntities(
    String tableName, {
    bool includeInactive = false,
  }) async {
    try {
      return await _remoteDataSource.getAllEntities(tableName,
          includeInactive: includeInactive);
    } catch (e) {
      throw DatabaseFailure(
        message: 'Gagal mengambil data dari $tableName',
        originalError: e,
      );
    }
  }

  @override
  Future<dynamic> getEntity(String tableName, String id) async {
    try {
      return await _remoteDataSource.getEntity(tableName, id);
    } catch (e) {
      throw DatabaseFailure(
        message: 'Gagal mengambil data $id dari $tableName',
        originalError: e,
      );
    }
  }

  @override
  Future<List<dynamic>> searchEntities(String tableName, String query) async {
    try {
      return await _remoteDataSource.searchEntities(tableName, query);
    } catch (e) {
      throw DatabaseFailure(
        message: 'Gagal mencari $query di $tableName',
        originalError: e,
      );
    }
  }

  @override
  Future<List<dynamic>> getEntitiesPaginated(
    String tableName, {
    required int offset,
    required int limit,
    bool includeInactive = false,
  }) async {
    try {
      final allEntities = await _remoteDataSource.getAllEntities(tableName,
          includeInactive: includeInactive);
      return allEntities.skip(offset).take(limit).toList();
    } catch (e) {
      throw DatabaseFailure(
        message: 'Gagal mengambil data $tableName (offset: $offset, limit: $limit)',
        originalError: e,
      );
    }
  }

  // ============================================
  // CREATE OPERATIONS
  // ============================================

  @override
  Future<Result<Map<String, dynamic>>> createEntity(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    try {
      // Check for duplicate codes
      if (data.containsKey('code')) {
        final exists = await _remoteDataSource.codeExists(
          tableName,
          data['code'] as String,
        );
        if (exists) {
          return Result.failure(ValidationFailure(
            message: 'Kode "${data['code']}" sudah ada',
          ));
        }
      }

      final result = await _remoteDataSource.createEntity(tableName, data);
      return Result.success(result);
    } catch (e) {
      return Result.failure(mapException(e, context: 'createEntity($tableName)'));
    }
  }

  @override
  Future<Result<ProvinceDto>> createProvince(ProvinceCreateDto dto) async {
    try {
      final exists = await _remoteDataSource.codeExists('provinces', dto.code);
      if (exists) {
        return Result.failure(ValidationFailure(
          message: 'Kode provinsi "${dto.code}" sudah ada',
        ));
      }

      final result = await _remoteDataSource.createProvince(dto);
      final province = ProvinceDto(
        id: result['id'] as String,
        code: result['code'] as String,
        name: result['name'] as String,
        isActive: (result['is_active'] as bool?) ?? true,
      );
      return Result.success(province);
    } catch (e) {
      return Result.failure(mapException(e, context: 'createProvince'));
    }
  }

  @override
  Future<Result<CityDto>> createCity(CityCreateDto dto) async {
    try {
      final exists = await _remoteDataSource.codeExists('cities', dto.code);
      if (exists) {
        return Result.failure(ValidationFailure(
          message: 'Kode kota "${dto.code}" sudah ada',
        ));
      }

      final result = await _remoteDataSource.createCity(dto);
      final city = CityDto(
        id: result['id'] as String,
        code: result['code'] as String,
        name: result['name'] as String,
        provinceId: result['province_id'] as String,
        isActive: (result['is_active'] as bool?) ?? true,
      );
      return Result.success(city);
    } catch (e) {
      return Result.failure(mapException(e, context: 'createCity'));
    }
  }

  @override
  Future<Result<CompanyTypeDto>> createCompanyType(
    CompanyTypeCreateDto dto,
  ) async {
    try {
      final exists = await _remoteDataSource.codeExists('company_types', dto.code);
      if (exists) {
        return Result.failure(ValidationFailure(
          message: 'Kode tipe perusahaan "${dto.code}" sudah ada',
        ));
      }

      final result = await _remoteDataSource.createCompanyType(dto);
      final companyType = CompanyTypeDto(
        id: result['id'] as String,
        code: result['code'] as String,
        name: result['name'] as String,
        sortOrder: (result['sort_order'] as int?) ?? 0,
        isActive: (result['is_active'] as bool?) ?? true,
      );
      return Result.success(companyType);
    } catch (e) {
      return Result.failure(mapException(e, context: 'createCompanyType'));
    }
  }

  @override
  Future<Result<IndustryDto>> createIndustry(IndustryCreateDto dto) async {
    try {
      final exists = await _remoteDataSource.codeExists('industries', dto.code);
      if (exists) {
        return Result.failure(ValidationFailure(
          message: 'Kode industri "${dto.code}" sudah ada',
        ));
      }

      final result = await _remoteDataSource.createIndustry(dto);
      final industry = IndustryDto(
        id: result['id'] as String,
        code: result['code'] as String,
        name: result['name'] as String,
        sortOrder: (result['sort_order'] as int?) ?? 0,
        isActive: (result['is_active'] as bool?) ?? true,
      );
      return Result.success(industry);
    } catch (e) {
      return Result.failure(mapException(e, context: 'createIndustry'));
    }
  }

  @override
  Future<Result<PipelineStageDto>> createPipelineStage(
    PipelineStageCreateDto dto,
  ) async {
    try {
      // Validate probability range
      if (dto.probability < 0 || dto.probability > 100) {
        return Result.failure(ValidationFailure(
          message: 'Probabilitas harus antara 0-100',
        ));
      }

      final exists = await _remoteDataSource.codeExists('pipeline_stages', dto.code);
      if (exists) {
        return Result.failure(ValidationFailure(
          message: 'Kode tahap "${dto.code}" sudah ada',
        ));
      }

      final result = await _remoteDataSource.createPipelineStage(dto);
      final stage = PipelineStageDto(
        id: result['id'] as String,
        code: result['code'] as String,
        name: result['name'] as String,
        probability: (result['probability'] as int?) ?? 0,
        sequence: (result['sequence'] as int?) ?? 0,
        color: result['color'] as String?,
        isFinal: (result['is_final'] as bool?) ?? false,
        isWon: (result['is_won'] as bool?) ?? false,
        isActive: (result['is_active'] as bool?) ?? true,
        createdAt: DateTime.parse(result['created_at'] as String),
        updatedAt: DateTime.parse(result['updated_at'] as String),
      );
      return Result.success(stage);
    } catch (e) {
      return Result.failure(mapException(e, context: 'createPipelineStage'));
    }
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  @override
  Future<Result<Map<String, dynamic>>> updateEntity(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) => runCatching(
    () => _remoteDataSource.updateEntity(tableName, id, data),
    context: 'updateEntity($tableName)',
  );

  @override
  Future<Result<void>> bulkToggleActive(
    String tableName,
    List<String> ids, {
    required bool isActive,
  }) => runCatching(
    () => _remoteDataSource.bulkToggleActive(tableName, ids, isActive: isActive),
    context: 'bulkToggleActive($tableName)',
  );

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  @override
  Future<Result<void>> softDeleteEntity(String tableName, String id) =>
    runCatching(
      () => _remoteDataSource.softDeleteEntity(tableName, id),
      context: 'softDeleteEntity($tableName)',
    );

  @override
  Future<Result<void>> hardDeleteEntity(String tableName, String id) =>
    runCatching(
      () => _remoteDataSource.hardDeleteEntity(tableName, id),
      context: 'hardDeleteEntity($tableName)',
    );

  @override
  Future<Result<void>> softDeleteRegionalOffice(String id) async {
    try {
      // Check if any active branches exist under this regional office
      final supabase = _remoteDataSource.supabaseClient;
      final branches = await supabase
          .from('branches')
          .select('id')
          .eq('regional_office_id', id)
          .eq('is_active', true);

      if ((branches as List).isNotEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Tidak dapat menghapus Kantor Wilayah yang masih memiliki ${branches.length} cabang aktif. '
              'Harap nonaktifkan atau pindahkan cabang terlebih dahulu.',
        ));
      }

      // Proceed with soft delete
      return await softDeleteEntity('regional_offices', id);
    } catch (e) {
      return Result.failure(mapException(e, context: 'softDeleteRegionalOffice'));
    }
  }

  @override
  Future<Result<void>> softDeleteBranch(String id) async {
    try {
      // Check if any active users are assigned to this branch
      final supabase = _remoteDataSource.supabaseClient;
      final users = await supabase
          .from('users')
          .select('id')
          .eq('branch_id', id)
          .eq('is_active', true);

      if ((users as List).isNotEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Tidak dapat menghapus Kantor Cabang yang masih memiliki ${users.length} user aktif. '
              'Harap pindahkan user ke cabang lain terlebih dahulu.',
        ));
      }

      // Proceed with soft delete
      return await softDeleteEntity('branches', id);
    } catch (e) {
      return Result.failure(mapException(e, context: 'softDeleteBranch'));
    }
  }

  // ============================================
  // ACTIVATION/DEACTIVATION
  // ============================================

  @override
  Future<Result<void>> activateEntity(String tableName, String id) =>
    runCatching(
      () => _remoteDataSource.activateEntity(tableName, id),
      context: 'activateEntity($tableName)',
    );

  @override
  Future<Result<void>> deactivateEntity(String tableName, String id) =>
    runCatching(
      () => _remoteDataSource.deactivateEntity(tableName, id),
      context: 'deactivateEntity($tableName)',
    );

  // ============================================
  // VALIDATION
  // ============================================

  @override
  Future<bool> codeExists(String tableName, String code, {String? excludeId}) async {
    try {
      return await _remoteDataSource.codeExists(tableName, code, excludeId: excludeId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<void>> validateDelete(String tableName, String id) async {
    try {
      final hasDeps = await _remoteDataSource.hasDependencies(tableName, id);
      if (hasDeps) {
        return Result.failure(ValidationFailure(
          message: 'Tidak dapat menghapus data ini karena memiliki data terkait',
        ));
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(mapException(e, context: 'validateDelete($tableName)'));
    }
  }
}
