import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/result.dart';
import '../../data/datasources/local/customer_local_data_source.dart';
import '../../data/datasources/local/key_person_local_data_source.dart';
import '../../data/datasources/remote/customer_remote_data_source.dart';
import '../../data/dtos/customer_dtos.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart' as domain;
import '../../domain/entities/key_person.dart' as domain;
import '../../domain/repositories/customer_repository.dart';
import 'activity_providers.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'pipeline_providers.dart';
import 'sync_providers.dart';

// ==========================================
// Data Source Providers
// ==========================================

/// Provider for the customer local data source.
final customerLocalDataSourceProvider =
    Provider<CustomerLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerLocalDataSource(db);
});

/// Provider for the key person local data source.
final keyPersonLocalDataSourceProvider =
    Provider<KeyPersonLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return KeyPersonLocalDataSource(db);
});

/// Provider for the customer remote data source.
final customerRemoteDataSourceProvider =
    Provider<CustomerRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CustomerRemoteDataSource(supabase);
});

/// Provider for the key person remote data source.
final keyPersonRemoteDataSourceProvider =
    Provider<KeyPersonRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return KeyPersonRemoteDataSource(supabase);
});

// ==========================================
// Repository Provider
// ==========================================

/// Provider for the customer repository.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final localDataSource = ref.watch(customerLocalDataSourceProvider);
  final keyPersonLocalDataSource = ref.watch(keyPersonLocalDataSourceProvider);
  final pipelineLocalDataSource = ref.watch(pipelineLocalDataSourceProvider);
  final activityLocalDataSource = ref.watch(activityLocalDataSourceProvider);
  final remoteDataSource = ref.watch(customerRemoteDataSourceProvider);
  final keyPersonRemoteDataSource = ref.watch(keyPersonRemoteDataSourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final currentUser = ref.watch(currentUserProvider).value;
  final database = ref.watch(databaseProvider);

  return CustomerRepositoryImpl(
    localDataSource: localDataSource,
    keyPersonLocalDataSource: keyPersonLocalDataSource,
    pipelineLocalDataSource: pipelineLocalDataSource,
    activityLocalDataSource: activityLocalDataSource,
    remoteDataSource: remoteDataSource,
    keyPersonRemoteDataSource: keyPersonRemoteDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
    database: database,
  );
});

// ==========================================
// Customer List Providers
// ==========================================

/// Default page size for customer pagination.
const customerPageSize = 25;

/// Provider for watching all customers as a stream.
/// @deprecated Use [paginatedCustomersProvider] for lazy loading.
final customerListStreamProvider =
    StreamProvider<List<domain.Customer>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchAllCustomers();
});

/// Provider for fetching customers by search query.
/// @deprecated Use [paginatedCustomersProvider] with search query for lazy loading.
final customerSearchProvider = FutureProvider.family
    .autoDispose<List<domain.Customer>, String>((ref, query) async {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.searchCustomers(query);
});

// ==========================================
// Paginated Customer Providers
// ==========================================

/// State provider for customer list pagination limit.
/// Increment this to load more items.
final customerLimitProvider = StateProvider<int>((ref) => customerPageSize);

/// Provider for watching customers with pagination (reactive stream).
/// Handles both list and search - pass null for full list or search query.
final paginatedCustomersProvider =
    StreamProvider.family<List<domain.Customer>, String?>((ref, searchQuery) {
  final limit = ref.watch(customerLimitProvider);
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchCustomersPaginated(limit: limit, searchQuery: searchQuery);
});

/// Provider for total customer count (for "hasMore" calculation).
/// Pass search query to get filtered count.
final customerTotalCountProvider =
    FutureProvider.family<int, String?>((ref, searchQuery) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerCount(searchQuery: searchQuery);
});

// ==========================================
// Customer Detail Providers
// ==========================================

/// Provider for watching a single customer by ID (reactive stream).
final customerDetailProvider =
    StreamProvider.family<domain.Customer?, String>((ref, id) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchCustomerById(id);
});

/// Provider for watching key persons of a customer (reactive stream).
final customerKeyPersonsProvider =
    StreamProvider.family<List<domain.KeyPerson>, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchCustomerKeyPersons(customerId);
});

/// Provider for watching the primary key person of a customer (reactive stream).
final primaryKeyPersonProvider =
    StreamProvider.family<domain.KeyPerson?, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.watchPrimaryKeyPerson(customerId);
});

// ==========================================
// Form Notifiers
// ==========================================

/// State for customer form.
class CustomerFormState {
  CustomerFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedCustomer,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.Customer? savedCustomer;

  CustomerFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.Customer? savedCustomer,
  }) =>
      CustomerFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        savedCustomer: savedCustomer ?? this.savedCustomer,
      );
}

/// Notifier for customer form operations.
class CustomerFormNotifier extends StateNotifier<CustomerFormState> {
  CustomerFormNotifier(this._repository) : super(CustomerFormState());

  final CustomerRepository _repository;

  /// Create a new customer.
  Future<void> createCustomer(CustomerCreateDto dto) async {
    // Clear any previous error and set loading
    state = CustomerFormState(isLoading: true);

    final result = await _repository.createCustomer(dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedCustomer: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Update an existing customer.
  Future<void> updateCustomer(String id, CustomerUpdateDto dto) async {
    // Clear any previous error and set loading
    state = CustomerFormState(isLoading: true);

    final result = await _repository.updateCustomer(id, dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedCustomer: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Reset form state.
  void reset() {
    state = CustomerFormState();
  }
}

/// Provider for customer form notifier.
final customerFormNotifierProvider =
    StateNotifierProvider.autoDispose<CustomerFormNotifier, CustomerFormState>(
        (ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerFormNotifier(repository);
});

// ==========================================
// Key Person Form Notifiers
// ==========================================

/// State for key person form.
class KeyPersonFormState {
  KeyPersonFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedKeyPerson,
  });

  final bool isLoading;
  final String? errorMessage;
  final domain.KeyPerson? savedKeyPerson;

  KeyPersonFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    domain.KeyPerson? savedKeyPerson,
  }) =>
      KeyPersonFormState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        savedKeyPerson: savedKeyPerson ?? this.savedKeyPerson,
      );
}

/// Notifier for key person form operations.
class KeyPersonFormNotifier extends StateNotifier<KeyPersonFormState> {
  KeyPersonFormNotifier(this._repository) : super(KeyPersonFormState());

  final CustomerRepository _repository;

  /// Add a new key person.
  Future<void> addKeyPerson(KeyPersonDto dto) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.addKeyPerson(dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedKeyPerson: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Update an existing key person.
  Future<void> updateKeyPerson(String id, KeyPersonDto dto) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.updateKeyPerson(id, dto);

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          savedKeyPerson: value,
        );
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Delete a key person.
  Future<void> deleteKeyPerson(String id, {String? customerId}) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteKeyPerson(id);

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        // No invalidation needed - StreamProviders auto-update from Drift
      case ResultFailure(:final failure):
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
  }

  /// Reset form state.
  void reset() {
    state = KeyPersonFormState();
  }
}

/// Provider for key person form notifier.
final keyPersonFormNotifierProvider = StateNotifierProvider.autoDispose<
    KeyPersonFormNotifier, KeyPersonFormState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return KeyPersonFormNotifier(repository);
});
