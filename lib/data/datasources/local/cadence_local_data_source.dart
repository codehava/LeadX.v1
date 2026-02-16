import 'package:drift/drift.dart';

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';

/// Local data source for cadence meeting operations.
/// Handles all local database operations for cadence.
class CadenceLocalDataSource {
  CadenceLocalDataSource(this._db);

  final AppDatabase _db;

  // ==========================================
  // Schedule Config Operations
  // ==========================================

  /// Get all active cadence schedule configs.
  Future<List<CadenceScheduleConfigData>> getActiveConfigs() async {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.isActive.equals(true)))
        .get();
  }

  /// Get config by target role.
  /// Returns the first matching config if multiple exist for the same role.
  Future<CadenceScheduleConfigData?> getConfigByTargetRole(String role) async {
    final results = await (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.targetRole.equals(role))
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get config by facilitator role.
  /// Returns the first matching config if multiple exist for the same role.
  Future<CadenceScheduleConfigData?> getConfigByFacilitatorRole(
    String role,
  ) async {
    final results = await (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.facilitatorRole.equals(role))
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Get all configs by facilitator role (when multiple configs exist for same role).
  Future<List<CadenceScheduleConfigData>> getConfigsByFacilitatorRole(
    String role,
  ) async {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.facilitatorRole.equals(role))
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Get config by ID.
  Future<CadenceScheduleConfigData?> getConfigById(String configId) async {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.id.equals(configId)))
        .getSingleOrNull();
  }

  /// Watch config by ID as a reactive stream.
  Stream<CadenceScheduleConfigData?> watchConfigById(String configId) {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.id.equals(configId)))
        .watchSingleOrNull();
  }

  /// Watch active configs as a reactive stream.
  Stream<List<CadenceScheduleConfigData>> watchActiveConfigs() {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Watch config by facilitator role as a reactive stream.
  Stream<CadenceScheduleConfigData?> watchConfigByFacilitatorRole(
    String role,
  ) {
    return (_db.select(_db.cadenceScheduleConfig)
          ..where((t) => t.facilitatorRole.equals(role))
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Insert or update config.
  Future<int> upsertConfig(CadenceScheduleConfigCompanion data) {
    return _db
        .into(_db.cadenceScheduleConfig)
        .insertOnConflictUpdate(data);
  }

  // ==========================================
  // Admin: Schedule Config Operations
  // ==========================================

  /// Watch all schedule configs (active and inactive) for admin.
  Stream<List<CadenceScheduleConfigData>> watchAllConfigs() {
    return (_db.select(_db.cadenceScheduleConfig)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isActive),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  /// Insert a new config.
  Future<int> insertConfig(CadenceScheduleConfigCompanion data) {
    return _db.into(_db.cadenceScheduleConfig).insert(data);
  }

  /// Update an existing config.
  Future<int> updateConfig(
    String configId,
    CadenceScheduleConfigCompanion data,
  ) {
    return (_db.update(_db.cadenceScheduleConfig)
          ..where((t) => t.id.equals(configId)))
        .write(data);
  }

  /// Soft delete a config (set is_active = false).
  Future<int> softDeleteConfig(String configId) {
    return updateConfig(
      configId,
      CadenceScheduleConfigCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================
  // Meeting Operations - Watch
  // ==========================================

  /// Watch upcoming meetings for a user (as participant).
  Stream<List<CadenceMeeting>> watchUpcomingMeetingsForUser(String userId) {
    final query = _db.select(_db.cadenceMeetings).join([
      innerJoin(
        _db.cadenceParticipants,
        _db.cadenceParticipants.meetingId.equalsExp(_db.cadenceMeetings.id),
      ),
    ])
      ..where(_db.cadenceParticipants.userId.equals(userId))
      ..where(_db.cadenceMeetings.status.isIn(['SCHEDULED', 'IN_PROGRESS']))
      ..where(_db.cadenceMeetings.scheduledAt.isBiggerThanValue(
        DateTime.now().subtract(const Duration(hours: 24)),
      ))
      ..orderBy([OrderingTerm.asc(_db.cadenceMeetings.scheduledAt)]);

    return query.watch().map((rows) =>
        rows.map((row) => row.readTable(_db.cadenceMeetings)).toList());
  }

  /// Watch past meetings for a user (as participant).
  Stream<List<CadenceMeeting>> watchPastMeetingsForUser(
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

  /// Watch meetings where user is facilitator/host.
  Stream<List<CadenceMeeting>> watchHostedMeetings(String hostId) {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.facilitatorId.equals(hostId))
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .watch();
  }

  /// Watch a single meeting by ID.
  Stream<CadenceMeeting?> watchMeeting(String meetingId) {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.id.equals(meetingId)))
        .watchSingleOrNull();
  }

  // ==========================================
  // Meeting Operations - Get
  // ==========================================

  /// Get meeting by ID.
  Future<CadenceMeeting?> getMeetingById(String meetingId) {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.id.equals(meetingId)))
        .getSingleOrNull();
  }

  /// Check if meeting exists for host on date.
  Future<bool> meetingExistsForHostOnDate(
    String hostId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await (_db.select(_db.cadenceMeetings)
          ..where((t) => t.facilitatorId.equals(hostId))
          ..where((t) => t.scheduledAt.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.scheduledAt.isSmallerThanValue(endOfDay))
          ..where((t) => t.status.isNotIn(['CANCELLED'])))
        .get();

    return result.isNotEmpty;
  }

  // ==========================================
  // Meeting Operations - Write
  // ==========================================

  /// Insert a new meeting.
  Future<int> insertMeeting(CadenceMeetingsCompanion data) {
    return _db.into(_db.cadenceMeetings).insert(data);
  }

  /// Update a meeting.
  Future<int> updateMeeting(String meetingId, CadenceMeetingsCompanion data) {
    return (_db.update(_db.cadenceMeetings)
          ..where((t) => t.id.equals(meetingId)))
        .write(data);
  }

  /// Start a meeting.
  Future<int> startMeeting(String meetingId) {
    return updateMeeting(
      meetingId,
      CadenceMeetingsCompanion(
        status: const Value('IN_PROGRESS'),
        startedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// End/complete a meeting.
  Future<int> endMeeting(String meetingId) {
    return updateMeeting(
      meetingId,
      CadenceMeetingsCompanion(
        status: const Value('COMPLETED'),
        completedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Cancel a meeting.
  Future<int> cancelMeeting(String meetingId) {
    return updateMeeting(
      meetingId,
      CadenceMeetingsCompanion(
        status: const Value('CANCELLED'),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================
  // Participant Operations - Watch
  // ==========================================

  /// Watch participants for a meeting.
  Stream<List<CadenceParticipant>> watchMeetingParticipants(
    String meetingId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Watch current user's participation for a meeting.
  Stream<CadenceParticipant?> watchParticipation(
    String meetingId,
    String userId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  // ==========================================
  // Participant Operations - Get
  // ==========================================

  /// Get participant by ID.
  Future<CadenceParticipant?> getParticipant(String participantId) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.id.equals(participantId)))
        .getSingleOrNull();
  }

  /// Get participation for a user in a meeting.
  Future<CadenceParticipant?> getParticipation(
    String meetingId,
    String userId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Get all participants for a meeting.
  Future<List<CadenceParticipant>> getMeetingParticipants(
    String meetingId,
  ) {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.meetingId.equals(meetingId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get previous commitment (Q4) for Q1 auto-fill.
  Future<String?> getPreviousCommitment(
    String userId,
    String facilitatorId,
  ) async {
    final query = _db.customSelect(
      '''
      SELECT cp.q4_next_commitment
      FROM cadence_participants cp
      JOIN cadence_meetings cm ON cm.id = cp.meeting_id
      WHERE cp.user_id = ?
        AND cm.facilitator_id = ?
        AND cm.status = 'COMPLETED'
        AND cp.q4_next_commitment IS NOT NULL
      ORDER BY cm.scheduled_at DESC
      LIMIT 1
      ''',
      variables: [
        Variable.withString(userId),
        Variable.withString(facilitatorId),
      ],
    );

    final result = await query.getSingleOrNull();
    return result?.read<String?>('q4_next_commitment');
  }

  // ==========================================
  // Participant Operations - Write
  // ==========================================

  /// Insert a participant.
  Future<int> insertParticipant(CadenceParticipantsCompanion data) {
    return _db.into(_db.cadenceParticipants).insert(data);
  }

  /// Update a participant.
  Future<int> updateParticipant(
    String participantId,
    CadenceParticipantsCompanion data,
  ) {
    return (_db.update(_db.cadenceParticipants)
          ..where((t) => t.id.equals(participantId)))
        .write(data);
  }

  /// Submit pre-meeting form.
  Future<int> submitForm(
    String participantId, {
    required String? q1CompletionStatus,
    required String q2WhatAchieved,
    String? q3Obstacles,
    required String q4NextCommitment,
    required String formSubmissionStatus,
    required int formScoreImpact,
  }) {
    return updateParticipant(
      participantId,
      CadenceParticipantsCompanion(
        preMeetingSubmitted: const Value(true),
        q1CompletionStatus: Value(q1CompletionStatus),
        q2WhatAchieved: Value(q2WhatAchieved),
        q3Obstacles: Value(q3Obstacles),
        q4NextCommitment: Value(q4NextCommitment),
        formSubmittedAt: Value(DateTime.now()),
        formSubmissionStatus: Value(formSubmissionStatus),
        formScoreImpact: Value(formScoreImpact),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark attendance for a participant.
  Future<int> markAttendance(
    String participantId, {
    required String status,
    required int scoreImpact,
    String? excusedReason,
    required String markedBy,
  }) {
    return updateParticipant(
      participantId,
      CadenceParticipantsCompanion(
        attendanceStatus: Value(status),
        attendanceScoreImpact: Value(scoreImpact),
        excusedReason: Value(excusedReason),
        arrivedAt: status == 'PRESENT' || status == 'LATE'
            ? Value(DateTime.now())
            : const Value.absent(),
        markedBy: Value(markedBy),
        markedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Save host notes.
  Future<int> saveHostNotes(String participantId, String notes) {
    return updateParticipant(
      participantId,
      CadenceParticipantsCompanion(
        hostNotes: Value(notes),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Save feedback.
  Future<int> saveFeedback(String participantId, String feedbackText) {
    return updateParticipant(
      participantId,
      CadenceParticipantsCompanion(
        feedbackText: Value(feedbackText),
        feedbackGivenAt: Value(DateTime.now()),
        feedbackUpdatedAt: Value(DateTime.now()),
        isPendingSync: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================
  // History Operations
  // ==========================================

  /// Get participant history for a user.
  Future<List<CadenceParticipant>> getParticipantHistory(
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

  /// Get meetings pending sync.
  Future<List<CadenceMeeting>> getPendingSyncMeetings() {
    return (_db.select(_db.cadenceMeetings)
          ..where((t) => t.isPendingSync.equals(true)))
        .get();
  }

  /// Get participants pending sync.
  Future<List<CadenceParticipant>> getPendingSyncParticipants() {
    return (_db.select(_db.cadenceParticipants)
          ..where((t) => t.isPendingSync.equals(true)))
        .get();
  }

  /// Mark meeting as synced.
  Future<int> markMeetingAsSynced(String meetingId, DateTime syncedAt) {
    return updateMeeting(
      meetingId,
      CadenceMeetingsCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
      ),
    );
  }

  /// Mark participant as synced.
  Future<int> markParticipantAsSynced(String participantId, DateTime syncedAt) {
    return updateParticipant(
      participantId,
      CadenceParticipantsCompanion(
        isPendingSync: const Value(false),
        lastSyncAt: Value(syncedAt),
        updatedAt: Value(syncedAt),
      ),
    );
  }

  /// Upsert meeting from remote.
  /// Skips if local copy has isPendingSync=true (pending local changes).
  Future<int> upsertMeeting(CadenceMeetingsCompanion data) async {
    // Check if local record has pending changes
    final id = data.id.value;
    final hasPending = await (_db.select(_db.cadenceMeetings)
          ..where((m) => m.id.equals(id) & m.isPendingSync.equals(true)))
        .getSingleOrNull();
    if (hasPending != null) {
      AppLogger.instance.debug(
        'sync.pull | Skipped cadence meeting $id with pending local changes',
      );
      return 0;
    }
    return _db.into(_db.cadenceMeetings).insertOnConflictUpdate(data);
  }

  /// Upsert participant from remote.
  /// Skips if local copy has isPendingSync=true (pending local changes).
  Future<int> upsertParticipant(CadenceParticipantsCompanion data) async {
    // Check if local record has pending changes
    final id = data.id.value;
    final hasPending = await (_db.select(_db.cadenceParticipants)
          ..where((p) => p.id.equals(id) & p.isPendingSync.equals(true)))
        .getSingleOrNull();
    if (hasPending != null) {
      AppLogger.instance.debug(
        'sync.pull | Skipped cadence participant $id with pending local changes',
      );
      return 0;
    }
    return _db.into(_db.cadenceParticipants).insertOnConflictUpdate(data);
  }

  // ==========================================
  // User Hierarchy Operations
  // ==========================================

  /// Get IDs of direct subordinates (users whose parent_id = this user).
  Future<List<String>> getDirectSubordinateIds(String userId) async {
    final result = await (_db.select(_db.users)
          ..where((u) => u.parentId.equals(userId))
          ..where((u) => u.isActive.equals(true)))
        .get();
    return result.map((u) => u.id).toList();
  }

  /// Get user by ID.
  Future<User?> getUserById(String userId) async {
    return (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Get multiple users by IDs (for batch lookup).
  Future<Map<String, User>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final result = await (_db.select(_db.users)
          ..where((u) => u.id.isIn(userIds)))
        .get();
    return {for (final user in result) user.id: user};
  }
}
