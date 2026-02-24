import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/utils/period_type_helpers.dart';
import '../../../providers/admin/admin_4dx_providers.dart';
import '../../../widgets/admin/admin_menu_card.dart';

/// Admin 4DX Configuration Home Screen.
///
/// Provides access to:
/// - Measure Management (LEAD & LAG measures)
/// - Period Management (weekly, monthly, quarterly)
/// - Overview statistics
class Admin4DXHomeScreen extends ConsumerWidget {
  const Admin4DXHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fetch measures and periods for stats
    final measuresAsync = ref.watch(allMeasuresProvider);
    final periodsAsync = ref.watch(allPeriodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurasi 4DX'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Kelola Ukuran & Periode',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Konfigurasi measure LEAD/LAG dan periode penilaian',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  label: 'Total Measures',
                  value: measuresAsync.when(
                    data: (measures) => measures.length.toString(),
                    loading: () => '...',
                    error: (_, _) => 'Error',
                  ),
                  icon: Icons.speed,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  label: 'Total Periods',
                  value: periodsAsync.when(
                    data: (periods) => periods.length.toString(),
                    loading: () => '...',
                    error: (_, _) => 'Error',
                  ),
                  icon: Icons.calendar_month,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // LEAD vs LAG breakdown
          measuresAsync.when(
            data: (measures) {
              final leadCount = measures.where((m) => m.measureType == 'LEAD').length;
              final lagCount = measures.where((m) => m.measureType == 'LAG').length;
              return Row(
                children: [
                  Expanded(
                    child: _StatsCard(
                      label: 'LEAD (60%)',
                      value: leadCount.toString(),
                      icon: Icons.trending_up,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatsCard(
                      label: 'LAG (40%)',
                      value: lagCount.toString(),
                      icon: Icons.flag,
                      color: Colors.purple,
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Main Menu Items
          AdminMenuCard(
            icon: Icons.speed,
            title: 'Kelola Measures',
            subtitle: 'Tambah, edit, dan atur ukuran LEAD/LAG',
            color: Colors.blue,
            onTap: () => context.push(RoutePaths.adminMeasures),
          ),
          const SizedBox(height: 12),

          AdminMenuCard(
            icon: Icons.calendar_month,
            title: 'Kelola Periode',
            subtitle: 'Atur periode penilaian mingguan/bulanan',
            color: Colors.green,
            onTap: () => context.push(RoutePaths.adminPeriods),
          ),
          const SizedBox(height: 12),

          AdminMenuCard(
            icon: Icons.track_changes,
            title: 'Kelola Target',
            subtitle: 'Atur target per pengguna untuk setiap periode',
            color: Colors.teal,
            onTap: () => context.push(RoutePaths.adminTargets),
          ),
          const SizedBox(height: 12),

          AdminMenuCard(
            icon: Icons.table_chart,
            title: 'Ringkasan Skor',
            subtitle: 'Grid skor pengguna per ukuran',
            color: Colors.indigo,
            onTap: () => context.push(RoutePaths.adminScoringSummary),
          ),
          const SizedBox(height: 24),

          // Current Period Info
          periodsAsync.when(
            data: (periods) {
              final currentPeriods = periods.where((p) => p.isCurrent).toList()
                ..sort((a, b) => periodTypePriority(a.periodType)
                    .compareTo(periodTypePriority(b.periodType)));

              if (currentPeriods.isEmpty) {
                return Card(
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tidak ada periode aktif. Buat periode baru atau aktifkan yang ada.',
                            style: TextStyle(color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Periode Aktif',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...currentPeriods.map((period) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: periodTypeColor(period.periodType)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                formatPeriodType(period.periodType),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    period.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_formatDate(period.startDate)} - ${_formatDate(period.endDate)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (period.isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'LOCKED',
                                  style: TextStyle(
                                    color: colorScheme.onError,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Stats card widget for displaying metrics.
class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
