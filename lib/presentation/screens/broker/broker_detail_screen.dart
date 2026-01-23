import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/broker.dart';
import '../../../domain/entities/key_person.dart';
import '../../../domain/entities/pipeline.dart';
import '../../providers/activity_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/pipeline_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../activity/activity_execution_sheet.dart';
import '../activity/immediate_activity_sheet.dart';
import '../customer/key_person_form_sheet.dart';

/// Screen displaying Broker details with tabs.
class BrokerDetailScreen extends ConsumerStatefulWidget {
  const BrokerDetailScreen({
    super.key,
    required this.brokerId,
  });

  final String brokerId;

  @override
  ConsumerState<BrokerDetailScreen> createState() => _BrokerDetailScreenState();
}

class _BrokerDetailScreenState extends ConsumerState<BrokerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brokerAsync = ref.watch(brokerDetailProvider(widget.brokerId));
    final isAdmin = ref.watch(isAdminProvider);

    return brokerAsync.when(
      data: (broker) {
        if (broker == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Broker')),
            body: const Center(child: Text('Broker tidak ditemukan')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(broker.name),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.push('/home/brokers/${broker.id}/edit');
                        break;
                      case 'delete':
                        _confirmDelete(context, broker);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Hapus', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Key Persons'),
                Tab(text: 'Pipelines'),
                Tab(text: 'Activities'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(broker: broker),
              _KeyPersonsTab(brokerId: broker.id),
              _PipelinesTab(brokerId: broker.id),
              _ActivitiesTab(brokerId: broker.id, brokerName: broker.name),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Broker')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Broker')),
        body: AppErrorState(
          title: 'Gagal memuat data',
          onRetry: () => ref.invalidate(brokerDetailProvider(widget.brokerId)),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Broker broker) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Broker'),
        content: Text('Apakah Anda yakin ingin menghapus ${broker.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(brokerFormNotifierProvider.notifier).deleteBroker(broker.id);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broker berhasil dihapus')),
        );
      }
    }
  }
}

/// Info tab showing Broker details.
class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.broker});

  final Broker broker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.handshake,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              broker.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Broker',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Kode', value: broker.code),
                  if (broker.licenseNumber != null)
                    _InfoRow(label: 'No. Lisensi', value: broker.licenseNumber!),
                  if (broker.commissionRate != null)
                    _InfoRow(
                        label: 'Tarif Komisi',
                        value: broker.formattedCommissionRate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact card
          if (broker.phone != null ||
              broker.email != null ||
              broker.website != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (broker.phone != null)
                      _InfoRow(label: 'Telepon', value: broker.phone!),
                    if (broker.email != null)
                      _InfoRow(label: 'Email', value: broker.email!),
                    if (broker.website != null)
                      _InfoRow(label: 'Website', value: broker.website!),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Address card
          if (broker.address != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(broker.address!),
                    if (broker.hasLocation) ...[
                      const SizedBox(height: 8),
                      Text(
                        'GPS: ${broker.latitude}, ${broker.longitude}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab showing key persons (PICs) for this broker.
class _KeyPersonsTab extends ConsumerWidget {
  const _KeyPersonsTab({required this.brokerId});

  final String brokerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyPersonsAsync = ref.watch(brokerKeyPersonsProvider(brokerId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      body: keyPersonsAsync.when(
        data: (keyPersons) {
          if (keyPersons.isEmpty) {
            return const AppEmptyState(
              icon: Icons.people_outline,
              title: 'Belum Ada Key Person',
              subtitle: 'Tambahkan PIC untuk broker ini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: keyPersons.length,
            itemBuilder: (context, index) {
              final kp = keyPersons[index];
              return _KeyPersonCard(
                keyPerson: kp,
                onEdit: isAdmin ? () => _handleEdit(context, kp) : null,
                onDelete: isAdmin
                    ? () => _handleDelete(context, ref, kp)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AppErrorState(
          title: 'Gagal memuat data',
          onRetry: () => ref.invalidate(brokerKeyPersonsProvider(brokerId)),
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _addKeyPerson(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah PIC'),
            )
          : null,
    );
  }

  void _addKeyPerson(BuildContext context) {
    KeyPersonFormSheet.show(
      context,
      brokerId: brokerId,
    );
  }

  void _handleEdit(BuildContext context, KeyPerson keyPerson) {
    KeyPersonFormSheet.show(
      context,
      brokerId: brokerId,
      keyPerson: keyPerson,
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    KeyPerson keyPerson,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Key Person'),
        content: Text('Apakah Anda yakin ingin menghapus ${keyPerson.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(customerRepositoryProvider)
          .deleteKeyPerson(keyPerson.id);
      ref.invalidate(brokerKeyPersonsProvider(keyPerson.brokerId!));
    }
  }
}

/// Card widget for displaying key person info.
class _KeyPersonCard extends StatelessWidget {
  const _KeyPersonCard({
    required this.keyPerson,
    this.onEdit,
    this.onDelete,
  });

  final KeyPerson keyPerson;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: keyPerson.isPrimary
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person,
            color: keyPerson.isPrimary
                ? AppColors.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Row(
          children: [
            Text(keyPerson.name),
            if (keyPerson.isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Primary',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          [
            if (keyPerson.position != null) keyPerson.position!,
            if (keyPerson.phone != null) keyPerson.phone!,
          ].join(' • '),
        ),
        trailing: (onEdit != null || onDelete != null)
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (onDelete != null)
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              )
            : null,
      ),
    );
  }
}

/// Tab showing pipelines associated with this broker.
class _PipelinesTab extends ConsumerWidget {
  const _PipelinesTab({required this.brokerId});

  final String brokerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelinesAsync = ref.watch(brokerPipelinesProvider(brokerId));
    final theme = Theme.of(context);

    return pipelinesAsync.when(
      data: (pipelines) {
        if (pipelines.isEmpty) {
          return const Center(
            child: AppEmptyState(
              icon: Icons.trending_up,
              title: 'Belum Ada Pipeline',
              subtitle: 'Belum ada pipeline yang direferensikan oleh broker ini.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: pipelines.length,
          itemBuilder: (context, index) {
            final pipeline = pipelines[index];
            return _PipelineCard(
              pipeline: pipeline,
              onTap: () => context.push('/home/pipelines/${pipeline.id}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => AppErrorState(
        title: 'Gagal memuat data',
        onRetry: () => ref.invalidate(brokerPipelinesProvider(brokerId)),
      ),
    );
  }
}

/// Card widget for displaying pipeline info in the broker detail.
class _PipelineCard extends StatelessWidget {
  const _PipelineCard({
    required this.pipeline,
    required this.onTap,
  });

  final Pipeline pipeline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageColor = pipeline.stageColor != null 
        ? Color(int.parse('FF${pipeline.stageColor!.replaceAll('#', '')}', radix: 16))
        : AppColors.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pipeline.stageName ?? 'Unknown Stage',
                      style: TextStyle(
                        color: stageColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    pipeline.code,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pipeline.customerName ?? 'Unknown Customer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pipeline.cobLobDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pipeline.formattedPotentialPremium,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const Spacer(),
                  if (pipeline.expectedCloseDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(pipeline.expectedCloseDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Tab showing activities for this broker.
class _ActivitiesTab extends ConsumerWidget {
  const _ActivitiesTab({
    required this.brokerId,
    required this.brokerName,
  });

  final String brokerId;
  final String brokerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(brokerActivitiesProvider(brokerId));
    final theme = Theme.of(context);

    return Scaffold(
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada aktivitas'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showImmediateSheet(context),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Log Aktivitas'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _navigateToSchedule(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Jadwalkan'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Group activities by status
          final upcoming = activities.where((a) =>
              a.status == ActivityStatus.planned ||
              a.status == ActivityStatus.inProgress).toList();
          final completed = activities.where((a) =>
              a.status == ActivityStatus.completed).toList();
          final other = activities.where((a) =>
              a.status == ActivityStatus.cancelled ||
              a.status == ActivityStatus.rescheduled ||
              a.status == ActivityStatus.overdue).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                Text(
                  'Mendatang (${upcoming.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...upcoming.map((a) => _ActivityTile(
                      activity: a,
                      onTap: () => context.push('/home/activities/${a.id}'),
                      onExecute: a.canExecute
                          ? () => _executeActivity(context, a)
                          : null,
                    )),
                const SizedBox(height: 16),
              ],
              if (completed.isNotEmpty) ...[
                Text(
                  'Selesai (${completed.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...completed.map((a) => _ActivityTile(
                      activity: a,
                      onTap: () => context.push('/home/activities/${a.id}'),
                    )),
                const SizedBox(height: 16),
              ],
              if (other.isNotEmpty) ...[
                Text(
                  'Lainnya (${other.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...other.map((a) => _ActivityTile(
                      activity: a,
                      onTap: () => context.push('/home/activities/${a.id}'),
                    )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AppErrorState(
          title: 'Gagal memuat aktivitas',
          onRetry: () => ref.invalidate(brokerActivitiesProvider(brokerId)),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'broker_activity_immediate_fab',
            onPressed: () => _showImmediateSheet(context),
            backgroundColor: AppColors.tertiary,
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'broker_activity_schedule_fab',
            onPressed: () => _navigateToSchedule(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showImmediateSheet(BuildContext context) {
    context.push(
      '/home/activities/immediate?objectType=BROKER&objectId=$brokerId&objectName=${Uri.encodeComponent(brokerName)}',
    );
  }

  void _navigateToSchedule(BuildContext context) {
    context.push(
      '/home/activities/create?objectType=BROKER&objectId=$brokerId&objectName=${Uri.encodeComponent(brokerName)}',
    );
  }

  void _executeActivity(BuildContext context, Activity activity) {
    ActivityExecutionSheet.show(
      context,
      activity: activity,
    );
  }
}

/// Activity tile for the activities list.
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.onTap,
    this.onExecute,
  });

  final Activity activity;
  final VoidCallback onTap;
  final VoidCallback? onExecute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor().withValues(alpha: 0.2),
                radius: 20,
                child: Icon(
                  _getTypeIcon(),
                  size: 20,
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDateTime(activity.scheduledDatetime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.statusText,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onExecute != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onExecute,
                  icon: const Icon(Icons.play_circle_fill),
                  color: AppColors.success,
                  tooltip: 'Eksekusi',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (activity.status) {
      case ActivityStatus.planned:
        return AppColors.info;
      case ActivityStatus.inProgress:
        return AppColors.warning;
      case ActivityStatus.completed:
        return AppColors.success;
      case ActivityStatus.cancelled:
        return AppColors.activityCancelled;
      case ActivityStatus.rescheduled:
        return AppColors.primary;
      case ActivityStatus.overdue:
        return AppColors.error;
    }
  }

  IconData _getTypeIcon() {
    final iconName = activity.activityTypeIcon?.toLowerCase() ?? '';
    switch (iconName) {
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

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (dtDate == today) {
      dateStr = 'Hari ini';
    } else if (dtDate == today.add(const Duration(days: 1))) {
      dateStr = 'Besok';
    } else {
      dateStr = '${dt.day}/${dt.month}';
    }

    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }
}
