# Phase 5: Background Sync & Dead Letter Queue - Context

**Gathered:** 2026-02-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Sync persists across app restarts via WorkManager/BGTaskScheduler, failed items are pruned and surfaced to users, and queue doesn't grow indefinitely. This phase adds background sync execution, dead letter management, queue pruning, and user-facing sync health indicators.

Key existing infrastructure:
- `sync_queue_items` table already has `retryCount`, `lastError`, `createdAt`, `lastAttemptAt`
- Items with `retryCount >= 5` are silently abandoned today (no UI, no status change)
- Debug `SyncQueueScreen` already exists at `/home/sync-queue` with retry, clear completed, trigger sync
- Settings screen already has "Sinkronisasi" row linking to the sync queue screen
- `SyncProgressIndicator` in app bar shows sync/offline/error states
- `pendingSyncCountProvider` and `conflictCountProvider` streams exist
- 5-minute foreground background sync timer already runs while app is open

</domain>

<decisions>
## Implementation Decisions

### Dead letter UI
- Evolve the existing debug `SyncQueueScreen` into a production-ready screen (not a separate new screen)
- Keep full queue view capability but default to showing failed/dead letter items prominently
- UI language in Indonesian matching existing app conventions
- Empty state: friendly success message "Semua data tersinkronisasi" with checkmark icon (already exists in current screen)
- Show user-friendly translated error reasons per failed item (not raw exception text)
- Discard action: keep local data but clear isPendingSync (entity exists locally only, never synced to server)

### Claude's Discretion — Dead letter UI
- Screen placement (inside Settings vs dedicated sync status screen)
- Detail level per failed item (minimal vs detailed)
- Available actions (retry + discard, or also edit-then-retry)
- Bulk "Retry All" vs per-item only
- How to handle discard for entities that should not exist without server confirmation

### Background sync behavior
- Background sync is "nice to have" — reps typically leave app open or reopen regularly
- WorkManager (Android) / BGTaskScheduler (iOS) for processing queue when app is backgrounded/closed
- Toggle in Settings to enable/disable background sync (gives users battery control)

### Claude's Discretion — Background sync
- Periodic vs connectivity-triggered scheduling (pick based on platform capabilities and battery trade-offs)
- Notification strategy for background sync results (silent vs failure-only)

### Failure thresholds
- Keep 5 retry attempts as the dead letter threshold (current behavior)
- Pruning runs after each sync — clean up completed items older than retention period
- Dead letter items auto-expire after 30 days if user hasn't acted on them
- Non-retryable errors (auth, validation): immediate dead letter vs separate category is Claude's discretion

### Claude's Discretion — Failure thresholds
- Completed item retention period before pruning
- Whether sync_conflicts audit table is pruned with same schedule
- Retry count reset behavior when user manually retries a dead letter item
- Non-retryable error categorization (immediate dead letter vs distinct "requires action" status)

### User awareness
- Settings "Sinkronisasi" row: show red badge count when dead letter items exist
- Settings "Sinkronisasi" subtitle: show "Terakhir sinkronisasi: X menit lalu" timestamp
- App bar sync indicator: show persistent orange/red warning icon when dead letter items exist
- Tapping app bar warning icon navigates directly to the dead letter screen (no intermediate tooltip)

</decisions>

<specifics>
## Specific Ideas

- The existing `SyncQueueScreen` is a solid foundation — it already has card-based item display, status badges (PENDING/RETRY/FAILED), retry buttons, conflict count banner, and Indonesian empty state
- The `_buildSyncButton` in `responsive_shell.dart` already has sync status logic (offline/syncing/pending/synced) — extend with dead letter state
- `pendingSyncCountProvider` and `conflictCountProvider` patterns can be followed for a `deadLetterCountProvider`
- Error messages should be translated to Indonesian — currently raw exception text is shown in monospace

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-background-sync-dead-letter-queue*
*Context gathered: 2026-02-18*
