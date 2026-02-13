# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-13)

**Core value:** Sales reps can reliably capture and access customer data in the field regardless of connectivity — data is never lost, always available, and syncs transparently when online.
**Current focus:** Phase 2 - Sync Engine Core

## Current Position

Phase: 2 of 10 (Sync Engine Core)
Plan: 1 of 3 (02-01 complete)
Status: Executing Phase 2
Last activity: 2026-02-13 — Completed 02-01 Sync queue coalescing and debounced triggers

Progress: [█░░░░░░░░░] ~13%

## Performance Metrics

**Velocity:**
- Total plans completed: 4
- Average duration: 11 min
- Total execution time: 0.73 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-foundation-observability | 3/3 | 41 min | 14 min |
| 02-sync-engine-core | 1/3 | 3 min | 3 min |

**Recent Trend:**
- Last 5 plans: 02-01 (3 min), 01-03 (25 min), 01-02 (3 min), 01-01 (13 min)
- Trend: Improving

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

### Pending Todos

None yet.

### Blockers/Concerns

None yet.

## Session Continuity

Last session: 2026-02-13
Stopped at: Completed 02-01-PLAN.md — Sync queue coalescing and debounced triggers
Resume file: None

---
*Last updated: 2026-02-13 (02-01 complete)*
