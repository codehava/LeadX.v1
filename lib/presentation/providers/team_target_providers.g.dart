// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_target_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$canManageTeamTargetsHash() =>
    r'94068f70483b82d022b828e735180694e8ffe881';

/// Whether the current user can manage team targets (BH/BM/ROH, not admin/RM).
///
/// Copied from [canManageTeamTargets].
@ProviderFor(canManageTeamTargets)
final canManageTeamTargetsProvider = AutoDisposeProvider<bool>.internal(
  canManageTeamTargets,
  name: r'canManageTeamTargetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canManageTeamTargetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanManageTeamTargetsRef = AutoDisposeProviderRef<bool>;
String _$mySubordinatesHash() => r'57d5a59a60eedaaf1c9e76e3fbdcd0ca7cab1a0c';

/// Get subordinates for the current user (manager's direct reports).
///
/// Copied from [mySubordinates].
@ProviderFor(mySubordinates)
final mySubordinatesProvider = AutoDisposeFutureProvider<List<User>>.internal(
  mySubordinates,
  name: r'mySubordinatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mySubordinatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySubordinatesRef = AutoDisposeFutureProviderRef<List<User>>;
String _$managerOwnTargetsHash() => r'f9641daedc8aa20f4b570f98886576bb0f45f56c';

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

/// Get the manager's own targets for a period (for cascade reference).
///
/// Copied from [managerOwnTargets].
@ProviderFor(managerOwnTargets)
const managerOwnTargetsProvider = ManagerOwnTargetsFamily();

/// Get the manager's own targets for a period (for cascade reference).
///
/// Copied from [managerOwnTargets].
class ManagerOwnTargetsFamily extends Family<AsyncValue<List<UserTarget>>> {
  /// Get the manager's own targets for a period (for cascade reference).
  ///
  /// Copied from [managerOwnTargets].
  const ManagerOwnTargetsFamily();

  /// Get the manager's own targets for a period (for cascade reference).
  ///
  /// Copied from [managerOwnTargets].
  ManagerOwnTargetsProvider call(String periodId) {
    return ManagerOwnTargetsProvider(periodId);
  }

  @override
  ManagerOwnTargetsProvider getProviderOverride(
    covariant ManagerOwnTargetsProvider provider,
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
  String? get name => r'managerOwnTargetsProvider';
}

/// Get the manager's own targets for a period (for cascade reference).
///
/// Copied from [managerOwnTargets].
class ManagerOwnTargetsProvider
    extends AutoDisposeFutureProvider<List<UserTarget>> {
  /// Get the manager's own targets for a period (for cascade reference).
  ///
  /// Copied from [managerOwnTargets].
  ManagerOwnTargetsProvider(String periodId)
    : this._internal(
        (ref) => managerOwnTargets(ref as ManagerOwnTargetsRef, periodId),
        from: managerOwnTargetsProvider,
        name: r'managerOwnTargetsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$managerOwnTargetsHash,
        dependencies: ManagerOwnTargetsFamily._dependencies,
        allTransitiveDependencies:
            ManagerOwnTargetsFamily._allTransitiveDependencies,
        periodId: periodId,
      );

  ManagerOwnTargetsProvider._internal(
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
    FutureOr<List<UserTarget>> Function(ManagerOwnTargetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManagerOwnTargetsProvider._internal(
        (ref) => create(ref as ManagerOwnTargetsRef),
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
    return _ManagerOwnTargetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManagerOwnTargetsProvider && other.periodId == periodId;
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
mixin ManagerOwnTargetsRef on AutoDisposeFutureProviderRef<List<UserTarget>> {
  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _ManagerOwnTargetsProviderElement
    extends AutoDisposeFutureProviderElement<List<UserTarget>>
    with ManagerOwnTargetsRef {
  _ManagerOwnTargetsProviderElement(super.provider);

  @override
  String get periodId => (origin as ManagerOwnTargetsProvider).periodId;
}

String _$teamTargetAssignmentHash() =>
    r'7e4995a50e252afee4f826f1e59c6575d26d7673';

/// Notifier for saving subordinate targets (delegates to existing bulk assign).
///
/// Copied from [TeamTargetAssignment].
@ProviderFor(TeamTargetAssignment)
final teamTargetAssignmentProvider =
    AutoDisposeAsyncNotifierProvider<TeamTargetAssignment, void>.internal(
      TeamTargetAssignment.new,
      name: r'teamTargetAssignmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teamTargetAssignmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TeamTargetAssignment = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
