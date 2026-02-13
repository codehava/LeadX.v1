# External Integrations

**Analysis Date:** 2026-02-13

## APIs & External Services

**Supabase (Primary Backend):**
- PostgreSQL relational database
  - Schema: `supabase/migrations/` contain 17+ migrations
  - Tables: 30+ entities (users, customers, pipelines, activities, scoring, cadence, etc.)
  - Row-level security (RLS) for data access control
  - Client: `supabase_flutter` 2.8.3
  - Connection: Via `SupabaseClient` initialized in `lib/main.dart` with URL and anon key
  - Env vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY` from `.env`

**Supabase Real-time (Subscriptions):**
- Real-time change streams for collaborative features
- Used by Drift repositories to watch for remote updates
- Integrated via `supabase_flutter` SDK

**Supabase Auth (PKCE Flow):**
- User authentication and session management
- JWT-based tokens with refresh logic
- Password recovery flow with email links
- Email magic links (if enabled in Supabase settings)
- OAuth integration ready (config in Supabase console)
- Implementation: `lib/data/repositories/auth_repository_impl.dart`
- Auth state stream: `appAuthStateProvider` in `lib/presentation/providers/auth_providers.dart`

**Supabase Edge Functions:**
- Server-side functions running Deno runtime
- Deployed to: `https://ouhzsezcgtexsevostaw.supabase.co/functions/v1/{function-name}`
- Authentication: Via Bearer token (JWT from user session)
- CORS: Enabled for all origins

Available Functions:
  - **admin-create-user** - Creates new user in Auth + users table
    - Endpoint: `POST /functions/v1/admin-create-user`
    - Requires: ADMIN or SUPERADMIN role
    - Input: `{email, name, nip, role, phone?, parentId?, branchId?, regionalOfficeId?}`
    - Output: `{user: {...}, temporaryPassword: string}`
    - Implementation: `supabase/functions/admin-create-user/index.ts`
    - Uses service_role key for secure admin operations

  - **admin-reset-password** - Resets user password (admin only)
    - Endpoint: `POST /functions/v1/admin-reset-password`
    - Requires: ADMIN or SUPERADMIN role
    - Input: `{userId: string}`
    - Output: `{temporaryPassword: string}`
    - Implementation: `supabase/functions/admin-reset-password/index.ts`
    - Uses service_role key for secure password updates

  - **score-aggregation-cron** - Background cron for scoring aggregates
    - Trigger: Scheduled periodically (cron config in supabase.json)
    - Updates user_score_aggregates table
    - Implementation: `supabase/functions/score-aggregation-cron/index.ts`

- Deployment: `supabase functions deploy` or via Supabase CLI

See `supabase/functions/README.md` for detailed Edge Functions documentation.

## Data Storage

**Databases:**
- **Primary:** Supabase PostgreSQL (remote)
  - Connection: `SupabaseClient` via `supabase_flutter` SDK
  - Auth method: JWT (from Supabase Auth)
  - URL env var: `SUPABASE_URL`
  - Anon key env var: `SUPABASE_ANON_KEY`
  - Client: Supabase JavaScript SDK wrapped in flutter package

- **Local Cache:** Drift SQLite (offline-first)
  - Database file: Platform-specific (iOS: Documents, Android: getApplicationDocumentsDirectory)
  - Schema: `lib/data/database/app_database.dart` (@DriftDatabase)
  - Tables: Generated from `lib/data/database/tables/` definitions
  - Sync: Bi-directional with PostgreSQL via SyncService
  - Access: Via Drift generated code (watch, get, update, delete methods)
  - ORM: Type-safe Dart code generation

**File Storage:**
- **Activity Photos:**
  - Local storage: `{appDir}/activity_photos/` directory
  - Managed by: `lib/data/services/camera_service.dart`
  - Lifecycle: Photos uploaded to Supabase storage via SyncService
  - Storage path: Supabase Storage bucket (bucket name TBD, likely `activity_photos` or `uploads`)
  - Access: Supabase storage API via SupabaseClient
  - Permissions: Subject to RLS and role-based access control

**Caching:**
- **Network Image Cache:**
  - Library: `cached_network_image` 3.4.1
  - Purpose: Cache remote images (logos, avatars, etc.)
  - Default cache location: Platform-specific temp directory
  - Duration: 30 days (default)

- **In-Memory Lookup Caches:**
  - Repositories maintain name-to-ID caches (e.g., `_stageNameCache`, `_userNameCache`)
  - Examples: `PipelineRepositoryImpl`, `ActivityRepositoryImpl`
  - Must be invalidated after sync: `repository.invalidateCaches()`
  - See CLAUDE.md for cache management pattern

- **Auth Session Cache:**
  - Supabase handles session persistence via platform-specific storage
  - Flutter Android/iOS: Native secure storage
  - Flutter Web: LocalStorage + IndexedDB via Supabase JS SDK
  - Invalidation: Only for currentUserProvider after profile sync

## Authentication & Identity

**Auth Provider:**
- Supabase Auth (PostgRES-native)
  - Method: PKCE flow (more secure for mobile apps)
  - Session persistence: Platform-specific
  - JWT tokens: Stored in Supabase session storage
  - Refresh logic: Automatic via Supabase SDK
  - Password reset: Via email link (edge function generated)

**User Roles:**
- SUPERADMIN - System administrator
- ADMIN - Admin user (can manage users, periods, measures)
- MANAGER - Team manager (can view team scores, assign targets)
- RM - Relationship Manager / Sales representative
- User table: `users` with role column (enum-like)
- Role-based access: Enforced via RLS policies on Supabase

**Authentication Flow:**
1. User enters email/password on login screen
2. Supabase Auth validates credentials
3. JWT token issued and stored in session
4. User profile loaded from `users` table
5. Auth state emitted to UI via `appAuthStateProvider`
6. Password recovery: Email link triggers `passwordRecovery` event in auth

Implementation: `lib/data/repositories/auth_repository_impl.dart`

## Monitoring & Observability

**Error Tracking:**
- Not detected - No Sentry, Bugsnag, or similar integration

**Logs:**
- Local: `flutter_logs` and `logger` 2.5.0 package
  - Debug output: `debugPrint()` throughout codebase
  - Logger setup: `logger` package usage (see `lib/data/services/`)
  - Local log capture: Not configured for file storage
- Remote: Supabase system_errors table logs server-side issues
  - Table: `system_errors` (created in `supabase/migrations/20260206000003_system_errors_table.sql`)
  - Purpose: Audit trail for sync errors, permission violations, etc.
  - Access: Admin only via RLS

**Analytics:**
- Not detected - No Google Analytics, Mixpanel, or similar

## CI/CD & Deployment

**Hosting:**
- **Web:** Vercel (SPA deployment with rewrite rules)
  - Config: `web/vercel.json` (output directory: `build/web`, rewrite to `/index.html`)
  - Deployment: `flutter build web --release` then push to Vercel
  - Domain: Likely linked to Vercel project

- **iOS:** Apple App Store (manual via App Store Connect)
  - Build: `flutter build ios --release`
  - Distribution: TestFlight or direct App Store

- **Android:** Google Play Store (manual via Google Play Console)
  - Build: `flutter build apk --release`
  - Distribution: Google Play Store

- **Backend:** Supabase Cloud (managed PostgreSQL + Edge Functions)
  - PostgreSQL: Supabase-managed (backups, scaling, SSL)
  - Edge Functions: Deployed via `supabase functions deploy`

**CI Pipeline:**
- Not detected - No GitHub Actions, GitLab CI, or similar configured
- Manual deployment implied

**Local Development:**
```bash
flutter pub get                                # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Generate code
flutter run                                    # Debug on emulator/device
flutter run -d chrome                          # Debug web version
```

## Environment Configuration

**Required Env Vars:**
- `SUPABASE_URL` - Project URL (e.g., `https://ouhzsezcgtexsevostaw.supabase.co`)
- `SUPABASE_ANON_KEY` - Anonymous API key for client-side operations

**Secrets Location:**
- `.env` file (bundled with app, committed to repo)
- Supabase service_role key: **NOT in .env** - stored on Supabase servers (Edge Functions only)
- See `.env.example` for template

**Configuration Files:**
- `lib/config/env/env_config.dart` - Runtime config access (singleton)
- `analysis_options.yaml` - Analyzer rules (strict, excludes generated code)
- `pubspec.yaml` - Dependencies and asset declarations
- `supabase.json` - Supabase project config (cron, functions, etc.)

## Webhooks & Callbacks

**Incoming:**
- Supabase Edge Functions receive webhook-style POST requests
  - `admin-create-user`, `admin-reset-password` accept HTTP POST with JSON
  - Authentication: Bearer token (JWT from client)
  - CORS: Enabled for all origins via `corsHeaders` in edge functions

**Outgoing:**
- **Supabase Realtime subscriptions** - Subscribes to DB changes (not webhooks)
  - Used by Drift repositories to trigger local updates
  - Connection: WebSocket via Supabase client
  - Channel: Per-table or per-row subscriptions via RLS

- **Email notifications** - Supabase Auth can send emails
  - Password reset emails (via Supabase email templates)
  - Configuration: In Supabase project settings (SMTP provider)
  - Status: Likely configured but not evident in code

**Background Jobs:**
- Sync Service (`lib/data/services/sync_service.dart`)
  - Triggers when connectivity changes (FIFO queue processing)
  - Syncs pending creates/updates/deletes to Supabase
  - Exponential backoff with max 5 retries
  - Runs in app process (not external job queue)

- Score Aggregation (`supabase/functions/score-aggregation-cron/index.ts`)
  - Background cron job (server-side)
  - Recalculates user score aggregates
  - Trigger: Scheduled frequency (see supabase.json)

## Data Sync Strategy

**Offline-First Pattern:**
1. Write to local Drift database immediately (optimistic)
2. Queue operation in sync_queue table
3. When online, SyncService processes queue FIFO
4. Sync sends HTTP requests to Supabase Edge Functions or REST API
5. Conflict resolution: Last-write-wins (timestamp-based)
6. UI reads from local Drift only (via StreamProviders)

**Sync Queue:**
- Table: `sync_queue` in local Drift database
- Fields: entityType, entityId, operation (create|update|delete), payload, retryCount, lastError
- See `lib/domain/entities/sync_models.dart` for `SyncOperation` enum
- Processing: `lib/data/services/sync_service.dart` - `SyncService.processQueue()`

**Entity Sync Properties:**
- `is_pending_sync` - Boolean flag (true while queued)
- `last_sync_at` - Timestamp of last successful sync
- `deleted_at` - Soft delete timestamp (never hard delete)

---

*Integration audit: 2026-02-13*
