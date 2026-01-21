import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/gps_service.dart';

/// Provider for GPS service.
final gpsServiceProvider = Provider<GpsService>((ref) {
  return GpsService();
});

/// Provider for current GPS position.
/// Returns null if position could not be obtained.
final currentGpsPositionProvider = FutureProvider<GpsPosition?>((ref) async {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.getCurrentPosition();
});

/// Provider for GPS permission status.
final gpsPermissionStatusProvider = FutureProvider<LocationPermissionStatus>((ref) async {
  final gpsService = ref.watch(gpsServiceProvider);
  return gpsService.checkAndRequestPermission();
});
