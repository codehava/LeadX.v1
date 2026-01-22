import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/dtos/hvc_dtos.dart';
import '../../../domain/entities/hvc.dart';
import '../../providers/gps_providers.dart';
import '../../providers/hvc_providers.dart';
import '../../widgets/common/searchable_dropdown.dart';

/// Screen for creating or editing an HVC.
class HvcFormScreen extends ConsumerStatefulWidget {
  const HvcFormScreen({
    super.key,
    this.hvcId,
  });

  final String? hvcId;

  bool get isEditing => hvcId != null;

  @override
  ConsumerState<HvcFormScreen> createState() => _HvcFormScreenState();
}

class _HvcFormScreenState extends ConsumerState<HvcFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _radiusController = TextEditingController(text: '500');
  final _potentialValueController = TextEditingController();

  String? _selectedTypeId;
  double? _latitude;
  double? _longitude;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _radiusController.dispose();
    _potentialValueController.dispose();
    super.dispose();
  }

  void _initializeForm(Hvc hvc) {
    if (_isInitialized) return;
    _isInitialized = true;

    _nameController.text = hvc.name;
    _descriptionController.text = hvc.description ?? '';
    _addressController.text = hvc.address ?? '';
    _radiusController.text = hvc.radiusMeters.toString();
    if (hvc.potentialValue != null) {
      _potentialValueController.text = hvc.potentialValue!.toStringAsFixed(0);
    }
    _selectedTypeId = hvc.typeId;
    _latitude = hvc.latitude;
    _longitude = hvc.longitude;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(hvcFormNotifierProvider);
    final hvcTypesAsync = ref.watch(hvcTypesProvider);

    // If editing, load existing HVC data
    if (widget.isEditing && !_isInitialized) {
      final hvcAsync = ref.watch(hvcDetailProvider(widget.hvcId!));
      hvcAsync.whenData((hvc) {
        if (hvc != null) _initializeForm(hvc);
      });
    }

    // Handle save success
    ref.listen<HvcFormState>(hvcFormNotifierProvider, (prev, next) {
      if (next.savedHvc != null && prev?.savedHvc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'HVC berhasil diperbarui'
                : 'HVC berhasil dibuat'),
          ),
        );
        context.pop();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit HVC' : 'Tambah HVC'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HVC Type
            hvcTypesAsync.when(
              data: (types) => SearchableDropdown<String>(
                label: 'Tipe HVC *',
                hint: 'Pilih tipe HVC',
                items: types
                    .map((t) => DropdownItem(value: t.id, label: t.name))
                    .toList(),
                value: _selectedTypeId,
                onChanged: (value) {
                  setState(() {
                    _selectedTypeId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Tipe HVC harus dipilih';
                  return null;
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Gagal memuat tipe HVC'),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama HVC *',
                hintText: 'Masukkan nama HVC',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi (opsional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                hintText: 'Masukkan alamat',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // GPS Capture
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi GPS',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_latitude != null && _longitude != null)
                      Text(
                        'Lat: ${_latitude!.toStringAsFixed(6)}, '
                        'Lng: ${_longitude!.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Text(
                        'Belum ada koordinat',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _captureGps,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Ambil Lokasi'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Geofence Radius
            TextFormField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Radius Geofence (meter)',
                hintText: '500',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Potential Value
            TextFormField(
              controller: _potentialValueController,
              decoration: const InputDecoration(
                labelText: 'Nilai Potensial (Rp)',
                hintText: 'Masukkan nilai potensial',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: formState.isLoading ? null : _submit,
              child: formState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Simpan' : 'Buat HVC'),
            ),
          ],
        ),
      ),
    );
  }

  void _captureGps() async {
    try {
      final gpsService = ref.read(gpsServiceProvider);
      final position = await gpsService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mendapatkan lokasi GPS'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi berhasil diambil')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tipe HVC terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final notifier = ref.read(hvcFormNotifierProvider.notifier);

    final potentialValue = _potentialValueController.text.isNotEmpty
        ? double.tryParse(_potentialValueController.text.replaceAll('.', ''))
        : null;
    final radiusMeters = int.tryParse(_radiusController.text) ?? 500;

    if (widget.isEditing) {
      notifier.updateHvc(
        widget.hvcId!,
        HvcUpdateDto(
          name: _nameController.text.trim(),
          typeId: _selectedTypeId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          radiusMeters: radiusMeters,
          potentialValue: potentialValue,
        ),
      );
    } else {
      notifier.createHvc(
        HvcCreateDto(
          name: _nameController.text.trim(),
          typeId: _selectedTypeId!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          radiusMeters: radiusMeters,
          potentialValue: potentialValue,
        ),
      );
    }
  }
}
