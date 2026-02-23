---
phase: 07-offline-ux-polish
plan: 03
subsystem: presentation
tags: [dashboard-staleness, sync-queue-filter, entity-navigation]

# Dependency graph
requires:
  - phase: 07-offline-ux-polish (plan 01)
    provides: lastSyncTimestampProvider, formatLastSync utility
  - phase: 07-offline-ux-polish (plan 02)
    provides: Card badges with tap-to-navigate to /home/sync-queue?entityId=xxx
provides:
  - Dashboard staleness display with 1-hour amber threshold
  - Sync queue screen entity ID filtering via constructor parameter
  - Route-level entityId query parameter parsing
  - Complete navigation flow: card badge tap -> filtered sync queue
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dashboard staleness indicator using lastSyncTimestampProvider + formatLastSync"
    - "Entity ID filter on sync queue screen via constructor parameter + client-side list filtering"
    - "GoRouter query parameter parsing for entity-specific navigation"

key-files:
  created: []
  modified:
    - lib/presentation/screens/home/tabs/dashboard_tab.dart
    - lib/presentation/screens/sync/sync_queue_screen.dart
    - lib/config/routes/app_router.dart

key-decisions:
  - "Staleness indicator placed in dashboard welcome card only (not in shell app bar)"
  - "1-hour threshold for amber/orange staleness warning"
  - "Entity filtering applied client-side after status filter (gagal/semua) composes with entity filter"
  - "AppBar shows 'Sinkronisasi (filtered)' title when entityId is set"
  - "'Lihat Semua' TextButton in AppBar actions clears filter by navigating to /home/sync-queue without query param"

patterns-established:
  - "Dashboard-level sync staleness display with configurable threshold"
  - "Entity-filtered sync queue via query parameter forwarding"

requirements-completed: [UX-03, UX-04]

# Metrics
completed: 2026-02-19
---

# Phase 07 Plan 03: Dashboard Staleness Display + Sync Queue Entity Filtering Summary

**Added last-synced timestamp to dashboard welcome card with 1-hour amber staleness warning, and enabled entity-filtered sync queue navigation from card badges**

## Accomplishments

### Dashboard Staleness Display
- Added imports for sync_providers.dart and format_last_sync.dart to dashboard_tab.dart
- Watch lastSyncTimestampProvider in build method
- Added staleness indicator below welcome text in Card with:
  - Icon (Icons.sync, 14px) + text from formatLastSync()
  - Grey color when sync is recent (< 1 hour)
  - Amber/orange (Colors.orange.shade700) when sync is stale (> 1 hour)
  - "Belum pernah sinkronisasi" when no sync has occurred
  - Loading/error states return SizedBox.shrink()

### Sync Queue Entity Filtering
- SyncQueueScreen constructor now accepts optional `entityId` parameter
- Added go_router import for context.push navigation
- Items filtered client-side: `items.where((item) => item.entityId == widget.entityId)` applied after status filter
- AppBar title changes to "Sinkronisasi (filtered)" when entityId is set
- "Lihat Semua" TextButton appears in AppBar actions when filtered, navigates to `/home/sync-queue` (no query param)

### Route Configuration
- app_router.dart sync-queue route builder updated to parse `state.uri.queryParameters['entityId']`
- entityId passed to SyncQueueScreen constructor
- ResponsiveShell wrapping preserved

## Full Navigation Flow
1. Entity card shows failed/dead letter sync badge (Plan 02)
2. User taps badge -> GestureDetector calls `context.push('/home/sync-queue?entityId=$entityId')`
3. GoRouter parses entityId query parameter, passes to SyncQueueScreen
4. SyncQueueScreen filters items to only that entity's queue entries
5. User sees "Lihat Semua" button to view all queue items

## Deviations from Plan
None.

## Issues Encountered
None.

## Verification
- `flutter analyze` passes with 0 errors (267 pre-existing infos/warnings)

## Self-Check: PASSED

---
*Phase: 07-offline-ux-polish*
*Completed: 2026-02-19*
