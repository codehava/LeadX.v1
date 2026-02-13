import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker/talker.dart';

/// Forwards Talker errors and exceptions to Sentry.
///
/// Also adds warning+ level logs as Sentry breadcrumbs
/// for richer crash context.
class SentryTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    Sentry.captureException(
      err.error,
      stackTrace: err.stackTrace,
    );
    super.onError(err);
  }

  @override
  void onException(TalkerException err) {
    Sentry.captureException(
      err.exception,
      stackTrace: err.stackTrace,
    );
    super.onException(err);
  }

  @override
  void onLog(TalkerData log) {
    // Forward warning+ level logs as Sentry breadcrumbs
    final level = log.logLevel;
    if (level != null && level.index >= LogLevel.warning.index) {
      Sentry.addBreadcrumb(Breadcrumb(
        message: log.message ?? '',
        level: _mapLevel(level),
        category: 'talker',
      ));
    }
    super.onLog(log);
  }

  SentryLevel _mapLevel(LogLevel level) {
    return switch (level) {
      LogLevel.critical => SentryLevel.fatal,
      LogLevel.error => SentryLevel.error,
      LogLevel.warning => SentryLevel.warning,
      LogLevel.info => SentryLevel.info,
      _ => SentryLevel.debug,
    };
  }
}
