---
status: complete
phase: 02-sync-engine-core
source: [02-01-SUMMARY.md, 02-02-SUMMARY.md, 02-03-SUMMARY.md]
started: 2026-02-13
updated: 2026-02-13
---

## Current Test

[testing complete]

## Tests

### 1. App compiles without errors
expected: `flutter analyze` completes with zero errors. No new warnings introduced by Phase 2 changes.
result: pass

### 2. Create customer works with transaction wrapping
expected: Creating a new customer from the app succeeds — customer appears in list, data is saved locally. The Drift transaction wrapping should be invisible to the user (same behavior as before, just crash-safe now).
result: issue
reported: "issues with several of the dropdowns in forms not being put into the form after clicking"
severity: major

### 3. Edit customer immediately after creation
expected: Create a customer, then immediately edit it (change name or phone). Both operations complete successfully. The sync queue coalesces the create+update into a single create with the updated payload (no duplicate or lost data).
result: issue
reported: "same problem as before — dropdowns in forms not populating after clicking"
severity: major

### 4. Manual sync triggers immediately
expected: Tapping the sync button triggers sync immediately (no 500ms delay). The sync completes and shows results. This tests that SyncNotifier bypasses the debounce for user-initiated sync.
result: [pending]

### 5. Rapid successive operations don't cause errors
expected: Quickly create 3-4 activities or customers in succession. All operations complete without errors. The debounce batches the sync triggers into fewer sync executions (you may notice sync fires once after a brief pause rather than after each individual save).
result: [pending]

### 6. Sync pulls data successfully (incremental timestamps)
expected: After a manual sync completes, trigger another sync. The second sync should complete noticeably faster than the first (it only fetches records updated since the last pull). No data is missing after the second sync.
result: issue
reported: "the server time and current device time is different for activity after syncing, local time(id) is 9 but server time is 4 am tomorrow"
severity: major

## Summary

total: 6
passed: 3
issues: 3
pending: 0
skipped: 0

## Gaps

- truth: "Creating a new customer from the app succeeds with dropdowns populating correctly in forms"
  status: failed
  reason: "User reported: issues with several of the dropdowns in forms not being put into the form after clicking"
  severity: major
  test: 2
  root_cause: ""
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Editing a customer immediately after creation works with dropdowns populating correctly"
  status: failed
  reason: "User reported: same problem as before — dropdowns in forms not populating after clicking"
  severity: major
  test: 3
  root_cause: ""
  artifacts: []
  missing: []
  debug_session: ""

- truth: "Activity timestamps are consistent between local device and server after syncing"
  status: failed
  reason: "User reported: the server time and current device time is different for activity after syncing, local time(id) is 9 but server time is 4 am tomorrow"
  severity: major
  test: 6
  root_cause: ""
  artifacts: []
  missing: []
  debug_session: ""
