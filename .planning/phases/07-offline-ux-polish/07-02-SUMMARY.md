---
phase: 07-offline-ux-polish
plan: 02
subsystem: presentation
tags: [sync-badges, entity-cards, sync-queue-navigation]

# Dependency graph
requires:
  - phase: 07-offline-ux-polish (plan 01)
    provides: syncQueueEntityStatusMapProvider, SyncQueueEntityStatus enum, SyncStatusBadge with corrected colors
provides:
  - All 7 entity card types display sync queue-aware badges
  - Failed/dead letter badges are tappable and navigate to filtered sync queue
affects: [07-03]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Consistent _buildSyncBadge pattern across all 7 card widgets"
    - "ConsumerWidget conversion for cards that previously were StatelessWidget"
    - "GestureDetector wrapping SyncStatusBadge for tap-to-navigate on failed/dead letter"

key-files:
  created: []
  modified:
    - lib/presentation/widgets/cards/customer_card.dart
    - lib/presentation/widgets/cards/pipeline_card.dart
    - lib/presentation/widgets/activity/activity_card.dart
    - lib/presentation/widgets/hvc/hvc_card.dart
    - lib/presentation/widgets/broker/broker_card.dart
    - lib/presentation/widgets/referral/referral_card.dart
    - lib/presentation/screens/cadence/widgets/meeting_card.dart

key-decisions:
  - "All 7 cards use identical _buildSyncBadge pattern for consistency"
  - "Cards converted from StatelessWidget to ConsumerWidget where needed (pipeline, activity, hvc, broker, referral, meeting)"
  - "CustomerCard was already ConsumerWidget, only badge logic replaced"
  - "No badge shown when entity is fully synced (SyncQueueEntityStatus.none)"
  - "Failed and dead letter badges wrapped in GestureDetector navigating to /home/sync-queue?entityId=xxx"
  - "Pending badge shows but is not tappable (no action needed by user)"
  - "MeetingCard had no sync badge previously; one was added to the header row"
  - "ActivityCard: removed raw Icons.sync from _buildContent, added SyncStatusBadge to _buildHeader"

patterns-established:
  - "_buildSyncBadge(context, ref, entityId, isPendingSync) pattern reusable across all entity cards"

requirements-completed: [UX-02]

# Metrics
completed: 2026-02-19
---

# Phase 07 Plan 02: Sync Queue-Aware Badges on Entity Cards Summary

**Updated all 7 entity card types with sync queue-aware badges that show pending/failed/dead letter status and navigate to filtered sync queue on tap**

## Accomplishments
- CustomerCard: Replaced old badge logic with _buildSyncBadge method using syncQueueEntityStatusMapProvider
- PipelineCard: Converted from StatelessWidget to ConsumerWidget, added queue-aware badge
- ActivityCard: Converted to ConsumerWidget, removed raw Icons.sync from content, added SyncStatusBadge to header
- HvcCard: Converted to ConsumerWidget, replaced pending-only badge with queue-aware badge
- BrokerCard: Converted to ConsumerWidget, replaced synced+pending badge with queue-aware badge (no badge when synced)
- ReferralCard: Converted to ConsumerWidget, replaced pending-only badge with queue-aware badge
- MeetingCard: Converted to ConsumerWidget, added new sync badge to header row (previously had none)

## The _buildSyncBadge Pattern
All 7 cards use this identical pattern:
1. Watch syncQueueEntityStatusMapProvider for batch status map
2. Look up entity by ID in the map
3. Fall back to isPendingSync flag if entity not in queue
4. Map SyncQueueEntityStatus to SyncStatus for badge display
5. Wrap failed/dead letter badges in GestureDetector navigating to `/home/sync-queue?entityId=xxx`

## Deviations from Plan
None.

## Issues Encountered
- BrokerCard had two `build` methods (BrokerCard and _InfoChip), needed more context for unique edit match

## Self-Check: PASSED

---
*Phase: 07-offline-ux-polish*
*Completed: 2026-02-19*
