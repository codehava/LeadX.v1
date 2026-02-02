# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LeadX CRM is a mobile-first, offline-first CRM application for PT Askrindo sales team implementing the 4 Disciplines of Execution (4DX) framework. Built with Flutter for cross-platform deployment (iOS, Android, Web) with Supabase backend.

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run code generators (Drift, Freezed, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation (during development)
dart run build_runner watch --delete-conflicting-outputs

# Run the app (debug)
flutter run

# Run the app for web
flutter run -d chrome

# Build for release
flutter build apk --release
flutter build ios --release
flutter build web --release

# Run tests
flutter test

# Run a single test file
flutter test test/data/repositories/customer_repository_impl_test.dart

# Analyze code
flutter analyze
```

## Architecture

### Layer Structure (Clean Architecture)

```
lib/
├── main.dart                    # Entry point, Supabase init
├── app.dart                     # MaterialApp with Riverpod
├── config/
│   ├── env/                     # Environment configuration (.env)
│   └── routes/                  # GoRouter configuration
├── core/
│   ├── constants/               # App and API constants
│   ├── errors/                  # Failures and exceptions
│   └── theme/                   # AppTheme, AppColors, AppTypography
├── data/
│   ├── database/                # Drift (SQLite) database and tables
│   ├── datasources/
│   │   ├── local/               # Local data sources (Drift)
│   │   └── remote/              # Remote data sources (Supabase)
│   ├── dtos/                    # Data Transfer Objects (Freezed)
│   ├── repositories/            # Repository implementations
│   └── services/                # SyncService, ConnectivityService, etc.
├── domain/
│   ├── entities/                # Business entities (Freezed)
│   └── repositories/            # Repository interfaces
└── presentation/
    ├── providers/               # Riverpod providers
    ├── screens/                 # Screen widgets by feature
    └── widgets/                 # Reusable UI components
```

### Offline-First Pattern

All data operations follow this pattern:
1. **Write to local database first** (Drift/SQLite) - immediate UI feedback
2. **Queue operation in sync_queue** - tracks pending syncs
3. **Trigger background sync** - uploads when online
4. **UI reads from local database only** - via Riverpod streams

The `SyncService` processes the queue FIFO, handling retries and conflict resolution.

### Key Technologies

| Layer | Technology |
|-------|------------|
| State Management | Riverpod with code generation (`@riverpod`) |
| Navigation | GoRouter (declarative, deep linking) |
| Local Database | Drift (type-safe SQLite, WASM for web) |
| Backend | Supabase (PostgreSQL, Auth, Realtime) |
| Models | Freezed (immutable) + JSON serializable |
| Authentication | Supabase GoTrue with JWT |

### Database Schema

Local SQLite schema mirrors PostgreSQL backend. Key table groups:
- **Organization**: users, user_hierarchy, regional_offices, branches
- **Master Data**: company_types, industries, pipeline_stages, activity_types, etc.
- **Business Data**: customers, key_persons, pipelines, activities
- **4DX Scoring**: measure_definitions, user_targets, user_scores

Generated files are in `lib/data/database/app_database.g.dart`.

### Providers Pattern

Providers are defined in `lib/presentation/providers/`. The hierarchy:
1. **Database/Service providers** - singleton instances
2. **Repository providers** - depend on data sources + sync service
3. **State providers** - watch repositories, expose to UI

Example: `customerListProvider` watches `CustomerRepository.watchAllCustomers()`.

## Code Generation

This project heavily uses code generation. After modifying any of these, run `build_runner`:
- `*.freezed.dart` - Freezed models (`@freezed`)
- `*.g.dart` - JSON serialization, Riverpod generators, Drift tables
- DTOs in `lib/data/dtos/`
- Entities in `lib/domain/entities/`
- Database tables in `lib/data/database/tables/`

## Testing

Tests use `mocktail` for mocking. Test structure mirrors `lib/`:
```
test/
├── data/repositories/           # Repository unit tests
├── data/services/               # Service unit tests
├── integration/                 # Flow tests (customer, pipeline, sync)
├── presentation/screens/        # Widget tests
└── helpers/                     # Test utilities and mocks
```

## Environment Configuration

The app loads `.env` at startup (bundled as asset). Required variables:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Supabase Edge Functions

Admin operations that require elevated privileges (user creation, password reset) use Edge Functions. These run server-side with the `service_role` key.

### Deployment

```bash
# Deploy all functions
supabase functions deploy

# Deploy specific function
supabase functions deploy admin-create-user
supabase functions deploy admin-reset-password
```

### Available Functions

- **admin-create-user**: Creates new user with Supabase Auth + users table
- **admin-reset-password**: Generates temporary password for user

See `supabase/functions/README.md` for detailed documentation, API specs, and troubleshooting.

### Why Edge Functions?

Admin API operations (`auth.admin.createUser`, `auth.admin.updateUserById`) require the `service_role` key which must never be exposed client-side. Edge Functions keep this key secure on the server while allowing admins to perform privileged operations.

## Key Patterns to Follow

1. **Repository pattern**: All data access goes through repositories (interfaces in `domain/`, implementations in `data/`)
2. **Entity-DTO separation**: Domain entities (Freezed) are separate from database/API models
3. **Soft deletes**: Use `deleted_at` timestamp, never hard delete business data
4. **Sync status**: All syncable entities have `is_pending_sync` and `last_sync_at` columns
5. **Functional error handling**: Use `Either<Failure, T>` from dartz for operations that can fail
6. **Cache invalidation**: Required to prevent stale UI data. Follow these rules:
   - **Repository caches**: If a repository has in-memory lookup caches (e.g., `_stageNameCache`, `_userNameCache`), it MUST have an `invalidateCaches()` method that clears them
   - **After sync operations**: Call `repository.invalidateCaches()` after pulling data from remote in `SyncNotifier._pullFromRemote()`
   - **After mutations in notifiers**: Call `ref.invalidate()` on affected stream providers after successful create/update/delete operations
   - **Example repositories with caches**: `PipelineRepositoryImpl`, `ActivityRepositoryImpl`, `PipelineReferralRepositoryImpl`
   - **Provider invalidation**: `SyncNotifier._invalidateDataProviders()` invalidates all list stream providers after sync completion
