// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cadence_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CadenceScheduleConfigDtoImpl _$$CadenceScheduleConfigDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceScheduleConfigDtoImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  targetRole: json['target_role'] as String,
  facilitatorRole: json['facilitator_role'] as String,
  frequency: json['frequency'] as String,
  dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
  dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
  defaultTime: json['default_time'] as String?,
  durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
  preMeetingHours: (json['pre_meeting_hours'] as num?)?.toInt() ?? 24,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$CadenceScheduleConfigDtoImplToJson(
  _$CadenceScheduleConfigDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'target_role': instance.targetRole,
  'facilitator_role': instance.facilitatorRole,
  'frequency': instance.frequency,
  'day_of_week': instance.dayOfWeek,
  'day_of_month': instance.dayOfMonth,
  'default_time': instance.defaultTime,
  'duration_minutes': instance.durationMinutes,
  'pre_meeting_hours': instance.preMeetingHours,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

_$CadenceMeetingDtoImpl _$$CadenceMeetingDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceMeetingDtoImpl(
  id: json['id'] as String,
  configId: json['config_id'] as String,
  title: json['title'] as String,
  scheduledAt: DateTime.parse(json['scheduled_at'] as String),
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  facilitatorId: json['facilitator_id'] as String,
  status: json['status'] as String? ?? 'SCHEDULED',
  location: json['location'] as String?,
  meetingLink: json['meeting_link'] as String?,
  agenda: json['agenda'] as String?,
  notes: json['notes'] as String?,
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  createdBy: json['created_by'] as String,
  isPendingSync: json['is_pending_sync'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$CadenceMeetingDtoImplToJson(
  _$CadenceMeetingDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'config_id': instance.configId,
  'title': instance.title,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'duration_minutes': instance.durationMinutes,
  'facilitator_id': instance.facilitatorId,
  'status': instance.status,
  'location': instance.location,
  'meeting_link': instance.meetingLink,
  'agenda': instance.agenda,
  'notes': instance.notes,
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'created_by': instance.createdBy,
  'is_pending_sync': instance.isPendingSync,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

_$CadenceParticipantDtoImpl _$$CadenceParticipantDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceParticipantDtoImpl(
  id: json['id'] as String,
  meetingId: json['meeting_id'] as String,
  userId: json['user_id'] as String,
  attendanceStatus: json['attendance_status'] as String? ?? 'PENDING',
  arrivedAt: json['arrived_at'] == null
      ? null
      : DateTime.parse(json['arrived_at'] as String),
  excusedReason: json['excused_reason'] as String?,
  attendanceScoreImpact: (json['attendance_score_impact'] as num?)?.toInt(),
  markedBy: json['marked_by'] as String?,
  markedAt: json['marked_at'] == null
      ? null
      : DateTime.parse(json['marked_at'] as String),
  preMeetingSubmitted: json['pre_meeting_submitted'] as bool? ?? false,
  q1PreviousCommitment: json['q1_previous_commitment'] as String?,
  q1CompletionStatus: json['q1_completion_status'] as String?,
  q2WhatAchieved: json['q2_what_achieved'] as String?,
  q3Obstacles: json['q3_obstacles'] as String?,
  q4NextCommitment: json['q4_next_commitment'] as String?,
  formSubmittedAt: json['form_submitted_at'] == null
      ? null
      : DateTime.parse(json['form_submitted_at'] as String),
  formSubmissionStatus: json['form_submission_status'] as String?,
  formScoreImpact: (json['form_score_impact'] as num?)?.toInt(),
  hostNotes: json['host_notes'] as String?,
  feedbackText: json['feedback_text'] as String?,
  feedbackGivenAt: json['feedback_given_at'] == null
      ? null
      : DateTime.parse(json['feedback_given_at'] as String),
  feedbackUpdatedAt: json['feedback_updated_at'] == null
      ? null
      : DateTime.parse(json['feedback_updated_at'] as String),
  isPendingSync: json['is_pending_sync'] as bool? ?? false,
  lastSyncAt: json['last_sync_at'] == null
      ? null
      : DateTime.parse(json['last_sync_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$CadenceParticipantDtoImplToJson(
  _$CadenceParticipantDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'meeting_id': instance.meetingId,
  'user_id': instance.userId,
  'attendance_status': instance.attendanceStatus,
  'arrived_at': instance.arrivedAt?.toIso8601String(),
  'excused_reason': instance.excusedReason,
  'attendance_score_impact': instance.attendanceScoreImpact,
  'marked_by': instance.markedBy,
  'marked_at': instance.markedAt?.toIso8601String(),
  'pre_meeting_submitted': instance.preMeetingSubmitted,
  'q1_previous_commitment': instance.q1PreviousCommitment,
  'q1_completion_status': instance.q1CompletionStatus,
  'q2_what_achieved': instance.q2WhatAchieved,
  'q3_obstacles': instance.q3Obstacles,
  'q4_next_commitment': instance.q4NextCommitment,
  'form_submitted_at': instance.formSubmittedAt?.toIso8601String(),
  'form_submission_status': instance.formSubmissionStatus,
  'form_score_impact': instance.formScoreImpact,
  'host_notes': instance.hostNotes,
  'feedback_text': instance.feedbackText,
  'feedback_given_at': instance.feedbackGivenAt?.toIso8601String(),
  'feedback_updated_at': instance.feedbackUpdatedAt?.toIso8601String(),
  'is_pending_sync': instance.isPendingSync,
  'last_sync_at': instance.lastSyncAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

_$CadenceFormCreateDtoImpl _$$CadenceFormCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceFormCreateDtoImpl(
  q1CompletionStatus: json['q1_completion_status'] as String?,
  q2WhatAchieved: json['q2_what_achieved'] as String,
  q3Obstacles: json['q3_obstacles'] as String?,
  q4NextCommitment: json['q4_next_commitment'] as String,
);

Map<String, dynamic> _$$CadenceFormCreateDtoImplToJson(
  _$CadenceFormCreateDtoImpl instance,
) => <String, dynamic>{
  'q1_completion_status': instance.q1CompletionStatus,
  'q2_what_achieved': instance.q2WhatAchieved,
  'q3_obstacles': instance.q3Obstacles,
  'q4_next_commitment': instance.q4NextCommitment,
};

_$AttendanceUpdateDtoImpl _$$AttendanceUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceUpdateDtoImpl(
  attendanceStatus: json['attendance_status'] as String,
  excusedReason: json['excused_reason'] as String?,
  arrivedAt: json['arrived_at'] == null
      ? null
      : DateTime.parse(json['arrived_at'] as String),
);

Map<String, dynamic> _$$AttendanceUpdateDtoImplToJson(
  _$AttendanceUpdateDtoImpl instance,
) => <String, dynamic>{
  'attendance_status': instance.attendanceStatus,
  'excused_reason': instance.excusedReason,
  'arrived_at': instance.arrivedAt?.toIso8601String(),
};

_$FeedbackUpdateDtoImpl _$$FeedbackUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$FeedbackUpdateDtoImpl(
  hostNotes: json['host_notes'] as String?,
  feedbackText: json['feedback_text'] as String?,
);

Map<String, dynamic> _$$FeedbackUpdateDtoImplToJson(
  _$FeedbackUpdateDtoImpl instance,
) => <String, dynamic>{
  'host_notes': instance.hostNotes,
  'feedback_text': instance.feedbackText,
};

_$CadenceMeetingCreateDtoImpl _$$CadenceMeetingCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceMeetingCreateDtoImpl(
  id: json['id'] as String,
  configId: json['config_id'] as String,
  title: json['title'] as String,
  scheduledAt: DateTime.parse(json['scheduled_at'] as String),
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  facilitatorId: json['facilitator_id'] as String,
  createdBy: json['created_by'] as String,
  location: json['location'] as String?,
  meetingLink: json['meeting_link'] as String?,
  agenda: json['agenda'] as String?,
);

Map<String, dynamic> _$$CadenceMeetingCreateDtoImplToJson(
  _$CadenceMeetingCreateDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'config_id': instance.configId,
  'title': instance.title,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'duration_minutes': instance.durationMinutes,
  'facilitator_id': instance.facilitatorId,
  'created_by': instance.createdBy,
  'location': instance.location,
  'meeting_link': instance.meetingLink,
  'agenda': instance.agenda,
};

_$CadenceParticipantCreateDtoImpl _$$CadenceParticipantCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceParticipantCreateDtoImpl(
  id: json['id'] as String,
  meetingId: json['meeting_id'] as String,
  userId: json['user_id'] as String,
  q1PreviousCommitment: json['q1_previous_commitment'] as String?,
);

Map<String, dynamic> _$$CadenceParticipantCreateDtoImplToJson(
  _$CadenceParticipantCreateDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'meeting_id': instance.meetingId,
  'user_id': instance.userId,
  'q1_previous_commitment': instance.q1PreviousCommitment,
};

_$CadenceConfigCreateDtoImpl _$$CadenceConfigCreateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceConfigCreateDtoImpl(
  name: json['name'] as String,
  description: json['description'] as String?,
  targetRole: json['target_role'] as String,
  facilitatorRole: json['facilitator_role'] as String,
  frequency: json['frequency'] as String,
  dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
  dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
  defaultTime: json['default_time'] as String?,
  durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
  preMeetingHours: (json['pre_meeting_hours'] as num?)?.toInt() ?? 24,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$$CadenceConfigCreateDtoImplToJson(
  _$CadenceConfigCreateDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'target_role': instance.targetRole,
  'facilitator_role': instance.facilitatorRole,
  'frequency': instance.frequency,
  'day_of_week': instance.dayOfWeek,
  'day_of_month': instance.dayOfMonth,
  'default_time': instance.defaultTime,
  'duration_minutes': instance.durationMinutes,
  'pre_meeting_hours': instance.preMeetingHours,
  'is_active': instance.isActive,
};

_$CadenceConfigUpdateDtoImpl _$$CadenceConfigUpdateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceConfigUpdateDtoImpl(
  name: json['name'] as String?,
  description: json['description'] as String?,
  targetRole: json['target_role'] as String?,
  facilitatorRole: json['facilitator_role'] as String?,
  frequency: json['frequency'] as String?,
  dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
  dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
  defaultTime: json['default_time'] as String?,
  durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
  preMeetingHours: (json['pre_meeting_hours'] as num?)?.toInt(),
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$$CadenceConfigUpdateDtoImplToJson(
  _$CadenceConfigUpdateDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'target_role': instance.targetRole,
  'facilitator_role': instance.facilitatorRole,
  'frequency': instance.frequency,
  'day_of_week': instance.dayOfWeek,
  'day_of_month': instance.dayOfMonth,
  'default_time': instance.defaultTime,
  'duration_minutes': instance.durationMinutes,
  'pre_meeting_hours': instance.preMeetingHours,
  'is_active': instance.isActive,
};
