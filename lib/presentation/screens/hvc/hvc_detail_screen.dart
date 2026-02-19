import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/hvc.dart';
import '../../../domain/entities/key_person.dart';
import '../../providers/activity_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/hvc_providers.dart';
import '../../providers/customer_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../activity/activity_execution_sheet.dart';
import '../activity/immediate_activity_sheet.dart';
import '../customer/key_person_form_sheet.dart';
import '../../widgets/hvc/hvc_customer_link_sheet.dart';

/// Screen displaying HVC details with tabs.
class HvcDetailScreen extends ConsumerStatefulWidget {
  const HvcDetailScreen({
    super.key,
    required this.hvcId,
  });

  final String hvcId;

  @override
  ConsumerState<HvcDetailScreen> createState() => _HvcDetailScreenState();
}

class _HvcDetailScreenState extends ConsumerState<HvcDetailScreen>
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
    final hvcAsync = ref.watch(hvcDetailProvider(widget.hvcId));
    final isAdmin = ref.watch(isAdminProvider);

    return hvcAsync.when(
      data: (hvc) {
        if (hvc == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('HVC')),
            body: const AppEmptyState(
              icon: Icons.error_outline,
              title: 'Tidak Ditemukan',
              subtitle: 'HVC tidak ditemukan.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(hvc.name),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.push('/hvcs/${hvc.id}/edit');
                        break;
                      case 'delete':
                        _confirmDelete(context, hvc);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Pelanggan'),
                Tab(text: 'Key Person'),
                Tab(text: 'Aktivitas'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(hvc: hvc),
              _LinkedCustomersTab(hvcId: hvc.id, hvcName: hvc.name),
              _KeyPersonsTab(hvcId: hvc.id, isAdmin: isAdmin),
              _ActivitiesTab(hvcId: hvc.id, hvcName: hvc.name),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('HVC')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('HVC')),
        body: AppErrorState(
          title: 'Gagal memuat detail HVC',
          onRetry: () => ref.invalidate(hvcDetailProvider(widget.hvcId)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Hvc hvc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus HVC'),
        content: Text('Apakah Anda yakin ingin menghapus "${hvc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final notifier = ref.read(hvcFormNotifierProvider.notifier);
              final success = await notifier.deleteHvc(hvc.id);
              if (success && mounted) {
                if (context.mounted) context.pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('HVC berhasil dihapus')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Info tab showing HVC details.
class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.hvc});

  final Hvc hvc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  if (hvc.typeName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hvc.typeName!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  if (hvc.typeName != null) const SizedBox(height: 16),

                  // Code
                  _InfoRow(label: 'Kode', value: hvc.code),

                  // Description
                  if (hvc.description != null && hvc.description!.isNotEmpty)
                    _InfoRow(label: 'Deskripsi', value: hvc.description!),

                  // Address
                  if (hvc.address != null && hvc.address!.isNotEmpty)
                    _InfoRow(label: 'Alamat', value: hvc.address!),

                  // Potential value
                  if (hvc.potentialValue != null)
                    _InfoRow(
                      label: 'Nilai Potensial',
                      value: hvc.formattedPotentialValue,
                    ),

                  // Geofence radius
                  _InfoRow(
                    label: 'Radius Geofence',
                    value: '${hvc.radiusMeters} meter',
                  ),

                  // GPS
                  if (hvc.hasLocation)
                    _InfoRow(
                      label: 'Koordinat',
                      value: '${hvc.latitude}, ${hvc.longitude}',
                    ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Tab showing linked customers.
class _LinkedCustomersTab extends ConsumerWidget {
  const _LinkedCustomersTab({
    required this.hvcId,
    required this.hvcName,
  });

  final String hvcId;
  final String hvcName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(linkedCustomersProvider(hvcId));
    final theme = Theme.of(context);

    return Scaffold(
      body: linksAsync.when(
        data: (links) {
          if (links.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada pelanggan terhubung'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _addCustomer(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Pelanggan'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 88),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return Dismissible(
                key: Key(link.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) => _confirmUnlink(
                  context,
                  ref,
                  link.id,
                  link.customerId,
                  link.customerName ?? 'Pelanggan',
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.business),
                    ),
                    title: Text(link.customerName ?? 'Pelanggan'),
                    subtitle: Text(link.relationshipDisplayName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.link_off, color: Colors.red),
                          tooltip: 'Hapus Link',
                          onPressed: () => _confirmUnlink(
                            context,
                            ref,
                            link.id,
                            link.customerId,
                            link.customerName ?? 'Pelanggan',
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => context.push('/home/customers/${link.customerId}'),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppErrorState(
          title: 'Gagal memuat pelanggan',
          onRetry: () => ref.invalidate(linkedCustomersProvider(hvcId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'hvc_add_customer_fab',
        onPressed: () => _addCustomer(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _confirmUnlink(
    BuildContext context,
    WidgetRef ref,
    String linkId,
    String customerId,
    String customerName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Link'),
        content: Text('Hapus hubungan dengan "$customerName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result ?? false) {
      final notifier = ref.read(customerHvcLinkNotifierProvider.notifier);
      final success = await notifier.unlinkCustomerFromHvc(
        linkId,
        hvcId: hvcId,
        customerId: customerId,
      );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link berhasil dihapus')),
        );
      }
      return success;
    }
    return false;
  }

  void _addCustomer(BuildContext context) {
    HvcCustomerLinkSheet.show(
      context,
      hvcId: hvcId,
      hvcName: hvcName,
    );
  }
}

/// Tab showing key persons for this HVC.
class _KeyPersonsTab extends ConsumerWidget {
  const _KeyPersonsTab({
    required this.hvcId,
    required this.isAdmin,
  });

  final String hvcId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyPersonsAsync = ref.watch(hvcKeyPersonsProvider(hvcId));
    final theme = Theme.of(context);

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                const Text('Belum ada key person'),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _addKeyPerson(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Key Person'),
                  ),
                ],
              ],
            ),
          );
        }

        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keyPersons.length,
            itemBuilder: (context, index) {
              final keyPerson = keyPersons[index];
              return _KeyPersonCard(
                keyPerson: keyPerson,
                onEdit: isAdmin ? () => _handleEdit(context, keyPerson) : null,
                onDelete: isAdmin ? () => _handleDelete(context, ref, keyPerson) : null,
              );
            },
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  heroTag: 'hvc_key_person_fab',
                  onPressed: () => _addKeyPerson(context),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppErrorState(
        title: 'Gagal memuat key persons',
        onRetry: () => ref.invalidate(hvcKeyPersonsProvider(hvcId)),
      ),
    );
  }

  void _addKeyPerson(BuildContext context) {
    KeyPersonFormSheet.show(
      context,
      hvcId: hvcId,
    );
  }

  void _handleEdit(BuildContext context, KeyPerson keyPerson) {
    KeyPersonFormSheet.show(
      context,
      hvcId: hvcId,
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
        content: Text('Hapus "${keyPerson.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // We use CustomerRepository for key persons as it handles the generic key person table
      final repo = ref.read(customerRepositoryProvider);
      final result = await repo.deleteKeyPerson(keyPerson.id);
      
      switch (result) {
        case Success():
          if (context.mounted) {
            ref.invalidate(hvcKeyPersonsProvider(hvcId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Key person berhasil dihapus')),
            );
          }
        case ResultFailure(:final failure):
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus: ${failure.message}')),
            );
          }
      }
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                keyPerson.name.isNotEmpty ? keyPerson.name[0].toUpperCase() : '?',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        keyPerson.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (keyPerson.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PIC',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (keyPerson.position != null)
                    Text(
                      keyPerson.position!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (keyPerson.department != null)
                    Text(
                      keyPerson.department!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (keyPerson.phone != null)
              IconButton(
                icon: const Icon(Icons.phone),
                tooltip: keyPerson.phone,
                onPressed: () => launchUrl(Uri.parse('tel:${keyPerson.phone}')),
              ),
            if (keyPerson.email != null)
              IconButton(
                icon: const Icon(Icons.email),
                tooltip: keyPerson.email,
                onPressed: () => launchUrl(Uri.parse('mailto:${keyPerson.email}')),
              ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Tab showing activities for this HVC.
class _ActivitiesTab extends ConsumerWidget {
  const _ActivitiesTab({
    required this.hvcId,
    required this.hvcName,
  });

  final String hvcId;
  final String hvcName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(hvcActivitiesProvider(hvcId));
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
          final upcoming = activities
              .where((a) =>
                  a.status == ActivityStatus.planned ||
                  a.status == ActivityStatus.inProgress)
              .toList();
          final completed = activities
              .where((a) => a.status == ActivityStatus.completed)
              .toList();
          final other = activities
              .where((a) =>
                  a.status == ActivityStatus.cancelled ||
                  a.status == ActivityStatus.rescheduled ||
                  a.status == ActivityStatus.overdue)
              .toList();

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
        error: (error, stack) => AppErrorState(
          title: 'Gagal memuat aktivitas',
          onRetry: () => ref.invalidate(hvcActivitiesProvider(hvcId)),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'hvc_activity_immediate_fab',
            onPressed: () => _showImmediateSheet(context),
            backgroundColor: AppColors.tertiary,
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'hvc_activity_schedule_fab',
            onPressed: () => _navigateToSchedule(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showImmediateSheet(BuildContext context) {
    context.push(
      '/home/activities/immediate?objectType=HVC&objectId=$hvcId&objectName=${Uri.encodeComponent(hvcName)}',
    );
  }

  void _navigateToSchedule(BuildContext context) {
    context.push(
      '/home/activities/create?objectType=HVC&objectId=$hvcId&objectName=${Uri.encodeComponent(hvcName)}',
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'Hari ini';
    } else if (date == today.add(const Duration(days: 1))) {
      dateStr = 'Besok';
    } else if (date == today.subtract(const Duration(days: 1))) {
      dateStr = 'Kemarin';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$dateStr, $hour:$minute';
  }
}
