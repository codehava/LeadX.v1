import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'app_auth_state.freezed.dart';

/// Authentication state for the app.
@freezed
class AppAuthState with _$AppAuthState {
  /// Initial state - checking auth status
  const factory AppAuthState.initial() = _Initial;

  /// Checking authentication status
  const factory AppAuthState.loading() = _Loading;

  /// User is authenticated
  const factory AppAuthState.authenticated(User user) = _Authenticated;

  /// User is not authenticated
  const factory AppAuthState.unauthenticated() = _Unauthenticated;

  /// Authentication error occurred
  const factory AppAuthState.error(String message) = _Error;
}

/// Login request data.
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });
}

/// Session data from Supabase.
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final User user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
