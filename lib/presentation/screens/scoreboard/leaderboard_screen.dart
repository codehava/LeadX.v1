import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/scoring_entities.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/scoreboard_providers.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/scoreboard/leaderboard_card.dart';
import '../../widgets/scoreboard/period_selector.dart';

/// Dedicated full-page leaderboard screen with filtering and search.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(leaderboardFilterNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final periodsAsync = ref.watch(scoringPeriodsProvider);
    final currentPeriodsAsync = ref.watch(allCurrentPeriodsProvider);
    final currentPeriods = currentPeriodsAsync.valueOrNull ?? [];

    // Resolve effective period: null (Periode Aktif) → use display period
    final selectedPeriod = filterState.selectedPeriod;
    final currentPeriodAsync = ref.watch(currentPeriodProvider);
    final effectivePeriodId =
        selectedPeriod?.id ?? currentPeriodAsync.valueOrNull?.id;

    final leaderboardAsync = effectivePeriodId != null
        ? ref.watch(filteredLeaderboardProvider(
            effectivePeriodId,
            branchId: filterState.selectedBranchId,
            regionalOfficeId: filterState.selectedRegionalOfficeId,
            searchQuery: filterState.searchQuery.isNotEmpty
                ? filterState.searchQuery
                : null,
            role: filterState.selectedRole,
          ))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : const Text('Team Leaderboard'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          _buildPeriodSelector(periodsAsync, filterState, currentPeriods),

          // Filter chips (All / My Branch / My Region)
          _buildFilterChips(filterState, currentUser),

          // Role filter chips
          if (!_isSearching) _buildRoleFilterChips(filterState),

          // Team Summary (for BH/BM/ROH/Admin)
          if (currentUser != null && _shouldShowTeamSummary(currentUser))
            _buildTeamSummary(filterState, currentUser, effectivePeriodId),

          // Divider
          const Divider(height: 1),

          // Leaderboard list
          Expanded(
            child: _buildLeaderboardList(leaderboardAsync, currentUser),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search by name...',
        border: InputBorder.none,
      ),
      style: Theme.of(context).textTheme.titleLarge,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildPeriodSelector(
    AsyncValue<List<ScoringPeriod>> periodsAsync,
    LeaderboardFilter filterState,
    List<ScoringPeriod> currentPeriods,
  ) {
    return periodsAsync.when(
      data: (periods) {
        if (periods.isEmpty) return const SizedBox();

        return Card(
          margin: const EdgeInsets.all(16),
          child: PeriodSelector(
            selectedPeriod: filterState.selectedPeriod,
            allPeriods: periods,
            currentPeriods: currentPeriods,
            onChanged: (period) {
              if (period == null) {
                ref
                    .read(leaderboardFilterNotifierProvider.notifier)
                    .selectActivePeriods();
              } else {
                ref
                    .read(leaderboardFilterNotifierProvider.notifier)
                    .selectPeriod(period);
              }
            },
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChips(LeaderboardFilter filterState, User? currentUser) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All Company'),
              selected: filterState.filterMode == LeaderboardFilterMode.all,
              onSelected: (_) {
                ref
                    .read(leaderboardFilterNotifierProvider.notifier)
                    .setFilterMode(LeaderboardFilterMode.all);
              },
              selectedColor: theme.colorScheme.primaryContainer,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('My Branch'),
              selected: filterState.filterMode == LeaderboardFilterMode.branch,
              onSelected: (_) {
                ref
                    .read(leaderboardFilterNotifierProvider.notifier)
                    .setFilterMode(LeaderboardFilterMode.branch);
              },
              selectedColor: theme.colorScheme.primaryContainer,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('My Region'),
              selected: filterState.filterMode == LeaderboardFilterMode.region,
              onSelected: (_) {
                ref
                    .read(leaderboardFilterNotifierProvider.notifier)
                    .setFilterMode(LeaderboardFilterMode.region);
              },
              selectedColor: theme.colorScheme.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterChips(LeaderboardFilter filterState) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Semua Jabatan'),
              selected: filterState.selectedRole == null,
              onSelected: (_) {
                ref
                    .read(leaderboardFilterNotifierProvider.notifier)
                    .setRole(null);
              },
              selectedColor: theme.colorScheme.secondaryContainer,
            ),
            const SizedBox(width: 8),
            for (final role in ['RM', 'BH', 'BM', 'ROH'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(role),
                  selected: filterState.selectedRole == role,
                  onSelected: (_) {
                    ref
                        .read(leaderboardFilterNotifierProvider.notifier)
                        .setRole(role);
                  },
                  selectedColor: theme.colorScheme.secondaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    AsyncValue<List<LeaderboardEntry>>? leaderboardAsync,
    User? currentUser,
  ) {
    if (leaderboardAsync == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No leaderboard data available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting a different period or filter',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(filteredLeaderboardProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LeaderboardCard(
                  entry: entry,
                  isCurrentUser: entry.userId == currentUser?.id,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppErrorState.general(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(filteredLeaderboardProvider);
        },
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref
            .read(leaderboardFilterNotifierProvider.notifier)
            .setSearchQuery('');
      }
    });
  }

  void _onSearchChanged(String value) {
    // Debounce search
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(leaderboardFilterNotifierProvider.notifier)
          .setSearchQuery(value);
    });
  }

  /// Check if team summary should be shown for this user.
  bool _shouldShowTeamSummary(User user) {
    // Show for BH, BM, ROH, and Admins
    return user.role == UserRole.bh ||
        user.role == UserRole.bm ||
        user.role == UserRole.roh ||
        user.isAdmin;
  }

  /// Build team summary section.
  Widget _buildTeamSummary(
      LeaderboardFilter filterState, User currentUser, String? effectivePeriodId) {
    if (effectivePeriodId == null) return const SizedBox.shrink();
    final selectedPeriod = filterState.selectedPeriod;

    // Determine which ID to use based on filter mode
    String? branchId;
    String? regionalOfficeId;
    if (filterState.filterMode == LeaderboardFilterMode.branch) {
      branchId = currentUser.branchId;
    } else if (filterState.filterMode == LeaderboardFilterMode.region) {
      regionalOfficeId = currentUser.regionalOfficeId;
    }

    final teamSummaryAsync = ref.watch(teamSummaryProvider(
      effectivePeriodId,
      branchId: branchId,
      regionalOfficeId: regionalOfficeId,
    ));

    return teamSummaryAsync.when(
      data: (summary) {
        if (summary == null) return const SizedBox.shrink();

        final theme = Theme.of(context);
        return Card(
          margin: const EdgeInsets.all(16),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Team Summary',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryMetric(
                        theme,
                        'Team Score',
                        '${summary.averageScore.toStringAsFixed(1)}%',
                        Icons.emoji_events,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryMetric(
                        theme,
                        'Members',
                        summary.teamMembersCount.toString(),
                        Icons.people,
                      ),
                    ),
                    if (summary.teamRank != null)
                      Expanded(
                        child: _buildSummaryMetric(
                          theme,
                          'Team Rank',
                          '#${summary.teamRank}',
                          Icons.trending_up,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryMetric(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
