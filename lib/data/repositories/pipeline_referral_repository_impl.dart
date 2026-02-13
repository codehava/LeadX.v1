import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/logging/app_logger.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/pipeline_referral.dart' as domain;
import '../../domain/entities/sync_models.dart';
import '../../domain/repositories/pipeline_referral_repository.dart';
import '../database/app_database.dart' as db;
import '../datasources/local/pipeline_referral_local_data_source.dart';
import '../datasources/remote/pipeline_referral_remote_data_source.dart';
import '../dtos/pipeline_referral_dtos.dart';
import '../services/sync_service.dart';

/// Implementation of PipelineReferralRepository with offline-first pattern.
class PipelineReferralRepositoryImpl implements PipelineReferralRepository {
  PipelineReferralRepositoryImpl({
    required PipelineReferralLocalDataSource localDataSource,
    required PipelineReferralRemoteDataSource remoteDataSource,
    required SyncService syncService,
    required String currentUserId,
    required String currentUserRole,
    required db.AppDatabase database,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncService = syncService,
        _currentUserId = currentUserId,
        _currentUserRole = currentUserRole,
        _database = database;

  final PipelineReferralLocalDataSource _localDataSource;
  final PipelineReferralRemoteDataSource _remoteDataSource;
  final SyncService _syncService;
  final String _currentUserId;
  final String _currentUserRole;
  final db.AppDatabase _database;

  /// Check if current user is admin (can do all operations)
  bool get _isAdmin => _currentUserRole == 'ADMIN' || _currentUserRole == 'SUPERADMIN';
  final _uuid = const Uuid();
  final _log = AppLogger.instance;

  // Lookup caches
  Map<String, String>? _userNameCache;
  Map<String, String>? _customerNameCache;
  Map<String, String>? _branchNameCache;

  // ==========================================
  // Stream Operations
  // ==========================================

  @override
  Stream<List<domain.PipelineReferral>> watchOutboundReferrals(String userId) {
    return _localDataSource.watchByReferrer(userId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToReferral).toList();
    });
  }

  @override
  Stream<List<domain.PipelineReferral>> watchInboundReferrals(String userId) {
    return _localDataSource.watchByReceiver(userId).asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToReferral).toList();
    });
  }

  @override
  Stream<List<domain.PipelineReferral>> watchPendingApprovals(String managerId) {
    // Note: This returns ALL pending approvals.
    // The UI should filter by checking if the current user is the designated approver.
    return _localDataSource.watchPendingApprovals().asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToReferral).toList();
    });
  }

  @override
  Stream<List<domain.PipelineReferral>> watchAllReferrals() {
    return _localDataSource.watchAllReferrals().asyncMap((list) async {
      await _ensureCachesLoaded();
      return list.map(_mapToReferral).toList();
    });
  }

  // ==========================================
  // Read Operations
  // ==========================================

  @override
  Future<domain.PipelineReferral?> getReferralById(String id) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getReferralById(id);
    return data != null ? _mapToReferral(data) : null;
  }

  @override
  Stream<domain.PipelineReferral?> watchReferralById(String id) {
    return _localDataSource.watchReferralById(id).asyncMap((data) async {
      if (data == null) return null;
      await _ensureCachesLoaded();
      return _mapToReferral(data);
    });
  }

  @override
  Future<List<domain.PipelineReferral>> getOutboundReferrals(String userId) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getByReferrer(userId);
    return data.map(_mapToReferral).toList();
  }

  @override
  Future<List<domain.PipelineReferral>> getInboundReferrals(String userId) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getByReceiver(userId);
    return data.map(_mapToReferral).toList();
  }

  @override
  Future<List<domain.PipelineReferral>> getPendingApprovals(String managerId) async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getPendingApprovals();
    return data.map(_mapToReferral).toList();
  }

  @override
  Future<List<domain.PipelineReferral>> getPendingSyncReferrals() async {
    await _ensureCachesLoaded();
    final data = await _localDataSource.getPendingSyncReferrals();
    return data.map(_mapToReferral).toList();
  }

  // ==========================================
  // Create Referral (ONLINE ONLY)
  // ==========================================

  @override
  Future<Either<Failure, domain.PipelineReferral>> createReferral(
    PipelineReferralCreateDto dto,
  ) async {
    try {
      final now = DateTime.now();
      final id = _uuid.v4();
      final code = _generateReferralCode();

      _log.debug('pipeline.referral | === CREATE REFERRAL START ===');
      _log.debug('pipeline.referral | DTO: customerId=${dto.customerId}, receiverRmId=${dto.receiverRmId}');
      _log.debug('pipeline.referral | Generated: id=$id, code=$code');

      // Validate current user ID
      if (_currentUserId.isEmpty) {
        _log.error('pipeline.referral | currentUserId is empty');
        return Left(AuthFailure(message: 'User belum login. Silakan login ulang.'));
      }
      _log.debug('pipeline.referral | currentUserId=$_currentUserId');

      // Get customer info to find the current assigned RM (the actual referrer)
      _log.debug('pipeline.referral | Fetching customer info...');
      final customer = await _remoteDataSource.getCustomerById(dto.customerId);
      if (customer == null) {
        _log.error('pipeline.referral | customer is null');
        return Left(ValidationFailure(message: 'Customer tidak ditemukan.'));
      }
      final referrerRmId = customer['assigned_rm_id'] as String?;
      if (referrerRmId == null || referrerRmId.isEmpty) {
        _log.error('pipeline.referral | customer has no assigned RM');
        return Left(ValidationFailure(message: 'Customer belum memiliki RM yang ditugaskan.'));
      }
      _log.debug('pipeline.referral | Customer assigned RM (referrer): $referrerRmId');

      // Get referrer (customer's current RM) info from remote
      _log.debug('pipeline.referral | Fetching referrer user info...');
      final referrerUser = await _remoteDataSource.getUserById(referrerRmId);
      if (referrerUser == null) {
        _log.error('pipeline.referral | referrerUser is null');
        return Left(ValidationFailure(message: 'Data RM asal tidak ditemukan.'));
      }
      _log.debug('pipeline.referral | referrerUser: branch_id=${referrerUser['branch_id']}, regional_office_id=${referrerUser['regional_office_id']}');

      // Get receiver info from remote
      _log.debug('pipeline.referral | Fetching receiver user info...');
      final receiverUser = await _remoteDataSource.getUserById(dto.receiverRmId);
      if (receiverUser == null) {
        _log.error('pipeline.referral | receiverUser is null');
        return Left(ValidationFailure(message: 'Receiver user not found'));
      }
      _log.debug('pipeline.referral | receiverUser: branch_id=${receiverUser['branch_id']}, regional_office_id=${receiverUser['regional_office_id']}');

      // Prevent referring to the same RM
      if (referrerRmId == dto.receiverRmId) {
        _log.error('pipeline.referral | referrer and receiver are the same');
        return Left(ValidationFailure(
          message: 'Tidak dapat mereferral ke RM yang sama dengan RM saat ini.',
        ));
      }

      // Determine approver based on receiver's hierarchy
      _log.debug('pipeline.referral | Finding approver for receiver...');
      final approverInfo = await findApproverForUser(dto.receiverRmId);
      if (approverInfo == null) {
        _log.error('pipeline.referral | approverInfo is null');
        return Left(ValidationFailure(
          message: 'No approver found for receiver. Cannot create referral.',
        ));
      }
      _log.debug('pipeline.referral | approverInfo: id=${approverInfo.approverId}, type=${approverInfo.approverType.value}, name=${approverInfo.approverName}');

      // Create directly on server (online-only)
      // referrer_rm_id is the customer's current assigned RM (not the user creating the referral)
      final payload = {
        'id': id,
        'code': code,
        'customer_id': dto.customerId,
        'referrer_rm_id': referrerRmId,
        'receiver_rm_id': dto.receiverRmId,
        'referrer_branch_id': referrerUser['branch_id'],
        'receiver_branch_id': receiverUser['branch_id'],
        'referrer_regional_office_id': referrerUser['regional_office_id'],
        'receiver_regional_office_id': receiverUser['regional_office_id'],
        'approver_type': approverInfo.approverType.value,
        'reason': dto.reason,
        'notes': dto.notes,
        'status': 'PENDING_RECEIVER',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      _log.debug('pipeline.referral | Payload: $payload');
      _log.debug('pipeline.referral | Calling remote createReferral...');
      final remoteResult = await _remoteDataSource.createReferral(payload);
      _log.debug('pipeline.referral | Remote result: $remoteResult');

      // Save to local database for offline viewing
      final companion = db.PipelineReferralsCompanion.insert(
        id: remoteResult['id'] as String,
        code: remoteResult['code'] as String,
        customerId: remoteResult['customer_id'] as String,
        referrerRmId: remoteResult['referrer_rm_id'] as String,
        receiverRmId: remoteResult['receiver_rm_id'] as String,
        referrerBranchId: Value(remoteResult['referrer_branch_id'] as String?),
        receiverBranchId: Value(remoteResult['receiver_branch_id'] as String?),
        referrerRegionalOfficeId: Value(remoteResult['referrer_regional_office_id'] as String?),
        receiverRegionalOfficeId: Value(remoteResult['receiver_regional_office_id'] as String?),
        approverType: Value(remoteResult['approver_type'] as String? ?? 'BM'),
        reason: remoteResult['reason'] as String,
        notes: Value(remoteResult['notes'] as String?),
        status: Value(remoteResult['status'] as String),
        isPendingSync: const Value(false),
        createdAt: DateTime.parse(remoteResult['created_at'] as String),
        updatedAt: DateTime.parse(remoteResult['updated_at'] as String),
        lastSyncAt: Value(DateTime.now()),
      );

      _log.debug('pipeline.referral | Saving to local database...');
      await _localDataSource.insertReferral(companion);
      _log.debug('pipeline.referral | Local save successful');

      // Return the created referral
      await _ensureCachesLoaded();
      final localData = await _localDataSource.getReferralById(id);
      _log.debug('pipeline.referral | === CREATE REFERRAL SUCCESS ===');
      return Right(_mapToReferral(localData!));
    } on SocketException catch (e, stackTrace) {
      _log.error('pipeline.referral | Socket exception: $e');
      _log.debug('pipeline.referral | StackTrace: $stackTrace');
      return Left(NetworkFailure(
        message: 'Tidak ada koneksi internet. Pembuatan referral membutuhkan jaringan.',
      ));
    } catch (e, stackTrace) {
      _log.error('pipeline.referral | Create error (${e.runtimeType}): $e');
      _log.debug('pipeline.referral | StackTrace: $stackTrace');

      // Parse PostgrestException for better error messages
      final errorStr = e.toString();
      var message = 'Gagal membuat referral';

      if (errorStr.contains('violates row-level security')) {
        message = 'Tidak memiliki izin untuk membuat referral. Pastikan Anda sudah login.';
      } else if (errorStr.contains('violates foreign key constraint')) {
        message = 'Data referensi tidak valid. Pastikan customer dan user tujuan valid.';
      } else if (errorStr.contains('duplicate key')) {
        message = 'Referral dengan kode ini sudah ada.';
      } else if (errorStr.contains('null value')) {
        message = 'Data tidak lengkap. Pastikan semua field terisi.';
      } else {
        message = 'Gagal membuat referral: $e';
      }

      _log.debug('pipeline.referral | Returning failure with message: $message');

      return Left(ServerFailure(
        message: message,
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Receiver Actions
  // ==========================================

  @override
  Future<Either<Failure, domain.PipelineReferral>> acceptReferral(
    String id,
    String? notes,
  ) async {
    try {
      final existing = await _localDataSource.getReferralById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Referral not found: $id'));
      }

      if (existing.status != 'PENDING_RECEIVER') {
        return Left(ValidationFailure(
          message: 'Referral cannot be accepted in current status: ${existing.status}',
        ));
      }

      // Admin can accept on behalf of receiver
      if (existing.receiverRmId != _currentUserId && !_isAdmin) {
        return Left(AuthFailure(
          message: 'Hanya penerima atau admin yang dapat menerima referral ini',
        ));
      }

      // Update locally and queue for sync atomically
      final now = DateTime.now();
      await _database.transaction(() async {
        await _localDataSource.markReceiverAccepted(id, notes);

        await _syncService.queueOperation(
          entityType: SyncEntityType.pipelineReferral,
          entityId: id,
          operation: SyncOperation.update,
          payload: {
            'id': id,
            'status': 'RECEIVER_ACCEPTED',
            'receiver_accepted_at': now.toIso8601String(),
            'receiver_notes': notes,
            'updated_at': now.toIso8601String(),
          },
        );
      });

      unawaited(_syncService.triggerSync());

      final referral = await getReferralById(id);
      return Right(referral!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to accept referral: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.PipelineReferral>> rejectReferral(
    String id,
    String reason,
  ) async {
    try {
      final existing = await _localDataSource.getReferralById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Referral not found: $id'));
      }

      if (existing.status != 'PENDING_RECEIVER') {
        return Left(ValidationFailure(
          message: 'Referral cannot be rejected in current status: ${existing.status}',
        ));
      }

      // Admin can reject on behalf of receiver
      if (existing.receiverRmId != _currentUserId && !_isAdmin) {
        return Left(AuthFailure(
          message: 'Hanya penerima atau admin yang dapat menolak referral ini',
        ));
      }

      // Update locally and queue for sync atomically
      final now = DateTime.now();
      await _database.transaction(() async {
        await _localDataSource.markReceiverRejected(id, reason);

        await _syncService.queueOperation(
          entityType: SyncEntityType.pipelineReferral,
          entityId: id,
          operation: SyncOperation.update,
          payload: {
            'id': id,
            'status': 'RECEIVER_REJECTED',
            'receiver_rejected_at': now.toIso8601String(),
            'receiver_reject_reason': reason,
            'updated_at': now.toIso8601String(),
          },
        );
      });

      unawaited(_syncService.triggerSync());

      final referral = await getReferralById(id);
      return Right(referral!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to reject referral: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Manager Actions
  // ==========================================

  @override
  Future<Either<Failure, domain.PipelineReferral>> approveReferral(
    String id,
    String approverId,
    String? notes,
  ) async {
    try {
      _log.debug('pipeline.referral | approveReferral: id=$id, approverId=$approverId');
      final existing = await _localDataSource.getReferralById(id);
      if (existing == null) {
        _log.debug('pipeline.referral | approveReferral: Referral not found locally');
        return Left(NotFoundFailure(message: 'Referral tidak ditemukan. Coba refresh terlebih dahulu.'));
      }

      _log.debug('pipeline.referral | approveReferral: Found referral with status=${existing.status}');
      if (existing.status != 'RECEIVER_ACCEPTED') {
        return Left(ValidationFailure(
          message: 'Referral tidak dapat disetujui karena status: ${existing.status}. Coba refresh terlebih dahulu.',
        ));
      }

      // Update locally and queue for sync atomically
      _log.debug('pipeline.referral | approveReferral: Updating local status...');
      final now = DateTime.now();
      await _database.transaction(() async {
        await _localDataSource.markManagerApproved(id, approverId, notes);
        _log.debug('pipeline.referral | approveReferral: Local status updated');

        await _syncService.queueOperation(
          entityType: SyncEntityType.pipelineReferral,
          entityId: id,
          operation: SyncOperation.update,
          payload: {
            'id': id,
            'status': 'BM_APPROVED',
            'bm_approved_at': now.toIso8601String(),
            'bm_approved_by': approverId,
            'bm_notes': notes,
            'updated_at': now.toIso8601String(),
          },
        );
        _log.debug('pipeline.referral | approveReferral: Queued for sync');
      });

      try {
        unawaited(_syncService.triggerSync());
      } catch (triggerError) {
        _log.debug('pipeline.referral | approveReferral: Trigger sync error (non-fatal): $triggerError');
      }

      _log.debug('pipeline.referral | approveReferral: Fetching updated referral...');
      final referral = await getReferralById(id);
      if (referral == null) {
        _log.debug('pipeline.referral | approveReferral: WARNING - referral not found after update');
        // Return success anyway since local update succeeded
        return Right(domain.PipelineReferral(
          id: id,
          code: existing.code,
          customerId: existing.customerId,
          referrerRmId: existing.referrerRmId,
          receiverRmId: existing.receiverRmId,
          approverType: domain.ApproverTypeX.fromString(existing.approverType),
          reason: existing.reason,
          status: domain.ReferralStatus.bmApproved,
          createdAt: existing.createdAt,
          updatedAt: now,
        ));
      }
      _log.debug('pipeline.referral | approveReferral: Success');
      return Right(referral);
    } catch (e) {
      _log.debug('pipeline.referral | approveReferral: Error - $e');
      return Left(DatabaseFailure(
        message: 'Gagal menyetujui referral: $e',
        originalError: e,
      ));
    }
  }

  @override
  Future<Either<Failure, domain.PipelineReferral>> rejectAsManager(
    String id,
    String approverId,
    String reason,
  ) async {
    try {
      _log.debug('pipeline.referral | rejectAsManager: id=$id, approverId=$approverId');
      final existing = await _localDataSource.getReferralById(id);
      if (existing == null) {
        _log.debug('pipeline.referral | rejectAsManager: Referral not found locally');
        return Left(NotFoundFailure(message: 'Referral tidak ditemukan. Coba refresh terlebih dahulu.'));
      }

      _log.debug('pipeline.referral | rejectAsManager: Found referral with status=${existing.status}');
      if (existing.status != 'RECEIVER_ACCEPTED') {
        return Left(ValidationFailure(
          message: 'Referral tidak dapat ditolak karena status: ${existing.status}. Coba refresh terlebih dahulu.',
        ));
      }

      // Update locally and queue for sync atomically
      _log.debug('pipeline.referral | rejectAsManager: Updating local status...');
      final now = DateTime.now();
      await _database.transaction(() async {
        await _localDataSource.markManagerRejected(id, approverId, reason);
        _log.debug('pipeline.referral | rejectAsManager: Local status updated');

        await _syncService.queueOperation(
          entityType: SyncEntityType.pipelineReferral,
          entityId: id,
          operation: SyncOperation.update,
          payload: {
            'id': id,
            'status': 'BM_REJECTED',
            'bm_rejected_at': now.toIso8601String(),
            'bm_approved_by': approverId,
            'bm_reject_reason': reason,
            'updated_at': now.toIso8601String(),
          },
        );
        _log.debug('pipeline.referral | rejectAsManager: Queued for sync');
      });

      try {
        unawaited(_syncService.triggerSync());
      } catch (triggerError) {
        _log.debug('pipeline.referral | rejectAsManager: Trigger sync error (non-fatal): $triggerError');
      }

      _log.debug('pipeline.referral | rejectAsManager: Fetching updated referral...');
      final referral = await getReferralById(id);
      if (referral == null) {
        _log.debug('pipeline.referral | rejectAsManager: WARNING - referral not found after update');
        return Right(domain.PipelineReferral(
          id: id,
          code: existing.code,
          customerId: existing.customerId,
          referrerRmId: existing.referrerRmId,
          receiverRmId: existing.receiverRmId,
          approverType: domain.ApproverTypeX.fromString(existing.approverType),
          reason: existing.reason,
          status: domain.ReferralStatus.bmRejected,
          createdAt: existing.createdAt,
          updatedAt: now,
        ));
      }
      _log.debug('pipeline.referral | rejectAsManager: Success');
      return Right(referral);
    } catch (e) {
      _log.debug('pipeline.referral | rejectAsManager: Error - $e');
      return Left(DatabaseFailure(
        message: 'Gagal menolak referral: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Referrer Actions
  // ==========================================

  @override
  Future<Either<Failure, domain.PipelineReferral>> cancelReferral(
    String id,
    String reason,
  ) async {
    try {
      final existing = await _localDataSource.getReferralById(id);
      if (existing == null) {
        return Left(NotFoundFailure(message: 'Referral not found: $id'));
      }

      // Can only cancel if not yet completed/rejected
      final cancellableStatuses = ['PENDING_RECEIVER', 'RECEIVER_ACCEPTED'];
      if (!cancellableStatuses.contains(existing.status)) {
        return Left(ValidationFailure(
          message: 'Referral cannot be cancelled in current status: ${existing.status}',
        ));
      }

      // Admin can cancel on behalf of referrer
      if (existing.referrerRmId != _currentUserId && !_isAdmin) {
        return Left(AuthFailure(
          message: 'Hanya pengirim atau admin yang dapat membatalkan referral ini',
        ));
      }

      // Update locally and queue for sync atomically
      final now = DateTime.now();
      await _database.transaction(() async {
        await _localDataSource.markCancelled(id, reason);

        await _syncService.queueOperation(
          entityType: SyncEntityType.pipelineReferral,
          entityId: id,
          operation: SyncOperation.update,
          payload: {
            'id': id,
            'status': 'CANCELLED',
            'cancelled_at': now.toIso8601String(),
            'cancel_reason': reason,
            'updated_at': now.toIso8601String(),
          },
        );
      });

      unawaited(_syncService.triggerSync());

      final referral = await getReferralById(id);
      return Right(referral!);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to cancel referral: $e',
        originalError: e,
      ));
    }
  }

  // ==========================================
  // Approver Determination
  // ==========================================

  @override
  Future<domain.ApproverInfo?> findApproverForUser(String userId) async {
    try {
      final result = await _remoteDataSource.findApproverForUser(userId);
      if (result == null) return null;

      return domain.ApproverInfo(
        approverId: result['approver_id'] as String,
        approverType: domain.ApproverTypeX.fromString(
          result['approver_type'] as String,
        ),
        approverName: result['approver_name'] as String?,
      );
    } catch (e) {
      _log.error('pipeline.referral | Error finding approver: $e');
      return null;
    }
  }

  // ==========================================
  // Sync Operations
  // ==========================================

  @override
  Future<void> syncFromRemote({DateTime? since}) async {
    try {
      final remoteData = await _remoteDataSource.fetchReferrals(since: since);
      _log.debug('pipeline.referral | Fetched ${remoteData.length} referrals from remote');
      // Log statuses for debugging approval visibility
      for (final r in remoteData) {
        _log.debug('pipeline.referral | - ${r['code']}: status=${r['status']}, approver_type=${r['approver_type']}');
      }

      final companions = remoteData.map((data) {
        return db.PipelineReferralsCompanion(
          id: Value(data['id'] as String),
          code: Value(data['code'] as String),
          customerId: Value(data['customer_id'] as String),
          referrerRmId: Value(data['referrer_rm_id'] as String),
          receiverRmId: Value(data['receiver_rm_id'] as String),
          referrerBranchId: Value(data['referrer_branch_id'] as String?),
          receiverBranchId: Value(data['receiver_branch_id'] as String?),
          referrerRegionalOfficeId: Value(data['referrer_regional_office_id'] as String?),
          receiverRegionalOfficeId: Value(data['receiver_regional_office_id'] as String?),
          approverType: Value(data['approver_type'] as String? ?? 'BM'),
          reason: Value(data['reason'] as String),
          notes: Value(data['notes'] as String?),
          status: Value(data['status'] as String),
          receiverAcceptedAt: Value(_parseDateTime(data['receiver_accepted_at'])),
          receiverRejectedAt: Value(_parseDateTime(data['receiver_rejected_at'])),
          receiverRejectReason: Value(data['receiver_reject_reason'] as String?),
          receiverNotes: Value(data['receiver_notes'] as String?),
          bmApprovedAt: Value(_parseDateTime(data['bm_approved_at'])),
          bmApprovedBy: Value(data['bm_approved_by'] as String?),
          bmRejectedAt: Value(_parseDateTime(data['bm_rejected_at'])),
          bmRejectReason: Value(data['bm_reject_reason'] as String?),
          bmNotes: Value(data['bm_notes'] as String?),
          bonusCalculated: Value(data['bonus_calculated'] as bool? ?? false),
          bonusAmount: Value((data['bonus_amount'] as num?)?.toDouble()),
          expiresAt: Value(_parseDateTime(data['expires_at'])),
          cancelledAt: Value(_parseDateTime(data['cancelled_at'])),
          cancelReason: Value(data['cancel_reason'] as String?),
          isPendingSync: const Value(false),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          updatedAt: Value(DateTime.parse(data['updated_at'] as String)),
          lastSyncAt: Value(DateTime.now()),
        );
      }).toList();

      await _localDataSource.upsertReferrals(companions);
      _log.debug('pipeline.referral | Upserted ${companions.length} referrals locally');
    } catch (e) {
      _log.error('pipeline.referral | Sync error: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsSynced(String id, DateTime syncedAt) =>
      _localDataSource.markAsSynced(id, syncedAt);

  // ==========================================
  // Cache Operations
  // ==========================================

  @override
  void invalidateCaches() {
    _userNameCache = null;
    _customerNameCache = null;
    _branchNameCache = null;
    _log.debug('pipeline.referral | Caches invalidated');
  }

  // ==========================================
  // Private Helpers
  // ==========================================

  /// Generate a unique referral code.
  String _generateReferralCode() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = now.millisecondsSinceEpoch.toString().substring(8);
    return 'REF-$dateStr-$seq';
  }

  /// Parse datetime from JSON (handles null).
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Get branch name from cache (handles null).
  String? _getBranchName(String? branchId) {
    if (branchId == null) return null;
    return _branchNameCache?[branchId];
  }

  /// Get user name from cache (handles null).
  String? _getUserName(String? userId) {
    if (userId == null) return null;
    return _userNameCache?[userId];
  }

  /// Initialize lookup caches.
  Future<void> _ensureCachesLoaded() async {
    if (_userNameCache == null) {
      final users = await _database.select(_database.users).get();
      _userNameCache = {for (final u in users) u.id: u.name};
    }
    if (_customerNameCache == null) {
      final customers = await (_database.select(_database.customers)
            ..where((c) => c.deletedAt.isNull()))
          .get();
      _customerNameCache = {for (final c in customers) c.id: c.name};
    }
    if (_branchNameCache == null) {
      final branches = await _database.select(_database.branches).get();
      _branchNameCache = {for (final b in branches) b.id: b.name};
    }
  }

  /// Map database record to domain entity.
  /// Note: Includes defensive null checks for web/WASM where SQLite fields
  /// may come through as JavaScript undefined instead of Dart null.
  domain.PipelineReferral _mapToReferral(db.PipelineReferral data) {
    // Defensive: ensure required string fields are not undefined on web
    final id = data.id;
    final code = data.code;
    final customerId = data.customerId;
    final referrerRmId = data.referrerRmId;
    final receiverRmId = data.receiverRmId;
    final approverType = data.approverType;
    final reason = data.reason;
    final status = data.status;

    return domain.PipelineReferral(
      id: id.isNotEmpty ? id : 'unknown-${DateTime.now().millisecondsSinceEpoch}',
      code: code.isNotEmpty ? code : 'REF-UNKNOWN',
      customerId: customerId.isNotEmpty ? customerId : '',
      referrerRmId: referrerRmId.isNotEmpty ? referrerRmId : '',
      receiverRmId: receiverRmId.isNotEmpty ? receiverRmId : '',
      referrerBranchId: data.referrerBranchId,
      receiverBranchId: data.receiverBranchId,
      referrerRegionalOfficeId: data.referrerRegionalOfficeId,
      receiverRegionalOfficeId: data.receiverRegionalOfficeId,
      approverType: domain.ApproverTypeX.fromString(
        approverType.isNotEmpty ? approverType : 'BM',
      ),
      reason: reason.isNotEmpty ? reason : 'Unknown',
      notes: data.notes,
      status: domain.ReferralStatusX.fromString(
        status.isNotEmpty ? status : 'PENDING_RECEIVER',
      ),
      receiverAcceptedAt: data.receiverAcceptedAt,
      receiverRejectedAt: data.receiverRejectedAt,
      receiverRejectReason: data.receiverRejectReason,
      receiverNotes: data.receiverNotes,
      bmApprovedAt: data.bmApprovedAt,
      bmApprovedBy: data.bmApprovedBy,
      bmRejectedAt: data.bmRejectedAt,
      bmRejectReason: data.bmRejectReason,
      bmNotes: data.bmNotes,
      bonusCalculated: data.bonusCalculated,
      bonusAmount: data.bonusAmount,
      expiresAt: data.expiresAt,
      cancelledAt: data.cancelledAt,
      cancelReason: data.cancelReason,
      isPendingSync: data.isPendingSync,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      // Lookup fields
      customerName: _customerNameCache?[data.customerId],
      referrerRmName: _userNameCache?[data.referrerRmId],
      receiverRmName: _userNameCache?[data.receiverRmId],
      referrerBranchName: _getBranchName(data.referrerBranchId),
      receiverBranchName: _getBranchName(data.receiverBranchId),
      approverName: _getUserName(data.bmApprovedBy),
    );
  }
}
