# Phase 8: Stubbed Feature Completion - Research

**Researched:** 2026-02-19
**Domain:** Flutter feature completion (delete, contact launchers, activity editing, notification settings)
**Confidence:** HIGH

## Summary

Phase 8 completes half-implemented features across four areas: customer delete action, phone/email contact launchers, activity editing, and notification settings. All features have existing UI stubs (buttons, menu items, route placeholders) that need wiring to actual functionality.

The codebase already has the required packages installed (`url_launcher: ^6.3.1`) and the data layer patterns for soft-delete and sync queuing are well-established. The main work involves: (1) adding cascade soft-delete logic for customer deletion, (2) creating an `ActivityUpdateDto` and `updateActivity` repository method that doesn't exist yet, (3) making phone/email fields tappable across all detail screens, and (4) creating a notification settings screen backed by the existing `NotificationSettings` database table.

**Primary recommendation:** This phase is primarily UI-wiring and completing existing patterns -- no new architectural decisions needed. Follow existing repository/sync patterns exactly. The biggest new work is the activity edit flow (new DTO, repository method, route, and form edit mode) and cascade customer delete.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Customer Delete -- Cascading & Behavior
- Cascade soft-delete all related data: When a customer is soft-deleted, also soft-delete their key persons, pipelines, and activities (set `deleted_at` on all)
- Always allow deletion with generic warning: Show confirmation dialog with warning text that related data will also be deleted -- no specific counts, no blocking restrictions
- No undo UI: Soft-delete is DB-recoverable but no restore/undo button in the app
- Navigate to customer list after delete: Pop to customer list screen (not just pop once)
- Queue the delete for offline-first: Allow deleting customers with pending unsynced changes -- queue the delete operation, coalescing will handle it
- Role-based delete permissions: Claude's discretion -- decide based on existing role patterns in the app

#### Activity Edit Scope
- Editable fields: Claude's discretion on which fields are editable vs locked -- decide based on business logic
- Completed activities: Only notes/description can be edited after completion -- other fields are locked
- Edit entry point: Edit button in AppBar of activity detail screen only (no long-press on cards)
- Pending sync editing allowed: Allow editing activities that are pending sync -- update the queued payload, coalescing will merge create+update or update+update
- Edit route needed: Create `/home/activities/:id/edit` route, add `activityId` parameter to `ActivityFormScreen` for edit mode, pre-fill all fields from existing activity

#### Contact Action Placement -- Phone & Email Launchers
- Customer detail info tab: Make phone and email fields tappable (tap phone -> dialer, tap email -> email client) -- not just the bottom quick action bar
- Key person cards (customer detail + HVC detail): Both phone and email buttons on key person cards should work -- launch dialer/email client via url_launcher
- Activity detail PIC: Add phone/email contact actions for the activity's PIC (key person) -- user shouldn't have to navigate away to call
- HVC detail main contacts: All phone/email fields displayed on HVC detail should be tappable, not just key person cards
- Broker PIC contacts: Same pattern as key persons -- make phone and email tappable on broker cards/detail screens
- Consistent pattern: Every phone number and email address displayed anywhere in the app should be tappable -- apply uniformly across customer, HVC, activity, and broker screens

### Claude's Discretion

- **Activity edit field selection**: Choose which fields are editable vs locked based on business logic and existing form patterns
- **Delete role permissions**: Decide based on existing user role patterns in the codebase
- **Notification settings screen layout**: DB schema already has columns (pushEnabled, emailEnabled, activityReminders, pipelineUpdates, referralNotifications, cadenceReminders, systemNotifications, reminderMinutesBefore) -- build placeholder toggle UI that saves to DB even if push notifications aren't wired yet

### Deferred Ideas (OUT OF SCOPE)

- **Google Maps location selection for customers** -- New capability allowing users to select customer location via Google Maps API with map picker. Belongs in its own phase.
- **Customer share feature** -- Deferred from this phase.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FEAT-01 | ~~Deferred~~ — Customer share moved out of this phase |  |
| FEAT-02 | Customer detail screen delete functionality works with confirmation dialog | Delete confirmation dialog UI already built (lines 192-214); `deleteCustomer` method exists in repository with soft-delete+sync queuing; needs cascade soft-delete of key persons, pipelines, activities; needs navigation to customer list |
| FEAT-03 | Phone call and email launch work from customer detail, HVC detail, and activity detail screens | url_launcher already imported and working in customer detail bottom bar; key person phone buttons have `// TODO: Call`; email buttons are commented out; HVC has no direct phone/email (only key persons); broker has phone/email fields; activity detail PIC needs contact actions |
| FEAT-04 | Activities can be edited after creation via the activity form screen | ActivityRepository has NO `updateActivity` method for general editing (only execute/reschedule/cancel); needs new `ActivityUpdateDto`, repository method, notifier method; ActivityFormScreen needs `activityId` parameter for edit mode; new route `/home/activities/:id/edit` needed |
| FEAT-05 | Notification settings screen exists and is reachable from settings | `NotificationSettings` table exists in DB with all required columns; settings screen has "coming soon" snackbar stub; route `notifications` exists but points to Placeholder; need a new `NotificationSettingsScreen` with toggle UI |
</phase_requirements>

## Standard Stack

### Core (Already Installed)
| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| url_launcher | ^6.3.1 | Launch phone dialer, email client, URLs | Already imported and used in customer_detail_screen.dart and activity_detail_screen.dart |
| drift | ^2.22.1 | Local SQLite database with reactive streams | Core DB layer, all CRUD operations |
| flutter_riverpod | ^2.6.1 | State management with providers | Standard state management |
| go_router | ^14.6.3 | Declarative routing | All navigation |

### No New Dependencies Needed
All required packages are already in pubspec.yaml. No new dependencies required for this phase.

## Architecture Patterns

### Existing Project Structure (No Changes)
```
lib/
├── config/routes/          # GoRouter + route_names.dart (add activity edit route)
├── data/
│   ├── datasources/local/  # Local data sources (add batch soft-delete methods)
│   ├── dtos/               # DTOs (add ActivityUpdateDto)
│   └── repositories/       # Repository implementations (add updateActivity)
├── domain/
│   └── repositories/       # Repository interfaces (add updateActivity)
└── presentation/
    ├── providers/           # Riverpod providers (add updateActivity to notifier)
    ├── screens/
    │   ├── activity/        # ActivityFormScreen (add edit mode)
    │   ├── customer/        # CustomerDetailScreen (wire delete)
    │   ├── hvc/             # HvcDetailScreen (wire contact actions)
    │   ├── broker/          # BrokerDetailScreen (wire contact actions)
    │   └── profile/         # Add NotificationSettingsScreen
    └── widgets/             # Reusable widgets (add tappable contact fields)
```

### Pattern 1: Cascade Customer Soft-Delete
**What:** Soft-delete customer + all related key persons, pipelines, and activities in a single Drift transaction
**When to use:** Customer delete action
**Key insight:** The existing `deleteCustomer` in `customer_repository_impl.dart` only soft-deletes the customer record itself. Need to add cascade logic inside the transaction.

```dart
// In customer_repository_impl.dart deleteCustomer:
await _database.transaction(() async {
  // 1. Soft-delete all key persons for this customer
  await _keyPersonLocalDataSource.softDeleteByCustomerId(customerId);
  // 2. Soft-delete all pipelines for this customer
  await _pipelineLocalDataSource.softDeleteByCustomerId(customerId);
  // 3. Soft-delete all activities for this customer
  await _activityLocalDataSource.softDeleteByCustomerId(customerId);
  // 4. Soft-delete the customer itself
  await _localDataSource.softDeleteCustomer(id);
  // 5. Queue delete operation for sync
  await _syncService.queueOperation(...);
});
```

**Important:** New batch soft-delete methods (`softDeleteByCustomerId`) need to be added to key_person_local_data_source.dart, pipeline_local_data_source.dart, and activity_local_data_source.dart. These methods don't exist yet.

### Pattern 3: Tappable Contact Fields
**What:** Make phone numbers and email addresses tappable throughout the app using url_launcher
**When to use:** Every `_InfoRow` or `ListTile` displaying phone/email across all detail screens
**Key insight:** Customer detail screen already has `_launchUrl` method. Create a reusable `TappableContactField` widget or modify `_InfoRow` to accept an `onTap` callback.

```dart
// Reusable pattern for tappable phone:
GestureDetector(
  onTap: () => launchUrl(Uri.parse('tel:$phone')),
  child: Text(phone, style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
)

// For key person cards - uncomment email button and wire phone button:
if (keyPerson.phone != null)
  IconButton(
    icon: const Icon(Icons.phone),
    onPressed: () => launchUrl(Uri.parse('tel:${keyPerson.phone}')),
  ),
if (keyPerson.email != null)
  IconButton(
    icon: const Icon(Icons.email),
    onPressed: () => launchUrl(Uri.parse('mailto:${keyPerson.email}')),
  ),
```

### Pattern 4: Activity Edit Mode
**What:** Add `activityId` parameter to `ActivityFormScreen` for edit mode with pre-filled data
**When to use:** Edit button in activity detail AppBar
**Key insight:** The form screen currently only supports create mode. Need to:
1. Add `activityId` optional parameter
2. Load existing activity data in `initState` when `activityId` is provided
3. Pre-fill all form fields from existing activity
4. Create `ActivityUpdateDto` (does not exist) and `updateActivity` repository method (does not exist)
5. Lock fields for completed activities (only notes/description editable)

```dart
// New ActivityUpdateDto needed:
@freezed
class ActivityUpdateDto with _$ActivityUpdateDto {
  const factory ActivityUpdateDto({
    String? activityTypeId,
    DateTime? scheduledDatetime,
    String? keyPersonId,
    String? summary,
    String? notes,
  }) = _ActivityUpdateDto;
}

// New repository method needed:
Future<Result<Activity>> updateActivity(String id, ActivityUpdateDto dto);
```

### Pattern 5: Notification Settings Screen
**What:** Toggle UI screen backed by `NotificationSettings` database table
**When to use:** Settings screen notification tile navigation
**Key insight:** The `NotificationSettings` table already exists with all required columns. Need to create a screen with `SwitchListTile` widgets for each setting, backed by a provider that reads/writes to the local DB.

### Anti-Patterns to Avoid
- **Don't use `ref.invalidate()` for Drift-backed providers** -- Drift streams auto-update. Only invalidate lookup caches.
- **Don't navigate with `context.pop()` for multi-screen pops** -- Use `context.go('/home/customers')` to navigate to customer list after delete (not `context.pop()` which only goes back one screen).
- **Don't create separate screens for each contact action** -- Use inline `url_launcher` calls, not navigation.
## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Phone/email launching | Custom intent handling | `launchUrl(Uri.parse('tel:...'))` from url_launcher | Platform-specific URL scheme handling |
| Reactive form state | Manual state management | Existing `ActivityFormNotifier` pattern | Consistent with codebase conventions |
| DB toggle persistence | SharedPreferences for settings | Drift `NotificationSettings` table | Already exists, type-safe, reactive |

**Key insight:** Every piece of infrastructure for these features already exists in the codebase. The work is wiring, not building.

## Common Pitfalls

### Pitfall 1: Customer Delete Navigation
**What goes wrong:** Using `context.pop()` after delete only goes back one screen (e.g., to edit screen if user came from there)
**Why it happens:** Pop-based navigation doesn't guarantee reaching the customer list
**How to avoid:** Use `context.go('/home/customers')` to navigate directly to the customer list
**Warning signs:** User ends up on wrong screen after delete

### Pitfall 3: Cascade Delete Missing Sync Queue Entries
**What goes wrong:** Soft-deleting related entities without queuing them for sync, causing remote data to be out of sync
**Why it happens:** Only queuing the customer delete but not the cascade deletes
**How to avoid:** Queue delete operations for EACH cascaded entity type (key_person, pipeline, activity) inside the transaction. However, since the backend may handle cascade deletes via RLS/triggers, the simplest approach is to just soft-delete locally and queue only the customer delete -- the backend cascade will handle the rest when synced.
**Recommendation:** Soft-delete related records locally for immediate UI feedback, but only queue the customer delete for sync. The backend's cascade delete logic will handle the related records. This avoids N sync queue entries for a single customer delete.

### Pitfall 4: Activity Edit Creating Duplicate Instead of Updating
**What goes wrong:** Calling `createActivity` instead of `updateActivity` when in edit mode
**Why it happens:** Form screen doesn't differentiate between create and edit
**How to avoid:** Check for `activityId` in submit handler; route to `updateActivity` when editing
**Warning signs:** Duplicate activities appearing after edit

### Pitfall 5: url_launcher Missing URL Scheme Check
**What goes wrong:** `launchUrl` fails silently or crashes on some platforms without proper scheme
**Why it happens:** Phone numbers may have formatting issues; email addresses may be malformed
**How to avoid:** Always use `canLaunchUrl` check before `launchUrl` (existing pattern in customer_detail_screen.dart). Strip non-numeric chars from phone numbers before building `tel:` URI.
**Warning signs:** Nothing happens when user taps phone/email

### Pitfall 6: Edit Mode Form Pre-fill Timing
**What goes wrong:** Form fields initialized in `initState` but activity data loads asynchronously
**Why it happens:** Activity data comes from provider (async), but TextEditingController values set in initState (sync)
**How to avoid:** Load activity data in `initState` via `WidgetsBinding.instance.addPostFrameCallback` or use `ref.read()` to get cached data. Set controller values once data arrives using a flag to prevent overwriting user edits.
**Warning signs:** Form fields empty on first render, then filled after rebuild

## Code Examples

### Example 1: Cascade Customer Delete (Repository)
```dart
// In customer_repository_impl.dart:
@override
Future<Result<void>> deleteCustomer(String id) =>
    runCatching(() async {
      await _database.transaction(() async {
        // Cascade soft-delete related records locally
        await _keyPersonLocalDataSource.softDeleteByCustomerId(id);
        await _pipelineLocalDataSource.softDeleteByCustomerId(id);
        await _activityLocalDataSource.softDeleteByCustomerId(id);

        // Soft-delete customer
        await _localDataSource.softDeleteCustomer(id);

        // Queue ONLY customer delete for sync (backend handles cascade)
        await _syncService.queueOperation(
          entityType: SyncEntityType.customer,
          entityId: id,
          operation: SyncOperation.delete,
          payload: {'id': id},
        );
      });
      unawaited(_syncService.triggerSync());
    }, context: 'deleteCustomer');
```

### Example 3: Batch Soft-Delete Method (New)
```dart
// In key_person_local_data_source.dart (NEW method):
Future<void> softDeleteByCustomerId(String customerId) async {
  await (_db.update(_db.keyPersons)
    ..where((kp) => kp.customerId.equals(customerId) & kp.deletedAt.isNull()))
    .write(KeyPersonsCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
}
```

### Example 4: Activity Edit Route
```dart
// In app_router.dart, under activities/:id routes:
GoRoute(
  path: 'edit',
  name: RouteNames.activityEdit,
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ActivityFormScreen(activityId: id);
  },
),
```

### Example 5: Notification Settings Screen Pattern
```dart
// Basic structure for NotificationSettingsScreen:
class NotificationSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Notifikasi')),
      body: settingsAsync.when(
        data: (settings) => ListView(children: [
          SwitchListTile(
            title: const Text('Push Notification'),
            value: settings.pushEnabled,
            onChanged: (v) => ref.read(notificationSettingsNotifierProvider.notifier)
                .updateSetting(pushEnabled: v),
          ),
          // ... more toggles for each setting
        ]),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState.general(title: 'Error', message: e.toString()),
      ),
    );
  }
}
```

## Detailed Findings by Feature

### FEAT-01: Customer Share — DEFERRED

Moved out of this phase scope.

### FEAT-02: Customer Delete with Cascade

**Current state:**
- Delete confirmation dialog exists (lines 192-214) with Indonesian text
- Dialog calls `context.pop()` after delete -- needs to change to `context.go('/home/customers')`
- `deleteCustomer` in repository only soft-deletes the customer record (lines 236-252 of customer_repository_impl.dart)
- `softDeleteCustomer` in local data source just sets `deletedAt` on customer (lines 102-110)
- No cascade delete of related data

**Work needed:**
1. Add `softDeleteByCustomerId(String customerId)` to:
   - `key_person_local_data_source.dart`
   - `pipeline_local_data_source.dart`
   - `activity_local_data_source.dart`
2. Update `deleteCustomer` in `customer_repository_impl.dart` to call cascade soft-deletes within the transaction
3. Wire the delete button in the UI dialog to call the repository method
4. Change navigation after delete to `context.go('/home/customers')` instead of `context.pop()`
5. Show success snackbar
6. Update confirmation dialog text to warn about related data deletion

**Role permissions recommendation (Claude's discretion):**
- Existing pattern: `isAdmin` check gates HVC and Broker delete (only admin/superadmin)
- Customer delete should follow the same pattern: allow all roles to delete since customers are assigned per RM
- Rationale: An RM should be able to delete their own customers. The soft-delete is recoverable by admin.
- If restricting: at minimum, the assigned RM should be able to delete. Admin/superadmin always can.
- Recommendation: Allow any authenticated user to delete customers they can see (same as edit access).

### FEAT-03: Phone & Email Contact Launchers

**Current state by screen:**

1. **Customer detail info tab (`_InfoTab`)**: Phone and email displayed as static text in `_InfoRow` widgets (lines 269-271). NOT tappable.

2. **Customer detail key person cards (`_KeyPersonCard`)**: Phone button exists (line 492) with `// TODO: Call`. Email button is COMMENTED OUT (lines 495-501).

3. **HVC detail info tab (`_InfoTab`)**: HVC entity has NO phone or email fields. Contact info is only on key persons.

4. **HVC detail key person cards (`_KeyPersonCard`)**: Phone button exists (line 672) with `// TODO: Launch phone`. Email button is COMMENTED OUT (lines 676-683).

5. **Activity detail PIC**: Key person name shown (line 131) but NO contact actions at all. Need to add phone/email buttons.

6. **Broker detail info tab (`_InfoTab`)**: Phone and email displayed as static `_InfoRow` text (lines 276-278). NOT tappable.

7. **Broker detail key person cards (`_KeyPersonCard`)**: Uses `ListTile` format. Phone shown in subtitle text, no dedicated buttons.

**Work needed:**
1. Create a reusable `_TappableInfoRow` or modify `_InfoRow` to accept `onTap` for phone/email fields
2. In customer detail `_InfoTab`: Make phone row tap -> `tel:`, email row tap -> `mailto:`
3. In customer detail `_KeyPersonCard`: Wire phone button, uncomment and wire email button
4. In HVC detail `_KeyPersonCard`: Wire phone button, uncomment and wire email button
5. In activity detail: Add phone/email buttons to PIC ListTile
6. In broker detail `_InfoTab`: Make phone and email rows tappable
7. In broker detail `_KeyPersonCard`: Add phone/email icon buttons (currently using `ListTile` style without them)
8. The `_launchUrl` helper method from customer detail can be extracted as a utility or duplicated per screen

### FEAT-04: Activity Editing

**Current state:**
- `ActivityDetailScreen` has edit button in AppBar (line 39-41) with `// TODO: Navigate to edit`
- `ActivityFormScreen` only accepts create parameters: `objectType`, `objectId`, `objectName`, `isImmediate`
- NO `activityId` parameter
- `ActivityRepository` has NO `updateActivity` method (only `executeActivity`, `rescheduleActivity`, `cancelActivity`)
- NO `ActivityUpdateDto` in `activity_dtos.dart`
- NO edit route in `app_router.dart`
- `ActivityFormNotifier` has NO `updateActivity` method

**Work needed:**
1. **New DTO:** Create `ActivityUpdateDto` in `activity_dtos.dart` (freezed, with optional fields)
2. **Repository interface:** Add `Future<Result<Activity>> updateActivity(String id, ActivityUpdateDto dto)` to `activity_repository.dart`
3. **Repository implementation:** Implement `updateActivity` in `activity_repository_impl.dart`:
   - Build `ActivitiesCompanion` from DTO
   - Update via `_localDataSource.updateActivity(id, companion)`
   - Insert audit log with action 'EDITED'
   - Queue sync operation (SyncOperation.update)
4. **Notifier:** Add `updateActivity` method to `ActivityFormNotifier`
5. **Route:** Add `/home/activities/:id/edit` route in `app_router.dart`
6. **Route name:** Add `activityEdit` to `route_names.dart`
7. **Form screen:** Add `activityId` parameter to `ActivityFormScreen`:
   - When `activityId` is provided, load existing activity data
   - Pre-fill all form fields
   - Change submit button text
   - Use `updateActivity` instead of `createActivity` on submit
8. **Detail screen:** Wire edit button to navigate to edit route
9. **Completed activity restriction:** When activity status is `completed`, lock all fields except notes/summary

**Editable fields recommendation (Claude's discretion):**
- For non-completed activities: ALL fields editable (activity type, scheduled datetime, key person, summary, notes)
- Object type and object association (customer/HVC/broker) should be LOCKED -- changing the associated entity doesn't make business sense
- For completed activities: Only `summary` and `notes` editable (per user decision)
- `isImmediate` flag: LOCKED (cannot change after creation)
- Execution data (GPS, photos, distance): LOCKED (cannot change after execution)

### FEAT-05: Notification Settings Screen

**Current state:**
- `NotificationSettings` table exists in `lib/data/database/tables/notifications.dart` with columns:
  - `pushEnabled` (bool, default true)
  - `emailEnabled` (bool, default true)
  - `activityReminders` (bool, default true)
  - `pipelineUpdates` (bool, default true)
  - `referralNotifications` (bool, default true)
  - `cadenceReminders` (bool, default true)
  - `systemNotifications` (bool, default true)
  - `reminderMinutesBefore` (int, default 30)
- Settings screen has snackbar stub: "Pengaturan notifikasi akan segera hadir" (line 97)
- Route `notifications` exists in route_names.dart and app_router.dart but points to a `Placeholder` widget
- NO `NotificationSettingsScreen` file exists
- NO provider/notifier for notification settings exists
- NO local data source for notification settings exists

**Work needed:**
1. **Local data source:** Create notification settings local data source with CRUD methods
2. **Provider/notifier:** Create `notificationSettingsProvider` (StreamProvider) and `NotificationSettingsNotifier`
3. **Screen:** Create `NotificationSettingsScreen` with:
   - Section header "Umum" with push and email toggles
   - Section header "Kategori" with category toggles (activity, pipeline, referral, cadence, system)
   - Reminder time picker (dropdown or slider for `reminderMinutesBefore`)
4. **Route:** Either reuse existing `/home/notifications` route or create new `/home/notification-settings` route
5. **Settings screen:** Change snackbar to navigation: `context.push('/home/notification-settings')`
6. **Initialize settings:** Ensure default settings row is created for user on first access

**Layout recommendation (Claude's discretion):**
- Group into sections: General (push, email), Categories (activity, pipeline, referral, cadence, system), Timing (reminder minutes)
- Use `SwitchListTile` for toggles
- Use dropdown for reminder minutes: 5, 10, 15, 30, 60 minutes
- Indonesian labels matching existing app language patterns
- Persist to local DB immediately on toggle (no save button)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `url_launcher.launch()` | `launchUrl(Uri.parse(...))` | url_launcher v6.0 | Project already uses new API correctly |

**Deprecated/outdated:**
## Open Questions

1. **Backend cascade delete behavior**
   - What we know: Frontend needs to soft-delete related records locally for immediate UI feedback
   - What's unclear: Whether the Supabase backend automatically cascades customer deletes to related tables via triggers/RLS
   - Recommendation: Soft-delete locally in a transaction for immediate UI response. Queue only the customer delete for sync. If backend doesn't cascade, add cascade logic to the sync push handler later. This is the safest approach.

2. **Activity edit sync payload**
   - What we know: Sync queue uses coalescing (create+update -> create, update+update -> latest update)
   - What's unclear: Whether the existing sync payload format supports partial updates or needs full entity
   - Recommendation: Build the sync payload as a full entity snapshot (matching `ActivitySyncDto` format) since the sync push handler likely does an upsert. The existing coalescing logic will merge payloads correctly.

3. **Notification settings sync**
   - What we know: `NotificationSettings` table exists locally. No sync entity type for it.
   - What's unclear: Whether notification settings need to sync to Supabase or remain local-only
   - Recommendation: Keep notification settings local-only for now (no sync). These are device/app preferences, not business data. Push notification infrastructure doesn't exist yet anyway.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: customer_detail_screen.dart, activity_detail_screen.dart, activity_form_screen.dart, hvc_detail_screen.dart, broker_detail_screen.dart, settings_screen.dart
- Codebase analysis: customer_repository.dart, customer_repository_impl.dart, activity_repository.dart, activity_repository_impl.dart
- Codebase analysis: activity_dtos.dart, activity.dart, customer.dart, key_person.dart, hvc.dart, broker.dart
- Codebase analysis: app_router.dart, route_names.dart, notifications.dart (DB table)
- Codebase analysis: pubspec.yaml (dependency versions)

### Secondary (MEDIUM confidence)
- None

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All packages already installed and patterns established
- Architecture: HIGH - All patterns follow existing codebase conventions exactly
- Pitfalls: HIGH - Verified against actual codebase code and package versions

**Research date:** 2026-02-19
**Valid until:** 2026-03-19 (stable; no rapidly changing tech)
