import 'package:flutter/material.dart';

/// Reusable multi-select checkbox field for selecting multiple items from a list.
///
/// Generic widget that displays a list of items with checkboxes, allowing users
/// to select multiple items. Includes "Select All" / "Clear All" buttons and
/// shows the count of selected items.
///
/// Usage:
/// ```dart
/// MultiSelectCheckboxField<ActivityTypeDto>(
///   label: 'Activity Types',
///   items: activityTypes,
///   selectedIds: _selectedActivityTypeIds,
///   onChanged: (ids) => setState(() => _selectedActivityTypeIds = ids),
///   getItemId: (item) => item.id,
///   getItemLabel: (item) => item.name,
/// )
/// ```
class MultiSelectCheckboxField<T> extends StatefulWidget {
  /// Label displayed above the checkbox list
  final String label;

  /// List of items to display
  final List<T> items;

  /// Set of currently selected item IDs
  final Set<String> selectedIds;

  /// Callback when selection changes
  final ValueChanged<Set<String>> onChanged;

  /// Function to extract ID from item
  final String Function(T) getItemId;

  /// Function to extract display label from item
  final String Function(T) getItemLabel;

  /// Optional function to extract subtitle from item
  final String? Function(T)? getItemSubtitle;

  /// Whether to show search/filter bar
  final bool showSearch;

  /// Maximum height for the checkbox list (null = no limit)
  final double? maxHeight;

  const MultiSelectCheckboxField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
    required this.getItemId,
    required this.getItemLabel,
    this.getItemSubtitle,
    this.showSearch = false,
    this.maxHeight,
  });

  @override
  State<MultiSelectCheckboxField<T>> createState() =>
      _MultiSelectCheckboxFieldState<T>();
}

class _MultiSelectCheckboxFieldState<T>
    extends State<MultiSelectCheckboxField<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter items based on search query
    final filteredItems = widget.showSearch && _searchQuery.isNotEmpty
        ? widget.items.where((item) {
            final label = widget.getItemLabel(item).toLowerCase();
            return label.contains(_searchQuery.toLowerCase());
          }).toList()
        : widget.items;

    final selectedCount = widget.selectedIds.length;
    final totalCount = widget.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with label and action buttons
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$selectedCount / $totalCount selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Action buttons
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                final allIds =
                    widget.items.map(widget.getItemId).toSet();
                widget.onChanged(allIds);
              },
              icon: const Icon(Icons.check_box, size: 18),
              label: const Text('Select All'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                widget.onChanged({});
              },
              icon: const Icon(Icons.check_box_outline_blank, size: 18),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Search bar
        if (widget.showSearch) ...[
          TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
        ],

        // Checkbox list
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: widget.maxHeight != null
              ? BoxConstraints(maxHeight: widget.maxHeight!)
              : null,
          child: filteredItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No items match your search'
                          : 'No items available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final itemId = widget.getItemId(item);
                    final isSelected = widget.selectedIds.contains(itemId);
                    final subtitle = widget.getItemSubtitle?.call(item);

                    return CheckboxListTile(
                      title: Text(widget.getItemLabel(item)),
                      subtitle: subtitle != null ? Text(subtitle) : null,
                      value: isSelected,
                      onChanged: (selected) {
                        final newSelection = Set<String>.from(widget.selectedIds);
                        if (selected ?? false) {
                          newSelection.add(itemId);
                        } else {
                          newSelection.remove(itemId);
                        }
                        widget.onChanged(newSelection);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
