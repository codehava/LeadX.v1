# Technology Stack

**Analysis Date:** 2026-02-13

## Languages

**Primary:**
- Dart 3.10.4+ - Mobile/web app logic in `lib/` directory
- TypeScript (Deno) - Supabase Edge Functions for admin operations

**Secondary:**
- SQL - Supabase migrations and triggers in `supabase/migrations/`

## Runtime

**Environment:**
- Flutter (cross-platform: iOS, Android, Web)
- Dart VM (mobile/native)
- WASM (web via drift_flutter)
- Supabase Edge Functions (Deno runtime)

**Package Manager:**
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter 3.x - UI framework for iOS, Android, Web
- Supabase 2.8.3 - Backend platform (PostgreSQL, Auth, Real-time)

**State Management:**
- Riverpod 2.6.1 - Reactive state management with code generation (`@riverpod`)
- Freezed 2.5.7 - Immutable model generation

**Navigation:**
- GoRouter 14.6.3 - Declarative routing with deep linking support

**Local Database:**
- Drift 2.22.1 - Type-safe SQLite ORM (WASM for web, native for mobile)
- sqlite3_flutter_libs 0.5.28 - Native SQLite binaries for iOS/Android
- drift_flutter 0.2.4 - Unified database API across web/native platforms

**UI Components:**
- Material Design 3 - Via Flutter MaterialApp
- fl_chart 0.69.0 - Charts for scoreboard/analytics display
- cached_network_image 3.4.1 - Image caching
- flutter_svg 2.0.16 - SVG rendering
- shimmer 3.0.0 - Loading skeleton screens
- flutter_slidable 3.1.1 - Swipe actions on list items
- pull_to_refresh_flutter3 2.0.2 - Pull-to-refresh UX
- table_calendar 3.1.3 - Calendar UI for scheduling

**Testing:**
- Flutter Test - Built-in test framework
- mocktail 1.0.4 - Mocking library for unit tests

**Build/Dev Tools:**
- build_runner 2.4.13 - Code generation orchestrator
- json_serializable 6.8.0 - JSON serialization code gen
- riverpod_generator 2.6.2 - Riverpod provider code generation
- drift_dev 2.22.1 - Drift ORM code generation
- flutter_lints 6.0.0 - Lint rules for code quality

## Key Dependencies

**Critical (Offline-First & Sync):**
- supabase_flutter 2.8.3 - Supabase SDK with auth, DB, realtime
- connectivity_plus 6.1.1 - Network connectivity monitoring for sync trigger
- dartz 0.10.1 - Either<Failure, T> for functional error handling

**Mobile Features:**
- geolocator 13.0.2 - GPS location for customer visits
- permission_handler 11.3.1 - Runtime permissions (camera, location, storage)
- image_picker 1.1.2 - Camera/gallery access for activity photos
- geocoding 3.0.0 - Reverse geocoding for address lookup
- flutter_secure_storage 9.2.3 - Encrypted local storage for credentials (unused currently, uses Supabase session storage)

**Cross-Platform:**
- package_info_plus 8.1.3 - App version info
- url_launcher 6.3.1 - Deep linking and URL handling
- share_plus 10.1.4 - Native share functionality
- path_provider 2.1.5 - App documents directory access
- path 1.9.0 - Path manipulation utilities
- uuid 4.5.1 - UUID generation for entity IDs

**Utilities:**
- intl 0.20.2 - Internationalization (Indonesian date formatting)
- logger 2.5.0 - Debug logging
- flutter_dotenv 5.2.1 - Environment variable loading from bundled `.env`
- equatable 2.0.7 - Value equality for models

## Configuration

**Environment:**
- `.env` file (bundled as asset, committed to repo)
- Loaded at app startup via `flutter_dotenv` in `lib/main.dart`

**Required Variables:**
```
SUPABASE_URL=https://ouhzsezcgtexsevostaw.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Optional Env Variables (via EnvConfig):**
- `DEBUG` - Debug mode (defaults to true)
- `API_TIMEOUT` - Network timeout in seconds (defaults to 30)
- `SYNC_INTERVAL` - Background sync interval in seconds (defaults to 30)
- `MAX_SYNC_RETRIES` - Sync retry attempts (defaults to 3)
- `GPS_DISTANCE_FILTER` - GPS update threshold in meters (defaults to 10)
- `GPS_TIMEOUT` - GPS acquisition timeout in seconds (defaults to 15)
- `VISIT_DISTANCE_THRESHOLD` - Customer visit validation distance in meters (defaults to 500)

See `lib/config/env/env_config.dart` for configuration access.

**Build Configuration:**
- `pubspec.yaml` - Dart/Flutter dependencies and assets
- `analysis_options.yaml` - Strict linter rules (no code generation files, tests excluded)
- `web/vercel.json` - Vercel SPA rewrite rules for web deployment

## Platform Requirements

**Development:**
- Dart SDK 3.10.4+
- Flutter 3.x SDK
- iOS 12.0+ (for native app)
- Android API 21+ (for native app)
- Modern browser with WASM support (for web)

**Production:**
- iOS 12.0+ (AppStore deployment)
- Android API 21+ (Play Store deployment)
- Web deployed on Vercel with SPA routing
- Supabase PostgreSQL backend (managed)
- Supabase Edge Functions (Deno runtime) for admin operations

## Database

**Local Storage:**
- Drift SQLite schema in `lib/data/database/app_database.dart`
- 30+ tables mirroring PostgreSQL backend
- WASM-based SQLite on web, native SQLite3 on iOS/Android
- Supports offline queries via `.watch()` streams
- Generated from `lib/data/database/tables/` table definitions

**Remote Storage:**
- Supabase PostgreSQL (same schema as local)
- Bi-directional sync via SyncService
- Sync queue table tracks pending operations

---

*Stack analysis: 2026-02-13*
