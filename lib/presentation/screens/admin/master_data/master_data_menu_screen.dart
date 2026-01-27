import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import 'master_data_entity_type.dart';

/// Screen displaying all master data entity types organized by category.
/// Users can tap on an entity type to navigate to its list screen.
class MasterDataMenuScreen extends StatelessWidget {
  const MasterDataMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Master'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final category in MasterDataCategory.values)
              _buildCategorySection(context, category),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    MasterDataCategory category,
  ) {
    final entityTypes = category.entityTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            category.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entityTypes.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) => _buildEntityListTile(
            context,
            entityTypes[index],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEntityListTile(
    BuildContext context,
    MasterDataEntityType entityType,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(
        entityType.icon,
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        entityType.displayName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => _navigateToEntityList(context, entityType),
    );
  }

  void _navigateToEntityList(
    BuildContext context,
    MasterDataEntityType entityType,
  ) {
    // Navigate to master data list with entity type parameter
    context.pushNamed(
      RouteNames.adminMasterDataList,
      pathParameters: {'entityType': entityType.tableName},
    );
  }
}
