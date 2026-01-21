import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leadx_crm/core/errors/failures.dart';
import 'package:leadx_crm/domain/entities/app_auth_state.dart';
import 'package:leadx_crm/domain/entities/user.dart';
import 'package:leadx_crm/domain/repositories/auth_repository.dart';
import 'package:leadx_crm/presentation/providers/auth_providers.dart';

/// A fake implementation of [AuthRepository] for testing purposes.
/// Allows controlling authentication state and responses in tests.
class FakeAuthRepository implements AuthRepository {
  bool _isAuthenticated = false;
  User? _currentUser;
  AuthSession? _currentSession;
  final _authStateController = StreamController<AppAuthState>.broadcast();

  // Control test behavior
  bool shouldSignInSucceed = true;
  bool shouldSignOutSucceed = true;
  bool shouldRefreshSucceed = true;
  bool shouldPasswordResetSucceed = true;
  String? signInErrorMessage;
  User? signInUser;

  /// Creates a fake repository with an optional initial user.
  FakeAuthRepository({User? initialUser}) {
    if (initialUser != null) {
      _currentUser = initialUser;
      _isAuthenticated = true;
      _currentSession = AuthSession(
        accessToken: 'fake-access-token',
        refreshToken: 'fake-refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: initialUser,
      );
    }
  }

  /// Sets the authenticated state for testing.
  void setAuthenticated(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    _currentSession = AuthSession(
      accessToken: 'fake-access-token',
      refreshToken: 'fake-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      user: user,
    );
    _authStateController.add(AppAuthState.authenticated(user));
  }

  /// Sets the unauthenticated state for testing.
  void setUnauthenticated() {
    _currentUser = null;
    _isAuthenticated = false;
    _currentSession = null;
    _authStateController.add(const AppAuthState.unauthenticated());
  }

  @override
  Future<AppAuthState> getAuthState() async {
    if (_isAuthenticated && _currentUser != null) {
      return AppAuthState.authenticated(_currentUser!);
    }
    return const AppAuthState.unauthenticated();
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    if (!shouldSignInSucceed) {
      return Left(AuthFailure(
        message: signInErrorMessage ?? 'Email atau password salah',
      ));
    }

    final user = signInUser ?? createTestUser(email: email);
    setAuthenticated(user);
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (!shouldSignOutSucceed) {
      return const Left(AuthFailure(message: 'Sign out failed'));
    }

    setUnauthenticated();
    return const Right(null);
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<Either<Failure, AuthSession>> refreshSession() async {
    if (!shouldRefreshSucceed || _currentSession == null) {
      return const Left(AuthFailure(message: 'Session refresh failed'));
    }
    return Right(_currentSession!);
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!shouldPasswordResetSucceed) {
      return const Left(AuthFailure(message: 'Password reset failed'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  }) async {
    return const Right(null);
  }

  @override
  Stream<AppAuthState> authStateChanges() => _authStateController.stream;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  AuthSession? get currentSession => _currentSession;

  void dispose() {
    _authStateController.close();
  }
}

/// Creates a test user with customizable properties.
User createTestUser({
  String id = 'test-user-id',
  String email = 'test@example.com',
  String name = 'Test User',
  UserRole role = UserRole.rm,
  bool isActive = true,
}) {
  return User(
    id: id,
    email: email,
    name: name,
    nip: '12345',
    phone: '+6281234567890',
    role: role,
    parentId: null,
    branchId: 'branch-1',
    regionalOfficeId: 'ro-1',
    photoUrl: null,
    isActive: isActive,
    lastLoginAt: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Creates a [ProviderScope] configured for testing with mocked providers.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   createTestApp(
///     child: const LoginScreen(),
///     fakeAuthRepository: FakeAuthRepository(),
///   ),
/// );
/// ```
Widget createTestApp({
  required Widget child,
  FakeAuthRepository? fakeAuthRepository,
  List<Override> additionalOverrides = const [],
}) {
  final authRepo = fakeAuthRepository ?? FakeAuthRepository();

  return ProviderScope(
    overrides: [
      // Override auth repository with fake
      authRepositoryProvider.overrideWithValue(authRepo),
      // Override auth state to use fake repository's stream
      authStateProvider.overrideWith((ref) {
        return authRepo.authStateChanges();
      }),
      // Override current user provider
      currentUserProvider.overrideWith((ref) async {
        return authRepo.getCurrentUser();
      }),
      // Override isAuthenticated
      isAuthenticatedProvider.overrideWith((ref) {
        return authRepo.isAuthenticated;
      }),
      ...additionalOverrides,
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a test app wrapped with necessary providers for navigation testing.
Widget createTestAppWithRouter({
  required Widget child,
  FakeAuthRepository? fakeAuthRepository,
  List<Override> additionalOverrides = const [],
}) {
  final authRepo = fakeAuthRepository ?? FakeAuthRepository();

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepo),
      authStateProvider.overrideWith((ref) {
        return authRepo.authStateChanges();
      }),
      currentUserProvider.overrideWith((ref) async {
        return authRepo.getCurrentUser();
      }),
      isAuthenticatedProvider.overrideWith((ref) {
        return authRepo.isAuthenticated;
      }),
      ...additionalOverrides,
    ],
    child: MaterialApp.router(
      routerConfig: _createTestRouterConfig(child),
    ),
  );
}

// Simple router config for testing
_createTestRouterConfig(Widget child) {
  // For simple widget tests, we just return a basic MaterialApp
  // More complex navigation tests should use go_router directly
  return null; // Will use MaterialApp.home instead
}
