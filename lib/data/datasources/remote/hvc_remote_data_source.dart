import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/date_time_utils.dart';

/// Remote data source for HVC operations with Supabase.
class HvcRemoteDataSource {
  HvcRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ==========================================
  // HVC Operations
  // ==========================================

  /// Fetch HVCs from Supabase for incremental sync.
  /// When [since] is null, performs a full sync (only non-deleted records).
  /// When [since] is provided, fetches records updated OR deleted since that time.
  Future<List<Map<String, dynamic>>> fetchHvcs({DateTime? since}) async {
    var query = _supabase.from('hvcs').select();

    if (since != null) {
      // Delta sync: fetch updated OR deleted since last sync
      query = query.or('updated_at.gt.${since.toUtcIso8601()},deleted_at.gt.${since.toUtcIso8601()}');
    } else {
      // Full sync: only non-deleted records
      query = query.isFilter('deleted_at', null);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Create a new HVC.
  Future<Map<String, dynamic>> createHvc(Map<String, dynamic> payload) async {
    final response = await _supabase.from('hvcs').insert(payload).select().single();
    return response;
  }

  /// Update an existing HVC.
  Future<Map<String, dynamic>> updateHvc(
      String id, Map<String, dynamic> payload) async {
    final response = await _supabase
        .from('hvcs')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Soft delete an HVC.
  Future<void> deleteHvc(String id) async {
    await _supabase.from('hvcs').update({
      'deleted_at': DateTime.now().toUtcIso8601(),
      'updated_at': DateTime.now().toUtcIso8601(),
    }).eq('id', id);
  }

  // ==========================================
  // HVC Type Operations (Master Data)
  // ==========================================

  /// Fetch all active HVC types.
  Future<List<Map<String, dynamic>>> fetchHvcTypes() async {
    final response = await _supabase
        .from('hvc_types')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return List<Map<String, dynamic>>.from(response as List);
  }

  // ==========================================
  // Customer-HVC Link Operations
  // ==========================================

  /// Fetch customer-HVC links for incremental sync.
  /// When [since] is null, performs a full sync (only non-deleted records).
  /// When [since] is provided, fetches records updated OR deleted since that time.
  Future<List<Map<String, dynamic>>> fetchCustomerHvcLinks({
    DateTime? since,
  }) async {
    var query = _supabase.from('customer_hvc_links').select();

    if (since != null) {
      // Delta sync: fetch updated OR deleted since last sync
      query = query.or('updated_at.gt.${since.toUtcIso8601()},deleted_at.gt.${since.toUtcIso8601()}');
    } else {
      // Full sync: only non-deleted records
      query = query.isFilter('deleted_at', null);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetch links for a specific HVC with customer details.
  Future<List<Map<String, dynamic>>> fetchLinkedCustomers(String hvcId) async {
    final response = await _supabase
        .from('customer_hvc_links')
        .select('*, customers(id, code, name)')
        .eq('hvc_id', hvcId)
        .isFilter('deleted_at', null);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Fetch links for a specific customer with HVC details.
  Future<List<Map<String, dynamic>>> fetchCustomerHvcs(String customerId) async {
    final response = await _supabase
        .from('customer_hvc_links')
        .select('*, hvcs(id, code, name)')
        .eq('customer_id', customerId)
        .isFilter('deleted_at', null);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Create a customer-HVC link.
  Future<Map<String, dynamic>> createLink(Map<String, dynamic> payload) async {
    final response = await _supabase
        .from('customer_hvc_links')
        .insert(payload)
        .select()
        .single();
    return response;
  }

  /// Delete (soft) a customer-HVC link.
  Future<void> deleteLink(String id) async {
    await _supabase.from('customer_hvc_links').update({
      'deleted_at': DateTime.now().toUtcIso8601(),
      'updated_at': DateTime.now().toUtcIso8601(),
    }).eq('id', id);
  }

  /// Upsert HVC (for sync).
  Future<void> upsertHvc(Map<String, dynamic> payload) async {
    await _supabase.from('hvcs').upsert(payload);
  }

  /// Upsert customer-HVC link (for sync).
  Future<void> upsertLink(Map<String, dynamic> payload) async {
    await _supabase.from('customer_hvc_links').upsert(payload);
  }
}
