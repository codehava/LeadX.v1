import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'failures.dart';
import 'result.dart';

/// Maps an exception to a typed [Failure] for domain-level error handling.
///
/// Uses Dart 3 switch expression for exhaustive exception classification:
/// - [SocketException] -> [NetworkFailure]
/// - [TimeoutException] -> [NetworkFailure]
/// - [supabase.PostgrestException] -> status-specific failure
/// - [supabase.AuthException] -> [AuthFailure]
/// - [FormatException] -> [DatabaseFailure]
/// - Fallback -> [UnexpectedFailure]
///
/// The optional [context] parameter is prepended to error messages for
/// traceability (e.g., 'createCustomer', 'syncFromRemote').
Failure mapException(Object error, {String? context}) {
  final prefix = context != null ? '$context: ' : '';

  return switch (error) {
    SocketException() => NetworkFailure(
        message: 'Check your connection and try again.',
        originalError: error,
      ),
    TimeoutException() => NetworkFailure(
        message: 'Check your connection and try again.',
        originalError: error,
      ),
    supabase.PostgrestException() => _mapPostgrestException(error, prefix),
    supabase.AuthException() => AuthFailure(
        message: 'Session expired. Please login again.',
        originalError: error,
      ),
    FormatException() => DatabaseFailure(
        message: '${prefix}Invalid data format: ${error.message}',
        originalError: error,
      ),
    _ => UnexpectedFailure(
        message: '$prefix$error',
        originalError: error,
      ),
  };
}

/// Maps a [supabase.PostgrestException] to a specific failure type based on
/// its HTTP status code.
Failure _mapPostgrestException(
  supabase.PostgrestException error,
  String prefix,
) {
  final code = error.code;

  // Parse HTTP status from the code string (e.g., '401', 'PGRST301')
  final statusCode = int.tryParse(code ?? '') ?? _extractStatusFromPgrstCode(code);

  if (statusCode == null) {
    return UnexpectedFailure(
      message: '${prefix}Database error: ${error.message}',
      originalError: error,
    );
  }

  return switch (statusCode) {
    401 => AuthFailure(
        message: 'Session expired. Please login again.',
        originalError: error,
      ),
    403 => ForbiddenFailure(
        message: '${prefix}Access denied.',
      ),
    404 => NotFoundFailure(
        message: '${prefix}Resource not found.',
      ),
    409 => SyncConflictFailure(
        entityId: null,
        entityType: null,
      ),
    >= 400 && < 500 => ValidationFailure(
        message: '$prefix${error.message}',
      ),
    >= 500 => ServerFailure(
        message: '${prefix}Server error. Please try again later.',
        statusCode: statusCode,
        originalError: error,
      ),
    _ => UnexpectedFailure(
        message: '${prefix}Database error: ${error.message}',
        originalError: error,
      ),
  };
}

/// Extracts an HTTP status code from PostgREST error codes like 'PGRST301'.
///
/// PostgREST uses codes in the format 'PGRSTxxx' where xxx maps to HTTP status.
/// Returns null if the code doesn't match.
int? _extractStatusFromPgrstCode(String? code) {
  if (code == null) return null;

  // PGRST301 = 401 (JWT expired)
  if (code == 'PGRST301') return 401;
  // PGRST302 = 401 (anonymous access not allowed)
  if (code == 'PGRST302') return 401;

  return null;
}

/// Convenience wrapper that executes [action] and returns a [Result].
///
/// Catches all exceptions and maps them via [mapException].
/// Use for simple CRUD operations where the entire body can be wrapped.
///
/// ```dart
/// Future<Result<Customer>> createCustomer(dto) =>
///   runCatching(() async {
///     // ... insert, queue sync, return customer
///   }, context: 'createCustomer');
/// ```
Future<Result<T>> runCatching<T>(
  Future<T> Function() action, {
  String? context,
}) async {
  try {
    final value = await action();
    return Result.success(value);
  } catch (e) {
    return Result.failure(mapException(e, context: context));
  }
}
