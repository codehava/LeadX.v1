import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../data/dtos/admin/user_management_dtos.dart';
import '../../../../data/dtos/master_data_dtos.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/admin_user_providers.dart';
import '../../../providers/master_data_providers.dart';
import '../../../widgets/common/searchable_dropdown.dart';

/// Screen for creating or editing a user.
///
/// When [userId] is null, creates a new user.
/// When [userId] is provided, edits an existing user.
class UserFormScreen extends ConsumerStatefulWidget {
  const UserFormScreen({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _nipController = TextEditingController();
  final _phoneController = TextEditingController();

  UserRole _selectedRole = UserRole.rm;
  String? _selectedBranchId;
  String? _selectedRegionalOfficeId;
  String? _selectedParentId;
  bool _isLoading = false;
  String? _generatedPassword;

  bool get isEditMode => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Load user data in post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserData();
      });
    }
  }

  Future<void> _loadUserData() async {
    if (!isEditMode || widget.userId == null) return;

    try {
      final user = await ref.read(userByIdProvider(widget.userId!).future);

      if (user != null && mounted) {
        setState(() {
          _emailController.text = user.email;
          _nameController.text = user.name;
          _nipController.text = user.nip ?? '';
          _phoneController.text = user.phone ?? '';
          _selectedRole = user.role;
          _selectedRegionalOfficeId = user.regionalOfficeId;
          _selectedBranchId = user.branchId;
          _selectedParentId = user.parentId;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengguna: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _nipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Pengguna' : 'Tambah Pengguna'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                hintText: 'contoh@askrindo.co.id',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isEditMode, // Email cannot be changed
              validator: Validators.validateEmailRequired,
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                hintText: 'John Doe',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // NIP field
            TextFormField(
              controller: _nipController,
              decoration: const InputDecoration(
                labelText: 'NIP *',
                hintText: '123456789',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIP wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                hintText: '081234567890',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),

            // Role dropdown
            DropdownButtonFormField<UserRole>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Regional Office dropdown with search
            _RegionalOfficeSearchDropdown(
              selectedRegionalOfficeId: _selectedRegionalOfficeId,
              onChanged: (officeId) {
                setState(() {
                  _selectedRegionalOfficeId = officeId;
                  // Clear branch selection when regional office changes
                  _selectedBranchId = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Branch dropdown with search (filtered by regional office)
            _BranchSearchDropdown(
              selectedBranchId: _selectedBranchId,
              selectedRegionalOfficeId: _selectedRegionalOfficeId,
              onChanged: (branchId) {
                setState(() => _selectedBranchId = branchId);
              },
            ),
            const SizedBox(height: 16),

            // Supervisor dropdown
            _SupervisorDropdown(
              selectedParentId: _selectedParentId,
              onChanged: (parentId) {
                setState(() => _selectedParentId = parentId);
              },
            ),
            const SizedBox(height: 24),

            // Generated password display (only for create mode)
            if (_generatedPassword != null && !isEditMode) ...[
              Card(
                color: colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.key,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Password Sementara',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _generatedPassword!,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'Salin password',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _generatedPassword!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password disalin'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PENTING: Sampaikan password ini kepada pengguna. '
                        'Password ini hanya ditampilkan sekali dan pengguna '
                        'akan diminta mengubahnya saat login pertama.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditMode ? 'Simpan Perubahan' : 'Buat Pengguna'),
            ),

            // Cancel/Close button
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isLoading ? null : () => context.pop(),
              child: Text(
                _generatedPassword != null ? 'Tutup' : 'Batal',
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
      final notifier = ref.read(adminUserNotifierProvider.notifier);

      if (isEditMode && widget.userId != null) {
        // Update existing user
        final dto = UserUpdateDto(
          name: _nameController.text.trim(),
          nip: _nipController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          branchId: _selectedBranchId,
          regionalOfficeId: _selectedRegionalOfficeId,
          parentId: _selectedParentId,
        );

        await notifier.updateUser(widget.userId!, dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengguna berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        // Create new user
        final dto = UserCreateDto(
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          nip: _nipController.text.trim(),
          role: _selectedRole,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          branchId: _selectedBranchId,
          regionalOfficeId: _selectedRegionalOfficeId,
          parentId: _selectedParentId,
        );

        final result = await notifier.createUser(dto);

        if (mounted) {
          setState(() {
            _generatedPassword = result.temporaryPassword;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pengguna ${result.user.name} berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );

          // Scroll to top to show password
          await Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 300),
          );
        }
        return; // Don't set _isLoading = false again, already done above
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
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Branch dropdown widget with search and filtering by regional office
class _BranchSearchDropdown extends ConsumerWidget {
  const _BranchSearchDropdown({
    required this.selectedBranchId,
    required this.selectedRegionalOfficeId,
    required this.onChanged,
  });

  final String? selectedBranchId;
  final String? selectedRegionalOfficeId;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesStreamProvider);

    return branchesAsync.when(
      data: (branches) {
        // Filter branches by regional office if selected
        final filteredBranches = selectedRegionalOfficeId != null
            ? branches
                .where((b) => b.regionalOfficeId == selectedRegionalOfficeId)
                .toList()
            : const <BranchDto>[];

        if (selectedRegionalOfficeId == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pilih Kantor Regional terlebih dahulu',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }

        final items = filteredBranches
            .map((branch) => DropdownItem<String>(
                  value: branch.id,
                  label: branch.name,
                ))
            .toList();

        return SearchableDropdown<String>(
          label: 'Cabang (Branch)',
          hint: 'Pilih cabang...',
          value: selectedBranchId,
          items: items,
          onChanged: onChanged,
          prefixIcon: Icons.business,
          modalTitle: 'Pilih Cabang',
        );
      },
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Cabang (Branch)',
          prefixIcon: Icon(Icons.business),
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Cabang (Branch)',
          prefixIcon: Icon(Icons.business),
          border: OutlineInputBorder(),
          errorText: 'Gagal memuat cabang',
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

/// Regional Office dropdown widget with search
class _RegionalOfficeSearchDropdown extends ConsumerWidget {
  const _RegionalOfficeSearchDropdown({
    required this.selectedRegionalOfficeId,
    required this.onChanged,
  });

  final String? selectedRegionalOfficeId;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officesAsync = ref.watch(regionalOfficesStreamProvider);

    return officesAsync.when(
      data: (offices) {
        final items = offices
            .map((office) => DropdownItem<String>(
                  value: office.id,
                  label: office.name,
                  subtitle: office.code,
                ))
            .toList();

        return SearchableDropdown<String>(
          label: 'Kantor Regional (Cabang)',
          hint: 'Pilih kantor regional...',
          value: selectedRegionalOfficeId,
          items: items,
          onChanged: onChanged,
          prefixIcon: Icons.location_city,
          modalTitle: 'Pilih Kantor Regional',
        );
      },
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Kantor Regional (Cabang)',
          prefixIcon: Icon(Icons.location_city),
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Kantor Regional (Cabang)',
          prefixIcon: Icon(Icons.location_city),
          border: OutlineInputBorder(),
          errorText: 'Gagal memuat kantor regional',
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

/// Supervisor dropdown widget
class _SupervisorDropdown extends ConsumerWidget {
  const _SupervisorDropdown({
    required this.selectedParentId,
    required this.onChanged,
  });

  final String? selectedParentId;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      data: (users) {
        // Filter out inactive users and sort by name
        final activeUsers = users.where((u) => u.isActive).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        final items = activeUsers
            .map((user) => DropdownItem<String>(
                  value: user.id,
                  label: user.name,
                  subtitle: user.role.shortName,
                ))
            .toList();

        return SearchableDropdown<String>(
          label: 'Atasan (Supervisor)',
          hint: 'Pilih supervisor...',
          value: selectedParentId,
          items: items,
          onChanged: onChanged,
          prefixIcon: Icons.supervisor_account,
          modalTitle: 'Pilih Atasan',
        );
      },
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Atasan (Supervisor)',
          prefixIcon: Icon(Icons.supervisor_account),
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Atasan (Supervisor)',
          prefixIcon: Icon(Icons.supervisor_account),
          border: OutlineInputBorder(),
          errorText: 'Gagal memuat supervisor',
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
