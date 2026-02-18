import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A badge indicator for sync status.
class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;
  final bool showLabel;

  const SyncStatusBadge({
    super.key,
    required this.status,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      SyncStatus.synced => (AppColors.syncSynced, 'Synced', Icons.cloud_done),
      SyncStatus.pending => (AppColors.syncPending, 'Pending', Icons.cloud_upload),
      SyncStatus.failed => (AppColors.syncFailed, 'Failed', Icons.cloud_off),
      SyncStatus.offline => (AppColors.syncOffline, 'Offline', Icons.cloud_outlined),
      SyncStatus.deadLetter => (Colors.orange, 'Gagal', Icons.warning_amber),
    };

    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(icon, size: 16, color: color);
  }
}

/// Sync status enum.
enum SyncStatus {
  synced,
  pending,
  failed,
  offline,
  deadLetter,
}
