import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for pipeline referral operations via Supabase.
class PipelineReferralRemoteDataSource {
  PipelineReferralRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Fetch all referrals, optionally filtered by updatedAt for incremental sync.
  /// Returns raw JSON data from Supabase.
  Future<List<Map<String, dynamic>>> fetchReferrals({DateTime? since}) async {
    var query = _client.from('pipeline_referrals').select();

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch referrals sent by a user (outbound).
  Future<List<Map<String, dynamic>>> fetchByReferrer(
    String userId, {
    DateTime? since,
  }) async {
    var query = _client
        .from('pipeline_referrals')
        .select()
        .eq('referrer_rm_id', userId);

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch referrals received by a user (inbound).
  Future<List<Map<String, dynamic>>> fetchByReceiver(
    String userId, {
    DateTime? since,
  }) async {
    var query = _client
        .from('pipeline_referrals')
        .select()
        .eq('receiver_rm_id', userId);

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch referrals pending approval (RECEIVER_ACCEPTED status).
  Future<List<Map<String, dynamic>>> fetchPendingApprovals({
    DateTime? since,
  }) async {
    var query = _client
        .from('pipeline_referrals')
        .select()
        .eq('status', 'RECEIVER_ACCEPTED');

    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch a single referral by ID.
  Future<Map<String, dynamic>?> fetchReferralById(String id) async {
    final response = await _client
        .from('pipeline_referrals')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Create a new referral on the server.
  /// Returns the created referral data.
  Future<Map<String, dynamic>> createReferral(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('pipeline_referrals')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update an existing referral on the server.
  /// Returns the updated referral data.
  Future<Map<String, dynamic>> updateReferral(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('pipeline_referrals')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Upsert a referral (insert or update based on ID).
  Future<Map<String, dynamic>> upsertReferral(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('pipeline_referrals')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  // ==========================================
  // Approver Determination
  // ==========================================

  /// Find the approver for a given user based on direct atasan (parent_id).
  /// Returns the approver user record and type (BM or ROH).
  ///
  /// Uses PostgreSQL function `get_user_atasan` which bypasses RLS
  /// to allow looking up the parent user in the hierarchy.
  Future<Map<String, dynamic>?> findApproverForUser(String userId) async {
    try {
      // Call the SECURITY DEFINER function that bypasses RLS
      final result = await _client.rpc(
        'get_user_atasan',
        params: {'p_user_id': userId},
      );

      if (result == null) return null;

      // Result is already a map with approver_id, approver_name, approver_type
      return {
        'approver_id': result['approver_id'] as String,
        'approver_name': result['approver_name'] as String?,
        'approver_type': result['approver_type'] as String,
      };
    } catch (e) {
      print('[ReferralRemote] Error finding approver: $e');
      return null;
    }
  }

  // ==========================================
  // Helper Queries
  // ==========================================

  /// Get user info by ID.
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    return _client
        .from('users')
        .select('id, name, email, role, branch_id, regional_office_id')
        .eq('id', userId)
        .maybeSingle();
  }

  /// Get customer info by ID.
  Future<Map<String, dynamic>?> getCustomerById(String customerId) async {
    return _client
        .from('customers')
        .select('id, name, code, assigned_rm_id')
        .eq('id', customerId)
        .maybeSingle();
  }

  /// Get count of referrals by status.
  Future<int> getCountByStatus(String status) async {
    final response = await _client
        .from('pipeline_referrals')
        .select('id')
        .eq('status', status)
        .count();
    return response.count;
  }

  /// Get count of inbound referrals pending action for a user.
  Future<int> getPendingInboundCount(String userId) async {
    final response = await _client
        .from('pipeline_referrals')
        .select('id')
        .eq('receiver_rm_id', userId)
        .eq('status', 'PENDING_RECEIVER')
        .count();
    return response.count;
  }
}
