---
status: diagnosed
phase: 06-sync-coordination
source: [06-01-SUMMARY.md, 06-02-SUMMARY.md, 06-03-SUMMARY.md]
started: 2026-02-18T16:00:00Z
updated: 2026-02-18T16:30:00Z
---

## Current Test

[testing complete]

## Tests

### 1. App starts without crash after coordinator wiring
expected: App launches normally with no crash or hang. Reaches login or home screen depending on auth state.
result: issue
reported: "on startup, the initial sync doesnt show or doesnt even sync anything"
severity: major

### 2. Initial sync progress sheet appears after login
expected: After logging in (or on first app open after login), the sync progress bottom sheet appears showing sync phases (master data, delta sync, user data). It should not be dismissible by tapping outside.
result: issue
reported: "it appears, but resuled tables arent in, zone mismatch as the error say it"
severity: blocker

### 3. Successful initial sync shows continue button
expected: When initial sync completes successfully, the progress sheet shows a "Lanjutkan" (Continue) button. Tapping it dismisses the sheet and you proceed to the home screen.
result: skipped
reason: Blocked by zone mismatch error in test 2

### 4. Manual sync button works normally
expected: On the home screen, tapping the sync button (in the app bar or responsive shell) triggers a sync. The sync runs to completion without errors. Sync status updates normally.
result: pass

### 5. Toast when manual sync triggered while syncing
expected: Quickly double-tap the sync button (or tap it while a sync is actively running). Instead of starting a second sync, a toast/snackbar appears saying "Sinkronisasi sedang berjalan -- permintaan Anda diantrikan" (or similar queued message). The original sync continues normally.
result: pass

### 6. Master data re-sync guard
expected: Long-press the sync area to trigger master data re-sync. If a regular sync is already running, a toast appears saying "Sinkronisasi sedang berjalan, coba lagi nanti" and the re-sync sheet does not open.
result: issue
reported: "it shows mempersiapkan, rather than blocking"
severity: major

### 7. Retry UI on sync failure (if testable)
expected: If initial sync fails (e.g., turn off WiFi mid-sync), the progress sheet shows a retry message like "Mencoba ulang dalam X detik..." and automatically retries. After 3 failures, a red "Batalkan & Keluar" (Cancel & Log Out) button appears.
result: pass

### 8. Cancel and log out clears session
expected: After the "Batalkan & Keluar" button appears (test 7), tapping it signs you out and returns to the login screen. Local data is preserved (not wiped). On next login, initial sync will run again.
result: pass

## Summary

total: 8
passed: 4
issues: 3
pending: 0
skipped: 1

## Gaps

- truth: "App launches normally and initial sync triggers on startup"
  status: failed
  reason: "User reported: on startup, the initial sync doesnt show or doesnt even sync anything"
  severity: major
  test: 1
  root_cause: "coordinator.markInitialSyncComplete() is NEVER called by anyone. LoginScreen and HomeScreen call appSettings.markInitialSyncCompleted() directly, bypassing the coordinator. The in-memory _initialSyncComplete flag stays false, causing SyncProgressSheet Phase 2 (performDeltaSync with SyncType.masterDataResync) and Phase 3 (triggerSync with SyncType.manual) to be silently rejected by the coordinator gate. On restart, appSettings says initial sync is done but tables are empty."
  artifacts:
    - path: "lib/presentation/screens/auth/login_screen.dart"
      issue: "Calls appSettings.markInitialSyncCompleted() instead of coordinator.markInitialSyncComplete()"
    - path: "lib/presentation/screens/home/home_screen.dart"
      issue: "Calls appSettings.markInitialSyncCompleted() instead of coordinator.markInitialSyncComplete()"
    - path: "lib/data/services/sync_coordinator.dart"
      issue: "markInitialSyncComplete() method exists but is never called"
  missing:
    - "LoginScreen and HomeScreen must call coordinator.markInitialSyncComplete() instead of appSettings directly"
    - "OR SyncProgressSheet should call coordinator.markInitialSyncComplete() after Phase 1 succeeds but before Phase 2"
  debug_session: ".planning/debug/zone-mismatch-initial-sync.md"

- truth: "Initial sync progress sheet completes and populates tables"
  status: failed
  reason: "User reported: it appears, but resuled tables arent in, zone mismatch as the error say it"
  severity: blocker
  test: 2
  root_cause: "WidgetsFlutterBinding.ensureInitialized() runs at main.dart line 25 in the ROOT zone, but runApp() and all provider initialization runs inside SentryFlutter.init appRunner callback in a DIFFERENT zone (Sentry's error-capturing zone). Phase 6 made this worse by adding eager initializeSyncServices() which creates the Drift database BEFORE runApp(), whereas previously ProviderScope deferred provider creation."
  artifacts:
    - path: "lib/main.dart"
      issue: "WidgetsFlutterBinding.ensureInitialized() at line 25 (root zone) vs runApp at line 81 (Sentry zone) — zone mismatch"
  missing:
    - "Move WidgetsFlutterBinding.ensureInitialized() INSIDE the appRunner callback as the very first line"
  debug_session: ".planning/debug/zone-mismatch-initial-sync.md"

- truth: "Master data re-sync blocked when sync already running"
  status: failed
  reason: "User reported: it shows mempersiapkan, rather than blocking"
  severity: major
  test: 6
  root_cause: "Two compounding bugs: (1) onLongPress handler checks syncService.isSyncing which is structurally NEVER true during coordinator-driven syncs — processQueue() returns early at the coordinator lock check before _isSyncing=true is reached. (2) onLongPress handler is missing coordinator.isLocked check that onTap already has — Plan 02 added isSyncing to onLongPress, Plan 03 added coordinator to onTap, but nobody added coordinator to onLongPress."
  artifacts:
    - path: "lib/presentation/widgets/shell/responsive_shell.dart"
      issue: "onLongPress handler (line 304) missing coordinator.isLocked check that onTap has (line 267)"
    - path: "lib/data/services/sync_service.dart"
      issue: "_isSyncing never true when coordinator lock held — early return at line 101 prevents reaching _isSyncing=true at line 147"
  missing:
    - "Add coordinator.isLocked check to onLongPress handler mirroring onTap"
    - "Optionally fix syncService.isSyncing to reflect coordinator lock state"
  debug_session: ".planning/debug/resync-guard-not-blocking.md"
