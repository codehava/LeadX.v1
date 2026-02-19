---
status: diagnosed
phase: 08-stubbed-feature-completion
source: [08-01-SUMMARY.md, 08-02-SUMMARY.md, 08-03-SUMMARY.md, 08-04-SUMMARY.md]
started: 2026-02-19T05:30:00Z
updated: 2026-02-19T06:10:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Customer delete confirmation dialog
expected: On customer detail screen, tap popup menu > "Hapus". Confirmation dialog appears with cascade warning in Indonesian mentioning key persons, pipelines, and activities will also be deleted.
result: pass

### 2. Customer delete execution and navigation
expected: After confirming delete, customer is removed. A success snackbar "Nasabah berhasil dihapus" appears. You are navigated to the customer list screen (not just one screen back).
result: pass

### 3. Customer detail phone/email tappable
expected: On customer detail info tab, phone number is displayed in primary color with underline. Tapping it opens phone dialer. Email address is similarly styled and tapping opens email client.
result: pass

### 4. Customer key person contact buttons
expected: On customer detail, key person cards show phone and email icon buttons. Tapping phone button opens dialer with that person's number. Tapping email button opens email client with that person's address. Email button only shows if key person has an email.
result: pass

### 5. HVC key person contact buttons
expected: On HVC detail screen, key person cards show phone and email icon buttons. Phone opens dialer. Email opens email client. Email button only appears if key person has email address.
result: pass

### 6. Activity PIC contact actions
expected: On activity detail screen, if the activity has a PIC (key person), phone and email action buttons appear next to the PIC name. Tapping phone opens dialer with PIC's number. Tapping email opens email client with PIC's address.
result: issue
reported: "in activity detail both broker pic and pic selected doesnt show"
severity: major

### 7. Broker detail contact actions
expected: On broker detail info tab, phone and email are tappable (primary color, underlined) and open dialer/email client. Broker key person cards have phone and email icon buttons that work the same way.
result: pass

### 8. Activity edit navigation and pre-fill
expected: On activity detail screen, tap the edit button in AppBar. Navigates to activity form screen. All fields are pre-filled with existing activity data (activity type, scheduled date/time, key person, summary, notes). Object type and association are shown but locked (not editable).
result: issue
reported: "no pic options"
severity: major

### 9. Activity edit save
expected: In activity edit form, change a field (e.g., notes or summary), tap save ("Simpan Perubahan"). Activity updates successfully, you return to detail screen with updated data visible.
result: pass

### 10. Activity edit field locking for completed activities
expected: Open a completed activity's edit form. All fields except summary and notes are disabled/locked. You can only edit summary and notes. Activity type, date/time, and key person controls are non-interactive.
result: pass

### 11. Notification settings navigation
expected: Go to Settings screen. Tap "Pengaturan Notifikasi" tile. Navigates to a notification settings screen (not a "coming soon" snackbar). AppBar shows "Pengaturan Notifikasi".
result: pass

### 12. Notification settings toggles and persistence
expected: Notification settings screen shows 3 sections: "Umum" (Push/Email toggles), "Kategori" (5 category toggles), "Waktu Pengingat" (reminder time dropdown). Toggle a switch off, navigate away, come back -- the switch remains off. Reminder time dropdown offers 5, 10, 15, 30, 60 minute options.
result: pass

## Summary

total: 12
passed: 10
issues: 2
pending: 0
skipped: 0

## Gaps

- truth: "Activity detail PIC section shows phone and email action buttons for the key person"
  status: failed
  reason: "User reported: in activity detail both broker pic and pic selected doesnt show"
  severity: major
  test: 6
  root_cause: "keyPersonId is never written to the local activities table — 7 omission points in activity_repository_impl.dart (createActivity, createImmediateActivity, rescheduleActivity, syncFromRemote, _createSyncPayload, _createImmediateSyncPayload, _createUpdateSyncPayload). Because keyPersonId is null, _mapToActivity cannot resolve keyPersonName, so _PicListTile guard condition fails and widget never renders."
  artifacts:
    - path: "lib/data/repositories/activity_repository_impl.dart"
      issue: "keyPersonId omitted from all ActivitiesCompanion constructions and sync payloads"
  missing:
    - "Add keyPersonId: Value(dto.keyPersonId) to createActivity and createImmediateActivity companions"
    - "Add keyPersonId: Value(existing.keyPersonId) to rescheduleActivity companion"
    - "Add keyPersonId: Value(data['key_person_id']) to syncFromRemote companion"
    - "Add 'key_person_id': dto.keyPersonId to create and immediate sync payloads"
    - "Add 'key_person_id': data.keyPersonId to update sync payload"
  debug_session: ".planning/debug/pic-not-displaying-activity.md"

- truth: "Activity edit form pre-fills key person (PIC) dropdown with options available for selection"
  status: failed
  reason: "User reported: no pic options"
  severity: major
  test: 8
  root_cause: "Secondary effect of Issue 1. Edit form code is correct but activity.keyPersonId is always null (never persisted), so _selectedKeyPersonId stays null and no pre-selection occurs. The dropdown itself may show options if key persons exist for the entity, but the previously-selected PIC cannot be highlighted."
  artifacts:
    - path: "lib/data/repositories/activity_repository_impl.dart"
      issue: "Same root cause as Issue 1 — keyPersonId never persisted"
  missing:
    - "Fix Issue 1 resolves this — keyPersonId will be persisted and pre-selected in edit mode"
  debug_session: ".planning/debug/pic-not-displaying-activity.md"
