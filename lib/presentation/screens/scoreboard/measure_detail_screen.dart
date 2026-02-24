import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/period_type_helpers.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../providers/scoreboard_providers.dart';
import '../../providers/auth_providers.dart';
import '../../../core/theme/app_colors.dart';

/// Screen showing detailed view of a specific measure with historical data.
class MeasureDetailScreen extends ConsumerStatefulWidget {
  final String measureId;

  const MeasureDetailScreen({
    super.key,
    required this.measureId,
  });

  @override
  ConsumerState<MeasureDetailScreen> createState() =>
      _MeasureDetailScreenState();
}

class _MeasureDetailScreenState extends ConsumerState<MeasureDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final periodsAsync = ref.watch(scoringPeriodsProvider);
    final measuresAsync = ref.watch(measureDefinitionsProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Measure Detail')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure Detail'),
      ),
      body: measuresAsync.when(
        data: (measures) {
          final measure =
              measures.where((m) => m.id == widget.measureId).firstOrNull;
          if (measure == null) {
            return const Center(child: Text('Measure not found'));
          }

          return periodsAsync.when(
            data: (periods) {
              if (periods.isEmpty) {
                return const Center(
                  child: Text('No scoring periods available'),
                );
              }

              return _buildContent(context, currentUser, measure, periods);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Error loading periods: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading measure: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic user,
    MeasureDefinition measure,
    List<ScoringPeriod> allPeriods,
  ) {
    final theme = Theme.of(context);

    // Sort periods by date (newest first for UI, oldest first for chart)
    final sortedPeriods = List<ScoringPeriod>.from(allPeriods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(scoringPeriodsProvider);
        ref.invalidate(measureDefinitionsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Measure info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: measure.measureType == 'LEAD'
                              ? AppColors.info.withValues(alpha: 0.1)
                              : AppColors.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          measure.measureType,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: measure.measureType == 'LEAD'
                                ? AppColors.info
                                : AppColors.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          measure.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (measure.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      measure.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data Type: ${measure.dataType}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (measure.unit != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.straighten,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Unit: ${measure.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Historical trend chart
          _buildHistoricalChart(context, user.id as String, measure, sortedPeriods),
          const SizedBox(height: 24),

          // Historical scores list
          _buildHistoricalList(context, user.id as String, measure, sortedPeriods),
        ],
      ),
    );
  }

  Widget _buildHistoricalChart(
    BuildContext context,
    String userId,
    MeasureDefinition measure,
    List<ScoringPeriod> periods,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<_ScorePoint>>(
                future: _loadHistoricalScores(userId, measure.id, periods),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_chart_outlined,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No historical data available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return _buildChart(context, data, measure);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<_ScorePoint> data,
    MeasureDefinition measure,
  ) {
    final theme = Theme.of(context);

    // Reverse data so oldest is on left
    final chartData = data.reversed.toList();

    // Find min/max for Y axis
    final maxValue = chartData.fold<double>(
      0,
      (max, point) => point.actualValue > max ? point.actualValue : max,
    );
    final maxTarget = chartData.fold<double>(
      0,
      (max, point) => point.targetValue > max ? point.targetValue : max,
    );
    final yMax = (maxValue > maxTarget ? maxValue : maxTarget) * 1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yMax / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    chartData[index].periodName,
                    style: theme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yMax / 4,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: yMax,
        lineBarsData: [
          // Actual line
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.actualValue,
              );
            }).toList(),
            isCurved: true,
            color: measure.measureType == 'LEAD'
                ? AppColors.info
                : AppColors.tertiary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: measure.measureType == 'LEAD'
                      ? AppColors.info
                      : AppColors.tertiary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: (measure.measureType == 'LEAD'
                      ? AppColors.info
                      : AppColors.tertiary)
                  .withValues(alpha: 0.1),
            ),
          ),
          // Target line
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.targetValue,
              );
            }).toList(),
            isCurved: false,
            color: theme.colorScheme.outline,
            barWidth: 2,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.colorScheme.inverseSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final point = chartData[spot.x.toInt()];
                final isActual = spot.barIndex == 0;
                return LineTooltipItem(
                  isActual
                      ? 'Actual: ${point.actualValue.toStringAsFixed(1)}${measure.unit ?? ''}'
                      : 'Target: ${point.targetValue.toStringAsFixed(1)}${measure.unit ?? ''}',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalList(
    BuildContext context,
    String userId,
    MeasureDefinition measure,
    List<ScoringPeriod> periods,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historical Scores',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<_ScorePoint>>(
              future: _loadHistoricalScores(userId, measure.id, periods),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No historical scores available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                return Column(
                  children: data.asMap().entries.map((entry) {
                    final point = entry.value;
                    final isLast = entry.key == data.length - 1;
                    final percentage = point.targetValue > 0
                        ? (point.actualValue / point.targetValue * 100)
                        : 0.0;

                    return Column(
                      children: [
                        _buildScoreListItem(
                          context,
                          point,
                          percentage,
                          measure,
                        ),
                        if (!isLast)
                          Divider(
                            height: 24,
                            color: theme.colorScheme.outlineVariant,
                          ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreListItem(
    BuildContext context,
    _ScorePoint point,
    double percentage,
    MeasureDefinition measure,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Row(
      children: [
        // Period info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      point.periodName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: periodTypeColor(point.periodType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      formatPeriodType(point.periodType),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: periodTypeColor(point.periodType),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${dateFormat.format(point.startDate)} - ${dateFormat.format(point.endDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (point.isCurrent) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Current',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Score info
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${point.actualValue.toStringAsFixed(1)}${measure.unit ?? ''}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(percentage),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Target: ${point.targetValue.toStringAsFixed(1)}${measure.unit ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getScoreColor(percentage),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<_ScorePoint>> _loadHistoricalScores(
    String userId,
    String measureId,
    List<ScoringPeriod> periods,
  ) async {
    final scorePoints = <_ScorePoint>[];

    for (final period in periods) {
      final scores = await ref.read(
        userScoresProvider(userId, period.id).future,
      );

      final score = scores.where((s) => s.measureId == measureId).firstOrNull;

      if (score != null) {
        scorePoints.add(_ScorePoint(
          periodId: period.id,
          periodName: period.name,
          periodType: period.periodType,
          startDate: period.startDate,
          endDate: period.endDate,
          isCurrent: period.isCurrent,
          actualValue: score.actualValue,
          targetValue: score.targetValue,
        ));
      }
    }

    return scorePoints;
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 100) return AppColors.success;
    if (percentage >= 75) return AppColors.successLight;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

/// Data point for score history.
class _ScorePoint {
  final String periodId;
  final String periodName;
  final String periodType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final double actualValue;
  final double targetValue;

  _ScorePoint({
    required this.periodId,
    required this.periodName,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.actualValue,
    required this.targetValue,
  });
}
