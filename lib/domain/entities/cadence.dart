import 'package:freezed_annotation/freezed_annotation.dart';

part 'cadence.freezed.dart';
part 'cadence.g.dart';

// ============================================
// ENUMS
// ============================================

/// Meeting frequency for cadence schedules.
enum MeetingFrequency {
  @JsonValue('DAILY')
  daily,
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('QUARTERLY')
  quarterly,
}

/// Meeting status indicating current state.
enum MeetingStatus {
  @JsonValue('SCHEDULED')
  scheduled,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

/// Attendance status for cadence participants.
enum AttendanceStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PRESENT')
  present,
  @JsonValue('LATE')
  late,
  @JsonValue('EXCUSED')
  excused,
  @JsonValue('ABSENT')
  absent,
}

/// Form submission timing status.
enum FormSubmissionStatus {
  @JsonValue('ON_TIME')
  onTime,
  @JsonValue('LATE')
  late,
  @JsonValue('VERY_LATE')
  veryLate,
  @JsonValue('NOT_SUBMITTED')
  notSubmitted,
}

/// Status of previous commitment (Q1).
enum CommitmentCompletionStatus {
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('PARTIAL')
  partial,
  @JsonValue('NOT_DONE')
  notDone,
}

// ============================================
// SCHEDULE CONFIG ENTITY
// ============================================

/// Cadence schedule configuration defining meeting parameters per level.
@freezed
class CadenceScheduleConfig with _$CadenceScheduleConfig {
  const factory CadenceScheduleConfig({
    required String id,
    required String name,
    required String targetRole, // RM, BH, BM, ROH
    required String facilitatorRole, // BH, BM, ROH, DIRECTOR
    required MeetingFrequency frequency,
    int? dayOfWeek, // 0=Sunday, 6=Saturday (for weekly)
    int? dayOfMonth, // 1-31 (for monthly)
    String? defaultTime, // HH:mm format
    @Default(60) int durationMinutes,
    @Default(24) int preMeetingHours, // Hours before meeting for form deadline
    @Default(true) bool isActive,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CadenceScheduleConfig;

  const CadenceScheduleConfig._();

  factory CadenceScheduleConfig.fromJson(Map<String, dynamic> json) =>
      _$CadenceScheduleConfigFromJson(json);

  /// Get display name for frequency.
  String get frequencyText {
    switch (frequency) {
      case MeetingFrequency.daily:
        return 'Daily';
      case MeetingFrequency.weekly:
        return 'Weekly';
      case MeetingFrequency.monthly:
        return 'Monthly';
      case MeetingFrequency.quarterly:
        return 'Quarterly';
    }
  }

  /// Get day of week name (if weekly).
  String? get dayOfWeekName {
    if (dayOfWeek == null) return null;
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[dayOfWeek!];
  }
}

// ============================================
// MEETING ENTITY
// ============================================

/// Cadence meeting instance.
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
    // Config reference (for deadline calculation)
    int? preMeetingHours,
  }) = _CadenceMeeting;

  const CadenceMeeting._();

  factory CadenceMeeting.fromJson(Map<String, dynamic> json) =>
      _$CadenceMeetingFromJson(json);

  /// Calculate form submission deadline.
  DateTime get formDeadline => scheduledAt.subtract(
        Duration(hours: preMeetingHours ?? 24),
      );

  /// Calculate form submission deadline with explicit hours.
  DateTime formDeadlineWithHours(int hours) =>
      scheduledAt.subtract(Duration(hours: hours));

  /// Check if meeting is upcoming.
  bool get isUpcoming =>
      status == MeetingStatus.scheduled && scheduledAt.isAfter(DateTime.now());

  /// Check if meeting is in progress.
  bool get isInProgress => status == MeetingStatus.inProgress;

  /// Check if meeting is completed.
  bool get isCompleted => status == MeetingStatus.completed;

  /// Check if meeting is cancelled.
  bool get isCancelled => status == MeetingStatus.cancelled;

  /// Check if form deadline has passed.
  bool get isFormDeadlinePassed => DateTime.now().isAfter(formDeadline);

  /// Get form submission progress text.
  String get formProgressText =>
      '${submittedFormCount ?? 0}/${totalParticipants ?? 0} submitted';

  /// Get attendance progress text.
  String get attendanceProgressText =>
      '${presentCount ?? 0}/${totalParticipants ?? 0} present';

  /// Get status display text.
  String get statusText {
    switch (status) {
      case MeetingStatus.scheduled:
        return 'Scheduled';
      case MeetingStatus.inProgress:
        return 'In Progress';
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get status color for UI.
  String get statusColor {
    switch (status) {
      case MeetingStatus.scheduled:
        return '#2196F3'; // Blue
      case MeetingStatus.inProgress:
        return '#FF9800'; // Orange
      case MeetingStatus.completed:
        return '#4CAF50'; // Green
      case MeetingStatus.cancelled:
        return '#9E9E9E'; // Grey
    }
  }
}

// ============================================
// PARTICIPANT ENTITY (Combined: Attendance + Form + Feedback)
// ============================================

/// Cadence meeting participant with attendance, form, and feedback data.
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
    String? q1PreviousCommitment, // Auto-filled from last meeting's Q4
    CommitmentCompletionStatus? q1CompletionStatus,
    String? q2WhatAchieved, // Required
    String? q3Obstacles, // Optional
    String? q4NextCommitment, // Required
    DateTime? formSubmittedAt,
    FormSubmissionStatus? formSubmissionStatus,
    int? formScoreImpact,

    // Host notes & feedback
    String? hostNotes, // Internal notes (not visible to participant)
    String? feedbackText, // Formal feedback visible to participant
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

  /// Total score impact (attendance + form).
  int get totalScoreImpact =>
      (attendanceScoreImpact ?? 0) + (formScoreImpact ?? 0);

  /// Check if feedback has been given.
  bool get hasFeedback => feedbackText != null && feedbackText!.isNotEmpty;

  /// Check if form is complete (Q2 and Q4 required).
  bool get isFormComplete =>
      q2WhatAchieved != null &&
      q2WhatAchieved!.isNotEmpty &&
      q4NextCommitment != null &&
      q4NextCommitment!.isNotEmpty;

  /// Check if attendance has been marked.
  bool get isAttendanceMarked => attendanceStatus != AttendanceStatus.pending;

  /// Get attendance status display text.
  String get attendanceStatusText {
    switch (attendanceStatus) {
      case AttendanceStatus.pending:
        return 'Pending';
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }

  /// Get attendance status color.
  String get attendanceStatusColor {
    switch (attendanceStatus) {
      case AttendanceStatus.pending:
        return '#9E9E9E'; // Grey
      case AttendanceStatus.present:
        return '#4CAF50'; // Green
      case AttendanceStatus.late:
        return '#FF9800'; // Orange
      case AttendanceStatus.excused:
        return '#2196F3'; // Blue
      case AttendanceStatus.absent:
        return '#F44336'; // Red
    }
  }

  /// Get form submission status text.
  String get formStatusText {
    if (!preMeetingSubmitted) return 'Not Submitted';
    switch (formSubmissionStatus) {
      case FormSubmissionStatus.onTime:
        return 'On Time';
      case FormSubmissionStatus.late:
        return 'Late';
      case FormSubmissionStatus.veryLate:
        return 'Very Late';
      case FormSubmissionStatus.notSubmitted:
        return 'Not Submitted';
      case null:
        return 'Submitted';
    }
  }

  /// Get Q1 completion status text.
  String? get q1CompletionStatusText {
    switch (q1CompletionStatus) {
      case CommitmentCompletionStatus.completed:
        return 'Completed';
      case CommitmentCompletionStatus.partial:
        return 'Partial';
      case CommitmentCompletionStatus.notDone:
        return 'Not Done';
      case null:
        return null;
    }
  }
}

// ============================================
// FORM SUBMISSION DTO (For creating/updating forms)
// ============================================

/// Data transfer object for submitting pre-meeting forms.
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

// ============================================
// MEETING WITH PARTICIPANTS (For detail views)
// ============================================

/// Meeting with full participant list for detail/host views.
@freezed
class CadenceMeetingWithParticipants with _$CadenceMeetingWithParticipants {
  const factory CadenceMeetingWithParticipants({
    required CadenceMeeting meeting,
    required List<CadenceParticipant> participants,
    CadenceScheduleConfig? config,
  }) = _CadenceMeetingWithParticipants;

  const CadenceMeetingWithParticipants._();

  factory CadenceMeetingWithParticipants.fromJson(Map<String, dynamic> json) =>
      _$CadenceMeetingWithParticipantsFromJson(json);

  /// Get participants who submitted forms.
  List<CadenceParticipant> get submittedParticipants =>
      participants.where((p) => p.preMeetingSubmitted).toList();

  /// Get participants who haven't submitted forms.
  List<CadenceParticipant> get pendingParticipants =>
      participants.where((p) => !p.preMeetingSubmitted).toList();

  /// Get participants marked as present.
  List<CadenceParticipant> get presentParticipants => participants
      .where((p) =>
          p.attendanceStatus == AttendanceStatus.present ||
          p.attendanceStatus == AttendanceStatus.late)
      .toList();

  /// Get participants marked as absent.
  List<CadenceParticipant> get absentParticipants => participants
      .where((p) => p.attendanceStatus == AttendanceStatus.absent)
      .toList();

  /// Get participants with attendance pending.
  List<CadenceParticipant> get attendancePendingParticipants => participants
      .where((p) => p.attendanceStatus == AttendanceStatus.pending)
      .toList();
}
