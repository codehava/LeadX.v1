---
phase: 06-sync-coordination
plan: 04
subsystem: sync
tags: [zone-mismatch, sync-coordinator, initial-sync, sentry, flutter-binding]

# Dependency graph
requires:
  - phase: 06-sync-coordination (plans 01-03)
    provides: SyncCoordinator with lock, markInitialSyncComplete, isLocked, SyncProgressSheet
provides:
  - Zone-correct WidgetsFlutterBinding inside Sentry appRunner
  - Coordinator-routed markInitialSyncComplete in LoginScreen and HomeScreen
  - Coordinator isLocked guard on master data re-sync onLongPress
affects: [07-offline-ux-polish]

# Tech tracking
tech-stack:
  added: []
  patterns: [zone-aware binding initialization inside Sentry appRunner]

key-files:
  created: []
  modified:
    - lib/main.dart
    - lib/presentation/screens/auth/login_screen.dart
    - lib/presentation/screens/home/home_screen.dart
    - lib/presentation/widgets/shell/responsive_shell.dart

key-decisions:
  - "WidgetsFlutterBinding moved inside appRunner since Sentry wraps it in its own zone; binding must be in same zone as runApp"
  - "coordinator.markInitialSyncComplete() replaces direct appSettings call to set both persisted and in-memory flags"
  - "onLongPress gets coordinator.isLocked check plus legacy isSyncing fallback for standalone sync"

patterns-established:
  - "Zone-aware initialization: WidgetsFlutterBinding must be inside Sentry appRunner callback"
  - "Coordinator routing: UI screens use coordinator for sync lifecycle, not appSettings directly"

requirements-completed: [CONF-05]

# Metrics
duration: 5min
completed: 2026-02-18
---

# Phase 6 Plan 4: UAT Gap Closure Summary

**Fixed 3 UAT-diagnosed bugs: zone mismatch crash, coordinator flag not set on initial sync, and missing re-sync onLongPress guard**

## Performance

- **Duration:** 5 min
- **Started:** 2026-02-18T09:07:39Z
- **Completed:** 2026-02-18T09:12:49Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Eliminated zone mismatch crash by moving WidgetsFlutterBinding.ensureInitialized() inside Sentry appRunner callback
- Routed markInitialSyncComplete through coordinator in both LoginScreen and HomeScreen, setting the in-memory flag that gates Phase 2/3 sync
- Added coordinator.isLocked guard to onLongPress handler in ResponsiveShell, mirroring existing onTap guard

## Task Commits

Each task was committed atomically:

1. **Task 1: Fix zone mismatch by moving WidgetsFlutterBinding inside appRunner** - `4a9274e` (fix)
2. **Task 2: Route markInitialSyncComplete through coordinator and add coordinator guard to onLongPress** - `a4a60ec` (fix)

## Files Created/Modified
- `lib/main.dart` - Moved WidgetsFlutterBinding.ensureInitialized() from root zone into appRunner callback
- `lib/presentation/screens/auth/login_screen.dart` - Replaced appSettings.markInitialSyncCompleted() with coordinator.markInitialSyncComplete()
- `lib/presentation/screens/home/home_screen.dart` - Same coordinator routing for backup initial sync check
- `lib/presentation/widgets/shell/responsive_shell.dart` - Added coordinator.isLocked check to onLongPress with legacy isSyncing fallback

## Decisions Made
- WidgetsFlutterBinding moved inside appRunner since Sentry wraps it in its own zone; binding must be in same zone as runApp
- coordinator.markInitialSyncComplete() replaces direct appSettings call to set both persisted and in-memory flags
- onLongPress gets coordinator.isLocked check plus legacy isSyncing fallback for standalone sync

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three UAT gap root causes (tests 1, 2, 6) are now addressed
- Phase 6 sync coordination is fully functional: zone-correct startup, coordinator-gated initial sync, coordinator-guarded re-sync
- Ready for Phase 7 (Offline UX Polish)

## Self-Check: PASSED

- All 4 modified files confirmed on disk
- Commit `4a9274e` (Task 1) confirmed in git log
- Commit `a4a60ec` (Task 2) confirmed in git log
- SUMMARY.md created at `.planning/phases/06-sync-coordination/06-04-SUMMARY.md`

---
*Phase: 06-sync-coordination*
*Completed: 2026-02-18*
