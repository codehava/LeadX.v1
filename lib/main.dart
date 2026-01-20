/// LeadX CRM Application
///
/// Mobile-first, offline-first CRM for PT Askrindo sales team
/// implementing the 4 Disciplines of Execution (4DX) framework.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration
  final envConfig = EnvConfig.instance;

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
