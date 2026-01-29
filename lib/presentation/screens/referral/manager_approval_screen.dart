import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/pipeline_referral.dart';
import '../../providers/auth_providers.dart';
import '../../providers/pipeline_referral_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/referral/referral_card.dart';

/// Screen for managers (BM/ROH) to review and approve referrals.
class ManagerApprovalScreen extends ConsumerWidget {
  const ManagerApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingApprovalsAsync = ref.watch(pendingApprovalsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Referral'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingApprovalsProvider);
        },
        child: pendingApprovalsAsync.when(
          data: (referrals) {
            if (referrals.isEmpty) {
              return const AppEmptyState(
                icon: Icons.approval_outlined,
                title: 'Tidak Ada Referral',
                subtitle:
                    'Tidak ada referral yang membutuhkan persetujuan Anda.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: referrals.length,
              itemBuilder: (context, index) {
                final referral = referrals[index];
                return ReferralApprovalCard(
                  referral: referral,
                  onTap: () => context.push('/home/referrals/${referral.id}'),
                  onApprove: () =>
                      _showApproveDialog(context, ref, referral, currentUser?.id),
                  onReject: () =>
                      _showRejectDialog(context, ref, referral, currentUser?.id),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorState(
            title: 'Gagal memuat referral',
            onRetry: () => ref.invalidate(pendingApprovalsProvider),
          ),
        ),
      ),
    );
  }

  void _showApproveDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
    String? approverId,
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
              'Anda akan menyetujui referral nasabah "${referral.customerName}" '
              'dari ${referral.referrerRmName} ke ${referral.receiverRmName}.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nasabah dan semua pipeline-nya akan ditransfer ke ${referral.receiverRmName}.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800,
                          ),
                    ),
                  ),
                ],
              ),
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
              if (approverId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: User tidak terautentikasi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.approveReferral(
                referral.id,
                notes:
                    notesController.text.isEmpty ? null : notesController.text,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil disetujui'
                          : 'Gagal menyetujui referral',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  ref.invalidate(pendingApprovalsProvider);
                }
              }
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    PipelineReferral referral,
    String? approverId,
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

              if (approverId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: User tidak terautentikasi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final notifier = ref.read(referralActionNotifierProvider.notifier);
              final success = await notifier.rejectAsManager(
                referral.id,
                reasonController.text,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Referral berhasil ditolak'
                          : 'Gagal menolak referral',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
                if (success) {
                  ref.invalidate(pendingApprovalsProvider);
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
}
