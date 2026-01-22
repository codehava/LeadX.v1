import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/errors/failures.dart';
import '../../domain/entities/app_auth_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase implementation of AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;
  
  AuthSession? _currentSession;
  User? _currentUser;
  final _authStateController = StreamController<AppAuthState>.broadcast();

  AuthRepositoryImpl(this._client) {
    // Listen to Supabase auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data);
    });
  }

  void _handleAuthStateChange(supabase.AuthState data) {
    switch (data.event) {
      case supabase.AuthChangeEvent.initialSession:
        // Session restored from storage (e.g., opening new tab)
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.signedIn:
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.signedOut:
        _currentSession = null;
        _currentUser = null;
        _authStateController.add(const AppAuthState.unauthenticated());
        break;
      case supabase.AuthChangeEvent.tokenRefreshed:
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.userUpdated:
        _fetchUserAndNotify(data.session);
        break;
      default:
        break;
    }
  }

  Future<void> _fetchUserAndNotify(supabase.Session? session) async {
    if (session == null) {
      _authStateController.add(const AppAuthState.unauthenticated());
      return;
    }

    try {
      final user = await _fetchUserProfile(session.user.id);
      _currentUser = user;
      _currentSession = AuthSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (session.expiresAt ?? 0) * 1000,
        ),
        user: user,
      );
      _authStateController.add(AppAuthState.authenticated(user));
    } catch (e) {
      _authStateController.add(AppAuthState.error(e.toString()));
    }
  }

  Future<User> _fetchUserProfile(String userId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return _mapUserFromJson(response);
  }

  User _mapUserFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      nip: json['nip'] as String?,
      phone: json['phone'] as String?,
      role: _parseRole(json['role'] as String),
      parentId: json['parent_id'] as String?,
      branchId: json['branch_id'] as String?,
      regionalOfficeId: json['regional_office_id'] as String?,
      photoUrl: json['photo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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
        return UserRole.rm;
    }
  }

  @override
  Future<AppAuthState> getAuthState() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return const AppAuthState.unauthenticated();
    }

    try {
      final user = await _fetchUserProfile(session.user.id);
      _currentUser = user;
      _currentSession = AuthSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (session.expiresAt ?? 0) * 1000,
        ),
        user: user,
      );
      return AppAuthState.authenticated(user);
    } catch (e) {
      return AppAuthState.error(e.toString());
    }
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        return Left(AuthFailure(message: 'Login failed: No session returned'));
      }

      final user = await _fetchUserProfile(response.user!.id);
      
      // Check if user is active
      if (!user.isActive) {
        await _client.auth.signOut();
        return Left(AuthFailure(message: 'Your account is inactive'));
      }

      // Update last login
      await _client
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      _currentUser = user;
      _currentSession = AuthSession(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (response.session!.expiresAt ?? 0) * 1000,
        ),
        user: user,
      );

      return Right(user);
    } on supabase.AuthException catch (e) {
      return Left(AuthFailure(message: _mapAuthError(e.message)));
    } catch (e) {
      return Left(AuthFailure(message: 'Login failed: ${e.toString()}'));
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email belum diverifikasi';
    }
    if (message.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    return message;
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _client.auth.signOut();
      _currentSession = null;
      _currentUser = null;
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final session = _client.auth.currentSession;
    if (session == null) return null;

    try {
      _currentUser = await _fetchUserProfile(session.user.id);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, AuthSession>> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      if (response.session == null) {
        return Left(AuthFailure(message: 'Session refresh failed'));
      }

      final user = await _fetchUserProfile(response.user!.id);
      final session = AuthSession(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (response.session!.expiresAt ?? 0) * 1000,
        ),
        user: user,
      );
      _currentSession = session;
      _currentUser = user;

      return Right(session);
    } catch (e) {
      return Left(AuthFailure(message: 'Session refresh failed'));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Password reset failed'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Password update failed'));
    }
  }

  @override
  Stream<AppAuthState> authStateChanges() => _authStateController.stream;

  @override
  bool get isAuthenticated => _currentSession != null;

  @override
  AuthSession? get currentSession => _currentSession;

  void dispose() {
    _authStateController.close();
  }
}
