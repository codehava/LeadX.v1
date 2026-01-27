import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/providers/admin_providers.dart';
import 'master_data_entity_type.dart';

/// Generic form screen for creating and editing master data entities.
///
/// This screen adapts to any master data entity type with:
/// - Dynamic form fields based on entity type
/// - Validation for required fields and code uniqueness
/// - Save and cancel functionality
class MasterDataFormScreen extends ConsumerStatefulWidget {
  final String entityType;
  final String? itemId;

  const MasterDataFormScreen({
    required this.entityType,
    this.itemId,
    super.key,
  });

  @override
  ConsumerState<MasterDataFormScreen> createState() =>
      _MasterDataFormScreenState();
}

class _MasterDataFormScreenState extends ConsumerState<MasterDataFormScreen> {
  late MasterDataEntityType _type;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();
  final TextEditingController _probabilityController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Find entity type from table name
    _type = MasterDataEntityType.values.firstWhere(
      (type) => type.tableName == widget.entityType,
      orElse: () => MasterDataEntityType.companyType,
    );

    // Load existing data if editing
    if (widget.itemId != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (widget.itemId == null) return;

    setState(() => _isLoading = true);
    try {
      final repository = ref.read(adminMasterDataRepositoryProvider);
      final item = await repository.getEntity(_type.tableName, widget.itemId!);

      if (!mounted) return;
      if (item != null) {
        _codeController.text = item['code']?.toString() ?? '';
        _nameController.text = item['name']?.toString() ?? '';
        _sortOrderController.text = item['sort_order']?.toString() ?? '';
        _probabilityController.text = item['probability']?.toString() ?? '';
        _isActive = item['is_active'] == true;
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(adminMasterDataRepositoryProvider);
      final data = {
        'code': _codeController.text.trim(),
        'name': _nameController.text.trim(),
        'is_active': _isActive,
      };

      // Add entity-specific fields
      if (_type == MasterDataEntityType.pipelineStage ||
          _type == MasterDataEntityType.pipelineStatus ||
          _type == MasterDataEntityType.companyType ||
          _type == MasterDataEntityType.ownershipType ||
          _type == MasterDataEntityType.industry ||
          _type == MasterDataEntityType.cob ||
          _type == MasterDataEntityType.activityType ||
          _type == MasterDataEntityType.declineReason ||
          _type == MasterDataEntityType.hvcType ||
          _type == MasterDataEntityType.lob) {
        if (_sortOrderController.text.isNotEmpty) {
          data['sort_order'] = int.tryParse(_sortOrderController.text) ?? 0;
        }
      }

      if (_type == MasterDataEntityType.pipelineStage) {
        if (_probabilityController.text.isNotEmpty) {
          data['probability'] = int.tryParse(_probabilityController.text) ?? 0;
        }
      }

      if (widget.itemId != null) {
        // Edit
        final result =
            await repository.updateEntity(_type.tableName, widget.itemId!, data);
        result.fold(
          (failure) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menyimpan: ${failure.message}')),
            );
          },
          (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data berhasil disimpan')),
            );
            context.pop();
          },
        );
      } else {
        // Create - use specific method if available
        if (_type == MasterDataEntityType.companyType) {
          // Generic create for now
          final result = await repository.createEntity(_type.tableName, data);
          result.fold(
            (failure) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal membuat: ${failure.message}')),
              );
            },
            (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil dibuat')),
              );
              context.pop();
            },
          );
        } else {
          final result = await repository.createEntity(_type.tableName, data);
          result.fold(
            (failure) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal membuat: ${failure.message}')),
              );
            },
            (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil dibuat')),
              );
              context.pop();
            },
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _sortOrderController.dispose();
    _probabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.itemId != null ? 'Edit ${_type.displayName}' : 'Tambah ${_type.displayName}',
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Code field
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Kode',
                        hintText: 'Masukkan kode ${_type.displayName.toLowerCase()}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Kode tidak boleh kosong';
                        }
                        return null;
                      },
                      enabled: widget.itemId == null,
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Masukkan nama ${_type.displayName.toLowerCase()}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sort order field (if applicable)
                    if (_type != MasterDataEntityType.province &&
                        _type != MasterDataEntityType.city)
                      Column(
                        children: [
                          TextFormField(
                            controller: _sortOrderController,
                            decoration: InputDecoration(
                              labelText: 'Urutan',
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Probability field (pipeline stages only)
                    if (_type == MasterDataEntityType.pipelineStage)
                      Column(
                        children: [
                          TextFormField(
                            controller: _probabilityController,
                            decoration: InputDecoration(
                              labelText: 'Probabilitas (%)',
                              hintText: '0-100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isNotEmpty ?? false) {
                                final prob = int.tryParse(value!);
                                if (prob == null || prob < 0 || prob > 100) {
                                  return 'Probabilitas harus antara 0-100';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Active status toggle
                    SwitchListTile(
                      title: const Text('Status Aktif'),
                      subtitle: Text(
                        _isActive ? 'Data akan aktif' : 'Data tidak aktif',
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : () => context.pop(),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveData,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
