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

  final database = ref.watch(databaseProvider);

  return BrokerRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
  );
});

// ==========================================
// List Providers
// ==========================================

/// Default page size for broker pagination.
const brokerPageSize = 25;

/// Stream provider for all brokers.
/// @deprecated Use [paginatedBrokersProvider] for lazy loading.
final brokerListStreamProvider = StreamProvider<List<domain.Broker>>((ref) {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.watchAllBrokers();
});

/// Provider for searching brokers.
/// @deprecated Use [paginatedBrokersProvider] with search query for lazy loading.
final brokerSearchProvider = FutureProvider.autoDispose
    .family<List<domain.Broker>, String>((ref, query) async {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.searchBrokers(query);
});

// ==========================================
// Paginated Broker Providers
// ==========================================

/// State provider for broker list pagination limit.
/// Increment this to load more items.
final brokerLimitProvider = StateProvider<int>((ref) => brokerPageSize);

/// Provider for watching brokers with pagination (reactive stream).
/// Handles both list and search - pass null for full list or search query.
final paginatedBrokersProvider =
    StreamProvider.family<List<domain.Broker>, String?>((ref, searchQuery) {
  final limit = ref.watch(brokerLimitProvider);
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.watchBrokersPaginated(limit: limit, searchQuery: searchQuery);
});

/// Provider for total broker count (for "hasMore" calculation).
/// Pass search query to get filtered count.
final brokerTotalCountProvider =
    FutureProvider.family<int, String?>((ref, searchQuery) {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.getBrokerCount(searchQuery: searchQuery);
});

// ==========================================
// Detail Providers
// ==========================================

/// Provider for watching a single broker by ID (reactive stream).
final brokerDetailProvider =
    StreamProvider.family<domain.Broker?, String>((ref, id) {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.watchBrokerById(id);
});

/// Provider for watching broker key persons (PICs) (reactive stream).
final brokerKeyPersonsProvider =
    StreamProvider.family<List<domain.KeyPerson>, String>((ref, brokerId) {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.watchBrokerKeyPersons(brokerId);
});

/// Provider for watching broker pipeline count (reactive stream).
final brokerPipelineCountProvider =
    StreamProvider.family<int, String>((ref, brokerId) {
  final repository = ref.watch(brokerRepositoryProvider);
  return repository.watchBrokerPipelineCount(brokerId);
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
  BrokerFormNotifier(this._repository) : super(BrokerFormState());

  final BrokerRepository _repository;

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
        // No invalidation needed - StreamProviders auto-update from Drift
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
        // No invalidation needed - StreamProviders auto-update from Drift
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
        // No invalidation needed - StreamProviders auto-update from Drift
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
  return BrokerFormNotifier(repository);
});
