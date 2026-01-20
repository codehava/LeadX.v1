# 🔄 Data Sync Strategy

## Strategi Sinkronisasi Data Offline-First LeadX CRM

---

## 📋 Overview

LeadX CRM menggunakan strategi **Offline-First** dimana local database (SQLite/Drift) adalah source of truth untuk UI, dengan sinkronisasi ke server (Supabase) ketika online.

---

## 🏛️ Sync Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SYNC ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   User      │───▶│  Local DB   │───▶│  Sync Queue │         │
│  │   Action    │    │  (Drift)    │    │             │         │
│  └─────────────┘    └─────────────┘    └──────┬──────┘         │
│                                               │                  │
│                                               ▼                  │
│                          ┌────────────────────────────────────┐ │
│                          │      Online?                       │ │
│                          │  ┌─────────┐    ┌─────────┐       │ │
│                          │  │   No    │    │   Yes   │       │ │
│                          │  └────┬────┘    └────┬────┘       │ │
│                          │       │              │             │ │
│                          │       ▼              ▼             │ │
│                          │  ┌─────────┐    ┌─────────┐       │ │
│                          │  │ Wait in │    │  Push   │       │ │
│                          │  │  Queue  │    │ to API  │       │ │
│                          │  └─────────┘    └─────────┘       │ │
│                          └────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Sync Queue

### Queue Table Structure

```sql
-- Local SQLite table
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,    -- 'customer', 'pipeline', 'activity'
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,          -- 'CREATE', 'UPDATE', 'DELETE'
  payload TEXT NOT NULL,         -- JSON data
  status TEXT DEFAULT 'PENDING', -- 'PENDING', 'IN_PROGRESS', 'SYNCED', 'FAILED'
  retry_count INTEGER DEFAULT 0,
  error_message TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT
);
```

### Sync Status Flow

```
PENDING → IN_PROGRESS → SYNCED
                     ↘ FAILED (after 3 retries)
```

---

## 🔄 Sync Process

### 1. Create/Update Flow

1. User performs action (create customer, update pipeline)
2. Save immediately to local DB
3. Add entry to sync_queue with status PENDING
4. If online, trigger sync
5. If offline, queue waits

### 2. Sync Trigger Events

| Event | Action |
|-------|--------|
| App becomes online | Process queue |
| Manual refresh | Process queue |
| Background timer | Process queue (every 5 min) |
| App foreground | Check & process queue |

### 3. Conflict Resolution

| Scenario | Resolution |
|----------|------------|
| Client newer | Apply client changes |
| Server newer | Keep server, update local |
| Same timestamp | Merge or prompt user |

```dart
// Conflict detection
if (clientUpdatedAt > serverUpdatedAt) {
  // Client wins - push to server
} else if (serverUpdatedAt > clientUpdatedAt) {
  // Server wins - update local
} else {
  // Conflict - merge or prompt
}
```

---

## ⚡ Sync Priority

### Priority Levels

| Priority | Entity | Reason |
|----------|--------|--------|
| 1 (Highest) | Activities | GPS data, time-sensitive |
| 2 | Pipelines | Business critical |
| 3 | Customers | Core data |
| 4 (Lowest) | Settings | Can wait |

### Batch Processing

```dart
// Process queue in batches
const BATCH_SIZE = 10;
const MAX_RETRIES = 3;

Future<void> processQueue() async {
  final pendingItems = await queue.getByStatus('PENDING', limit: BATCH_SIZE);
  
  for (final item in pendingItems) {
    try {
      await syncItem(item);
      await queue.markSynced(item.id);
    } catch (e) {
      if (item.retryCount >= MAX_RETRIES) {
        await queue.markFailed(item.id, e.toString());
      } else {
        await queue.incrementRetry(item.id);
      }
    }
  }
}
```

---

## 📱 Implementation

### Drift Table

```dart
class SyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Sync Service

```dart
class SyncService {
  final LocalDatabase localDb;
  final SupabaseClient supabase;
  final ConnectivityService connectivity;
  
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await localDb.syncQueue.insert(SyncQueueCompanion(
      id: Value(uuid.v4()),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payload: Value(jsonEncode(payload)),
    ));
    
    if (await connectivity.isOnline) {
      processQueue();
    }
  }
}
```

---

## 📚 Related Documents

- [Offline-First Design](offline-first-design.md)
- [System Architecture](system-architecture.md)
- [Tech Stack](tech-stack.md)

---

*Dokumen ini adalah bagian dari LeadX CRM Architecture Documentation.*
