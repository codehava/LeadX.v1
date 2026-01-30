import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../providers/cadence_providers.dart';
import 'widgets/meeting_card.dart';

/// Main cadence screen showing upcoming and past meetings for the current user.
/// Shows different views based on whether user is a participant or host.
class CadenceListScreen extends ConsumerStatefulWidget {
  const CadenceListScreen({super.key});

  @override
  ConsumerState<CadenceListScreen> createState() => _CadenceListScreenState();
}

class _CadenceListScreenState extends ConsumerState<CadenceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Auto-sync cadence data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCadenceData();
    });
  }

  /// Sync cadence data from remote.
  Future<void> _syncCadenceData() async {
    try {
      await ref.read(cadenceRepositoryProvider).syncFromRemote();
      // Refresh providers after sync
      ref.invalidate(upcomingMeetingsProvider);
      ref.invalidate(pastMeetingsProvider);
    } catch (e) {
      debugPrint('[CadenceListScreen] Sync error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final canHost = currentUser?.canManageSubordinates ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadence'),
        actions: [
          if (canHost)
            IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'Host Dashboard',
              onPressed: () => context.push('/home/cadence/host'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _syncCadenceData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UpcomingMeetingsTab(),
          _PastMeetingsTab(),
        ],
      ),
    );
  }
}

class _UpcomingMeetingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingMeetingsProvider);

    return upcomingAsync.when(
      data: (meetings) {
        if (meetings.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.event_available,
            title: 'No upcoming meetings',
            subtitle: 'Your cadence meetings will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingMeetingsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MeetingCard(
                  meeting: meeting,
                  showFormStatus: true,
                  onTap: () => context.push('/home/cadence/${meeting.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(context, ref, error),
    );
  }
}

class _PastMeetingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastAsync = ref.watch(pastMeetingsProvider);

    return pastAsync.when(
      data: (meetings) {
        if (meetings.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.history,
            title: 'No past meetings',
            subtitle: 'Your completed meetings will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pastMeetingsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MeetingCard(
                  meeting: meeting,
                  showFeedback: true,
                  onTap: () => context.push('/home/cadence/${meeting.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(context, ref, error),
    );
  }
}

Widget _buildEmptyState(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  final theme = Theme.of(context);
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
  final theme = Theme.of(context);
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading meetings',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref.invalidate(upcomingMeetingsProvider);
              ref.invalidate(pastMeetingsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
