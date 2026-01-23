import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/services/app_settings_service.dart';

/// Provider for AppSettingsService.
final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppSettingsService(db);
});

/// Notifier for managing theme mode settings.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._settingsService) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final AppSettingsService _settingsService;

  /// Load theme mode from persistent storage.
  Future<void> _loadThemeMode() async {
    final value = await _settingsService.get(AppSettingsService.keyThemeMode);
    if (value != null) {
      state = _themeModeFromString(value);
    }
  }

  /// Set theme mode and persist.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _settingsService.set(
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

/// Provider for theme mode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final settingsService = ref.watch(appSettingsServiceProvider);
  return ThemeModeNotifier(settingsService);
});
