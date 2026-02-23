---
phase: 09-admin-dashboard-features
plan: 02
subsystem: ui, admin
tags: [flutter, riverpod, user-management, soft-delete, dead-code-cleanup]

requires:
  - phase: 09-admin-dashboard-features/01
    provides: Edge Function admin-delete-user, deleteUser data layer chain, deletedAt on User entity
provides:
  - Admin delete confirmation dialog with SearchableDropdown RM picker
  - Online guard and self-delete guard on delete action
  - User list toggle filter for showing soft-deleted users
  - QuickAddSheet dead code removed
  - Clarifying comments on both quick activity entry points
affects: [admin-ui, user-management]

tech-stack:
  added: []
  patterns: [online-guard-for-destructive-operations, deleted-user-filter-toggle]

key-files:
  created: []
  modified:
    - lib/presentation/screens/admin/users/user_detail_screen.dart
    - lib/presentation/screens/admin/users/user_list_screen.dart
    - lib/presentation/providers/admin_user_providers.dart
    - lib/presentation/screens/home/tabs/activities_tab.dart
    - lib/presentation/screens/activity/immediate_activity_sheet.dart
  deleted:
    - lib/presentation/screens/home/widgets/quick_add_sheet.dart

key-decisions:
  - "Online guard defaults to ?? true (connected) matching OfflineBanner convention (03-03) to avoid false offline on stream init"
  - "verify_jwt = false required in config.toml for all admin Edge Functions — gateway JWT check conflicts with in-function auth.getUser() verification"
  - "Supabase PostgreSQL requires explicit ALTER TABLE for deleted_at column — Drift migration only covers local SQLite"
  - "Deleted users shown with Opacity(0.5) and 'Dihapus' badge in user list"
  - "Delete menu item hidden for already-deleted users"

patterns-established:
  - "Online guard pattern for destructive online-only operations: read connectivityStreamProvider.valueOrNull ?? true"
  - "Deleted entity filter toggle pattern: StateProvider<bool> + IconButton toggle in app bar"

requirements-completed: [FEAT-06, FEAT-07]

duration: ~20min
completed: 2026-02-23
---

# Plan 09-02: Admin Delete UI + User List Filter + Dead Code Cleanup Summary

**Delete confirmation dialog with SearchableDropdown RM picker, online/self-delete guards, user list deleted filter, and QuickAddSheet removal**

## Performance

- **Duration:** ~20 min (including bug fixes during verification)
- **Tasks:** 3 (2 auto + 1 human-verify checkpoint)
- **Files modified:** 7 (including 1 deleted)

## Accomplishments
- Admin can delete a user via confirmation dialog with SearchableDropdown RM reassignment picker
- Online guard blocks delete when offline with Indonesian error message
- Self-delete guard blocks deleting own account
- Delete menu hidden for already-deleted users; "Dihapus" badge shown on detail screen
- User list has toggle (person_off icon) to show/hide deleted users with dimmed styling and "Dihapus" badge
- QuickAddSheet dead code file deleted
- Clarifying comments on both quick activity entry points (activities tab FAB vs ImmediateActivitySheet)

## Task Commits

1. **Task 1: Delete dialog with RM picker + user list filter** - `8a9d5c1`
2. **Task 2: QuickAddSheet removal + clarifying comments** - `9632f88`

**Bug fixes during verification:**
3. **Fix: connectivity default** - `a817cf0` (online guard false positive)
4. **Fix: config.toml verify_jwt** - `426882e` (gateway JWT rejection)
5. **Docs: Supabase migration + README** - `a13f05d` (missing server-side column)

## Files Created/Modified
- `lib/presentation/screens/admin/users/user_detail_screen.dart` - Delete flow with guards, RM picker dialog
- `lib/presentation/screens/admin/users/user_list_screen.dart` - Deleted users filter toggle
- `lib/presentation/providers/admin_user_providers.dart` - activeUsersProvider, showDeletedUsersProvider
- `lib/presentation/screens/home/tabs/activities_tab.dart` - Clarifying comment on flash FAB
- `lib/presentation/screens/activity/immediate_activity_sheet.dart` - Clarifying doc comment
- `lib/presentation/screens/home/widgets/quick_add_sheet.dart` - DELETED (dead code)
- `supabase/config.toml` - verify_jwt=false for admin-delete-user
- `supabase/migrations/20260223000001_add_users_deleted_at.sql` - Server-side migration
- `supabase/functions/README.md` - admin-delete-user API documentation

## Decisions Made
- Online guard uses `?? true` default matching OfflineBanner convention (avoids false offline on stream init)
- All admin Edge Functions need `verify_jwt = false` in config.toml (in-function verification via auth.getUser)
- Server-side PostgreSQL migration needed separately from Drift local migration

## Deviations from Plan

### Auto-fixed Issues

**1. Connectivity guard false positive**
- **Found during:** Human verification (Task 3)
- **Issue:** `connectivityStreamProvider.valueOrNull ?? false` defaulted to offline when stream hadn't emitted
- **Fix:** Changed to `?? true` matching OfflineBanner convention (decision 03-03)
- **Committed in:** `a817cf0`

**2. Gateway JWT rejection for new Edge Function**
- **Found during:** Human verification (Task 3)
- **Issue:** `config.toml` missing `verify_jwt = false` for admin-delete-user — gateway rejected valid JWT
- **Fix:** Added `[functions.admin-delete-user] verify_jwt = false` and redeployed
- **Committed in:** `426882e`

**3. Missing server-side deleted_at column**
- **Found during:** Human verification (Task 3)
- **Issue:** Drift migration added deletedAt locally but PostgreSQL users table lacked the column
- **Fix:** Created SQL migration file + ran ALTER TABLE on Supabase
- **Committed in:** `a13f05d`

---

**Total deviations:** 3 auto-fixed (all discovered during human verification)
**Impact on plan:** All fixes necessary for correct operation. No scope creep.

## Issues Encountered
- Edge Function deployment requires both the function code AND config.toml settings to be in sync
- Local Drift migrations and remote PostgreSQL migrations are independent — both must be done

## User Setup Required
1. Run SQL migration on Supabase: `ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;`
2. Deploy Edge Function: `npx supabase functions deploy admin-delete-user --no-verify-jwt`

## Next Phase Readiness
- Phase 09 complete — all admin dashboard features implemented
- Ready for Phase 10 (final phase)

---
*Phase: 09-admin-dashboard-features*
*Completed: 2026-02-23*
