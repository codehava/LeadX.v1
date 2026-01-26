import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/camera_service.dart';
import 'auth_providers.dart';

/// State for profile photo update operation
class ProfilePhotoState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ProfilePhotoState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProfilePhotoState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProfilePhotoState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Notifier for profile photo operations
class ProfilePhotoNotifier extends StateNotifier<ProfilePhotoState> {
  final Ref _ref;

  ProfilePhotoNotifier(this._ref) : super(const ProfilePhotoState());

  /// Upload new profile photo
  Future<bool> uploadPhoto({
    required String localPath,
    required Uint8List? bytes,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = _ref.read(authRepositoryProvider);
      final currentUser = await repository.getCurrentUser();

      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User tidak ditemukan',
        );
        return false;
      }

      // Upload photo to storage
      final uploadResult = await repository.uploadProfilePhoto(
        userId: currentUser.id,
        localPath: localPath,
        bytes: bytes,
      );

      if (uploadResult.isLeft()) {
        final failure = uploadResult.fold((l) => l, (r) => null);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure?.message ?? 'Upload gagal',
        );
        return false;
      }

      final photoUrl = uploadResult.fold((l) => '', (r) => r);

      // Update profile with new photo URL
      final updateResult = await repository.updateProfile(
        photoUrl: photoUrl,
      );

      if (updateResult.isLeft()) {
        final failure = updateResult.fold((l) => l, (r) => null);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure?.message ?? 'Update profil gagal',
        );
        return false;
      }

      // Refresh current user provider
      _ref.invalidate(currentUserProvider);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
      return false;
    }
  }

  /// Remove profile photo
  Future<bool> removePhoto() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = _ref.read(authRepositoryProvider);
      final currentUser = await repository.getCurrentUser();

      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User tidak ditemukan',
        );
        return false;
      }

      final result = await repository.removeProfilePhoto(currentUser.id);

      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure?.message ?? 'Gagal menghapus foto',
        );
        return false;
      }

      // Refresh current user provider
      _ref.invalidate(currentUserProvider);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
      return false;
    }
  }

  void clearState() {
    state = const ProfilePhotoState();
  }
}

/// Provider for profile photo operations
final profilePhotoNotifierProvider =
    StateNotifierProvider<ProfilePhotoNotifier, ProfilePhotoState>((ref) {
  return ProfilePhotoNotifier(ref);
});

/// Provider for camera service
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});
