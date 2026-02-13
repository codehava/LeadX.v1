---
phase: 03-error-classification-recovery
plan: 02
subsystem: errors
tags: [result-type, pattern-matching, error-handling, pipeline, activity, repository-migration]

# Dependency graph
requires:
  - phase: 03-error-classification-recovery/01
    provides: Sealed Result<T> type, mapException(), runCatching(), migration pattern from CustomerRepository
provides:
  - "PipelineRepository fully migrated from dartz Either to sealed Result (5 mutating methods)"
  - "ActivityRepository fully migrated from dartz Either to sealed Result (8 mutating methods)"
  - "All 3 core repositories (Customer, Pipeline, Activity) return Result<T> with typed error classification"
  - "ERR-02 requirement satisfied: 3 core repositories migrated"
affects: [03-03 screen error display updates, all future repository consumers]

# Tech tracking
tech-stack:
  added: []
  patterns: [runCatching for simple photo CRUD, explicit try/catch+mapException for complex multi-step operations with validation]

key-files:
  created: []
  modified:
    - lib/domain/repositories/pipeline_repository.dart
    - lib/data/repositories/pipeline_repository_impl.dart
    - lib/presentation/providers/pipeline_providers.dart
    - lib/presentation/screens/pipeline/pipeline_stage_update_sheet.dart
    - lib/presentation/screens/pipeline/pipeline_status_update_sheet.dart
    - test/data/repositories/pipeline_repository_impl_test.dart
    - test/data/repositories/pipeline_repository_impl_test.mocks.dart
    - lib/domain/repositories/activity_repository.dart
    - lib/data/repositories/activity_repository_impl.dart
    - lib/presentation/providers/activity_providers.dart

key-decisions:
  - "runCatching for simple CRUD (deletePipeline, addPhoto, deletePhoto, addPhotoFromUrl); explicit try/catch+mapException for complex methods with not-found/validation logic"
  - "Pipeline screen sheets (stage_update, status_update) updated as blocking deviation -- they called .fold() directly on repository results"
  - "Pre-existing test bug fixed: closedAt test missing finalPremium in DTO, and getPipelineById mock override order causing wrong pipeline returned"

patterns-established:
  - "All core repository migrations complete -- same pattern: interface Result<T>, impl mapException/runCatching, providers switch pattern matching"
  - "Screen-level consumers that call repository methods directly must also be updated when migrating (not just providers)"

# Metrics
duration: 18min
completed: 2026-02-14
---

# Phase 03 Plan 02: Pipeline & Activity Repository Migration Summary

**Pipeline (5 methods) and Activity (8 methods) repositories migrated from dartz Either to sealed Result with typed mapException error classification and exhaustive switch pattern matching across 10 files**

## Performance

- **Duration:** 18 min
- **Started:** 2026-02-13T20:30:16Z
- **Completed:** 2026-02-13T20:49:13Z
- **Tasks:** 2
- **Files modified:** 10

## Accomplishments
- Migrated all 5 PipelineRepository mutating methods from dartz Either to sealed Result end-to-end (interface, impl, providers, tests)
- Migrated all 8 ActivityRepository mutating methods from dartz Either to sealed Result end-to-end (interface, impl, providers)
- Replaced 12 .fold() call sites across 4 provider/screen files with switch pattern matching
- All 21 pipeline repository tests pass with Result-based assertions
- ERR-02 requirement complete: all 3 core repositories (Customer, Pipeline, Activity) use sealed Result<T>

## Task Commits

Each task was committed atomically:

1. **Task 1: Migrate PipelineRepository to Result type end-to-end** - `5926b48` (feat)
2. **Task 2: Migrate ActivityRepository to Result type end-to-end** - `c355a49` (feat)

## Files Created/Modified
- `lib/domain/repositories/pipeline_repository.dart` - Interface with Result<T> return types for 5 methods
- `lib/data/repositories/pipeline_repository_impl.dart` - Implementation using mapException/runCatching
- `lib/presentation/providers/pipeline_providers.dart` - Form notifiers using switch pattern matching (5 call sites)
- `lib/presentation/screens/pipeline/pipeline_stage_update_sheet.dart` - Switch pattern matching for stage update result
- `lib/presentation/screens/pipeline/pipeline_status_update_sheet.dart` - Switch pattern matching for status update result
- `test/data/repositories/pipeline_repository_impl_test.dart` - Updated assertions for Result type, fixed test bugs
- `test/data/repositories/pipeline_repository_impl_test.mocks.dart` - Regenerated mocks
- `lib/domain/repositories/activity_repository.dart` - Interface with Result<T> return types for 8 methods
- `lib/data/repositories/activity_repository_impl.dart` - Implementation using mapException/runCatching
- `lib/presentation/providers/activity_providers.dart` - Form notifiers using switch pattern matching (7 call sites)

## Decisions Made
- Used `runCatching()` for 4 simple methods (deletePipeline, addPhoto, deletePhoto, addPhotoFromUrl) and explicit `try/catch + mapException` for 9 complex methods with not-found/validation logic
- Pipeline screen sheets needed updating as they called `.fold()` directly on repository results (Rule 3 deviation)
- Fixed pre-existing test bug: closedAt test was missing `finalPremium` in DTO and had mock override ordering issue

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Updated pipeline_stage_update_sheet and pipeline_status_update_sheet**
- **Found during:** Task 1 (Pipeline provider migration)
- **Issue:** Both screen files call `.fold()` directly on repository results (not through the notifier), so changing the return type from Either to Result would break compilation
- **Fix:** Added `Result` import and replaced `.fold()` with switch pattern matching in both files
- **Files modified:** lib/presentation/screens/pipeline/pipeline_stage_update_sheet.dart, lib/presentation/screens/pipeline/pipeline_status_update_sheet.dart
- **Verification:** flutter analyze passes with no errors
- **Committed in:** 5926b48

**2. [Rule 1 - Bug] Fixed pre-existing test bugs in pipeline_repository_impl_test.dart**
- **Found during:** Task 1 (running tests after migration)
- **Issue:** (a) `closedAt` test missing `finalPremium` in DTO caused ValidationFailure instead of Success; (b) `getPipelineById` mock override ordering caused wrong pipeline to be returned on first call; (c) Missing stubs for `getStageById`, `getCustomerById`, `transaction`, `triggerSync` that were previously swallowed by generic catch blocks
- **Fix:** Added `finalPremium: 50000000` to DTO, used sequential mock returns for `getPipelineById`, added default stubs in setUp for all commonly-called methods
- **Files modified:** test/data/repositories/pipeline_repository_impl_test.dart
- **Verification:** All 21 tests pass
- **Committed in:** 5926b48

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug fix)
**Impact on plan:** Both fixes necessary for compilation and test correctness. No scope creep.

## Issues Encountered
None beyond the auto-fixed deviations documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All 3 core repositories fully migrated to sealed Result type
- ERR-02 requirement satisfied
- Plan 03 (screen-level error display improvements) can now use typed failures from all repositories
- Pattern is fully established: future repository migrations follow the exact same steps

## Self-Check: PASSED

All 9 modified files verified present. Both commits (5926b48, c355a49) verified in git log.

---
*Phase: 03-error-classification-recovery*
*Completed: 2026-02-14*
