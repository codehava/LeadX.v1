// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminUserRemoteDataSourceHash() =>
    r'21e14cf2a6dda6a7476fcce651d205adabde9c8a';

/// Provider for admin user remote data source.
///
/// Copied from [adminUserRemoteDataSource].
@ProviderFor(adminUserRemoteDataSource)
final adminUserRemoteDataSourceProvider =
    AutoDisposeProvider<AdminUserRemoteDataSource>.internal(
      adminUserRemoteDataSource,
      name: r'adminUserRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminUserRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUserRemoteDataSourceRef =
    AutoDisposeProviderRef<AdminUserRemoteDataSource>;
String _$adminUserRepositoryHash() =>
    r'347a033843a33211f757ada36febe89ab0401f99';

/// Provider for admin user repository.
///
/// Copied from [adminUserRepository].
@ProviderFor(adminUserRepository)
final adminUserRepositoryProvider =
    AutoDisposeProvider<AdminUserRepository>.internal(
      adminUserRepository,
      name: r'adminUserRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminUserRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUserRepositoryRef = AutoDisposeProviderRef<AdminUserRepository>;
String _$allUsersHash() => r'e3ce4ae21978390c76aac44faee226c2800eaab9';

/// Provider for all users list.
///
/// Copied from [allUsers].
@ProviderFor(allUsers)
final allUsersProvider = AutoDisposeFutureProvider<List<User>>.internal(
  allUsers,
  name: r'allUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllUsersRef = AutoDisposeFutureProviderRef<List<User>>;
String _$usersByRoleHash() => r'd98724d24edf4a0f086c17d199dade4de47f4e25';

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

/// Provider for users filtered by role.
///
/// Copied from [usersByRole].
@ProviderFor(usersByRole)
const usersByRoleProvider = UsersByRoleFamily();

/// Provider for users filtered by role.
///
/// Copied from [usersByRole].
class UsersByRoleFamily extends Family<AsyncValue<List<User>>> {
  /// Provider for users filtered by role.
  ///
  /// Copied from [usersByRole].
  const UsersByRoleFamily();

  /// Provider for users filtered by role.
  ///
  /// Copied from [usersByRole].
  UsersByRoleProvider call(UserRole role) {
    return UsersByRoleProvider(role);
  }

  @override
  UsersByRoleProvider getProviderOverride(
    covariant UsersByRoleProvider provider,
  ) {
    return call(provider.role);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'usersByRoleProvider';
}

/// Provider for users filtered by role.
///
/// Copied from [usersByRole].
class UsersByRoleProvider extends AutoDisposeFutureProvider<List<User>> {
  /// Provider for users filtered by role.
  ///
  /// Copied from [usersByRole].
  UsersByRoleProvider(UserRole role)
    : this._internal(
        (ref) => usersByRole(ref as UsersByRoleRef, role),
        from: usersByRoleProvider,
        name: r'usersByRoleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$usersByRoleHash,
        dependencies: UsersByRoleFamily._dependencies,
        allTransitiveDependencies: UsersByRoleFamily._allTransitiveDependencies,
        role: role,
      );

  UsersByRoleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
  }) : super.internal();

  final UserRole role;

  @override
  Override overrideWith(
    FutureOr<List<User>> Function(UsersByRoleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsersByRoleProvider._internal(
        (ref) => create(ref as UsersByRoleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<User>> createElement() {
    return _UsersByRoleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersByRoleProvider && other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UsersByRoleRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `role` of this provider.
  UserRole get role;
}

class _UsersByRoleProviderElement
    extends AutoDisposeFutureProviderElement<List<User>>
    with UsersByRoleRef {
  _UsersByRoleProviderElement(super.provider);

  @override
  UserRole get role => (origin as UsersByRoleProvider).role;
}

String _$usersByBranchHash() => r'9a9d623660051a3e1a07f59367b2ec40d5808015';

/// Provider for users filtered by branch.
///
/// Copied from [usersByBranch].
@ProviderFor(usersByBranch)
const usersByBranchProvider = UsersByBranchFamily();

/// Provider for users filtered by branch.
///
/// Copied from [usersByBranch].
class UsersByBranchFamily extends Family<AsyncValue<List<User>>> {
  /// Provider for users filtered by branch.
  ///
  /// Copied from [usersByBranch].
  const UsersByBranchFamily();

  /// Provider for users filtered by branch.
  ///
  /// Copied from [usersByBranch].
  UsersByBranchProvider call(String branchId) {
    return UsersByBranchProvider(branchId);
  }

  @override
  UsersByBranchProvider getProviderOverride(
    covariant UsersByBranchProvider provider,
  ) {
    return call(provider.branchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'usersByBranchProvider';
}

/// Provider for users filtered by branch.
///
/// Copied from [usersByBranch].
class UsersByBranchProvider extends AutoDisposeFutureProvider<List<User>> {
  /// Provider for users filtered by branch.
  ///
  /// Copied from [usersByBranch].
  UsersByBranchProvider(String branchId)
    : this._internal(
        (ref) => usersByBranch(ref as UsersByBranchRef, branchId),
        from: usersByBranchProvider,
        name: r'usersByBranchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$usersByBranchHash,
        dependencies: UsersByBranchFamily._dependencies,
        allTransitiveDependencies:
            UsersByBranchFamily._allTransitiveDependencies,
        branchId: branchId,
      );

  UsersByBranchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.branchId,
  }) : super.internal();

  final String branchId;

  @override
  Override overrideWith(
    FutureOr<List<User>> Function(UsersByBranchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsersByBranchProvider._internal(
        (ref) => create(ref as UsersByBranchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        branchId: branchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<User>> createElement() {
    return _UsersByBranchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsersByBranchProvider && other.branchId == branchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, branchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UsersByBranchRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `branchId` of this provider.
  String get branchId;
}

class _UsersByBranchProviderElement
    extends AutoDisposeFutureProviderElement<List<User>>
    with UsersByBranchRef {
  _UsersByBranchProviderElement(super.provider);

  @override
  String get branchId => (origin as UsersByBranchProvider).branchId;
}

String _$userSubordinatesHash() => r'bb3de511a52b682394924f3d2aa5cb7a61188850';

/// Provider for user's subordinates.
///
/// Copied from [userSubordinates].
@ProviderFor(userSubordinates)
const userSubordinatesProvider = UserSubordinatesFamily();

/// Provider for user's subordinates.
///
/// Copied from [userSubordinates].
class UserSubordinatesFamily extends Family<AsyncValue<List<User>>> {
  /// Provider for user's subordinates.
  ///
  /// Copied from [userSubordinates].
  const UserSubordinatesFamily();

  /// Provider for user's subordinates.
  ///
  /// Copied from [userSubordinates].
  UserSubordinatesProvider call(String userId) {
    return UserSubordinatesProvider(userId);
  }

  @override
  UserSubordinatesProvider getProviderOverride(
    covariant UserSubordinatesProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userSubordinatesProvider';
}

/// Provider for user's subordinates.
///
/// Copied from [userSubordinates].
class UserSubordinatesProvider extends AutoDisposeFutureProvider<List<User>> {
  /// Provider for user's subordinates.
  ///
  /// Copied from [userSubordinates].
  UserSubordinatesProvider(String userId)
    : this._internal(
        (ref) => userSubordinates(ref as UserSubordinatesRef, userId),
        from: userSubordinatesProvider,
        name: r'userSubordinatesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userSubordinatesHash,
        dependencies: UserSubordinatesFamily._dependencies,
        allTransitiveDependencies:
            UserSubordinatesFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserSubordinatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<User>> Function(UserSubordinatesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserSubordinatesProvider._internal(
        (ref) => create(ref as UserSubordinatesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<User>> createElement() {
    return _UserSubordinatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSubordinatesProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserSubordinatesRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserSubordinatesProviderElement
    extends AutoDisposeFutureProviderElement<List<User>>
    with UserSubordinatesRef {
  _UserSubordinatesProviderElement(super.provider);

  @override
  String get userId => (origin as UserSubordinatesProvider).userId;
}

String _$adminUserNotifierHash() => r'bdeaa91ae1aaa90bb6a812b82f92eb9d82555799';

/// State for user management operations.
///
/// Copied from [AdminUserNotifier].
@ProviderFor(AdminUserNotifier)
final adminUserNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AdminUserNotifier, void>.internal(
      AdminUserNotifier.new,
      name: r'adminUserNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminUserNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminUserNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
