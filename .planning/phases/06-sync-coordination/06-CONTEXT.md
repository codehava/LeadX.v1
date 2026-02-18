# Phase 6: Sync Coordination - Context

**Gathered:** 2026-02-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Prevent race conditions between initial sync and regular sync, serialize push/pull phases, and ensure single sync execution at a time. This phase replaces the simple `_isSyncing` boolean with a proper sync lock, adds request queuing (instead of silently dropping triggers), gates user operations during initial sync, and serializes push-then-pull execution.

Existing sync UI elements (SyncStatusBadge, SyncProgressIndicator, SyncProgressSheet) are enhanced minimally — major UX changes belong in Phase 7 (Offline UX Polish).

</domain>

<decisions>
## Implementation Decisions

### Initial sync gating
- Block user interaction entirely until initial sync completes — modal bottom sheet stays non-dismissable
- Resume from where it stopped on partial failure (track per-table progress) — current SyncProgressSheet partially supports this
- User writes are blocked entirely during initial sync (the modal prevents form access)
- Short cooldown (~5 seconds) after initial sync before regular sync triggers are accepted
- Initial sync gate also applies after schema migration if new sync tables were added — not just first-ever login
- Auto-retry with backoff on failure (2s/5s/15s intervals, 3 attempts)
- After 3 failed retries, show "Cancel and log out" button — user can try again later
- Cancel clears auth session; next login re-attempts initial sync

### Queued sync feedback
- Toast notification when sync triggers while another is running: "Sync already in progress — your request is queued"
- Existing SyncStatusBadge in app bar continues showing synced/pending/offline/deadLetter states as-is

### Failure during sync
- Coordination issues (lock contention, phase failures) are silent to user — logged to Talker only
- User only sees final sync outcome (synced/failed) through existing badge

### Claude's Discretion
- Whether push failure should skip pull (pull guards exist from Phase 4 to protect pending local data)
- Sync lock recovery mechanism (timeout-based vs startup cleanup vs both)
- Maximum queued sync depth (cap at 1 vs unlimited — likely cap at 1 to prevent runaway)
- Whether multiple queued requests collapse into one sync execution
- 'Queued' badge state on SyncStatusBadge vs relying on existing 'pending' state
- Whether to preserve or clear partial data on "Cancel and log out" (resume pattern suggests preserve)
- App kill during initial sync recovery strategy (resume vs fresh start — current SyncProgressSheet has resume support)
- Progress display detail level (current table names + counter vs simplified messaging)
- Manual vs background vs repository sync priority handling
- Whether sync lock tracks sync type (initial/manual/background) or is type-agnostic
- Background sync (push-only) behavior during initial sync
- Whether master data re-sync (long press) respects or bypasses sync lock

</decisions>

<specifics>
## Specific Ideas

- Current `_isSyncing` boolean in SyncService is the primary coordination mechanism — needs replacement with proper lock
- SyncProgressSheet already has per-table resume support via AppSettingsService — leverage this for resume-from-interruption
- Pull sync already has isPendingSync guards from Phase 4 — relevant for push-failure-then-pull decision
- Background sync is push-only (WorkManager) from Phase 5 — simpler coordination since it doesn't pull
- App bar SyncStatusBadge already shows pending/syncing state — minimal UI changes needed for coordination
- Debounce timer (500ms) and shared Completer pattern already batch rapid triggers — new lock layer sits above this

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-sync-coordination*
*Context gathered: 2026-02-18*
