# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-13)

**Core value:** Sales reps can reliably capture and access customer data in the field regardless of connectivity — data is never lost, always available, and syncs transparently when online.
**Current focus:** Phase 2.1 - Pre-existing Bug Fixes (Timezone + Dropdown)

## Current Position

Phase: 2.1 of 10 (Pre-existing Bug Fixes) -- COMPLETE
Plan: 3 of 3 (02.1-03 complete)
Status: Phase 2.1 Complete
Last activity: 2026-02-13 — Completed 02.1-03 Dropdown race condition fix (AutocompleteField -> SearchableDropdown)

Progress: [██░░░░░░░░] ~20%

## Performance Metrics

**Velocity:**
- Total plans completed: 8
- Average duration: 9 min
- Total execution time: 1.2 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation-observability | 3/3 | 41 min | 14 min |
| 02-sync-engine-core | 3/3 | 19 min | 6 min |
| 02.1-pre-existing-bug-fixes | 2/3 | 9 min | 5 min |

**Recent Trend:**
- Last 5 plans: 02.1-01 (5 min), 02.1-03 (4 min), 02-03 (9 min), 02-02 (7 min), 02-01 (3 min)
- Trend: Stable/Fast

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- Focus on stability before new features — Unreliable sync/offline undermines all other value
- Complete stubbed features after stability — Features half-done create user confusion
- Keep last-write-wins conflict resolution for now — Full CRDT/merge is complex; last-write-wins sufficient for single-user-per-record
- Maintain offline-first pattern for all fixes — Every fix must preserve the write-local-first-sync-later contract
- Used appRunner pattern for Sentry so widget tree errors are captured (01-02)
- SENTRY_DSN is optional; empty string silently disables Sentry (01-02)
- tracesSampleRate 0.2 (20%) balances observability with performance (01-02)
- SyncError implements Exception for lint compliance while keeping sealed class (01-01)
- Activities.syncedAt renamed via ALTER TABLE RENAME COLUMN to preserve data (01-01)
- All syncable tables now have standardized isPendingSync + lastSyncAt + updatedAt (01-01)
- Talker v4.x instead of v5.x due to talker_riverpod_logger dependency constraints (01-03)
- Module prefix convention 'module.sub | message' with pipe separator for searchability (01-03)
- Log levels: debug (routine), info (state changes), warning (non-critical), error (exceptions) (01-03)
- Full payload replacement on create+update coalesce, not merge (02-01)
- SyncNotifier calls processQueue() directly to bypass debounce for manual sync (02-01)
- 500ms debounce window for triggerSync() balances responsiveness with batching (02-01)
- Dart 3 record pattern matching for coalescing rules (02-01)
- CustomerRepositoryImpl gets _database via constructor injection matching pipeline/activity pattern (02-02)
- Exception thrown inside transactions (not NotFoundFailure) to satisfy only_throw_errors lint (02-02)
- clearPrimaryForCustomer moved inside transaction for full atomicity (02-02)
- rescheduleActivity wrapped as 5th activity method since updateActivity doesn't exist (02-02)
- 30-second safety margin on since timestamps prevents missed records at cost of occasional duplicates (02-03)
- Per-entity timestamp keys use table names: customers, key_persons, pipelines, activities, hvcs, customer_hvc_links, brokers, cadence_meetings, pipeline_referrals (02-03)
- endMeeting wraps all participant score calculations + meeting end + all queue ops in single transaction (02-03)
- toUtcIso8601() extension method for natural call syntax matching .toIso8601String() pattern (02.1-01)
- Date-only fields use .toIso8601String().substring(0,10) to prevent UTC date-shift for UTC+ timezones (02.1-01)
- Direct widget swap from AutocompleteField to SearchableDropdown -- APIs compatible (same param names) (02.1-03)
- Modal titles in Indonesian matching existing UI conventions (Pilih Provinsi, Pilih COB, etc.) (02.1-03)
- All dropdown selection fields use SearchableDropdown with modal bottom sheet pattern (02.1-03)

### Roadmap Evolution

- Phase 2.1 inserted after Phase 2: Pre-existing Bug Fixes — Timezone Serialization + Dropdown Race Condition (URGENT) — discovered during Phase 2 UAT, both bugs pre-date Phase 2 changes

### Pending Todos

None yet.

### Blockers/Concerns

None yet.

## Session Continuity

Last session: 2026-02-13
Stopped at: Completed 02.1-01-PLAN.md — Timezone serialization fix (activity_providers Task 2 was missing)
Resume file: None

---
*Last updated: 2026-02-13 (02.1-01 complete, 02.1-01 SUMMARY created)*
