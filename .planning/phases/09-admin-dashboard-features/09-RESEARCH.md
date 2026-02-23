# Phase 9: Admin & Dashboard Features - Research

**Researched:** 2026-02-23
**Domain:** Admin user deletion with data reassignment + quick activity cleanup
**Confidence:** HIGH

## Summary

Phase 9 has two components: (1) implementing admin user deletion with cascading data reassignment (FEAT-06), and (2) minor cleanup of the quick activity logging feature (FEAT-07), which is already functionally complete. The bulk of the work is FEAT-06.

User deletion requires a new Supabase Edge Function (`admin-delete-user`) following the existing pattern established by `admin-create-user` and `admin-reset-password`. The Edge Function handles the server-side data reassignment using the `service_role` key, while the Flutter client provides the admin UI for selecting a replacement RM and confirming the deletion. The Users table needs a `deleted_at` column added via Drift migration (v12 -> v13). HVCs and Brokers use `createdBy` as their ownership field (not `assignedRmId`), which is the field that must be transferred.

For FEAT-07, the dashboard "Log Aktivitas" button already correctly navigates to `ActivityFormScreen` with `immediate=true`. The activities tab flash FAB also works. The only remaining work is removing the dead `QuickAddSheet` widget and adding clarifying comments.

**Primary recommendation:** Build a new `admin-delete-user` Edge Function that handles the full reassignment + soft-delete transaction server-side, with the Flutter client providing a two-step confirmation dialog with RM picker and online-only guard.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Admin must pick a new RM to reassign data to before deletion proceeds
- **Customers**: All customers where deleted user is `assigned_rm_id` transfer to new RM
- **Pipelines**: All pipelines where deleted user is `assigned_rm_id` or `scored_to_user_id` transfer to new RM
- **Activities**: All activities transfer `user_id` to new RM, but `created_by` stays as original author (audit trail)
- **HVCs and Brokers**: Transfer all to new RM (consistent with customer/pipeline pattern)
- **Pipeline Referrals**: Transfer referrer/receiver RM references to new RM
- **Cadence participation**: Keep historical meeting records as-is (user just no longer appears in future meetings)
- **Subordinates**: Auto-reassign to the deleted user's parent (one level up in hierarchy) -- no manual step needed
- **user_hierarchy**: Cleaned up automatically (existing CASCADE FK)
- **user_targets / user_scores**: Claude's discretion -- archive or soft-delete based on 4DX scoring model
- **Online only**: User deletion requires active internet connection (Edge Function call). Show error if offline. Not queued in sync_queue.
- **Role permissions**: Both Admin and Superadmin roles can delete users (matches existing create/edit permissions)
- **Self-delete blocked**: Users cannot delete themselves
- **Confirmation**: Simple confirmation dialog with RM reassignment picker. No data count summary.
- **Subordinate handling**: Automatic -- subordinates reassigned to deleted user's parent before deletion proceeds
- **Quick Activity Logging (FEAT-07)**: Already complete. Dashboard "Log Aktivitas" button and Activities tab flash FAB both route to `ActivityFormScreen` with `immediate=true`. No changes needed.
- **Cleanup**: Remove unused `QuickAddSheet` (dead code -- only self-references)
- **Disclaimers**: Add code comments on both `ImmediateActivitySheet` and `ActivityFormScreen` immediate mode clarifying their separate entry points and purposes

### Claude's Discretion
- Scoring data handling (archive vs soft-delete user_targets/user_scores)
- Delete flow UX (inline dialog vs two-step)
- Deleted user name display pattern in historical records
- Whether deleted users can be restored
- Edge Function implementation details
- Database migration approach for adding `deleted_at` to users table

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FEAT-06 | Admin can delete users with cascading cleanup | Edge Function pattern (admin-delete-user), data reassignment SQL, Drift migration v13 for `deleted_at` on users table, UI confirmation dialog with RM picker, online-only guard |
| FEAT-07 | Dashboard quick activity logging via bottom sheet is functional | Already complete -- dashboard "Log Aktivitas" routes to ActivityFormScreen with immediate=true. Only cleanup needed: remove dead QuickAddSheet, add clarifying comments |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Supabase Edge Functions (Deno) | JSR @supabase/supabase-js@2 | Server-side user deletion with service_role key | Existing pattern from admin-create-user and admin-reset-password |
| Drift | Current (schema v12 -> v13) | Local database migration for users.deleted_at column | Project's SQLite ORM |
| Riverpod (code gen) | Current | State management for admin user deletion flow | Project standard |
| GoRouter | Current | Navigation for admin screens | Project standard |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| supabase_flutter | Current | Calling Edge Functions from client | Admin operations |
| connectivity_plus | Current (via ConnectivityService) | Online-only guard for delete operation | Check before allowing delete |

## Architecture Patterns

### Edge Function Pattern (admin-delete-user)
**What:** New Edge Function following exact same boilerplate as admin-create-user / admin-reset-password: CORS headers, JWT verification, role check (ADMIN/SUPERADMIN), body parsing, service_role client for data operations.

**Key difference from create/reset:** The delete function performs a multi-table server-side transaction:
1. Validate self-delete not attempted
2. Reassign subordinates to deleted user's parent (update `parent_id`)
3. Transfer customers (`assigned_rm_id`)
4. Transfer pipelines (`assigned_rm_id`, `scored_to_user_id`)
5. Transfer activities (`user_id` only, NOT `created_by`)
6. Transfer HVCs (`created_by`)
7. Transfer Brokers (`created_by`)
8. Transfer pipeline referrals (`referrer_rm_id`, `receiver_rm_id`)
9. Soft-delete user_targets and user_scores (set `deleted_at` or archive)
10. Set `is_active = false` and `deleted_at = now()` on users table
11. Ban user from Supabase Auth (updateUserById with `ban_duration: '87600h'` -- 10 years)

**Why server-side transaction:** All data reassignment must be atomic. If any step fails, nothing should change. The service_role key is needed for multi-table updates that bypass RLS.

### Ownership Column Reference Map
**What:** The specific columns that reference a user ID across all business tables.

| Table | Column | Transfer Rule |
|-------|--------|--------------|
| `customers` | `assigned_rm_id` | Transfer to new RM |
| `customers` | `created_by` | Keep original (audit trail) |
| `pipelines` | `assigned_rm_id` | Transfer to new RM |
| `pipelines` | `scored_to_user_id` | Transfer to new RM |
| `pipelines` | `created_by` | Keep original (audit trail) |
| `pipelines` | `referred_by_user_id` | Keep original (historical referral) |
| `activities` | `user_id` | Transfer to new RM |
| `activities` | `created_by` | Keep original (audit trail) |
| `hvcs` | `created_by` | Transfer to new RM (ownership field for HVCs) |
| `brokers` | `created_by` | Transfer to new RM (ownership field for Brokers) |
| `pipeline_referrals` | `referrer_rm_id` | Transfer to new RM |
| `pipeline_referrals` | `receiver_rm_id` | Transfer to new RM |
| `cadence_meetings` | `facilitator_id` | Keep as-is (historical) |
| `cadence_meetings` | `created_by` | Keep as-is (historical) |
| `user_hierarchy` | `ancestor_id`, `descendant_id` | Delete rows for deleted user |
| `user_targets` | `user_id` | Soft-delete (set deleted_at or equivalent) |
| `user_scores` | `user_id` | Soft-delete (set deleted_at or equivalent) |
| `user_score_aggregates` | `user_id` | Keep historical (for leaderboard history) |

### Admin Delete UI Flow
**What:** Two-step dialog pattern for user deletion.
**Step 1:** Confirmation dialog asking "Are you sure you want to delete {userName}?" with a SearchableDropdown for selecting the replacement RM. The dropdown lists all active users except the one being deleted. Submit button disabled until an RM is selected.
**Step 2:** Processing indicator while Edge Function executes. On success: navigate to user list, show toast. On error: show error toast.

### Online-Only Guard Pattern
**What:** Check connectivity before allowing delete operation.
**How:** Read `connectivityStreamProvider` (already available in sync_providers.dart). If offline, show error dialog explaining deletion requires internet connection.

### User List Filter for Deleted Users
**What:** Add a toggle filter to `UserListScreen` to optionally show deleted users.
**How:** The existing `allUsersProvider` calls `getAllUsers({includeInactive: false})` which queries the remote Supabase `users` table with `is_active = true` filter. Need to add a `deleted_at IS NULL` filter in the remote data source, plus an optional `includeDeleted` toggle on the user list screen.

### Drift Migration v13: Add deleted_at to Users
**What:** Local SQLite migration to add `deleted_at` nullable DateTime column to the `users` table.
**How:** Standard Drift migration pattern matching v12 (add column):
```dart
if (from < 13) {
  await m.addColumn(users, users.deletedAt);
}
```
Also add the `deletedAt` column to the Users Drift table definition.

### Scoring Data Handling (Claude's Discretion)
**Recommendation:** Keep `user_targets` and `user_scores` records intact but exclude them from active queries by filtering on `users.deleted_at IS NULL` in the scoring aggregation queries. Do NOT add `deleted_at` to user_targets/user_scores tables themselves -- the user's `deleted_at` flag on the users table is sufficient. The 4DX scoring model benefits from keeping historical data for period comparison, and the data is already keyed by period, so old periods with the deleted user's scores remain valid historical records.

**Rationale:** The score-aggregation-cron Edge Function already queries by period and user. Simply excluding deleted users from future period calculations (by checking `users.deleted_at IS NULL` in the join) preserves historical accuracy while stopping future scoring.

### Deleted User Name Display (Claude's Discretion)
**Recommendation:** Keep original name as-is in all historical records. The lookup patterns already work (user records remain in the users table, just soft-deleted). No "(Dihapus)" suffix needed because:
1. The user is still in the database, just marked deleted
2. All existing name lookup providers (supervisorNameProvider, user name caches in repositories) still work
3. Admin user list shows deleted users with a filter, so names are always resolvable

### Restorability (Claude's Discretion)
**Recommendation:** Do NOT implement restore functionality. The deletion flow deactivates the auth account, reassigns all data, and marks deleted_at. Undoing this would require reassigning data back (impossible -- the new RM may have modified it) and reactivating the auth account. Keep it simple: deletion is permanent. If needed, create a new user account.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Multi-table data reassignment | Client-side cascade with multiple Supabase calls | Single Edge Function with service_role key | Atomicity, security, performance |
| Auth account deactivation | Custom token invalidation | Supabase `auth.admin.updateUserById` with `ban_duration` | Proper session invalidation |
| Online connectivity check | Custom socket pinging | Existing `ConnectivityService` / `connectivityStreamProvider` | Already implemented and tested |
| RM selection dropdown | Custom user picker | Existing `SearchableDropdown` widget with `allUsersProvider` | Consistent UI pattern |

**Key insight:** The Edge Function is the critical piece -- it must handle the entire reassignment + deletion atomically. The Flutter client is just a thin UI layer that calls it.

## Common Pitfalls

### Pitfall 1: Forgetting to Handle HVC/Broker Ownership via `created_by`
**What goes wrong:** HVCs and Brokers use `created_by` as their ownership field (no `assigned_rm_id`), which is different from Customers/Pipelines. If you only transfer `assigned_rm_id` columns, HVCs and Brokers become orphaned.
**Why it happens:** Inconsistent column naming across entity types.
**How to avoid:** Explicitly transfer `created_by` on hvcs and brokers tables, per the ownership column reference map above.
**Warning signs:** HVCs/brokers disappearing from new RM's list after previous RM is deleted.

### Pitfall 2: Transferring `created_by` Audit Fields
**What goes wrong:** If `created_by` on customers/pipelines/activities is transferred, audit trail is destroyed.
**Why it happens:** Conflating "ownership" with "authorship."
**How to avoid:** Only transfer ownership columns (`assigned_rm_id`, `user_id`, `scored_to_user_id`). Leave `created_by` on customers/pipelines/activities intact. Transfer `created_by` ONLY on HVCs and Brokers where it serves as the ownership field.

### Pitfall 3: Not Deactivating Auth Account
**What goes wrong:** Deleted user can still log in if only `deleted_at` is set on the users table.
**Why it happens:** Supabase Auth is separate from the users table.
**How to avoid:** Use `auth.admin.updateUserById` with `ban_duration: '87600h'` (10 years) to effectively disable the account. Also set `is_active = false` on users table for the existing deactivation pattern.

### Pitfall 4: Self-Delete Not Blocked
**What goes wrong:** Admin accidentally deletes themselves, gets locked out.
**Why it happens:** Missing validation in Edge Function.
**How to avoid:** Edge Function MUST check `targetUserId !== callerUserId` and return 400 error. Flutter UI should also hide/disable delete action for current user.

### Pitfall 5: Offline Delete Attempt
**What goes wrong:** User tries to delete while offline; Edge Function call fails silently or with confusing error.
**Why it happens:** Admin operations are online-only but the UI doesn't make this clear.
**How to avoid:** Check `connectivityStreamProvider` before showing the delete dialog. If offline, show a clear Indonesian error: "Hapus pengguna membutuhkan koneksi internet."

### Pitfall 6: Subordinate Reassignment Order
**What goes wrong:** If subordinates are not reassigned before the user is deleted, they lose their parent reference.
**Why it happens:** The `user_hierarchy` table has CASCADE FK, so deleting the ancestor row may cascade incorrectly.
**How to avoid:** In the Edge Function, FIRST reassign subordinates to the deleted user's parent (update `parent_id` on users table), THEN clear the user_hierarchy entries for the deleted user, THEN soft-delete.

### Pitfall 7: Pipeline Referral Edge Cases
**What goes wrong:** Active referrals where the deleted user is referrer or receiver may become invalid.
**Why it happens:** Referral status workflow expects valid user IDs.
**How to avoid:** Transfer both `referrer_rm_id` and `receiver_rm_id` to the new RM. For active/pending referrals, this effectively assigns the new RM as the referral party.

### Pitfall 8: Migration Not Adding Column to Table Definition
**What goes wrong:** Drift migration adds the column but the table class definition in `users.dart` doesn't have `deletedAt`. Build_runner generates code without the field.
**Why it happens:** Migration and table definition are separate files.
**How to avoid:** Add `DateTimeColumn get deletedAt => dateTime().nullable()();` to the Users Drift table class AND add the migration step. Then run `build_runner`.

## Code Examples

### Edge Function Pattern (admin-delete-user)
```typescript
// Follows exact same boilerplate as admin-create-user
// Key payload:
interface DeleteUserRequest {
  userId: string       // User to delete
  newRmId: string      // Replacement RM for data reassignment
}

// Core logic (inside try block after auth/role checks):
// 1. Validate
if (targetUserId === user.id) {
  return error(400, 'Cannot delete yourself')
}

// 2. Get deleted user's parent for subordinate reassignment
const { data: targetUser } = await adminClient
  .from('users')
  .select('parent_id')
  .eq('id', targetUserId)
  .single()

// 3. Reassign subordinates to deleted user's parent
await adminClient
  .from('users')
  .update({ parent_id: targetUser.parent_id, updated_at: now })
  .eq('parent_id', targetUserId)

// 4-8. Transfer business data (customers, pipelines, activities, etc.)
// ... bulk updates per ownership column reference map

// 9. Soft-delete user
await adminClient
  .from('users')
  .update({ is_active: false, deleted_at: now, updated_at: now })
  .eq('id', targetUserId)

// 10. Ban auth account
await adminClient.auth.admin.updateUserById(targetUserId, {
  ban_duration: '87600h'
})
```

### Drift Migration v13
```dart
// In app_database.dart, increment schemaVersion to 13
int get schemaVersion => 13;

// In onUpgrade:
if (from < 13) {
  await m.addColumn(users, users.deletedAt);
}
```

### Users Table Definition Update
```dart
// In lib/data/database/tables/users.dart
class Users extends Table {
  // ... existing columns ...
  DateTimeColumn get deletedAt => dateTime().nullable()();
  // ...
}
```

### User Entity Update
```dart
// In lib/domain/entities/user.dart
@freezed
class User with _$User {
  const factory User({
    // ... existing fields ...
    DateTime? deletedAt,
  }) = _User;

  // Add helper:
  bool get isDeleted => deletedAt != null;
}
```

### Online-Only Guard in Delete Handler
```dart
Future<void> _handleDelete(User user) async {
  // Check connectivity first
  final isConnected = ref.read(connectivityStreamProvider).valueOrNull ?? false;
  if (!isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hapus pengguna membutuhkan koneksi internet'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Check self-delete
  final currentUser = await ref.read(currentUserProvider.future);
  if (currentUser?.id == user.id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak dapat menghapus akun sendiri'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Show confirmation dialog with RM picker...
}
```

### Delete Confirmation Dialog with RM Picker
```dart
// Two-step dialog: pick replacement RM, then confirm
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Hapus Pengguna'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hapus ${user.name}? Semua data akan dipindahkan ke RM pengganti.'),
        const SizedBox(height: 16),
        SearchableDropdown<String>(
          label: 'RM Pengganti',
          hint: 'Pilih RM pengganti...',
          modalTitle: 'Pilih RM Pengganti',
          // items: active users excluding the user being deleted
        ),
      ],
    ),
    actions: [
      TextButton(onPressed: () => context.pop(), child: const Text('Batal')),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Colors.red),
        onPressed: selectedRmId != null ? () => _executeDelete() : null,
        child: const Text('Hapus'),
      ),
    ],
  ),
);
```

### Remote Data Source Delete Method
```dart
// In admin_user_remote_data_source.dart
Future<void> deleteUser(String userId, String newRmId) async {
  final response = await _client.functions.invoke(
    'admin-delete-user',
    body: {
      'userId': userId,
      'newRmId': newRmId,
    },
  );

  if (response.status != 200) {
    final error = response.data['error'] ?? 'Unknown error';
    throw Exception('Failed to delete user: $error');
  }
}
```

### Repository + Provider Pattern
```dart
// In admin_user_repository.dart (interface)
Future<Result<void>> deleteUser(String userId, String newRmId);

// In admin_user_repository_impl.dart
@override
Future<Result<void>> deleteUser(
  String userId, String newRmId,
) => runCatching(() async {
  await _remoteDataSource.deleteUser(userId, newRmId);
}, context: 'deleteUser');

// In admin_user_providers.dart (AdminUserNotifier)
Future<void> deleteUser(String userId, String newRmId) async {
  final repository = ref.read(adminUserRepositoryProvider);
  final result = await repository.deleteUser(userId, newRmId);

  switch (result) {
    case Success():
      ref.invalidate(allUsersProvider);
    case ResultFailure(:final failure):
      throw Exception(failure.message);
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `_handleDelete` shows TODO toast | Full delete with Edge Function + reassignment | Phase 9 | FEAT-06 complete |
| `QuickAddSheet` widget (unused) | `ActivityFormScreen` with `immediate=true` | Phase 8 | Dead code removal |

**Already completed (not to be touched):**
- Dashboard "Log Aktivitas" button: already routes to `/home/activities/create?immediate=true`
- Activities tab flash FAB: already routes to `${RoutePaths.activityCreate}?immediate=true`
- `ImmediateActivitySheet`: used from entity detail screens (customer, HVC, broker) -- separate purpose

## Open Questions

1. **Supabase Transaction Support in Edge Functions**
   - What we know: Supabase Edge Functions use the Supabase JS client which makes individual API calls. There is no built-in multi-table transaction wrapper in the Supabase JS SDK for Edge Functions.
   - What's unclear: Whether a single Edge Function can wrap all updates in a PostgreSQL transaction via `rpc()` call to a database function, or if we need to rely on individual UPDATE calls.
   - Recommendation: Use individual UPDATE statements in the Edge Function. If any UPDATE fails, return error. The partial-update risk is acceptable because (a) reassignment is idempotent (running again with same params gives same result) and (b) the soft-delete of the user is the LAST step, so partial failure means the user is still active and the admin can retry. For maximum safety, consider creating a PostgreSQL function (`admin_delete_user_cascade`) called via `rpc()` that wraps everything in a transaction.

2. **UserScoreAggregates for Deleted Users**
   - What we know: `user_score_aggregates` contains historical leaderboard snapshots per period.
   - What's unclear: Whether the scoreboard UI currently filters by `users.is_active` or `users.deleted_at`.
   - Recommendation: Keep aggregate records intact. The scoreboard already works with historical data. Just ensure future score calculations skip deleted users.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `admin-create-user/index.ts`, `admin-reset-password/index.ts` -- Edge Function pattern
- Codebase analysis: `admin_user_remote_data_source.dart` -- client-side Edge Function calling pattern
- Codebase analysis: `admin_user_repository_impl.dart` -- Result<T> + runCatching pattern
- Codebase analysis: `user_detail_screen.dart` -- existing delete TODO at line 366
- Codebase analysis: `user_list_screen.dart` -- existing filter/search patterns
- Codebase analysis: Database tables -- ownership column mapping verified across all entity tables
- Codebase analysis: `app_database.dart` -- migration pattern (v12 current, v13 next)
- Codebase analysis: `dashboard_tab.dart` line 365 -- quick activity already routes correctly
- Codebase analysis: `quick_add_sheet.dart` -- confirmed dead code (only self-references)

### Secondary (MEDIUM confidence)
- Supabase Auth admin API: `auth.admin.updateUserById` with `ban_duration` for account deactivation (based on Supabase docs pattern used in admin-reset-password)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all technologies already in use in the project, patterns established by Phase 8 and existing admin screens
- Architecture: HIGH -- Edge Function pattern is well-established with two existing examples; ownership columns verified via codebase grep
- Pitfalls: HIGH -- derived from actual codebase analysis of column names and FK relationships

**Research date:** 2026-02-23
**Valid until:** 2026-03-23 (stable -- project-specific patterns, no external dependency changes)
