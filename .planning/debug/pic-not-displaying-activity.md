---
status: diagnosed
trigger: "Activity detail PIC contact actions don't show + Activity edit form has no PIC options in dropdown"
created: 2026-02-19T00:00:00Z
updated: 2026-02-19T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED - Issue 1 caused by keyPersonId never being persisted. Issue 2 CANNOT reproduce from code - edit mode key person dropdown should work.
test: Full code trace of both issues
expecting: Confirmed root causes
next_action: Return diagnosis

## Symptoms

expected: 1) Activity detail shows PIC name with phone/email action buttons. 2) Activity edit form shows PIC dropdown with options.
actual: 1) PIC row does not appear at all. 2) No PIC options in edit form dropdown.
errors: None (silent failures)
reproduction: 1) Open any activity detail for an activity with key person selected. 2) Edit any activity.
started: Since implementation

## Eliminated

(none needed)

## Evidence

- timestamp: 2026-02-19
  checked: createActivity() in activity_repository_impl.dart lines 196-213
  found: ActivitiesCompanion.insert OMITS keyPersonId field. dto.keyPersonId exists but is never written to the companion.
  implication: ROOT CAUSE #1 - keyPersonId is never saved to local DB when creating scheduled activities

- timestamp: 2026-02-19
  checked: createImmediateActivity() lines 256-280
  found: Same omission - no keyPersonId in companion
  implication: Immediate activities also lose keyPersonId

- timestamp: 2026-02-19
  checked: rescheduleActivity() lines 493-511
  found: New rescheduled activity companion omits keyPersonId: Value(existing.keyPersonId)
  implication: Rescheduled activities lose keyPersonId even if original had it

- timestamp: 2026-02-19
  checked: syncFromRemote() lines 801-840
  found: ActivitiesCompanion from remote data omits keyPersonId: Value(data['key_person_id'] as String?)
  implication: Even if remote DB has key_person_id, pull sync doesn't populate it locally

- timestamp: 2026-02-19
  checked: _createSyncPayload() lines 1295-1311
  found: No 'key_person_id' field in payload
  implication: Create sync payload doesn't include keyPersonId

- timestamp: 2026-02-19
  checked: _createImmediateSyncPayload() lines 1319-1342
  found: No 'key_person_id' field
  implication: Immediate activity sync payload missing keyPersonId

- timestamp: 2026-02-19
  checked: _createUpdateSyncPayload() lines 1346-1375
  found: No 'key_person_id' field
  implication: Update sync payload also missing keyPersonId

- timestamp: 2026-02-19
  checked: _mapToActivity() lines 1167-1170
  found: keyPersonName resolved from _keyPersonNameCache[data.keyPersonId] - since keyPersonId is always null in DB, keyPersonName is always null
  implication: Guard condition `if (activity.keyPersonName != null)` on line 131 of detail screen always fails

- timestamp: 2026-02-19
  checked: _PicListTile widget lines 928-991
  found: Widget code is correct - shows phone/email buttons when keyPerson has phone/email via keyPersonByIdProvider
  implication: Widget would work correctly IF it were rendered (but it's not because keyPersonName is null)

- timestamp: 2026-02-19
  checked: Activity edit form _buildKeyPersonField conditions (lines 316-324)
  found: Edit mode path is `if (_isEditMode && !_fieldsLocked && _selectedObjectId != null)` - this SHOULD work because _applyActivityData sets _selectedObjectId from activity data
  implication: The key person field should render in edit mode

- timestamp: 2026-02-19
  checked: _applyActivityData lines 107-137
  found: Sets _selectedObjectType and _selectedObjectId from activity data, and _selectedKeyPersonId from activity.keyPersonId
  implication: All state variables are set. BUT since keyPersonId was never persisted (root cause #1), activity.keyPersonId is null, so _selectedKeyPersonId stays null

- timestamp: 2026-02-19
  checked: _buildCustomerKeyPersonField lines 755-801
  found: Uses customerKeyPersonsProvider(objectId) which calls watchKeyPersonsByCustomer. This correctly filters by customerId, ownerType='CUSTOMER', deletedAt.isNull()
  implication: If key persons exist for the customer, they should appear in the dropdown. The dropdown SHOULD have options.

- timestamp: 2026-02-19
  checked: Edit mode form rendering conditions at lines 322-324
  found: Key person field renders if _isEditMode && !_fieldsLocked && _selectedObjectId != null. _selectedObjectId is set in _applyActivityData from activity.customerId/hvcId/brokerId.
  implication: The dropdown field SHOULD appear AND have options (if key persons exist for that entity)

## Resolution

root_cause: |
  ISSUE 1 (Activity Detail PIC not showing): CONFIRMED ROOT CAUSE
  ================================================================
  The `keyPersonId` field is NEVER written to the local activities table. There are 7 omission points
  in `activity_repository_impl.dart`:

  1. `createActivity()` (line ~196) - ActivitiesCompanion.insert omits `keyPersonId: Value(dto.keyPersonId)`
  2. `createImmediateActivity()` (line ~256) - Same omission
  3. `rescheduleActivity()` (line ~493) - New companion omits `keyPersonId: Value(existing.keyPersonId)`
  4. `syncFromRemote()` (line ~801) - Remote-to-local mapping omits `keyPersonId: Value(data['key_person_id'])`
  5. `_createSyncPayload()` (line ~1295) - Missing `'key_person_id': dto.keyPersonId`
  6. `_createImmediateSyncPayload()` (line ~1319) - Missing `'key_person_id': dto.keyPersonId`
  7. `_createUpdateSyncPayload()` (line ~1346) - Missing `'key_person_id': data.keyPersonId`

  Because keyPersonId is never stored, `_mapToActivity()` finds `data.keyPersonId == null`,
  so `keyPersonName` is never resolved. The guard `if (activity.keyPersonName != null)` on
  line 131 of activity_detail_screen.dart always evaluates to false, so _PicListTile never renders.

  ISSUE 2 (Activity Edit Form no PIC options): LIKELY SECONDARY EFFECT
  ================================================================
  The edit form key person dropdown code is actually correct. The rendering condition at line 322-324
  should work: `_isEditMode && !_fieldsLocked && _selectedObjectId != null`.

  `_applyActivityData` correctly sets `_selectedObjectId` from the activity's customerId/hvcId/brokerId,
  and `_selectedObjectType` is set correctly. The provider chain
  (customerKeyPersonsProvider/brokerKeyPersonsProvider/hvcKeyPersonsProvider) correctly fetches
  key persons for the given entity.

  However, there are two possible sub-issues:
  a) The previously selected key person ID won't be pre-selected in the dropdown because
     `activity.keyPersonId` is null (due to root cause #1), so `_selectedKeyPersonId` stays null.
  b) If the user is testing with an entity that genuinely has no key persons in the local DB,
     the dropdown will show "Belum ada key person untuk customer ini" (no key persons message).

  The most likely explanation for "no pic options": the user may be observing that NO key person
  is pre-selected (because keyPersonId was never saved), interpreting this as "no options".
  OR the test entity genuinely has no key persons.

fix: (not applied - diagnosis only)
verification: (not applied)
files_changed: []
