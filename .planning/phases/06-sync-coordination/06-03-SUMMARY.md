---
phase: 06-sync-coordination
plan: 03
subsystem: sync
tags: [coordinator, provider, riverpod, lock, background-sync, toast, startup]

# Dependency graph
requires:
  - phase: 06-sync-coordination
    provides: SyncCoordinator service with Completer-based lock (plan 01)
provides:
  - syncCoordinatorProvider (Riverpod provider for SyncCoordinator singleton)
  - Coordinated SyncNotifier.triggerSync() with lock acquire/release and queue collapse
  - Background sync initial sync gate via AppSettingsService
  - Eager coordinator initialization on app startup via initializeSyncServices()
  - Manual sync toast notification when sync is queued
affects: [07-sync-notifier-refactor]

# Tech tracking
tech-stack:
  added: []
  patterns: [eager-startup-initialization, uncontrolled-provider-scope, coordinator-lock-in-notifier]

key-files:
  created: []
  modified:
    - lib/presentation/providers/sync_providers.dart
    - lib/presentation/widgets/shell/responsive_shell.dart
    - lib/data/services/background_sync_service.dart
    - lib/main.dart

key-decisions:
  - "UncontrolledProviderScope in main.dart for eager initializeSyncServices() call before widget tree"
  - "Manual sync toast shown at UI layer (responsive_shell) via coordinator.isLocked check before triggerSync()"
  - "Background sync uses AppSettingsService.hasInitialSyncCompleted() instead of raw DB query for consistency"
  - "Queued sync is silent for non-manual triggers; only user-initiated manual sync shows toast"

patterns-established:
  - "Coordinator-aware triggerSync: acquire lock -> push+pull -> release lock -> consume queued -> recursive call"
  - "Background sync initial gate: check hasInitialSyncCompleted before processing queue in separate FlutterEngine"

requirements-completed: [CONF-05]

# Metrics
duration: 12min
completed: 2026-02-18
---

# Phase 06 Plan 03: Sync Entry Point Wiring Summary

**SyncCoordinator wired into all sync entry points via Riverpod provider with coordinated lock in SyncNotifier, initial sync gate in background callback, eager startup initialization, and manual sync toast**

## Performance

- **Duration:** 12 min
- **Started:** 2026-02-18T08:20:00Z
- **Completed:** 2026-02-18T08:32:00Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Created syncCoordinatorProvider and wired coordinator into SyncService, InitialSyncService, and SyncNotifier providers
- Rewrote SyncNotifier.triggerSync() to acquire/release coordinator lock with queued sync collapse and follow-up execution
- Added initial sync completion gate in background sync callback to prevent pushing before reference data exists
- Wired initializeSyncServices() into main.dart for eager coordinator initialization on app startup
- Added toast notification in responsive_shell manual sync button when lock is held

## Task Commits

Each task was committed atomically:

1. **Task 1: Create SyncCoordinator provider and update SyncNotifier with coordinated sync** - `5780ed1` (feat)
2. **Task 2: Update background sync and app startup for coordinator integration** - `2ed277e` (feat)

## Files Created/Modified
- `lib/presentation/providers/sync_providers.dart` - Added syncCoordinatorProvider; injected coordinator into SyncService, InitialSyncService, SyncNotifier providers; rewrote triggerSync() with lock; updated initializeSyncServices()
- `lib/presentation/widgets/shell/responsive_shell.dart` - Manual sync button checks coordinator.isLocked before triggering, shows queued toast
- `lib/data/services/background_sync_service.dart` - Added initial sync completion gate; replaced raw DB query with AppSettingsService
- `lib/main.dart` - Created ProviderContainer with UncontrolledProviderScope; calls initializeSyncServices() eagerly before widget tree

## Decisions Made
- Used UncontrolledProviderScope pattern in main.dart to create ProviderContainer before widget tree, enabling eager initializeSyncServices() call. This ensures coordinator is initialized (stale lock recovery, initial sync state loaded) before any sync can trigger.
- Manual sync toast ("Sinkronisasi sedang berjalan -- permintaan Anda diantrikan") shown at UI layer via coordinator.isLocked check in responsive_shell, per user decision that coordination issues for non-manual triggers should be silent (logged to Talker only).
- Background sync AppSettingsService replaces raw DB query for consistency with foreground code patterns.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Wired initializeSyncServices() into main.dart**
- **Found during:** Task 2
- **Issue:** Plan assumed initializeSyncServices() was already called from main.dart ("The app startup already calls initializeSyncServices(). Verify this is the case."). Verification showed it was defined but never called -- the function was created in a previous phase but never wired into app startup.
- **Fix:** Created ProviderContainer explicitly in main.dart, called initializeSyncServices(container), then wrapped the app in UncontrolledProviderScope to share the container with the widget tree. This replaces the previous ProviderScope pattern.
- **Files modified:** lib/main.dart
- **Verification:** flutter analyze passes; the coordinator.initialize() now runs on every app startup
- **Committed in:** 2ed277e (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Essential fix -- without wiring initializeSyncServices(), the coordinator would never initialize on startup and stale lock recovery would not run. No scope creep.

## Issues Encountered
- Pre-existing compilation error in test/helpers/mock_sync_infrastructure.dart (missing getFailedAndDeadLetterItems from Phase 5). Integration tests depending on this helper fail. Unit tests (auth, customer, pipeline) all pass. Out of scope.
- Pre-existing info-level analyzer warnings (unawaited_futures in pull methods, unnecessary_underscores in UI) -- all pre-date this plan.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 6 complete: All 3 plans delivered. SyncCoordinator is fully integrated into all sync entry points.
- The 7 sync coordination points are now active: (1) SyncService.processQueue checks coordinator lock, (2) SyncService.triggerSync checks coordinator lock, (3) SyncService.startBackgroundSync checks coordinator lock, (4) SyncNotifier.triggerSync acquires/releases coordinator lock, (5) InitialSyncService.performInitialSync acquires/releases coordinator lock, (6) InitialSyncService.performDeltaSync acquires/releases coordinator lock, (7) Background sync checks persisted initial sync flag.
- Ready for Phase 7 (sync notifier refactor) or any further sync-related work.

## Self-Check: PASSED

- All 4 modified files verified on disk
- Commit 5780ed1 verified in git log
- Commit 2ed277e verified in git log

---
*Phase: 06-sync-coordination*
*Completed: 2026-02-18*
