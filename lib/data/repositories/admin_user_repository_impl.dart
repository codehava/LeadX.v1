import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
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
  Future<List<User>> getAllUsers({bool includeInactive = false}) async {
    try {
      final usersData = await _remoteDataSource.fetchAllUsers(
        includeInactive: includeInactive,
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
  Future<Either<Failure, UserCreateResult>> createUser(
      UserCreateDto dto) async {
    try {
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

      return Right(
        UserCreateResult(
          user: user,
          temporaryPassword: tempPassword,
        ),
      );
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Gagal membuat pengguna: $e',
          originalError: e,
        ),
      );
    }
  }

  // ============================================
  // UPDATE USER
  // ============================================

  @override
  Future<Either<Failure, User>> updateUser(
    String userId,
    UserUpdateDto dto,
  ) async {
    try {
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
      final user = _mapToUser(userData);

      return Right(user);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Gagal memperbarui pengguna',
          originalError: e,
        ),
      );
    }
  }

  // ============================================
  // ACTIVATE/DEACTIVATE
  // ============================================

  @override
  Future<Either<Failure, void>> deactivateUser(String userId) async {
    try {
      await _remoteDataSource.deactivateUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Gagal menonaktifkan pengguna',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> activateUser(String userId) async {
    try {
      await _remoteDataSource.activateUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Gagal mengaktifkan pengguna',
          originalError: e,
        ),
      );
    }
  }

  // ============================================
  // PASSWORD OPERATIONS
  // ============================================

  @override
  Future<Either<Failure, String>> generateTemporaryPassword(
      String userId) async {
    try {
      final tempPassword =
          await _remoteDataSource.generateTemporaryPassword(userId);
      return Right(tempPassword);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Gagal membuat password sementara',
          originalError: e,
        ),
      );
    }
  }

  // ============================================
  // HIERARCHY OPERATIONS
  // ============================================

  @override
  Future<Either<Failure, void>> updateUserHierarchy(
    String userId,
    String? newParentId,
  ) async {
    try {
      if (newParentId == null) {
        await _remoteDataSource.removeHierarchyLink(userId);
      } else {
        await _remoteDataSource.createHierarchyLink(userId, newParentId);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Gagal memperbarui hierarki',
          originalError: e,
        ),
      );
    }
  }

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
