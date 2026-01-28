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
    // HVC transactional data
    'hvcs',
    'customer_hvc_links',
    // Brokers
    'brokers',
    // 4DX Scoring (added)
    'measure_definitions',
    'scoring_periods',
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
    // Determine starting index (for resume)
    int startIndex = 0;
    if (!forceRestart && _appSettings != null) {
      startIndex = await _appSettings!.getResumeSyncIndex();

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
      case 'hvcs':
        await _syncHvcs();
        break;
      case 'customer_hvc_links':
        await _syncCustomerHvcLinks();
        break;
      case 'brokers':
        await _syncBrokers();
        break;
      // 4DX Scoring
      case 'measure_definitions':
        await _syncMeasureDefinitions();
        break;
      case 'scoring_periods':
        await _syncScoringPeriods();
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

  Future<void> _syncHvcs() async {
    final data = await _supabase.from('hvcs').select().isFilter('deleted_at', null);
    
    await _db.batch((batch) {
      for (final row in data as List) {
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

  Future<void> _syncCustomerHvcLinks() async {
    // Note: Supabase table has different schema than local table
    // Supabase: id, customer_id, hvc_id, relationship_type, notes, linked_at, linked_by
    // Local: adds is_active, is_pending_sync, created_at, updated_at, deleted_at
    final data = await _supabase.from('customer_hvc_links').select();
    
    await _db.batch((batch) {
      for (final row in data as List) {
        // Map Supabase linked_at/linked_by to local created_at/created_by
        final linkedAt = row['linked_at'] != null 
            ? DateTime.parse(row['linked_at'] as String) 
            : DateTime.now();
        final linkedBy = row['linked_by'] as String? ?? 'system';
        
        batch.insert(
          _db.customerHvcLinks,
          CustomerHvcLinksCompanion.insert(
            id: row['id'] as String,
            customerId: row['customer_id'] as String,
            hvcId: row['hvc_id'] as String,
            relationshipType: row['relationship_type'] as String? ?? 'MEMBER',
            isActive: const Value(true), // Default, not in Supabase schema
            createdBy: linkedBy,
            isPendingSync: const Value(false),
            createdAt: linkedAt,
            updatedAt: linkedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // BROKER SYNC METHOD
  // ============================================

  Future<void> _syncBrokers() async {
    final data = await _supabase.from('brokers').select().isFilter('deleted_at', null);
    
    await _db.batch((batch) {
      for (final row in data as List) {
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
            dataType: row['unit'] as String? ?? 'COUNT',
            unit: Value(row['unit'] as String?),
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

  /// Dispose resources.
  void dispose() {
    _progressController.close();
  }
}
