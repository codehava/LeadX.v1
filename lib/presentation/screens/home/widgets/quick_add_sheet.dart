import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Quick add bottom sheet for creating new items.
class QuickAddSheet extends StatelessWidget {
  final VoidCallback? onNewCustomer;
  final VoidCallback? onNewPipeline;
  final VoidCallback? onNewActivity;
  final VoidCallback? onImmediateActivity;

  const QuickAddSheet({
    super.key,
    this.onNewCustomer,
    this.onNewPipeline,
    this.onNewActivity,
    this.onImmediateActivity,
  });

  static void show(
    BuildContext context, {
    VoidCallback? onNewCustomer,
    VoidCallback? onNewPipeline,
    VoidCallback? onNewActivity,
    VoidCallback? onImmediateActivity,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickAddSheet(
        onNewCustomer: onNewCustomer,
        onNewPipeline: onNewPipeline,
        onNewActivity: onNewActivity,
        onImmediateActivity: onImmediateActivity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tambah Baru',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildItem(
            context,
            icon: Icons.person_add,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primaryContainer,
            title: 'Customer Baru',
            subtitle: 'Tambah customer baru',
            onTap: () {
              Navigator.pop(context);
              onNewCustomer?.call();
            },
          ),
          _buildItem(
            context,
            icon: Icons.trending_up,
            iconColor: AppColors.success,
            backgroundColor: AppColors.successContainer,
            title: 'Pipeline Baru',
            subtitle: 'Tambah pipeline baru',
            onTap: () {
              Navigator.pop(context);
              onNewPipeline?.call();
            },
          ),
          _buildItem(
            context,
            icon: Icons.event,
            iconColor: AppColors.tertiary,
            backgroundColor: AppColors.tertiaryContainer,
            title: 'Aktivitas Baru',
            subtitle: 'Jadwalkan aktivitas',
            onTap: () {
              Navigator.pop(context);
              onNewActivity?.call();
            },
          ),
          _buildItem(
            context,
            icon: Icons.flash_on,
            iconColor: AppColors.info,
            backgroundColor: AppColors.infoContainer,
            title: 'Aktivitas Segera',
            subtitle: 'Log aktivitas langsung',
            onTap: () {
              Navigator.pop(context);
              onImmediateActivity?.call();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
