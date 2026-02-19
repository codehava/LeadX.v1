---
phase: 08-stubbed-feature-completion
plan: 03
subsystem: activity
tags: [activity-edit, crud, offline-sync, form, gorouter]

# Dependency graph
requires:
  - phase: 02-sync-engine-core
    provides: sync queue and offline-first write pattern
  - phase: 03-error-classification-recovery
    provides: Result type and mapException for repository error handling
provides:
  - ActivityUpdateDto for partial activity updates
  - updateActivity repository method with sync queue integration
  - Activity edit route /home/activities/:id/edit
  - ActivityFormScreen edit mode with field locking
affects: [08-stubbed-feature-completion]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Edit mode via optional activityId parameter on form screen"
    - "Field locking for completed activities (notes/summary only)"
    - "Object type/association always locked in edit mode"

key-files:
  created: []
  modified:
    - lib/data/dtos/activity_dtos.dart
    - lib/data/dtos/activity_dtos.freezed.dart
    - lib/domain/repositories/activity_repository.dart
    - lib/data/repositories/activity_repository_impl.dart
    - lib/presentation/providers/activity_providers.dart
    - lib/config/routes/route_names.dart
    - lib/config/routes/app_router.dart
    - lib/presentation/screens/activity/activity_form_screen.dart
    - lib/presentation/screens/activity/activity_detail_screen.dart

key-decisions:
  - "ActivityUpdateDto uses all optional fields for partial updates -- object type/ID and isImmediate intentionally omitted (locked in edit mode)"
  - "Completed activities only allow editing summary and notes -- all other fields locked via _fieldsLocked getter"
  - "Object type/association always shown as read-only card in edit mode with lock icon"
  - "Edit form pre-fills data via addPostFrameCallback + listenManual pattern for async stream data loading"

patterns-established:
  - "Edit mode pattern: optional entityId parameter, _isEditMode getter, _dataLoaded flag to prevent overwrites"
  - "Field locking pattern: _fieldsLocked getter combining edit mode + completed status for conditional disabling"

requirements-completed: [FEAT-04]

# Metrics
duration: 11min
completed: 2026-02-19
---

# Phase 08 Plan 03: Activity Edit Summary

**Full activity edit flow with ActivityUpdateDto, updateActivity repository method, edit route, pre-filled form, and field locking for completed activities**

## Performance

- **Duration:** 11 min
- **Started:** 2026-02-19T05:01:26Z
- **Completed:** 2026-02-19T05:12:19Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- Created ActivityUpdateDto with optional fields for partial activity updates
- Implemented updateActivity in repository with transaction, audit log (EDITED), and sync queue (SyncOperation.update)
- Added edit route /home/activities/:id/edit with GoRouter subroute under :id
- Modified ActivityFormScreen to support edit mode with pre-filled fields, object locking, and completed-activity field restrictions
- Wired edit button on activity detail screen to navigate to edit route

## Task Commits

Each task was committed atomically:

1. **Task 1: Create ActivityUpdateDto and add updateActivity to repository layer** - `0fa03d3` (feat)
2. **Task 2: Add edit route and modify ActivityFormScreen for edit mode** - `d6b05ff` (feat)

## Files Created/Modified
- `lib/data/dtos/activity_dtos.dart` - Added ActivityUpdateDto freezed class with optional fields
- `lib/data/dtos/activity_dtos.freezed.dart` - Generated freezed code for ActivityUpdateDto
- `lib/domain/repositories/activity_repository.dart` - Added updateActivity method signature
- `lib/data/repositories/activity_repository_impl.dart` - Implemented updateActivity with transaction, audit log, sync queue
- `lib/presentation/providers/activity_providers.dart` - Added updateActivity to ActivityFormNotifier
- `lib/config/routes/route_names.dart` - Added activityEdit route name and path
- `lib/config/routes/app_router.dart` - Added edit subroute under activities/:id
- `lib/presentation/screens/activity/activity_form_screen.dart` - Full edit mode support with field locking
- `lib/presentation/screens/activity/activity_detail_screen.dart` - Wired edit button navigation

## Decisions Made
- ActivityUpdateDto uses all optional fields for partial updates -- object type/ID and isImmediate intentionally omitted (locked in edit mode per plan decision)
- Completed activities only allow editing summary and notes -- all other fields disabled via conditional null check on ChoiceChip onSelected and ListTile onTap
- Object type/association always shown as read-only card in edit mode with lock icon indicator
- Edit form loads activity data via addPostFrameCallback + listenManual pattern for async stream data, with _dataLoaded flag preventing overwrites on rebuilds
- Split submit handler into _submitEditForm (builds ActivityUpdateDto, calls updateActivity) and _submitCreateForm (existing create logic) for clarity

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Activity edit flow complete end-to-end: detail screen edit button -> edit form -> updateActivity -> sync queue
- Pre-existing errors in sync_providers.dart (from other parallel work) logged to deferred-items.md -- not introduced by this plan

## Self-Check: PASSED

- All 8 key files verified present on disk
- Both task commits (0fa03d3, d6b05ff) verified in git log
- ActivityUpdateDto class generated in freezed output
- updateActivity method present in repository interface, implementation, and notifier
- activityEdit route present in route_names.dart and app_router.dart
- activityId parameter present in ActivityFormScreen
- Edit button navigation wired in activity_detail_screen.dart

---
*Phase: 08-stubbed-feature-completion*
*Completed: 2026-02-19*
