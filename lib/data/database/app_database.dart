import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/logging/app_logger.dart';

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
    UserScoreAggregates,

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
  int get schemaVersion => 10;

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
          // Migration from v4 to v5: Update scoring tables
          // Note: WIG tables were removed in v8 (consolidated into measures)
          if (from < 5) {
            // Add new columns to measure_definitions
            await m.addColumn(measureDefinitions, measureDefinitions.weight);
            await m.addColumn(measureDefinitions, measureDefinitions.defaultTarget);
            await m.addColumn(measureDefinitions, measureDefinitions.periodType);
            await m.addColumn(measureDefinitions, measureDefinitions.calculationMethod);
            // Add new columns to scoring_periods
            await m.addColumn(scoringPeriods, scoringPeriods.isLocked);
            // Add new columns to user_targets
            await m.addColumn(userTargets, userTargets.assignedAt);
            // Add new columns to user_scores
            await m.addColumn(userScores, userScores.score);
            await m.addColumn(userScores, userScores.rank);
            // Rename PeriodSummaryScores to UserScoreSnapshots handled by recreation
          }
          // Migration from v5 to v6: Add Cadence tables
          if (from < 6) {
            await m.createTable(cadenceScheduleConfig);
            await m.createTable(cadenceMeetings);
            await m.createTable(cadenceParticipants);
          }
          // Migration from v6 to v7: Add preMeetingHours column to cadence_schedule_config
          // Note: Only needed for databases created before preMeetingHours was added to table schema.
          // Databases created with v6 already have this column from createTable.
          if (from < 7) {
            // Check if column already exists (it will if table was created with current schema)
            final result = await customSelect(
              "SELECT COUNT(*) as cnt FROM pragma_table_info('cadence_schedule_config') WHERE name = 'pre_meeting_hours'",
            ).getSingle();
            final columnExists = (result.data['cnt'] as int) > 0;

            if (!columnExists) {
              await m.addColumn(
                  cadenceScheduleConfig, cadenceScheduleConfig.preMeetingHours);
            }
          }
          // Migration from v7 to v8: Drop WIG tables (consolidated into measures)
          if (from < 8) {
            await customStatement('DROP TABLE IF EXISTS wig_progress');
            await customStatement('DROP TABLE IF EXISTS wigs');
          }
          // Migration from v8 to v9: Rename user_score_snapshots to user_score_aggregates
          if (from < 9) {
            await customStatement(
                'ALTER TABLE user_score_snapshots RENAME TO user_score_aggregates');
          }
          // Migration from v9 to v10: Standardize sync metadata columns
          if (from < 10) {
            // Disable FK during migration to prevent constraint issues
            await customStatement('PRAGMA foreign_keys = OFF');

            // Add lastSyncAt to tables missing it (Category B)
            await m.addColumn(keyPersons, keyPersons.lastSyncAt);
            await m.addColumn(hvcs, hvcs.lastSyncAt);
            await m.addColumn(customerHvcLinks, customerHvcLinks.lastSyncAt);
            await m.addColumn(brokers, brokers.lastSyncAt);
            await m.addColumn(cadenceMeetings, cadenceMeetings.lastSyncAt);

            // Add lastSyncAt and updatedAt to PipelineStageHistoryItems (Category D)
            await m.addColumn(
                pipelineStageHistoryItems, pipelineStageHistoryItems.lastSyncAt);
            await m.addColumn(
                pipelineStageHistoryItems, pipelineStageHistoryItems.updatedAt);

            // Rename Activities.syncedAt -> lastSyncAt (Category C)
            // SQLite 3.25+ supports ALTER TABLE RENAME COLUMN
            await customStatement(
              'ALTER TABLE activities RENAME COLUMN synced_at TO last_sync_at',
            );
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
          AppLogger.instance.warning('db | Using ${result.chosenImplementation} due to '
              'missing features: ${result.missingFeatures}');
        }
      },
    ),
  );
}
