# 📴 Offline-First Design Patterns

## Arsitektur dan Implementasi Offline-First LeadX CRM

---

## 📋 Overview

LeadX CRM dirancang dengan arsitektur **Offline-First**, yang berarti aplikasi tetap berfungsi penuh tanpa koneksi internet. Dokumen ini menjelaskan pattern, strategi, dan implementasi detail.

---

## 🎯 Design Principles

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Local First** | Local database adalah source of truth untuk UI |
| **Eventual Consistency** | Sync occurs when possible, not required |
| **Transparent to User** | Offline mode tidak memerlukan mode switch |
| **Graceful Degradation** | Features tetapi tersedia, dengan limitasi jelas |
| **Conflict Awareness** | User informed of conflicts, not surprised |

### User Experience Goals

1. **Seamless Transition** - User tidak perlu tahu online/offline
2. **No Data Loss** - Semua perubahan tersimpan dan ter-sync
3. **Clear Feedback** - Sync status selalu visible
4. **Quick Recovery** - Fast sync saat kembali online

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    OFFLINE-FIRST ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                           UI LAYER                                       ││
│  │                                                                          ││
│  │  • Reads from LOCAL DATABASE only                                        ││
│  │  • Never directly calls remote API                                       ││
│  │  • Reacts to database changes (streams)                                  ││
│  │                                                                          ││
│  └────────────────────────────┬────────────────────────────────────────────┘│
│                               │                                              │
│                               │ Streams                                      │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                      REPOSITORY LAYER                                    ││
│  │                                                                          ││
│  │  ┌─────────────────────────────────────────────────────────────────┐    ││
│  │  │                    CUSTOMER REPOSITORY                           │    ││
│  │  │                                                                  │    ││
│  │  │  READ:                                                          │    ││
│  │  │  ① Query Local Database (Drift)                                 │    ││
│  │  │  ② Return stream of local data                                  │    ││
│  │  │                                                                  │    ││
│  │  │  WRITE:                                                         │    ││
│  │  │  ① Save to Local Database (immediate)                          │    ││
│  │  │  ② Add to Sync Queue                                           │    ││
│  │  │  ③ Trigger sync if online                                      │    ││
│  │  │                                                                  │    ││
│  │  └─────────────────────────────────────────────────────────────────┘    ││
│  │                                                                          ││
│  └────────────────────────────┬────────────────────────────────────────────┘│
│                               │                                              │
│         ┌─────────────────────┼─────────────────────┐                       │
│         │                     │                     │                       │
│         ▼                     ▼                     ▼                       │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐                │
│  │ LOCAL DB     │     │ SYNC QUEUE   │     │ SYNC SERVICE │                │
│  │ (Drift)      │     │              │     │              │                │
│  │              │     │ • entity     │     │ • Monitor    │                │
│  │ • customers  │     │ • action     │     │   connection │                │
│  │ • pipelines  │     │ • payload    │     │ • Process    │                │
│  │ • activities │     │ • status     │     │   queue      │                │
│  │ • etc.       │     │ • retries    │     │ • Handle     │                │
│  │              │     │              │     │   conflicts  │                │
│  └──────────────┘     └──────────────┘     └──────────────┘                │
│                                                   │                         │
│                                                   │ When online             │
│                                                   ▼                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                         REMOTE API (Supabase)                           ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Patterns

### Pattern 1: Read Operation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          READ FLOW                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐    ┌───────────┐          │
│  │    UI     │ → │Repository │ →  │ Local DB  │  → │  Stream   │          │
│  │ (Widget)  │    │           │    │  (Drift)  │    │ to UI     │          │
│  └───────────┘    └───────────┘    └───────────┘    └───────────┘          │
│                                                                              │
│  Example:                                                                    │
│                                                                              │
│  // Provider watches local database stream                                   │
│  Stream<List<Customer>> watchAllCustomers() {                               │
│    return database.customersDao.watchAll();                                 │
│  }                                                                          │
│                                                                              │
│  // UI subscribes to provider                                               │
│  final customers = ref.watch(customerListProvider);                         │
│                                                                              │
│  Benefits:                                                                   │
│  ✓ Instant response (no network wait)                                       │
│  ✓ Works offline                                                            │
│  ✓ Reactive updates                                                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Pattern 2: Write Operation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          WRITE FLOW                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Step 1: Local Write (Immediate)                                            │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐                           │
│  │    UI     │ →  │Repository │ →  │ Local DB  │   ✓ Saved                 │
│  │ (Submit)  │    │ .create() │    │  INSERT   │                           │
│  └───────────┘    └───────────┘    └───────────┘                           │
│                                                                              │
│  Step 2: Queue for Sync                                                      │
│  ┌───────────┐    ┌───────────┐                                             │
│  │Repository │ →  │Sync Queue │   Status: PENDING                          │
│  │           │    │  INSERT   │                                             │
│  └───────────┘    └───────────┘                                             │
│                                                                              │
│  Step 3: UI Feedback                                                         │
│  ┌───────────┐                                                              │
│  │    UI     │   Shows success (local saved)                                │
│  │ Feedback  │   Shows sync indicator (pending)                             │
│  └───────────┘                                                              │
│                                                                              │
│  Step 4: Background Sync (when online)                                       │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐                           │
│  │Sync Svc   │ →  │ Supabase  │ →  │Update     │                           │
│  │ Process   │    │   API     │    │  Queue    │                           │
│  └───────────┘    └───────────┘    └───────────┘                           │
│                         │                                                    │
│                         ▼                                                    │
│  ┌───────────┐    ┌───────────┐                                             │
│  │ Update    │ ←  │ Server    │   Update local with server response        │
│  │ Local DB  │    │ Response  │   (e.g., server-generated fields)          │
│  └───────────┘    └───────────┘                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Pattern 3: Update Operation

```dart
// Repository implementation
Future<void> updateCustomer(Customer customer) async {
  // 1. Update local database immediately
  await _localDataSource.updateCustomer(customer.copyWith(
    updatedAt: DateTime.now(),
    syncStatus: SyncStatus.pending,
  ));
  
  // 2. Add to sync queue
  await _syncQueue.add(SyncOperation(
    entityType: 'customer',
    entityId: customer.id,
    action: SyncAction.update,
    payload: customer.toJson(),
    createdAt: DateTime.now(),
  ));
  
  // 3. Trigger sync if online (non-blocking)
  _syncService.triggerSync();
}
```

---

## 🔄 Sync Queue Implementation

### Queue Table Schema

```sql
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL,      -- 'customer', 'pipeline', 'activity'
    entity_id UUID NOT NULL,               -- ID of the record
    action VARCHAR(20) NOT NULL,           -- 'CREATE', 'UPDATE', 'DELETE'
    payload JSONB NOT NULL,                -- Full record data
    status VARCHAR(20) DEFAULT 'PENDING',  -- 'PENDING', 'IN_PROGRESS', 'SYNCED', 'FAILED'
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ,
    
    -- Ensure ordered processing
    CONSTRAINT sync_queue_order UNIQUE (entity_type, entity_id, created_at)
);

CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id);
```

### Drift Table Definition

```dart
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()(); // JSON string
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Queue Processing Logic

```dart
class SyncService {
  final SyncQueueDao _queueDao;
  final RemoteDataSource _remote;
  final LocalDataSource _local;
  
  Future<void> processQueue() async {
    // Get pending items in FIFO order
    final items = await _queueDao.getPendingItems(limit: 50);
    
    for (final item in items) {
      try {
        // Mark as in progress
        await _queueDao.updateStatus(item.id, SyncStatus.inProgress);
        
        // Process based on action
        switch (item.action) {
          case SyncAction.create:
            await _processCreate(item);
            break;
          case SyncAction.update:
            await _processUpdate(item);
            break;
          case SyncAction.delete:
            await _processDelete(item);
            break;
        }
        
        // Mark as synced
        await _queueDao.updateStatus(item.id, SyncStatus.synced);
        
      } catch (e) {
        await _handleSyncError(item, e);
      }
    }
  }
  
  Future<void> _handleSyncError(SyncQueueItem item, dynamic error) async {
    final newRetryCount = item.retryCount + 1;
    
    if (newRetryCount >= 3) {
      // Max retries reached, mark as failed
      await _queueDao.markFailed(item.id, error.toString());
      // Notify user
      await _notificationService.showSyncFailure(item);
    } else {
      // Update retry count, will be processed later
      await _queueDao.updateRetryCount(item.id, newRetryCount);
    }
  }
}
```

---

## ⚔️ Conflict Resolution

### Resolution Strategies

| Strategy | When to Use | Implementation |
|----------|-------------|----------------|
| **Server Wins** | Critical data, compliance | Always take server version |
| **Client Wins** | User preference, drafts | Always take client version |
| **Last Write Wins** | Non-critical updates | Compare timestamps |
| **Field Merge** | Collaborative editing | Merge non-conflicting fields |
| **Manual Resolution** | Important conflicts | Prompt user to choose |

### Default Strategy: Timestamp-Based with Notification

```dart
class ConflictResolver {
  
  ConflictResult resolve(LocalRecord local, ServerRecord server) {
    // Compare update timestamps
    if (local.updatedAt.isAfter(server.updatedAt)) {
      // Client is newer - push client changes
      return ConflictResult(
        action: ConflictAction.pushClient,
        notify: false,
      );
    } else if (server.updatedAt.isAfter(local.updatedAt)) {
      // Server is newer - accept server, notify user
      return ConflictResult(
        action: ConflictAction.acceptServer,
        notify: true,
        message: 'Data telah diperbarui oleh pengguna lain',
      );
    } else {
      // Same timestamp - try field merge
      return _attemptFieldMerge(local, server);
    }
  }
  
  ConflictResult _attemptFieldMerge(LocalRecord local, ServerRecord server) {
    final mergedFields = <String, dynamic>{};
    var hasConflict = false;
    
    for (final field in local.fields.keys) {
      if (local.fields[field] == server.fields[field]) {
        // Same value, no conflict
        mergedFields[field] = local.fields[field];
      } else if (local.dirtyFields.contains(field) && !server.dirtyFields.contains(field)) {
        // Only local changed this field
        mergedFields[field] = local.fields[field];
      } else if (!local.dirtyFields.contains(field) && server.dirtyFields.contains(field)) {
        // Only server changed this field
        mergedFields[field] = server.fields[field];
      } else {
        // Both changed - conflict
        hasConflict = true;
        break;
      }
    }
    
    if (hasConflict) {
      // Can't auto-merge, server wins with notification
      return ConflictResult(
        action: ConflictAction.acceptServer,
        notify: true,
        message: 'Konflik data terdeteksi. Versi server digunakan.',
      );
    }
    
    return ConflictResult(
      action: ConflictAction.merge,
      mergedData: mergedFields,
    );
  }
}
```

### Conflict UI

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SYNC CONFLICT DIALOG                                 │
│                                                                              │
│  ⚠️  Konflik Data Terdeteksi                                                │
│                                                                              │
│  Data "PT ABC Sejahtera" telah diubah oleh pengguna lain saat Anda offline.│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ Field          │ Versi Anda          │ Versi Server                    ││
│  ├────────────────┼─────────────────────┼─────────────────────────────────┤│
│  │ Alamat         │ Jl. Sudirman No. 1  │ Jl. Sudirman No. 10             ││
│  │ Telepon        │ 021-1234567         │ 021-7654321                     ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  [Gunakan Versi Saya]        [Gunakan Versi Server]        [Lihat Detail]  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📶 Connectivity Detection

### Network State Management

```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final BehaviorSubject<ConnectionStatus> _statusSubject = 
      BehaviorSubject.seeded(ConnectionStatus.unknown);
  
  Stream<ConnectionStatus> get statusStream => _statusSubject.stream;
  ConnectionStatus get currentStatus => _statusSubject.value;
  
  ConnectivityService() {
    _init();
  }
  
  void _init() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        _statusSubject.add(ConnectionStatus.offline);
      } else {
        // Verify actual connectivity by pinging server
        final isReachable = await _checkServerReachability();
        _statusSubject.add(
          isReachable ? ConnectionStatus.online : ConnectionStatus.offline
        );
      }
    });
  }
  
  Future<bool> _checkServerReachability() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/'),
        timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### Auto-Sync Trigger

```dart
class SyncTrigger {
  final ConnectivityService _connectivity;
  final SyncService _syncService;
  
  StreamSubscription? _subscription;
  
  void start() {
    _subscription = _connectivity.statusStream.listen((status) {
      if (status == ConnectionStatus.online) {
        // Just came online - trigger sync
        _syncService.startBackgroundSync();
      }
    });
  }
  
  void stop() {
    _subscription?.cancel();
  }
}
```

---

## 🔔 Sync Status UI

### Status Indicator Component

```dart
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);
    
    return switch (syncState) {
      SyncState.synced => const SizedBox.shrink(),
      SyncState.syncing => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Menyinkronkan...', style: TextStyle(fontSize: 12)),
        ],
      ),
      SyncState.pending => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_queue, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            '${syncState.pendingCount} perubahan menunggu',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      ),
      SyncState.offline => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text('Offline', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      SyncState.error => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red),
          SizedBox(width: 8),
          TextButton(
            onPressed: () => ref.read(syncServiceProvider).retryFailed(),
            child: Text('Sync gagal. Coba lagi?'),
          ),
        ],
      ),
    };
  }
}
```

### Sync Log/Queue View

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SYNC QUEUE                                          │
│                                                                              │
│  Last synced: 5 menit yang lalu                          [↻ Sync Sekarang] │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ PENDING (3)                                                              ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │ 🟡 Customer: PT XYZ          │ CREATE  │ 2 menit lalu                   ││
│  │ 🟡 Activity: Visit ABC       │ CREATE  │ 5 menit lalu                   ││
│  │ 🟡 Pipeline: PIP-00123       │ UPDATE  │ 10 menit lalu                  ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ FAILED (1)                                                 [Retry All]  ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │ 🔴 Customer: PT ABC          │ UPDATE  │ Server error     │ [Retry]    ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │ RECENTLY SYNCED (50)                                                     ││
│  ├─────────────────────────────────────────────────────────────────────────┤│
│  │ ✅ Activity: Call ABC        │ CREATE  │ 15 menit lalu                  ││
│  │ ✅ Pipeline: PIP-00122       │ CREATE  │ 20 menit lalu                  ││
│  │ ...                                                                      ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Initial Sync & Full Sync

### First-Time Sync Strategy

```dart
class InitialSyncService {
  
  Future<void> performInitialSync(String userId) async {
    // Show progress to user
    _progressNotifier.value = SyncProgress(stage: 'Initializing...', percent: 0);
    
    // 1. Fetch all reference/master data first (small tables)
    await _syncMasterData();
    _progressNotifier.value = SyncProgress(stage: 'Master data...', percent: 20);
    
    // 2. Fetch user's hierarchy (for RLS context)
    await _syncUserHierarchy(userId);
    _progressNotifier.value = SyncProgress(stage: 'User data...', percent: 30);
    
    // 3. Fetch user's customers (paginated)
    await _syncCustomers(userId);
    _progressNotifier.value = SyncProgress(stage: 'Customers...', percent: 50);
    
    // 4. Fetch user's pipelines
    await _syncPipelines(userId);
    _progressNotifier.value = SyncProgress(stage: 'Pipelines...', percent: 70);
    
    // 5. Fetch user's activities
    await _syncActivities(userId);
    _progressNotifier.value = SyncProgress(stage: 'Activities...', percent: 90);
    
    // 6. Fetch scores and cadence
    await _syncScores(userId);
    _progressNotifier.value = SyncProgress(stage: 'Complete!', percent: 100);
    
    // Mark initial sync complete
    await _preferences.setInitialSyncComplete(true);
  }
  
  Future<void> _syncCustomers(String userId) async {
    // Paginated fetch
    int page = 0;
    bool hasMore = true;
    
    while (hasMore) {
      final customers = await _remote.getCustomers(
        userId: userId,
        page: page,
        pageSize: 100,
      );
      
      await _local.insertCustomers(customers);
      
      hasMore = customers.length == 100;
      page++;
    }
  }
}
```

---

## 📚 Best Practices Summary

### Do's ✅

| Practice | Reason |
|----------|--------|
| Always write to local first | Immediate user feedback |
| Use streams for data display | Reactive, auto-updating UI |
| Show sync status clearly | User confidence |
| Handle all error cases | Prevent data loss |
| Test offline extensively | Core functionality |

### Don'ts ❌

| Practice | Reason |
|----------|--------|
| Block UI on network operations | Poor UX, app feels slow |
| Ignore sync errors | Data loss, user frustration |
| Queue indefinitely | Memory/storage issues |
| Hide offline status | User doesn't know state |
| Assume network available | Field conditions vary |

---

## 📚 Related Documents

- [System Architecture](system-architecture.md) - Overall architecture
- [Data Sync Strategy](data-sync-strategy.md) - Sync details
- [Tech Stack](tech-stack.md) - Technologies used

---

*Offline-first adalah fitur critical untuk field sales app. Implementasi yang baik menentukan adopsi user.*
