/// Custom exceptions for LeadX CRM.
library;

/// Base exception for all app exceptions.
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when token is invalid or expired.
class TokenExpiredException extends AuthException {
  const TokenExpiredException()
      : super(message: 'Your session has expired. Please login again.');
}

/// Exception thrown when user credentials are invalid.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super(message: 'Invalid email or password.');
}

/// Exception thrown when network operations fail.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error. Please check your connection.',
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when device is offline.
class OfflineException extends NetworkException {
  const OfflineException()
      : super(message: 'You are offline. Please connect to the internet.');
}

/// Exception thrown when server returns an error.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when a resource is not found.
class NotFoundException extends ServerException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
  }) : super(statusCode: 404);
}

/// Exception thrown when access is forbidden.
class ForbiddenException extends ServerException {
  const ForbiddenException({
    super.message = 'You do not have permission to access this resource.',
  }) : super(statusCode: 403);
}

/// Exception thrown when database operations fail.
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when sync operations fail.
class SyncException extends AppException {
  final String? entityId;
  final String? entityType;

  const SyncException({
    required super.message,
    this.entityId,
    this.entityType,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when there's a sync conflict.
class SyncConflictException extends SyncException {
  const SyncConflictException({
    required super.entityId,
    required super.entityType,
    super.message = 'A sync conflict occurred. Server data will be used.',
  });
}

/// Exception thrown when location services fail.
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when location permission is denied.
class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException()
      : super(message: 'Location permission is required for this action.');
}

/// Exception thrown when GPS signal is unavailable.
class LocationUnavailableException extends LocationException {
  const LocationUnavailableException()
      : super(message: 'Unable to get your location. Please try again.');
}

/// Exception thrown for validation errors.
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
  });
}

/// Exception thrown when file operations fail.
class FileException extends AppException {
  const FileException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception for unexpected errors.
class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred.',
    super.originalError,
    super.stackTrace,
  });
}
