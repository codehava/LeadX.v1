import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
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

  /// Get a specific customer by ID.
  Future<Customer?> getCustomerById(String id);

  /// Create a new customer.
  /// Saves locally first, then queues for sync.
  Future<Either<Failure, Customer>> createCustomer(CustomerCreateDto dto);

  /// Update an existing customer.
  /// Updates locally first, then queues for sync.
  Future<Either<Failure, Customer>> updateCustomer(
    String id,
    CustomerUpdateDto dto,
  );

  /// Soft delete a customer.
  /// Marks as deleted locally, then queues for sync.
  Future<Either<Failure, void>> deleteCustomer(String id);

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

  /// Add a key person to a customer.
  Future<Either<Failure, KeyPerson>> addKeyPerson(KeyPersonDto dto);

  /// Update an existing key person.
  Future<Either<Failure, KeyPerson>> updateKeyPerson(
    String id,
    KeyPersonDto dto,
  );

  /// Delete a key person.
  Future<Either<Failure, void>> deleteKeyPerson(String id);

  /// Get the primary key person for a customer.
  Future<KeyPerson?> getPrimaryKeyPerson(String customerId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync customers from remote to local.
  /// Uses incremental sync based on updatedAt timestamp.
  Future<Either<Failure, int>> syncFromRemote({DateTime? since});

  /// Mark a customer as synced.
  Future<void> markAsSynced(String id, DateTime syncedAt);
}
