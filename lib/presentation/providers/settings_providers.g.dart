// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appSettingsServiceHash() =>
    r'5bc9e2a5739f4231d239887a9c053894c5417acd';

/// Provider for AppSettingsService.
///
/// Copied from [appSettingsService].
@ProviderFor(appSettingsService)
final appSettingsServiceProvider =
    AutoDisposeProvider<AppSettingsService>.internal(
      appSettingsService,
      name: r'appSettingsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appSettingsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppSettingsServiceRef = AutoDisposeProviderRef<AppSettingsService>;
String _$themeModeNotifierHash() => r'5d4eb2c97c50e4401842666f9afcc890d4a14282';

/// Notifier for managing theme mode settings with persistence.
///
/// Copied from [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
      ThemeModeNotifier.new,
      name: r'themeModeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeModeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeModeNotifier = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
