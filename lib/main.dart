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

import 'app.dart';
import 'config/env/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URL strategy for web (removes # from URLs)
  usePathUrlStrategy();

  // Load environment variables from bundled .env file
  await dotenv.load(fileName: '.env');

  // Get and validate environment configuration
  final envConfig = EnvConfig.instance;
  envConfig.validate();

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

      // Run the app
      runApp(
        const ProviderScope(
          child: LeadXApp(),
        ),
      );
    },
  );
}
