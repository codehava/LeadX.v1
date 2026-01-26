import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/dtos/admin/user_management_dtos.dart';
import '../entities/user.dart';

/// Repository interface for admin user management operations.
///
/// Provides CRUD operations for user management, hierarchy management,
/// and password operations. All operations require admin privileges.
abstract class AdminUserRepository {
  // ============================================
  // LIST & SEARCH
  // ============================================

  /// Get all users in the system.
  ///
  /// [includeInactive] - if true, includes deactivated users.
  Future<List<User>> getAllUsers({bool includeInactive = false});

  /// Search users by name, email, or NIP.
  Future<List<User>> searchUsers(String query);

  /// Get users filtered by role.
  Future<List<User>> getUsersByRole(UserRole role);

  /// Get users filtered by branch.
  Future<List<User>> getUsersByBranch(String branchId);

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  /// Create a new user with auto-generated temporary password.
  ///
  /// Returns [UserCreateResult] with user details and temporary password.
  /// The temporary password must be displayed to admin and communicated to user.
  Future<Either<Failure, UserCreateResult>> createUser(UserCreateDto dto);

  /// Update an existing user's information.
  ///
  /// Only provided fields in [dto] will be updated.
  Future<Either<Failure, User>> updateUser(String userId, UserUpdateDto dto);

  /// Deactivate a user account.
  ///
  /// Sets [isActive] to false. User cannot log in until reactivated.
  Future<Either<Failure, void>> deactivateUser(String userId);

  /// Activate a previously deactivated user account.
  ///
  /// Sets [isActive] to true.
  Future<Either<Failure, void>> activateUser(String userId);

  // ============================================
  // PASSWORD OPERATIONS
  // ============================================

  /// Generate a new temporary password for a user.
  ///
  /// Returns the temporary password. User will be forced to change on next login.
  /// Use this for password resets.
  Future<Either<Failure, String>> generateTemporaryPassword(String userId);

  // ============================================
  // HIERARCHY OPERATIONS
  // ============================================

  /// Update a user's supervisor in the hierarchy.
  ///
  /// [newParentId] - ID of the new supervisor, or null to remove supervisor.
  Future<Either<Failure, void>> updateUserHierarchy(
    String userId,
    String? newParentId,
  );

  /// Get all direct subordinates of a user.
  Future<List<User>> getSubordinates(String userId);
}
