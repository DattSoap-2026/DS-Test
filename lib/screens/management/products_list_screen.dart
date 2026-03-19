import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/products_service.dart';
import '../../services/csv_service.dart';
import '../../models/types/product_types.dart';
import '../../services/master_data_service.dart';
import '../../services/sync_manager.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/csv_type_mapper.dart';
import '../../utils/debouncer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/dashboard/kpi_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../widgets/ui/shimmer_list_loader.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

enum ProductViewMode { small, medium, grid }

class ProductsManagementScreen extends StatefulWidget {
  final String? initialTypeFilter;
  final bool isMasterDataMode;
  final bool isReadOnly;
  final VoidCallback? onBack;

  const ProductsManagementScreen({
    super.key,
    this.initialTypeFilter,
    this.isMasterDataMode = false,
    this.isReadOnly = false,
    this.onBack,
  });

  @override
  State<ProductsManagementScreen> createState() =>
      _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  ProductsService get _productsService => context.read<ProductsService>();
  bool _isLoading = true;
  List<Product> _products = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  String? _selectedType;
  String _statusFilter = 'all'; // 'all', 'active', 'inactive'
  String _sortBy = 'name'; // 'name', 'price', 'stock', 'category'
  bool _sortAscending = true;
  ProductViewMode _viewMode = ProductViewMode.medium;
  final Set<String> _selectedProducts = {};
  List<String> _allTypeNames = [];
  MasterDataService get _masterDataService => context.read<MasterDataService>();
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocusChange);
    _selectedType = _normalizeTypeLabel(widget.initialTypeFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      _loadTypes();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _handleSearchFocusChange() {
    if (!_searchFocusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        _isSearchExpanded &&
        mounted) {
      setState(() => _isSearchExpanded = false);
    }
  }

  String? _normalizeTypeLabel(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    return ProductType.fromString(raw).value;
  }

  Future<void> _loadTypes() async {
    try {
      final types = await _masterDataService.getProductTypes();
      final normalizedTypeNames =
          types
              .map((t) => ProductType.fromString(t.name).value)
              .toSet()
              .toList()
            ..sort();
      if (mounted) {
        setState(() {
          _allTypeNames = normalizedTypeNames;
        });
      }
    } catch (e) {
      debugPrint('Error loading types: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productsService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _products;

    // Status filter
    if (_statusFilter == 'active') {
      filtered = filtered
          .where((p) => p.status.toLowerCase() == 'active')
          .toList();
    } else if (_statusFilter == 'inactive') {
      filtered = filtered
          .where((p) => p.status.toLowerCase() != 'active')
          .toList();
    }

    // Type filter
    if (_selectedType != null) {
      final selectedType = ProductType.fromString(_selectedType!).value;
      filtered = filtered
          .where(
            (p) =>
                ProductType.fromString(p.itemType.value).value == selectedType,
          )
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.sku.toLowerCase().contains(query),
          )
          .toList();
    }

    // Sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'stock':
          comparison = a.stock.compareTo(b.stock);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  int get _totalProducts => _products.length;
  int get _activeProducts =>
      _products.where((p) => p.status.toLowerCase() == 'active').length;

  int get _stockAlertCount {
    return _products.where((p) {
      if (p.status.toLowerCase() != 'active') return false;
      final stock = p.stock;
      final alertLevel = p.reorderLevel ?? p.minimumSafetyStock ?? 0.0;
      return stock <= alertLevel;
    }).length;
  }

  double get _totalCatalogValue {
    return _products
        .where((p) => p.status.toLowerCase() == 'active')
        .fold(0.0, (sum, p) => sum + (p.stock * p.price));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canManageProducts = context.select<AuthProvider, bool>(
      (auth) => auth.currentUser?.hasAdminOrStoreAccess ?? false,
    );
    final effectiveReadOnly = widget.isReadOnly || !canManageProducts;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(effectiveReadOnly),
          if (!widget.isMasterDataMode) _buildKPICards(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const ShimmerListLoader(hasAvatar: false, itemCount: 15)
                : _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductsView(effectiveReadOnly),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool effectiveReadOnly) {
    final theme = Theme.of(context);
    final normalizedInitialType = _normalizeTypeLabel(widget.initialTypeFilter);
    String title = 'Products';
    String subtitle = "Manage your company's product catalog.";
    String? helperText;
    Color color = const Color(0xFF4f46e5);
    IconData icon = Icons.inventory_2;
    String? emoji;

    switch (normalizedInitialType) {
      case 'Raw Material':
        title = 'Raw Materials';
        subtitle = 'Define raw chemicals & inputs used in production';
        helperText =
            'This is reference data only. Stock quantity and purchase entries are managed separately.';
        color = Colors.brown;
        icon = Icons.grain;
        emoji = null;
        break;
      case 'Packaging Material':
        title = 'Packaging Material';
        subtitle = 'Boxes, wrappers & containers for finished goods';
        helperText =
            'Used during finishing stage. Stock is tracked in inventory, not here.';
        color = AppColors.warning;
        icon = Icons.inventory_2;
        emoji = null;
        break;
      case 'Semi-Finished Good':
        title = 'Semi-Finished (Bhatti)';
        subtitle = 'Intermediate products from production stages';
        helperText =
            'Semi-finished items are not sold directly and are used only for further production.';
        color = Colors.deepOrange;
        icon = Icons.whatshot;
        emoji = null;
        break;
      case 'Finished Good':
        title = 'Finished Goods';
        subtitle = 'Final products available for sale';
        helperText =
            'Finished goods combine semi-finished items and packaging materials.';
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        emoji = null;
        break;
      case 'Traded Good':
        title = 'Traded Goods';
        subtitle = 'Products bought and sold directly';
        helperText =
            'Items that require no processing/manufacturing, just trading.';
        color = AppColors.info;
        icon = Icons.store;
        emoji = null;
        break;
      default:
        emoji = null;
    }

    final compactHeaderActions = Responsive.width(context) < 1320;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final actionHorizontalPadding = compactHeaderActions ? 8.0 : 12.0;
    final addButtonHorizontalPadding = compactHeaderActions ? 12.0 : 16.0;
    final actionIconSize = compactHeaderActions ? 16.0 : 18.0;
    final actionVisualDensity =
        compactHeaderActions && textScale <= 1.0
        ? VisualDensity.compact
        : VisualDensity.standard;
    final actionTextStyle = TextStyle(
      fontSize: compactHeaderActions ? 12 : 13,
      fontWeight: FontWeight.w600,
    );

    final actions = [
      if (!effectiveReadOnly) ...[
        Consumer2<AppSyncCoordinator, AuthProvider>(
          builder: (context, appSyncCoordinator, auth, _) {
            final isSyncing = appSyncCoordinator.isSyncing;
            final pending = appSyncCoordinator.pendingCount;
            final user = auth.currentUser;

            return OutlinedButton.icon(
              onPressed: (isSyncing || user == null)
                  ? null
                  : () async {
                      await appSyncCoordinator.syncAll(
                        user,
                        forceRefresh: true,
                      );
                      if (!mounted) return;
                      await _loadProducts();
                    },
              icon: isSyncing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Badge(
                      label: Text(pending.toString()),
                      isLabelVisible: pending > 0,
                      child: Icon(Icons.sync, size: actionIconSize),
                    ),
              label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isSyncing
                    ? theme.disabledColor
                    : theme.colorScheme.primary,
                textStyle: actionTextStyle,
                visualDensity: actionVisualDensity,
                padding: EdgeInsets.symmetric(
                  horizontal: actionHorizontalPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final csvService = context.read<CsvService>();
            try {
              final data = await csvService.pickAndParseCsv();
              if (!mounted) return;
              if (data.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No data found in CSV or file not selected'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Importing ${data.length} products...')),
              );

              int successCount = 0;
              List<String> errors = [];

              for (int i = 0; i < data.length; i++) {
                final row = data[i];
                final rowNum = i + 2;
                try {
                  await _productsService.createProduct(
                    name: row['name']?.toString() ?? 'Unnamed',
                    sku:
                        row['sku']?.toString() ??
                        'No-SKU-${DateTime.now().millisecondsSinceEpoch}',
                    category: row['category']?.toString() ?? 'Uncategorized',
                    itemType: CsvTypeMapper.toItemType(
                      row['type']?.toString(),
                    ).value,
                    type: CsvTypeMapper.toProductType(
                      row['type']?.toString(),
                    ).name,
                    stock:
                        double.tryParse(row['stock']?.toString() ?? '0') ?? 0.0,
                    baseUnit: row['baseunit']?.toString() ?? 'pcs',
                    conversionFactor:
                        double.tryParse(
                          row['conversionfactor']?.toString() ?? '1',
                        ) ??
                        1.0,
                    unitWeightGrams:
                        double.tryParse(
                          row['unitweightgrams']?.toString() ?? '0',
                        ) ??
                        0.0,
                    price:
                        double.tryParse(row['price']?.toString() ?? '0') ?? 0.0,
                    status: row['status']?.toString() ?? 'active',
                    userId:
                        context.read<AuthProvider>().currentUser?.id ??
                        'system_import',
                    unit: row['unit']?.toString() ?? 'pcs',
                  );
                  successCount++;
                } catch (e) {
                  final sku = row['sku'] ?? 'Unknown SKU';
                  errors.add('Row $rowNum ($sku): $e');
                  debugPrint('Error importing row $rowNum: $e');
                }
              }

              if (mounted) {
                _loadProducts();

                if (errors.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully imported $successCount products',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => ResponsiveAlertDialog(
                      title: Text('Import Completed with Errors'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imported: $successCount\nFailed: ${errors.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text('Errors:'),
                            const SizedBox(height: 5),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: errors.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      errors[index],
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
              }
            }
          },
          icon: Icon(Icons.upload_file_rounded, size: actionIconSize),
          label: const Text('Import CSV'),
          style: OutlinedButton.styleFrom(
            textStyle: actionTextStyle,
            visualDensity: actionVisualDensity,
            padding: EdgeInsets.symmetric(horizontal: actionHorizontalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showImportGuide,
          icon: const Icon(Icons.help_outline),
          tooltip: 'CSV Format Guide',
          style: IconButton.styleFrom(visualDensity: actionVisualDensity),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final csvService = context.read<CsvService>();
            try {
              await csvService.exportProducts(_filteredProducts);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export functionality initiated'),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
              }
            }
          },
          icon: Icon(Icons.ios_share_rounded, size: actionIconSize),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            textStyle: actionTextStyle,
            visualDensity: actionVisualDensity,
            padding: EdgeInsets.symmetric(horizontal: actionHorizontalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => context.go('/dashboard/management/master-data'),
          icon: Icon(Icons.settings_suggest_rounded, size: actionIconSize),
          label: const Text('Manage Masters'),
          style: OutlinedButton.styleFrom(
            textStyle: actionTextStyle,
            visualDensity: actionVisualDensity,
            padding: EdgeInsets.symmetric(horizontal: actionHorizontalPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await context.pushNamed(
              'management_product_new',
              queryParameters: {'type': widget.initialTypeFilter},
            );
            if (result != null && mounted) {
              _loadProducts();
            }
          },
          icon: Icon(Icons.add, size: actionIconSize),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: theme.colorScheme.onPrimary,
            textStyle: actionTextStyle,
            visualDensity: actionVisualDensity,
            padding: EdgeInsets.symmetric(
              horizontal: addButtonHorizontalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ];

    return MasterScreenHeader(
      title: title,
      subtitle: subtitle,
      helperText: widget.isMasterDataMode ? helperText : null,
      color: color,
      icon: icon,
      emoji: emoji,
      actions: actions,
      actionsInline: !compactHeaderActions,
      forceActionsBelowTitle: compactHeaderActions,
      inlineTitleFlex: compactHeaderActions ? 2 : 3,
      inlineActionsFlex: compactHeaderActions ? 6 : 3,
      onBack: widget.onBack,
      isReadOnly: effectiveReadOnly,
    );
  }

  Widget _buildKPICards() {
    // Collect unique categories
    final categories = _products.map((p) => p.category).toSet().length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: Responsive.clamp(context, min: 160, max: 220, ratio: 0.2),
            child: KPICard(
              title: 'Total Products',
              value: _totalProducts.toString(),
              subtitle: '$_activeProducts Active',
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF6366f1),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: Responsive.clamp(context, min: 160, max: 220, ratio: 0.2),
            child: KPICard(
              title: 'Categories',
              value: categories.toString(),
              subtitle: 'Across catalog',
              icon: Icons.category_outlined,
              color: const Color(0xFFd946ef),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: Responsive.clamp(context, min: 160, max: 220, ratio: 0.2),
            child: KPICard(
              title: 'Total Value',
              value: 'Rs ${(_totalCatalogValue).toStringAsFixed(0)}',
              subtitle: 'Inventory valuation',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF22c55e),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: Responsive.clamp(context, min: 160, max: 220, ratio: 0.2),
            child: KPICard(
              title: 'Stock Alerts',
              value: _stockAlertCount.toString(),
              subtitle: 'Low Stock Items',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFf97316),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasSearchText = _searchController.text.trim().isNotEmpty;
          final searchExpanded = _isSearchExpanded || hasSearchText;
          final viewportWidth = Responsive.width(context);
          final useDesktopSingleRow = viewportWidth >= Responsive.tabletBreakpoint;
          final textScale = MediaQuery.textScalerOf(context).scale(1.0).clamp(
            1.0,
            1.3,
          );
          final isSmall = constraints.maxWidth < Responsive.smallBreakpoint;
          final isMedium = constraints.maxWidth >= Responsive.smallBreakpoint &&
              constraints.maxWidth < Responsive.mediumBreakpoint;
          final gap = isSmall ? 6.0 : 8.0;

          final filtersWidth = (108.0 * textScale).clamp(108.0, 128.0).toDouble();
          final viewWidth = (108.0 * textScale).clamp(104.0, 132.0).toDouble();
          final statusWidth = (96.0 * textScale).clamp(92.0, 120.0).toDouble();
          final typeWidth = isSmall ? 176.0 : isMedium ? 210.0 : 240.0;
          final sortWidth = isSmall ? 124.0 : 136.0;
          final desktopMinControlsWidth =
              filtersWidth +
              viewWidth +
              statusWidth +
              statusWidth +
              typeWidth +
              sortWidth +
              40.0 + // sort direction
              (gap * 6);
          final expandedSearchWidth = useDesktopSingleRow
              ? (constraints.maxWidth - desktopMinControlsWidth)
                    .clamp(220.0, 680.0)
                    .toDouble()
              : isSmall
              ? (constraints.maxWidth * 0.42).clamp(180.0, 280.0).toDouble()
              : (constraints.maxWidth * 0.38).clamp(240.0, 420.0).toDouble();
          final controls = <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: searchExpanded ? expandedSearchWidth : 44,
              child: _buildExpandableSearch(theme, searchExpanded),
            ),
            SizedBox(width: filtersWidth, child: _buildFiltersButton()),
            SizedBox(width: viewWidth, child: _buildViewModeToggle()),
            _buildStatusToggle('Active', 'active', AppColors.success),
            _buildStatusToggle('Inactive', 'inactive', AppColors.error),
            SizedBox(width: typeWidth, child: _buildTypeDropdown()),
            SizedBox(width: sortWidth, child: _buildSortDropdown()),
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => setState(() => _sortAscending = !_sortAscending),
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                ),
                tooltip: _sortAscending ? 'Ascending' : 'Descending',
              ),
            ),
          ];

          if (useDesktopSingleRow) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _joinWithHorizontalSpacing(controls, gap),
              ),
            );
          }

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: controls,
          );
        },
      ),
    );
  }

  List<Widget> _joinWithHorizontalSpacing(List<Widget> children, double gap) {
    if (children.length <= 1) return children;
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i != children.length - 1) {
        result.add(SizedBox(width: gap));
      }
    }
    return result;
  }

  Widget _buildExpandableSearch(ThemeData theme, bool expanded) {
    if (!expanded) {
      return Tooltip(
        message: 'Search',
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _expandSearchField,
          child: Ink(
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              color: theme.colorScheme.surface,
            ),
            child: Center(
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Search products by name or SKU...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: _searchController.text.trim().isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  _searchController.clear();
                  _debouncer.run(() {
                    if (!mounted) return;
                    setState(() => _searchQuery = '');
                  });
                  _collapseSearchIfEmpty();
                },
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      onTap: _expandSearchField,
      onChanged: (val) {
        _debouncer.run(() {
          if (!mounted) return;
          setState(() => _searchQuery = val);
        });
      },
    );
  }

  void _expandSearchField() {
    if (!_isSearchExpanded && mounted) {
      setState(() => _isSearchExpanded = true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _collapseSearchIfEmpty() {
    if (_searchController.text.trim().isNotEmpty) return;
    if (_searchFocusNode.hasFocus) return;
    if (_isSearchExpanded && mounted) {
      setState(() => _isSearchExpanded = false);
    }
  }

  Widget _buildFiltersButton() {
    return Tooltip(
      message: 'Advanced filters are coming soon.',
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.filter_list, size: 18),
        label: const Text('Filters'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    final theme = Theme.of(context);
    return PopupMenuButton<ProductViewMode>(
      tooltip: 'View Mode',
      onSelected: (mode) {
        if (_viewMode == mode) return;
        setState(() => _viewMode = mode);
      },
      itemBuilder: (context) => [
        PopupMenuItem<ProductViewMode>(
          value: ProductViewMode.small,
          child: Row(
            children: [
              Icon(
                Icons.view_headline_rounded,
                size: 18,
                color: _viewMode == ProductViewMode.small
                    ? theme.colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              const Text('Small'),
            ],
          ),
        ),
        PopupMenuItem<ProductViewMode>(
          value: ProductViewMode.medium,
          child: Row(
            children: [
              Icon(
                Icons.view_list_rounded,
                size: 18,
                color: _viewMode == ProductViewMode.medium
                    ? theme.colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              const Text('Medium'),
            ],
          ),
        ),
        PopupMenuItem<ProductViewMode>(
          value: ProductViewMode.grid,
          child: Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: _viewMode == ProductViewMode.grid
                    ? theme.colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 8),
              const Text('Grid'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_viewModeIcon(_viewMode), size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _viewModeLabel(_viewMode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _viewModeLabel(ProductViewMode mode) {
    switch (mode) {
      case ProductViewMode.small:
        return 'Small';
      case ProductViewMode.medium:
        return 'Medium';
      case ProductViewMode.grid:
        return 'Grid';
    }
  }

  IconData _viewModeIcon(ProductViewMode mode) {
    switch (mode) {
      case ProductViewMode.small:
        return Icons.view_headline_rounded;
      case ProductViewMode.medium:
        return Icons.view_list_rounded;
      case ProductViewMode.grid:
        return Icons.grid_view_rounded;
    }
  }

  Widget _buildStatusToggle(String label, String value, Color activeColor) {
    final theme = Theme.of(context);
    final isSelected = _statusFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _statusFilter = isSelected ? 'all' : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.outlineVariant
                : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('product_type_dropdown'),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedType,
          isExpanded: true,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          dropdownColor: theme.cardColor,
          hint: Text(
            'All Types',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          items: () {
            final Set<String> typeNames = {};
            if (_allTypeNames.isNotEmpty) {
              typeNames.addAll(_allTypeNames);
            } else {
              typeNames.addAll([
                'Raw Material',
                'Finished Good',
                'Traded Good',
                'Semi-Finished Good',
                'Oils & Liquids',
                'Packaging Material',
                'Chemicals & Additives',
              ]);
            }
            if (_selectedType != null) typeNames.add(_selectedType!);

            return [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ...typeNames.map(
                (name) => DropdownMenuItem(
                  value: name,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ];
          }(),
          onChanged: (val) =>
              setState(() => _selectedType = _normalizeTypeLabel(val)),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('product_sort_dropdown'),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: true,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          dropdownColor: theme.cardColor,
          items: const [
            DropdownMenuItem(
              value: 'name',
              child: Text('Name', style: TextStyle(fontSize: 13)),
            ),
            DropdownMenuItem(
              value: 'price',
              child: Text('Price', style: TextStyle(fontSize: 13)),
            ),
            DropdownMenuItem(
              value: 'stock',
              child: Text('Stock', style: TextStyle(fontSize: 13)),
            ),
            DropdownMenuItem(
              value: 'category',
              child: Text('Category', style: TextStyle(fontSize: 13)),
            ),
          ],
          onChanged: (val) => setState(() => _sortBy = val!),
        ),
      ),
    );
  }

  Future<void> _openProductForm(
    Product product, {
    required bool readOnly,
  }) async {
    final result = await context.pushNamed(
      'management_product_new',
      queryParameters: {
        'type': product.itemType.value,
        if (readOnly) 'readOnly': 'true',
        'masterMode': widget.isMasterDataMode ? 'true' : 'false',
      },
      extra: product,
    );
    if (!readOnly && result != null && mounted) {
      _loadProducts();
    }
  }

  String _formatPercent(double? value) {
    if (value == null) return '-';
    final sanitized = value.isNaN || value.isInfinite ? 0.0 : value;
    if (sanitized == sanitized.truncateToDouble()) {
      return '${sanitized.toStringAsFixed(0)}%';
    }
    return '${sanitized.toStringAsFixed(1)}%';
  }

  bool _isSemiFinishedProduct(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value).value;
    if (normalizedType == ProductType.semiFinishedGood.value) return true;

    final entityType = (product.entityType ?? '').toLowerCase().trim();
    if (entityType == 'semi_finished') return true;

    return product.itemType.value.toLowerCase().contains('semi');
  }

  String _formatQtyCompact(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.0001) {
      return rounded.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _formatSemiStockInBox(Product product) {
    final stock = product.stock.isFinite ? product.stock : 0.0;
    final unit = product.baseUnit.trim().toLowerCase();
    final secondaryUnit = (product.secondaryUnit ?? '').trim().toLowerCase();

    if (unit.contains('box')) {
      return '${_formatQtyCompact(stock)} Box';
    }

    final boxWeightKg = product.unitWeightGrams > 0
        ? product.unitWeightGrams / 1000.0
        : 0.0;

    if ((unit == 'kg' || unit.contains('kilogram')) && boxWeightKg > 0) {
      final boxes = stock / boxWeightKg;
      return '${_formatQtyCompact(boxes)} Box';
    }

    if (unit.contains('bag') || unit.contains('sack')) {
      final boxesPerBag =
          (product.boxesPerBatch ??
                  product.standardBatchOutputPcs?.round() ??
                  0)
              .toDouble();
      if (boxesPerBag > 0) {
        return '${_formatQtyCompact(stock * boxesPerBag)} Box';
      }

      final factor = product.conversionFactor;
      if (secondaryUnit.contains('box') && factor.isFinite && factor > 0) {
        return '${_formatQtyCompact(stock * factor)} Box';
      }
    }

    return '${_formatQtyCompact(stock)} Box';
  }

  String _formatStockForDisplay(Product product) {
    if (_isSemiFinishedProduct(product)) {
      return _formatSemiStockInBox(product);
    }
    return '${product.stock.toStringAsFixed(0)} ${product.baseUnit}';
  }

  String _resolveSemiBhattiSource(Product product) {
    final tokens = <String?>[
      product.departmentId,
      ...product.allowedDepartmentIds,
      product.name,
    ];

    bool hasGita = false;
    bool hasSona = false;
    bool hasBhatti = false;

    for (final token in tokens) {
      final value = (token ?? '').trim().toLowerCase();
      if (value.isEmpty) continue;
      if (value.contains('gita') || value.contains('geeta')) hasGita = true;
      if (value.contains('sona')) hasSona = true;
      if (value.contains('bhatti')) hasBhatti = true;
    }

    if (hasGita && hasSona) return 'Sona/Gita Bhatti';
    if (hasGita) return 'Gita Bhatti';
    if (hasSona) return 'Sona Bhatti';
    if (hasBhatti) return 'Sona Bhatti';
    return 'Bhatti';
  }

  String _productionSource(Product product) {
    if (_isSemiFinishedProduct(product)) {
      return _resolveSemiBhattiSource(product);
    }

    if (product.productionStage != null) {
      return product.productionStage!.value;
    }

    final entityType = (product.entityType ?? '').toLowerCase();
    if (entityType == 'semi_finished') return 'Bhatti';
    if (entityType == 'finished') return 'Finishing';
    if (entityType == 'formula_output') return 'Formula Output';

    final itemType = product.itemType.value.toLowerCase();
    if (itemType.contains('semi')) return 'Bhatti';
    if (itemType.contains('finished')) {
      return product.allowedSemiFinishedIds.isNotEmpty
          ? 'Semi + Packing'
          : 'Finishing';
    }
    if (itemType.contains('packaging')) return 'Packaging Supply';
    if (itemType.contains('traded')) return 'Direct Purchase';
    if (itemType.contains('raw') ||
        itemType.contains('chemical') ||
        itemType.contains('oil') ||
        itemType.contains('liquid')) {
      return 'Procurement';
    }
    return '-';
  }

  String _packingType(Product product) {
    if (_isSemiFinishedProduct(product)) return '-';

    if (product.packagingType != null) {
      return product.packagingType!.value;
    }
    final unitsPerBundle = product.unitsPerBundle;
    if (unitsPerBundle != null && unitsPerBundle > 0) {
      return '$unitsPerBundle / Bundle';
    }
    if (product.itemType.value.toLowerCase().contains('packaging')) {
      return 'Packaging RM';
    }
    if (product.itemType.value.toLowerCase().contains('finished')) {
      return 'Standard Pack';
    }
    return '-';
  }

  Widget _buildProductsView(bool effectiveReadOnly) {
    switch (_viewMode) {
      case ProductViewMode.small:
        return _buildCompactListView(effectiveReadOnly);
      case ProductViewMode.medium:
        return _buildDataTable(effectiveReadOnly);
      case ProductViewMode.grid:
        return _buildGridView(effectiveReadOnly);
    }
  }

  Widget _buildCompactListView(bool effectiveReadOnly) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final products = _filteredProducts;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        separatorBuilder: (context, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = _selectedProducts.contains(product.id);
          final isActive = product.status.toLowerCase() == 'active';
          return Container(
            key: ValueKey('compact_product_${product.id}'),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Checkbox(
                      value: isSelected,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedProducts.add(product.id);
                          } else {
                            _selectedProducts.remove(product.id);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () =>
                        _openProductForm(product, readOnly: effectiveReadOnly),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildProductImage(
                          product.localImagePath,
                          20,
                          theme,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          _openProductForm(product, readOnly: effectiveReadOnly),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isActive
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                              ),
                            ),
                            Text(
                              product.sku,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.category} | ${product.itemType.value}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 98, maxWidth: 112),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _isSemiFinishedProduct(product)
                              ? '-'
                              : 'Rs ${product.price.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isActive
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatStockForDisplay(product),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 92,
                          child: _buildStatusBadge(product.status, compact: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  _buildProductActionsMenu(
                    product,
                    effectiveReadOnly: effectiveReadOnly,
                    compact: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(bool effectiveReadOnly) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final products = _filteredProducts;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final textScale =
              MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.4);
          const spacing = 12.0;
          const horizontalPadding = 24.0; // GridView padding: 12 left + 12 right
          final maxTileWidth = width >= 1800
              ? 340.0
              : width >= 1400
              ? 320.0
              : width >= Responsive.tabletBreakpoint
              ? 300.0
              : 360.0;
          final effectiveTileWidth = (width - horizontalPadding)
              .clamp(220.0, maxTileWidth)
              .toDouble();
          final imageSectionHeight = effectiveTileWidth * (9 / 16);
          final metadataSectionHeight = (200.0 * textScale)
              .clamp(200.0, 280.0)
              .toDouble();
          final tileHeight = imageSectionHeight + metadataSectionHeight;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxTileWidth,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: tileHeight,
            ),
            itemBuilder: (context, index) => _buildGridCard(
              products[index],
              effectiveReadOnly: effectiveReadOnly,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridCard(
    Product product, {
    required bool effectiveReadOnly,
  }) {
    final theme = Theme.of(context);
    final isActive = product.status.toLowerCase() == 'active';
    return Material(
      key: ValueKey('grid_product_${product.id}'),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openProductForm(product, readOnly: effectiveReadOnly),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.28),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProductImage(
                              product.localImagePath,
                              56,
                              theme,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildProductActionsMenu(
                              product,
                              effectiveReadOnly: effectiveReadOnly,
                              compact: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isActive
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.sku,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.itemType.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _isSemiFinishedProduct(product)
                                  ? '-'
                                  : 'Rs ${product.price.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isActive
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatStockForDisplay(product),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildStatusBadge(product.status, compact: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductActionsMenu(
    Product product, {
    required bool effectiveReadOnly,
    bool compact = false,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: Icon(Icons.more_vert_rounded, size: compact ? 18 : 20),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: compact ? 32 : 36,
        minHeight: compact ? 32 : 36,
      ),
      onSelected: (value) =>
          _handleProductMenuAction(value, product, effectiveReadOnly),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: AppColors.info),
              SizedBox(width: 8),
              Text('View'),
            ],
          ),
        ),
        if (!effectiveReadOnly)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 16, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _handleProductMenuAction(
    String value,
    Product product,
    bool effectiveReadOnly,
  ) async {
    if (value == 'view') {
      await _openProductForm(product, readOnly: true);
      return;
    }
    if (value == 'edit' && !effectiveReadOnly) {
      await _openProductForm(product, readOnly: false);
    }
  }

  Widget _buildDataTable(bool effectiveReadOnly) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final compactTable = viewportWidth < 1160;
          final showingSemiOnly =
              _selectedType == ProductType.semiFinishedGood.value;
          final showFinancialColumns = !showingSemiOnly;
          final minTableWidth = showFinancialColumns
              ? (compactTable ? 980.0 : 1180.0)
              : (compactTable ? 860.0 : 1020.0);
          final tableWidth = viewportWidth < minTableWidth
              ? minTableWidth
              : viewportWidth;
          final headerTextStyle = TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: compactTable ? 9 : 10,
            letterSpacing: compactTable ? 0.7 : 1,
          );
          final bodyFontSize = compactTable ? 11.0 : 12.0;
          final titleFontSize = compactTable ? 12.0 : 13.0;
          final skuFontSize = compactTable ? 8.0 : 9.0;
          final rowHorizontalPadding = compactTable ? 4.0 : 8.0;
          final rowVerticalPadding = compactTable ? 1.0 : 2.0;
          final checkboxGap = compactTable ? 8.0 : 16.0;
          final nameCellHorizontalPadding = compactTable ? 2.0 : 4.0;
          final nameCellVerticalPadding = compactTable ? 4.0 : 6.0;
          final actionColumnWidth = compactTable ? 50.0 : 64.0;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rowHorizontalPadding,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Checkbox(
                            value:
                                _selectedProducts.length ==
                                    _filteredProducts.length &&
                                _filteredProducts.isNotEmpty,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedProducts.addAll(
                                    _filteredProducts.map((p) => p.id),
                                  );
                                } else {
                                  _selectedProducts.clear();
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: checkboxGap),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'PRODUCT NAME',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'CATEGORY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'TYPE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'SOURCE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PACKING',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        if (showFinancialColumns)
                          Expanded(
                            flex: 1,
                            child: Text(
                              'GST %',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: headerTextStyle,
                            ),
                          ),
                        if (showFinancialColumns)
                          Expanded(
                            flex: 1,
                            child: Text(
                              'DISC %',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: headerTextStyle,
                            ),
                          ),
                        if (showFinancialColumns)
                          Expanded(
                            flex: 1,
                            child: Text(
                              'PRICE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: headerTextStyle,
                            ),
                          ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'STOCK',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'STATUS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                          ),
                        ),
                        SizedBox(
                          width: actionColumnWidth,
                          child: Text(
                            'ACTIONS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: headerTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _filteredProducts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected = _selectedProducts.contains(
                          product.id,
                        );
                        final isActive =
                            product.status.toLowerCase() == 'active';

                        final isDark = theme.brightness == Brightness.dark;

                        return Container(
                          key: ValueKey('table_product_${product.id}'),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3)
                                : theme.colorScheme.surface,
                            border: Border.all(
                              color: isDark
                                  ? theme.colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    )
                                  : theme.colorScheme.outlineVariant,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: rowHorizontalPadding,
                            vertical: rowVerticalPadding,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Checkbox(
                                  value: isSelected,
                                  visualDensity: compactTable
                                      ? VisualDensity.compact
                                      : VisualDensity.standard,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedProducts.add(product.id);
                                      } else {
                                        _selectedProducts.remove(product.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: checkboxGap),
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _openProductForm(
                                    product,
                                    readOnly: effectiveReadOnly,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: nameCellVerticalPadding,
                                      horizontal: nameCellHorizontalPadding,
                                    ),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        Container(
                                          width: compactTable ? 32 : 40,
                                          height: compactTable ? 32 : 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: _buildProductImage(
                                              product.localImagePath,
                                              compactTable ? 16 : 20,
                                              theme,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: compactTable ? 8 : 12),
                                        // Product Name & SKU
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: titleFontSize,
                                                  color: isActive
                                                      ? theme.colorScheme.onSurface
                                                      : theme.colorScheme.onSurface
                                                            .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              Text(
                                                product.sku,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.3),
                                                  fontSize: skuFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  product.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.8)
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  product.itemType.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.8)
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _productionSource(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.8)
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _packingType(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.8)
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              if (showFinancialColumns)
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    _isSemiFinishedProduct(product)
                                        ? '-'
                                        : _formatPercent(product.gstRate),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              if (showFinancialColumns)
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    _isSemiFinishedProduct(product)
                                        ? '-'
                                        : _formatPercent(
                                            product.defaultDiscount,
                                          ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              if (showFinancialColumns)
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    _isSemiFinishedProduct(product)
                                        ? '-'
                                        : 'Rs ${product.price.toStringAsFixed(2)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  _formatStockForDisplay(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: _buildStatusBadge(
                                  product.status,
                                  compact: compactTable,
                                ),
                              ),
                              SizedBox(
                                width: actionColumnWidth,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: PopupMenuButton<String>(
                                    tooltip: 'Actions',
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      size: compactTable ? 18 : 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: compactTable ? 32 : 36,
                                      minHeight: compactTable ? 32 : 36,
                                    ),
                                    onSelected: (value) async {
                                      if (value == 'view') {
                                        await _openProductForm(
                                          product,
                                          readOnly: true,
                                        );
                                      } else if (value == 'edit' &&
                                          !effectiveReadOnly) {
                                        await _openProductForm(
                                          product,
                                          readOnly: false,
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.visibility_outlined,
                                              size: 16,
                                              color: AppColors.info,
                                            ),
                                            SizedBox(width: 8),
                                            Text('View'),
                                          ],
                                        ),
                                      ),
                                      if (!effectiveReadOnly)
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                size: 16,
                                                color: AppColors.warning,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status, {bool compact = false}) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? AppColors.success : AppColors.error;
    final label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: color,
            size: compact ? 10 : 12,
          ),
          SizedBox(width: compact ? 3 : 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: compact ? 9 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showImportGuide() {
    showDialog(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.info),
            SizedBox(width: 8),
            Text('CSV Import Guide'),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.clamp(
              context,
              min: 320,
              max: 640,
              ratio: 0.92,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'To import products successfully, your CSV file must follow specific formatting rules.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Required Columns:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 8),
                _buildGuideRow('Name', 'Product Name (e.g., "Gita 100g")'),
                _buildGuideRow('SKU', 'Unique Code (e.g., "FG-GIT-100")'),
                _buildGuideRow(
                  'Type',
                  'Product Type (Crucial for categorization)',
                ),

                const SizedBox(height: 16),
                const Text(
                  'Valid "Type" Values:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTypeGuideRow(
                  'Finished Good',
                  'Final products ready for sale (e.g., Soap Bars)',
                ),
                _buildTypeGuideRow(
                  'Traded Good',
                  'Items bought and sold without manufacturing',
                ),
                _buildTypeGuideRow(
                  'Raw Material',
                  'Ingredients used in production (e.g., Oil, Chemicals)',
                ),
                _buildTypeGuideRow(
                  'Semi Finished',
                  'Intermediate products (e.g., Soap Base)',
                ),

                const SizedBox(height: 16),
                const Text(
                  'Other Columns (Optional):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Category, Price, Stock, Unit (kg/pcs), Description, Status',
                  style: TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.info),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Use the "Export Template" button to get a pre-formatted CSV file with examples.',
                          style: TextStyle(fontSize: 13, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String? _sanitizeImagePath(String? rawPath) {
    if (rawPath == null) return null;
    final trimmed = rawPath.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _isAppDocumentsPath(String path) {
    final normalized = path.replaceAll('\\', '/').toLowerCase();
    return normalized.startsWith('app_documents/');
  }

  bool _isAbsoluteFilePath(String path) {
    final normalized = path.trim();
    return normalized.startsWith('/') ||
        normalized.startsWith('\\') ||
        RegExp(r'^[a-zA-Z]:[\\\/]').hasMatch(normalized);
  }

  Widget _buildProductImage(
    String? imagePath,
    double iconSize,
    ThemeData theme, {
    BoxFit fit = BoxFit.cover,
  }) {
    final normalizedPath = _sanitizeImagePath(imagePath);
    if (normalizedPath == null) {
      return _buildImagePlaceholder(iconSize, theme);
    }

    final isFilePath =
        _isAppDocumentsPath(normalizedPath) || _isAbsoluteFilePath(normalizedPath);
    if (isFilePath) {
      return FutureBuilder<File?>(
        future: _resolveImageFile(normalizedPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: fit,
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder(
                  iconSize,
                  theme,
                  icon: Icons.broken_image,
                );
              },
            );
          }

          return _buildImagePlaceholder(iconSize, theme);
        },
      );
    }

    return Image.asset(
      normalizedPath,
      fit: fit,
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(iconSize, theme);
      },
    );
  }

  Widget _buildImagePlaceholder(
    double iconSize,
    ThemeData theme, {
    IconData icon = Icons.inventory_2_outlined,
  }) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.26),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<File?> _resolveImageFile(String imagePath) async {
    final sanitized = _sanitizeImagePath(imagePath);
    if (sanitized == null) return null;
    try {
      String? fullPath;
      if (_isAppDocumentsPath(sanitized)) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final relativePath = sanitized
            .replaceAll('\\', '/')
            .replaceFirst(RegExp(r'^app_documents/+', caseSensitive: false), '');
        fullPath =
            '${appDocDir.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}';
      } else if (_isAbsoluteFilePath(sanitized)) {
        fullPath = sanitized;
      } else {
        return null;
      }

      final file = File(fullPath);
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('Failed to resolve image: $e');
    }
    return null;
  }

  Widget _buildGuideRow(String label, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Responsive.clamp(context, min: 72, max: 96, ratio: 0.1),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildTypeGuideRow(String label, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.clamp(
                context,
                min: 100,
                max: 140,
                ratio: 0.14,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
