---
status: investigating
trigger: "activity edit form shows no PIC (key person) options in dropdown"
created: 2026-02-19T00:00:00Z
updated: 2026-02-19T00:00:00Z
---

## Current Focus

hypothesis: In edit mode, the objectId (customer ID) is not available when the key person dropdown tries to load, resulting in no key persons being fetched.
test: Read activity_form_screen.dart to trace how objectId is set in edit vs create mode, and how key persons are loaded.
expecting: A code path where objectId is null or not yet set when key person provider is invoked during edit mode.
next_action: Read activity_form_screen.dart and activity_providers.dart

## Symptoms

expected: When editing an activity, the PIC (key person) dropdown should show key persons for the associated customer.
actual: PIC dropdown shows no options in edit mode.
errors: None reported (no crash, just empty dropdown).
reproduction: Open activity edit form for an existing activity.
started: After plan modified ActivityFormScreen to support edit mode.

## Eliminated

## Evidence

## Resolution

root_cause:
fix:
verification:
files_changed: []
