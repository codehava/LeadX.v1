---
status: diagnosed
trigger: "Long-pressing sync area shows re-sync sheet instead of being blocked with toast when sync is already running"
created: 2026-02-18T00:00:00Z
updated: 2026-02-18T00:01:00Z
symptoms_prefilled: true
goal: find_root_cause_only
---

## Current Focus

hypothesis: CONFIRMED - syncService.isSyncing is always false during SyncNotifier-driven syncs because processQueue() returns early when coordinator lock is held, never setting _isSyncing=true
test: Traced code paths through all four files
expecting: n/a - root cause confirmed
next_action: Return diagnosis

## Symptoms

expected: When sync is in progress, long-pressing sync area shows toast "Sinkronisasi sedang berjalan, coba lagi nanti" and does NOT open re-sync sheet
actual: Long-pressing sync area shows "mempersiapkan" (preparing) - the sync sheet opens despite sync running
errors: No error messages - behavioral bug
reproduction: Start a sync, then long-press the sync area while sync is running
started: After Phase 6 plan 02 and 03 modifications to responsive_shell.dart

## Eliminated

- hypothesis: Guard code was overwritten by plan 03 changes
  evidence: The guard code IS present in the onLongPress handler at lines 306-318, it was not overwritten
  timestamp: 2026-02-18T00:00:30Z

- hypothesis: Timing issue where sync completes before long-press checks
  evidence: The problem is not timing - the _isSyncing flag is structurally never set to true during SyncNotifier-driven syncs
  timestamp: 2026-02-18T00:00:45Z

## Evidence

- timestamp: 2026-02-18T00:00:15Z
  checked: responsive_shell.dart onLongPress handler (lines 304-343)
  found: Guard checks ref.read(syncServiceProvider).isSyncing on line 307, does NOT check coordinator.isLocked
  implication: Guard relies solely on SyncService._isSyncing flag

- timestamp: 2026-02-18T00:00:20Z
  checked: responsive_shell.dart onTap handler (lines 258-303)
  found: onTap handler DOES check coordinator.isLocked (line 267) as a separate guard, and it works correctly
  implication: Plan 03 added coordinator check to onTap but onLongPress only got the SyncService.isSyncing check from plan 02

- timestamp: 2026-02-18T00:00:25Z
  checked: SyncNotifier.triggerSync() in sync_providers.dart (lines 201-256)
  found: Acquires coordinator lock at line 211 BEFORE calling _syncService.processQueue() at line 222
  implication: Coordinator is locked when processQueue is called

- timestamp: 2026-02-18T00:00:30Z
  checked: SyncService.processQueue() in sync_service.dart (lines 84-285)
  found: At line 91-102, when coordinator is available AND locked, returns EARLY without ever reaching line 147 where _isSyncing=true is set
  implication: _isSyncing is NEVER true during SyncNotifier-driven syncs because processQueue bails out at the coordinator lock check

- timestamp: 2026-02-18T00:00:35Z
  checked: SyncService._isSyncing lifecycle in sync_service.dart
  found: _isSyncing is set true at line 147 (after coordinator check) and false in finally block at line 283. The coordinator check at line 92 causes early return at line 101 before line 147.
  implication: The isSyncing getter always returns false when the coordinator lock is held (which is exactly when a manual/background sync is running via SyncNotifier)

- timestamp: 2026-02-18T00:00:40Z
  checked: SyncCoordinator.isLocked in sync_coordinator.dart (line 47)
  found: isLocked returns true when _activeSyncCompleter is not null - this is set when acquireLock succeeds
  implication: coordinator.isLocked IS the correct indicator of active sync, not syncService.isSyncing

## Resolution

root_cause: |
  TWO compounding bugs cause the re-sync guard to fail:

  BUG 1 (Primary): The onLongPress handler (responsive_shell.dart line 307) checks
  `syncService.isSyncing` but this flag is NEVER true during SyncNotifier-driven syncs.

  Mechanism: When SyncNotifier.triggerSync() runs, it first acquires the coordinator lock
  (sync_coordinator.dart), then calls syncService.processQueue(). Inside processQueue(),
  the first thing checked is coordinator.isLocked (sync_service.dart line 92). Since the
  lock was just acquired by SyncNotifier, processQueue() returns EARLY at line 101 without
  ever setting _isSyncing=true (line 147). Therefore syncService.isSyncing is always false
  when a manual sync is actively running.

  BUG 2 (Missing check): The onLongPress handler does NOT check coordinator.isLocked,
  while the onTap handler (line 267) DOES. Plan 02 added the isSyncing check to onLongPress.
  Plan 03 added the coordinator.isLocked check to onTap. Neither plan added the coordinator
  check to onLongPress, so the long-press path has an incomplete guard.

  Combined effect: The onLongPress guard checks a flag that is structurally always false
  during coordinator-managed syncs, and is missing the coordinator lock check that would
  actually work.

fix:
verification:
files_changed: []
