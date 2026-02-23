# Phase 9: Admin & Dashboard Features - Context

**Gathered:** 2026-02-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Complete admin user deletion with cascading data reassignment (FEAT-06), and confirm/clean up dashboard quick activity logging (FEAT-07). FEAT-07 is already functionally complete — the full-form immediate activity flow works from both dashboard and activities tab. Phase 9 work is primarily FEAT-06 (user deletion) plus minor cleanup.

</domain>

<decisions>
## Implementation Decisions

### Deletion Cascade Scope
- Admin must pick a new RM to reassign data to before deletion proceeds
- **Customers**: All customers where deleted user is `assigned_rm_id` transfer to new RM
- **Pipelines**: All pipelines where deleted user is `assigned_rm_id` or `scored_to_user_id` transfer to new RM
- **Activities**: All activities transfer `user_id` to new RM, but `created_by` stays as original author (audit trail)
- **HVCs and Brokers**: Transfer all to new RM (consistent with customer/pipeline pattern)
- **Pipeline Referrals**: Transfer referrer/receiver RM references to new RM
- **Cadence participation**: Keep historical meeting records as-is (user just no longer appears in future meetings)
- **Subordinates**: Auto-reassign to the deleted user's parent (one level up in hierarchy) — no manual step needed
- **user_hierarchy**: Cleaned up automatically (existing CASCADE FK)
- **user_targets / user_scores**: Claude's discretion — archive or soft-delete based on 4DX scoring model

### Deletion Safeguards
- **Online only**: User deletion requires active internet connection (Edge Function call). Show error if offline. Not queued in sync_queue.
- **Role permissions**: Both Admin and Superadmin roles can delete users (matches existing create/edit permissions)
- **Self-delete blocked**: Users cannot delete themselves
- **Confirmation**: Simple confirmation dialog with RM reassignment picker. No data count summary.
- **Subordinate handling**: Automatic — subordinates reassigned to deleted user's parent before deletion proceeds

### Delete Flow
- Claude's discretion on whether reassignment picker is inline in delete dialog or a two-step process — pick whichever is simpler and clearer for the admin

### Deleted User Visibility
- **Name in historical records**: Claude's discretion — show original name or with indicator based on simplest approach with existing lookup patterns
- **Admin user list**: Hidden by default, filterable to show deleted users (toggle filter)
- **Auth account**: Use existing deactivate pattern (isActive=false) plus set deleted_at. Don't remove Supabase Auth account.
- **Restorability**: Claude's discretion — pick based on implementation complexity

### Quick Activity Logging (FEAT-07)
- **Status**: Already complete. Dashboard "Log Aktivitas" button and Activities tab flash FAB both route to `ActivityFormScreen` with `immediate=true`. No changes needed.
- **Cleanup**: Remove unused `QuickAddSheet` (dead code — only self-references)
- **Disclaimers**: Add code comments on both `ImmediateActivitySheet` (used from customer/HVC/broker detail screens) and `ActivityFormScreen` immediate mode (used from dashboard/activities tab) clarifying their separate entry points and purposes

### Claude's Discretion
- Scoring data handling (archive vs soft-delete user_targets/user_scores)
- Delete flow UX (inline dialog vs two-step)
- Deleted user name display pattern in historical records
- Whether deleted users can be restored
- Edge Function implementation details
- Database migration approach for adding `deleted_at` to users table

</decisions>

<specifics>
## Specific Ideas

- Transfer pattern: new RM gets all business data ownership (customers, pipelines, HVCs, brokers, referrals) but `created_by` audit fields stay with original user
- Activities transfer `user_id` only (visibility/ownership), not `created_by` (authorship credit)
- Cadence meeting participation is historical — keep records intact, just remove from future participation
- Existing `deactivateUser` approach (isActive=false) serves as the auth-blocking mechanism alongside soft-delete

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 09-admin-dashboard-features*
*Context gathered: 2026-02-23*
