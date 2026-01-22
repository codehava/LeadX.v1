/// LeadX CRM Application
///
/// Mobile-first, offline-first CRM for PT Askrindo sales team
/// implementing the 4 Disciplines of Execution (4DX) framework.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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

  // Initialize Supabase
  await Supabase.initialize(
    url: envConfig.supabaseUrl,
    anonKey: envConfig.supabaseAnonKey,
  );

  // Run the app
  runApp(
    const ProviderScope(
      child: LeadXApp(),
    ),
  );
}
