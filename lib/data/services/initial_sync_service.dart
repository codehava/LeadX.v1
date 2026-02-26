import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/sync_models.dart';
import '../database/app_database.dart';
import '../datasources/local/master_data_local_data_source.dart';
import 'app_settings_service.dart';
import 'sync_coordinator.dart';

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
    SyncCoordinator? coordinator,
  })  : _supabase = supabaseClient,
        _db = database,
        _masterDataSource = masterDataSource,
        _appSettings = appSettingsService,
        _coordinator = coordinator;

  final SupabaseClient _supabase;
  final AppDatabase _db;
  final MasterDataLocalDataSource _masterDataSource;
  final AppSettingsService? _appSettings;
  final SyncCoordinator? _coordinator;

  /// Page size for paginated fetches.
  static const int pageSize = 50;

  /// Tables to sync in order (dependencies first).
  /// These are static/reference tables that use full sync.
  static const List<String> _tablesToSync = [
    // User hierarchy (Must be first as Users are referenced by created_by in other tables)
    'regional_offices',
    'branches',
    'users',
    'user_hierarchy',

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
    // 4DX Scoring
    'measure_definitions',
    'scoring_periods',
    'user_targets',
    'user_scores',
    // Cadence
    'cadence_schedule_config',
  ];

  /// Transactional tables that use delta sync (fetch only changes since last sync).
  /// These tables grow over time and benefit from incremental sync.
  static const List<String> _deltaSyncTables = [
    'hvcs',
    'brokers',
    'customer_hvc_links',
    'pipeline_referrals',
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
    // Acquire coordinator lock if available, else fallback to _isSyncing
    if (_coordinator != null) {
      if (!await _coordinator.acquireLock(type: SyncType.initial)) {
        return SyncResult(
          success: false,
          processedCount: 0,
          successCount: 0,
          failedCount: 0,
          errors: ['Could not acquire initial sync lock'],
          syncedAt: DateTime.now(),
        );
      }
    } else if (_isSyncing) {
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
    var startIndex = 0;
    if (!forceRestart && _appSettings != null) {
      startIndex = await _appSettings.getResumeSyncIndex();

      // Safety check: if resuming but Users table is empty, we must restart
      // because Users are now required early in the process (moved to top).
      if (startIndex > 0) {
        // Check if users table is empty
        final userCountIdx = _db.users.id.count();
        final userCount = await (_db.selectOnly(_db.users)..addColumns([userCountIdx]))
            .map((row) => row.read(userCountIdx))
            .getSingle();
            
        if (userCount == 0) {
          startIndex = 0; // Force restart to ensure users are synced
        }
      }

      await _appSettings.markSyncStarted();
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
            await _appSettings.markTableSynced(i + 1);
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
      _coordinator?.releaseLock();
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
      // Note: hvcs, brokers, customer_hvc_links moved to delta sync (performDeltaSync)
      // 4DX Scoring
      case 'measure_definitions':
        await _syncMeasureDefinitions();
        break;
      case 'scoring_periods':
        await _syncScoringPeriods();
        break;
      case 'user_targets':
        await _syncUserTargets();
        break;
      case 'user_scores':
        await _syncUserScores();
        break;
      // User hierarchy
      case 'regional_offices':
        await _syncRegionalOffices();
        break;
      case 'branches':
        await _syncBranches();
        break;
      case 'users':
        await syncUsers();
        break;
      case 'user_hierarchy':
        await _syncUserHierarchy();
        break;
      // Cadence
      case 'cadence_schedule_config':
        await _syncCadenceScheduleConfig();
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
            color: Value(row['color'] as String?),
            isFinal: Value(row['is_final'] as bool? ?? false),
            isWon: Value(row['is_won'] as bool? ?? false),
            isActive: Value(row['is_active'] as bool? ?? true),
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
            icon: Value(row['icon'] as String?),
            color: Value(row['color'] as String?),
            requireLocation: Value(row['require_location'] as bool? ?? false),
            requirePhoto: Value(row['require_photo'] as bool? ?? false),
            requireNotes: Value(row['require_notes'] as bool? ?? false),
            sortOrder: Value(row['sort_order'] as int? ?? 0),
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

  Future<void> _syncHvcs({DateTime? since}) async {
    var query = _supabase.from('hvcs').select();

    if (since != null) {
      // Delta sync: fetch updated OR deleted since last sync
      query = query.or('updated_at.gt.${since.toUtcIso8601()},deleted_at.gt.${since.toUtcIso8601()}');
    } else {
      // Full sync: only non-deleted records
      query = query.isFilter('deleted_at', null);
    }

    final data = await query;

    // Collect IDs of deleted records for batch deletion
    final deletedIds = <String>[];
    final recordsToUpsert = <Map<String, dynamic>>[];

    for (final row in data as List) {
      final deletedAt = row['deleted_at'] as String?;
      if (deletedAt != null) {
        deletedIds.add(row['id'] as String);
      } else {
        recordsToUpsert.add(row as Map<String, dynamic>);
      }
    }

    // Delete removed records
    if (deletedIds.isNotEmpty) {
      await (_db.delete(_db.hvcs)..where((t) => t.id.isIn(deletedIds))).go();
    }

    // Upsert active records
    await _db.batch((batch) {
      for (final row in recordsToUpsert) {
        batch.insert(
          _db.hvcs,
          HvcsCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            typeId: row['type_id'] as String,
            description: Value(row['description'] as String?),
            address: Value(row['address'] as String?),
            latitude: Value((row['latitude'] as num?)?.toDouble()),
            longitude: Value((row['longitude'] as num?)?.toDouble()),
            radiusMeters: Value(row['radius_meters'] as int? ?? 500),
            potentialValue: Value((row['potential_value'] as num?)?.toDouble()),
            imageUrl: Value(row['image_url'] as String?),
            isActive: Value(row['is_active'] as bool? ?? true),
            createdBy: row['created_by'] as String,
            isPendingSync: const Value(false),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncCustomerHvcLinks({DateTime? since}) async {
    // Note: After migration, Supabase table has updated_at and deleted_at columns
    // Supabase: id, customer_id, hvc_id, relationship_type, notes, linked_at, linked_by, updated_at, deleted_at
    // Local: id, customer_id, hvc_id, relationship_type, is_active, created_by, is_pending_sync, created_at, updated_at, deleted_at
    var query = _supabase.from('customer_hvc_links').select();

    if (since != null) {
      // Delta sync: fetch updated OR deleted since last sync
      query = query.or('updated_at.gt.${since.toUtcIso8601()},deleted_at.gt.${since.toUtcIso8601()}');
    }
    // Note: No deleted_at filter for full sync since customer_hvc_links may not have deleted_at yet

    final data = await query;

    // Collect IDs of deleted records for batch deletion
    final deletedIds = <String>[];
    final recordsToUpsert = <Map<String, dynamic>>[];

    for (final row in data as List) {
      final deletedAt = row['deleted_at'] as String?;
      if (deletedAt != null) {
        deletedIds.add(row['id'] as String);
      } else {
        recordsToUpsert.add(row as Map<String, dynamic>);
      }
    }

    // Delete removed records
    if (deletedIds.isNotEmpty) {
      await (_db.delete(_db.customerHvcLinks)..where((t) => t.id.isIn(deletedIds))).go();
    }

    // Upsert active records
    await _db.batch((batch) {
      for (final row in recordsToUpsert) {
        // Map Supabase linked_at/linked_by to local created_at/created_by
        final linkedAt = row['linked_at'] != null
            ? DateTime.parse(row['linked_at'] as String)
            : DateTime.now();
        final linkedBy = row['linked_by'] as String? ?? 'system';
        // Use updated_at if available (after migration), otherwise fall back to linked_at
        final updatedAt = row['updated_at'] != null
            ? DateTime.parse(row['updated_at'] as String)
            : linkedAt;

        batch.insert(
          _db.customerHvcLinks,
          CustomerHvcLinksCompanion.insert(
            id: row['id'] as String,
            customerId: row['customer_id'] as String,
            hvcId: row['hvc_id'] as String,
            relationshipType: row['relationship_type'] as String? ?? 'MEMBER',
            isActive: const Value(true),
            createdBy: linkedBy,
            isPendingSync: const Value(false),
            createdAt: linkedAt,
            updatedAt: updatedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // BROKER SYNC METHOD
  // ============================================

  Future<void> _syncBrokers({DateTime? since}) async {
    // Use pagination for large datasets (1000+ records)
    final allData = <Map<String, dynamic>>[];
    var offset = 0;
    var hasMore = true;

    while (hasMore) {
      var query = _supabase.from('brokers').select();

      if (since != null) {
        // Delta sync: fetch updated OR deleted since last sync
        query = query.or('updated_at.gt.${since.toUtcIso8601()},deleted_at.gt.${since.toUtcIso8601()}');
      } else {
        // Full sync: only non-deleted records
        query = query.isFilter('deleted_at', null);
      }

      // Add ordering for consistent pagination and fetch page
      final response = await query
          .order('created_at', ascending: true)
          .range(offset, offset + pageSize - 1);

      final pageData = List<Map<String, dynamic>>.from(response as List);
      allData.addAll(pageData);

      // Check if there are more results
      hasMore = pageData.length == pageSize;
      offset += pageSize;
    }

    // Collect IDs of deleted records for batch deletion
    final deletedIds = <String>[];
    final recordsToUpsert = <Map<String, dynamic>>[];

    for (final row in allData) {
      final deletedAt = row['deleted_at'] as String?;
      if (deletedAt != null) {
        deletedIds.add(row['id'] as String);
      } else {
        recordsToUpsert.add(row);
      }
    }

    // Delete removed records
    if (deletedIds.isNotEmpty) {
      await (_db.delete(_db.brokers)..where((t) => t.id.isIn(deletedIds))).go();
    }

    // Upsert active records
    await _db.batch((batch) {
      for (final row in recordsToUpsert) {
        batch.insert(
          _db.brokers,
          BrokersCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            licenseNumber: Value(row['license_number'] as String?),
            address: Value(row['address'] as String?),
            provinceId: Value(row['province_id'] as String?),
            cityId: Value(row['city_id'] as String?),
            latitude: Value((row['latitude'] as num?)?.toDouble()),
            longitude: Value((row['longitude'] as num?)?.toDouble()),
            phone: Value(row['phone'] as String?),
            email: Value(row['email'] as String?),
            website: Value(row['website'] as String?),
            commissionRate: Value((row['commission_rate'] as num?)?.toDouble()),
            imageUrl: Value(row['image_url'] as String?),
            notes: Value(row['notes'] as String?),
            isActive: Value(row['is_active'] as bool? ?? true),
            isPendingSync: const Value(false),
            createdBy: row['created_by'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // 4DX SCORING SYNC METHODS
  // ============================================

  Future<void> _syncMeasureDefinitions() async {
    final data = await _supabase.from('measure_definitions').select().eq('is_active', true);

    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.measureDefinitions,
          MeasureDefinitionsCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            name: row['name'] as String,
            description: Value(row['description'] as String?),
            measureType: row['measure_type'] as String,
            dataType: Value(row['data_type'] as String? ?? 'COUNT'),
            unit: row['unit'] as String? ?? '',
            sortOrder: Value(row['sort_order'] as int? ?? 0),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncScoringPeriods() async {
    final data = await _supabase.from('scoring_periods').select();
    
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.scoringPeriods,
          ScoringPeriodsCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            periodType: row['period_type'] as String,
            startDate: DateTime.parse(row['start_date'] as String),
            endDate: DateTime.parse(row['end_date'] as String),
            isCurrent: Value(row['is_current'] as bool? ?? false),
            isActive: Value(row['is_locked'] != true), // invert is_locked
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncUserTargets() async {
    // Get current user ID from Supabase auth
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Fetch all current period IDs
    final periodsData = await _supabase
        .from('scoring_periods')
        .select('id')
        .eq('is_current', true);
    final periodIds = (periodsData as List)
        .map((row) => row['id'] as String)
        .toList();
    if (periodIds.isEmpty) return;

    final data = await _supabase
        .from('user_targets')
        .select()
        .eq('user_id', userId)
        .inFilter('period_id', periodIds);

    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.userTargets,
          UserTargetsCompanion.insert(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            measureId: row['measure_id'] as String,
            periodId: row['period_id'] as String,
            targetValue: (row['target_value'] as num).toDouble(),
            assignedBy: row['assigned_by'] as String? ?? userId,
            assignedAt: row['assigned_at'] != null
                ? DateTime.parse(row['assigned_at'] as String)
                : DateTime.now(),
            createdAt: row['created_at'] != null
                ? DateTime.parse(row['created_at'] as String)
                : DateTime.now(),
            updatedAt: row['updated_at'] != null
                ? DateTime.parse(row['updated_at'] as String)
                : DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _syncUserScores() async {
    // Get current user ID from Supabase auth
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Fetch all current period IDs
    final periodsData = await _supabase
        .from('scoring_periods')
        .select('id')
        .eq('is_current', true);
    final periodIds = (periodsData as List)
        .map((row) => row['id'] as String)
        .toList();
    if (periodIds.isEmpty) return;

    final data = await _supabase
        .from('user_scores')
        .select()
        .eq('user_id', userId)
        .inFilter('period_id', periodIds);

    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.userScores,
          UserScoresCompanion.insert(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            measureId: row['measure_id'] as String,
            periodId: row['period_id'] as String,
            targetValue: (row['target_value'] as num?)?.toDouble() ?? 0,
            actualValue: Value((row['actual_value'] as num?)?.toDouble() ?? 0),
            percentage: Value((row['percentage'] as num?)?.toDouble() ?? 0),
            calculatedAt: row['calculated_at'] != null
                ? DateTime.parse(row['calculated_at'] as String)
                : DateTime.now(),
            createdAt: row['created_at'] != null
                ? DateTime.parse(row['created_at'] as String)
                : DateTime.now(),
            updatedAt: row['updated_at'] != null
                ? DateTime.parse(row['updated_at'] as String)
                : DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // CADENCE SYNC METHODS
  // ============================================

  Future<void> _syncCadenceScheduleConfig() async {
    final data = await _supabase.from('cadence_schedule_config').select().eq('is_active', true);

    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.cadenceScheduleConfig,
          CadenceScheduleConfigCompanion.insert(
            id: row['id'] as String,
            name: row['name'] as String,
            description: Value(row['description'] as String?),
            targetRole: row['target_role'] as String,
            facilitatorRole: row['facilitator_role'] as String,
            frequency: row['frequency'] as String,
            dayOfWeek: Value(row['day_of_week'] as int?),
            dayOfMonth: Value(row['day_of_month'] as int?),
            defaultTime: Value(row['default_time'] as String?),
            durationMinutes: Value(row['duration_minutes'] as int? ?? 60),
            preMeetingHours: Value(row['pre_meeting_hours'] as int? ?? 24),
            isActive: Value(row['is_active'] as bool? ?? true),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
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

  Future<void> syncUsers() async {
    final data = await _supabase.from('users').select().eq('is_active', true);

    // First pass: Insert all users WITHOUT parent_id to avoid FK constraint issues
    // (parent_id references users table, so parent must exist first)
    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.users,
          UsersCompanion.insert(
            id: row['id'] as String,
            email: row['email'] as String,
            name: row['name'] as String,
            role: row['role'] as String,
            // Skip parentId in first pass to avoid self-referential FK issues
            branchId: Value(row['branch_id'] as String?),
            regionalOfficeId: Value(row['regional_office_id'] as String?),
            nip: Value(row['nip'] as String?),
            phone: Value(row['phone'] as String?),
            photoUrl: Value(row['photo_url'] as String?),
            isActive: Value(row['is_active'] as bool? ?? true),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    // Build set of synced user IDs for FK validation
    final syncedUserIds = (data as List).map((row) => row['id'] as String).toSet();

    // Second pass: Update parent_id only if parent exists locally
    for (final row in data) {
      final parentId = row['parent_id'] as String?;
      // Only set parent_id if the parent was also synced (exists locally)
      if (parentId != null && syncedUserIds.contains(parentId)) {
        await (_db.update(_db.users)
              ..where((u) => u.id.equals(row['id'] as String)))
            .write(UsersCompanion(parentId: Value(parentId)));
      }
    }
  }

  Future<void> _syncUserHierarchy() async {
    final data = await _supabase.from('user_hierarchy').select();

    // Get all local user IDs to filter hierarchy entries
    final localUsers = await _db.select(_db.users).get();
    final localUserIdSet = localUsers.map((user) => user.id).toSet();

    await _db.batch((batch) {
      for (final row in data as List) {
        final ancestorId = row['ancestor_id'] as String;
        final descendantId = row['descendant_id'] as String;

        // Only insert if both ancestor and descendant exist in local users table
        if (localUserIdSet.contains(ancestorId) && localUserIdSet.contains(descendantId)) {
          batch.insert(
            _db.userHierarchy,
            UserHierarchyCompanion.insert(
              ancestorId: ancestorId,
              descendantId: descendantId,
              depth: row['depth'] as int,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    });
  }

  // ============================================
  // DELTA SYNC FOR TRANSACTIONAL TABLES
  // ============================================

  /// Perform delta sync for transactional tables (hvcs, brokers, customer_hvc_links).
  /// Only fetches records updated since the last sync timestamp.
  /// Call this periodically after initial sync is complete.
  Future<SyncResult> performDeltaSync({
    InitialSyncProgressCallback? onProgress,
  }) async {
    // Acquire coordinator lock if available, else fallback to _isSyncing
    if (_coordinator != null) {
      // skipInitialSyncChecks: true — performDeltaSync is called as Phase 2 of the
      // initial sync orchestration (from SyncProgressSheet) while _initialSyncComplete
      // is still false and before markInitialSyncComplete() sets the cooldown timestamp.
      if (!await _coordinator.acquireLock(type: SyncType.masterDataResync, skipInitialSyncChecks: true)) {
        return SyncResult(
          success: false,
          processedCount: 0,
          successCount: 0,
          failedCount: 0,
          errors: ['Could not acquire delta sync lock'],
          syncedAt: DateTime.now(),
        );
      }
    } else if (_isSyncing) {
      return SyncResult(
        success: false,
        processedCount: 0,
        successCount: 0,
        failedCount: 0,
        errors: ['Sync already in progress'],
        syncedAt: DateTime.now(),
      );
    }

    _isSyncing = true;
    final errors = <String>[];
    var successCount = 0;
    var failedCount = 0;

    try {
      for (var i = 0; i < _deltaSyncTables.length; i++) {
        final tableName = _deltaSyncTables[i];

        _emitProgress(
          InitialSyncProgress(
            currentTable: tableName,
            currentTableIndex: i + 1,
            totalTables: _deltaSyncTables.length,
            currentPage: 0,
            totalRows: 0,
            percentage: (i / _deltaSyncTables.length) * 100,
            message: 'Delta sync: $tableName...',
          ),
          onProgress,
        );

        try {
          // Get last sync timestamp for this table
          final lastSyncAt = await _appSettings?.getTableLastSyncAt(tableName);

          // Perform delta sync
          await _syncTableDelta(tableName, lastSyncAt);

          // Update last sync timestamp
          await _appSettings?.setTableLastSyncAt(tableName, DateTime.now());

          successCount++;
        } catch (e) {
          errors.add('Failed to delta sync $tableName: $e');
          failedCount++;
        }
      }

      _emitProgress(InitialSyncProgress.completed(), onProgress);

      return SyncResult(
        success: errors.isEmpty,
        processedCount: _deltaSyncTables.length,
        successCount: successCount,
        failedCount: failedCount,
        errors: errors,
        syncedAt: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
      _coordinator?.releaseLock();
    }
  }

  /// Sync a delta table with optional since timestamp.
  Future<void> _syncTableDelta(String tableName, DateTime? since) async {
    switch (tableName) {
      case 'hvcs':
        await _syncHvcs(since: since);
        break;
      case 'brokers':
        await _syncBrokers(since: since);
        break;
      case 'customer_hvc_links':
        await _syncCustomerHvcLinks(since: since);
        break;
      case 'pipeline_referrals':
        await _syncPipelineReferrals(since: since);
        break;
    }
  }

  // ============================================
  // PIPELINE REFERRALS SYNC METHOD
  // ============================================

  Future<void> _syncPipelineReferrals({DateTime? since}) async {
    var query = _supabase.from('pipeline_referrals').select();

    if (since != null) {
      // Delta sync: fetch updated since last sync
      query = query.gte('updated_at', since.toUtcIso8601());
    }

    final data = await query;

    await _db.batch((batch) {
      for (final row in data as List) {
        batch.insert(
          _db.pipelineReferrals,
          PipelineReferralsCompanion.insert(
            id: row['id'] as String,
            code: row['code'] as String,
            customerId: row['customer_id'] as String,
            referrerRmId: row['referrer_rm_id'] as String,
            receiverRmId: row['receiver_rm_id'] as String,
            referrerBranchId: Value(row['referrer_branch_id'] as String?),
            receiverBranchId: Value(row['receiver_branch_id'] as String?),
            referrerRegionalOfficeId: Value(row['referrer_regional_office_id'] as String?),
            receiverRegionalOfficeId: Value(row['receiver_regional_office_id'] as String?),
            approverType: Value(row['approver_type'] as String? ?? 'BM'),
            status: Value(row['status'] as String),
            reason: row['reason'] as String,
            notes: Value(row['notes'] as String?),
            receiverNotes: Value(row['receiver_notes'] as String?),
            receiverAcceptedAt: Value(row['receiver_accepted_at'] != null
                ? DateTime.parse(row['receiver_accepted_at'] as String)
                : null),
            receiverRejectedAt: Value(row['receiver_rejected_at'] != null
                ? DateTime.parse(row['receiver_rejected_at'] as String)
                : null),
            receiverRejectReason: Value(row['receiver_reject_reason'] as String?),
            bmApprovedAt: Value(row['bm_approved_at'] != null
                ? DateTime.parse(row['bm_approved_at'] as String)
                : null),
            bmApprovedBy: Value(row['bm_approved_by'] as String?),
            bmNotes: Value(row['bm_notes'] as String?),
            bmRejectedAt: Value(row['bm_rejected_at'] != null
                ? DateTime.parse(row['bm_rejected_at'] as String)
                : null),
            bmRejectReason: Value(row['bm_reject_reason'] as String?),
            cancelledAt: Value(row['cancelled_at'] != null
                ? DateTime.parse(row['cancelled_at'] as String)
                : null),
            cancelReason: Value(row['cancel_reason'] as String?),
            bonusCalculated: Value(row['bonus_calculated'] as bool? ?? false),
            bonusAmount: Value((row['bonus_amount'] as num?)?.toDouble()),
            isPendingSync: const Value(false),
            lastSyncAt: Value(DateTime.now()),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
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
