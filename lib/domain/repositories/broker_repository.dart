import '../../core/errors/result.dart';
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

  /// Watch brokers with pagination support (reactive stream).
  /// Returns up to [limit] brokers, optionally filtered by [searchQuery].
  Stream<List<Broker>> watchBrokersPaginated({
    required int limit,
    String? searchQuery,
  });

  /// Get total count of brokers, optionally filtered by [searchQuery].
  /// Used for pagination "hasMore" calculation.
  Future<int> getBrokerCount({String? searchQuery});

  /// Watch a single broker by ID (reactive stream).
  Stream<Broker?> watchBrokerById(String id);

  /// Get all brokers.
  Future<List<Broker>> getAllBrokers();

  /// Get a single broker by ID.
  Future<Broker?> getBrokerById(String id);

  /// Create a new broker (Admin only).
  Future<Result<Broker>> createBroker(BrokerCreateDto dto);

  /// Update an existing broker (Admin only).
  Future<Result<Broker>> updateBroker(String id, BrokerUpdateDto dto);

  /// Delete a broker (Admin only, soft delete).
  Future<Result<void>> deleteBroker(String id);

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

  /// Watch pipeline count for a broker (reactive stream).
  Stream<int> watchBrokerPipelineCount(String brokerId);

  // ==========================================
  // Sync Operations
  // ==========================================

  /// Sync brokers from remote.
  Future<Result<int>> syncFromRemote({DateTime? since});
}
