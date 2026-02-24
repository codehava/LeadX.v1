import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../../core/logging/app_logger.dart';

/// Service for GPS/location operations.
/// Handles location permissions, position fetching, and distance calculations.
class GpsService {
  final _log = AppLogger.instance;

  /// Location settings for high accuracy.
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Minimum distance (meters) before update
  );

  /// Timeout for location requests.
  static const Duration _locationTimeout = Duration(seconds: 30);

  /// Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions.
  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  /// Get current position.
  /// Returns null if location cannot be obtained.
  Future<GpsPosition?> getCurrentPosition() async {
    try {
      final permissionStatus = await checkAndRequestPermission();
      if (permissionStatus != LocationPermissionStatus.granted) {
        _log.warning('gps | Permission not granted: $permissionStatus');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ).timeout(_locationTimeout);

      return GpsPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      _log.error('gps | Error getting position: $e');
      return null;
    }
  }

  /// Get last known position (faster, less accurate).
  Future<GpsPosition?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      return GpsPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      _log.error('gps | Error getting last known position: $e');
      return null;
    }
  }

  /// Calculate distance between two points in meters.
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calculate distance using Haversine formula (for offline use).
  static double calculateDistanceHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Check if position is within radius of target.
  bool isWithinRadius(
    GpsPosition position,
    double targetLat,
    double targetLon, {
    double radiusMeters = 500,
  }) {
    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      targetLat,
      targetLon,
    );
    return distance <= radiusMeters;
  }

  /// Stream of position updates.
  Stream<GpsPosition> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings)
        .map((position) => GpsPosition(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
              timestamp: position.timestamp,
            ));
  }

  /// Open app settings (for permission denied forever).
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Validate proximity to target location for activity execution.
  /// Returns a result with current position, distance, and whether within radius.
  Future<ProximityValidationResult> validateActivityProximity({
    required double targetLat,
    required double targetLon,
    double radiusMeters = 500,
  }) async {
    try {
      final permissionStatus = await checkAndRequestPermission();
      if (permissionStatus != LocationPermissionStatus.granted) {
        return ProximityValidationResult(
          isWithinRadius: false,
          distanceMeters: 0,
          currentPosition: null,
          errorMessage: 'Location permission not granted: ${permissionStatus.name}',
        );
      }

      final position = await getCurrentPosition();
      if (position == null) {
        return ProximityValidationResult(
          isWithinRadius: false,
          distanceMeters: 0,
          currentPosition: null,
          errorMessage: 'Could not get current location',
        );
      }

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        targetLat,
        targetLon,
      );

      final withinRadius = distance <= radiusMeters;

      return ProximityValidationResult(
        isWithinRadius: withinRadius,
        distanceMeters: distance,
        currentPosition: position,
        errorMessage: withinRadius
            ? null
            : 'You are ${distance.toInt()}m from the target (max ${radiusMeters.toInt()}m)',
      );
    } catch (e) {
      _log.error('gps | Error validating proximity: $e');
      return ProximityValidationResult(
        isWithinRadius: false,
        distanceMeters: 0,
        currentPosition: null,
        errorMessage: 'Error validating proximity: $e',
      );
    }
  }
}

/// GPS position model.
class GpsPosition {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime? timestamp;

  const GpsPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.timestamp,
  });

  @override
  String toString() {
    return 'GpsPosition($latitude, $longitude, accuracy: ${accuracy.toStringAsFixed(1)}m)';
  }
}

/// Location permission status.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Result of proximity validation for activity execution.
class ProximityValidationResult {
  final bool isWithinRadius;
  final double distanceMeters;
  final GpsPosition? currentPosition;
  final String? errorMessage;

  const ProximityValidationResult({
    required this.isWithinRadius,
    required this.distanceMeters,
    this.currentPosition,
    this.errorMessage,
  });

  /// Check if validation was successful (got position, within radius).
  bool get isValid => currentPosition != null && isWithinRadius;

  /// Check if there was an error getting location.
  bool get hasError => errorMessage != null && currentPosition == null;

  @override
  String toString() {
    if (hasError) return 'ProximityValidationResult(error: $errorMessage)';
    return 'ProximityValidationResult(distance: ${distanceMeters.toInt()}m, valid: $isWithinRadius)';
  }
}
