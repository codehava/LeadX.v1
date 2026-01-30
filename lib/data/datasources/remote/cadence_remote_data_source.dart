import 'package:supabase_flutter/supabase_flutter.dart';

import '../../dtos/cadence_dtos.dart';

/// Remote data source for cadence meeting operations.
/// Handles all Supabase operations for cadence.
class CadenceRemoteDataSource {
  CadenceRemoteDataSource(this._supabase);

  final SupabaseClient _supabase;

  // ==========================================
  // Schedule Config Operations
  // ==========================================

  /// Fetch all active schedule configs.
  Future<List<CadenceScheduleConfigDto>> fetchActiveConfigs() async {
    final response = await _supabase
        .from('cadence_schedule_config')
        .select()
        .eq('is_active', true)
        .order('created_at');

    return (response as List)
        .map((json) => CadenceScheduleConfigDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Fetch config by ID.
  Future<CadenceScheduleConfigDto?> fetchConfigById(String configId) async {
    final response = await _supabase
        .from('cadence_schedule_config')
        .select()
        .eq('id', configId)
        .maybeSingle();

    if (response == null) return null;
    return CadenceScheduleConfigDto.fromJson(
        Map<String, dynamic>.from(response));
  }

  // ==========================================
  // Meeting Operations
  // ==========================================

  /// Fetch meetings for a user (as participant).
  /// Uses explicit two-step approach to avoid nested query issues with RLS.
  Future<List<CadenceMeetingDto>> fetchMeetingsForUser(String userId) async {
    // Step 1: Get participant records for this user
    final participantResponse = await _supabase
        .from('cadence_participants')
        .select('meeting_id')
        .eq('user_id', userId);

    final meetingIds = (participantResponse as List)
        .map((row) => row['meeting_id'] as String)
        .toSet()
        .toList();

    if (meetingIds.isEmpty) {
      return [];
    }

    // Step 2: Fetch meetings by IDs
    final response = await _supabase
        .from('cadence_meetings')
        .select()
        .inFilter('id', meetingIds)
        .order('scheduled_at', ascending: false);

    return (response as List)
        .map((json) => CadenceMeetingDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Fetch meetings where user is facilitator.
  Future<List<CadenceMeetingDto>> fetchHostedMeetings(String hostId) async {
    final response = await _supabase
        .from('cadence_meetings')
        .select()
        .eq('facilitator_id', hostId)
        .order('scheduled_at', ascending: false);

    return (response as List)
        .map((json) => CadenceMeetingDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Fetch meeting by ID.
  Future<CadenceMeetingDto?> fetchMeetingById(String meetingId) async {
    final response = await _supabase
        .from('cadence_meetings')
        .select()
        .eq('id', meetingId)
        .maybeSingle();

    if (response == null) return null;
    return CadenceMeetingDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Update meeting.
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

    return CadenceMeetingDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Create meeting.
  Future<CadenceMeetingDto> createMeeting(CadenceMeetingCreateDto dto) async {
    final response = await _supabase
        .from('cadence_meetings')
        .insert(dto.toJson())
        .select()
        .single();

    return CadenceMeetingDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Start meeting.
  Future<CadenceMeetingDto> startMeeting(String meetingId) async {
    return updateMeeting(meetingId, {
      'status': 'IN_PROGRESS',
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  /// End/complete meeting.
  Future<CadenceMeetingDto> endMeeting(String meetingId) async {
    return updateMeeting(meetingId, {
      'status': 'COMPLETED',
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Cancel meeting.
  Future<CadenceMeetingDto> cancelMeeting(String meetingId) async {
    return updateMeeting(meetingId, {
      'status': 'CANCELLED',
    });
  }

  // ==========================================
  // Participant Operations
  // ==========================================

  /// Fetch participants for a meeting.
  Future<List<CadenceParticipantDto>> fetchMeetingParticipants(
    String meetingId,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .select()
        .eq('meeting_id', meetingId)
        .order('created_at');

    return (response as List)
        .map((json) => CadenceParticipantDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Fetch participant by ID.
  Future<CadenceParticipantDto?> fetchParticipantById(
    String participantId,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .select()
        .eq('id', participantId)
        .maybeSingle();

    if (response == null) return null;
    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Fetch participation for a user in a meeting.
  Future<CadenceParticipantDto?> fetchParticipation(
    String meetingId,
    String userId,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .select()
        .eq('meeting_id', meetingId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Submit pre-meeting form.
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

    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Update attendance status.
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

    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Update host notes.
  Future<CadenceParticipantDto> updateHostNotes(
    String participantId,
    String notes,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .update({
          'host_notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', participantId)
        .select()
        .single();

    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Update feedback.
  Future<CadenceParticipantDto> updateFeedback(
    String participantId,
    String feedbackText,
  ) async {
    final now = DateTime.now().toIso8601String();

    // Get existing to check if this is first feedback
    final existing = await _supabase
        .from('cadence_participants')
        .select('feedback_given_at')
        .eq('id', participantId)
        .single();

    final isFirstFeedback = existing['feedback_given_at'] == null;

    final updateData = <String, dynamic>{
      'feedback_text': feedbackText,
      'feedback_updated_at': now,
      'updated_at': now,
    };

    if (isFirstFeedback) {
      updateData['feedback_given_at'] = now;
    }

    final response = await _supabase
        .from('cadence_participants')
        .update(updateData)
        .eq('id', participantId)
        .select()
        .single();

    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  /// Create participant.
  Future<CadenceParticipantDto> createParticipant(
    CadenceParticipantCreateDto dto,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .insert(dto.toJson())
        .select()
        .single();

    return CadenceParticipantDto.fromJson(Map<String, dynamic>.from(response));
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Upsert meeting (for sync).
  Future<void> upsertMeeting(Map<String, dynamic> data) async {
    await _supabase.from('cadence_meetings').upsert(data);
  }

  /// Upsert participant (for sync).
  Future<void> upsertParticipant(Map<String, dynamic> data) async {
    await _supabase.from('cadence_participants').upsert(data);
  }

  /// Fetch meetings updated since timestamp (for incremental sync).
  Future<List<CadenceMeetingDto>> fetchMeetingsUpdatedSince(
    DateTime since,
  ) async {
    final response = await _supabase
        .from('cadence_meetings')
        .select()
        .gt('updated_at', since.toIso8601String())
        .order('updated_at');

    return (response as List)
        .map((json) => CadenceMeetingDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Fetch participants updated since timestamp (for incremental sync).
  Future<List<CadenceParticipantDto>> fetchParticipantsUpdatedSince(
    DateTime since,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .select()
        .gt('updated_at', since.toIso8601String())
        .order('updated_at');

    return (response as List)
        .map((json) => CadenceParticipantDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Fetch all participant records for a user (initial sync).
  Future<List<CadenceParticipantDto>> fetchParticipantsForUser(
    String userId,
  ) async {
    final response = await _supabase
        .from('cadence_participants')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (response as List)
        .map((json) => CadenceParticipantDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  // ==========================================
  // History Operations
  // ==========================================

  /// Fetch participant history for a user.
  Future<List<CadenceParticipantDto>> fetchParticipantHistory(
    String userId, {
    int? limit,
  }) async {
    var query = _supabase
        .from('cadence_participants')
        .select('''
          *,
          cadence_meetings!inner(status, scheduled_at)
        ''')
        .eq('user_id', userId)
        .eq('cadence_meetings.status', 'COMPLETED')
        .order('cadence_meetings.scheduled_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return (response as List)
        .map((json) => CadenceParticipantDto.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
