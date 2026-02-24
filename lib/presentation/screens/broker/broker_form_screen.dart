import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../data/dtos/broker_dtos.dart';
import '../../../domain/entities/broker.dart';
import '../../providers/broker_providers.dart';
import '../../providers/gps_providers.dart';

/// Screen for creating or editing a Broker.
class BrokerFormScreen extends ConsumerStatefulWidget {
  const BrokerFormScreen({
    super.key,
    this.brokerId,
  });

  final String? brokerId;

  @override
  ConsumerState<BrokerFormScreen> createState() => _BrokerFormScreenState();
}

class _BrokerFormScreenState extends ConsumerState<BrokerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _notesController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isEdit = false;
  bool _hasInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _commissionRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeForm(Broker broker) {
    if (_hasInitialized) return;
    _hasInitialized = true;
    
    _nameController.text = broker.name;
    _licenseNumberController.text = broker.licenseNumber ?? '';
    _addressController.text = broker.address ?? '';
    _phoneController.text = broker.phone ?? '';
    _emailController.text = broker.email ?? '';
    _websiteController.text = broker.website ?? '';
    _commissionRateController.text = broker.commissionRate?.toString() ?? '';
    _notesController.text = broker.notes ?? '';
    _latitude = broker.latitude;
    _longitude = broker.longitude;
  }

  @override
  Widget build(BuildContext context) {
    _isEdit = widget.brokerId != null;
    
    final formState = ref.watch(brokerFormNotifierProvider);

    // Listen for save success
    ref.listen<BrokerFormState>(brokerFormNotifierProvider, (prev, next) {
      if (next.savedBroker != null && prev?.savedBroker == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Broker berhasil diperbarui'
                : 'Broker berhasil ditambahkan'),
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

    // If editing, load existing broker data
    if (_isEdit) {
      final brokerAsync = ref.watch(brokerDetailProvider(widget.brokerId!));
      return brokerAsync.when(
        data: (broker) {
          if (broker != null) {
            _initializeForm(broker);
          }
          return _buildScaffold(context, formState);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Broker')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Broker')),
          body: const Center(child: Text('Gagal memuat data')),
        ),
      );
    }

    return _buildScaffold(context, formState);
  }

  Widget _buildScaffold(BuildContext context, BrokerFormState formState) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Broker' : 'Tambah Broker'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Basic Info Section
            _buildSectionHeader('Informasi Dasar'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama *',
                hintText: 'Nama broker',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: 'Nomor Lisensi',
                hintText: 'Nomor lisensi OJK',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _commissionRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tarif Komisi (%)',
                hintText: 'Contoh: 5.5',
                suffixText: '%',
              ),
              validator: Validators.validatePercentage,
            ),
            const SizedBox(height: 24),

            // Contact Section
            _buildSectionHeader('Kontak'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telepon',
                hintText: '+62...',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'email@example.com',
                prefixIcon: Icon(Icons.email),
              ),
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _websiteController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Website',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.language),
              ),
              validator: Validators.validateUrl,
            ),
            const SizedBox(height: 24),

            // Address Section
            _buildSectionHeader('Alamat'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                hintText: 'Alamat lengkap',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            
            // GPS Capture
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _latitude != null ? Icons.location_on : Icons.location_off,
                          color: _latitude != null ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _latitude != null
                              ? 'Lokasi: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                              : 'Lokasi belum ditentukan',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: _captureGps,
                      child: const Text('Ambil Lokasi GPS'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes Section
            _buildSectionHeader('Catatan'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                hintText: 'Catatan tambahan...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            FilledButton(
              onPressed: formState.isLoading ? null : _submit,
              child: formState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Broker'),
            ),
            // Safe area bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Future<void> _captureGps() async {
    final gpsService = ref.read(gpsServiceProvider);
    
    try {
      final position = await gpsService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lokasi berhasil diambil')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat mengambil lokasi'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(brokerFormNotifierProvider.notifier);
    
    final commissionRate = _commissionRateController.text.isNotEmpty
        ? double.tryParse(_commissionRateController.text)
        : null;

    if (_isEdit) {
      await notifier.updateBroker(
        widget.brokerId!,
        BrokerUpdateDto(
          name: _nameController.text,
          licenseNumber: _licenseNumberController.text.isNotEmpty
              ? _licenseNumberController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
          email: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
          website: _websiteController.text.isNotEmpty
              ? _websiteController.text
              : null,
          commissionRate: commissionRate,
          latitude: _latitude,
          longitude: _longitude,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        ),
      );
    } else {
      await notifier.createBroker(
        BrokerCreateDto(
          name: _nameController.text,
          licenseNumber: _licenseNumberController.text.isNotEmpty
              ? _licenseNumberController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : null,
          email: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
          website: _websiteController.text.isNotEmpty
              ? _websiteController.text
              : null,
          commissionRate: commissionRate,
          latitude: _latitude,
          longitude: _longitude,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        ),
      );
    }
  }
}
