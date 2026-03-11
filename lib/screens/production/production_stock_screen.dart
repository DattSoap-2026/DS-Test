import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/products_service.dart';
import '../../services/master_data_service.dart';
import '../../models/types/product_types.dart';
import '../../models/types/user_types.dart';
import '../../utils/unit_scope_utils.dart';

enum _StockCategory { semiFinished, finished, packaging }

extension _StockCategoryX on _StockCategory {
  String get label {
    switch (this) {
      case _StockCategory.semiFinished:
        return 'Semi Finished';
      case _StockCategory.finished:
        return 'Finished Goods';
      case _StockCategory.packaging:
        return 'Packaging';
    }
  }
}

class ProductionStockScreen extends StatefulWidget {
  final bool showLowStockOnly;

  const ProductionStockScreen({super.key, this.showLowStockOnly = false});

  @override
  State<ProductionStockScreen> createState() => _ProductionStockScreenState();
}

class _ProductionStockScreenState extends State<ProductionStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _sourceProducts = [];
  List<Product> _scopedProducts = [];
  List<Product> _filteredProducts = [];
  List<DynamicProductType> _productTypes = [];
  bool _isLoading = true;
  String? _errorMessage;
  _StockCategory _selectedCategory = _StockCategory.finished;
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});
  String _accessSignature = '';

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _searchController.addListener(_onSearchChanged);
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessProduction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Access Denied: Production operations restricted to authorized roles',
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    _fetchStock();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().currentUser;
    final signature = _buildAccessSignature(user);
    if (signature != _accessSignature) {
      _accessSignature = signature;
      _resolveUserScope(user);
      if (_sourceProducts.isNotEmpty) {
        _applyScopeAndSearchFilters();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyScopeAndSearchFilters();
  }

  void _onCategoryChanged(_StockCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyScopeAndSearchFilters();
  }

  String _buildAccessSignature(AppUser? user) {
    if (user == null) return 'guest';
    final deptTokens = user.departments
        .map((d) => '${d.main}:${d.team ?? ''}')
        .join('|');
    return [
      user.id,
      user.role.value,
      user.department ?? '',
      user.assignedBhatti ?? '',
      deptTokens,
    ].join('::');
  }

  void _resolveUserScope(AppUser? user) {
    _unitScope = resolveUserUnitScope(user);
  }

  String _entityTypeKey(Product product) {
    return (product.entityType ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  bool _matchesCategory(Product product, _StockCategory category) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    final entityType = _entityTypeKey(product);
    switch (category) {
      case _StockCategory.semiFinished:
        return product.type == ProductTypeEnum.semi ||
            normalizedType == ProductType.semiFinishedGood.value ||
            entityType == 'semi_finished' ||
            entityType == 'semi' ||
            entityType == 'formula_output';
      case _StockCategory.finished:
        return product.type == ProductTypeEnum.finished ||
            normalizedType == ProductType.finishedGood.value ||
            entityType == 'finished' ||
            entityType == 'finished_good' ||
            entityType == 'final_product';
      case _StockCategory.packaging:
        return product.type == ProductTypeEnum.packaging ||
            normalizedType == ProductType.packagingMaterial.value ||
            entityType == 'packaging' ||
            entityType == 'packaging_material';
    }
  }

  bool _isProductVisibleForCurrentUser(Product product) {
    if (_unitScope.canViewAll) return true;
    final scopeTokens = <String?>[
      product.departmentId,
      ...product.allowedDepartmentIds,
    ];
    final hasScopeTokens = scopeTokens.any(
      (token) => (token ?? '').trim().isNotEmpty,
    );

    final strictVisible = matchesUnitScope(
      scope: _unitScope,
      tokens: scopeTokens,
      defaultIfNoScopeTokens: false,
    );
    if (strictVisible) return true;

    if (_unitScope.keys.isEmpty) return true;
    if (!hasScopeTokens) return true;

    return false;
  }

  bool _isLowStock(Product product) {
    final reorderLevel = product.reorderLevel;
    if (reorderLevel == null) return false;
    return product.stock <= reorderLevel;
  }

  int _countForCategory(_StockCategory category) {
    return _sourceProducts
        .where(
          (product) =>
              _matchesCategory(product, category) &&
              _isProductVisibleForCurrentUser(product) &&
              (!widget.showLowStockOnly || _isLowStock(product)),
        )
        .length;
  }

  String _scopeSummaryText() {
    if (_unitScope.canViewAll) {
      if (!widget.showLowStockOnly) return 'Showing stock for all units';
      return 'Showing stock for all units | Low stock filter active';
    }
    if (_unitScope.keys.isEmpty) {
      if (!widget.showLowStockOnly) {
        return 'No assigned units found. Showing available stock (compatibility mode).';
      }
      return 'No assigned units found. Showing low stock (compatibility mode).';
    }
    if (!widget.showLowStockOnly) {
      return 'Showing assigned units: ${_unitScope.label}';
    }
    return 'Showing assigned units: ${_unitScope.label} | Low stock filter active';
  }

  void _applyScopeAndSearchFilters() {
    final scoped =
        _sourceProducts
            .where(
              (product) =>
                  _matchesCategory(product, _selectedCategory) &&
                  _isProductVisibleForCurrentUser(product) &&
                  (!widget.showLowStockOnly || _isLowStock(product)),
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    final query = _searchController.text.toLowerCase();
    final filtered = query.isEmpty
        ? scoped
        : scoped.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.sku.toLowerCase().contains(query);
          }).toList();

    if (!mounted) return;
    setState(() {
      _scopedProducts = scoped;
      _filteredProducts = filtered;
    });
  }

  Future<void> _fetchStock() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productService = context.read<ProductsService>();
      final masterDataService = context.read<MasterDataService>();
      final user = context.read<AuthProvider>().currentUser;
      _resolveUserScope(user);
      _accessSignature = _buildAccessSignature(user);

      // Force refresh product types cache
      masterDataService.invalidateCache();

      var products = await productService.getProducts(status: 'active');
      if (products.isEmpty) {
        products = await productService.getProducts();
      }
      final productTypes = await masterDataService.getProductTypes();

      if (!mounted) return;
      setState(() {
        _sourceProducts = products;
        _productTypes = productTypes;
        _isLoading = false;
      });
      _applyScopeAndSearchFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load stock data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Stock'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStock,
            tooltip: 'Refresh Stock',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _StockCategory.values.map((category) {
                  final isSelected = category == _selectedCategory;
                  final label =
                      '${category.label} (${_countForCategory(category)})';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => _onCategoryChanged(category),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _scopeSummaryText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading stock',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _fetchStock,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _scopedProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.showLowStockOnly
                              ? 'All Stock Healthy'
                              : 'No ${_selectedCategory.label} Found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'No matching products found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLowStock =
        product.reorderLevel != null && product.stock <= product.reorderLevel!;

    final displayUnit = _getDisplayUnit(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock
              ? theme.colorScheme.error.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(
              alpha: isDark ? 0.2 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLowStock
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: isLowStock
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.stock.toStringAsFixed(0)} $displayUnit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isLowStock
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isLowStock)
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Low Stock',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayUnit(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    final isSemi = _matchesCategory(product, _StockCategory.semiFinished);

    // Match by name (primary) or by id fallback
    DynamicProductType? productType;
    for (final t in _productTypes) {
      if (t.name == normalizedType) {
        productType = t;
        break;
      }
    }
    // If not found by exact name, try case-insensitive match
    if (productType == null) {
      final normalized = normalizedType.toLowerCase();
      for (final t in _productTypes) {
        if (t.name.toLowerCase() == normalized) {
          productType = t;
          break;
        }
      }
    }

    // Use displayUnit from matched type
    if (productType != null && (productType.displayUnit?.isNotEmpty ?? false)) {
      return productType.displayUnit!;
    }

    // Smart fallback: semi-finished items default to 'Box' (Firebase displayUnit)
    if (isSemi) {
      debugPrint(
        '⚠️ Semi-finished displayUnit fallback to Box: ${product.name} ($normalizedType)',
      );
      return 'Box';
    }

    if (productType == null) {
      debugPrint(
        '⚠️ ProductType not found for: ${product.name} ($normalizedType)',
      );
      debugPrint(
        '   Available types: ${_productTypes.map((t) => t.name).join(", ")}',
      );
    }
    return product.baseUnit;
  }
}
