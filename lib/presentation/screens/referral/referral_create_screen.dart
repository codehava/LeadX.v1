import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/dtos/pipeline_referral_dtos.dart';
import '../../../domain/entities/pipeline_referral.dart';
import '../../providers/admin_user_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/pipeline_referral_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/referral/referral_status_badge.dart';

/// Screen for creating a new pipeline referral.
/// Note: This is an online-only operation - requires network to search receiver RM.
class ReferralCreateScreen extends ConsumerStatefulWidget {
  const ReferralCreateScreen({super.key});

  @override
  ConsumerState<ReferralCreateScreen> createState() =>
      _ReferralCreateScreenState();
}

class _ReferralCreateScreenState extends ConsumerState<ReferralCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedReceiverId;
  ApproverInfo? _approverInfo;
  bool _isLoadingApprover = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Referral'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Referral akan mentransfer nasabah beserta seluruh pipeline-nya ke RM tujuan setelah disetujui manager.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Network requirement warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.tertiaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      size: 18,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Membutuhkan koneksi internet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Customer Selection
              Text(
                'Nasabah *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomerPicker(),

              const SizedBox(height: 16),

              // Receiver RM Selection
              Text(
                'RM Tujuan *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildReceiverPicker(),

              // Approver Info
              if (_isLoadingApprover) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mencari approver...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ] else if (_approverInfo != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Approver',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _approverInfo!.approverName ?? 'Unknown',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ApproverTypeBadge(
                        approverType: _approverInfo!.approverType,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Reason
              AppTextField(
                controller: _reasonController,
                label: 'Alasan Referral *',
                hint: 'Jelaskan alasan referral nasabah ini',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alasan harus diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Notes (optional)
              AppTextField(
                controller: _notesController,
                label: 'Catatan (opsional)',
                hint: 'Catatan tambahan untuk penerima',
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              // Submit Button
              AppButton(
                label: 'Buat Referral',
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerPicker() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final customersAsync = ref.watch(customerListStreamProvider);

    return customersAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Belum ada nasabah. Silakan sinkronisasi data terlebih dahulu.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return DropdownButtonFormField<String>(
          value: _selectedCustomerId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Pilih nasabah',
          ),
          items: customers.map((customer) {
            return DropdownMenuItem(
              value: customer.id,
              child: Text(
                customer.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCustomerId = value;
            });
          },
          validator: (value) {
            if (value == null) return 'Pilih nasabah';
            return null;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Error loading customers: $error',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildReceiverPicker() {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      data: (users) {
        // Filter to only show field users (RM, SH, BM, etc.) - exclude admins
        final fieldUsers = users.where((u) => !u.isAdmin).toList();

        return DropdownButtonFormField<String>(
          value: _selectedReceiverId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Pilih RM tujuan',
          ),
          items: fieldUsers.map((user) {
            return DropdownMenuItem<String>(
              value: user.id,
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) async {
            setState(() {
              _selectedReceiverId = value;
              _isLoadingApprover = true;
              _approverInfo = null;
            });

            // Fetch approver info
            if (value != null) {
              final repository = ref.read(pipelineReferralRepositoryProvider);
              final approver = await repository.findApproverForUser(value);
              if (mounted) {
                setState(() {
                  _approverInfo = approver;
                  _isLoadingApprover = false;
                });
              }
            }
          },
          validator: (value) {
            if (value == null) return 'Pilih RM tujuan';
            return null;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Error loading users'),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_approverInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat menemukan approver untuk RM tujuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(referralActionNotifierProvider.notifier);
      final dto = PipelineReferralCreateDto(
        customerId: _selectedCustomerId!,
        receiverRmId: _selectedReceiverId!,
        reason: _reasonController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final success = await notifier.createReferral(dto);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Referral berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else {
          final state = ref.read(referralActionNotifierProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Gagal membuat referral'),
              backgroundColor: Colors.red,
            ),
          );
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
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
