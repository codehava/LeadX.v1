# Phase 7: Offline UX Polish - Research

**Researched:** 2026-02-19
**Domain:** Flutter offline-first UI indicators (OfflineBanner, SyncStatusBadge, staleness, dead letter navigation)
**Confidence:** HIGH

## Summary

Phase 7 extends existing, well-tested infrastructure to full coverage across the app. The codebase already contains all foundational components: `OfflineBanner` widget watching `connectivityStreamProvider`, `SyncStatusBadge` with 5 states (synced/pending/failed/offline/deadLetter), `ConnectivityService` with polling and server reachability verification, dead letter tracking via `SyncQueueLocalDataSource`, and per-table sync timestamps in `AppSettingsService`. The gap is deployment coverage and a few missing data pathways.

The shell (`ResponsiveShell`) already has a sync button with dead letter awareness, pending count badge, and `SyncProgressIndicator` in the app bar. However, `OfflineBanner` is placed per-screen (only 5 screens) rather than at the shell level. Entity cards partially use `SyncStatusBadge` (Customer, Pipeline, HVC, Broker, Referral have badges for pending state), but none show failed/dead letter state. The Activity card uses a raw `Icons.sync` icon instead of `SyncStatusBadge`. The `lastSyncTimestampProvider` currently only checks the `customers` table rather than computing a global maximum. No "Last synced" display exists on the dashboard.

**Primary recommendation:** Move `OfflineBanner` to `ResponsiveShell.body`, add a `watchSyncQueueStatusForEntity()` Stream method to `SyncQueueLocalDataSource`, extend card badges to show failed/dead letter with tap-to-navigate, add a global `lastSyncTimestampProvider` that computes max across all table timestamps, and display staleness on the dashboard header.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Sync Status Badges
- Only show badges for problem states (pending, failed, dead letter) -- no badge means synced
- All syncable entity types get badges (Customer, Pipeline, Activity, HVC, Broker, Key Person, Cadence, Referral) -- not just core three
- Badge position: top right corner of card header row (consistent with current Customer/Pipeline card placement)
- List cards only -- detail screens do NOT show per-entity sync status (rely on OfflineBanner for connectivity info)
- Activity cards must migrate from raw sync icon to proper SyncStatusBadge component

#### Staleness Display
- Single global "Last synced" timestamp (not per-entity-type) -- use most recent sync across all tables
- Visual warning via color change when data is stale (amber/orange text after threshold)
- Staleness threshold: Claude's discretion (pick reasonable threshold for field rep usage patterns)
- Display location: Claude's discretion (dashboard header and/or list headers -- pick based on where users need reassurance most)

#### Offline Banner Scope
- Move OfflineBanner to the shell level (ResponsiveShell) so it covers all screens globally -- remove per-screen deployments
- Keep current appearance: compact amber bar with "Offline - data may be stale" text
- Disappear instantly when connectivity restored -- no "Back online" confirmation
- All actions remain enabled while offline -- everything saves locally first, no disabling

#### Failed Sync Visibility
- Entity cards show a failed badge when that entity has a failed/dead letter item in sync queue
- Two distinct badge appearances: amber/orange for "failed, will retry" (retry count < 5) vs red for "dead letter, needs manual action" (retry count >= 5)
- Tapping failed badge on card navigates to Sync Queue screen (filtered to that entity)
- Global dead letter count badge stays in Settings screen only -- no additional badge locations (app bar, bottom nav)

### Claude's Discretion
- Exact staleness warning threshold (30 min, 1 hour, etc.)
- Where to place "Last synced" timestamp (dashboard header, list screen headers, or both)
- How to query per-entity sync queue status efficiently for card badges (e.g., StreamProvider, batch query, etc.)
- Whether to consolidate existing per-screen OfflineBanner imports during shell migration

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| UX-01 | A persistent offline connectivity banner is visible at the top of every screen when the device is offline | `OfflineBanner` widget exists, watches `connectivityStreamProvider`. Currently placed per-screen in 5 locations. Move to `ResponsiveShell` body wrapper. Detail/form screens push over shell via `_rootNavigatorKey` and won't inherit shell banner -- this is acceptable per locked decision (detail screens rely on shell app bar sync button for connectivity info). |
| UX-02 | Sync status badges (pending/synced) appear on all entity cards in list views and at top of detail screens | `SyncStatusBadge` widget exists with 5 states. Already on Customer, Pipeline, HVC, Broker, Referral cards (pending-only). Missing from Activity card (uses raw icon) and Cadence MeetingCard. Key Person cards are embedded in detail screens (private `_KeyPersonCard` widgets) -- they are list-like tiles but within detail context. Per locked decision, detail screens do NOT show per-entity sync status. |
| UX-03 | Dashboard displays "Last synced: X minutes ago" timestamp sourced from AppSettings | `lastSyncTimestampProvider` exists but only checks `customers` table. Need to compute global max across all table sync timestamps. `_formatLastSync()` utility already exists in `settings_screen.dart` -- extract to shared utility. Display on dashboard welcome card area. |
| UX-04 | User can see failed sync items count as a badge and access a retry UI to retry or discard individual items | Dead letter count badge exists in Settings screen and app bar sync button. `SyncQueueScreen` exists with retry/discard actions, conflict count banner, translated error messages. Need: per-entity failed badge on cards with tap navigation to filtered sync queue, and a new `watchSyncQueueStatusForEntity()` stream method. |
</phase_requirements>

## Standard Stack

### Core (already in project)

| Library | Purpose | Relevance |
|---------|---------|-----------|
| `flutter_riverpod` | State management | All providers, StreamProviders for reactive UI |
| `drift` | Local SQLite database | `.watch()` streams for reactive badge updates |
| `connectivity_plus` | Network detection | `ConnectivityService` already wraps this |
| `go_router` | Navigation | Route to sync queue screen with query params |

### Supporting (already in project)

| Library | Purpose | Relevance |
|---------|---------|-----------|
| `supabase_flutter` | Backend client | Server reachability check in ConnectivityService |

### Alternatives Considered

None -- this phase uses existing infrastructure exclusively. No new dependencies needed.

## Architecture Patterns

### Existing Component Inventory

```
lib/presentation/widgets/common/
  offline_banner.dart          # OfflineBanner - watches connectivityStreamProvider
  sync_status_badge.dart       # SyncStatusBadge - 5 states with semantic colors

lib/presentation/widgets/shell/
  responsive_shell.dart        # Shell with app bar sync button, dead letter count

lib/presentation/widgets/cards/
  customer_card.dart           # Has SyncStatusBadge (pending only)
  pipeline_card.dart           # Has SyncStatusBadge (pending only)

lib/presentation/widgets/hvc/
  hvc_card.dart                # Has SyncStatusBadge (pending only)

lib/presentation/widgets/broker/
  broker_card.dart             # Has SyncStatusBadge (shows synced+pending)

lib/presentation/widgets/referral/
  referral_card.dart           # Has SyncStatusBadge (pending only)

lib/presentation/widgets/activity/
  activity_card.dart           # RAW Icons.sync icon -- needs migration

lib/presentation/screens/cadence/widgets/
  meeting_card.dart            # NO sync badge at all

lib/data/datasources/local/
  sync_queue_local_data_source.dart  # Dead letter + queue management
                                      # Has Future-based getPendingItemForEntity()
                                      # MISSING: Stream-based watch for per-entity status

lib/data/services/
  app_settings_service.dart    # Per-table sync timestamps (table_sync_at_*)
  connectivity_service.dart    # Stream<bool> with 30s polling

lib/presentation/providers/
  sync_providers.dart          # connectivityStreamProvider, deadLetterCountProvider,
                                # lastSyncTimestampProvider (customers only),
                                # pendingSyncCountProvider
```

### Pattern 1: Shell-Level OfflineBanner Placement

**What:** Wrap `widget.child` in `ResponsiveShell` with a `Column` containing `OfflineBanner` above the child content.

**Where it applies:** `_buildMobileLayout`, `_buildTabletLayout`, `_buildDesktopLayout` in `responsive_shell.dart`.

**Current mobile layout:**
```dart
Widget _buildMobileLayout(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(context),
    drawer: _buildDrawer(context),
    body: widget.child,  // <-- child is bare
    bottomNavigationBar: _buildBottomNav(context),
  );
}
```

**Target mobile layout:**
```dart
Widget _buildMobileLayout(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(context),
    drawer: _buildDrawer(context),
    body: Column(
      children: [
        const OfflineBanner(),
        Expanded(child: widget.child),
      ],
    ),
    bottomNavigationBar: _buildBottomNav(context),
  );
}
```

**Important:** Detail/form screens use `parentNavigatorKey: _rootNavigatorKey` which pushes them OVER the shell entirely. The OfflineBanner will NOT be visible on those screens. This is acceptable per the locked decision: all actions remain enabled offline, and those screens are transient (user navigates back to shell-wrapped screens). The app bar sync button (visible in shell) already provides connectivity awareness.

### Pattern 2: Per-Entity Sync Queue Status via Batch Stream

**What:** Instead of N individual queries per card, use a single batch stream that watches the entire sync queue and provides a map of entity statuses.

**Why batch:** The sync queue is small (typically 0-50 items). Watching the full table via one Drift stream and mapping to a `Map<String, SyncStatus>` in a provider is more efficient than per-entity watchers.

**Data flow:**
```
SyncQueueLocalDataSource.watchAllItemStatuses()
  -> Stream<List<SyncQueueItem>>
    -> Provider: syncQueueEntityStatusMapProvider
      -> Map<String, SyncQueueEntityStatus>  // keyed by entityId
        -> Card widgets lookup entity status from map
```

**SyncQueueEntityStatus model:**
```dart
enum SyncQueueEntityStatus {
  none,       // No queue entry (synced or never queued)
  pending,    // status == 'pending'
  failed,     // status == 'failed' (retryCount < 5)
  deadLetter, // status == 'dead_letter' (retryCount >= 5)
}
```

**Recommendation:** Add a `watchAllItems()` Stream method to `SyncQueueLocalDataSource` that returns `Stream<List<SyncQueueItem>>`, then create a `syncQueueEntityStatusMapProvider` that transforms this into a lookup map. Cards query the map by their entity ID for O(1) lookups with reactive updates.

### Pattern 3: Global Last Sync Timestamp

**What:** Compute the most recent sync timestamp across ALL table sync timestamps stored in `AppSettingsService`.

**Current:** `lastSyncTimestampProvider` only reads `table_sync_at_customers`.

**Target:** Read all `table_sync_at_*` keys and return the maximum DateTime.

**Implementation approach:** Add a `getGlobalLastSyncAt()` method to `AppSettingsService` that queries all settings with `table_sync_at_` prefix, parses dates, and returns the maximum. Use this in the provider.

**Table keys synced (from `_pullFromRemote`):**
- `table_sync_at_customers`
- `table_sync_at_key_persons`
- `table_sync_at_pipelines`
- `table_sync_at_activities`
- `table_sync_at_hvcs`
- `table_sync_at_customer_hvc_links`
- `table_sync_at_brokers`
- `table_sync_at_cadence_meetings`
- `table_sync_at_pipeline_referrals`

### Pattern 4: Badge Tap Navigation with Entity Filter

**What:** When user taps a failed/dead letter badge on a card, navigate to SyncQueueScreen with the entity ID as a query parameter so the screen can filter to show only that entity's queue items.

**Current route:** `/home/sync-queue` (no filtering).

**Target route:** `/home/sync-queue?entityId=<uuid>` or `/home/sync-queue?entityType=customer`.

**Implementation:** Add optional query parameter parsing to `SyncQueueScreen`, pass it through the route builder, and use it to filter the displayed items.

### Anti-Patterns to Avoid

- **Per-entity stream watchers:** Do NOT create individual `StreamProvider.family` for each entity's sync status. The sync queue is small enough for a single batch stream. N individual watchers would create N Drift queries.
- **Polling for badge updates:** Do NOT use `Timer.periodic` to refresh badges. Drift streams are reactive and will emit on any sync queue table change.
- **Invalidating Drift-backed providers:** Per CLAUDE.md, do NOT use `ref.invalidate()` for Drift-backed providers. The badge status provider should be a StreamProvider watching Drift.
- **Hiding the synced badge:** Per locked decision, "no badge means synced." Do NOT show a green checkmark badge -- show nothing.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Connectivity detection | Custom socket polling | `ConnectivityService` (already exists) | Already handles platform differences, server reachability, 30s polling |
| Relative time formatting | Custom date math | Extract `_formatLastSync()` from `settings_screen.dart` | Already handles Indonesian locale strings, edge cases |
| Sync status color mapping | Inline color logic per card | `SyncStatusBadge` widget (already exists) | 5-state switch with `AppColors.sync*` semantic colors |
| Dead letter classification | Custom retry count checks | `SyncQueueLocalDataSource` status field | `dead_letter` status already set by `SyncService` when retries exhausted |

**Key insight:** ~80% of the infrastructure exists. The work is wiring, not building.

## Common Pitfalls

### Pitfall 1: OfflineBanner Not Visible on Detail/Form Screens

**What goes wrong:** Moving OfflineBanner to ResponsiveShell means it disappears on screens that push over the shell (detail screens, form screens use `parentNavigatorKey: _rootNavigatorKey`).

**Why it happens:** GoRouter's `parentNavigatorKey` causes routes to push on the root navigator, above the shell.

**How to avoid:** Accept this as a design decision. The locked requirement says "detail screens do NOT show per-entity sync status" and "all actions remain enabled while offline." The shell app bar sync button already provides connectivity awareness for the shell-wrapped screens, and pushing screens inherit no shell. Users spend most time on list/dashboard screens within the shell.

**Warning signs:** User reports of "not seeing offline banner" -- verify they're on a shell-wrapped screen, not a detail/form screen pushed over the shell.

### Pitfall 2: N+1 Query Problem for Card Badges

**What goes wrong:** Each card individually queries the sync queue for its entity's status, causing O(N) database queries for a list of N cards.

**Why it happens:** Natural instinct to query per-entity status inline.

**How to avoid:** Use a single batch stream provider (`syncQueueEntityStatusMapProvider`) that watches the entire sync queue table and produces a `Map<String, SyncQueueEntityStatus>`. Cards do O(1) map lookups. The sync queue table is small (typically 0-50 items), so watching the full table is efficient.

**Warning signs:** Janky scrolling on entity list screens, excessive Drift query logging.

### Pitfall 3: Stale Badge After Sync Completes

**What goes wrong:** Sync completes successfully and removes queue items, but card badges don't update.

**Why it happens:** Using `FutureProvider` instead of `StreamProvider` for badge data, or not properly watching the Drift stream.

**How to avoid:** Ensure `syncQueueEntityStatusMapProvider` is a `StreamProvider` watching Drift's `.watch()` method. When sync service calls `markAsCompleted()` (which deletes queue items), Drift automatically emits new values to all watching streams, and badges disappear reactively.

**Warning signs:** Badges persist after manual sync button press.

### Pitfall 4: lastSyncTimestamp Not Updating Reactively

**What goes wrong:** Dashboard "Last synced" timestamp stays stale after sync completes.

**Why it happens:** `lastSyncTimestampProvider` is a `FutureProvider` that only re-evaluates when `syncNotifierProvider` changes (via `ref.watch`). If the watcher doesn't trigger correctly, the timestamp won't update.

**How to avoid:** The current pattern of `ref.watch(syncNotifierProvider)` inside `lastSyncTimestampProvider` should work because `syncNotifierProvider` state changes on every sync. Verify by testing: trigger sync, confirm timestamp updates on dashboard.

**Warning signs:** "Last synced: 30 minutes ago" even though sync just completed.

### Pitfall 5: Inconsistent Badge Behavior Across Entity Types

**What goes wrong:** Some cards show badges and others don't, or badge positioning is inconsistent.

**Why it happens:** Each card widget is implemented independently. Some check `isPendingSync`, others check sync queue status differently.

**How to avoid:** Standardize: all cards use the same pattern: (1) lookup entity ID in `syncQueueEntityStatusMapProvider` map, (2) if not found, check `entity.isPendingSync` as fallback, (3) render `SyncStatusBadge` in top-right of header row. For failed/dead letter, wrap badge in `GestureDetector` with navigation. Consider extracting a `SyncAwareBadge` wrapper widget.

## Code Examples

### Example 1: Shell-Level OfflineBanner (Mobile Layout)

```dart
// In ResponsiveShell._buildMobileLayout
Widget _buildMobileLayout(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(context),
    drawer: _buildDrawer(context),
    body: Column(
      children: [
        const OfflineBanner(),
        Expanded(child: widget.child),
      ],
    ),
    bottomNavigationBar: _buildBottomNav(context),
  );
}
```

### Example 2: Batch Sync Queue Status Stream

```dart
// In SyncQueueLocalDataSource
Stream<List<SyncQueueItem>> watchAllItems() {
  return (_db.select(_db.syncQueueItems)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
}
```

```dart
// In sync_providers.dart
final syncQueueEntityStatusMapProvider =
    StreamProvider<Map<String, SyncQueueEntityStatus>>((ref) {
  final syncQueueDataSource = ref.watch(syncQueueDataSourceProvider);
  return syncQueueDataSource.watchAllItems().map((items) {
    final map = <String, SyncQueueEntityStatus>{};
    for (final item in items) {
      final status = switch (item.status) {
        'dead_letter' => SyncQueueEntityStatus.deadLetter,
        'failed' => SyncQueueEntityStatus.failed,
        'pending' => SyncQueueEntityStatus.pending,
        _ => SyncQueueEntityStatus.pending,
      };
      // Keep the worst status per entity (dead_letter > failed > pending)
      final existing = map[item.entityId];
      if (existing == null || status.index > existing.index) {
        map[item.entityId] = status;
      }
    }
    return map;
  });
});
```

### Example 3: Card Badge with Failed State + Tap Navigation

```dart
// In a card widget's header Row
Widget _buildSyncBadge(BuildContext context, WidgetRef ref, String entityId) {
  final statusMap = ref.watch(syncQueueEntityStatusMapProvider);
  final queueStatus = statusMap.valueOrNull?[entityId];

  // No queue entry = synced = no badge (per locked decision)
  if (queueStatus == null) return const SizedBox.shrink();

  final syncStatus = switch (queueStatus) {
    SyncQueueEntityStatus.pending => SyncStatus.pending,
    SyncQueueEntityStatus.failed => SyncStatus.failed,
    SyncQueueEntityStatus.deadLetter => SyncStatus.deadLetter,
    SyncQueueEntityStatus.none => null,
  };

  if (syncStatus == null) return const SizedBox.shrink();

  final badge = SyncStatusBadge(status: syncStatus);

  // Failed/dead letter badges are tappable -> navigate to sync queue
  if (queueStatus == SyncQueueEntityStatus.failed ||
      queueStatus == SyncQueueEntityStatus.deadLetter) {
    return GestureDetector(
      onTap: () => context.push('/home/sync-queue?entityId=$entityId'),
      child: badge,
    );
  }

  return badge;
}
```

### Example 4: Global Last Sync Timestamp

```dart
// In AppSettingsService
Future<DateTime?> getGlobalLastSyncAt() async {
  final settings = await _db.select(_db.appSettings).get();
  DateTime? latest;
  for (final setting in settings) {
    if (setting.key.startsWith(_keyTableSyncPrefix)) {
      final dt = DateTime.tryParse(setting.value);
      if (dt != null && (latest == null || dt.isAfter(latest))) {
        latest = dt;
      }
    }
  }
  return latest;
}
```

```dart
// Updated provider in sync_providers.dart
final lastSyncTimestampProvider = FutureProvider<DateTime?>((ref) async {
  ref.watch(syncNotifierProvider); // Re-evaluate on sync completion
  final appSettings = ref.watch(appSettingsServiceProvider);
  return appSettings.getGlobalLastSyncAt();
});
```

### Example 5: Dashboard Staleness Display

```dart
// In DashboardTab, inside the welcome card or a new row
Widget _buildLastSyncIndicator(WidgetRef ref) {
  final lastSyncAsync = ref.watch(lastSyncTimestampProvider);

  return lastSyncAsync.when(
    data: (lastSync) {
      final text = _formatLastSync(lastSync); // Extract from settings_screen.dart
      final isStale = lastSync != null &&
          DateTime.now().difference(lastSync) > const Duration(hours: 1);

      return Row(
        children: [
          Icon(
            Icons.sync,
            size: 14,
            color: isStale ? Colors.orange.shade700 : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isStale ? Colors.orange.shade700 : Colors.grey,
            ),
          ),
        ],
      );
    },
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
  );
}
```

### Example 6: Activity Card Migration (Raw Icon to SyncStatusBadge)

**Before:**
```dart
// In activity_card.dart _buildContent()
if (activity.isPendingSync)
  Icon(
    Icons.sync,
    size: 16,
    color: theme.colorScheme.outline,
  ),
```

**After:**
```dart
// In activity_card.dart _buildHeader() -- move to header row, use SyncStatusBadge
// Remove raw icon from _buildContent
// Add to end of header Row children:
_buildSyncBadge(context, ref, activity.id),
```

## Discretion Recommendations

### Staleness Threshold: 1 Hour

**Reasoning:** Field reps typically sync when they have connectivity (office, hotspot). A 1-hour threshold balances between:
- Too aggressive (15-30 min): Would constantly show "stale" for reps in poor coverage areas, causing alert fatigue
- Too relaxed (4+ hours): Reps might not notice they've been working with very old data all day

1 hour means: if you haven't synced in the last hour, the timestamp turns amber. This matches typical "check in with the office" cadence for field sales teams.

### Staleness Display Location: Dashboard Only

**Reasoning:** The dashboard is the home screen and natural "status overview" location. Placing "Last synced" on every list header would be repetitive and take vertical space from content. The dashboard welcome card area already has contextual info ("Selamat datang!") and can naturally accommodate a small sync status line.

The app bar sync button in the shell already provides glanceable sync awareness on all shell-wrapped screens. Adding staleness text to the dashboard gives users one authoritative place to check detailed sync timing.

### Sync Queue Status Query: Batch Stream Provider

**Reasoning:** The sync queue typically has 0-50 items. A single Drift stream watching the full table is:
- One database watcher (vs. N per-entity watchers)
- O(N) map construction on each emission (N = queue size, not list length)
- O(1) lookup per card
- Reactive: Drift emits on any queue table change

This is far more efficient than per-entity StreamProvider.family which would create a separate database query per visible card.

### OfflineBanner Import Consolidation: Yes, Clean Up

**Reasoning:** After moving OfflineBanner to the shell, the 5 per-screen imports become dead code. Remove them to avoid confusion and prevent double-banner if someone adds it back. The screens are:
1. `activity_detail_screen.dart` (pushed over shell -- won't have banner either way)
2. `activities_tab.dart` (shell-wrapped -- will inherit shell banner)
3. `customer_detail_screen.dart` (pushed over shell)
4. `customers_tab.dart` (shell-wrapped -- will inherit shell banner)
5. `pipeline_detail_screen.dart` (pushed over shell)

Remove from all 5. The 3 detail screens lose the banner entirely (acceptable per design), and the 2 tab screens gain it via the shell.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Per-screen OfflineBanner | Shell-level OfflineBanner | Phase 7 (this phase) | Consistent offline indication across all shell screens |
| `isPendingSync` only | `isPendingSync` + sync queue status | Phase 7 | Cards show failed/dead letter, not just pending |
| Customer table proxy for last sync | Global max across all table timestamps | Phase 7 | Accurate "last synced" regardless of which table synced most recently |
| Raw `Icons.sync` on Activity card | `SyncStatusBadge` component | Phase 7 | Consistent visual language across all entity cards |

## Open Questions

1. **Key Person cards in detail screens**
   - What we know: Key Persons are listed as `_KeyPersonCard` private widgets inside `CustomerDetailScreen`, `HvcDetailScreen`, and `BrokerDetailScreen`. These are embedded in detail tabs, not in top-level list screens.
   - What's unclear: The CONTEXT says "all syncable entity types get badges" including Key Person. But Key Persons appear only in detail screen tabs, and the locked decision says "detail screens do NOT show per-entity sync status."
   - Recommendation: Apply badges to the embedded `_KeyPersonCard` widgets since they ARE list-like cards within a tab, even though they're in a detail screen. The "no detail screen sync status" decision refers to the entity being viewed in the detail screen (e.g., the Customer itself), not to sub-entity lists within it. If this interpretation is wrong, it's easy to remove.

2. **Cadence entity: CadenceMeeting vs CadenceConfig**
   - What we know: `CadenceMeeting` has `isPendingSync` field and appears in `MeetingCard`. `CadenceConfig` is admin-managed and doesn't appear in user-facing cards.
   - What's unclear: Whether "Cadence" in the badge list refers to meetings specifically.
   - Recommendation: Add badge to `MeetingCard` for cadence meetings, which is the user-facing card type.

3. **SyncQueue screen filtering by entity**
   - What we know: The CONTEXT says "tapping failed badge on card navigates to Sync Queue screen (filtered to that entity)."
   - What's unclear: Whether "filtered to that entity" means by entity ID (specific record) or entity type (all customers, etc.).
   - Recommendation: Filter by `entityId` (specific record) since the user tapped that specific card's badge. Show the exact queue items for that entity. Fall back to showing all items if the entity has no queue items (shouldn't happen if badge was visible).

## Sources

### Primary (HIGH confidence)
- Direct codebase analysis of all files listed in Architecture Patterns section
- `lib/presentation/widgets/common/offline_banner.dart` -- current OfflineBanner implementation
- `lib/presentation/widgets/common/sync_status_badge.dart` -- 5-state SyncStatusBadge
- `lib/presentation/widgets/shell/responsive_shell.dart` -- shell layout with sync button
- `lib/data/datasources/local/sync_queue_local_data_source.dart` -- queue query methods
- `lib/data/services/app_settings_service.dart` -- per-table sync timestamps
- `lib/presentation/providers/sync_providers.dart` -- all sync-related providers
- `lib/config/routes/app_router.dart` -- routing structure, parentNavigatorKey usage
- All 7 entity card widgets (CustomerCard, PipelineCard, HvcCard, BrokerCard, ReferralCard, ActivityCard, MeetingCard)
- `lib/presentation/screens/profile/settings_screen.dart` -- `_formatLastSync()` utility, dead letter count in Settings
- `lib/presentation/screens/sync/sync_queue_screen.dart` -- existing sync queue UI

### Secondary (MEDIUM confidence)
- CLAUDE.md project conventions (reactive UI pattern, StreamProvider pattern, AppLogger usage)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all components already exist in codebase, no new libraries needed
- Architecture: HIGH -- patterns directly observed from existing implementations; extending, not inventing
- Pitfalls: HIGH -- pitfalls identified from concrete routing structure (parentNavigatorKey) and Drift query patterns already in use
- Discretion recommendations: MEDIUM -- staleness threshold (1 hour) is a judgment call based on field rep usage patterns, not empirical data

**Research date:** 2026-02-19
**Valid until:** 2026-03-19 (stable -- no external dependency changes expected)
