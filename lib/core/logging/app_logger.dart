import 'package:talker/talker.dart';

/// Centralized logging for LeadX CRM.
///
/// Initialize once at app startup via [init], then access
/// the singleton [instance] throughout the app.
///
/// Module prefix convention: 'module.sub | message'
/// Examples:
///   - 'sync.queue | Processing 5 items'
///   - 'sync.push | Failed: customer/abc-123'
///   - 'auth | Login success for user@email.com'
///   - 'db | Migration v9 -> v10 complete'
class AppLogger {
  AppLogger._();

  static late final Talker _instance;

  /// The singleton Talker instance. Must call [init] first.
  static Talker get instance => _instance;

  /// Initialize the logger. Call once at app startup before any logging.
  ///
  /// Pass [observer] to forward logs to external services (e.g., Sentry).
  static void init({TalkerObserver? observer}) {
    _instance = Talker(
      settings: TalkerSettings(
        enabled: true,
        useConsoleLogs: true,
      ),
      observer: observer,
    );
  }
}
