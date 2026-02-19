# Phase 8: Stubbed Feature Completion - Context

**Gathered:** 2026-02-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Complete half-implemented features: customer share/delete actions, phone/email contact launchers across all entity screens, activity editing with pre-filled form, and notification settings placeholder screen. All features have existing UI stubs (buttons, menu items, route placeholders) that need wiring to actual functionality.

</domain>

<decisions>
## Implementation Decisions

### Customer Delete — Cascading & Behavior
- **Cascade soft-delete all related data**: When a customer is soft-deleted, also soft-delete their key persons, pipelines, and activities (set `deleted_at` on all)
- **Always allow deletion with generic warning**: Show confirmation dialog with warning text that related data will also be deleted — no specific counts, no blocking restrictions
- **No undo UI**: Soft-delete is DB-recoverable but no restore/undo button in the app
- **Navigate to customer list after delete**: Pop to customer list screen (not just pop once)
- **Queue the delete for offline-first**: Allow deleting customers with pending unsynced changes — queue the delete operation, coalescing will handle it
- **Role-based delete permissions**: Claude's discretion — decide based on existing role patterns in the app

### Activity Edit Scope
- **Editable fields**: Claude's discretion on which fields are editable vs locked — decide based on business logic (e.g., changing customer association may not make sense)
- **Completed activities**: Only notes/description can be edited after completion — other fields are locked
- **Edit entry point**: Edit button in AppBar of activity detail screen only (no long-press on cards)
- **Pending sync editing allowed**: Allow editing activities that are pending sync — update the queued payload, coalescing will merge create+update or update+update
- **Edit route needed**: Create `/home/activities/:id/edit` route, add `activityId` parameter to `ActivityFormScreen` for edit mode, pre-fill all fields from existing activity

### Contact Action Placement — Phone & Email Launchers
- **Customer detail info tab**: Make phone and email fields tappable (tap phone → dialer, tap email → email client) — not just the bottom quick action bar
- **Key person cards (customer detail + HVC detail)**: Both phone and email buttons on key person cards should work — launch dialer/email client via url_launcher
- **Activity detail PIC**: Add phone/email contact actions for the activity's PIC (key person) — user shouldn't have to navigate away to call
- **HVC detail main contacts**: All phone/email fields displayed on HVC detail should be tappable, not just key person cards
- **Broker PIC contacts**: Same pattern as key persons — make phone and email tappable on broker cards/detail screens
- **Consistent pattern**: Every phone number and email address displayed anywhere in the app should be tappable — apply uniformly across customer, HVC, activity, and broker screens

### Claude's Discretion
- **Share content format**: Decide the share text format for customer data (name, company, phone, email) — plain text via share_plus, Claude picks the formatting
- **Activity edit field selection**: Choose which fields are editable vs locked based on business logic and existing form patterns
- **Delete role permissions**: Decide based on existing user role patterns in the codebase
- **Notification settings screen layout**: DB schema already has columns (pushEnabled, emailEnabled, activityReminders, pipelineUpdates, referralNotifications, cadenceReminders, systemNotifications, reminderMinutesBefore) — build placeholder toggle UI that saves to DB even if push notifications aren't wired yet

</decisions>

<specifics>
## Specific Ideas

- Bottom quick action bar on customer detail already works (phone, WhatsApp, email, navigation) — don't duplicate, just supplement with tappable fields in info sections
- Key person email buttons are currently commented out in both customer and HVC detail screens — uncomment and wire up
- Activity form screen currently has no `activityId` parameter — needs edit mode flag + data loading
- Existing delete confirmation dialog UI in customer detail is already built (Indonesian text) — just needs repository call wired in
- Settings screen notification tile currently shows snackbar "coming soon" — replace with actual navigation to notification settings screen
- Broker PIC contacts should follow the same tap-to-call/email pattern as key person cards

</specifics>

<deferred>
## Deferred Ideas

- **Google Maps location selection for customers** — New capability allowing users to select customer location via Google Maps API with map picker. Belongs in its own phase (location/maps feature).
- **Share content as vCard** — If plain text sharing proves insufficient, consider vCard format in a future iteration.

</deferred>

---

*Phase: 08-stubbed-feature-completion*
*Context gathered: 2026-02-19*
