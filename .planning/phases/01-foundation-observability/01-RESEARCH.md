# Phase 1: Foundation & Observability - Research

**Researched:** 2026-02-13
**Domain:** Drift schema migration, error type system, crash reporting, structured logging
**Confidence:** HIGH

## Summary

Phase 1 lays infrastructure that all subsequent phases depend on: consistent sync metadata across Drift tables, a sealed error hierarchy for sync failures, Sentry crash reporting, and Talker structured logging. The codebase currently has significant sync metadata inconsistencies across 12+ syncable entity types (some use `lastSyncAt`, some use `syncedAt`, some have neither; some lack `isPendingSync`). There are 273 `debugPrint` calls across 26 files with ad-hoc `[SyncService]` prefixes that need systematic replacement. The `logger` package is declared in `pubspec.yaml` but never imported anywhere -- it should be removed when Talker is added.

The existing error hierarchy (`lib/core/errors/exceptions.dart` and `failures.dart`) provides a foundation but has no sync-specific classification of retryable vs permanent errors. The current `SyncService._processItem()` catches `SocketException` and `TimeoutException` but wraps them in generic `Exception` with string messages, losing type information.

**Primary recommendation:** Execute in this order: (1) sealed SyncError hierarchy, (2) schema standardization migration, (3) Sentry integration, (4) Talker logging replacement. The error hierarchy is purely additive and risk-free. Schema migration is the highest-risk item and should have the migration tested against a production database copy before deployment. Sentry and Talker can be done in parallel but Talker should configure its Sentry observer to forward errors.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| sentry_flutter | ^9.13.0 | Crash reporting, unhandled exception capture | Industry standard for Flutter crash reporting; captures native crashes on iOS/Android |
| talker | ^5.1.13 | Structured logging core | Module-prefixed logging with levels, observers, and custom log types |
| talker_flutter | ^5.1.13 | Flutter-specific logging UI (TalkerScreen, route observer) | In-app log viewer for debugging; TalkerRouteObserver for navigation breadcrumbs |
| talker_riverpod_logger | ^5.1.13 | Riverpod provider event logging via Talker | Unified logging when already using Talker + Riverpod |
| drift | 2.22.1 (existing) | Schema migration for sync metadata columns | Already in project; migration API handles addColumn safely |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| drift_dev | 2.22.1 (existing) | Schema export and migration testing tools | `dart run drift_dev schema dump` for baseline export |

### Remove
| Library | Reason |
|---------|--------|
| logger: ^2.5.0 | Declared in pubspec.yaml but never imported anywhere in lib/; replaced by Talker |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Talker | logger (current dep) | logger is simpler but has no observer pattern, no UI, no Sentry bridge, no module prefixes |
| Talker | logging (dart:developer) | Built-in but no structured observers, no UI, no integration ecosystem |
| Sentry | Firebase Crashlytics | Crashlytics requires Firebase setup; Sentry is backend-agnostic and works with Supabase projects |

**Installation:**
```yaml
# pubspec.yaml additions
dependencies:
  sentry_flutter: ^9.13.0
  talker: ^5.1.13
  talker_flutter: ^5.1.13
  talker_riverpod_logger: ^5.1.13

# Remove:
#   logger: ^2.5.0  (unused)
```

## Architecture Patterns

### Recommended Project Structure Changes
```
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart       # Existing (unchanged)
│   │   ├── failures.dart         # Existing (unchanged)
│   │   └── sync_errors.dart      # NEW: Sealed SyncError hierarchy
│   └── logging/
│       ├── app_logger.dart       # NEW: Singleton Talker instance + module loggers
│       └── sentry_observer.dart  # NEW: TalkerObserver that forwards to Sentry
├── data/
│   └── database/
│       └── app_database.dart     # MODIFIED: Migration v9 -> v10
```

### Pattern 1: Sealed SyncError Hierarchy
**What:** A sealed class hierarchy that classifies sync failures by recoverability (retryable vs permanent) with exhaustive pattern matching.
**When to use:** In SyncService._processItem() catch blocks, in repository sync methods, in error display logic.
**Example:**
```dart
// lib/core/errors/sync_errors.dart
sealed class SyncError {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;
  final String? entityType;
  final String? entityId;

  const SyncError({
    required this.message,
    this.originalError,
    this.stackTrace,
    this.entityType,
    this.entityId,
  });

  /// Whether this error is retryable (network issues, timeouts, 5xx)
  bool get isRetryable;
}

// Retryable errors (should retry with backoff)
final class NetworkSyncError extends SyncError {
  const NetworkSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });
  @override
  bool get isRetryable => true;
}

final class TimeoutSyncError extends SyncError {
  const TimeoutSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });
  @override
  bool get isRetryable => true;
}

final class ServerSyncError extends SyncError {
  final int statusCode;
  const ServerSyncError({
    required this.statusCode,
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });
  @override
  bool get isRetryable => statusCode >= 500; // 5xx retryable, 4xx not
}

// Permanent errors (should NOT retry)
final class AuthSyncError extends SyncError {
  const AuthSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });
  @override
  bool get isRetryable => false;
}

final class ValidationSyncError extends SyncError {
  final Map<String, dynamic>? details;
  const ValidationSyncError({
    required super.message,
    this.details,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });
  @override
  bool get isRetryable => false;
}

final class ConflictSyncError extends SyncError {
  const ConflictSyncError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.entityType,
    super.entityId,
  });
  @override
  bool get isRetryable => false;
}
```

### Pattern 2: Module-Prefixed Talker Logging
**What:** A singleton Talker instance with module-specific loggers that prefix all messages.
**When to use:** Replace every `debugPrint('[SyncService] ...')` call.
**Example:**
```dart
// lib/core/logging/app_logger.dart
import 'package:talker/talker.dart';

class AppLogger {
  static late final Talker instance;

  /// Initialize once at app startup (before SentryFlutter.init)
  static void init({List<TalkerObserver>? observers}) {
    instance = Talker(
      settings: TalkerSettings(
        // In release mode, disable console output (Sentry handles it)
        enabled: true,
      ),
      observer: observers != null ? TalkerMultiObserver(observers) : null,
    );
  }

  /// Create a module-scoped logger that prefixes all messages
  static Talker module(String prefix) {
    // Talker doesn't have built-in module scoping, so we use custom log types
    // Alternative: just use the main instance with prefix in message
    return instance;
  }
}

// Usage in SyncService:
class SyncService {
  final _log = AppLogger.instance;

  Future<SyncResult> processQueue() async {
    _log.info('sync.queue | processQueue called, isSyncing=$_isSyncing');
    // ...
    _log.debug('sync.push | Processing item: ${item.entityType}/${item.entityId}');
    // ...
    _log.error('sync.push | Failed: ${item.entityType}/${item.entityId}', e, st);
  }
}
```

### Pattern 3: Sentry + Talker Bridge
**What:** A TalkerObserver that forwards errors and exceptions to Sentry with context.
**When to use:** Initialized once at app startup. All Talker error/exception calls automatically go to Sentry.
**Example:**
```dart
// lib/core/logging/sentry_observer.dart
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker/talker.dart';

class SentryTalkerObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    Sentry.captureException(
      err.error,
      stackTrace: err.stackTrace,
    );
    super.onError(err);
  }

  @override
  void onException(TalkerException exception) {
    Sentry.captureException(
      exception.exception,
      stackTrace: exception.stackTrace,
    );
    super.onException(exception);
  }

  @override
  void onLog(TalkerLog log) {
    // Forward warning+ level logs as Sentry breadcrumbs
    if (log.logLevel.index >= LogLevel.warning.index) {
      Sentry.addBreadcrumb(Breadcrumb(
        message: log.message,
        level: _mapLevel(log.logLevel),
        category: 'talker',
      ));
    }
    super.onLog(log);
  }

  SentryLevel _mapLevel(LogLevel level) {
    return switch (level) {
      LogLevel.critical => SentryLevel.fatal,
      LogLevel.error => SentryLevel.error,
      LogLevel.warning => SentryLevel.warning,
      LogLevel.info => SentryLevel.info,
      _ => SentryLevel.debug,
    };
  }
}
```

### Pattern 4: main.dart Initialization Order
**What:** Correct initialization order for Sentry wrapping the entire app, with Talker initialized first.
**When to use:** In `main.dart`.
**Example:**
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Talker FIRST (so logging is available immediately)
  AppLogger.init(observers: [SentryTalkerObserver()]);

  // 2. Wrap everything in SentryFlutter.init
  await SentryFlutter.init(
    (options) {
      options.dsn = envConfig.sentryDsn;
      options.tracesSampleRate = 0.2;  // 20% of transactions
      options.environment = kReleaseMode ? 'production' : 'development';
    },
    appRunner: () async {
      // ... existing initialization ...
      runApp(
        ProviderScope(
          observers: [TalkerRiverpodObserver(talker: AppLogger.instance)],
          child: const LeadXApp(),
        ),
      );
    },
  );
}
```

### Anti-Patterns to Avoid
- **String-based error classification:** Do NOT check `e.toString().contains('401')` to classify errors. Use the sealed SyncError hierarchy with pattern matching.
- **Catching `Exception` broadly:** The current `_processItem()` catches `SocketException` and `TimeoutException` but wraps them in generic `Exception`. Map them to specific `SyncError` subclasses instead.
- **debugPrint in production:** Flutter's `debugPrint` is compiled out in release mode with `--release`, but the string interpolation still executes. Talker's level-aware logging avoids this waste.
- **Initializing Sentry after runApp:** If `SentryFlutter.init` doesn't wrap `runApp`, errors during widget tree initialization won't be captured. Always use the `appRunner` parameter.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Crash reporting | Custom error boundary + remote logging | sentry_flutter | Native crash capture (NDK, iOS), automatic ANR/hang detection, source maps, release tracking |
| Structured logging | Custom Logger class with file output | talker + talker_flutter | Observer pattern, in-app UI viewer, automatic Sentry bridge, Riverpod integration |
| Log forwarding to Sentry | Manual Sentry.captureException in every catch block | SentryTalkerObserver | Single observer handles all forwarding; DRY, consistent |
| Module-prefixed logging | Custom log wrapper functions | Talker message prefixes (e.g., `'sync.queue | message'`) | Consistent format, searchable in Sentry dashboard |

**Key insight:** The Talker observer pattern is the critical architectural choice. It decouples log producers (sync service, repositories) from log consumers (console, Sentry, in-app UI). Adding a new consumer (e.g., remote logging service) requires only adding an observer, not modifying every log call site.

## Common Pitfalls

### Pitfall 1: Schema Migration Breaking Existing Data
**What goes wrong:** Adding a non-nullable column without a default value to an existing table with data causes SQLite to reject the migration.
**Why it happens:** SQLite requires all new columns on existing rows to have a value. If you declare `lastSyncAt => dateTime()()` (non-nullable, no default), migration fails.
**How to avoid:** Always make new sync metadata columns NULLABLE or provide a default. For this phase: `lastSyncAt` should be `dateTime().nullable()()` and `isPendingSync` should have `withDefault(const Constant(false))` (which most tables already do).
**Warning signs:** Migration test fails on production data copy; `SqliteException: NOT NULL constraint failed`.

### Pitfall 2: Foreign Keys Blocking Migration
**What goes wrong:** Drift migrations run with foreign keys enabled by default. Adding/modifying columns on tables with FK relationships can fail.
**Why it happens:** The `beforeOpen` callback enables `PRAGMA foreign_keys = ON`, but this also applies during migration.
**How to avoid:** In the `onUpgrade` callback, run `await customStatement('PRAGMA foreign_keys = OFF')` BEFORE migration steps, then re-enable in `beforeOpen`. The existing code already enables FK in `beforeOpen`, so just add the OFF statement at the start of `onUpgrade`.
**Warning signs:** `SqliteException: FOREIGN KEY constraint failed` during migration.

### Pitfall 3: Sentry DSN Exposure in Client Code
**What goes wrong:** Hardcoding Sentry DSN in source code exposes it in version control and compiled binaries.
**Why it happens:** Quick setup tutorials show inline DSN strings.
**How to avoid:** Store SENTRY_DSN in the existing `.env` file (already bundled as asset and loaded by flutter_dotenv). Access via `EnvConfig.instance`. Note: Sentry DSN is a public key (not secret), but best practice is still env-file management.
**Warning signs:** DSN visible in git history or decompiled app.

### Pitfall 4: Talker Initialization Order
**What goes wrong:** Errors during app initialization (before Talker is created) are lost.
**Why it happens:** If Talker is initialized inside `SentryFlutter.init`'s `appRunner`, errors in Supabase init or env loading aren't captured.
**How to avoid:** Initialize Talker FIRST (it's synchronous). Then wrap remaining initialization in Sentry. If Talker observer needs Sentry, and Sentry isn't initialized yet, the observer will fail silently on the first few calls -- this is acceptable since Sentry's own error handler catches those.
**Warning signs:** Early startup crashes not appearing in logs or Sentry.

### Pitfall 5: Activities Table Column Rename (syncedAt -> lastSyncAt)
**What goes wrong:** The Activities table uses `syncedAt` instead of `lastSyncAt`. Simply adding `lastSyncAt` and removing `syncedAt` would lose existing sync timestamp data.
**Why it happens:** The Activities table was created before the naming convention was established.
**How to avoid:** Use a Drift `TableMigration` that copies data from `syncedAt` to a new `lastSyncAt` column, or use raw SQL: `ALTER TABLE activities RENAME COLUMN synced_at TO last_sync_at`. Note: SQLite supports `ALTER TABLE ... RENAME COLUMN` since version 3.25.0 (2018), which all Flutter targets support.
**Warning signs:** Loss of sync timestamps after migration; activities re-syncing unnecessarily.

### Pitfall 6: Schema Version Conflicts with Production
**What goes wrong:** Deploying a migration that doesn't account for all possible starting schema versions.
**Why it happens:** Development database was created fresh at latest schema, but production users may be on any version from 1-9.
**How to avoid:** The existing migration already uses `if (from < N)` guards. The new migration (v10) should follow the same pattern. Test by creating databases at each prior version and running migration to v10.
**Warning signs:** Crash on app startup after update for users who haven't updated in a while.

## Code Examples

### Example 1: Drift Migration v9 -> v10 (Sync Metadata Standardization)
```dart
// In app_database.dart, change schemaVersion to 10

// In onUpgrade:
if (from < 10) {
  // === Add missing lastSyncAt columns ===
  // Tables that have isPendingSync but lack lastSyncAt:
  // KeyPersons, Hvcs, CustomerHvcLinks, Brokers, CadenceMeetings,
  // PipelineStageHistoryItems

  // KeyPersons: add lastSyncAt
  await m.addColumn(keyPersons, keyPersons.lastSyncAt);

  // Hvcs: add lastSyncAt
  await m.addColumn(hvcs, hvcs.lastSyncAt);

  // CustomerHvcLinks: add lastSyncAt
  await m.addColumn(customerHvcLinks, customerHvcLinks.lastSyncAt);

  // Brokers: add lastSyncAt
  await m.addColumn(brokers, brokers.lastSyncAt);

  // CadenceMeetings: add lastSyncAt
  await m.addColumn(cadenceMeetings, cadenceMeetings.lastSyncAt);

  // PipelineStageHistoryItems: add lastSyncAt and updatedAt
  await m.addColumn(pipelineStageHistoryItems, pipelineStageHistoryItems.lastSyncAt);

  // === Rename Activities.syncedAt -> lastSyncAt ===
  // SQLite 3.25+ supports ALTER TABLE RENAME COLUMN
  await customStatement(
    'ALTER TABLE activities RENAME COLUMN synced_at TO last_sync_at',
  );
}
```

**CRITICAL NOTE:** After this migration, the Activities Drift table definition must also be updated: change `syncedAt` to `lastSyncAt` so generated code matches the renamed column. This requires a build_runner regeneration. All code referencing `activities.syncedAt` must be updated to `activities.lastSyncAt`.

### Example 2: SyncService Error Classification
```dart
// In SyncService._processItem(), replace generic catches:
try {
  switch (item.operation) {
    case 'create':
      await _supabaseClient.from(tableName).insert(payload);
    // ...
  }
} on SocketException catch (e, st) {
  throw NetworkSyncError(
    message: 'Network unreachable',
    originalError: e,
    stackTrace: st,
    entityType: item.entityType,
    entityId: item.entityId,
  );
} on TimeoutException catch (e, st) {
  throw TimeoutSyncError(
    message: 'Request timed out',
    originalError: e,
    stackTrace: st,
    entityType: item.entityType,
    entityId: item.entityId,
  );
} on PostgrestException catch (e, st) {
  final code = int.tryParse(e.code ?? '') ?? 0;
  if (code == 401 || e.code == 'PGRST301') {
    throw AuthSyncError(
      message: 'Authentication failed',
      originalError: e,
      stackTrace: st,
      entityType: item.entityType,
      entityId: item.entityId,
    );
  } else if (code == 409) {
    throw ConflictSyncError(
      message: 'Conflict: ${e.message}',
      originalError: e,
      stackTrace: st,
      entityType: item.entityType,
      entityId: item.entityId,
    );
  } else if (code >= 400 && code < 500) {
    throw ValidationSyncError(
      message: 'Validation error: ${e.message}',
      originalError: e,
      stackTrace: st,
      entityType: item.entityType,
      entityId: item.entityId,
    );
  } else {
    throw ServerSyncError(
      statusCode: code,
      message: 'Server error: ${e.message}',
      originalError: e,
      stackTrace: st,
      entityType: item.entityType,
      entityId: item.entityId,
    );
  }
}
```

### Example 3: Pattern Matching on SyncError
```dart
// In processQueue error handler:
} on SyncError catch (syncError) {
  if (syncError.isRetryable) {
    await _syncQueueDataSource.incrementRetryCount(item.id);
    _log.warning('sync.push | Retryable error for ${item.entityType}/${item.entityId}: ${syncError.message}');
  } else {
    await _syncQueueDataSource.markAsFailed(item.id, syncError.message);
    _log.error('sync.push | Permanent error for ${item.entityType}/${item.entityId}', syncError.originalError);
  }
  // Exhaustive handling possible with switch:
  switch (syncError) {
    case NetworkSyncError():
      errors.add('Network: ${syncError.message}');
    case TimeoutSyncError():
      errors.add('Timeout: ${syncError.message}');
    case AuthSyncError():
      errors.add('Auth: ${syncError.message}');
    case ValidationSyncError():
      errors.add('Validation: ${syncError.message}');
    case ConflictSyncError():
      errors.add('Conflict: ${syncError.message}');
    case ServerSyncError():
      errors.add('Server (${syncError.statusCode}): ${syncError.message}');
  }
}
```

### Example 4: Sentry User Context After Login
```dart
// After successful authentication:
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: user.id,
    email: user.email,
    data: {
      'role': user.role,
      'branch_id': user.branchId ?? 'none',
      'regional_office_id': user.regionalOfficeId ?? 'none',
    },
  ));
});

// On logout:
Sentry.configureScope((scope) => scope.setUser(null));
```

## Current Schema Inconsistencies (SYNC-05)

This is the critical inventory the planner needs. Each syncable table is categorized by its current sync metadata columns:

### Category A: Full sync metadata (isPendingSync + lastSyncAt + updatedAt)
| Table | isPendingSync | lastSyncAt | updatedAt | Notes |
|-------|:---:|:---:|:---:|-------|
| Customers | YES | YES | YES | Gold standard |
| Pipelines | YES | YES | YES | Gold standard |
| PipelineReferrals | YES | YES | YES | Gold standard |
| CadenceParticipants | YES | YES | YES | Gold standard |

### Category B: Missing lastSyncAt only
| Table | isPendingSync | lastSyncAt | updatedAt | Action Needed |
|-------|:---:|:---:|:---:|-------|
| KeyPersons | YES | **NO** | YES | Add lastSyncAt |
| Hvcs | YES | **NO** | YES | Add lastSyncAt |
| CustomerHvcLinks | YES | **NO** | YES | Add lastSyncAt |
| Brokers | YES | **NO** | YES | Add lastSyncAt |
| CadenceMeetings | YES | **NO** | YES | Add lastSyncAt |

### Category C: Non-standard column name
| Table | isPendingSync | lastSyncAt | updatedAt | Action Needed |
|-------|:---:|:---:|:---:|-------|
| Activities | YES | `syncedAt` (wrong name) | YES | Rename syncedAt -> lastSyncAt |

### Category D: Missing multiple columns
| Table | isPendingSync | lastSyncAt | updatedAt | Action Needed |
|-------|:---:|:---:|:---:|-------|
| PipelineStageHistoryItems | YES | **NO** | **NO** | Add lastSyncAt + updatedAt |

### Category E: Different sync tracking pattern
| Table | Current Pattern | Action Needed |
|-------|----------------|---------------|
| ActivityAuditLogs | `isSynced` (bool) | Evaluate: add isPendingSync + lastSyncAt or keep as-is (audit logs may use different pattern intentionally) |
| ActivityPhotos | `isPendingUpload` (bool) | Evaluate: rename to isPendingSync + add lastSyncAt or keep as-is (upload vs sync distinction may be intentional) |

### Category F: Reference/org tables (no local writes, pull-only)
| Table | Current Pattern | Action Needed |
|-------|----------------|---------------|
| Users | lastSyncAt + updatedAt, NO isPendingSync | None -- pull-only table, no local writes |
| RegionalOffices | updatedAt only | None -- pull-only reference data |
| Branches | updatedAt only | None -- pull-only reference data |
| All master data tables | Minimal timestamps | None -- pull-only, no sync queue |

### Migration Impact on SyncService._markEntityAsSynced()
After migration, `_markEntityAsSynced()` must be updated to set `lastSyncAt` for ALL entity types (currently 5 of 12 entity types skip it). The cadenceMeeting case currently writes to `updatedAt` instead of `lastSyncAt` -- this is incorrect and should be fixed.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `debugPrint` scattered logging | Talker structured logging | Talker 4.x+ (2023) | Module prefixes, observer pattern, Sentry forwarding |
| Firebase Crashlytics | Sentry for non-Firebase stacks | sentry_flutter 7.x+ (2023) | Better for Supabase projects, no Firebase dependency |
| Manual `onUpgrade` migrations | Drift `make-migrations` step-by-step | drift 2.14+ (2024) | Automated migration code generation, schema export for testing |
| Class hierarchy exceptions | Dart 3 sealed classes | Dart 3.0 (2023) | Exhaustive pattern matching, compile-time completeness checks |

**Current in codebase:**
- `SyncState` already uses `sealed class` (Freezed `@freezed sealed class`) -- good precedent for SyncError
- `Failure` hierarchy uses `abstract class` + `Equatable` (dartz pattern) -- SyncError should use native `sealed class` for exhaustive matching without dartz

## Open Questions

1. **ActivityAuditLogs and ActivityPhotos sync pattern**
   - What we know: These tables use `isSynced`/`isPendingUpload` instead of standard `isPendingSync`. They have dedicated sync methods (`syncPendingAuditLogs`, `syncPendingPhotos`) separate from the main sync queue.
   - What's unclear: Should they be standardized to use `isPendingSync`/`lastSyncAt` or do they intentionally use a different pattern because they sync via different mechanisms (direct upload vs queue)?
   - Recommendation: Keep current pattern for Phase 1 (they don't go through sync queue). Document as tech debt for Phase 2 evaluation. Adding standard columns won't break them.

2. **Sentry DSN provisioning**
   - What we know: The project uses `.env` for Supabase credentials, loaded via flutter_dotenv.
   - What's unclear: Does the user have a Sentry organization/project set up? What DSN to use?
   - Recommendation: Add `SENTRY_DSN` to `.env` file and `EnvConfig` class. Implementation can use empty string as default (Sentry silently disables when DSN is empty). User creates Sentry project separately.

3. **Schema export baseline**
   - What we know: Current schema version is 9. No prior schema exports exist (no `drift_schemas/` folder).
   - What's unclear: Whether to retroactively export all 9 prior versions or just start from v9.
   - Recommendation: Export v9 as the baseline, then v10 after migration changes. Testing migration from v9->v10 covers all users since the `if (from < 10)` guard handles any starting version. No need to retroactively export v1-v8.

4. **Talker log prefix convention**
   - What we know: Requirements specify `sync.queue`, `sync.push`, `sync.pull` prefixes.
   - What's unclear: Convention for non-sync modules (auth, database, connectivity).
   - Recommendation: Use dot-separated module prefixes: `sync.queue`, `sync.push`, `sync.pull`, `auth`, `db`, `connectivity`, `gps`. Consistent format: `'module.sub | message'` with pipe separator.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: All Drift table definitions in `lib/data/database/tables/*.dart` (direct file reads)
- Codebase analysis: `lib/data/services/sync_service.dart` -- current error handling and sync patterns
- Codebase analysis: `lib/core/errors/exceptions.dart` and `failures.dart` -- existing error hierarchy
- [pub.dev/sentry_flutter](https://pub.dev/packages/sentry_flutter) - v9.13.0, verified publisher sentry.io
- [pub.dev/talker](https://pub.dev/packages/talker) - v5.1.13, verified publisher frezycode.com
- [pub.dev/talker_flutter](https://pub.dev/packages/talker_flutter) - v5.1.13
- [pub.dev/talker_riverpod_logger](https://pub.dev/packages/talker_riverpod_logger) - v5.1.13
- [Drift migration docs](https://drift.simonbinder.eu/migrations/) - addColumn, schema export, migration strategy
- [Drift migration API](https://drift.simonbinder.eu/migrations/api/) - addColumn constraints and gotchas
- [Drift schema export docs](https://drift.simonbinder.eu/migrations/exports/) - schema dump workflow

### Secondary (MEDIUM confidence)
- [Sentry Flutter docs](https://docs.sentry.io/platforms/dart/guides/flutter/) - setup, user context, breadcrumbs
- [Sentry breadcrumbs docs](https://docs.sentry.io/platforms/dart/guides/flutter/enriching-events/breadcrumbs/) - manual breadcrumb API
- [Talker GitHub](https://github.com/Frezyx/talker) - SentryTalkerObserver example, custom log types
- [Dart sealed classes](https://dart.dev/language/class-modifiers) - sealed class syntax and exhaustiveness

### Tertiary (LOW confidence)
- None -- all claims verified with primary or secondary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All libraries verified on pub.dev with recent stable versions and verified publishers
- Architecture: HIGH - Patterns verified from official docs and existing codebase conventions (sealed class precedent in SyncState)
- Schema inconsistencies: HIGH - Direct codebase analysis of all table definitions and SyncService._markEntityAsSynced()
- Pitfalls: HIGH - Based on SQLite constraints (well-documented), existing migration code review, and Sentry/Talker official setup guides

**Research date:** 2026-02-13
**Valid until:** 2026-03-13 (stable libraries, unlikely to change significantly)
