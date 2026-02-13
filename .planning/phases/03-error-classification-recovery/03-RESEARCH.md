# Phase 3: Error Classification & Recovery - Research

**Researched:** 2026-02-14
**Domain:** Dart sealed Result type, exception-to-failure mapping, offline-first error UI, dartz Either migration
**Confidence:** HIGH

## Summary

Phase 3 replaces the project's dependency on `dartz` `Either<Failure, T>` with a Dart-native sealed `Result<T>` type, maps raw Supabase/network exceptions to typed `Failure` subclasses at the repository boundary, and upgrades screens to show cached data with staleness warnings instead of raw error strings when offline.

The codebase already has solid foundations from Phases 1-2: a sealed `SyncError` hierarchy with retryable/permanent classification, a comprehensive `Failure` class hierarchy (13 concrete subtypes), and `AppErrorState` widget. However, repository catch blocks are generic -- every repository method catches `(e)` and wraps in `DatabaseFailure(message: 'Failed to X: $e')` regardless of whether the actual error was a network timeout, auth failure, or database issue. Remote data sources propagate raw `PostgrestException`, `SocketException`, and `TimeoutException` without mapping. Screens display `Text('Error: $error')` with `.toString()` output rather than user-friendly messages.

The migration from `dartz Either` to sealed `Result` is mechanical but wide: 85+ `Either<Failure, T>` return sites across 13 repositories, 60+ `.fold()` call sites in presentation layer. The approach must be incremental (repository-by-repository) to avoid a single massive breaking change. The requirement specifies at least CustomerRepository, PipelineRepository, and ActivityRepository must be migrated.

**Primary recommendation:** Create a minimal sealed `Result<T>` type in `core/errors/result.dart` (not a third-party package), migrate the three core repositories + their presentation consumers, add an exception mapping utility that converts Supabase/Dart exceptions to typed Failures at the repository boundary, and create an offline-aware error widget that shows cached data with staleness banners.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| dart:core sealed classes | Dart 3.10+ | Result<T> sealed type with exhaustive matching | Native language feature; no package needed |
| Existing Failure hierarchy | N/A | Error classification (13 subtypes) | Already comprehensive; needs no new types |
| Existing SyncError hierarchy | N/A | Sync-specific retryable/permanent errors | Created in Phase 1; feeds error mapping |
| Existing AppErrorState widget | N/A | Error display with retry button | Foundation for enhanced offline-aware variant |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| equatable | ^2.0.7 (existing) | Value equality for Failure classes | Already used by all Failure subclasses |
| connectivity_plus | ^6.1.1 (existing) | Offline detection for staleness warnings | Already used by ConnectivityService |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Custom sealed Result | `result_dart` ^2.1.1 (pub.dev) | Adds operators like `map`, `flatMap` for free, but adds a dependency for something achievable in ~40 lines of Dart; project requirement (ERR-02) specifically says "Dart-native sealed Result<T> type" |
| Custom sealed Result | `fpdart` ^1.1.0 | Full FP library with TaskEither, Option, etc. -- overkill for what this project needs |
| Custom sealed Result | Keep `dartz` Either | Works but is unmaintained (last release 2022), pattern matching is worse than sealed classes, `.fold()` is less readable than `switch` |

### Remove (Eventually)
| Library | Reason |
|---------|--------|
| `dartz: ^0.10.1` | Replaced incrementally by sealed Result; remove from pubspec once all repositories migrated (likely Phase 3+ completion) |

**Installation:** No new packages needed. This phase uses only native Dart features.

## Architecture Patterns

### Recommended File Structure
```
lib/core/errors/
├── exceptions.dart          # Existing: AppException hierarchy (thrown by data sources)
├── failures.dart            # Existing: Failure hierarchy (returned to presentation)
├── sync_errors.dart         # Existing: SyncError sealed hierarchy (sync-specific)
├── result.dart              # NEW: sealed Result<T> type
└── exception_mapper.dart    # NEW: maps raw exceptions to typed Failures
```

### Pattern 1: Sealed Result<T> Type
**What:** A minimal sealed class replacing dartz Either<Failure, T>
**When to use:** All repository return types that can succeed or fail
**Example:**
```dart
// lib/core/errors/result.dart
sealed class Result<T> {
  const Result();

  /// Create a success result.
  const factory Result.success(T value) = Success<T>;

  /// Create a failure result.
  const factory Result.failure(Failure failure) = Failure_<T>;

  /// Pattern match on success/failure.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  });

  /// Get value or null.
  T? get valueOrNull;

  /// Get failure or null.
  Failure? get failureOrNull;

  /// Whether this is a success.
  bool get isSuccess;

  /// Whether this is a failure.
  bool get isFailure;
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) => success(value);

  @override
  T? get valueOrNull => value;

  @override
  Failure? get failureOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;
}

final class Failure_<T> extends Result<T> {
  final Failure failure;
  const Failure_(this.failure);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) => failure(this.failure);

  @override
  T? get valueOrNull => null;

  @override
  Failure? get failureOrNull => failure;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;
}
```

**Consumer usage (replaces `.fold()`):**
```dart
// Old (dartz):
result.fold(
  (failure) => state = state.copyWith(errorMessage: failure.message),
  (customer) => state = state.copyWith(savedCustomer: customer),
);

// New (sealed Result, switch expression):
switch (result) {
  case Success(:final value):
    state = state.copyWith(savedCustomer: value);
  case Failure_(:final failure):
    state = state.copyWith(errorMessage: failure.message);
}

// New (sealed Result, .when() method - closer to dartz .fold()):
result.when(
  success: (customer) => state = state.copyWith(savedCustomer: customer),
  failure: (failure) => state = state.copyWith(errorMessage: failure.message),
);
```

### Pattern 2: Exception-to-Failure Mapping at Repository Boundary
**What:** A utility that converts raw exceptions (PostgrestException, SocketException, TimeoutException, AuthException) to typed Failure subclasses
**When to use:** Every repository catch block instead of generic `DatabaseFailure(message: 'Failed to X: $e')`
**Example:**
```dart
// lib/core/errors/exception_mapper.dart
import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'failures.dart';
import 'result.dart';

/// Maps raw exceptions to typed Failure instances.
///
/// Used at repository boundary to convert data layer exceptions
/// into domain failures with user-friendly messages.
Failure mapException(Object error, {String? context}) {
  return switch (error) {
    SocketException() => const NetworkFailure(
        message: 'Check your connection and try again.',
      ),
    TimeoutException() => const NetworkFailure(
        message: 'Check your connection and try again.',
      ),
    PostgrestException(code: final code, message: final msg) => _mapPostgrestException(
        code: code,
        message: msg,
        originalError: error,
      ),
    AuthException() => AuthFailure(
        message: 'Session expired. Please login again.',
        originalError: error,
      ),
    FormatException() => DatabaseFailure(
        message: context ?? 'Invalid data format.',
        originalError: error,
      ),
    _ => UnexpectedFailure(
        message: context ?? 'An unexpected error occurred.',
        originalError: error,
      ),
  };
}

Failure _mapPostgrestException({
  String? code,
  required String message,
  required Object originalError,
}) {
  final statusCode = int.tryParse(code ?? '') ?? 0;
  if (statusCode == 401 || code == 'PGRST301') {
    return AuthFailure(
      message: 'Session expired. Please login again.',
      originalError: originalError,
    );
  } else if (statusCode == 403) {
    return const ForbiddenFailure();
  } else if (statusCode == 404) {
    return const NotFoundFailure();
  } else if (statusCode == 409) {
    return SyncConflictFailure(
      entityId: null,
      entityType: null,
    );
  } else if (statusCode >= 400 && statusCode < 500) {
    return ValidationFailure(message: message);
  } else {
    return ServerFailure(
      statusCode: statusCode,
      message: message,
      originalError: originalError,
    );
  }
}

/// Convenience: run async work and map any exception to Result<T>.
Future<Result<T>> runCatching<T>(
  Future<T> Function() action, {
  String? context,
}) async {
  try {
    return Result.success(await action());
  } catch (e) {
    return Result.failure(mapException(e, context: context));
  }
}
```

### Pattern 3: Offline-Aware Error Display
**What:** Screens show cached data with a staleness banner when offline, instead of showing error state
**When to use:** All list/detail screens that use Drift-backed StreamProviders
**Key insight:** Since all list/detail data comes from Drift streams (local database), they will ALWAYS have data even when offline. The "offline" case only affects write operations and sync operations. The `AsyncValue.error` from a StreamProvider backed by Drift would only fire on a database error, not a network error.

**Implication for this project:** The customer list screen already reads from Drift via `paginatedCustomersProvider` (a StreamProvider). When the device is offline, the Drift stream still works perfectly -- it just shows whatever is in the local database. The "offline" state should be displayed as a BANNER on top of the existing data, NOT as an error replacement.

**Example:**
```dart
// Offline-aware wrapper widget
class OfflineAwarePage extends ConsumerWidget {
  final Widget child;
  const OfflineAwarePage({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityStreamProvider).valueOrNull ?? true;
    return Column(
      children: [
        if (!isConnected)
          MaterialBanner(
            content: const Text('Offline - data may be stale'),
            leading: const Icon(Icons.wifi_off),
            actions: [Container()], // required but empty
          ),
        Expanded(child: child),
      ],
    );
  }
}
```

### Pattern 4: Incremental Migration Strategy
**What:** Migrate one repository at a time: interface -> implementation -> providers -> screens
**When to use:** ERR-02 specifies "incremental migration, repository-by-repository"
**Migration order per repository:**
1. Add `import 'result.dart'` to repository interface
2. Change return types from `Either<Failure, T>` to `Result<T>`
3. Update implementation: replace `Left(failure)` with `Result.failure(failure)`, `Right(value)` with `Result.success(value)`
4. Replace generic catch blocks with `mapException()` calls
5. Update provider notifiers: replace `.fold()` with `.when()` or `switch`
6. Update screen code if it directly uses `.fold()`
7. Run tests, fix any type errors
8. Remove `dartz` import from migrated files

### Anti-Patterns to Avoid
- **Catching all exceptions as DatabaseFailure:** This is the current pattern. A `TimeoutException` from Supabase is NOT a database failure -- it's a `NetworkFailure`. Use `mapException()` to classify correctly.
- **Mixing dartz Either and sealed Result in same repository:** Each repository should be fully one or the other. Don't return `Result` from some methods and `Either` from others in the same interface.
- **Showing error state for offline reads:** Drift-backed streams work offline. Only write/sync operations can have network errors. Never replace cached list data with an error screen due to offline state.
- **Removing dartz before all repositories are migrated:** The `dartz` import remains in pubspec until every repository is migrated. This phase migrates 3 core repos; others can be migrated later.
- **Adding network checks to repository read methods:** Read methods hit local Drift database only. They should never check connectivity or return NetworkFailure. Only methods that touch remote data sources can have network failures.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Result type operators (map, flatMap) | Full FP Result with 15+ operators | Minimal sealed Result with `when()` + `switch` | Project uses Result only at repository boundary; consumers immediately unwrap. Complex operators unused. |
| Exception classification | Per-repository if/else chains | Shared `mapException()` utility | Same exception types appear across all 13 repositories; centralize mapping logic |
| Offline detection | Custom connectivity checks per screen | Existing `ConnectivityService` + `connectivityStreamProvider` | Already built, tested, and handles web/mobile differences |

**Key insight:** The project does NOT need a full functional programming Result type with monadic operators. Every call site immediately unwraps the Result via `.fold()` / `.when()` / `switch`. A minimal sealed class with 2 subtypes is sufficient.

## Common Pitfalls

### Pitfall 1: Breaking Existing Tests During Migration
**What goes wrong:** Changing `Either<Failure, T>` to `Result<T>` in repository interfaces breaks all test assertions that use `isA<Right<Failure, Customer>>()` or `result.getOrElse(() => ...)`.
**Why it happens:** Tests import dartz matchers and constructors directly.
**How to avoid:** Migrate tests at the same time as each repository. Update assertions to use `isA<Success<Customer>>()` and `result.valueOrNull`. Run tests after each repository migration.
**Warning signs:** Test files importing both `dartz` and `result.dart`.

### Pitfall 2: Naming Collision with Failure Class
**What goes wrong:** The sealed Result type needs a `Failure` variant, but `Failure` is already a class name in `failures.dart`.
**Why it happens:** Dart doesn't allow two classes with the same name in the same library scope.
**How to avoid:** Name the Result failure variant `Failure_<T>` (with underscore suffix) or use a different pattern like `ResultFailure<T>`. The `Failure` import from `failures.dart` is the domain concept; the Result variant is the wrapper. Alternatively, use `Result.failure()` constructor name only, with the concrete class being `_FailureResult` or similar.
**Warning signs:** Import conflicts, "ambiguous name" compiler errors.

### Pitfall 3: Auth Error Retry Loop
**What goes wrong:** Supabase returns 401 for expired JWT tokens during sync. Without proper mapping, these get classified as generic errors and retried 5 times (current `maxRetries = 5`), wasting time and bandwidth.
**Why it happens:** The sync service already handles this via `AuthSyncError` in `_processItem()`, but repository-level sync methods (`syncFromRemote`) catch all exceptions and return `SyncFailure` without preserving the auth classification.
**How to avoid:** The `mapException()` utility correctly maps `PostgrestException` with code 401/PGRST301 to `AuthFailure`. Sync methods should propagate this classification. The sync service's `_processItem()` already does this correctly via `SyncError` hierarchy -- ensure repository sync methods don't swallow the typed error.
**Warning signs:** Repeated 401 errors in Talker logs for the same sync queue item.

### Pitfall 4: Overly Aggressive Offline Error Replacement
**What goes wrong:** Developers add `if (isOffline) return Result.failure(OfflineFailure())` to repository methods that only read from local database, breaking the offline-first contract.
**Why it happens:** Confusion between "reading cached data" (always works) and "writing to remote" (requires connectivity).
**How to avoid:** Read methods (`watch*`, `get*`, `search*`) NEVER check connectivity or return failures. Only methods that interact with remote data sources or sync can produce NetworkFailure/OfflineFailure. The offline staleness banner is a UI concern, not a repository concern.
**Warning signs:** OfflineFailure appearing from `getCustomerById()` or `watchAllCustomers()`.

### Pitfall 5: Forgetting to Handle `Failure_` Variant in Provider Notifiers
**What goes wrong:** Pattern matching on Result is exhaustive, but developers might use `if (result.isSuccess)` without handling the failure case, leading to silent error swallowing.
**Why it happens:** Unlike dartz `.fold()` which forces both paths, `if/else` on Result booleans doesn't.
**How to avoid:** Always use `switch` or `.when()` which require both branches. The Dart analyzer will warn about non-exhaustive switches on sealed types. Lint rules enforce this.
**Warning signs:** `result.isSuccess` checks without corresponding `else` branch.

## Code Examples

### Example 1: Migrated CustomerRepository Interface
```dart
// lib/domain/repositories/customer_repository.dart
import '../errors/result.dart';  // NEW
import '../errors/failures.dart'; // Still needed for Failure type
// Remove: import 'package:dartz/dartz.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchAllCustomers();
  Stream<Customer?> watchCustomerById(String id);
  Future<Customer?> getCustomerById(String id);

  // Changed: Either<Failure, Customer> -> Result<Customer>
  Future<Result<Customer>> createCustomer(CustomerCreateDto dto);
  Future<Result<Customer>> updateCustomer(String id, CustomerUpdateDto dto);
  Future<Result<void>> deleteCustomer(String id);

  // ... etc
}
```

### Example 2: Migrated Repository Implementation with mapException
```dart
// In CustomerRepositoryImpl
@override
Future<Result<Customer>> createCustomer(CustomerCreateDto dto) async {
  return runCatching(() async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final code = _generateCustomerCode();
    // ... same business logic ...
    await _database.transaction(() async {
      await _localDataSource.insertCustomer(companion);
      await _syncService.queueOperation(/* ... */);
    });
    unawaited(_syncService.triggerSync());
    final customer = await getCustomerById(id);
    return customer!;
  }, context: 'Failed to create customer');
}
```

### Example 3: Provider Notifier with Pattern Matching
```dart
// In CustomerFormNotifier
Future<void> createCustomer(CustomerCreateDto dto) async {
  state = CustomerFormState(isLoading: true);
  final result = await _repository.createCustomer(dto);
  switch (result) {
    case Success(:final value):
      state = state.copyWith(isLoading: false, savedCustomer: value);
    case Failure_(:final failure):
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
  }
}
```

### Example 4: Customer List Screen with Offline Banner
```dart
// In CustomersTab._buildCustomerList()
Widget _buildCustomerList() {
  final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
  final customersAsync = ref.watch(paginatedCustomersProvider(searchKey));
  final isConnected = ref.watch(connectivityStreamProvider).valueOrNull ?? true;

  return Column(
    children: [
      if (!isConnected)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.shade100,
          child: Row(
            children: [
              Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(
                'Offline - data may be stale',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
              ),
            ],
          ),
        ),
      Expanded(
        child: customersAsync.when(
          data: (customers) => /* existing list builder */,
          loading: () => /* existing loading */,
          error: (error, _) => AppErrorState.general(
            message: error is Failure ? error.message : 'Unexpected error',
            onRetry: _handleRefresh,
          ),
        ),
      ),
    ],
  );
}
```

### Example 5: Error-Aware AsyncValue.when with Fallback
```dart
// For screens where error should show last known data instead of error widget
extension AsyncValueX<T> on AsyncValue<T> {
  Widget whenWithCachedFallback({
    required Widget Function(T data) data,
    required Widget Function() loading,
    required Widget Function(Object error) error,
    T? lastKnownData,
  }) {
    return when(
      data: data,
      loading: loading,
      error: (err, _) {
        if (lastKnownData != null) {
          return data(lastKnownData);
        }
        return error(err);
      },
    );
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| dartz Either<L, R> | Dart sealed classes + exhaustive switch | Dart 3.0 (May 2023) | Eliminates dependency, better IDE support, exhaustive checking |
| `.fold(onLeft, onRight)` | `switch (result) { case Success: ... case Failure_: ... }` | Dart 3.0 patterns | More readable, enforced exhaustiveness, better type narrowing |
| Abstract class + subclasses | `sealed class` | Dart 3.0 | Compiler-enforced exhaustive matching |
| `debugPrint` for error logging | `AppLogger` (Talker) with module prefixes | Phase 1 | Structured error reporting with severity levels |
| Generic catch-all `DatabaseFailure` | `mapException()` typed mapping | Phase 3 (this phase) | Enables intelligent retry, user-friendly messages |

**Deprecated/outdated:**
- `dartz` package: Last published 2022-07-29 (v0.10.1). Functional but unmaintained. Dart 3 sealed classes supersede its Either type.
- `result.fold()` from dartz: Pattern matching via `switch` is more idiomatic Dart 3+ and provides exhaustive checking at compile time.

## Scope Analysis

### What Must Be Migrated (ERR-02 Minimum: 3 Repositories)

| Repository | Interface Methods with Either | Impl Catch Blocks | Provider .fold() Sites | Test Files |
|------------|-------------------------------|-------------------|------------------------|------------|
| CustomerRepository | 9 | 9 | 6 | customer_repository_impl_test.dart |
| PipelineRepository | 5 | 6 | 5 | pipeline_repository_impl_test.dart |
| ActivityRepository | 8 | 8 | 6 | (no dedicated test file) |
| **Total (3 repos)** | **22** | **23** | **17** | **2 test files** |

### What Stays on dartz (Migrated Later)
| Repository | Either Methods | Notes |
|------------|---------------|-------|
| AuthRepository | 7 | Auth has special error handling patterns |
| BrokerRepository | 4 | Lower priority |
| HvcRepository | 5 | Lower priority |
| CadenceRepository | 16 | Largest repo, most complex |
| PipelineReferralRepository | 6 | Lower priority |
| AdminUserRepository | 5 | Admin-only |
| AdminMasterDataRepository | 12 | Admin-only |
| **Total (remaining)** | **55** | Migrate in future phases |

### Screen Changes Needed (ERR-03)

| Screen | Current Error Handling | Target |
|--------|----------------------|--------|
| customers_tab.dart | `Text('Error: $error')` | Offline banner + cached data |
| customer_detail_screen.dart | `Text('Error: $error')` (3 places) | Offline banner + cached data |
| Pipeline list/detail | Same pattern | Same treatment |
| Activity list/detail | Same pattern | Same treatment |

### Exception Mapping (ERR-04)

All remote data sources (`CustomerRemoteDataSource`, `PipelineRemoteDataSource`, `ActivityRemoteDataSource`) currently throw raw `PostgrestException`. These exceptions propagate up through repository sync methods and are caught with generic `catch (e)` blocks. The `mapException()` utility will centralize classification.

## Open Questions

1. **Result type naming for Failure variant**
   - What we know: `Failure` name is taken by `failures.dart`. Need a different name for the Result wrapper.
   - What's unclear: Best naming convention (`Failure_`, `ResultFailure`, `Err`)
   - Recommendation: Use `Failure_<T>` (trailing underscore) for the private variant class, but expose only through `Result.failure()` constructor so call sites never reference `Failure_` directly. Consumer code uses `case Failure_(:final failure)` in switch patterns, which reads naturally as "failure case, destructure the failure."

2. **Whether to add `dartz` Either -> Result adapter during migration**
   - What we know: During incremental migration, some repositories return Result while others return Either. The sync notifier calls both types.
   - What's unclear: Whether an adapter extension like `Either.toResult()` would help transition code that consumes mixed repositories.
   - Recommendation: Yes, add a small extension `on Either<Failure, T> { Result<T> toResult() }` in result.dart to ease migration. Remove it once all repos are migrated.

3. **Whether `runCatching` should be the standard or explicit try/catch**
   - What we know: Both patterns work. `runCatching` is more concise. Explicit try/catch gives more control.
   - What's unclear: Whether all repository methods benefit from `runCatching` or if some need granular exception handling.
   - Recommendation: Use `runCatching` as the default for simple CRUD methods. Use explicit try/catch + `mapException()` for complex methods that need to handle specific exceptions differently (e.g., sync methods that need to log before returning).

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `lib/core/errors/failures.dart` - 13 concrete Failure subclasses, Equatable-based
- Codebase analysis: `lib/core/errors/sync_errors.dart` - Sealed SyncError with 6 final subtypes
- Codebase analysis: `lib/core/errors/exceptions.dart` - AppException hierarchy (13 concrete types)
- Codebase analysis: `lib/data/repositories/customer_repository_impl.dart` - Current error handling pattern (generic catch -> DatabaseFailure)
- Codebase analysis: `lib/data/services/sync_service.dart` - PostgrestException -> SyncError mapping (lines 270-326)
- Codebase analysis: `lib/presentation/screens/home/tabs/customers_tab.dart` - Current `Text('Error: $error')` pattern
- Codebase analysis: `lib/presentation/widgets/common/error_state.dart` - Existing AppErrorState widget
- Dart language specification: Sealed classes stable since Dart 3.0, exhaustive switching enforced

### Secondary (MEDIUM confidence)
- [pub.dev result_dart](https://pub.dev/packages/result_dart) - Alternative Result package (v2.1.1), confirmed API surface but decided against adding dependency per ERR-02 requirement
- [Dart sealed types specification](https://github.com/dart-lang/language/blob/main/accepted/future-releases/sealed-types/feature-specification.md) - Language-level sealed class behavior

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - No new dependencies needed; all based on existing Dart features and project code
- Architecture: HIGH - Patterns verified against actual codebase; migration path is mechanical
- Pitfalls: HIGH - Based on direct analysis of current error handling gaps in 13 repositories
- Scope: HIGH - Exact method counts verified via grep across all repository files

**Research date:** 2026-02-14
**Valid until:** 2026-03-14 (stable domain; Dart sealed classes are a settled feature)
