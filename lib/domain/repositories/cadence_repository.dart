import '../../core/errors/result.dart';
import '../entities/cadence.dart';

/// Repository interface for cadence meeting operations.
abstract class CadenceRepository {
  // ==========================================
  // Schedule Config Operations
  // ==========================================

  /// Get all active cadence schedule configs.
  Future<List<CadenceScheduleConfig>> getActiveConfigs();

  /// Get config by target role.
  Future<CadenceScheduleConfig?> getConfigForRole(String role);

  /// Get config for current user as facilitator.
  Future<CadenceScheduleConfig?> getMyFacilitatorConfig();

  // ==========================================
  // Admin: Schedule Config Management (Admin Only)
  // ==========================================

  /// Watch all schedule configs (active and inactive).
  Stream<List<CadenceScheduleConfig>> watchAllConfigs();

  /// Watch active configs as a reactive stream.
  Stream<List<CadenceScheduleConfig>> watchActiveConfigs();

  /// Watch config for current user as facilitator (reactive stream).
  Stream<CadenceScheduleConfig?> watchMyFacilitatorConfig();

  /// Get a specific config by ID.
  Future<CadenceScheduleConfig?> getConfigById(String configId);

  /// Watch a specific config by ID (reactive stream).
  Stream<CadenceScheduleConfig?> watchConfigById(String configId);

  /// Create a new schedule config.
  Future<Result<CadenceScheduleConfig>> createConfig({
    required String name,
    String? description,
    required String targetRole,
    required String facilitatorRole,
    required String frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    String? defaultTime,
    int durationMinutes = 60,
    int preMeetingHours = 24,
    bool isActive = true,
  });

  /// Update an existing schedule config.
  Future<Result<CadenceScheduleConfig>> updateConfig({
    required String configId,
    String? name,
    String? description,
    String? targetRole,
    String? facilitatorRole,
    String? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    String? defaultTime,
    int? durationMinutes,
    int? preMeetingHours,
    bool? isActive,
  });

  /// Toggle config active status.
  Future<Result<CadenceScheduleConfig>> toggleConfigActive(
    String configId,
    bool isActive,
  );

  /// Soft delete a config (set is_active = false).
  Future<Result<void>> deleteConfig(String configId);

  // ==========================================
  // Meeting Operations (Streams)
  // ==========================================

  /// Watch upcoming meetings for current user (as participant).
  Stream<List<CadenceMeeting>> watchUpcomingMeetings();

  /// Watch past meetings for current user (as participant).
  Stream<List<CadenceMeeting>> watchPastMeetings({int? limit});

  /// Watch meetings where current user is host/facilitator.
  Stream<List<CadenceMeeting>> watchHostedMeetings();

  /// Watch single meeting by ID.
  Stream<CadenceMeeting?> watchMeeting(String meetingId);

  /// Watch participants for a meeting.
  Stream<List<CadenceParticipant>> watchMeetingParticipants(String meetingId);

  /// Watch current user's participation record for a meeting.
  Stream<CadenceParticipant?> watchMyParticipation(String meetingId);

  // ==========================================
  // Meeting Operations (Actions)
  // ==========================================

  /// Start a meeting (host only).
  Future<Result<CadenceMeeting>> startMeeting(String meetingId);

  /// End/complete a meeting (host only).
  Future<Result<CadenceMeeting>> endMeeting(String meetingId);

  /// Cancel a meeting (host only).
  Future<Result<CadenceMeeting>> cancelMeeting(
    String meetingId,
    String reason,
  );

  /// Update meeting notes (host only).
  Future<Result<void>> updateMeetingNotes(
    String meetingId,
    String notes,
  );

  /// Update meeting agenda (host only).
  Future<Result<void>> updateMeetingAgenda(
    String meetingId,
    String agenda,
  );

  // ==========================================
  // Participant Form Operations
  // ==========================================

  /// Submit pre-meeting form (Q1-Q4).
  Future<Result<CadenceParticipant>> submitPreMeetingForm(
    CadenceFormSubmission submission,
  );

  /// Save form as draft (not submitted).
  Future<Result<CadenceParticipant>> saveFormDraft(
    CadenceFormSubmission submission,
  );

  /// Get participant's previous commitment (Q4) for Q1 auto-fill.
  Future<String?> getPreviousCommitment(String userId, String facilitatorId);

  // ==========================================
  // Attendance Operations (Host Only)
  // ==========================================

  /// Mark attendance for a participant.
  Future<Result<CadenceParticipant>> markAttendance({
    required String participantId,
    required AttendanceStatus status,
    String? excusedReason,
  });

  /// Batch mark attendance for multiple participants.
  Future<Result<List<CadenceParticipant>>> batchMarkAttendance({
    required String meetingId,
    required Map<String, AttendanceStatus> attendanceMap,
  });

  // ==========================================
  // Feedback Operations (Host Only)
  // ==========================================

  /// Save internal host notes for a participant (not visible to participant).
  Future<Result<void>> saveHostNotes({
    required String participantId,
    required String notes,
  });

  /// Give feedback to a participant (visible to participant).
  Future<Result<void>> saveFeedback({
    required String participantId,
    required String feedbackText,
  });

  // ==========================================
  // History & Reporting
  // ==========================================

  /// Get participant's cadence history with feedback.
  Future<List<CadenceParticipant>> getParticipantHistory({
    required String userId,
    int? limit,
  });

  /// Get meeting with all participants (for detail/summary view).
  Future<CadenceMeetingWithParticipants?> getMeetingWithParticipants(
    String meetingId,
  );

  /// Watch meeting with all participants (reactive stream).
  Stream<CadenceMeetingWithParticipants?> watchMeetingWithParticipants(
    String meetingId,
  );

  // ==========================================
  // Meeting Generation (Host)
  // ==========================================

  /// Ensure upcoming meetings exist for current user as host.
  /// Creates meetings + auto-populates participants if missing.
  Future<Result<List<CadenceMeeting>>> ensureUpcomingMeetings({
    int weeksAhead = 4,
  });

  /// Get direct subordinates who should be participants.
  Future<List<String>> getTeamMemberIds();

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync cadence data from remote to local.
  Future<void> syncFromRemote({DateTime? since});

  /// Get pending sync records.
  Future<List<CadenceMeeting>> getPendingSyncMeetings();
  Future<List<CadenceParticipant>> getPendingSyncParticipants();

  /// Mark records as synced.
  Future<void> markMeetingAsSynced(String id, DateTime syncedAt);
  Future<void> markParticipantAsSynced(String id, DateTime syncedAt);
}
