// ⚠️ CRITICAL FILE - DO NOT MODIFY WITHOUT PERMISSION
// Custom searchable dropdown widget for product selection in scheme forms.
// Modified: Complete implementation with search functionality
// Contact: Developer before making changes

import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => _SearchableDropdownDialog<T>(
        position: position,
        width: size.width,
        topOffset: size.height + 4,
        items: widget.items,
        itemLabel: widget.itemLabel,
        currentValue: widget.value,
        onSelected: (item) {
          widget.onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLabel = widget.value != null
        ? widget.itemLabel(widget.value as T)
        : 'Select ${widget.label}';

    return InkWell(
      onTap: _showDropdown,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          selectedLabel,
          style: TextStyle(
            color: widget.value != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SearchableDropdownDialog<T> extends StatefulWidget {
  final Offset position;
  final double width;
  final double topOffset;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? currentValue;
  final void Function(T) onSelected;

  const _SearchableDropdownDialog({
    required this.position,
    required this.width,
    required this.topOffset,
    required this.items,
    required this.itemLabel,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  State<_SearchableDropdownDialog<T>> createState() =>
      _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T>
    extends State<_SearchableDropdownDialog<T>> {
  final _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget
                .itemLabel(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy + widget.topOffset,
          width: widget.width,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: _filterItems,
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: _filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No items found'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = item == widget.currentValue;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  widget.itemLabel(item),
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                                selected: isSelected,
                                onTap: () => widget.onSelected(item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
