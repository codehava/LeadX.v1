import 'dart:math';

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
  Future<List<Map<String, dynamic>>> fetchAllUsers({
    bool includeInactive = false,
  }) async {
    var query = _client.from('users').select();

    if (!includeInactive) {
      query = query.eq('is_active', true);
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
    // Generate temporary password
    final tempPassword = _generatePassword();

    // Create auth user using Supabase Admin API
    final authResponse = await _client.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: tempPassword,
        emailConfirm: true, // Auto-confirm email
        userMetadata: {
          'must_change_password': true,
        },
      ),
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create auth user');
    }

    final userId = authResponse.user!.id;

    // Create user profile in users table
    final userData = {
      'id': userId,
      'email': email,
      'name': name,
      'nip': nip,
      'role': role,
      'phone': phone,
      'branch_id': branchId,
      'regional_office_id': regionalOfficeId,
      'is_active': true,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _client.from('users').insert(userData);

    // Create hierarchy entry if supervisor is specified
    if (parentId != null) {
      await createHierarchyLink(userId, parentId);
    }

    // Fetch the created user with all relations
    final createdUser = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return {
      'user': createdUser,
      'temporaryPassword': tempPassword,
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
  Future<String> generateTemporaryPassword(String userId) async {
    final tempPassword = _generatePassword();

    // Update password using Admin API
    await _client.auth.admin.updateUserById(
      userId,
      attributes: AdminUserAttributes(
        password: tempPassword,
        userMetadata: {
          'must_change_password': true,
        },
      ),
    );

    return tempPassword;
  }

  // ============================================
  // HIERARCHY OPERATIONS
  // ============================================

  /// Create a hierarchy link between user and supervisor.
  Future<void> createHierarchyLink(String userId, String parentId) async {
    // Check if link already exists
    final existing = await _client
        .from('user_hierarchy')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      await _client.from('user_hierarchy').update({
        'parent_id': parentId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('user_id', userId);
    } else {
      // Create new
      await _client.from('user_hierarchy').insert({
        'user_id': userId,
        'parent_id': parentId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  /// Remove hierarchy link for a user.
  Future<void> removeHierarchyLink(String userId) async {
    await _client.from('user_hierarchy').delete().eq('user_id', userId);
  }

  /// Fetch subordinates of a user.
  Future<List<Map<String, dynamic>>> fetchSubordinates(String userId) async {
    // Get user IDs from hierarchy table
    final hierarchyResult = await _client
        .from('user_hierarchy')
        .select('user_id')
        .eq('parent_id', userId);

    final subordinateIds = hierarchyResult
        .map<String>((row) => row['user_id'] as String)
        .toList();

    if (subordinateIds.isEmpty) {
      return [];
    }

    // Fetch user details
    final usersResult = await _client
        .from('users')
        .select()
        .inFilter('id', subordinateIds)
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(usersResult);
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Generate a random 12-character password with mixed case, numbers, and symbols.
  String _generatePassword() {
    const length = 12;
    const chars =
        r'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%';
    final random = Random.secure();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
