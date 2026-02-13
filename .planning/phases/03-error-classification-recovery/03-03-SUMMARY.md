---
phase: 03-error-classification-recovery
plan: 03
subsystem: ui
tags: [flutter, riverpod, offline-first, connectivity, error-handling, consumer-widget]

# Dependency graph
requires:
  - phase: 03-01
    provides: AppErrorState widget and Result sealed type
provides:
  - Reusable OfflineBanner widget watching connectivityStreamProvider
  - Offline-aware customer list/detail, pipeline detail, activity list/detail screens
  - Proper AppErrorState usage replacing raw Text('Error') in 6 screens
affects: [04-sync-status-transparency, ui-screens, offline-experience]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "OfflineBanner pattern: ConsumerWidget watching connectivityStreamProvider with valueOrNull ?? true default"
    - "Error callback pattern: AppErrorState.general() in AsyncValue.when() error callbacks"

key-files:
  created:
    - lib/presentation/widgets/common/offline_banner.dart
  modified:
    - lib/presentation/screens/home/tabs/customers_tab.dart
    - lib/presentation/screens/customer/customer_detail_screen.dart
    - lib/presentation/screens/pipeline/pipeline_detail_screen.dart
    - lib/presentation/screens/home/tabs/activities_tab.dart
    - lib/presentation/screens/activity/activity_detail_screen.dart

key-decisions:
  - "OfflineBanner defaults to connected (valueOrNull ?? true) to avoid false offline flash on startup"
  - "OfflineBanner placed inside Column above Expanded content, not wrapping children"
  - "AppErrorState.general() used for all Drift error callbacks since network errors are handled by OfflineBanner"

patterns-established:
  - "OfflineBanner placement: Add as first child in Column wrapping screen body content"
  - "Error callback replacement: Replace Text('Error: $error') with AppErrorState.general(title: '...', message: error.toString())"

# Metrics
duration: 5min
completed: 2026-02-14
---

# Phase 3 Plan 3: Offline-Aware UI Summary

**OfflineBanner widget watching connectivity + AppErrorState replacing raw error text across 6 core entity screens**

## Performance

- **Duration:** 5 min
- **Started:** 2026-02-13T20:30:19Z
- **Completed:** 2026-02-13T20:35:16Z
- **Tasks:** 2
- **Files modified:** 6 (1 created, 5 modified)

## Accomplishments
- Created reusable OfflineBanner ConsumerWidget that shows staleness warning when device is offline
- Added offline awareness to all 6 core entity screens (customer list/detail, pipeline detail, activity list/detail)
- Replaced all raw Text('Error: $error') patterns with AppErrorState widgets in all 6 screens
- Fixed pre-existing .fold() call on Result type in customer detail key person delete (03-01 migration gap)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create OfflineBanner widget and update customer screens** - `7629725` (feat)
2. **Task 2: Update pipeline and activity screens with offline banner and error display** - `35b93ed` (feat)

## Files Created/Modified
- `lib/presentation/widgets/common/offline_banner.dart` - New reusable offline connectivity banner widget
- `lib/presentation/screens/home/tabs/customers_tab.dart` - Added OfflineBanner, replaced error text with AppErrorState
- `lib/presentation/screens/customer/customer_detail_screen.dart` - Added OfflineBanner, replaced 4 error texts with AppErrorState, fixed Result .fold() migration
- `lib/presentation/screens/pipeline/pipeline_detail_screen.dart` - Added OfflineBanner, replaced error text with AppErrorState
- `lib/presentation/screens/home/tabs/activities_tab.dart` - Added OfflineBanner, replaced error text with AppErrorState
- `lib/presentation/screens/activity/activity_detail_screen.dart` - Added OfflineBanner, replaced error text with AppErrorState

## Decisions Made
- OfflineBanner defaults to connected (valueOrNull ?? true) to avoid false offline flash on startup, matching responsive_shell.dart pattern
- OfflineBanner placed as first child in Column wrapping screen body, not wrapping content -- it just shows/hides itself
- All error callbacks use AppErrorState.general() since Drift error callbacks only fire on database errors (rare), not network errors

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed .fold() to switch/case for Result type in key person delete**
- **Found during:** Task 1 (customer_detail_screen.dart)
- **Issue:** `deleteKeyPerson` returns `Result<void>` (migrated in 03-01) but call site still used dartz `.fold()` pattern
- **Fix:** Replaced `.fold((failure) {...}, (_) {...})` with `switch (result) { case ResultFailure(:final failure): ... case Success(): ... }`
- **Files modified:** lib/presentation/screens/customer/customer_detail_screen.dart
- **Verification:** flutter analyze passes with no errors
- **Committed in:** 7629725 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Essential fix for compilation -- .fold() doesn't exist on sealed Result type. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- ERR-03 requirement fully satisfied: all core entity screens show cached data with staleness warning when offline
- All 6 screens now use AppErrorState instead of raw error text
- OfflineBanner is reusable for any future screens that need offline awareness
- Ready for 03-02 plan (if not yet complete) or next phase

---
## Self-Check: PASSED

All 7 files verified present. Both task commits (7629725, 35b93ed) verified in git history.

---
*Phase: 03-error-classification-recovery*
*Completed: 2026-02-14*
