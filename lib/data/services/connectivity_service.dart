import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for monitoring network connectivity.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    SupabaseClient? supabaseClient,
  })  : _connectivity = connectivity ?? Connectivity(),
        _supabaseClient = supabaseClient,
        // On web, default to true (browser requires internet to load app).
        // On mobile, default to false until we verify actual connectivity.
        _isConnected = kIsWeb;

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

    // Get initial connectivity status from platform
    final results = await _connectivity.checkConnectivity();
    final hasInterface = _hasConnection(results);

    debugPrint('[ConnectivityService] Initial connectivity check: results=$results, hasInterface=$hasInterface, kIsWeb=$kIsWeb');

    // On web, connectivity_plus has limited support
    // If we're on web, assume we're online (since the app is running in a browser)
    if (kIsWeb) {
      _isConnected = true;
      debugPrint('[ConnectivityService] Web platform detected, assuming online');
    } else if (hasInterface) {
      // On mobile, having a network interface doesn't mean we have internet
      // Verify by actually trying to reach the server
      debugPrint('[ConnectivityService] Verifying server reachability...');
      _isConnected = await checkServerReachability();
      debugPrint('[ConnectivityService] Server reachable: $_isConnected');
    } else {
      _isConnected = false;
    }

    // Emit initial state to the stream so UI gets the correct value immediately
    _controller?.add(_isConnected);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      var connected = _hasConnection(results);

      // On web, if no connection detected, still assume online
      if (kIsWeb && !connected) {
        connected = true;
      }

      // On mobile, verify actual server reachability when interface becomes available
      if (!kIsWeb && connected && !_isConnected) {
        debugPrint('[ConnectivityService] Interface available, verifying reachability...');
        connected = await checkServerReachability();
      }

      debugPrint('[ConnectivityService] Connectivity changed: results=$results, connected=$connected');

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
      final hasInterface = _hasConnection(results);

      // If we have an interface, verify actual server reachability
      final connected = hasInterface && await checkServerReachability();

      if (connected != _isConnected) {
        debugPrint('[ConnectivityService] Poll detected change: $connected (interface: $hasInterface)');
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
