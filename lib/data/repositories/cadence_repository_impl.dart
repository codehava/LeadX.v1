import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/logging/app_logger.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/cadence.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/cadence_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/cadence_local_data_source.dart';
import '../datasources/remote/cadence_remote_data_source.dart';
import '../dtos/cadence_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of CadenceRepository with offline-first pattern.
class CadenceRepositoryImpl implements CadenceRepository {
  CadenceRepositoryImpl({
    required CadenceLocalDataSource localDataSource,
    required CadenceRemoteDataSource remoteDataSource,
    required SyncService syncService,
    required String currentUserId,
    required String currentUserRole,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId,
        _currentUserRole = currentUserRole;

  final CadenceLocalDataSource _localDataSource;
  final CadenceRemoteDataSource _remoteDataSource;
  final SyncService _syncService;
  final String _currentUserId;
  final String _currentUserRole;
  final _uuid = const Uuid();
  final _log = AppLogger.instance;

  // ==========================================
  // Score Constants
  // ==========================================

  static const int _scorePresent = 3;
  static const int _scoreLate = 1;
  static const int _scoreExcused = 0;
  static const int _scoreAbsent = -5;

  static const int _scoreFormOnTime = 2;
  static const int _scoreFormLate = 0;
  static const int _scoreFormVeryLate = -1;
  static const int _scoreFormNotSubmitted = -3;

  // ==========================================
  // Schedule Config Operations
  // ==========================================

  @override
  Future<List<domain.CadenceScheduleConfig>> getActiveConfigs() async {
    final data = await _localDataSource.getActiveConfigs();
    return data.map(_mapToScheduleConfig).toList();
  }

  @override
  Future<domain.CadenceScheduleConfig?> getConfigForRole(String role) async {
    final data = await _localDataSource.getConfigByTargetRole(role);
    return data != null ? _mapToScheduleConfig(data) : null;
  }

  @override
  Future<domain.CadenceScheduleConfig?> getMyFacilitatorConfig() async {
    final data = await _localDataSource.getConfigByFacilitatorRole(_currentUserRole);
    return data != null ? _mapToScheduleConfig(data) : null;
  }

  // ==========================================
  // Admin: Schedule Config Management (Admin Only)
  // ==========================================

  @override
  Stream<List<domain.CadenceScheduleConfig>> watchAllConfigs() {
    return _localDataSource.watchAllConfigs().map((list) {
      return list.map(_mapToScheduleConfig).toList();
    });
  }

  @override
  Stream<List<domain.CadenceScheduleConfig>> watchActiveConfigs() {
    return _localDataSource.watchActiveConfigs().map((list) {
      return list.map(_mapToScheduleConfig).toList();
    });
  }

  @override
  Stream<domain.CadenceScheduleConfig?> watchMyFacilitatorConfig() {
    return _localDataSource
        .watchConfigByFacilitatorRole(_currentUserRole)
        .map((data) => data != null ? _mapToScheduleConfig(data) : null);
  }

  @override
  Future<domain.CadenceScheduleConfig?> getConfigById(String configId) async {
    final data = await _localDataSource.getConfigById(configId);
    return data != null ? _mapToScheduleConfig(data) : null;
  }

  @override
  Stream<domain.CadenceScheduleConfig?> watchConfigById(String configId) {
    return _localDataSource
        .watchConfigById(configId)
        .map((data) => data != null ? _mapToScheduleConfig(data) : null);
  }

  @override
  Future<Either<Failure, domain.CadenceScheduleConfig>> createConfig({
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
  }) async {
    try {
      final configId = _uuid.v4();
      final now = DateTime.now();

      await _localDataSource.insertConfig(
        db.CadenceScheduleConfigCompanion.insert(
          id: configId,
          name: name,
          description: Value(description),
          targetRole: targetRole,
          facilitatorRole: facilitatorRole,
          frequency: frequency,
          dayOfWeek: Value(dayOfWeek),
          dayOfMonth: Value(dayOfMonth),
          defaultTime: Value(defaultTime),
          durationMinutes: Value(durationMinutes),
          preMeetingHours: Value(preMeetingHours),
          isActive: Value(isActive),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final config = await _localDataSource.getConfigById(configId);
      if (config == null) {
        return Left(DatabaseFailure(message: 'Failed to create config'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceConfig,
        entityId: configId,
        operation: SyncOperation.create,
        payload: {
          'id': configId,
          'name': name,
          'description': description,
          'target_role': targetRole,
          'facilitator_role': facilitatorRole,
          'frequency': frequency,
          'day_of_week': dayOfWeek,
          'day_of_month': dayOfMonth,
          'default_time': defaultTime,
          'duration_minutes': durationMinutes,
          'pre_meeting_hours': preMeetingHours,
          'is_active': isActive,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      unawaited(_syncService.triggerSync());

      return Right(_mapToScheduleConfig(config));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to create cadence config: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.CadenceScheduleConfig>> updateConfig({
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
  }) async {
    try {
      final now = DateTime.now();

      await _localDataSource.updateConfig(
        configId,
        db.CadenceScheduleConfigCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          description: description != null ? Value(description) : const Value.absent(),
          targetRole: targetRole != null ? Value(targetRole) : const Value.absent(),
          facilitatorRole: facilitatorRole != null ? Value(facilitatorRole) : const Value.absent(),
          frequency: frequency != null ? Value(frequency) : const Value.absent(),
          dayOfWeek: dayOfWeek != null ? Value(dayOfWeek) : const Value.absent(),
          dayOfMonth: dayOfMonth != null ? Value(dayOfMonth) : const Value.absent(),
          defaultTime: defaultTime != null ? Value(defaultTime) : const Value.absent(),
          durationMinutes: durationMinutes != null ? Value(durationMinutes) : const Value.absent(),
          preMeetingHours: preMeetingHours != null ? Value(preMeetingHours) : const Value.absent(),
          isActive: isActive != null ? Value(isActive) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );

      final config = await _localDataSource.getConfigById(configId);
      if (config == null) {
        return Left(DatabaseFailure(message: 'Config not found after update'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceConfig,
        entityId: configId,
        operation: SyncOperation.update,
        payload: {
          'id': configId,
          'name': config.name,
          'description': config.description,
          'target_role': config.targetRole,
          'facilitator_role': config.facilitatorRole,
          'frequency': config.frequency,
          'day_of_week': config.dayOfWeek,
          'day_of_month': config.dayOfMonth,
          'default_time': config.defaultTime,
          'duration_minutes': config.durationMinutes,
          'pre_meeting_hours': config.preMeetingHours,
          'is_active': config.isActive,
          'updated_at': now.toIso8601String(),
        },
      );

      unawaited(_syncService.triggerSync());

      return Right(_mapToScheduleConfig(config));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update cadence config: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.CadenceScheduleConfig>> toggleConfigActive(
    String configId,
    bool isActive,
  ) async {
    return updateConfig(configId: configId, isActive: isActive);
  }

  @override
  Future<Either<Failure, Unit>> deleteConfig(String configId) async {
    try {
      await _localDataSource.softDeleteConfig(configId);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceConfig,
        entityId: configId,
        operation: SyncOperation.update,
        payload: {
          'id': configId,
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      unawaited(_syncService.triggerSync());

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete cadence config: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Meeting Operations (Streams)
  // ==========================================

  @override
  Stream<List<domain.CadenceMeeting>> watchUpcomingMeetings() {
    return _localDataSource
        .watchUpcomingMeetingsForUser(_currentUserId)
        .asyncMap((list) async {
      return Future.wait(list.map(_mapToMeetingWithStats));
    });
  }

  @override
  Stream<List<domain.CadenceMeeting>> watchPastMeetings({int? limit}) {
    return _localDataSource
        .watchPastMeetingsForUser(_currentUserId, limit: limit)
        .asyncMap((list) async {
      return Future.wait(list.map(_mapToMeetingWithStats));
    });
  }

  @override
  Stream<List<domain.CadenceMeeting>> watchHostedMeetings() {
    return _localDataSource
        .watchHostedMeetings(_currentUserId)
        .asyncMap((list) async {
      return Future.wait(list.map(_mapToMeetingWithStats));
    });
  }

  @override
  Stream<domain.CadenceMeeting?> watchMeeting(String meetingId) {
    return _localDataSource.watchMeeting(meetingId).asyncMap((data) async {
      if (data == null) return null;
      return _mapToMeetingWithStats(data);
    });
  }

  @override
  Stream<List<domain.CadenceParticipant>> watchMeetingParticipants(
    String meetingId,
  ) {
    return _localDataSource.watchMeetingParticipants(meetingId).asyncMap((list) {
      return _mapParticipantsWithUserInfo(list);
    });
  }

  @override
  Stream<domain.CadenceParticipant?> watchMyParticipation(String meetingId) {
    return _localDataSource
        .watchParticipation(meetingId, _currentUserId)
        .map((data) => data != null ? _mapToParticipant(data) : null);
  }

  // ==========================================
  // Meeting Operations (Actions)
  // ==========================================

  @override
  Future<Either<Failure, domain.CadenceMeeting>> startMeeting(
    String meetingId,
  ) async {
    try {
      await _localDataSource.startMeeting(meetingId);

      final meeting = await _localDataSource.getMeetingById(meetingId);
      if (meeting == null) {
        return Left(DatabaseFailure(message: 'Meeting not found'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceMeeting,
        entityId: meetingId,
        operation: SyncOperation.update,
        payload: _createMeetingSyncPayload(meeting),
      );

      unawaited(_syncService.triggerSync());

      return Right(await _mapToMeetingWithStats(meeting));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to start meeting: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.CadenceMeeting>> endMeeting(
    String meetingId,
  ) async {
    try {
      // Calculate scores for participants without attendance marked
      final participants = await _localDataSource.getMeetingParticipants(meetingId);
      for (final p in participants) {
        if (p.attendanceStatus == 'PENDING') {
          // Mark as absent if not marked
          await _localDataSource.markAttendance(
            p.id,
            status: 'ABSENT',
            scoreImpact: _scoreAbsent,
            markedBy: _currentUserId,
          );
        }

        // Calculate form score if not submitted
        if (!p.preMeetingSubmitted && p.formSubmissionStatus == null) {
          await _localDataSource.updateParticipant(
            p.id,
            db.CadenceParticipantsCompanion(
              formSubmissionStatus: const Value('NOT_SUBMITTED'),
              formScoreImpact: const Value(_scoreFormNotSubmitted),
              isPendingSync: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }

        // Queue participant for sync
        final updatedParticipant = await _localDataSource.getParticipant(p.id);
        if (updatedParticipant != null) {
          await _syncService.queueOperation(
            entityType: SyncEntityType.cadenceParticipant,
            entityId: p.id,
            operation: SyncOperation.update,
            payload: _createParticipantSyncPayload(updatedParticipant),
          );
        }
      }

      await _localDataSource.endMeeting(meetingId);

      final meeting = await _localDataSource.getMeetingById(meetingId);
      if (meeting == null) {
        return Left(DatabaseFailure(message: 'Meeting not found'));
      }

      // Queue meeting for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceMeeting,
        entityId: meetingId,
        operation: SyncOperation.update,
        payload: _createMeetingSyncPayload(meeting),
      );

      unawaited(_syncService.triggerSync());

      return Right(await _mapToMeetingWithStats(meeting));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to end meeting: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.CadenceMeeting>> cancelMeeting(
    String meetingId,
    String reason,
  ) async {
    try {
      await _localDataSource.updateMeeting(
        meetingId,
        db.CadenceMeetingsCompanion(
          status: const Value('CANCELLED'),
          notes: Value(reason),
          isPendingSync: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final meeting = await _localDataSource.getMeetingById(meetingId);
      if (meeting == null) {
        return Left(DatabaseFailure(message: 'Meeting not found'));
      }

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceMeeting,
        entityId: meetingId,
        operation: SyncOperation.update,
        payload: _createMeetingSyncPayload(meeting),
      );

      unawaited(_syncService.triggerSync());

      return Right(await _mapToMeetingWithStats(meeting));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to cancel meeting: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMeetingNotes(
    String meetingId,
    String notes,
  ) async {
    try {
      await _localDataSource.updateMeeting(
        meetingId,
        db.CadenceMeetingsCompanion(
          notes: Value(notes),
          isPendingSync: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final meeting = await _localDataSource.getMeetingById(meetingId);
      if (meeting != null) {
        await _syncService.queueOperation(
          entityType: SyncEntityType.cadenceMeeting,
          entityId: meetingId,
          operation: SyncOperation.update,
          payload: _createMeetingSyncPayload(meeting),
        );
      }

      unawaited(_syncService.triggerSync());
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update meeting notes: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMeetingAgenda(
    String meetingId,
    String agenda,
  ) async {
    try {
      await _localDataSource.updateMeeting(
        meetingId,
        db.CadenceMeetingsCompanion(
          agenda: Value(agenda),
          isPendingSync: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final meeting = await _localDataSource.getMeetingById(meetingId);
      if (meeting != null) {
        await _syncService.queueOperation(
          entityType: SyncEntityType.cadenceMeeting,
          entityId: meetingId,
          operation: SyncOperation.update,
          payload: _createMeetingSyncPayload(meeting),
        );
      }

      unawaited(_syncService.triggerSync());
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update meeting agenda: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Participant Form Operations
  // ==========================================

  @override
  Future<Either<Failure, domain.CadenceParticipant>> submitPreMeetingForm(
    domain.CadenceFormSubmission submission,
  ) async {
    try {
      final participant = await _localDataSource.getParticipant(submission.participantId);
      if (participant == null) {
        return Left(DatabaseFailure(message: 'Participant not found'));
      }

      // Get meeting to calculate submission status
      final meeting = await _localDataSource.getMeetingById(participant.meetingId);
      if (meeting == null) {
        return Left(DatabaseFailure(message: 'Meeting not found'));
      }

      // Get config for deadline calculation
      final config = await _localDataSource.getConfigById(meeting.configId);
      final preMeetingHours = config?.preMeetingHours ?? 24;

      // Calculate submission status and score
      final deadline = meeting.scheduledAt.subtract(Duration(hours: preMeetingHours));
      final now = DateTime.now();
      String submissionStatus;
      int scoreImpact;

      if (now.isBefore(deadline)) {
        submissionStatus = 'ON_TIME';
        scoreImpact = _scoreFormOnTime;
      } else if (now.isBefore(deadline.add(const Duration(hours: 2)))) {
        submissionStatus = 'LATE';
        scoreImpact = _scoreFormLate;
      } else {
        submissionStatus = 'VERY_LATE';
        scoreImpact = _scoreFormVeryLate;
      }

      await _localDataSource.submitForm(
        submission.participantId,
        q1CompletionStatus: submission.q1CompletionStatus?.name.toUpperCase(),
        q2WhatAchieved: submission.q2WhatAchieved,
        q3Obstacles: submission.q3Obstacles,
        q4NextCommitment: submission.q4NextCommitment,
        formSubmissionStatus: submissionStatus,
        formScoreImpact: scoreImpact,
      );

      final updated = await _localDataSource.getParticipant(submission.participantId);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceParticipant,
        entityId: submission.participantId,
        operation: SyncOperation.update,
        payload: _createParticipantSyncPayload(updated!),
      );

      unawaited(_syncService.triggerSync());

      return Right(_mapToParticipant(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to submit form: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.CadenceParticipant>> saveFormDraft(
    domain.CadenceFormSubmission submission,
  ) async {
    try {
      await _localDataSource.updateParticipant(
        submission.participantId,
        db.CadenceParticipantsCompanion(
          q1CompletionStatus: Value(submission.q1CompletionStatus?.name.toUpperCase()),
          q2WhatAchieved: Value(submission.q2WhatAchieved),
          q3Obstacles: Value(submission.q3Obstacles),
          q4NextCommitment: Value(submission.q4NextCommitment),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updated = await _localDataSource.getParticipant(submission.participantId);
      return Right(_mapToParticipant(updated!));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to save draft: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<String?> getPreviousCommitment(
    String userId,
    String facilitatorId,
  ) async {
    return _localDataSource.getPreviousCommitment(userId, facilitatorId);
  }

  // ==========================================
  // Attendance Operations (Host Only)
  // ==========================================

  @override
  Future<Either<Failure, domain.CadenceParticipant>> markAttendance({
    required String participantId,
    required domain.AttendanceStatus status,
    String? excusedReason,
  }) async {
    try {
      final scoreImpact = _getAttendanceScore(status);

      await _localDataSource.markAttendance(
        participantId,
        status: status.name.toUpperCase(),
        scoreImpact: scoreImpact,
        excusedReason: excusedReason,
        markedBy: _currentUserId,
      );

      final updated = await _localDataSource.getParticipant(participantId);

      // Queue for sync
      await _syncService.queueOperation(
        entityType: SyncEntityType.cadenceParticipant,
        entityId: participantId,
        operation: SyncOperation.update,
        payload: _createParticipantSyncPayload(updated!),
      );

      unawaited(_syncService.triggerSync());

      return Right(_mapToParticipant(updated));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to mark attendance: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, List<domain.CadenceParticipant>>> batchMarkAttendance({
    required String meetingId,
    required Map<String, domain.AttendanceStatus> attendanceMap,
  }) async {
    try {
      final results = <domain.CadenceParticipant>[];

      for (final entry in attendanceMap.entries) {
        final result = await markAttendance(
          participantId: entry.key,
          status: entry.value,
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (participant) => results.add(participant),
        );
      }

      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to batch mark attendance: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Feedback Operations (Host Only)
  // ==========================================

  @override
  Future<Either<Failure, Unit>> saveHostNotes({
    required String participantId,
    required String notes,
  }) async {
    try {
      await _localDataSource.saveHostNotes(participantId, notes);

      final updated = await _localDataSource.getParticipant(participantId);
      if (updated != null) {
        await _syncService.queueOperation(
          entityType: SyncEntityType.cadenceParticipant,
          entityId: participantId,
          operation: SyncOperation.update,
          payload: _createParticipantSyncPayload(updated),
        );
      }

      unawaited(_syncService.triggerSync());
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to save host notes: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveFeedback({
    required String participantId,
    required String feedbackText,
  }) async {
    try {
      await _localDataSource.saveFeedback(participantId, feedbackText);

      final updated = await _localDataSource.getParticipant(participantId);
      if (updated != null) {
        await _syncService.queueOperation(
          entityType: SyncEntityType.cadenceParticipant,
          entityId: participantId,
          operation: SyncOperation.update,
          payload: _createParticipantSyncPayload(updated),
        );
      }

      unawaited(_syncService.triggerSync());
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to save feedback: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // History & Reporting
  // ==========================================

  @override
  Future<List<domain.CadenceParticipant>> getParticipantHistory({
    required String userId,
    int? limit,
  }) async {
    final data = await _localDataSource.getParticipantHistory(userId, limit: limit);
    return data.map(_mapToParticipant).toList();
  }

  @override
  Future<domain.CadenceMeetingWithParticipants?> getMeetingWithParticipants(
    String meetingId,
  ) async {
    final meeting = await _localDataSource.getMeetingById(meetingId);
    if (meeting == null) return null;

    final participants = await _localDataSource.getMeetingParticipants(meetingId);
    final config = await _localDataSource.getConfigById(meeting.configId);

    return domain.CadenceMeetingWithParticipants(
      meeting: await _mapToMeetingWithStats(meeting),
      participants: await _mapParticipantsWithUserInfo(participants),
      config: config != null ? _mapToScheduleConfig(config) : null,
    );
  }

  @override
  Stream<domain.CadenceMeetingWithParticipants?> watchMeetingWithParticipants(
    String meetingId,
  ) {
    // Combine meeting stream with participants stream
    return _localDataSource.watchMeeting(meetingId).asyncMap((meeting) async {
      if (meeting == null) return null;

      final participants = await _localDataSource.getMeetingParticipants(meetingId);
      final config = await _localDataSource.getConfigById(meeting.configId);

      return domain.CadenceMeetingWithParticipants(
        meeting: await _mapToMeetingWithStats(meeting),
        participants: await _mapParticipantsWithUserInfo(participants),
        config: config != null ? _mapToScheduleConfig(config) : null,
      );
    });
  }

  // ==========================================
  // Meeting Generation (Host)
  // ==========================================

  @override
  Future<Either<Failure, List<domain.CadenceMeeting>>> ensureUpcomingMeetings({
    int weeksAhead = 4,
  }) async {
    try {
      final config = await _localDataSource.getConfigByFacilitatorRole(_currentUserRole);
      if (config == null) {
        return const Right([]); // No config for this role
      }

      final meetings = <domain.CadenceMeeting>[];
      final now = DateTime.now();

      for (int week = 0; week < weeksAhead; week++) {
        final targetDate = _calculateNextMeetingDate(
          config.frequency,
          config.dayOfWeek,
          config.dayOfMonth,
          config.defaultTime,
          now.add(Duration(days: week * 7)),
        );

        if (targetDate == null) continue;

        // Check if meeting already exists
        final exists = await _localDataSource.meetingExistsForHostOnDate(
          _currentUserId,
          targetDate,
        );

        if (!exists) {
          final meeting = await _createMeetingWithParticipants(config, targetDate);
          meetings.add(meeting);
        }
      }

      return Right(meetings);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to ensure upcoming meetings: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<List<String>> getTeamMemberIds() async {
    return _localDataSource.getDirectSubordinateIds(_currentUserId);
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  @override
  Future<void> syncFromRemote({DateTime? since}) async {
    try {
      _log.debug('cadence | Starting sync for user: $_currentUserId');

      if (_currentUserId.isEmpty) {
        _log.debug('cadence | WARNING: currentUserId is empty, skipping sync');
        return;
      }

      // Fetch configs
      final configs = await _remoteDataSource.fetchActiveConfigs();
      for (final dto in configs) {
        await _localDataSource.upsertConfig(_dtoToConfigCompanion(dto));
      }
      _log.debug('cadence | Synced ${configs.length} configs');

      // Fetch cadences where user is a participant
      final participantCadences = since != null
          ? await _remoteDataSource.fetchMeetingsUpdatedSince(since)
          : await _remoteDataSource.fetchMeetingsForUser(_currentUserId);
      _log.debug('cadence | Fetched ${participantCadences.length} participant cadences');

      // Fetch cadences where user is the facilitator/host
      final hostedCadences =
          await _remoteDataSource.fetchHostedMeetings(_currentUserId);
      _log.debug('cadence | Fetched ${hostedCadences.length} hosted cadences');

      // Merge both lists, avoiding duplicates by ID
      final allCadenceIds = <String>{};
      final allCadences = <CadenceMeetingDto>[];
      for (final cadence in [...participantCadences, ...hostedCadences]) {
        if (allCadenceIds.add(cadence.id)) {
          allCadences.add(cadence);
        }
      }

      // Upsert all cadences to local database
      for (final dto in allCadences) {
        await _localDataSource.upsertMeeting(_dtoToMeetingCompanion(dto));
      }

      // Fetch participants - for initial sync, fetch user's participant records
      final participants = since != null
          ? await _remoteDataSource.fetchParticipantsUpdatedSince(since)
          : await _remoteDataSource.fetchParticipantsForUser(_currentUserId);
      _log.debug('cadence | Fetched ${participants.length} participant records for user');

      for (final dto in participants) {
        await _localDataSource.upsertParticipant(_dtoToParticipantCompanion(dto));
      }

      // For hosted cadences, also fetch their participants
      // (so host can see all participant names/statuses)
      final hostedCadenceIds = hostedCadences.map((c) => c.id).toSet();
      for (final cadenceId in hostedCadenceIds) {
        final cadenceParticipants =
            await _remoteDataSource.fetchMeetingParticipants(cadenceId);
        for (final dto in cadenceParticipants) {
          await _localDataSource
              .upsertParticipant(_dtoToParticipantCompanion(dto));
        }
      }
      _log.debug('cadence | Sync complete. Total cadences: ${allCadences.length}');
    } catch (e) {
      _log.error('cadence | Sync error: $e');
      rethrow;
    }
  }

  @override
  Future<List<domain.CadenceMeeting>> getPendingSyncMeetings() async {
    final data = await _localDataSource.getPendingSyncMeetings();
    return Future.wait(data.map(_mapToMeetingWithStats));
  }

  @override
  Future<List<domain.CadenceParticipant>> getPendingSyncParticipants() async {
    final data = await _localDataSource.getPendingSyncParticipants();
    return data.map(_mapToParticipant).toList();
  }

  @override
  Future<void> markMeetingAsSynced(String id, DateTime syncedAt) {
    return _localDataSource.markMeetingAsSynced(id, syncedAt);
  }

  @override
  Future<void> markParticipantAsSynced(String id, DateTime syncedAt) {
    return _localDataSource.markParticipantAsSynced(id, syncedAt);
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  int _getAttendanceScore(domain.AttendanceStatus status) {
    switch (status) {
      case domain.AttendanceStatus.present:
        return _scorePresent;
      case domain.AttendanceStatus.late:
        return _scoreLate;
      case domain.AttendanceStatus.excused:
        return _scoreExcused;
      case domain.AttendanceStatus.absent:
        return _scoreAbsent;
      case domain.AttendanceStatus.pending:
        return 0;
    }
  }

  DateTime? _calculateNextMeetingDate(
    String frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    String? defaultTime,
    DateTime from,
  ) {
    // Parse time
    int hour = 9;
    int minute = 0;
    if (defaultTime != null && defaultTime.contains(':')) {
      final parts = defaultTime.split(':');
      hour = int.tryParse(parts[0]) ?? 9;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    switch (frequency) {
      case 'WEEKLY':
        if (dayOfWeek == null) return null;
        var date = from;
        while (date.weekday != dayOfWeek) {
          date = date.add(const Duration(days: 1));
        }
        return DateTime(date.year, date.month, date.day, hour, minute);

      case 'MONTHLY':
        final targetDay = dayOfMonth ?? 1;
        var date = DateTime(from.year, from.month, targetDay, hour, minute);
        if (date.isBefore(from)) {
          date = DateTime(from.year, from.month + 1, targetDay, hour, minute);
        }
        return date;

      case 'DAILY':
        return DateTime(from.year, from.month, from.day, hour, minute);

      default:
        return null;
    }
  }

  Future<domain.CadenceMeeting> _createMeetingWithParticipants(
    db.CadenceScheduleConfigData config,
    DateTime scheduledAt,
  ) async {
    final meetingId = _uuid.v4();
    final now = DateTime.now();

    // Create meeting
    await _localDataSource.insertMeeting(db.CadenceMeetingsCompanion.insert(
      id: meetingId,
      configId: config.id,
      title: '${config.name} - ${_formatDate(scheduledAt)}',
      scheduledAt: scheduledAt,
      durationMinutes: config.durationMinutes,
      facilitatorId: _currentUserId,
      status: const Value('SCHEDULED'),
      createdBy: _currentUserId,
      isPendingSync: const Value(true),
      createdAt: now,
      updatedAt: now,
    ));

    // Queue meeting for sync
    final meeting = await _localDataSource.getMeetingById(meetingId);
    await _syncService.queueOperation(
      entityType: SyncEntityType.cadenceMeeting,
      entityId: meetingId,
      operation: SyncOperation.create,
      payload: _createMeetingSyncPayload(meeting!),
    );

    // Get team members and create participants
    final teamMemberIds = await getTeamMemberIds();
    for (final userId in teamMemberIds) {
      final participantId = _uuid.v4();
      final previousCommitment = await _localDataSource.getPreviousCommitment(
        userId,
        _currentUserId,
      );

      await _localDataSource.insertParticipant(db.CadenceParticipantsCompanion.insert(
        id: participantId,
        meetingId: meetingId,
        userId: userId,
        q1PreviousCommitment: Value(previousCommitment),
        isPendingSync: const Value(true),
        createdAt: now,
        updatedAt: now,
      ));

      // Queue participant for sync
      final participant = await _localDataSource.getParticipant(participantId);
      if (participant != null) {
        await _syncService.queueOperation(
          entityType: SyncEntityType.cadenceParticipant,
          entityId: participantId,
          operation: SyncOperation.create,
          payload: _createParticipantSyncPayload(participant),
        );
      }
    }

    unawaited(_syncService.triggerSync());

    return _mapToMeetingWithStats(meeting);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==========================================
  // Mapping Functions
  // ==========================================

  domain.CadenceScheduleConfig _mapToScheduleConfig(
    db.CadenceScheduleConfigData data,
  ) {
    return domain.CadenceScheduleConfig(
      id: data.id,
      name: data.name,
      description: data.description,
      targetRole: data.targetRole,
      facilitatorRole: data.facilitatorRole,
      frequency: _parseFrequency(data.frequency),
      dayOfWeek: data.dayOfWeek,
      dayOfMonth: data.dayOfMonth,
      defaultTime: data.defaultTime,
      durationMinutes: data.durationMinutes,
      preMeetingHours: data.preMeetingHours,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  Future<domain.CadenceMeeting> _mapToMeetingWithStats(db.CadenceMeeting data) async {
    final participants = await _localDataSource.getMeetingParticipants(data.id);
    final config = await _localDataSource.getConfigById(data.configId);

    return domain.CadenceMeeting(
      id: data.id,
      configId: data.configId,
      title: data.title,
      scheduledAt: data.scheduledAt,
      durationMinutes: data.durationMinutes,
      facilitatorId: data.facilitatorId,
      status: _parseMeetingStatus(data.status),
      location: data.location,
      meetingLink: data.meetingLink,
      agenda: data.agenda,
      notes: data.notes,
      startedAt: data.startedAt,
      completedAt: data.completedAt,
      createdBy: data.createdBy,
      isPendingSync: data.isPendingSync,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      // Stats
      totalParticipants: participants.length,
      submittedFormCount: participants.where((p) => p.preMeetingSubmitted).length,
      presentCount: participants.where((p) =>
          p.attendanceStatus == 'PRESENT' || p.attendanceStatus == 'LATE').length,
      configName: config?.name,
      preMeetingHours: config?.preMeetingHours,
    );
  }

  domain.CadenceParticipant _mapToParticipant(
    db.CadenceParticipant data, {
    String? userName,
    String? userRole,
  }) {
    return domain.CadenceParticipant(
      id: data.id,
      meetingId: data.meetingId,
      userId: data.userId,
      userName: userName,
      userRole: userRole,
      attendanceStatus: _parseAttendanceStatus(data.attendanceStatus),
      arrivedAt: data.arrivedAt,
      excusedReason: data.excusedReason,
      attendanceScoreImpact: data.attendanceScoreImpact,
      markedBy: data.markedBy,
      markedAt: data.markedAt,
      preMeetingSubmitted: data.preMeetingSubmitted,
      q1PreviousCommitment: data.q1PreviousCommitment,
      q1CompletionStatus: _parseCompletionStatus(data.q1CompletionStatus),
      q2WhatAchieved: data.q2WhatAchieved,
      q3Obstacles: data.q3Obstacles,
      q4NextCommitment: data.q4NextCommitment,
      formSubmittedAt: data.formSubmittedAt,
      formSubmissionStatus: _parseFormSubmissionStatus(data.formSubmissionStatus),
      formScoreImpact: data.formScoreImpact,
      hostNotes: data.hostNotes,
      feedbackText: data.feedbackText,
      feedbackGivenAt: data.feedbackGivenAt,
      feedbackUpdatedAt: data.feedbackUpdatedAt,
      isPendingSync: data.isPendingSync,
      lastSyncAt: data.lastSyncAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Map participants with user info (batch lookup for efficiency).
  Future<List<domain.CadenceParticipant>> _mapParticipantsWithUserInfo(
    List<db.CadenceParticipant> participants,
  ) async {
    if (participants.isEmpty) return [];

    // Batch lookup users
    final userIds = participants.map((p) => p.userId).toList();
    final usersMap = await _localDataSource.getUsersByIds(userIds);

    return participants.map((p) {
      final user = usersMap[p.userId];
      return _mapToParticipant(
        p,
        userName: user?.name,
        userRole: user?.role,
      );
    }).toList();
  }

  // ==========================================
  // Parsing Functions
  // ==========================================

  domain.MeetingFrequency _parseFrequency(String value) {
    switch (value.toUpperCase()) {
      case 'DAILY':
        return domain.MeetingFrequency.daily;
      case 'WEEKLY':
        return domain.MeetingFrequency.weekly;
      case 'MONTHLY':
        return domain.MeetingFrequency.monthly;
      case 'QUARTERLY':
        return domain.MeetingFrequency.quarterly;
      default:
        return domain.MeetingFrequency.weekly;
    }
  }

  domain.MeetingStatus _parseMeetingStatus(String value) {
    switch (value.toUpperCase()) {
      case 'SCHEDULED':
        return domain.MeetingStatus.scheduled;
      case 'IN_PROGRESS':
        return domain.MeetingStatus.inProgress;
      case 'COMPLETED':
        return domain.MeetingStatus.completed;
      case 'CANCELLED':
        return domain.MeetingStatus.cancelled;
      default:
        return domain.MeetingStatus.scheduled;
    }
  }

  domain.AttendanceStatus _parseAttendanceStatus(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return domain.AttendanceStatus.pending;
      case 'PRESENT':
        return domain.AttendanceStatus.present;
      case 'LATE':
        return domain.AttendanceStatus.late;
      case 'EXCUSED':
        return domain.AttendanceStatus.excused;
      case 'ABSENT':
        return domain.AttendanceStatus.absent;
      default:
        return domain.AttendanceStatus.pending;
    }
  }

  domain.FormSubmissionStatus? _parseFormSubmissionStatus(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'ON_TIME':
        return domain.FormSubmissionStatus.onTime;
      case 'LATE':
        return domain.FormSubmissionStatus.late;
      case 'VERY_LATE':
        return domain.FormSubmissionStatus.veryLate;
      case 'NOT_SUBMITTED':
        return domain.FormSubmissionStatus.notSubmitted;
      default:
        return null;
    }
  }

  domain.CommitmentCompletionStatus? _parseCompletionStatus(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'COMPLETED':
        return domain.CommitmentCompletionStatus.completed;
      case 'PARTIAL':
        return domain.CommitmentCompletionStatus.partial;
      case 'NOT_DONE':
        return domain.CommitmentCompletionStatus.notDone;
      default:
        return null;
    }
  }

  // ==========================================
  // Sync Payload Builders
  // ==========================================

  Map<String, dynamic> _createMeetingSyncPayload(db.CadenceMeeting meeting) {
    return {
      'id': meeting.id,
      'config_id': meeting.configId,
      'title': meeting.title,
      'scheduled_at': meeting.scheduledAt.toIso8601String(),
      'duration_minutes': meeting.durationMinutes,
      'facilitator_id': meeting.facilitatorId,
      'status': meeting.status,
      'location': meeting.location,
      'meeting_link': meeting.meetingLink,
      'agenda': meeting.agenda,
      'notes': meeting.notes,
      'started_at': meeting.startedAt?.toIso8601String(),
      'completed_at': meeting.completedAt?.toIso8601String(),
      'created_by': meeting.createdBy,
      'created_at': meeting.createdAt.toIso8601String(),
      'updated_at': meeting.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _createParticipantSyncPayload(db.CadenceParticipant p) {
    return {
      'id': p.id,
      'meeting_id': p.meetingId,
      'user_id': p.userId,
      'attendance_status': p.attendanceStatus,
      'arrived_at': p.arrivedAt?.toIso8601String(),
      'excused_reason': p.excusedReason,
      'attendance_score_impact': p.attendanceScoreImpact,
      'marked_by': p.markedBy,
      'marked_at': p.markedAt?.toIso8601String(),
      'pre_meeting_submitted': p.preMeetingSubmitted,
      'q1_previous_commitment': p.q1PreviousCommitment,
      'q1_completion_status': p.q1CompletionStatus,
      'q2_what_achieved': p.q2WhatAchieved,
      'q3_obstacles': p.q3Obstacles,
      'q4_next_commitment': p.q4NextCommitment,
      'form_submitted_at': p.formSubmittedAt?.toIso8601String(),
      'form_submission_status': p.formSubmissionStatus,
      'form_score_impact': p.formScoreImpact,
      'host_notes': p.hostNotes,
      'feedback_text': p.feedbackText,
      'feedback_given_at': p.feedbackGivenAt?.toIso8601String(),
      'feedback_updated_at': p.feedbackUpdatedAt?.toIso8601String(),
      'created_at': p.createdAt.toIso8601String(),
      'updated_at': p.updatedAt.toIso8601String(),
    };
  }

  // ==========================================
  // DTO to Companion Conversions
  // ==========================================

  db.CadenceScheduleConfigCompanion _dtoToConfigCompanion(
    CadenceScheduleConfigDto dto,
  ) {
    return db.CadenceScheduleConfigCompanion(
      id: Value(dto.id),
      name: Value(dto.name),
      description: Value(dto.description),
      targetRole: Value(dto.targetRole),
      facilitatorRole: Value(dto.facilitatorRole),
      frequency: Value(dto.frequency),
      dayOfWeek: Value(dto.dayOfWeek),
      dayOfMonth: Value(dto.dayOfMonth),
      defaultTime: Value(dto.defaultTime),
      durationMinutes: Value(dto.durationMinutes),
      preMeetingHours: Value(dto.preMeetingHours),
      isActive: Value(dto.isActive),
      createdAt: Value(dto.createdAt),
      updatedAt: Value(dto.updatedAt),
    );
  }

  db.CadenceMeetingsCompanion _dtoToMeetingCompanion(CadenceMeetingDto dto) {
    return db.CadenceMeetingsCompanion(
      id: Value(dto.id),
      configId: Value(dto.configId),
      title: Value(dto.title),
      scheduledAt: Value(dto.scheduledAt),
      durationMinutes: Value(dto.durationMinutes),
      facilitatorId: Value(dto.facilitatorId),
      status: Value(dto.status),
      location: Value(dto.location),
      meetingLink: Value(dto.meetingLink),
      agenda: Value(dto.agenda),
      notes: Value(dto.notes),
      startedAt: Value(dto.startedAt),
      completedAt: Value(dto.completedAt),
      createdBy: Value(dto.createdBy),
      isPendingSync: const Value(false),
      createdAt: Value(dto.createdAt),
      updatedAt: Value(dto.updatedAt),
    );
  }

  db.CadenceParticipantsCompanion _dtoToParticipantCompanion(
    CadenceParticipantDto dto,
  ) {
    return db.CadenceParticipantsCompanion(
      id: Value(dto.id),
      meetingId: Value(dto.meetingId),
      userId: Value(dto.userId),
      attendanceStatus: Value(dto.attendanceStatus),
      arrivedAt: Value(dto.arrivedAt),
      excusedReason: Value(dto.excusedReason),
      attendanceScoreImpact: Value(dto.attendanceScoreImpact),
      markedBy: Value(dto.markedBy),
      markedAt: Value(dto.markedAt),
      preMeetingSubmitted: Value(dto.preMeetingSubmitted),
      q1PreviousCommitment: Value(dto.q1PreviousCommitment),
      q1CompletionStatus: Value(dto.q1CompletionStatus),
      q2WhatAchieved: Value(dto.q2WhatAchieved),
      q3Obstacles: Value(dto.q3Obstacles),
      q4NextCommitment: Value(dto.q4NextCommitment),
      formSubmittedAt: Value(dto.formSubmittedAt),
      formSubmissionStatus: Value(dto.formSubmissionStatus),
      formScoreImpact: Value(dto.formScoreImpact),
      hostNotes: Value(dto.hostNotes),
      feedbackText: Value(dto.feedbackText),
      feedbackGivenAt: Value(dto.feedbackGivenAt),
      feedbackUpdatedAt: Value(dto.feedbackUpdatedAt),
      isPendingSync: const Value(false),
      lastSyncAt: Value(dto.lastSyncAt),
      createdAt: Value(dto.createdAt),
      updatedAt: Value(dto.updatedAt),
    );
  }
}
