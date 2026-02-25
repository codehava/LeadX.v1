import 'package:equatable/equatable.dart';

/// Base class for failure states in the application.
///
/// Uses Either pattern for error handling in use cases.
abstract class Failure extends Equatable implements Exception {
  final String message;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, originalError];
}

/// Failure related to authentication.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.originalError});
}

/// Failure when token is invalid or expired.
class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure()
      : super(message: 'Your session has expired. Please login again.');
}

/// Failure when credentials are invalid.
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(message: 'Invalid email or password.');
}

/// Failure related to network operations.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network error. Please check your connection.',
    super.originalError,
  });
}

/// Failure when device is offline.
class OfflineFailure extends NetworkFailure {
  const OfflineFailure()
      : super(message: 'You are offline. Please connect to the internet.');
}

/// Failure from server errors.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, statusCode, originalError];
}

/// Failure when resource is not found.
class NotFoundFailure extends ServerFailure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
  }) : super(statusCode: 404);
}

/// Failure when access is forbidden.
class ForbiddenFailure extends ServerFailure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to access this resource.',
  }) : super(statusCode: 403);
}

/// Failure related to database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.originalError});
}

/// Failure related to sync operations.
class SyncFailure extends Failure {
  final String? entityId;
  final String? entityType;

  const SyncFailure({
    required super.message,
    this.entityId,
    this.entityType,
    super.originalError,
  });

  @override
  List<Object?> get props => [message, entityId, entityType, originalError];
}

/// Failure when sync conflict occurs.
class SyncConflictFailure extends SyncFailure {
  const SyncConflictFailure({
    required super.entityId,
    required super.entityType,
  }) : super(message: 'A sync conflict occurred. Server data will be used.');
}

/// Failure related to location services.
class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.originalError});
}

/// Failure when location permission is denied.
class LocationPermissionDeniedFailure extends LocationFailure {
  const LocationPermissionDeniedFailure()
      : super(message: 'Location permission is required for this action.');
}

/// Failure when GPS is unavailable.
class LocationUnavailableFailure extends LocationFailure {
  const LocationUnavailableFailure()
      : super(message: 'Unable to get your location. Please try again.');
}

/// Failure for validation errors.
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Failure for file operations.
class FileFailure extends Failure {
  const FileFailure({required super.message, super.originalError});
}

/// Failure for unexpected errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.originalError,
  });
}
