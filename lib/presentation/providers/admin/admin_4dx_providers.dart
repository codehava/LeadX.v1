import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/admin_4dx_repository_impl.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../../domain/repositories/admin_4dx_repository.dart';
import '../scoreboard_providers.dart';

part 'admin_4dx_providers.g.dart';

// ============================================
// REPOSITORY
// ============================================

@riverpod
Admin4DXRepository admin4DXRepository(ref) {
  // ignore: argument_type_not_assignable
  final remoteDataSource = ref.watch(scoreboardRemoteDataSourceProvider);
  // ignore: argument_type_not_assignable
  return Admin4DXRepositoryImpl(remoteDataSource);
}

// ============================================
// MEASURES
// ============================================

/// Get all measure definitions (including inactive for admin).
@riverpod
Future<List<MeasureDefinition>> allMeasures(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getAllMeasures();
}

/// Get measure definition by ID.
@riverpod
Future<MeasureDefinition?> measureById(ref, String id) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getMeasureById(id);
}

/// Measure creation/update notifier.
@riverpod
class MeasureForm extends _$MeasureForm {
  @override
  FutureOr<MeasureDefinition?> build() => null;

  /// Create a new measure.
  Future<void> createMeasure({
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
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final measure = await repository.createMeasure(
        code: code,
        name: name,
        description: description,
        measureType: measureType,
        dataType: dataType,
        unit: unit,
        calculationFormula: calculationFormula,
        sourceTable: sourceTable,
        sourceCondition: sourceCondition,
        weight: weight,
        defaultTarget: defaultTarget,
        periodType: periodType,
        templateType: templateType,
        templateConfig: templateConfig,
        sortOrder: sortOrder,
      );

      // Invalidate the measures list
      ref.invalidate(allMeasuresProvider);

      return measure;
    });
  }

  /// Update an existing measure.
  Future<void> updateMeasure(
    String id, {
    String? name,
    String? description,
    double? weight,
    double? defaultTarget,
    String? periodType,
    bool? isActive,
    int? sortOrder,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final measure = await repository.updateMeasure(
        id,
        name: name,
        description: description,
        weight: weight,
        defaultTarget: defaultTarget,
        periodType: periodType,
        isActive: isActive,
        sortOrder: sortOrder,
      );

      // Invalidate the measures list
      ref.invalidate(allMeasuresProvider);
      ref.invalidate(measureByIdProvider(id));

      return measure;
    });
  }

  /// Delete a measure.
  Future<void> deleteMeasure(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.deleteMeasure(id);

      // Invalidate the measures list
      ref.invalidate(allMeasuresProvider);

      return null;
    });
  }
}

// ============================================
// PERIODS
// ============================================

/// Get all scoring periods.
@riverpod
Future<List<ScoringPeriod>> allPeriods(ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getAllPeriods();
}

/// Get period by ID.
@riverpod
Future<ScoringPeriod?> periodById(ref, String id) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getPeriodById(id);
}

/// Period creation/update notifier.
@riverpod
class PeriodForm extends _$PeriodForm {
  @override
  FutureOr<ScoringPeriod?> build() => null;

  /// Create a new period.
  Future<void> createPeriod({
    required String name,
    required String periodType,
    required DateTime startDate,
    required DateTime endDate,
    bool isCurrent = false,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final period = await repository.createPeriod(
        name: name,
        periodType: periodType,
        startDate: startDate,
        endDate: endDate,
        isCurrent: isCurrent,
      );

      // Invalidate the periods list
      ref.invalidate(allPeriodsProvider);

      return period;
    });
  }

  /// Update an existing period.
  Future<void> updatePeriod(
    String id, {
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final period = await repository.updatePeriod(
        id,
        name: name,
        startDate: startDate,
        endDate: endDate,
        isCurrent: isCurrent,
        isActive: isActive,
      );

      // Invalidate the periods list
      ref.invalidate(allPeriodsProvider);
      ref.invalidate(periodByIdProvider(id));

      return period;
    });
  }

  /// Delete a period.
  Future<void> deletePeriod(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.deletePeriod(id);

      // Invalidate the periods list
      ref.invalidate(allPeriodsProvider);

      return null;
    });
  }

  /// Lock a period.
  Future<void> lockPeriod(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final period = await repository.lockPeriod(id);

      // Invalidate the periods list
      ref.invalidate(allPeriodsProvider);
      ref.invalidate(periodByIdProvider(id));

      return period;
    });
  }

  /// Set a period as current.
  Future<void> setCurrentPeriod(String id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.setCurrentPeriod(id);

      // Invalidate the periods list
      ref.invalidate(allPeriodsProvider);

      return null;
    });
  }

  /// Generate multiple periods automatically.
  Future<void> generatePeriods({
    required String periodType,
    required DateTime startDate,
    required int count,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.generatePeriods(
        periodType: periodType,
        startDate: startDate,
        count: count,
      );

      // Invalidate the periods list
      ref.invalidate(allPeriodsProvider);

      return null;
    });
  }
}
