---
status: diagnosed
trigger: "Zone mismatch error during initial sync after login + initial sync not triggering on app restart. Related to Phase 6 UncontrolledProviderScope changes."
created: 2026-02-18T00:00:00Z
updated: 2026-02-18T00:30:00Z
---

## Current Focus

hypothesis: ROOT CAUSES CONFIRMED (3 distinct bugs)
test: code trace analysis complete
expecting: n/a
next_action: report findings

## Symptoms

expected: After login, initial sync completes successfully populating local tables. On app restart, initial sync should re-trigger if needed.
actual: (1) Initial sync progress sheet appears but fails with "zone mismatch" error, tables not populated. (2) On app restart, initial sync doesn't show or trigger at all.
errors: "zone mismatch" error from Drift/SQLite operations
reproduction: Login to app after Phase 6 changes
started: After Phase 6 introduced UncontrolledProviderScope and eager SyncCoordinator initialization

## Eliminated

- hypothesis: "UncontrolledProviderScope itself causes the zone issue"
  evidence: UncontrolledProviderScope merely passes a ProviderContainer; it does not create zones. The container creation location (inside SentryFlutter.init's appRunner) is what matters.
  timestamp: 2026-02-18T00:15:00Z

## Evidence

- timestamp: 2026-02-18T00:05:00Z
  checked: git diff 2c5afbb..2ed277e for main.dart
  found: Phase 6 moved from ProviderScope (line 74 old) to UncontrolledProviderScope with ProviderContainer created at line 72. WidgetsFlutterBinding.ensureInitialized() stays at line 25 (root zone). ProviderContainer and initializeSyncServices run at lines 72-78 (Sentry zone). runApp at line 81 (Sentry zone).
  implication: ensureInitialized in root zone, everything else in Sentry zone = zone mismatch

- timestamp: 2026-02-18T00:08:00Z
  checked: sentry_flutter v9.13.0 and known zone issues
  found: getsentry/sentry-dart issues #2079, #2063, #1943 document zone mismatch. Flutter docs at flutter.dev/release/breaking-changes/zone-errors document the required fix.
  implication: Well-known issue with clear solution

- timestamp: 2026-02-18T00:12:00Z
  checked: initializeSyncServices() eager initialization chain
  found: container.read(syncCoordinatorProvider) -> reads appSettingsServiceProvider -> reads databaseProvider -> creates AppDatabase. Database created in Sentry zone BEFORE runApp.
  implication: Eager DB creation in wrong zone is the new trigger from Phase 6

- timestamp: 2026-02-18T00:20:00Z
  checked: coordinator.markInitialSyncComplete() call sites
  found: Method exists at sync_coordinator.dart:172 but is NEVER called. LoginScreen:53 and HomeScreen:56 call appSettings.markInitialSyncCompleted() directly.
  implication: Coordinator in-memory _initialSyncComplete stays false for the session

- timestamp: 2026-02-18T00:25:00Z
  checked: acquireLock gate for non-initial sync types
  found: sync_coordinator.dart:121 - acquireLock rejects any non-initial sync if _initialSyncComplete is false. Phase 2 (deltaSyncType=masterDataResync) and Phase 3 (manual triggerSync) are both rejected silently.
  implication: After Phase 1 completes, Phases 2 and 3 of initial sync silently fail, leaving transactional tables and user data empty

- timestamp: 2026-02-18T00:28:00Z
  checked: responsive_shell.dart long-press re-sync guard (line 307)
  found: Checks syncService.isSyncing but not coordinator.isLocked. After initial sync Phase 1 releases the lock and sets isSyncing=false, the re-sync sheet can open even though coordinator state may be stale.
  implication: Wrong guard for UAT test 6 failure

## Resolution

root_cause: |
  THREE ROOT CAUSES IDENTIFIED:

  BUG 1 - ZONE MISMATCH (Blocker, UAT test 2):
  File: C:/Users/cartr/git_stuff/LeadX.v1/lib/main.dart
  WidgetsFlutterBinding.ensureInitialized() at line 25 runs in ROOT zone.
  SentryFlutter.init's appRunner callback runs in SENTRY zone.
  ProviderContainer creation (line 72), initializeSyncServices (line 78),
  and runApp (line 81) all run in Sentry zone. The Flutter bindings were
  initialized in a different zone than runApp, causing the zone mismatch.
  Phase 6 made this worse by eagerly creating the database via
  initializeSyncServices() BEFORE runApp.

  BUG 2 - COORDINATOR STATE DESYNC (Major, causes silent Phase 2+3 failure):
  Files: C:/Users/cartr/git_stuff/LeadX.v1/lib/presentation/screens/auth/login_screen.dart (line 53)
         C:/Users/cartr/git_stuff/LeadX.v1/lib/presentation/screens/home/home_screen.dart (line 56)
         C:/Users/cartr/git_stuff/LeadX.v1/lib/data/services/sync_coordinator.dart (line 172)

  LoginScreen and HomeScreen call appSettings.markInitialSyncCompleted() directly,
  bypassing coordinator.markInitialSyncComplete(). The coordinator's in-memory
  _initialSyncComplete flag stays FALSE after initial sync. This causes:

  a) SyncProgressSheet Phase 2 (performDeltaSync with SyncType.masterDataResync)
     is REJECTED by coordinator.acquireLock() at line 121 -- returns lock-failure result
  b) SyncProgressSheet Phase 3 (triggerSync with SyncType.manual) is REJECTED by
     coordinator.acquireLock() at line 121 -- returns silently
  c) Result: master data tables may sync but delta tables (hvcs, brokers, etc.)
     and user data (customers, pipelines, activities) are NEVER pulled
  d) On app restart, coordinator.initialize() reads appSettings correctly,
     so _initialSyncComplete = true and normal sync works

  BUT ALSO: The markInitialSyncCompleted call in LoginScreen (line 53) happens
  AFTER SyncProgressSheet.show returns true. Since Phase 2 and 3 silently fail,
  SyncProgressSheet still returns true (individual phase errors are caught and
  don't fail the overall sync). So appSettings gets marked as completed even
  though most data was not pulled. On restart, sync appears done but tables are empty.

  BUG 3 - WRONG RE-SYNC GUARD (Major, UAT test 6):
  File: C:/Users/cartr/git_stuff/LeadX.v1/lib/presentation/widgets/shell/responsive_shell.dart (line 307)
  Long-press re-sync checks syncService.isSyncing but should check
  coordinator.isLocked (or both). When no sync is actively running but
  coordinator may be in a relevant state, the check is insufficient.

fix:
verification:
files_changed: []
