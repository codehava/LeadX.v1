import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../../domain/entities/user.dart';
import '../../providers/admin/admin_4dx_providers.dart';
import '../../providers/scoreboard_providers.dart';
import '../../providers/team_target_providers.dart';
import '../../widgets/scoreboard/period_selector.dart';

/// Team Target List Screen.
///
/// Displays subordinates with their target assignment status for a selected period.
/// Available to BH, BM, and ROH roles.
class TeamTargetListScreen extends ConsumerStatefulWidget {
  const TeamTargetListScreen({super.key});

  @override
  ConsumerState<TeamTargetListScreen> createState() =>
      _TeamTargetListScreenState();
}

class _TeamTargetListScreenState extends ConsumerState<TeamTargetListScreen> {
  /// null = "Periode Aktif" (aggregate view across all current periods).
  ScoringPeriod? _selectedPeriod;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final periodsAsync = ref.watch(allPeriodsProvider);
    final subordinatesAsync = ref.watch(mySubordinatesProvider);
    final currentPeriodsAsync = ref.watch(allCurrentPeriodsProvider);
    final currentPeriods = currentPeriodsAsync.valueOrNull ?? [];
    final measuresAsync = ref.watch(allMeasuresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tim Target'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Period Selector & Search
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                // Period selector
                periodsAsync.when(
                  data: (periods) {
                    final editablePeriods =
                        periods.where((p) => p.isActive).toList();
                    if (editablePeriods.isEmpty) {
                      return const Text('Tidak ada periode tersedia');
                    }

                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Periode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: EdgeInsets.zero,
                      ),
                      child: PeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        allPeriods: editablePeriods,
                        currentPeriods: currentPeriods,
                        onChanged: (period) {
                          setState(() => _selectedPeriod = period);
                        },
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text('Gagal memuat periode'),
                ),
                const SizedBox(height: 12),

                // Locked period warning (only for specific selected period)
                if (_selectedPeriod != null && _selectedPeriod!.isLocked)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Periode ini terkunci. Target hanya bisa dilihat, tidak bisa diubah.',
                            style: TextStyle(
                                color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari bawahan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),

          // Cascade summary card — for specific period only
          if (_selectedPeriod != null)
            _CascadeSummaryCard(periodId: _selectedPeriod!.id),

          // Subordinate List
          Expanded(
            child: _buildSubordinateList(
                subordinatesAsync, measuresAsync, theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSubordinateList(
    AsyncValue<List<User>> subordinatesAsync,
    AsyncValue<List<MeasureDefinition>> measuresAsync,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final currentPeriodsAsync = ref.watch(allCurrentPeriodsProvider);
    final currentPeriodAsync = ref.watch(currentPeriodProvider);

    return subordinatesAsync.when(
      data: (subordinates) => currentPeriodsAsync.when(
        data: (currentPeriods) => measuresAsync.when(
          data: (measures) {
            // Count active measures as fallback denominator
            final activeMeasureCount =
                measures.where((m) => m.isActive).length;

            // Determine which period IDs to query targets for
            Set<String> periodIdsToQuery;
            if (_selectedPeriod == null) {
              // "Periode Aktif" → all current period IDs
              periodIdsToQuery = currentPeriods.map((p) => p.id).toSet();
            } else {
              // Specific period
              periodIdsToQuery = {_selectedPeriod!.id};
            }

            // Watch targets across the relevant periods
            final allTargets = <UserTarget>[];
            final allManagerTargets = <UserTarget>[];
            var anyLoading = false;

            for (final pId in periodIdsToQuery) {
              final targetsAsync = ref.watch(targetsForPeriodProvider(pId));
              targetsAsync.when(
                data: (targets) => allTargets.addAll(targets),
                loading: () => anyLoading = true,
                error: (e, _) {
                  AppLogger.instance.warning(
                      'team_targets | Failed to load targets for period $pId: $e');
                },
              );

              final managerAsync =
                  ref.watch(managerOwnTargetsProvider(pId));
              managerAsync.when(
                data: (targets) => allManagerTargets.addAll(targets),
                loading: () => anyLoading = true,
                error: (e, _) {
                  AppLogger.instance.warning(
                      'team_targets | Failed to load manager targets for period $pId: $e');
                },
              );
            }

            // Count unique measures the manager has been assigned
            final managerMeasureCount =
                allManagerTargets.map((t) => t.measureId).toSet().length;

            // Use manager's measure count when available, fallback to all active measures
            final effectiveTotalMeasures = managerMeasureCount > 0
                ? managerMeasureCount
                : activeMeasureCount;

            if (anyLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter by search
            final filtered = subordinates.where((u) {
              if (_searchQuery.isNotEmpty) {
                return u.name.toLowerCase().contains(_searchQuery);
              }
              return true;
            }).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada bawahan yang cocok'
                          : 'Tidak ada bawahan langsung',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            // For navigation: resolve the period to pass to the form
            final periodForNav = _selectedPeriod ?? currentPeriodAsync.valueOrNull;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(mySubordinatesProvider);
                ref.invalidate(allCurrentPeriodsProvider);
                ref.invalidate(allMeasuresProvider);
                for (final pId in periodIdsToQuery) {
                  ref.invalidate(targetsForPeriodProvider(pId));
                  ref.invalidate(managerOwnTargetsProvider(pId));
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  // Count unique measures with targets across relevant periods
                  final userMeasureIds = allTargets
                      .where((t) => t.userId == user.id)
                      .map((t) => t.measureId)
                      .toSet();

                  return _SubordinateTargetCard(
                    user: user,
                    assignedCount: userMeasureIds.length,
                    totalMeasures: effectiveTotalMeasures,
                    isLocked: _selectedPeriod?.isLocked ?? false,
                    onTap: () {
                      if (periodForNav == null) return;
                      context.push(
                        RoutePaths.teamTargetForm
                            .replaceAll(':userId', user.id),
                        extra: periodForNav,
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Gagal memuat ukuran: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal memuat periode: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Gagal memuat bawahan: $error')),
    );
  }
}

/// Summary card showing manager's own target vs sum assigned to subordinates.
class _CascadeSummaryCard extends ConsumerWidget {
  final String periodId;

  const _CascadeSummaryCard({required this.periodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final managerTargetsAsync = ref.watch(managerOwnTargetsProvider(periodId));
    final subordinatesAsync = ref.watch(mySubordinatesProvider);
    final allTargetsAsync = ref.watch(targetsForPeriodProvider(periodId));

    return managerTargetsAsync.when(
      data: (managerTargets) {
        if (managerTargets.isEmpty) return const SizedBox.shrink();

        return subordinatesAsync.when(
          data: (subordinates) => allTargetsAsync.when(
            data: (allTargets) {
              final subIds = subordinates.map((s) => s.id).toSet();
              final subTargets =
                  allTargets.where((t) => subIds.contains(t.userId)).toList();

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_tree,
                            size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Ringkasan Cascade',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...managerTargets.map((mt) {
                      // Sum of subordinate targets for this measure
                      final subSum = subTargets
                          .where((t) => t.measureId == mt.measureId)
                          .fold<double>(0, (sum, t) => sum + t.targetValue);
                      final overAllocated = subSum > mt.targetValue;
                      final measureName =
                          mt.measureName ?? mt.measureId.substring(0, 8);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                measureName,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Anda: ${_fmt(mt.targetValue)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Tim: ${_fmt(subSum)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: overAllocated
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _fmt(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

/// Card for displaying subordinate target assignment status.
class _SubordinateTargetCard extends StatelessWidget {
  final User user;
  final int assignedCount;
  final int totalMeasures;
  final bool isLocked;
  final VoidCallback onTap;

  const _SubordinateTargetCard({
    required this.user,
    required this.assignedCount,
    required this.totalMeasures,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isComplete = assignedCount >= totalMeasures && totalMeasures > 0;
    final hasPartial = assignedCount > 0 && !isComplete;

    return Card(
      elevation: 0,
      color: isComplete
          ? Colors.green.withValues(alpha: 0.05)
          : hasPartial
              ? Colors.orange.withValues(alpha: 0.05)
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor:
                    _getRoleColor(user.role).withValues(alpha: 0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getRoleColor(user.role).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Target count badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.withValues(alpha: 0.1)
                          : hasPartial
                              ? Colors.orange.withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$assignedCount/$totalMeasures',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isComplete
                            ? Colors.green
                            : hasPartial
                                ? Colors.orange
                                : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? 'Lengkap'
                        : hasPartial
                            ? 'Sebagian'
                            : 'Belum ada',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isComplete
                          ? Colors.green
                          : hasPartial
                              ? Colors.orange
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
      case UserRole.admin:
        return Colors.purple;
      case UserRole.roh:
        return Colors.teal;
      case UserRole.bm:
        return Colors.blue;
      case UserRole.bh:
        return Colors.orange;
      case UserRole.rm:
        return Colors.green;
    }
  }
}
