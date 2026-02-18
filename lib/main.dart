/// LeadX CRM Application
///
/// Mobile-first, offline-first CRM for PT Askrindo sales team
/// implementing the 4 Disciplines of Execution (4DX) framework.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'app.dart';
import 'config/env/env_config.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/sentry_observer.dart';
import 'data/services/background_sync_service.dart';
import 'presentation/providers/sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URL strategy for web (removes # from URLs)
  usePathUrlStrategy();

  // Load environment variables from bundled .env file
  await dotenv.load(fileName: '.env');

  // Get and validate environment configuration
  final envConfig = EnvConfig.instance;
  envConfig.validate();

  // Initialize structured logging FIRST (so it's available during Sentry init)
  AppLogger.init(observer: SentryTalkerObserver());

  // Wrap everything in SentryFlutter.init so widget tree errors are captured
  await SentryFlutter.init(
    (options) {
      options.dsn = envConfig.sentryDsn;
      options.tracesSampleRate = 0.2; // 20% of transactions
      options.environment = kReleaseMode ? 'production' : 'development';
      // Only send events in release mode (or when DSN is explicitly set in dev)
      options.beforeSend = (event, hint) {
        if (!kReleaseMode && envConfig.sentryDsn.isEmpty) {
          return null; // Drop events in dev when no DSN configured
        }
        return event;
      };
    },
    appRunner: () async {
      // Initialize Supabase
      await Supabase.initialize(
        url: envConfig.supabaseUrl,
        anonKey: envConfig.supabaseAnonKey,
      );

      // Initialize locale data for Indonesian date formatting
      await initializeDateFormatting('id_ID', null);

      // Initialize background sync (WorkManager) -- mobile only, no-op on web.
      // Always register the periodic task; the callback itself checks the
      // user toggle setting and skips processing if disabled.
      await BackgroundSyncService.initialize();
      await BackgroundSyncService.registerPeriodicSync();

      // Create ProviderContainer for eager initialization of sync services.
      // Using UncontrolledProviderScope to share the container with the widget tree.
      final container = ProviderContainer(
        observers: [TalkerRiverpodObserver(talker: AppLogger.instance)],
      );

      // Initialize sync services eagerly: connectivity, coordinator (stale lock
      // recovery + initial sync state), and start the periodic sync timer.
      await initializeSyncServices(container);

      // Run the app with the shared container
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const LeadXApp(),
        ),
      );
    },
  );
}
