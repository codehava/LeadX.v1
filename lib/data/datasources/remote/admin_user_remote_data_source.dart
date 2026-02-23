import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for admin user management operations.
///
/// Handles direct Supabase operations for user CRUD, including
/// Supabase Auth API for user creation and password management.
class AdminUserRemoteDataSource {
  final SupabaseClient _client;

  AdminUserRemoteDataSource(this._client);

  // ============================================
  // LIST & SEARCH
  // ============================================

  /// Fetch all users from Supabase.
  ///
  /// By default filters out inactive and soft-deleted users.
  Future<List<Map<String, dynamic>>> fetchAllUsers({
    bool includeInactive = false,
    bool includeDeleted = false,
  }) async {
    var query = _client.from('users').select();

    if (!includeInactive) {
      query = query.eq('is_active', true);
    }

    if (!includeDeleted) {
      query = query.isFilter('deleted_at', null);
    }

    final result = await query.order('name');
    return List<Map<String, dynamic>>.from(result);
  }

  /// Search users by name, email, or NIP.
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final result = await _client
        .from('users')
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%,nip.ilike.%$query%')
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(result);
  }

  /// Fetch users by role.
  Future<List<Map<String, dynamic>>> fetchUsersByRole(String role) async {
    final result = await _client
        .from('users')
        .select()
        .eq('role', role)
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(result);
  }

  /// Fetch users by branch.
  Future<List<Map<String, dynamic>>> fetchUsersByBranch(String branchId) async {
    final result = await _client
        .from('users')
        .select()
        .eq('branch_id', branchId)
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(result);
  }

  // ============================================
  // CREATE USER
  // ============================================

  /// Create a new user in Supabase Auth and users table.
  ///
  /// Returns a map with 'user' data and 'temporaryPassword'.
  /// Uses Edge Function for server-side user creation with service_role key.
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String name,
    required String nip,
    required String role,
    String? phone,
    String? parentId,
    String? branchId,
    String? regionalOfficeId,
  }) async {
    // Call Edge Function to create user
    final response = await _client.functions.invoke(
      'admin-create-user',
      body: {
        'email': email,
        'name': name,
        'nip': nip,
        'role': role,
        'phone': phone,
        'parentId': parentId,
        'branchId': branchId,
        'regionalOfficeId': regionalOfficeId,
      },
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Unknown error';
      throw Exception('Failed to create user: $error');
    }

    return {
      'user': response.data['user'],
      'temporaryPassword': response.data['temporaryPassword'],
    };
  }

  // ============================================
  // UPDATE USER
  // ============================================

  /// Update user information in users table.
  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final updateData = {
      ...updates,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _client.from('users').update(updateData).eq('id', userId);

    // Fetch updated user
    final updatedUser = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return updatedUser;
  }

  // ============================================
  // ACTIVATE/DEACTIVATE
  // ============================================

  /// Deactivate a user account.
  Future<void> deactivateUser(String userId) async {
    await _client.from('users').update({
      'is_active': false,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  /// Activate a user account.
  Future<void> activateUser(String userId) async {
    await _client.from('users').update({
      'is_active': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  // ============================================
  // PASSWORD OPERATIONS
  // ============================================

  /// Generate a new temporary password and update user.
  /// Uses Edge Function for server-side password reset with service_role key.
  Future<String> generateTemporaryPassword(String userId) async {
    // Call Edge Function to reset password
    final response = await _client.functions.invoke(
      'admin-reset-password',
      body: {
        'userId': userId,
      },
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Unknown error';
      throw Exception('Failed to reset password: $error');
    }

    return response.data['temporaryPassword'] as String;
  }

  // ============================================
  // DELETE USER
  // ============================================

  /// Delete a user and reassign their data to a new RM.
  ///
  /// Uses Edge Function for server-side cascade deletion:
  /// reassign subordinates, transfer business data, soft-delete, ban auth.
  Future<void> deleteUser(String userId, String newRmId) async {
    final response = await _client.functions.invoke(
      'admin-delete-user',
      body: {
        'userId': userId,
        'newRmId': newRmId,
      },
    );

    if (response.status != 200) {
      final error = response.data['error'] ?? 'Unknown error';
      throw Exception('Failed to delete user: $error');
    }
  }

  // ============================================
  // HIERARCHY OPERATIONS
  // ============================================

  /// Create a hierarchy link between user and supervisor.
  Future<void> createHierarchyLink(String userId, String parentId) async {
    // Update user's parent_id in users table
    await _client.from('users').update({
      'parent_id': parentId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  /// Remove hierarchy link for a user.
  Future<void> removeHierarchyLink(String userId) async {
    // Clear parent_id in users table
    await _client.from('users').update({
      'parent_id': null,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
  }

  /// Fetch subordinates of a user.
  Future<List<Map<String, dynamic>>> fetchSubordinates(String userId) async {
    // Query users table directly for direct subordinates (parent_id = userId)
    final result = await _client
        .from('users')
        .select()
        .eq('parent_id', userId)
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(result);
  }

}
