import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../presentation/providers/admin_providers.dart';
import 'master_data_entity_type.dart';

/// Generic list screen for all master data entity types.
///
/// This screen adapts to display any master data entity type with:
/// - Search functionality
/// - Data table with entity-specific columns
/// - Edit and delete actions per row
/// - Create new entity FAB
class MasterDataListScreen extends ConsumerStatefulWidget {
  final String entityType;

  const MasterDataListScreen({
    required this.entityType,
    super.key,
  });

  @override
  ConsumerState<MasterDataListScreen> createState() =>
      _MasterDataListScreenState();
}

class _MasterDataListScreenState extends ConsumerState<MasterDataListScreen> {
  late MasterDataEntityType _type;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Find entity type from table name
    _type = MasterDataEntityType.values.firstWhere(
      (type) => type.tableName == widget.entityType,
      orElse: () => MasterDataEntityType.companyType,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(adminMasterDataRepositoryProvider);
      final data = await repository.getAllEntities(_type.tableName);
      if (!mounted) return;
      setState(() {
        _allData = data.cast<Map<String, dynamic>>();
        _filteredData = _allData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = _allData;
      } else {
        _filteredData = _allData.where((item) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          final code = item['code']?.toString().toLowerCase() ?? '';
          final searchTerm = query.toLowerCase();
          return name.contains(searchTerm) || code.contains(searchTerm);
        }).toList();
      }
    });
  }

  void _showDeleteConfirmation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
            'Apakah Anda yakin ingin menghapus "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item['id'].toString());
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    try {
      final repository = ref.read(adminMasterDataRepositoryProvider);
      final result = await repository.softDeleteEntity(_type.tableName, id);

      if (!mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dihapus')),
          );
          _loadData();
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_type.displayName),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
              decoration: InputDecoration(
                hintText: 'Cari ${_type.displayName.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredData.isEmpty
                        ? const Center(
                            child: Text('Belum ada data'),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: _buildColumns(),
                                rows: _buildRows(),
                              ),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(null),
        tooltip: 'Tambah ${_type.displayName}',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('Kode')),
      const DataColumn(label: Text('Nama')),
      if (_type == MasterDataEntityType.pipelineStage)
        const DataColumn(label: Text('Probabilitas')),
      const DataColumn(label: Text('Status')),
      const DataColumn(label: Text('Aksi')),
    ];
  }

  List<DataRow> _buildRows() {
    return _filteredData.map((item) {
      return DataRow(
        cells: [
          DataCell(Text(item['code']?.toString() ?? '-')),
          DataCell(Text(item['name']?.toString() ?? '-')),
          if (_type == MasterDataEntityType.pipelineStage)
            DataCell(Text('${item['probability']?.toString() ?? '-'}%')),
          DataCell(
            Chip(
              label: Text((item['is_active'] == true) ? 'Aktif' : 'Tidak Aktif'),
              backgroundColor: (item['is_active'] == true)
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _navigateToForm(item['id'].toString()),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(item),
                  tooltip: 'Hapus',
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  void _navigateToForm(String? id) {
    final queryParams = <String, String>{};
    if (id != null) {
      queryParams['id'] = id;
    }
    context.pushNamed(
      RouteNames.adminMasterDataCreate,
      pathParameters: {
        'entityType': _type.tableName,
      },
      queryParameters: queryParams,
    );
  }
}
