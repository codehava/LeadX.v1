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

/// Screen displaying list of HVCs.
class HvcListScreen extends ConsumerStatefulWidget {
  const HvcListScreen({super.key});

  @override
  ConsumerState<HvcListScreen> createState() => _HvcListScreenState();
}

class _HvcListScreenState extends ConsumerState<HvcListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                autofocus: true,
              )
            : const Text('HVC'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: _searchQuery.isNotEmpty
          ? _buildSearchResults()
          : _buildHvcList(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/home/hvcs/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah HVC'),
            )
          : null,
    );
  }

  Widget _buildHvcList() {
    final hvcsAsync = ref.watch(hvcListStreamProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(hvcListStreamProvider);
      },
      child: hvcsAsync.when(
        data: (hvcs) {
          if (hvcs.isEmpty) {
            return const AppEmptyState(
              icon: Icons.business_outlined,
              title: 'Belum Ada HVC',
              subtitle: 'Belum ada High Value Customer yang terdaftar.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: hvcs.length,
            itemBuilder: (context, index) {
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
          onRetry: () => ref.invalidate(hvcListStreamProvider),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(hvcSearchProvider(_searchQuery));

    return searchAsync.when(
      data: (hvcs) {
        if (hvcs.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off,
            title: 'Tidak Ditemukan',
            subtitle: 'Tidak ada HVC yang cocok dengan "$_searchQuery".',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: hvcs.length,
          itemBuilder: (context, index) {
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
        title: 'Gagal mencari HVC',
        onRetry: () => ref.invalidate(hvcSearchProvider(_searchQuery)),
      ),
    );
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
