import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/local/activity_local_data_source.dart';
import '../../data/datasources/remote/activity_remote_data_source.dart';
import '../../data/dtos/activity_dtos.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../data/services/camera_service.dart';
import '../../data/services/gps_service.dart';
import '../../domain/entities/activity.dart' as domain;
import 'auth_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for the activity local data source.
final activityLocalDataSourceProvider = Provider<ActivityLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return ActivityLocalDataSource(db);
});

/// Provider for the activity remote data source.
final activityRemoteDataSourceProvider =
    Provider<ActivityRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ActivityRemoteDataSource(supabase);
});

// ==========================================
// Service Providers
// ==========================================

/// Provider for GPS service.
final gpsServiceProvider = Provider<GpsService>((ref) {
  return GpsService();
});

/// Provider for camera service.
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the activity repository.
final activityRepositoryProvider = Provider<ActivityRepositoryImpl>((ref) {
  final localDataSource = ref.watch(activityLocalDataSourceProvider);
  final remoteDataSource = ref.watch(activityRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  return ActivityRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
  );
});

// ==========================================
// Stream Providers
// ==========================================

/// Provider for watching user activities for a date range.
final userActivitiesProvider = StreamProvider.family<
    List<domain.Activity>, ({DateTime startDate, DateTime endDate})>((ref, params) {
  final repository = ref.watch(activityRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value([]);
  return repository.watchUserActivities(
    currentUser.id,
    params.startDate,
    params.endDate,
  );
});

/// Provider for watching today's activities.
final todayActivitiesProvider = StreamProvider<List<domain.Activity>>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value([]);
  return repository.watchTodayActivities(currentUser.id);
});

/// Provider for watching activities for a specific customer.
final customerActivitiesProvider =
    StreamProvider.family<List<domain.Activity>, String>((ref, customerId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchCustomerActivities(customerId);
});

/// Provider for watching activities for a specific HVC.
final hvcActivitiesProvider =
    StreamProvider.family<List<domain.Activity>, String>((ref, hvcId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchHvcActivities(hvcId);
});

/// Provider for watching activities for a specific broker.
final brokerActivitiesProvider =
    StreamProvider.family<List<domain.Activity>, String>((ref, brokerId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchBrokerActivities(brokerId);
});

// ==========================================
// Detail Providers
// ==========================================

/// Provider for watching a specific activity by ID (reactive stream).
final activityDetailProvider =
    StreamProvider.family<domain.Activity?, String>((ref, id) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActivityById(id);
});

/// Provider for watching activity with full details (type, photos, logs) (reactive stream).
final activityWithDetailsProvider =
    StreamProvider.family<domain.ActivityWithDetails?, String>((ref, id) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActivityWithDetails(id);
});

// ==========================================
// Master Data Providers
// ==========================================

/// @deprecated Use [activityTypesStreamProvider] from master_data_providers instead.
/// Returns DTOs for better separation of concerns.
final activityTypesProvider =
    FutureProvider<List<domain.ActivityType>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivityTypes();
});

// ==========================================
// Calendar State Providers
// ==========================================

/// Provider for the selected date in the calendar.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Calendar view mode.
enum CalendarViewMode { day, week, month }

/// Provider for the calendar view mode.
final calendarViewModeProvider = StateProvider<CalendarViewMode>((ref) {
  return CalendarViewMode.week;
});

// ==========================================
// Form Notifiers
// ==========================================

/// State for activity form.
class ActivityFormState {
  ActivityFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedActivity,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.Activity? savedActivity;

  ActivityFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.Activity? savedActivity,
  }) {
    return ActivityFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      savedActivity: savedActivity ?? this.savedActivity,
    );
  }
}

/// Notifier for activity form operations.
class ActivityFormNotifier extends StateNotifier<ActivityFormState> {
  ActivityFormNotifier(this._repository, this._remoteDataSource) : super(ActivityFormState());

  final ActivityRepositoryImpl _repository;
  final ActivityRemoteDataSource _remoteDataSource;

  /// Create a new scheduled activity.
  Future<void> createActivity(ActivityCreateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createActivity(dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (activity) {
        state = state.copyWith(
          isLoading: false,
          savedActivity: activity,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      },
    );
  }

  /// Create an immediate activity.
  Future<void> createImmediateActivity(ImmediateActivityDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createImmediateActivity(dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (activity) {
        state = state.copyWith(
          isLoading: false,
          savedActivity: activity,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      },
    );
  }

  /// Execute a planned activity.
  Future<void> executeActivity(String id, ActivityExecutionDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.executeActivity(id, dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (activity) {
        state = state.copyWith(
          isLoading: false,
          savedActivity: activity,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      },
    );
  }

  /// Reschedule an activity.
  Future<void> rescheduleActivity(String id, ActivityRescheduleDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.rescheduleActivity(id, dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (activity) {
        state = state.copyWith(
          isLoading: false,
          savedActivity: activity,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      },
    );
  }

  /// Cancel an activity.
  Future<bool> cancelActivity(String id, String reason, {String? customerId, String? hvcId, String? brokerId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.cancelActivity(id, reason);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      },
    );
  }

  /// Add photos to an activity.
  /// Used after execution to save captured photos.
  Future<void> addPhotosToActivity(
    String activityId,
    List<String> photoPaths, {
    double? latitude,
    double? longitude,
  }) async {
    for (final path in photoPaths) {
      await _repository.addPhoto(
        activityId,
        path,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  /// Add photos with bytes directly (for web).
  /// Uploads directly to Supabase Storage and creates DB record.
  Future<void> addPhotosWithBytes(
    String activityId,
    List<CapturedPhoto> photos, {
    double? latitude,
    double? longitude,
  }) async {
    debugPrint('[ActivityFormNotifier] addPhotosWithBytes called with ${photos.length} photos for activity $activityId');
    
    for (final photo in photos) {
      try {
        // Generate UUID for photo ID (required by Supabase)
        const uuid = Uuid();
        final fileId = uuid.v4();
        
        debugPrint('[ActivityFormNotifier] Processing photo: bytes=${photo.bytes != null}, localPath=${photo.localPath}');
        
        if (photo.bytes != null) {
          // Web: upload bytes directly
          debugPrint('[ActivityFormNotifier] Uploading photo bytes to Supabase Storage...');
          final photoUrl = await _remoteDataSource.uploadPhotoBytes(
            activityId,
            photo.bytes!,
            fileId,
          );
          debugPrint('[ActivityFormNotifier] Upload successful, URL: $photoUrl');
          
          // Create photo record in remote database
          debugPrint('[ActivityFormNotifier] Creating remote photo record...');
          await _remoteDataSource.createPhotoRecord({
            'id': fileId,
            'activity_id': activityId,
            'file_path': photoUrl, // Use URL as file_path for web (no local path)
            'photo_url': photoUrl,
            'caption': null,
            'taken_at': photo.takenAt.toIso8601String(),
            'latitude': latitude,
            'longitude': longitude,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint('[ActivityFormNotifier] Remote record created');
          
          // Also insert into local database so it shows in detail view
          debugPrint('[ActivityFormNotifier] Inserting into local database...');
          final localResult = await _repository.addPhotoFromUrl(
            activityId,
            fileId,
            photoUrl,
            latitude: latitude,
            longitude: longitude,
            takenAt: photo.takenAt,
          );
          
          localResult.fold(
            (failure) => debugPrint('[ActivityFormNotifier] ERROR: Failed to insert local DB record: ${failure.message}'),
            (savedPhoto) => debugPrint('[ActivityFormNotifier] SUCCESS: Local DB record created with id=${savedPhoto.id}'),
          );
        } else {
          // Mobile: use local path and queue for sync
          debugPrint('[ActivityFormNotifier] Mobile photo - using addPhoto with localPath');
          await _repository.addPhoto(
            activityId,
            photo.localPath,
            latitude: latitude,
            longitude: longitude,
          );
        }
      } catch (e, stackTrace) {
        // Log but don't fail - photo upload is non-critical
        debugPrint('[ActivityFormNotifier] ERROR uploading photo: $e');
        debugPrint('[ActivityFormNotifier] Stack trace: $stackTrace');
      }
    }
    
    debugPrint('[ActivityFormNotifier] addPhotosWithBytes completed');
  }

  /// Reset form state.
  void reset() {
    state = ActivityFormState();
  }
}

/// Provider for activity form notifier.
final activityFormNotifierProvider =
    StateNotifierProvider.autoDispose<ActivityFormNotifier, ActivityFormState>(
        (ref) {
  final repository = ref.watch(activityRepositoryProvider);
  final remoteDataSource = ref.watch(activityRemoteDataSourceProvider);
  return ActivityFormNotifier(repository, remoteDataSource);
});

// ==========================================
// Execution State
// ==========================================

/// State for activity execution (GPS validation).
class ActivityExecutionState {
  ActivityExecutionState({
    this.isValidating = false,
    this.isValid = false,
    this.distanceMeters = 0,
    this.position,
    this.errorMessage,
    this.isOverride = false,
    this.overrideReason,
  });

  final bool isValidating;
  final bool isValid;
  final double distanceMeters;
  final GpsPosition? position;
  final String? errorMessage;
  final bool isOverride;
  final String? overrideReason;

  ActivityExecutionState copyWith({
    bool? isValidating,
    bool? isValid,
    double? distanceMeters,
    GpsPosition? position,
    String? errorMessage,
    bool? isOverride,
    String? overrideReason,
  }) {
    return ActivityExecutionState(
      isValidating: isValidating ?? this.isValidating,
      isValid: isValid ?? this.isValid,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      position: position ?? this.position,
      errorMessage: errorMessage,
      isOverride: isOverride ?? this.isOverride,
      overrideReason: overrideReason ?? this.overrideReason,
    );
  }

  /// Check if there was an error during GPS validation.
  bool get hasError => errorMessage != null && position == null;
}

/// Notifier for activity execution with GPS validation.
class ActivityExecutionNotifier extends StateNotifier<ActivityExecutionState> {
  ActivityExecutionNotifier(this._gpsService) : super(ActivityExecutionState());

  final GpsService _gpsService;

  /// Validate proximity to target location.
  Future<void> validateProximity({
    required double targetLat,
    required double targetLon,
    double radiusMeters = 500,
  }) async {
    state = state.copyWith(isValidating: true, errorMessage: null);

    final result = await _gpsService.validateActivityProximity(
      targetLat: targetLat,
      targetLon: targetLon,
      radiusMeters: radiusMeters,
    );

    state = state.copyWith(
      isValidating: false,
      isValid: result.isWithinRadius,
      distanceMeters: result.distanceMeters,
      position: result.currentPosition,
      errorMessage: result.errorMessage,
    );
  }

  /// Enable override mode with reason.
  void enableOverride(String reason) {
    state = state.copyWith(isOverride: true, overrideReason: reason);
  }

  /// Reset execution state.
  void reset() {
    state = ActivityExecutionState();
  }
}

/// Provider for activity execution notifier.
final activityExecutionNotifierProvider = StateNotifierProvider.autoDispose<
    ActivityExecutionNotifier, ActivityExecutionState>((ref) {
  final gpsService = ref.watch(gpsServiceProvider);
  return ActivityExecutionNotifier(gpsService);
});
