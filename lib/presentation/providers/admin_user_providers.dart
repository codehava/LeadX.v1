import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/remote/admin_user_remote_data_source.dart';
import '../../data/dtos/admin/user_management_dtos.dart';
import '../../data/repositories/admin_user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/admin_user_repository.dart';
import 'auth_providers.dart';

part 'admin_user_providers.g.dart';

// ============================================
// DATA SOURCE PROVIDERS
// ============================================

/// Provider for admin user remote data source.
@riverpod
AdminUserRemoteDataSource adminUserRemoteDataSource(
  AdminUserRemoteDataSourceRef ref,
) {
  final supabase = ref.watch(supabaseClientProvider);
  return AdminUserRemoteDataSource(supabase);
}

// ============================================
// REPOSITORY PROVIDERS
// ============================================

/// Provider for admin user repository.
@riverpod
AdminUserRepository adminUserRepository(AdminUserRepositoryRef ref) {
  final remoteDataSource = ref.watch(adminUserRemoteDataSourceProvider);
  return AdminUserRepositoryImpl(remoteDataSource: remoteDataSource);
}

// ============================================
// STATE PROVIDERS
// ============================================

/// Provider for all users list.
@riverpod
Future<List<User>> allUsers(AllUsersRef ref) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getAllUsers();
}

/// Provider for users filtered by role.
@riverpod
Future<List<User>> usersByRole(UsersByRoleRef ref, UserRole role) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getUsersByRole(role);
}

/// Provider for users filtered by branch.
@riverpod
Future<List<User>> usersByBranch(UsersByBranchRef ref, String branchId) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getUsersByBranch(branchId);
}

/// Provider for user's subordinates.
@riverpod
Future<List<User>> userSubordinates(
  UserSubordinatesRef ref,
  String userId,
) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getSubordinates(userId);
}

/// Provider for a single user by ID.
@riverpod
Future<User?> userById(UserByIdRef ref, String userId) async {
  final users = await ref.watch(allUsersProvider.future);
  try {
    return users.firstWhere((user) => user.id == userId);
  } catch (e) {
    return null;
  }
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
  Future<UserCreateResult?> createUser(UserCreateDto dto) async {
    state = const AsyncValue.loading();

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.createUser(dto);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (createResult) {
        state = const AsyncValue.data(null);
        // Invalidate user lists to trigger refresh
        ref.invalidate(allUsersProvider);
        return createResult;
      },
    );
  }

  /// Update an existing user.
  Future<bool> updateUser(String userId, UserUpdateDto dto) async {
    state = const AsyncValue.loading();

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.updateUser(userId, dto);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = const AsyncValue.data(null);
        // Invalidate user lists to trigger refresh
        ref.invalidate(allUsersProvider);
        return true;
      },
    );
  }

  /// Deactivate a user account.
  Future<bool> deactivateUser(String userId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.deactivateUser(userId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(allUsersProvider);
        return true;
      },
    );
  }

  /// Activate a user account.
  Future<bool> activateUser(String userId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.activateUser(userId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(allUsersProvider);
        return true;
      },
    );
  }

  /// Generate a new temporary password for a user.
  Future<String?> generateTemporaryPassword(String userId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.generateTemporaryPassword(userId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (tempPassword) {
        state = const AsyncValue.data(null);
        return tempPassword;
      },
    );
  }

  /// Update user hierarchy (supervisor assignment).
  Future<bool> updateUserHierarchy(String userId, String? newParentId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.updateUserHierarchy(userId, newParentId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(userSubordinatesProvider);
        return true;
      },
    );
  }
}
