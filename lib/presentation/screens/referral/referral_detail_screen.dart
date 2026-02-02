import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/pipeline_referral.dart';
import '../../providers/auth_providers.dart';
import '../../providers/pipeline_referral_providers.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/referral/referral_status_badge.dart';

/// Detail screen for viewing and acting on a pipeline referral.
class ReferralDetailScreen extends ConsumerWidget {
  const ReferralDetailScreen({
    super.key,
    required this.referralId,
  });

  final String referralId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralDetailProvider(referralId));
    final theme = Theme.of(context);

    return referralAsync.when(
      data: (referral) {
        if (referral == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Referral')),
            body: const Center(child: Text('Referral tidak ditemukan')),
          );
        }
        return _buildContent(context, ref, referral, theme);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Referral')),
        body: const Center(child: AppLoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Referral')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
    ThemeData theme,
  ) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final colorScheme = theme.colorScheme;

    final isReferrer = currentUser != null && referral.isReferrer(currentUser.id);
    final isReceiver = currentUser != null && referral.isReceiver(currentUser.id);
    final isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(referral.code),
        actions: [
          // Cancel action for referrer (admin can also cancel)
          if ((isReferrer || isAdmin) && referral.canBeCancelled)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              tooltip: 'Batalkan Referral',
              onPressed: () => _showCancelDialog(context, ref, referral),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(referral, theme),

            const SizedBox(height: 24),

            // Customer Info
            _InfoSection(
              title: 'Informasi Nasabah',
              children: [
                _InfoRow(label: 'Nama', value: referral.customerName ?? '-'),
              ],
            ),

            const SizedBox(height: 24),

            // Transfer Info
            _InfoSection(
              title: 'Informasi Transfer',
              children: [
                _InfoRow(
                  label: 'Dari (Referrer)',
                  value: referral.referrerRmName ?? '-',
                ),
                if (referral.referrerBranchName != null)
                  _InfoRow(
                    label: 'Cabang Asal',
                    value: referral.referrerBranchName!,
                  ),
                _InfoRow(
                  label: 'Kepada (Receiver)',
                  value: referral.receiverRmName ?? '-',
                ),
                if (referral.receiverBranchName != null)
                  _InfoRow(
                    label: 'Cabang Tujuan',
                    value: referral.receiverBranchName!,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Approver Info
            _InfoSection(
              title: 'Informasi Approval',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tipe Approver',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ApproverTypeBadge(
                      approverType: referral.approverType,
                      approverName: referral.approverName,
                    ),
                  ],
                ),
                if (referral.bmApprovedBy != null)
                  _InfoRow(
                    label: 'Disetujui Oleh',
                    value: referral.approverName ?? referral.bmApprovedBy!,
                  ),
                if (referral.bmApprovedAt != null)
                  _InfoRow(
                    label: 'Tanggal Approval',
                    value: _formatDateTime(referral.bmApprovedAt!),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Referral Details
            _InfoSection(
              title: 'Detail Referral',
              children: [
                _InfoRow(label: 'Alasan', value: referral.reason),
                if (referral.notes != null && referral.notes!.isNotEmpty)
                  _InfoRow(label: 'Catatan', value: referral.notes!),
                if (referral.receiverNotes != null &&
                    referral.receiverNotes!.isNotEmpty)
                  _InfoRow(
                    label: 'Catatan Penerima',
                    value: referral.receiverNotes!,
                  ),
                if (referral.bmNotes != null && referral.bmNotes!.isNotEmpty)
                  _InfoRow(label: 'Catatan Approver', value: referral.bmNotes!),
              ],
            ),

            // Rejection/Cancellation Info
            if (referral.receiverRejectReason != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                title: 'Alasan Penolakan (Receiver)',
                titleColor: Colors.red,
                children: [
                  _InfoRow(label: '', value: referral.receiverRejectReason!),
                ],
              ),
            ],

            if (referral.bmRejectReason != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                title: 'Alasan Penolakan (Manager)',
                titleColor: Colors.red,
                children: [
                  _InfoRow(label: '', value: referral.bmRejectReason!),
                ],
              ),
            ],

            if (referral.cancelReason != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                title: 'Alasan Pembatalan',
                titleColor: Colors.grey,
                children: [
                  _InfoRow(label: '', value: referral.cancelReason!),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Timestamps
            _InfoSection(
              title: 'Waktu',
              children: [
                _InfoRow(
                  label: 'Dibuat',
                  value: _formatDateTime(referral.createdAt),
                ),
                _InfoRow(
                  label: 'Terakhir Diupdate',
                  value: _formatDateTime(referral.updatedAt),
                ),
                if (referral.receiverAcceptedAt != null)
                  _InfoRow(
                    label: 'Diterima Receiver',
                    value: _formatDateTime(referral.receiverAcceptedAt!),
                  ),
                if (referral.receiverRejectedAt != null)
                  _InfoRow(
                    label: 'Ditolak Receiver',
                    value: _formatDateTime(referral.receiverRejectedAt!),
                  ),
                if (referral.cancelledAt != null)
                  _InfoRow(
                    label: 'Dibatalkan',
                    value: _formatDateTime(referral.cancelledAt!),
                  ),
              ],
            ),

            // Bottom padding for action buttons
            const SizedBox(height: 100),
          ],
        ),
      ),
      // Action buttons at bottom
      bottomNavigationBar: _buildActionBar(context, ref, referral, isReceiver),
    );
  }

  Widget _buildStatusCard(PipelineReferral referral, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.swap_horiz,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.customerName ?? 'Unknown Customer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  referral.transferDisplay,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ReferralStatusBadge(status: referral.status),
        ],
      ),
    );
  }

  Widget? _buildActionBar(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
    bool isReceiver,
  ) {
    // Show action buttons only for pending items
    if (!referral.status.isActionable) return null;

    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isManager = currentUser?.canManageSubordinates ?? false;
    final isAdmin = currentUser?.isAdmin ?? false;

    // Receiver actions - Accept/Reject referral (admin can also do this)
    if ((isReceiver || isAdmin) && referral.canBeAccepted) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(context, ref, referral),
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showAcceptDialog(context, ref, referral),
                  icon: const Icon(Icons.check),
                  label: const Text('Terima'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Manager actions - Approve/Reject after receiver accepted (admin can also do this)
    if ((isManager || isAdmin) && referral.canBeApproved) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showManagerRejectDialog(context, ref, referral),
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showManagerApproveDialog(context, ref, referral),
                  icon: const Icon(Icons.check),
                  label: const Text('Setujui'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return null;
  }

  void _showAcceptDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
  ) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menerima referral nasabah "${referral.customerName}" '
              'dari ${referral.referrerRmName}.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.acceptReferral(
                referral.id,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              if (context.mounted) {
                final state = ref.read(referralActionNotifierProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil diterima, menunggu approval'
                          : state.errorMessage ?? 'Gagal menerima referral',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  ref.invalidate(referralDetailProvider(referralId));
                }
              }
            },
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menolak referral nasabah "${referral.customerName}" '
              'dari ${referral.referrerRmName}.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.rejectReferral(
                referral.id,
                reasonController.text,
              );
              if (context.mounted) {
                final state = ref.read(referralActionNotifierProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil ditolak'
                          : state.errorMessage ?? 'Gagal menolak referral',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
                if (success && context.mounted) {
                  context.pop();
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan membatalkan referral nasabah "${referral.customerName}" '
              'ke ${referral.receiverRmName}.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan pembatalan harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.cancelReferral(
                referral.id,
                reasonController.text,
              );
              if (context.mounted) {
                final state = ref.read(referralActionNotifierProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil dibatalkan'
                          : state.errorMessage ?? 'Gagal membatalkan referral',
                    ),
                    backgroundColor: success ? Colors.grey : Colors.red,
                  ),
                );
                if (success && context.mounted) {
                  context.pop();
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showManagerApproveDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
  ) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menyetujui transfer nasabah "${referral.customerName}" '
              'dari ${referral.referrerRmName} ke ${referral.receiverRmName}.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.approveReferral(
                referral.id,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              if (context.mounted) {
                final state = ref.read(referralActionNotifierProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil disetujui'
                          : state.errorMessage ?? 'Gagal menyetujui referral',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success && context.mounted) {
                  // Navigate back to referral list
                  context.pop();
                }
              }
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showManagerRejectDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Referral'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menolak transfer nasabah "${referral.customerName}" '
              'dari ${referral.referrerRmName} ke ${referral.receiverRmName}.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.rejectAsManager(
                referral.id,
                reasonController.text,
              );
              if (context.mounted) {
                final state = ref.read(referralActionNotifierProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil ditolak'
                          : state.errorMessage ?? 'Gagal menolak referral',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
                if (success && context.mounted) {
                  // Navigate back to referral list
                  context.pop();
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Section widget for grouping info rows.
class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.children,
    this.titleColor,
  });

  final String title;
  final List<Widget> children;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// Single row of info with label and value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
