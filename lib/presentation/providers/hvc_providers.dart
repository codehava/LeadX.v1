import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  return HvcRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    keyPersonLocalDataSource: keyPersonLocalDataSource,
    customerLocalDataSource: customerLocalDataSource,
    syncService: syncService,
    currentUserId: currentUser?.id ?? '',
  );
});

// ==========================================
// HVC List Providers
// ==========================================

/// Provider for watching all HVCs as a stream.
final hvcListStreamProvider = StreamProvider<List<domain.Hvc>>((ref) {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.watchAllHvcs();
});

/// Provider for fetching HVCs by search query.
final hvcSearchProvider = FutureProvider.family
    .autoDispose<List<domain.Hvc>, String>((ref, query) async {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.searchHvcs(query);
});

// ==========================================
// HVC Detail Providers
// ==========================================

/// Provider for fetching a single HVC by ID.
final hvcDetailProvider =
    FutureProvider.family<domain.Hvc?, String>((ref, id) async {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.getHvcById(id);
});

/// @deprecated Use [hvcTypesStreamProvider] from master_data_providers instead.
/// Returns DTOs for better separation of concerns.
final hvcTypesProvider = FutureProvider<List<domain.HvcType>>((ref) async {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.getHvcTypes();
});

/// Provider for fetching key persons of an HVC.
final hvcKeyPersonsProvider =
    FutureProvider.family<List<domain.KeyPerson>, String>((ref, hvcId) async {
  final repository = ref.watch(hvcRepositoryProvider);
  return repository.getHvcKeyPersons(hvcId);
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

/// Provider for linked customer count of an HVC.
final linkedCustomerCountProvider =
    FutureProvider.family<int, String>((ref, hvcId) async {
  final repository = ref.watch(hvcRepositoryProvider);
  final links = await repository.getLinkedCustomers(hvcId);
  return links.length;
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

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (hvc) => state = state.copyWith(
        isLoading: false,
        savedHvc: hvc,
      ),
    );
  }

  /// Update an existing HVC.
  Future<void> updateHvc(String id, HvcUpdateDto dto) async {
    state = HvcFormState(isLoading: true);

    final result = await _repository.updateHvc(id, dto);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (hvc) => state = state.copyWith(
        isLoading: false,
        savedHvc: hvc,
      ),
    );
  }

  /// Delete an HVC.
  Future<bool> deleteHvc(String id) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteHvc(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
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

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (link) => state = state.copyWith(
        isLoading: false,
        savedLink: link,
      ),
    );
  }

  /// Unlink customer from HVC.
  Future<bool> unlinkCustomerFromHvc(String linkId) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.unlinkCustomerFromHvc(linkId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
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
