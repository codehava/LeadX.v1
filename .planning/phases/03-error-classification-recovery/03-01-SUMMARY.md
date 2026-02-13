---
phase: 03-error-classification-recovery
plan: 01
subsystem: errors
tags: [sealed-class, result-type, pattern-matching, error-handling, dart3]

# Dependency graph
requires:
  - phase: 01-foundation-observability
    provides: AppLogger for structured logging in repository methods
provides:
  - "Sealed Result<T> type with Success/ResultFailure variants for exhaustive pattern matching"
  - "mapException() utility mapping SocketException, TimeoutException, PostgrestException, AuthException, FormatException to typed Failures"
  - "runCatching() convenience wrapper for async Result<T> operations"
  - "Either<Failure,T>.toResult() migration adapter for incremental dartz removal"
  - "CustomerRepository fully migrated from dartz Either to sealed Result (interface, impl, providers, tests)"
affects: [03-02 pipeline+activity migration, 03-03 screen error display updates, all future repository implementations]

# Tech tracking
tech-stack:
  added: []
  patterns: [sealed Result type, exhaustive switch pattern matching, mapException centralized error classification, runCatching async wrapper]

key-files:
  created:
    - lib/core/errors/result.dart
    - lib/core/errors/exception_mapper.dart
  modified:
    - lib/domain/repositories/customer_repository.dart
    - lib/data/repositories/customer_repository_impl.dart
    - lib/presentation/providers/customer_providers.dart
    - lib/presentation/providers/sync_providers.dart
    - lib/presentation/screens/hvc/hvc_detail_screen.dart
    - test/data/repositories/customer_repository_impl_test.dart
    - test/data/repositories/customer_repository_impl_test.mocks.dart

key-decisions:
  - "ResultFailure instead of Failure_ to satisfy camel_case_types lint while avoiding conflict with Failure base class"
  - "Renamed Failure_ variant to ResultFailure for lint compliance"
  - "@immutable from package:meta via ignore:depend_on_referenced_packages to satisfy avoid_equals_and_hash_code_on_mutable_classes lint"
  - "runCatching for simple CRUD (create/delete), explicit try/catch+mapException for methods with not-found logic or complex sync flows"
  - "updateCustomer returns null from transaction on not-found instead of throwing, enabling proper NotFoundFailure return (fixes pre-existing bug)"
  - "Generic Exception mapped to UnexpectedFailure (not DatabaseFailure) -- more accurate error classification"

patterns-established:
  - "Result<T> return type: All repository mutating methods return Future<Result<T>> instead of Future<Either<Failure, T>>"
  - "switch pattern matching: Consumers use 'case Success(:final value)' / 'case ResultFailure(:final failure)' for exhaustive handling"
  - "mapException centralization: All catch blocks use mapException() instead of constructing failures inline"
  - "runCatching wrapper: Simple CRUD methods use runCatching(() async { ... }, context: 'methodName') for minimal boilerplate"
  - ".when() callback: Available for single-expression result handling as alternative to switch"

# Metrics
duration: 14min
completed: 2026-02-14
---

# Phase 03 Plan 01: Error Classification & Recovery Foundation Summary

**Sealed Result<T> type with exhaustive pattern matching, mapException utility classifying 6+ exception types, and full CustomerRepository migration from dartz Either to typed error handling**

## Performance

- **Duration:** 14 min
- **Started:** 2026-02-13T20:13:48Z
- **Completed:** 2026-02-13T20:27:49Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- Created sealed Result<T> type with Success/ResultFailure variants supporting Dart 3 exhaustive switch
- Built mapException() classifying SocketException, TimeoutException, PostgrestException (status-aware), AuthException, FormatException to typed Failures
- Migrated all 8 CustomerRepository mutating methods from dartz Either to sealed Result end-to-end
- Updated 7 consumer call sites across 3 files (customer_providers, sync_providers, hvc_detail_screen) from .fold() to switch pattern matching
- All 17 customer repository tests pass with Result-based assertions

## Task Commits

Each task was committed atomically:

1. **Task 1: Create sealed Result type and exception mapper** - `95cd772` (feat)
2. **Task 2: Migrate CustomerRepository to Result type end-to-end** - `b6a76d0` (feat)

## Files Created/Modified
- `lib/core/errors/result.dart` - Sealed Result<T> with Success/ResultFailure, .when(), convenience getters, Either.toResult() adapter
- `lib/core/errors/exception_mapper.dart` - mapException() and runCatching() for centralized error classification
- `lib/domain/repositories/customer_repository.dart` - Interface with Result<T> return types
- `lib/data/repositories/customer_repository_impl.dart` - Implementation using runCatching/mapException
- `lib/presentation/providers/customer_providers.dart` - Form notifiers using switch pattern matching
- `lib/presentation/providers/sync_providers.dart` - Sync pull results using switch pattern matching
- `lib/presentation/screens/hvc/hvc_detail_screen.dart` - Delete key person using switch pattern matching
- `test/data/repositories/customer_repository_impl_test.dart` - Updated assertions for Result type
- `test/data/repositories/customer_repository_impl_test.mocks.dart` - Regenerated mocks

## Decisions Made
- Named failure variant `ResultFailure` instead of `Failure_` to satisfy Dart `camel_case_types` lint
- Used `runCatching` for 4 simple CRUD methods (create/delete customer, add/delete key person), explicit try/catch+mapException for 4 methods with complex logic (update customer/key person, sync from remote x2)
- Fixed pre-existing bug: `updateCustomer` now properly returns `NotFoundFailure` instead of generic `DatabaseFailure` when customer not found during update
- Generic `Exception` caught by `mapException` maps to `UnexpectedFailure` (more accurate than old `DatabaseFailure` catch-all)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed updateCustomer returning wrong failure type for not-found case**
- **Found during:** Task 2 (CustomerRepositoryImpl migration)
- **Issue:** Old code threw `Exception('Customer not found')` inside transaction, caught by outer catch as `DatabaseFailure`. Test expected `NotFoundFailure` but would have failed.
- **Fix:** Changed transaction to return `null` for not-found, check outside transaction, return `Result.failure(NotFoundFailure(...))` explicitly
- **Files modified:** lib/data/repositories/customer_repository_impl.dart
- **Verification:** Test passes: `expect(failure, isA<NotFoundFailure>())`
- **Committed in:** b6a76d0

**2. [Rule 3 - Blocking] Fixed AppLogger.init() missing in test setUp**
- **Found during:** Task 2 (running tests)
- **Issue:** `AppLogger.instance` is a late-initialized singleton; tests never called `AppLogger.init()`, causing `LateInitializationError` on every test
- **Fix:** Added `setUpAll(() { AppLogger.init(); })` to test file
- **Files modified:** test/data/repositories/customer_repository_impl_test.dart
- **Verification:** All 17 tests pass
- **Committed in:** b6a76d0

**3. [Rule 3 - Blocking] Updated sync_providers.dart and hvc_detail_screen.dart consumers**
- **Found during:** Task 2 (analyzing build after interface change)
- **Issue:** sync_providers.dart and hvc_detail_screen.dart call .fold() on CustomerRepository results; changing interface to Result<T> would break them
- **Fix:** Added Result import, replaced .fold() with switch pattern matching in both files
- **Files modified:** lib/presentation/providers/sync_providers.dart, lib/presentation/screens/hvc/hvc_detail_screen.dart
- **Verification:** flutter analyze passes with no errors
- **Committed in:** b6a76d0

---

**Total deviations:** 3 auto-fixed (1 bug fix, 2 blocking)
**Impact on plan:** All fixes necessary for correctness and successful compilation. No scope creep.

## Issues Encountered
None beyond the auto-fixed deviations documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Result<T> type and mapException are ready for Plan 02 (Pipeline + Activity repository migration)
- Pattern established: runCatching for simple CRUD, explicit try/catch+mapException for complex methods
- Plan 03 (screen error display updates) can use the switch pattern matching pattern demonstrated in customer_providers.dart

## Self-Check: PASSED

All files verified present. Both commits (95cd772, b6a76d0) verified in git log.

---
*Phase: 03-error-classification-recovery*
*Completed: 2026-02-14*
