import 'package:freezed_annotation/freezed_annotation.dart';

part 'cadence_dtos.freezed.dart';
part 'cadence_dtos.g.dart';

// ============================================
// SCHEDULE CONFIG DTO
// ============================================

/// DTO for syncing cadence schedule config with Supabase.
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

/// DTO for syncing cadence meeting with Supabase.
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
    @JsonKey(name: 'is_pending_sync') @Default(false) bool isPendingSync,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CadenceMeetingDto;

  factory CadenceMeetingDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceMeetingDtoFromJson(json);
}

// ============================================
// PARTICIPANT DTO (Combined table)
// ============================================

/// DTO for syncing cadence participant with Supabase.
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
    @JsonKey(name: 'is_pending_sync') @Default(false) bool isPendingSync,
    @JsonKey(name: 'last_sync_at') DateTime? lastSyncAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CadenceParticipantDto;

  factory CadenceParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceParticipantDtoFromJson(json);
}

// ============================================
// FORM CREATE/UPDATE DTOs
// ============================================

/// DTO for submitting pre-meeting form (Q1-Q4).
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

/// DTO for updating attendance status.
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

/// DTO for updating host notes and feedback.
@freezed
class FeedbackUpdateDto with _$FeedbackUpdateDto {
  const factory FeedbackUpdateDto({
    @JsonKey(name: 'host_notes') String? hostNotes,
    @JsonKey(name: 'feedback_text') String? feedbackText,
  }) = _FeedbackUpdateDto;

  factory FeedbackUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$FeedbackUpdateDtoFromJson(json);
}

// ============================================
// MEETING CREATE DTO
// ============================================

/// DTO for creating a new meeting.
@freezed
class CadenceMeetingCreateDto with _$CadenceMeetingCreateDto {
  const factory CadenceMeetingCreateDto({
    required String id,
    @JsonKey(name: 'config_id') required String configId,
    required String title,
    @JsonKey(name: 'scheduled_at') required DateTime scheduledAt,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'facilitator_id') required String facilitatorId,
    @JsonKey(name: 'created_by') required String createdBy,
    String? location,
    @JsonKey(name: 'meeting_link') String? meetingLink,
    String? agenda,
  }) = _CadenceMeetingCreateDto;

  factory CadenceMeetingCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceMeetingCreateDtoFromJson(json);
}

// ============================================
// PARTICIPANT CREATE DTO
// ============================================

/// DTO for creating a participant record.
@freezed
class CadenceParticipantCreateDto with _$CadenceParticipantCreateDto {
  const factory CadenceParticipantCreateDto({
    required String id,
    @JsonKey(name: 'meeting_id') required String meetingId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'q1_previous_commitment') String? q1PreviousCommitment,
  }) = _CadenceParticipantCreateDto;

  factory CadenceParticipantCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceParticipantCreateDtoFromJson(json);
}

// ============================================
// ADMIN: SCHEDULE CONFIG CREATE/UPDATE DTOs
// ============================================

/// DTO for creating a new cadence schedule config (Admin only).
@freezed
class CadenceConfigCreateDto with _$CadenceConfigCreateDto {
  const factory CadenceConfigCreateDto({
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
  }) = _CadenceConfigCreateDto;

  factory CadenceConfigCreateDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceConfigCreateDtoFromJson(json);
}

/// DTO for updating an existing cadence schedule config (Admin only).
@freezed
class CadenceConfigUpdateDto with _$CadenceConfigUpdateDto {
  const factory CadenceConfigUpdateDto({
    String? name,
    String? description,
    @JsonKey(name: 'target_role') String? targetRole,
    @JsonKey(name: 'facilitator_role') String? facilitatorRole,
    String? frequency,
    @JsonKey(name: 'day_of_week') int? dayOfWeek,
    @JsonKey(name: 'day_of_month') int? dayOfMonth,
    @JsonKey(name: 'default_time') String? defaultTime,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'pre_meeting_hours') int? preMeetingHours,
    @JsonKey(name: 'is_active') bool? isActive,
  }) = _CadenceConfigUpdateDto;

  factory CadenceConfigUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$CadenceConfigUpdateDtoFromJson(json);
}
