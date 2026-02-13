# Stack Research: Stability Improvements for LeadX CRM

**Domain:** Flutter offline-first CRM reliability (sync, error handling, offline data patterns)
**Researched:** 2026-02-13
**Confidence:** MEDIUM-HIGH (core recommendations verified via pub.dev and official docs; some pattern recommendations based on multiple credible sources)

## Context

LeadX CRM is an existing Flutter/Supabase app. The core stack (Flutter, Supabase, Drift, Riverpod, Freezed) is established and not up for debate. This research focuses exclusively on **what to add or upgrade** to make the app reliable: sync that does not lose data, errors that do not crash the app, and offline behavior that actually works.

### Current Stack Snapshot (What We Have)

| Package | Current Version | Latest Available | Gap |
|---------|----------------|-----------------|-----|
| flutter_riverpod | 2.6.1 | 3.2.1 | MAJOR version behind |
| riverpod_generator | 2.6.2 | 4.0.3 | MAJOR version behind |
| drift | 2.22.1 | 2.31.0 | Minor versions behind |
| supabase_flutter | 2.8.3 | 2.12.0 | Minor versions behind |
| freezed | 2.5.7 | 3.2.5 | MAJOR version behind |
| connectivity_plus | 6.1.1 | 7.0.0 | MAJOR version behind |
| go_router | 14.6.3 | 17.1.0 | Multiple minors behind |
| dartz | 0.10.1 | 0.10.1 | Current, but deprecated ecosystem |
| logger | 2.5.0 | -- | Functional but limited |

**Critical observation:** Several core packages are MAJOR versions behind. Upgrading these is a stability prerequisite, not optional enhancement.

---

## Recommended Stack Additions

### 1. Structured Error Handling: Dart Native Sealed Result Type

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Custom `Result<T>` sealed class | N/A (Dart-native) | Replace `Either<Failure, T>` from dartz | Flutter official docs explicitly recommend sealed `Result` types over third-party FP libraries. Dart 3 sealed classes + pattern matching provide exhaustive error handling without external dependencies. dartz is unmaintained (last release 2022). |

**Confidence:** HIGH -- This is the official Flutter architecture recommendation ([Flutter docs: Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result)).

**Migration path:** Keep `dartz` temporarily while migrating repository by repository. The sealed Result class is ~15 lines of code:

```dart
sealed class Result<T> {
  const Result();
  factory Result.ok(T value) => Ok(value);
  factory Result.error(Exception error) => Error(error);
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.error);
  final Exception error;
}
```

**Why NOT fpdart:** fpdart 1.2.0 is well-maintained and more featureful, but the project already has dartz patterns. Migrating to another FP library is lateral movement. Migrating to the Dart-native pattern is forward movement toward zero-dependency error handling aligned with the Flutter team's guidance.

---

### 2. Crash Reporting and Error Monitoring: Sentry

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| sentry_flutter | ^9.13.0 | Crash reporting, performance monitoring, error tracking | Industry standard. Supports native crashes (Java/Kotlin/C/C++ on Android, ObjC/Swift on iOS). Free tier covers most small teams. Released just hours ago (2026-02-12), actively maintained by sentry.io verified publisher. |

**Confidence:** HIGH -- verified on pub.dev, version 9.13.0 published 2026-02-12.

**Why Sentry over Firebase Crashlytics:** LeadX uses Supabase, not Firebase. Adding Firebase solely for Crashlytics introduces an unnecessary dependency and SDK overhead. Sentry is backend-agnostic, has a generous free tier (5K errors/month), and provides better Dart-native error grouping.

---

### 3. Structured Logging: Talker

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| talker_flutter | ^5.1.13 | Structured logging with in-app log viewer, error history, log sharing | Replaces `debugPrint` scattered throughout codebase. Provides filterable log levels, in-app debug screen (TalkerScreen), navigation observer, and integrates with Sentry for forwarding. |
| talker_riverpod_logger | ^5.1.13 | Riverpod provider lifecycle logging | Logs provider creation, updates, disposal, and failures. Critical for debugging sync provider chains. |

**Confidence:** MEDIUM-HIGH -- verified on pub.dev (published 2026-01-26), well-adopted (1.1k+ likes on core talker package).

**Why NOT keep `logger` 2.5.0:** The current `logger` package provides basic pretty-printing but no structured log history, no in-app viewer, no Riverpod integration, and no error forwarding to Sentry. Talker does all of this with a unified API. The migration is additive (replace `debugPrint` calls), not a rewrite.

---

### 4. Reliable Connectivity Detection: internet_connection_checker_plus

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| internet_connection_checker_plus | ^2.9.1 | Verify actual internet reachability, not just network interface | `connectivity_plus` only checks if WiFi/mobile is available -- it cannot tell if you actually have internet. The current `ConnectivityService` already works around this with `checkServerReachability()`, but `internet_connection_checker_plus` provides a standardized, tested solution with subsecond response times. |

**Confidence:** MEDIUM -- verified on pub.dev (published ~2025-12-17). This package depends on connectivity_plus internally.

**Implementation note:** Keep `connectivity_plus` for network-type detection (WiFi vs mobile) but layer `internet_connection_checker_plus` on top for actual reachability verification. This replaces the custom `checkServerReachability()` method in `ConnectivityService` with a battle-tested library.

---

### 5. Retry Logic: retry Package

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| retry | ^3.1.2 | Exponential backoff with jitter for network operations | The current `SyncService` has manual retry counting but no backoff delay between retries. The `retry` package provides configurable exponential backoff with jitter out of the box. Simple API: `retry(() => supabase.from(table).insert(data), retryIf: (e) => e is SocketException)`. |

**Confidence:** MEDIUM -- verified on pub.dev. Last published May 2023, which is old, but the package is stable/complete (small surface area, no bugs to fix). From google.dev verified publisher.

**Why NOT dio_smart_retry:** LeadX does not use Dio. Supabase Flutter client uses its own HTTP layer. The generic `retry` package works with any Future, making it suitable for wrapping Supabase calls directly.

---

### 6. Background Sync: workmanager

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| workmanager | ^0.9.0 | Persistent background sync that survives app restarts | Current sync runs on a `Timer.periodic` inside the app -- if the app is killed, pending sync items wait until next app launch. `workmanager` wraps Android WorkManager and iOS BGTaskScheduler for true background execution. |

**Confidence:** MEDIUM -- verified on pub.dev (v0.9.0+3, published 2025-08-31). Actively maintained with federated plugin architecture. However, background execution on iOS is inherently limited and unreliable.

**Important caveats:**
- iOS limits background execution to ~30 seconds and schedules at OS discretion
- Background Dart isolate cannot access Flutter plugins that need platform channels without careful initialization
- Recommended as a Phase 2+ enhancement, not initial stability work
- The current `Timer.periodic` approach works well enough when the app is foregrounded

---

## Required Package Upgrades

These are not new additions but critical upgrades. Running on major-version-old packages is itself a stability risk.

### Priority 1: Drift Upgrade

| Technology | Target Version | Current | Why Upgrade |
|------------|---------------|---------|-------------|
| drift | ^2.31.0 | 2.22.1 | 9 minor versions of bug fixes, performance improvements, and migration tooling improvements. No breaking changes within 2.x. |
| drift_dev | ^2.31.0 | 2.22.1 | Must match drift version. |

**Confidence:** HIGH -- same major version, safe upgrade.

**Before upgrading:** Export current schema with `dart run drift_dev schema dump` to establish a migration baseline. This is critical and the project does not currently appear to use Drift's schema export tooling.

### Priority 2: Supabase Upgrade

| Technology | Target Version | Current | Why Upgrade |
|------------|---------------|---------|-------------|
| supabase_flutter | ^2.12.0 | 2.8.3 | Auth token refresh reliability improvements, realtime reconnection fixes, and connection pooling improvements. Directly addresses sync reliability. |

**Confidence:** HIGH -- same major version, safe upgrade. Multiple auth/session reliability fixes between 2.8 and 2.12.

### Priority 3: Connectivity Plus Upgrade

| Technology | Target Version | Current | Why Upgrade |
|------------|---------------|---------|-------------|
| connectivity_plus | ^7.0.0 | 6.1.1 | Major version bump. Check changelog for breaking changes before upgrading. Required by internet_connection_checker_plus. |

**Confidence:** MEDIUM -- major version bump requires migration review.

### Priority 4: Riverpod + Freezed (Deferred)

| Technology | Target Version | Current | Why Defer |
|------------|---------------|---------|-----------|
| flutter_riverpod | ^3.2.1 | 2.6.1 | MAJOR version. Riverpod 3 changes code generation patterns. Large migration surface across all providers. Do this AFTER stability work, not during. |
| riverpod_generator | ^4.0.3 | 2.6.2 | Must match Riverpod version. |
| freezed | ^3.2.5 | 2.5.7 | MAJOR version. Freezed 3 changes generated code patterns. Coordinate with Riverpod 3 migration. |

**Confidence:** HIGH that deferring is correct. Upgrading state management and model generation during a stability sprint introduces the opposite of stability. Plan this as a separate milestone.

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| PowerSync | Requires a third-party sync service (cloud or self-hosted), adds vendor dependency and cost. The project already has a working sync queue architecture with Drift + Supabase. Fix the existing sync engine instead of replacing it. | Improve current SyncService with retry, idempotency, and conflict resolution |
| Firebase Crashlytics | Adds Firebase SDK dependency to a Supabase project. Unnecessary SDK bloat and conflicting backend ecosystem. | Sentry (backend-agnostic) |
| fpdart | Lateral migration from one FP library (dartz) to another. Does not solve the problem, just changes the dependency. | Dart-native sealed Result type |
| Hive / ObjectBox | LeadX already uses Drift for local storage. Adding a second database creates data fragmentation and sync complexity. | Continue with Drift, upgrade to latest |
| Dio | Supabase Flutter has its own HTTP client. Adding Dio creates two HTTP layers, complicates interceptor chains, and does not improve reliability. | Wrap Supabase calls with the `retry` package |
| isar | Database is deprecated/archived by the author. Do not adopt. | Drift (already in use) |

---

## Stack Patterns by Concern

### Pattern: Sync Reliability

**Current problem:** Sync queue processes items but has no backoff, no idempotency, swallows errors with `debugPrint`, and the `_pullFromRemote` method wraps each entity pull in a bare try-catch that silently continues.

**Stack to fix it:**
- `retry` ^3.1.2 -- wrap each Supabase call in `retry()` with exponential backoff
- `sentry_flutter` ^9.13.0 -- capture and report failed sync operations
- `talker_flutter` ^5.1.13 -- structured logging instead of debugPrint
- Custom `Result<T>` sealed class -- force callers to handle errors

### Pattern: Error Recovery

**Current problem:** App uses `Either<Failure, T>` from dartz but many code paths catch exceptions and just `debugPrint` them. No crash reporting means errors in production are invisible.

**Stack to fix it:**
- `sentry_flutter` ^9.13.0 -- capture uncaught exceptions and track error frequency
- Dart-native `Result<T>` -- exhaustive pattern matching prevents unhandled error cases
- `talker_flutter` ^5.1.13 -- log errors with context, viewable in-app for debugging

### Pattern: Offline Data Integrity

**Current problem:** The `ConnectivityService` polls every 30 seconds but uses a custom server reachability check. The `SyncService` does not handle idempotency (replaying a create operation after a network timeout can create duplicates if the server received the first request).

**Stack to fix it:**
- `internet_connection_checker_plus` ^2.9.1 -- replace custom reachability with tested library
- Client-generated UUIDs (already in place via `uuid` package) -- natural idempotency key
- Upsert instead of insert in sync operations -- prevents duplicates on retry
- `supabase_flutter` ^2.12.0 -- improved token refresh prevents 401 errors during sync

---

## Version Compatibility Matrix

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| drift ^2.31.0 | drift_dev ^2.31.0, drift_flutter ^0.2.x | Must keep drift and drift_dev versions matched |
| supabase_flutter ^2.12.0 | flutter_riverpod ^2.6.1 (current) | No conflicts. Supabase is state-management-agnostic |
| sentry_flutter ^9.13.0 | Flutter SDK >=3.x | Supports Android, iOS, Web, desktop |
| talker_flutter ^5.1.13 | talker_riverpod_logger ^5.1.13 | Must keep talker packages on same version |
| connectivity_plus ^7.0.0 | internet_connection_checker_plus ^2.9.1 | ICCP depends on connectivity_plus internally |
| retry ^3.1.2 | Dart SDK >=3.x | No Flutter-specific dependencies, pure Dart |
| workmanager ^0.9.0 | Android API 23+, iOS 13+ | Does not support web platform |

---

## Installation

```yaml
# pubspec.yaml additions for stability milestone

dependencies:
  # Error Monitoring
  sentry_flutter: ^9.13.0

  # Structured Logging (replaces logger: ^2.5.0)
  talker_flutter: ^5.1.13
  talker_riverpod_logger: ^5.1.13

  # Reliable Connectivity
  internet_connection_checker_plus: ^2.9.1

  # Retry Logic
  retry: ^3.1.2

  # Upgrades (change existing versions)
  drift: ^2.31.0
  drift_flutter: ^0.2.4  # check for latest compatible
  supabase_flutter: ^2.12.0
  connectivity_plus: ^7.0.0

dev_dependencies:
  # Upgrade to match drift
  drift_dev: ^2.31.0
```

```bash
# Installation
flutter pub get

# After drift upgrade, export schema baseline
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/

# Regenerate code
dart run build_runner build --delete-conflicting-outputs
```

**Remove after migration complete:**
```yaml
  # Remove once Result<T> migration is done
  # dartz: ^0.10.1

  # Remove once talker is fully integrated
  # logger: ^2.5.0
```

---

## Sources

### Verified (HIGH confidence)
- [Flutter official docs: Offline-first patterns](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) -- architecture patterns, sync strategies
- [Flutter official docs: Result type](https://docs.flutter.dev/app-architecture/design-patterns/result) -- sealed Result class recommendation
- [pub.dev: sentry_flutter 9.13.0](https://pub.dev/packages/sentry_flutter) -- version and publication date verified
- [pub.dev: drift 2.31.0](https://pub.dev/packages/drift) -- version verified
- [pub.dev: supabase_flutter 2.12.0](https://pub.dev/packages/supabase_flutter) -- version verified
- [pub.dev: flutter_riverpod 3.2.1](https://pub.dev/packages/flutter_riverpod) -- version verified (deferred upgrade)
- [pub.dev: freezed 3.2.5](https://pub.dev/packages/freezed) -- version verified (deferred upgrade)
- [pub.dev: retry 3.1.2](https://pub.dev/packages/retry) -- version verified, google.dev publisher
- [pub.dev: connectivity_plus 7.0.0](https://pub.dev/packages/connectivity_plus) -- version verified
- [pub.dev: workmanager 0.9.0+3](https://pub.dev/packages/workmanager) -- version verified
- [Drift migration docs](https://drift.simonbinder.eu/migrations/) -- schema export and step-by-step migration

### Verified (MEDIUM confidence)
- [pub.dev: talker_flutter 5.1.13](https://pub.dev/packages/talker_flutter) -- version verified, well-adopted
- [pub.dev: talker_riverpod_logger 5.1.13](https://pub.dev/packages/talker_riverpod_logger) -- version verified
- [pub.dev: internet_connection_checker_plus 2.9.1](https://pub.dev/packages/internet_connection_checker_plus) -- version verified
- [Supabase auth sessions docs](https://supabase.com/docs/guides/auth/sessions) -- token refresh behavior

### WebSearch-informed (verified with multiple sources)
- [GeekyAnts: Offline-First Flutter Blueprint](https://geekyants.com/blog/offline-first-flutter-implementation-blueprint-for-real-world-apps) -- sync patterns
- [PowerSync pricing](https://www.powersync.com/pricing) -- evaluated and rejected (adds vendor dependency)
- [fpdart vs dartz comparison](https://medium.com/@yazanabedo112/functional-programming-experience-in-dart-a-journey-between-dartz-and-fpdart-afef3f97c45d) -- informed decision to go Dart-native

---
*Stack research for: LeadX CRM Stability Milestone*
*Researched: 2026-02-13*
