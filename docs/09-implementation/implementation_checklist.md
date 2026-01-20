# LeadX CRM - Implementation Checklist

## 📋 Overview

This checklist provides a structured approach to developing LeadX CRM, organized by development phases and feature modules. Each feature follows a consistent implementation pattern:

1. **Data Layer** - Database tables, Drift entities, DTOs
2. **Repository Layer** - Local and remote data sources, sync logic
3. **Domain Layer** - Use cases, business logic
4. **Presentation Layer** - Providers, UI screens, widgets
5. **Testing** - Unit tests, widget tests, integration tests

---

## 🏗️ Phase 0: Foundation (4 weeks) ✅ INTERNAL COMPLETE

### Week 1: Project Setup
- [x] Initialize Git repository with branching strategy
- [x] Set up GitHub Actions CI/CD pipeline (`.github/workflows/ci.yml`)
- [x] Configure linting and formatting (flutter_lints)
- [x] Create project structure following clean architecture
- [x] Set up environment configuration (EnvConfig)

### Week 2: Supabase & Database
- [x] Supabase deployed on Coolify
- [x] Database schema SQL files created (4 files + migration)
- [x] RLS policies SQL file created
- [ ] Run SQL files on Supabase ⚠️ USER ACTION
- [ ] Create test user ⚠️ USER ACTION
- [ ] Seed initial master data (in SQL files)

### Week 3: Flutter Project Structure
- [x] Set up Flutter project with Riverpod
- [x] Configure go_router for navigation
- [x] Set up Drift for local database
- [x] Create Drift table definitions (37 tables)
- [x] Set up code generation (build_runner)
- [x] Configure Supabase Flutter client

### Week 4: Design System
- [x] Create color scheme (light/dark themes)
- [x] Define typography scale
- [x] Create common widgets library
  - [x] AppButton
  - [x] AppTextField
  - [x] AppCard
  - [x] AppBottomSheet
  - [x] LoadingIndicator
  - [x] ErrorWidget (AppErrorState)
  - [x] EmptyState (AppEmptyState)
  - [x] SyncStatusBadge
  - [x] AppSearchField
  - [x] AppSectionHeader
- [x] Create responsive layout helpers (responsive_layout.dart)
- [x] Set up asset management (assets/icons, images, fonts)

---

## 🎯 Phase 1: MVP Features (12 weeks)

### 1. Authentication Module (Weeks 1-2) ✅ 90% COMPLETE

#### Data Layer
- [x] Create `users` Drift table
- [x] Create `AuthRemoteDataSource` (integrated in AuthRepositoryImpl)
- [x] Create `User` domain model (Freezed)
- [x] Create `AppAuthState` sealed class

#### Repository Layer
- [x] Implement `AuthRepository`
  - [x] `signIn(email, password)`
  - [x] `signOut()`
  - [x] `getCurrentUser()`
  - [x] `refreshToken()`
  - [x] `resetPassword(email)`

#### Presentation Layer
- [x] Create `AuthProvider` with Riverpod (auth_providers.dart)
- [x] Implement `SplashScreen` (token check)
- [x] Implement `LoginScreen`
  - [x] Email/password form
  - [x] Form validation
  - [x] Error handling
  - [ ] Remember me checkbox
- [x] Implement `ForgotPasswordScreen`
- [x] Create auth guards for navigation (app_router.dart)

#### Testing
- [ ] Unit tests for AuthRepository
- [ ] Widget tests for LoginScreen
- [ ] Integration test for auth flow

---

### 2. Customer Module (Weeks 3-4)

#### Data Layer
- [ ] Create `customers` Drift table
- [ ] Create `key_persons` Drift table
- [ ] Create `CustomerLocalDataSource`
- [ ] Create `CustomerRemoteDataSource`
- [ ] Create `Customer` and `KeyPerson` domain models
- [ ] Create customer DTOs

#### Repository Layer
- [ ] Implement `CustomerRepository`
  - [ ] `getAllCustomers()` - with streams
  - [ ] `getCustomerById(id)`
  - [ ] `createCustomer(customer)`
  - [ ] `updateCustomer(customer)`
  - [ ] `deleteCustomer(id)` - soft delete
  - [ ] `searchCustomers(query)`
  - [ ] `getCustomerKeyPersons(customerId)`
  - [ ] `addKeyPerson(keyPerson)`
  - [ ] `updateKeyPerson(keyPerson)`
  - [ ] `deleteKeyPerson(id)`

#### Presentation Layer
- [ ] Create `CustomerListProvider`
- [ ] Create `CustomerDetailProvider`
- [ ] Implement `CustomerListScreen`
  - [ ] Search bar
  - [ ] Filter chips (by pipeline stage)
  - [ ] Customer cards with pipeline summary
  - [ ] Pull-to-refresh
  - [ ] FAB for create
- [ ] Implement `CustomerDetailScreen`
  - [ ] Info tab
  - [ ] Key Persons tab
  - [ ] Pipelines tab (integrated)
  - [ ] Activities tab
  - [ ] Quick actions bar
- [ ] Implement `CustomerFormScreen` (create/edit)
  - [ ] GPS auto-capture on create
  - [ ] Form validation
  - [ ] Province/City pickers
  - [ ] Industry/Company type dropdowns
- [ ] Implement `KeyPersonFormSheet`

#### Testing
- [ ] Unit tests for CustomerRepository
- [ ] Widget tests for CustomerListScreen
- [ ] Widget tests for CustomerFormScreen

---

### 3. Pipeline Module (Weeks 5-6)

#### Data Layer
- [ ] Create `pipelines` Drift table
- [ ] Create `pipeline_stages` Drift table
- [ ] Create `pipeline_statuses` Drift table
- [ ] Create related DTOs and domain models

#### Repository Layer
- [ ] Implement `PipelineRepository`
  - [ ] `getCustomerPipelines(customerId)`
  - [ ] `getPipelineById(id)`
  - [ ] `createPipeline(pipeline)`
  - [ ] `updatePipeline(pipeline)`
  - [ ] `updatePipelineStage(id, stageId, statusId)`
  - [ ] `deletePipeline(id)` - soft delete
  - [ ] `getPipelineStages()`
  - [ ] `getPipelineStatuses(stageId)`

#### Presentation Layer
- [ ] Create `PipelineProvider`
- [ ] Implement pipeline list in CustomerDetail
  - [ ] Stage badges with colors
  - [ ] Quick stage update dropdown
  - [ ] View detail action
- [ ] Implement `PipelineDetailScreen`
  - [ ] Pipeline info
  - [ ] Stage history
  - [ ] Broker info (if applicable)
  - [ ] Related activities
- [ ] Implement `PipelineFormScreen`
  - [ ] Customer pre-selected
  - [ ] COB/LOB pickers
  - [ ] Lead source picker
  - [ ] Broker picker (conditional)
  - [ ] Potential premium input
  - [ ] Expected close date

#### Testing
- [ ] Unit tests for PipelineRepository
- [ ] Widget tests for PipelineFormScreen
- [ ] Widget tests for stage update flow

---

### 4. Activity Module (Weeks 7-8)

#### Data Layer
- [ ] Create `activities` Drift table
- [ ] Create `activity_photos` Drift table
- [ ] Create `activity_audit_logs` Drift table
- [ ] Create `activity_types` Drift table
- [ ] Create related DTOs and domain models

#### Repository Layer
- [ ] Implement `ActivityRepository`
  - [ ] `getUserActivities(userId, dateRange)`
  - [ ] `getCustomerActivities(customerId)`
  - [ ] `getPipelineActivities(pipelineId)`
  - [ ] `createActivity(activity)` - scheduled
  - [ ] `createImmediateActivity(activity)` - instant
  - [ ] `executeActivity(id, execution)` - with GPS
  - [ ] `rescheduleActivity(id, newDateTime)`
  - [ ] `cancelActivity(id, reason)`
  - [ ] `getActivityTypes()`
  - [ ] `getActivityHistory(activityId)`

#### Presentation Layer
- [ ] Create `ActivityProvider`
- [ ] Create `ActivityCalendarProvider`
- [ ] Implement `ActivityCalendarScreen`
  - [ ] Calendar view (weekly/monthly)
  - [ ] Activity list by date
  - [ ] Status indicators
  - [ ] Quick actions
- [ ] Implement `ActivityDetailScreen`
  - [ ] Activity info
  - [ ] GPS data & map preview
  - [ ] Photos
  - [ ] History log (audit trail)
- [ ] Implement `ActivityFormScreen`
  - [ ] Object type picker (Customer/HVC/Broker/Pipeline)
  - [ ] Activity type picker
  - [ ] Date/time picker
  - [ ] Notes field
- [ ] Implement `ActivityExecutionSheet`
  - [ ] GPS capture (silent)
  - [ ] Distance validation
  - [ ] Override option with reason
  - [ ] Notes input
  - [ ] Photo capture (optional)
  - [ ] Submit confirmation
- [ ] Implement `ImmediateActivitySheet`
  - [ ] Quick activity logging
  - [ ] GPS auto-capture
  - [ ] Minimal form

#### Testing
- [ ] Unit tests for ActivityRepository
- [ ] Widget tests for ActivityCalendarScreen
- [ ] Widget tests for execution flow
- [ ] GPS mock testing

---

### 5. Offline Sync Module (Integrated - Weeks 9-10)

#### Data Layer
- [ ] Create `sync_queue` Drift table
- [ ] Create `SyncOperation` model

#### Sync Service
- [ ] Implement `ConnectivityService`
  - [ ] Network state monitoring
  - [ ] Server reachability check
- [ ] Implement `SyncService`
  - [ ] `processQueue()` - FIFO processing
  - [ ] `triggerSync()` - manual sync
  - [ ] `startBackgroundSync()` - periodic
  - [ ] Conflict resolution (timestamp-based)
  - [ ] Retry logic with backoff
  - [ ] Error handling & notification
- [ ] Implement `InitialSyncService`
  - [ ] Paginated data fetch
  - [ ] Progress tracking
  - [ ] Master data sync
  - [ ] User hierarchy sync

#### Presentation Layer
- [ ] Create `SyncStateProvider`
- [ ] Implement `SyncStatusIndicator` widget
  - [ ] Synced state
  - [ ] Syncing animation
  - [ ] Pending count
  - [ ] Offline indicator
  - [ ] Error with retry
- [ ] Implement `SyncQueueScreen` (optional)
  - [ ] Pending items list
  - [ ] Failed items with retry
  - [ ] Recently synced

#### Testing
- [ ] Unit tests for SyncService
- [ ] Conflict resolution tests
- [ ] Offline/online transition tests

---

### 6. Dashboard & Scoreboard (Weeks 11-12)

#### Data Layer
- [ ] Create `user_targets` Drift table
- [ ] Create `user_scores` Drift table
- [ ] Create `measure_definitions` Drift table
- [ ] Create `scoring_periods` Drift table

#### Repository Layer
- [ ] Implement `ScoreboardRepository`
  - [ ] `getUserScore(userId, periodId)`
  - [ ] `getUserRank(userId, periodId)`
  - [ ] `getTeamScores(supervisorId, periodId)`
  - [ ] `getUserTargets(userId, periodId)`
  - [ ] `getMeasureDefinitions()`

#### Presentation Layer
- [ ] Create `DashboardProvider`
- [ ] Create `ScoreboardProvider`
- [ ] Implement `DashboardScreen`
  - [ ] Welcome card
  - [ ] Today's activities summary
  - [ ] Weekly summary cards
  - [ ] Personal score preview
  - [ ] Customer summary with pipeline stages
- [ ] Implement `ScoreboardScreen`
  - [ ] Period selector
  - [ ] Personal score card
  - [ ] Lead/Lag measures breakdown
  - [ ] Rank indicator
  - [ ] Team leaderboard (for supervisors)

#### Testing
- [ ] Unit tests for ScoreboardRepository
- [ ] Widget tests for DashboardScreen

---

## 🚀 Phase 2: Enhancement (8 weeks)

### 7. Cadence Module

- [ ] Create cadence database tables (Drift)
- [ ] Implement `CadenceRepository`
  - [ ] Get upcoming meetings
  - [ ] Submit pre-meeting form
  - [ ] Host meeting actions
  - [ ] Mark attendance
- [ ] Implement `CadenceListScreen`
- [ ] Implement `CadenceMeetingScreen`
- [ ] Implement `PreMeetingFormScreen`
- [ ] Implement `CadenceHostScreen` (BH+)

---

### 8. Target Assignment

- [ ] Implement target management in repository
- [ ] Create `TargetAssignmentScreen` (BH+)
  - [ ] Subordinate selector
  - [ ] Measure list
  - [ ] Target input per measure
  - [ ] Cascade validation
- [ ] Create `TargetViewScreen` (RM)

---

### 9. HVC Module

- [ ] Create HVC database tables (Drift)
- [ ] Implement `HvcRepository`
  - [ ] CRUD operations (Admin only)
  - [ ] Link/unlink customers
  - [ ] Key persons management
- [ ] Implement `HvcListScreen`
- [ ] Implement `HvcDetailScreen`
  - [ ] Summary tab
  - [ ] Key Persons tab (HVC level)
  - [ ] Linked Customers tab
  - [ ] Activities tab
- [ ] Implement `HvcFormScreen` (Admin only)
- [ ] Implement `CustomerHvcLinkSheet`

---

### 10. Broker Module

- [ ] Create Broker database tables (Drift)
- [ ] Implement `BrokerRepository`
  - [ ] CRUD operations (Admin only)
  - [ ] Key persons management
  - [ ] Pipeline tracking
- [ ] Implement `BrokerListScreen`
- [ ] Implement `BrokerDetailScreen`
  - [ ] Summary tab
  - [ ] Key Persons tab
  - [ ] Pipelines Referred tab
  - [ ] Activities tab
- [ ] Implement `BrokerFormScreen` (Admin only)

---

### 11. Pipeline Referral

- [ ] Create referral database tables (Drift)
- [ ] Implement `ReferralRepository`
  - [ ] Create referral
  - [ ] Accept/reject as receiver
  - [ ] Approve/reject as BM
  - [ ] Get referral status
- [ ] Implement `ReferralCreateSheet`
- [ ] Implement `ReferralInboxScreen`
- [ ] Implement `ReferralApprovalScreen` (BM)
- [ ] Implement referral notifications

---

### 12. Admin Panel

- [ ] Implement `AdminPanelScreen` (entry point)
- [ ] User Management
  - [ ] User list with filters
  - [ ] User create/edit form
  - [ ] Role assignment
  - [ ] Hierarchy assignment
  - [ ] Activate/deactivate
- [ ] Master Data Management
  - [ ] Pipeline stages & statuses
  - [ ] Activity types
  - [ ] Lead sources
  - [ ] COB/LOB
  - [ ] Industries
  - [ ] Company/Ownership types
- [ ] 4DX Configuration
  - [ ] Measure definitions
  - [ ] Scoring periods
  - [ ] Weight configuration
- [ ] Cadence Configuration
  - [ ] Schedule settings
  - [ ] Pre-meeting deadline
- [ ] Bulk Upload
  - [ ] Template download
  - [ ] File upload & validation
  - [ ] Preview with error highlighting
  - [ ] Process confirmation

---

### 13. Notifications

- [ ] Create notifications table (Drift)
- [ ] Implement `NotificationRepository`
- [ ] Implement `NotificationService`
  - [ ] Activity reminders
  - [ ] Cadence reminders
  - [ ] Referral updates
  - [ ] Sync failures
- [ ] Implement `NotificationListScreen`
- [ ] Implement `NotificationPreferencesScreen`
- [ ] In-app notification badge

---

### 14. Reporting & Export

- [ ] Implement report generation logic
- [ ] Activity reports
- [ ] Pipeline reports
- [ ] Score reports
- [ ] Customer reports
- [ ] Export to Excel/PDF/CSV
- [ ] Implement `ReportsScreen`

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

### Performance
- [ ] App launch time < 3 seconds
- [ ] List scroll smooth at 60fps
- [ ] Offline operations instant
- [ ] Sync queue processes within 5 seconds when online
- [ ] Memory usage < 200MB

### Security
- [ ] JWT token secure storage
- [ ] SQLCipher encryption enabled
- [ ] RLS policies tested
- [ ] No sensitive data in logs
- [ ] Certificate pinning (optional)

### Accessibility
- [ ] Screen reader support
- [ ] Sufficient color contrast
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

*Implementation checklist for LeadX CRM - January 2025*
