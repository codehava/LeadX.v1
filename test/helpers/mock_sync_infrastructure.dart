import 'dart:async';

import 'package:leadx_crm/data/database/app_database.dart';
import 'package:leadx_crm/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:leadx_crm/data/services/connectivity_service.dart';

// Note: Mocks are generated separately in each test file

/// Creates a test SyncQueueItem for testing.
SyncQueueItem createTestSyncQueueItem({
  int id = 1,
  String entityType = 'customer',
  String entityId = 'customer-1',
  String operation = 'create',
  String payload = '{"id": "customer-1", "name": "Test Customer"}',
  int retryCount = 0,
  String status = 'pending',
  DateTime? createdAt,
  String? lastError,
  DateTime? lastAttemptAt,
}) {
  return SyncQueueItem(
    id: id,
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    payload: payload,
    retryCount: retryCount,
    status: status,
    createdAt: createdAt ?? DateTime.now(),
    lastError: lastError,
    lastAttemptAt: lastAttemptAt,
  );
}

/// A fake connectivity service that allows controlling online state.
class FakeConnectivityService implements ConnectivityService {
  bool _isConnected = true;
  bool _isInitialized = false;
  final _connectivityController = StreamController<bool>.broadcast();

  @override
  bool get isConnected => _isConnected;

  @override
  bool get isOffline => !_isConnected;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Set the connection state for testing.
  void setConnected(bool connected) {
    _isConnected = connected;
    _connectivityController.add(connected);
  }

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  @override
  void dispose() {
    _connectivityController.close();
  }

  Future<bool> checkConnectivity() async => _isConnected;

  @override
  Future<bool> checkServerReachability() async => _isConnected;

  @override
  Future<void> waitForConnectivity({Duration? timeout}) async {
    if (_isConnected) return;
    // In tests, just complete immediately or wait for stream
    await _connectivityController.stream.firstWhere((connected) => connected);
  }
}

/// A tracking implementation of SyncQueueLocalDataSource for integration tests.
/// Records all operations for verification.
class TrackingSyncQueueDataSource implements SyncQueueLocalDataSource {
  final List<SyncQueueItem> _items = [];
  final List<String> _operations = [];
  final List<SyncConflict> _conflicts = [];
  int _nextId = 1;

  /// Get the recorded operations.
  List<String> get operations => List.unmodifiable(_operations);

  /// Get the current items in queue.
  List<SyncQueueItem> get items => List.unmodifiable(_items);

  /// Clear all items and operations.
  void reset() {
    _items.clear();
    _operations.clear();
    _conflicts.clear();
    _nextId = 1;
  }

  /// Add an item directly (for testing purposes).
  void addItemDirectly(SyncQueueItem item) {
    _items.add(item);
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async {
    _operations.add('getPendingItems');
    return _items.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<List<SyncQueueItem>> getRetryableItems({int maxRetries = 5}) async {
    _operations.add('getRetryableItems($maxRetries)');
    return _items
        .where((item) =>
            item.retryCount < maxRetries &&
            (item.status == 'pending' || item.status == 'failed'))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<int> addToQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) async {
    _operations.add('addToQueue($entityType, $entityId, $operation)');
    final id = _nextId++;
    _items.add(SyncQueueItem(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      retryCount: 0,
      status: 'pending',
      createdAt: DateTime.now(),
      lastError: null,
      lastAttemptAt: null,
    ));
    return id;
  }

  @override
  Future<void> markAsCompleted(int id) async {
    _operations.add('markAsCompleted($id)');
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> markAsFailed(int id, String error) async {
    _operations.add('markAsFailed($id, $error)');
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = SyncQueueItem(
        id: item.id,
        entityType: item.entityType,
        entityId: item.entityId,
        operation: item.operation,
        payload: item.payload,
        retryCount: item.retryCount,
        status: 'failed',
        createdAt: item.createdAt,
        lastError: error,
        lastAttemptAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> markAsDeadLetter(int id, String error) async {
    _operations.add('markAsDeadLetter($id, $error)');
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = SyncQueueItem(
        id: item.id,
        entityType: item.entityType,
        entityId: item.entityId,
        operation: item.operation,
        payload: item.payload,
        retryCount: item.retryCount,
        status: 'dead_letter',
        createdAt: item.createdAt,
        lastError: error,
        lastAttemptAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    _operations.add('incrementRetryCount($id)');
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = SyncQueueItem(
        id: item.id,
        entityType: item.entityType,
        entityId: item.entityId,
        operation: item.operation,
        payload: item.payload,
        retryCount: item.retryCount + 1,
        status: item.status,
        createdAt: item.createdAt,
        lastError: item.lastError,
        lastAttemptAt: DateTime.now(),
      );
    }
  }

  @override
  Future<int> clearCompletedItems({DateTime? olderThan}) async {
    _operations.add('clearCompletedItems');
    return 0;
  }

  @override
  Future<int> clearAll() async {
    _operations.add('clearAll');
    final count = _items.length;
    _items.clear();
    return count;
  }

  @override
  Stream<int> watchPendingCount() {
    return Stream.value(_items.length);
  }

  @override
  Future<int> getPendingCount() async {
    return _items.length;
  }

  @override
  Future<List<SyncQueueItem>> getItemsByEntityType(String entityType) async {
    return _items.where((item) => item.entityType == entityType).toList();
  }

  @override
  Future<SyncQueueItem?> getItemById(int id) async {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SyncQueueItem?> getPendingItemForEntity(
    String entityType,
    String entityId,
  ) async {
    try {
      return _items.firstWhere(
        (item) => item.entityType == entityType && item.entityId == entityId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasPendingOperation(String entityType, String entityId) async {
    return _items.any(
      (item) => item.entityType == entityType && item.entityId == entityId,
    );
  }

  @override
  Future<void> updatePayload(int id, String payload) async {
    _operations.add('updatePayload($id)');
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = SyncQueueItem(
        id: item.id,
        entityType: item.entityType,
        entityId: item.entityId,
        operation: item.operation,
        payload: payload,
        retryCount: item.retryCount,
        status: item.status,
        createdAt: item.createdAt,
        lastError: item.lastError,
        lastAttemptAt: item.lastAttemptAt,
      );
    }
  }

  @override
  Future<int> removeOperation(String entityType, String entityId) async {
    _operations.add('removeOperation($entityType, $entityId)');
    final count = _items
        .where((item) =>
            item.entityType == entityType && item.entityId == entityId)
        .length;
    _items.removeWhere((item) =>
        item.entityType == entityType && item.entityId == entityId);
    return count;
  }

  @override
  Future<List<SyncQueueItem>> getAllItems() async {
    return _items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> resetRetryCount(int id) async {
    _operations.add('resetRetryCount($id)');
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = SyncQueueItem(
        id: item.id,
        entityType: item.entityType,
        entityId: item.entityId,
        operation: item.operation,
        payload: item.payload,
        retryCount: 0,
        status: 'pending',
        createdAt: item.createdAt,
        lastError: null,
        lastAttemptAt: item.lastAttemptAt,
      );
    }
  }

  // ============================================
  // DEAD LETTER MANAGEMENT
  // ============================================

  @override
  Stream<int> watchDeadLetterCount() {
    return Stream.value(
      _items.where((item) => item.status == 'dead_letter').length,
    );
  }

  @override
  Future<List<SyncQueueItem>> getDeadLetterItems() async {
    return _items
        .where((item) => item.status == 'dead_letter')
        .toList()
      ..sort((a, b) =>
          (b.lastAttemptAt ?? b.createdAt).compareTo(a.lastAttemptAt ?? a.createdAt));
  }

  @override
  Future<void> discardDeadLetterItem(int id) async {
    _operations.add('discardDeadLetterItem($id)');
    _items.removeWhere((item) => item.id == id);
  }

  // ============================================
  // PRUNING
  // ============================================

  @override
  Future<int> pruneOldItems({required Duration completedRetention}) async {
    _operations.add('pruneOldItems');
    return 0;
  }

  @override
  Future<int> pruneExpiredDeadLetters({
    Duration expiry = const Duration(days: 30),
  }) async {
    _operations.add('pruneExpiredDeadLetters');
    return 0;
  }

  @override
  Future<int> pruneSyncConflicts({
    Duration olderThan = const Duration(days: 30),
  }) async {
    _operations.add('pruneSyncConflicts');
    return 0;
  }

  // ============================================
  // CONFLICT LOGGING
  // ============================================

  @override
  Future<int> insertConflict({
    required String entityType,
    required String entityId,
    required String localPayload,
    required String serverPayload,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required String winner,
    String resolution = 'lww',
  }) async {
    _operations.add('insertConflict($entityType, $entityId, $winner)');
    return _conflicts.length + 1;
  }

  @override
  Stream<int> watchRecentConflictCount({int days = 7}) {
    return Stream.value(_conflicts.length);
  }

  @override
  Future<List<SyncConflict>> getRecentConflicts({
    int days = 7,
    int limit = 50,
  }) async {
    return _conflicts.take(limit).toList();
  }
}
