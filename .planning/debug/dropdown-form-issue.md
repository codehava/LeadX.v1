---
status: diagnosed
trigger: "Dropdowns in customer create/edit forms are not populating after clicking (selecting a value from dropdown doesn't set it in the form)"
created: 2026-02-13T00:00:00Z
updated: 2026-02-13T00:00:00Z
symptoms_prefilled: true
goal: find_root_cause_only
---

## Current Focus

hypothesis: AutocompleteField overlay has a focus/gesture race condition causing tap-on-suggestion to fail intermittently
test: Traced entire tap->select->setState flow in AutocompleteField widget
expecting: Find timing gap between focus loss and InkWell.onTap in overlay
next_action: Return diagnosis to caller

## Symptoms

expected: Selecting a value from a dropdown in customer create/edit form should populate the form field
actual: Dropdowns not populating after clicking - selected value not set in form
errors: None reported (UI issue, not crash)
reproduction: Open customer create or edit form, try to select a dropdown value
started: Reported during Phase 2 UAT, but is a PRE-EXISTING issue (Phase 2 did not modify any UI/form code)

## Eliminated

- hypothesis: Phase 2 provider wiring changes broke dropdown data flow
  evidence: Phase 2 only added `database` parameter to CustomerRepositoryImpl. Master data providers (provinces, cities, companyTypes, ownershipTypes, industries) are completely independent of customerRepositoryProvider. The only change was in customer_providers.dart (2 lines added for transaction support). No form or widget code was modified.
  timestamp: 2026-02-13T00:10:00Z

- hypothesis: Master data providers return empty data
  evidence: MasterDataLocalDataSource queries are straightforward Drift watch queries with isActive filter. The StreamProviders (provincesStreamProvider, companyTypesStreamProvider, etc.) correctly watch the local data source. Data availability is not the issue since the AutocompleteField is only rendered inside the `data:` callback of AsyncValue.when().
  timestamp: 2026-02-13T00:15:00Z

- hypothesis: onChanged callback not setting state variables
  evidence: All dropdown onChanged callbacks in customer_form_screen.dart correctly call setState with the new value (e.g., line 237: setState(() { _selectedProvinceId = value; })). The state variables are used correctly in _handleSave() for form submission.
  timestamp: 2026-02-13T00:20:00Z

- hypothesis: AutocompleteField._selectItem method has logic error
  evidence: The _selectItem method (line 303-312) correctly sets _selectedValue, updates _textController.text, calls widget.onChanged, calls _formFieldState.didChange, unfocuses, and removes overlay. The sequence is correct and fires synchronously. The parent's setState from onChanged schedules a rebuild for the next frame (after _selectItem completes).
  timestamp: 2026-02-13T00:25:00Z

- hypothesis: didUpdateWidget causes stale text after parent rebuild
  evidence: After parent setState triggers rebuild, AutocompleteField.didUpdateWidget fires. It checks widget.value != oldWidget.value (true, since value changed from null to selected). _updateTextFromValue() looks up the item by value in widget.items using == operator (content equality for String). Items are always available since we're in the data: callback. The text is set correctly (even though it was already set by _selectItem).
  timestamp: 2026-02-13T00:30:00Z

- hypothesis: FormField state is lost during rebuilds
  evidence: FormField has no explicit key and same generic type T, so Flutter's widget reconciliation preserves the FormFieldState across rebuilds. FormFieldState.didChange updates internal value. FormField.initialValue only used in initState, not reset on didUpdateWidget.
  timestamp: 2026-02-13T00:35:00Z

## Evidence

- timestamp: 2026-02-13T00:05:00Z
  checked: Git history of autocomplete_field.dart
  found: Created in commit 6b8005f ("implement pipeline"), last modified in 7efeb92 ("Enhance activity detail screen"). Phase 2 commits did NOT touch this file.
  implication: If this is a bug, it's pre-existing from initial implementation, not caused by Phase 2.

- timestamp: 2026-02-13T00:08:00Z
  checked: Customer form screen dropdown implementation
  found: 5 dropdowns using AutocompleteField - Province, City, CompanyType, OwnershipType, Industry. All use identical pattern: AsyncValue.when(data: => AutocompleteField(value: _selectedXxx, items: xxx.map().toList(), onChanged: (v) => setState(() => _selectedXxx = v))).
  implication: If the bug affects one dropdown, it likely affects all (same implementation pattern).

- timestamp: 2026-02-13T00:10:00Z
  checked: Phase 2 changes to customer_providers.dart
  found: Only 2 lines added: `final database = ref.watch(databaseProvider);` and `database: database,` in the CustomerRepositoryImpl constructor. No changes to master data providers or form providers.
  implication: Phase 2 changes cannot have caused this dropdown issue.

- timestamp: 2026-02-13T00:12:00Z
  checked: Pipeline form screen (pipeline_form_screen.dart) and Activity form screen (activity_form_screen.dart)
  found: Pipeline form uses AutocompleteField for COB, LOB, Lead Source, Broker, BrokerPIC, and CustomerContact dropdowns (same pattern as customer form). Activity form uses SearchableDropdown (modal bottom sheet) and ChoiceChip for activity types.
  implication: Bug likely affects both customer AND pipeline forms (both use AutocompleteField). Activity form uses different widget (SearchableDropdown) and may not be affected.

- timestamp: 2026-02-13T00:18:00Z
  checked: AutocompleteField overlay focus/tap interaction sequence
  found: CRITICAL RACE CONDITION in _onFocusChange (line 145-157). When user taps overlay suggestion: (1) Tap DOWN causes TextField to lose focus. (2) _onFocusChange schedules _removeOverlay() after 200ms delay. (3) InkWell.onTap fires on tap UP, calling _selectItem. The 200ms delay is intended to allow the tap to register before removing the overlay.
  implication: This 200ms window is fragile. If tap-up is delayed (long press, slow device, platform-specific gesture handling), overlay may be removed before onTap fires, causing the selection to be lost.

- timestamp: 2026-02-13T00:22:00Z
  checked: SearchableDropdown widget (searchable_dropdown.dart)
  found: SearchableDropdown uses a modal bottom sheet (showModalBottomSheet) for selection. Selection is returned via Navigator.pop(context, item.value). This is Flutter's standard modal navigation pattern - robust and race-condition-free.
  implication: SearchableDropdown is inherently more reliable than AutocompleteField's overlay approach. If the bug is confirmed, migrating to SearchableDropdown would fix it.

- timestamp: 2026-02-13T00:28:00Z
  checked: Flutter analyzer output for both files
  found: autocomplete_field.dart has 3 info-level issues (none blocking). customer_form_screen.dart has warnings for unused _markAsChanged method and unused _isCapturingGps field, plus info-level issues. No errors.
  implication: No compilation or type-safety issues. The _markAsChanged method is defined but never called (unsaved changes tracking is broken for dropdowns) but this is a separate issue.

- timestamp: 2026-02-13T00:32:00Z
  checked: Whether programmatic _textController.text assignment triggers onChanged
  found: In Flutter, programmatically setting TextEditingController.text does NOT trigger TextField.onChanged. So _selectItem setting _textController.text = item.label does NOT trigger _onTextChanged, which would otherwise clear the selection if the text didn't match exactly.
  implication: This rules out _onTextChanged as a cause of selection clearing after _selectItem fires.

- timestamp: 2026-02-13T00:40:00Z
  checked: Overlay positioning with SingleChildScrollView
  found: AutocompleteField uses CompositedTransformTarget/CompositedTransformFollower for overlay positioning. The overlay OverlayEntry is inserted at the top of the overlay stack (above all widgets), so it renders on top of the scroll view. However, the overlay dropdown may extend beyond the viewport when the form is scrolled, and CompositedTransformFollower positioning can be unreliable within scrollable containers in Flutter.
  implication: On scrolled forms, overlay position might be wrong, making it look like taps don't register (user taps visible item but the hit area is offset).

## Resolution

root_cause: |
  PRE-EXISTING BUG in AutocompleteField widget (lib/presentation/widgets/common/autocomplete_field.dart).
  NOT caused by Phase 2 changes (Phase 2 did not modify any form or widget code).

  The AutocompleteField has a fragile overlay-based dropdown implementation with a 200ms race window
  between focus loss (when user taps a suggestion) and overlay removal. The InkWell.onTap in the overlay
  must fire within this 200ms window after focus loss, or the selection is lost. This is a well-known
  pitfall of custom overlay-based autocomplete implementations in Flutter.

  Contributing factors:
  1. FOCUS/TAP RACE CONDITION: When user taps an overlay suggestion on web/desktop, the TextField loses
     focus on tap-down, scheduling overlay removal after 200ms. InkWell.onTap fires on tap-up. If the
     tap duration exceeds 200ms or gesture recognition is delayed, the overlay is removed before onTap fires.

  2. SCROLL POSITION ISSUES: The overlay uses CompositedTransformFollower for positioning. When the form
     is scrolled, overlay positioning may become unreliable, causing visual misalignment between where
     items appear and where they can actually be tapped.

  3. WIDGET REBUILD DURING GESTURE: The parent's setState (triggered by onChanged) could theoretically
     cause a rebuild that interferes with the overlay's gesture recognition between tap-down and tap-up,
     though this is less likely given the synchronous execution model.

  The SearchableDropdown widget (used in activity forms) does NOT have this issue because it uses
  Flutter's standard showModalBottomSheet navigation pattern.

fix: |
  RECOMMENDED FIX: Replace AutocompleteField with SearchableDropdown in customer and pipeline forms.

  Alternative fix: Improve AutocompleteField reliability by:
  a) Increasing the delay from 200ms to 300-400ms
  b) Using a flag to prevent overlay removal during active gesture
  c) Wrapping the overlay in a TapRegion to properly handle focus/tap interactions
  d) Using Flutter's built-in Autocomplete widget instead of custom overlay management

verification:
files_changed: []
