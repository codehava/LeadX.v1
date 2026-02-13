import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/app_logger.dart';
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
  int _lastTabCount = 0;
  bool _isRefreshing = false;
  int _refreshKey = 0; // Incremented to force widget rebuild on web

  @override
  void initState() {
    super.initState();
    // Tab controller will be created/updated in build based on user state
  }

  int _calculateTabCount(bool isManager, bool isAdmin) {
    int count = 2; // Inbound + Outbound
    if (isManager) count++; // Approval tab
    if (isAdmin) count++; // All tab
    return count;
  }

  void _ensureTabController(int tabCount) {
    // Recreate tab controller if count changed
    if (_tabController == null || _lastTabCount != tabCount) {
      _tabController?.dispose();
      _lastTabCount = tabCount;
      _tabController = TabController(
        length: tabCount,
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
    final isAdmin = currentUser?.isAdmin ?? false;

    // Ensure tab controller matches current user state
    final tabCount = _calculateTabCount(isManager, isAdmin);
    _ensureTabController(tabCount);

    // Ensure tab controller is initialized
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral'),
        actions: [
          // Refresh button for web (pull-to-refresh doesn't work on web)
          if (kIsWeb)
            _isRefreshing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () async {
                      setState(() => _isRefreshing = true);
                      try {
                        await _syncReferrals();
                        // Small delay to ensure DB writes are committed (web/WASM timing)
                        await Future.delayed(const Duration(milliseconds: 100));
                        // Invalidate providers to force re-subscription to streams
                        ref.invalidate(inboundReferralsProvider);
                        ref.invalidate(outboundReferralsProvider);
                        if (isManager) {
                          ref.invalidate(pendingApprovalsProvider);
                        }
                        if (isAdmin) {
                          ref.invalidate(allReferralsProvider);
                        }
                        // Increment key to force widget rebuild (web workaround)
                        _refreshKey++;
                      } finally {
                        if (mounted) {
                          setState(() => _isRefreshing = false);
                        }
                      }
                    },
                  ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isManager || isAdmin, // Allow scrolling if 3+ tabs
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
            // All tab for admins only
            if (isAdmin)
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings, size: 18),
                    SizedBox(width: 8),
                    Text('Semua'),
                  ],
                ),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeyedSubtree(
            key: ValueKey('inbound_$_refreshKey'),
            child: _buildInboundTab(currentUser?.id),
          ),
          KeyedSubtree(
            key: ValueKey('outbound_$_refreshKey'),
            child: _buildOutboundTab(currentUser?.id),
          ),
          // Approval tab content for managers
          if (isManager)
            KeyedSubtree(
              key: ValueKey('approval_$_refreshKey'),
              child: _buildApprovalTab(currentUser?.id),
            ),
          // All referrals tab content for admins
          if (isAdmin)
            KeyedSubtree(
              key: ValueKey('all_$_refreshKey'),
              child: _buildAllTab(currentUser?.id),
            ),
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

  Future<void> _syncReferrals() async {
    try {
      final repository = ref.read(pipelineReferralRepositoryProvider);
      await repository.syncFromRemote();
    } catch (e) {
      AppLogger.instance.warning('ui.referral | Sync error: $e');
    }
  }

  Widget _buildInboundTab(String? userId) {
    final inboundAsync = ref.watch(inboundReferralsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await _syncReferrals();
        await Future.delayed(const Duration(milliseconds: 100));
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
        await _syncReferrals();
        await Future.delayed(const Duration(milliseconds: 100));
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
        await _syncReferrals();
        await Future.delayed(const Duration(milliseconds: 100));
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

  Widget _buildAllTab(String? userId) {
    final allAsync = ref.watch(allReferralsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await _syncReferrals();
        await Future.delayed(const Duration(milliseconds: 100));
        ref.invalidate(allReferralsProvider);
      },
      child: allAsync.when(
        data: (referrals) {
          if (referrals.isEmpty) {
            return const AppEmptyState(
              icon: Icons.folder_open_outlined,
              title: 'Tidak Ada Referral',
              subtitle: 'Belum ada referral yang dibuat.',
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
          onRetry: () => ref.invalidate(allReferralsProvider),
        ),
      ),
    );
  }
}
