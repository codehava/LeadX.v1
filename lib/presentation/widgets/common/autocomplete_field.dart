import 'package:flutter/material.dart';

/// A dropdown item model for [AutocompleteField].
class AutocompleteItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const AutocompleteItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompleteItem<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// An inline autocomplete field widget that shows suggestions
/// directly below the text field as user types.
///
/// Features:
/// - Inline search within textfield
/// - Compact dropdown suggestions below the field
/// - Real-time filtering as user types
/// - Optional subtitle and icon for each item
/// - Consistent with app design system
class AutocompleteField<T> extends StatefulWidget {
  /// Label shown above the field.
  final String? label;

  /// Hint text when no item is selected.
  final String? hint;

  /// Helper text shown below the field.
  final String? helperText;

  /// Currently selected item value.
  final T? value;

  /// List of items to select from.
  final List<AutocompleteItem<T>> items;

  /// Callback when an item is selected.
  final ValueChanged<T?>? onChanged;

  /// Validator function for form validation.
  final String? Function(T?)? validator;

  /// Whether the field is enabled.
  final bool enabled;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Whether to show a clear button when item is selected.
  final bool showClearButton;

  /// Maximum height of the suggestions dropdown.
  final double maxSuggestionsHeight;

  /// Minimum characters before showing suggestions.
  final int minCharsForSuggestions;

  const AutocompleteField({
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
    this.showClearButton = true,
    this.maxSuggestionsHeight = 200,
    this.minCharsForSuggestions = 0,
  });

  @override
  State<AutocompleteField<T>> createState() => _AutocompleteFieldState<T>();
}

class _AutocompleteFieldState<T> extends State<AutocompleteField<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  OverlayEntry? _overlayEntry;
  List<AutocompleteItem<T>> _filteredItems = [];
  bool _isOpen = false;
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _updateTextFromValue();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AutocompleteField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
      _updateTextFromValue();
    }
  }

  void _updateTextFromValue() {
    if (_selectedValue != null) {
      final selectedItem = widget.items.cast<AutocompleteItem<T>?>().firstWhere(
            (item) => item?.value == _selectedValue,
            orElse: () => null,
          );
      if (selectedItem != null) {
        _textController.text = selectedItem.label;
      }
    } else {
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _textController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _filterItems(_textController.text);
      _showOverlay();
    } else {
      // Delay to allow tap on suggestion
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _filterItems(String query) {
    if (query.length < widget.minCharsForSuggestions && query.isNotEmpty) {
      _filteredItems = [];
    } else if (query.isEmpty) {
      _filteredItems = widget.items;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredItems = widget.items.where((item) {
        return item.label.toLowerCase().contains(lowerQuery) ||
            (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: _buildSuggestionsList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsList() {
    final theme = Theme.of(context);

    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Tidak ada hasil',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxSuggestionsHeight),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final isSelected = item.value == _selectedValue;

          return InkWell(
            onTap: () => _selectItem(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : null,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.subtitle != null)
                          Text(
                            item.subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectItem(AutocompleteItem<T> item) {
    setState(() {
      _selectedValue = item.value;
      _textController.text = item.label;
    });
    widget.onChanged?.call(item.value);
    _focusNode.unfocus();
    _removeOverlay();
  }

  void _clearSelection() {
    setState(() {
      _selectedValue = null;
      _textController.clear();
    });
    widget.onChanged?.call(null);
  }

  void _onTextChanged(String value) {
    _filterItems(value);
    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
    } else if (_focusNode.hasFocus) {
      _showOverlay();
    }

    // Clear selection if text doesn't match exactly
    if (_selectedValue != null) {
      final selectedItem = widget.items.cast<AutocompleteItem<T>?>().firstWhere(
            (item) => item?.value == _selectedValue,
            orElse: () => null,
          );
      if (selectedItem != null && selectedItem.label != value) {
        _selectedValue = null;
        widget.onChanged?.call(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (state) {
        final hasError = state.hasError;
        final errorText = state.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
            CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                enabled: widget.enabled,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  helperText: hasError ? null : widget.helperText,
                  errorText: errorText,
                  prefixIcon:
                      widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showClearButton &&
                          _textController.text.isNotEmpty &&
                          widget.enabled)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _clearSelection,
                        ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: widget.enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.disabledColor,
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: widget.enabled
                      ? theme.colorScheme.surface
                      : theme.disabledColor.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
