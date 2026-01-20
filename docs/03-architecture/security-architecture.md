# 🔐 Security Architecture

## Arsitektur Keamanan LeadX CRM

---

## 📋 Overview

Dokumen ini mendeskripsikan arsitektur keamanan LeadX CRM yang mencakup:
- Authentication & Authorization
- Data Protection
- Network Security
- Application Security
- Compliance

---

## 🏛️ Security Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SECURITY LAYERS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  LAYER 1: NETWORK SECURITY                                          │    │
│  │  ├── Cloudflare CDN (DDoS Protection, WAF)                         │    │
│  │  ├── HTTPS/TLS 1.3 (All traffic encrypted)                         │    │
│  │  └── VPS Firewall (UFW - Ports 80, 443, SSH only)                  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  LAYER 2: API GATEWAY (Kong)                                        │    │
│  │  ├── Rate Limiting                                                  │    │
│  │  ├── API Key Validation                                             │    │
│  │  └── Request/Response Logging                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  LAYER 3: AUTHENTICATION (Supabase GoTrue)                          │    │
│  │  ├── JWT Token Validation                                           │    │
│  │  ├── Session Management                                             │    │
│  │  └── Password Hashing (bcrypt)                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  LAYER 4: AUTHORIZATION (PostgreSQL RLS)                            │    │
│  │  ├── Row Level Security Policies                                    │    │
│  │  ├── Role-Based Access Control                                      │    │
│  │  └── Hierarchical Data Scoping                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                               │                                              │
│                               ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  LAYER 5: DATA PROTECTION                                           │    │
│  │  ├── Database Encryption (at-rest)                                  │    │
│  │  ├── Local DB Encryption (SQLCipher)                               │    │
│  │  └── Sensitive Data Masking                                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Authentication

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION FLOW                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. LOGIN REQUEST                                                            │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │  Flutter App │───▶│  Supabase    │───▶│  PostgreSQL  │                  │
│  │              │    │  GoTrue      │    │  users table │                  │
│  └──────────────┘    └──────────────┘    └──────────────┘                  │
│         │                   │                                               │
│         │                   ▼                                               │
│  2. TOKEN RESPONSE   ┌──────────────┐                                       │
│         │            │ Verify creds │                                       │
│         │            │ Generate JWT │                                       │
│         │            └──────────────┘                                       │
│         │                   │                                               │
│         ▼                   ▼                                               │
│  ┌──────────────┐    ┌──────────────┐                                       │
│  │ Store tokens │◀───│ Access Token │                                       │
│  │ securely     │    │ + Refresh    │                                       │
│  └──────────────┘    └──────────────┘                                       │
│                                                                              │
│  3. AUTHENTICATED REQUEST                                                   │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │  API Request │───▶│ Kong Gateway │───▶│  PostgREST   │                  │
│  │  + JWT Token │    │ Validate JWT │    │  + RLS       │                  │
│  └──────────────┘    └──────────────┘    └──────────────┘                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### JWT Token Structure

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user-uuid",
    "email": "user@askrindo.co.id",
    "role": "RM",
    "branch_id": "branch-uuid",
    "iat": 1706745600,
    "exp": 1706832000
  }
}
```

### Token Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| Access Token Expiry | 1 hour | Short-lived for security |
| Refresh Token Expiry | 7 days | Auto-refresh mechanism |
| Token Algorithm | HS256 | HMAC SHA-256 |
| Token Storage | Flutter Secure Storage | Encrypted keychain/keystore |

### Password Policy

| Requirement | Value |
|-------------|-------|
| Minimum Length | 8 characters |
| Uppercase Required | Yes (min 1) |
| Lowercase Required | Yes (min 1) |
| Number Required | Yes (min 1) |
| Special Character | Optional |
| Password History | Last 3 passwords |
| Lockout After | 5 failed attempts |
| Lockout Duration | 15 minutes |

---

## 🛡️ Authorization (Row Level Security)

### RLS Strategy

```sql
-- Enable RLS on all tables
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE pipelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
-- ... (all tables)
```

### Access Patterns by Role

| Role | Own Data | Team Data | Branch Data | Regional Data | All Data |
|------|----------|-----------|-------------|---------------|----------|
| RM | ✅ | ❌ | ❌ | ❌ | ❌ |
| BH | ✅ | ✅ (direct reports) | ❌ | ❌ | ❌ |
| BM | ✅ | ✅ | ✅ (own branch) | ❌ | ❌ |
| ROH | ✅ | ✅ | ✅ | ✅ (own region) | ❌ |
| Admin | ✅ | ✅ | ✅ | ✅ | ✅ |
| Superadmin | ✅ | ✅ | ✅ | ✅ | ✅ |

### RLS Implementation Patterns

#### Pattern 1: Owner-Based Access
```sql
-- RM can only see their own customers
CREATE POLICY "rm_own_customers" ON customers
FOR ALL
TO authenticated
USING (assigned_rm_id = auth.uid());
```

#### Pattern 2: Hierarchical Access (via closure table)
```sql
-- Supervisors can see subordinate's data
CREATE POLICY "supervisor_view_subordinate_customers" ON customers
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = auth.uid()
    AND descendant_id = customers.assigned_rm_id
  )
);
```

#### Pattern 3: Role-Based Full Access
```sql
-- Admins can see all
CREATE POLICY "admin_all_access" ON customers
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('ADMIN', 'SUPERADMIN')
  )
);
```

### User Hierarchy Closure Table

```sql
-- Precomputed hierarchy for efficient RLS
CREATE TABLE user_hierarchy (
  ancestor_id UUID NOT NULL,
  descendant_id UUID NOT NULL,
  depth INTEGER NOT NULL,
  PRIMARY KEY (ancestor_id, descendant_id)
);

-- Example: BH-1 supervises RM-1, RM-2
-- Entries:
-- (BH-1, BH-1, 0)  -- self
-- (BH-1, RM-1, 1)  -- direct report
-- (BH-1, RM-2, 1)  -- direct report

-- When BM-1 supervises BH-1:
-- (BM-1, BM-1, 0)  -- self
-- (BM-1, BH-1, 1)  -- direct report
-- (BM-1, RM-1, 2)  -- indirect (via BH-1)
-- (BM-1, RM-2, 2)  -- indirect (via BH-1)
```

---

## 🔒 Data Protection

### Data Classification

| Classification | Examples | Protection Level |
|----------------|----------|------------------|
| **Public** | App version, general UI | None |
| **Internal** | Customer names, addresses | Encrypted at rest |
| **Confidential** | Pipeline values, GPS coordinates | Encrypted + RLS |
| **Restricted** | Passwords, tokens, API keys | Encrypted + Not stored in DB |

### Encryption

#### In-Transit
| Layer | Method |
|-------|--------|
| Client ↔ CDN | TLS 1.3 |
| CDN ↔ VPS | TLS 1.3 |
| Internal Services | Docker network (isolated) |

#### At-Rest
| Layer | Method |
|-------|--------|
| PostgreSQL | Transparent Data Encryption (via VPS disk) |
| Local SQLite | SQLCipher (AES-256) |
| File Storage (MinIO) | Server-side encryption |
| Token Storage | Flutter Secure Storage (Keychain/Keystore) |

### Local Data Encryption (Mobile)

```dart
// Using SQLCipher with Drift
final database = AppDatabase(
  LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'leadx.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // Encrypt database with key from secure storage
        db.execute("PRAGMA key = '$encryptionKey'");
      },
    );
  }),
);
```

---

## 🌐 Network Security

### Firewall Rules (UFW)

```bash
# Default deny incoming
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (with fail2ban)
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

### Cloudflare Protection

| Feature | Status |
|---------|--------|
| DDoS Protection | ✅ Enabled |
| WAF (Web Application Firewall) | ✅ Enabled |
| Bot Protection | ✅ Enabled |
| SSL/TLS | ✅ Full (Strict) |
| Rate Limiting | ✅ 100 req/min per IP |

### API Rate Limiting (Kong)

| Endpoint | Rate Limit | Window |
|----------|------------|--------|
| `/auth/*` | 10 req | 1 minute |
| `/rest/*` | 100 req | 1 minute |
| `/storage/*` | 50 req | 1 minute |
| `/realtime/*` | No limit | WebSocket |

---

## 📱 Application Security

### Input Validation

```dart
// Example: Validate customer input
class CustomerValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama wajib diisi';
    }
    if (value.length > 200) {
      return 'Nama maksimal 200 karakter';
    }
    // Prevent XSS
    if (RegExp(r'[<>"\']').hasMatch(value)) {
      return 'Karakter tidak valid';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }
}
```

### SQL Injection Prevention

```dart
// Using Drift - parameterized queries
Future<List<Customer>> searchCustomers(String query) {
  return (select(customers)
    ..where((c) => c.name.like('%$query%')) // Drift escapes automatically
  ).get();
}

// Supabase client - also parameterized
final result = await supabase
  .from('customers')
  .select()
  .ilike('name', '%$query%'); // Parameterized
```

### Secure Storage

```dart
// Store tokens securely
final storage = FlutterSecureStorage();

Future<void> saveToken(String token) async {
  await storage.write(
    key: 'access_token',
    value: token,
    aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}
```

---

## 📊 Audit & Logging

### Audit Trail

```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_name VARCHAR(100) NOT NULL,
  record_id UUID NOT NULL,
  action VARCHAR(20) NOT NULL, -- CREATE, UPDATE, DELETE
  old_values JSONB,
  new_values JSONB,
  changed_by UUID REFERENCES users(id),
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

-- Trigger for automatic audit logging
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by)
  VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) END,
    auth.uid()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to critical tables
CREATE TRIGGER audit_customers
AFTER INSERT OR UPDATE OR DELETE ON customers
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

### Security Logging

| Event | Logged | Alert |
|-------|--------|-------|
| Login success | ✅ | ❌ |
| Login failure | ✅ | After 3 failures |
| Password change | ✅ | ❌ |
| Data export | ✅ | ✅ |
| Bulk delete | ✅ | ✅ |
| Admin actions | ✅ | ❌ |
| API errors | ✅ | If >10/min |

---

## ✅ Security Checklist

### Pre-Deployment
- [ ] All secrets in environment variables (not in code)
- [ ] JWT secret is random 32+ characters
- [ ] Database passwords are strong
- [ ] SSL certificates configured
- [ ] Firewall rules enabled
- [ ] RLS enabled on all tables
- [ ] Audit logging configured

### Regular Audits
- [ ] Weekly: Review failed login attempts
- [ ] Monthly: Review access patterns
- [ ] Quarterly: Penetration testing
- [ ] Annually: Full security audit

---

## 📚 Related Documents

- [Tech Stack](tech-stack.md) - Technology overview
- [Non-Functional Requirements](../02-requirements/non-functional-requirements.md) - Security requirements
- [Deployment Guide](../09-implementation/deployment-guide.md) - Secure deployment

---

*Security architecture version 1.0 - January 2025*
