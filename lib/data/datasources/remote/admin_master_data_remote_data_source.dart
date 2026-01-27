import 'package:supabase_flutter/supabase_flutter.dart';

import '../../dtos/master_data_dtos.dart';

/// Remote data source for master data CRUD operations via Supabase.
class AdminMasterDataRemoteDataSource {
  final SupabaseClient _client;

  AdminMasterDataRemoteDataSource(this._client);

  /// Get the Supabase client instance.
  SupabaseClient get supabaseClient => _client;

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all entities from a table.
  Future<List<Map<String, dynamic>>> getAllEntities(
    String tableName, {
    bool includeInactive = false,
  }) async {
    var query = _client.from(tableName).select();

    if (!includeInactive) {
      query = query.eq('is_active', true);
    }

    final result = await query;
    return List<Map<String, dynamic>>.from(result as List);
  }

  /// Get a single entity by ID.
  Future<Map<String, dynamic>?> getEntity(String tableName, String id) async {
    try {
      final result = await _client.from(tableName).select().eq('id', id).single();
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      return null;
    }
  }

  /// Search entities by name (case-insensitive).
  Future<List<Map<String, dynamic>>> searchEntities(
    String tableName,
    String query,
  ) async {
    final result = await _client
        .from(tableName)
        .select()
        .ilike('name', '%$query%')
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(result as List);
  }

  // ============================================
  // CREATE OPERATIONS
  // ============================================

  /// Create a generic entity.
  Future<Map<String, dynamic>> createEntity(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final result = await _client.from(tableName).insert(data).select().single();
    return Map<String, dynamic>.from(result as Map);
  }

  /// Create province.
  Future<Map<String, dynamic>> createProvince(ProvinceCreateDto dto) async {
    return createEntity('provinces', {
      'code': dto.code,
      'name': dto.name,
      'is_active': dto.isActive,
    });
  }

  /// Create city.
  Future<Map<String, dynamic>> createCity(CityCreateDto dto) async {
    return createEntity('cities', {
      'code': dto.code,
      'name': dto.name,
      'province_id': dto.provinceId,
      'is_active': dto.isActive,
    });
  }

  /// Create company type.
  Future<Map<String, dynamic>> createCompanyType(CompanyTypeCreateDto dto) async {
    return createEntity('company_types', {
      'code': dto.code,
      'name': dto.name,
      'sort_order': dto.sortOrder,
      'is_active': dto.isActive,
    });
  }

  /// Create industry.
  Future<Map<String, dynamic>> createIndustry(IndustryCreateDto dto) async {
    return createEntity('industries', {
      'code': dto.code,
      'name': dto.name,
      'sort_order': dto.sortOrder,
      'is_active': dto.isActive,
    });
  }

  /// Create pipeline stage.
  Future<Map<String, dynamic>> createPipelineStage(
    PipelineStageCreateDto dto,
  ) async {
    return createEntity('pipeline_stages', {
      'code': dto.code,
      'name': dto.name,
      'probability': dto.probability,
      'sequence': dto.sequence,
      'color': dto.color,
      'is_final': dto.isFinal,
      'is_won': dto.isWon,
      'is_active': dto.isActive,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update a generic entity.
  Future<Map<String, dynamic>> updateEntity(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) async {
    // Convert snake_case keys if needed and add timestamp
    final updateData = {...data, 'updated_at': DateTime.now().toIso8601String()};
    final result = await _client
        .from(tableName)
        .update(updateData)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(result as Map);
  }

  /// Bulk toggle active/inactive status.
  Future<void> bulkToggleActive(
    String tableName,
    List<String> ids, {
    required bool isActive,
  }) async {
    await _client
        .from(tableName)
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .inFilter('id', ids);
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Soft delete (set deleted_at timestamp).
  Future<void> softDeleteEntity(String tableName, String id) async {
    await _client.from(tableName).update({
      'deleted_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Hard delete (only for non-critical master data).
  Future<void> hardDeleteEntity(String tableName, String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }

  // ============================================
  // ACTIVATION/DEACTIVATION
  // ============================================

  /// Activate entity.
  Future<void> activateEntity(String tableName, String id) async {
    await _client.from(tableName).update({
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Deactivate entity.
  Future<void> deactivateEntity(String tableName, String id) async {
    await _client.from(tableName).update({
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Check if code exists.
  Future<bool> codeExists(
    String tableName,
    String code, {
    String? excludeId,
  }) async {
    try {
      final results = await _client
          .from(tableName)
          .select('id')
          .eq('code', code) as List;

      if (excludeId == null) {
        return results.isNotEmpty;
      }

      // Filter out the excluded ID
      return results.any((item) => item['id'] != excludeId);
    } catch (e) {
      return false;
    }
  }

  /// Check for dependencies before deletion.
  Future<bool> hasDependencies(String tableName, String id) async {
    // Mapping of tables to their dependent tables
    const dependencies = {
      'provinces': ['cities'],
      'cobs': ['lobs'],
      'pipeline_stages': ['pipeline_statuses'],
      'hvc_types': ['hvcs'],
    };

    final dependentTables = dependencies[tableName] ?? [];

    for (final depTable in dependentTables) {
      try {
        final result = await _client
            .from(depTable)
            .select('id')
            .eq(_getParentIdField(tableName), id)
            .limit(1);
        final resultList = result as List;
        if (resultList.isNotEmpty) {
          return true;
        }
      } catch (e) {
        // Continue checking other tables
      }
    }

    return false;
  }

  /// Get the parent ID field name for a table.
  String _getParentIdField(String tableName) {
    const fieldMap = {
      'provinces': 'province_id',
      'cobs': 'cob_id',
      'pipeline_stages': 'stage_id',
      'hvc_types': 'type_id',
    };
    return fieldMap[tableName] ?? '${tableName.substring(0, tableName.length - 1)}_id';
  }
}
