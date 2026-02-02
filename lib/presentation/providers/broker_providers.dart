import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/broker_local_data_source.dart';
import '../../data/datasources/remote/broker_remote_data_source.dart';
import '../../data/dtos/broker_dtos.dart';
import '../../data/repositories/broker_repository_impl.dart';
import '../../domain/entities/broker.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/repositories/broker_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for Broker local data source.
final brokerLocalDataSourceProvider = Provider<BrokerLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return BrokerLocalDataSource(database);
});

/// Provider for Broker remote data source.
final brokerRemoteDataSourceProvider = Provider<BrokerRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BrokerRemoteDataSource(supabase);
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the Broker repository.
final brokerRepositoryProvider = Provider<BrokerRepository>((ref) {
  final localDataSource = ref.watch(brokerLocalDataSourceProvider);
  final remoteDataSource = ref.watch(brokerRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  return BrokerRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
  );
});

// ==========================================
// List Providers
// ==========================================

/// Stream provider for all brokers.
final brokerListStreamProvider = StreamProvider<List<domain.Broker>>((ref) {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.watchAllBrokers();
});

/// Provider for searching brokers.
final brokerSearchProvider = FutureProvider.autoDispose
    .family<List<domain.Broker>, String>((ref, query) async {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.searchBrokers(query);
});

// ==========================================
// Detail Providers
// ==========================================

/// Provider for fetching a single broker by ID.
final brokerDetailProvider =
    FutureProvider.family<domain.Broker?, String>((ref, id) async {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.getBrokerById(id);
});

/// Provider for broker key persons (PICs).
final brokerKeyPersonsProvider =
    FutureProvider.family<List<domain.KeyPerson>, String>((ref, brokerId) async {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.getBrokerKeyPersons(brokerId);
});

/// Provider for broker pipeline count.
final brokerPipelineCountProvider =
    FutureProvider.family<int, String>((ref, brokerId) async {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.getBrokerPipelineCount(brokerId);
});

// ==========================================
// Form Notifiers
// ==========================================

/// State for Broker form.
class BrokerFormState {
  BrokerFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedBroker,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.Broker? savedBroker;

  BrokerFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.Broker? savedBroker,
  }) {
    return BrokerFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      savedBroker: savedBroker ?? this.savedBroker,
    );
  }
}

/// Notifier for Broker form operations.
class BrokerFormNotifier extends StateNotifier<BrokerFormState> {
  BrokerFormNotifier(this._ref, this._repository) : super(BrokerFormState());

  final Ref _ref;
  final BrokerRepository _repository;

  /// Invalidate broker-related providers after mutations.
  void _invalidateBrokerProviders(String brokerId) {
    _ref.invalidate(brokerDetailProvider(brokerId));
    _ref.invalidate(brokerKeyPersonsProvider(brokerId));
    _ref.invalidate(brokerPipelineCountProvider(brokerId));
  }

  /// Create a new broker.
  Future<void> createBroker(BrokerCreateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.createBroker(dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (broker) {
        state = state.copyWith(
          isLoading: false,
          savedBroker: broker,
        );
        _invalidateBrokerProviders(broker.id);
      },
    );
  }

  /// Update an existing broker.
  Future<void> updateBroker(String id, BrokerUpdateDto dto) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.updateBroker(id, dto);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (broker) {
        state = state.copyWith(
          isLoading: false,
          savedBroker: broker,
        );
        _invalidateBrokerProviders(broker.id);
      },
    );
  }

  /// Delete a broker.
  Future<void> deleteBroker(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.deleteBroker(id);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(isLoading: false);
        _invalidateBrokerProviders(id);
      },
    );
  }

  /// Reset form state.
  void reset() {
    state = BrokerFormState();
  }
}

/// Provider for Broker form notifier.
final brokerFormNotifierProvider =
    StateNotifierProvider.autoDispose<BrokerFormNotifier, BrokerFormState>(
        (ref) {
  final repository = ref.watch(brokerRepositoryProvider);
  return BrokerFormNotifier(ref, repository);
});
