---
status: diagnosed
trigger: "activity detail screen does not show PIC (key person) contact action buttons (phone/email)"
created: 2026-02-19T00:00:00Z
updated: 2026-02-19T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED - Multiple issues prevent PIC contact buttons from showing
test: Code trace through full data flow
expecting: Identify all gaps in keyPersonId/keyPersonName population
next_action: Return diagnosis

## Symptoms

expected: Activity detail shows PIC name with phone/email action buttons for broker PIC and customer PIC
actual: PIC row does not appear at all - neither name nor buttons
errors: None (silent failure - data simply not populated)
reproduction: Open any activity detail screen for an activity linked to a key person
started: Since implementation

## Eliminated

(none - root cause found on first pass)

## Evidence

- timestamp: 2026-02-19T00:00:00Z
  checked: _PicListTile widget in activity_detail_screen.dart (lines 928-991)
  found: Widget code is correct - it watches keyPersonByIdProvider when keyPersonId is present, shows phone/email buttons when data has phone/email
  implication: Widget rendering logic is not the problem

- timestamp: 2026-02-19T00:00:00Z
  checked: Guard condition for _PicListTile rendering (line 131)
  found: `if (activity.keyPersonName != null)` - PicListTile only renders when keyPersonName is non-null
  implication: If keyPersonName is null, the entire PIC section is invisible

- timestamp: 2026-02-19T00:00:00Z
  checked: _mapToActivity in activity_repository_impl.dart (lines 1167-1170)
  found: keyPersonName is resolved from _keyPersonNameCache using data.keyPersonId. BUT cache only includes key persons where deletedAt IS NULL (line 1083-1084)
  implication: If key person is soft-deleted, name won't resolve (minor edge case)

- timestamp: 2026-02-19T00:00:00Z
  checked: createActivity in activity_repository_impl.dart (lines 188-246)
  found: The ActivitiesCompanion.insert does NOT include keyPersonId from dto.keyPersonId. The DTO has keyPersonId field but it is never written to the local DB row.
  implication: ROOT CAUSE #1 - keyPersonId is never saved when creating an activity

- timestamp: 2026-02-19T00:00:00Z
  checked: createImmediateActivity in activity_repository_impl.dart (lines 249-313)
  found: Same issue - ActivitiesCompanion.insert does NOT include keyPersonId from dto.keyPersonId
  implication: ROOT CAUSE #1 also affects immediate activities

- timestamp: 2026-02-19T00:00:00Z
  checked: _createSyncPayload in activity_repository_impl.dart (lines 1290-1312)
  found: Sync payload does NOT include key_person_id field
  implication: Even if keyPersonId were saved locally, it would not sync to remote

- timestamp: 2026-02-19T00:00:00Z
  checked: _createImmediateSyncPayload (lines 1314-1343)
  found: Same - no key_person_id in sync payload
  implication: Immediate activities also don't sync keyPersonId

- timestamp: 2026-02-19T00:00:00Z
  checked: syncFromRemote (lines 790-848)
  found: The ActivitiesCompanion built from remote data does NOT include keyPersonId. Missing: `keyPersonId: Value(data['key_person_id'] as String?)`
  implication: ROOT CAUSE #2 - Even if remote has key_person_id, pull sync would not populate it locally

- timestamp: 2026-02-19T00:00:00Z
  checked: _createUpdateSyncPayload (lines 1345-1375)
  found: Does NOT include key_person_id in the update sync payload
  implication: Updates also lose keyPersonId during sync

- timestamp: 2026-02-19T00:00:00Z
  checked: ActivitySyncDto in activity_dtos.dart (lines 100-134)
  found: ActivitySyncDto does NOT include keyPersonId / key_person_id field
  implication: The sync DTO itself is incomplete

- timestamp: 2026-02-19T00:00:00Z
  checked: keyPersonByIdProvider in customer_providers.dart (lines 153-177)
  found: Provider exists and correctly calls ds.getKeyPersonById(id) which returns data including phone/email. No deletedAt filter on lookup.
  implication: Provider is fine - would work if keyPersonId were populated on the activity

- timestamp: 2026-02-19T00:00:00Z
  checked: rescheduleActivity (lines 491-511)
  found: New rescheduled activity companion does NOT carry forward keyPersonId from existing activity
  implication: Even if original had keyPersonId, rescheduled copy would lose it

## Resolution

root_cause: |
  The `keyPersonId` field is NEVER written to the local activities table when creating activities,
  and is also missing from all sync payloads. There are 5 omission points:

  1. `createActivity()` - ActivitiesCompanion.insert omits `keyPersonId: Value(dto.keyPersonId)`
  2. `createImmediateActivity()` - Same omission
  3. `rescheduleActivity()` - New companion omits `keyPersonId: Value(existing.keyPersonId)`
  4. `syncFromRemote()` - Remote-to-local mapping omits `keyPersonId: Value(data['key_person_id'])`
  5. `_createSyncPayload()` and `_createImmediateSyncPayload()` and `_createUpdateSyncPayload()` -
     All sync payloads omit `'key_person_id'`
  6. `ActivitySyncDto` - Missing the keyPersonId field definition

  Because keyPersonId is never stored on the activity row, `_mapToActivity()` finds `data.keyPersonId == null`,
  so `keyPersonName` is never resolved from the cache. The guard `if (activity.keyPersonName != null)` on
  line 131 of activity_detail_screen.dart evaluates to false, so _PicListTile never renders at all.

fix: (not applied - diagnosis only)
verification: (not applied)
files_changed: []
