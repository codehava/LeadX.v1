# LeadX CRM - Implementation Checklist

## 📋 Overview

This checklist provides a structured approach to developing LeadX CRM, organized by development phases and feature modules. Each feature follows a consistent implementation pattern:

1. **Data Layer** - Database tables, Drift entities, DTOs
2. **Repository Layer** - Local and remote data sources, sync logic
3. **Domain Layer** - Use cases, business logic
4. **Presentation Layer** - Providers, UI screens, widgets
5. **Testing** - Unit tests, widget tests, integration tests

**Legend:**
- ✅ `[x]` - Completed
- 🔄 `[/]` - In Progress
- ⬜ `[ ]` - Not Started

**Last Updated:** January 28, 2026

---

## 🔧 State Management Guidelines (Riverpod 2.x)

### Provider Types (Best Practice)

| Use Case | Provider Type | Example |
|----------|--------------|--------|
| Sync dependency injection | `Provider` | `supabaseClientProvider` |
| Single async fetch | `FutureProvider` | `currentUserProvider` |
| Real-time data streams | `StreamProvider` | `authStateProvider`, `customerListProvider` |
| Sync state + mutations | `Notifier` + `@riverpod` | `themeNotifier` |
| Async state + mutations | `AsyncNotifier` + `@riverpod` | `customerFormNotifier`, `loginNotifier` |
| Parameterized providers | Add `.family` modifier | `customerDetailProvider(id)` |

### Migration Notes
- ❌ **Avoid**: `StateNotifier`, `StateProvider`, `ChangeNotifier` (legacy APIs, deprecated in Riverpod 3.0)
- ✅ **Use**: `Notifier`/`AsyncNotifier` with `@riverpod` code generation
- ✅ **Use**: `ref.watch()` for reactive dependencies, `ref.read()` for one-time access
- ✅ **Use**: `ref.listen()` for side effects (navigation, snackbars)

### Code Generation Pattern
```dart
// providers/customer_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'customer_providers.g.dart';

@riverpod
class CustomerForm extends _$CustomerForm {
  @override
  FutureOr<Customer?> build() => null; // Initial state
  
  Future<void> save(CustomerDto dto) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(customerRepoProvider).create(dto));
  }
}
```

---

## 🏗️ Phase 0: Foundation ✅ COMPLETE

### Week 1: Project Setup ✅
- [x] Initialize Git repository with branching strategy
- [x] Set up GitHub Actions CI/CD pipeline (`.github/workflows/ci.yml`)
- [x] Configure linting and formatting (flutter_lints)
- [x] Create project structure following clean architecture
- [x] Set up environment configuration (EnvConfig)

### Week 2: Supabase & Database ✅
- [x] Supabase deployed on Coolify
- [x] Database schema SQL files created (4 files + migration)
- [x] RLS policies SQL file created
- [x] Run SQL files on Supabase ✅
- [x] Create test user ✅
- [x] Seed initial master data (in SQL files)
- [x] Database audit triggers ✅ (SQL: `06_audit_triggers.sql`)
  - [x] Create `log_entity_changes()` trigger function
  - [x] Apply trigger to `pipelines` table
  - [x] Apply trigger to `customers` table
  - [x] Apply trigger to `pipeline_referrals` table
  - [x] Create `pipeline_stage_history` table with auto-insert trigger
  - [x] RLS policies for audit tables (admin + hierarchical access)

### Week 3: Flutter Project Structure ✅
- [x] Set up Flutter project with Riverpod
- [x] Configure go_router for navigation
- [x] Set up Drift for local database
- [x] Create Drift table definitions (37 tables)
  - [x] `users.dart` - Users, Branches, Regions, UserHierarchy
  - [x] `customers.dart` - Customers, KeyPersons
  - [x] `pipelines.dart` - Pipelines, PipelineReferrals
  - [x] `activities.dart` - Activities, ActivityPhotos, ActivityAuditLogs
  - [x] `master_data.dart` - All master data tables (19 tables)
  - [x] `scoring.dart` - MeasureDefinitions, ScoringPeriods, UserTargets, UserScores, PeriodSummaryScores
  - [x] `cadence.dart` - CadenceScheduleConfig, CadenceMeetings, CadenceParticipants
  - [x] `notifications.dart` - Notifications, NotificationSettings, Announcements, AnnouncementReads
  - [x] `sync_queue.dart` - SyncQueueItems, AuditLogs, AppSettings
- [x] Set up code generation (build_runner)
- [x] Configure Supabase Flutter client

### Week 4: Design System ✅
- [x] Create color scheme (light/dark themes)
  - [x] `app_colors.dart` - Primary, secondary, semantic colors
  - [x] `app_theme.dart` - Light and dark theme data
- [x] Define typography scale (`app_typography.dart`)
- [x] Create common widgets library
  - [x] `AppButton` - Primary, secondary, text variants
  - [x] `AppTextField` - With validation support
  - [x] `AppCard` - Elevated, outlined, filled variants
  - [x] `AppBottomSheet` - Modal bottom sheets
  - [x] `LoadingIndicator` - Spinner with optional text
  - [x] `AppErrorState` - Error display with retry
  - [x] `AppEmptyState` - Empty list placeholder
  - [x] `SyncStatusBadge` - Sync status indicator
  - [x] `AppSearchField` - Search input
  - [x] `AppSectionHeader` - Section headers
  - [x] `SearchableDropdown` - Modal dropdown with search for long lists
- [x] Create responsive layout helpers (`responsive_layout.dart`)
- [x] Set up asset management (assets/icons, images, fonts)

---

## 🎯 Phase 1: MVP Features

### 1. Authentication Module ✅ 95% COMPLETE

#### Data Layer ✅
- [x] Create `users` Drift table
- [x] Create User domain model (`user.dart` with Freezed)
  - [x] `User` entity with all fields
  - [x] `UserRole` enum (RM, BH, BM, ROH, ADMIN)
  - [x] `AuthSession` model
- [x] Create `AppAuthState` sealed class (`app_auth_state.dart`)
  - [x] `initial` - App start state
  - [x] `authenticated` - With User
  - [x] `unauthenticated` - Logged out
  - [x] `sessionExpired` - Token expired

#### Repository Layer ✅
- [x] Create `AuthRepository` interface
  - [x] `getAuthState()` - Get current state
  - [x] `signIn(email, password)` - Login
  - [x] `signOut()` - Logout
  - [x] `getCurrentUser()` - Fetch user
  - [x] `refreshSession()` - Refresh token
  - [x] `requestPasswordReset(email)` - Send reset email
  - [x] `updatePassword(newPassword)` - Change password
  - [x] `authStateChanges()` - Stream of state changes
- [x] Implement `AuthRepositoryImpl`
  - [x] Supabase auth integration
  - [x] User profile fetch from `users` table
  - [x] Session management
  - [x] Error mapping (AuthFailure types)

#### Presentation Layer ✅
- [x] Create auth providers (`auth_providers.dart`)
  - [x] `supabaseClientProvider`
  - [x] `authRepositoryProvider`
  - [x] `authStateProvider` (Stream)
  - [x] `currentUserProvider`
  - [x] `isAuthenticatedProvider`
  - [x] `isAdminProvider`
  - [x] `currentUserRoleProvider`
  - [x] `loginNotifierProvider` with `LoginNotifier`
- [x] Implement `SplashScreen`
  - [x] Token validity check
  - [x] Auto-redirect to login/home
- [x] Implement `LoginScreen`
  - [x] Email/password form
  - [x] Form validation
  - [x] Error handling with messages
  - [x] Error handling with messages
- [x] Implement `ForgotPasswordScreen`
  - [x] Email input
  - [x] Success message
- [x] Create auth guards for navigation (`app_router.dart`)
  - [x] `authGuard` redirect logic

#### Testing ✅
- [x] Unit tests for `AuthRepositoryImpl`
  - [x] `signIn` success/failure cases
  - [x] `signOut` test
  - [x] `getCurrentUser` test
  - [x] `refreshSession` test
- [x] Widget tests for `LoginScreen`
  - [x] Form validation display
  - [x] Error state display
  - [x] Navigation on success
- [x] Widget tests for `ForgotPasswordScreen`
- [ ] Integration test for auth flow

---

### 2. Customer Module ✅ CORE COMPLETE (Phase 3-4)

#### Data Layer
**Drift Tables** ✅
- [x] `customers` table defined
- [x] `key_persons` table defined (unified for Customer/HVC/Broker)

**Domain Models** ✅
- [x] Create `Customer` domain entity (Freezed)
  - [x] All fields from Drift table
  - [x] `CustomerStatus` enum
  - [x] `toJson/fromJson` methods
- [x] Create `KeyPerson` domain entity (Freezed)
- [ ] Create `CustomerWithKeyPersons` aggregate

**DTOs** ✅
- [x] Create `CustomerCreateDto`
- [x] Create `CustomerUpdateDto`
- [x] Create `CustomerSyncDto` (for Supabase)
- [x] Create `KeyPersonDto`

**Data Sources** ✅
- [x] Create `CustomerLocalDataSource`
  - [x] `getAllCustomers()` - Stream
  - [x] `getCustomerById(id)`
  - [x] `insertCustomer(customer)`
  - [x] `updateCustomer(customer)`
  - [x] `softDeleteCustomer(id)`
  - [x] `searchCustomers(query)`
  - [x] `getCustomersByAssignedRm(rmId)`
  - [x] `getPendingSyncCustomers()`
  - [x] `markAsSynced(id, syncedAt)`
- [x] Create `CustomerRemoteDataSource`
  - [x] `fetchCustomers(since)` - Incremental sync
  - [x] `createCustomer(dto)`
  - [x] `updateCustomer(id, dto)`
  - [x] `deleteCustomer(id)`
- [x] Create `MasterDataLocalDataSource` (Phase 4)
  - [x] Provinces, Cities, CompanyTypes, OwnershipTypes, Industries
  - [x] COBs, LOBs, PipelineStages, ActivityTypes, HvcTypes

#### Repository Layer ✅
- [x] Create `CustomerRepository` interface
  - [x] `watchAllCustomers()` - Stream<List<Customer>>
  - [x] `getCustomerById(id)` - Future<Customer?>
  - [x] `createCustomer(customer)` - Future<Either<Failure, Customer>>
  - [x] `updateCustomer(customer)` - Future<Either<Failure, Customer>>
  - [x] `deleteCustomer(id)` - Future<Either<Failure, void>>
  - [x] `searchCustomers(query)` - Future<List<Customer>>
  - [x] `getCustomerKeyPersons(customerId)` - Future<List<KeyPerson>>
  - [x] `addKeyPerson(keyPerson)` - Future<Either<Failure, KeyPerson>>
  - [x] `updateKeyPerson(keyPerson)`
  - [x] `deleteKeyPerson(id)`
- [x] Implement `CustomerRepositoryImpl`
  - [x] Offline-first: Write to local, queue for sync
  - [x] Conflict resolution logic
  - [x] Error handling

#### Presentation Layer ✅
**Providers** ✅
- [x] Create `customerListProvider` (StreamProvider)
- [x] Create `customerDetailProvider` (FutureProvider.family)
- [x] Create `CustomerFormNotifier` (AsyncNotifier + @riverpod)
- [x] Create `customerSearchProvider` (Provider)
- [x] Create `keyPersonListProvider` (StreamProvider.family)
- [x] Create `masterDataProviders` (Phase 4)
  - [x] provincesStreamProvider, citiesByProvinceProvider
  - [x] companyTypesStreamProvider, ownershipTypesStreamProvider
  - [x] industriesStreamProvider, cobsStreamProvider, lobsByCobProvider

**Screens** ✅
- [x] Implement `CustomersTab` (Customer List)
  - [x] AppBar with search icon
  - [x] Search bar (expandable)
  - [x] Filter chips (Semua, Aktif, Belum Sync)
  - [x] Customer list with `CustomerCard`
    - [x] Customer name, code
    - [ ] Pipeline stage summary (Phase 5)
    - [x] Sync status indicator
    - [x] Tap to detail
  - [x] Pull-to-refresh
  - [x] FAB for create
  - [x] Empty state
  - [x] Loading state
  - [x] Error state with retry

- [x] Implement `CustomerDetailScreen`
  - [x] TabBar: Info | Key Persons | Pipelines | Activities
  - [x] **Info Tab**
    - [x] Customer details card
    - [x] Address display
    - [x] Contact info (phone, email, website)
    - [x] Company info (type, ownership, industry)
    - [ ] Assigned RM info
    - [ ] HVC links (if any)
    - [x] Edit button
  - [x] **Key Persons Tab**
    - [x] Key person list
    - [x] Add key person FAB
    - [x] Edit/delete actions
  - [x] **Pipelines Tab** ✅
    - [x] Pipeline list with stage badges
    - [x] Add pipeline FAB
    - [x] Quick stage update (via PipelineStageUpdateSheet)
    - [x] Kanban/List toggle view
  - [x] **Activities Tab** ✅
    - [x] Activity list grouped by status
    - [x] Add activity FAB (Log + Schedule)
    - [x] Execute button for pending activities
  - [x] Quick actions bar
    - [x] Call
    - [x] WhatsApp
    - [x] Email
    - [x] Navigate

- [x] Implement `CustomerFormScreen` (create/edit)
  - [x] Form fields:
    - [x] Name (required)
    - [x] Address (required)
    - [x] Province picker (required) - SearchableDropdown
    - [x] City picker (required, filtered by province) - SearchableDropdown
    - [x] Postal code
    - [x] Phone
    - [x] Email (with validation)
    - [x] Website
    - [x] Company type picker (required) - SearchableDropdown
    - [x] Ownership type picker (required) - SearchableDropdown
    - [x] Industry picker (required) - SearchableDropdown
    - [x] NPWP
  - [x] Notes
  - [x] GPS auto-capture on create (GpsService + gps_providers integrated)
  - [x] Form validation
  - [x] Save button
  - [x] Discard confirmation (PopScope + DiscardConfirmationDialog)
  - [x] Loading state during save

- [x] Implement `KeyPersonFormSheet`
  - [x] Bottom sheet modal
  - [x] Fields: name, position, department, phone, email, isPrimary, notes
  - [x] Validation
  - [x] Save/cancel buttons

**Services**
- [x] Create `GpsService`
  - [x] Permission handling
  - [x] getCurrentPosition()
  - [x] Distance calculation
  - [x] Proximity validation

**Widgets** ✅
- [x] `CustomerCard` widget

#### Testing 🔄
- [x] Unit tests for `CustomerRepositoryImpl`
  - [x] CRUD operations
  - [x] Search functionality
  - [x] Offline queue behavior
- [ ] Widget tests for `CustomerListScreen`
  - [ ] List rendering
  - [ ] Search behavior
  - [ ] Navigation to detail
- [ ] Widget tests for `CustomerFormScreen`
  - [ ] Form validation
  - [ ] GPS capture
  - [ ] Save flow

---

### 3. Sync Service Module ✅ CORE COMPLETE

#### Data Layer ✅
- [x] `sync_queue` table defined
- [x] `app_settings` table defined

**Domain Models** ✅
- [x] Create `SyncOperation` enum (CREATE, UPDATE, DELETE)
- [x] Create `SyncStatus` enum (PENDING, IN_PROGRESS, COMPLETED, FAILED)
- [x] Create `SyncQueueItem` domain entity
- [x] Create `SyncResult` model
- [x] Create `SyncState` (for UI)

**Data Sources** ✅
- [x] Create `SyncQueueLocalDataSource`
  - [x] `getPendingItems()` - FIFO order
  - [x] `addToQueue(entityType, entityId, operation, payload)`
  - [x] `markAsCompleted(id)`
  - [x] `markAsFailed(id, error)`
  - [x] `incrementRetryCount(id)`
  - [x] `clearCompletedItems(olderThan)`

#### Service Layer ✅
- [x] Implement `ConnectivityService`
  - [x] Network state stream
  - [x] `isConnected` getter
  - [x] Server reachability check (ping Supabase)
  - [x] Debounced status changes

- [x] Implement `SyncService`
  - [x] `processQueue()` - Process pending items FIFO
  - [x] `triggerSync()` - Manual sync
  - [x] `startBackgroundSync(interval)` - Periodic sync
  - [x] `stopBackgroundSync()`
  - [x] Conflict resolution (last-write-wins with timestamp)
  - [x] Retry logic with exponential backoff
  - [x] Error handling & notification
  - [x] Progress tracking

- [x] Implement `InitialSyncService`
  - [x] `performInitialSync()` - First-time data load
  - [x] Paginated fetch (50 items per page)
  - [x] Progress callback
  - [x] Master data sync (provinces, cities, etc.)
  - [x] User hierarchy sync (regional_offices, branches, users, user_hierarchy)
  - [x] Resume interrupted sync (via AppSettingsService)

#### Presentation Layer ✅
**Providers** ✅
- [x] Create `connectivityProvider` (StreamProvider)
- [x] Create `SyncStateNotifier` (AsyncNotifier + @riverpod)
- [x] Create `pendingSyncCountProvider` (Provider)
- [x] Create `lastSyncTimeProvider` (Provider)
- [x] Create `initialSyncServiceProvider`

**Widgets** ✅
- [x] Enhance `SyncStatusBadge`
  - [x] Synced state (checkmark)
  - [x] Syncing animation (spinner)
  - [x] Pending count badge
  - [x] Offline indicator (no wifi icon)
  - [ ] Error with retry (warning icon, tap to retry)
  
- [x] Create `SyncProgressSheet`
  - [x] Initial sync progress bar
  - [x] Table-by-table progress
  - [ ] Cancel button (if applicable)

- [x] Implement `SyncQueueScreen` (debug screen)
  - [x] Pending items list
  - [x] Failed items with error details
  - [x] Retry individual items
  - [x] Clear failed items

#### Testing ⬜
- [ ] Unit tests for `SyncService`
  - [ ] Queue processing order
  - [ ] Retry logic
  - [ ] Conflict resolution
**Drift Tables** ✅
- [x] `pipelines` table defined
- [x] `pipeline_referrals` table defined
- [x] `pipeline_stages` master data
- [x] `pipeline_statuses` master data

**Domain Models** ✅
- [x] Create `Pipeline` domain entity (Freezed)
  - [x] All fields from Drift table
  - [x] `stageColor` from pipeline_stages
  - [x] `stageProbability` from pipeline_stages
  - [x] `weightedValue` computed
  - [x] `customerName`, `cobName`, `lobName` for display
- [x] Create `PipelineStageInfo` entity
- [x] Create `PipelineStatusInfo` entity

**DTOs** ✅
- [x] Create `PipelineCreateDto`
- [x] Create `PipelineUpdateDto`
- [x] Create `PipelineStageUpdateDto`
- [x] Create `PipelineSyncDto`

**Data Sources** ✅
- [x] Create `PipelineLocalDataSource`
- [x] Create `PipelineRemoteDataSource`

#### Repository Layer ✅
- [x] Create `PipelineRepository` interface
  - [x] `getCustomerPipelines(customerId)`
  - [x] `getPipelineById(id)`
  - [x] `getAllPipelines()` - For dashboard
  - [x] `createPipeline(pipeline)`
  - [x] `updatePipeline(pipeline)`
  - [x] `updatePipelineStage(id, stageId, statusId)`
  - [x] `deletePipeline(id)` - Soft delete
  - [x] `getPipelineStages()` - Master data
  - [x] `getPipelineStatuses(stageId)` - Filtered by stage
  - [x] `watchAllPipelines()` - Stream
  - [x] `watchCustomerPipelines(customerId)` - Stream
- [x] Implement `PipelineRepositoryImpl`

#### Presentation Layer ✅
**Providers** ✅
- [x] Create `pipelineListStreamProvider` (StreamProvider)
- [x] Create `pipelineDetailProvider` (FutureProvider.family)
- [x] Create `pipelineStagesProvider` (FutureProvider) - Master data
- [x] Create `pipelineStatusesByStageProvider` (FutureProvider.family) - Filtered by stage
- [x] Create `customerPipelinesProvider` (StreamProvider.family)
- [x] Create `PipelineFormNotifier` (StateNotifier) - TODO: migrate to @riverpod

**Screens** ✅

> [!IMPORTANT]
> **Phase 5 Priority: CustomerDetailScreen Pipeline Tab**
> This integration requires Pipeline domain/data layer to be complete first.

- [x] Integrate pipeline list in `CustomerDetailScreen` pipelines tab
  - [x] Create `customerPipelinesProvider` (StreamProvider.family by customerId)
  - [x] Pipeline card with:
    - [x] COB/LOB display
    - [x] Stage badge with color from `pipeline_stages.color`
    - [x] Current status text
    - [x] Potential premium display (formatted currency)
    - [x] Expected close date
    - [x] Sync status indicator
  - [x] Quick stage update dropdown (move to next stage)
  - [x] Add Pipeline FAB (navigate to PipelineFormScreen with customerId)
  - [x] Tap to navigate to PipelineDetailScreen
  - [x] Empty state when no pipelines
  - [x] Loading state
  - [x] Kanban/List toggle view (SegmentedButton)

- [x] Implement `PipelineDetailScreen`
  - [x] Pipeline info card
  - [x] Customer info
  - [x] Edit button
  - [x] Quick stage update (via PipelineStageUpdateSheet)
  - [ ] Stage history timeline (future)
  - [ ] Related activities list (Phase 5)

- [x] Implement `PipelineFormScreen` (create/edit)
  - [x] Customer pre-selected (if from customer)
  - [x] Customer picker (if standalone)
  - [x] COB picker (required)
  - [x] LOB picker (required, filtered by COB)
  - [x] Lead source picker (required)
  - [x] Broker picker (conditional - if source=BROKER)
  - [x] Customer contact picker (from customer key persons)
  - [x] TSI input
  - [x] Potential premium input (required)
  - [x] Expected close date picker
  - [x] Is tender toggle
  - [x] Notes
  - [x] Form validation
  - [x] Save flow
  - [ ] Broker PIC picker (deferred to Broker feature)

- [x] Implement `PipelineStageUpdateSheet`
  - [x] Stage picker (P3 → P2 → P1 → Won/Lost)
  - [x] Status picker (filtered by stage)
  - [x] Notes field
  - [x] Decline reason input (for Lost)
  - [x] Final premium input (for Won)
  - [x] Policy number input (for Won)

**Widgets** ✅
- [x] `PipelineCard` widget
- [x] `PipelineKanbanBoard` widget

#### Testing ⬜
- [ ] Unit tests for `PipelineRepositoryImpl`
- [ ] Widget tests for `PipelineFormScreen`
- [ ] Widget tests for stage update flow

---

### 5. Activity Module ✅ 95% COMPLETE

#### Data Layer
**Drift Tables** ✅
- [x] `activities` table defined
- [x] `activity_photos` table defined
- [x] `activity_audit_logs` table defined
- [x] `activity_types` master data

**Domain Models** ✅
- [x] Create `Activity` domain entity (Freezed)
- [x] Create `ActivityStatus` enum
- [x] Create `ActivityPhoto` entity
- [x] Create `ActivityAuditLog` entity
- [x] Create `ActivityType` entity
- [x] Create `ActivityObjectType` enum (CUSTOMER, HVC, BROKER)

**DTOs** ✅
- [x] Create `ScheduledActivityDto` (scheduled)
- [x] Create `ImmediateActivityDto` (instant logging)
- [x] Create `ActivityExecutionDto`
- [x] Create `ActivityRescheduleDto`
- [x] Create `ActivityCancelDto`

**Data Sources** ✅
- [x] Create `ActivityLocalDataSource`
- [x] Create `ActivityRemoteDataSource`
- [x] Create `ActivityPhotoLocalDataSource` *(consolidated in ActivityLocalDataSource)*

#### Repository Layer ✅
- [x] Create `ActivityRepository` interface
  - [x] `getUserActivities(userId, dateRange)`
  - [x] `getCustomerActivities(customerId)`
  - [ ] `getPipelineActivities(pipelineId)`
  - [ ] `getHvcActivities(hvcId)`
  - [ ] `getBrokerActivities(brokerId)`
  - [x] `createActivity(activity)` - Scheduled
  - [x] `createImmediateActivity(activity)` - Instant
  - [x] `executeActivity(id, execution)` - Mark complete with GPS
  - [x] `rescheduleActivity(id, newDateTime, reason)`
  - [x] `cancelActivity(id, reason)`
  - [x] `getActivityTypes()`
  - [x] `getActivityAuditLogs(activityId)` - Audit logs
  - [x] `addPhoto(activityId, localPath, ...)` - Add activity photo
  - [x] `deletePhoto(photoId)` - Delete activity photo
- [x] Implement `ActivityRepositoryImpl`

#### Service Layer ✅
- [x] Implement `GpsService`
  - [x] `getCurrentPosition()` - With timeout
  - [x] `calculateDistance(lat1, lon1, lat2, lon2)`
  - [x] `validateProximity()` - Check radius
  - [x] Permission handling

- [x] Implement `CameraService`
  - [x] `capturePhoto()` - With EXIF data
  - [x] `pickFromGallery()`
  - [x] `compressImage(path)`
  - [ ] Geotag validation

#### Presentation Layer 🔄
**Providers** ✅
- [x] Create `userActivitiesProvider` (FutureProvider.family) - By user/date
- [x] Create `todayActivitiesProvider` (FutureProvider)
- [x] Create `activityWithDetailsProvider` (FutureProvider.family)
- [x] Create `customerActivitiesProvider` (FutureProvider.family)
- [x] Create `selectedDateProvider` - Calendar state
- [x] Create `calendarViewModeProvider`
- [x] Create `activityTypesProvider` (FutureProvider) - Master data
- [x] Create `gpsServiceProvider`
- [x] Create `ActivityFormNotifier` (StateNotifier)
- [x] Create `ActivityExecutionNotifier` (StateNotifier)

**Screens**

> [!NOTE]
> CustomerDetailScreen Activity Tab is fully integrated.

- [x] Integrate activity list in `CustomerDetailScreen` activities tab
  - [x] Create `customerActivitiesProvider` (FutureProvider.family by customerId)
  - [x] Activity card with:
    - [x] Activity type icon and name
    - [x] Scheduled datetime
    - [x] Status badge (PLANNED/COMPLETED/CANCELLED)
    - [x] Summary text
    - [x] GPS status (if executed)
  - [x] Group activities by status (Upcoming/Completed/Other)
  - [x] Add Activity FAB (Log Aktivitas + Jadwalkan)
  - [x] Tap to navigate to ActivityDetailScreen
  - [x] Empty state when no activities
  - [x] Loading state

- [x] Implement `ActivityCalendarScreen`
  - [x] Calendar view toggle (day/week/month)
  - [x] Activity list by selected date
  - [x] Status indicators on calendar dates
  - [ ] Quick actions from calendar
  - [x] FAB for create scheduled activity
  - [x] Pull-to-refresh

- [x] Implement `ActivityDetailScreen`
  - [x] Activity info card
  - [x] Object info (customer/HVC/broker)
  - [x] GPS data display
  - [x] Map preview (if coordinates available)
  - [x] Photos gallery (when available)
  - [x] History log (audit trail)
  - [x] Actions:
    - [x] Execute (if planned) - wired to ActivityExecutionSheet
    - [x] Reschedule - wired to ActivityRescheduleSheet
    - [x] Cancel - wired to cancel dialog

- [x] Implement `ActivityFormScreen` (scheduled)
  - [x] Object type picker (Customer/HVC/Broker)
  - [x] Object picker (based on type)
  - [x] Activity type picker
  - [x] Date picker
  - [x] Time picker
  - [x] Summary input
  - [x] Notes input
  - [x] Form validation
  - [x] Save flow

- [x] Implement `ActivityExecutionSheet`
  - [x] GPS capture (automatic)
  - [x] Distance validation display
  - [x] GPS override option (with reason required)
  - [x] Notes input
  - [x] Photo capture (based on ActivityType.requirePhoto)
  - [x] Submit button
  - [x] Cancel button
  - [x] Loading state

- [x] Implement `ImmediateActivitySheet`
  - [x] Quick activity logging
  - [x] Object info display
  - [x] Activity type quick select
  - [x] GPS auto-capture
  - [x] Notes (optional)
  - [x] Photo capture (based on ActivityType.requirePhoto)
  - [x] Submit flow

- [x] Implement `ActivityRescheduleSheet`
  - [x] New date picker
  - [x] New time picker
  - [x] Reason input (required)
  - [x] Confirm button

- [x] Implement `ActivitiesTab` (Home)
  - [x] Show calendar/list view with week date picker
  - [x] FAB for schedule/immediate activities
  - [x] Execute button on pending activities

#### Testing ⬜
- [ ] Unit tests for `ActivityRepositoryImpl`
- [ ] Unit tests for `GpsService`
- [ ] Widget tests for `ActivityCalendarScreen`
- [ ] Widget tests for execution flow
- [ ] GPS mock testing

---

### 6. Dashboard & Scoreboard Module ✅ CORE COMPLETE

#### Data Layer
**Drift Tables** ✅
- [x] `user_targets` table defined
- [x] `user_scores` table defined
- [x] `measure_definitions` table defined
- [x] `scoring_periods` table defined
- [x] `period_summary_scores` table defined

**Domain Models** ✅
- [x] Create `MeasureDefinition` entity
- [x] Create `ScoringPeriod` entity
- [x] Create `UserTarget` entity
- [x] Create `UserScore` entity
- [x] Create `PeriodSummary` entity
- [x] Create `LeaderboardEntry` entity
- [x] Create `DashboardStats` entity

**Data Sources** ✅
- [x] Create `ScoreboardLocalDataSource`
- [x] Create `ScoreboardRemoteDataSource`

#### Repository Layer ✅
- [x] Create `ScoreboardRepository` interface
  - [x] `getUserScore(userId, periodId)`
  - [x] `getUserRank(userId, periodId)`
  - [x] `getLeaderboard(periodId, limit)`
  - [x] `getUserTargets(userId, periodId)`
  - [x] `getMeasureDefinitions()`
  - [x] `getCurrentPeriod()`
  - [x] `getPeriods()` - For period selector
  - [ ] `getTeamScores(supervisorId, periodId)` - For BH/BM (future)
- [x] Implement `ScoreboardRepositoryImpl`

#### Presentation Layer
**Providers** ✅
- [x] Create `dashboardStatsProvider` - Dashboard aggregation
- [x] Create `ScoreboardNotifier` (AsyncNotifier + @riverpod)
- [x] Create `currentPeriodProvider` (FutureProvider)
- [x] Create `userScoresProvider` (FutureProvider.family)
- [x] Create `leaderboardProvider` (FutureProvider.family)

**Screens** ✅
- [x] Implement `DashboardTab`
  - [x] Welcome card
  - [x] Today's activities from data
  - [x] Active pipelines count (live)
  - [x] User ranking (live, tappable)
  - [x] Quick action buttons

- [x] Implement `ScoreboardScreen`
  - [x] Period selector
  - [x] Personal score card with ScoreGauge
  - [x] Lead measures breakdown (MeasureProgressBar)
  - [x] Lag measures breakdown
  - [x] Target vs actual display
  - [x] Rank indicator with trend
  - [x] Team leaderboard (LeaderboardCard)

**Widgets** ✅
- [x] `ScoreGauge` - Circular score indicator
- [x] `MeasureProgressBar` - Progress bar with status
- [x] `LeaderboardCard` - Leaderboard entry card

#### Testing ⬜
- [ ] Unit tests for `ScoreboardRepositoryImpl`
- [ ] Widget tests for `DashboardTab`
- [ ] Widget tests for `ScoreboardScreen`


---

### 7. History Log Module ✅ CORE COMPLETE

> [!NOTE]
> This module enables viewing historical changes for Pipeline, Customer, and other entities.
> Database triggers (Phase 0) must be deployed first to capture audit data.

#### Data Layer
**Domain Models** ✅
- [x] Create `AuditLog` domain entity (Freezed)
  - [x] id, userId, userEmail, action, targetTable, targetId
  - [x] oldValues, newValues (Map<String, dynamic>)
  - [x] createdAt
- [x] Create `PipelineStageHistory` domain entity (Freezed)
  - [x] id, pipelineId, fromStageId, toStageId
  - [x] fromStatusId, toStatusId
  - [x] notes, changedBy, changedAt
  - [x] latitude, longitude (optional GPS)

**Data Sources** ✅
- [x] Create `HistoryLogRemoteDataSource` (fetch only, no push)
  - [x] `fetchEntityHistory(table, entityId, since)` - Lazy fetch
  - [x] `fetchAuditLogs(filters, pagination)` - For admin panel
  - [x] `fetchPipelineStageHistory(pipelineId)` - With notes
- [x] Create `HistoryLogLocalDataSource` (caching)

#### Repository Layer ✅
- [x] Create `HistoryLogRepository` interface
  - [x] `getEntityHistory(table, entityId)` - Lazy fetch from Supabase
  - [x] `getPipelineStageHistory(pipelineId)` - With notes & stage names
- [x] Implement `HistoryLogRepositoryImpl`
  - [x] Lazy fetch on demand (not part of regular sync)
  - [x] Cache locally after first fetch
  - [x] Invalidate cache when entity is updated

#### Presentation Layer ✅
**Providers**
- [x] Create `entityHistoryProvider(table, entityId)` - FutureProvider.family
- [x] Create `pipelineStageHistoryProvider(pipelineId)` - FutureProvider.family
- [ ] Create `adminAuditLogsProvider` - AsyncNotifier for admin panel (deferred)

**Widgets**
- [x] Create `HistoryLogCard` widget
  - [x] Action icon/badge (CREATE, UPDATE, DELETE)
  - [x] User name and timestamp
  - [x] Changes summary
  - [x] Expandable details view
- [x] Create `HistoryTimeline` widget
  - [x] Vertical timeline layout
  - [x] Grouped by date
  - [x] Lazy loading for long histories
- [x] Create `StageHistoryCard` widget (Pipeline specific)
  - [x] Stage badges (from → to)
  - [x] Notes display
  - [x] GPS indicator if captured
- [x] Create `StageHistoryTimeline` widget

**Screen Integrations**
- [x] Add History route to `PipelineDetailScreen` (via popup menu)
- [x] Create `PipelineHistoryScreen`
- [x] Add History route to `CustomerDetailScreen`
- [x] Create `CustomerHistoryScreen`
- [ ] Create `AdminAuditLogsScreen` (deferred to admin module)

#### Testing ⬜
- [ ] Unit tests for `HistoryLogRepositoryImpl`
- [ ] Widget tests for `HistoryTimeline`
- [ ] Test lazy fetch behavior

---

## 🚀 Phase 2: Enhancement Features

### 8. HVC Module ✅ 95% COMPLETE

#### Data Layer ✅
- [x] `hvcs` table defined
- [x] `hvc_types` master data defined
- [x] `customer_hvc_links` junction table defined
- [x] `key_persons` (owner_type=HVC) support

**Domain Models** ✅
- [x] Create `Hvc` domain entity (Freezed)
- [x] Create `HvcType` entity
- [x] Create `CustomerHvcLink` entity
- [x] Create `HvcWithDetails` aggregate

**Data Sources** ✅
- [x] Create `HvcLocalDataSource`
- [x] Create `HvcRemoteDataSource`

#### Repository Layer ✅
- [x] Create `HvcRepository` interface
  - [x] `watchAllHvcs()` - Stream
  - [x] `getAllHvcs()`
  - [x] `getHvcById(id)`
  - [x] `createHvc(hvc)` - Admin only
  - [x] `updateHvc(hvc)` - Admin only
  - [x] `deleteHvc(id)` - Admin only, soft delete
  - [x] `searchHvcs(query)`
  - [x] `getHvcTypes()` - Master data
  - [x] `getHvcKeyPersons(hvcId)` - Uses KeyPerson with ownerType=HVC
  - [x] `watchLinkedCustomers(hvcId)` - Stream
  - [x] `getLinkedCustomers(hvcId)`
  - [x] `watchCustomerHvcs(customerId)` - Stream
  - [x] `getCustomerHvcs(customerId)` - For customer detail
  - [x] `linkCustomerToHvc(dto)`
  - [x] `unlinkCustomerFromHvc(linkId)`
  - [x] `syncFromRemote({since})` - Incremental sync
  - [x] `syncLinksFromRemote({since})` - Link sync
- [x] Implement `HvcRepositoryImpl`

#### Presentation Layer ✅
**Providers** ✅
- [x] Create `hvcListStreamProvider` (StreamProvider)
- [x] Create `hvcDetailProvider` (FutureProvider.family)
- [x] Create `hvcTypesProvider` (FutureProvider) - Master data
- [x] Create `hvcSearchProvider` (FutureProvider.family)
- [x] Create `hvcKeyPersonsProvider` (FutureProvider.family)
- [x] Create `linkedCustomerCountProvider` (FutureProvider.family)
- [x] Create `linkedCustomersProvider` (StreamProvider.family)
- [x] Create `customerHvcsProvider` (StreamProvider.family)
- [x] Create `HvcFormNotifier` (StateNotifier)
- [x] Create `CustomerHvcLinkNotifier` (StateNotifier)

**Screens** ✅
- [x] Implement `HvcListScreen`
  - [x] AppBar with search toggle
  - [x] HVC cards with type badge
  - [x] Linked customers count (via `linkedCustomerCountProvider`)
  - [x] FAB for create (Admin only check via `isAdminProvider`)
  - [x] Search results view
  - [x] Pull-to-refresh

- [x] Implement `HvcDetailScreen`
  - [x] Tabs: Info | Key Persons | Linked Customers | Activities
  - [x] **Info Tab**
    - [x] HVC info card with name, code, type
    - [x] Address display
    - [x] GPS coordinates if available
    - [x] Potential value display
    - [x] Edit button (Admin only popup menu)
    - [x] Delete option (Admin only)
  - [x] **Key Persons Tab**
    - [x] Key person list (HVC-level via `hvcKeyPersonsProvider`)
    - [x] Add key person FAB
    - [x] Edit/delete actions via popup menu
    - [x] Uses `KeyPersonFormSheet` (reused from Customer)
  - [x] **Linked Customers Tab**
    - [x] Customer list with relationship type
    - [x] Add customer link via `HvcCustomerLinkSheet`
    - [x] Unlink action with confirmation dialog
    - [x] Navigate to customer detail on tap
  - [x] **Activities Tab**
    - [x] Activity history via `hvcActivitiesProvider`
    - [x] Grouped by status (Upcoming/Completed/Past)
    - [x] Add activity FAB (Log + Schedule)
    - [x] Execute activity action

- [x] Implement `HvcFormScreen` (Admin only)
  - [x] HVC type picker (SearchableDropdown)
  - [x] Name input
  - [x] Description input
  - [x] Address input
  - [x] GPS capture button with auto-capture option
  - [x] Radius configuration
  - [x] Potential value input
  - [x] Form validation
  - [x] Create/Update flow

- [x] Implement `CustomerHvcLinkSheet` (from Customer side)
  - [x] HVC picker (searchable via `hvcListStreamProvider`)
  - [x] Relationship type (HOLDING, SUBSIDIARY, AFFILIATE, JV, TENANT, MEMBER, SUPPLIER, CONTRACTOR, DISTRIBUTOR)
  - [x] Notes field
  - [x] Save button with loading state

- [x] Implement `HvcCustomerLinkSheet` (from HVC side)
  - [x] Customer picker (searchable via `customerListStreamProvider`)
  - [x] Relationship type picker
  - [x] Notes field
  - [x] Save button with loading state

**Widgets** ✅
- [x] `HvcCard` widget with sync status indicator

#### Testing ⬜
- [ ] Unit tests for `HvcRepositoryImpl`
- [ ] Widget tests for `HvcListScreen`
- [ ] Admin-only access tests

---

### 9. Broker Module ✅ 95% COMPLETE

#### Data Layer ✅
- [x] `brokers` table defined
- [x] `key_persons` (owner_type=BROKER) support

**Domain Models** ✅
- [x] Create `Broker` domain entity (Freezed)
- [x] Create `BrokerWithDetails` aggregate

**Data Sources** ✅
- [x] Create `BrokerLocalDataSource`
- [x] Create `BrokerRemoteDataSource`

#### Repository Layer ✅
- [x] Create `BrokerRepository` interface
  - [x] `getAllBrokers()` - Stream
  - [x] `getBrokerById(id)`
  - [x] `createBroker(broker)` - Admin only
  - [x] `updateBroker(broker)` - Admin only
  - [x] `deleteBroker(id)` - Admin only
  - [x] `getBrokerKeyPersons(brokerId)` - PICs
  - [x] `addBrokerKeyPerson(keyPerson)`
  - [x] `getBrokerPipelines(brokerId)` - Referred pipelines
- [x] Implement `BrokerRepositoryImpl`

#### Presentation Layer ✅
**Providers** ✅
- [x] Create `brokerListStreamProvider` (StreamProvider)
- [x] Create `brokerDetailProvider` (FutureProvider.family)
- [x] Create `BrokerFormNotifier` (StateNotifier)

**Screens** ✅
- [x] Implement `BrokerListScreen`
  - [x] AppBar with search
  - [x] Broker cards
  - [x] Pipeline count
  - [x] FAB for create (Admin only)

- [x] Implement `BrokerDetailScreen`
  - [x] Tabs: Info | Key Persons | Pipelines | Activities
  - [x] **Info Tab**
    - [x] Broker info card
    - [x] Address with GPS
    - [x] Contact info
  - [x] **Key Persons Tab**
    - [x] PIC list
    - [x] Add button (Admin only)
  - [x] **Pipelines Tab**
    - [x] Referred pipelines list (placeholder)
  - [x] **Activities Tab**
    - [x] Activity history

- [x] Implement `BrokerFormScreen` (Admin only)
  - [x] Name input
  - [x] Company name input
  - [x] License number input
  - [x] Address input
  - [x] Phone/email/website
  - [x] Commission rate
  - [x] GPS capture
  - [x] Notes

**Widgets** ✅
- [x] `BrokerCard` widget with pipeline count and sync status

#### Integration ✅
- [x] Routes in `app_router.dart` (list, detail, create, edit)
- [x] Route names in `route_names.dart`
- [x] Navigation rail/sidebar/drawer items in `responsive_shell.dart`
- [x] `_syncBrokers()` in `InitialSyncService`

#### Testing ⬜
- [ ] Unit tests for `BrokerRepositoryImpl`
- [ ] Widget tests for `BrokerListScreen`
- [ ] Admin-only access tests

---

### 10. Profile & Settings Module ✅ COMPLETE

#### Presentation Layer ✅
**Screens**
- [x] Implement `ProfileTab`
  - [x] Profile avatar (shows photoUrl or initials)
  - [x] User info (name, email, role, phone)
  - [x] Edit profile action
  - [x] Change password action
  - [x] Logout action with confirmation

- [x] Implement `EditProfileScreen`
  - [x] Name edit
  - [/] Avatar upload (backend ready via Supabase Storage, UI integration pending)
  - [x] Phone edit

- [x] Implement `ChangePasswordScreen`
  - [x] Current password input
  - [x] New password input
  - [x] Confirm password input
  - [x] Strength indicator
  - [x] Submit with AuthRepository.updatePassword

- [x] Implement `SettingsScreen`
  - [x] Theme toggle (light/dark/system) with persistence
  - [ ] Language selector - deferred
  - [x] Notification settings link (placeholder)
  - [x] Sync settings link
  - [x] About

- [x] Implement `AboutScreen`
  - [x] App version (package_info_plus)
  - [x] Terms of service link
  - [x] Privacy policy link
  - [x] Contact support

#### Infrastructure ✅
- [x] `settings_providers.dart` with ThemeModeNotifier
- [x] Theme persistence via AppSettingsService
- [x] Routes integration (editProfile, changePassword, about)

#### Testing ⬜
- [ ] Widget tests for profile screens

---

### 11. Admin Panel Module 🔄 IN PROGRESS

#### Presentation Layer 🔄
**Screens**
- [x] Implement `AdminPanelScreen` (entry point)
  - [x] Menu grid: Users, Master Data, 4DX, Cadence, Bulk Upload
  - [x] Role guard (ADMIN only)

**User Management** ✅ COMPLETE
- [x] Implement `UserManagementScreen`
  - [x] User list with search/filter
  - [x] Role filter
  - [x] Branch filter
  - [x] Status filter (active/inactive)

- [x] Implement `UserFormScreen`
  - [x] Name, email
  - [x] Role picker
  - [x] Branch picker (SearchableDropdown)
  - [x] Supervisor picker
  - [x] Activate/deactivate toggle
  - [x] Create/update flow

- [x] Implement `UserDetailScreen`
  - [x] Info tab (user details)
  - [x] Subordinates tab (team members)
  - [x] Audit log tab (viewing user actions)

**Master Data Management** ✅ COMPLETE
- [x] Implement `MasterDataScreen`
  - [x] Category selector (Pipeline Stages, Activity Types, etc.)
  - [x] List with CRUD actions

- [x] Implement `MasterDataFormScreen` (generic)
  - [x] Dynamic form based on category
  - [x] Validation
  - [x] Save flow

**4DX Configuration** ⬜
- [ ] Implement `MeasureDefinitionsScreen`
  - [ ] Measure list
  - [ ] Add/edit measure

- [ ] Implement `ScoringPeriodsScreen`
  - [ ] Period list
  - [ ] Add/edit period
  - [ ] Mark current period

**Bulk Upload** ⬜
- [ ] Implement `BulkUploadScreen`
  - [ ] Template download buttons (Customer, Pipeline, User)
  - [ ] File picker
  - [ ] Preview table with validation
  - [ ] Error highlighting
  - [ ] Confirm upload

#### Testing ⬜
- [ ] Widget tests for admin screens
- [ ] Role guard tests

---

### 12. Target Assignment Module ⬜

#### Repository Layer ⬜
- [ ] Add to `ScoreboardRepository`:
  - [ ] `assignTarget(userId, measureId, periodId, target)` - BH+
  - [ ] `getSubordinateTargets(supervisorId, periodId)`
  - [ ] `cascadeTargets(parentUserId, targets)` - Distribute to team

#### Presentation Layer ⬜
**Screens**
- [ ] Implement `TargetAssignmentScreen` (BH/BM/ROH)
  - [ ] Subordinate selector
  - [ ] Period selector
  - [ ] Measure list with target input
  - [ ] Cascade validation (sum check)
  - [ ] Save all targets
  - [ ] Bulk import option

- [ ] Implement `TargetViewScreen` (RM)
  - [ ] Period selector
  - [ ] Target list with progress
  - [ ] Measure breakdown

#### Testing ⬜
- [ ] Unit tests for target assignment
- [ ] Widget tests for assignment screen
- [ ] Cascade validation tests

---

### 13. Cadence Meeting Module ⬜

#### Data Layer ✅
- [x] `cadence_schedule_config` table defined
- [x] `cadence_meetings` table defined
- [x] `cadence_participants` table defined

**Domain Models** ⬜
- [ ] Create `CadenceConfig` entity
- [ ] Create `CadenceMeeting` entity
- [ ] Create `CadenceParticipant` entity
- [ ] Create `PreMeetingForm` model

**Data Sources** ⬜
- [ ] Create `CadenceLocalDataSource`
- [ ] Create `CadenceRemoteDataSource`

#### Repository Layer ⬜
- [ ] Create `CadenceRepository` interface
  - [ ] `getUpcomingMeetings(userId)`
  - [ ] `getMeetingById(id)`
  - [ ] `submitPreMeetingForm(meetingId, form)`
  - [ ] `markAttendance(meetingId, userId, attended)`
  - [ ] `startMeeting(meetingId)` - Host only
  - [ ] `completeMeeting(meetingId, notes)`
  - [ ] `getParticipants(meetingId)`
  - [ ] `getMyPendingForms()`
- [ ] Implement `CadenceRepositoryImpl`

#### Presentation Layer ⬜
**Providers**
- [ ] Create `cadenceListProvider` (StreamProvider) - Upcoming/past meetings
- [ ] Create `cadenceMeetingProvider` (FutureProvider.family)
- [ ] Create `pendingFormsProvider` (StreamProvider)
- [ ] Create `PreMeetingFormNotifier` (AsyncNotifier + @riverpod)

**Screens**
- [ ] Implement `CadenceListScreen`
  - [ ] Upcoming meetings list
  - [ ] Past meetings list
  - [ ] Pre-meeting deadline indicators

- [ ] Implement `CadenceMeetingScreen`
  - [ ] Meeting info
  - [ ] Participant list
  - [ ] Form submission status
  - [ ] Join button for participants
  - [ ] Host controls (start, mark attendance, complete)

- [ ] Implement `PreMeetingFormScreen`
  - [ ] Previous commitment status (COMPLETED/PARTIAL/NOT_DONE)
  - [ ] Current commitment input
  - [ ] Blockers input
  - [ ] Submit button
  - [ ] Deadline countdown

- [ ] Implement `CadenceHostScreen` (BH/BM/ROH)
  - [ ] Attendance marking
  - [ ] Form review for each participant
  - [ ] Meeting notes
  - [ ] Complete meeting action

#### Testing ⬜
- [ ] Unit tests for `CadenceRepositoryImpl`
- [ ] Widget tests for form submission
- [ ] Deadline validation tests

---

### 14. Pipeline Referral Module ⬜

#### Data Layer ✅
- [x] `pipeline_referrals` table defined

**Domain Models** ⬜
- [ ] Create `PipelineReferral` entity
- [ ] Create `ReferralStatus` enum

**Data Sources** ⬜
- [ ] Create `ReferralLocalDataSource`
- [ ] Create `ReferralRemoteDataSource`

#### Repository Layer ⬜
- [ ] Create `ReferralRepository` interface
  - [ ] `createReferral(referral)` - Referrer action
  - [ ] `acceptReferral(id)` - Receiver action
  - [ ] `rejectReferral(id, reason)` - Receiver action
  - [ ] `approveReferral(id)` - BM action
  - [ ] `rejectReferralAsBm(id, reason)` - BM action
  - [ ] `getInboundReferrals(userId)` - Receiver's inbox
  - [ ] `getOutboundReferrals(userId)` - Referrer's sent
  - [ ] `getPendingApprovals(bmId)` - BM's queue
  - [ ] `getReferralById(id)`
- [ ] Implement `ReferralRepositoryImpl`

#### Presentation Layer ⬜
**Providers**
- [ ] Create `referralInboxProvider` (StreamProvider) - Received referrals
- [ ] Create `referralOutboxProvider` (StreamProvider) - Sent referrals
- [ ] Create `pendingApprovalsProvider` (StreamProvider) - BM queue
- [ ] Create `ReferralActionNotifier` (AsyncNotifier + @riverpod)

**Screens**
- [ ] Implement `ReferralCreateSheet`
  - [ ] Customer picker
  - [ ] COB/LOB picker
  - [ ] Potential premium input
  - [ ] Receiver RM picker
  - [ ] Reason input
  - [ ] Notes input
  - [ ] Submit button

- [ ] Implement `ReferralInboxScreen`
  - [ ] Tabs: Received | Sent
  - [ ] Referral cards with status
  - [ ] Accept/reject actions
  - [ ] Detail view

- [ ] Implement `ReferralApprovalScreen` (BM)
  - [ ] Pending approvals list
  - [ ] Referral details
  - [ ] Approve/reject actions

- [ ] Implement referral notifications integration

#### Testing ⬜
- [ ] Unit tests for `ReferralRepositoryImpl`
- [ ] Widget tests for referral flow
- [ ] Status transition tests

---

### 15. Notifications Module ⬜

#### Data Layer ✅
- [x] `notifications` table defined
- [x] `notification_settings` table defined
- [x] `announcements` table defined
- [x] `announcement_reads` table defined

**Domain Models** ⬜
- [ ] Create `Notification` entity
- [ ] Create `NotificationType` enum
- [ ] Create `NotificationSettings` entity
- [ ] Create `Announcement` entity

**Data Sources** ⬜
- [ ] Create `NotificationLocalDataSource`
- [ ] Create `NotificationRemoteDataSource`

#### Service Layer ⬜
- [ ] Implement `NotificationService`
  - [ ] Activity reminders (30 min before)
  - [ ] Cadence reminders (pre-meeting deadline)
  - [ ] Referral status updates
  - [ ] Sync failure notifications
  - [ ] Local notification scheduling
  - [ ] Push notification handling

#### Repository Layer ⬜
- [ ] Create `NotificationRepository` interface
  - [ ] `getNotifications(userId)`
  - [ ] `markAsRead(id)`
  - [ ] `markAllAsRead()`
  - [ ] `deleteNotification(id)`
  - [ ] `getUnreadCount()`
  - [ ] `getSettings(userId)`
  - [ ] `updateSettings(settings)`
- [ ] Implement `NotificationRepositoryImpl`

#### Presentation Layer ⬜
**Providers**
- [ ] Create `notificationListProvider` (StreamProvider)
- [ ] Create `unreadCountProvider` (Provider) - Derived from list
- [ ] Create `notificationSettingsProvider` (FutureProvider)
- [ ] Create `NotificationActionNotifier` (AsyncNotifier + @riverpod)

**Screens**
- [ ] Implement `NotificationListScreen`
  - [ ] Notification list
  - [ ] Read/unread indicators
  - [ ] Swipe to delete
  - [ ] Mark all as read
  - [ ] Tap to navigate

- [ ] Implement `NotificationPreferencesScreen`
  - [ ] Push toggle
  - [ ] Email toggle
  - [ ] Per-type toggles
  - [ ] Reminder time picker

- [ ] Update notification badge in shell

#### Testing ⬜
- [ ] Unit tests for `NotificationService`
- [ ] Widget tests for notification screens

---

### 16. Reporting & Export Module ⬜

#### Service Layer ⬜
- [ ] Implement `ReportService`
  - [ ] Activity report generation
  - [ ] Pipeline report generation
  - [ ] Score report generation
  - [ ] Customer report generation
  - [ ] Export to Excel
  - [ ] Export to PDF
  - [ ] Export to CSV

#### Presentation Layer ⬜
**Screens**
- [ ] Implement `ReportsScreen`
  - [ ] Report type selector
  - [ ] Date range picker
  - [ ] Filter options
  - [ ] Generate report button
  - [ ] Export actions

- [ ] Implement report preview
  - [ ] Table view
  - [ ] Chart view (for scores)
  - [ ] Share action

#### Testing ⬜
- [ ] Unit tests for report generation
- [ ] Export format tests

---

## ✅ Quality Assurance Checklist

### Testing Coverage
- [ ] Unit tests for all repositories (min 80%)
- [ ] Widget tests for all screens
- [ ] Integration tests for critical flows
  - [ ] Authentication flow
  - [ ] Customer CRUD flow
  - [ ] Pipeline stage update flow
  - [ ] Activity execution with GPS
  - [ ] Offline sync flow
  - [ ] Referral approval flow

### Performance
- [ ] App launch time < 3 seconds
- [ ] List scroll smooth at 60fps
- [ ] Offline operations instant
- [ ] Sync queue processes within 5 seconds when online
- [ ] Memory usage < 200MB

### Security
- [ ] JWT token secure storage (flutter_secure_storage)
- [ ] SQLCipher encryption enabled
- [ ] RLS policies tested
- [ ] No sensitive data in logs
- [ ] Certificate pinning (optional)

### Accessibility
- [ ] Screen reader support (Semantics)
- [ ] Sufficient color contrast (WCAG AA)
- [ ] Touch targets min 48x48dp
- [ ] Font scaling support

### Platform Testing
- [ ] iOS (iPhone + iPad)
- [ ] Android (phone + tablet)
- [ ] Web (responsive)

---

## 📚 Documentation Checklist

- [ ] API documentation
- [ ] Code comments for complex logic
- [ ] README with setup instructions
- [ ] Architecture decision records (ADRs)
- [ ] User manual
- [ ] Admin guide

---

## 📅 Recommended Implementation Order

### Week 1-2: Core Sync & Customer (Parallel)
1. **Sync Service** - Essential for offline-first
2. **Customer Module** - Core data

### Week 3-4: Pipeline
3. **Pipeline Module** - Depends on Customer

### Week 5-6: Activity
4. **Activity Module** - GPS, photos, execution

### Week 7-8: Dashboard, Scoreboard & History
5. **Dashboard** - Aggregation layer
6. **Scoreboard** - 4DX integration
7. **History Log Module** - Audit trail & notes history

### Week 9-10: HVC & Broker
8. **HVC Module** - Simpler, similar to Customer
9. **Broker Module** - Similar to HVC

### Week 11-12: Profile, Settings & Admin
10. **Profile & Settings** - User preferences
11. **Admin Panel** - Master data management (includes Audit Logs screen)

### Week 13-14: Advanced Features
12. **Target Assignment** - BH+ role feature
13. **Cadence Meeting** - Team workflows

### Week 15-16: Support Features & Polish
14. **Pipeline Referral** - Approval workflow
15. **Notifications** - Cross-cutting
16. **Reporting & Export** - Analytics

---

*Implementation checklist for LeadX CRM - Updated January 28, 2026*
