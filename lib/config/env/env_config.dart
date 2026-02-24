/// Environment configuration for LeadX CRM.
///
/// This class provides access to environment-specific settings
/// such as Supabase URL and API keys loaded from .env file at runtime.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static final EnvConfig _instance = EnvConfig._();
  static EnvConfig get instance => _instance;

  /// Validates that required environment variables are configured.
  /// 
  /// Throws [StateError] if required values are not set.
  /// Call this early in app startup to fail fast.
  void validate() {
    final errors = <String>[];

    if (supabaseUrl.isEmpty || supabaseUrl.contains('your-project')) {
      errors.add('SUPABASE_URL is not configured in .env file');
    }

    if (supabaseAnonKey.isEmpty || supabaseAnonKey == 'your-anon-key') {
      errors.add('SUPABASE_ANON_KEY is not configured in .env file');
    }

    if (errors.isNotEmpty) {
      throw StateError(
        'Environment configuration error:\n${errors.join('\n')}\n\n'
        'Please create a .env file in the project root with:\n'
        'SUPABASE_URL=https://your-project.supabase.co\n'
        'SUPABASE_ANON_KEY=your-anon-key',
      );
    }
  }

  /// Whether the environment is properly configured.
  bool get isConfigured {
    return supabaseUrl.isNotEmpty && 
           !supabaseUrl.contains('your-project') &&
           supabaseAnonKey.isNotEmpty &&
           supabaseAnonKey != 'your-anon-key';
  }

  /// Supabase project URL (loaded from .env)
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key (loaded from .env)
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Sentry DSN for crash reporting (loaded from .env)
  /// Empty string disables Sentry (it silently no-ops when DSN is empty)
  String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  /// Whether the app is in debug mode
  bool get isDebug => const bool.fromEnvironment('DEBUG', defaultValue: true);

  /// API timeout duration in seconds
  int get apiTimeout => const int.fromEnvironment('API_TIMEOUT', defaultValue: 30);

  /// Sync interval in seconds
  int get syncInterval => const int.fromEnvironment('SYNC_INTERVAL', defaultValue: 30);

  /// Maximum retry attempts for sync operations
  int get maxSyncRetries => const int.fromEnvironment('MAX_SYNC_RETRIES', defaultValue: 3);

  /// GPS distance filter in meters
  int get gpsDistanceFilter => const int.fromEnvironment('GPS_DISTANCE_FILTER', defaultValue: 10);

  /// GPS timeout in seconds
  int get gpsTimeout => const int.fromEnvironment('GPS_TIMEOUT', defaultValue: 15);

  /// Visit distance threshold in meters (for validation)
  int get visitDistanceThreshold => const int.fromEnvironment('VISIT_DISTANCE_THRESHOLD', defaultValue: 500);
}
