---
phase: 01-foundation-observability
plan: 02
subsystem: observability
tags: [sentry, crash-reporting, flutter, error-tracking]

# Dependency graph
requires: []
provides:
  - Sentry crash reporting SDK integrated into app lifecycle
  - User context (id, email) attached to Sentry events on login
  - SENTRY_DSN loaded from .env via EnvConfig
affects: [03-structured-logging, production-debugging, error-monitoring]

# Tech tracking
tech-stack:
  added: [sentry_flutter ^9.13.0]
  patterns: [SentryFlutter.init appRunner pattern, beforeSend gating, scope user context]

key-files:
  created: []
  modified:
    - pubspec.yaml
    - .env
    - lib/config/env/env_config.dart
    - lib/main.dart
    - lib/presentation/providers/auth_providers.dart

key-decisions:
  - "Used appRunner pattern so widget tree errors are captured by Sentry"
  - "Set tracesSampleRate to 0.2 (20%) to keep performance overhead low"
  - "beforeSend drops events in dev mode when no DSN configured to prevent noise"
  - "SENTRY_DSN is optional -- empty string silently disables Sentry"

patterns-established:
  - "SentryFlutter.init wraps the entire app including Supabase init via appRunner callback"
  - "Sentry user context set on login, cleared on logout in LoginNotifier"
  - "Environment-specific config loaded from .env via EnvConfig singleton getters"

# Metrics
duration: 3min
completed: 2026-02-13
---

# Phase 1 Plan 2: Sentry Crash Reporting Summary

**Sentry Flutter SDK integrated with appRunner pattern, user context on login/logout, and DSN loaded from .env**

## Performance

- **Duration:** 3 min
- **Started:** 2026-02-13T06:26:23Z
- **Completed:** 2026-02-13T06:29:57Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Sentry Flutter SDK added and wired to capture unhandled exceptions across the entire app lifecycle
- User context (id, email) automatically attached to crash reports on login and cleared on logout
- DSN configuration loaded from .env with safe fallback (empty string disables Sentry silently)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add sentry_flutter dependency and configure DSN loading** - `aa013cc` (chore)
2. **Task 2: Wire SentryFlutter.init into main.dart and add user context in auth flow** - `f0165a9` (feat)

## Files Created/Modified
- `pubspec.yaml` - Added sentry_flutter ^9.13.0 dependency under Observability section
- `.env` - Added SENTRY_DSN= placeholder with comment linking to Sentry dashboard
- `lib/config/env/env_config.dart` - Added sentryDsn getter (returns empty string if not set)
- `lib/main.dart` - Rewrote to wrap app in SentryFlutter.init with appRunner, beforeSend gating, and environment tagging
- `lib/presentation/providers/auth_providers.dart` - Added Sentry.configureScope to set user on login and clear on logout

## Decisions Made
- Used `appRunner` pattern (not `init` + `runApp` separately) so widget tree construction errors are captured
- Set `tracesSampleRate: 0.2` (20%) to balance observability with performance overhead
- `beforeSend` drops all events in debug mode when no DSN is configured, preventing noisy local dev
- SENTRY_DSN is intentionally NOT validated in EnvConfig.validate() -- it's optional, and Sentry silently no-ops when DSN is empty

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

**External services require manual configuration.** To enable Sentry crash reporting:
1. Create a Sentry project for Flutter at https://sentry.io -> Create Project -> Flutter
2. Copy the DSN from Sentry Dashboard -> Settings -> Projects -> [project] -> Client Keys (DSN)
3. Set `SENTRY_DSN=<your-dsn>` in the `.env` file
4. The app works without Sentry configured (empty DSN silently disables it)

## Next Phase Readiness
- Sentry integration complete, ready for structured logging (Plan 03)
- Production crash reporting will be active once SENTRY_DSN is configured in .env
- User context pattern established for future enrichment (e.g., adding role, branch info)

## Self-Check: PASSED

All files exist, all commits verified, all content patterns confirmed.

---
*Phase: 01-foundation-observability*
*Completed: 2026-02-13*
