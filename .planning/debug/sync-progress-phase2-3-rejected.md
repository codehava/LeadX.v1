---
status: diagnosed
trigger: "SyncProgressSheet Phase 2/3 rejected by SyncCoordinator with 'initial sync not complete'"
created: 2026-02-19T00:00:00Z
updated: 2026-02-19T00:00:00Z
---

## Current Focus

hypothesis: markInitialSyncComplete() is called AFTER SyncProgressSheet.show() returns, but Phase 2 and Phase 3 run INSIDE the sheet -- so they execute BEFORE the flag is set
test: Trace the exact call sequence from login_screen.dart through sync_progress_sheet.dart
expecting: Phase 2/3 attempt acquireLock with non-initial SyncType while _initialSyncComplete is still false
next_action: Return diagnosis

## Symptoms

expected: Phase 2 (performDeltaSync) and Phase 3 (triggerSync) should succeed during initial sync flow
actual: Both are rejected with "Rejected SyncType.masterDataResync sync (initial sync not complete)" and "Rejected SyncType.manual sync (initial sync not complete)"
errors: Log message: "Rejected {type} sync (initial sync not complete)"
reproduction: Login -> SyncProgressSheet shown -> Phase 1 succeeds -> Phase 2 rejected -> Phase 3 rejected -> Sheet returns success -> markInitialSyncComplete called (too late)
started: Since SyncCoordinator was introduced with the initial sync gating logic

## Eliminated

(none needed -- root cause found on first hypothesis)

## Evidence

- timestamp: 2026-02-19T00:00:00Z
  checked: login_screen.dart lines 51-54
  found: markInitialSyncComplete() is called AFTER SyncProgressSheet.show() returns true
  implication: The flag is set too late -- Phase 2/3 already ran inside the sheet

- timestamp: 2026-02-19T00:00:00Z
  checked: sync_progress_sheet.dart lines 127-217 (_performSingleSyncAttempt)
  found: Phase 1 calls performInitialSync (SyncType.initial -- passes gate). Phase 1 releases lock in its finally block (line 234 of initial_sync_service.dart). Phase 2 calls performDeltaSync (SyncType.masterDataResync -- blocked by gate). Phase 3 calls triggerSync (SyncType.manual -- blocked by gate).
  implication: Phase 2 and 3 use non-initial SyncTypes but _initialSyncComplete is still false

- timestamp: 2026-02-19T00:00:00Z
  checked: sync_coordinator.dart lines 120-126
  found: Gate logic: `if (!_initialSyncComplete && type != SyncType.initial) { return false; }` -- any non-initial type is rejected when flag is false
  implication: This is the exact gate that rejects Phase 2 and Phase 3

- timestamp: 2026-02-19T00:00:00Z
  checked: initial_sync_service.dart lines 963-968 (performDeltaSync)
  found: performDeltaSync acquires lock with SyncType.masterDataResync -- this is NOT SyncType.initial
  implication: Even though delta sync is part of the initial sync flow, it uses a different SyncType that gets gated

- timestamp: 2026-02-19T00:00:00Z
  checked: sync_providers.dart line 211 (triggerSync)
  found: triggerSync acquires lock with SyncType.manual -- this is also NOT SyncType.initial
  implication: Phase 3 is also gated by the initial sync check

- timestamp: 2026-02-19T00:00:00Z
  checked: initial_sync_service.dart line 234 (finally block of performInitialSync)
  found: `_coordinator?.releaseLock()` -- Phase 1 releases the lock when it completes
  implication: Phase 2 tries to acquire a NEW lock (masterDataResync), which hits the gate check since _initialSyncComplete is still false

## Resolution

root_cause: The SyncProgressSheet runs 3 phases sequentially inside _performSingleSyncAttempt(). Phase 1 (performInitialSync) acquires the lock as SyncType.initial and releases it in its finally block. Phase 2 (performDeltaSync) then tries to acquire a NEW lock as SyncType.masterDataResync, and Phase 3 (triggerSync) tries SyncType.manual. Both Phase 2 and 3 are rejected by the gate at sync_coordinator.dart:121 (`if (!_initialSyncComplete && type != SyncType.initial)`) because markInitialSyncComplete() is only called AFTER SyncProgressSheet.show() returns in login_screen.dart:54 -- long after Phases 2 and 3 have already tried and failed.

fix: (not yet applied)
verification: (not yet verified)
files_changed: []
