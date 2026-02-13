import 'dart:typed_data';

import '../../core/errors/result.dart';
import '../entities/app_auth_state.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Get current authentication state.
  Future<AppAuthState> getAuthState();

  /// Sign in with email and password.
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user.
  Future<Result<void>> signOut();

  /// Get current user if authenticated.
  Future<User?> getCurrentUser();

  /// Refresh current user from database (clears cache).
  /// Use when user profile may have been updated externally.
  Future<User?> refreshCurrentUser();

  /// Refresh the access token.
  Future<Result<AuthSession>> refreshSession();

  /// Request password reset email.
  Future<Result<void>> requestPasswordReset(String email);

  /// Update password with reset token.
  Future<Result<void>> updatePassword({
    required String newPassword,
  });

  /// Stream of auth state changes.
  Stream<AppAuthState> authStateChanges();

  /// Check if user is currently authenticated.
  bool get isAuthenticated;

  /// Get the current session if available.
  AuthSession? get currentSession;

  /// Update user profile information.
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  });

  /// Upload profile photo and return public URL.
  Future<Result<String>> uploadProfilePhoto({
    required String userId,
    required String localPath,
    required Uint8List? bytes, // For web platform
  });

  /// Remove profile photo.
  Future<Result<void>> removeProfilePhoto(String userId);
}
