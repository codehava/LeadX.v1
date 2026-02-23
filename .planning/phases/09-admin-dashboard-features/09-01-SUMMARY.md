---
phase: 09-admin-dashboard-features
plan: 01
subsystem: admin, database, api
tags: [edge-function, supabase, drift, sqlite, soft-delete, user-management]

requires:
  - phase: 08-stubbed-feature-completion
    provides: Complete admin user management screens (create, edit, deactivate)
provides:
  - Edge Function admin-delete-user with 10-step cascade reassignment
  - Drift schema v13 with deletedAt column on users table
  - User entity with deletedAt field and isDeleted computed property
  - Full data layer chain for deleteUser (remote DS -> repository -> provider)
  - fetchAllUsers filters soft-deleted users by default
affects: [09-02, admin-ui, user-management]

tech-stack:
  added: []
  patterns: [edge-function-cascade-delete, soft-delete-with-auth-ban]

key-files:
  created:
    - supabase/functions/admin-delete-user/index.ts
  modified:
    - lib/data/database/tables/users.dart
    - lib/data/database/app_database.dart
    - lib/domain/entities/user.dart
    - lib/data/datasources/remote/admin_user_remote_data_source.dart
    - lib/domain/repositories/admin_user_repository.dart
    - lib/data/repositories/admin_user_repository_impl.dart
    - lib/presentation/providers/admin_user_providers.dart

key-decisions:
  - "Edge Function performs 10-step cascade: reassign subordinates, customers, pipelines, activities, HVCs, brokers, referrals, then soft-delete user, then ban auth"
  - "Soft-delete is intentionally LAST so partial failures leave user active (admin can retry since reassignment is idempotent)"
  - "user_targets and user_scores NOT modified — historical scoring data preserved, deletedAt flag sufficient for exclusion"
  - "created_by fields preserved on customers/pipelines/activities for audit trail; only ownership fields reassigned"
  - "Auth ban uses 87600h (10 years) via adminClient.auth.admin.updateUserById"

patterns-established:
  - "Edge Function cascade pattern: validate → reassign all related data → soft-delete → ban auth"
  - "includeDeleted parameter pattern for fetchAll queries that need to optionally show soft-deleted records"

requirements-completed: [FEAT-06]

duration: ~15min
completed: 2026-02-23
---

# Plan 09-01: Admin Delete User Backend Infrastructure Summary

**Edge Function with 10-step cascade data reassignment + Drift v13 deletedAt column + full deleteUser data layer chain**

## Performance

- **Duration:** ~15 min (across interrupted session)
- **Tasks:** 2
- **Files modified:** 11 (including generated files)

## Accomplishments
- Edge Function `admin-delete-user` implements full cascade: subordinate reassignment, business data transfer (customers, pipelines, activities, HVCs, brokers, referrals), soft-delete, and auth ban
- Drift schema upgraded to v13 with `deletedAt` nullable column on users table
- User entity has `deletedAt` field and `isDeleted` computed property
- Complete data layer chain: `AdminUserRemoteDataSource.deleteUser` → `AdminUserRepository.deleteUser` → `AdminUserNotifier.deleteUser`
- `fetchAllUsers` filters `deleted_at IS NULL` by default with `includeDeleted` parameter

## Task Commits

1. **Task 1: Create admin-delete-user Edge Function and update Drift schema** - `b027603`
2. **Task 2: Wire data layer — remote data source, repository, and provider for deleteUser** - `6da035b`

## Files Created/Modified
- `supabase/functions/admin-delete-user/index.ts` - Server-side user deletion with cascading data reassignment
- `lib/data/database/tables/users.dart` - Users Drift table with deletedAt column
- `lib/data/database/app_database.dart` - Schema v13 migration
- `lib/domain/entities/user.dart` - User entity with deletedAt and isDeleted
- `lib/data/datasources/remote/admin_user_remote_data_source.dart` - deleteUser remote call + includeDeleted filter
- `lib/domain/repositories/admin_user_repository.dart` - deleteUser interface
- `lib/data/repositories/admin_user_repository_impl.dart` - deleteUser implementation + deletedAt mapping
- `lib/presentation/providers/admin_user_providers.dart` - deleteUser in AdminUserNotifier

## Decisions Made
- Edge Function cascade order matches CONTEXT.md locked decisions exactly
- Soft-delete last for retry safety (reassignment is idempotent)
- Historical scoring data (user_targets, user_scores) preserved — deletedAt flag sufficient
- `created_by` preserved on all entities for audit trail; only ownership fields (assigned_rm_id, user_id, etc.) reassigned
- Auth ban duration: 87600h (10 years) via Supabase admin API

## Deviations from Plan
None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
Edge Function needs deployment: `supabase functions deploy admin-delete-user`

## Next Phase Readiness
- Backend infrastructure complete for admin user deletion
- Ready for 09-02: UI layer (delete confirmation dialog, user list filter, dead code cleanup)

---
*Phase: 09-admin-dashboard-features*
*Completed: 2026-02-23*
