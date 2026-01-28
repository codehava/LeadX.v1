import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/key_person.dart';
import '../../providers/activity_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/pipeline_providers.dart';
import '../../widgets/cards/pipeline_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/pipeline/pipeline_kanban_board.dart';
import '../activity/activity_execution_sheet.dart';
import '../activity/immediate_activity_sheet.dart';
import 'key_person_form_sheet.dart';

/// Customer detail screen with tabs for info, key persons, pipelines, activities.
class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen>
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
    final customerAsync = ref.watch(customerDetailProvider(widget.customerId));
    final theme = Theme.of(context);

    return customerAsync.when(
      data: (customer) {
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer')),
            body: const Center(child: Text('Customer tidak ditemukan')),
          );
        }
        return _buildContent(customer, theme);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Customer')),
        body: const Center(child: AppLoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Customer')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(Customer customer, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/home/customers/${customer.id}/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, customer),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'history', child: Text('Riwayat Perubahan')),
              const PopupMenuItem(value: 'share', child: Text('Bagikan')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Key Person'),
            Tab(text: 'Pipeline'),
            Tab(text: 'Aktivitas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _InfoTab(customer: customer),
          _KeyPersonsTab(customerId: customer.id),
          _PipelinesTab(customerId: customer.id),
          _ActivitiesTab(customerId: customer.id, customerName: customer.name),
        ],
      ),
      // Quick action buttons
      bottomNavigationBar: _buildQuickActions(customer, theme),
    );
  }

  Widget _buildQuickActions(Customer customer, ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickActionButton(
              icon: Icons.phone,
              label: 'Telepon',
              onTap: customer.phone != null
                  ? () => _launchUrl('tel:${customer.phone}')
                  : null,
            ),
            _QuickActionButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              onTap: customer.phone != null
                  ? () => _launchUrl('https://wa.me/${_formatWhatsApp(customer.phone!)}')
                  : null,
            ),
            _QuickActionButton(
              icon: Icons.email,
              label: 'Email',
              onTap: customer.email != null
                  ? () => _launchUrl('mailto:${customer.email}')
                  : null,
            ),
            _QuickActionButton(
              icon: Icons.navigation,
              label: 'Navigasi',
              onTap: customer.hasLocation
                  ? () => _launchUrl(
                      'https://www.google.com/maps/search/?api=1&query=${customer.latitude},${customer.longitude}')
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Customer customer) {
    switch (action) {
      case 'history':
        context.push('/home/customers/${customer.id}/history');
      case 'delete':
        _showDeleteConfirmation(customer);
      case 'share':
        // TODO: Implement share
        break;
    }
  }

  void _showDeleteConfirmation(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Customer?'),
        content: Text('Apakah Anda yakin ingin menghapus ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Delete customer
              if (mounted) context.pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatWhatsApp(String phone) {
    var formatted = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (formatted.startsWith('0')) {
      formatted = '62${formatted.substring(1)}';
    }
    return formatted;
  }
}

/// Info tab showing customer details.
class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(
            title: 'Informasi Dasar',
            children: [
              _InfoRow(label: 'Kode', value: customer.code),
              _InfoRow(label: 'Nama', value: customer.name),
              _InfoRow(label: 'Status', value: customer.isActive ? 'Aktif' : 'Tidak Aktif'),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'Alamat',
            children: [
              _InfoRow(label: 'Alamat', value: customer.address),
              if (customer.provinceName != null) _InfoRow(label: 'Provinsi', value: customer.provinceName!),
              if (customer.cityName != null) _InfoRow(label: 'Kota', value: customer.cityName!),
              if (customer.postalCode != null) _InfoRow(label: 'Kode Pos', value: customer.postalCode!),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'Kontak',
            children: [
              if (customer.phone != null) _InfoRow(label: 'Telepon', value: customer.phone!),
              if (customer.email != null) _InfoRow(label: 'Email', value: customer.email!),
              if (customer.website != null) _InfoRow(label: 'Website', value: customer.website!),
            ],
          ),
          const SizedBox(height: 24),
          _InfoSection(
            title: 'Informasi Bisnis',
            children: [
              if (customer.companyTypeName != null) _InfoRow(label: 'Tipe Perusahaan', value: customer.companyTypeName!),
              if (customer.ownershipTypeName != null) _InfoRow(label: 'Tipe Kepemilikan', value: customer.ownershipTypeName!),
              if (customer.industryName != null) _InfoRow(label: 'Industri', value: customer.industryName!),
              if (customer.npwp != null) _InfoRow(label: 'NPWP', value: customer.npwp!),
            ],
          ),
          if (customer.notes != null) ...[
            const SizedBox(height: 24),
            _InfoSection(
              title: 'Catatan',
              children: [
                Text(customer.notes!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Key persons tab.
class _KeyPersonsTab extends ConsumerWidget {
  const _KeyPersonsTab({required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyPersonsAsync = ref.watch(customerKeyPersonsProvider(customerId));
    final theme = Theme.of(context);

    return keyPersonsAsync.when(
      data: (keyPersons) {
        if (keyPersons.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                const Text('Belum ada key person'),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => KeyPersonFormSheet.show(
                    context,
                    customerId: customerId,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Key Person'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: keyPersons.length + 1,
          itemBuilder: (context, index) {
            if (index == keyPersons.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton.icon(
                  onPressed: () => KeyPersonFormSheet.show(
                    context,
                    customerId: customerId,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Key Person'),
                ),
              );
            }
            return _KeyPersonCard(
              keyPerson: keyPersons[index],
              onEdit: () => _handleEdit(context, keyPersons[index]),
              onDelete: () => _handleDelete(context, ref, keyPersons[index]),
            );
          },
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  void _handleEdit(BuildContext context, KeyPerson keyPerson) {
    KeyPersonFormSheet.show(
      context,
      customerId: customerId,
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

    if (confirmed == true) {
      final repo = ref.read(customerRepositoryProvider);
      final result = await repo.deleteKeyPerson(keyPerson.id);
      
      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus: ${failure.message}')),
            );
          }
        },
        (_) {
          if (context.mounted) {
            ref.invalidate(customerKeyPersonsProvider(customerId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Key person berhasil dihapus')),
            );
          }
        },
      );
    }
  }
}

  class _KeyPersonCard extends ConsumerWidget {
  const _KeyPersonCard({
    required this.keyPerson,
    required this.onEdit,
    required this.onDelete,
  });

  final KeyPerson keyPerson;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                ],
              ),
            ),
            if (keyPerson.phone != null)
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // TODO: Call
                },
              ),
            // if (keyPerson.email != null)
            //   IconButton(
            //     icon: const Icon(Icons.email),
            //     onPressed: () {
            //       // TODO: Email
            //     },
            //   ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
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

/// Pipelines tab showing customer pipelines with List/Kanban toggle.
class _PipelinesTab extends ConsumerStatefulWidget {
  const _PipelinesTab({required this.customerId});

  final String customerId;

  @override
  ConsumerState<_PipelinesTab> createState() => _PipelinesTabState();
}

class _PipelinesTabState extends ConsumerState<_PipelinesTab> {
  bool _isKanbanView = false;

  @override
  Widget build(BuildContext context) {
    final pipelinesAsync = ref.watch(customerPipelinesProvider(widget.customerId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pipelines'),
        actions: [
          // View toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.list),
                label: Text('List'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.view_kanban),
                label: Text('Kanban'),
              ),
            ],
            selected: {_isKanbanView},
            onSelectionChanged: (values) {
              setState(() => _isKanbanView = values.first);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pipelinesAsync.when(
        data: (pipelines) {
          if (pipelines.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  const Text('Belum ada pipeline'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/home/pipelines/new?customerId=${widget.customerId}'),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Pipeline'),
                  ),
                ],
              ),
            );
          }
          
          if (_isKanbanView) {
            return PipelineKanbanBoard(
              pipelines: pipelines,
              onPipelineTap: (pipeline) => context.push(
                '/home/pipelines/${pipeline.id}?customerId=${widget.customerId}',
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: pipelines.length,
            itemBuilder: (context, index) {
              final pipeline = pipelines[index];
              return PipelineCard(
                pipeline: pipeline,
                onTap: () => context.push('/home/pipelines/${pipeline.id}?customerId=${widget.customerId}'),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          heroTag: 'pipelines_tab_fab',
          onPressed: () => context.push('/home/pipelines/new?customerId=${widget.customerId}'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Activities tab showing customer activities.
class _ActivitiesTab extends ConsumerWidget {
  const _ActivitiesTab({required this.customerId, required this.customerName});

  final String customerId;
  final String customerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(customerActivitiesProvider(customerId));
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
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'activity_immediate_fab',
              onPressed: () => _showImmediateSheet(context),
              backgroundColor: AppColors.tertiary,
              child: const Icon(Icons.flash_on),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'activity_schedule_fab',
              onPressed: () => _navigateToSchedule(context),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showImmediateSheet(BuildContext context) {
    context.push(
      '/home/activities/immediate?objectType=CUSTOMER&objectId=$customerId&objectName=${Uri.encodeComponent(customerName)}',
    );
  }

  void _navigateToSchedule(BuildContext context) {
    context.push(
      '/home/activities/create?objectType=CUSTOMER&objectId=$customerId&objectName=${Uri.encodeComponent(customerName)}',
    );
  }

  void _executeActivity(BuildContext context, Activity activity) {
    ActivityExecutionSheet.show(
      context,
      activity: activity,
      // targetLat/targetLon would come from customer location if available
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
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
      padding: const EdgeInsets.only(bottom: 8),
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
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isEnabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
