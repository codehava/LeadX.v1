import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/customer.dart';
import '../../../domain/entities/key_person.dart';
import '../../providers/customer_providers.dart';
import '../../widgets/common/loading_indicator.dart';

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
          _PlaceholderTab(title: 'Pipeline'),
          _PlaceholderTab(title: 'Aktivitas'),
        ],
      ),
      // Quick action buttons
      bottomNavigationBar: _buildQuickActions(customer, theme),
    );
  }

  Widget _buildQuickActions(Customer customer, ThemeData theme) {
    return Container(
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
    );
  }

  void _handleMenuAction(String action, Customer customer) {
    switch (action) {
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
                  onPressed: () {
                    // TODO: Add key person
                  },
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
                  onPressed: () {
                    // TODO: Add key person
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Key Person'),
                ),
              );
            }
            return _KeyPersonCard(keyPerson: keyPersons[index]);
          },
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _KeyPersonCard extends StatelessWidget {
  const _KeyPersonCard({required this.keyPerson});

  final KeyPerson keyPerson;

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
            if (keyPerson.email != null)
              IconButton(
                icon: const Icon(Icons.email),
                onPressed: () {
                  // TODO: Email
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder tab for pipelines and activities.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('$title - Coming Soon'),
        ],
      ),
    );
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
