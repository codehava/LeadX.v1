# Coding Conventions

**Analysis Date:** 2026-02-13

## Naming Patterns

### Files

**Format:** `snake_case` with underscores

**Examples:**
- Screens: `login_screen.dart`, `customers_tab.dart`, `customer_detail_screen.dart`
- Data sources: `customer_local_data_source.dart`, `customer_remote_data_source.dart`
- Providers: `customer_providers.dart`, `auth_providers.dart`, `sync_providers.dart`
- Repositories: `customer_repository_impl.dart`
- DTOs: `customer_dtos.dart`, `master_data_dtos.dart`
- Database tables: `activities.dart`, `customers.dart`, `users.dart`
- Tables are grouped: `history_log_tables.dart`, `master_data.dart`

### Functions

**Format:** `camelCase`

**Patterns:**
- Private functions prefix with `_`: `_handleLogin()`, `_generateCustomerCode()`, `_mapToCustomer()`
- Getter functions use simple names: `isActive`, `isDeleted`, `isCompleted`
- Setter functions use `set` prefix: `setPosition()`, `setCustomers()`, `addCustomer()`
- Watch/Stream functions use `watch` prefix: `watchAllCustomers()`, `watchCustomerById()`
- Get/Future functions use `get` prefix: `getCustomerById()`, `getCustomerCount()`
- Fetch functions in remote data sources use `fetch` prefix: `fetchCustomers()`
- Create/update/upsert in remote DS: `createCustomer()`, `updateCustomer()`, `upsertData()`
- Event handlers: `_handleLogin()`, `_handleCreate()`, `_handleUpdate()`

**Example from `lib/data/repositories/customer_repository_impl.dart`:**
```dart
@override
Stream<List<domain.Customer>> watchAllCustomers() =>
    _localDataSource.watchAllCustomers().map(
          (customers) => customers.map(_mapToCustomer).toList(),
        );

@override
Future<domain.Customer?> getCustomerById(String id) async {
  final data = await _localDataSource.getCustomerById(id);
  return data != null ? _mapToCustomer(data) : null;
}
```

### Variables

**Format:** `camelCase`

**Patterns:**
- Private fields/variables prefix with `_`: `_emailController`, `_currentUserId`, `_localDataSource`
- Boolean variables use `is` or `should` prefix: `isActive`, `isPendingSync`, `shouldCreateSucceed`
- Controllers for text/form fields: `_emailController`, `_passwordController`
- Stream controllers: `_customersController`
- Late-initialized variables: `late CustomerRepository repository`
- Constants use `const`: `const _uuid = Uuid()`, `const testUserId = 'test-user-id'`

**Example from `lib/presentation/screens/auth/login_screen.dart`:**
```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
}
```

### Types

**Format:** `PascalCase` for classes and types

**Patterns:**
- Classes: `Customer`, `Activity`, `Pipeline`, `CustomerRepository`
- Enums: `ActivityStatus`, `ActivityObjectType`, `KeyPersonOwnerType`
- Domain entities use simple names: `Customer`, `Activity`, `Pipeline`
- DTOs use suffix pattern: `CustomerCreateDto`, `CustomerUpdateDto`, `CustomerSyncDto`
- Local database models prefix with `db`: `db.Customer`, `db.Activity` (imported as alias)
- Remote data sources: `CustomerRemoteDataSource`, `ActivityRemoteDataSource`
- Local data sources: `CustomerLocalDataSource`, `ActivityLocalDataSource`

**Example from `lib/data/dtos/customer_dtos.dart`:**
```dart
@freezed
class CustomerCreateDto with _$CustomerCreateDto {
  const factory CustomerCreateDto({
    required String name,
    String? address,
    // ...
  }) = _CustomerCreateDto;
}

@freezed
class CustomerUpdateDto with _$CustomerUpdateDto {
  const factory CustomerUpdateDto({
    String? name,
    String? address,
    // ...
  }) = _CustomerUpdateDto;
}

@freezed
class CustomerSyncDto with _$CustomerSyncDto {
  const factory CustomerSyncDto({
    required String id,
    @JsonKey(name: 'province_id') required String provinceId,
    // ...
  }) = _CustomerSyncDto;
}
```

## Code Style

### Formatting

**Tool:** Flutter's built-in formatter (no explicit Prettier)

**Key Settings from `analysis_options.yaml`:**
- Strict type checks enabled: `strict-casts: true`, `strict-raw-types: true`
- Prefer single quotes: `prefer_single_quotes: true`
- Prefer final fields: `prefer_final_fields: true`
- Prefer final locals: `prefer_final_locals: true`
- Prefer const constructors: `prefer_const_constructors: false` (disabled for flexibility)
- Prefer const in immutables: `prefer_const_constructors_in_immutables: true`

**Line length:** Standard (no explicit limit specified, but keep reasonable ~100-120 chars)

**Example formatting from `lib/core/theme/app_colors.dart`:**
```dart
abstract class AppColors {
  // ============================================
  // PRIMARY COLORS
  // ============================================

  /// Primary brand color - Blue
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
}
```

### Linting

**Tool:** Flutter Lints (package `flutter_lints`)

**Configuration:** `analysis_options.yaml`

**Key Rules Enforced:**
- `missing_required_param: error` - All required params must be specified
- `missing_return: error` - Functions must return promised types
- `must_be_immutable: error` - Classes with @immutable must not have mutable fields
- `avoid_print: true` - Use debugPrint instead
- `avoid_catching_errors: true` - Don't catch Error objects
- `only_throw_errors: true` - Only throw Error and Exception subclasses
- `avoid_returning_null_for_future: true` - Futures should not return null
- `unawaited_futures: true` - Flag futures not awaited
- `cancel_subscriptions: true` - Subscriptions must be cancelled
- `close_sinks: true` - Sinks must be closed

**Disabled Rules (Stylistic only):**
- `always_put_required_named_parameters_first: false`
- `directives_ordering: false`
- `sort_constructors_first: false`

**Important:** Generated files excluded from analysis:
```yaml
exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
```

## Import Organization

### Order

**Standard Flutter/Dart convention:**

1. **Dart imports** - `dart:` libraries first
2. **Flutter imports** - `package:flutter/` next
3. **Package imports** - External packages (alphabetical)
4. **Relative imports** - Local project imports

**Example from `lib/presentation/screens/auth/login_screen.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/sync/sync_progress_sheet.dart';
```

**Example from `lib/data/repositories/customer_repository_impl.dart`:**
```dart
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/customer_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/customer_local_data_source.dart';
```

### Path Aliases

**Not used explicitly** - Project uses relative paths with `../`

**Pattern:** Relative paths match the directory structure for clarity

## Error Handling

### Pattern: Either Type with dartz

**Framework:** `dartz` package for `Either<Failure, T>`

**Usage:** All operations that can fail return `Either<Failure, T>`

**Structure:**
```dart
// From lib/core/errors/failures.dart
abstract class Failure extends Equatable {
  final String message;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, originalError];
}
```

**Specific Failures (Sealed-like hierarchy):**
- `AuthFailure` - Authentication errors
  - `TokenExpiredFailure` - Session expired
  - `InvalidCredentialsFailure` - Bad login
- `NetworkFailure` - Network issues
  - `OfflineFailure` - No internet
- `ServerFailure` - HTTP errors with statusCode
  - `NotFoundFailure` - 404
  - `ForbiddenFailure` - 403
- `DatabaseFailure` - Local/Drift errors
- `SyncFailure` - Sync operation errors
  - `SyncConflictFailure` - Conflict during sync
- `LocationFailure` - GPS/location errors
  - `LocationPermissionDeniedFailure` - Permission denied
  - `LocationUnavailableFailure` - GPS not available
- `ValidationFailure` - Field validation errors with fieldErrors map
- `FileFailure` - File operation errors
- `UnexpectedFailure` - Catch-all for unexpected errors

**Example from `lib/data/repositories/customer_repository_impl.dart` (lines 82-84):**
```dart
@override
Future<Either<Failure, domain.Customer>> createCustomer(
  CustomerCreateDto dto,
) async {
  try {
    // ... implementation
    return Right(customer);
  } catch (e) {
    return Left(DatabaseFailure(message: 'Failed to create customer'));
  }
}
```

**Usage in tests from `test/helpers/customer_test_helpers.dart`:**
```dart
@override
Future<Either<Failure, Customer>> createCustomer(CustomerCreateDto dto) async {
  if (!shouldCreateSucceed) {
    return Left(DatabaseFailure(message: errorMessage ?? 'Failed to create customer'));
  }
  final customer = createTestCustomer(...);
  return Right(customer);
}
```

### Exceptions vs Failures

**Exceptions** (in `lib/core/errors/exceptions.dart`):
- Used internally for throwing
- Similar hierarchy to Failures
- Contain `originalError`, `stackTrace`

**Failures** (in `lib/core/errors/failures.dart`):
- Used as return types in Either pattern
- User-facing error messages
- No stack trace (cleaner for UI)

**Conversion happens in repositories:** Catch exceptions, return failures in Either

## Logging

**Framework:** `logger` package (v2.5.0)

**Usage:** `debugPrint()` for console logging (preferred over print)

**Pattern from `lib/presentation/screens/auth/login_screen.dart`:**
```dart
debugPrint('[LoginScreen] Login success, hasInitialSynced=$hasInitialSynced');
debugPrint('[LoginScreen] Starting initial sync...');
debugPrint('[LoginScreen] Initial sync completed');
```

**Convention:**
- Prefix log messages with class name in brackets: `[ClassName]`
- Log state changes and async completion
- Do NOT log sensitive data (passwords, tokens)
- Use for debugging - logs are stripped in release builds

## Comments

### When to Comment

**Write comments for:**
- Complex business logic or algorithms
- Non-obvious decisions (especially offline-first patterns)
- Workarounds for bugs or platform limitations
- Public API documentation

**Example from `lib/core/theme/app_colors.dart`:**
```dart
/// App color palette for LeadX CRM.
///
/// Colors are organized by semantic meaning to ensure
/// consistent usage throughout the app.
abstract class AppColors {
```

### JSDoc/TSDoc (DartDoc)

**Pattern:** Triple-slash `///` comments above public members

**Required for:**
- Public classes
- Public methods
- Public fields
- Constants used externally

**Example from `lib/presentation/providers/customer_providers.dart`:**
```dart
/// Provider for the customer local data source.
final customerLocalDataSourceProvider =
    Provider<CustomerLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerLocalDataSource(db);
});

/// Default page size for customer pagination.
const customerPageSize = 25;

/// Provider for watching all customers as a stream.
/// @deprecated Use [paginatedCustomersProvider] for lazy loading.
final customerListStreamProvider =
    StreamProvider<List<domain.Customer>>((ref) {
```

**Inline Comments:** Avoid - use clear naming instead

## Function Design

### Size Guidelines

**Aim for:** 10-30 lines per function (max 50 lines)

**Rationale:** Easier to understand, test, and reuse

**Example from `lib/presentation/screens/auth/login_screen.dart`:**
```dart
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final success = await ref.read(loginNotifierProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

  if (success && mounted) {
    // Check if initial sync is needed
    final appSettings = ref.read(appSettingsServiceProvider);
    final hasInitialSynced = await appSettings.hasInitialSyncCompleted();

    debugPrint('[LoginScreen] Login success, hasInitialSynced=$hasInitialSynced');

    if (!hasInitialSynced) {
      debugPrint('[LoginScreen] Starting initial sync...');
      if (mounted) {
        await SyncProgressSheet.show(context);
        await appSettings.markInitialSyncCompleted();
        debugPrint('[LoginScreen] Initial sync completed');
      }
    }

    if (mounted) {
      context.go(RoutePaths.home);
    }
  }
}
```

### Parameters

**Guidelines:**
- Max 5 positional parameters (use named parameters otherwise)
- Required parameters come first
- Optional parameters come last
- Use `required` keyword for clarity

**Example from `test/helpers/customer_test_helpers.dart`:**
```dart
Customer createTestCustomer({
  String? id,
  String? code,
  String name = 'Test Customer',
  String address = 'Test Address',
  String provinceId = 'province-1',
  String cityId = 'city-1',
  String companyTypeId = 'company-type-1',
  String ownershipTypeId = 'ownership-type-1',
  String industryId = 'industry-1',
  // ... more optional params
})
```

### Return Values

**Pattern:** Explicit types always

**Examples:**
- `Future<T>` for async operations
- `Stream<T>` for reactive streams
- `Either<Failure, T>` for fallible operations
- `T?` for nullable returns
- Avoid implicit `dynamic`

**Example from `lib/domain/entities/activity.dart`:**
```dart
/// Check if activity needs to be synced.
bool get needsSync => isPendingSync;

/// Check if activity is soft deleted.
bool get isDeleted => deletedAt != null;

/// Check if activity can be executed.
bool get canExecute => status == ActivityStatus.planned;
```

## Module Design

### Exports and Barrel Files

**Not used explicitly** - Each file imports what it needs directly

**Pattern:** Import specific files, not barrels

**Example from `lib/presentation/screens/auth/login_screen.dart`:**
```dart
import '../../../config/routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/sync/sync_progress_sheet.dart';
```

### Provider Pattern

**Riverpod with code generation**

**File location:** `lib/presentation/providers/`

**Naming convention:** `*_providers.dart` or `*_provider.dart`

**Provider types used:**
- `Provider<T>` - Synchronous, computed values
- `StreamProvider<T>` - Streams (used for Drift watch streams)
- `StreamProvider.family<T, Arg>` - Parameterized streams
- `FutureProvider<T>` - One-time async operations
- `FutureProvider.family<T, Arg>` - Parameterized futures
- `StateProvider<T>` - Mutable state
- `StateNotifierProvider<Notifier, State>` - Complex state management

**Example from `lib/presentation/providers/customer_providers.dart`:**
```dart
// Data Source Providers
final customerLocalDataSourceProvider =
    Provider<CustomerLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerLocalDataSource(db);
});

// Repository Providers
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final localDataSource = ref.watch(customerLocalDataSourceProvider);
  final remoteDataSource = ref.watch(customerRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).value;

  return CustomerRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
  );
});

// List Providers (using StreamProvider for Drift streams)
final customerListStreamProvider =
    StreamProvider<List<domain.Customer>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchAllCustomers();
});
```

### Entity Display Helpers

**Pattern:** Computed properties on Freezed entities for UI display

**Example from `lib/domain/entities/activity.dart`:**
```dart
@freezed
class Activity with _$Activity {
  const factory Activity({
    required String id,
    // ... fields ...
  }) = _Activity;

  const Activity._();

  // Computed properties for UI
  bool get needsSync => isPendingSync;
  bool get isDeleted => deletedAt != null;
  bool get isCompleted => status == ActivityStatus.completed;
  bool get canExecute => status == ActivityStatus.planned;
}
```

---

*Convention analysis: 2026-02-13*
