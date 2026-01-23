import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/app_settings_service.dart';
import 'database_provider.dart';

part 'settings_providers.g.dart';

/// Provider for AppSettingsService.
@riverpod
AppSettingsService appSettingsService(AppSettingsServiceRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppSettingsService(db);
}

/// Notifier for managing theme mode settings with persistence.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // Load theme mode asynchronously
    _loadThemeMode();
    return ThemeMode.system;
  }

  /// Load theme mode from persistent storage.
  Future<void> _loadThemeMode() async {
    final settingsService = ref.read(appSettingsServiceProvider);
    final value = await settingsService.get(AppSettingsService.keyThemeMode);
    if (value != null) {
      state = _themeModeFromString(value);
    }
  }

  /// Set theme mode and persist.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.set(
      AppSettingsService.keyThemeMode,
      _themeModeToString(mode),
    );
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
