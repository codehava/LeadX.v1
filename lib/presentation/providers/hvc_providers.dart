import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/result.dart';
import '../../data/datasources/local/hvc_local_data_source.dart';
import '../../data/datasources/remote/hvc_remote_data_source.dart';
import '../../data/dtos/hvc_dtos.dart';
import '../../data/repositories/hvc_repository_impl.dart';
import '../../domain/entities/hvc.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/repositories/hvc_repository.dart';
import 'auth_providers.dart';
import 'customer_providers.dart';
import 'database_provider.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for HVC local data source.
final hvcLocalDataSourceProvider = Provider<HvcLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return HvcLocalDataSource(db);
});

/// Provider for HVC remote data source.
final hvcRemoteDataSourceProvider = Provider<HvcRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return HvcRemoteDataSource(supabase);
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the HVC repository.
final hvcRepositoryProvider = Provider<HvcRepository>((ref) {
  final localDataSource = ref.watch(hvcLocalDataSourceProvider);
  final remoteDataSource = ref.watch(hvcRemoteDataSourceProvider);
  final keyPersonLocalDataSource = ref.watch(keyPersonLocalDataSourceProvider);
  final customerLocalDataSource = ref.watch(customerLocalDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).value;

  final database = ref.watch(databaseProvider);

  return HvcRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    keyPersonLocalDataSource: keyPersonLocalDataSource,
    customerLocalDataSource: customerLocalDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
  );
});

// ==========================================
// HVC List Providers
// ==========================================

/// Default page size for HVC pagination.
const hvcPageSize = 25;

/// Provider for watching all HVCs as a stream.
/// @deprecated Use [paginatedHvcsProvider] for lazy loading.
final hvcListStreamProvider = StreamProvider<List<domain.Hvc>>((ref) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchAllHvcs();
});

/// Provider for fetching HVCs by search query.
/// @deprecated Use [paginatedHvcsProvider] with search query for lazy loading.
final hvcSearchProvider = FutureProvider.family
    .autoDispose<List<domain.Hvc>, String>((ref, query) async {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.searchHvcs(query);
});

// ==========================================
// Paginated HVC Providers
// ==========================================

/// State provider for HVC list pagination limit.
/// Increment this to load more items.
final hvcLimitProvider = StateProvider<int>((ref) => hvcPageSize);

/// Provider for watching HVCs with pagination (reactive stream).
/// Handles both list and search - pass null for full list or search query.
final paginatedHvcsProvider =
    StreamProvider.family<List<domain.Hvc>, String?>((ref, searchQuery) {
  final limit = ref.watch(hvcLimitProvider);
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchHvcsPaginated(limit: limit, searchQuery: searchQuery);
});

/// Provider for total HVC count (for "hasMore" calculation).
/// Pass search query to get filtered count.
final hvcTotalCountProvider =
    FutureProvider.family<int, String?>((ref, searchQuery) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.getHvcCount(searchQuery: searchQuery);
});

// ==========================================
// HVC Detail Providers
// ==========================================

/// Provider for watching a single HVC by ID (reactive stream).
final hvcDetailProvider =
    StreamProvider.family<domain.Hvc?, String>((ref, id) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchHvcById(id);
});

/// @deprecated Use [hvcTypesStreamProvider] from master_data_providers instead.
/// Returns DTOs for better separation of concerns.
final hvcTypesProvider = FutureProvider<List<domain.HvcType>>((ref) async {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.getHvcTypes();
});

/// Provider for watching key persons of an HVC (reactive stream).
final hvcKeyPersonsProvider =
    StreamProvider.family<List<domain.KeyPerson>, String>((ref, hvcId) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchHvcKeyPersons(hvcId);
});

// ==========================================
// Customer-HVC Link Providers
// ==========================================

/// Provider for watching linked customers of an HVC.
final linkedCustomersProvider = StreamProvider.family<
    List<domain.CustomerHvcLink>, String>((ref, hvcId) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchLinkedCustomers(hvcId);
});

/// Provider for watching HVCs linked to a customer.
final customerHvcsProvider = StreamProvider.family<
    List<domain.CustomerHvcLink>, String>((ref, customerId) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchCustomerHvcs(customerId);
});

/// Provider for linked customer count of an HVC (derived from existing stream).
final linkedCustomerCountProvider =
    StreamProvider.family<int, String>((ref, hvcId) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchLinkedCustomers(hvcId).map((links) => links.length);
});

// ==========================================
// Form Notifiers
// ==========================================

/// State for HVC form.
class HvcFormState {
  HvcFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedHvc,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.Hvc? savedHvc;

  HvcFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.Hvc? savedHvc,
  }) =>
      HvcFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        savedHvc: savedHvc ?? this.savedHvc,
      );
}

/// Notifier for HVC form operations.
class HvcFormNotifier extends StateNotifier<HvcFormState> {
  HvcFormNotifier(this._repository) : super(HvcFormState());

  final HvcRepository _repository;

  /// Create a new HVC.
  Future<void> createHvc(HvcCreateDto dto) async {
    state = HvcFormState(isLoading: true);

    final result = await _repository.createHvc(dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedHvc: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Update an existing HVC.
  Future<void> updateHvc(String id, HvcUpdateDto dto) async {
    state = HvcFormState(isLoading: true);

    final result = await _repository.updateHvc(id, dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedHvc: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Delete an HVC.
  Future<bool> deleteHvc(String id) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteHvc(id);

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Reset form state.
  void reset() {
    state = HvcFormState();
  }
}

/// Provider for HVC form notifier.
final hvcFormNotifierProvider =
    StateNotifierProvider.autoDispose<HvcFormNotifier, HvcFormState>((ref) {
  final repository = ref.watch(hvcRepositoryProvider);
  return HvcFormNotifier(repository);
});

// ==========================================
// Customer-HVC Link Notifier
// ==========================================

/// State for customer-HVC link operations.
class CustomerHvcLinkState {
  CustomerHvcLinkState({
    this.isLoading = false,
    this.errorMessage,
    this.savedLink,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.CustomerHvcLink? savedLink;

  CustomerHvcLinkState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.CustomerHvcLink? savedLink,
  }) =>
      CustomerHvcLinkState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        savedLink: savedLink ?? this.savedLink,
      );
}

/// Notifier for customer-HVC link operations.
class CustomerHvcLinkNotifier extends StateNotifier<CustomerHvcLinkState> {
  CustomerHvcLinkNotifier(this._repository) : super(CustomerHvcLinkState());

  final HvcRepository _repository;

  /// Link customer to HVC.
  Future<void> linkCustomerToHvc(CustomerHvcLinkDto dto) async {
    state = CustomerHvcLinkState(isLoading: true);

    final result = await _repository.linkCustomerToHvc(dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedLink: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Unlink customer from HVC.
  Future<bool> unlinkCustomerFromHvc(String linkId, {required String hvcId, required String customerId}) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.unlinkCustomerFromHvc(linkId);

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        // No invalidation needed - StreamProviders auto-update from Drift
        return true;
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
    }
  }

  /// Reset state.
  void reset() {
    state = CustomerHvcLinkState();
  }
}

/// Provider for customer-HVC link notifier.
final customerHvcLinkNotifierProvider = StateNotifierProvider.autoDispose<
    CustomerHvcLinkNotifier, CustomerHvcLinkState>((ref) {
  final repository = ref.watch(hvcRepositoryProvider);
  return CustomerHvcLinkNotifier(repository);
});
