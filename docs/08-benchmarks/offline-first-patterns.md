# 📴 Offline-First Patterns

## Best Practices untuk Offline-First CRM

---

## 📋 Overview

Dokumen ini membahas pattern dan best practices untuk implementasi offline-first di LeadX CRM, berdasarkan benchmark dari CRM enterprise dan mobile-first applications.

---

## 🏢 Industry Benchmarks

### Enterprise CRM Offline Capabilities

| Platform | Offline Support | Sync Strategy | Storage |
|----------|-----------------|---------------|---------|
| **Salesforce Mobile** | Partial (selected records) | Server-wins | SQLite |
| **HubSpot Mobile** | Read-only offline | Online-first | Cache |
| **Zoho CRM** | Full offline | Conflict resolution UI | SQLite |
| **Microsoft Dynamics** | Partial | Server-wins | SQLite |
| **LeadX (Target)** | Full offline | Hybrid with UI | Drift/SQLite |

### Key Insights

- Enterprise CRMs umumnya prioritize server data
- Mobile-first CRMs (Zoho, Pipedrive) punya offline lebih baik
- Conflict resolution UI meningkatkan user trust

---

## 🔄 Sync Strategies

### 1. Optimistic Updates (LeadX Default)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          OPTIMISTIC UPDATE FLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User Action ─────▶ Local DB Updated ─────▶ UI Reflects Change              │
│                           │                                                  │
│                           ▼                                                  │
│                    Queue for Sync                                            │
│                           │                                                  │
│                           ▼                                                  │
│                    Background Sync to Server                                 │
│                           │                                                  │
│              ┌────────────┴────────────┐                                    │
│              ▼                         ▼                                    │
│         ✅ Success                ❌ Conflict                               │
│         (Confirm)                 (Resolve)                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Pro**: Responsive UX, immediate feedback
**Con**: Potential conflicts, rollback complexity

### 2. Pessimistic Updates

```
User Action ─────▶ Server Request ─────▶ Wait Response ─────▶ Update Local
```

**Pro**: Data consistency guaranteed
**Con**: Blocked on network, poor offline

### 3. Hybrid (LeadX Recommendation)

| Data Type | Strategy | Rationale |
|-----------|----------|-----------|
| Customer/Pipeline Create | Optimistic | User needs immediate feedback |
| Activity Log | Optimistic | Field work can't wait |
| Stage Change | Optimistic with validation | Business-critical |
| Settings/Config | Pessimistic | Infrequent, need accuracy |
| Reports | Online-only | Aggregated data |

---

## 🗄️ Local Storage Patterns

### Schema Synchronization

```sql
-- Sync metadata per record
ALTER TABLE customers ADD COLUMN _sync_status VARCHAR(20);
-- Values: 'SYNCED', 'PENDING_CREATE', 'PENDING_UPDATE', 'PENDING_DELETE', 'CONFLICT'

ALTER TABLE customers ADD COLUMN _last_synced_at TIMESTAMPTZ;
ALTER TABLE customers ADD COLUMN _local_updated_at TIMESTAMPTZ;
ALTER TABLE customers ADD COLUMN _server_version INTEGER;
```

### Sync Queue Table

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,         -- CREATE, UPDATE, DELETE
  payload TEXT,                 -- JSON data
  created_at TEXT NOT NULL,
  retry_count INTEGER DEFAULT 0,
  last_error TEXT,
  status TEXT DEFAULT 'PENDING' -- PENDING, PROCESSING, FAILED, COMPLETED
);
```

---

## ⚔️ Conflict Resolution

### Detection Methods

| Method | Description | LeadX Usage |
|--------|-------------|-------------|
| **Version Vector** | Compare version numbers | Primary method |
| **Timestamp** | Last-write-wins | Fallback |
| **Field-level** | Merge non-conflicting fields | For complex entities |

### Resolution Strategies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CONFLICT RESOLUTION UI                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ⚠️ Conflict Detected: Customer "PT ABC"                                    │
│  ─────────────────────────────────────────────────────────────────────      │
│                                                                              │
│  Field: Phone Number                                                         │
│                                                                              │
│  ┌─────────────────────┐    ┌─────────────────────┐                        │
│  │   YOUR CHANGE       │    │   SERVER VERSION    │                        │
│  │   021-5555-1234     │    │   021-5555-5678     │                        │
│  │   Changed: 5 min ago│    │   Changed: 2 min ago│                        │
│  │   By: You           │    │   By: Ahmad (RM)    │                        │
│  │                     │    │                     │                        │
│  │   [Keep Mine]       │    │   [Use Server]      │                        │
│  └─────────────────────┘    └─────────────────────┘                        │
│                                                                              │
│                        [Merge Both] [Decide Later]                          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Sync Performance Metrics

### Target Benchmarks

| Metric | Target | Measurement |
|--------|--------|-------------|
| Initial sync time | < 30 seconds | 1000 records |
| Incremental sync | < 5 seconds | Delta sync |
| Conflict rate | < 0.1% | Conflicts / syncs |
| Queue drain time | < 30 seconds | After coming online |

---

## 📚 Related Documents

- [Data Sync Strategy](../03-architecture/data-sync-strategy.md)
- [Offline-First Design](../03-architecture/offline-first-design.md)
- [Tech Stack](../03-architecture/tech-stack.md)

---

*Benchmark document - January 2025*
