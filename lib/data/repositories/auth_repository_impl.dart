import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/errors/failures.dart';
import '../../domain/entities/app_auth_state.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../database/app_database.dart' as db;

/// Supabase implementation of AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _client;
  final db.AppDatabase? _database;

  /// Timeout duration for network requests.
  static const Duration _networkTimeout = Duration(seconds: 5);

  AuthSession? _currentSession;
  User? _currentUser;
  final _authStateController = StreamController<AppAuthState>.broadcast();
  bool _initialized = false;

  /// Tracks if we're in password recovery mode.
  /// This prevents the signedIn event from overwriting the passwordRecovery state.
  bool _inPasswordRecoveryMode = false;

  AuthRepositoryImpl(this._client, {db.AppDatabase? database})
      : _database = database {
    // IMPORTANT: Set up listener BEFORE initializing state
    // This ensures we catch passwordRecovery events from URL parameters
    _client.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data);
    });

    // Initialize auth state from persisted session
    // Delay slightly to allow auth events (like passwordRecovery) to fire first
    _initializeAuthState();
  }

  /// Initialize auth state from persisted session
  void _initializeAuthState() {
    // Check for persisted session synchronously first
    final session = _client.auth.currentSession;

    if (session != null) {
      debugPrint('[Auth] Found persisted session, attempting to restore...');
      // Emit loading state immediately so router doesn't hang
      _authStateController.add(const AppAuthState.loading());
      // Session exists, but wait briefly for potential passwordRecovery event
      // This handles the case where user clicks a reset link and the app loads
      _restoreSessionWithRecoveryCheck(session);
    } else {
      debugPrint('[Auth] No persisted session found');
      _authStateController.add(const AppAuthState.unauthenticated());
      _initialized = true;
    }
  }

  /// Restore session with a check for password recovery mode.
  /// Waits briefly to allow passwordRecovery events to fire first.
  Future<void> _restoreSessionWithRecoveryCheck(supabase.Session session) async {
    // Wait briefly for auth events to fire (passwordRecovery fires quickly)
    await Future.delayed(const Duration(milliseconds: 100));

    // If passwordRecovery event fired, don't restore as authenticated
    if (_inPasswordRecoveryMode) {
      debugPrint('[Auth] Password recovery mode detected, not restoring as authenticated');
      _initialized = true;
      return;
    }

    // Normal session restoration
    await _restoreSessionAsync(session);
  }

  /// Restore session asynchronously
  Future<void> _restoreSessionAsync(supabase.Session session) async {
    try {
      await _fetchUserAndNotify(session);
      debugPrint('[Auth] Session restored successfully');
    } catch (e) {
      debugPrint('[Auth] Failed to restore session: $e');
      _authStateController.add(const AppAuthState.unauthenticated());
    } finally {
      _initialized = true;
    }
  }

  void _handleAuthStateChange(supabase.AuthState data) {
    switch (data.event) {
      case supabase.AuthChangeEvent.initialSession:
        // Session restored from storage (e.g., opening new tab)
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.signedIn:
        // If we're in password recovery mode, don't emit authenticated state.
        // The signedIn event fires after passwordRecovery when clicking reset link,
        // which would otherwise overwrite the passwordRecovery state.
        if (_inPasswordRecoveryMode) {
          debugPrint('[Auth] signedIn ignored - in password recovery mode');
          return;
        }
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.signedOut:
        _currentSession = null;
        _currentUser = null;
        _inPasswordRecoveryMode = false;
        _authStateController.add(const AppAuthState.unauthenticated());
        break;
      case supabase.AuthChangeEvent.tokenRefreshed:
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.userUpdated:
        // userUpdated fires after password reset - exit recovery mode
        _inPasswordRecoveryMode = false;
        _fetchUserAndNotify(data.session);
        break;
      case supabase.AuthChangeEvent.passwordRecovery:
        _inPasswordRecoveryMode = true;
        _authStateController.add(const AppAuthState.passwordRecovery());
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
      final user = await _fetchUserWithFallback(session);
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

  /// Attempt to fetch user from local SQLite database.
  /// Returns null if not found or database not available.
  Future<User?> _fetchLocalUser(String userId) async {
    if (_database == null) return null;

    try {
      final localUser = await (_database.select(_database.users)
            ..where((t) => t.id.equals(userId)))
          .getSingleOrNull();

      if (localUser == null) return null;

      return User(
        id: localUser.id,
        email: localUser.email,
        name: localUser.name,
        nip: localUser.nip,
        phone: localUser.phone,
        role: _parseRole(localUser.role),
        parentId: localUser.parentId,
        branchId: localUser.branchId,
        regionalOfficeId: localUser.regionalOfficeId,
        photoUrl: localUser.photoUrl,
        isActive: localUser.isActive,
        lastLoginAt: localUser.lastLoginAt,
        createdAt: localUser.createdAt,
        updatedAt: localUser.updatedAt,
      );
    } catch (e) {
      debugPrint('[Auth] Failed to fetch local user: $e');
      return null;
    }
  }

  /// Create a minimal User from session data when offline.
  /// Uses JWT claims for basic info.
  User _createMinimalUserFromSession(supabase.Session session) {
    return User(
      id: session.user.id,
      email: session.user.email ?? '',
      name: '',
      nip: null,
      phone: session.user.phone,
      role: UserRole.rm, // Default role - will be updated when online
      parentId: null,
      branchId: null,
      regionalOfficeId: null,
      photoUrl: null,
      isActive: true,
      lastLoginAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Fetch user with timeout and fallback to local storage.
  /// Priority: 1) Remote API 2) Local database 3) Minimal from session
  Future<User> _fetchUserWithFallback(supabase.Session session) async {
    final userId = session.user.id;

    try {
      // Try remote fetch with timeout
      final user = await _fetchUserProfile(userId).timeout(_networkTimeout);

      // Insert current user into local DB to satisfy FK constraints
      // This ensures customer creation works even if full sync hasn't completed
      await _upsertCurrentUserLocally(user);

      return user;
    } catch (e) {
      debugPrint('[Auth] Remote fetch failed: $e - trying local database');

      // Try local database
      final localUser = await _fetchLocalUser(userId);
      if (localUser != null) {
        debugPrint('[Auth] Found user in local database');
        return localUser;
      }

      // Fall back to minimal user from session
      debugPrint('[Auth] Using minimal user from session');
      final minimalUser = _createMinimalUserFromSession(session);

      // Also insert minimal user to satisfy FK constraints
      await _upsertCurrentUserLocally(minimalUser);

      return minimalUser;
    }
  }

  /// Upsert current user into local database to satisfy FK constraints.
  /// This ensures operations like customer creation work before full sync completes.
  Future<void> _upsertCurrentUserLocally(User user) async {
    if (_database == null) return;

    try {
      await _database!.into(_database!.users).insertOnConflictUpdate(
        db.UsersCompanion.insert(
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role.name,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        ),
      );
      debugPrint('[Auth] Upserted current user to local DB: ${user.id}');
    } catch (e) {
      debugPrint('[Auth] Failed to upsert user locally: $e');
      // Don't throw - this is a best-effort optimization
    }
  }

  @override
  Future<AppAuthState> getAuthState() async {
    // Wait for initialization to complete with timeout
    int attempts = 0;
    while (!_initialized && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (!_initialized) {
      debugPrint('[Auth] Initialization timeout, returning current state');
    }

    // If in password recovery mode, return that state regardless of session
    if (_inPasswordRecoveryMode) {
      return const AppAuthState.passwordRecovery();
    }

    final session = _client.auth.currentSession;
    if (session == null) {
      return const AppAuthState.unauthenticated();
    }

    // If we have a cached user, return authenticated state immediately
    // (useful when offline but still authenticated)
    if (_currentUser != null) {
      return AppAuthState.authenticated(_currentUser!);
    }

    try {
      final user = await _fetchUserWithFallback(session);
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
      debugPrint('[Auth] Failed to get auth state: $e');
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
      _currentUser = await _fetchUserWithFallback(session);
      return _currentUser;
    } catch (e) {
      debugPrint('[Auth] getCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, AuthSession>> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession().timeout(
        _networkTimeout,
        onTimeout: () {
          throw TimeoutException('Session refresh timeout');
        },
      );

      if (response.session == null) {
        return Left(AuthFailure(message: 'Session refresh failed'));
      }

      final user = await _fetchUserWithFallback(response.session!);
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
    } on TimeoutException {
      // If refresh times out but we have cached data, return that
      if (_currentSession != null) {
        debugPrint('[Auth] Session refresh timeout - returning cached session');
        return Right(_currentSession!);
      }
      return Left(AuthFailure(message: 'Session refresh timeout - offline'));
    } catch (e) {
      return Left(AuthFailure(message: 'Session refresh failed'));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      // Determine redirect URL based on platform
      final redirectUrl = kIsWeb
          ? '${Uri.base.origin}/reset-password'
          : 'io.supabase.leadxcrm://reset-password';

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
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

      // Clear recovery mode and sign out so user must log in with new password
      _inPasswordRecoveryMode = false;
      await _client.auth.signOut();

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

  @override
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String localPath,
    required Uint8List? bytes,
  }) async {
    try {
      const bucket = 'user-photos';
      final storagePath = '$userId/profile.jpg';

      // Upload file
      if (bytes != null) {
        // Web: upload bytes
        await _client.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const supabase.FileOptions(
            contentType: 'image/jpeg',
            upsert: true, // Overwrite existing
          ),
        );
      } else {
        // Mobile: upload file
        final file = File(localPath);
        if (!await file.exists()) {
          return const Left(AuthFailure(message: 'File tidak ditemukan'));
        }

        final fileBytes = await file.readAsBytes();
        await _client.storage.from(bucket).uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: const supabase.FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
      }

      // Get public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(storagePath);

      // Add timestamp to bust cache
      final urlWithTimestamp = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return Right(urlWithTimestamp);
    } catch (e) {
      debugPrint('Photo upload error: $e');
      return Left(AuthFailure(message: 'Upload foto gagal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        return const Left(AuthFailure(message: 'Tidak terautentikasi'));
      }

      final userId = session.user.id;

      // Build update payload (only include provided fields)
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      // Update remote database
      await _client
          .from('users')
          .update(updates)
          .eq('id', userId);

      // Fetch updated user
      final updatedUser = await _fetchUserProfile(userId);
      _currentUser = updatedUser;

      // Update session
      if (_currentSession != null) {
        _currentSession = AuthSession(
          accessToken: _currentSession!.accessToken,
          refreshToken: _currentSession!.refreshToken,
          expiresAt: _currentSession!.expiresAt,
          user: updatedUser,
        );
      }

      // Notify listeners
      _authStateController.add(AppAuthState.authenticated(updatedUser));

      return Right(updatedUser);
    } catch (e) {
      debugPrint('Profile update error: $e');
      return Left(AuthFailure(message: 'Update profil gagal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeProfilePhoto(String userId) async {
    try {
      const bucket = 'user-photos';
      final storagePath = '$userId/profile.jpg';

      // Remove from storage (ignore if doesn't exist)
      try {
        await _client.storage.from(bucket).remove([storagePath]);
      } catch (e) {
        debugPrint('Photo removal warning: $e');
      }

      // Update database to remove URL
      await _client
          .from('users')
          .update({
            'photo_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Fetch updated user
      final updatedUser = await _fetchUserProfile(userId);
      _currentUser = updatedUser;

      // Notify listeners
      _authStateController.add(AppAuthState.authenticated(updatedUser));

      return const Right(null);
    } catch (e) {
      debugPrint('Photo removal error: $e');
      return Left(AuthFailure(message: 'Hapus foto gagal: ${e.toString()}'));
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
