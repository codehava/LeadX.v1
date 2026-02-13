import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/cadence.dart';
import '../../providers/cadence_providers.dart';
import 'widgets/meeting_card.dart';

/// Dashboard screen for hosts to manage their cadence meetings.
class HostDashboardScreen extends ConsumerStatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  ConsumerState<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends ConsumerState<HostDashboardScreen> {
  @override
  void initState() {
    super.initState();
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
      ref.invalidate(hostedMeetingsProvider);
      ref.invalidate(myFacilitatorConfigProvider);
    } catch (e) {
      AppLogger.instance.warning('cadence | HostDashboard sync error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hostedMeetingsAsync = ref.watch(hostedMeetingsProvider);
    final configAsync = ref.watch(myFacilitatorConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _syncCadenceData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(hostedMeetingsProvider);
          ref.invalidate(myFacilitatorConfigProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Config info card
            configAsync.when(
              data: (config) {
                if (config == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No cadence schedule configured',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Contact admin to set up your cadence schedule',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _buildConfigCard(context, config);
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading config: $error'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Upcoming meetings
            Text(
              'Upcoming Meetings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            hostedMeetingsAsync.when(
              data: (meetings) {
                final upcoming = meetings
                    .where((m) =>
                        m.status == MeetingStatus.scheduled ||
                        m.status == MeetingStatus.inProgress)
                    .toList();

                if (upcoming.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No upcoming meetings',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: upcoming.map((meeting) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MeetingCard(
                        meeting: meeting,
                        showFormStatus: true,
                        onTap: () => context.push('/home/cadence/${meeting.id}'),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $error'),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section: Recent completed meetings
            Text(
              'Recent Completed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            hostedMeetingsAsync.when(
              data: (meetings) {
                final completed = meetings
                    .where((m) => m.status == MeetingStatus.completed)
                    .take(5)
                    .toList();

                if (completed.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No completed meetings yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: completed.map((meeting) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MeetingCard(
                        meeting: meeting,
                        showFeedback: true,
                        onTap: () => context.push('/home/cadence/${meeting.id}'),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ensureUpcomingMeetings(context, ref),
        icon: const Icon(Icons.auto_fix_high),
        label: const Text('Generate Meetings'),
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context, CadenceScheduleConfig config) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Cadence Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildConfigRow(context, 'Name', config.name),
            _buildConfigRow(context, 'Target Role', config.targetRole),
            _buildConfigRow(context, 'Frequency', config.frequencyText),
            if (config.dayOfWeekName != null)
              _buildConfigRow(context, 'Day', config.dayOfWeekName!),
            if (config.dayOfMonth != null)
              _buildConfigRow(context, 'Day of Month', '${config.dayOfMonth}'),
            _buildConfigRow(context, 'Duration', '${config.durationMinutes} min'),
            _buildConfigRow(
              context,
              'Form Deadline',
              '${config.preMeetingHours}h before',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureUpcomingMeetings(BuildContext context, WidgetRef ref) async {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      const SnackBar(content: Text('Generating meetings...')),
    );

    final result = await ref
        .read(cadenceRepositoryProvider)
        .ensureUpcomingMeetings(weeksAhead: 4);

    switch (result) {
      case Success(:final value):
        scaffold.hideCurrentSnackBar();
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              value.isEmpty
                  ? 'All meetings already exist'
                  : '${value.length} meeting(s) generated',
            ),
          ),
        );
        ref.invalidate(hostedMeetingsProvider);
      case ResultFailure(:final failure):
        scaffold.hideCurrentSnackBar();
        scaffold.showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
    }
  }
}
