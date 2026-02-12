import '../../domain/entities/scoring_entities.dart';
import '../../domain/repositories/admin_4dx_repository.dart';
import '../datasources/remote/scoreboard_remote_data_source.dart';

/// Implementation of Admin4DXRepository.
/// Handles admin-only operations for measures and periods (web-only, no offline support).
class Admin4DXRepositoryImpl implements Admin4DXRepository {
  final ScoreboardRemoteDataSource _remoteDataSource;

  Admin4DXRepositoryImpl(this._remoteDataSource);

  // ============================================
  // MEASURE MANAGEMENT
  // ============================================

  @override
  Future<List<MeasureDefinition>> getAllMeasures() async {
    return _remoteDataSource.fetchAllMeasureDefinitions();
  }

  @override
  Future<MeasureDefinition?> getMeasureById(String id) async {
    final measures = await _remoteDataSource.fetchMeasureDefinitions();
    try {
      return measures.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
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
  }) async {
    final data = {
      'code': code,
      'name': name,
      'description': description,
      'measure_type': measureType,
      'data_type': dataType,
      'unit': unit,
      'calculation_formula': calculationFormula,
      'source_table': sourceTable,
      'source_condition': sourceCondition,
      'weight': weight,
      'default_target': defaultTarget,
      'period_type': periodType,
      'template_type': templateType,
      'template_config': templateConfig,
      'sort_order': sortOrder,
      'is_active': true,
    };

    return _remoteDataSource.createMeasureDefinition(data);
  }

  @override
  Future<MeasureDefinition> updateMeasure(
    String id, {
    String? name,
    String? description,
    double? weight,
    double? defaultTarget,
    String? periodType,
    bool? isActive,
    int? sortOrder,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (weight != null) data['weight'] = weight;
    if (defaultTarget != null) data['default_target'] = defaultTarget;
    if (periodType != null) data['period_type'] = periodType;
    if (isActive != null) data['is_active'] = isActive;
    if (sortOrder != null) data['sort_order'] = sortOrder;

    return _remoteDataSource.updateMeasureDefinition(id, data);
  }

  @override
  Future<void> deleteMeasure(String id) async {
    await _remoteDataSource.deleteMeasureDefinition(id);
  }

  // ============================================
  // PERIOD MANAGEMENT
  // ============================================

  @override
  Future<List<ScoringPeriod>> getAllPeriods() async {
    return _remoteDataSource.fetchScoringPeriods();
  }

  @override
  Future<ScoringPeriod?> getPeriodById(String id) async {
    final periods = await _remoteDataSource.fetchScoringPeriods();
    try {
      return periods.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ScoringPeriod> createPeriod({
    required String name,
    required String periodType,
    required DateTime startDate,
    required DateTime endDate,
    bool isCurrent = false,
  }) async {
    final data = {
      'name': name,
      'period_type': periodType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_current': isCurrent,
      'is_locked': false,
      'is_active': true,
    };

    return _remoteDataSource.createScoringPeriod(data);
  }

  @override
  Future<ScoringPeriod> updatePeriod(
    String id, {
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    bool? isActive,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (startDate != null) data['start_date'] = startDate.toIso8601String();
    if (endDate != null) data['end_date'] = endDate.toIso8601String();
    if (isCurrent != null) data['is_current'] = isCurrent;
    if (isActive != null) data['is_active'] = isActive;

    return _remoteDataSource.updateScoringPeriod(id, data);
  }

  @override
  Future<void> deletePeriod(String id) async {
    await _remoteDataSource.deleteScoringPeriod(id);
  }

  @override
  Future<ScoringPeriod> lockPeriod(String id) async {
    return _remoteDataSource.lockPeriod(id);
  }

  @override
  Future<void> setCurrentPeriod(String id) async {
    await _remoteDataSource.setCurrentPeriod(id);
  }

  @override
  Future<List<ScoringPeriod>> generatePeriods({
    required String periodType,
    required DateTime startDate,
    required int count,
  }) async {
    final periods = <ScoringPeriod>[];
    var currentStart = startDate;

    for (var i = 0; i < count; i++) {
      final (name, endDate) = _calculatePeriodEnd(periodType, currentStart, i + 1);

      final period = await createPeriod(
        name: name,
        periodType: periodType,
        startDate: currentStart,
        endDate: endDate,
        isCurrent: false,
      );

      periods.add(period);
      currentStart = endDate.add(const Duration(days: 1));
    }

    return periods;
  }

  // ============================================
  // TARGET MANAGEMENT
  // ============================================

  @override
  Future<List<UserTarget>> getTargetsForPeriod(String periodId) async {
    return _remoteDataSource.fetchTargetsForPeriod(periodId);
  }

  @override
  Future<List<UserTarget>> getUserTargetsForPeriod(
      String userId, String periodId) async {
    return _remoteDataSource.fetchUserTargets(userId, periodId);
  }

  @override
  Future<UserTarget> upsertUserTarget({
    required String userId,
    required String measureId,
    required String periodId,
    required double targetValue,
    required String assignedBy,
  }) async {
    return _remoteDataSource.upsertUserTarget(
      userId: userId,
      measureId: measureId,
      periodId: periodId,
      targetValue: targetValue,
      assignedBy: assignedBy,
    );
  }

  @override
  Future<void> bulkAssignTargets({
    required String periodId,
    required String assignedBy,
    required List<String> userIds,
    required Map<String, double> measureTargets,
  }) async {
    // Build cartesian product: each user × each measure target
    final targets = <Map<String, dynamic>>[];
    for (final userId in userIds) {
      for (final entry in measureTargets.entries) {
        targets.add({
          'userId': userId,
          'measureId': entry.key,
          'targetValue': entry.value,
        });
      }
    }

    await _remoteDataSource.bulkUpsertUserTargets(
      periodId: periodId,
      assignedBy: assignedBy,
      targets: targets,
    );
  }

  @override
  Future<void> applyDefaultTargets({
    required String userId,
    required String periodId,
    required String assignedBy,
  }) async {
    // Fetch active measures and use their default targets
    final measures = await _remoteDataSource.fetchMeasureDefinitions();
    final targets = measures
        .where((m) => m.defaultTarget > 0)
        .map((m) => {
              'userId': userId,
              'measureId': m.id,
              'targetValue': m.defaultTarget,
            })
        .toList();

    if (targets.isNotEmpty) {
      await _remoteDataSource.bulkUpsertUserTargets(
        periodId: periodId,
        assignedBy: assignedBy,
        targets: targets,
      );
    }
  }

  @override
  Future<void> deleteUserTarget(String targetId) async {
    await _remoteDataSource.deleteUserTarget(targetId);
  }

  // Helper to calculate period end date and name
  (String name, DateTime endDate) _calculatePeriodEnd(
    String periodType,
    DateTime startDate,
    int sequence,
  ) {
    switch (periodType) {
      case 'WEEKLY':
        final endDate = startDate.add(const Duration(days: 6));
        return (
          'Week $sequence, ${_monthName(startDate.month)} ${startDate.year}',
          endDate
        );
      case 'MONTHLY':
        final endDate = DateTime(
          startDate.year,
          startDate.month + 1,
          0,
        );
        return (
          '${_monthName(startDate.month)} ${startDate.year}',
          endDate
        );
      case 'QUARTERLY':
        final quarterEndMonth = ((startDate.month - 1) ~/ 3 + 1) * 3;
        // Handle year rollover for Q4 (Oct-Dec) where quarterEndMonth = 12
        final endDate = quarterEndMonth == 12
            ? DateTime(startDate.year + 1, 1, 0) // Last day of Dec (year+1, month 1, day 0)
            : DateTime(startDate.year, quarterEndMonth + 1, 0);
        return (
          'Q${(startDate.month - 1) ~/ 3 + 1} ${startDate.year}',
          endDate
        );
      case 'YEARLY':
        final endDate = DateTime(startDate.year, 12, 31);
        return ('Year ${startDate.year}', endDate);
      default:
        throw ArgumentError('Unknown period type: $periodType');
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
