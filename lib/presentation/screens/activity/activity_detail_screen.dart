import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../providers/activity_providers.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/hvc_providers.dart';
import '../../widgets/common/error_state.dart';
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
              context.pushNamed(
                RouteNames.activityEdit,
                pathParameters: {'id': activityId},
              );
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
                              details.activityType?.name ?? activity.displayName,
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
                        onTap: () => _navigateToObject(context, activity),
                      ),
                    if (activity.keyPersonName != null)
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('PIC'),
                        subtitle: Text(activity.keyPersonName!),
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
                              child: GestureDetector(
                                onTap: () => _showPhotoViewer(context, photo, index, details.photos!.length),
                                child: Hero(
                                  tag: 'photo_${photo.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildPhotoThumbnail(photo),
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
                      // Fetch target location based on object type
                      double? targetLat;
                      double? targetLon;

                      switch (activity.objectType) {
                        case ActivityObjectType.customer:
                          if (activity.customerId != null) {
                            final customer = ref.read(customerDetailProvider(activity.customerId!)).value;
                            targetLat = customer?.latitude;
                            targetLon = customer?.longitude;
                          }
                          break;
                        case ActivityObjectType.broker:
                          if (activity.brokerId != null) {
                            final broker = ref.read(brokerDetailProvider(activity.brokerId!)).value;
                            targetLat = broker?.latitude;
                            targetLon = broker?.longitude;
                          }
                          break;
                        case ActivityObjectType.hvc:
                          if (activity.hvcId != null) {
                            final hvc = ref.read(hvcDetailProvider(activity.hvcId!)).value;
                            targetLat = hvc?.latitude;
                            targetLon = hvc?.longitude;
                          }
                          break;
                      }

                      final result = await ActivityExecutionSheet.show(
                        context,
                        activity: activity,
                        targetLat: targetLat,
                        targetLon: targetLon,
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
        error: (error, _) => AppErrorState.general(
          title: 'Failed to load activity details',
          message: error.toString(),
        ),
      ),
    );
  }

  /// Build photo thumbnail - handles both local and remote photos.
  Widget _buildPhotoThumbnail(ActivityPhoto photo) {
    // Check if photo is pending upload and has local path (mobile)
    if (photo.isPendingUpload && photo.localPath != null && !kIsWeb) {
      return Image.file(
        File(photo.localPath!),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 100,
          height: 100,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
      );
    }

    // Use cached network image for uploaded photos
    return CachedNetworkImage(
      imageUrl: photo.photoUrl,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
      ),
    );
  }

  /// Build full-size photo - handles both local and remote photos.
  Widget _buildFullSizePhoto(ActivityPhoto photo) {
    // Check if photo is pending upload and has local path (mobile)
    if (photo.isPendingUpload && photo.localPath != null && !kIsWeb) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.white54,
          ),
        ),
      );
    }

    // Use cached network image for uploaded photos
    return CachedNetworkImage(
      imageUrl: photo.photoUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(
          Icons.broken_image,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// Show fullscreen photo viewer with download option.
  void _showPhotoViewer(
      BuildContext context, ActivityPhoto photo, int index, int total) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'photo_${photo.id}',
                  child: _buildFullSizePhoto(photo),
                ),
              ),
            ),
            // Top bar with close and actions
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      '${index + 1} / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      tooltip: 'Download',
                      onPressed: () async {
                        final uri = Uri.parse(photo.photoUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Bottom info
            if (photo.takenAt != null || photo.caption != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (photo.caption != null)
                        Text(
                          photo.caption!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      if (photo.takenAt != null)
                        Text(
                          'Diambil: ${_formatAuditDateTime(photo.takenAt!)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
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

  void _navigateToObject(BuildContext context, Activity activity) {
    switch (activity.objectType) {
      case ActivityObjectType.customer:
        if (activity.customerId != null) {
          context.go('/home/customers/${activity.customerId}');
        }
        break;
      case ActivityObjectType.hvc:
        if (activity.hvcId != null) {
          context.go('/home/hvcs/${activity.hvcId}');
        }
        break;
      case ActivityObjectType.broker:
        if (activity.brokerId != null) {
          context.go('/home/brokers/${activity.brokerId}');
        }
        break;
    }
  }

  String _formatDateTime(DateTime dt) {
    // Ensure we display in local time
    final localDt = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dtDate = DateTime(localDt.year, localDt.month, localDt.day);

    String dateStr;
    if (dtDate == today) {
      dateStr = 'Hari ini';
    } else {
      dateStr = '${localDt.day}/${localDt.month}/${localDt.year}';
    }

    final timeStr =
        '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
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
                  .cancelActivity(
                    activity.id,
                    reasonController.text,
                    customerId: activity.customerId,
                    hvcId: activity.hvcId,
                    brokerId: activity.brokerId,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aktivitas berhasil dibatalkan'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Navigate back to previous screen after cancellation
                context.pop();
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

  Future<void> _openInMaps(BuildContext context, double lat, double lon) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka peta. Koordinat: $lat, $lon'),
          ),
        );
      }
    }
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
    // Ensure we display in local time
    final localDt = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localDt);
    
    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return '${localDt.day}/${localDt.month}/${localDt.year} ${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    }
  }
}
