---
status: diagnosed
phase: 06-sync-coordination
source: [06-01-SUMMARY.md, 06-02-SUMMARY.md, 06-03-SUMMARY.md, 06-04-SUMMARY.md]
started: 2026-02-19T10:00:00Z
updated: 2026-02-19T10:15:00Z
---

## Current Test

[testing complete]

## Tests

### 1. App starts without crash after coordinator wiring
expected: App launches normally with no crash or hang. Reaches login or home screen depending on auth state. No zone mismatch errors in console.
result: pass

### 2. Initial sync progress sheet appears and completes after login
expected: After logging in, the sync progress bottom sheet appears showing sync phases. Tables are populated — no zone mismatch error. Sheet is not dismissible by tapping outside.
result: issue
reported: "sync.coordinator | Rejected SyncType.masterDataResync sync (initial sync not complete), none of the tables get populated"
severity: major

### 3. Initial sync continue button works
expected: When initial sync completes successfully, the progress sheet shows a "Lanjutkan" (Continue) button. Tapping it dismisses the sheet and you proceed to the home screen with data loaded.
result: issue
reported: "continue works, but none of the data is populated"
severity: major

### 4. Manual sync button works normally
expected: On the home screen, tapping the sync button triggers a sync. The sync runs to completion without errors.
result: pass

### 5. Toast when manual sync triggered while syncing
expected: Quickly double-tap the sync button while a sync is running. Instead of starting a second sync, a toast/snackbar appears saying sync is queued. The original sync continues normally.
result: pass

### 6. Master data re-sync blocked when sync already running
expected: Long-press the sync area while a regular sync is actively running. A toast appears saying "Sinkronisasi sedang berjalan, coba lagi nanti" and the re-sync sheet does NOT open.
result: pass

### 7. Retry UI on initial sync failure
expected: If initial sync fails (e.g., turn off WiFi mid-sync), the progress sheet shows a retry message and automatically retries. After 3 failures, a red "Batalkan & Keluar" (Cancel & Log Out) button appears.
result: pass

### 8. Cancel and log out clears session
expected: After the cancel button appears (test 7), tapping it signs you out and returns to the login screen. On next login, initial sync will run again.
result: issue
reported: "non-initial tables(customer,pipeline etc) are still loaded, clicking sync once for the previous issues loads everything, but initial sync doesnt sync main tables"
severity: major

### 9. Initial sync flag resets on logout
expected: After logging out and logging back in, the initial sync progress sheet appears again (fresh sync). The flag was reset on logout so re-login triggers a fresh sync.
result: pass

## Summary

total: 9
passed: 6
issues: 3
pending: 0
skipped: 0

## Gaps

- truth: "Initial sync progress sheet populates tables without coordinator rejection"
  status: failed
  reason: "User reported: sync.coordinator | Rejected SyncType.masterDataResync sync (initial sync not complete), none of the tables get populated"
  severity: major
  test: 2
  root_cause: "markInitialSyncComplete() is called in login_screen.dart AFTER SyncProgressSheet.show() returns, but Phases 2 and 3 run INSIDE the sheet BEFORE it returns. The coordinator gate at sync_coordinator.dart:121 rejects non-initial sync types when _initialSyncComplete is false. Phase 2 uses SyncType.masterDataResync and Phase 3 uses SyncType.manual — both rejected."
  artifacts:
    - path: "lib/presentation/screens/auth/login_screen.dart"
      issue: "markInitialSyncComplete() called after sheet returns (line 54) — too late"
    - path: "lib/presentation/widgets/sync/sync_progress_sheet.dart"
      issue: "Phase 2/3 execute inside sheet before flag is set (lines 159-205)"
    - path: "lib/data/services/sync_coordinator.dart"
      issue: "Gate at line 121 rejects non-initial types when _initialSyncComplete is false"
  missing:
    - "Move markInitialSyncComplete() into SyncProgressSheet after Phase 1 succeeds but before Phase 2 starts"
  debug_session: ".planning/debug/sync-progress-phase2-3-rejected.md"

- truth: "After initial sync continue, home screen shows populated data"
  status: failed
  reason: "User reported: continue works, but none of the data is populated"
  severity: major
  test: 3
  root_cause: "Same root cause as test 2 — Phase 2 (delta sync for main tables) was silently rejected by coordinator, so no customer/pipeline/activity data was pulled"
  artifacts:
    - path: "lib/presentation/widgets/sync/sync_progress_sheet.dart"
      issue: "Phase 2/3 errors caught and logged but don't fail the overall sync — sheet returns success"
  missing:
    - "Fix test 2 root cause; Phase 2/3 will then populate tables"
  debug_session: ".planning/debug/sync-progress-phase2-3-rejected.md"

- truth: "Initial sync populates main tables (customer, pipeline, etc.) not just master data"
  status: failed
  reason: "User reported: non-initial tables(customer,pipeline etc) are still loaded, clicking sync once for the previous issues loads everything, but initial sync doesnt sync main tables"
  severity: major
  test: 8
  root_cause: "Same root cause as test 2 — initial sync Phase 2/3 rejected. Manual sync works because markInitialSyncComplete() was eventually called after the sheet returned, so subsequent manual syncs pass the gate."
  artifacts:
    - path: "lib/presentation/screens/auth/login_screen.dart"
      issue: "markInitialSyncComplete() sets the flag after sheet — manual sync then works"
    - path: "lib/presentation/screens/home/home_screen.dart"
      issue: "Same pattern — backup sync check also calls markInitialSyncComplete() too late"
  missing:
    - "Fix test 2 root cause — single fix resolves all 3 gaps"
  debug_session: ".planning/debug/sync-progress-phase2-3-rejected.md"
