---
status: diagnosed
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
result: pass

### 5. Rapid successive operations don't cause errors
expected: Quickly create 3-4 activities or customers in succession. All operations complete without errors. The debounce batches the sync triggers into fewer sync executions (you may notice sync fires once after a brief pause rather than after each individual save).
result: pass

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
  root_cause: "PRE-EXISTING BUG — AutocompleteField widget has a 200ms race condition between focus loss and overlay removal. When user taps a suggestion, TextField loses focus on tap-down scheduling overlay removal, but InkWell.onTap must fire on tap-up within the 200ms window. Also affected by scroll position issues with CompositedTransformFollower. NOT caused by Phase 2 (no form/widget code was modified)."
  artifacts:
    - path: "lib/presentation/widgets/common/autocomplete_field.dart"
      issue: "200ms race window in _onFocusChange between focus loss and _removeOverlay"
    - path: "lib/presentation/screens/customer/customer_form_screen.dart"
      issue: "5 dropdowns using AutocompleteField all affected"
  missing:
    - "Replace AutocompleteField with SearchableDropdown (modal bottom sheet) or fix overlay focus/tap timing"
  debug_session: ".planning/debug/dropdown-form-issue.md"

- truth: "Editing a customer immediately after creation works with dropdowns populating correctly"
  status: failed
  reason: "User reported: same problem as before — dropdowns in forms not populating after clicking"
  severity: major
  test: 3
  root_cause: "Same root cause as Test 2 — AutocompleteField overlay race condition. Pre-existing bug."
  artifacts:
    - path: "lib/presentation/widgets/common/autocomplete_field.dart"
      issue: "Same 200ms race condition"
  missing:
    - "Same fix as Test 2"
  debug_session: ".planning/debug/dropdown-form-issue.md"

- truth: "Activity timestamps are consistent between local device and server after syncing"
  status: failed
  reason: "User reported: the server time and current device time is different for activity after syncing, local time(id) is 9 but server time is 4 am tomorrow"
  severity: major
  test: 6
  root_cause: "PRE-EXISTING BUG — DateTime.now().toIso8601String() on local (non-UTC) DateTime produces string WITHOUT timezone indicator (no Z, no +07:00). Supabase TIMESTAMPTZ columns interpret bare timestamps as UTC. Result: local 9 PM WIB (UTC+7) stored as 9 PM UTC = 4 AM WIB next day. 86 occurrences across 9 repository files, zero use .toUtc() before serialization. NOT caused by Phase 2 (payload serialization code was not modified)."
  artifacts:
    - path: "lib/data/repositories/activity_repository_impl.dart"
      issue: "22 occurrences of .toIso8601String() without .toUtc()"
    - path: "lib/data/repositories/customer_repository_impl.dart"
      issue: "10 occurrences"
    - path: "lib/data/repositories/pipeline_repository_impl.dart"
      issue: "9 occurrences"
    - path: "lib/data/repositories/pipeline_referral_repository_impl.dart"
      issue: "12 occurrences"
    - path: "lib/data/repositories/cadence_repository_impl.dart"
      issue: "16 occurrences"
    - path: "lib/data/repositories/hvc_repository_impl.dart"
      issue: "6 occurrences"
    - path: "lib/data/repositories/broker_repository_impl.dart"
      issue: "4 occurrences"
    - path: "lib/data/repositories/admin_4dx_repository_impl.dart"
      issue: "4 occurrences"
    - path: "lib/data/repositories/auth_repository_impl.dart"
      issue: "3 occurrences"
  missing:
    - "Replace all .toIso8601String() in sync payloads with .toUtc().toIso8601String()"
    - "Consider a centralized helper: String toUtcIso8601(DateTime dt) => dt.toUtc().toIso8601String()"
    - "Existing server data may need a one-time migration to correct shifted timestamps"
  debug_session: ".planning/debug/timezone-mismatch-issue.md"
