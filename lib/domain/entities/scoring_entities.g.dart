// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeasureDefinitionImpl _$$MeasureDefinitionImplFromJson(
  Map<String, dynamic> json,
) => _$MeasureDefinitionImpl(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  measureType: json['measureType'] as String,
  dataType: json['dataType'] as String,
  unit: json['unit'] as String?,
  calculationFormula: json['calculationFormula'] as String?,
  sourceTable: json['sourceTable'] as String?,
  sourceCondition: json['sourceCondition'] as String?,
  weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
  defaultTarget: (json['defaultTarget'] as num?)?.toDouble() ?? 0,
  periodType: json['periodType'] as String?,
  templateType: json['templateType'] as String?,
  templateConfig: json['templateConfig'] as Map<String, dynamic>?,
  isActive: json['isActive'] as bool? ?? true,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$MeasureDefinitionImplToJson(
  _$MeasureDefinitionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'measureType': instance.measureType,
  'dataType': instance.dataType,
  'unit': instance.unit,
  'calculationFormula': instance.calculationFormula,
  'sourceTable': instance.sourceTable,
  'sourceCondition': instance.sourceCondition,
  'weight': instance.weight,
  'defaultTarget': instance.defaultTarget,
  'periodType': instance.periodType,
  'templateType': instance.templateType,
  'templateConfig': instance.templateConfig,
  'isActive': instance.isActive,
  'sortOrder': instance.sortOrder,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$ScoringPeriodImpl _$$ScoringPeriodImplFromJson(Map<String, dynamic> json) =>
    _$ScoringPeriodImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      periodType: json['periodType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScoringPeriodImplToJson(_$ScoringPeriodImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'periodType': instance.periodType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isCurrent': instance.isCurrent,
      'isLocked': instance.isLocked,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$UserTargetImpl _$$UserTargetImplFromJson(Map<String, dynamic> json) =>
    _$UserTargetImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      measureId: json['measureId'] as String,
      periodId: json['periodId'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      assignedBy: json['assignedBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      measureName: json['measureName'] as String?,
      measureType: json['measureType'] as String?,
      measureUnit: json['measureUnit'] as String?,
    );

Map<String, dynamic> _$$UserTargetImplToJson(_$UserTargetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'measureId': instance.measureId,
      'periodId': instance.periodId,
      'targetValue': instance.targetValue,
      'assignedBy': instance.assignedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'measureName': instance.measureName,
      'measureType': instance.measureType,
      'measureUnit': instance.measureUnit,
    };

_$UserScoreImpl _$$UserScoreImplFromJson(Map<String, dynamic> json) =>
    _$UserScoreImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      measureId: json['measureId'] as String,
      periodId: json['periodId'] as String,
      actualValue: (json['actualValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      measureName: json['measureName'] as String?,
      measureType: json['measureType'] as String?,
      measureUnit: json['measureUnit'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserScoreImplToJson(_$UserScoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'measureId': instance.measureId,
      'periodId': instance.periodId,
      'actualValue': instance.actualValue,
      'targetValue': instance.targetValue,
      'percentage': instance.percentage,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'measureName': instance.measureName,
      'measureType': instance.measureType,
      'measureUnit': instance.measureUnit,
      'sortOrder': instance.sortOrder,
    };

_$PeriodSummaryImpl _$$PeriodSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PeriodSummaryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      periodId: json['periodId'] as String,
      totalLeadScore: (json['totalLeadScore'] as num?)?.toDouble() ?? 0,
      totalLagScore: (json['totalLagScore'] as num?)?.toDouble() ?? 0,
      compositeScore: (json['compositeScore'] as num?)?.toDouble() ?? 0,
      bonusPoints: (json['bonusPoints'] as num?)?.toDouble() ?? 0,
      penaltyPoints: (json['penaltyPoints'] as num?)?.toDouble() ?? 0,
      rank: (json['rank'] as num?)?.toInt(),
      rankChange: (json['rankChange'] as num?)?.toInt(),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userName: json['userName'] as String?,
      periodName: json['periodName'] as String?,
    );

Map<String, dynamic> _$$PeriodSummaryImplToJson(_$PeriodSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'periodId': instance.periodId,
      'totalLeadScore': instance.totalLeadScore,
      'totalLagScore': instance.totalLagScore,
      'compositeScore': instance.compositeScore,
      'bonusPoints': instance.bonusPoints,
      'penaltyPoints': instance.penaltyPoints,
      'rank': instance.rank,
      'rankChange': instance.rankChange,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userName': instance.userName,
      'periodName': instance.periodName,
    };

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryImpl(
  id: json['id'] as String,
  rank: json['rank'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  score: (json['score'] as num).toDouble(),
  leadScore: (json['leadScore'] as num).toDouble(),
  lagScore: (json['lagScore'] as num).toDouble(),
  rankChange: (json['rankChange'] as num?)?.toInt(),
  branchName: json['branchName'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
  _$LeaderboardEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'rank': instance.rank,
  'userId': instance.userId,
  'userName': instance.userName,
  'score': instance.score,
  'leadScore': instance.leadScore,
  'lagScore': instance.lagScore,
  'rankChange': instance.rankChange,
  'branchName': instance.branchName,
  'profileImageUrl': instance.profileImageUrl,
};

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(
  Map<String, dynamic> json,
) => _$DashboardStatsImpl(
  todayActivitiesCompleted:
      (json['todayActivitiesCompleted'] as num?)?.toInt() ?? 0,
  todayActivitiesTotal: (json['todayActivitiesTotal'] as num?)?.toInt() ?? 0,
  activePipelinesCount: (json['activePipelinesCount'] as num?)?.toInt() ?? 0,
  totalPotentialPremium:
      (json['totalPotentialPremium'] as num?)?.toDouble() ?? 0,
  userScore: (json['userScore'] as num?)?.toDouble(),
  userRank: (json['userRank'] as num?)?.toInt(),
  totalTeamMembers: (json['totalTeamMembers'] as num?)?.toInt(),
  rankChange: (json['rankChange'] as num?)?.toInt(),
  weeklyVisits: (json['weeklyVisits'] as num?)?.toInt() ?? 0,
  weeklyVisitsTarget: (json['weeklyVisitsTarget'] as num?)?.toInt() ?? 0,
  weeklyPipelinesWon: (json['weeklyPipelinesWon'] as num?)?.toInt() ?? 0,
  weeklyPremiumWon: (json['weeklyPremiumWon'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$DashboardStatsImplToJson(
  _$DashboardStatsImpl instance,
) => <String, dynamic>{
  'todayActivitiesCompleted': instance.todayActivitiesCompleted,
  'todayActivitiesTotal': instance.todayActivitiesTotal,
  'activePipelinesCount': instance.activePipelinesCount,
  'totalPotentialPremium': instance.totalPotentialPremium,
  'userScore': instance.userScore,
  'userRank': instance.userRank,
  'totalTeamMembers': instance.totalTeamMembers,
  'rankChange': instance.rankChange,
  'weeklyVisits': instance.weeklyVisits,
  'weeklyVisitsTarget': instance.weeklyVisitsTarget,
  'weeklyPipelinesWon': instance.weeklyPipelinesWon,
  'weeklyPremiumWon': instance.weeklyPremiumWon,
};

_$TeamSummaryImpl _$$TeamSummaryImplFromJson(Map<String, dynamic> json) =>
    _$TeamSummaryImpl(
      id: json['id'] as String,
      periodId: json['periodId'] as String,
      branchId: json['branchId'] as String?,
      regionalOfficeId: json['regionalOfficeId'] as String?,
      branchName: json['branchName'] as String?,
      regionalOfficeName: json['regionalOfficeName'] as String?,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      averageLeadScore: (json['averageLeadScore'] as num?)?.toDouble() ?? 0,
      averageLagScore: (json['averageLagScore'] as num?)?.toDouble() ?? 0,
      teamRank: (json['teamRank'] as num?)?.toInt(),
      totalTeams: (json['totalTeams'] as num?)?.toInt(),
      teamMembersCount: (json['teamMembersCount'] as num?)?.toInt() ?? 0,
      scoreChange: (json['scoreChange'] as num?)?.toDouble(),
      rankChange: (json['rankChange'] as num?)?.toInt(),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$$TeamSummaryImplToJson(_$TeamSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'periodId': instance.periodId,
      'branchId': instance.branchId,
      'regionalOfficeId': instance.regionalOfficeId,
      'branchName': instance.branchName,
      'regionalOfficeName': instance.regionalOfficeName,
      'averageScore': instance.averageScore,
      'averageLeadScore': instance.averageLeadScore,
      'averageLagScore': instance.averageLagScore,
      'teamRank': instance.teamRank,
      'totalTeams': instance.totalTeams,
      'teamMembersCount': instance.teamMembersCount,
      'scoreChange': instance.scoreChange,
      'rankChange': instance.rankChange,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };
