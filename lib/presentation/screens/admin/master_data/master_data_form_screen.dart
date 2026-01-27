import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/providers/admin_providers.dart';
import '../../../../presentation/providers/master_data_providers.dart';
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
  final TextEditingController _sequenceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _isSaving = false;

  // FK selection fields
  String? _selectedProvinceId;
  String? _selectedCobId;
  String? _selectedStageId;
  String? _selectedRegionalOfficeId;

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
        _sequenceController.text = item['sequence']?.toString() ?? '';
        _probabilityController.text = item['probability']?.toString() ?? '';
        _descriptionController.text = item['description']?.toString() ?? '';
        _addressController.text = item['address']?.toString() ?? '';
        _phoneController.text = item['phone']?.toString() ?? '';
        _latitudeController.text = item['latitude']?.toString() ?? '';
        _longitudeController.text = item['longitude']?.toString() ?? '';
        _isActive = item['is_active'] == true;

        // Load FK values
        if (item['province_id'] != null) {
          _selectedProvinceId = item['province_id'] as String;
        }
        if (item['cob_id'] != null) {
          _selectedCobId = item['cob_id'] as String;
        }
        if (item['stage_id'] != null) {
          _selectedStageId = item['stage_id'] as String;
        }
        if (item['regional_office_id'] != null) {
          _selectedRegionalOfficeId = item['regional_office_id'] as String;
        }
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
        if (_sequenceController.text.isNotEmpty) {
          data['sequence'] = int.tryParse(_sequenceController.text) ?? 0;
        }
      }

      if (_type == MasterDataEntityType.pipelineStatus) {
        if (_sequenceController.text.isNotEmpty) {
          data['sequence'] = int.tryParse(_sequenceController.text) ?? 0;
        }
        if (_descriptionController.text.isNotEmpty) {
          data['description'] = _descriptionController.text.trim();
        }
        if (_selectedStageId != null) {
          data['stage_id'] = _selectedStageId!;
        }
      }

      // FK fields for entities that depend on other master data
      if (_type == MasterDataEntityType.city) {
        if (_selectedProvinceId != null) {
          data['province_id'] = _selectedProvinceId!;
        }
      }

      if (_type == MasterDataEntityType.lob) {
        if (_selectedCobId != null) {
          data['cob_id'] = _selectedCobId!;
        }
        if (_descriptionController.text.isNotEmpty) {
          data['description'] = _descriptionController.text.trim();
        }
      }

      if (_type == MasterDataEntityType.cob) {
        if (_descriptionController.text.isNotEmpty) {
          data['description'] = _descriptionController.text.trim();
        }
      }

      // Optional fields for regional offices and branches
      if (_type == MasterDataEntityType.regionalOffice ||
          _type == MasterDataEntityType.branch) {
        if (_descriptionController.text.isNotEmpty) {
          data['description'] = _descriptionController.text.trim();
        }
        if (_addressController.text.isNotEmpty) {
          data['address'] = _addressController.text.trim();
        }
        if (_phoneController.text.isNotEmpty) {
          data['phone'] = _phoneController.text.trim();
        }
        if (_latitudeController.text.isNotEmpty) {
          final lat = double.tryParse(_latitudeController.text);
          if (lat != null) data['latitude'] = lat;
        }
        if (_longitudeController.text.isNotEmpty) {
          final lng = double.tryParse(_longitudeController.text);
          if (lng != null) data['longitude'] = lng;
        }
      }

      // Regional office selection for branches
      if (_type == MasterDataEntityType.branch) {
        if (_selectedRegionalOfficeId != null) {
          data['regional_office_id'] = _selectedRegionalOfficeId!;
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
    _sequenceController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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
                          TextFormField(
                            controller: _sequenceController,
                            decoration: InputDecoration(
                              labelText: 'Urutan Tampilan',
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

                    // Province selection (for City)
                    if (_type == MasterDataEntityType.city)
                      Column(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final provincesAsync = ref.watch(provincesStreamProvider);
                              return provincesAsync.when(
                                data: (provinces) {
                                  return DropdownButtonFormField<String?>(
                                    initialValue: _selectedProvinceId,
                                    decoration: InputDecoration(
                                      labelText: 'Provinsi',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: provinces.map((province) {
                                      return DropdownMenuItem<String?>(
                                        value: province.id,
                                        child: Text(province.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedProvinceId = value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Provinsi harus dipilih';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (err, stack) => SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text('Error: $err'),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // COB selection (for LOB)
                    if (_type == MasterDataEntityType.lob)
                      Column(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final cobsAsync = ref.watch(cobsStreamProvider);
                              return cobsAsync.when(
                                data: (cobs) {
                                  return DropdownButtonFormField<String?>(
                                    initialValue: _selectedCobId,
                                    decoration: InputDecoration(
                                      labelText: 'Class of Business',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: cobs.map((cob) {
                                      return DropdownMenuItem<String?>(
                                        value: cob.id,
                                        child: Text(cob.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedCobId = value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'COB harus dipilih';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (err, stack) => SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text('Error: $err'),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi',
                              hintText: 'Deskripsi LOB',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Pipeline Stage selection (for Pipeline Status)
                    if (_type == MasterDataEntityType.pipelineStatus)
                      Column(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final stagesAsync = ref.watch(pipelineStagesStreamProvider);
                              return stagesAsync.when(
                                data: (stages) {
                                  return DropdownButtonFormField<String?>(
                                    initialValue: _selectedStageId,
                                    decoration: InputDecoration(
                                      labelText: 'Tahap Pipeline',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: stages.map((stage) {
                                      return DropdownMenuItem<String?>(
                                        value: stage.id,
                                        child: Text(stage.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedStageId = value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tahap pipeline harus dipilih';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (err, stack) => SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text('Error: $err'),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _sequenceController,
                            decoration: InputDecoration(
                              labelText: 'Urutan dalam Tahap',
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi',
                              hintText: 'Deskripsi status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Description field (for COB)
                    if (_type == MasterDataEntityType.cob)
                      Column(
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi',
                              hintText: 'Deskripsi COB',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Regional Office selection (for Branch)
                    if (_type == MasterDataEntityType.branch)
                      Column(
                        children: [
                          Consumer(
                            builder: (context, ref, _) {
                              final regionalOfficesAsync =
                                  ref.watch(regionalOfficesStreamProvider);
                              return regionalOfficesAsync.when(
                                data: (regionalOffices) {
                                  return DropdownButtonFormField<String?>(
                                    initialValue: _selectedRegionalOfficeId,
                                    decoration: InputDecoration(
                                      labelText: 'Kantor Wilayah',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: regionalOffices.map((ro) {
                                      return DropdownMenuItem<String?>(
                                        value: ro.id,
                                        child: Text(ro.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                          () => _selectedRegionalOfficeId = value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Kantor Wilayah harus dipilih';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (err, stack) => SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text('Error: $err'),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Optional fields for Regional Office and Branch
                    if (_type == MasterDataEntityType.regionalOffice ||
                        _type == MasterDataEntityType.branch)
                      Column(
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi (Opsional)',
                              hintText: 'Masukkan deskripsi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Alamat (Opsional)',
                              hintText: 'Masukkan alamat lengkap',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Telepon (Opsional)',
                              hintText: 'Contoh: +62-21-12345678',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latitudeController,
                                  decoration: InputDecoration(
                                    labelText: 'Latitude (Opsional)',
                                    hintText: '-6.2088',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _longitudeController,
                                  decoration: InputDecoration(
                                    labelText: 'Longitude (Opsional)',
                                    hintText: '106.8456',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ),
                            ],
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
