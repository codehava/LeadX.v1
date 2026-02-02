import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../providers/broker_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/app_search_field.dart';
import '../../widgets/broker/broker_card.dart';
import '../../../domain/entities/broker.dart';

/// Screen displaying list of Brokers with lazy loading.
class BrokerListScreen extends ConsumerStatefulWidget {
  const BrokerListScreen({super.key});

  @override
  ConsumerState<BrokerListScreen> createState() => _BrokerListScreenState();
}

class _BrokerListScreenState extends ConsumerState<BrokerListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when near the bottom (200px threshold)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    final currentLimit = ref.read(brokerLimitProvider);
    final totalCount =
        ref.read(brokerTotalCountProvider(searchKey)).valueOrNull ?? 0;

    // Only load more if there are more items
    if (currentLimit < totalCount) {
      ref.read(brokerLimitProvider.notifier).state += brokerPageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? AppSearchField(
                controller: _searchController,
                hintText: 'Cari Broker...',
                onChanged: _onSearchChanged,
                autofocus: true,
              )
            : const Text('Broker'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _buildBrokerList(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/home/brokers/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Broker'),
            )
          : null,
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        // Reset pagination when closing search
        ref.read(brokerLimitProvider.notifier).state = brokerPageSize;
      }
    });
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && value == _searchController.text) {
        setState(() => _searchQuery = value);
        // Reset to first page on new search
        ref.read(brokerLimitProvider.notifier).state = brokerPageSize;
      }
    });
  }

  Widget _buildBrokerList() {
    // Use single paginated provider for both list and search
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    final brokersAsync = ref.watch(paginatedBrokersProvider(searchKey));
    final totalCount =
        ref.watch(brokerTotalCountProvider(searchKey)).valueOrNull ?? 0;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: brokersAsync.when(
        data: (brokers) {
          if (brokers.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return AppEmptyState(
                icon: Icons.search_off,
                title: 'Tidak Ditemukan',
                subtitle: 'Tidak ada Broker yang cocok dengan "$_searchQuery".',
              );
            }
            return const AppEmptyState(
              icon: Icons.handshake_outlined,
              title: 'Belum Ada Broker',
              subtitle: 'Belum ada broker yang terdaftar.',
            );
          }

          final hasMore = brokers.length < totalCount;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            // Add 1 for loading indicator if there are more items
            itemCount: brokers.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == brokers.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final broker = brokers[index];
              return _BrokerCardWithCount(
                broker: broker,
                onTap: () => context.push('/home/brokers/${broker.id}'),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => AppErrorState(
          title: 'Gagal memuat data Broker',
          onRetry: _handleRefresh,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Reset pagination to first page
    ref.read(brokerLimitProvider.notifier).state = brokerPageSize;
    // Invalidate count provider to refresh total
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    ref.invalidate(brokerTotalCountProvider(searchKey));
    // Wait a bit for the stream to refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Helper widget that fetches pipeline count for each Broker card.
class _BrokerCardWithCount extends ConsumerWidget {
  const _BrokerCardWithCount({
    required this.broker,
    this.onTap,
  });

  final Broker broker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(brokerPipelineCountProvider(broker.id));

    return BrokerCard(
      broker: broker,
      pipelineCount: countAsync.valueOrNull ?? 0,
      onTap: onTap,
    );
  }
}
