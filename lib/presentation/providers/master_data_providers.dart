import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/datasources/local/master_data_local_data_source.dart';
import '../../data/dtos/master_data_dtos.dart';
import 'database_provider.dart';

// ============================================
// DATA SOURCE PROVIDER
// ============================================

/// Provider for MasterDataLocalDataSource.
final masterDataLocalDataSourceProvider = Provider<MasterDataLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return MasterDataLocalDataSource(db);
});

// ============================================
// GEOGRAPHY PROVIDERS
// ============================================

/// Stream of all active provinces.
final provincesStreamProvider = StreamProvider<List<ProvinceDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchProvinces();
});

/// Stream of cities filtered by province ID.
final citiesByProvinceProvider = StreamProvider.family<List<CityDto>, String?>((ref, provinceId) {
  if (provinceId == null || provinceId.isEmpty) {
    return Stream.value([]);
  }
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchCitiesByProvince(provinceId);
});

// ============================================
// COMPANY CLASSIFICATION PROVIDERS
// ============================================

/// Stream of all active company types.
final companyTypesStreamProvider = StreamProvider<List<CompanyTypeDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchCompanyTypes();
});

/// Stream of all active ownership types.
final ownershipTypesStreamProvider = StreamProvider<List<OwnershipTypeDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchOwnershipTypes();
});

/// Stream of all active industries.
final industriesStreamProvider = StreamProvider<List<IndustryDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchIndustries();
});

// ============================================
// PRODUCT CLASSIFICATION PROVIDERS
// ============================================

/// Stream of all active COBs (Class of Business).
final cobsStreamProvider = StreamProvider<List<CobDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchCobs();
});

/// Stream of LOBs (Line of Business) filtered by COB ID.
final lobsByCobProvider = StreamProvider.family<List<LobDto>, String?>((ref, cobId) {
  if (cobId == null || cobId.isEmpty) {
    return Stream.value([]);
  }
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchLobsByCob(cobId);
});

// ============================================
// PIPELINE CLASSIFICATION PROVIDERS
// ============================================

/// Stream of all active pipeline stages.
final pipelineStagesStreamProvider = StreamProvider<List<PipelineStageDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchPipelineStages();
});

// ============================================
// ACTIVITY CLASSIFICATION PROVIDERS
// ============================================

/// Stream of all active activity types.
final activityTypesStreamProvider = StreamProvider<List<ActivityTypeDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchActivityTypes();
});

// ============================================
// LEAD SOURCE PROVIDERS
// ============================================

/// Stream of all active lead sources.
final leadSourcesStreamProvider = StreamProvider<List<LeadSourceDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchLeadSources();
});

// ============================================
// BROKER PROVIDERS
// ============================================

/// Stream of all active brokers.
final brokersStreamProvider = StreamProvider<List<Broker>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchBrokers();
});

// ============================================
// DECLINE REASON PROVIDERS
// ============================================

/// Stream of all active decline reasons.
final declineReasonsStreamProvider = StreamProvider<List<DeclineReasonDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.getDeclineReasons().asStream();
});

// ============================================
// HVC TYPE PROVIDERS
// ============================================

/// Stream of all active HVC types.
final hvcTypesStreamProvider = StreamProvider<List<HvcTypeDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchHvcTypes();
});

// ============================================
// ORGANIZATION PROVIDERS
// ============================================

/// Stream of all active regional offices.
final regionalOfficesStreamProvider = StreamProvider<List<RegionalOfficeDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchRegionalOffices();
});

/// Stream of all active branches.
final branchesStreamProvider = StreamProvider<List<BranchDto>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchBranches();
});
