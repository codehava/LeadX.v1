// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyLogRemoteDataSourceHash() =>
    r'9a05b4ae1700c744426776f06c76422cd7de75a3';

/// See also [historyLogRemoteDataSource].
@ProviderFor(historyLogRemoteDataSource)
final historyLogRemoteDataSourceProvider =
    AutoDisposeProvider<HistoryLogRemoteDataSource>.internal(
      historyLogRemoteDataSource,
      name: r'historyLogRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyLogRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryLogRemoteDataSourceRef =
    AutoDisposeProviderRef<HistoryLogRemoteDataSource>;
String _$historyLogLocalDataSourceHash() =>
    r'812228dfc30b103be8d7c63a91119c97037cd4cb';

/// See also [historyLogLocalDataSource].
@ProviderFor(historyLogLocalDataSource)
final historyLogLocalDataSourceProvider =
    AutoDisposeProvider<HistoryLogLocalDataSource>.internal(
      historyLogLocalDataSource,
      name: r'historyLogLocalDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyLogLocalDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryLogLocalDataSourceRef =
    AutoDisposeProviderRef<HistoryLogLocalDataSource>;
String _$historyLogRepositoryHash() =>
    r'ac3b6ff4714432070f1c29148078fef9de5c3522';

/// See also [historyLogRepository].
@ProviderFor(historyLogRepository)
final historyLogRepositoryProvider =
    AutoDisposeProvider<HistoryLogRepository>.internal(
      historyLogRepository,
      name: r'historyLogRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyLogRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryLogRepositoryRef = AutoDisposeProviderRef<HistoryLogRepository>;
String _$entityHistoryHash() => r'c98ea88fea0505d01acda744d93fbdb0f63203b7';

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

/// See also [entityHistory].
@ProviderFor(entityHistory)
const entityHistoryProvider = EntityHistoryFamily();

/// See also [entityHistory].
class EntityHistoryFamily extends Family<AsyncValue<List<AuditLog>>> {
  /// See also [entityHistory].
  const EntityHistoryFamily();

  /// See also [entityHistory].
  EntityHistoryProvider call(EntityHistoryParams params) {
    return EntityHistoryProvider(params);
  }

  @override
  EntityHistoryProvider getProviderOverride(
    covariant EntityHistoryProvider provider,
  ) {
    return call(provider.params);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'entityHistoryProvider';
}

/// See also [entityHistory].
class EntityHistoryProvider extends AutoDisposeFutureProvider<List<AuditLog>> {
  /// See also [entityHistory].
  EntityHistoryProvider(EntityHistoryParams params)
    : this._internal(
        (ref) => entityHistory(ref as EntityHistoryRef, params),
        from: entityHistoryProvider,
        name: r'entityHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$entityHistoryHash,
        dependencies: EntityHistoryFamily._dependencies,
        allTransitiveDependencies:
            EntityHistoryFamily._allTransitiveDependencies,
        params: params,
      );

  EntityHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final EntityHistoryParams params;

  @override
  Override overrideWith(
    FutureOr<List<AuditLog>> Function(EntityHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EntityHistoryProvider._internal(
        (ref) => create(ref as EntityHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AuditLog>> createElement() {
    return _EntityHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntityHistoryProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EntityHistoryRef on AutoDisposeFutureProviderRef<List<AuditLog>> {
  /// The parameter `params` of this provider.
  EntityHistoryParams get params;
}

class _EntityHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<AuditLog>>
    with EntityHistoryRef {
  _EntityHistoryProviderElement(super.provider);

  @override
  EntityHistoryParams get params => (origin as EntityHistoryProvider).params;
}

String _$pipelineStageHistoryHash() =>
    r'cdf1065aa14e3ed06b8ba3406602463ee9b94826';

/// See also [pipelineStageHistory].
@ProviderFor(pipelineStageHistory)
const pipelineStageHistoryProvider = PipelineStageHistoryFamily();

/// See also [pipelineStageHistory].
class PipelineStageHistoryFamily
    extends Family<AsyncValue<List<PipelineStageHistory>>> {
  /// See also [pipelineStageHistory].
  const PipelineStageHistoryFamily();

  /// See also [pipelineStageHistory].
  PipelineStageHistoryProvider call(PipelineStageHistoryParams params) {
    return PipelineStageHistoryProvider(params);
  }

  @override
  PipelineStageHistoryProvider getProviderOverride(
    covariant PipelineStageHistoryProvider provider,
  ) {
    return call(provider.params);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pipelineStageHistoryProvider';
}

/// See also [pipelineStageHistory].
class PipelineStageHistoryProvider
    extends AutoDisposeFutureProvider<List<PipelineStageHistory>> {
  /// See also [pipelineStageHistory].
  PipelineStageHistoryProvider(PipelineStageHistoryParams params)
    : this._internal(
        (ref) => pipelineStageHistory(ref as PipelineStageHistoryRef, params),
        from: pipelineStageHistoryProvider,
        name: r'pipelineStageHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pipelineStageHistoryHash,
        dependencies: PipelineStageHistoryFamily._dependencies,
        allTransitiveDependencies:
            PipelineStageHistoryFamily._allTransitiveDependencies,
        params: params,
      );

  PipelineStageHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final PipelineStageHistoryParams params;

  @override
  Override overrideWith(
    FutureOr<List<PipelineStageHistory>> Function(
      PipelineStageHistoryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PipelineStageHistoryProvider._internal(
        (ref) => create(ref as PipelineStageHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PipelineStageHistory>> createElement() {
    return _PipelineStageHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PipelineStageHistoryProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PipelineStageHistoryRef
    on AutoDisposeFutureProviderRef<List<PipelineStageHistory>> {
  /// The parameter `params` of this provider.
  PipelineStageHistoryParams get params;
}

class _PipelineStageHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<PipelineStageHistory>>
    with PipelineStageHistoryRef {
  _PipelineStageHistoryProviderElement(super.provider);

  @override
  PipelineStageHistoryParams get params =>
      (origin as PipelineStageHistoryProvider).params;
}

String _$customerHistoryHash() => r'd05b5005ab83ddeeed94bcb34f83ef8426345e23';

/// Get customer history by ID.
///
/// Copied from [customerHistory].
@ProviderFor(customerHistory)
const customerHistoryProvider = CustomerHistoryFamily();

/// Get customer history by ID.
///
/// Copied from [customerHistory].
class CustomerHistoryFamily extends Family<AsyncValue<List<AuditLog>>> {
  /// Get customer history by ID.
  ///
  /// Copied from [customerHistory].
  const CustomerHistoryFamily();

  /// Get customer history by ID.
  ///
  /// Copied from [customerHistory].
  CustomerHistoryProvider call(String customerId) {
    return CustomerHistoryProvider(customerId);
  }

  @override
  CustomerHistoryProvider getProviderOverride(
    covariant CustomerHistoryProvider provider,
  ) {
    return call(provider.customerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerHistoryProvider';
}

/// Get customer history by ID.
///
/// Copied from [customerHistory].
class CustomerHistoryProvider
    extends AutoDisposeFutureProvider<List<AuditLog>> {
  /// Get customer history by ID.
  ///
  /// Copied from [customerHistory].
  CustomerHistoryProvider(String customerId)
    : this._internal(
        (ref) => customerHistory(ref as CustomerHistoryRef, customerId),
        from: customerHistoryProvider,
        name: r'customerHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerHistoryHash,
        dependencies: CustomerHistoryFamily._dependencies,
        allTransitiveDependencies:
            CustomerHistoryFamily._allTransitiveDependencies,
        customerId: customerId,
      );

  CustomerHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final String customerId;

  @override
  Override overrideWith(
    FutureOr<List<AuditLog>> Function(CustomerHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerHistoryProvider._internal(
        (ref) => create(ref as CustomerHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AuditLog>> createElement() {
    return _CustomerHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerHistoryProvider && other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerHistoryRef on AutoDisposeFutureProviderRef<List<AuditLog>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _CustomerHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<AuditLog>>
    with CustomerHistoryRef {
  _CustomerHistoryProviderElement(super.provider);

  @override
  String get customerId => (origin as CustomerHistoryProvider).customerId;
}

String _$pipelineAuditHistoryHash() =>
    r'01bd337dbfcb8b2cc2db00e8bf6e361285aa2e0e';

/// Get pipeline audit history by ID.
///
/// Copied from [pipelineAuditHistory].
@ProviderFor(pipelineAuditHistory)
const pipelineAuditHistoryProvider = PipelineAuditHistoryFamily();

/// Get pipeline audit history by ID.
///
/// Copied from [pipelineAuditHistory].
class PipelineAuditHistoryFamily extends Family<AsyncValue<List<AuditLog>>> {
  /// Get pipeline audit history by ID.
  ///
  /// Copied from [pipelineAuditHistory].
  const PipelineAuditHistoryFamily();

  /// Get pipeline audit history by ID.
  ///
  /// Copied from [pipelineAuditHistory].
  PipelineAuditHistoryProvider call(String pipelineId) {
    return PipelineAuditHistoryProvider(pipelineId);
  }

  @override
  PipelineAuditHistoryProvider getProviderOverride(
    covariant PipelineAuditHistoryProvider provider,
  ) {
    return call(provider.pipelineId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pipelineAuditHistoryProvider';
}

/// Get pipeline audit history by ID.
///
/// Copied from [pipelineAuditHistory].
class PipelineAuditHistoryProvider
    extends AutoDisposeFutureProvider<List<AuditLog>> {
  /// Get pipeline audit history by ID.
  ///
  /// Copied from [pipelineAuditHistory].
  PipelineAuditHistoryProvider(String pipelineId)
    : this._internal(
        (ref) =>
            pipelineAuditHistory(ref as PipelineAuditHistoryRef, pipelineId),
        from: pipelineAuditHistoryProvider,
        name: r'pipelineAuditHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pipelineAuditHistoryHash,
        dependencies: PipelineAuditHistoryFamily._dependencies,
        allTransitiveDependencies:
            PipelineAuditHistoryFamily._allTransitiveDependencies,
        pipelineId: pipelineId,
      );

  PipelineAuditHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pipelineId,
  }) : super.internal();

  final String pipelineId;

  @override
  Override overrideWith(
    FutureOr<List<AuditLog>> Function(PipelineAuditHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PipelineAuditHistoryProvider._internal(
        (ref) => create(ref as PipelineAuditHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pipelineId: pipelineId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AuditLog>> createElement() {
    return _PipelineAuditHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PipelineAuditHistoryProvider &&
        other.pipelineId == pipelineId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pipelineId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PipelineAuditHistoryRef on AutoDisposeFutureProviderRef<List<AuditLog>> {
  /// The parameter `pipelineId` of this provider.
  String get pipelineId;
}

class _PipelineAuditHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<AuditLog>>
    with PipelineAuditHistoryRef {
  _PipelineAuditHistoryProviderElement(super.provider);

  @override
  String get pipelineId => (origin as PipelineAuditHistoryProvider).pipelineId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
