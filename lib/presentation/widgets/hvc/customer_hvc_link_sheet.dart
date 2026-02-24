import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/hvc_dtos.dart';
import '../../../domain/entities/hvc.dart';
import '../../providers/hvc_providers.dart';
import '../../widgets/common/searchable_dropdown.dart';

/// Bottom sheet for linking a customer to an HVC.
class CustomerHvcLinkSheet extends ConsumerStatefulWidget {
  const CustomerHvcLinkSheet({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  final String customerId;
  final String customerName;

  /// Show the sheet and return the created link on success.
  static Future<CustomerHvcLink?> show(
    BuildContext context, {
    required String customerId,
    required String customerName,
  }) {
    return showModalBottomSheet<CustomerHvcLink>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomerHvcLinkSheet(
        customerId: customerId,
        customerName: customerName,
      ),
    );
  }

  @override
  ConsumerState<CustomerHvcLinkSheet> createState() =>
      _CustomerHvcLinkSheetState();
}

class _CustomerHvcLinkSheetState extends ConsumerState<CustomerHvcLinkSheet> {
  String? _selectedHvcId;
  String _selectedRelationshipType = 'tenant';
  final _notesController = TextEditingController();

  static const List<DropdownItem<String>> _relationshipTypes = [
    DropdownItem(value: 'holding', label: 'Holding'),
    DropdownItem(value: 'subsidiary', label: 'Subsidiary'),
    DropdownItem(value: 'affiliate', label: 'Affiliate'),
    DropdownItem(value: 'jv', label: 'Joint Venture'),
    DropdownItem(value: 'tenant', label: 'Tenant'),
    DropdownItem(value: 'member', label: 'Member'),
    DropdownItem(value: 'supplier', label: 'Supplier'),
    DropdownItem(value: 'contractor', label: 'Contractor'),
    DropdownItem(value: 'distributor', label: 'Distributor'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hvcsAsync = ref.watch(hvcListStreamProvider);
    final linkState = ref.watch(customerHvcLinkNotifierProvider);

    // Listen for save success
    ref.listen<CustomerHvcLinkState>(customerHvcLinkNotifierProvider,
        (prev, next) {
      if (next.savedLink != null && prev?.savedLink == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menghubungkan ke HVC')),
        );
        Navigator.pop(context, next.savedLink);
      }
      if (next.errorMessage != null && prev?.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Hubungkan ke HVC',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pelanggan: ${widget.customerName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // HVC picker
          hvcsAsync.when(
            data: (hvcs) => SearchableDropdown<String>(
              label: 'Pilih HVC *',
              hint: 'Cari HVC...',
              items: hvcs
                  .map((h) => DropdownItem(
                        value: h.id,
                        label: h.name,
                        subtitle: h.typeName ?? h.code,
                      ))
                  .toList(),
              value: _selectedHvcId,
              onChanged: (value) {
                setState(() {
                  _selectedHvcId = value;
                });
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Gagal memuat daftar HVC'),
          ),
          const SizedBox(height: 16),

          // Relationship type
          SearchableDropdown<String>(
            label: 'Tipe Hubungan *',
            hint: 'Pilih tipe hubungan',
            items: _relationshipTypes,
            value: _selectedRelationshipType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRelationshipType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Notes (optional)
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              hintText: 'Tambahkan catatan...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: linkState.isLoading ? null : _submit,
                  child: linkState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Hubungkan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _submit() {
    if (_selectedHvcId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih HVC terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dto = CustomerHvcLinkDto(
      customerId: widget.customerId,
      hvcId: _selectedHvcId!,
      relationshipType: _selectedRelationshipType,
    );

    ref.read(customerHvcLinkNotifierProvider.notifier).linkCustomerToHvc(dto);
  }
}
