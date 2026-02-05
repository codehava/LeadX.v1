import '../entities/scoring_entities.dart';

/// Repository interface for admin 4DX management (measures and periods).
/// Admin-only operations that modify scoring configuration.
abstract class Admin4DXRepository {
  // ============================================
  // MEASURE MANAGEMENT
  // ============================================

  /// Get all measure definitions (including inactive for admin).
  Future<List<MeasureDefinition>> getAllMeasures();

  /// Get measure definition by ID.
  Future<MeasureDefinition?> getMeasureById(String id);

  /// Create a new measure definition.
  Future<MeasureDefinition> createMeasure({
    required String code,
    required String name,
    String? description,
    required String measureType,
    required String dataType,
    String? unit,
    String? calculationFormula,
    String? sourceTable,
    String? sourceCondition,
    required double weight,
    required double defaultTarget,
    required String periodType,
    String? templateType,
    Map<String, dynamic>? templateConfig,
    int sortOrder = 0,
  });

  /// Update an existing measure definition.
  Future<MeasureDefinition> updateMeasure(
    String id, {
    String? name,
    String? description,
    double? weight,
    double? defaultTarget,
    String? periodType,
    bool? isActive,
    int? sortOrder,
  });

  /// Soft delete a measure definition.
  Future<void> deleteMeasure(String id);

  // ============================================
  // PERIOD MANAGEMENT
  // ============================================

  /// Get all scoring periods.
  Future<List<ScoringPeriod>> getAllPeriods();

  /// Get scoring period by ID.
  Future<ScoringPeriod?> getPeriodById(String id);

  /// Create a new scoring period.
  Future<ScoringPeriod> createPeriod({
    required String name,
    required String periodType,
    required DateTime startDate,
    required DateTime endDate,
    bool isCurrent = false,
  });

  /// Update an existing scoring period.
  Future<ScoringPeriod> updatePeriod(
    String id, {
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    bool? isActive,
  });

  /// Delete a scoring period.
  Future<void> deletePeriod(String id);

  /// Lock a scoring period (prevents further modifications).
  Future<ScoringPeriod> lockPeriod(String id);

  /// Set a period as the current active period.
  Future<void> setCurrentPeriod(String id);

  /// Generate multiple periods automatically.
  Future<List<ScoringPeriod>> generatePeriods({
    required String periodType,
    required DateTime startDate,
    required int count,
  });
}
