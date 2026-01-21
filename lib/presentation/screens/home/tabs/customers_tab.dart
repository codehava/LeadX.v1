import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../domain/entities/customer.dart';
import '../../../providers/customer_providers.dart';
import '../../../widgets/cards/customer_card.dart';
import '../../../widgets/common/app_search_field.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/loading_indicator.dart';

/// Customers tab showing customer list with search and filter.
class CustomersTab extends ConsumerStatefulWidget {
  const CustomersTab({super.key});

  @override
  ConsumerState<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends ConsumerState<CustomersTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchBar = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(colorScheme),
          // Customer list
          Expanded(
            child: _buildCustomerList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customers_tab_fab',
        onPressed: () => context.push(RoutePaths.customerCreate),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: true,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Aktif'),
            selected: false,
            onSelected: (_) {},
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Belum Sync'),
            selected: false,
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    // Use search provider if searching, otherwise use list stream
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }
    return _buildListStream();
  }

  Widget _buildListStream() {
    final customersAsync = ref.watch(customerListStreamProvider);

    return customersAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return AppEmptyState.noData(
            title: 'Belum ada customer',
            subtitle: 'Tap tombol + untuk menambahkan customer baru',
            actionLabel: 'Tambah Customer',
            onAction: () => context.push(RoutePaths.customerCreate),
          );
        }
        return _buildCustomerListView(customers);
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(customerListStreamProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(customerSearchProvider(_searchQuery));

    return searchAsync.when(
      data: (customers) {
        if (customers.isEmpty) {
          return AppEmptyState.noSearchResults();
        }
        return _buildCustomerListView(customers);
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildCustomerListView(List<Customer> customers) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: customers.length,
        itemBuilder: (context, index) {
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
      }
    });
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && value == _searchController.text) {
        setState(() => _searchQuery = value);
      }
    });
  }

  void _navigateToDetail(String id) {
    context.push('/home/customers/$id');
  }

  Future<void> _handleRefresh() async {
    // Trigger a manual sync
    ref.invalidate(customerListStreamProvider);
    // Wait a bit for the stream to refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
