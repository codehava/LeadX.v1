# Cadence Feature Implementation Plan

## Executive Summary

The Cadence of Accountability feature implements **4DX Discipline 4** - a structured weekly/monthly meeting system where participants submit pre-meeting forms (Q1-Q4), hosts track attendance, and feedback is exchanged. The system integrates with the existing scoring framework.

---

## Current Status

### Completed
- [x] Documentation (4 detailed docs in `docs/`)
- [x] Drift table definitions (`lib/data/database/tables/cadence.dart`) - includes `preMeetingHours`
- [x] Supabase SQL schema (`docs/04-database/sql/03_4dx_system_seed.sql`) - fully aligned with Drift
- [x] RLS policies (`docs/04-database/sql/04_rls_policies.sql`) - uses `facilitator_id`
- [x] Schema migration v3 (`docs/04-database/sql/migrations/20260130_cadence_schema_v3.sql`)
- [x] Route names registered (`lib/config/routes/route_names.dart`)
- [x] Routes implemented in `app_router.dart`
- [x] Domain entities (Freezed models) - `lib/domain/entities/cadence.dart`
- [x] DTOs (Data Transfer Objects) - `lib/data/dtos/cadence_dtos.dart`
- [x] Repository interfaces - `lib/domain/repositories/cadence_repository.dart`
- [x] Repository implementations - `lib/data/repositories/cadence_repository_impl.dart`
- [x] Local data sources - `lib/data/datasources/local/cadence_local_data_source.dart`
- [x] Remote data sources (Supabase) - `lib/data/datasources/remote/cadence_remote_data_source.dart`
- [x] Riverpod providers - `lib/presentation/providers/cadence_providers.dart`
- [x] UI screens:
  - `lib/presentation/screens/cadence/cadence_list_screen.dart` (participant view)
  - `lib/presentation/screens/cadence/cadence_detail_screen.dart` (meeting detail)
  - `lib/presentation/screens/cadence/cadence_form_screen.dart` (pre-meeting form Q1-Q4)
  - `lib/presentation/screens/cadence/host_dashboard_screen.dart` (host management)
- [x] UI widgets:
  - `lib/presentation/screens/cadence/widgets/meeting_card.dart`
  - `lib/presentation/screens/cadence/widgets/participant_card.dart`
- [x] Attendance marking (bottom sheet in detail screen)
- [x] Feedback management (bottom sheet in detail screen)
- [x] Score calculation logic (attendance + form submission scoring)

### Not Yet Implemented
- [ ] `getTeamMemberIds()` - needs user_hierarchy table query
- [ ] Notification integration (reminders for form deadlines)
- [ ] Integration with main scoring system (UserScores table)
- [ ] Admin cadence config management UI
- [ ] Sync handlers in SyncService for cadence tables

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                               │
├──────────────────────────────────────────────────────────────────────────────┤
│  Screens                          │  Providers                               │
│  ├── CadenceScheduleScreen        │  ├── cadenceScheduleProvider            │
│  ├── PreCadenceFormScreen         │  ├── cadenceMeetingProvider             │
│  ├── CadenceHistoryScreen         │  ├── cadenceParticipantProvider         │
│  ├── HostDashboardScreen          │  ├── cadenceFormProvider                │
│  ├── HostMeetingScreen            │  ├── hostDashboardProvider              │
│  ├── ParticipantDetailScreen      │  └── cadenceActionNotifier              │
│  └── MeetingSummaryScreen         │                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                               DOMAIN LAYER                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│  Entities (Freezed)               │  Repository Interfaces                   │
│  ├── CadenceScheduleConfig        │  └── CadenceRepository                   │
│  ├── CadenceMeeting               │      ├── watchUpcomingMeetings()        │
│  ├── CadenceParticipant           │      ├── submitPreMeetingForm()         │
│  └── CadenceFeedback              │      ├── markAttendance()               │
│                                   │      ├── saveFeedback()                  │
│                                   │      └── startMeeting() / endMeeting()  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                DATA LAYER                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│  DTOs                             │  Data Sources                            │
│  ├── CadenceScheduleDto           │  ├── CadenceLocalDataSource             │
│  ├── CadenceMeetingDto            │  │   └── Drift (SQLite) operations      │
│  ├── CadenceParticipantDto        │  └── CadenceRemoteDataSource            │
│  └── CadenceFormSubmissionDto     │      └── Supabase operations            │
│                                   │                                          │
│  Repository Implementation        │  Services                                │
│  └── CadenceRepositoryImpl        │  └── SyncService (existing)             │
│      └── Offline-first pattern    │      └── Add cadence sync handlers      │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Meeting Scheduling & Participant Assignment

### Host-Participant Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     CADENCE MEETING HIERARCHY                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CADENCE LEVEL      HOST ROLE    PARTICIPANT ROLE    FREQUENCY              │
│  ─────────────────────────────────────────────────────────────────────────  │
│  Team Cadence       BH           RMs (direct)        Weekly (Monday)        │
│  Branch Cadence     BM           BHs (direct)        Weekly (Friday)        │
│  Regional Cadence   ROH          BMs (direct)        Monthly (Last Friday)  │
│  Company Cadence    Admin     ROHs (direct)       Quarterly (1st Monday) │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Participant Determination Logic

Uses the `user_hierarchy` closure table to efficiently query direct reports:

```dart
/// Get direct subordinates for a host (depth=1 means direct child)
Future<List<User>> getDirectSubordinates(String hostId) async {
  final query = _db.select(_db.users).join([
    innerJoin(
      _db.userHierarchy,
      _db.userHierarchy.descendantId.equalsExp(_db.users.id),
    ),
  ])
    ..where(_db.userHierarchy.ancestorId.equals(hostId))
    ..where(_db.userHierarchy.depth.equals(1))  // Direct reports only
    ..where(_db.users.isActive.equals(true));

  return query.get().then((rows) =>
    rows.map((row) => _mapToUser(row.readTable(_db.users))).toList()
  );
}

/// Filter subordinates by target role for the cadence config
Future<List<User>> getParticipantsForConfig(
  String hostId,
  CadenceScheduleConfig config,
) async {
  final query = _db.select(_db.users).join([
    innerJoin(
      _db.userHierarchy,
      _db.userHierarchy.descendantId.equalsExp(_db.users.id),
    ),
  ])
    ..where(_db.userHierarchy.ancestorId.equals(hostId))
    ..where(_db.userHierarchy.depth.equals(1))
    ..where(_db.users.isActive.equals(true))
    ..where(_db.users.role.equals(config.targetRole)); // e.g., 'RM' for BH host

  return query.get().then((rows) =>
    rows.map((row) => _mapToUser(row.readTable(_db.users))).toList()
  );
}
```

### Meeting Generation Strategy

**Option A: Server-Side Scheduled Job (Recommended)**

PostgreSQL function + pg_cron to auto-generate meetings:

```sql
-- Function to generate upcoming cadence meetings
CREATE OR REPLACE FUNCTION generate_cadence_meetings()
RETURNS void AS $$
DECLARE
  config RECORD;
  host RECORD;
  next_meeting_date TIMESTAMPTZ;
  meeting_id UUID;
BEGIN
  -- For each active config
  FOR config IN
    SELECT * FROM cadence_schedule_config WHERE is_active = true
  LOOP
    -- For each potential host of this config type
    FOR host IN
      SELECT * FROM users
      WHERE role = config.facilitator_role AND is_active = true
    LOOP
      -- Calculate next meeting date based on config
      next_meeting_date := calculate_next_meeting_date(
        config.frequency,
        config.day_of_week,
        config.day_of_month,
        config.default_time::time
      );

      -- Check if meeting already exists for this host/date
      IF NOT EXISTS (
        SELECT 1 FROM cadence_meetings
        WHERE facilitator_id = host.id
        AND DATE(scheduled_at) = DATE(next_meeting_date)
        AND status != 'CANCELLED'
      ) THEN
        -- Create meeting
        meeting_id := uuid_generate_v4();
        INSERT INTO cadence_meetings (
          id, config_id, title, scheduled_at, duration_minutes,
          facilitator_id, status, created_by, created_at, updated_at
        ) VALUES (
          meeting_id,
          config.id,
          config.name || ' - ' || host.name,
          next_meeting_date,
          config.duration_minutes,
          host.id,
          'SCHEDULED',
          host.id,
          NOW(),
          NOW()
        );

        -- Auto-populate participants (direct subordinates with target role)
        INSERT INTO cadence_participants (
          id, meeting_id, user_id, attendance_status,
          created_at, updated_at
        )
        SELECT
          uuid_generate_v4(),
          meeting_id,
          uh.descendant_id,
          'PENDING',
          NOW(),
          NOW()
        FROM user_hierarchy uh
        JOIN users u ON u.id = uh.descendant_id
        WHERE uh.ancestor_id = host.id
          AND uh.depth = 1  -- Direct reports only
          AND u.is_active = true
          AND u.role = config.target_role;

        -- Carry forward Q4 (next commitment) from last meeting to Q1
        UPDATE cadence_participants cp
        SET q1_previous_commitment = (
          SELECT prev.q4_next_commitment
          FROM cadence_participants prev
          JOIN cadence_meetings prev_m ON prev_m.id = prev.meeting_id
          WHERE prev.user_id = cp.user_id
            AND prev_m.facilitator_id = host.id
            AND prev_m.status = 'COMPLETED'
          ORDER BY prev_m.scheduled_at DESC
          LIMIT 1
        )
        WHERE cp.meeting_id = meeting_id;
      END IF;
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Schedule to run daily at midnight
SELECT cron.schedule('generate-cadence-meetings', '0 0 * * *', 'SELECT generate_cadence_meetings()');
```

**Option B: Client-Side On-Demand Generation**

```dart
/// Service to ensure meetings exist for host
class CadenceMeetingGenerator {
  Future<void> ensureUpcomingMeetingsExist(String hostId) async {
    // Get config for this host's role
    final user = await _userRepository.getUserById(hostId);
    final config = await _getConfigForFacilitatorRole(user.role);
    if (config == null) return; // Not a host role

    // Calculate next 4 weeks of meeting dates
    final upcomingDates = _calculateUpcomingMeetingDates(config, weeks: 4);

    for (final date in upcomingDates) {
      // Check if meeting exists
      final exists = await _meetingExists(hostId, date);
      if (!exists) {
        await _createMeetingWithParticipants(hostId, config, date);
      }
    }
  }

  Future<void> _createMeetingWithParticipants(
    String hostId,
    CadenceScheduleConfig config,
    DateTime scheduledAt,
  ) async {
    // Create meeting
    final meetingId = const Uuid().v4();
    await _localDataSource.insertMeeting(CadenceMeetingsCompanion.insert(
      id: meetingId,
      configId: config.id,
      title: '${config.name} - Week ${_getWeekNumber(scheduledAt)}',
      scheduledAt: scheduledAt,
      durationMinutes: config.durationMinutes,
      facilitatorId: hostId,
      status: const Value('SCHEDULED'),
      createdBy: hostId,
      isPendingSync: const Value(true),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Get direct subordinates with target role
    final subordinates = await _getParticipantsForConfig(hostId, config);

    // Create participant records
    for (final sub in subordinates) {
      // Get previous commitment (Q4 from last meeting)
      final previousCommitment = await _getLastCommitment(sub.id, hostId);

      await _localDataSource.insertParticipant(CadenceParticipantsCompanion.insert(
        id: const Uuid().v4(),
        meetingId: meetingId,
        userId: sub.id,
        q1PreviousCommitment: Value(previousCommitment),
        isPendingSync: const Value(true),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Queue meeting + participants for sync
    await _syncService.queueOperation(
      entityType: SyncEntityType.cadenceMeeting,
      entityId: meetingId,
      operation: SyncOperation.create,
      payload: { /* meeting data */ },
    );
  }
}
```

### Schedule Config Seed Data

**Required seed data for `cadence_schedule_config`:**

```sql
INSERT INTO cadence_schedule_config (
  id, name, description, target_role, facilitator_role,
  frequency, day_of_week, default_time, duration_minutes,
  pre_meeting_hours, is_active, created_at, updated_at
) VALUES
-- Team Cadence: BH hosts RMs, Weekly Monday 09:00, 24h form deadline
(
  'cfg-team', 'Team Cadence', 'Weekly team accountability meeting',
  'RM', 'BH', 'WEEKLY', 1, '09:00', 30, 24, true, NOW(), NOW()
),
-- Branch Cadence: BM hosts BHs, Weekly Friday 09:00, 24h form deadline
(
  'cfg-branch', 'Branch Cadence', 'Weekly branch review meeting',
  'BH', 'BM', 'WEEKLY', 5, '09:00', 45, 24, true, NOW(), NOW()
),
-- Regional Cadence: ROH hosts BMs, Monthly last Friday 14:00, 24h form deadline
(
  'cfg-regional', 'Regional Cadence', 'Monthly regional review meeting',
  'BM', 'ROH', 'MONTHLY', 5, '14:00', 60, 24, true, NOW(), NOW()
),
-- Company Cadence: Director hosts ROHs, Quarterly 1st Monday 09:00, 48h form deadline
(
  'cfg-company', 'Company Cadence', 'Quarterly company review meeting',
  'ROH', 'DIRECTOR', 'QUARTERLY', 1, '09:00', 90, 48, true, NOW(), NOW()
);
```

### Q1 Auto-Population (Commitment Carry-Forward)

When a meeting is created, Q1 (previous commitment) should be auto-populated from the participant's Q4 (next commitment) in their most recent completed meeting with the same host:

```dart
/// Get the last commitment for a participant to populate Q1
Future<String?> _getLastCommitment(String participantId, String hostId) async {
  final query = _db.customSelect('''
    SELECT cp.q4_next_commitment
    FROM cadence_participants cp
    JOIN cadence_meetings cm ON cm.id = cp.meeting_id
    WHERE cp.user_id = ?
      AND cm.facilitator_id = ?
      AND cm.status = 'COMPLETED'
      AND cp.q4_next_commitment IS NOT NULL
    ORDER BY cm.scheduled_at DESC
    LIMIT 1
  ''', variables: [
    Variable.withString(participantId),
    Variable.withString(hostId),
  ]);

  final result = await query.getSingleOrNull();
  return result?.read<String?>('q4_next_commitment');
}
```

### Repository Methods for Host

Add to `CadenceRepository`:

```dart
// ==========================================
// Host Scheduling Operations
// ==========================================

/// Get schedule config for current user's role as facilitator
Future<CadenceScheduleConfig?> getMyScheduleConfig();

/// Ensure upcoming meetings exist for current user as host
/// Creates meetings + auto-populates participants if missing
Future<Either<Failure, List<CadenceMeeting>>> ensureUpcomingMeetings({
  int weeksAhead = 4,
});

/// Get direct subordinates who should be participants (based on config)
Future<List<User>> getMyTeamMembers();

/// Manually add a participant to a meeting (edge case)
Future<Either<Failure, CadenceParticipant>> addParticipant({
  required String meetingId,
  required String userId,
});

/// Remove a participant from a meeting (edge case)
Future<Either<Failure, Unit>> removeParticipant(String participantId);
```

---

## Implementation Phases

### Phase 1: Domain Layer (Foundation)

#### 1.1 Create Domain Entities

**File: `lib/domain/entities/cadence.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cadence.freezed.dart';
part 'cadence.g.dart';

// ============================================
// ENUMS
// ============================================

enum MeetingFrequency { daily, weekly, monthly, quarterly }
enum MeetingStatus { scheduled, inProgress, completed, cancelled }
enum AttendanceStatus { pending, present, late, excused, absent }
enum FormSubmissionStatus { onTime, late, veryLate, notSubmitted }
enum CommitmentCompletionStatus { completed, partial, notDone }

// ============================================
// SCHEDULE CONFIG ENTITY
// ============================================

@freezed
class CadenceScheduleConfig with _$CadenceScheduleConfig {
  const factory CadenceScheduleConfig({
    required String id,
    required String name,
    required String targetRole,      // RM, BH, BM, ROH
    required String facilitatorRole, // BH, BM, ROH, Director
    required MeetingFrequency frequency,
    int? dayOfWeek,                  // 0=Sunday, 6=Saturday
    int? dayOfMonth,                 // 1-31
    String? defaultTime,             // HH:mm format
    @Default(60) int durationMinutes,
    @Default(24) int preMeetingHours, // Hours before meeting for form deadline
    @Default(true) bool isActive,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CadenceScheduleConfig;

  factory CadenceScheduleConfig.fromJson(Map<String, dynamic> json) =>
      _$CadenceScheduleConfigFromJson(json);
}

// ============================================
// MEETING ENTITY
// ============================================

@freezed
class CadenceMeeting with _$CadenceMeeting {
  const factory CadenceMeeting({
    required String id,
    required String configId,
    required String title,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String facilitatorId,
    @Default(MeetingStatus.scheduled) MeetingStatus status,
    String? location,
    String? meetingLink,
    String? agenda,
    String? notes,
    DateTime? startedAt,
    DateTime? completedAt,
    required String createdBy,
    @Default(false) bool isPendingSync,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Computed/joined fields
    String? facilitatorName,
    String? configName,
    int? totalParticipants,
    int? submittedFormCount,
    int? presentCount,
  }) = _CadenceMeeting;

  const CadenceMeeting._();

  factory CadenceMeeting.fromJson(Map<String, dynamic> json) =>
      _$CadenceMeetingFromJson(json);

  /// Calculate form submission deadline (uses default 24h; repository should use config.preMeetingHours)
  DateTime formDeadlineWithHours(int preMeetingHours) => scheduledAt.subtract(
    Duration(hours: preMeetingHours),
  );

  /// Check if meeting is upcoming
  bool get isUpcoming => status == MeetingStatus.scheduled &&
      scheduledAt.isAfter(DateTime.now());

  /// Check if form deadline has passed
  bool get isFormDeadlinePassed => DateTime.now().isAfter(formDeadline);

  /// Get form submission progress text
  String get formProgressText =>
      '${submittedFormCount ?? 0}/${totalParticipants ?? 0} submitted';
}

// ============================================
// PARTICIPANT ENTITY (Combined: Attendance + Form + Feedback)
// ============================================

@freezed
class CadenceParticipant with _$CadenceParticipant {
  const factory CadenceParticipant({
    required String id,
    required String meetingId,
    required String userId,

    // Attendance
    @Default(AttendanceStatus.pending) AttendanceStatus attendanceStatus,
    DateTime? arrivedAt,
    String? excusedReason,
    int? attendanceScoreImpact,
    String? markedBy,
    DateTime? markedAt,

    // Pre-meeting form (Q1-Q4)
    @Default(false) bool preMeetingSubmitted,
    String? q1PreviousCommitment,
    CommitmentCompletionStatus? q1CompletionStatus,
    String? q2WhatAchieved,
    String? q3Obstacles,
    String? q4NextCommitment,
    DateTime? formSubmittedAt,
    FormSubmissionStatus? formSubmissionStatus,
    int? formScoreImpact,

    // Host notes & feedback
    String? hostNotes,
    String? feedbackText,
    DateTime? feedbackGivenAt,
    DateTime? feedbackUpdatedAt,

    // Sync
    @Default(false) bool isPendingSync,
    DateTime? lastSyncAt,
    required DateTime createdAt,
    required DateTime updatedAt,

    // Joined fields
    String? userName,
    String? userRole,
  }) = _CadenceParticipant;

  const CadenceParticipant._();

  factory CadenceParticipant.fromJson(Map<String, dynamic> json) =>
      _$CadenceParticipantFromJson(json);

  /// Total score impact (attendance + form)
  int get totalScoreImpact =>
      (attendanceScoreImpact ?? 0) + (formScoreImpact ?? 0);

  /// Check if feedback has been given
  bool get hasFeedback => feedbackText != null && feedbackText!.isNotEmpty;

  /// Check if form is complete (Q2 and Q4 required)
  bool get isFormComplete =>
      q2WhatAchieved != null &&
      q2WhatAchieved!.isNotEmpty &&
      q4NextCommitment != null &&
      q4NextCommitment!.isNotEmpty;
}

// ============================================
// FORM SUBMISSION DTO (For creating/updating forms)
// ============================================

@freezed
class CadenceFormSubmission with _$CadenceFormSubmission {
  const factory CadenceFormSubmission({
    required String participantId,
    CommitmentCompletionStatus? q1CompletionStatus,
    required String q2WhatAchieved,
    String? q3Obstacles,
    required String q4NextCommitment,
  }) = _CadenceFormSubmission;

  factory CadenceFormSubmission.fromJson(Map<String, dynamic> json) =>
      _$CadenceFormSubmissionFromJson(json);
}
```

#### 1.2 Create Repository Interface

**File: `lib/domain/repositories/cadence_repository.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cadence.dart';

abstract class CadenceRepository {
  // ==========================================
  // Schedule Config Operations
  // ==========================================

  /// Get all active cadence schedule configs
  Future<List<CadenceScheduleConfig>> getActiveConfigs();

  /// Get config by target role
  Future<CadenceScheduleConfig?> getConfigForRole(String role);

  // ==========================================
  // Meeting Operations (Streams)
  // ==========================================

  /// Watch upcoming meetings for current user (as participant)
  Stream<List<CadenceMeeting>> watchUpcomingMeetings();

  /// Watch past meetings for current user (as participant)
  Stream<List<CadenceMeeting>> watchPastMeetings({int? limit});

  /// Watch meetings where current user is host
  Stream<List<CadenceMeeting>> watchHostedMeetings();

  /// Watch single meeting with participants
  Stream<CadenceMeeting?> watchMeeting(String meetingId);

  /// Watch participants for a meeting
  Stream<List<CadenceParticipant>> watchMeetingParticipants(String meetingId);

  /// Watch current user's participation record for a meeting
  Stream<CadenceParticipant?> watchMyParticipation(String meetingId);

  // ==========================================
  // Meeting Operations (Actions)
  // ==========================================

  /// Start a meeting (host only)
  Future<Either<Failure, CadenceMeeting>> startMeeting(String meetingId);

  /// End a meeting (host only)
  Future<Either<Failure, CadenceMeeting>> endMeeting(String meetingId);

  /// Cancel a meeting (host only)
  Future<Either<Failure, CadenceMeeting>> cancelMeeting(
    String meetingId,
    String reason,
  );

  /// Update meeting notes (host only)
  Future<Either<Failure, Unit>> updateMeetingNotes(
    String meetingId,
    String notes,
  );

  // ==========================================
  // Participant Operations
  // ==========================================

  /// Submit pre-meeting form (Q1-Q4)
  Future<Either<Failure, CadenceParticipant>> submitPreMeetingForm(
    CadenceFormSubmission submission,
  );

  /// Save form as draft (not submitted)
  Future<Either<Failure, CadenceParticipant>> saveFormDraft(
    CadenceFormSubmission submission,
  );

  /// Mark attendance for a participant (host only)
  Future<Either<Failure, CadenceParticipant>> markAttendance({
    required String participantId,
    required AttendanceStatus status,
    String? excusedReason,
  });

  /// Batch mark attendance for multiple participants
  Future<Either<Failure, List<CadenceParticipant>>> batchMarkAttendance({
    required String meetingId,
    required Map<String, AttendanceStatus> attendanceMap,
  });

  /// Save host notes for a participant (host only)
  Future<Either<Failure, Unit>> saveHostNotes({
    required String participantId,
    required String notes,
  });

  /// Give feedback to a participant (host only)
  Future<Either<Failure, Unit>> saveFeedback({
    required String participantId,
    required String feedbackText,
  });

  // ==========================================
  // History & Reporting
  // ==========================================

  /// Get participant's cadence history with feedback
  Future<List<CadenceParticipant>> getParticipantHistory({
    required String userId,
    int? limit,
  });

  /// Get meeting summary (for post-meeting view)
  Future<CadenceMeetingSummary?> getMeetingSummary(String meetingId);
}

/// Summary data for completed meetings
@freezed
class CadenceMeetingSummary with _$CadenceMeetingSummary {
  const factory CadenceMeetingSummary({
    required CadenceMeeting meeting,
    required int totalParticipants,
    required int presentCount,
    required int lateCount,
    required int excusedCount,
    required int absentCount,
    required int formSubmittedCount,
    required int feedbackGivenCount,
    required Duration actualDuration,
    required List<CadenceParticipant> participants,
  }) = _CadenceMeetingSummary;
}
```

---

### Phase 2: Data Layer

#### 2.1 Create DTOs

**File: `lib/data/dtos/cadence_dtos.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/cadence.dart';

part 'cadence_dtos.freezed.dart';
part 'cadence_dtos.g.dart';

// ============================================
// SCHEDULE CONFIG DTO
// ============================================

@freezed
class CadenceScheduleConfigDto with _$CadenceScheduleConfigDto {
  const factory CadenceScheduleConfigDto({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'target_role') required String targetRole,
    @JsonKey(name: 'facilitator_role') required String facilitatorRole,
    required String frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') @Default(60) int durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') @Default(24) int preMeetingHours,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CadenceScheduleConfigDto;

  factory CadenceScheduleConfigDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceScheduleConfigDtoFromJson(json);
}

// ============================================
// MEETING DTO
// ============================================

@freezed
class CadenceMeetingDto with _$CadenceMeetingDto {
  const factory CadenceMeetingDto({
    required String id,
    @JsonKey(name: 'config_id') required String configId,
    required String title,
    @JsonKey(name: 'scheduled_at') required DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'facilitator_id') required String facilitatorId,
    @Default('SCHEDULED') String status,
    String? location,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    String? agenda,
    String? notes,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CadenceMeetingDto;

  factory CadenceMeetingDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceMeetingDtoFromJson(json);
}

// ============================================
// PARTICIPANT DTO (Combined table)
// ============================================

@freezed
class CadenceParticipantDto with _$CadenceParticipantDto {
  const factory CadenceParticipantDto({
    required String id,
    @JsonKey(name: 'meeting_id') required String meetingId,
    @JsonKey(name: 'user_id') required String userId,

    // Attendance
    @JsonKey(name: 'attendance_status') @Default('PENDING') String attendanceStatus,
    @JsonKey(name: 'arrived_at') DateTime? arrivedAt,
    @JsonKey(name: 'excused_reason') String? excusedReason,
    @JsonKey(name: 'attendance_score_impact') int? attendanceScoreImpact,
    @JsonKey(name: 'marked_by') String? markedBy,
    @JsonKey(name: 'marked_at') DateTime? markedAt,

    // Pre-meeting form
    @JsonKey(name: 'pre_meeting_submitted') @Default(false) bool preMeetingSubmitted,
    @JsonKey(name: 'q1_previous_commitment') String? q1PreviousCommitment,
    @JsonKey(name: 'q1_completion_status') String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') String? q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') String? q4NextCommitment,
    @JsonKey(name: 'form_submitted_at') DateTime? formSubmittedAt,
    @JsonKey(name: 'form_submission_status') String? formSubmissionStatus,
    @JsonKey(name: 'form_score_impact') int? formScoreImpact,

    // Feedback
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
    @JsonKey(name: 'feedback_given_at') DateTime? feedbackGivenAt,
    @JsonKey(name: 'feedback_updated_at') DateTime? feedbackUpdatedAt,

    // Sync
    @JsonKey(name: 'last_sync_at') DateTime? lastSyncAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CadenceParticipantDto;

  factory CadenceParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceParticipantDtoFromJson(json);
}

// ============================================
// FORM CREATE DTO (For submitting forms)
// ============================================

@freezed
class CadenceFormCreateDto with _$CadenceFormCreateDto {
  const factory CadenceFormCreateDto({
    @JsonKey(name: 'q1_completion_status') String? q1CompletionStatus,
    @JsonKey(name: 'q2_what_achieved') required String q2WhatAchieved,
    @JsonKey(name: 'q3_obstacles') String? q3Obstacles,
    @JsonKey(name: 'q4_next_commitment') required String q4NextCommitment,
  }) = _CadenceFormCreateDto;

  factory CadenceFormCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceFormCreateDtoFromJson(json);
}

// ============================================
// ATTENDANCE UPDATE DTO
// ============================================

@freezed
class AttendanceUpdateDto with _$AttendanceUpdateDto {
  const factory AttendanceUpdateDto({
    @JsonKey(name: 'attendance_status') required String attendanceStatus,
    @JsonKey(name: 'excused_reason') String? excusedReason,
    @JsonKey(name: 'arrived_at') DateTime? arrivedAt,
  }) = _AttendanceUpdateDto;

  factory AttendanceUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$AttendanceUpdateDtoFromJson(json);
}

// ============================================
// FEEDBACK UPDATE DTO
// ============================================

@freezed
class FeedbackUpdateDto with _$FeedbackUpdateDto {
  const factory FeedbackUpdateDto({
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
  }) = _FeedbackUpdateDto;

  factory FeedbackUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$FeedbackUpdateDtoFromJson(json);
}
```

#### 2.2 Create Local Data Source

**File: `lib/data/datasources/local/cadence_local_data_source.dart`**

```dart
import 'package:drift/drift.dart';
import '../../database/app_database.dart';

class CadenceLocalDataSource {
  CadenceLocalDataSource(this._db);
  final AppDatabase _db;

  // ==========================================
  // Schedule Config Operations
  // ==========================================

  Future<List<CadenceScheduleConfigData>> getActiveConfigs() async {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.isActive.equals(true)))
        .get();
  }

  Future<CadenceScheduleConfigData?> getConfigByTargetRole(String role) async {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.targetRole.equals(role))
          ..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();
  }

  // ==========================================
  // Meeting Operations
  // ==========================================

  Stream<List<CadenceMeetingData>> watchUpcomingMeetingsForUser(String userId) {
    final query = _db.select(_db.cadenceMeetings).join([
      innerJoin(
        _db.cadenceParticipants,
        _db.cadenceParticipants.meetingId.equalsExp(_db.cadenceMeetings.id),
      ),
    ])
      ..where(_db.cadenceParticipants.userId.equals(userId))
      ..where(_db.cadenceMeetings.status.equals('SCHEDULED'))
      ..where(_db.cadenceMeetings.scheduledAt.isBiggerThanValue(DateTime.now()))
      ..orderBy([OrderingTerm.asc(_db.cadenceMeetings.scheduledAt)]);

    return query.watch().map((rows) =>
        rows.map((row) => row.readTable(_db.cadenceMeetings)).toList());
  }

  Stream<List<CadenceMeetingData>> watchPastMeetingsForUser(
    String userId, {
    int? limit,
  }) {
    var query = _db.select(_db.cadenceMeetings).join([
      innerJoin(
        _db.cadenceParticipants,
        _db.cadenceParticipants.meetingId.equalsExp(_db.cadenceMeetings.id),
      ),
    ])
      ..where(_db.cadenceParticipants.userId.equals(userId))
      ..where(_db.cadenceMeetings.status.equals('COMPLETED'))
      ..orderBy([OrderingTerm.desc(_db.cadenceMeetings.scheduledAt)]);

    if (limit != null) {
      query = query..limit(limit);
    }

    return query.watch().map((rows) =>
        rows.map((row) => row.readTable(_db.cadenceMeetings)).toList());
  }

  Stream<List<CadenceMeetingData>> watchHostedMeetings(String hostId) {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.facilitatorId.equals(hostId))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .watch();
  }

  Stream<CadenceMeetingData?> watchMeeting(String meetingId) {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.id.equals(meetingId)))
        .watchSingleOrNull();
  }

  Future<CadenceMeetingData?> getMeetingById(String meetingId) {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.id.equals(meetingId)))
        .getSingleOrNull();
  }

  Future<int> updateMeeting(String meetingId, CadenceMeetingsCompanion data) {
    return (_db.update(_db.cadenceMeetings)
          ..where((t) => t.id.equals(meetingId)))
        .write(data);
  }

  // ==========================================
  // Participant Operations
  // ==========================================

  Stream<List<CadenceParticipantData>> watchMeetingParticipants(
    String meetingId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Stream<CadenceParticipantData?> watchParticipation(
    String meetingId,
    String userId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  Future<CadenceParticipantData?> getParticipant(String participantId) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.id.equals(participantId)))
        .getSingleOrNull();
  }

  Future<CadenceParticipantData?> getParticipation(
    String meetingId,
    String userId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<int> updateParticipant(
    String participantId,
    CadenceParticipantsCompanion data,
  ) {
    return (_db.update(_db.cadenceParticipants)
          ..where((t) => t.id.equals(participantId)))
        .write(data);
  }

  Future<int> insertParticipant(CadenceParticipantsCompanion data) {
    return _db.into(_db.cadenceParticipants).insert(data);
  }

  // ==========================================
  // History Operations
  // ==========================================

  Future<List<CadenceParticipantData>> getParticipantHistory(
    String userId, {
    int? limit,
  }) async {
    var query = _db.select(_db.cadenceParticipants).join([
      innerJoin(
        _db.cadenceMeetings,
        _db.cadenceMeetings.id.equalsExp(_db.cadenceParticipants.meetingId),
      ),
    ])
      ..where(_db.cadenceParticipants.userId.equals(userId))
      ..where(_db.cadenceMeetings.status.equals('COMPLETED'))
      ..orderBy([OrderingTerm.desc(_db.cadenceMeetings.scheduledAt)]);

    if (limit != null) {
      query = query..limit(limit);
    }

    final results = await query.get();
    return results
        .map((row) => row.readTable(_db.cadenceParticipants))
        .toList();
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  Future<List<CadenceParticipantData>> getPendingSyncParticipants() {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.isPendingSync.equals(true)))
        .get();
  }

  Future<List<CadenceMeetingData>> getPendingSyncMeetings() {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.isPendingSync.equals(true)))
        .get();
  }
}
```

#### 2.3 Create Remote Data Source

**File: `lib/data/datasources/remote/cadence_remote_data_source.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dtos/cadence_dtos.dart';

class CadenceRemoteDataSource {
  CadenceRemoteDataSource(this._supabase);
  final SupabaseClient _supabase;

  // ==========================================
  // Schedule Config
  // ==========================================

  Future<List<CadenceScheduleConfigDto>> fetchActiveConfigs() async {
    final response = await _supabase
        .from('cadence_schedule_config')
        .select()
        .eq('is_active', true)
        .order('created_at');

    return (response as List)
        .map((json) => CadenceScheduleConfigDto.fromJson(json))
        .toList();
  }

  // ==========================================
  // Meetings
  // ==========================================

  Future<List<CadenceMeetingDto>> fetchMeetingsForUser(String userId) async {
    final response = await _supabase
        .from('cadence_meetings')
        .select('''
          *,
          cadence_participants!inner(user_id)
        ''')
        .eq('cadence_participants.user_id', userId)
        .order('scheduled_at', ascending: false);

    return (response as List)
        .map((json) => CadenceMeetingDto.fromJson(json))
        .toList();
  }

  Future<CadenceMeetingDto> updateMeeting(
    String meetingId,
    Map<String, dynamic> data,
  ) async {
    final response = await _supabase
        .from('cadence_meetings')
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', meetingId)
        .select()
        .single();

    return CadenceMeetingDto.fromJson(response);
  }

  // ==========================================
  // Participants
  // ==========================================

  Future<List<CadenceParticipantDto>> fetchMeetingParticipants(
    String meetingId,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .select()
        .eq('meeting_id', meetingId)
        .order('created_at');

    return (response as List)
        .map((json) => CadenceParticipantDto.fromJson(json))
        .toList();
  }

  Future<CadenceParticipantDto> submitPreMeetingForm(
    String participantId,
    CadenceFormCreateDto form,
    String submissionStatus,
    int scoreImpact,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .update({
          'pre_meeting_submitted': true,
          'q1_completion_status': form.q1CompletionStatus,
          'q2_what_achieved': form.q2WhatAchieved,
          'q3_obstacles': form.q3Obstacles,
          'q4_next_commitment': form.q4NextCommitment,
          'form_submitted_at': DateTime.now().toIso8601String(),
          'form_submission_status': submissionStatus,
          'form_score_impact': scoreImpact,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', participantId)
        .select()
        .single();

    return CadenceParticipantDto.fromJson(response);
  }

  Future<CadenceParticipantDto> updateAttendance(
    String participantId,
    AttendanceUpdateDto attendance,
    int scoreImpact,
    String markedBy,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .update({
          'attendance_status': attendance.attendanceStatus,
          'arrived_at': attendance.arrivedAt?.toIso8601String(),
          'excused_reason': attendance.excusedReason,
          'attendance_score_impact': scoreImpact,
          'marked_by': markedBy,
          'marked_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', participantId)
        .select()
        .single();

    return CadenceParticipantDto.fromJson(response);
  }

  Future<CadenceParticipantDto> updateFeedback(
    String participantId,
    FeedbackUpdateDto feedback,
  ) async {
    final now = DateTime.now().toIso8601String();

    // Get existing to check if this is first feedback
    final existing = await _supabase
        .from('cadence_participants')
        .select('feedback_given_at')
        .eq('id', participantId)
        .single();

    final isFirstFeedback = existing['feedback_given_at'] == null;

    final response = await _supabase
        .from('cadence_participants')
        .update({
          'host_notes': feedback.hostNotes,
          'feedback_text': feedback.feedbackText,
          if (isFirstFeedback) 'feedback_given_at': now,
          'feedback_updated_at': now,
          'updated_at': now,
        })
        .eq('id', participantId)
        .select()
        .single();

    return CadenceParticipantDto.fromJson(response);
  }

  // ==========================================
  // Sync
  // ==========================================

  Future<void> syncParticipant(CadenceParticipantDto participant) async {
    await _supabase.from('cadence_participants').upsert(participant.toJson());
  }

  Future<void> syncMeeting(CadenceMeetingDto meeting) async {
    await _supabase.from('cadence_meetings').upsert(meeting.toJson());
  }
}
```

#### 2.4 Create Repository Implementation

**File: `lib/data/repositories/cadence_repository_impl.dart`**

Follow the pattern from `pipeline_repository_impl.dart`:
- Constructor injection for all dependencies
- Offline-first: write to local first, queue for sync
- Stream methods that watch local database
- Action methods that update local + queue sync
- Score calculation helpers for attendance and form submission

---

### Phase 3: Presentation Layer

#### 3.1 Create Providers

**File: `lib/presentation/providers/cadence_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/repositories/cadence_repository.dart';

part 'cadence_providers.g.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

@riverpod
CadenceRepository cadenceRepository(CadenceRepositoryRef ref) {
  // Wire up dependencies similar to pipelineRepositoryProvider
  throw UnimplementedError('Wire up cadence repository');
}

// ============================================
// MEETING LIST PROVIDERS
// ============================================

@riverpod
Stream<List<CadenceMeeting>> upcomingMeetings(UpcomingMeetingsRef ref) {
  return ref.watch(cadenceRepositoryProvider).watchUpcomingMeetings();
}

@riverpod
Stream<List<CadenceMeeting>> pastMeetings(PastMeetingsRef ref) {
  return ref.watch(cadenceRepositoryProvider).watchPastMeetings(limit: 20);
}

@riverpod
Stream<List<CadenceMeeting>> hostedMeetings(HostedMeetingsRef ref) {
  return ref.watch(cadenceRepositoryProvider).watchHostedMeetings();
}

// ============================================
// SINGLE MEETING PROVIDERS
// ============================================

@riverpod
Stream<CadenceMeeting?> cadenceMeeting(
  CadenceMeetingRef ref,
  String meetingId,
) {
  return ref.watch(cadenceRepositoryProvider).watchMeeting(meetingId);
}

@riverpod
Stream<List<CadenceParticipant>> meetingParticipants(
  MeetingParticipantsRef ref,
  String meetingId,
) {
  return ref.watch(cadenceRepositoryProvider).watchMeetingParticipants(meetingId);
}

@riverpod
Stream<CadenceParticipant?> myParticipation(
  MyParticipationRef ref,
  String meetingId,
) {
  return ref.watch(cadenceRepositoryProvider).watchMyParticipation(meetingId);
}

// ============================================
// ACTION NOTIFIERS
// ============================================

@riverpod
class CadenceFormNotifier extends _$CadenceFormNotifier {
  @override
  AsyncValue<CadenceParticipant?> build() => const AsyncValue.data(null);

  Future<bool> submitForm(CadenceFormSubmission submission) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(cadenceRepositoryProvider)
        .submitPreMeetingForm(submission);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (participant) {
        state = AsyncValue.data(participant);
        return true;
      },
    );
  }

  Future<bool> saveDraft(CadenceFormSubmission submission) async {
    final result = await ref
        .read(cadenceRepositoryProvider)
        .saveFormDraft(submission);

    return result.isRight();
  }
}

@riverpod
class HostMeetingNotifier extends _$HostMeetingNotifier {
  @override
  AsyncValue<CadenceMeeting?> build() => const AsyncValue.data(null);

  Future<bool> startMeeting(String meetingId) async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(cadenceRepositoryProvider)
        .startMeeting(meetingId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (meeting) {
        state = AsyncValue.data(meeting);
        return true;
      },
    );
  }

  Future<bool> endMeeting(String meetingId) async {
    final result = await ref
        .read(cadenceRepositoryProvider)
        .endMeeting(meetingId);

    return result.isRight();
  }

  Future<bool> markAttendance({
    required String participantId,
    required AttendanceStatus status,
    String? excusedReason,
  }) async {
    final result = await ref.read(cadenceRepositoryProvider).markAttendance(
      participantId: participantId,
      status: status,
      excusedReason: excusedReason,
    );

    return result.isRight();
  }

  Future<bool> saveFeedback({
    required String participantId,
    required String feedbackText,
  }) async {
    final result = await ref.read(cadenceRepositoryProvider).saveFeedback(
      participantId: participantId,
      feedbackText: feedbackText,
    );

    return result.isRight();
  }
}
```

#### 3.2 Create Screens

| Screen | Route | Description | Priority |
|--------|-------|-------------|----------|
| `CadenceScheduleScreen` | `/home/cadence` | Upcoming & past meetings for participant | P0 |
| `PreCadenceFormScreen` | `/home/cadence/:id/form` | Q1-Q4 form submission | P0 |
| `CadenceDetailScreen` | `/home/cadence/:id` | Meeting detail with feedback history | P1 |
| `HostDashboardScreen` | `/admin/cadence` | Host's meeting management | P0 |
| `HostMeetingScreen` | `/admin/cadence/:id/meeting` | During-meeting view (attendance, notes) | P0 |
| `ParticipantDetailScreen` | `/admin/cadence/:id/participant/:pid` | Per-participant detail with feedback | P1 |
| `MeetingSummaryScreen` | `/admin/cadence/:id/summary` | Post-meeting summary | P1 |

---

### Phase 4: Scoring Integration

#### 4.1 Score Impact Calculation

```dart
/// Calculate form submission score impact
int calculateFormScoreImpact({
  required DateTime deadline,
  required DateTime submittedAt,
}) {
  final diff = submittedAt.difference(deadline);

  if (diff.isNegative) {
    return 2; // On-time: +2
  } else if (diff.inHours <= 2) {
    return 0; // Late (within 2 hours): 0
  } else {
    return -1; // Very late: -1
  }
}

/// Form not submitted: -3

/// Calculate attendance score impact
int calculateAttendanceScoreImpact(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 3;  // +3
    case AttendanceStatus.late:
      return 1;  // +1
    case AttendanceStatus.excused:
      return 0;  // 0
    case AttendanceStatus.absent:
      return -5; // -5
    default:
      return 0;
  }
}
```

#### 4.2 Integration with Existing Scoring System

Update `user_scores` table after meeting completion:
- Sum all `attendance_score_impact` and `form_score_impact` per user
- Add to their periodic score

---

### Phase 5: Notification Integration

| Trigger | Timing | Message |
|---------|--------|---------|
| Form reminder | 48h before deadline | "Pre-Cadence form due in 48 hours" |
| Form reminder | 24h before deadline | "Form due tomorrow at {time}" |
| Form urgent | 2h before deadline | "Form due in 2 hours!" |
| Meeting reminder | 24h before | "Team Cadence tomorrow at {time}" |
| Meeting reminder | 1h before | "Team Cadence in 1 hour" |
| Feedback received | After host saves | "BH {name} gave you feedback" |

---

## File Creation Checklist

### Domain Layer
- [ ] `lib/domain/entities/cadence.dart`
- [ ] `lib/domain/repositories/cadence_repository.dart`

### Data Layer
- [ ] `lib/data/dtos/cadence_dtos.dart`
- [ ] `lib/data/datasources/local/cadence_local_data_source.dart`
- [ ] `lib/data/datasources/remote/cadence_remote_data_source.dart`
- [ ] `lib/data/repositories/cadence_repository_impl.dart`

### Presentation Layer
- [ ] `lib/presentation/providers/cadence_providers.dart`
- [ ] `lib/presentation/screens/cadence/cadence_schedule_screen.dart`
- [ ] `lib/presentation/screens/cadence/pre_cadence_form_screen.dart`
- [ ] `lib/presentation/screens/cadence/cadence_detail_screen.dart`
- [ ] `lib/presentation/screens/cadence/host_dashboard_screen.dart`
- [ ] `lib/presentation/screens/cadence/host_meeting_screen.dart`
- [ ] `lib/presentation/screens/cadence/participant_detail_screen.dart`
- [ ] `lib/presentation/screens/cadence/meeting_summary_screen.dart`
- [ ] `lib/presentation/widgets/cadence/` (shared widgets)

### Routes
- [ ] Update `lib/config/routes/app_router.dart` with actual screen implementations

### Services
- [ ] `lib/data/services/cadence_meeting_generator.dart` (meeting + participant creation)
- [ ] Update `SyncService` with cadence sync handlers
- [ ] Update `InitialSyncService` with cadence delta sync

### Database Migrations

> **Status:** Base tables are defined in `docs/04-database/sql/03_4dx_system_seed.sql`. Migration v3 is available for existing databases.

- [x] Base tables in `docs/04-database/sql/03_4dx_system_seed.sql` (CREATE TABLE statements)
- [x] Migration v3 in `docs/04-database/sql/migrations/20260130_cadence_schema_v3.sql` (for existing databases)
- [x] RLS policies in `docs/04-database/sql/04_rls_policies.sql`
- [ ] `supabase/migrations/YYYYMMDD_cadence_score_trigger.sql` (score calculation trigger)
- [ ] `supabase/functions/generate-cadence-meetings/` (Edge Function or pg_cron job)

#### SQL File Locations

| File | Purpose |
|------|---------|
| `docs/04-database/sql/03_4dx_system_seed.sql` | Base CREATE TABLE statements (for new databases) |
| `docs/04-database/sql/04_rls_policies.sql` | Row Level Security policies |
| `docs/04-database/sql/migrations/20260130_cadence_schema_v3.sql` | Migration for existing databases |
| `docs/04-database/tables/cadence.md` | Schema documentation |

> **New Database:** Run `03_4dx_system_seed.sql` which includes the cadence tables with all columns.
>
> **Existing Database:** Run `migrations/20260130_cadence_schema_v3.sql` which drops and recreates the tables with the new schema.

#### Schema Alignment: Drift vs Supabase

This table verifies all columns are aligned between local (Drift) and remote (Supabase) schemas.

**CadenceScheduleConfig:**
| Drift Column | Supabase Column | Notes |
|--------------|-----------------|-------|
| id (text) | id (UUID) | ✅ Compatible |
| name (text) | name (TEXT) | ✅ |
| description (text nullable) | description (TEXT) | ✅ |
| targetRole (text) | target_role (VARCHAR) | ✅ |
| facilitatorRole (text) | facilitator_role (VARCHAR) | ✅ |
| frequency (text) | frequency (VARCHAR) | ✅ |
| dayOfWeek (int nullable) | day_of_week (INTEGER) | ✅ |
| dayOfMonth (int nullable) | day_of_month (INTEGER) | ✅ |
| defaultTime (text nullable) | default_time (TEXT) | ✅ |
| durationMinutes (int) | duration_minutes (INTEGER) | ✅ |
| preMeetingHours (int) | pre_meeting_hours (INTEGER) | ✅ Form deadline hours |
| isActive (bool) | is_active (BOOLEAN) | ✅ |
| createdAt (datetime) | created_at (TIMESTAMPTZ) | ✅ |
| updatedAt (datetime) | updated_at (TIMESTAMPTZ) | ✅ |

**CadenceMeetings:**
| Drift Column | Supabase Column | Notes |
|--------------|-----------------|-------|
| id (text) | id (UUID) | ✅ |
| configId (text FK) | config_id (UUID FK) | ✅ |
| title (text) | title (TEXT) | ✅ |
| scheduledAt (datetime) | scheduled_at (TIMESTAMPTZ) | ✅ |
| durationMinutes (int) | duration_minutes (INTEGER) | ✅ |
| facilitatorId (text FK) | facilitator_id (UUID FK) | ✅ |
| status (text) | status (VARCHAR) | ✅ |
| location (text nullable) | location (TEXT) | ✅ |
| meetingLink (text nullable) | meeting_link (TEXT) | ✅ |
| agenda (text nullable) | agenda (TEXT) | ✅ |
| notes (text nullable) | notes (TEXT) | ✅ |
| startedAt (datetime nullable) | started_at (TIMESTAMPTZ) | ✅ |
| completedAt (datetime nullable) | completed_at (TIMESTAMPTZ) | ✅ |
| createdBy (text FK) | created_by (UUID FK) | ✅ |
| isPendingSync (bool) | is_pending_sync (BOOLEAN) | ✅ |
| createdAt (datetime) | created_at (TIMESTAMPTZ) | ✅ |
| updatedAt (datetime) | updated_at (TIMESTAMPTZ) | ✅ |

**CadenceParticipants (26 columns):**
| Drift Column | Supabase Column | Notes |
|--------------|-----------------|-------|
| id (text) | id (UUID) | ✅ |
| meetingId (text FK) | meeting_id (UUID FK) | ✅ |
| userId (text FK) | user_id (UUID FK) | ✅ |
| attendanceStatus (text) | attendance_status (VARCHAR) | ✅ |
| arrivedAt (datetime nullable) | arrived_at (TIMESTAMPTZ) | ✅ |
| excusedReason (text nullable) | excused_reason (TEXT) | ✅ |
| attendanceScoreImpact (int nullable) | attendance_score_impact (INTEGER) | ✅ |
| markedBy (text nullable) | marked_by (UUID FK) | ✅ |
| markedAt (datetime nullable) | marked_at (TIMESTAMPTZ) | ✅ |
| preMeetingSubmitted (bool) | pre_meeting_submitted (BOOLEAN) | ✅ |
| q1PreviousCommitment (text nullable) | q1_previous_commitment (TEXT) | ✅ |
| q1CompletionStatus (text nullable) | q1_completion_status (VARCHAR) | ✅ |
| q2WhatAchieved (text nullable) | q2_what_achieved (TEXT) | ✅ |
| q3Obstacles (text nullable) | q3_obstacles (TEXT) | ✅ |
| q4NextCommitment (text nullable) | q4_next_commitment (TEXT) | ✅ |
| formSubmittedAt (datetime nullable) | form_submitted_at (TIMESTAMPTZ) | ✅ |
| formSubmissionStatus (text nullable) | form_submission_status (VARCHAR) | ✅ |
| formScoreImpact (int nullable) | form_score_impact (INTEGER) | ✅ |
| hostNotes (text nullable) | host_notes (TEXT) | ✅ |
| feedbackText (text nullable) | feedback_text (TEXT) | ✅ |
| feedbackGivenAt (datetime nullable) | feedback_given_at (TIMESTAMPTZ) | ✅ |
| feedbackUpdatedAt (datetime nullable) | feedback_updated_at (TIMESTAMPTZ) | ✅ |
| isPendingSync (bool) | is_pending_sync (BOOLEAN) | ✅ |
| lastSyncAt (datetime nullable) | last_sync_at (TIMESTAMPTZ) | ✅ |
| createdAt (datetime) | created_at (TIMESTAMPTZ) | ✅ |
| updatedAt (datetime) | updated_at (TIMESTAMPTZ) | ✅ |

> **All 57 fields verified aligned between Drift and Supabase (14 + 17 + 26).**

---

## Offline/Online Sync Integration

### Sync Architecture Overview

The app uses a **bidirectional offline-first sync** pattern:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYNC ARCHITECTURE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  LOCAL (Drift/SQLite)                        REMOTE (Supabase/PostgreSQL)  │
│  ┌─────────────────────┐                     ┌─────────────────────┐       │
│  │ cadence_meetings    │ ───── OUTBOUND ────▶│ cadence_meetings    │       │
│  │ cadence_participants│      (SyncService)  │ cadence_participants│       │
│  │ cadence_schedule_cfg│                     │ cadence_schedule_cfg│       │
│  └─────────────────────┘                     └─────────────────────┘       │
│           │                                           │                     │
│           │                                           │                     │
│  ┌─────────────────────┐                              │                     │
│  │     sync_queue      │◀─── queue operation         │                     │
│  │  (pending changes)  │                              │                     │
│  └─────────────────────┘                              │                     │
│                                                       │                     │
│  ┌─────────────────────┐      INBOUND                │                     │
│  │   Local Tables      │◀────(InitialSyncService)────┘                     │
│  │                     │     Delta sync: fetch                              │
│  │ isPendingSync=false │     WHERE updated_at > lastSyncAt                 │
│  │ lastSyncAt=now      │                                                    │
│  └─────────────────────┘                                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1. Outbound Sync (Local → Server)

**How it works:**
1. User performs action (submit form, mark attendance)
2. Repository writes to local DB with `isPendingSync = true`
3. Repository calls `SyncService.queueOperation()` with JSON payload
4. When online, `SyncService.processQueue()` sends to Supabase
5. On success, marks local record `isPendingSync = false`, `lastSyncAt = now`

**Required SyncService Updates:**

**File: `lib/data/services/sync_service.dart`**

Add to `_getTableName()`:
```dart
case 'cadenceMeeting':
  return 'cadence_meetings';
case 'cadenceParticipant':
  return 'cadence_participants';
case 'cadenceScheduleConfig':
  return 'cadence_schedule_config';
```

Add to `_markEntityAsSynced()`:
```dart
case 'cadenceMeeting':
  await (_database.update(_database.cadenceMeetings)
        ..where((m) => m.id.equals(entityId)))
      .write(db.CadenceMeetingsCompanion(
        isPendingSync: const Value(false),
        updatedAt: Value(syncedAt),
      ));
case 'cadenceParticipant':
  await (_database.update(_database.cadenceParticipants)
        ..where((p) => p.id.equals(entityId)))
      .write(db.CadenceParticipantsCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ));
```

Add `SyncEntityType` enum values:
```dart
enum SyncEntityType {
  // ... existing
  cadenceMeeting,
  cadenceParticipant,
}
```

### 2. Inbound Sync (Server → Local) - Delta Sync

**How it works:**
1. App stores `lastSyncAt` timestamp per table in `AppSettings`
2. `InitialSyncService.performDeltaSync()` fetches:
   - Records where `updated_at > lastSyncAt`
   - Records where `deleted_at > lastSyncAt` (for soft deletes)
3. Upserts active records, deletes removed records locally
4. Updates `lastSyncAt` for next delta

**Required InitialSyncService Updates:**

**File: `lib/data/services/initial_sync_service.dart`**

Add to `_deltaSyncTables`:
```dart
static const List<String> _deltaSyncTables = [
  'hvcs',
  'brokers',
  'customer_hvc_links',
  'pipeline_referrals',
  'cadence_meetings',      // ADD
  'cadence_participants',  // ADD
];
```

Add `_syncCadenceMeetings()`:
```dart
Future<void> _syncCadenceMeetings({DateTime? since}) async {
  var query = _supabase.from('cadence_meetings').select();

  if (since != null) {
    // Delta sync: fetch updated since last sync
    query = query.gte('updated_at', since.toIso8601String());
  }

  final data = await query;

  await _db.batch((batch) {
    for (final row in data as List) {
      batch.insert(
        _db.cadenceMeetings,
        CadenceMeetingsCompanion.insert(
          id: row['id'] as String,
          configId: row['config_id'] as String,
          title: row['title'] as String,
          scheduledAt: DateTime.parse(row['scheduled_at'] as String),
          durationMinutes: row['duration_minutes'] as int,
          facilitatorId: row['facilitator_id'] as String,
          status: Value(row['status'] as String),
          location: Value(row['location'] as String?),
          meetingLink: Value(row['meeting_link'] as String?),
          agenda: Value(row['agenda'] as String?),
          notes: Value(row['notes'] as String?),
          startedAt: Value(row['started_at'] != null
              ? DateTime.parse(row['started_at'] as String)
              : null),
          completedAt: Value(row['completed_at'] != null
              ? DateTime.parse(row['completed_at'] as String)
              : null),
          createdBy: row['created_by'] as String,
          isPendingSync: const Value(false),
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
        ),
        mode: InsertMode.insertOrReplace,
      );
    }
  });
}
```

Add `_syncCadenceParticipants()`:
```dart
Future<void> _syncCadenceParticipants({DateTime? since}) async {
  var query = _supabase.from('cadence_participants').select();

  if (since != null) {
    query = query.gte('updated_at', since.toIso8601String());
  }

  final data = await query;

  await _db.batch((batch) {
    for (final row in data as List) {
      batch.insert(
        _db.cadenceParticipants,
        CadenceParticipantsCompanion.insert(
          id: row['id'] as String,
          meetingId: row['meeting_id'] as String,
          userId: row['user_id'] as String,
          // Attendance
          attendanceStatus: Value(row['attendance_status'] as String?),
          arrivedAt: Value(row['arrived_at'] != null
              ? DateTime.parse(row['arrived_at'] as String)
              : null),
          excusedReason: Value(row['excused_reason'] as String?),
          attendanceScoreImpact: Value(row['attendance_score_impact'] as int?),
          markedBy: Value(row['marked_by'] as String?),
          markedAt: Value(row['marked_at'] != null
              ? DateTime.parse(row['marked_at'] as String)
              : null),
          // Form
          preMeetingSubmitted: Value(row['pre_meeting_submitted'] as bool? ?? false),
          q1PreviousCommitment: Value(row['q1_previous_commitment'] as String?),
          q1CompletionStatus: Value(row['q1_completion_status'] as String?),
          q2WhatAchieved: Value(row['q2_what_achieved'] as String?),
          q3Obstacles: Value(row['q3_obstacles'] as String?),
          q4NextCommitment: Value(row['q4_next_commitment'] as String?),
          formSubmittedAt: Value(row['form_submitted_at'] != null
              ? DateTime.parse(row['form_submitted_at'] as String)
              : null),
          formSubmissionStatus: Value(row['form_submission_status'] as String?),
          formScoreImpact: Value(row['form_score_impact'] as int?),
          // Feedback
          hostNotes: Value(row['host_notes'] as String?),
          feedbackText: Value(row['feedback_text'] as String?),
          feedbackGivenAt: Value(row['feedback_given_at'] != null
              ? DateTime.parse(row['feedback_given_at'] as String)
              : null),
          feedbackUpdatedAt: Value(row['feedback_updated_at'] != null
              ? DateTime.parse(row['feedback_updated_at'] as String)
              : null),
          // Sync
          isPendingSync: const Value(false),
          lastSyncAt: Value(DateTime.now()),
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
        ),
        mode: InsertMode.insertOrReplace,
      );
    }
  });
}
```

Add to `_syncTableDelta()`:
```dart
case 'cadence_meetings':
  await _syncCadenceMeetings(since: since);
  break;
case 'cadence_participants':
  await _syncCadenceParticipants(since: since);
  break;
```

### 3. Conflict Resolution Strategy

| Scenario | Resolution |
|----------|------------|
| **Form submission** | Last-write-wins with timestamp. Host cannot overwrite participant form. |
| **Attendance marking** | Host's local change wins (host is authority). Server timestamp used for scoring. |
| **Feedback** | Host-only operation; no conflict possible. |
| **Meeting start/end** | Host-only operation; last-write-wins. |

### 4. Offline Behavior by Action

| Action | Offline Behavior | Sync Priority |
|--------|------------------|---------------|
| **Submit form** | ✅ Works offline. Queued. Score calculated on sync based on server timestamp vs deadline. | HIGH |
| **View meetings** | ✅ Shows local data. May be stale. | N/A |
| **Host: Mark attendance** | ✅ Works offline. Queued. | HIGH |
| **Host: Save notes/feedback** | ✅ Works offline. Queued. | MEDIUM |
| **Host: Start/End meeting** | ✅ Works offline. Timestamp recorded locally, synced later. | HIGH |

### 5. Score Calculation Timing

**Important:** Form submission scoring depends on server-side deadline comparison.

**Option A (Recommended): Calculate on sync**
```dart
// In repository, when syncing form submission:
Future<void> _syncFormSubmission(CadenceParticipant participant) async {
  // Get meeting and config for deadline calculation
  final meeting = await _remoteDataSource.getMeeting(participant.meetingId);
  final config = await _remoteDataSource.getConfig(meeting.configId);

  // Calculate form deadline from config.preMeetingHours
  final deadline = meeting.scheduledAt.subtract(
    Duration(hours: config.preMeetingHours), // Default 24 hours
  );

  // Calculate score based on server time
  final submittedAt = participant.formSubmittedAt!;
  final score = calculateFormScoreImpact(deadline: deadline, submittedAt: submittedAt);

  // Update with calculated score
  await _remoteDataSource.submitPreMeetingForm(
    participant.id,
    form,
    _getSubmissionStatus(deadline, submittedAt),
    score,
  );
}
```

**Option B: Server-side trigger (PostgreSQL)**
```sql
CREATE OR REPLACE FUNCTION calculate_form_score()
RETURNS TRIGGER AS $$
DECLARE
  meeting_scheduled_at TIMESTAMPTZ;
  form_deadline TIMESTAMPTZ;
  hours_diff NUMERIC;
BEGIN
  -- Get meeting scheduled time
  SELECT scheduled_at INTO meeting_scheduled_at
  FROM cadence_meetings WHERE id = NEW.meeting_id;

  -- Calculate deadline (24 hours before meeting)
  form_deadline := meeting_scheduled_at - INTERVAL '24 hours';

  -- Calculate score
  IF NEW.form_submitted_at <= form_deadline THEN
    NEW.form_submission_status := 'ON_TIME';
    NEW.form_score_impact := 2;
  ELSIF NEW.form_submitted_at <= form_deadline + INTERVAL '2 hours' THEN
    NEW.form_submission_status := 'LATE';
    NEW.form_score_impact := 0;
  ELSE
    NEW.form_submission_status := 'VERY_LATE';
    NEW.form_score_impact := -1;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_form_score
BEFORE INSERT OR UPDATE OF form_submitted_at ON cadence_participants
FOR EACH ROW
WHEN (NEW.form_submitted_at IS NOT NULL)
EXECUTE FUNCTION calculate_form_score();
```

### 6. Repository Pattern for Offline-First

```dart
/// Example: Submit pre-meeting form (offline-first)
Future<Either<Failure, CadenceParticipant>> submitPreMeetingForm(
  CadenceFormSubmission submission,
) async {
  try {
    final now = DateTime.now();
    final participantId = submission.participantId;

    // 1. Get current participant record
    final existing = await _localDataSource.getParticipant(participantId);
    if (existing == null) {
      return Left(NotFoundFailure('Participant not found'));
    }

    // 2. Update local database FIRST
    await _localDataSource.updateParticipant(
      participantId,
      CadenceParticipantsCompanion(
        preMeetingSubmitted: const Value(true),
        q1CompletionStatus: Value(submission.q1CompletionStatus?.name),
        q2WhatAchieved: Value(submission.q2WhatAchieved),
        q3Obstacles: Value(submission.q3Obstacles),
        q4NextCommitment: Value(submission.q4NextCommitment),
        formSubmittedAt: Value(now),
        // Note: formSubmissionStatus and formScoreImpact calculated on sync
        isPendingSync: const Value(true),
        updatedAt: Value(now),
      ),
    );

    // 3. Queue for sync
    await _syncService.queueOperation(
      entityType: SyncEntityType.cadenceParticipant,
      entityId: participantId,
      operation: SyncOperation.update,
      payload: {
        'id': participantId,
        'pre_meeting_submitted': true,
        'q1_completion_status': submission.q1CompletionStatus?.name,
        'q2_what_achieved': submission.q2WhatAchieved,
        'q3_obstacles': submission.q3Obstacles,
        'q4_next_commitment': submission.q4NextCommitment,
        'form_submitted_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    // 4. Trigger sync if online
    if (_connectivityService.isConnected) {
      unawaited(_syncService.triggerSync());
    }

    // 5. Return updated participant
    final updated = await _localDataSource.getParticipant(participantId);
    return Right(_mapToParticipant(updated!));
  } catch (e) {
    return Left(DatabaseFailure(e.toString()));
  }
}
```

---

## Additional Considerations

### 1. Notification Integration

The app has existing notification infrastructure (`lib/data/database/tables/notifications.dart`) with `cadenceReminders` setting. Cadence needs to integrate with this.

**Notification Triggers:**

| Trigger | Timing | Type | Message |
|---------|--------|------|---------|
| Form reminder | 48h before deadline | Local + Push | "Pre-Cadence form due in 48 hours" |
| Form reminder | 24h before deadline | Local + Push | "Form due tomorrow at {time}" |
| Form urgent | 2h before deadline | Local + Push | "⚠️ Form due in 2 hours!" |
| Meeting reminder | 24h before | Local + Push | "Team Cadence tomorrow at {time}" |
| Meeting reminder | 1h before | Local + Push | "Team Cadence in 1 hour" |
| Feedback received | On save | Push | "BH {name} gave you feedback" |
| Commitment follow-up | Mid-week (Wed) | Local | "How's progress on your commitment?" |

**Implementation:**

```dart
/// Service to schedule cadence notifications
class CadenceNotificationService {
  /// Schedule notifications when a meeting is created/synced
  Future<void> scheduleNotificationsForMeeting(CadenceMeeting meeting) async {
    // Get config for form deadline hours
    final config = await _getConfigForMeeting(meeting.configId);
    final formDeadline = meeting.scheduledAt.subtract(
      Duration(hours: config.preMeetingHours),
    );

    // Form reminders (for participants)
    await _scheduleNotification(
      id: '${meeting.id}_form_48h',
      title: 'Pre-Cadence Form Reminder',
      body: 'Your form for ${meeting.title} is due in 48 hours',
      scheduledAt: formDeadline.subtract(Duration(hours: 48)),
      type: NotificationType.cadence,
      data: {'meetingId': meeting.id, 'action': 'OPEN_FORM'},
    );

    // Meeting reminders
    await _scheduleNotification(
      id: '${meeting.id}_meeting_24h',
      title: 'Upcoming Cadence Meeting',
      body: '${meeting.title} is tomorrow at ${_formatTime(meeting.scheduledAt)}',
      scheduledAt: meeting.scheduledAt.subtract(Duration(hours: 24)),
      type: NotificationType.cadence,
      data: {'meetingId': meeting.id, 'action': 'VIEW_MEETING'},
    );
  }

  /// Cancel notifications if meeting is cancelled
  Future<void> cancelNotificationsForMeeting(String meetingId) async {
    await _cancelNotification('${meetingId}_form_48h');
    await _cancelNotification('${meetingId}_form_24h');
    await _cancelNotification('${meetingId}_form_2h');
    await _cancelNotification('${meetingId}_meeting_24h');
    await _cancelNotification('${meetingId}_meeting_1h');
  }
}
```

**Files to create:**
- [ ] `lib/data/services/cadence_notification_service.dart`

### 2. Scoring Integration with 4DX System

Cadence scores need to feed into the existing `user_scores` table for the scoreboard.

**Score Aggregation:**

```sql
-- Trigger to update user_scores when cadence_participants is updated
CREATE OR REPLACE FUNCTION update_cadence_score()
RETURNS TRIGGER AS $$
DECLARE
  period_id UUID;
  measure_id UUID;
  total_score INTEGER;
BEGIN
  -- Get current scoring period
  SELECT id INTO period_id FROM scoring_periods WHERE is_current = true LIMIT 1;

  -- Get cadence measure definition (should exist in measure_definitions)
  SELECT id INTO measure_id FROM measure_definitions WHERE code = 'CADENCE_SCORE';

  -- Calculate total cadence score for this user in this period
  SELECT COALESCE(SUM(attendance_score_impact), 0) + COALESCE(SUM(form_score_impact), 0)
  INTO total_score
  FROM cadence_participants cp
  JOIN cadence_meetings cm ON cm.id = cp.meeting_id
  JOIN scoring_periods sp ON sp.id = period_id
  WHERE cp.user_id = NEW.user_id
    AND cm.scheduled_at >= sp.start_date
    AND cm.scheduled_at <= sp.end_date;

  -- Upsert into user_scores
  INSERT INTO user_scores (id, user_id, measure_id, period_id, actual_value, target_value, calculated_at, created_at, updated_at)
  VALUES (
    uuid_generate_v4(),
    NEW.user_id,
    measure_id,
    period_id,
    total_score,
    8, -- Max possible per week (form +2 + attendance +3 + commitment +3)
    NOW(),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id, measure_id, period_id)
  DO UPDATE SET
    actual_value = EXCLUDED.actual_value,
    calculated_at = NOW(),
    updated_at = NOW();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_cadence_score
AFTER INSERT OR UPDATE OF attendance_score_impact, form_score_impact ON cadence_participants
FOR EACH ROW
EXECUTE FUNCTION update_cadence_score();
```

**Measure Definition Seed:**

```sql
INSERT INTO measure_definitions (id, code, name, description, measure_type, data_type, unit, is_active, sort_order, created_at, updated_at)
VALUES (
  'measure-cadence',
  'CADENCE_SCORE',
  'Cadence Participation',
  'Score from form submission and attendance in cadence meetings',
  'LEAD',
  'SUM',
  'points',
  true,
  10,
  NOW(),
  NOW()
);
```

### 3. Commitment Tracking Score (Missing from original doc)

The documentation mentions commitment completion scoring (+3/+1/0/-2) but it's tracked in the NEXT meeting when Q1 completion status is set.

**Logic:**
1. When participant submits form with `q1_completion_status`:
   - `COMPLETED` → +3 points
   - `PARTIAL` → +1 point
   - `NOT_DONE` → 0 points
   - No status set (didn't make commitment) → -2 points

```dart
int calculateCommitmentScoreImpact(CommitmentCompletionStatus? status, bool hadPreviousCommitment) {
  if (!hadPreviousCommitment) return 0; // No commitment to track

  switch (status) {
    case CommitmentCompletionStatus.completed:
      return 3;
    case CommitmentCompletionStatus.partial:
      return 1;
    case CommitmentCompletionStatus.notDone:
      return 0;
    case null:
      return -2; // Had commitment but didn't report
  }
}
```

**Add to `cadence_participants` table:**
```sql
ALTER TABLE cadence_participants
ADD COLUMN IF NOT EXISTS commitment_score_impact INTEGER;

COMMENT ON COLUMN cadence_participants.commitment_score_impact IS '+3 completed, +1 partial, 0 not done, -2 no commitment made';
```

### 3a. Referral Bonus Score (Pipeline Referral Feature)

When a referred pipeline reaches WON status (stage = ACCEPTED), the referrer RM should receive a bonus score.

**Infrastructure Status (Already Implemented):**
- `referred_by_user_id` is set on pipelines when referral is approved
- `bonus_calculated` and `bonus_amount` columns exist on `pipeline_referrals`
- Database trigger sets referrer tracking on approval

**TODO - Scoring Logic:**

1. Create trigger or scheduled job to detect WON pipelines with `referred_by_user_id`
2. Calculate bonus: `final_premium × referral_bonus_percentage` (default 5%)
3. Update referrer's score in `user_scores` table with REFERRAL_BONUS measure
4. Mark `bonus_calculated = true` on the referral record

**Measure Definition Seed:**

```sql
INSERT INTO measure_definitions (id, code, name, description, measure_type, data_type, unit, is_active, sort_order, created_at, updated_at)
VALUES (
  'measure-referral-bonus',
  'REFERRAL_BONUS',
  'Referral Bonus',
  'Bonus points from referred pipelines that are won',
  'LEAD',
  'SUM',
  'points',
  true,
  11,
  NOW(),
  NOW()
);
```

**Trigger Logic:**

```sql
-- Trigger when pipeline closes as WON and has a referrer
CREATE OR REPLACE FUNCTION calculate_referral_bonus()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process if pipeline just closed as WON and has a referrer
  IF NEW.closed_at IS NOT NULL
     AND NEW.referred_by_user_id IS NOT NULL
     AND OLD.closed_at IS NULL THEN

    -- Update pipeline_referrals bonus fields
    UPDATE pipeline_referrals
    SET
      bonus_calculated = true,
      bonus_amount = NEW.final_premium * 0.05, -- 5% default
      updated_at = NOW()
    WHERE id = NEW.referral_id
      AND bonus_calculated = false;

    -- TODO: Insert/update user_scores for referrer
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Files to create:**
- [ ] `supabase/migrations/YYYYMMDD_referral_bonus_trigger.sql`

### 4. RLS Policies for Supabase

> **Status:** RLS policies are already defined in `docs/04-database/sql/04_rls_policies.sql`

**Key policies:**
- `cadence_config_select` - All authenticated users can read configs
- `cadence_config_admin` - Admins can modify configs
- `cadence_meetings_select` - Facilitators and participants can read their meetings
- `cadence_meetings_create` - BH+ roles can create meetings
- `cadence_participants_own` - Users can manage their own participation
- `cadence_participants_host` - Facilitators can manage participants in their meetings

### 5. Edge Cases

| Edge Case | Handling |
|-----------|----------|
| **Participant transferred mid-cycle** | Keep existing participant record; don't auto-add to new team until next meeting generation |
| **Host changed/reassigned** | Update `facilitator_id` on existing scheduled meetings; participants remain |
| **New team member joins** | Auto-add to next generated meeting (not retroactively) |
| **Meeting cancelled after forms submitted** | Mark meeting as `CANCELLED`; no score impact; notify participants |
| **Participant submits form after meeting started** | Mark as `VERY_LATE` (-1 point); still allow submission |
| **Host forgets to end meeting** | Auto-end after 4 hours past scheduled time (server job) |

### 6. Form Validation Rules

| Field | Required | Max Length | Validation |
|-------|----------|------------|------------|
| Q1 (completion status) | Yes (if had commitment) | N/A | Enum only |
| Q2 (what achieved) | Yes | 500 chars | Non-empty |
| Q3 (obstacles) | No | 500 chars | N/A |
| Q4 (next commitment) | Yes | 500 chars | Non-empty, specific/measurable guideline |

```dart
class CadenceFormValidator {
  static List<String> validate(CadenceFormSubmission form, bool hadPreviousCommitment) {
    final errors = <String>[];

    if (hadPreviousCommitment && form.q1CompletionStatus == null) {
      errors.add('Please indicate completion status of your previous commitment');
    }

    if (form.q2WhatAchieved.isEmpty) {
      errors.add('Q2: What you achieved is required');
    } else if (form.q2WhatAchieved.length > 500) {
      errors.add('Q2: Maximum 500 characters');
    }

    if (form.q3Obstacles != null && form.q3Obstacles!.length > 500) {
      errors.add('Q3: Maximum 500 characters');
    }

    if (form.q4NextCommitment.isEmpty) {
      errors.add('Q4: Next commitment is required');
    } else if (form.q4NextCommitment.length > 500) {
      errors.add('Q4: Maximum 500 characters');
    }

    return errors;
  }
}
```

### 7. Admin Panel Features

| Feature | Screen | Priority |
|---------|--------|----------|
| View all cadence configs | Admin Cadence Settings | P1 |
| Edit schedule config (day, time, duration) | Admin Cadence Settings | P1 |
| View cadence calendar (all teams) | Admin Cadence Overview | P2 |
| Reports: Attendance rate by branch | Admin Reports | P2 |
| Reports: Form submission rate | Admin Reports | P2 |
| Override: Cancel meeting | Admin Meeting Detail | P2 |
| Override: Add/remove participants | Admin Meeting Detail | P2 |

### 8. Realtime Updates (Optional Enhancement)

For live updates during meetings (attendance, feedback), consider Supabase Realtime:

```dart
/// Subscribe to meeting participants for live updates during meeting
void subscribeToMeetingParticipants(String meetingId) {
  _supabase
    .from('cadence_participants')
    .stream(primaryKey: ['id'])
    .eq('meeting_id', meetingId)
    .listen((data) {
      // Update local state
      _updateParticipantsFromRealtime(data);
    });
}
```

**Note:** This is optional; delta sync is sufficient for most use cases.

---

## Updated File Creation Checklist

### Database (Completed)
- [x] `lib/data/database/tables/cadence.dart` - Drift tables with `preMeetingHours`
- [x] `docs/04-database/sql/03_4dx_system_seed.sql` - Supabase CREATE TABLE
- [x] `docs/04-database/sql/04_rls_policies.sql` - RLS policies with `facilitator_id`
- [x] `docs/04-database/sql/migrations/20260130_cadence_schema_v3.sql` - Migration for existing DBs
- [x] `docs/04-database/tables/cadence.md` - Schema documentation

### Additional Files (Not Started)
- [ ] `lib/data/services/cadence_notification_service.dart`
- [ ] `supabase/migrations/YYYYMMDD_cadence_measure_definition_seed.sql`
- [ ] `supabase/migrations/YYYYMMDD_cadence_commitment_score_column.sql`
- [ ] `lib/presentation/widgets/cadence/form_validator.dart`

---

## Testing Strategy

1. **Unit Tests**
   - Repository methods
   - Score calculation helpers (form, attendance, commitment)
   - DTO mapping
   - Form validation

2. **Integration Tests**
   - Form submission flow (online + offline)
   - Attendance marking flow
   - Offline-first sync behavior
   - Meeting generation with participants
   - Q1 auto-population

3. **Widget Tests**
   - Form validation UI
   - Attendance checkboxes
   - Feedback display
   - Status badges

4. **E2E Tests**
   - Full participant flow: view meeting → fill form → attend → view feedback
   - Full host flow: view dashboard → start meeting → mark attendance → give feedback → end meeting

---

## Implementation Order

1. **Week 1**: Domain entities + DTOs + Repository interface
2. **Week 2**: Local data source + Repository implementation
3. **Week 3**: Providers + Participant screens (Schedule, Form, Detail)
4. **Week 4**: Host screens (Dashboard, Meeting, Summary)
5. **Week 5**: Scoring integration + Notifications + Testing

---

*Implementation Plan v2.0 - Updated January 2026*

**Changelog v2.0:**
- Added `preMeetingHours` to Drift schema and SQL
- Aligned SQL schema in `03_4dx_system_seed.sql` with Drift
- Fixed RLS policies to use `facilitator_id` instead of `host_id`
- Created migration v3 for existing databases
- Updated all documentation and schema alignment tables
