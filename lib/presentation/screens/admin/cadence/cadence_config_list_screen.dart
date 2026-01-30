import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../domain/entities/cadence.dart';
import '../../../providers/cadence_providers.dart';

/// Admin screen for managing cadence schedule configurations.
class CadenceConfigListScreen extends ConsumerWidget {
  const CadenceConfigListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(allCadenceConfigsProvider);
    final actionState = ref.watch(adminCadenceConfigNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show snackbar on success/error
    ref.listen(adminCadenceConfigNotifierProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(adminCadenceConfigNotifierProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(adminCadenceConfigNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Cadence'),
        elevation: 0,
      ),
      body: configsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Gagal memuat data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allCadenceConfigsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (configs) {
          if (configs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada konfigurasi cadence',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambah konfigurasi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allCadenceConfigsProvider);
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Level')),
                        DataColumn(label: Text('Frekuensi')),
                        DataColumn(label: Text('Hari')),
                        DataColumn(label: Text('Waktu')),
                        DataColumn(label: Text('Durasi')),
                        DataColumn(label: Text('Deadline')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: configs.map((config) => _buildRow(context, ref, config, actionState.isLoading)).toList(),
                    ),
                  ),
                ),
              ),
              if (actionState.isLoading)
                const ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.adminCadenceCreate),
        tooltip: 'Tambah Konfigurasi',
        child: const Icon(Icons.add),
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    WidgetRef ref,
    CadenceScheduleConfig config,
    bool isLoading,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(config.name)),
        DataCell(Text(_formatLevel(config.targetRole, config.facilitatorRole))),
        DataCell(Text(_formatFrequency(config.frequency))),
        DataCell(Text(_formatDay(config.frequency, config.dayOfWeek, config.dayOfMonth))),
        DataCell(Text(config.defaultTime ?? '-')),
        DataCell(Text('${config.durationMinutes} menit')),
        DataCell(Text('${config.preMeetingHours} jam')),
        DataCell(
          Switch(
            value: config.isActive,
            onChanged: isLoading
                ? null
                : (value) {
                    ref
                        .read(adminCadenceConfigNotifierProvider.notifier)
                        .toggleActive(config.id, value);
                  },
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: isLoading
                    ? null
                    : () => context.pushNamed(
                          RouteNames.adminCadenceCreate,
                          queryParameters: {'id': config.id},
                        ),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: isLoading ? Colors.grey : Colors.red),
                onPressed: isLoading ? null : () => _confirmDelete(context, ref, config),
                tooltip: 'Hapus',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLevel(String targetRole, String facilitatorRole) {
    return '$targetRole → $facilitatorRole';
  }

  String _formatFrequency(MeetingFrequency frequency) {
    switch (frequency) {
      case MeetingFrequency.daily:
        return 'Harian';
      case MeetingFrequency.weekly:
        return 'Mingguan';
      case MeetingFrequency.monthly:
        return 'Bulanan';
      case MeetingFrequency.quarterly:
        return 'Kuartalan';
    }
  }

  String _formatDay(MeetingFrequency frequency, int? dayOfWeek, int? dayOfMonth) {
    if (frequency == MeetingFrequency.daily) {
      return 'Setiap hari';
    }
    if (frequency == MeetingFrequency.weekly && dayOfWeek != null) {
      const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      return days[dayOfWeek];
    }
    if ((frequency == MeetingFrequency.monthly || frequency == MeetingFrequency.quarterly) && dayOfMonth != null) {
      return 'Tanggal $dayOfMonth';
    }
    return '-';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CadenceScheduleConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Konfigurasi'),
        content: Text('Apakah Anda yakin ingin menghapus "${config.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(adminCadenceConfigNotifierProvider.notifier)
                  .deleteConfig(config.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
