import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/customer_dtos.dart';
import '../../../domain/entities/key_person.dart';
import '../../providers/broker_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/hvc_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Bottom sheet form for creating or editing a key person.
class KeyPersonFormSheet extends ConsumerStatefulWidget {
  const KeyPersonFormSheet({
    super.key,
    this.customerId,
    this.hvcId,
    this.brokerId,
    this.keyPerson,
  }) : assert(
          customerId != null || hvcId != null || brokerId != null,
          'Must provide exactly one owner ID',
        );

  /// Customer ID to associate the key person with.
  final String? customerId;

  /// HVC ID to associate the key person with.
  final String? hvcId;

  /// Broker ID to associate the key person with.
  final String? brokerId;

  /// Existing key person for editing, null for creating new.
  final KeyPerson? keyPerson;

  /// Show the key person form sheet.
  static Future<void> show(
    BuildContext context, {
    String? customerId,
    String? hvcId,
    String? brokerId,
    KeyPerson? keyPerson,
  }) {
    assert(
      customerId != null || hvcId != null || brokerId != null,
      'Must provide exactly one owner ID',
    );
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => KeyPersonFormSheet(
        customerId: customerId,
        hvcId: hvcId,
        brokerId: brokerId,
        keyPerson: keyPerson,
      ),
    );
  }

  bool get isEditing => keyPerson != null;

  @override
  ConsumerState<KeyPersonFormSheet> createState() => _KeyPersonFormSheetState();
}

class _KeyPersonFormSheetState extends ConsumerState<KeyPersonFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isPrimary = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.keyPerson != null) {
      _nameController.text = widget.keyPerson!.name;
      _positionController.text = widget.keyPerson!.position ?? '';
      _departmentController.text = widget.keyPerson!.department ?? '';
      _phoneController.text = widget.keyPerson!.phone ?? '';
      _emailController.text = widget.keyPerson!.email ?? '';
      _notesController.text = widget.keyPerson!.notes ?? '';
      _isPrimary = widget.keyPerson!.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final navBarHeight = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + navBarHeight),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    widget.isEditing ? 'Edit Key Person' : 'Tambah Key Person',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      AppTextField(
                        controller: _nameController,
                        label: 'Nama *',
                        hint: 'Masukkan nama key person',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Position & Department
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _positionController,
                              label: 'Jabatan',
                              hint: 'Contoh: Direktur',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _departmentController,
                              label: 'Departemen',
                              hint: 'Contoh: Finance',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      AppTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        hint: 'Contoh: 08123456789',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Contoh: nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      AppTextField(
                        controller: _notesController,
                        label: 'Catatan',
                        hint: 'Catatan tambahan (opsional)',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Is Primary toggle
                      SwitchListTile(
                        value: _isPrimary,
                        onChanged: (value) => setState(() => _isPrimary = value),
                        title: const Text('Kontak Utama'),
                        subtitle: const Text(
                          'Tandai sebagai kontak utama untuk customer ini',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),

                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              label: widget.isEditing ? 'Update' : 'Simpan',
                              isLoading: _isLoading,
                              onPressed: _handleSave,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customerRepo = ref.read(customerRepositoryProvider);
      
      String ownerType = 'CUSTOMER';
      if (widget.hvcId != null) {
        ownerType = 'HVC';
      } else if (widget.brokerId != null) {
        ownerType = 'BROKER';
      }

      // Create DTO for both create and update
      final dto = KeyPersonDto(
        ownerType: ownerType,
        name: _nameController.text,
        customerId: widget.customerId,
        hvcId: widget.hvcId,
        brokerId: widget.brokerId,
        position: _positionController.text.isEmpty ? null : _positionController.text,
        department: _departmentController.text.isEmpty ? null : _departmentController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isPrimary: _isPrimary,
      );

      if (widget.isEditing) {
        // Update existing key person
        final result = await customerRepo.updateKeyPerson(widget.keyPerson!.id, dto);
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          },
          (keyPerson) {
            if (mounted) {
              // Invalidate the appropriate provider to refresh the list
              _invalidateKeyPersonProviders();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Key person berhasil diupdate')),
              );
            }
          },
        );
      } else {
        // Create new key person
        final result = await customerRepo.addKeyPerson(dto);
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          },
          (keyPerson) {
            if (mounted) {
              // Invalidate the appropriate provider to refresh the list
              _invalidateKeyPersonProviders();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Key person berhasil ditambahkan')),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Invalidate key person providers to refresh the list.
  void _invalidateKeyPersonProviders() {
    if (widget.hvcId != null) {
      ref.invalidate(hvcKeyPersonsProvider(widget.hvcId!));
    }
    if (widget.customerId != null) {
      ref.invalidate(customerKeyPersonsProvider(widget.customerId!));
    }
    if (widget.brokerId != null) {
      ref.invalidate(brokerKeyPersonsProvider(widget.brokerId!));
    }
  }
}
