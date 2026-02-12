import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
Admin4DXRepository admin4DXRepository(Ref ref) {
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
Future<List<MeasureDefinition>> allMeasures(Ref ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getAllMeasures();
}

/// Get measure definition by ID.
@riverpod
Future<MeasureDefinition?> measureById(Ref ref, String id) async {
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
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
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

      state = AsyncValue.data(measure);
      ref.invalidate(allMeasuresProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
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
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
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

      state = AsyncValue.data(measure);
      ref.invalidate(allMeasuresProvider);
      ref.invalidate(measureByIdProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }

  /// Delete a measure.
  Future<void> deleteMeasure(String id) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.deleteMeasure(id);

      state = const AsyncValue.data(null);
      ref.invalidate(allMeasuresProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }
}

// ============================================
// PERIODS
// ============================================

/// Get all scoring periods.
@riverpod
Future<List<ScoringPeriod>> allPeriods(Ref ref) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getAllPeriods();
}

/// Get period by ID.
@riverpod
Future<ScoringPeriod?> periodById(Ref ref, String id) async {
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
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final period = await repository.createPeriod(
        name: name,
        periodType: periodType,
        startDate: startDate,
        endDate: endDate,
        isCurrent: isCurrent,
      );

      state = AsyncValue.data(period);
      ref.invalidate(allPeriodsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
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
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
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

      state = AsyncValue.data(period);
      ref.invalidate(allPeriodsProvider);
      ref.invalidate(periodByIdProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }

  /// Delete a period.
  Future<void> deletePeriod(String id) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.deletePeriod(id);

      state = const AsyncValue.data(null);
      ref.invalidate(allPeriodsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }

  /// Lock a period.
  Future<void> lockPeriod(String id) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      final period = await repository.lockPeriod(id);

      state = AsyncValue.data(period);
      ref.invalidate(allPeriodsProvider);
      ref.invalidate(periodByIdProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }

  /// Set a period as current.
  Future<void> setCurrentPeriod(String id) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.setCurrentPeriod(id);

      state = const AsyncValue.data(null);
      ref.invalidate(allPeriodsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }

  /// Generate multiple periods automatically.
  Future<void> generatePeriods({
    required String periodType,
    required DateTime startDate,
    required int count,
  }) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.generatePeriods(
        periodType: periodType,
        startDate: startDate,
        count: count,
      );

      state = const AsyncValue.data(null);
      ref.invalidate(allPeriodsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }
}

// ============================================
// TARGETS
// ============================================

/// Get all targets for a specific period.
@riverpod
Future<List<UserTarget>> targetsForPeriod(Ref ref, String periodId) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getTargetsForPeriod(periodId);
}

/// Get targets for a specific user in a period.
@riverpod
Future<List<UserTarget>> adminUserTargets(
    Ref ref, String userId, String periodId) async {
  // ignore: argument_type_not_assignable
  final repository = ref.watch(admin4DXRepositoryProvider);
  // ignore: return_of_invalid_type
  return repository.getUserTargetsForPeriod(userId, periodId);
}

/// Target assignment notifier for admin operations.
@riverpod
class TargetAssignment extends _$TargetAssignment {
  @override
  FutureOr<void> build() => null;

  /// Save all targets for a specific user in a period.
  Future<bool> saveUserTargets({
    required String userId,
    required String periodId,
    required String assignedBy,
    required Map<String, double> measureTargets,
  }) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);

      await repository.bulkAssignTargets(
        periodId: periodId,
        assignedBy: assignedBy,
        userIds: [userId],
        measureTargets: measureTargets,
      );

      state = const AsyncValue.data(null);

      // Invalidate affected providers
      ref.invalidate(targetsForPeriodProvider(periodId));
      ref.invalidate(adminUserTargetsProvider(userId, periodId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }

    return !state.hasError;
  }

  /// Bulk assign targets to multiple users.
  Future<bool> bulkAssignTargets({
    required String periodId,
    required String assignedBy,
    required List<String> userIds,
    required Map<String, double> measureTargets,
  }) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.bulkAssignTargets(
        periodId: periodId,
        assignedBy: assignedBy,
        userIds: userIds,
        measureTargets: measureTargets,
      );

      state = const AsyncValue.data(null);

      // Invalidate affected providers
      ref.invalidate(targetsForPeriodProvider(periodId));
      for (final userId in userIds) {
        ref.invalidate(adminUserTargetsProvider(userId, periodId));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }

    return !state.hasError;
  }

  /// Apply default targets for a user.
  Future<bool> applyDefaults({
    required String userId,
    required String periodId,
    required String assignedBy,
  }) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.applyDefaultTargets(
        userId: userId,
        periodId: periodId,
        assignedBy: assignedBy,
      );

      state = const AsyncValue.data(null);

      // Invalidate affected providers
      ref.invalidate(targetsForPeriodProvider(periodId));
      ref.invalidate(adminUserTargetsProvider(userId, periodId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }

    return !state.hasError;
  }

  /// Delete a user target.
  Future<bool> deleteTarget({
    required String targetId,
    required String periodId,
    String? userId,
  }) async {
    final link = ref.keepAlive();
    state = const AsyncValue.loading();

    try {
      // ignore: argument_type_not_assignable
      final repository = ref.read(admin4DXRepositoryProvider);
      await repository.deleteUserTarget(targetId);

      state = const AsyncValue.data(null);

      // Invalidate affected providers
      ref.invalidate(targetsForPeriodProvider(periodId));
      if (userId != null) {
        ref.invalidate(adminUserTargetsProvider(userId, periodId));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }

    return !state.hasError;
  }
}
