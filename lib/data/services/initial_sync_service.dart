import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/sync_models.dart';
import '../database/app_database.dart';
import '../datasources/local/master_data_local_data_source.dart';
import 'app_settings_service.dart';

/// Progress callback for initial sync.
typedef InitialSyncProgressCallback = void Function(InitialSyncProgress progress);

/// Progress model for initial sync.
class InitialSyncProgress {
  final String currentTable;
  final int currentTableIndex;
  final int totalTables;
  final int currentPage;
  final int totalRows;
  final double percentage;
  final String message;

  const InitialSyncProgress({
    required this.currentTable,
    required this.currentTableIndex,
    required this.totalTables,
    required this.currentPage,
    required this.totalRows,
    required this.percentage,
    required this.message,
  });

  factory InitialSyncProgress.starting() => const InitialSyncProgress(
        currentTable: '',
        currentTableIndex: 0,
        totalTables: 0,
        currentPage: 0,
        totalRows: 0,
        percentage: 0,
        message: 'Memulai sinkronisasi...',
      );

  factory InitialSyncProgress.completed() => const InitialSyncProgress(
        currentTable: '',
        currentTableIndex: 0,
        totalTables: 0,
        currentPage: 0,
        totalRows: 0,
        percentage: 100,
        message: 'Sinkronisasi selesai!',
      );
}

/// Service for initial/first-time sync of master data and reference tables.
/// Downloads all required data when user first logs in.
/// Supports resuming interrupted syncs.
class InitialSyncService {
  InitialSyncService({
    required SupabaseClient supabaseClient,
    required AppDatabase database,
    required MasterDataLocalDataSource masterDataSource,
    AppSettingsService? appSettingsService,
  })  : _supabase = supabaseClient,
        _db = database,
        _masterDataSource = masterDataSource,
        _appSettings = appSettingsService;

  final SupabaseClient _supabase;
  final AppDatabase _db;
  final MasterDataLocalDataSource _masterDataSource;
  final AppSettingsService? _appSettings;

  /// Page size for paginated fetches.
  static const int pageSize = 50;

  /// Tables to sync in order (dependencies first).
  static const List<String> _tablesToSync = [
    // Master data
    'provinces',
    'cities',
    'company_types',
    'ownership_types',
    'industries',
    'cobs',
    'lobs',
    'pipeline_stages',
    'pipeline_statuses',
    'activity_types',
    'lead_sources',
    'decline_reasons',
    'hvc_types',
    // User hierarchy (dependencies first)
    'regional_offices',
    'branches',
    'users',
    'user_hierarchy',
  ];

  /// Stream controller for progress updates.
  final StreamController<InitialSyncProgress> _progressController =
      StreamController<InitialSyncProgress>.broadcast();

  /// Stream of sync progress.
  Stream<InitialSyncProgress> get progressStream => _progressController.stream;

  /// Whether sync is currently running.
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Perform initial sync of all master data.
  /// Supports resuming from interrupted sync if AppSettingsService is provided.
  Future<SyncResult> performInitialSync({
    InitialSyncProgressCallback? onProgress,
    bool forceRestart = false,
  }) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        errors: ['Initial sync already in progress'],
        syncedAt: DateTime.now(),
      );
    }

    _isSyncing = true;
    final errors = <String>[];
    var successCount = 0;
    var failedCount = 0;

    // Determine starting index (for resume)
    int startIndex = 0;
    if (!forceRestart && _appSettings != null) {
      startIndex = await _appSettings!.getResumeSyncIndex();
      await _appSettings!.markSyncStarted();
    }

    try {
      _emitProgress(InitialSyncProgress.starting(), onProgress);

      for (var i = startIndex; i < _tablesToSync.length; i++) {
        final tableName = _tablesToSync[i];
        
        try {
          _emitProgress(
            InitialSyncProgress(
              currentTable: tableName,
              currentTableIndex: i + 1,
              totalTables: _tablesToSync.length,
              currentPage: 0,
              totalRows: 0,
              percentage: (i / _tablesToSync.length) * 100,
              message: 'Mengunduh $tableName...',
            ),
            onProgress,
          );

          await _syncTable(tableName);
          successCount++;

          // Track progress for resume
          if (_appSettings != null) {
            await _appSettings!.markTableSynced(i + 1);
          }
        } catch (e) {
          errors.add('Failed to sync $tableName: $e');
          failedCount++;
          // Don't stop on individual table failure, continue to next
        }
      }

      _emitProgress(InitialSyncProgress.completed(), onProgress);

      return SyncResult(
        success: errors.isEmpty,
        processedCount: _tablesToSync.length - startIndex,
        successCount: successCount,
        failedCount: failedCount,
        errors: errors,
        syncedAt: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  void _emitProgress(
    InitialSyncProgress progress,
    InitialSyncProgressCallback? callback,
  ) {
    _progressController.add(progress);
    callback?.call(progress);
  }

  /// Sync a single table with pagination.
  Future<void> _syncTable(String tableName) async {
    switch (tableName) {
      case 'provinces':
        await _syncProvinces();
        break;
      case 'cities':
        await _syncCities();
        break;
      case 'company_types':
        await _syncCompanyTypes();
        break;
      case 'ownership_types':
        await _syncOwnershipTypes();
        break;
      case 'industries':
        await _syncIndustries();
        break;
      case 'cobs':
        await _syncCobs();
        break;
      case 'lobs':
        await _syncLobs();
        break;
      case 'pipeline_stages':
        await _syncPipelineStages();
        break;
      case 'pipeline_statuses':
        await _syncPipelineStatuses();
        break;
      case 'activity_types':
        await _syncActivityTypes();
        break;
      case 'lead_sources':
        await _syncLeadSources();
        break;
      case 'decline_reasons':
        await _syncDeclineReasons();
        break;
      case 'hvc_types':
        await _syncHvcTypes();
        break;
      // User hierarchy
      case 'regional_offices':
        await _syncRegionalOffices();
        break;
      case 'branches':
        await _syncBranches();
        break;
      case 'users':
        await _syncUsers();
        break;
      case 'user_hierarchy':
        await _syncUserHierarchy();
        break;
    }
  }

  // ============================================
  // TABLE-SPECIFIC SYNC METHODS
  // ============================================

  Future<void> _syncProvinces() async {
    final data = await _supabase.from('provinces').select().eq('is_active', true);
    
    final companions = (data as List).map((row) => ProvincesCompanion.insert(
          id: row['id'] as String,
          code: row['code'] as String,
          name: row['name'] as String,
        )).toList();

    await _masterDataSource.upsertProvinces(companions);
  }

  Future<void> _syncCities() async {
    final data = await _supabase.from('cities').select().eq('is_active', true);
    
    final companions = (data as List).map((row) => CitiesCompanion.insert(
          id: row['id'] as String,
          code: row['code'] as String,
          name: row['name'] as String,
          provinceId: row['province_id'] as String,
        )).toList();

    await _masterDataSource.upsertCities(companions);
  }

  Future<void> _syncCompanyTypes() async {
    final data = await _supabase.from('company_types').select().eq('is_active', true);
    
    final companions = (data as List).map((row) => CompanyTypesCompanion.insert(
          id: row['id'] as String,
          code: row['code'] as String,
          name: row['name'] as String,
        )).toList();

    await _masterDataSource.upsertCompanyTypes(companions);
  }

  Future<void> _syncOwnershipTypes() async {
    final data = await _supabase.from('ownership_types').select().eq('is_active', true);
    
    final companions = (data as List).map((row) => OwnershipTypesCompanion.insert(
          id: row['id'] as String,
          code: row['code'] as String,
          name: row['name'] as String,
        )).toList();

    await _masterDataSource.upsertOwnershipTypes(companions);
  }

  Future<void> _syncIndustries() async {
    final data = await _supabase.from('industries').select().eq('is_active', true);
    
    final companions = (data as List).map((row) => IndustriesCompanion.insert(
          id: row['id'] as String,
          code: row['code'] as String,
          name: row['name'] as String,
        )).toList();

    await _masterDataSource.upsertIndustries(companions);
  }

  Future<void> _syncCobs() async {
    final data = await _supabase.from('cobs').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.cobs,
          CobsCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncLobs() async {
    final data = await _supabase.from('lobs').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.lobs,
          LobsCompanion.insert(
            id: row['id'] as String,
            cobId: row['cob_id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncPipelineStages() async {
    final data = await _supabase.from('pipeline_stages').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.pipelineStages,
          PipelineStagesCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            probability: row['probability'] as int,
            sequence: row['sequence'] as int,
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncPipelineStatuses() async {
    final data = await _supabase.from('pipeline_statuses').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.pipelineStatuses,
          PipelineStatusesCompanion.insert(
            id: row['id'] as String,
            stageId: row['stage_id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            sequence: row['sequence'] as int,
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncActivityTypes() async {
    final data = await _supabase.from('activity_types').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.activityTypes,
          ActivityTypesCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncLeadSources() async {
    final data = await _supabase.from('lead_sources').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.leadSources,
          LeadSourcesCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncDeclineReasons() async {
    final data = await _supabase.from('decline_reasons').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.declineReasons,
          DeclineReasonsCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncHvcTypes() async {
    final data = await _supabase.from('hvc_types').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.hvcTypes,
          HvcTypesCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // USER HIERARCHY SYNC METHODS
  // ============================================

  Future<void> _syncRegionalOffices() async {
    final data = await _supabase.from('regional_offices').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.regionalOffices,
          RegionalOfficesCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncBranches() async {
    final data = await _supabase.from('branches').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.branches,
          BranchesCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            regionalOfficeId: row['regional_office_id'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncUsers() async {
    final data = await _supabase.from('users').select().eq('is_active', true);
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.users,
          UsersCompanion.insert(
            id: row['id'] as String,
            email: row['email'] as String,
            name: row['name'] as String,
            role: row['role'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncUserHierarchy() async {
    final data = await _supabase.from('user_hierarchy').select();
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.userHierarchy,
          UserHierarchyCompanion.insert(
            ancestorId: row['ancestor_id'] as String,
            descendantId: row['descendant_id'] as String,
            depth: row['depth'] as int,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Dispose resources.
  void dispose() {
    _progressController.close();
  }
}
