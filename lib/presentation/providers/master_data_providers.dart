import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/datasources/local/master_data_local_data_source.dart';
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
final provincesStreamProvider = StreamProvider<List<Province>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchProvinces();
});

/// Stream of cities filtered by province ID.
final citiesByProvinceProvider = StreamProvider.family<List<City>, String?>((ref, provinceId) {
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
final companyTypesStreamProvider = StreamProvider<List<CompanyType>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchCompanyTypes();
});

/// Stream of all active ownership types.
final ownershipTypesStreamProvider = StreamProvider<List<OwnershipType>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchOwnershipTypes();
});

/// Stream of all active industries.
final industriesStreamProvider = StreamProvider<List<Industry>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchIndustries();
});

// ============================================
// PRODUCT CLASSIFICATION PROVIDERS
// ============================================

/// Stream of all active COBs (Class of Business).
final cobsStreamProvider = StreamProvider<List<Cob>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchCobs();
});

/// Stream of LOBs (Line of Business) filtered by COB ID.
final lobsByCobProvider = StreamProvider.family<List<Lob>, String?>((ref, cobId) {
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
final pipelineStagesStreamProvider = StreamProvider<List<PipelineStage>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchPipelineStages();
});

// ============================================
// ACTIVITY CLASSIFICATION PROVIDERS
// ============================================

/// Stream of all active activity types.
final activityTypesStreamProvider = StreamProvider<List<ActivityType>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchActivityTypes();
});

// ============================================
// HVC PROVIDERS
// ============================================

/// Stream of all active HVC types.
final hvcTypesStreamProvider = StreamProvider<List<HvcType>>((ref) {
  final dataSource = ref.watch(masterDataLocalDataSourceProvider);
  return dataSource.watchHvcTypes();
});
