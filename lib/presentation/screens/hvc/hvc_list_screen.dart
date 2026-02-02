import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../providers/hvc_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/app_search_field.dart';
import '../../widgets/hvc/hvc_card.dart';
import '../../../domain/entities/hvc.dart';

/// Screen displaying list of HVCs with lazy loading.
class HvcListScreen extends ConsumerStatefulWidget {
  const HvcListScreen({super.key});

  @override
  ConsumerState<HvcListScreen> createState() => _HvcListScreenState();
}

class _HvcListScreenState extends ConsumerState<HvcListScreen> {
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
    final currentLimit = ref.read(hvcLimitProvider);
    final totalCount =
        ref.read(hvcTotalCountProvider(searchKey)).valueOrNull ?? 0;

    // Only load more if there are more items
    if (currentLimit < totalCount) {
      ref.read(hvcLimitProvider.notifier).state += hvcPageSize;
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
                hintText: 'Cari HVC...',
                onChanged: _onSearchChanged,
                autofocus: true,
              )
            : const Text('HVC'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _buildHvcList(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/home/hvcs/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah HVC'),
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
        ref.read(hvcLimitProvider.notifier).state = hvcPageSize;
      }
    });
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && value == _searchController.text) {
        setState(() => _searchQuery = value);
        // Reset to first page on new search
        ref.read(hvcLimitProvider.notifier).state = hvcPageSize;
      }
    });
  }

  Widget _buildHvcList() {
    // Use single paginated provider for both list and search
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    final hvcsAsync = ref.watch(paginatedHvcsProvider(searchKey));
    final totalCount =
        ref.watch(hvcTotalCountProvider(searchKey)).valueOrNull ?? 0;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: hvcsAsync.when(
        data: (hvcs) {
          if (hvcs.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return AppEmptyState(
                icon: Icons.search_off,
                title: 'Tidak Ditemukan',
                subtitle: 'Tidak ada HVC yang cocok dengan "$_searchQuery".',
              );
            }
            return const AppEmptyState(
              icon: Icons.business_outlined,
              title: 'Belum Ada HVC',
              subtitle: 'Belum ada High Value Customer yang terdaftar.',
            );
          }

          final hasMore = hvcs.length < totalCount;

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            // Add 1 for loading indicator if there are more items
            itemCount: hvcs.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == hvcs.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final hvc = hvcs[index];
              return _HvcCardWithCount(
                hvc: hvc,
                onTap: () => context.push('/home/hvcs/${hvc.id}'),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => AppErrorState(
          title: 'Gagal memuat data HVC',
          onRetry: _handleRefresh,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Reset pagination to first page
    ref.read(hvcLimitProvider.notifier).state = hvcPageSize;
    // Invalidate count provider to refresh total
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    ref.invalidate(hvcTotalCountProvider(searchKey));
    // Wait a bit for the stream to refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Helper widget that fetches linked customer count for each HVC card.
class _HvcCardWithCount extends ConsumerWidget {
  const _HvcCardWithCount({
    required this.hvc,
    this.onTap,
  });

  final Hvc hvc;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(linkedCustomerCountProvider(hvc.id));

    return HvcCard(
      hvc: hvc,
      linkedCustomerCount: countAsync.valueOrNull ?? 0,
      onTap: onTap,
    );
  }
}
