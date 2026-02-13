---
status: diagnosed
trigger: "the server time and current device time is different for activity after syncing, local time(id) is 9 but server time is 4 am tomorrow"
created: 2026-02-13T00:00:00Z
updated: 2026-02-13T00:00:00Z
symptoms_prefilled: true
goal: find_root_cause_only
---

## Current Focus

hypothesis: CONFIRMED - Local DateTimes serialized via .toIso8601String() omit timezone info; Supabase (UTC) interprets them as UTC, causing a +7h forward shift
test: Traced full serialization chain from DateTime.now() through sync payloads to Supabase TIMESTAMPTZ columns
expecting: Confirmed the exact mechanism
next_action: Return diagnosis

## Symptoms

expected: Activity timestamps on server should match local device time (e.g., 9 PM WIB = 2 PM UTC)
actual: Local time shows 9 PM, server shows 4 AM next day (9 PM + 7h = 4 AM, confirms UTC+7 offset applied twice)
errors: No crash errors - data integrity issue
reproduction: Create/update activity with timestamp in non-UTC timezone, sync to server, compare
started: Pre-existing issue (present since initial sync implementation)

## Eliminated

- hypothesis: Double UTC conversion
  evidence: Not double-converting; rather, timezone info is simply missing from the serialized string, causing Supabase to misinterpret local time as UTC
  timestamp: 2026-02-13

## Evidence

- timestamp: 2026-02-13
  checked: Supabase activities table schema (current_schema.sql lines 1120-1153)
  found: ALL timestamp columns are `timestamp with time zone` (TIMESTAMPTZ) - scheduled_datetime, executed_at, created_at, updated_at, cancelled_at, deleted_at, last_sync_at
  implication: PostgreSQL expects timezone-aware input; without timezone info it falls back to session timezone (UTC on Supabase)

- timestamp: 2026-02-13
  checked: Dart DateTime.now().toIso8601String() behavior
  found: DateTime.now() creates a LOCAL DateTime. .toIso8601String() on local DateTime produces NO timezone indicator (e.g., "2026-02-13T21:00:00.000" - no Z, no +07:00). Only UTC DateTimes get the Z suffix.
  implication: All sync payloads send timestamps without timezone info

- timestamp: 2026-02-13
  checked: Supabase PostgreSQL timezone configuration
  found: Supabase defaults to UTC timezone. When receiving a timestamp string without timezone info into a TIMESTAMPTZ column, PostgreSQL interprets it as UTC.
  implication: "2026-02-13T21:00:00.000" (meant as 9 PM WIB) is stored as "2026-02-13T21:00:00+00" (9 PM UTC = 4 AM next day WIB)

- timestamp: 2026-02-13
  checked: All sync payload methods in activity_repository_impl.dart
  found: _createSyncPayload (line 1227), _createImmediateSyncPayload (line 1251), _createUpdateSyncPayload (line 1282), _createRescheduleSyncPayload (line 1314), cancelActivity inline payload (line 541) - ALL use .toIso8601String() on local DateTimes WITHOUT .toUtc()
  implication: Every activity sync operation has this bug

- timestamp: 2026-02-13
  checked: admin_user_remote_data_source.dart for comparison
  found: Uses .toUtc().toIso8601String() correctly (5 occurrences on lines 121, 144, 152, 188, 197)
  implication: The correct pattern exists in the codebase but was not applied to repository sync payloads

- timestamp: 2026-02-13
  checked: All repository sync payloads across the codebase
  found: 86 occurrences of .toIso8601String() across 9 repository files, ZERO use .toUtc().toIso8601String()
  implication: This is a systemic issue affecting ALL entity types, not just activities

- timestamp: 2026-02-13
  checked: Drift DateTime storage (default mode)
  found: No build.yaml found, so Drift uses default Unix timestamp storage (INTEGER). When reading back, Drift returns local DateTime objects (non-UTC). So data.scheduledDatetime from DB is also local.
  implication: Even the _createUpdateSyncPayload which reads from DB produces local timestamps without timezone info

- timestamp: 2026-02-13
  checked: Sync service soft-delete code (sync_service.dart line 263)
  found: Also uses DateTime.now().toIso8601String() without .toUtc() for deleted_at
  implication: Even the sync service itself has this issue

- timestamp: 2026-02-13
  checked: Math verification against user report
  found: User reports local=9, server=4 AM next day. If local is 9 PM WIB (UTC+7): 9 PM local sent as "21:00" without TZ -> Supabase stores as 21:00 UTC -> displayed as 04:00+07 next day (21+7=28=04 next day). The +7h shift matches EXACTLY.
  implication: Root cause confirmed with mathematical proof

## Resolution

root_cause: |
  DateTime.now().toIso8601String() produces local timestamps WITHOUT timezone offset info
  (e.g., "2026-02-13T21:00:00.000" instead of "2026-02-13T21:00:00.000Z" or "2026-02-13T21:00:00.000+07:00").
  Supabase PostgreSQL (configured to UTC) interprets these timezone-less strings as UTC.
  For a user in UTC+7, this means all timestamps are shifted forward by 7 hours on the server.

  This is a SYSTEMIC issue across ALL 9 repository files (86 occurrences) and the sync service (1 occurrence).
  The correct pattern (.toUtc().toIso8601String()) exists in admin_user_remote_data_source.dart but was not used elsewhere.

fix: |
  Change all .toIso8601String() calls in sync payloads to .toUtc().toIso8601String().
  This ensures timestamps include the "Z" suffix, so PostgreSQL correctly interprets them as UTC.

  Files to fix:
  - lib/data/repositories/activity_repository_impl.dart (22 occurrences)
  - lib/data/repositories/customer_repository_impl.dart (10 occurrences)
  - lib/data/repositories/pipeline_repository_impl.dart (9 occurrences)
  - lib/data/repositories/pipeline_referral_repository_impl.dart (12 occurrences)
  - lib/data/repositories/cadence_repository_impl.dart (16 occurrences)
  - lib/data/repositories/hvc_repository_impl.dart (6 occurrences)
  - lib/data/repositories/broker_repository_impl.dart (4 occurrences)
  - lib/data/repositories/admin_4dx_repository_impl.dart (4 occurrences)
  - lib/data/repositories/auth_repository_impl.dart (3 occurrences)
  - lib/data/services/sync_service.dart (1 occurrence, line 263)

  Additionally, consider adding a helper function to centralize this:
  ```dart
  String toUtcIso8601(DateTime dt) => dt.toUtc().toIso8601String();
  ```

verification:
files_changed: []
