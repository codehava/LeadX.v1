import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for Broker operations with Supabase.
class BrokerRemoteDataSource {
  BrokerRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ==========================================
  // Broker Operations
  // ==========================================

  /// Fetch brokers from Supabase for incremental sync.
  Future<List<Map<String, dynamic>>> fetchBrokers({DateTime? since}) async {
    var query = _supabase.from('brokers').select();

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Create a new broker.
  Future<Map<String, dynamic>> createBroker(Map<String, dynamic> payload) async {
    final response =
        await _supabase.from('brokers').insert(payload).select().single();
    return response;
  }

  /// Update an existing broker.
  Future<Map<String, dynamic>> updateBroker(
      String id, Map<String, dynamic> payload) async {
    final response = await _supabase
        .from('brokers')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Soft delete a broker.
  Future<void> deleteBroker(String id) async {
    await _supabase.from('brokers').update({
      'deleted_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  /// Upsert broker (for sync).
  Future<void> upsertBroker(Map<String, dynamic> payload) async {
    await _supabase.from('brokers').upsert(payload);
  }

  // ==========================================
  // Key Person Operations (Broker PICs)
  // ==========================================

  /// Fetch key persons for a broker.
  Future<List<Map<String, dynamic>>> fetchBrokerKeyPersons(
      String brokerId) async {
    final response = await _supabase
        .from('key_persons')
        .select()
        .eq('broker_id', brokerId)
        .eq('owner_type', 'BROKER')
        .isFilter('deleted_at', null);
    return List<Map<String, dynamic>>.from(response as List);
  }

  // ==========================================
  // Pipeline Operations
  // ==========================================

  /// Fetch pipelines for a broker.
  Future<List<Map<String, dynamic>>> fetchBrokerPipelines(
      String brokerId) async {
    final response = await _supabase
        .from('pipelines')
        .select('*, pipeline_stages(name, color), cobs(name), lobs(name)')
        .eq('broker_id', brokerId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }
}
