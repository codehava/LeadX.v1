import 'package:flutter/material.dart';

import '../../domain/entities/scoring_entities.dart';

/// Format period type enum string to Indonesian display label.
String formatPeriodType(String periodType) {
  switch (periodType) {
    case 'WEEKLY':
      return 'Mingguan';
    case 'MONTHLY':
      return 'Bulanan';
    case 'QUARTERLY':
      return 'Kuartalan';
    case 'YEARLY':
      return 'Tahunan';
    default:
      return periodType;
  }
}

/// Get color for a period type.
Color periodTypeColor(String periodType) {
  switch (periodType) {
    case 'WEEKLY':
      return Colors.blue;
    case 'MONTHLY':
      return Colors.green;
    case 'QUARTERLY':
      return Colors.orange;
    case 'YEARLY':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

/// Get sort priority for period types (lower = shorter granularity = first).
int periodTypePriority(String periodType) {
  switch (periodType) {
    case 'WEEKLY':
      return 1;
    case 'MONTHLY':
      return 2;
    case 'QUARTERLY':
      return 3;
    case 'YEARLY':
      return 4;
    default:
      return 99;
  }
}

/// Format a summary string of all running current periods.
///
/// Returns e.g. "Minggu 8, Februari, Q1 2026" sorted by priority (weekly first).
/// Returns empty string if [currentPeriods] is empty.
String formatRunningPeriodsSummary(List<ScoringPeriod> currentPeriods) {
  if (currentPeriods.isEmpty) return '';
  final sorted = [...currentPeriods]
    ..sort((a, b) =>
        periodTypePriority(a.periodType).compareTo(periodTypePriority(b.periodType)));
  return sorted.map((p) => p.name).join(', ');
}
