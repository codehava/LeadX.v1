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
@riverpod
Future<List<User>> allUsers(Ref ref) async {
  final repository = ref.watch(adminUserRepositoryProvider);
  return repository.getAllUsers();
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
@riverpod
Future<User?> userById(Ref ref, String userId) async {
  final users = await ref.watch(allUsersProvider.future);
  try {
    return users.firstWhere((user) => user.id == userId);
  } catch (e) {
    return null;
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

    return result.fold(
      (failure) => throw Exception(failure.message),
      (createResult) {
        ref.invalidate(allUsersProvider);
        return createResult;
      },
    );
  }

  /// Update an existing user.
  /// Throws exception on failure.
  Future<void> updateUser(String userId, UserUpdateDto dto) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.updateUser(userId, dto);

    result.fold(
      (failure) => throw Exception(failure.message),
      (user) => ref.invalidate(allUsersProvider),
    );
  }

  /// Deactivate a user account.
  /// Throws exception on failure.
  Future<void> deactivateUser(String userId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.deactivateUser(userId);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidate(allUsersProvider),
    );
  }

  /// Activate a user account.
  /// Throws exception on failure.
  Future<void> activateUser(String userId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.activateUser(userId);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidate(allUsersProvider),
    );
  }

  /// Generate a new temporary password for a user.
  /// Throws exception on failure.
  Future<String> generateTemporaryPassword(String userId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.generateTemporaryPassword(userId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (tempPassword) => tempPassword,
    );
  }

  /// Update user hierarchy (supervisor assignment).
  /// Throws exception on failure.
  Future<void> updateUserHierarchy(String userId, String? newParentId) async {
    final repository = ref.read(adminUserRepositoryProvider);
    final result = await repository.updateUserHierarchy(userId, newParentId);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidate(userSubordinatesProvider),
    );
  }
}
