---
phase: 01-foundation-observability
plan: 03
subsystem: logging
tags: [talker, sentry, logging, observability, riverpod-observer]

# Dependency graph
requires:
  - phase: 01-01
    provides: "Sync error hierarchy and schema standardization"
  - phase: 01-02
    provides: "Sentry crash reporting integration in main.dart"
provides:
  - "AppLogger singleton wrapping Talker with module-prefixed structured logging"
  - "SentryTalkerObserver forwarding errors/exceptions to Sentry"
  - "TalkerRiverpodObserver logging provider lifecycle events"
  - "Zero debugPrint calls in codebase (all replaced with structured logging)"
  - "Module prefix convention: 'module.sub | message' for searchable logs"
affects: [all-phases, debugging, production-monitoring]

# Tech tracking
tech-stack:
  added: [talker ^4.5.2, talker_flutter ^4.5.2, talker_riverpod_logger ^4.9.3]
  patterns: [module-prefixed-logging, singleton-logger, sentry-observer-forwarding]

key-files:
  created:
    - lib/core/logging/app_logger.dart
    - lib/core/logging/sentry_observer.dart
  modified:
    - lib/main.dart
    - pubspec.yaml
    - 26 files across data/services, data/repositories, data/datasources, presentation/providers, presentation/screens, presentation/widgets

key-decisions:
  - "Talker v4.x instead of v5.x due to dependency constraint conflicts with talker_riverpod_logger"
  - "Module prefix convention 'module.sub | message' with pipe separator for searchability"
  - "Log levels: debug (routine), info (state changes), warning (non-critical), error (exceptions)"
  - "Condensed verbose multi-line error patterns into single structured log calls"
  - "Removed unused logger package from dependencies"

patterns-established:
  - "Module prefixes: sync.queue, sync.push, sync.pull, auth, db, connectivity, gps, camera, customer, pipeline, pipeline.referral, activity, cadence, scoreboard, ui.sync, ui.home, ui.referral"
  - "Class files use 'final _log = AppLogger.instance;' field"
  - "Provider/static contexts use 'AppLogger.instance.method()' directly"
  - "foundation.dart import kept only for kIsWeb/kReleaseMode, removed when only used for debugPrint"

# Metrics
duration: 25min
completed: 2026-02-13
---

# Phase 01 Plan 03: Structured Logging Summary

**Talker structured logging with Sentry error forwarding replacing all 266+ debugPrint calls across 26 files using module-prefixed convention**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-02-13
- **Completed:** 2026-02-13
- **Tasks:** 2
- **Files modified:** 28 (2 created, 26 modified)

## Accomplishments

- Created AppLogger singleton wrapping Talker with module-prefixed logging helpers
- Created SentryTalkerObserver that forwards errors/exceptions to Sentry and adds warning+ logs as Sentry breadcrumbs
- Wired TalkerRiverpodObserver into ProviderScope for provider lifecycle logging
- Replaced all 266+ debugPrint calls across 26 files with structured Talker logging using appropriate log levels
- Removed unused `logger` package from dependencies
- Established module prefix convention for the entire codebase

## Task Commits

Each task was committed atomically:

1. **Task 1: Create AppLogger, SentryTalkerObserver, wire into app init** - `db5086d` (feat)
2. **Task 2: Replace all debugPrint calls with Talker logging across 26 files** - `081f1c1` (refactor)

## Files Created/Modified

### Created
- `lib/core/logging/app_logger.dart` - Singleton Talker wrapper with init() and instance getter
- `lib/core/logging/sentry_observer.dart` - TalkerObserver forwarding errors to Sentry

### Modified (Task 1)
- `pubspec.yaml` - Added talker ^4.5.2, talker_flutter ^4.5.2, talker_riverpod_logger ^4.9.3; removed logger
- `lib/main.dart` - AppLogger.init() before SentryFlutter.init(), TalkerRiverpodObserver in ProviderScope

### Modified (Task 2 - debugPrint replacements)
- `lib/data/services/sync_service.dart` - sync.queue, sync.push prefixes (13 calls)
- `lib/data/services/connectivity_service.dart` - connectivity prefix (8 calls)
- `lib/data/services/camera_service.dart` - camera prefix (5 calls)
- `lib/data/services/gps_service.dart` - gps prefix (4 calls)
- `lib/data/database/app_database.dart` - db prefix (1 call)
- `lib/data/repositories/activity_repository_impl.dart` - activity prefix (32 calls)
- `lib/data/repositories/auth_repository_impl.dart` - auth prefix (22 calls)
- `lib/data/repositories/customer_repository_impl.dart` - customer prefix (7 calls)
- `lib/data/repositories/pipeline_repository_impl.dart` - pipeline prefix (13 calls)
- `lib/data/repositories/pipeline_referral_repository_impl.dart` - pipeline.referral prefix (65 calls)
- `lib/data/repositories/scoreboard_repository_impl.dart` - scoreboard prefix (3 calls)
- `lib/data/repositories/cadence_repository_impl.dart` - cadence prefix (8 calls)
- `lib/data/datasources/remote/activity_remote_data_source.dart` - activity.remote prefix (4 calls)
- `lib/data/datasources/remote/customer_remote_data_source.dart` - customer.remote prefix (3 calls)
- `lib/data/datasources/remote/pipeline_referral_remote_data_source.dart` - pipeline.referral.remote prefix (1 call)
- `lib/presentation/providers/sync_providers.dart` - sync.queue, sync.pull prefixes (38 calls)
- `lib/presentation/providers/activity_providers.dart` - activity.photo prefix (13 calls)
- `lib/presentation/providers/pipeline_referral_providers.dart` - pipeline.referral prefix (6 calls)
- `lib/presentation/widgets/sync/sync_progress_sheet.dart` - ui.sync prefix (10 calls)
- `lib/presentation/screens/auth/splash_screen.dart` - auth prefix (6 calls)
- `lib/presentation/screens/auth/login_screen.dart` - auth prefix (4 calls)
- `lib/presentation/screens/auth/reset_password_screen.dart` - auth prefix (3 calls)
- `lib/presentation/screens/home/home_screen.dart` - ui.home prefix (3 calls)
- `lib/presentation/screens/cadence/host_dashboard_screen.dart` - cadence prefix (1 call)
- `lib/presentation/screens/cadence/cadence_list_screen.dart` - cadence prefix (1 call)
- `lib/presentation/screens/referral/referral_list_screen.dart` - ui.referral prefix (1 call)

## Decisions Made

1. **Talker v4.x instead of v5.x**: The talker_riverpod_logger package constrains talker to ^4.5.2, making v5.x incompatible. Used v4.5.2 across all three packages for consistency.
2. **Module prefix convention**: Adopted 'module.sub | message' format with pipe separator for easy grep filtering in production logs.
3. **Log level assignment**: Applied semantic log levels - debug for routine operations, info for significant state changes, warning for non-critical failures/fallbacks, error for actual exceptions.
4. **Condensed verbose error patterns**: Multi-line error output patterns (e.g., `=== ERROR ===`, `Error type:`, `Error:`, `StackTrace:`) were consolidated into single `_log.error()` calls for cleaner log output.
5. **Import strategy**: Removed `import 'package:flutter/foundation.dart';` from files only using debugPrint. Files using kIsWeb kept it with `show kIsWeb` directive.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Talker v5.x dependency conflict, downgraded to v4.x**
- **Found during:** Task 1
- **Issue:** Plan specified talker ^5.1.13 but talker_riverpod_logger constrains talker to ^4.5.2
- **Fix:** Used talker ^4.5.2, talker_flutter ^4.5.2, talker_riverpod_logger ^4.9.3
- **Files modified:** pubspec.yaml
- **Verification:** flutter pub get succeeds
- **Committed in:** db5086d

**2. [Rule 1 - Bug] Two missed debugPrint calls in cache invalidation methods**
- **Found during:** Task 2 (verification pass)
- **Issue:** pipeline_repository_impl.dart and pipeline_referral_repository_impl.dart each had one remaining debugPrint in invalidateCaches() method
- **Fix:** Replaced with _log.debug() calls using appropriate module prefixes
- **Files modified:** pipeline_repository_impl.dart, pipeline_referral_repository_impl.dart
- **Verification:** grep -r "debugPrint" lib/ returns 0 results
- **Committed in:** 081f1c1

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Deviation 1 required version adjustment but maintained identical functionality. Deviation 2 was a simple oversight caught by verification. No scope creep.

## Issues Encountered

- The plan specified Talker v5.x but dependency resolution required v4.x. The API difference is minimal (v4 uses `observer:` singular parameter vs v5's `observers:` list), resolved by adjusting the init call.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 1 (Foundation & Observability) is now complete with all 3 plans executed
- Structured logging provides production-ready observability for all sync operations
- Sentry integration captures errors automatically via TalkerObserver
- Ready for Phase 2 execution with full logging infrastructure in place

## Self-Check: PASSED

- FOUND: lib/core/logging/app_logger.dart
- FOUND: lib/core/logging/sentry_observer.dart
- FOUND: 01-03-SUMMARY.md
- FOUND: commit db5086d
- FOUND: commit 081f1c1

---
*Phase: 01-foundation-observability*
*Completed: 2026-02-13*
