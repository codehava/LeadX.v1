import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/admin_user_repository.dart';
import '../datasources/remote/admin_user_remote_data_source.dart';
import '../dtos/admin/user_management_dtos.dart';

/// Implementation of [AdminUserRepository] using direct Supabase operations.
///
/// Pattern: Direct remote operations (no sync queue) for admin actions.
/// Admin operations require immediate feedback and are infrequent.
class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserRemoteDataSource _remoteDataSource;

  AdminUserRepositoryImpl({
    required AdminUserRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ============================================
  // LIST & SEARCH
  // ============================================

  @override
  Future<List<User>> getAllUsers({
    bool includeInactive = false,
    bool includeDeleted = false,
  }) async {
    try {
      final usersData = await _remoteDataSource.fetchAllUsers(
        includeInactive: includeInactive,
        includeDeleted: includeDeleted,
      );

      return usersData.map((data) => _mapToUser(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      final usersData = await _remoteDataSource.searchUsers(query);
      return usersData.map((data) => _mapToUser(data)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final roleString = _roleToString(role);
      final usersData = await _remoteDataSource.fetchUsersByRole(roleString);
      return usersData.map((data) => _mapToUser(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

  @override
  Future<List<User>> getUsersByBranch(String branchId) async {
    try {
      final usersData = await _remoteDataSource.fetchUsersByBranch(branchId);
      return usersData.map((data) => _mapToUser(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by branch: $e');
    }
  }

  // ============================================
  // CREATE USER
  // ============================================

  @override
  Future<Result<UserCreateResult>> createUser(
      UserCreateDto dto) => runCatching(() async {
      final result = await _remoteDataSource.createUser(
        email: dto.email,
        name: dto.name,
        nip: dto.nip,
        role: _roleToString(dto.role),
        phone: dto.phone,
        parentId: dto.parentId,
        branchId: dto.branchId,
        regionalOfficeId: dto.regionalOfficeId,
      );

      final user = _mapToUser(result['user'] as Map<String, dynamic>);
      final tempPassword = result['temporaryPassword'] as String;

      return UserCreateResult(
        user: user,
        temporaryPassword: tempPassword,
      );
  }, context: 'createUser');

  // ============================================
  // UPDATE USER
  // ============================================

  @override
  Future<Result<User>> updateUser(
    String userId,
    UserUpdateDto dto,
  ) => runCatching(() async {
      final updates = <String, dynamic>{};

      if (dto.name != null) updates['name'] = dto.name;
      if (dto.nip != null) updates['nip'] = dto.nip;
      if (dto.phone != null) updates['phone'] = dto.phone;
      if (dto.role != null) updates['role'] = _roleToString(dto.role!);
      if (dto.parentId != null) updates['parent_id'] = dto.parentId;
      if (dto.branchId != null) updates['branch_id'] = dto.branchId;
      if (dto.regionalOfficeId != null) {
        updates['regional_office_id'] = dto.regionalOfficeId;
      }

      final userData = await _remoteDataSource.updateUser(userId, updates);
      return _mapToUser(userData);
  }, context: 'updateUser');

  // ============================================
  // ACTIVATE/DEACTIVATE
  // ============================================

  @override
  Future<Result<void>> deactivateUser(String userId) => runCatching(() async {
      await _remoteDataSource.deactivateUser(userId);
  }, context: 'deactivateUser');

  @override
  Future<Result<void>> activateUser(String userId) => runCatching(() async {
      await _remoteDataSource.activateUser(userId);
  }, context: 'activateUser');

  @override
  Future<Result<void>> deleteUser(
    String userId,
    String newRmId,
  ) => runCatching(() async {
      await _remoteDataSource.deleteUser(userId, newRmId);
  }, context: 'deleteUser');

  // ============================================
  // PASSWORD OPERATIONS
  // ============================================

  @override
  Future<Result<String>> generateTemporaryPassword(
      String userId) => runCatching(() async {
      return _remoteDataSource.generateTemporaryPassword(userId);
  }, context: 'generateTemporaryPassword');

  // ============================================
  // HIERARCHY OPERATIONS
  // ============================================

  @override
  Future<Result<void>> updateUserHierarchy(
    String userId,
    String? newParentId,
  ) => runCatching(() async {
      if (newParentId == null) {
        await _remoteDataSource.removeHierarchyLink(userId);
      } else {
        await _remoteDataSource.createHierarchyLink(userId, newParentId);
      }
  }, context: 'updateUserHierarchy');

  @override
  Future<List<User>> getSubordinates(String userId) async {
    try {
      final subordinatesData =
          await _remoteDataSource.fetchSubordinates(userId);
      return subordinatesData.map((data) => _mapToUser(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch subordinates: $e');
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Map Supabase user data to domain User entity.
  User _mapToUser(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      nip: data['nip'] as String?,
      phone: data['phone'] as String?,
      role: _parseRole(data['role'] as String),
      parentId: data['parent_id'] as String?,
      branchId: data['branch_id'] as String?,
      regionalOfficeId: data['regional_office_id'] as String?,
      photoUrl: data['photo_url'] as String?,
      isActive: data['is_active'] as bool? ?? true,
      lastLoginAt: data['last_login_at'] != null
          ? DateTime.parse(data['last_login_at'] as String)
          : null,
      deletedAt: data['deleted_at'] != null
          ? DateTime.parse(data['deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  /// Parse role string from database to UserRole enum.
  UserRole _parseRole(String role) {
    switch (role.toUpperCase()) {
      case 'SUPERADMIN':
        return UserRole.superadmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'ROH':
        return UserRole.roh;
      case 'BM':
        return UserRole.bm;
      case 'BH':
        return UserRole.bh;
      case 'RM':
        return UserRole.rm;
      default:
        return UserRole.rm; // Default fallback
    }
  }

  /// Convert UserRole enum to database string.
  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'SUPERADMIN';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.roh:
        return 'ROH';
      case UserRole.bm:
        return 'BM';
      case UserRole.bh:
        return 'BH';
      case UserRole.rm:
        return 'RM';
    }
  }
}
