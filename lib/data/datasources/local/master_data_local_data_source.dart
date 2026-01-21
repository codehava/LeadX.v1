import 'package:drift/drift.dart';

import '../../database/app_database.dart';

/// Local data source for master data (read-only reference tables).
class MasterDataLocalDataSource {
  final AppDatabase _db;

  MasterDataLocalDataSource(this._db);

  // ============================================
  // GEOGRAPHY
  // ============================================

  /// Get all active provinces.
  Future<List<Province>> getProvinces() async {
    return (_db.select(_db.provinces)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch all active provinces as stream.
  Stream<List<Province>> watchProvinces() {
    return (_db.select(_db.provinces)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Get cities by province ID.
  Future<List<City>> getCitiesByProvince(String provinceId) async {
    return (_db.select(_db.cities)
          ..where((t) => t.provinceId.equals(provinceId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch cities by province ID.
  Stream<List<City>> watchCitiesByProvince(String provinceId) {
    return (_db.select(_db.cities)
          ..where((t) => t.provinceId.equals(provinceId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  // ============================================
  // COMPANY CLASSIFICATIONS
  // ============================================

  /// Get all active company types.
  Future<List<CompanyType>> getCompanyTypes() async {
    return (_db.select(_db.companyTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch all active company types.
  Stream<List<CompanyType>> watchCompanyTypes() {
    return (_db.select(_db.companyTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Get all active ownership types.
  Future<List<OwnershipType>> getOwnershipTypes() async {
    return (_db.select(_db.ownershipTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch all active ownership types.
  Stream<List<OwnershipType>> watchOwnershipTypes() {
    return (_db.select(_db.ownershipTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Get all active industries.
  Future<List<Industry>> getIndustries() async {
    return (_db.select(_db.industries)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch all active industries.
  Stream<List<Industry>> watchIndustries() {
    return (_db.select(_db.industries)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  // ============================================
  // PRODUCT CLASSIFICATIONS
  // ============================================

  /// Get all active COBs.
  Future<List<Cob>> getCobs() async {
    return (_db.select(_db.cobs)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch all active COBs.
  Stream<List<Cob>> watchCobs() {
    return (_db.select(_db.cobs)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Get LOBs by COB ID.
  Future<List<Lob>> getLobsByCob(String cobId) async {
    return (_db.select(_db.lobs)
          ..where((t) => t.cobId.equals(cobId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch LOBs by COB ID.
  Stream<List<Lob>> watchLobsByCob(String cobId) {
    return (_db.select(_db.lobs)
          ..where((t) => t.cobId.equals(cobId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  // ============================================
  // PIPELINE CLASSIFICATIONS
  // ============================================

  /// Get all active pipeline stages.
  Future<List<PipelineStage>> getPipelineStages() async {
    return (_db.select(_db.pipelineStages)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
  }

  /// Watch all active pipeline stages.
  Stream<List<PipelineStage>> watchPipelineStages() {
    return (_db.select(_db.pipelineStages)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .watch();
  }

  /// Get pipeline statuses by stage ID.
  Future<List<PipelineStatuse>> getStatusesByStage(String stageId) async {
    return (_db.select(_db.pipelineStatuses)
          ..where((t) => t.stageId.equals(stageId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
  }

  // ============================================
  // ACTIVITY CLASSIFICATIONS
  // ============================================

  /// Get all active activity types.
  Future<List<ActivityType>> getActivityTypes() async {
    return (_db.select(_db.activityTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch all active activity types.
  Stream<List<ActivityType>> watchActivityTypes() {
    return (_db.select(_db.activityTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// Get all active lead sources.
  Future<List<LeadSource>> getLeadSources() async {
    return (_db.select(_db.leadSources)
          ..where((t) => t.isActive.equals(true)))
        .get();
  }

  /// Get all active decline reasons.
  Future<List<DeclineReason>> getDeclineReasons() async {
    return (_db.select(_db.declineReasons)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  // ============================================
  // HVC
  // ============================================

  /// Get all active HVC types.
  Future<List<HvcType>> getHvcTypes() async {
    return (_db.select(_db.hvcTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Watch all active HVC types.
  Stream<List<HvcType>> watchHvcTypes() {
    return (_db.select(_db.hvcTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  // ============================================
  // BULK INSERT (for sync from remote)
  // ============================================

  /// Upsert provinces from remote.
  Future<void> upsertProvinces(List<ProvincesCompanion> provinces) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.provinces, provinces);
    });
  }

  /// Upsert cities from remote.
  Future<void> upsertCities(List<CitiesCompanion> cities) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.cities, cities);
    });
  }

  /// Upsert company types from remote.
  Future<void> upsertCompanyTypes(List<CompanyTypesCompanion> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.companyTypes, items);
    });
  }

  /// Upsert ownership types from remote.
  Future<void> upsertOwnershipTypes(List<OwnershipTypesCompanion> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.ownershipTypes, items);
    });
  }

  /// Upsert industries from remote.
  Future<void> upsertIndustries(List<IndustriesCompanion> items) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.industries, items);
    });
  }
}
