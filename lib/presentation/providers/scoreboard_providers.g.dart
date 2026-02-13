// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoreboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scoreboardLocalDataSourceHash() =>
    r'41bbd9b90a76cd88da5a5523f3f7a7cbb8c75df1';

/// See also [scoreboardLocalDataSource].
@ProviderFor(scoreboardLocalDataSource)
final scoreboardLocalDataSourceProvider =
    AutoDisposeProvider<ScoreboardLocalDataSource>.internal(
      scoreboardLocalDataSource,
      name: r'scoreboardLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scoreboardLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScoreboardLocalDataSourceRef =
    AutoDisposeProviderRef<ScoreboardLocalDataSource>;
String _$scoreboardRemoteDataSourceHash() =>
    r'e41d6cdc818e128b0c1c64c17b77f1e53b958a02';

/// See also [scoreboardRemoteDataSource].
@ProviderFor(scoreboardRemoteDataSource)
final scoreboardRemoteDataSourceProvider =
    AutoDisposeProvider<ScoreboardRemoteDataSource>.internal(
      scoreboardRemoteDataSource,
      name: r'scoreboardRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scoreboardRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScoreboardRemoteDataSourceRef =
    AutoDisposeProviderRef<ScoreboardRemoteDataSource>;
String _$scoreboardRepositoryHash() =>
    r'22d298a46cceaa4887e3ab9e269445f421e34b99';

/// See also [scoreboardRepository].
@ProviderFor(scoreboardRepository)
final scoreboardRepositoryProvider =
    AutoDisposeProvider<ScoreboardRepository>.internal(
      scoreboardRepository,
      name: r'scoreboardRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scoreboardRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScoreboardRepositoryRef = AutoDisposeProviderRef<ScoreboardRepository>;
String _$scoringPeriodsHash() => r'51520c5ba9e0fc602d80f0f1f40e8086779be39b';

/// Get all scoring periods.
///
/// Copied from [scoringPeriods].
@ProviderFor(scoringPeriods)
final scoringPeriodsProvider =
    AutoDisposeFutureProvider<List<ScoringPeriod>>.internal(
      scoringPeriods,
      name: r'scoringPeriodsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scoringPeriodsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScoringPeriodsRef = AutoDisposeFutureProviderRef<List<ScoringPeriod>>;
String _$currentPeriodHash() => r'77c2e3d272408539472799594fa514360c5b95ba';

/// Get the current scoring period.
///
/// Copied from [currentPeriod].
@ProviderFor(currentPeriod)
final currentPeriodProvider =
    AutoDisposeFutureProvider<ScoringPeriod?>.internal(
      currentPeriod,
      name: r'currentPeriodProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentPeriodHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPeriodRef = AutoDisposeFutureProviderRef<ScoringPeriod?>;
String _$measureDefinitionsHash() =>
    r'f6a3d9430b7c9cc4938575052e213293456b22f7';

/// Get all measure definitions.
///
/// Copied from [measureDefinitions].
@ProviderFor(measureDefinitions)
final measureDefinitionsProvider =
    AutoDisposeFutureProvider<List<MeasureDefinition>>.internal(
      measureDefinitions,
      name: r'measureDefinitionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$measureDefinitionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MeasureDefinitionsRef =
    AutoDisposeFutureProviderRef<List<MeasureDefinition>>;
String _$leadMeasuresHash() => r'9216164c28cb3af8aa03c43d992624ec9c52c32c';

/// Get lead measure definitions.
///
/// Copied from [leadMeasures].
@ProviderFor(leadMeasures)
final leadMeasuresProvider =
    AutoDisposeFutureProvider<List<MeasureDefinition>>.internal(
      leadMeasures,
      name: r'leadMeasuresProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leadMeasuresHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeadMeasuresRef = AutoDisposeFutureProviderRef<List<MeasureDefinition>>;
String _$lagMeasuresHash() => r'2e5e2987bde14dbb19e5f3595579ea5770efb1d9';

/// Get lag measure definitions.
///
/// Copied from [lagMeasures].
@ProviderFor(lagMeasures)
final lagMeasuresProvider =
    AutoDisposeFutureProvider<List<MeasureDefinition>>.internal(
      lagMeasures,
      name: r'lagMeasuresProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lagMeasuresHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LagMeasuresRef = AutoDisposeFutureProviderRef<List<MeasureDefinition>>;
String _$userScoresHash() => r'5f0d45ed31a9d5a2b4b24768485ffa1b81ea899d';

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

/// Get user scores for a period.
///
/// Copied from [userScores].
@ProviderFor(userScores)
const userScoresProvider = UserScoresFamily();

/// Get user scores for a period.
///
/// Copied from [userScores].
class UserScoresFamily extends Family<AsyncValue<List<UserScore>>> {
  /// Get user scores for a period.
  ///
  /// Copied from [userScores].
  const UserScoresFamily();

  /// Get user scores for a period.
  ///
  /// Copied from [userScores].
  UserScoresProvider call(String userId, String periodId) {
    return UserScoresProvider(userId, periodId);
  }

  @override
  UserScoresProvider getProviderOverride(
    covariant UserScoresProvider provider,
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
  String? get name => r'userScoresProvider';
}

/// Get user scores for a period.
///
/// Copied from [userScores].
class UserScoresProvider extends AutoDisposeFutureProvider<List<UserScore>> {
  /// Get user scores for a period.
  ///
  /// Copied from [userScores].
  UserScoresProvider(String userId, String periodId)
    : this._internal(
        (ref) => userScores(ref as UserScoresRef, userId, periodId),
        from: userScoresProvider,
        name: r'userScoresProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userScoresHash,
        dependencies: UserScoresFamily._dependencies,
        allTransitiveDependencies: UserScoresFamily._allTransitiveDependencies,
        userId: userId,
        periodId: periodId,
      );

  UserScoresProvider._internal(
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
    FutureOr<List<UserScore>> Function(UserScoresRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserScoresProvider._internal(
        (ref) => create(ref as UserScoresRef),
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
  AutoDisposeFutureProviderElement<List<UserScore>> createElement() {
    return _UserScoresProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserScoresProvider &&
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
mixin UserScoresRef on AutoDisposeFutureProviderRef<List<UserScore>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _UserScoresProviderElement
    extends AutoDisposeFutureProviderElement<List<UserScore>>
    with UserScoresRef {
  _UserScoresProviderElement(super.provider);

  @override
  String get userId => (origin as UserScoresProvider).userId;
  @override
  String get periodId => (origin as UserScoresProvider).periodId;
}

String _$userLeadScoresHash() => r'ddc30b590ad44573655a5a6f5db59ea2e03e34e5';

/// Get user's lead scores.
///
/// Copied from [userLeadScores].
@ProviderFor(userLeadScores)
const userLeadScoresProvider = UserLeadScoresFamily();

/// Get user's lead scores.
///
/// Copied from [userLeadScores].
class UserLeadScoresFamily extends Family<AsyncValue<List<UserScore>>> {
  /// Get user's lead scores.
  ///
  /// Copied from [userLeadScores].
  const UserLeadScoresFamily();

  /// Get user's lead scores.
  ///
  /// Copied from [userLeadScores].
  UserLeadScoresProvider call(String userId, String periodId) {
    return UserLeadScoresProvider(userId, periodId);
  }

  @override
  UserLeadScoresProvider getProviderOverride(
    covariant UserLeadScoresProvider provider,
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
  String? get name => r'userLeadScoresProvider';
}

/// Get user's lead scores.
///
/// Copied from [userLeadScores].
class UserLeadScoresProvider
    extends AutoDisposeFutureProvider<List<UserScore>> {
  /// Get user's lead scores.
  ///
  /// Copied from [userLeadScores].
  UserLeadScoresProvider(String userId, String periodId)
    : this._internal(
        (ref) => userLeadScores(ref as UserLeadScoresRef, userId, periodId),
        from: userLeadScoresProvider,
        name: r'userLeadScoresProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userLeadScoresHash,
        dependencies: UserLeadScoresFamily._dependencies,
        allTransitiveDependencies:
            UserLeadScoresFamily._allTransitiveDependencies,
        userId: userId,
        periodId: periodId,
      );

  UserLeadScoresProvider._internal(
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
    FutureOr<List<UserScore>> Function(UserLeadScoresRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserLeadScoresProvider._internal(
        (ref) => create(ref as UserLeadScoresRef),
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
  AutoDisposeFutureProviderElement<List<UserScore>> createElement() {
    return _UserLeadScoresProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserLeadScoresProvider &&
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
mixin UserLeadScoresRef on AutoDisposeFutureProviderRef<List<UserScore>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _UserLeadScoresProviderElement
    extends AutoDisposeFutureProviderElement<List<UserScore>>
    with UserLeadScoresRef {
  _UserLeadScoresProviderElement(super.provider);

  @override
  String get userId => (origin as UserLeadScoresProvider).userId;
  @override
  String get periodId => (origin as UserLeadScoresProvider).periodId;
}

String _$userLagScoresHash() => r'612e51777533718c0ab61b4455d9af0703e3416e';

/// Get user's lag scores.
///
/// Copied from [userLagScores].
@ProviderFor(userLagScores)
const userLagScoresProvider = UserLagScoresFamily();

/// Get user's lag scores.
///
/// Copied from [userLagScores].
class UserLagScoresFamily extends Family<AsyncValue<List<UserScore>>> {
  /// Get user's lag scores.
  ///
  /// Copied from [userLagScores].
  const UserLagScoresFamily();

  /// Get user's lag scores.
  ///
  /// Copied from [userLagScores].
  UserLagScoresProvider call(String userId, String periodId) {
    return UserLagScoresProvider(userId, periodId);
  }

  @override
  UserLagScoresProvider getProviderOverride(
    covariant UserLagScoresProvider provider,
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
  String? get name => r'userLagScoresProvider';
}

/// Get user's lag scores.
///
/// Copied from [userLagScores].
class UserLagScoresProvider extends AutoDisposeFutureProvider<List<UserScore>> {
  /// Get user's lag scores.
  ///
  /// Copied from [userLagScores].
  UserLagScoresProvider(String userId, String periodId)
    : this._internal(
        (ref) => userLagScores(ref as UserLagScoresRef, userId, periodId),
        from: userLagScoresProvider,
        name: r'userLagScoresProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userLagScoresHash,
        dependencies: UserLagScoresFamily._dependencies,
        allTransitiveDependencies:
            UserLagScoresFamily._allTransitiveDependencies,
        userId: userId,
        periodId: periodId,
      );

  UserLagScoresProvider._internal(
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
    FutureOr<List<UserScore>> Function(UserLagScoresRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserLagScoresProvider._internal(
        (ref) => create(ref as UserLagScoresRef),
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
  AutoDisposeFutureProviderElement<List<UserScore>> createElement() {
    return _UserLagScoresProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserLagScoresProvider &&
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
mixin UserLagScoresRef on AutoDisposeFutureProviderRef<List<UserScore>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _UserLagScoresProviderElement
    extends AutoDisposeFutureProviderElement<List<UserScore>>
    with UserLagScoresRef {
  _UserLagScoresProviderElement(super.provider);

  @override
  String get userId => (origin as UserLagScoresProvider).userId;
  @override
  String get periodId => (origin as UserLagScoresProvider).periodId;
}

String _$userTargetsHash() => r'1e2c5c5c9b5462592fb2518df1f94817dd78159d';

/// Get user targets for a period.
///
/// Copied from [userTargets].
@ProviderFor(userTargets)
const userTargetsProvider = UserTargetsFamily();

/// Get user targets for a period.
///
/// Copied from [userTargets].
class UserTargetsFamily extends Family<AsyncValue<List<UserTarget>>> {
  /// Get user targets for a period.
  ///
  /// Copied from [userTargets].
  const UserTargetsFamily();

  /// Get user targets for a period.
  ///
  /// Copied from [userTargets].
  UserTargetsProvider call(String userId, String periodId) {
    return UserTargetsProvider(userId, periodId);
  }

  @override
  UserTargetsProvider getProviderOverride(
    covariant UserTargetsProvider provider,
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
  String? get name => r'userTargetsProvider';
}

/// Get user targets for a period.
///
/// Copied from [userTargets].
class UserTargetsProvider extends AutoDisposeFutureProvider<List<UserTarget>> {
  /// Get user targets for a period.
  ///
  /// Copied from [userTargets].
  UserTargetsProvider(String userId, String periodId)
    : this._internal(
        (ref) => userTargets(ref as UserTargetsRef, userId, periodId),
        from: userTargetsProvider,
        name: r'userTargetsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userTargetsHash,
        dependencies: UserTargetsFamily._dependencies,
        allTransitiveDependencies: UserTargetsFamily._allTransitiveDependencies,
        userId: userId,
        periodId: periodId,
      );

  UserTargetsProvider._internal(
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
    FutureOr<List<UserTarget>> Function(UserTargetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserTargetsProvider._internal(
        (ref) => create(ref as UserTargetsRef),
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
    return _UserTargetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTargetsProvider &&
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
mixin UserTargetsRef on AutoDisposeFutureProviderRef<List<UserTarget>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _UserTargetsProviderElement
    extends AutoDisposeFutureProviderElement<List<UserTarget>>
    with UserTargetsRef {
  _UserTargetsProviderElement(super.provider);

  @override
  String get userId => (origin as UserTargetsProvider).userId;
  @override
  String get periodId => (origin as UserTargetsProvider).periodId;
}

String _$userPeriodSummaryHash() => r'7170914c95f342c9ce1ed349c82649cca0762c97';

/// Get user's period summary.
///
/// Copied from [userPeriodSummary].
@ProviderFor(userPeriodSummary)
const userPeriodSummaryProvider = UserPeriodSummaryFamily();

/// Get user's period summary.
///
/// Copied from [userPeriodSummary].
class UserPeriodSummaryFamily extends Family<AsyncValue<PeriodSummary?>> {
  /// Get user's period summary.
  ///
  /// Copied from [userPeriodSummary].
  const UserPeriodSummaryFamily();

  /// Get user's period summary.
  ///
  /// Copied from [userPeriodSummary].
  UserPeriodSummaryProvider call(String userId, String periodId) {
    return UserPeriodSummaryProvider(userId, periodId);
  }

  @override
  UserPeriodSummaryProvider getProviderOverride(
    covariant UserPeriodSummaryProvider provider,
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
  String? get name => r'userPeriodSummaryProvider';
}

/// Get user's period summary.
///
/// Copied from [userPeriodSummary].
class UserPeriodSummaryProvider
    extends AutoDisposeFutureProvider<PeriodSummary?> {
  /// Get user's period summary.
  ///
  /// Copied from [userPeriodSummary].
  UserPeriodSummaryProvider(String userId, String periodId)
    : this._internal(
        (ref) =>
            userPeriodSummary(ref as UserPeriodSummaryRef, userId, periodId),
        from: userPeriodSummaryProvider,
        name: r'userPeriodSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userPeriodSummaryHash,
        dependencies: UserPeriodSummaryFamily._dependencies,
        allTransitiveDependencies:
            UserPeriodSummaryFamily._allTransitiveDependencies,
        userId: userId,
        periodId: periodId,
      );

  UserPeriodSummaryProvider._internal(
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
    FutureOr<PeriodSummary?> Function(UserPeriodSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserPeriodSummaryProvider._internal(
        (ref) => create(ref as UserPeriodSummaryRef),
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
  AutoDisposeFutureProviderElement<PeriodSummary?> createElement() {
    return _UserPeriodSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPeriodSummaryProvider &&
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
mixin UserPeriodSummaryRef on AutoDisposeFutureProviderRef<PeriodSummary?> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `periodId` of this provider.
  String get periodId;
}

class _UserPeriodSummaryProviderElement
    extends AutoDisposeFutureProviderElement<PeriodSummary?>
    with UserPeriodSummaryRef {
  _UserPeriodSummaryProviderElement(super.provider);

  @override
  String get userId => (origin as UserPeriodSummaryProvider).userId;
  @override
  String get periodId => (origin as UserPeriodSummaryProvider).periodId;
}

String _$currentUserPeriodSummaryHash() =>
    r'c43dd9f240f3ab01043eee8c6f655b8f887e1d03';

/// Get current user's period summary for current period.
///
/// Copied from [currentUserPeriodSummary].
@ProviderFor(currentUserPeriodSummary)
final currentUserPeriodSummaryProvider =
    AutoDisposeFutureProvider<PeriodSummary?>.internal(
      currentUserPeriodSummary,
      name: r'currentUserPeriodSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentUserPeriodSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserPeriodSummaryRef =
    AutoDisposeFutureProviderRef<PeriodSummary?>;
String _$leaderboardHash() => r'389ae6b0e9c87cdec2e4b72e1a09d84200ecf19e';

/// Get leaderboard for a period.
///
/// Copied from [leaderboard].
@ProviderFor(leaderboard)
const leaderboardProvider = LeaderboardFamily();

/// Get leaderboard for a period.
///
/// Copied from [leaderboard].
class LeaderboardFamily extends Family<AsyncValue<List<LeaderboardEntry>>> {
  /// Get leaderboard for a period.
  ///
  /// Copied from [leaderboard].
  const LeaderboardFamily();

  /// Get leaderboard for a period.
  ///
  /// Copied from [leaderboard].
  LeaderboardProvider call(String periodId, {int limit = 10}) {
    return LeaderboardProvider(periodId, limit: limit);
  }

  @override
  LeaderboardProvider getProviderOverride(
    covariant LeaderboardProvider provider,
  ) {
    return call(provider.periodId, limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'leaderboardProvider';
}

/// Get leaderboard for a period.
///
/// Copied from [leaderboard].
class LeaderboardProvider
    extends AutoDisposeFutureProvider<List<LeaderboardEntry>> {
  /// Get leaderboard for a period.
  ///
  /// Copied from [leaderboard].
  LeaderboardProvider(String periodId, {int limit = 10})
    : this._internal(
        (ref) => leaderboard(ref as LeaderboardRef, periodId, limit: limit),
        from: leaderboardProvider,
        name: r'leaderboardProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leaderboardHash,
        dependencies: LeaderboardFamily._dependencies,
        allTransitiveDependencies: LeaderboardFamily._allTransitiveDependencies,
        periodId: periodId,
        limit: limit,
      );

  LeaderboardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.periodId,
    required this.limit,
  }) : super.internal();

  final String periodId;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<LeaderboardEntry>> Function(LeaderboardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LeaderboardProvider._internal(
        (ref) => create(ref as LeaderboardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        periodId: periodId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LeaderboardEntry>> createElement() {
    return _LeaderboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaderboardProvider &&
        other.periodId == periodId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, periodId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LeaderboardRef on AutoDisposeFutureProviderRef<List<LeaderboardEntry>> {
  /// The parameter `periodId` of this provider.
  String get periodId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _LeaderboardProviderElement
    extends AutoDisposeFutureProviderElement<List<LeaderboardEntry>>
    with LeaderboardRef {
  _LeaderboardProviderElement(super.provider);

  @override
  String get periodId => (origin as LeaderboardProvider).periodId;
  @override
  int get limit => (origin as LeaderboardProvider).limit;
}

String _$currentPeriodLeaderboardHash() =>
    r'2bdb5f8ecb600903bd9dd24e24efde30fbaa72b4';

/// Get leaderboard for current period.
///
/// Copied from [currentPeriodLeaderboard].
@ProviderFor(currentPeriodLeaderboard)
final currentPeriodLeaderboardProvider =
    AutoDisposeFutureProvider<List<LeaderboardEntry>>.internal(
      currentPeriodLeaderboard,
      name: r'currentPeriodLeaderboardProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentPeriodLeaderboardHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPeriodLeaderboardRef =
    AutoDisposeFutureProviderRef<List<LeaderboardEntry>>;
String _$dashboardStatsHash() => r'72bffd27eb4d7d0128e313da0ff0a33edacff1ad';

/// Get dashboard statistics for current user.
///
/// Copied from [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeFutureProvider<DashboardStats>.internal(
      dashboardStats,
      name: r'dashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardStatsRef = AutoDisposeFutureProviderRef<DashboardStats>;
String _$filteredLeaderboardHash() =>
    r'5db380f1332576b2a74cf20ba9f4113d7f19e091';

/// Get filtered leaderboard based on current filter state.
///
/// Copied from [filteredLeaderboard].
@ProviderFor(filteredLeaderboard)
const filteredLeaderboardProvider = FilteredLeaderboardFamily();

/// Get filtered leaderboard based on current filter state.
///
/// Copied from [filteredLeaderboard].
class FilteredLeaderboardFamily
    extends Family<AsyncValue<List<LeaderboardEntry>>> {
  /// Get filtered leaderboard based on current filter state.
  ///
  /// Copied from [filteredLeaderboard].
  const FilteredLeaderboardFamily();

  /// Get filtered leaderboard based on current filter state.
  ///
  /// Copied from [filteredLeaderboard].
  FilteredLeaderboardProvider call(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
    String? searchQuery,
  }) {
    return FilteredLeaderboardProvider(
      periodId,
      branchId: branchId,
      regionalOfficeId: regionalOfficeId,
      searchQuery: searchQuery,
    );
  }

  @override
  FilteredLeaderboardProvider getProviderOverride(
    covariant FilteredLeaderboardProvider provider,
  ) {
    return call(
      provider.periodId,
      branchId: provider.branchId,
      regionalOfficeId: provider.regionalOfficeId,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredLeaderboardProvider';
}

/// Get filtered leaderboard based on current filter state.
///
/// Copied from [filteredLeaderboard].
class FilteredLeaderboardProvider
    extends AutoDisposeFutureProvider<List<LeaderboardEntry>> {
  /// Get filtered leaderboard based on current filter state.
  ///
  /// Copied from [filteredLeaderboard].
  FilteredLeaderboardProvider(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
    String? searchQuery,
  }) : this._internal(
         (ref) => filteredLeaderboard(
           ref as FilteredLeaderboardRef,
           periodId,
           branchId: branchId,
           regionalOfficeId: regionalOfficeId,
           searchQuery: searchQuery,
         ),
         from: filteredLeaderboardProvider,
         name: r'filteredLeaderboardProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$filteredLeaderboardHash,
         dependencies: FilteredLeaderboardFamily._dependencies,
         allTransitiveDependencies:
             FilteredLeaderboardFamily._allTransitiveDependencies,
         periodId: periodId,
         branchId: branchId,
         regionalOfficeId: regionalOfficeId,
         searchQuery: searchQuery,
       );

  FilteredLeaderboardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.periodId,
    required this.branchId,
    required this.regionalOfficeId,
    required this.searchQuery,
  }) : super.internal();

  final String periodId;
  final String? branchId;
  final String? regionalOfficeId;
  final String? searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<LeaderboardEntry>> Function(FilteredLeaderboardRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredLeaderboardProvider._internal(
        (ref) => create(ref as FilteredLeaderboardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        periodId: periodId,
        branchId: branchId,
        regionalOfficeId: regionalOfficeId,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LeaderboardEntry>> createElement() {
    return _FilteredLeaderboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredLeaderboardProvider &&
        other.periodId == periodId &&
        other.branchId == branchId &&
        other.regionalOfficeId == regionalOfficeId &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, periodId.hashCode);
    hash = _SystemHash.combine(hash, branchId.hashCode);
    hash = _SystemHash.combine(hash, regionalOfficeId.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredLeaderboardRef
    on AutoDisposeFutureProviderRef<List<LeaderboardEntry>> {
  /// The parameter `periodId` of this provider.
  String get periodId;

  /// The parameter `branchId` of this provider.
  String? get branchId;

  /// The parameter `regionalOfficeId` of this provider.
  String? get regionalOfficeId;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _FilteredLeaderboardProviderElement
    extends AutoDisposeFutureProviderElement<List<LeaderboardEntry>>
    with FilteredLeaderboardRef {
  _FilteredLeaderboardProviderElement(super.provider);

  @override
  String get periodId => (origin as FilteredLeaderboardProvider).periodId;
  @override
  String? get branchId => (origin as FilteredLeaderboardProvider).branchId;
  @override
  String? get regionalOfficeId =>
      (origin as FilteredLeaderboardProvider).regionalOfficeId;
  @override
  String? get searchQuery =>
      (origin as FilteredLeaderboardProvider).searchQuery;
}

String _$teamSummaryHash() => r'bcca0f7ec4edfa2e5221aa5a7eb31ab5fb20d87f';

/// Get team summary for branch or region.
///
/// Copied from [teamSummary].
@ProviderFor(teamSummary)
const teamSummaryProvider = TeamSummaryFamily();

/// Get team summary for branch or region.
///
/// Copied from [teamSummary].
class TeamSummaryFamily extends Family<AsyncValue<TeamSummary?>> {
  /// Get team summary for branch or region.
  ///
  /// Copied from [teamSummary].
  const TeamSummaryFamily();

  /// Get team summary for branch or region.
  ///
  /// Copied from [teamSummary].
  TeamSummaryProvider call(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
  }) {
    return TeamSummaryProvider(
      periodId,
      branchId: branchId,
      regionalOfficeId: regionalOfficeId,
    );
  }

  @override
  TeamSummaryProvider getProviderOverride(
    covariant TeamSummaryProvider provider,
  ) {
    return call(
      provider.periodId,
      branchId: provider.branchId,
      regionalOfficeId: provider.regionalOfficeId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teamSummaryProvider';
}

/// Get team summary for branch or region.
///
/// Copied from [teamSummary].
class TeamSummaryProvider extends AutoDisposeFutureProvider<TeamSummary?> {
  /// Get team summary for branch or region.
  ///
  /// Copied from [teamSummary].
  TeamSummaryProvider(
    String periodId, {
    String? branchId,
    String? regionalOfficeId,
  }) : this._internal(
         (ref) => teamSummary(
           ref as TeamSummaryRef,
           periodId,
           branchId: branchId,
           regionalOfficeId: regionalOfficeId,
         ),
         from: teamSummaryProvider,
         name: r'teamSummaryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$teamSummaryHash,
         dependencies: TeamSummaryFamily._dependencies,
         allTransitiveDependencies:
             TeamSummaryFamily._allTransitiveDependencies,
         periodId: periodId,
         branchId: branchId,
         regionalOfficeId: regionalOfficeId,
       );

  TeamSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.periodId,
    required this.branchId,
    required this.regionalOfficeId,
  }) : super.internal();

  final String periodId;
  final String? branchId;
  final String? regionalOfficeId;

  @override
  Override overrideWith(
    FutureOr<TeamSummary?> Function(TeamSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeamSummaryProvider._internal(
        (ref) => create(ref as TeamSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        periodId: periodId,
        branchId: branchId,
        regionalOfficeId: regionalOfficeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TeamSummary?> createElement() {
    return _TeamSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeamSummaryProvider &&
        other.periodId == periodId &&
        other.branchId == branchId &&
        other.regionalOfficeId == regionalOfficeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, periodId.hashCode);
    hash = _SystemHash.combine(hash, branchId.hashCode);
    hash = _SystemHash.combine(hash, regionalOfficeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeamSummaryRef on AutoDisposeFutureProviderRef<TeamSummary?> {
  /// The parameter `periodId` of this provider.
  String get periodId;

  /// The parameter `branchId` of this provider.
  String? get branchId;

  /// The parameter `regionalOfficeId` of this provider.
  String? get regionalOfficeId;
}

class _TeamSummaryProviderElement
    extends AutoDisposeFutureProviderElement<TeamSummary?>
    with TeamSummaryRef {
  _TeamSummaryProviderElement(super.provider);

  @override
  String get periodId => (origin as TeamSummaryProvider).periodId;
  @override
  String? get branchId => (origin as TeamSummaryProvider).branchId;
  @override
  String? get regionalOfficeId =>
      (origin as TeamSummaryProvider).regionalOfficeId;
}

String _$scoreboardNotifierHash() =>
    r'a285812880552fdd57fd2c044612189c5b613806';

/// See also [ScoreboardNotifier].
@ProviderFor(ScoreboardNotifier)
final scoreboardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ScoreboardNotifier,
      ScoreboardState
    >.internal(
      ScoreboardNotifier.new,
      name: r'scoreboardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scoreboardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScoreboardNotifier = AutoDisposeAsyncNotifier<ScoreboardState>;
String _$leaderboardFilterNotifierHash() =>
    r'6f3695a356058861af65c953f2827827f0ea6daa';

/// Notifier for managing leaderboard filter state.
///
/// Copied from [LeaderboardFilterNotifier].
@ProviderFor(LeaderboardFilterNotifier)
final leaderboardFilterNotifierProvider =
    AutoDisposeNotifierProvider<
      LeaderboardFilterNotifier,
      LeaderboardFilter
    >.internal(
      LeaderboardFilterNotifier.new,
      name: r'leaderboardFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leaderboardFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeaderboardFilterNotifier = AutoDisposeNotifier<LeaderboardFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
