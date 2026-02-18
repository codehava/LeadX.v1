---
phase: 05-background-sync-dead-letter-queue
plan: 03
subsystem: sync
tags: [flutter, workmanager, background-sync, ios, android, offline-first]

# Dependency graph
requires:
  - phase: 05-background-sync-dead-letter-queue
    provides: "Dead letter status tracking, sync queue processing, pruning lifecycle"
  - phase: 04-conflict-resolution
    provides: "Idempotent operations for safe background retry"
provides:
  - "WorkManager background sync service with push-only processing"
  - "iOS BGTaskScheduler configuration (Info.plist + AppDelegate)"
  - "Android WorkManager periodic task registration"
  - "Settings toggle for user-controlled background sync enable/disable"
  - "backgroundSyncEnabledProvider for reactive toggle state"
affects: [06-sync-coordination]

# Tech tracking
tech-stack:
  added: [workmanager]
  patterns:
    - "Top-level callbackDispatcher with independent Supabase+Drift init for separate FlutterEngine"
    - "Push-only background sync to stay within iOS 30-second time limit"
    - "Always-register pattern with in-callback toggle check to avoid register/cancel lifecycle complexity"

key-files:
  created:
    - lib/data/services/background_sync_service.dart
  modified:
    - lib/main.dart
    - lib/presentation/screens/profile/settings_screen.dart
    - lib/presentation/providers/sync_providers.dart
    - ios/Runner/AppDelegate.swift
    - ios/Runner/Info.plist
    - pubspec.yaml
    - pubspec.lock

key-decisions:
  - "Push-only in background (no pull) to stay within iOS 30-second BGTaskScheduler limit"
  - "Always register periodic task on startup; callback checks toggle setting and skips if disabled"
  - "Auth session checked before sync attempt -- graceful skip if expired (return true, no aggressive retry)"
  - "ExistingPeriodicWorkPolicy.update prevents duplicate task registrations"
  - "Background sync defaults to OFF -- user must explicitly opt in via Settings toggle"
  - "backgroundSyncEnabledProvider uses AppSettings (Drift) -- no shared_preferences dependency added"

patterns-established:
  - "Background service pattern: top-level @pragma('vm:entry-point') callback with independent init of Supabase, Drift, ConnectivityService"
  - "Settings toggle pattern: AppSettings key-value persistence + provider invalidation + service register/cancel"

requirements-completed: [CONF-04]

# Metrics
duration: 8min
completed: 2026-02-18
---

# Phase 05 Plan 03: Background Sync Summary

**WorkManager background sync with push-only queue processing, iOS/Android platform config, and user-controlled settings toggle**

## Performance

- **Duration:** ~8 min (across continuation checkpoint)
- **Started:** 2026-02-18T06:30:00Z (estimated)
- **Completed:** 2026-02-18T07:00:47Z
- **Tasks:** 2 auto + 1 checkpoint (approved)
- **Files modified:** 8

## Accomplishments
- Added workmanager package and created BackgroundSyncService with top-level callbackDispatcher that runs in a separate FlutterEngine with independent Supabase and Drift initialization
- Background callback performs push-only sync (no pull) to stay within iOS 30-second BGTaskScheduler time limit, with auth session validation and connectivity checks
- Configured iOS platform: Info.plist UIBackgroundModes (fetch + processing) and BGTaskSchedulerPermittedIdentifiers, AppDelegate WorkmanagerPlugin.registerTask
- Integrated WorkManager init in main.dart with always-register pattern (callback checks toggle setting internally)
- Added "Sinkronisasi Latar Belakang" toggle in Settings screen that persists to AppSettings and controls background sync behavior

## Task Commits

Each task was committed atomically:

1. **Task 1: Add workmanager dependency + create BackgroundSyncService + platform config** - `fccecbd` (feat)
2. **Task 2: Integrate workmanager init in main.dart + Settings toggle** - `c21ae02` (feat)
3. **Task 3: Human-verify checkpoint** - APPROVED (no commit)

## Files Created/Modified
- `lib/data/services/background_sync_service.dart` - Top-level callbackDispatcher and BackgroundSyncService class with register/cancel static methods
- `lib/main.dart` - BackgroundSyncService.initialize() + registerPeriodicSync() in app startup
- `lib/presentation/screens/profile/settings_screen.dart` - SwitchListTile for background sync toggle with AppSettings persistence
- `lib/presentation/providers/sync_providers.dart` - backgroundSyncEnabledProvider FutureProvider reading from AppSettings
- `ios/Runner/AppDelegate.swift` - WorkmanagerPlugin import and registerTask call
- `ios/Runner/Info.plist` - UIBackgroundModes (fetch, processing) and BGTaskSchedulerPermittedIdentifiers
- `pubspec.yaml` - workmanager dependency added
- `pubspec.lock` - Lock file updated with workmanager resolution

## Decisions Made
- Push-only in background (no pull) -- pull involves 10+ tables and risks exceeding iOS 30-second limit; push is bounded by queue size
- Always register periodic task on startup rather than conditional register/cancel -- simpler lifecycle, callback checks toggle and skips if disabled
- Auth session checked before sync attempt -- if expired, return true (success) so WorkManager doesn't retry aggressively
- ExistingPeriodicWorkPolicy.update used to prevent duplicate task registrations on repeated app launches
- Background sync defaults to OFF per "nice to have" characterization -- users opt in
- Used AppSettings (Drift key-value) for toggle persistence instead of adding shared_preferences dependency

## Deviations from Plan

None - plan executed as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 5 fully complete: dead letter tracking (Plan 01), dead letter UI (Plan 02), and background sync (Plan 03)
- All three SYNC-06, CONF-02, CONF-04 requirements satisfied
- Phase 6 (Sync Coordination) can build on the background sync foundation for sync locking and phase serialization
- WorkManager integration provides the periodic trigger that Phase 6 will need to coordinate with foreground sync

## Self-Check: PASSED

- All 8 created/modified files verified present on disk
- Commits fccecbd and c21ae02 verified in git log
- Checkpoint task 3 approved by user

---
*Phase: 05-background-sync-dead-letter-queue*
*Completed: 2026-02-18*
