import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for monitoring network connectivity.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    SupabaseClient? supabaseClient,
  })  : _connectivity = connectivity ?? Connectivity(),
        _supabaseClient = supabaseClient,
        // Default to true to avoid showing offline indicator immediately.
        // Will be properly updated by initialize() with actual connectivity check.
        _isConnected = true;

  final Connectivity _connectivity;
  final SupabaseClient? _supabaseClient;

  StreamController<bool>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollTimer;
  bool _isConnected;
  
  /// Polling interval for connectivity checks (30 seconds).
  static const Duration _pollInterval = Duration(seconds: 30);

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
    
    print('[ConnectivityService] Initial connectivity check: results=$results, isConnected=$_isConnected, kIsWeb=$kIsWeb');

    // On web, connectivity_plus has limited support
    // If we're on web and results show no connection, assume we're online
    // (since the app is running in a browser which requires internet)
    if (kIsWeb && !_isConnected) {
      print('[ConnectivityService] Web platform detected, assuming online');
      _isConnected = true;
    }

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      var connected = _hasConnection(results);
      
      // On web, if no connection detected, still assume online
      if (kIsWeb && !connected) {
        connected = true;
      }
      
      print('[ConnectivityService] Connectivity changed: results=$results, connected=$connected');
      
      if (connected != _isConnected) {
        _isConnected = connected;
        _controller?.add(_isConnected);
      }
    });

    // Start periodic polling for mobile platforms (connectivity_plus can miss events)
    if (!kIsWeb) {
      _startPeriodicPolling();
    }
  }

  /// Start periodic connectivity polling.
  void _startPeriodicPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      final results = await _connectivity.checkConnectivity();
      final connected = _hasConnection(results);
      
      if (connected != _isConnected) {
        print('[ConnectivityService] Poll detected change: $connected');
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
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.bluetooth ||
            result == ConnectivityResult.vpn ||
            result == ConnectivityResult.other,
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
    _pollTimer?.cancel();
    _subscription?.cancel();
    _controller?.close();
  }
}
