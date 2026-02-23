---
phase: 07-offline-ux-polish
plan: 01
subsystem: presentation
tags: [offline-banner, sync-providers, staleness, badge-colors]

# Dependency graph
requires:
  - phase: 06-sync-coordination
    provides: SyncCoordinator, sync queue data source, app settings service
provides:
  - Shell-level OfflineBanner covering all shell screens
  - syncQueueEntityStatusMapProvider batch provider for O(1) card badge lookups
  - lastSyncTimestampProvider using global max across all table_sync_at_* keys
  - formatLastSync shared utility for Indonesian-locale relative time
  - Corrected badge colors (failed=amber, deadLetter=red)
affects: [07-02, 07-03]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Shell-level OfflineBanner placement in ResponsiveShell for all layouts"
    - "Batch sync queue status map via single Drift stream with entity-keyed Map"
    - "SyncQueueEntityStatus enum with index-based priority (none < pending < failed < deadLetter)"

key-files:
  created:
    - lib/core/utils/format_last_sync.dart
  modified:
    - lib/presentation/widgets/shell/responsive_shell.dart
    - lib/presentation/screens/customer/customer_detail_screen.dart
    - lib/presentation/screens/activity/activity_detail_screen.dart
    - lib/presentation/screens/pipeline/pipeline_detail_screen.dart
    - lib/presentation/screens/home/tabs/activities_tab.dart
    - lib/presentation/screens/home/tabs/customers_tab.dart
    - lib/core/theme/app_colors.dart
    - lib/presentation/widgets/common/sync_status_badge.dart
    - lib/data/datasources/local/sync_queue_local_data_source.dart
    - lib/data/services/app_settings_service.dart
    - lib/presentation/providers/sync_providers.dart
    - lib/presentation/screens/profile/settings_screen.dart

key-decisions:
  - "OfflineBanner moved to shell level in ResponsiveShell, removed from 5 individual screens"
  - "Detail screens (customer, activity, pipeline) pushed over shell do NOT get OfflineBanner (acceptable per plan)"
  - "syncFailed color changed from red to amber/orange (0xFFFF8C00) since failed items will auto-retry"
  - "syncDeadLetter color is red (0xFFEF4444) since these need manual intervention"
  - "Global last sync computed as max DateTime across all table_sync_at_* keys in app settings"
  - "Batch status map uses highest-priority status per entity when multiple queue items exist"

patterns-established:
  - "Shell-level persistent banners via ResponsiveShell Column wrapper"
  - "Batch entity status lookup pattern: single StreamProvider producing Map<String, SyncQueueEntityStatus>"

requirements-completed: [UX-01, UX-02]

# Metrics
completed: 2026-02-19
---

# Phase 07 Plan 01: Shell-level OfflineBanner + Infrastructure Summary

**Moved OfflineBanner from 5 per-screen deployments to shell-level, created batch sync queue status provider, global last sync timestamp, shared format utility, and fixed badge color semantics**

## Accomplishments
- OfflineBanner added to all three ResponsiveShell layouts (mobile, tablet, desktop)
- OfflineBanner removed from customer_detail_screen, activity_detail_screen, pipeline_detail_screen, activities_tab, customers_tab
- Badge colors corrected: syncFailed = amber/orange (will retry), syncDeadLetter = red (needs manual action)
- sync_status_badge.dart updated to use AppColors.syncDeadLetter for dead letter state
- watchAllItems() stream method added to sync_queue_local_data_source.dart
- getGlobalLastSyncAt() method added to app_settings_service.dart
- formatLastSync shared utility created in lib/core/utils/format_last_sync.dart
- settings_screen.dart migrated from private _formatLastSync to shared formatLastSync
- SyncQueueEntityStatus enum added to sync_providers.dart
- syncQueueEntityStatusMapProvider StreamProvider created for batch card badge lookups
- lastSyncTimestampProvider updated to use getGlobalLastSyncAt()

## Deviations from Plan
None significant.

## Issues Encountered
- Removing Column/Expanded wrappers from detail screens required careful bracket nesting fixes
- pipeline_detail_screen.dart needed complete body section rewrite for proper indentation

## Self-Check: PASSED

---
*Phase: 07-offline-ux-polish*
*Completed: 2026-02-19*
