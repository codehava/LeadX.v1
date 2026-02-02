import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/cadence_local_data_source.dart';
import '../../data/datasources/remote/cadence_remote_data_source.dart';
import '../../data/repositories/cadence_repository_impl.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/repositories/cadence_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for the cadence local data source.
final cadenceLocalDataSourceProvider = Provider<CadenceLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CadenceLocalDataSource(db);
});

/// Provider for the cadence remote data source.
final cadenceRemoteDataSourceProvider =
    Provider<CadenceRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CadenceRemoteDataSource(supabase);
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the cadence repository.
final cadenceRepositoryProvider = Provider<CadenceRepository>((ref) {
  final localDataSource = ref.watch(cadenceLocalDataSourceProvider);
  final remoteDataSource = ref.watch(cadenceRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  return CadenceRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    currentUserRole: currentUser?.role.name.toUpperCase() ?? '',
  );
});

// ==========================================
// Meeting List Providers (Participant View)
// ==========================================

/// Watch upcoming meetings for current user (as participant).
final upcomingMeetingsProvider = StreamProvider<List<CadenceMeeting>>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchUpcomingMeetings();
});

/// Watch past meetings for current user (as participant).
final pastMeetingsProvider = StreamProvider<List<CadenceMeeting>>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchPastMeetings(limit: 20);
});

// ==========================================
// Meeting List Providers (Host View)
// ==========================================

/// Watch meetings where current user is host/facilitator.
final hostedMeetingsProvider = StreamProvider<List<CadenceMeeting>>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchHostedMeetings();
});

// ==========================================
// Single Meeting Providers
// ==========================================

/// Watch a single meeting by ID.
final cadenceMeetingProvider =
    StreamProvider.family<CadenceMeeting?, String>((ref, meetingId) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchMeeting(meetingId);
});

/// Watch participants for a meeting.
final meetingParticipantsProvider =
    StreamProvider.family<List<CadenceParticipant>, String>((ref, meetingId) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchMeetingParticipants(meetingId);
});

/// Watch current user's participation for a meeting.
final myParticipationProvider =
    StreamProvider.family<CadenceParticipant?, String>((ref, meetingId) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchMyParticipation(meetingId);
});

// ==========================================
// Meeting With Participants Provider
// ==========================================

/// Watch meeting with all participants for detail view (reactive stream).
final meetingWithParticipantsProvider =
    StreamProvider.family<CadenceMeetingWithParticipants?, String>(
        (ref, meetingId) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchMeetingWithParticipants(meetingId);
});

// ==========================================
// Config Providers
// ==========================================

/// Watch all active schedule configs (reactive stream).
final cadenceConfigsProvider =
    StreamProvider<List<CadenceScheduleConfig>>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchActiveConfigs();
});

/// Watch config for current user as facilitator (reactive stream).
final myFacilitatorConfigProvider =
    StreamProvider<CadenceScheduleConfig?>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchMyFacilitatorConfig();
});

// ==========================================
// History Providers
// ==========================================

/// Get participant's cadence history.
final participantHistoryProvider =
    FutureProvider.family<List<CadenceParticipant>, String>((ref, userId) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.getParticipantHistory(userId: userId, limit: 50);
});

// ==========================================
// Form State
// ==========================================

/// State for pre-meeting form submission.
class CadenceFormState {
  CadenceFormState({
    this.isLoading = false,
    this.isSubmitted = false,
    this.errorMessage,
    this.participant,
  });

  final bool isLoading;
  final bool isSubmitted;
  final String? errorMessage;
  final CadenceParticipant? participant;

  CadenceFormState copyWith({
    bool? isLoading,
    bool? isSubmitted,
    String? errorMessage,
    CadenceParticipant? participant,
  }) {
    return CadenceFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage,
      participant: participant ?? this.participant,
    );
  }
}

/// Notifier for pre-meeting form operations.
class CadenceFormNotifier extends StateNotifier<CadenceFormState> {
  CadenceFormNotifier(this._repository) : super(CadenceFormState());

  final CadenceRepository _repository;

  /// Submit pre-meeting form.
  Future<void> submitForm(CadenceFormSubmission submission) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.submitPreMeetingForm(submission);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (participant) {
        state = state.copyWith(
          isLoading: false,
          isSubmitted: true,
          participant: participant,
        );
      },
    );
  }

  /// Save form as draft.
  Future<void> saveDraft(CadenceFormSubmission submission) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.saveFormDraft(submission);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (participant) {
        state = state.copyWith(
          isLoading: false,
          participant: participant,
        );
      },
    );
  }

  /// Reset form state.
  void reset() {
    state = CadenceFormState();
  }
}

/// Provider for pre-meeting form notifier.
final cadenceFormNotifierProvider =
    StateNotifierProvider.autoDispose<CadenceFormNotifier, CadenceFormState>(
        (ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return CadenceFormNotifier(repository);
});

// ==========================================
// Host Action State
// ==========================================

/// State for host meeting actions.
class HostActionState {
  HostActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  HostActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return HostActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Notifier for host meeting actions.
class HostActionNotifier extends StateNotifier<HostActionState> {
  HostActionNotifier(this._repository) : super(HostActionState());

  final CadenceRepository _repository;

  /// Start a meeting.
  Future<bool> startMeeting(String meetingId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.startMeeting(meetingId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (meeting) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Meeting started',
        );
        return true;
      },
    );
  }

  /// End a meeting.
  Future<bool> endMeeting(String meetingId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.endMeeting(meetingId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (meeting) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Meeting completed',
        );
        return true;
      },
    );
  }

  /// Mark attendance for a participant.
  Future<bool> markAttendance({
    required String participantId,
    required AttendanceStatus status,
    String? excusedReason,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.markAttendance(
      participantId: participantId,
      status: status,
      excusedReason: excusedReason,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (participant) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Save feedback for a participant.
  Future<bool> saveFeedback({
    required String participantId,
    required String feedbackText,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.saveFeedback(
      participantId: participantId,
      feedbackText: feedbackText,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Feedback saved',
        );
        return true;
      },
    );
  }

  /// Clear messages.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// Provider for host action notifier.
final hostActionNotifierProvider =
    StateNotifierProvider.autoDispose<HostActionNotifier, HostActionState>(
        (ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return HostActionNotifier(repository);
});

// ==========================================
// Computed Providers
// ==========================================

/// Check if current user has a facilitator role.
final isHostProvider = FutureProvider<bool>((ref) async {
  final config = await ref.watch(myFacilitatorConfigProvider.future);
  return config != null;
});

/// Get next upcoming meeting for current user.
final nextMeetingProvider = Provider<AsyncValue<CadenceMeeting?>>((ref) {
  final meetings = ref.watch(upcomingMeetingsProvider);
  return meetings.whenData((list) => list.isNotEmpty ? list.first : null);
});

// ==========================================
// Admin: Config Management Providers
// ==========================================

/// Watch all schedule configs (active and inactive) for admin view.
final allCadenceConfigsProvider =
    StreamProvider<List<CadenceScheduleConfig>>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchAllConfigs();
});

/// Watch a specific config by ID for edit screen (reactive stream).
final cadenceConfigByIdProvider =
    StreamProvider.family<CadenceScheduleConfig?, String>((ref, configId) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return repository.watchConfigById(configId);
});

/// State for admin config operations.
class AdminCadenceConfigState {
  AdminCadenceConfigState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AdminCadenceConfigState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminCadenceConfigState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Notifier for admin cadence config operations.
class AdminCadenceConfigNotifier
    extends StateNotifier<AdminCadenceConfigState> {
  AdminCadenceConfigNotifier(this._repository)
      : super(AdminCadenceConfigState());

  final CadenceRepository _repository;

  /// Create a new config.
  Future<bool> createConfig({
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.createConfig(
      name: name,
      description: description,
      targetRole: targetRole,
      facilitatorRole: facilitatorRole,
      frequency: frequency,
      dayOfWeek: dayOfWeek,
      dayOfMonth: dayOfMonth,
      defaultTime: defaultTime,
      durationMinutes: durationMinutes,
      preMeetingHours: preMeetingHours,
      isActive: isActive,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (config) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Konfigurasi berhasil dibuat',
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      },
    );
  }

  /// Update an existing config.
  Future<bool> updateConfig({
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.updateConfig(
      configId: configId,
      name: name,
      description: description,
      targetRole: targetRole,
      facilitatorRole: facilitatorRole,
      frequency: frequency,
      dayOfWeek: dayOfWeek,
      dayOfMonth: dayOfMonth,
      defaultTime: defaultTime,
      durationMinutes: durationMinutes,
      preMeetingHours: preMeetingHours,
      isActive: isActive,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (config) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Konfigurasi berhasil diperbarui',
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      },
    );
  }

  /// Toggle config active status.
  Future<bool> toggleActive(String configId, bool isActive) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.toggleConfigActive(configId, isActive);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (config) {
        state = state.copyWith(
          isLoading: false,
          successMessage: isActive ? 'Konfigurasi diaktifkan' : 'Konfigurasi dinonaktifkan',
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      },
    );
  }

  /// Delete (deactivate) a config.
  Future<bool> deleteConfig(String configId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.deleteConfig(configId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Konfigurasi berhasil dihapus',
        );
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      },
    );
  }

  /// Clear messages.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// Provider for admin cadence config notifier.
final adminCadenceConfigNotifierProvider = StateNotifierProvider.autoDispose<
    AdminCadenceConfigNotifier, AdminCadenceConfigState>((ref) {
  final repository = ref.watch(cadenceRepositoryProvider);
  return AdminCadenceConfigNotifier(repository);
});
