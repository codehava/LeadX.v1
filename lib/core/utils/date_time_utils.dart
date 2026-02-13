/// DateTime extensions for consistent UTC timestamp serialization.
///
/// WHY THIS EXISTS:
/// Dart's [DateTime.toIso8601String()] omits the timezone suffix for local
/// DateTime instances (e.g. "2026-01-15T14:30:00.000" instead of
/// "2026-01-15T07:30:00.000Z"). Supabase PostgreSQL columns of type
/// `timestamptz` interpret bare ISO strings as UTC, so a local WIB time
/// (UTC+7) of 14:30 would be stored as 14:30 UTC -- 7 hours too late.
///
/// Calling `.toUtc()` before `.toIso8601String()` ensures the Z suffix is
/// always present and the timestamp is correctly interpreted by Supabase.
///
/// USAGE:
/// ```dart
/// import 'package:leadx_crm/core/utils/date_time_utils.dart';
///
/// // Non-nullable DateTime
/// final payload = {'created_at': DateTime.now().toUtcIso8601()};
///
/// // Nullable DateTime
/// final payload = {'deleted_at': deletedAt.toUtcIso8601()};
/// ```
///
/// NOTE: Do NOT use this for date-only fields (e.g. `expected_close_date`,
/// `start_date`, `end_date`) that map to PostgreSQL DATE columns. Converting
/// to UTC can shift the date by one day for UTC+ timezones. Instead, use
/// `.toIso8601String().substring(0, 10)` to extract the yyyy-MM-dd portion.
library;

/// Extension on non-nullable [DateTime] for UTC ISO 8601 serialization.
extension DateTimeUtcExtension on DateTime {
  /// Converts to UTC and returns an ISO 8601 string with Z suffix.
  ///
  /// Example: `DateTime.now().toUtcIso8601()` => "2026-01-15T07:30:00.000Z"
  String toUtcIso8601() => toUtc().toIso8601String();
}

/// Extension on nullable [DateTime?] for UTC ISO 8601 serialization.
extension NullableDateTimeUtcExtension on DateTime? {
  /// Converts to UTC and returns an ISO 8601 string with Z suffix,
  /// or null if this DateTime is null.
  ///
  /// Example: `nullableDate.toUtcIso8601()` => "2026-01-15T07:30:00.000Z" or null
  String? toUtcIso8601() => this?.toUtc().toIso8601String();
}
