# Architecture

**Analysis Date:** 2026-02-13

## Pattern Overview

**Overall:** Clean Architecture with offline-first synchronization and reactive state management.

**Key Characteristics:**
- **Layered separation**: Presentation (UI) → Domain (business logic) → Data (persistence & sync)
- **Reactive streams**: Drift SQLite watches + Riverpod providers for real-time UI updates
- **Offline-first pattern**: Write to local DB immediately, queue sync operations, pull from remote when online
- **Repository pattern**: All data access abstracted behind interfaces for testability
- **Functional error handling**: `Either<Failure, T>` for operations that can fail (from dartz package)

## Layers

**Presentation Layer:**
- Purpose: Flutter UI widgets, screens, and state management
- Location: `lib/presentation/`
- Contains: Screens, reusable widgets, Riverpod providers
- Depends on: Riverpod, Domain entities, Presentation providers
- Used by: Main app and router

**Domain Layer:**
- Purpose: Business entities, repository interfaces, and use-case abstractions
- Location: `lib/domain/`
- Contains: Freezed entities, repository interfaces, enums, sync models
- Depends on: None (pure Dart, no external dependencies)
- Used by: Data layer (implements interfaces), Presentation layer (uses entities)

**Data Layer:**
- Purpose: Concrete implementations for data persistence, sync, and remote APIs
- Location: `lib/data/`
- Contains: Repository implementations, local/remote data sources, Drift database, services, DTOs
- Depends on: Domain interfaces, Drift, Supabase, SyncService
- Used by: Domain repositories, Presentation providers

**Core Layer:**
- Purpose: Shared utilities, constants, themes, error definitions
- Location: `lib/core/`
- Contains: AppTheme, AppColors, AppConstants, Failures, Validators
- Depends on: Flutter framework
- Used by: All layers

**Config Layer:**
- Purpose: Application initialization and routing configuration
- Location: `lib/config/`
- Contains: Environment configuration, route definitions (GoRouter), route names
- Depends on: Presentation screens, Auth state
- Used by: `main.dart` and `app.dart`

## Data Flow

**Create/Update/Delete Flow (Offline-First):**

1. User submits form in Presentation Screen (e.g., `CustomerFormScreen`)
2. Screen calls repository method: `repository.createCustomer(dto)`
3. Repository implementation in `lib/data/repositories/`:
   - Creates UUID for new record
   - Inserts into local Drift database (`_localDataSource.createCustomer()`)
   - Queues sync operation: `_syncService.queueOperation(type: create, payload: dto)`
   - Returns `Either<Failure, Customer>` entity to UI
4. Drift table emits change event (if providers watching this entity)
5. Background SyncService processes queue when online:
   - Retrieves pending items from `sync_queue` table
   - Uploads to Supabase via remote data source
   - Updates `is_pending_sync` flag when complete
   - Handles retries with exponential backoff
6. UI reads from local database only via `StreamProvider`

**Read Flow (Reactive):**

1. Screen creates `StreamProvider` watching repository method (e.g., `customerListStreamProvider`)
2. Provider watches: `customerRepository.watchAllCustomers()`
3. Repository delegates to: `_localDataSource.watchAllCustomers()`
4. Local data source queries Drift: `_db.select(_db.customers).watch()`
5. Drift emits changes via `Stream<List<Customer>>`
6. Repository maps database entities to domain entities
7. Provider delivers stream to UI
8. UI rebuilds automatically on each emission

**Sync Pull Flow (Initial & Background):**

1. `SyncNotifier.triggerSync()` or `InitialSyncService.performInitialSync()`
2. Calls `_syncService.triggerSync()` → `_pullFromRemote()`
3. For each repository (Customer, Pipeline, Activity, etc.):
   - Remote DS fetches data: `remoteDataSource.fetchCustomers(since: lastSync)`
   - Maps API JSON to DTOs
   - Upserts into Drift database (overwrites with server copy)
   - Invalidates lookup caches: `repository.invalidateCaches()`
4. UI auto-updates via watching streams (no manual invalidation needed for Drift-backed providers)

**State Management Stack:**

1. **Auth state**: `authStateProvider` (AsyncValue) - current user, session
2. **Repository state**: Not stored separately - lives in Drift tables
3. **UI-driven state**: `StateNotifier` (e.g., `SyncNotifier` for sync progress)
4. **Sync state stream**: `syncStateStreamProvider` from `SyncService._stateController`
5. **Connectivity state**: `connectivityStreamProvider` from `ConnectivityService`

## Key Abstractions

**Repository Pattern:**
- Purpose: Abstract all data access behind interfaces
- Examples: `lib/domain/repositories/customer_repository.dart` (interface), `lib/data/repositories/customer_repository_impl.dart` (implementation)
- Pattern: Repository watches local DS, also takes remote DS and sync service for orchestration

**Data Source Abstraction:**
- Purpose: Separate local (Drift) from remote (Supabase) operations
- Examples: `lib/data/datasources/local/customer_local_data_source.dart`, `lib/data/datasources/remote/customer_remote_data_source.dart`
- Pattern: Local DS uses Drift queries; remote DS uses Supabase REST client

**Entity-DTO Separation:**
- Purpose: Domain entities (Freezed) separate from API/database DTOs
- Domain entities: `lib/domain/entities/customer.dart` - clean, no sync fields
- DTOs: `lib/data/dtos/customer_dtos.dart` - includes camelCase JSON keys for Supabase
- Sync DTOs: Include `@JsonKey(name: 'snake_case')` for PostgreSQL column mapping
- Mappers: `lib/data/mappers/` handles DTO → Entity conversions

**Sync Service:**
- Purpose: Manages offline queue, retry logic, and conflict resolution
- Location: `lib/data/services/sync_service.dart`
- State flow: Idle → Syncing → Success/Error, emits via `_stateController`
- Queue processing: FIFO with exponential backoff (max 5 retries, base 1000ms)

**Local Database (Drift):**
- Purpose: Type-safe SQLite with hot-reload schemas
- Location: `lib/data/database/app_database.dart` (main DB class) + `lib/data/database/tables/` (table definitions)
- Tables: 50+ tables grouped by domain (Users, Customers, Pipelines, Scoring, etc.)
- Features: `watch()` streams for reactive updates, soft deletes via `deleted_at`, sync tracking

## Entry Points

**Main Entry Point:**
- Location: `lib/main.dart`
- Triggers: App startup
- Responsibilities: Initialize dotenv, Supabase, locale formatting, wrap in ProviderScope

**App Entry Point:**
- Location: `lib/app.dart`
- Triggers: After main.dart
- Responsibilities: Build MaterialApp with GoRouter, apply theme, watch auth state for redirects

**Router/Navigation Entry Point:**
- Location: `lib/config/routes/app_router.dart`
- Triggers: Every route change
- Responsibilities: Define all routes (GoRouter), auth redirects (splash → login → home), admin guards

**Splash/Auth Flow Entry Point:**
- Location: `lib/presentation/screens/auth/splash_screen.dart`
- Triggers: On app launch before login
- Responsibilities: Check auth state, initialize initial sync if needed

**Home Screen Entry Point:**
- Location: `lib/presentation/screens/home/home_screen.dart`
- Triggers: After successful auth
- Responsibilities: Render main navigation (4 tabs), check for pending initial sync

## Error Handling

**Strategy:** Functional error handling with `Either<Failure, T>` for fallible operations.

**Patterns:**

1. **Service/Repository Level:**
   ```dart
   // In repository implementation
   Future<Either<Failure, Customer>> createCustomer(CustomerCreateDto dto) async {
     try {
       final entity = await _localDataSource.createCustomer(dto);
       await _syncService.queueOperation(...);
       return Right(entity);
     } catch (e) {
       return Left(DatabaseFailure(message: 'Failed to create customer'));
     }
   }
   ```

2. **UI Level (Screen/Widget):**
   ```dart
   // In screen notifier or state
   final result = await repository.createCustomer(dto);
   result.fold(
     (failure) => showSnackBar(failure.message),
     (customer) => context.pop(),
   );
   ```

3. **Failure Hierarchy:** `lib/core/errors/failures.dart`
   - Base: `Failure` (message, originalError)
   - Subtypes: `AuthFailure`, `NetworkFailure`, `DatabaseFailure`, `ValidationFailure`, `ServerFailure`
   - Token expiry: `TokenExpiredFailure` triggers redirect to login

4. **Sync Error Handling:**
   - Retry logic: Exponential backoff (1s, 2s, 4s, 8s, 16s) up to 5 attempts
   - Failed items remain in `sync_queue` table
   - UI shows pending count via `pendingSyncCountProvider`
   - Manual retry available via `SyncNotifier.triggerSync()`

## Cross-Cutting Concerns

**Logging:**
- Approach: `debugPrint()` for development, prefixed with module name (e.g., `[SyncService]`, `[CustomerFormScreen]`)
- No production logging framework; output goes to console during development/testing

**Validation:**
- Location: `lib/core/utils/validators.dart`
- Used in: Form screens (TextFormField validators), DTO creation
- Patterns: Email regex, required fields, number ranges

**Authentication:**
- Approach: Supabase GoTrue with JWT tokens
- Provider: `currentUserProvider` via `authStateProvider`
- Session persistence: Automatic via Supabase (stored in device keychain)
- Token refresh: Automatic via Supabase client
- Admin checks: `isAdminProvider` used in route guards

**Authorization:**
- Approach: Role-based (admin vs. regular user)
- Route guards: `_adminGuard()` in router redirects non-admins to unauthorized screen
- Data filtering: Repositories filter by `current_user_id` for most data

**Connectivity Handling:**
- Service: `ConnectivityService` in `lib/data/services/connectivity_service.dart`
- Detects: Online/offline state via Supabase auth session
- Triggers: Background sync only when connected
- UI indicator: `connectivityStreamProvider` shows connection status

**Caching:**
- Lookup caches: Some repositories (Pipeline, Activity) cache name lookups to avoid repeated remote calls
- Methods: `repository.invalidateCaches()` called after sync pulls
- Not used: Drift-backed StreamProviders use DB as source of truth (no manual cache invalidation)

---

*Architecture analysis: 2026-02-13*
