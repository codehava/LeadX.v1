import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/dtos/admin/user_management_dtos.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/admin_user_providers.dart';

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
    // For edit mode, we'd fetch the user data here
    // For now, we'll implement create mode fully
    // TODO: Implement edit mode data loading
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!value.contains('@')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
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

            // Branch placeholder (TODO: Implement branch dropdown)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cabang',
                hintText: 'Pilih cabang...',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
                enabled: false,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Fitur pemilihan cabang akan segera tersedia',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Supervisor placeholder (TODO: Implement supervisor dropdown)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Atasan/Supervisor',
                hintText: 'Pilih supervisor...',
                prefixIcon: Icon(Icons.supervisor_account),
                border: OutlineInputBorder(),
                enabled: false,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Fitur pemilihan supervisor akan segera tersedia',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Generated password display
            if (_generatedPassword != null) ...[
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

            // Cancel button (only show if password not generated yet)
            if (_generatedPassword == null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isLoading ? null : () => context.pop(),
                child: const Text('Batal'),
              ),
            ],

            // Close button (show after user created)
            if (_generatedPassword != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Tutup'),
              ),
            ],
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
      if (isEditMode) {
        // TODO: Implement edit mode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit mode belum diimplementasikan'),
            backgroundColor: Colors.orange,
          ),
        );
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
        );

        final notifier = ref.read(adminUserNotifierProvider.notifier);
        final result = await notifier.createUser(dto);

        if (result != null) {
          setState(() {
            _generatedPassword = result.temporaryPassword;
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Pengguna ${result.user.name} berhasil dibuat'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Scroll to top to show password
          await Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 300),
          );
        } else {
          // Error handled by notifier, show error from state
          final errorState = ref.read(adminUserNotifierProvider);
          final errorMessage = errorState.maybeWhen(
            error: (error, _) => error.toString(),
            orElse: () => 'Terjadi kesalahan',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
        }
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
      setState(() => _isLoading = false);
    }
  }
}
