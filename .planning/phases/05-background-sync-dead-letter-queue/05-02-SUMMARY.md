---
phase: 05-background-sync-dead-letter-queue
plan: 02
subsystem: ui
tags: [flutter, riverpod, sync, dead-letter, i18n, offline-first]

# Dependency graph
requires:
  - phase: 05-background-sync-dead-letter-queue
    provides: "Dead letter status tracking, resetRetryCount, discardDeadLetterItem, deadLetterCountProvider, lastSyncTimestampProvider"
provides:
  - "Production-ready SyncQueueScreen with Indonesian labels and dead letter prominence"
  - "SyncErrorTranslator for mapping raw errors to user-friendly Indonesian messages"
  - "App bar dead letter warning state with navigation to sync queue"
  - "Settings Sinkronisasi badge count and last sync timestamp"
  - "SyncStatus.deadLetter enum variant"
affects: [05-background-sync-dead-letter-queue]

# Tech tracking
tech-stack:
  added: []
  patterns: [error-translation-pattern, dead-letter-ui-awareness]

key-files:
  created:
    - lib/core/utils/sync_error_translator.dart
  modified:
    - lib/presentation/screens/sync/sync_queue_screen.dart
    - lib/presentation/screens/profile/settings_screen.dart
    - lib/presentation/widgets/shell/responsive_shell.dart
    - lib/presentation/widgets/common/sync_status_badge.dart
    - lib/data/datasources/local/sync_queue_local_data_source.dart

key-decisions:
  - "SyncErrorTranslator uses contains-based pattern matching for error classification since errors come from SyncError.message strings"
  - "Max retries errors recursively translate the underlying error message for better user experience"
  - "Dead letter badge (red) takes priority over pending count badge (warning) in app bar"
  - "App bar tap navigates to sync queue when in dead letter state instead of triggering sync"
  - "Filter defaults to 'Gagal' view showing failed+dead_letter items since that is the primary user concern"

patterns-established:
  - "SyncErrorTranslator pattern: static translate() for error messages, entityTypeName() for entity display, operationName() for operation display"
  - "Dead letter awareness pattern: deadLetterCountProvider watched in shell + settings for cross-app awareness indicators"

requirements-completed: [CONF-02, SYNC-06]

# Metrics
duration: 6min
completed: 2026-02-18
---

# Phase 05 Plan 02: Dead Letter UI & User Awareness Summary

**Production dead letter UI with Indonesian error translation, settings badge + timestamp, and app bar warning state for sync queue awareness**

## Performance

- **Duration:** 6 min
- **Started:** 2026-02-18T06:15:04Z
- **Completed:** 2026-02-18T06:21:06Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- SyncQueueScreen evolved from debug to production UI with Gagal/Semua filter, Indonesian labels, retry/discard actions, and bulk retry
- SyncErrorTranslator maps raw sync errors to user-friendly Indonesian messages (auth, validation, network, timeout, conflict, server, foreign key)
- App bar sync button shows persistent warning state with red dead letter count badge, tapping navigates to sync queue
- Settings Sinkronisasi row shows red badge count and relative "Terakhir sinkronisasi: X menit lalu" timestamp

## Task Commits

Each task was committed atomically:

1. **Task 1: Create SyncErrorTranslator + evolve SyncQueueScreen** - `855dbba` (feat)
2. **Task 2: Settings badge + timestamp, app bar warning, SyncStatus.deadLetter** - `38e9d5b` (feat)

## Files Created/Modified
- `lib/core/utils/sync_error_translator.dart` - Maps raw error strings to Indonesian user messages, entity type names, operation names
- `lib/presentation/screens/sync/sync_queue_screen.dart` - Production dead letter UI with filter toggle, retry/discard, bulk retry, translated errors
- `lib/presentation/screens/profile/settings_screen.dart` - Badge count and last sync timestamp on Sinkronisasi ListTile
- `lib/presentation/widgets/shell/responsive_shell.dart` - Dead letter warning state in app bar sync button with navigation
- `lib/presentation/widgets/common/sync_status_badge.dart` - Added deadLetter variant to SyncStatus enum
- `lib/data/datasources/local/sync_queue_local_data_source.dart` - Added getFailedAndDeadLetterItems() for Gagal filter

## Decisions Made
- SyncErrorTranslator uses contains-based pattern matching since error strings come from SyncError.message
- Max retries errors recursively translate the underlying message for better UX
- Dead letter badge (red) takes priority over pending count badge (warning) in app bar
- App bar tap navigates to sync queue when in deadLetter state (not trigger sync)
- Filter defaults to 'Gagal' view since failed items are the primary user concern

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added getFailedAndDeadLetterItems() to sync queue data source**
- **Found during:** Task 1 (SyncQueueScreen rewrite)
- **Issue:** Plan specified "Gagal" filter showing failed+dead_letter items, but no query method existed for this combination
- **Fix:** Added getFailedAndDeadLetterItems() to SyncQueueLocalDataSource querying both statuses
- **Files modified:** lib/data/datasources/local/sync_queue_local_data_source.dart
- **Verification:** flutter analyze passes
- **Committed in:** 855dbba (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Essential for correctness of the Gagal filter view. No scope creep.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Dead letter UI complete with user awareness across app bar and settings
- Ready for Plan 03 (background sync timing + final integration)
- All SC5 retry semantics satisfied: resetRetryCount sets status to pending, isPendingSync implicitly true

## Self-Check: PASSED

- All 6 created/modified files verified present on disk
- Commits 855dbba and 38e9d5b verified in git log
- flutter analyze: 0 errors, 0 warnings (5 pre-existing info-level lints only)

---
*Phase: 05-background-sync-dead-letter-queue*
*Completed: 2026-02-18*
