import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/types/product_types.dart';
import 'inventory_search_filter.dart';
import '../ui/unified_card.dart';
import '../../utils/unit_converter.dart';
import '../../providers/inventory_provider.dart';
import '../../services/master_data_service.dart';

class InventoryTable extends ConsumerStatefulWidget {
  final List<Product> products;
  final String type;
  final FilterState filters;

  const InventoryTable({
    super.key,
    required this.products,
    required this.type,
    required this.filters,
  });

  @override
  ConsumerState<InventoryTable> createState() => _InventoryTableState();
}

class _InventoryTableState extends ConsumerState<InventoryTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isRawMaterial {
    return [
      'Raw Material',
      'Oils & Liquids',
      'Chemicals & Additives',
      'Packaging Material',
    ].contains(widget.type);
  }

  bool get _isSemiFinished => widget.type == 'Semi-Finished Good';

  bool get _hidePriceColumn => _isRawMaterial || _isSemiFinished;

  List<Product> get _filteredProducts {
    if (widget.products.isEmpty) return [];

    return widget.products.where((product) {
      // Search filter
      if (widget.filters.search.isNotEmpty) {
        final searchLower = widget.filters.search.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(searchLower);
        final matchesSku = product.sku.toLowerCase().contains(searchLower);
        if (!matchesName && !matchesSku) return false;
      }

      // Stock status filter
      if (widget.filters.stockStatus != StockStatusFilter.all) {
        final status = _getStockStatus(product);
        final isReorderPoint =
            product.reorderLevel != null &&
            product.stock > 0 &&
            product.stock <= product.reorderLevel! * 1.2 &&
            product.stock > product.reorderLevel!;

        switch (widget.filters.stockStatus) {
          case StockStatusFilter.reorder:
            if (!isReorderPoint && status != 'Low Stock') return false;
            break;
          case StockStatusFilter.inStock:
            if (status != 'In Stock') return false;
            break;
          case StockStatusFilter.low:
            if (status != 'Low Stock') return false;
            break;
          case StockStatusFilter.out:
            if (status != 'Out of Stock') return false;
            break;
          default:
            break;
        }
      }

      // Category filter
      if (widget.filters.categories.isNotEmpty) {
        if (product.category.isEmpty ||
            !widget.filters.categories.contains(product.category)) {
          return false;
        }
      }

      // Price range filter (skip where price is not meaningful)
      if (!_hidePriceColumn) {
        final price = product.price;
        if (price < widget.filters.priceRange.start ||
            price > widget.filters.priceRange.end) {
          return false;
        }
      }

      return true;
    }).toList()..sort((a, b) {
      int comparison = 0;
      switch (widget.filters.sortBy) {
        case SortField.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SortField.stock:
          comparison = a.stock.compareTo(b.stock);
          break;
        case SortField.price:
          comparison = _hidePriceColumn ? 0 : a.price.compareTo(b.price);
          break;
        case SortField.status:
          comparison = _getStockStatus(a).compareTo(_getStockStatus(b));
          break;
      }
      return widget.filters.sortOrder == SortOrder.asc
          ? comparison
          : -comparison;
    });
  }

  String _getStockStatus(Product product) {
    if (product.stock == 0) return 'Out of Stock';
    if (product.stock <= (product.minimumSafetyStock ?? 0)) return 'Low Stock';
    return 'In Stock';
  }

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'In Stock':
        return theme.colorScheme.primary;
      case 'Low Stock':
        return theme.colorScheme.error;
      case 'Out of Stock':
        return theme.colorScheme.error.withValues(alpha: 0.7);
      default:
        return theme.colorScheme.outline;
    }
  }

  String _formatStock(
    double stock,
    double? conversionFactor,
    String baseUnit,
    String? secondaryUnit,
  ) {
    return UnitConverter.formatDual(
      baseQty: stock,
      baseUnit: baseUnit,
      secondaryUnit: secondaryUnit,
      conversionFactor: conversionFactor ?? 1,
      showZeroLoose: true,
    );
  }

  String _formatSemiStock(
    Product product,
    List<DynamicProductType> productTypes,
  ) {
    // Get display unit from product type
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    // Try exact match first, then case-insensitive
    DynamicProductType? productType;
    for (final t in productTypes) {
      if (t.name == normalizedType) {
        productType = t;
        break;
      }
    }
    if (productType == null) {
      final lower = normalizedType.toLowerCase();
      for (final t in productTypes) {
        if (t.name.toLowerCase() == lower) {
          productType = t;
          break;
        }
      }
    }

    // If displayUnit not available, default 'Box' for semi-finished (Firebase value)
    final displayUnit = (productType?.displayUnit?.isNotEmpty ?? false)
        ? productType!.displayUnit!
        : (normalizedType.toLowerCase().contains('semi')
              ? 'Box'
              : product.baseUnit);

    final stock = product.stock.toDouble();
    final unit = product.baseUnit.toLowerCase().trim();
    final secondaryUnit = (product.secondaryUnit ?? '').toLowerCase().trim();
    final boxWeightKg = product.unitWeightGrams > 0
        ? product.unitWeightGrams / 1000.0
        : 0.0;

    double? stockInBoxes;
    if (unit.contains('box')) {
      stockInBoxes = stock;
    } else if ((unit == 'kg' || unit.contains('kilogram')) && boxWeightKg > 0) {
      stockInBoxes = stock / boxWeightKg;
    } else if (unit.contains('bag') || unit.contains('sack')) {
      final boxesPerBag =
          (product.boxesPerBatch ??
                  product.standardBatchOutputPcs?.round() ??
                  0)
              .toDouble();
      if (boxesPerBag > 0) {
        stockInBoxes = stock * boxesPerBag;
      } else {
        final factor = product.conversionFactor;
        if (secondaryUnit.contains('box') && factor.isFinite && factor > 0) {
          stockInBoxes = stock * factor;
        }
      }
    }

    if (stockInBoxes != null) {
      final hasDecimal = (stockInBoxes - stockInBoxes.round()).abs() > 0.0001;
      final qty = hasDecimal
          ? stockInBoxes.toStringAsFixed(2)
          : stockInBoxes.toStringAsFixed(0);
      return '$qty $displayUnit';
    }

    final hasDecimal = (stock - stock.round()).abs() > 0.0001;
    final qty = hasDecimal
        ? stock.toStringAsFixed(1)
        : stock.toStringAsFixed(0);
    return '$qty $displayUnit';
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts;
    final productTypes = ref
        .watch(productTypesProvider)
        .maybeWhen(data: (t) => t, orElse: () => <DynamicProductType>[]);

    if (filteredProducts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No ${widget.type.toLowerCase()}s found matching your filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          final status = _getStockStatus(product);
          final statusColor = _getStatusColor(context, status);
          final theme = Theme.of(context);

          return ref.watch(warehouseStocksProvider(product.id)).when(
            loading: () => UnifiedCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => UnifiedCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Text('Error: $err'),
            ),
            data: (warehouseStocks) {
              final gitaShed = warehouseStocks.firstWhere(
                (w) => w.warehouseId == 'Gita_Shed',
                orElse: () => WarehouseStock(
                  warehouseId: 'Gita_Shed',
                  warehouseName: 'Gita Shed',
                  stock: 0,
                ),
              );
              final sonaShed = warehouseStocks.firstWhere(
                (w) => w.warehouseId == 'Sona_Shed',
                orElse: () => WarehouseStock(
                  warehouseId: 'Sona_Shed',
                  warehouseName: 'Sona Shed',
                  stock: 0,
                ),
              );
              final mainWarehouse = warehouseStocks.firstWhere(
                (w) => w.warehouseId == 'Main',
                orElse: () => WarehouseStock(
                  warehouseId: 'Main',
                  warehouseName: 'Main Warehouse',
                  stock: 0,
                ),
              );
              final totalStock = product.stock.toDouble();

              return UnifiedCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product Info
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.sku} • ${product.category.isEmpty ? "No Cat" : product.category}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Gita Shed
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GITA SHED',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 8,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _formatWarehouseStock(
                                gitaShed.stock,
                                product,
                                productTypes,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: gitaShed.stock > 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Sona Shed
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SONA SHED',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 8,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _formatWarehouseStock(
                                sonaShed.stock,
                                product,
                                productTypes,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: sonaShed.stock > 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Main Warehouse
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'MAIN WH',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 8,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _formatWarehouseStock(
                                mainWarehouse.stock,
                                product,
                                productTypes,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: mainWarehouse.stock > 0
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Total
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TOTAL',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 8,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _formatWarehouseStock(
                                totalStock,
                                product,
                                productTypes,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          status == 'Out of Stock'
                              ? 'OUT'
                              : status == 'Low Stock'
                              ? 'LOW'
                              : 'OK',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatWarehouseStock(
    double stock,
    Product product,
    List<DynamicProductType> productTypes,
  ) {
    if (stock == 0) return '0';
    
    if (_isSemiFinished) {
      return _formatSemiStock(
        product.copyWith(stock: stock),
        productTypes,
      );
    }
    
    return _formatStock(
      stock,
      product.conversionFactor.toDouble(),
      product.baseUnit,
      product.secondaryUnit,
    );
  }
}
