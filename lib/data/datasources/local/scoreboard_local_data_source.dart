import 'package:drift/drift.dart';

import '../../database/app_database.dart' as db;
import '../../../domain/entities/scoring_entities.dart';

/// Local data source for 4DX scoring data.
class ScoreboardLocalDataSource {
  final db.AppDatabase _db;

  ScoreboardLocalDataSource(this._db);

  // ============================================
  // MEASURE DEFINITIONS
  // ============================================

  /// Get all active measure definitions.
  Future<List<MeasureDefinition>> getMeasureDefinitions() async {
    final query = _db.select(_db.measureDefinitions)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    final results = await query.get();
    return results.map(_mapToMeasureDefinition).toList();
  }

  /// Get measure definitions by type (LEAD or LAG).
  Future<List<MeasureDefinition>> getMeasureDefinitionsByType(
      String measureType) async {
    final query = _db.select(_db.measureDefinitions)
      ..where((t) =>
          t.isActive.equals(true) & t.measureType.equals(measureType))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    final results = await query.get();
    return results.map(_mapToMeasureDefinition).toList();
  }

  /// Insert or update measure definitions.
  Future<void> upsertMeasureDefinitions(
      List<MeasureDefinition> definitions) async {
    await _db.batch((batch) {
      for (final def in definitions) {
        batch.insert(
          _db.measureDefinitions,
          db.MeasureDefinitionsCompanion.insert(
            id: def.id,
            code: def.code,
            name: def.name,
            description: Value(def.description),
            measureType: def.measureType,
            dataType: def.dataType,
            unit: Value(def.unit),
            calculationFormula: Value(def.calculationFormula),
            sourceTable: Value(def.sourceTable),
            sourceCondition: Value(def.sourceCondition),
            isActive: Value(def.isActive),
            sortOrder: Value(def.sortOrder),
            createdAt: def.createdAt ?? DateTime.now(),
            updatedAt: def.updatedAt ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // SCORING PERIODS
  // ============================================

  /// Get all active scoring periods.
  Future<List<ScoringPeriod>> getScoringPeriods() async {
    final query = _db.select(_db.scoringPeriods)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.startDate)]);

    final results = await query.get();
    return results.map(_mapToScoringPeriod).toList();
  }

  /// Get the current scoring period.
  Future<ScoringPeriod?> getCurrentPeriod() async {
    final query = _db.select(_db.scoringPeriods)
      ..where((t) => t.isCurrent.equals(true) & t.isActive.equals(true))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result != null ? _mapToScoringPeriod(result) : null;
  }

  /// Get scoring period by ID.
  Future<ScoringPeriod?> getScoringPeriodById(String periodId) async {
    final query = _db.select(_db.scoringPeriods)
      ..where((t) => t.id.equals(periodId));

    final result = await query.getSingleOrNull();
    return result != null ? _mapToScoringPeriod(result) : null;
  }

  /// Insert or update scoring periods.
  Future<void> upsertScoringPeriods(List<ScoringPeriod> periods) async {
    await _db.batch((batch) {
      for (final period in periods) {
        batch.insert(
          _db.scoringPeriods,
          db.ScoringPeriodsCompanion.insert(
            id: period.id,
            name: period.name,
            periodType: period.periodType,
            startDate: period.startDate,
            endDate: period.endDate,
            isCurrent: Value(period.isCurrent),
            isActive: Value(period.isActive),
            createdAt: period.createdAt ?? DateTime.now(),
            updatedAt: period.updatedAt ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // USER TARGETS
  // ============================================

  /// Get user targets for a specific period.
  Future<List<UserTarget>> getUserTargets(
      String userId, String periodId) async {
    final query = _db.select(_db.userTargets).join([
      leftOuterJoin(
        _db.measureDefinitions,
        _db.measureDefinitions.id.equalsExp(_db.userTargets.measureId),
      ),
    ])
      ..where(_db.userTargets.userId.equals(userId) &
          _db.userTargets.periodId.equals(periodId))
      ..orderBy([OrderingTerm.asc(_db.measureDefinitions.sortOrder)]);

    final results = await query.get();
    return results.map((row) {
      final target = row.readTable(_db.userTargets);
      final measure = row.readTableOrNull(_db.measureDefinitions);
      return _mapToUserTarget(target, measure);
    }).toList();
  }

  /// Insert or update user targets.
  Future<void> upsertUserTargets(List<UserTarget> targets) async {
    await _db.batch((batch) {
      for (final target in targets) {
        batch.insert(
          _db.userTargets,
          db.UserTargetsCompanion.insert(
            id: target.id,
            userId: target.userId,
            measureId: target.measureId,
            periodId: target.periodId,
            targetValue: target.targetValue,
            assignedBy: target.assignedBy ?? '',
            createdAt: target.createdAt ?? DateTime.now(),
            updatedAt: target.updatedAt ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // USER SCORES
  // ============================================

  /// Get user scores for a specific period.
  Future<List<UserScore>> getUserScores(String userId, String periodId) async {
    final query = _db.select(_db.userScores).join([
      leftOuterJoin(
        _db.measureDefinitions,
        _db.measureDefinitions.id.equalsExp(_db.userScores.measureId),
      ),
    ])
      ..where(_db.userScores.userId.equals(userId) &
          _db.userScores.periodId.equals(periodId))
      ..orderBy([OrderingTerm.asc(_db.measureDefinitions.sortOrder)]);

    final results = await query.get();
    return results.map((row) {
      final score = row.readTable(_db.userScores);
      final measure = row.readTableOrNull(_db.measureDefinitions);
      return _mapToUserScore(score, measure);
    }).toList();
  }

  /// Get user scores by measure type (LEAD or LAG).
  Future<List<UserScore>> getUserScoresByType(
    String userId,
    String periodId,
    String measureType,
  ) async {
    final query = _db.select(_db.userScores).join([
      innerJoin(
        _db.measureDefinitions,
        _db.measureDefinitions.id.equalsExp(_db.userScores.measureId),
      ),
    ])
      ..where(_db.userScores.userId.equals(userId) &
          _db.userScores.periodId.equals(periodId) &
          _db.measureDefinitions.measureType.equals(measureType))
      ..orderBy([OrderingTerm.asc(_db.measureDefinitions.sortOrder)]);

    final results = await query.get();
    return results.map((row) {
      final score = row.readTable(_db.userScores);
      final measure = row.readTableOrNull(_db.measureDefinitions);
      return _mapToUserScore(score, measure);
    }).toList();
  }

  /// Insert or update user scores.
  Future<void> upsertUserScores(List<UserScore> scores) async {
    await _db.batch((batch) {
      for (final score in scores) {
        batch.insert(
          _db.userScores,
          db.UserScoresCompanion.insert(
            id: score.id,
            userId: score.userId,
            measureId: score.measureId,
            periodId: score.periodId,
            actualValue: score.actualValue,
            targetValue: score.targetValue,
            percentage: Value(score.percentage),
            calculatedAt: score.calculatedAt ?? DateTime.now(),
            createdAt: score.createdAt ?? DateTime.now(),
            updatedAt: score.updatedAt ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // PERIOD SUMMARY SCORES
  // ============================================

  /// Get user's period summary.
  Future<PeriodSummary?> getUserPeriodSummary(
      String userId, String periodId) async {
    final query = _db.select(_db.periodSummaryScores)
      ..where((t) => t.userId.equals(userId) & t.periodId.equals(periodId));

    final result = await query.getSingleOrNull();
    return result != null ? _mapToPeriodSummary(result, null, null) : null;
  }

  /// Get leaderboard for a period.
  Future<List<PeriodSummary>> getLeaderboard(String periodId,
      {int? limit}) async {
    var query = _db.select(_db.periodSummaryScores).join([
      leftOuterJoin(_db.users, _db.users.id.equalsExp(_db.periodSummaryScores.userId)),
      leftOuterJoin(_db.scoringPeriods,
          _db.scoringPeriods.id.equalsExp(_db.periodSummaryScores.periodId)),
    ])
      ..where(_db.periodSummaryScores.periodId.equals(periodId))
      ..orderBy([
        OrderingTerm.asc(_db.periodSummaryScores.rank),
        OrderingTerm.desc(_db.periodSummaryScores.compositeScore),
      ]);

    if (limit != null) {
      query = query..limit(limit);
    }

    final results = await query.get();
    return results.map((row) {
      final summary = row.readTable(_db.periodSummaryScores);
      final user = row.readTableOrNull(_db.users);
      final period = row.readTableOrNull(_db.scoringPeriods);
      return _mapToPeriodSummary(summary, user, period);
    }).toList();
  }

  /// Get user's rank in period.
  Future<int?> getUserRank(String userId, String periodId) async {
    final summary = await getUserPeriodSummary(userId, periodId);
    return summary?.rank;
  }

  /// Get total team members count for a period.
  Future<int> getTeamMembersCount(String periodId) async {
    final query = _db.selectOnly(_db.periodSummaryScores)
      ..addColumns([_db.periodSummaryScores.id.count()])
      ..where(_db.periodSummaryScores.periodId.equals(periodId));

    final result = await query.getSingle();
    return result.read(_db.periodSummaryScores.id.count()) ?? 0;
  }

  /// Insert or update period summaries.
  Future<void> upsertPeriodSummaries(List<PeriodSummary> summaries) async {
    await _db.batch((batch) {
      for (final summary in summaries) {
        batch.insert(
          _db.periodSummaryScores,
          db.PeriodSummaryScoresCompanion.insert(
            id: summary.id,
            userId: summary.userId,
            periodId: summary.periodId,
            totalLeadScore: Value(summary.totalLeadScore),
            totalLagScore: Value(summary.totalLagScore),
            compositeScore: Value(summary.compositeScore),
            rank: Value(summary.rank),
            rankChange: Value(summary.rankChange),
            calculatedAt: summary.calculatedAt ?? DateTime.now(),
            createdAt: summary.createdAt ?? DateTime.now(),
            updatedAt: summary.updatedAt ?? DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ============================================
  // MAPPERS
  // ============================================

  MeasureDefinition _mapToMeasureDefinition(db.MeasureDefinition data) {
    return MeasureDefinition(
      id: data.id,
      code: data.code,
      name: data.name,
      description: data.description,
      measureType: data.measureType,
      dataType: data.dataType,
      unit: data.unit,
      calculationFormula: data.calculationFormula,
      sourceTable: data.sourceTable,
      sourceCondition: data.sourceCondition,
      isActive: data.isActive,
      sortOrder: data.sortOrder,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  ScoringPeriod _mapToScoringPeriod(db.ScoringPeriod data) {
    return ScoringPeriod(
      id: data.id,
      name: data.name,
      periodType: data.periodType,
      startDate: data.startDate,
      endDate: data.endDate,
      isCurrent: data.isCurrent,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  UserTarget _mapToUserTarget(
    db.UserTarget data,
    db.MeasureDefinition? measure,
  ) {
    return UserTarget(
      id: data.id,
      userId: data.userId,
      measureId: data.measureId,
      periodId: data.periodId,
      targetValue: data.targetValue,
      assignedBy: data.assignedBy,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      measureName: measure?.name,
      measureType: measure?.measureType,
      measureUnit: measure?.unit,
    );
  }

  UserScore _mapToUserScore(
    db.UserScore data,
    db.MeasureDefinition? measure,
  ) {
    return UserScore(
      id: data.id,
      userId: data.userId,
      measureId: data.measureId,
      periodId: data.periodId,
      actualValue: data.actualValue,
      targetValue: data.targetValue,
      percentage: data.percentage,
      calculatedAt: data.calculatedAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      measureName: measure?.name,
      measureType: measure?.measureType,
      measureUnit: measure?.unit,
      sortOrder: measure?.sortOrder ?? 0,
    );
  }

  PeriodSummary _mapToPeriodSummary(
    db.PeriodSummaryScore data,
    db.User? user,
    db.ScoringPeriod? period,
  ) {
    return PeriodSummary(
      id: data.id,
      userId: data.userId,
      periodId: data.periodId,
      totalLeadScore: data.totalLeadScore,
      totalLagScore: data.totalLagScore,
      compositeScore: data.compositeScore,
      rank: data.rank,
      rankChange: data.rankChange,
      calculatedAt: data.calculatedAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      userName: user?.name,
      periodName: period?.name,
    );
  }
}
