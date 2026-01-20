# 🛠️ Technology Stack

## LeadX CRM Technical Stack Detail

---

## 📋 Overview

LeadX CRM menggunakan stack modern yang dipilih berdasarkan kriteria:
- **Cross-platform**: Single codebase untuk iOS, Android, Web
- **Offline-first**: Native offline support
- **Developer productivity**: Fast development cycle
- **Cost-effective**: Optimal cost for startup scale
- **Scalable**: Ready for growth

---

## 📱 Frontend Stack

### Flutter Framework

| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.x | Cross-platform UI framework |
| **Dart** | 3.x | Programming language |

**Why Flutter:**
- ✅ Single codebase: iOS, Android, Web
- ✅ Native performance (compiled to ARM)
- ✅ Rich widget library (Material Design 3)
- ✅ Hot reload for fast development
- ✅ Strong typing with Dart
- ✅ Active community & Google backing

### State Management

| Package | Version | Purpose |
|---------|---------|---------|
| **Riverpod** | 2.x | State management |
| **flutter_hooks** | 0.20.x | Reactive hooks |

**Why Riverpod:**
- ✅ Compile-time safety
- ✅ Dependency injection built-in
- ✅ Better testing support than Provider
- ✅ No BuildContext required
- ✅ Supports async + caching

```dart
// Example: Customer list provider
@riverpod
Future<List<Customer>> customerList(CustomerListRef ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getAllCustomers();
}
```

### Navigation

| Package | Version | Purpose |
|---------|---------|---------|
| **go_router** | 12.x | Declarative routing |

**Why go_router:**
- ✅ Official Flutter package
- ✅ Declarative routing
- ✅ Deep linking support
- ✅ Nested navigation
- ✅ Web URL support

```dart
// Example: Route configuration
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: 'customers',
          builder: (context, state) => const CustomerListScreen(),
        ),
        GoRoute(
          path: 'customers/:id',
          builder: (context, state) => CustomerDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);
```

### Local Database

| Package | Version | Purpose |
|---------|---------|---------|
| **Drift** | 2.x | Local database (SQLite) |
| **drift_dev** | 2.x | Code generation |
| **sqlite3_flutter_libs** | 0.5.x | SQLite binaries |

**Why Drift:**
- ✅ Type-safe SQL queries
- ✅ Code generation from schema
- ✅ Migration support
- ✅ Reactive streams
- ✅ Web support (WASM)

```dart
// Example: Customer table definition
class Customers extends Table {
  UuidColumn get id => customType(const UuidType())();
  TextColumn get code => text().withLength(max: 20).unique()();
  TextColumn get name => text().withLength(max: 200)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

### Network & API

| Package | Version | Purpose |
|---------|---------|---------|
| **supabase_flutter** | 2.x | Supabase SDK |
| **dio** | 5.x | HTTP client (backup/advanced) |
| **connectivity_plus** | 5.x | Network status |

### UI Components

| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_svg** | 2.x | SVG rendering |
| **cached_network_image** | 3.x | Image caching |
| **shimmer** | 3.x | Loading skeletons |
| **flutter_slidable** | 3.x | Swipe actions |
| **pull_to_refresh** | 2.x | Pull-to-refresh |

### Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| **intl** | 0.18.x | Internationalization |
| **freezed** | 2.x | Immutable models |
| **json_serializable** | 6.x | JSON serialization |
| **flutter_secure_storage** | 9.x | Secure token storage |
| **geolocator** | 10.x | GPS location (with battery optimization) |
| **location** | 5.x | Background location tracking |
| **image_picker** | 1.x | Photo capture |
| **permission_handler** | 11.x | Permission handling |
| **package_info_plus** | 5.x | App info |
| **share_plus** | 7.x | Share functionality |
| **url_launcher** | 6.x | External links |
| **geocoding** | 2.x | Reverse geocoding for addresses |

---

## ☁️ Backend Stack (Supabase)

### Supabase Platform

| Service | Purpose |
|---------|---------|
| **PostgreSQL 15** | Primary database |
| **PostgREST** | Auto-generated REST API |
| **GoTrue** | Authentication |
| **Realtime** | WebSocket subscriptions |
| **Storage** | S3-compatible file storage |
| **Edge Functions** | Serverless functions (Deno) |

**Why Supabase:**
- ✅ PostgreSQL with full SQL support
- ✅ Auto-generated APIs (no backend coding)
- ✅ Built-in auth with JWT
- ✅ Row Level Security (RLS)
- ✅ Real-time subscriptions
- ✅ Self-host option available
- ✅ Cost-effective (Pro plan ~$25/mo)

### 🔄 Supabase vs VPS PostgreSQL: Perbandingan

Berikut perbandingan antara menggunakan **Supabase (Managed)** vs **VPS PostgreSQL (Self-Hosted)**:

| Aspek | Supabase (Managed) | VPS PostgreSQL |
|-------|-------------------|----------------|
| **Setup Time** | 5 menit | 2-4 jam |
| **Maintenance** | ❌ No maintenance | ✅ Update, patching, monitoring |
| **Backup** | ✅ Auto daily backup | ⚙️ Manual setup (pg_dump, cron) |
| **Scaling** | ✅ 1-click upgrade | ⚙️ Manual migration |
| **High Availability** | ✅ Built-in (Pro+) | ⚙️ Setup sendiri (complex) |
| **REST API** | ✅ Auto-generated (PostgREST) | ❌ Build sendiri |
| **Auth** | ✅ Built-in (GoTrue) | ❌ Build sendiri |
| **Realtime** | ✅ Built-in WebSocket | ❌ Build sendiri |
| **Storage** | ✅ Built-in S3 | ❌ Setup sendiri |
| **Edge Functions** | ✅ Built-in (Deno) | ❌ Setup sendiri |
| **Cost (400 users)** | ~$25/mo | ~$20-50/mo + time |
| **Control** | ⚠️ Limited | ✅ Full control |
| **Vendor Lock-in** | ⚠️ Some (mitigated by self-host option) | ❌ None |

#### Kapan Pilih Supabase?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ✅ PILIH SUPABASE JIKA:                                                    │
│                                                                              │
│  • Tim kecil (1-3 backend devs)                                             │
│  • Butuh cepat launch (MVP dalam minggu, bukan bulan)                       │
│  • Tidak punya dedicated DevOps                                             │
│  • Budget terbatas untuk infrastructure management                          │
│  • Butuh fitur standar: Auth, Storage, Realtime                            │
│  • Prefer managed service untuk fokus ke product                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Kapan Pilih VPS PostgreSQL?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ✅ PILIH VPS POSTGRESQL JIKA:                                              │
│                                                                              │
│  • Punya dedicated DevOps/DBA                                               │
│  • Compliance requirement yang strict (data harus di Indonesia)             │
│  • Butuh custom extensions yang tidak tersedia di Supabase                 │
│  • Volume query sangat tinggi (cost Supabase menjadi mahal)                │
│  • Sudah punya infrastructure existing                                      │
│  • Butuh full control atas database performance tuning                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Hybrid Option: Self-Hosted Supabase

Supabase menyediakan opsi **self-hosted** yang bisa di-deploy ke VPS sendiri:

```bash
# Deploy Supabase ke VPS menggunakan Docker
git clone https://github.com/supabase/supabase
cd supabase/docker
docker compose up -d
```

**Keuntungan Hybrid:**
- ✅ Full control atas server
- ✅ Data di Indonesia (compliance)
- ✅ Tetap dapat fitur Supabase (Auth, Realtime, dll)
- ⚠️ Tanggung jawab maintenance sendiri

#### Rekomendasi untuk LeadX (FINAL DECISION)

> **✅ KEPUTUSAN: Self-Hosted Supabase di VPS Biznet Gio**

| Fase | Infrastructure | Alasan |
|------|----------------|--------|
| **All Phases** | Self-Hosted Supabase @ VPS Biznet | Data di Indonesia, full control, compliance ready |

**Detail VPS:**
- Provider: Biznet Gio Neo Lite
- Location: Indonesia
- OS: Ubuntu 22.04 LTS
- Production: 8GB RAM, 4 vCPU
- Estimated Cost: ~Rp 400.000/bulan (Production)

Lihat [Deployment Guide](../09-implementation/deployment-guide.md) untuk detail setup.

### Database Extensions

| Extension | Purpose |
|-----------|---------|
| **PostGIS** | Geospatial queries, distance calculation |
| **uuid-ossp** | UUID generation |
| **plpgsql** | Stored procedures |
| **pg_trgm** | Fuzzy text search |

```sql
-- Example: Distance query using PostGIS
SELECT c.*, 
  ST_Distance(c.location::geography, ST_MakePoint(lng, lat)::geography) as distance
FROM customers c
WHERE ST_DWithin(c.location::geography, ST_MakePoint(lng, lat)::geography, 5000)
ORDER BY distance;
```

### Authentication

| Feature | Implementation |
|---------|----------------|
| Email/Password | GoTrue native |
| JWT tokens | Access + Refresh |
| Password reset | Email-based |
| Session management | Supabase client handles |

```dart
// Example: Login with Supabase
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);
```

### Row Level Security

```sql
-- Example: RLS policy for customers
CREATE POLICY "Users can view own customers"
ON customers FOR SELECT
TO authenticated
USING (
  assigned_rm_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM user_hierarchy
    WHERE ancestor_id = auth.uid()
    AND descendant_id = customers.assigned_rm_id
  )
);
```

### Edge Functions (Deno)

| Function | Purpose |
|----------|---------|
| `calculate-scores` | Weekly score calculation |
| `send-notification` | Push notification dispatch |
| `generate-report` | Report generation |

```typescript
// Example: Edge function
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Calculate scores logic
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

---

## 🚀 Infrastructure

### Hosting & CDN

| Service | Purpose | Cost |
|---------|---------|------|
| **VPS Biznet Gio** | Self-Hosted Supabase (Indonesia) | ~Rp 400.000/mo |
| **Cloudflare Pages** | Web admin hosting | Free |
| **Cloudflare CDN** | CDN, DDoS protection, DNS | Free |

### Server Specifications (Production)

| Spec | Value |
|------|-------|
| Provider | Biznet Gio Neo Lite 4 |
| Location | Indonesia (Jakarta) |
| RAM | 8 GB |
| vCPU | 4 cores |
| Storage | 100 GB SSD |
| OS | Ubuntu 22.04 LTS |
| Stack | Docker + Supabase |

### App Distribution

| Platform | Method |
|----------|--------|
| **Android** | Google Play Store |
| **iOS** | Apple App Store |
| **Web** | Cloudflare Pages |
| **Internal Testing** | Firebase App Distribution / TestFlight |

### Monitoring & Analytics

| Service | Purpose | Cost |
|---------|---------|------|
| **Sentry** | Error tracking, performance | Free tier |
| **Supabase Dashboard** | Database monitoring | Included |
| **Firebase Analytics** | User analytics (optional) | Free |

---

## 🔧 Development Tools

### IDE & Editors

| Tool | Purpose |
|------|---------|
| **VS Code** | Primary IDE |
| **Android Studio** | Android debugging, emulator |
| **Xcode** | iOS debugging, simulator |

### VS Code Extensions

| Extension | Purpose |
|-----------|---------|
| **Flutter** | Flutter development |
| **Dart** | Dart support |
| **Error Lens** | Inline error display |
| **GitLens** | Git integration |
| **Thunder Client** | API testing |

### Build & CI/CD

| Tool | Purpose |
|------|---------|
| **GitHub Actions** | CI/CD pipeline |
| **Fastlane** | iOS/Android deployment |
| **Codemagic** | Alternative CI (optional) |

```yaml
# Example: GitHub Actions workflow
name: Build & Deploy
on:
  push:
    branches: [main]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
```

### Testing Tools

| Tool | Purpose |
|------|---------|
| **flutter_test** | Unit & widget testing |
| **integration_test** | Integration testing |
| **mockito** | Mocking |
| **golden_toolkit** | Visual regression |

---

## 📦 Package Management

### pubspec.yaml Structure

```yaml
name: leadx_crm
description: LeadX CRM Mobile Application
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^12.1.0
  
  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.18
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # Utilities
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  intl: ^0.18.0
  
  # UI
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  
  # Location
  geolocator: ^10.1.0
  
  # Storage
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  drift_dev: ^2.14.0
  mockito: ^5.4.0
```

---

## 🔐 Security Stack

| Layer | Technology |
|-------|------------|
| **Authentication** | Supabase GoTrue + JWT (HS256 → RS256 migration planned) |
| **MFA** | Planned for Phase 2 (TOTP-based) |
| **Transport** | TLS 1.3 |
| **Database Access** | Row Level Security (with indexed policy columns) |
| **Local Storage** | SQLCipher (AES-256 encrypted SQLite) |
| **Token Storage** | Flutter Secure Storage (Keychain/Keystore) |
| **API Protection** | API keys + JWT + Rate Limiting |
| **Remote Wipe** | Planned for Phase 2 |

---

## 🏆 Industry Benchmark Comparison

LeadX CRM arsitektur dibandingkan dengan standar industri (Salesforce, HubSpot, enterprise SFA):

### Offline-First Capabilities

| Feature | Salesforce | HubSpot | LeadX |
|---------|------------|---------|-------|
| Offline View | ✅ Caching | ✅ Limited | ✅ Full SQLite |
| Offline Edit | ✅ Draft queue | ⚠️ Notes/Tasks only | ✅ Full CRUD |
| Conflict Resolution | ✅ Manual/Auto | ⚠️ Basic | ✅ Timestamp-based |
| Sync Strategy | ✅ Selective | ⚠️ On-connect | ✅ FIFO Queue |
| Local Encryption | ✅ SQLCipher 256-bit | ❓ Unknown | ✅ SQLCipher 256-bit |

> **LeadX Advantage**: Full offline CRUD dengan conflict resolution, setara dengan Salesforce.

### Security Features

| Feature | Salesforce | HubSpot | LeadX |
|---------|------------|---------|-------|
| MFA | ✅ Native | ✅ 2FA | 🔜 Phase 2 |
| SSO | ✅ SAML/OAuth | ✅ SAML | 🔜 Future |
| RLS/RBAC | ✅ Apex + Sharing | ✅ Custom | ✅ PostgreSQL RLS |
| Data Encryption (at-rest) | ✅ AES-256 | ✅ AES-256 | ✅ AES-256 |
| Remote Wipe | ✅ MDM | ❓ Unknown | 🔜 Phase 2 |
| Audit Trail | ✅ Full | ✅ Full | ✅ Full |

> **LeadX Status**: Core security sudah kuat, MFA dan remote wipe di-prioritaskan untuk Phase 2.

### GPS Tracking

| Feature | Enterprise SFA Standard | LeadX |
|---------|------------------------|-------|
| Mandatory GPS on Activity | ✅ | ✅ |
| Battery Optimization | ✅ distanceFilter | ✅ distanceFilter + desiredAccuracy |
| Background Tracking | ✅ Foreground Service | ✅ Planned |
| Location Encryption | ✅ E2E | ✅ TLS + RLS |
| Privacy Consent | ✅ Required | ✅ Required |
| Anti-Spoofing | ✅ Various | 🔜 Phase 2 |

### Best Practices Adopted

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INDUSTRY BEST PRACTICES CHECKLIST                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ✅ IMPLEMENTED:                                                             │
│  ├── Layered Architecture (UI → State → Repository → Data)                 │
│  ├── Repository Pattern for data abstraction                               │
│  ├── Riverpod for compile-time safe state management                       │
│  ├── Drift for type-safe SQLite queries                                    │
│  ├── RLS with hierarchical access (closure table pattern)                  │
│  ├── JWT authentication with auto-refresh                                  │
│  ├── SQLCipher 256-bit encryption for local database                       │
│  ├── Secure token storage (Keychain/Keystore)                              │
│  ├── Comprehensive audit logging                                            │
│  └── TLS 1.3 for all traffic                                               │
│                                                                              │
│  🔜 PLANNED (Phase 2):                                                       │
│  ├── MFA (Multi-Factor Authentication)                                     │
│  ├── JWT migration to RS256 (asymmetric)                                   │
│  ├── Remote wipe capability                                                 │
│  ├── Anti-GPS spoofing detection                                           │
│  └── MDM integration for enterprise                                         │
│                                                                              │
│  📊 BENCHMARK SOURCES:                                                       │
│  ├── Salesforce Mobile App Security Whitepaper                             │
│  ├── HubSpot CRM Security Documentation                                    │
│  ├── Flutter Official Architecture Guidelines                              │
│  ├── Supabase Production Security Checklist                                │
│  └── OWASP Mobile Security Guidelines                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 💰 Cost Estimate (Monthly)

| Service | Tier | Cost (IDR) | Cost (USD) |
|---------|------|------------|------------|
| VPS Biznet (Production) | Neo Lite 4 | Rp 400.000 | ~$25 |
| VPS Biznet (UAT) | Neo Lite 2 | Rp 200.000 | ~$13 |
| Cloudflare | Free | Rp 0 | $0 |
| Sentry | Free | Rp 0 | $0 |
| Domain (.id) | Annual | ~Rp 15.000/mo | ~$1 |
| Google Play | One-time $25 | ~Rp 30.000/mo | ~$2 |
| Apple Developer | $99/year | ~Rp 125.000/mo | ~$8 |
| **Total** | | **~Rp 770.000/mo** | **~$49/mo** |

> **Note:** Dengan self-hosted Supabase, tidak ada biaya per-request atau bandwidth limits. Cost lebih predictable.

---

## 📈 Scaling Path (VPS Biznet)

### Phase 1: MVP & UAT (Current)
- VPS Biznet Neo Lite 2 (4GB RAM)
- Single server (UAT + Development)
- ~50-100 test users
- Cost: ~Rp 200.000/mo

### Phase 2: Production Launch
- VPS Biznet Neo Lite 4 (8GB RAM)
- Dedicated production server
- ~400-500 users
- Cost: ~Rp 400.000/mo

### Phase 3: Growth
- VPS Biznet Neo Lite 8 (16GB RAM) atau
- Separate DB server + App server
- Read replicas if needed
- ~2,000+ users
- Cost: ~Rp 800.000-1.500.000/mo

### Phase 4: Enterprise (Future)
- Multiple VPS with load balancer
- Database clustering (Patroni/PgBouncer)
- Multi-region if required
- ~10,000+ users

---

## 📚 Related Documents

- [System Architecture](system-architecture.md) - Architecture overview
- [Offline-First Design](offline-first-design.md) - Offline strategy
- [Security Architecture](security-architecture.md) - Security details

---

*Stack ini dioptimalkan untuk produktivitas pengembangan dan cost-efficiency.*
