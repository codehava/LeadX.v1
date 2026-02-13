import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../core/logging/app_logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for camera and photo operations.
/// Handles photo capture, gallery picking, and image processing.
class CameraService {
  final _log = AppLogger.instance;

  CameraService() : _picker = ImagePicker();

  final ImagePicker _picker;

  /// Take a photo using the device camera.
  /// Returns the captured photo info or null if cancelled/failed.
  Future<CapturedPhoto?> capturePhoto({
    int imageQuality = 70,
    double? maxWidth = 1920,
    double? maxHeight = 1920,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return null;

      // Copy to app directory for persistence
      final savedPath = await _copyToAppDirectory(image.path);

      return CapturedPhoto(
        localPath: savedPath,
        takenAt: DateTime.now(),
        originalPath: image.path,
      );
    } catch (e) {
      _log.error('camera | Error capturing photo: $e');
      return null;
    }
  }

  /// Pick a photo from the device gallery.
  /// Returns the picked photo info or null if cancelled/failed.
  Future<CapturedPhoto?> pickFromGallery({
    int imageQuality = 70,
    double? maxWidth = 1920,
    double? maxHeight = 1920,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;

      // On web, we can't copy to file system, use blob URL directly
      if (kIsWeb) {
        // Read bytes for later upload
        final bytes = await image.readAsBytes();
        _log.debug('camera | Web photo picked, ${bytes.length} bytes');
        return CapturedPhoto(
          localPath: image.path, // Blob URL on web
          takenAt: DateTime.now(),
          originalPath: image.path,
          bytes: bytes, // Store bytes for web upload
          fileName: image.name,
        );
      }

      // On mobile, copy to app directory for persistence
      final savedPath = await _copyToAppDirectory(image.path);

      return CapturedPhoto(
        localPath: savedPath,
        takenAt: DateTime.now(),
        originalPath: image.path,
      );
    } catch (e) {
      _log.error('camera | Error picking from gallery: $e');
      return null;
    }
  }

  /// Pick multiple photos from the device gallery.
  Future<List<CapturedPhoto>> pickMultipleFromGallery({
    int imageQuality = 70,
    double? maxWidth = 1920,
    double? maxHeight = 1920,
    int? limit,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        limit: limit,
      );

      final List<CapturedPhoto> results = [];
      for (final image in images) {
        final savedPath = await _copyToAppDirectory(image.path);
        results.add(CapturedPhoto(
          localPath: savedPath,
          takenAt: DateTime.now(),
          originalPath: image.path,
        ));
      }

      return results;
    } catch (e) {
      _log.error('camera | Error picking multiple: $e');
      return [];
    }
  }

  /// Copy image to app directory for persistence.
  /// Returns the new file path.
  Future<String> _copyToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'activity_photos'));
    
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = path.join(photosDir.path, fileName);

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    return destPath;
  }

  /// Delete a local photo file.
  Future<bool> deleteLocalPhoto(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      _log.error('camera | Error deleting photo: $e');
      return false;
    }
  }

  /// Get file size in bytes.
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if camera is available.
  Future<bool> isCameraAvailable() async {
    // On web, camera may not be available
    if (kIsWeb) return false;
    // On mobile, assume camera is available
    return true;
  }
}

/// Captured photo information.
class CapturedPhoto {
  final String localPath;
  final DateTime takenAt;
  final String? originalPath;
  final double? latitude;
  final double? longitude;
  final Uint8List? bytes; // For web: store bytes directly
  final String? fileName; // Original file name from picker

  const CapturedPhoto({
    required this.localPath,
    required this.takenAt,
    this.originalPath,
    this.latitude,
    this.longitude,
    this.bytes,
    this.fileName,
  });

  /// Check if photo has geotag from EXIF.
  bool get hasGeotag => latitude != null && longitude != null;

  /// Check if this is a web photo with bytes.
  bool get isWebPhoto => bytes != null;

  /// Get file name from path or stored fileName.
  String get displayFileName => fileName ?? path.basename(localPath);

  @override
  String toString() => 'CapturedPhoto($displayFileName, takenAt: $takenAt)';
}
