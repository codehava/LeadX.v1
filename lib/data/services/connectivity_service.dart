import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for monitoring network connectivity.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    SupabaseClient? supabaseClient,
  })  : _connectivity = connectivity ?? Connectivity(),
        _supabaseClient = supabaseClient;

  final Connectivity _connectivity;
  final SupabaseClient? _supabaseClient;

  StreamController<bool>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = false;

  /// Stream of connectivity status changes.
  Stream<bool> get connectivityStream =>
      _controller?.stream ?? const Stream.empty();

  /// Current connectivity status.
  bool get isConnected => _isConnected;

  /// Check if device is currently offline.
  bool get isOffline => !_isConnected;

  /// Initialize the connectivity service.
  Future<void> initialize() async {
    _controller = StreamController<bool>.broadcast();

    // Get initial connectivity status
    final results = await _connectivity.checkConnectivity();
    _isConnected = _hasConnection(results);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _hasConnection(results);
      if (connected != _isConnected) {
        _isConnected = connected;
        _controller?.add(_isConnected);
      }
    });
  }

  /// Check if any connectivity result indicates an active connection.
  bool _hasConnection(List<ConnectivityResult> results) => results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );

  /// Check if the Supabase server is reachable.
  /// Returns true if we can successfully call a simple API.
  Future<bool> checkServerReachability() async {
    if (!_isConnected) return false;

    try {
      if (_supabaseClient == null) return false;

      // Try a simple health check - just check if we can reach the server
      // We use a short timeout to avoid blocking
      await _supabaseClient
          .from('app_settings')
          .select('key')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Wait for connectivity to be restored.
  /// Returns immediately if already connected.
  Future<void> waitForConnectivity({Duration? timeout}) async {
    if (_isConnected) return;

    final completer = Completer<void>();
    StreamSubscription<bool>? subscription;

    subscription = connectivityStream.listen((connected) {
      if (connected) {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    if (timeout != null) {
      unawaited(Future.delayed(timeout, () {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('Connectivity timeout'),
          );
        }
      }));
    }

    return completer.future;
  }

  /// Dispose of resources.
  void dispose() {
    _subscription?.cancel();
    _controller?.close();
  }
}
