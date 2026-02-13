/// Sealed error hierarchy for sync failure classification.
///
/// Enables exhaustive pattern matching on sync failures to determine
/// whether errors are retryable (network, timeout, 5xx) or permanent
/// (auth, validation, conflict).
///
/// Used by [SyncService._processItem] to throw typed errors and by
/// [SyncService.processQueue] to decide retry vs fail behavior.
library;

/// Base sealed class for all sync errors.
///
/// Use pattern matching (`switch`) for exhaustive handling:
/// ```dart
/// switch (syncError) {
///   case NetworkSyncError(): // retry
///   case TimeoutSyncError(): // retry
///   case ServerSyncError(): // retry if 5xx
///   case AuthSyncError(): // permanent
///   case ValidationSyncError(): // permanent
///   case ConflictSyncError(): // permanent
/// }
/// ```
sealed class SyncError implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;
  final String? entityType;
  final String? entityId;

  const SyncError({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.entityType,
    this.entityId,
  });

  /// Whether this error is retryable (network issues, timeouts, 5xx).
  bool get isRetryable;

  @override
  String toString() =>
      'SyncError(message: $message, entityType: $entityType, entityId: $entityId, isRetryable: $isRetryable)';
}

/// Network unreachable error (e.g., SocketException).
///
/// Always retryable -- device may regain connectivity.
final class NetworkSyncError extends SyncError {
  const NetworkSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });

  @override
  bool get isRetryable => true;
}

/// Request timed out (e.g., TimeoutException).
///
/// Always retryable -- server may recover.
final class TimeoutSyncError extends SyncError {
  const TimeoutSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });

  @override
  bool get isRetryable => true;
}

/// Server error with HTTP status code.
///
/// Retryable only for 5xx status codes (server-side issues).
/// 4xx codes that don't match other specific types fall here.
final class ServerSyncError extends SyncError {
  final int statusCode;

  const ServerSyncError({
    required this.statusCode,
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });

  @override
  bool get isRetryable => statusCode >= 500;
}

/// Authentication/authorization error (401, PGRST301).
///
/// Never retryable -- requires user re-authentication.
final class AuthSyncError extends SyncError {
  const AuthSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });

  @override
  bool get isRetryable => false;
}

/// Validation error (400-499 range, excluding auth/conflict).
///
/// Never retryable -- payload must be fixed.
final class ValidationSyncError extends SyncError {
  final Map<String, dynamic>? details;

  const ValidationSyncError({
    required super.message,
    this.details,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });

  @override
  bool get isRetryable => false;
}

/// Conflict error (409).
///
/// Never retryable -- requires conflict resolution.
final class ConflictSyncError extends SyncError {
  const ConflictSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });

  @override
  bool get isRetryable => false;
}
