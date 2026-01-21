import 'package:flutter/material.dart';

/// A dropdown item model for [SearchableDropdown].
class DropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const DropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// A searchable dropdown widget that opens a modal bottom sheet
/// with search functionality for selecting from a list of items.
///
/// Features:
/// - Full-screen modal on mobile, dialog on desktop
/// - Real-time search filtering
/// - Optional subtitle and icon for each item
/// - Supports both single selection
/// - Consistent with app design system
class SearchableDropdown<T> extends StatelessWidget {
  /// Label shown above the dropdown.
  final String? label;

  /// Hint text when no item is selected.
  final String? hint;

  /// Helper text shown below the dropdown.
  final String? helperText;

  /// Currently selected item value.
  final T? value;

  /// List of items to select from.
  final List<DropdownItem<T>> items;

  /// Callback when an item is selected.
  final ValueChanged<T?>? onChanged;

  /// Validator function for form validation.
  final String? Function(T?)? validator;

  /// Whether the dropdown is enabled.
  final bool enabled;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Search hint text in the modal.
  final String searchHint;

  /// Title of the modal.
  final String? modalTitle;

  /// Whether to show a clear button when item is selected.
  final bool showClearButton;

  /// Custom item builder for more control.
  final Widget Function(DropdownItem<T> item, bool isSelected)? itemBuilder;

  const SearchableDropdown({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.searchHint = 'Cari...',
    this.modalTitle,
    this.showClearButton = true,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedItem = items.cast<DropdownItem<T>?>().firstWhere(
          (item) => item?.value == value,
          orElse: () => null,
        );

    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        final hasError = state.hasError;
        final errorText = state.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
            InkWell(
              onTap: enabled
                  ? () => _showSelectionModal(context, state)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: hint,
                  helperText: hasError ? null : helperText,
                  errorText: errorText,
                  prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showClearButton && selectedItem != null && enabled)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            onChanged?.call(null);
                            state.didChange(null);
                          },
                        ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.disabledColor,
                      ),
                    ],
                  ),
                  enabled: enabled,
                  filled: true,
                  fillColor: enabled
                      ? theme.colorScheme.surface
                      : theme.disabledColor.withValues(alpha: 0.1),
                ),
                isEmpty: selectedItem == null,
                child: selectedItem != null
                    ? Row(
                        children: [
                          if (selectedItem.icon != null) ...[
                            Icon(
                              selectedItem.icon,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedItem.label,
                                  style: theme.textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (selectedItem.subtitle != null)
                                  Text(
                                    selectedItem.subtitle!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSelectionModal(
    BuildContext context,
    FormFieldState<T> state,
  ) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SearchableDropdownModal<T>(
        title: modalTitle ?? label ?? 'Pilih',
        searchHint: searchHint,
        items: items,
        selectedValue: value,
        itemBuilder: itemBuilder,
      ),
    );

    if (result != null || (result == null && showClearButton)) {
      // Only call onChanged if result is not null, or if we explicitly selected null
      if (result != null) {
        onChanged?.call(result);
        state.didChange(result);
      }
    }
  }
}

/// Modal content for searchable dropdown.
class _SearchableDropdownModal<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<DropdownItem<T>> items;
  final T? selectedValue;
  final Widget Function(DropdownItem<T> item, bool isSelected)? itemBuilder;

  const _SearchableDropdownModal({
    required this.title,
    required this.searchHint,
    required this.items,
    this.selectedValue,
    this.itemBuilder,
  });

  @override
  State<_SearchableDropdownModal<T>> createState() =>
      _SearchableDropdownModalState<T>();
}

class _SearchableDropdownModalState<T>
    extends State<_SearchableDropdownModal<T>> {
  late TextEditingController _searchController;
  late List<DropdownItem<T>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = widget.items.where((item) {
          return item.label.toLowerCase().contains(lowerQuery) ||
              (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredItems.length} hasil',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Item list
          Flexible(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada hasil',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item.value == widget.selectedValue;

                      if (widget.itemBuilder != null) {
                        return InkWell(
                          onTap: () => Navigator.pop(context, item.value),
                          child: widget.itemBuilder!(item, isSelected),
                        );
                      }

                      return _buildDefaultItem(context, item, isSelected);
                    },
                  ),
          ),

          // Bottom padding for safe area
          SizedBox(height: mediaQuery.padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildDefaultItem(
    BuildContext context,
    DropdownItem<T> item,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: item.icon != null
          ? Icon(
              item.icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            )
          : null,
      title: Text(
        item.label,
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => Navigator.pop(context, item.value),
    );
  }
}
