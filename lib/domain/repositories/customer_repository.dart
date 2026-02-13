import '../../core/errors/result.dart';
import '../entities/customer.dart';
import '../entities/key_person.dart';
import '../../data/dtos/customer_dtos.dart';

/// Repository interface for customer operations.
abstract class CustomerRepository {
  // ==========================================
  // Customer CRUD Operations
  // ==========================================

  /// Watch all customers (reactive stream).
  /// Returns customers assigned to current user based on hierarchy.
  Stream<List<Customer>> watchAllCustomers();

  /// Watch customers with pagination support (reactive stream).
  /// Returns up to [limit] customers, optionally filtered by [searchQuery].
  Stream<List<Customer>> watchCustomersPaginated({
    required int limit,
    String? searchQuery,
  });

  /// Get total count of customers, optionally filtered by [searchQuery].
  /// Used for pagination "hasMore" calculation.
  Future<int> getCustomerCount({String? searchQuery});

  /// Watch a specific customer by ID (reactive stream).
  Stream<Customer?> watchCustomerById(String id);

  /// Get a specific customer by ID.
  Future<Customer?> getCustomerById(String id);

  /// Create a new customer.
  /// Saves locally first, then queues for sync.
  Future<Result<Customer>> createCustomer(CustomerCreateDto dto);

  /// Update an existing customer.
  /// Updates locally first, then queues for sync.
  Future<Result<Customer>> updateCustomer(
    String id,
    CustomerUpdateDto dto,
  );

  /// Soft delete a customer.
  /// Marks as deleted locally, then queues for sync.
  Future<Result<void>> deleteCustomer(String id);

  // ==========================================
  // Search & Filter
  // ==========================================

  /// Search customers by name, code, or address.
  Future<List<Customer>> searchCustomers(String query);

  /// Get customers by assigned RM.
  Future<List<Customer>> getCustomersByAssignedRm(String rmId);

  /// Get customers that need to be synced.
  Future<List<Customer>> getPendingSyncCustomers();

  // ==========================================
  // Key Person Operations
  // ==========================================

  /// Get all key persons for a customer.
  Future<List<KeyPerson>> getCustomerKeyPersons(String customerId);

  /// Watch all key persons for a customer (reactive stream).
  Stream<List<KeyPerson>> watchCustomerKeyPersons(String customerId);

  /// Watch the primary key person for a customer (reactive stream).
  Stream<KeyPerson?> watchPrimaryKeyPerson(String customerId);

  /// Add a key person to a customer.
  Future<Result<KeyPerson>> addKeyPerson(KeyPersonDto dto);

  /// Update an existing key person.
  Future<Result<KeyPerson>> updateKeyPerson(
    String id,
    KeyPersonDto dto,
  );

  /// Delete a key person.
  Future<Result<void>> deleteKeyPerson(String id);

  /// Get the primary key person for a customer.
  Future<KeyPerson?> getPrimaryKeyPerson(String customerId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync customers from remote to local.
  /// Uses incremental sync based on updatedAt timestamp.
  Future<Result<int>> syncFromRemote({DateTime? since});

  /// Sync key persons from remote to local.
  Future<Result<int>> syncKeyPersonsFromRemote({DateTime? since});

  /// Mark a customer as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt);
}
