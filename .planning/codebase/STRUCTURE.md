# Codebase Structure

**Analysis Date:** 2026-02-13

## Directory Layout

```
lib/
├── main.dart                           # Entry point: init Supabase, load .env
├── app.dart                            # MaterialApp with GoRouter and theme
├── config/
│   ├── env/
│   │   └── env_config.dart            # Environment variables from .env
│   └── routes/
│       ├── app_router.dart            # GoRouter definition with auth redirects
│       └── route_names.dart           # RoutePaths constants (all route paths)
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants (pagination, timeouts, sync)
│   │   └── api_constants.dart         # Supabase table names and endpoints
│   ├── errors/
│   │   └── failures.dart              # Failure hierarchy (AuthFailure, NetworkFailure, etc.)
│   ├── theme/
│   │   ├── app_theme.dart            # Light/dark theme definitions
│   │   ├── app_colors.dart           # Color palette
│   │   └── app_typography.dart       # Text styles
│   └── utils/
│       ├── validators.dart           # Form validators (email, required, etc.)
│       └── [other utilities]         # Date formatting, extensions, etc.
├── data/
│   ├── database/
│   │   ├── app_database.dart         # Main Drift database class (@DriftDatabase)
│   │   └── tables/
│   │       ├── users.dart            # Users, UserHierarchy, RegionalOffices, Branches
│   │       ├── master_data.dart      # CompanyTypes, Industries, PipelineStages, etc.
│   │       ├── customers.dart        # Customers, KeyPersons
│   │       ├── pipelines.dart        # Pipelines, PipelineReferrals
│   │       ├── activities.dart       # Activities, ActivityPhotos, ActivityAuditLogs
│   │       ├── scoring.dart          # MeasureDefinitions, ScoringPeriods, UserScores
│   │       ├── cadence.dart          # CadenceScheduleConfig, CadenceMeetings, etc.
│   │       ├── sync_queue.dart       # SyncQueue (pending operations)
│   │       └── [other domain tables] # HVCs, Brokers, Notifications, etc.
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── customer_local_data_source.dart
│   │   │   ├── pipeline_local_data_source.dart
│   │   │   ├── activity_local_data_source.dart
│   │   │   ├── sync_queue_local_data_source.dart
│   │   │   └── [other entities]_local_data_source.dart
│   │   └── remote/
│   │       ├── customer_remote_data_source.dart
│   │       ├── pipeline_remote_data_source.dart
│   │       ├── activity_remote_data_source.dart
│   │       └── [other entities]_remote_data_source.dart
│   ├── dtos/
│   │   ├── customer_dtos.dart        # CustomerCreateDto, CustomerUpdateDto, CustomerSyncDto
│   │   ├── pipeline_dtos.dart        # PipelineCreateDto, PipelineUpdateDto, etc.
│   │   ├── activity_dtos.dart        # ActivityCreateDto, ActivityUpdateDto, etc.
│   │   ├── admin/
│   │   │   └── user_management_dtos.dart  # Admin-only DTOs
│   │   └── [other domain]_dtos.dart
│   ├── mappers/
│   │   └── [entity]_mapper.dart      # DTO → Entity conversion helpers
│   ├── repositories/
│   │   ├── customer_repository_impl.dart
│   │   ├── pipeline_repository_impl.dart
│   │   ├── activity_repository_impl.dart
│   │   ├── auth_repository_impl.dart
│   │   ├── admin_user_repository_impl.dart
│   │   ├── admin_4dx_repository_impl.dart
│   │   ├── scoreboard_repository_impl.dart
│   │   └── [other entities]_repository_impl.dart
│   └── services/
│       ├── sync_service.dart         # Offline queue processing, retry logic
│       ├── connectivity_service.dart # Online/offline detection
│       ├── initial_sync_service.dart # First sync after login
│       ├── gps_service.dart          # GPS location capture
│       ├── camera_service.dart       # Camera integration
│       └── app_settings_service.dart # Local preferences (sync flags, etc.)
├── domain/
│   ├── entities/
│   │   ├── customer.dart             # @freezed Customer entity
│   │   ├── pipeline.dart             # @freezed Pipeline entity
│   │   ├── activity.dart             # @freezed Activity entity
│   │   ├── user.dart                 # @freezed User entity
│   │   ├── key_person.dart           # @freezed KeyPerson entity
│   │   ├── hvc.dart                  # @freezed HVC entity
│   │   ├── broker.dart               # @freezed Broker entity
│   │   ├── cadence.dart              # @freezed Cadence entity
│   │   ├── pipeline_referral.dart    # @freezed PipelineReferral entity
│   │   ├── scoring_entities.dart     # @freezed MeasureDefinition, UserTarget, UserScore
│   │   ├── sync_models.dart          # SyncQueue, SyncEntityType, SyncOperation
│   │   ├── app_auth_state.dart       # @freezed auth state (authenticated, passwordRecovery, etc.)
│   │   └── audit_log_entity.dart     # @freezed ActivityAuditLog entity
│   └── repositories/
│       ├── customer_repository.dart   # Abstract CustomerRepository interface
│       ├── pipeline_repository.dart   # Abstract PipelineRepository interface
│       ├── activity_repository.dart   # Abstract ActivityRepository interface
│       ├── auth_repository.dart       # Abstract AuthRepository interface
│       ├── admin_user_repository.dart # Abstract admin user operations
│       ├── admin_4dx_repository.dart  # Abstract 4DX scoring operations
│       ├── scoreboard_repository.dart # Abstract scoreboard/leaderboard
│       └── [other entities]_repository.dart
└── presentation/
    ├── providers/
    │   ├── auth_providers.dart        # authStateProvider, currentUserProvider, isAdminProvider
    │   ├── database_provider.dart     # databaseProvider (singleton AppDatabase)
    │   ├── sync_providers.dart        # syncServiceProvider, SyncNotifier, syncStateStreamProvider
    │   ├── connectivity_providers.dart # connectivityServiceProvider, isConnectedProvider
    │   ├── customer_providers.dart    # customerRepositoryProvider, customerListStreamProvider
    │   ├── pipeline_providers.dart    # pipelineRepositoryProvider, pipelineListStreamProvider
    │   ├── activity_providers.dart    # activityRepositoryProvider, activityStreamProvider
    │   ├── master_data_providers.dart # Master data lookups (companies, industries, etc.)
    │   ├── profile_providers.dart     # currentUserProvider, profileNotifierProvider
    │   ├── settings_providers.dart    # themeModeNotifierProvider, appSettingsProvider
    │   ├── gps_providers.dart         # gpsServiceProvider
    │   ├── admin/
    │   │   ├── admin_4dx_providers.dart  # Scoring providers
    │   │   └── [other admin providers]
    │   ├── [other feature]_providers.dart # broker, hvc, cadence, referral, etc.
    │   └── _providers.dart pattern    # Follow "feature_name" + "providers" naming
    ├── screens/
    │   ├── auth/
    │   │   ├── splash_screen.dart     # Startup, auth check, initial sync trigger
    │   │   ├── login_screen.dart      # Email/password auth
    │   │   ├── forgot_password_screen.dart
    │   │   └── reset_password_screen.dart
    │   ├── home/
    │   │   ├── home_screen.dart       # Main screen with tab navigation
    │   │   ├── tabs/
    │   │   │   ├── dashboard_tab.dart      # Dashboard/home tab
    │   │   │   ├── customers_tab.dart      # Customers list tab
    │   │   │   ├── activities_tab.dart     # Activities calendar/list tab
    │   │   │   └── profile_tab.dart        # User profile tab
    │   │   └── widgets/
    │   │       ├── dashboard_widgets.dart
    │   │       └── [other tab-specific widgets]
    │   ├── customer/
    │   │   ├── customer_detail_screen.dart    # View single customer
    │   │   ├── customer_form_screen.dart      # Create/edit customer (with GPS auto-capture)
    │   │   └── customer_history_screen.dart   # Activity history for customer
    │   ├── pipeline/
    │   │   ├── pipeline_list_screen.dart      # (via home tab)
    │   │   ├── pipeline_detail_screen.dart    # View pipeline
    │   │   ├── pipeline_form_screen.dart      # Create/edit pipeline
    │   │   └── pipeline_history_screen.dart
    │   ├── activity/
    │   │   ├── activity_form_screen.dart      # Create/edit activity
    │   │   ├── activity_detail_screen.dart
    │   │   └── activity_calendar_screen.dart
    │   ├── admin/
    │   │   ├── admin_home_screen.dart         # Admin dashboard
    │   │   ├── unauthorized_screen.dart       # Non-admin access attempt
    │   │   ├── users/
    │   │   │   ├── user_list_screen.dart      # Admin user management
    │   │   │   ├── user_form_screen.dart
    │   │   │   └── user_detail_screen.dart
    │   │   ├── 4dx/
    │   │   │   ├── admin_4dx_home_screen.dart
    │   │   │   ├── measures/
    │   │   │   │   ├── admin_measure_list_screen.dart
    │   │   │   │   └── admin_measure_form_screen.dart
    │   │   │   ├── periods/
    │   │   │   │   ├── admin_period_list_screen.dart
    │   │   │   │   └── admin_period_form_screen.dart
    │   │   │   └── targets/
    │   │   │       ├── admin_target_list_screen.dart
    │   │   │       └── admin_target_form_screen.dart
    │   │   ├── master_data/
    │   │   │   ├── master_data_menu_screen.dart
    │   │   │   ├── master_data_list_screen.dart
    │   │   │   └── master_data_form_screen.dart
    │   │   └── cadence/
    │   │       ├── cadence_config_list_screen.dart
    │   │       └── cadence_config_form_screen.dart
    │   ├── scoreboard/
    │   │   ├── scoreboard_screen.dart         # Main scoring dashboard
    │   │   ├── leaderboard_screen.dart        # Team leaderboard
    │   │   ├── my_targets_screen.dart         # Personal targets
    │   │   └── measure_detail_screen.dart     # View measure details
    │   ├── team_targets/
    │   │   ├── team_target_list_screen.dart
    │   │   └── team_target_form_screen.dart
    │   ├── hvc/
    │   │   ├── hvc_list_screen.dart
    │   │   ├── hvc_detail_screen.dart
    │   │   └── hvc_form_screen.dart
    │   ├── broker/
    │   │   ├── broker_list_screen.dart
    │   │   ├── broker_detail_screen.dart
    │   │   └── broker_form_screen.dart
    │   ├── referral/
    │   │   ├── referral_list_screen.dart
    │   │   ├── referral_detail_screen.dart
    │   │   ├── referral_create_screen.dart
    │   │   └── manager_approval_screen.dart
    │   ├── cadence/
    │   │   ├── cadence_list_screen.dart
    │   │   ├── cadence_detail_screen.dart
    │   │   ├── cadence_form_screen.dart
    │   │   └── host_dashboard_screen.dart
    │   ├── profile/
    │   │   ├── edit_profile_screen.dart
    │   │   ├── change_password_screen.dart
    │   │   ├── settings_screen.dart
    │   │   └── about_screen.dart
    │   └── sync/
    │       └── sync_queue_screen.dart   # Debug: show pending sync items
    └── widgets/
        ├── shell/
        │   └── responsive_shell.dart    # Shell with bottom nav (desktop/mobile)
        ├── common/
        │   ├── app_button.dart          # Reusable button components
        │   ├── app_text_field.dart      # Reusable text input
        │   ├── app_card.dart
        │   ├── app_dialog.dart
        │   ├── autocomplete_field.dart
        │   ├── loading_indicator.dart
        │   ├── discard_confirmation_dialog.dart
        │   └── [other common widgets]
        ├── cards/
        │   ├── customer_card.dart
        │   ├── pipeline_card.dart
        │   ├── activity_card.dart
        │   └── [other list cards]
        ├── layout/
        │   ├── centered_loading.dart
        │   ├── centered_error.dart
        │   └── empty_state.dart
        ├── activity/
        │   ├── activity_form_fields.dart
        │   ├── activity_photo_grid.dart
        │   └── activity_audit_log_widget.dart
        ├── pipeline/
        │   ├── pipeline_stage_selector.dart
        │   └── pipeline_status_badge.dart
        ├── scoreboard/
        │   ├── measure_card.dart
        │   ├── leaderboard_item.dart
        │   └── scoring_period_selector.dart
        ├── sync/
        │   ├── sync_progress_sheet.dart
        │   └── sync_status_indicator.dart
        ├── admin/
        │   ├── admin_navigation.dart
        │   └── measure_form_fields.dart
        └── [other feature-specific widgets]
```

## Directory Purposes

**`lib/config/env/`:**
- Purpose: Environment configuration from `.env` file
- Contains: EnvConfig class with supabaseUrl, supabaseAnonKey validation
- Key files: `env_config.dart`

**`lib/config/routes/`:**
- Purpose: Navigation routing definitions
- Contains: GoRouter configuration with auth redirects, route guards, deep linking
- Key files: `app_router.dart` (all routes), `route_names.dart` (RoutePaths constants)

**`lib/core/constants/`:**
- Purpose: App-wide constants and configuration
- Contains: Pagination sizes, API timeouts, sync parameters, Supabase table names
- Key files: `app_constants.dart`, `api_constants.dart`

**`lib/core/errors/`:**
- Purpose: Error/failure type hierarchy for functional error handling
- Contains: Failure base class, specific failure types (AuthFailure, NetworkFailure, etc.)
- Key files: `failures.dart`

**`lib/core/theme/`:**
- Purpose: Visual design system
- Contains: Light/dark theme definitions, color palette, typography
- Key files: `app_theme.dart`, `app_colors.dart`, `app_typography.dart`

**`lib/data/database/`:**
- Purpose: Local SQLite database via Drift
- Contains: AppDatabase class definition, all table definitions
- Key files: `app_database.dart` (main), `tables/*.dart` (individual table schemas)
- Generated: `app_database.g.dart` (generated by build_runner)

**`lib/data/datasources/local/`:**
- Purpose: Local database query logic
- Contains: One file per entity (e.g., CustomerLocalDataSource)
- Pattern: Methods named `watch*()` (return Stream), `get*()` (return Future), `search*()` (return Future<List>)
- Key files: One per major entity

**`lib/data/datasources/remote/`:**
- Purpose: Supabase REST API client wrappers
- Contains: One file per entity (e.g., CustomerRemoteDataSource)
- Pattern: Methods named `fetch*()`, `create*()`, `update*()`, `delete*()`
- Key files: One per major entity

**`lib/data/dtos/`:**
- Purpose: Data Transfer Objects for API/database serialization
- Contains: Create/Update/Sync DTOs per entity, marked with @freezed
- Pattern: `{Entity}CreateDto`, `{Entity}UpdateDto`, `{Entity}SyncDto`
- Key files: One per entity domain, plus `admin/` subdirectory for admin-only DTOs

**`lib/data/mappers/`:**
- Purpose: Convert between DTOs and domain entities
- Contains: Helper functions for DTO → Entity conversions
- Usage: Called by repositories when mapping local/remote data to domain entities

**`lib/data/repositories/`:**
- Purpose: Concrete repository implementations
- Contains: One file per entity implementing the repository interface
- Pattern: Orchestrates local DS, remote DS, and SyncService; maps entities
- Key files: `customer_repository_impl.dart`, `pipeline_repository_impl.dart`, etc.

**`lib/data/services/`:**
- Purpose: Cross-cutting service logic (sync, connectivity, GPS, etc.)
- Contains: SyncService (queue processing), ConnectivityService (online detection), other utilities
- Key files: `sync_service.dart` (core), `connectivity_service.dart`, `initial_sync_service.dart`

**`lib/domain/entities/`:**
- Purpose: Business domain models
- Contains: Freezed data classes representing business concepts
- Pattern: Immutable, with computed properties for UI (displayName, statusText, etc.)
- Key files: `customer.dart`, `pipeline.dart`, `activity.dart`, `user.dart`, `scoring_entities.dart`

**`lib/domain/repositories/`:**
- Purpose: Repository interface definitions
- Contains: Abstract classes defining data access contract
- Pattern: One interface per entity
- Key files: One per major entity (interfaces only, implementations in `lib/data/repositories/`)

**`lib/presentation/providers/`:**
- Purpose: Riverpod state management
- Contains: Provider definitions for repositories, services, UI state
- Pattern: Dependency injection via providers; reactive streams via StreamProvider
- Key files: `auth_providers.dart` (auth state), `database_provider.dart` (singleton DB), feature-specific providers

**`lib/presentation/screens/`:**
- Purpose: User interface screens
- Contains: One directory per feature, with screen widget(s) and optional `widgets/` subdirectory
- Pattern: Screens use ConsumerWidget/ConsumerStatefulWidget to access providers
- Key files: Feature-specific screens organized in subdirectories

**`lib/presentation/widgets/`:**
- Purpose: Reusable UI components
- Contains: `common/` for shared widgets, feature-specific subdirectories
- Pattern: Stateless/Stateful widgets, optional ConsumerWidget for provider access
- Key files: `common/` has the most reusable components

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App startup, Supabase initialization
- `lib/app.dart`: MaterialApp setup with router and theme
- `lib/config/routes/app_router.dart`: All routes and auth logic
- `lib/presentation/screens/auth/splash_screen.dart`: Initial auth check

**Core Infrastructure:**
- `lib/core/errors/failures.dart`: Error types
- `lib/core/constants/app_constants.dart`: App configuration
- `lib/data/database/app_database.dart`: SQLite database

**Data Layer Foundation:**
- `lib/data/services/sync_service.dart`: Offline queue and sync logic
- `lib/data/services/connectivity_service.dart`: Online/offline detection
- `lib/data/services/initial_sync_service.dart`: First-time data pull

**Authentication:**
- `lib/data/repositories/auth_repository_impl.dart`: Auth operations
- `lib/presentation/providers/auth_providers.dart`: Auth state providers
- `lib/presentation/screens/auth/login_screen.dart`: User login

**Example Feature (Customers):**
- Entity: `lib/domain/entities/customer.dart`
- Repository interface: `lib/domain/repositories/customer_repository.dart`
- Repository impl: `lib/data/repositories/customer_repository_impl.dart`
- Local DS: `lib/data/datasources/local/customer_local_data_source.dart`
- Remote DS: `lib/data/datasources/remote/customer_remote_data_source.dart`
- DTOs: `lib/data/dtos/customer_dtos.dart`
- Providers: `lib/presentation/providers/customer_providers.dart`
- Screens: `lib/presentation/screens/customer/` (form, detail, history)
- Widgets: `lib/presentation/widgets/cards/customer_card.dart`, etc.

## Naming Conventions

**Files:**
- Screens: `{feature}_screen.dart` (e.g., `customer_form_screen.dart`)
- Widgets: `{component_name}_widget.dart` or just `{component_name}.dart` (e.g., `customer_card.dart`)
- Providers: `{feature}_providers.dart` (e.g., `customer_providers.dart`)
- Data sources: `{entity}_{local|remote}_data_source.dart`
- Repositories: `{entity}_repository{_impl}.dart`
- DTOs: `{entity}_dtos.dart`
- Tables: `{domain_name}.dart` (contains multiple related tables)

**Directories:**
- Feature-based organization: `screens/{feature}/`, `widgets/{feature}/`
- Domain organization: `datasources/{local|remote}/`, `repositories/`, `entities/`
- Grouped by purpose: `core/{constants|errors|theme|utils}/`, `data/{database|services}/`

**Classes:**
- Screens: `{Feature}Screen` (e.g., `CustomerFormScreen`)
- Widgets: `{Component}` (e.g., `CustomerCard`)
- Data sources: `{Entity}LocalDataSource` / `{Entity}RemoteDataSource`
- Repositories: `{Entity}Repository` (interface), `{Entity}RepositoryImpl` (implementation)
- DTOs: `{Entity}CreateDto`, `{Entity}UpdateDto`, `{Entity}SyncDto`
- Tables: `class {Entity} extends Table`

## Where to Add New Code

**New Feature (e.g., adding Tasks entity):**
1. Create domain entity: `lib/domain/entities/task.dart` (@freezed)
2. Create repository interface: `lib/domain/repositories/task_repository.dart`
3. Create table: Add to `lib/data/database/tables/business_data.dart` or new file
4. Create local DS: `lib/data/datasources/local/task_local_data_source.dart`
5. Create remote DS: `lib/data/datasources/remote/task_remote_data_source.dart`
6. Create DTOs: `lib/data/dtos/task_dtos.dart`
7. Create repository impl: `lib/data/repositories/task_repository_impl.dart`
8. Create providers: `lib/presentation/providers/task_providers.dart`
9. Create screens: `lib/presentation/screens/task/` directory with form, list, detail
10. Add routes: Update `lib/config/routes/app_router.dart` with new paths
11. Run code generation: `dart run build_runner build --delete-conflicting-outputs`

**New Screen within existing feature:**
1. Create screen file: `lib/presentation/screens/{feature}/{new_screen}_screen.dart`
2. Create local widget subdirectory if needed: `lib/presentation/screens/{feature}/widgets/`
3. Add route in `lib/config/routes/app_router.dart`
4. Update navigation in parent screens/providers

**New Widget:**
1. Reusable (multi-feature): `lib/presentation/widgets/common/{widget_name}.dart`
2. Feature-specific: `lib/presentation/widgets/{feature}/{widget_name}.dart`
3. For screen-local widgets: Create `lib/presentation/screens/{feature}/widgets/` subdirectory

**Utilities:**
- Validators: `lib/core/utils/validators.dart`
- Extensions/formatters: `lib/core/utils/extensions.dart` or new file in `lib/core/utils/`
- Constants: Add to appropriate file in `lib/core/constants/`

## Special Directories

**`lib/data/database/tables/`:**
- Purpose: Drift table definitions organized by domain
- Generated: `app_database.g.dart` is auto-generated (do not edit)
- Committed: Yes, table definitions are source code
- Pattern: Each file groups related tables (e.g., `scoring.dart` has MeasureDefinitions, ScoringPeriods, UserScores)

**`lib/data/database/`:**
- Purpose: SQLite database definition
- Generated: `app_database.g.dart` from `app_database.dart` by build_runner
- Committed: Source file yes, generated file yes (versioned in git)
- Build: Run `dart run build_runner build --delete-conflicting-outputs` after schema changes

**`lib/presentation/providers/`:**
- Purpose: All Riverpod provider definitions
- Generated: No code generation for providers (unlike entities/DTOs)
- Committed: Yes
- Pattern: Define in feature files, import from screens/widgets

**Root level configuration:**
- `.env`: Environment variables (not committed, loaded at runtime)
- `pubspec.yaml`: Dependencies and build configuration
- `build.yaml`: Build runner configuration (optional, rarely modified)

---

*Structure analysis: 2026-02-13*
