import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../data/datasources/local/pipeline_referral_local_data_source.dart';
import '../../data/datasources/remote/pipeline_referral_remote_data_source.dart';
import '../../data/dtos/pipeline_referral_dtos.dart';
import '../../data/repositories/pipeline_referral_repository_impl.dart';
import '../../domain/entities/pipeline_referral.dart';
import '../../domain/repositories/pipeline_referral_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for the pipeline referral local data source.
final pipelineReferralLocalDataSourceProvider =
    Provider<PipelineReferralLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return PipelineReferralLocalDataSource(db);
});

/// Provider for the pipeline referral remote data source.
final pipelineReferralRemoteDataSourceProvider =
    Provider<PipelineReferralRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PipelineReferralRemoteDataSource(supabase);
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the pipeline referral repository.
final pipelineReferralRepositoryProvider =
    Provider<PipelineReferralRepository>((ref) {
  final localDataSource = ref.watch(pipelineReferralLocalDataSourceProvider);
  final remoteDataSource = ref.watch(pipelineReferralRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  final database = ref.watch(databaseProvider);

  return PipelineReferralRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    currentUserRole: currentUser?.role.name.toUpperCase() ?? '',
    database: database,
  );
});

// ==========================================
// Stream Providers
// ==========================================

/// Provider for watching inbound (received) referrals for the current user.
final inboundReferralsProvider =
    StreamProvider.autoDispose<List<PipelineReferral>>((ref) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  if (currentUser == null) {
    return Stream.value([]);
  }

  return repository.watchInboundReferrals(currentUser.id);
});

/// Provider for watching outbound (sent) referrals for the current user.
final outboundReferralsProvider =
    StreamProvider.autoDispose<List<PipelineReferral>>((ref) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  if (currentUser == null) {
    return Stream.value([]);
  }

  return repository.watchOutboundReferrals(currentUser.id);
});

/// Provider for watching referrals pending approval (for managers).
final pendingApprovalsProvider =
    StreamProvider.autoDispose<List<PipelineReferral>>((ref) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  if (currentUser == null) {
    return Stream.value([]);
  }

  return repository.watchPendingApprovals(currentUser.id);
});

/// Provider for watching all referrals (for admin users).
final allReferralsProvider =
    StreamProvider.autoDispose<List<PipelineReferral>>((ref) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  // Only admins can see all referrals
  if (currentUser == null || !currentUser.isAdmin) {
    return Stream.value([]);
  }

  return repository.watchAllReferrals();
});

/// Provider for watching inbound referrals for a specific user.
final userInboundReferralsProvider = StreamProvider.autoDispose
    .family<List<PipelineReferral>, String>((ref, userId) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  return repository.watchInboundReferrals(userId);
});

/// Provider for watching outbound referrals for a specific user.
final userOutboundReferralsProvider = StreamProvider.autoDispose
    .family<List<PipelineReferral>, String>((ref, userId) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  return repository.watchOutboundReferrals(userId);
});

// ==========================================
// Detail Provider
// ==========================================

/// Provider for watching a specific referral by ID (reactive stream).
final referralDetailProvider = StreamProvider.autoDispose
    .family<PipelineReferral?, String>((ref, id) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  return repository.watchReferralById(id);
});

// ==========================================
// Counts Provider
// ==========================================

/// Provider for pending inbound referrals count (for badges).
final pendingInboundCountProvider = Provider<int>((ref) {
  final inbound = ref.watch(inboundReferralsProvider);
  return inbound.maybeWhen(
    data: (referrals) => referrals
        .where((r) => r.status == ReferralStatus.pendingReceiver)
        .length,
    orElse: () => 0,
  );
});

/// Provider for pending approvals count (for manager badges).
final pendingApprovalCountProvider = Provider<int>((ref) {
  final approvals = ref.watch(pendingApprovalsProvider);
  return approvals.maybeWhen(
    data: (referrals) => referrals.length,
    orElse: () => 0,
  );
});

// ==========================================
// Approver Provider
// ==========================================

/// Provider for finding the approver for a specific user.
final approverForUserProvider =
    FutureProvider.family<ApproverInfo?, String>((ref, userId) async {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  return repository.findApproverForUser(userId);
});

// ==========================================
// Action State
// ==========================================

/// State for referral action operations.
class ReferralActionState {
  ReferralActionState({
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  final bool isLoading;
  final String? errorMessage;
  final PipelineReferral? result;

  ReferralActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    PipelineReferral? result,
  }) {
    return ReferralActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      result: result ?? this.result,
    );
  }
}

/// Notifier for referral action operations.
class ReferralActionNotifier extends StateNotifier<ReferralActionState> {
  ReferralActionNotifier(this._repository, this._currentUserId)
      : super(ReferralActionState());

  final PipelineReferralRepository _repository;
  final String _currentUserId;

  /// Create a new referral.
  Future<bool> createReferral(PipelineReferralCreateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createReferral(dto);

    // Check if notifier is still mounted - if not, the operation still succeeded
    // but we can't update state. Return based on result, not mounted status.
    if (!mounted) {
      AppLogger.instance.debug('pipeline.referral | Notifier unmounted, but operation ${result.isSuccess ? "succeeded" : "failed"}');
      return result.isSuccess;
    }

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          result: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Accept a referral (receiver action).
  Future<bool> acceptReferral(String id, {String? notes}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.acceptReferral(id, notes);

    // Check if notifier is still mounted - if not, the operation still succeeded
    // but we can't update state. Return based on result, not mounted status.
    if (!mounted) {
      AppLogger.instance.debug('pipeline.referral | acceptReferral: Notifier unmounted, but operation ${result.isSuccess ? "succeeded" : "failed"}');
      return result.isSuccess;
    }

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          result: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Reject a referral (receiver action).
  Future<bool> rejectReferral(String id, String reason) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.rejectReferral(id, reason);

    if (!mounted) {
      AppLogger.instance.debug('pipeline.referral | rejectReferral: Notifier unmounted, but operation ${result.isSuccess ? "succeeded" : "failed"}');
      return result.isSuccess;
    }

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          result: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Approve a referral (manager action).
  Future<bool> approveReferral(String id, {String? notes}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.approveReferral(id, _currentUserId, notes);

    if (!mounted) {
      AppLogger.instance.debug('pipeline.referral | approveReferral: Notifier unmounted, but operation ${result.isSuccess ? "succeeded" : "failed"}');
      return result.isSuccess;
    }

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          result: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Reject a referral as manager.
  Future<bool> rejectAsManager(String id, String reason) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result =
        await _repository.rejectAsManager(id, _currentUserId, reason);

    if (!mounted) {
      AppLogger.instance.debug('pipeline.referral | rejectAsManager: Notifier unmounted, but operation ${result.isSuccess ? "succeeded" : "failed"}');
      return result.isSuccess;
    }

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          result: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Cancel a referral (referrer action).
  Future<bool> cancelReferral(String id, String reason) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.cancelReferral(id, reason);

    if (!mounted) {
      AppLogger.instance.debug('pipeline.referral | cancelReferral: Notifier unmounted, but operation ${result.isSuccess ? "succeeded" : "failed"}');
      return result.isSuccess;
    }

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          result: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Reset the action state.
  void reset() {
    state = ReferralActionState();
  }
}

/// Provider for the referral action notifier.
final referralActionNotifierProvider =
    StateNotifierProvider.autoDispose<ReferralActionNotifier, ReferralActionState>(
        (ref) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  return ReferralActionNotifier(repository, currentUser?.id ?? '');
});

// ==========================================
// Create Referral Form State
// ==========================================

/// State for the create referral form.
/// Note: COB/LOB/premium removed - entire customer transfers, receiver decides products.
class CreateReferralFormState {
  CreateReferralFormState({
    this.customerId,
    this.customerName,
    this.receiverRmId,
    this.receiverRmName,
    this.reason,
    this.notes,
    this.approverInfo,
    this.isLoadingApprover = false,
  });

  final String? customerId;
  final String? customerName;
  final String? receiverRmId;
  final String? receiverRmName;
  final String? reason;
  final String? notes;
  final ApproverInfo? approverInfo;
  final bool isLoadingApprover;

  bool get isValid =>
      customerId != null &&
      receiverRmId != null &&
      reason != null &&
      reason!.isNotEmpty;

  CreateReferralFormState copyWith({
    String? customerId,
    String? customerName,
    String? receiverRmId,
    String? receiverRmName,
    String? reason,
    String? notes,
    ApproverInfo? approverInfo,
    bool? isLoadingApprover,
    bool clearApprover = false,
  }) {
    return CreateReferralFormState(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      receiverRmId: receiverRmId ?? this.receiverRmId,
      receiverRmName: receiverRmName ?? this.receiverRmName,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      approverInfo: clearApprover ? null : (approverInfo ?? this.approverInfo),
      isLoadingApprover: isLoadingApprover ?? this.isLoadingApprover,
    );
  }

  PipelineReferralCreateDto toDto() {
    return PipelineReferralCreateDto(
      customerId: customerId!,
      receiverRmId: receiverRmId!,
      reason: reason!,
      notes: notes,
    );
  }
}

/// Notifier for create referral form state.
/// Note: COB/LOB/premium removed - entire customer transfers, receiver decides products.
class CreateReferralFormNotifier extends StateNotifier<CreateReferralFormState> {
  CreateReferralFormNotifier(this._repository)
      : super(CreateReferralFormState());

  final PipelineReferralRepository _repository;

  void setCustomer(String id, String name) {
    state = state.copyWith(customerId: id, customerName: name);
  }

  /// Set receiver and fetch approver info.
  Future<void> setReceiver(String id, String name) async {
    state = state.copyWith(
      receiverRmId: id,
      receiverRmName: name,
      isLoadingApprover: true,
      clearApprover: true,
    );

    // Fetch approver for the receiver
    final approver = await _repository.findApproverForUser(id);
    if (!mounted) return;
    state = state.copyWith(
      approverInfo: approver,
      isLoadingApprover: false,
    );
  }

  void setReason(String value) {
    state = state.copyWith(reason: value);
  }

  void setNotes(String? value) {
    state = state.copyWith(notes: value);
  }

  void reset() {
    state = CreateReferralFormState();
  }
}

/// Provider for create referral form notifier.
final createReferralFormNotifierProvider = StateNotifierProvider.autoDispose<
    CreateReferralFormNotifier, CreateReferralFormState>((ref) {
  final repository = ref.watch(pipelineReferralRepositoryProvider);
  return CreateReferralFormNotifier(repository);
});
