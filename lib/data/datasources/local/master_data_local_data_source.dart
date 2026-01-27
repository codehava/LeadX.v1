import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../dtos/master_data_dtos.dart';
import '../../mappers/master_data_mappers.dart';

/// Local data source for master data (read-only reference tables).
class MasterDataLocalDataSource {
  final AppDatabase _db;

  MasterDataLocalDataSource(this._db);

  // ============================================
  // GEOGRAPHY
  // ============================================

  /// Get all active provinces.
  Future<List<ProvinceDto>> getProvinces() async {
    final provinces = await (_db.select(_db.provinces)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return MasterDataMappers.provinceListToDto(provinces);
  }

  /// Watch all active provinces as stream.
  Stream<List<ProvinceDto>> watchProvinces() {
    return (_db.select(_db.provinces)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((provinces) => MasterDataMappers.provinceListToDto(provinces));
  }

  /// Get cities by province ID.
  Future<List<CityDto>> getCitiesByProvince(String provinceId) async {
    final cities = await (_db.select(_db.cities)
          ..where((t) => t.provinceId.equals(provinceId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return MasterDataMappers.cityListToDto(cities);
  }

  /// Watch cities by province ID.
  Stream<List<CityDto>> watchCitiesByProvince(String provinceId) {
    return (_db.select(_db.cities)
          ..where((t) => t.provinceId.equals(provinceId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((cities) => MasterDataMappers.cityListToDto(cities));
  }

  // ============================================
  // COMPANY CLASSIFICATIONS
  // ============================================

  /// Get all active company types.
  Future<List<CompanyTypeDto>> getCompanyTypes() async {
    final types = await (_db.select(_db.companyTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.companyTypeListToDto(types);
  }

  /// Watch all active company types.
  Stream<List<CompanyTypeDto>> watchCompanyTypes() {
    return (_db.select(_db.companyTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((types) => MasterDataMappers.companyTypeListToDto(types));
  }

  /// Get all active ownership types.
  Future<List<OwnershipTypeDto>> getOwnershipTypes() async {
    final types = await (_db.select(_db.ownershipTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.ownershipTypeListToDto(types);
  }

  /// Watch all active ownership types.
  Stream<List<OwnershipTypeDto>> watchOwnershipTypes() {
    return (_db.select(_db.ownershipTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((types) => MasterDataMappers.ownershipTypeListToDto(types));
  }

  /// Get all active industries.
  Future<List<IndustryDto>> getIndustries() async {
    final industries = await (_db.select(_db.industries)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.industryListToDto(industries);
  }

  /// Watch all active industries.
  Stream<List<IndustryDto>> watchIndustries() {
    return (_db.select(_db.industries)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((industries) => MasterDataMappers.industryListToDto(industries));
  }

  // ============================================
  // PRODUCT CLASSIFICATIONS
  // ============================================

  /// Get all active COBs.
  Future<List<CobDto>> getCobs() async {
    final cobs = await (_db.select(_db.cobs)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.cobListToDto(cobs);
  }

  /// Watch all active COBs.
  Stream<List<CobDto>> watchCobs() {
    return (_db.select(_db.cobs)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((cobs) => MasterDataMappers.cobListToDto(cobs));
  }

  /// Get LOBs by COB ID.
  Future<List<LobDto>> getLobsByCob(String cobId) async {
    final lobs = await (_db.select(_db.lobs)
          ..where((t) => t.cobId.equals(cobId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.lobListToDto(lobs);
  }

  /// Watch LOBs by COB ID.
  Stream<List<LobDto>> watchLobsByCob(String cobId) {
    return (_db.select(_db.lobs)
          ..where((t) => t.cobId.equals(cobId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((lobs) => MasterDataMappers.lobListToDto(lobs));
  }

  /// Get all LOBs across all COBs.
  Future<List<LobDto>> getAllLobs() async {
    final lobs = await (_db.select(_db.lobs)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.lobListToDto(lobs);
  }

  // ============================================
  // PIPELINE CLASSIFICATIONS
  // ============================================

  /// Get all active pipeline stages.
  Future<List<PipelineStageDto>> getPipelineStages() async {
    final stages = await (_db.select(_db.pipelineStages)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
    return MasterDataMappers.pipelineStageListToDto(stages);
  }

  /// Watch all active pipeline stages.
  Stream<List<PipelineStageDto>> watchPipelineStages() {
    return (_db.select(_db.pipelineStages)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .watch()
        .map((stages) => MasterDataMappers.pipelineStageListToDto(stages));
  }

  /// Get pipeline statuses by stage ID.
  Future<List<PipelineStatusDto>> getStatusesByStage(String stageId) async {
    final statuses = await (_db.select(_db.pipelineStatuses)
          ..where((t) => t.stageId.equals(stageId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
    return MasterDataMappers.pipelineStatusListToDto(statuses);
  }

  // ============================================
  // ACTIVITY CLASSIFICATIONS
  // ============================================

  /// Get all active activity types.
  Future<List<ActivityTypeDto>> getActivityTypes() async {
    final types = await (_db.select(_db.activityTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.activityTypeListToDto(types);
  }

  /// Watch all active activity types.
  Stream<List<ActivityTypeDto>> watchActivityTypes() {
    return (_db.select(_db.activityTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((types) => MasterDataMappers.activityTypeListToDto(types));
  }

  /// Get all active lead sources.
  Future<List<LeadSourceDto>> getLeadSources() async {
    final sources = await (_db.select(_db.leadSources)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return MasterDataMappers.leadSourceListToDto(sources);
  }

  /// Watch all active lead sources.
  Stream<List<LeadSourceDto>> watchLeadSources() {
    return (_db.select(_db.leadSources)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((sources) => MasterDataMappers.leadSourceListToDto(sources));
  }

  /// Get all active decline reasons.
  Future<List<DeclineReasonDto>> getDeclineReasons() async {
    final reasons = await (_db.select(_db.declineReasons)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.declineReasonListToDto(reasons);
  }

  // ============================================
  // HVC
  // ============================================

  /// Get all active HVC types.
  Future<List<HvcTypeDto>> getHvcTypes() async {
    final types = await (_db.select(_db.hvcTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return MasterDataMappers.hvcTypeListToDto(types);
  }

  /// Watch all active HVC types.
  Stream<List<HvcTypeDto>> watchHvcTypes() {
    return (_db.select(_db.hvcTypes)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((types) => MasterDataMappers.hvcTypeListToDto(types));
  }

  // ============================================
  // BROKERS (NOT REFACTORED - Transactional data)
  // ============================================

  /// Get all active brokers.
  /// Note: Brokers are transactional data with sync tracking, not pure master data.
  Future<List<Broker>> getBrokers() async {
    return (_db.select(_db.brokers)
          ..where((t) => t.isActive.equals(true) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch all active brokers.
  Stream<List<Broker>> watchBrokers() {
    return (_db.select(_db.brokers)
          ..where((t) => t.isActive.equals(true) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
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
