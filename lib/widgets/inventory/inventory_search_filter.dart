import 'package:flutter/material.dart';
import '../ui/unified_card.dart';
import '../ui/themed_filter_chip.dart';
import 'package:flutter_app/utils/responsive.dart';

enum StockStatusFilter { all, inStock, low, out, reorder }

enum SortField { name, stock, price, status }

enum SortOrder { asc, desc }

class FilterState {
  final String search;
  final StockStatusFilter stockStatus;
  final List<String> categories;
  final RangeValues priceRange;
  final SortField sortBy;
  final SortOrder sortOrder;

  FilterState({
    this.search = '',
    this.stockStatus = StockStatusFilter.all,
    this.categories = const [],
    this.priceRange = const RangeValues(0, 100000),
    this.sortBy = SortField.name,
    this.sortOrder = SortOrder.asc,
  });

  FilterState copyWith({
    String? search,
    StockStatusFilter? stockStatus,
    List<String>? categories,
    RangeValues? priceRange,
    SortField? sortBy,
    SortOrder? sortOrder,
  }) {
    return FilterState(
      search: search ?? this.search,
      stockStatus: stockStatus ?? this.stockStatus,
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class InventorySearchFilter extends StatefulWidget {
  final Function(FilterState) onFilterChange;
  final List<String> categories;
  final String itemType;
  final double maxPrice;

  const InventorySearchFilter({
    super.key,
    required this.onFilterChange,
    required this.categories,
    required this.itemType,
    this.maxPrice = 10000,
  });

  @override
  State<InventorySearchFilter> createState() => _InventorySearchFilterState();
}

class _InventorySearchFilterState extends State<InventorySearchFilter> {
  final TextEditingController _searchController = TextEditingController();
  StockStatusFilter _stockStatus = StockStatusFilter.all;
  List<String> _selectedCategories = [];
  RangeValues _priceRange = const RangeValues(0, 10000);
  SortField _sortBy = SortField.name;
  SortOrder _sortOrder = SortOrder.asc;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _priceRange = RangeValues(0, widget.maxPrice);
  }

  @override
  void didUpdateWidget(covariant InventorySearchFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isNonPricedType && _sortBy == SortField.price) {
      setState(() {
        _sortBy = SortField.name;
        _priceRange = RangeValues(0, widget.maxPrice);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifyFilterChange();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _notifyFilterChange();
  }

  void _notifyFilterChange() {
    widget.onFilterChange(
      FilterState(
        search: _searchController.text,
        stockStatus: _stockStatus,
        categories: _selectedCategories,
        priceRange: _priceRange,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      ),
    );
  }

  bool get _hasActiveFilters {
    final hasActivePriceFilter =
        !_isNonPricedType &&
        (_priceRange.start > 0 || _priceRange.end < widget.maxPrice);

    return _stockStatus != StockStatusFilter.all ||
        _selectedCategories.isNotEmpty ||
        hasActivePriceFilter;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _stockStatus = StockStatusFilter.all;
      _selectedCategories = [];
      _priceRange = RangeValues(0, widget.maxPrice);
      _sortBy = SortField.name;
      _sortOrder = SortOrder.asc;
    });
    _notifyFilterChange();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    _notifyFilterChange();
  }

  bool get _isNonPricedType {
    return [
      'Raw Material',
      'Semi-Finished Good',
      'Oils & Liquids',
      'Chemicals & Additives',
      'Packaging Material',
    ].contains(widget.itemType);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = Responsive.width(context);
    final isDesktop = width >= 1024;
    final searchWidth = width >= 1500
        ? 460.0
        : width >= 1200
        ? 420.0
        : width >= 900
        ? 360.0
        : double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main filter row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Search input
            SizedBox(
              width: searchWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.28,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  boxShadow: isDesktop
                      ? [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.itemType.toLowerCase()}s...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.65,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: isDesktop ? 16 : 13,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Quick stock status chips
            ThemedFilterChip(
              label: 'LOW STOCK',
              selected: _stockStatus == StockStatusFilter.low,
              onSelected: () {
                setState(() {
                  _stockStatus = _stockStatus == StockStatusFilter.low
                      ? StockStatusFilter.all
                      : StockStatusFilter.low;
                });
                _notifyFilterChange();
              },
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),

            ThemedFilterChip(
              label: 'OUT OF STOCK',
              selected: _stockStatus == StockStatusFilter.out,
              onSelected: () {
                setState(() {
                  _stockStatus = _stockStatus == StockStatusFilter.out
                      ? StockStatusFilter.all
                      : StockStatusFilter.out;
                });
                _notifyFilterChange();
              },
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),

            // Sort & Order
            UnifiedCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<SortField>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: theme.colorScheme.surfaceContainer,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortBy = value);
                        _notifyFilterChange();
                      }
                    },
                    items: [
                      const DropdownMenuItem(
                        value: SortField.name,
                        child: Text('NAME'),
                      ),
                      const DropdownMenuItem(
                        value: SortField.stock,
                        child: Text('STOCK'),
                      ),
                      if (!_isNonPricedType)
                        const DropdownMenuItem(
                          value: SortField.price,
                          child: Text('PRICE'),
                        ),
                      const DropdownMenuItem(
                        value: SortField.status,
                        child: Text('STATUS'),
                      ),
                    ],
                  ),
                  const VerticalDivider(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _sortOrder = _sortOrder == SortOrder.asc
                            ? SortOrder.desc
                            : SortOrder.asc;
                      });
                      _notifyFilterChange();
                    },
                    icon: Icon(
                      _sortOrder == SortOrder.asc
                          ? Icons.north_rounded
                          : Icons.south_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Clear all button
            if (_hasActiveFilters)
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('RESET'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
          ],
        ),

        // Active filter tags
        if (_hasActiveFilters) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_stockStatus != StockStatusFilter.all)
                _buildFilterTag(
                  'Status: ${_getStockStatusText(_stockStatus)}',
                  () {
                    setState(() => _stockStatus = StockStatusFilter.all);
                    _notifyFilterChange();
                  },
                  theme,
                ),
              ..._selectedCategories.map(
                (category) => _buildFilterTag(
                  category,
                  () => _toggleCategory(category),
                  theme,
                ),
              ),
              if (!_isNonPricedType &&
                  (_priceRange.start > 0 || _priceRange.end < widget.maxPrice))
                _buildFilterTag(
                  '\u20B9${_priceRange.start.round()} - \u20B9${_priceRange.end.round()}',
                  () {
                    setState(
                      () => _priceRange = RangeValues(0, widget.maxPrice),
                    );
                    _notifyFilterChange();
                  },
                  theme,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFilterTag(
    String label,
    VoidCallback onDeleted,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: onDeleted,
            icon: const Icon(Icons.close_rounded, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }

  String _getStockStatusText(StockStatusFilter status) {
    switch (status) {
      case StockStatusFilter.all:
        return 'All';
      case StockStatusFilter.inStock:
        return 'In Stock';
      case StockStatusFilter.low:
        return 'Low Stock';
      case StockStatusFilter.out:
        return 'Out of Stock';
      case StockStatusFilter.reorder:
        return 'Needs Reorder';
    }
  }
}



