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

  /// Find the approver for a given user based on hierarchy.
  /// Returns the approver user record and type (BM or ROH).
  ///
  /// Logic:
  /// 1. Get receiver user to check branch_id
  /// 2. If receiver has branch_id, find BM in hierarchy
  /// 3. If no BM found (or no branch), find ROH in hierarchy
  /// 4. If ROH not in hierarchy, find ROH by regional_office_id
  Future<Map<String, dynamic>?> findApproverForUser(String userId) async {
    // First, get the user to check their branch and regional office
    final user = await _client
        .from('users')
        .select('id, branch_id, regional_office_id')
        .eq('id', userId)
        .maybeSingle();

    if (user == null) return null;

    final branchId = user['branch_id'] as String?;
    final regionalOfficeId = user['regional_office_id'] as String?;

    // Get all ancestors from user_hierarchy
    final hierarchyResult = await _client
        .from('user_hierarchy')
        .select('ancestor_id')
        .eq('descendant_id', userId)
        .gt('depth', 0)
        .order('depth', ascending: true);

    final ancestorIds = (hierarchyResult as List)
        .map((e) => e['ancestor_id'] as String)
        .toList();

    if (ancestorIds.isEmpty) {
      // No hierarchy found, try regional office fallback
      return _findRohByRegionalOffice(regionalOfficeId);
    }

    // Step 1: If user has a branch, try to find BM in hierarchy
    if (branchId != null && branchId.isNotEmpty) {
      final bmResult = await _client
          .from('users')
          .select('id, name, role')
          .eq('role', 'BM')
          .eq('is_active', true)
          .inFilter('id', ancestorIds)
          .limit(1)
          .maybeSingle();

      if (bmResult != null) {
        return {
          'approver_id': bmResult['id'],
          'approver_name': bmResult['name'],
          'approver_type': 'BM',
        };
      }
    }

    // Step 2: Try to find ROH in hierarchy
    final rohResult = await _client
        .from('users')
        .select('id, name, role')
        .eq('role', 'ROH')
        .eq('is_active', true)
        .inFilter('id', ancestorIds)
        .limit(1)
        .maybeSingle();

    if (rohResult != null) {
      return {
        'approver_id': rohResult['id'],
        'approver_name': rohResult['name'],
        'approver_type': 'ROH',
      };
    }

    // Step 3: Fallback - find ROH by regional_office_id
    return _findRohByRegionalOffice(regionalOfficeId);
  }

  /// Helper to find ROH by regional office ID.
  Future<Map<String, dynamic>?> _findRohByRegionalOffice(
    String? regionalOfficeId,
  ) async {
    if (regionalOfficeId == null || regionalOfficeId.isEmpty) {
      return null;
    }

    final rohByRegion = await _client
        .from('users')
        .select('id, name, role')
        .eq('role', 'ROH')
        .eq('is_active', true)
        .eq('regional_office_id', regionalOfficeId)
        .limit(1)
        .maybeSingle();

    if (rohByRegion != null) {
      return {
        'approver_id': rohByRegion['id'],
        'approver_name': rohByRegion['name'],
        'approver_type': 'ROH',
      };
    }

    return null;
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
        .select('id, name, code')
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
