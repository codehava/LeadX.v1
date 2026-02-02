import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/dtos/hvc_dtos.dart';
import '../entities/hvc.dart';
import '../entities/key_person.dart';

/// Repository interface for HVC operations.
abstract class HvcRepository {
  // ==========================================
  // HVC Operations
  // ==========================================

  /// Watch all HVCs as a stream.
  Stream<List<Hvc>> watchAllHvcs();

  /// Watch a single HVC by ID (reactive stream).
  Stream<Hvc?> watchHvcById(String id);

  /// Get all HVCs.
  Future<List<Hvc>> getAllHvcs();

  /// Get a single HVC by ID.
  Future<Hvc?> getHvcById(String id);

  /// Create a new HVC (Admin only).
  Future<Either<Failure, Hvc>> createHvc(HvcCreateDto dto);

  /// Update an existing HVC (Admin only).
  Future<Either<Failure, Hvc>> updateHvc(String id, HvcUpdateDto dto);

  /// Delete an HVC (Admin only, soft delete).
  Future<Either<Failure, void>> deleteHvc(String id);

  /// Search HVCs by name or code.
  Future<List<Hvc>> searchHvcs(String query);

  // ==========================================
  // HVC Type Operations (Master Data)
  // ==========================================

  /// Get all HVC types.
  Future<List<HvcType>> getHvcTypes();

  // ==========================================
  // Key Person Operations (reuse existing KeyPerson with ownerType=HVC)
  // ==========================================

  /// Get key persons for an HVC.
  Future<List<KeyPerson>> getHvcKeyPersons(String hvcId);

  /// Watch key persons for an HVC (reactive stream).
  Stream<List<KeyPerson>> watchHvcKeyPersons(String hvcId);

  // ==========================================
  // Customer-HVC Link Operations
  // ==========================================

  /// Watch linked customers for an HVC.
  Stream<List<CustomerHvcLink>> watchLinkedCustomers(String hvcId);

  /// Get linked customers for an HVC.
  Future<List<CustomerHvcLink>> getLinkedCustomers(String hvcId);

  /// Watch HVCs linked to a customer.
  Stream<List<CustomerHvcLink>> watchCustomerHvcs(String customerId);

  /// Get HVCs linked to a customer.
  Future<List<CustomerHvcLink>> getCustomerHvcs(String customerId);

  /// Link a customer to an HVC.
  Future<Either<Failure, CustomerHvcLink>> linkCustomerToHvc(
      CustomerHvcLinkDto dto);

  /// Unlink a customer from an HVC.
  Future<Either<Failure, void>> unlinkCustomerFromHvc(String linkId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync HVCs from remote.
  Future<Either<Failure, int>> syncFromRemote({DateTime? since});

  /// Sync customer-HVC links from remote.
  Future<Either<Failure, int>> syncLinksFromRemote({DateTime? since});
}
