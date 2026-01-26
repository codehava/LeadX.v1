import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/app_auth_state.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Get current authentication state.
  Future<AppAuthState> getAuthState();

  /// Sign in with email and password.
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user.
  Future<Either<Failure, void>> signOut();

  /// Get current user if authenticated.
  Future<User?> getCurrentUser();

  /// Refresh the access token.
  Future<Either<Failure, AuthSession>> refreshSession();

  /// Request password reset email.
  Future<Either<Failure, void>> requestPasswordReset(String email);

  /// Update password with reset token.
  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  });

  /// Stream of auth state changes.
  Stream<AppAuthState> authStateChanges();

  /// Check if user is currently authenticated.
  bool get isAuthenticated;

  /// Get the current session if available.
  AuthSession? get currentSession;

  /// Update user profile information.
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  });

  /// Upload profile photo and return public URL.
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String localPath,
    required Uint8List? bytes, // For web platform
  });

  /// Remove profile photo.
  Future<Either<Failure, void>> removeProfilePhoto(String userId);
}
