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

**Last Updated:** January 2026

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
  - [ ] **Activities Tab** (Phase 5 - placeholder)
    - [ ] Activity history list
    - [ ] Add activity FAB
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

### 5. Activity Module ⬜

#### Data Layer
**Drift Tables** ✅
- [x] `activities` table defined
- [x] `activity_photos` table defined
- [x] `activity_audit_logs` table defined
- [x] `activity_types` master data

**Domain Models** ⬜
- [ ] Create `Activity` domain entity (Freezed)
- [ ] Create `ActivityStatus` enum
- [ ] Create `ActivityPhoto` entity
- [ ] Create `ActivityAuditLog` entity
- [ ] Create `ActivityType` entity
- [ ] Create `ActivityObjectType` enum (CUSTOMER, HVC, BROKER, PIPELINE)

**DTOs** ⬜
- [ ] Create `ActivityCreateDto` (scheduled)
- [ ] Create `ImmediateActivityDto` (instant logging)
- [ ] Create `ActivityExecutionDto`
- [ ] Create `ActivityRescheduleDto`

**Data Sources** ⬜
- [ ] Create `ActivityLocalDataSource`
- [ ] Create `ActivityRemoteDataSource`
- [ ] Create `ActivityPhotoLocalDataSource`

#### Repository Layer ⬜
- [ ] Create `ActivityRepository` interface
  - [ ] `getUserActivities(userId, dateRange)`
  - [ ] `getCustomerActivities(customerId)`
  - [ ] `getPipelineActivities(pipelineId)`
  - [ ] `getHvcActivities(hvcId)`
  - [ ] `getBrokerActivities(brokerId)`
  - [ ] `createActivity(activity)` - Scheduled
  - [ ] `createImmediateActivity(activity)` - Instant
  - [ ] `executeActivity(id, execution)` - Mark complete with GPS
  - [ ] `rescheduleActivity(id, newDateTime, reason)`
  - [ ] `cancelActivity(id, reason)`
  - [ ] `getActivityTypes()`
  - [ ] `getActivityHistory(activityId)` - Audit logs
  - [ ] `addActivityPhoto(activityId, photo)`
  - [ ] `deleteActivityPhoto(photoId)`
- [ ] Implement `ActivityRepositoryImpl`

#### Service Layer ⬜
- [ ] Implement `GpsService`
  - [ ] `getCurrentLocation()` - With timeout
  - [ ] `calculateDistance(lat1, lon1, lat2, lon2)`
  - [ ] `validateProximity(activityId)` - Check 500m radius
  - [ ] Permission handling

- [ ] Implement `CameraService`
  - [ ] `capturePhoto()` - With EXIF data
  - [ ] `pickFromGallery()`
  - [ ] `compressImage(path)`
  - [ ] Geotag validation

#### Presentation Layer ⬜
**Providers**
- [ ] Create `activityListProvider` (StreamProvider.family) - By user/date
- [ ] Create `activityDetailProvider` (FutureProvider.family)
- [ ] Create `ActivityCalendarNotifier` (Notifier + @riverpod) - Calendar state
- [ ] Create `activityTypesProvider` (FutureProvider) - Master data
- [ ] Create `gpsProvider` (StreamProvider) - Location stream
- [ ] Create `ActivityFormNotifier` (AsyncNotifier + @riverpod)
- [ ] Create `ActivityExecutionNotifier` (AsyncNotifier + @riverpod)

**Screens**

> [!IMPORTANT]
> **Phase 5 Priority: CustomerDetailScreen Activity Tab**
> This integration requires Activity domain/data layer to be complete first.

- [ ] Integrate activity list in `CustomerDetailScreen` activities tab
  - [ ] Create `customerActivitiesProvider` (StreamProvider.family by customerId)
  - [ ] Activity card with:
    - [ ] Activity type icon and name
    - [ ] Scheduled datetime
    - [ ] Status badge (PLANNED/COMPLETED/CANCELLED)
    - [ ] Summary text
    - [ ] GPS status (if executed)
  - [ ] Group activities by date
  - [ ] Add Activity FAB (navigate to ActivityFormScreen with customerId)
  - [ ] Tap to navigate to ActivityDetailScreen
  - [ ] Empty state when no activities
  - [ ] Loading state

- [ ] Implement `ActivityCalendarScreen`
  - [ ] Calendar view toggle (weekly/monthly)
  - [ ] Activity list by selected date
  - [ ] Status indicators on calendar
  - [ ] Quick actions:
    - [ ] Execute planned activity
    - [ ] Log immediate activity
  - [ ] FAB for create scheduled activity
  - [ ] Pull-to-refresh

- [ ] Implement `ActivityDetailScreen`
  - [ ] Activity info card
  - [ ] Object info (customer/HVC/broker/pipeline)
  - [ ] GPS data display
  - [ ] Map preview (if coordinates available)
  - [ ] Photos gallery
  - [ ] History log (audit trail)
  - [ ] Actions:
    - [ ] Execute (if planned)
    - [ ] Reschedule
    - [ ] Cancel

- [ ] Implement `ActivityFormScreen` (scheduled)
  - [ ] Object type picker (Customer/HVC/Broker/Pipeline)
  - [ ] Object picker (based on type)
  - [ ] Activity type picker
  - [ ] Date picker
  - [ ] Time picker
  - [ ] Summary input
  - [ ] Notes input
  - [ ] Form validation
  - [ ] Save flow

- [ ] Implement `ActivityExecutionSheet`
  - [ ] GPS capture (automatic, silent)
  - [ ] Distance validation display
  - [ ] GPS override option (with reason required)
  - [ ] Notes input
  - [ ] Photo capture (optional)
  - [ ] Submit button
  - [ ] Cancel button
  - [ ] Loading state

- [ ] Implement `ImmediateActivitySheet`
  - [ ] Quick activity logging
  - [ ] Object picker
  - [ ] Activity type quick select
  - [ ] GPS auto-capture
  - [ ] Notes (optional)
  - [ ] Photo capture (optional)
  - [ ] Submit flow

- [ ] Implement `ActivityRescheduleSheet`
  - [ ] New date picker
  - [ ] New time picker
  - [ ] Reason input (required)
  - [ ] Confirm button

#### Testing ⬜
- [ ] Unit tests for `ActivityRepositoryImpl`
- [ ] Unit tests for `GpsService`
- [ ] Widget tests for `ActivityCalendarScreen`
- [ ] Widget tests for execution flow
- [ ] GPS mock testing

---

### 6. Dashboard & Scoreboard Module ⬜

#### Data Layer
**Drift Tables** ✅
- [x] `user_targets` table defined
- [x] `user_scores` table defined
- [x] `measure_definitions` table defined
- [x] `scoring_periods` table defined
- [x] `period_summary_scores` table defined

**Domain Models** ⬜
- [ ] Create `MeasureDefinition` entity
- [ ] Create `ScoringPeriod` entity
- [ ] Create `UserTarget` entity
- [ ] Create `UserScore` entity
- [ ] Create `PeriodSummary` entity
- [ ] Create `LeaderboardEntry` entity

**Data Sources** ⬜
- [ ] Create `ScoreboardLocalDataSource`
- [ ] Create `ScoreboardRemoteDataSource`

#### Repository Layer ⬜
- [ ] Create `ScoreboardRepository` interface
  - [ ] `getUserScore(userId, periodId)`
  - [ ] `getUserRank(userId, periodId)`
  - [ ] `getTeamScores(supervisorId, periodId)` - For BH/BM
  - [ ] `getLeaderboard(periodId, limit)`
  - [ ] `getUserTargets(userId, periodId)`
  - [ ] `getMeasureDefinitions()`
  - [ ] `getCurrentPeriod()`
  - [ ] `getPeriods()` - For period selector
- [ ] Implement `ScoreboardRepositoryImpl`

#### Presentation Layer
**Providers** ⬜
- [ ] Create `DashboardNotifier` (AsyncNotifier + @riverpod) - Dashboard aggregation
- [ ] Create `ScoreboardNotifier` (AsyncNotifier + @riverpod)
- [ ] Create `currentPeriodProvider` (FutureProvider)
- [ ] Create `userScoreProvider` (FutureProvider.family)
- [ ] Create `leaderboardProvider` (FutureProvider.family)

**Screens**
- [/] Implement `DashboardTab` (partially done)
  - [x] Welcome card
  - [ ] User greeting from auth state
  - [x] Today's activities summary (static)
  - [ ] Today's activities from data
  - [ ] Weekly summary cards
    - [ ] Activities completed/total
    - [ ] Active pipelines count
    - [ ] Won premium this week
  - [ ] Personal score preview
  - [ ] Customer summary by pipeline stage
  - [ ] Quick action buttons

- [ ] Implement `ScoreboardScreen`
  - [ ] Period selector
  - [ ] Personal score card
    - [ ] Overall score
    - [ ] Lead measures breakdown
    - [ ] Lag measures breakdown
    - [ ] Target vs actual
  - [ ] Rank indicator
    - [ ] Current rank
    - [ ] Rank change from previous period
  - [ ] Team leaderboard (for BH/BM/ROH)
  - [ ] Filters: This week, This month, This quarter

#### Testing ⬜
- [ ] Unit tests for `ScoreboardRepositoryImpl`
- [ ] Widget tests for `DashboardTab`
- [ ] Widget tests for `ScoreboardScreen`

---

## 🚀 Phase 2: Enhancement Features

### 7. HVC Module ⬜

#### Data Layer ✅
- [x] `hvcs` table defined
- [x] `hvc_types` master data defined
- [x] `customer_hvc_links` junction table defined
- [x] `key_persons` (owner_type=HVC) support

**Domain Models** ⬜
- [ ] Create `Hvc` domain entity (Freezed)
- [ ] Create `HvcType` entity
- [ ] Create `CustomerHvcLink` entity
- [ ] Create `HvcWithDetails` aggregate

**Data Sources** ⬜
- [ ] Create `HvcLocalDataSource`
- [ ] Create `HvcRemoteDataSource`

#### Repository Layer ⬜
- [ ] Create `HvcRepository` interface
  - [ ] `getAllHvcs()` - Stream
  - [ ] `getHvcById(id)`
  - [ ] `createHvc(hvc)` - Admin only
  - [ ] `updateHvc(hvc)` - Admin only
  - [ ] `deleteHvc(id)` - Admin only, soft delete
  - [ ] `getHvcKeyPersons(hvcId)`
  - [ ] `addHvcKeyPerson(keyPerson)`
  - [ ] `updateHvcKeyPerson(keyPerson)`
  - [ ] `deleteHvcKeyPerson(id)`
  - [ ] `getLinkedCustomers(hvcId)`
  - [ ] `linkCustomerToHvc(customerId, hvcId)`
  - [ ] `unlinkCustomerFromHvc(customerId, hvcId)`
  - [ ] `getCustomerHvcs(customerId)` - For customer detail
- [ ] Implement `HvcRepositoryImpl`

#### Presentation Layer ⬜
**Providers**
- [ ] Create `hvcListProvider` (StreamProvider)
- [ ] Create `hvcDetailProvider` (FutureProvider.family)
- [ ] Create `hvcTypesProvider` (FutureProvider) - Master data
- [ ] Create `customerHvcLinksProvider` (StreamProvider.family)
- [ ] Create `HvcFormNotifier` (AsyncNotifier + @riverpod)

**Screens**
- [ ] Implement `HvcListScreen`
  - [ ] AppBar with search
  - [ ] HVC cards with type badge
  - [ ] Linked customers count
  - [ ] FAB for create (Admin only)

- [ ] Implement `HvcDetailScreen`
  - [ ] Tabs: Summary | Key Persons | Linked Customers | Activities
  - [ ] **Summary Tab**
    - [ ] HVC info card
    - [ ] Type info
    - [ ] Address with map
    - [ ] Contact info
    - [ ] Edit button (Admin)
  - [ ] **Key Persons Tab**
    - [ ] Key person list (HVC-level)
    - [ ] Add button (Admin)
  - [ ] **Linked Customers Tab**
    - [ ] Customer list
    - [ ] Relationship type
    - [ ] Add link button
    - [ ] Unlink action
  - [ ] **Activities Tab**
    - [ ] Activity history

- [ ] Implement `HvcFormScreen` (Admin only)
  - [ ] HVC type picker
  - [ ] Name input
  - [ ] Address input
  - [ ] Contact info
  - [ ] Notes

- [ ] Implement `CustomerHvcLinkSheet`
  - [ ] HVC picker (searchable)
  - [ ] Relationship type (TENANT, SUBSIDIARY, AFFILIATE, etc.)
  - [ ] Notes
  - [ ] Save button

#### Testing ⬜
- [ ] Unit tests for `HvcRepositoryImpl`
- [ ] Widget tests for `HvcListScreen`
- [ ] Admin-only access tests

---

### 8. Broker Module ⬜

#### Data Layer ✅
- [x] `brokers` table defined
- [x] `key_persons` (owner_type=BROKER) support

**Domain Models** ⬜
- [ ] Create `Broker` domain entity (Freezed)
- [ ] Create `BrokerWithDetails` aggregate

**Data Sources** ⬜
- [ ] Create `BrokerLocalDataSource`
- [ ] Create `BrokerRemoteDataSource`

#### Repository Layer ⬜
- [ ] Create `BrokerRepository` interface
  - [ ] `getAllBrokers()` - Stream
  - [ ] `getBrokerById(id)`
  - [ ] `createBroker(broker)` - Admin only
  - [ ] `updateBroker(broker)` - Admin only
  - [ ] `deleteBroker(id)` - Admin only
  - [ ] `getBrokerKeyPersons(brokerId)` - PICs
  - [ ] `addBrokerKeyPerson(keyPerson)`
  - [ ] `getBrokerPipelines(brokerId)` - Referred pipelines
- [ ] Implement `BrokerRepositoryImpl`

#### Presentation Layer ⬜
**Providers**
- [ ] Create `brokerListProvider` (StreamProvider)
- [ ] Create `brokerDetailProvider` (FutureProvider.family)
- [ ] Create `BrokerFormNotifier` (AsyncNotifier + @riverpod)

**Screens**
- [ ] Implement `BrokerListScreen`
  - [ ] AppBar with search
  - [ ] Broker cards
  - [ ] Pipeline count
  - [ ] FAB for create (Admin only)

- [ ] Implement `BrokerDetailScreen`
  - [ ] Tabs: Summary | Key Persons | Pipelines | Activities
  - [ ] **Summary Tab**
    - [ ] Broker info card
    - [ ] Address with map
    - [ ] Contact info
  - [ ] **Key Persons Tab**
    - [ ] PIC list
    - [ ] Add button (Admin)
  - [ ] **Pipelines Tab**
    - [ ] Referred pipelines list
  - [ ] **Activities Tab**
    - [ ] Activity history

- [ ] Implement `BrokerFormScreen` (Admin only)
  - [ ] Name input
  - [ ] Address input
  - [ ] Phone/email
  - [ ] Notes

#### Testing ⬜
- [ ] Unit tests for `BrokerRepositoryImpl`
- [ ] Widget tests for `BrokerListScreen`

---

### 9. Target Assignment Module ⬜

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

### 10. Cadence Meeting Module ⬜

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

### 11. Pipeline Referral Module ⬜

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

### 12. Admin Panel Module ⬜

#### Presentation Layer ⬜
**Screens**
- [ ] Implement `AdminPanelScreen` (entry point)
  - [ ] Menu grid: Users, Master Data, 4DX, Cadence, Bulk Upload
  - [ ] Role guard (ADMIN only)

**User Management**
- [ ] Implement `UserManagementScreen`
  - [ ] User list with search/filter
  - [ ] Role filter
  - [ ] Branch filter
  - [ ] Status filter (active/inactive)

- [ ] Implement `UserFormScreen`
  - [ ] Name, email
  - [ ] Role picker
  - [ ] Branch picker
  - [ ] Supervisor picker
  - [ ] Activate/deactivate toggle
  - [ ] Create/update flow

**Master Data Management**
- [ ] Implement `MasterDataScreen`
  - [ ] Category selector (Pipeline Stages, Activity Types, etc.)
  - [ ] List with CRUD actions

- [ ] Implement `MasterDataFormScreen` (generic)
  - [ ] Dynamic form based on category
  - [ ] Validation
  - [ ] Save flow

**4DX Configuration**
- [ ] Implement `MeasureDefinitionsScreen`
  - [ ] Measure list
  - [ ] Add/edit measure

- [ ] Implement `ScoringPeriodsScreen`
  - [ ] Period list
  - [ ] Add/edit period
  - [ ] Mark current period

**Bulk Upload**
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

### 13. Notifications Module ⬜

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

### 14. Profile & Settings Module ⬜

#### Presentation Layer ⬜
**Screens**
- [ ] Implement `ProfileScreen`
  - [ ] Profile avatar
  - [ ] User info (name, email, role, branch)
  - [ ] Edit profile action
  - [ ] Change password action
  - [ ] Logout action

- [ ] Implement `EditProfileScreen`
  - [ ] Name edit
  - [ ] Avatar upload
  - [ ] Phone edit

- [ ] Implement `ChangePasswordScreen`
  - [ ] Current password input
  - [ ] New password input
  - [ ] Confirm password input
  - [ ] Strength indicator
  - [ ] Submit

- [ ] Implement `SettingsScreen`
  - [ ] Theme toggle (light/dark/system)
  - [ ] Language selector
  - [ ] Notification settings link
  - [ ] Sync settings link
  - [ ] About

- [ ] Implement `AboutScreen`
  - [ ] App version
  - [ ] Terms of service link
  - [ ] Privacy policy link
  - [ ] Contact support

#### Testing ⬜
- [ ] Widget tests for profile screens

---

### 15. Reporting & Export Module ⬜

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

### Week 7-8: Dashboard & Scoreboard
5. **Dashboard** - Aggregation layer
6. **Scoreboard** - 4DX integration

### Week 9-10: HVC & Broker
7. **HVC Module** - Simpler, similar to Customer
8. **Broker Module** - Similar to HVC

### Week 11-12: Advanced Features
9. **Target Assignment** - BH+ role feature
10. **Cadence Meeting** - Team workflows

### Week 13-14: Support Features
11. **Pipeline Referral** - Approval workflow
12. **Notifications** - Cross-cutting
13. **Profile & Settings** - User preferences

### Week 15-16: Admin & Polish
14. **Admin Panel** - Master data management
15. **Reporting & Export** - Analytics

---

*Implementation checklist for LeadX CRM - Updated January 2026*
