import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/date_time_utils.dart';

/// Remote data source for pipeline operations via Supabase.
class PipelineRemoteDataSource {
  PipelineRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetch all pipelines, optionally filtered by updatedAt for incremental sync.
  /// Returns raw JSON data from Supabase.
  Future<List<Map<String, dynamic>>> fetchPipelines({DateTime? since}) async {
    var query = _client.from('pipelines').select();

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch pipelines for a specific customer.
  Future<List<Map<String, dynamic>>> fetchPipelinesByCustomer(
    String customerId, {
    DateTime? since,
  }) async {
    var query = _client
        .from('pipelines')
        .select()
        .eq('customer_id', customerId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch pipelines assigned to a specific RM.
  Future<List<Map<String, dynamic>>> fetchPipelinesByRm(
    String rmId, {
    DateTime? since,
  }) async {
    var query = _client
        .from('pipelines')
        .select()
        .eq('assigned_rm_id', rmId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single pipeline by ID.
  Future<Map<String, dynamic>?> fetchPipelineById(String id) async {
    final response = await _client
        .from('pipelines')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Create a new pipeline on the server.
  /// Returns the created pipeline data.
  Future<Map<String, dynamic>> createPipeline(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('pipelines')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing pipeline on the server.
  /// Returns the updated pipeline data.
  Future<Map<String, dynamic>> updatePipeline(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('pipelines')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Soft delete a pipeline on the server.
  Future<void> deletePipeline(String id) async {
    await _client.from('pipelines').update({
      'deleted_at': DateTime.now().toUtcIso8601(),
    }).eq('id', id);
  }

  /// Upsert a pipeline (insert or update based on ID).
  Future<Map<String, dynamic>> upsertPipeline(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('pipelines')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  /// Get count of pipelines for a customer.
  Future<int> getPipelineCountByCustomer(String customerId) async {
    final response = await _client
        .from('pipelines')
        .select('id')
        .eq('customer_id', customerId)
        .isFilter('deleted_at', null)
        .count();
    return response.count;
  }

  /// Get count of pipelines by stage.
  Future<int> getPipelineCountByStage(String stageId) async {
    final response = await _client
        .from('pipelines')
        .select('id')
        .eq('stage_id', stageId)
        .isFilter('deleted_at', null)
        .count();
    return response.count;
  }
}
