# LeadX CRM

## What This Is

A mobile-first, offline-first CRM application for PT Askrindo's sales team implementing the 4 Disciplines of Execution (4DX) framework. Built with Flutter (iOS, Android, Web) and Supabase backend. Sales reps use it in the field to manage customers, track pipeline activities, and measure performance against team targets.

## Core Value

Sales reps can reliably capture and access customer data in the field regardless of connectivity — data is never lost, always available, and syncs transparently when online.

## Requirements

### Validated

<!-- Shipped and confirmed valuable. -->

- ✓ User authentication with Supabase GoTrue (login, session persistence, password recovery) — existing
- ✓ Role-based access control (Superadmin, Admin, Manager, RM) with route guards — existing
- ✓ Customer management (create, edit, search, list with filtering) — existing
- ✓ Key person management linked to customers — existing
- ✓ Pipeline management (create, edit, stage tracking) — existing
- ✓ Pipeline referral tracking — existing
- ✓ Activity tracking (create, list, detail view with photos) — existing
- ✓ HVC (High Value Contact) management — existing
- ✓ Broker management — existing
- ✓ 4DX scoring system (measure definitions, user targets, user scores) — existing
- ✓ Scoreboard with period-based aggregation — existing
- ✓ Cadence meeting management — existing
- ✓ Admin panel: user management (create via Edge Function, password reset) — existing
- ✓ Admin panel: period and measure management — existing
- ✓ Admin panel: team target assignment — existing
- ✓ Local SQLite database via Drift with 30+ tables — existing
- ✓ Sync queue architecture (queue operations, process FIFO) — existing
- ✓ Initial sync on first login — existing
- ✓ Reactive UI via Drift streams + Riverpod StreamProviders — existing
- ✓ GPS-based customer visit verification — existing
- ✓ Responsive layout (mobile + web shell) — existing

### Active

<!-- Current scope. Building toward these. -->

- [ ] Sync operates reliably without data loss, duplicates, or silent failures
- [ ] Proper conflict resolution when local and remote data diverge
- [ ] All screens function fully when offline with cached data
- [ ] Typed error handling throughout — no raw exceptions reaching UI
- [ ] Sync queue pruning and lifecycle management
- [ ] Complete customer detail actions (share, delete, phone, email)
- [ ] Complete activity editing flow
- [ ] Complete phone/email launch from HVC and activity screens
- [ ] Notification settings screen and routing
- [ ] Admin user deletion
- [ ] Reports and help screen navigation
- [ ] Dashboard quick activity logging

### Out of Scope

<!-- Explicit boundaries. Includes reasoning to prevent re-adding. -->

- New feature development beyond completing stubbed features — stability first
- CI/CD pipeline setup — manual deployment acceptable for now
- Error tracking service integration (Sentry, etc.) — consider after stability milestone
- Analytics integration — defer until app is deployed and stable
- OAuth/social login — email/password sufficient for enterprise use
- Real-time collaborative editing — single-user-per-record model is fine

## Context

- **Team**: PT Askrindo sales team (enterprise insurance company)
- **Users**: Relationship Managers (field sales), Managers, Admins
- **Environment**: Field sales reps often work in areas with poor or no connectivity
- **Prior state**: Significant codebase built but not yet deployed; several features stubbed out
- **Key concern areas** (from codebase analysis):
  - Sync timestamp fields inconsistent across entities (`lastSyncAt` vs `syncedAt` vs none)
  - Initial sync race condition (static flag not thread-safe)
  - N+1 query pattern in cadence meeting stats
  - Sync queue never pruned (grows indefinitely)
  - Generic `throw Exception()` in providers loses error type information
  - Connectivity polling every 30s may drain battery

## Constraints

- **Tech stack**: Flutter + Supabase + Drift — established, not changing
- **Offline-first**: All data operations must work offline; this is non-negotiable for field sales
- **Code generation**: Freezed, Riverpod, Drift, JSON serialization — must run `build_runner` after model changes
- **Soft deletes**: Business data uses `deleted_at` timestamps, never hard deletes
- **Architecture**: Clean Architecture layers (presentation/domain/data) — maintain separation

## Key Decisions

<!-- Decisions that constrain future work. Add throughout project lifecycle. -->

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Focus on stability before new features | Unreliable sync/offline undermines all other value | — Pending |
| Complete stubbed features after stability | Features half-done create user confusion | — Pending |
| Keep last-write-wins conflict resolution for now | Full CRDT/merge is complex; last-write-wins sufficient for single-user-per-record | — Pending |
| Maintain offline-first pattern for all fixes | Every fix must preserve the write-local-first-sync-later contract | — Pending |

---
*Last updated: 2026-02-13 after initialization*
