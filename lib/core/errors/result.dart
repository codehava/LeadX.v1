// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart' show immutable;

import 'failures.dart';

/// Sealed Result type for typed error handling.
///
/// Provides exhaustive pattern matching via Dart 3 sealed classes.
/// Two variants: [Success] (holds value) and [ResultFailure] (holds [Failure]).
///
/// Usage:
/// ```dart
/// final result = await repository.createCustomer(dto);
/// switch (result) {
///   case Success(:final value):
///     print('Created: ${value.name}');
///   case ResultFailure(:final failure):
///     print('Error: ${failure.message}');
/// }
/// ```
sealed class Result<T> {
  const Result._();

  /// Create a successful result wrapping [value].
  const factory Result.success(T value) = Success<T>;

  /// Create a failure result wrapping [failure].
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  /// Callback-style matching (similar to fold pattern).
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        ResultFailure(failure: final f) => failure(f),
      };

  /// The value if this is [Success], otherwise null.
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        ResultFailure() => null,
      };

  /// The failure if this is [ResultFailure], otherwise null.
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        ResultFailure(:final failure) => failure,
      };

  /// Whether this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Whether this is a [ResultFailure].
  bool get isFailure => this is ResultFailure<T>;
}

/// Successful result variant holding a [value] of type [T].
@immutable
final class Success<T> extends Result<T> {
  const Success(this.value) : super._();

  /// The success value.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failure result variant holding a [Failure] instance.
@immutable
final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure) : super._();

  /// The failure details.
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'ResultFailure($failure)';
}
