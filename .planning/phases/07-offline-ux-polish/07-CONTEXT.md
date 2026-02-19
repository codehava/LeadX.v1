# Phase 7: Offline UX Polish - Context

**Gathered:** 2026-02-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Make offline state and sync status transparent to users through persistent connectivity banners, sync status badges on entity cards, staleness indicators, and failed sync navigation. This phase extends existing infrastructure (OfflineBanner, SyncStatusBadge, ConnectivityService, dead letter tracking) to full coverage — no new sync/database work needed.

</domain>

<decisions>
## Implementation Decisions

### Sync Status Badges
- Only show badges for problem states (pending, failed, dead letter) — no badge means synced
- All syncable entity types get badges (Customer, Pipeline, Activity, HVC, Broker, Key Person, Cadence, Referral) — not just core three
- Badge position: top right corner of card header row (consistent with current Customer/Pipeline card placement)
- List cards only — detail screens do NOT show per-entity sync status (rely on OfflineBanner for connectivity info)
- Activity cards must migrate from raw sync icon to proper SyncStatusBadge component

### Staleness Display
- Single global "Last synced" timestamp (not per-entity-type) — use most recent sync across all tables
- Visual warning via color change when data is stale (amber/orange text after threshold)
- Staleness threshold: Claude's discretion (pick reasonable threshold for field rep usage patterns)
- Display location: Claude's discretion (dashboard header and/or list headers — pick based on where users need reassurance most)

### Offline Banner Scope
- Move OfflineBanner to the shell level (ResponsiveShell) so it covers all screens globally — remove per-screen deployments
- Keep current appearance: compact amber bar with "Offline - data may be stale" text
- Disappear instantly when connectivity restored — no "Back online" confirmation
- All actions remain enabled while offline — everything saves locally first, no disabling

### Failed Sync Visibility
- Entity cards show a failed badge when that entity has a failed/dead letter item in sync queue
- Two distinct badge appearances: amber/orange for "failed, will retry" (retry count < 5) vs red for "dead letter, needs manual action" (retry count >= 5)
- Tapping failed badge on card navigates to Sync Queue screen (filtered to that entity)
- Global dead letter count badge stays in Settings screen only — no additional badge locations (app bar, bottom nav)

### Claude's Discretion
- Exact staleness warning threshold (30 min, 1 hour, etc.)
- Where to place "Last synced" timestamp (dashboard header, list screen headers, or both)
- How to query per-entity sync queue status efficiently for card badges (e.g., StreamProvider, batch query, etc.)
- Whether to consolidate existing per-screen OfflineBanner imports during shell migration

</decisions>

<specifics>
## Specific Ideas

- User specified "on the shell, where it already is" for OfflineBanner — move to ResponsiveShell level for global coverage
- Existing SyncStatusBadge already has all 5 states (synced/pending/failed/offline/deadLetter) with semantic colors — extend usage, don't redesign
- Currently ~70-80% of infrastructure exists — phase is about extending and deploying existing components
- Indonesian language UI conventions already established ("Offline - data may be stale", "Terakhir sinkronisasi: X menit lalu")

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-offline-ux-polish*
*Context gathered: 2026-02-19*
