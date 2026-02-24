import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/date_time_utils.dart';

/// Remote data source for Broker operations with Supabase.
class BrokerRemoteDataSource {
  BrokerRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ==========================================
  // Broker Operations
  // ==========================================

  /// Page size for paginated fetches.
  static const int _pageSize = 500;

  /// Fetch brokers from Supabase for incremental sync.
  /// When [since] is null, performs a full sync (only non-deleted records).
  /// When [since] is provided, fetches records updated OR deleted since that time.
  /// Uses pagination to handle large datasets (1000+ records).
  Future<List<Map<String, dynamic>>> fetchBrokers({DateTime? since}) async {
    final allResults = <Map<String, dynamic>>[];
    var offset = 0;
    var hasMore = true;

    while (hasMore) {
      var query = _supabase.from('brokers').select();

      if (since != null) {
        // Delta sync: fetch updated OR deleted since last sync
        query = query.or('updated_at.gt.${since.toUtcIso8601()},deleted_at.gt.${since.toUtcIso8601()}');
      } else {
        // Full sync: only non-deleted records
        query = query.isFilter('deleted_at', null);
      }

      // Add ordering for consistent pagination and fetch page
      final response = await query
          .order('created_at', ascending: true)
          .range(offset, offset + _pageSize - 1);

      final pageData = List<Map<String, dynamic>>.from(response as List);
      allResults.addAll(pageData);

      // Check if there are more results
      hasMore = pageData.length == _pageSize;
      offset += _pageSize;
    }

    return allResults;
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
      'deleted_at': DateTime.now().toUtcIso8601(),
      'updated_at': DateTime.now().toUtcIso8601(),
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
