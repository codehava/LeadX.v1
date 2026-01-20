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
| **geolocator** | 10.x | GPS location |
| **image_picker** | 1.x | Photo capture |
| **permission_handler** | 11.x | Permission handling |
| **package_info_plus** | 5.x | App info |
| **share_plus** | 7.x | Share functionality |
| **url_launcher** | 6.x | External links |

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
| **Supabase Pro** | Backend hosting (Singapore) | $25/mo |
| **Cloudflare Pages** | Web admin hosting | Free |
| **Cloudflare CDN** | CDN, DDoS protection | Free |

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
| **Authentication** | Supabase GoTrue + JWT |
| **Transport** | TLS 1.3 |
| **Database Access** | Row Level Security |
| **Local Storage** | SQLCipher (encrypted SQLite) |
| **Token Storage** | Flutter Secure Storage |
| **API Protection** | API keys + JWT |

---

## 💰 Cost Estimate (Monthly)

| Service | Tier | Cost |
|---------|------|------|
| Supabase | Pro | $25 |
| Cloudflare | Free | $0 |
| Sentry | Free | $0 |
| Google Play | One-time $25 | ~$2/mo |
| Apple Developer | $99/year | ~$8/mo |
| **Total** | | **~$35/mo** |

---

## 📈 Scaling Path

### Phase 1: Startup (Current)
- Supabase Pro
- Single region (Singapore)
- ~500 users

### Phase 2: Growth
- Supabase Pro with add-ons
- Read replicas (if needed)
- ~2,000 users

### Phase 3: Enterprise
- Self-hosted Supabase option
- Multi-region deployment
- ~10,000+ users

---

## 📚 Related Documents

- [System Architecture](system-architecture.md) - Architecture overview
- [Offline-First Design](offline-first-design.md) - Offline strategy
- [Security Architecture](security-architecture.md) - Security details

---

*Stack ini dioptimalkan untuk produktivitas pengembangan dan cost-efficiency.*
