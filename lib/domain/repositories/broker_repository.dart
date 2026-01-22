import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/dtos/broker_dtos.dart';
import '../entities/broker.dart';
import '../entities/key_person.dart';

/// Repository interface for Broker operations.
abstract class BrokerRepository {
  // ==========================================
  // Broker CRUD Operations
  // ==========================================

  /// Watch all brokers as a stream.
  Stream<List<Broker>> watchAllBrokers();

  /// Get all brokers.
  Future<List<Broker>> getAllBrokers();

  /// Get a single broker by ID.
  Future<Broker?> getBrokerById(String id);

  /// Create a new broker (Admin only).
  Future<Either<Failure, Broker>> createBroker(BrokerCreateDto dto);

  /// Update an existing broker (Admin only).
  Future<Either<Failure, Broker>> updateBroker(String id, BrokerUpdateDto dto);

  /// Delete a broker (Admin only, soft delete).
  Future<Either<Failure, void>> deleteBroker(String id);

  /// Search brokers by name or code.
  Future<List<Broker>> searchBrokers(String query);

  // ==========================================
  // Key Person Operations (PICs)
  // ==========================================

  /// Get key persons for a broker.
  Future<List<KeyPerson>> getBrokerKeyPersons(String brokerId);

  /// Watch key persons for a broker.
  Stream<List<KeyPerson>> watchBrokerKeyPersons(String brokerId);

  // ==========================================
  // Pipeline Operations
  // ==========================================

  /// Get pipeline count for a broker.
  Future<int> getBrokerPipelineCount(String brokerId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync brokers from remote.
  Future<Either<Failure, int>> syncFromRemote({DateTime? since});
}
