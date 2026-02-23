import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/result.dart';
import '../../data/datasources/remote/admin_user_remote_data_source.dart';
import '../../data/dtos/admin/user_management_dtos.dart';
import '../../data/repositories/admin_user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/admin_user_repository.dart';
import 'auth_providers.dart';

part 'admin_user_providers.g.dart';

/// State provider controlling whether deleted users are shown in user list.
final showDeletedUsersProvider = StateProvider<bool>((ref) => false);

// ============================================
// DATA SOURCE PROVIDERS
// ============================================

/// Provider for admin user remote data source.
@riverpod
AdminUserRemoteDataSource adminUserRemoteDataSource(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AdminUserRemoteDataSource(supabase);
}

// ============================================
// REPOSITORY PROVIDERS
// ============================================

/// Provider for admin user repository.
@riverpod
AdminUserRepository adminUserRepository(Ref ref) {
  final remoteDataSource = ref.watch(adminUserRemoteDataSourceProvider);
  return AdminUserRepositoryImpl(remoteDataSource: remoteDataSource);
}

// ============================================
// STATE PROVIDERS
// ============================================

/// Provider for all users list.
///
/// Watches [showDeletedUsersProvider] to optionally include soft-deleted users.
/// When includeDeleted is true, also includes inactive users so deleted users
/// (who are always inactive) appear in results.
@riverpod
Future<List<User>> allUsers(Ref ref) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  final showDeleted = ref.watch(showDeletedUsersProvider);
  return repository.getAllUsers(
    includeDeleted: showDeleted,
    includeInactive: showDeleted,
  );
}

/// Provider for active (non-deleted) users only.
///
/// Used by the delete dialog RM picker to show only eligible replacement RMs.
/// Always excludes deleted and inactive users regardless of filter toggle.
@riverpod
Future<List<User>> activeUsers(Ref ref) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getAllUsers(
    includeDeleted: false,
    includeInactive: false,
  );
}

/// Provider for users filtered by role.
@riverpod
Future<List<User>> usersByRole(Ref ref, UserRole role) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getUsersByRole(role);
}

/// Provider for users filtered by branch.
@riverpod
Future<List<User>> usersByBranch(Ref ref, String branchId) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getUsersByBranch(branchId);
}

/// Provider for user's subordinates.
@riverpod
Future<List<User>> userSubordinates(Ref ref, String userId) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getSubordinates(userId);
}

/// Provider for a single user by ID.
///
/// Searches the current allUsers list. If the user is not found (e.g., they
/// are deleted and the filter is off), fetches all users including deleted
/// to find them.
@riverpod
Future<User?> userById(Ref ref, String userId) async {
  final users = await ref.watch(allUsersProvider.future);
  try {
    return users.firstWhere((user) => user.id == userId);
  } catch (_) {
    // User not found in current list — may be deleted.
    // Fetch with includeDeleted to find them.
    final repository = ref.read(adminUserRepositoryProvider);
    final allWithDeleted = await repository.getAllUsers(
      includeDeleted: true,
      includeInactive: true,
    );
    try {
      return allWithDeleted.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }
}

/// Provider to get supervisor name by user ID.
@riverpod
Future<String?> supervisorName(Ref ref, String? userId) async {
  if (userId == null || userId.isEmpty) {
    return null;
  }
  final user = await ref.watch(userByIdProvider(userId).future);
  return user?.name;
}

// ============================================
// NOTIFIER FOR USER CRUD OPERATIONS
// ============================================

/// State for user management operations.
@riverpod
class AdminUserNotifier extends _$AdminUserNotifier {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  /// Create a new user.
  ///
  /// Returns [UserCreateResult] on success with temporary password.
  /// Throws exception on failure.
  Future<UserCreateResult> createUser(UserCreateDto dto) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.createUser(dto);

    switch (result) {
      case Success(:final value):
        ref.invalidate(allUsersProvider);
        return value;
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }

  /// Update an existing user.
  /// Throws exception on failure.
  Future<void> updateUser(String userId, UserUpdateDto dto) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.updateUser(userId, dto);

    switch (result) {
      case Success():
        ref.invalidate(allUsersProvider);
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }

  /// Deactivate a user account.
  /// Throws exception on failure.
  Future<void> deactivateUser(String userId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.deactivateUser(userId);

    switch (result) {
      case Success():
        ref.invalidate(allUsersProvider);
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }

  /// Activate a user account.
  /// Throws exception on failure.
  Future<void> activateUser(String userId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.activateUser(userId);

    switch (result) {
      case Success():
        ref.invalidate(allUsersProvider);
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }

  /// Delete a user and reassign all business data to a new RM.
  /// Throws exception on failure.
  Future<void> deleteUser(String userId, String newRmId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.deleteUser(userId, newRmId);

    switch (result) {
      case Success():
        ref.invalidate(allUsersProvider);
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }

  /// Generate a new temporary password for a user.
  /// Throws exception on failure.
  Future<String> generateTemporaryPassword(String userId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.generateTemporaryPassword(userId);

    switch (result) {
      case Success(:final value):
        return value;
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }

  /// Update user hierarchy (supervisor assignment).
  /// Throws exception on failure.
  Future<void> updateUserHierarchy(String userId, String? newParentId) async {
    // Get old parent before update to invalidate their subordinates list
    final oldUser = await ref.read(userByIdProvider(userId).future);
    final oldParentId = oldUser?.parentId;

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.updateUserHierarchy(userId, newParentId);

    switch (result) {
      case Success():
        // Invalidate all users to refresh hierarchy data
        ref.invalidate(allUsersProvider);
        // Invalidate the specific user being updated
        ref.invalidate(userByIdProvider(userId));
        // Invalidate old supervisor's subordinates list
        if (oldParentId != null) {
          ref.invalidate(userSubordinatesProvider(oldParentId));
        }
        // Invalidate new supervisor's subordinates list
        if (newParentId != null) {
          ref.invalidate(userSubordinatesProvider(newParentId));
        }
      case ResultFailure(:final failure):
        throw Exception(failure.message);
    }
  }
}
