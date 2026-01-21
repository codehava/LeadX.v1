import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/dtos/customer_dtos.dart';
import '../../../data/services/gps_service.dart';
import '../../providers/customer_providers.dart';
import '../../providers/gps_providers.dart';
import '../../providers/master_data_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/discard_confirmation_dialog.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/searchable_dropdown.dart';

/// Screen for creating or editing a customer.
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  final String? customerId;

  bool get isEditing => customerId != null;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _npwpController = TextEditingController();
  final _notesController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Selected IDs for dropdowns
  String? _selectedProvinceId;
  String? _selectedCityId;
  String? _selectedCompanyTypeId;
  String? _selectedOwnershipTypeId;
  String? _selectedIndustryId;

  // GPS coordinates (auto-captured on create)
  double? _capturedLatitude;
  double? _capturedLongitude;
  bool _isCapturingGps = false;

  bool _isLoading = false;
  bool _hasUnsavedChanges = false;  // Track form changes

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadCustomer();
    } else {
      // Auto-capture GPS for new customers
      _captureGpsLocation();
    }
  }

  Future<void> _captureGpsLocation() async {
    setState(() => _isCapturingGps = true);
    try {
      final gpsService = ref.read(gpsServiceProvider);
      final position = await gpsService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _capturedLatitude = position.latitude;
          _capturedLongitude = position.longitude;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturingGps = false);
      }
    }
  }

  Future<void> _loadCustomer() async {
    if (widget.customerId == null) return;

    setState(() => _isLoading = true);

    final customer =
        await ref.read(customerDetailProvider(widget.customerId!).future);

    if (customer != null && mounted) {
      _nameController.text = customer.name;
      _addressController.text = customer.address;
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _websiteController.text = customer.website ?? '';
      _npwpController.text = customer.npwp ?? '';
      _notesController.text = customer.notes ?? '';
      _postalCodeController.text = customer.postalCode ?? '';

      setState(() {
        _selectedProvinceId = customer.provinceId;
        _selectedCityId = customer.cityId;
        _selectedCompanyTypeId = customer.companyTypeId;
        _selectedOwnershipTypeId = customer.ownershipTypeId;
        _selectedIndustryId = customer.industryId;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _npwpController.dispose();
    _notesController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormNotifierProvider);
    final theme = Theme.of(context);

    // Listen for successful save
    ref.listen<CustomerFormState>(customerFormNotifierProvider, (prev, next) {
      if (next.savedCustomer != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Customer berhasil diupdate'
                  : 'Customer berhasil ditambahkan',
            ),
          ),
        );
        context.pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await DiscardConfirmationDialog.show(context);
        if (shouldDiscard && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Customer' : 'Customer Baru'),
        ),
        body: _isLoading
            ? const Center(child: AppLoadingIndicator())
            : _buildForm(theme),
        bottomNavigationBar: _buildBottomBar(formState, theme),
      ),
    );
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Widget _buildForm(ThemeData theme) {
    // Watch master data providers
    final provincesAsync = ref.watch(provincesStreamProvider);
    final citiesAsync = ref.watch(citiesByProvinceProvider(_selectedProvinceId));
    final companyTypesAsync = ref.watch(companyTypesStreamProvider);
    final ownershipTypesAsync = ref.watch(ownershipTypesStreamProvider);
    final industriesAsync = ref.watch(industriesStreamProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Section
            _SectionHeader(title: 'Informasi Dasar'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              label: 'Nama Customer *',
              hint: 'Masukkan nama customer',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama customer wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _addressController,
              label: 'Alamat *',
              hint: 'Masukkan alamat lengkap',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Province & City dropdowns with cascade
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: provincesAsync.when(
                    data: (provinces) => SearchableDropdown<String>(
                      label: 'Provinsi *',
                      hint: 'Pilih provinsi',
                      modalTitle: 'Pilih Provinsi',
                      value: _selectedProvinceId,
                      items: provinces
                          .map((p) => DropdownItem(value: p.id, label: p.name))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProvinceId = value;
                          // Reset city when province changes
                          _selectedCityId = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Provinsi wajib dipilih' : null,
                    ),
                    loading: () => _buildLoadingDropdown('Provinsi *'),
                    error: (_, __) => _buildErrorDropdown('Provinsi *'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: citiesAsync.when(
                    data: (cities) => SearchableDropdown<String>(
                      label: 'Kota *',
                      hint: _selectedProvinceId == null
                          ? 'Pilih provinsi dulu'
                          : 'Pilih kota',
                      modalTitle: 'Pilih Kota',
                      value: _selectedCityId,
                      enabled: _selectedProvinceId != null,
                      items: cities
                          .map((c) => DropdownItem(value: c.id, label: c.name))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCityId = value),
                      validator: (value) =>
                          value == null ? 'Kota wajib dipilih' : null,
                    ),
                    loading: () => _buildLoadingDropdown('Kota *'),
                    error: (_, __) => _buildErrorDropdown('Kota *'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _postalCodeController,
              label: 'Kode Pos',
              hint: 'Masukkan kode pos',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),

            // Contact Info Section
            _SectionHeader(title: 'Informasi Kontak'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              hint: 'Contoh: 021-1234567',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Contoh: info@customer.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'Contoh: www.customer.com',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 32),

            // Business Info Section
            _SectionHeader(title: 'Informasi Bisnis'),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: companyTypesAsync.when(
                    data: (types) => SearchableDropdown<String>(
                      label: 'Tipe Perusahaan *',
                      hint: 'Pilih tipe',
                      modalTitle: 'Tipe Perusahaan',
                      value: _selectedCompanyTypeId,
                      items: types
                          .map((t) => DropdownItem(value: t.id, label: t.name))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCompanyTypeId = value),
                      validator: (value) =>
                          value == null ? 'Tipe wajib dipilih' : null,
                    ),
                    loading: () => _buildLoadingDropdown('Tipe Perusahaan *'),
                    error: (_, __) => _buildErrorDropdown('Tipe Perusahaan *'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ownershipTypesAsync.when(
                    data: (types) => SearchableDropdown<String>(
                      label: 'Kepemilikan *',
                      hint: 'Pilih kepemilikan',
                      modalTitle: 'Tipe Kepemilikan',
                      value: _selectedOwnershipTypeId,
                      items: types
                          .map((t) => DropdownItem(value: t.id, label: t.name))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedOwnershipTypeId = value),
                      validator: (value) =>
                          value == null ? 'Kepemilikan wajib dipilih' : null,
                    ),
                    loading: () => _buildLoadingDropdown('Kepemilikan *'),
                    error: (_, __) => _buildErrorDropdown('Kepemilikan *'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            industriesAsync.when(
              data: (industries) => SearchableDropdown<String>(
                label: 'Industri *',
                hint: 'Pilih industri',
                modalTitle: 'Industri',
                value: _selectedIndustryId,
                items: industries
                    .map((i) => DropdownItem(value: i.id, label: i.name))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedIndustryId = value),
                validator: (value) =>
                    value == null ? 'Industri wajib dipilih' : null,
              ),
              loading: () => _buildLoadingDropdown('Industri *'),
              error: (_, __) => _buildErrorDropdown('Industri *'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _npwpController,
              label: 'NPWP',
              hint: 'Masukkan nomor NPWP',
            ),

            const SizedBox(height: 32),

            // Notes Section
            _SectionHeader(title: 'Catatan'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: 'Catatan',
              hint: 'Tambahkan catatan (opsional)',
              maxLines: 4,
            ),

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Memuat...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 16),
              SizedBox(width: 12),
              Text('Gagal memuat data'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CustomerFormState formState, ThemeData theme) {
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
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: AppButton(
              label: widget.isEditing ? 'Update' : 'Simpan',
              isLoading: formState.isLoading,
              onPressed: _handleSave,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required dropdowns (FormField validator handles this but double-check)
    if (_selectedProvinceId == null ||
        _selectedCityId == null ||
        _selectedCompanyTypeId == null ||
        _selectedOwnershipTypeId == null ||
        _selectedIndustryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formNotifier = ref.read(customerFormNotifierProvider.notifier);

    if (widget.isEditing) {
      formNotifier.updateCustomer(
        widget.customerId!,
        CustomerUpdateDto(
          name: _nameController.text,
          address: _addressController.text,
          provinceId: _selectedProvinceId,
          cityId: _selectedCityId,
          postalCode: _postalCodeController.text.isNotEmpty
              ? _postalCodeController.text
              : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          website: _websiteController.text.isNotEmpty
              ? _websiteController.text
              : null,
          companyTypeId: _selectedCompanyTypeId,
          ownershipTypeId: _selectedOwnershipTypeId,
          industryId: _selectedIndustryId,
          npwp: _npwpController.text.isNotEmpty ? _npwpController.text : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        ),
      );
    } else {
      formNotifier.createCustomer(
        CustomerCreateDto(
          name: _nameController.text,
          address: _addressController.text,
          provinceId: _selectedProvinceId!,
          cityId: _selectedCityId!,
          companyTypeId: _selectedCompanyTypeId!,
          ownershipTypeId: _selectedOwnershipTypeId!,
          industryId: _selectedIndustryId!,
          assignedRmId: '', // Will be set from current user in repository
          postalCode: _postalCodeController.text.isNotEmpty
              ? _postalCodeController.text
              : null,
          latitude: _capturedLatitude,
          longitude: _capturedLongitude,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          website: _websiteController.text.isNotEmpty
              ? _websiteController.text
              : null,
          npwp: _npwpController.text.isNotEmpty ? _npwpController.text : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
