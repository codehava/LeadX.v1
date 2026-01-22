import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/broker.dart';
import '../../../domain/entities/key_person.dart';
import '../../providers/activity_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
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
    // Use pipeline provider - we'd need to create brokerPipelinesProvider
    // For now, show placeholder
    return const Center(
      child: AppEmptyState(
        icon: Icons.trending_up,
        title: 'Pipeline',
        subtitle: 'Daftar pipeline yang menggunakan broker ini.',
      ),
    );
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

    return Scaffold(
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const AppEmptyState(
              icon: Icons.event_note_outlined,
              title: 'Belum Ada Aktivitas',
              subtitle: 'Belum ada aktivitas untuk broker ini.',
            );
          }

          // Group activities by status
          final upcoming = activities
              .where((a) => a.status == ActivityStatus.planned)
              .toList();
          final completed = activities
              .where((a) => a.status == ActivityStatus.completed)
              .toList();
          final other = activities
              .where((a) =>
                  a.status != ActivityStatus.planned &&
                  a.status != ActivityStatus.completed)
              .toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            children: [
              if (upcoming.isNotEmpty) ...[
                _buildSectionHeader(context, 'Mendatang', upcoming.length),
                ...upcoming.map((a) => _ActivityTile(
                      activity: a,
                      onExecute: () => _executeActivity(context, a),
                    )),
              ],
              if (completed.isNotEmpty) ...[
                _buildSectionHeader(context, 'Selesai', completed.length),
                ...completed.map((a) => _ActivityTile(activity: a)),
              ],
              if (other.isNotEmpty) ...[
                _buildSectionHeader(context, 'Lainnya', other.length),
                ...other.map((a) => _ActivityTile(activity: a)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActivityOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Aktivitas'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showActivityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Log Aktivitas'),
              subtitle: const Text('Catat aktivitas yang baru dilakukan'),
              onTap: () {
                Navigator.pop(context);
                _showImmediateSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Jadwalkan Aktivitas'),
              subtitle: const Text('Rencanakan aktivitas ke depan'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSchedule(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImmediateSheet(BuildContext context) {
    ImmediateActivitySheet.show(
      context,
      objectType: 'BROKER',
      objectId: brokerId,
      objectName: brokerName,
    );
  }

  void _navigateToSchedule(BuildContext context) {
    context.push('/home/activities/schedule?objectType=BROKER&objectId=$brokerId');
  }

  void _executeActivity(BuildContext context, Activity activity) {
    ActivityExecutionSheet.show(context, activity: activity);
  }
}

/// Activity tile for the activities list.
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    this.onExecute,
  });

  final Activity activity;
  final VoidCallback? onExecute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
        ),
        title: Text(activity.activityTypeName ?? 'Aktivitas'),
        subtitle: Text(
          activity.summary ?? _formatDateTime(activity.scheduledDatetime),
        ),
        trailing: activity.status == ActivityStatus.planned && onExecute != null
            ? FilledButton.tonal(
                onPressed: onExecute,
                child: const Text('Execute'),
              )
            : null,
        onTap: () => context.push('/home/activities/${activity.id}'),
      ),
    );
  }

  Color _getStatusColor() {
    switch (activity.status) {
      case ActivityStatus.planned:
        return AppColors.info;
      case ActivityStatus.completed:
        return AppColors.success;
      case ActivityStatus.cancelled:
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (activity.status) {
      case ActivityStatus.planned:
        return Icons.schedule;
      case ActivityStatus.completed:
        return Icons.check_circle;
      case ActivityStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
