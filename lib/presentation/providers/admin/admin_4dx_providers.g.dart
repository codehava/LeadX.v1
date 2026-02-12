// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_4dx_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$admin4DXRepositoryHash() =>
    r'64d0b8f60cb342b06390826834571044255aaa10';

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
String _$allMeasuresHash() => r'0108c66297418d7a77a37e1d2356042e658d95a9';

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
String _$measureByIdHash() => r'b44017d9175879d08f9dc360cf49e37edadf4833';

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

String _$allPeriodsHash() => r'68209dfcf25c49592405c47a51ac58753a6b39a8';

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
String _$periodByIdHash() => r'108d9f04651bf3d45782af6fbbffe802b5a5fc9f';

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

String _$targetsForPeriodHash() => r'7e38d90fb5525c00f1a62aa32b6fb098027d1077';

/// Get all targets for a specific period.
///
/// Copied from [targetsForPeriod].
@ProviderFor(targetsForPeriod)
const targetsForPeriodProvider = TargetsForPeriodFamily();

/// Get all targets for a specific period.
///
/// Copied from [targetsForPeriod].
class TargetsForPeriodFamily extends Family<AsyncValue<List<UserTarget>>> {
  /// Get all targets for a specific period.
  ///
  /// Copied from [targetsForPeriod].
  const TargetsForPeriodFamily();

  /// Get all targets for a specific period.
  ///
  /// Copied from [targetsForPeriod].
  TargetsForPeriodProvider call(String periodId) {
    return TargetsForPeriodProvider(periodId);
  }

  @override
  TargetsForPeriodProvider getProviderOverride(
    covariant TargetsForPeriodProvider provider,
  ) {
    return call(provider.periodId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'targetsForPeriodProvider';
}

/// Get all targets for a specific period.
///
/// Copied from [targetsForPeriod].
class TargetsForPeriodProvider
    extends AutoDisposeFutureProvider<List<UserTarget>> {
  /// Get all targets for a specific period.
  ///
  /// Copied from [targetsForPeriod].
  TargetsForPeriodProvider(String periodId)
    : this._internal(
        (ref) => targetsForPeriod(ref as TargetsForPeriodRef, periodId),
        from: targetsForPeriodProvider,
        name: r'targetsForPeriodProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$targetsForPeriodHash,
        dependencies: TargetsForPeriodFamily._dependencies,
        allTransitiveDependencies:
            TargetsForPeriodFamily._allTransitiveDependencies,
        periodId: periodId,
      );

  TargetsForPeriodProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.periodId,
  }) : super.internal();

  final String periodId;

  @override
  Override overrideWith(
    FutureOr<List<UserTarget>> Function(TargetsForPeriodRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TargetsForPeriodProvider._internal(
        (ref) => create(ref as TargetsForPeriodRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        periodId: periodId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserTarget>> createElement() {
    return _TargetsForPeriodProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TargetsForPeriodProvider && other.periodId == periodId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, periodId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TargetsForPeriodRef on AutoDisposeFutureProviderRef<List<UserTarget>> {
  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _TargetsForPeriodProviderElement
    extends AutoDisposeFutureProviderElement<List<UserTarget>>
    with TargetsForPeriodRef {
  _TargetsForPeriodProviderElement(super.provider);

  @override
  String get periodId => (origin as TargetsForPeriodProvider).periodId;
}

String _$adminUserTargetsHash() => r'6c60ca4b400d02ac378e22d7dc366ef562b33d23';

/// Get targets for a specific user in a period.
///
/// Copied from [adminUserTargets].
@ProviderFor(adminUserTargets)
const adminUserTargetsProvider = AdminUserTargetsFamily();

/// Get targets for a specific user in a period.
///
/// Copied from [adminUserTargets].
class AdminUserTargetsFamily extends Family<AsyncValue<List<UserTarget>>> {
  /// Get targets for a specific user in a period.
  ///
  /// Copied from [adminUserTargets].
  const AdminUserTargetsFamily();

  /// Get targets for a specific user in a period.
  ///
  /// Copied from [adminUserTargets].
  AdminUserTargetsProvider call(String userId, String periodId) {
    return AdminUserTargetsProvider(userId, periodId);
  }

  @override
  AdminUserTargetsProvider getProviderOverride(
    covariant AdminUserTargetsProvider provider,
  ) {
    return call(provider.userId, provider.periodId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminUserTargetsProvider';
}

/// Get targets for a specific user in a period.
///
/// Copied from [adminUserTargets].
class AdminUserTargetsProvider
    extends AutoDisposeFutureProvider<List<UserTarget>> {
  /// Get targets for a specific user in a period.
  ///
  /// Copied from [adminUserTargets].
  AdminUserTargetsProvider(String userId, String periodId)
    : this._internal(
        (ref) => adminUserTargets(ref as AdminUserTargetsRef, userId, periodId),
        from: adminUserTargetsProvider,
        name: r'adminUserTargetsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminUserTargetsHash,
        dependencies: AdminUserTargetsFamily._dependencies,
        allTransitiveDependencies:
            AdminUserTargetsFamily._allTransitiveDependencies,
        userId: userId,
        periodId: periodId,
      );

  AdminUserTargetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.periodId,
  }) : super.internal();

  final String userId;
  final String periodId;

  @override
  Override overrideWith(
    FutureOr<List<UserTarget>> Function(AdminUserTargetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminUserTargetsProvider._internal(
        (ref) => create(ref as AdminUserTargetsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        periodId: periodId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserTarget>> createElement() {
    return _AdminUserTargetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserTargetsProvider &&
        other.userId == userId &&
        other.periodId == periodId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, periodId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminUserTargetsRef on AutoDisposeFutureProviderRef<List<UserTarget>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _AdminUserTargetsProviderElement
    extends AutoDisposeFutureProviderElement<List<UserTarget>>
    with AdminUserTargetsRef {
  _AdminUserTargetsProviderElement(super.provider);

  @override
  String get userId => (origin as AdminUserTargetsProvider).userId;
  @override
  String get periodId => (origin as AdminUserTargetsProvider).periodId;
}

String _$measureFormHash() => r'69a00d09f5e90a6fca8038f0834b4526f31813ac';

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
String _$periodFormHash() => r'ecc3f8307ece7e0f731c5927d567082acebcc341';

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
String _$targetAssignmentHash() => r'4b4041e61dec099d2631634aae293f851232a9d8';

/// Target assignment notifier for admin operations.
///
/// Copied from [TargetAssignment].
@ProviderFor(TargetAssignment)
final targetAssignmentProvider =
    AutoDisposeAsyncNotifierProvider<TargetAssignment, void>.internal(
      TargetAssignment.new,
      name: r'targetAssignmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$targetAssignmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TargetAssignment = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
