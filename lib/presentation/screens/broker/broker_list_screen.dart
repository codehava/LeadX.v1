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

/// Screen displaying list of Brokers.
class BrokerListScreen extends ConsumerStatefulWidget {
  const BrokerListScreen({super.key});

  @override
  ConsumerState<BrokerListScreen> createState() => _BrokerListScreenState();
}

class _BrokerListScreenState extends ConsumerState<BrokerListScreen> {
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
                hintText: 'Cari Broker...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                autofocus: true,
              )
            : const Text('Broker'),
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
      body: _searchQuery.isNotEmpty ? _buildSearchResults() : _buildBrokerList(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/home/brokers/new'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Broker'),
            )
          : null,
    );
  }

  Widget _buildBrokerList() {
    final brokersAsync = ref.watch(brokerListStreamProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(brokerListStreamProvider);
      },
      child: brokersAsync.when(
        data: (brokers) {
          if (brokers.isEmpty) {
            return const AppEmptyState(
              icon: Icons.handshake_outlined,
              title: 'Belum Ada Broker',
              subtitle: 'Belum ada broker yang terdaftar.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: brokers.length,
            itemBuilder: (context, index) {
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
          onRetry: () => ref.invalidate(brokerListStreamProvider),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(brokerSearchProvider(_searchQuery));

    return searchAsync.when(
      data: (brokers) {
        if (brokers.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off,
            title: 'Tidak Ditemukan',
            subtitle: 'Tidak ada Broker yang cocok dengan "$_searchQuery".',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          itemCount: brokers.length,
          itemBuilder: (context, index) {
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
        title: 'Gagal mencari Broker',
        onRetry: () => ref.invalidate(brokerSearchProvider(_searchQuery)),
      ),
    );
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
