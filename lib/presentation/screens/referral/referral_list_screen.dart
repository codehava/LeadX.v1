import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../providers/pipeline_referral_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/referral/referral_card.dart';

/// Screen displaying list of pipeline referrals.
/// Has tabs for incoming (received), outgoing (sent), and pending approvals (managers).
class ReferralListScreen extends ConsumerStatefulWidget {
  const ReferralListScreen({super.key});

  @override
  ConsumerState<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends ConsumerState<ReferralListScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    // Tab controller will be initialized in didChangeDependencies after we know if user is manager
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user is a manager to determine tab count
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final isManager = currentUser?.canManageSubordinates ?? false;

    // Only rebuild tab controller if manager status changed or not initialized
    if (_tabController == null || _isManager != isManager) {
      _tabController?.dispose();
      _isManager = isManager;
      _tabController = TabController(
        length: isManager ? 3 : 2,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final pendingInboundCount = ref.watch(pendingInboundCountProvider);
    final pendingApprovalCount = ref.watch(pendingApprovalCountProvider);
    final isManager = currentUser?.canManageSubordinates ?? false;

    // Ensure tab controller is initialized
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isManager, // Allow scrolling if 3 tabs
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call_received, size: 18),
                  const SizedBox(width: 8),
                  const Text('Diterima'),
                  if (pendingInboundCount > 0) ...[
                    const SizedBox(width: 8),
                    _buildBadge(pendingInboundCount),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_made, size: 18),
                  SizedBox(width: 8),
                  Text('Dikirim'),
                ],
              ),
            ),
            // Approval tab for managers only
            if (isManager)
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.approval, size: 18),
                    const SizedBox(width: 8),
                    const Text('Approval'),
                    if (pendingApprovalCount > 0) ...[
                      const SizedBox(width: 8),
                      _buildBadge(pendingApprovalCount),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInboundTab(currentUser?.id),
          _buildOutboundTab(currentUser?.id),
          // Approval tab content for managers
          if (isManager) _buildApprovalTab(currentUser?.id),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/home/referrals/new'),
        icon: const Icon(Icons.add),
        label: const Text('Buat Referral'),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInboundTab(String? userId) {
    final inboundAsync = ref.watch(inboundReferralsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(inboundReferralsProvider);
      },
      child: inboundAsync.when(
        data: (referrals) {
          if (referrals.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Tidak Ada Referral Masuk',
              subtitle: 'Anda belum menerima referral dari RM lain.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: referrals.length,
            itemBuilder: (context, index) {
              final referral = referrals[index];
              return ReferralCard(
                referral: referral,
                currentUserId: userId,
                onTap: () => context.push('/home/referrals/${referral.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(
          title: 'Gagal memuat referral',
          onRetry: () => ref.invalidate(inboundReferralsProvider),
        ),
      ),
    );
  }

  Widget _buildOutboundTab(String? userId) {
    final outboundAsync = ref.watch(outboundReferralsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(outboundReferralsProvider);
      },
      child: outboundAsync.when(
        data: (referrals) {
          if (referrals.isEmpty) {
            return const AppEmptyState(
              icon: Icons.outbox_outlined,
              title: 'Tidak Ada Referral Keluar',
              subtitle: 'Anda belum membuat referral ke RM lain.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: referrals.length,
            itemBuilder: (context, index) {
              final referral = referrals[index];
              return ReferralCard(
                referral: referral,
                currentUserId: userId,
                onTap: () => context.push('/home/referrals/${referral.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(
          title: 'Gagal memuat referral',
          onRetry: () => ref.invalidate(outboundReferralsProvider),
        ),
      ),
    );
  }

  Widget _buildApprovalTab(String? userId) {
    final approvalsAsync = ref.watch(pendingApprovalsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pendingApprovalsProvider);
      },
      child: approvalsAsync.when(
        data: (referrals) {
          if (referrals.isEmpty) {
            return const AppEmptyState(
              icon: Icons.check_circle_outline,
              title: 'Tidak Ada Approval Pending',
              subtitle: 'Tidak ada referral yang membutuhkan approval Anda.',
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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(
          title: 'Gagal memuat approval',
          onRetry: () => ref.invalidate(pendingApprovalsProvider),
        ),
      ),
    );
  }
}
