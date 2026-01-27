import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/remote/admin_master_data_remote_data_source.dart';
import '../../data/repositories/admin_master_data_repository_impl.dart';
import '../../domain/repositories/admin_master_data_repository.dart';

// ============================================
// SUPABASE CLIENT PROVIDER
// ============================================

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ============================================
// ADMIN MASTER DATA PROVIDERS
// ============================================

/// Provider for AdminMasterDataRemoteDataSource
final adminMasterDataRemoteDataSourceProvider =
    Provider<AdminMasterDataRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AdminMasterDataRemoteDataSource(supabaseClient);
});

/// Provider for AdminMasterDataRepository
final adminMasterDataRepositoryProvider =
    Provider<AdminMasterDataRepository>((ref) {
  final remoteDataSource = ref.watch(adminMasterDataRemoteDataSourceProvider);
  return AdminMasterDataRepositoryImpl(remoteDataSource: remoteDataSource);
});
