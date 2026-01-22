import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';

/// Provider for the application database.
/// This is initialized during app startup and shared across the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Alias for backward compatibility.
final appDatabaseProvider = databaseProvider;
