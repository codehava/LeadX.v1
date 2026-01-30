// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cadence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CadenceScheduleConfigImpl _$$CadenceScheduleConfigImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceScheduleConfigImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  targetRole: json['targetRole'] as String,
  facilitatorRole: json['facilitatorRole'] as String,
  frequency: $enumDecode(_$MeetingFrequencyEnumMap, json['frequency']),
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
  dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
  defaultTime: json['defaultTime'] as String?,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
  preMeetingHours: (json['preMeetingHours'] as num?)?.toInt() ?? 24,
  isActive: json['isActive'] as bool? ?? true,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$CadenceScheduleConfigImplToJson(
  _$CadenceScheduleConfigImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'targetRole': instance.targetRole,
  'facilitatorRole': instance.facilitatorRole,
  'frequency': _$MeetingFrequencyEnumMap[instance.frequency]!,
  'dayOfWeek': instance.dayOfWeek,
  'dayOfMonth': instance.dayOfMonth,
  'defaultTime': instance.defaultTime,
  'durationMinutes': instance.durationMinutes,
  'preMeetingHours': instance.preMeetingHours,
  'isActive': instance.isActive,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$MeetingFrequencyEnumMap = {
  MeetingFrequency.daily: 'DAILY',
  MeetingFrequency.weekly: 'WEEKLY',
  MeetingFrequency.monthly: 'MONTHLY',
  MeetingFrequency.quarterly: 'QUARTERLY',
};

_$CadenceMeetingImpl _$$CadenceMeetingImplFromJson(Map<String, dynamic> json) =>
    _$CadenceMeetingImpl(
      id: json['id'] as String,
      configId: json['configId'] as String,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      facilitatorId: json['facilitatorId'] as String,
      status:
          $enumDecodeNullable(_$MeetingStatusEnumMap, json['status']) ??
          MeetingStatus.scheduled,
      location: json['location'] as String?,
      meetingLink: json['meetingLink'] as String?,
      agenda: json['agenda'] as String?,
      notes: json['notes'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdBy: json['createdBy'] as String,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      facilitatorName: json['facilitatorName'] as String?,
      configName: json['configName'] as String?,
      totalParticipants: (json['totalParticipants'] as num?)?.toInt(),
      submittedFormCount: (json['submittedFormCount'] as num?)?.toInt(),
      presentCount: (json['presentCount'] as num?)?.toInt(),
      preMeetingHours: (json['preMeetingHours'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CadenceMeetingImplToJson(
  _$CadenceMeetingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'configId': instance.configId,
  'title': instance.title,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'facilitatorId': instance.facilitatorId,
  'status': _$MeetingStatusEnumMap[instance.status]!,
  'location': instance.location,
  'meetingLink': instance.meetingLink,
  'agenda': instance.agenda,
  'notes': instance.notes,
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdBy': instance.createdBy,
  'isPendingSync': instance.isPendingSync,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'facilitatorName': instance.facilitatorName,
  'configName': instance.configName,
  'totalParticipants': instance.totalParticipants,
  'submittedFormCount': instance.submittedFormCount,
  'presentCount': instance.presentCount,
  'preMeetingHours': instance.preMeetingHours,
};

const _$MeetingStatusEnumMap = {
  MeetingStatus.scheduled: 'SCHEDULED',
  MeetingStatus.inProgress: 'IN_PROGRESS',
  MeetingStatus.completed: 'COMPLETED',
  MeetingStatus.cancelled: 'CANCELLED',
};

_$CadenceParticipantImpl _$$CadenceParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceParticipantImpl(
  id: json['id'] as String,
  meetingId: json['meetingId'] as String,
  userId: json['userId'] as String,
  attendanceStatus:
      $enumDecodeNullable(
        _$AttendanceStatusEnumMap,
        json['attendanceStatus'],
      ) ??
      AttendanceStatus.pending,
  arrivedAt: json['arrivedAt'] == null
      ? null
      : DateTime.parse(json['arrivedAt'] as String),
  excusedReason: json['excusedReason'] as String?,
  attendanceScoreImpact: (json['attendanceScoreImpact'] as num?)?.toInt(),
  markedBy: json['markedBy'] as String?,
  markedAt: json['markedAt'] == null
      ? null
      : DateTime.parse(json['markedAt'] as String),
  preMeetingSubmitted: json['preMeetingSubmitted'] as bool? ?? false,
  q1PreviousCommitment: json['q1PreviousCommitment'] as String?,
  q1CompletionStatus: $enumDecodeNullable(
    _$CommitmentCompletionStatusEnumMap,
    json['q1CompletionStatus'],
  ),
  q2WhatAchieved: json['q2WhatAchieved'] as String?,
  q3Obstacles: json['q3Obstacles'] as String?,
  q4NextCommitment: json['q4NextCommitment'] as String?,
  formSubmittedAt: json['formSubmittedAt'] == null
      ? null
      : DateTime.parse(json['formSubmittedAt'] as String),
  formSubmissionStatus: $enumDecodeNullable(
    _$FormSubmissionStatusEnumMap,
    json['formSubmissionStatus'],
  ),
  formScoreImpact: (json['formScoreImpact'] as num?)?.toInt(),
  hostNotes: json['hostNotes'] as String?,
  feedbackText: json['feedbackText'] as String?,
  feedbackGivenAt: json['feedbackGivenAt'] == null
      ? null
      : DateTime.parse(json['feedbackGivenAt'] as String),
  feedbackUpdatedAt: json['feedbackUpdatedAt'] == null
      ? null
      : DateTime.parse(json['feedbackUpdatedAt'] as String),
  isPendingSync: json['isPendingSync'] as bool? ?? false,
  lastSyncAt: json['lastSyncAt'] == null
      ? null
      : DateTime.parse(json['lastSyncAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  userName: json['userName'] as String?,
  userRole: json['userRole'] as String?,
);

Map<String, dynamic> _$$CadenceParticipantImplToJson(
  _$CadenceParticipantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'meetingId': instance.meetingId,
  'userId': instance.userId,
  'attendanceStatus': _$AttendanceStatusEnumMap[instance.attendanceStatus]!,
  'arrivedAt': instance.arrivedAt?.toIso8601String(),
  'excusedReason': instance.excusedReason,
  'attendanceScoreImpact': instance.attendanceScoreImpact,
  'markedBy': instance.markedBy,
  'markedAt': instance.markedAt?.toIso8601String(),
  'preMeetingSubmitted': instance.preMeetingSubmitted,
  'q1PreviousCommitment': instance.q1PreviousCommitment,
  'q1CompletionStatus':
      _$CommitmentCompletionStatusEnumMap[instance.q1CompletionStatus],
  'q2WhatAchieved': instance.q2WhatAchieved,
  'q3Obstacles': instance.q3Obstacles,
  'q4NextCommitment': instance.q4NextCommitment,
  'formSubmittedAt': instance.formSubmittedAt?.toIso8601String(),
  'formSubmissionStatus':
      _$FormSubmissionStatusEnumMap[instance.formSubmissionStatus],
  'formScoreImpact': instance.formScoreImpact,
  'hostNotes': instance.hostNotes,
  'feedbackText': instance.feedbackText,
  'feedbackGivenAt': instance.feedbackGivenAt?.toIso8601String(),
  'feedbackUpdatedAt': instance.feedbackUpdatedAt?.toIso8601String(),
  'isPendingSync': instance.isPendingSync,
  'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'userName': instance.userName,
  'userRole': instance.userRole,
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.pending: 'PENDING',
  AttendanceStatus.present: 'PRESENT',
  AttendanceStatus.late: 'LATE',
  AttendanceStatus.excused: 'EXCUSED',
  AttendanceStatus.absent: 'ABSENT',
};

const _$CommitmentCompletionStatusEnumMap = {
  CommitmentCompletionStatus.completed: 'COMPLETED',
  CommitmentCompletionStatus.partial: 'PARTIAL',
  CommitmentCompletionStatus.notDone: 'NOT_DONE',
};

const _$FormSubmissionStatusEnumMap = {
  FormSubmissionStatus.onTime: 'ON_TIME',
  FormSubmissionStatus.late: 'LATE',
  FormSubmissionStatus.veryLate: 'VERY_LATE',
  FormSubmissionStatus.notSubmitted: 'NOT_SUBMITTED',
};

_$CadenceFormSubmissionImpl _$$CadenceFormSubmissionImplFromJson(
  Map<String, dynamic> json,
) => _$CadenceFormSubmissionImpl(
  participantId: json['participantId'] as String,
  q1CompletionStatus: $enumDecodeNullable(
    _$CommitmentCompletionStatusEnumMap,
    json['q1CompletionStatus'],
  ),
  q2WhatAchieved: json['q2WhatAchieved'] as String,
  q3Obstacles: json['q3Obstacles'] as String?,
  q4NextCommitment: json['q4NextCommitment'] as String,
);

Map<String, dynamic> _$$CadenceFormSubmissionImplToJson(
  _$CadenceFormSubmissionImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'q1CompletionStatus':
      _$CommitmentCompletionStatusEnumMap[instance.q1CompletionStatus],
  'q2WhatAchieved': instance.q2WhatAchieved,
  'q3Obstacles': instance.q3Obstacles,
  'q4NextCommitment': instance.q4NextCommitment,
};

_$CadenceMeetingWithParticipantsImpl
_$$CadenceMeetingWithParticipantsImplFromJson(Map<String, dynamic> json) =>
    _$CadenceMeetingWithParticipantsImpl(
      meeting: CadenceMeeting.fromJson(json['meeting'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => CadenceParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      config: json['config'] == null
          ? null
          : CadenceScheduleConfig.fromJson(
              json['config'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$CadenceMeetingWithParticipantsImplToJson(
  _$CadenceMeetingWithParticipantsImpl instance,
) => <String, dynamic>{
  'meeting': instance.meeting,
  'participants': instance.participants,
  'config': instance.config,
};
