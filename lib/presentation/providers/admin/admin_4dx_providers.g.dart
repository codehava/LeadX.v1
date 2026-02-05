// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_4dx_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$admin4DXRepositoryHash() =>
    r'9f9b76b1ac7cf2f9fba4baae684fb1fb599fcdd2';

/// See also [admin4DXRepository].
@ProviderFor(admin4DXRepository)
final admin4DXRepositoryProvider =
    AutoDisposeProvider<Admin4DXRepository>.internal(
      admin4DXRepository,
      name: r'admin4DXRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$admin4DXRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef Admin4DXRepositoryRef = AutoDisposeProviderRef<Admin4DXRepository>;
String _$allMeasuresHash() => r'208cb8ce49c23c705dd606f258be5d7249d2a479';

/// Get all measure definitions (including inactive for admin).
///
/// Copied from [allMeasures].
@ProviderFor(allMeasures)
final allMeasuresProvider =
    AutoDisposeFutureProvider<List<MeasureDefinition>>.internal(
      allMeasures,
      name: r'allMeasuresProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allMeasuresHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMeasuresRef = AutoDisposeFutureProviderRef<List<MeasureDefinition>>;
String _$measureByIdHash() => r'528e91eb3b3778b6ad52eb43006c002395119c14';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get measure definition by ID.
///
/// Copied from [measureById].
@ProviderFor(measureById)
const measureByIdProvider = MeasureByIdFamily();

/// Get measure definition by ID.
///
/// Copied from [measureById].
class MeasureByIdFamily extends Family<AsyncValue<MeasureDefinition?>> {
  /// Get measure definition by ID.
  ///
  /// Copied from [measureById].
  const MeasureByIdFamily();

  /// Get measure definition by ID.
  ///
  /// Copied from [measureById].
  MeasureByIdProvider call(String id) {
    return MeasureByIdProvider(id);
  }

  @override
  MeasureByIdProvider getProviderOverride(
    covariant MeasureByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'measureByIdProvider';
}

/// Get measure definition by ID.
///
/// Copied from [measureById].
class MeasureByIdProvider
    extends AutoDisposeFutureProvider<MeasureDefinition?> {
  /// Get measure definition by ID.
  ///
  /// Copied from [measureById].
  MeasureByIdProvider(String id)
    : this._internal(
        (ref) => measureById(ref as MeasureByIdRef, id),
        from: measureByIdProvider,
        name: r'measureByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$measureByIdHash,
        dependencies: MeasureByIdFamily._dependencies,
        allTransitiveDependencies: MeasureByIdFamily._allTransitiveDependencies,
        id: id,
      );

  MeasureByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<MeasureDefinition?> Function(MeasureByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MeasureByIdProvider._internal(
        (ref) => create(ref as MeasureByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MeasureDefinition?> createElement() {
    return _MeasureByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasureByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MeasureByIdRef on AutoDisposeFutureProviderRef<MeasureDefinition?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _MeasureByIdProviderElement
    extends AutoDisposeFutureProviderElement<MeasureDefinition?>
    with MeasureByIdRef {
  _MeasureByIdProviderElement(super.provider);

  @override
  String get id => (origin as MeasureByIdProvider).id;
}

String _$allPeriodsHash() => r'c21b7b2a1f458e9cb6e2ca1b82c44cb36801fb39';

/// Get all scoring periods.
///
/// Copied from [allPeriods].
@ProviderFor(allPeriods)
final allPeriodsProvider =
    AutoDisposeFutureProvider<List<ScoringPeriod>>.internal(
      allPeriods,
      name: r'allPeriodsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allPeriodsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllPeriodsRef = AutoDisposeFutureProviderRef<List<ScoringPeriod>>;
String _$periodByIdHash() => r'e912fc3f00ea6703d75977943e88874feb8a2406';

/// Get period by ID.
///
/// Copied from [periodById].
@ProviderFor(periodById)
const periodByIdProvider = PeriodByIdFamily();

/// Get period by ID.
///
/// Copied from [periodById].
class PeriodByIdFamily extends Family<AsyncValue<ScoringPeriod?>> {
  /// Get period by ID.
  ///
  /// Copied from [periodById].
  const PeriodByIdFamily();

  /// Get period by ID.
  ///
  /// Copied from [periodById].
  PeriodByIdProvider call(String id) {
    return PeriodByIdProvider(id);
  }

  @override
  PeriodByIdProvider getProviderOverride(
    covariant PeriodByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'periodByIdProvider';
}

/// Get period by ID.
///
/// Copied from [periodById].
class PeriodByIdProvider extends AutoDisposeFutureProvider<ScoringPeriod?> {
  /// Get period by ID.
  ///
  /// Copied from [periodById].
  PeriodByIdProvider(String id)
    : this._internal(
        (ref) => periodById(ref as PeriodByIdRef, id),
        from: periodByIdProvider,
        name: r'periodByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$periodByIdHash,
        dependencies: PeriodByIdFamily._dependencies,
        allTransitiveDependencies: PeriodByIdFamily._allTransitiveDependencies,
        id: id,
      );

  PeriodByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<ScoringPeriod?> Function(PeriodByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PeriodByIdProvider._internal(
        (ref) => create(ref as PeriodByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ScoringPeriod?> createElement() {
    return _PeriodByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PeriodByIdRef on AutoDisposeFutureProviderRef<ScoringPeriod?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PeriodByIdProviderElement
    extends AutoDisposeFutureProviderElement<ScoringPeriod?>
    with PeriodByIdRef {
  _PeriodByIdProviderElement(super.provider);

  @override
  String get id => (origin as PeriodByIdProvider).id;
}

String _$measureFormHash() => r'24a6fd8c37056e019ff30beab1591cc091156721';

/// Measure creation/update notifier.
///
/// Copied from [MeasureForm].
@ProviderFor(MeasureForm)
final measureFormProvider =
    AutoDisposeAsyncNotifierProvider<MeasureForm, MeasureDefinition?>.internal(
      MeasureForm.new,
      name: r'measureFormProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$measureFormHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MeasureForm = AutoDisposeAsyncNotifier<MeasureDefinition?>;
String _$periodFormHash() => r'c5696870f704a7d13fa20591865a30c3aecec1c6';

/// Period creation/update notifier.
///
/// Copied from [PeriodForm].
@ProviderFor(PeriodForm)
final periodFormProvider =
    AutoDisposeAsyncNotifierProvider<PeriodForm, ScoringPeriod?>.internal(
      PeriodForm.new,
      name: r'periodFormProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$periodFormHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PeriodForm = AutoDisposeAsyncNotifier<ScoringPeriod?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
