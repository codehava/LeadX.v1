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
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            category.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: entityTypes.length,
          itemBuilder: (context, index) => _buildEntityCard(
            context,
            entityTypes[index],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildEntityCard(
    BuildContext context,
    MasterDataEntityType entityType,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToEntityList(context, entityType),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                entityType.icon,
                size: 36,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                entityType.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
