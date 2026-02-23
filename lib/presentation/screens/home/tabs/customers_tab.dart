import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../domain/entities/customer.dart';
import '../../../providers/customer_providers.dart';
import '../../../widgets/cards/customer_card.dart';
import '../../../widgets/common/app_search_field.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_state.dart';
import '../../../widgets/common/loading_indicator.dart';

/// Customers tab showing customer list with search and filter.
/// Uses lazy loading with pagination for better performance.
class CustomersTab extends ConsumerStatefulWidget {
  const CustomersTab({super.key});

  @override
  ConsumerState<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<CustomersTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  bool _showSearchBar = false;

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
    final currentLimit = ref.read(customerLimitProvider);
    final totalCount =
        ref.read(customerTotalCountProvider(searchKey)).valueOrNull ?? 0;

    // Only load more if there are more items
    if (currentLimit < totalCount) {
      ref.read(customerLimitProvider.notifier).state += customerPageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? AppSearchField(
                controller: _searchController,
                hintText: 'Cari customer...',
                autofocus: true,
                onChanged: _onSearchChanged,
                onClear: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : const Text('Customer'),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body: _buildCustomerList(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customers_tab_fab',
        onPressed: () => context.push(RoutePaths.customerCreate),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerList() {
    // Use single paginated provider for both list and search
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    final customersAsync = ref.watch(paginatedCustomersProvider(searchKey));
    final totalCount =
        ref.watch(customerTotalCountProvider(searchKey)).valueOrNull ?? 0;

    return customersAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          if (_searchQuery.isNotEmpty) {
            return AppEmptyState.noSearchResults();
          }
          return AppEmptyState.noData(
            title: 'Belum ada customer',
            subtitle: 'Tap tombol + untuk menambahkan customer baru',
            actionLabel: 'Tambah Customer',
            onAction: () => context.push(RoutePaths.customerCreate),
          );
        }
        return _buildCustomerListView(customers, totalCount);
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, _) => AppErrorState.general(
        message: error.toString(),
        onRetry: _handleRefresh,
      ),
    );
  }

  Widget _buildCustomerListView(List<Customer> customers, int totalCount) {
    final hasMore = customers.length < totalCount;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        // Add 1 for loading indicator if there are more items
        itemCount: customers.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index == customers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final customer = customers[index];
          return CustomerCard(
            customer: customer,
            onTap: () => _navigateToDetail(customer.id),
          );
        },
      ),
    );
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _searchQuery = '';
        // Reset pagination when closing search
        ref.read(customerLimitProvider.notifier).state = customerPageSize;
      }
    });
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && value == _searchController.text) {
        setState(() => _searchQuery = value);
        // Reset to first page on new search
        ref.read(customerLimitProvider.notifier).state = customerPageSize;
      }
    });
  }

  void _navigateToDetail(String id) {
    context.push('/home/customers/$id');
  }

  Future<void> _handleRefresh() async {
    // Reset pagination to first page
    ref.read(customerLimitProvider.notifier).state = customerPageSize;
    // Invalidate count provider to refresh total
    final searchKey = _searchQuery.isEmpty ? null : _searchQuery;
    ref.invalidate(customerTotalCountProvider(searchKey));
    // Wait a bit for the stream to refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
