import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/errors/result.dart';
import '../../../../presentation/providers/admin_providers.dart';
import '../../../widgets/layout/responsive_layout.dart';
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

      // Enrich branch data with regional office names
      if (_type == MasterDataEntityType.branch) {
        final regionalOffices = await repository.getAllEntities('regional_offices');
        final roLookup = Map.fromEntries(
          regionalOffices.map((ro) => MapEntry(ro['id'] as String, ro['name'] as String)),
        );

        for (final branch in data) {
          final roId = branch['regional_office_id'] as String?;
          if (roId != null && roLookup.containsKey(roId)) {
            branch['regional_office_name'] = roLookup[roId];
          }
        }
      }

      // Enrich city data with province names
      if (_type == MasterDataEntityType.city) {
        final provinces = await repository.getAllEntities('provinces');
        final provinceLookup = Map.fromEntries(
          provinces.map((p) => MapEntry(p['id'] as String, p['name'] as String)),
        );

        for (final city in data) {
          final provinceId = city['province_id'] as String?;
          if (provinceId != null && provinceLookup.containsKey(provinceId)) {
            city['province_name'] = provinceLookup[provinceId];
          }
        }
      }

      // Enrich LOB data with COB names
      if (_type == MasterDataEntityType.lob) {
        final cobs = await repository.getAllEntities('cobs');
        final cobLookup = Map.fromEntries(
          cobs.map((c) => MapEntry(c['id'] as String, c['name'] as String)),
        );

        for (final lob in data) {
          final cobId = lob['cob_id'] as String?;
          if (cobId != null && cobLookup.containsKey(cobId)) {
            lob['cob_name'] = cobLookup[cobId];
          }
        }
      }

      // Enrich Pipeline Status with stage names
      if (_type == MasterDataEntityType.pipelineStatus) {
        final stages = await repository.getAllEntities('pipeline_stages');
        final stageLookup = Map.fromEntries(
          stages.map((s) => MapEntry(s['id'] as String, s['name'] as String)),
        );

        for (final status in data) {
          final stageId = status['stage_id'] as String?;
          if (stageId != null && stageLookup.containsKey(stageId)) {
            status['stage_name'] = stageLookup[stageId];
          }
        }
      }

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

      // Use specialized methods for entities with dependencies
      final Result<void> result;
      if (_type == MasterDataEntityType.regionalOffice) {
        result = await repository.softDeleteRegionalOffice(id);
      } else if (_type == MasterDataEntityType.branch) {
        result = await repository.softDeleteBranch(id);
      } else {
        result = await repository.softDeleteEntity(_type.tableName, id);
      }

      if (!mounted) return;
      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dihapus')),
          );
          _loadData();
        case ResultFailure(:final failure):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
      }
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
                        : ResponsiveLayout(
                            mobile: _buildMobileList(),
                            tablet: _buildTabletList(),
                            desktop: _buildDesktopList(),
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

  // Mobile: Card-based ListView
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredData.length,
      itemBuilder: (context, index) {
        final item = _filteredData[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () => _navigateToForm(item['id'].toString()),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']?.toString() ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildMobileSubtitle(item),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(item['is_active'] == true),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _navigateToForm(item['id'].toString());
                      if (value == 'delete') _showDeleteConfirmation(item);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileSubtitle(Map<String, dynamic> item) {
    final code = item['code']?.toString() ?? '-';
    String? extra;

    if (_type == MasterDataEntityType.pipelineStage) {
      extra = 'Prob: ${item['probability'] ?? '-'}%';
    } else if (_type == MasterDataEntityType.branch) {
      extra = item['regional_office_name']?.toString();
    } else if (_type == MasterDataEntityType.city) {
      extra = item['province_name']?.toString();
    } else if (_type == MasterDataEntityType.lob) {
      extra = item['cob_name']?.toString();
    } else if (_type == MasterDataEntityType.pipelineStatus) {
      extra = item['stage_name']?.toString();
    }

    if (extra != null) {
      return Text('Kode: $code • $extra');
    }
    return Text('Kode: $code');
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  // Tablet: Compact DataTable
  Widget _buildTabletList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _buildColumns(),
              rows: _buildRows(),
            ),
          ),
        ),
      ),
    );
  }

  // Desktop: Full DataTable with all columns
  Widget _buildDesktopList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _buildDesktopColumns(),
              rows: _buildDesktopRows(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildDesktopColumns() {
    return [
      const DataColumn(label: Text('Kode')),
      const DataColumn(label: Text('Nama')),
      // Entity-specific columns
      if (_type == MasterDataEntityType.pipelineStage) ...[
        const DataColumn(label: Text('Probabilitas')),
        const DataColumn(label: Text('Urutan')),
        const DataColumn(label: Text('Warna')),
        const DataColumn(label: Text('Final')),
        const DataColumn(label: Text('Menang')),
      ],
      if (_type == MasterDataEntityType.pipelineStatus) ...[
        const DataColumn(label: Text('Tahap')),
        const DataColumn(label: Text('Urutan')),
        const DataColumn(label: Text('Default')),
      ],
      if (_type == MasterDataEntityType.activityType) ...[
        const DataColumn(label: Text('Icon')),
        const DataColumn(label: Text('Warna')),
      ],
      if (_type == MasterDataEntityType.leadSource) ...[
        const DataColumn(label: Text('Referrer')),
        const DataColumn(label: Text('Broker')),
      ],
      if (_type == MasterDataEntityType.city)
        const DataColumn(label: Text('Provinsi')),
      if (_type == MasterDataEntityType.lob)
        const DataColumn(label: Text('COB')),
      if (_type == MasterDataEntityType.branch)
        const DataColumn(label: Text('Kantor Wilayah')),
      const DataColumn(label: Text('Status')),
      const DataColumn(label: Text('Aksi')),
    ];
  }

  List<DataRow> _buildDesktopRows() {
    return _filteredData.map((item) {
      return DataRow(
        cells: [
          DataCell(Text(item['code']?.toString() ?? '-')),
          DataCell(Text(item['name']?.toString() ?? '-')),
          // Entity-specific cells
          if (_type == MasterDataEntityType.pipelineStage) ...[
            DataCell(Text('${item['probability']?.toString() ?? '-'}%')),
            DataCell(Text(item['sequence']?.toString() ?? '-')),
            DataCell(_buildColorChip(item['color']?.toString())),
            DataCell(_buildBooleanBadge(item['is_final'] == true, 'Ya', 'Tidak')),
            DataCell(_buildBooleanBadge(item['is_won'] == true, 'Ya', 'Tidak')),
          ],
          if (_type == MasterDataEntityType.pipelineStatus) ...[
            DataCell(Text(item['stage_name']?.toString() ?? '-')),
            DataCell(Text(item['sequence']?.toString() ?? '-')),
            DataCell(_buildBooleanBadge(item['is_default'] == true, 'Ya', 'Tidak')),
          ],
          if (_type == MasterDataEntityType.activityType) ...[
            DataCell(Text(item['icon']?.toString() ?? '-')),
            DataCell(_buildColorChip(item['color']?.toString())),
          ],
          if (_type == MasterDataEntityType.leadSource) ...[
            DataCell(_buildBooleanBadge(item['requires_referrer'] == true, 'Ya', 'Tidak')),
            DataCell(_buildBooleanBadge(item['requires_broker'] == true, 'Ya', 'Tidak')),
          ],
          if (_type == MasterDataEntityType.city)
            DataCell(Text(item['province_name']?.toString() ?? '-')),
          if (_type == MasterDataEntityType.lob)
            DataCell(Text(item['cob_name']?.toString() ?? '-')),
          if (_type == MasterDataEntityType.branch)
            DataCell(Text(item['regional_office_name']?.toString() ?? '-')),
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

  Widget _buildColorChip(String? color) {
    if (color == null || color.isEmpty) {
      return const Text('-');
    }
    try {
      final colorValue = Color(int.parse(color.replaceFirst('#', '0xFF')));
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colorValue,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          Text(color),
        ],
      );
    } catch (_) {
      return Text(color);
    }
  }

  Widget _buildBooleanBadge(bool value, String trueLabel, String falseLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: value ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value ? trueLabel : falseLabel,
        style: TextStyle(
          fontSize: 12,
          color: value ? Colors.blue.shade800 : Colors.grey.shade600,
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('Kode')),
      const DataColumn(label: Text('Nama')),
      if (_type == MasterDataEntityType.pipelineStage)
        const DataColumn(label: Text('Probabilitas')),
      if (_type == MasterDataEntityType.branch)
        const DataColumn(label: Text('Kantor Wilayah')),
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
          if (_type == MasterDataEntityType.branch)
            DataCell(Text(item['regional_office_name']?.toString() ?? '-')),
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
