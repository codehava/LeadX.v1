import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/dtos/pipeline_referral_dtos.dart';
import '../entities/pipeline_referral.dart';

/// Repository interface for pipeline referral operations.
abstract class PipelineReferralRepository {
  // ==========================================
  // Referral CRUD Operations
  // ==========================================

  /// Create a new referral.
  /// Automatically determines the approver (BM or ROH) based on receiver's hierarchy.
  /// Saves locally first, then queues for sync.
  Future<Either<Failure, PipelineReferral>> createReferral(
    PipelineReferralCreateDto dto,
  );

  /// Get a specific referral by ID.
  Future<PipelineReferral?> getReferralById(String id);

  // ==========================================
  // Receiver Actions
  // ==========================================

  /// Accept a referral (receiver action).
  /// Changes status to RECEIVER_ACCEPTED.
  Future<Either<Failure, PipelineReferral>> acceptReferral(
    String id,
    String? notes,
  );

  /// Reject a referral (receiver action).
  /// Changes status to RECEIVER_REJECTED.
  Future<Either<Failure, PipelineReferral>> rejectReferral(
    String id,
    String reason,
  );

  // ==========================================
  // Manager Actions
  // ==========================================

  /// Approve a referral (BM/ROH action).
  /// Changes status to BM_APPROVED, triggering customer/pipeline transfer.
  Future<Either<Failure, PipelineReferral>> approveReferral(
    String id,
    String approverId,
    String? notes,
  );

  /// Reject a referral as manager (BM/ROH action).
  /// Changes status to BM_REJECTED.
  Future<Either<Failure, PipelineReferral>> rejectAsManager(
    String id,
    String approverId,
    String reason,
  );

  // ==========================================
  // Referrer Actions
  // ==========================================

  /// Cancel a referral (referrer action).
  /// Only allowed before final approval.
  Future<Either<Failure, PipelineReferral>> cancelReferral(
    String id,
    String reason,
  );

  // ==========================================
  // Watch Streams (Reactive)
  // ==========================================

  /// Watch referrals sent by a user (outbound).
  Stream<List<PipelineReferral>> watchOutboundReferrals(String userId);

  /// Watch referrals received by a user (inbound).
  Stream<List<PipelineReferral>> watchInboundReferrals(String userId);

  /// Watch referrals pending approval by a manager.
  /// Returns referrals where current user is the designated approver.
  Stream<List<PipelineReferral>> watchPendingApprovals(String managerId);

  /// Watch all referrals (for admin users).
  Stream<List<PipelineReferral>> watchAllReferrals();

  // ==========================================
  // List Operations
  // ==========================================

  /// Get referrals sent by a user (outbound).
  Future<List<PipelineReferral>> getOutboundReferrals(String userId);

  /// Get referrals received by a user (inbound).
  Future<List<PipelineReferral>> getInboundReferrals(String userId);

  /// Get referrals pending approval by a manager.
  Future<List<PipelineReferral>> getPendingApprovals(String managerId);

  /// Get referrals that need to be synced.
  Future<List<PipelineReferral>> getPendingSyncReferrals();

  // ==========================================
  // Approver Determination
  // ==========================================

  /// Find the approver for a given user (receiver).
  /// Returns the approver ID and type (BM or ROH) based on hierarchy.
  ///
  /// Logic:
  /// 1. If receiver has branch_id, search user_hierarchy for ancestor with role='BM'
  /// 2. If BM found → approverType = 'BM'
  /// 3. If no BM found (or no branch):
  ///    - Search user_hierarchy for ancestor with role='ROH'
  ///    - If not found, find ROH by matching regional_office_id
  ///    - approverType = 'ROH'
  Future<ApproverInfo?> findApproverForUser(String userId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync referrals from remote to local.
  /// Uses incremental sync based on updatedAt timestamp.
  Future<void> syncFromRemote({DateTime? since});

  /// Mark a referral as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt);
}
