import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/activities.dart';
import 'tables/cadence.dart';
import 'tables/customers.dart';
import 'tables/history_log_tables.dart';
import 'tables/master_data.dart';
import 'tables/notifications.dart';
import 'tables/pipelines.dart';
import 'tables/scoring.dart';
import 'tables/sync_queue.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

/// The main database for LeadX CRM.
/// 
/// Uses Drift (SQLite) for offline-first local storage.
/// Schema matches PostgreSQL backend for sync compatibility.
/// 
/// Web: Uses WASM-based SQLite via drift_flutter
/// Native: Uses native SQLite via sqlite3_flutter_libs
@DriftDatabase(
  tables: [
    // ============================================
    // ORGANIZATION & USERS (4 tables)
    // ============================================
    Users,
    UserHierarchy,
    RegionalOffices,
    Branches,
    
    // ============================================
    // GEOGRAPHY (2 tables)
    // ============================================
    Provinces,
    Cities,
    
    // ============================================
    // MASTER DATA (10 tables)
    // ============================================
    CompanyTypes,
    OwnershipTypes,
    Industries,
    Cobs,
    Lobs,
    PipelineStages,
    PipelineStatuses,
    ActivityTypes,
    LeadSources,
    DeclineReasons,
    
    // ============================================
    // BUSINESS DATA (6 tables)
    // ============================================
    Customers,
    KeyPersons,
    Pipelines,
    PipelineReferrals,
    Activities,
    ActivityPhotos,
    ActivityAuditLogs,
    
    // ============================================
    // HVC & BROKER (4 tables)
    // ============================================
    HvcTypes,
    Hvcs,
    CustomerHvcLinks,
    Brokers,
    
    // ============================================
    // 4DX SCORING (5 tables)
    // ============================================
    MeasureDefinitions,
    ScoringPeriods,
    UserTargets,
    UserScores,
    PeriodSummaryScores,
    
    // ============================================
    // CADENCE (3 tables)
    // ============================================
    CadenceScheduleConfig,
    CadenceMeetings,
    CadenceParticipants,
    
    // ============================================
    // NOTIFICATIONS (4 tables)
    // ============================================
    Notifications,
    NotificationSettings,
    Announcements,
    AnnouncementReads,
    
    // ============================================
    // SYSTEM (5 tables)
    // ============================================
    SyncQueueItems,
    AuditLogs,
    AppSettings,
    // History Log Cache
    PipelineStageHistoryItems,
    AuditLogCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Database schema version - increment on schema changes
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Migration from v1 to v2: Add isSynced column to activity_audit_logs
          if (from < 2) {
            await m.addColumn(activityAuditLogs, activityAuditLogs.isSynced);
          }
          // Migration from v2 to v3: Add history log cache tables
          if (from < 3) {
            await m.createTable(pipelineStageHistoryItems);
            await m.createTable(auditLogCache);
          }
          // Migration from v3 to v4: Add sync tracking columns to pipeline stage history
          if (from < 4) {
            await m.addColumn(
                pipelineStageHistoryItems, pipelineStageHistoryItems.isPendingSync);
            await m.addColumn(
                pipelineStageHistoryItems, pipelineStageHistoryItems.createdLocally);
          }
        },
        beforeOpen: (details) async {
          // Enable foreign keys
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Opens a database connection that works on all platforms.
/// 
/// - Native (iOS, Android, Desktop): Uses native SQLite via sqlite3_flutter_libs
/// - Web: Uses WASM-based SQLite (requires web assets setup)
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'leadx_crm',
    native: const DriftNativeOptions(
      // Share database across isolates for better concurrency
      shareAcrossIsolates: true,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          // ignore: avoid_print
          print('Using ${result.chosenImplementation} due to '
              'missing features: ${result.missingFeatures}');
        }
      },
    ),
  );
}
