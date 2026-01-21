import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';
import 'activity_execution_sheet.dart';
import 'activity_reschedule_sheet.dart';

/// Screen for viewing activity details.
class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;

  const ActivityDetailScreen({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activityAsync = ref.watch(activityWithDetailsProvider(activityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aktivitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit
            },
          ),
        ],
      ),
      body: activityAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Aktivitas tidak ditemukan'));
          }

          final activity = details.activity;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Activity type header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            _getStatusColor(activity.status).withValues(alpha: 0.2),
                        child: Icon(
                          _getTypeIcon(activity.activityTypeIcon),
                          color: _getStatusColor(activity.status),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(activity.status).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                activity.statusText,
                                style: TextStyle(
                                  color: _getStatusColor(activity.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Waktu'),
                      subtitle: Text(_formatDateTime(activity.scheduledDatetime)),
                    ),
                    if (activity.objectName != null)
                      ListTile(
                        leading: Icon(_getObjectTypeIcon(activity.objectType)),
                        title: Text(_getObjectTypeLabel(activity.objectType)),
                        subtitle: Text(activity.objectName!),
                      ),
                    if (activity.summary != null)
                      ListTile(
                        leading: const Icon(Icons.short_text),
                        title: const Text('Ringkasan'),
                        subtitle: Text(activity.summary!),
                      ),
                    if (activity.notes != null)
                      ListTile(
                        leading: const Icon(Icons.notes),
                        title: const Text('Catatan'),
                        subtitle: Text(activity.notes!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // GPS Info (if executed)
              if (activity.latitude != null && activity.longitude != null)
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Lokasi Eksekusi',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          activity.isLocationOverride
                              ? Icons.gps_off
                              : Icons.gps_fixed,
                          color: activity.isLocationOverride
                              ? Colors.orange
                              : Colors.green,
                        ),
                        title: Text(
                          activity.isLocationOverride
                              ? 'Lokasi Override'
                              : 'Lokasi Valid',
                        ),
                        subtitle: activity.isLocationOverride
                            ? Text(activity.overrideReason ?? 'No reason provided')
                            : Text(
                                '${activity.distanceFromTarget?.toInt() ?? 0}m dari target'),
                      ),
                    ],
                  ),
                ),

              // Photos (if any)
              if (details.photos?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Foto (${details.photos!.length})',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: details.photos!.length,
                          itemBuilder: (context, index) {
                            final photo = details.photos![index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  photo.photoUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],

              // Map Preview (if coordinates available)
              if (activity.latitude != null && activity.longitude != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.map, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Lokasi Eksekusi',
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${activity.latitude!.toStringAsFixed(6)}, ${activity.longitude!.toStringAsFixed(6)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: FilledButton.tonalIcon(
                                onPressed: () => _openInMaps(
                                  context,
                                  activity.latitude!,
                                  activity.longitude!,
                                ),
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('Buka Peta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],

              // History / Audit Log
              if (details.auditLogs?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Riwayat Aktivitas',
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      ...details.auditLogs!.map((log) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: _getAuditLogColor(log.action).withValues(alpha: 0.2),
                          child: Icon(
                            _getAuditLogIcon(log.action),
                            size: 16,
                            color: _getAuditLogColor(log.action),
                          ),
                        ),
                        title: Text(
                          _getAuditLogTitle(log.action),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (log.notes != null)
                              Text(
                                log.notes!,
                                style: theme.textTheme.bodySmall,
                              ),
                            Text(
                              _formatAuditDateTime(log.performedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: log.notes != null,
                      )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],

              // Actions
              if (activity.canExecute)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final result = await ActivityExecutionSheet.show(
                        context,
                        activity: activity,
                        // Pass customer location if available
                      );
                      if (result == true && context.mounted) {
                        // Refresh the activity details
                        ref.invalidate(activityWithDetailsProvider(activityId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Aktivitas berhasil dieksekusi'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Eksekusi Aktivitas'),
                  ),
                ),
              if (activity.canReschedule)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await ActivityRescheduleSheet.show(
                        context,
                        activity: activity,
                      );
                      if (result != null && context.mounted) {
                        // Refresh and show success
                        ref.invalidate(activityWithDetailsProvider(activityId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Aktivitas berhasil dijadwalkan ulang'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.schedule),
                    label: const Text('Jadwalkan Ulang'),
                  ),
                ),
              if (activity.canCancel)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () => _showCancelDialog(context, ref, activity),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Batalkan',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.planned:
        return Colors.blue;
      case ActivityStatus.inProgress:
        return Colors.orange;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.cancelled:
        return Colors.grey;
      case ActivityStatus.rescheduled:
        return Colors.purple;
      case ActivityStatus.overdue:
        return Colors.red;
    }
  }

  IconData _getTypeIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'visit':
      case 'place':
      case 'location':
        return Icons.place;
      case 'call':
      case 'phone':
        return Icons.phone;
      case 'meeting':
      case 'people':
        return Icons.people;
      case 'email':
      case 'mail':
        return Icons.email;
      default:
        return Icons.event;
    }
  }

  IconData _getObjectTypeIcon(ActivityObjectType type) {
    switch (type) {
      case ActivityObjectType.customer:
        return Icons.business;
      case ActivityObjectType.hvc:
        return Icons.star;
      case ActivityObjectType.broker:
        return Icons.handshake;
    }
  }

  String _getObjectTypeLabel(ActivityObjectType type) {
    switch (type) {
      case ActivityObjectType.customer:
        return 'Customer';
      case ActivityObjectType.hvc:
        return 'HVC';
      case ActivityObjectType.broker:
        return 'Broker';
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (dtDate == today) {
      dateStr = 'Hari ini';
    } else {
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    }

    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$dateStr pukul $timeStr';
  }

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, Activity activity) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Aktivitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin membatalkan aktivitas "${activity.displayName}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Pembatalan *',
                hintText: 'Masukkan alasan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan pembatalan wajib diisi'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }
              
              Navigator.pop(dialogContext);
              
              // Call cancel method
              await ref
                  .read(activityFormNotifierProvider.notifier)
                  .cancelActivity(activity.id, reasonController.text);
              
              if (context.mounted) {
                ref.invalidate(activityWithDetailsProvider(activityId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aktivitas berhasil dibatalkan'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _openInMaps(BuildContext context, double lat, double lon) {
    // Open in Google Maps via URL
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    // Using launchUrl would require url_launcher, for now just show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Koordinat: $lat, $lon'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // TODO: Copy to clipboard
          },
        ),
      ),
    );
  }

  Color _getAuditLogColor(String action) {
    switch (action.toUpperCase()) {
      case 'CREATED':
        return AppColors.info;
      case 'EXECUTED':
        return AppColors.success;
      case 'RESCHEDULED':
        return AppColors.warning;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getAuditLogIcon(String action) {
    switch (action.toUpperCase()) {
      case 'CREATED':
        return Icons.add_circle_outline;
      case 'EXECUTED':
        return Icons.check_circle_outline;
      case 'RESCHEDULED':
        return Icons.schedule;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getAuditLogTitle(String action) {
    switch (action.toUpperCase()) {
      case 'CREATED':
        return 'Aktivitas dibuat';
      case 'EXECUTED':
        return 'Aktivitas dieksekusi';
      case 'RESCHEDULED':
        return 'Aktivitas dijadwalkan ulang';
      case 'CANCELLED':
        return 'Aktivitas dibatalkan';
      default:
        return action;
    }
  }

  String _formatAuditDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
