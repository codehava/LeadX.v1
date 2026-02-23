---
status: testing
phase: 01-foundation-observability
source: [01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md]
started: 2026-02-13T07:15:00Z
updated: 2026-02-13T07:15:00Z
---

## Current Test

number: 1
name: App builds and analyzes cleanly
expected: |
  Running `flutter analyze` completes with no errors. Running `dart run build_runner build --delete-conflicting-outputs` completes without errors. The codebase compiles cleanly after all Phase 1 changes (schema migration, sync errors, Sentry, Talker logging).
awaiting: user response

## Tests

### 1. App builds and analyzes cleanly
expected: Running `flutter analyze` completes with no errors. `dart run build_runner build --delete-conflicting-outputs` completes without errors.
result: [pending]

### 2. App launches without database migration crash
expected: After all Phase 1 changes (schema v9->v10), launching the app on a device/emulator with an existing database does not crash. The migration adds lastSyncAt columns and renames Activities.syncedAt transparently. Fresh installs also work.
result: [pending]

### 3. Console shows structured Talker logs on startup
expected: When launching the app, the debug console shows Talker-formatted logs with module prefixes like "auth |", "db |", "connectivity |" instead of raw debugPrint output. No `debugPrint` or `[SyncService]`-style bracket prefixes appear.
result: [pending]

### 4. Login flow completes successfully
expected: Logging in with valid credentials succeeds. The console shows "auth | Login success" style Talker log. No crashes from Sentry initialization or user context setting.
result: [pending]

### 5. Sync operations show module-prefixed logs
expected: After login, triggering a sync (automatic or manual) shows logs with "sync.queue |", "sync.push |", and/or "sync.pull |" prefixes in the debug console. Error logs (if any) show typed error classification rather than raw exception dumps.
result: [pending]

### 6. App works with empty SENTRY_DSN
expected: With SENTRY_DSN= (empty) in .env, the app launches and operates normally without any Sentry-related errors or warnings in the console. Sentry silently disables itself.
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0

## Gaps

[none yet]
