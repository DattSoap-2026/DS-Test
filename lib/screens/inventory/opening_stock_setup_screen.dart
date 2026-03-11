import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth/auth_provider.dart';
import '../../services/opening_stock_service.dart';
import '../../services/products_service.dart';
import '../../services/warehouse_service.dart';
import '../../models/types/product_types.dart';
import '../../models/inventory/warehouse.dart';
import '../../utils/responsive.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/themed_filter_chip.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import '../../utils/unit_converter.dart';
import '../../utils/app_toast.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class OpeningStockSetupScreen extends StatefulWidget {
  const OpeningStockSetupScreen({super.key});

  @override
  State<OpeningStockSetupScreen> createState() =>
      _OpeningStockSetupScreenState();
}

class _OpeningStockSetupScreenState extends State<OpeningStockSetupScreen> {
  static const int _productFlex = 5;
  static const int _qtyFlex = 3;
  static const int _rateFlex = 2;
  static const double _actionWidth = 44;
  static const String _allTypeFilterKey = '__all__';
  static const List<String> _typeFilters = [
    'Raw Material',
    'Semi-Finished Good',
    'Finished Good',
    'Traded Good',
    'Packaging Material',
    'Oils & Liquids',
    'Chemicals & Additives',
  ];

  late final OpeningStockService _openingService;
  late final ProductsService _productsService;
  late final WarehouseService _warehouseService;

  bool _isLoading = true;
  bool _isSystemLocked = false;
  List<Product> _allProducts = [];
  List<Warehouse> _warehouses = [];
  String? _selectedWarehouseId;

  // Form State
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, TextEditingController> _secondaryQtyControllers = {};
  final Map<String, TextEditingController> _rateControllers = {};

  // Filter State
  String _searchQuery = '';
  String? _selectedTypeFilter;
  final ScrollController _typeFilterScrollController = ScrollController();
  late final Map<String, GlobalKey> _typeFilterChipKeys;

  // Cache for existing opening stocks (ProductId -> WarehouseId -> Qty)
  final Map<String, Map<String, double>> _openingStocks = {};

  // Cache for saved states (Product ID -> bool)
  final Map<String, bool> _savedProducts = {};
  final Map<String, bool> _savingProducts = {};

  @override
  void initState() {
    super.initState();
    _typeFilterChipKeys = {
      _allTypeFilterKey: GlobalKey(),
      for (final type in _typeFilters) type: GlobalKey(),
    };
    _openingService = context.read<OpeningStockService>();
    _productsService = context.read<ProductsService>();
    _warehouseService = context.read<WarehouseService>();
    _checkLockAndLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedTypeFilter(animate: false);
    });
  }

  Future<void> _checkLockAndLoad() async {
    setState(() => _isLoading = true);

    _isSystemLocked = await _openingService.isSystemLocked();

    if (_isSystemLocked) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final products = await _productsService.getProducts();
      final warehouseResult = await _warehouseService.getWarehouseOptions();
      final allOpenings = await _openingService.getAllOpeningStocks();

      if (mounted) {
        setState(() {
          _allProducts = products.where((p) => p.status == 'active').toList();
          _warehouses = warehouseResult.warehouses;
          _selectedWarehouseId = _warehouses.isNotEmpty ? _warehouses.first.id : null;

          _openingStocks.clear();
          for (final entry in allOpenings) {
            _openingStocks.putIfAbsent(entry.productId, () => {})[entry.warehouseId] = entry.quantity;
            _savedProducts[entry.productId] = true;
          }

          for (var p in _allProducts) {
            _qtyControllers[p.id] = TextEditingController(text: '0');
            _secondaryQtyControllers[p.id] = TextEditingController(text: '0');
            _rateControllers[p.id] = TextEditingController();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error loading data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var c in _qtyControllers.values) {
      c.dispose();
    }
    for (var c in _secondaryQtyControllers.values) {
      c.dispose();
    }
    for (var c in _rateControllers.values) {
      c.dispose();
    }
    _typeFilterScrollController.dispose();
    super.dispose();
  }

  void _centerSelectedTypeFilter({bool animate = true}) {
    final key = _selectedTypeFilter ?? _allTypeFilterKey;
    final targetContext = _typeFilterChipKeys[key]?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      duration: animate ? const Duration(milliseconds: 220) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  void _setSelectedTypeFilter(String? type) {
    setState(() {
      if (type == null) {
        _selectedTypeFilter = null;
      } else {
        _selectedTypeFilter = _selectedTypeFilter == type ? null : type;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedTypeFilter();
    });
  }

  List<Product> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType =
          _selectedTypeFilter == null ||
          p.itemType.value == _selectedTypeFilter;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isSystemLocked) {
      return Scaffold(
        body: Column(
          children: [
            MasterScreenHeader(
              title: 'Opening Stock Setup',
              subtitle: 'System currently locked',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'System Locked',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Opening stock entry is disabled after Go-Live.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'GO BACK',
                      onPressed: () => context.pop(),
                      variant: ButtonVariant.outline,
                      width: Responsive.clamp(
                        context,
                        min: 180,
                        max: 260,
                        ratio: 0.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Opening Stock',
            subtitle: 'Establish initial inventory balances',
            icon: Icons.inventory_2_rounded,
            color: theme.colorScheme.primary,
            onBack: () => context.pop(),
            actions: [
              CustomButton(
                label: 'LOCK SYSTEM',
                icon: Icons.lock_rounded,
                variant: ButtonVariant.danger,
                isDense: true,
                onPressed: _confirmGoLive,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _checkLockAndLoad,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Data',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          Expanded(child: _buildScrollableContent(theme)),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(ThemeData theme) {
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = isMobile ? 4.0 : 16.0;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildTopControls(theme)),
        SliverToBoxAdapter(child: _buildFilterBar(theme)),
        if (_filteredProducts.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
        else ...[
          if (!isMobile)
            SliverToBoxAdapter(
              child: _buildTableHeader(
                theme,
                horizontalPadding: horizontalPadding,
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              40,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildCompactProductRow(_filteredProducts[index], theme);
              }, childCount: _filteredProducts.length),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTopControls(ThemeData theme) {
    final isMobile = Responsive.isMobile(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isMobile ? 10 : 16, 16, 8),
      child: GlassContainer(
        padding: EdgeInsets.all(isMobile ? 14 : 24),
        borderRadius: isMobile ? 18 : 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warehouse_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'SOURCE WAREHOUSE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                final warehouseField = Container(
                  key: const ValueKey('opening-stock-warehouse-selector'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Warehouse',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedWarehouseId,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: _warehouses.map((warehouse) {
                          return DropdownMenuItem(
                            value: warehouse.id,
                            child: Text(
                              warehouse.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedWarehouseId = value);
                        },
                      ),
                    ],
                  ),
                );
                final searchField = TextFormField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search product or SKU...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ).applyDefaults(theme.inputDecorationTheme),
                );
                if (isNarrow) {
                  return Column(
                    children: [
                      warehouseField,
                      const SizedBox(height: 12),
                      searchField,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: warehouseField),
                    const SizedBox(width: 16),
                    Expanded(child: searchField),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        SizedBox(height: isMobile ? 4 : 8),
        SingleChildScrollView(
          controller: _typeFilterScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Padding(
                key: _typeFilterChipKeys[_allTypeFilterKey],
                padding: const EdgeInsets.only(right: 8),
                child: ThemedFilterChip(
                  label: 'ALL',
                  selected: _selectedTypeFilter == null,
                  onSelected: () => _setSelectedTypeFilter(null),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ..._typeFilters.map((type) {
                final isSelected = _selectedTypeFilter == type;
                return Padding(
                  key: _typeFilterChipKeys[type],
                  padding: const EdgeInsets.only(right: 8),
                  child: ThemedFilterChip(
                    label: type.toUpperCase(),
                    selected: isSelected,
                    onSelected: () => _setSelectedTypeFilter(type),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    textStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
      ],
    );
  }

  Widget _buildTableHeader(ThemeData theme, {double horizontalPadding = 16}) {
    final isMobile = Responsive.isMobile(context);
    final productFlex = isMobile ? 7 : _productFlex;
    final qtyFlex = isMobile ? 2 : _qtyFlex;
    final rateFlex = isMobile ? 2 : _rateFlex;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.6,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
      child: Row(
        children: [
          Expanded(
            flex: productFlex,
            child: Text('PRODUCT', style: labelStyle),
          ),
          Expanded(
            flex: qtyFlex,
            child: Text('QTY (SEC + BASE)', style: labelStyle),
          ),
          Expanded(
            flex: rateFlex,
            child: Text('RATE', style: labelStyle),
          ),
          SizedBox(
            width: _actionWidth,
            child: Text('ACT', style: labelStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProductRow(Product product, ThemeData theme) {
    final isSaved = _savedProducts[product.id] ?? false;
    final isMobile = Responsive.isMobile(context);
    final productFlex = isMobile ? 7 : _productFlex;
    final qtyFlex = isMobile ? 2 : _qtyFlex;
    final rateFlex = isMobile ? 2 : _rateFlex;
    final columnGap = isMobile ? 8.0 : 12.0;

    return AnimatedCard(
      child: GlassContainer(
        margin: EdgeInsets.symmetric(vertical: isMobile ? 2 : 4),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 10 : 12,
        ),
        borderRadius: 16,
        borderColor: isSaved ? theme.colorScheme.primary : null,
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.itemType.value.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _buildOpeningStockText(product, theme),
                          ],
                        ),
                      ),
                      if (isSaved)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, top: 2),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildQuantityInputs(
                    theme: theme,
                    product: product,
                    isMobile: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineNumberField(
                          theme: theme,
                          controller: _rateControllers[product.id]!,
                          hintText: 'RS',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        child: IconButton.filled(
                          onPressed: _canSaveProduct(product)
                              ? () => _saveSingleEntry(product)
                              : null,
                          icon: const Icon(Icons.check_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: productFlex,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
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
                              Text(
                                product.itemType.value.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              _buildOpeningStockText(product, theme),
                            ],
                          ),
                        ),
                        if (isSaved)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: columnGap),
                  Expanded(
                    flex: qtyFlex,
                    child: _buildQuantityInputs(
                      theme: theme,
                      product: product,
                      isMobile: false,
                    ),
                  ),
                  SizedBox(width: columnGap),
                  Expanded(
                    flex: rateFlex,
                    child: _buildInlineNumberField(
                      theme: theme,
                      controller: _rateControllers[product.id]!,
                      hintText: 'Rate (INR)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: columnGap),
                  SizedBox(
                    width: _actionWidth,
                    child: IconButton.filled(
                      onPressed: _canSaveProduct(product)
                          ? () => _saveSingleEntry(product)
                          : null,
                      icon: const Icon(Icons.check_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInlineNumberField({
    required ThemeData theme,
    required TextEditingController controller,
    required String hintText,
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) {
        if (mounted) {
          setState(() {});
        }
      },
      textAlign: textAlign,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ).applyDefaults(theme.inputDecorationTheme),
    );
  }

  Widget _buildQuantityInputs({
    required ThemeData theme,
    required Product product,
    required bool isMobile,
  }) {
    final hasSecondary = _hasSecondaryUnit(product);
    final baseController = _qtyControllers[product.id]!;
    final inputFormatters = [
      NormalizedNumberInputFormatter.decimal(keepZeroWhenEmpty: true),
    ];

    if (!hasSecondary) {
      final baseUnit = _deriveUnit(product);
      return _buildInlineNumberField(
        theme: theme,
        controller: baseController,
        hintText: '$baseUnit Qty',
        textAlign: TextAlign.center,
        inputFormatters: inputFormatters,
      );
    }

    final secondaryController = _secondaryQtyControllers[product.id]!;
    final secondaryUnit = _secondaryUnitLabel(product);
    final baseUnit = _deriveUnit(product);

    final unitStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.3,
    );

    return Row(
      children: [
        Text(secondaryUnit.toUpperCase(), style: unitStyle),
        SizedBox(width: isMobile ? 6 : 8),
        Expanded(
          child: _buildInlineNumberField(
            theme: theme,
            controller: secondaryController,
            hintText: '',
            textAlign: TextAlign.center,
            inputFormatters: inputFormatters,
          ),
        ),
        SizedBox(width: isMobile ? 10 : 12),
        Text(baseUnit.toUpperCase(), style: unitStyle),
        SizedBox(width: isMobile ? 6 : 8),
        Expanded(
          child: _buildInlineNumberField(
            theme: theme,
            controller: baseController,
            hintText: '',
            textAlign: TextAlign.center,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningStockText(Product product, ThemeData theme) {
    final openingStocksMap = _openingStocks[product.id] ?? {};
    if (openingStocksMap.isEmpty) return const SizedBox.shrink();
    
    final parts = <String>[];
    for (final wh in _warehouses) {
      final qty = openingStocksMap[wh.id] ?? 0.0;
      if (qty > 0) {
        final qtyStr = qty.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
        final shortName = wh.name.replaceAll(' Shed', '').replaceAll(' Warehouse', '').trim();
        parts.add('$shortName:$qtyStr');
      }
    }
    
    if (parts.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        'Stock: ' + parts.join(' | '),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.tertiary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  bool _hasSecondaryUnit(Product product) {
    return UnitConverter.hasSecondaryUnit(
      product.secondaryUnit,
      product.conversionFactor,
    );
  }

  String _secondaryUnitLabel(Product product) {
    final secondary = product.secondaryUnit?.trim() ?? '';
    return secondary.isEmpty ? 'Secondary' : secondary;
  }

  bool _hasNonZeroInput(Product product) {
    final qty =
        double.tryParse(_qtyControllers[product.id]?.text.trim() ?? '') ?? 0.0;
    final secondary =
        double.tryParse(
          _secondaryQtyControllers[product.id]?.text.trim() ?? '',
        ) ??
        0.0;
    final rateText = _rateControllers[product.id]?.text.trim() ?? '';
    final hasRate = rateText.isNotEmpty;
    return qty > 0 || secondary > 0 || hasRate;
  }

  bool _canSaveProduct(Product product) {
    if (_savingProducts[product.id] == true) return false;
    if (_savedProducts[product.id] == true && !_hasNonZeroInput(product)) {
      return false;
    }
    return true;
  }

  Future<bool> _confirmOpeningStockOverwrite(Product product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: const Text('UPDATE OPENING STOCK?'),
        content: Text(
          'Opening stock for ${product.name} already exists. Do you want to update it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          CustomButton(
            label: 'UPDATE',
            onPressed: () => Navigator.pop(ctx, true),
            isDense: true,
          ),
        ],
      ),
    );
    return result == true;
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found matching filters',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _deriveUnit(Product p) {
    final base = p.baseUnit.trim();
    if (base.isNotEmpty) return base;
    final type = p.itemType.value.toLowerCase();
    if (type.contains('raw material') || type.contains('semi')) {
      return 'KG';
    }
    return 'PCS';
  }

  Future<void> _saveSingleEntry(Product product) async {
    if (_selectedWarehouseId == null) {
      _showError('Please select a warehouse');
      return;
    }

    final qtyController = _qtyControllers[product.id];
    final secondaryQtyController = _secondaryQtyControllers[product.id];
    final rateController = _rateControllers[product.id];
    if (qtyController == null || rateController == null) {
      _showError('Missing input fields for ${product.name}');
      return;
    }

    final hasSecondary = _hasSecondaryUnit(product);
    if (hasSecondary && secondaryQtyController == null) {
      _showError('Missing secondary quantity field for ${product.name}');
      return;
    }

    final qtyStr = qtyController.text.trim();
    final secondaryQtyStr = secondaryQtyController?.text.trim() ?? '';
    final rateStr = rateController.text;

    if (qtyStr.isEmpty && secondaryQtyStr.isEmpty) return;

    final baseQty = qtyStr.isEmpty ? 0.0 : double.tryParse(qtyStr);
    if (baseQty == null || baseQty < 0) {
      _showError('Invalid base quantity');
      return;
    }

    final secondaryQty = secondaryQtyStr.isEmpty
        ? 0.0
        : double.tryParse(secondaryQtyStr);
    if (secondaryQty == null || secondaryQty < 0) {
      _showError('Invalid secondary quantity');
      return;
    }

    final convertedSecondaryQty = hasSecondary
        ? UnitConverter.toBaseUnit(secondaryQty, product.conversionFactor)
        : 0.0;
    final qty = baseQty + convertedSecondaryQty;
    if (qty <= 0) {
      _showError('Quantity must be greater than zero.');
      return;
    }

    final rate = rateStr.isNotEmpty ? double.tryParse(rateStr) : null;
    final unit = _deriveUnit(product);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }
    final userId = user.id;

    try {
      final existingEntry = await _openingService.getOpeningStock(
        productId: product.id,
        warehouseId: _selectedWarehouseId!,
      );
      if (existingEntry != null) {
        final shouldUpdate = await _confirmOpeningStockOverwrite(product);
        if (!shouldUpdate) return;
      }

      if (mounted) {
        setState(() => _savingProducts[product.id] = true);
      }
      await _openingService.createOpeningStock(
        productId: product.id,
        productType: product.itemType.value,
        warehouseId: _selectedWarehouseId!,
        quantity: qty,
        unit: unit,
        openingRate: rate,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          _savedProducts[product.id] = true;
          _savingProducts[product.id] = false;
          _openingStocks.putIfAbsent(product.id, () => {})[_selectedWarehouseId!] = qty;
        });
        AppToast.showSuccess(
          context,
          existingEntry == null
              ? 'Saved opening stock for ${product.name}'
              : 'Updated opening stock for ${product.name}',
        );
        _qtyControllers[product.id]!.clear();
        _secondaryQtyControllers[product.id]!.clear();
        _rateControllers[product.id]!.clear();
        _qtyControllers[product.id]!.text = '0';
        _secondaryQtyControllers[product.id]!.text = '0';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingProducts[product.id] = false);
      }
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    AppToast.showError(context, msg);
  }

  void _confirmGoLive() {
    showDialog(
      context: context,
      builder: (ctx) => ResponsiveAlertDialog(
        title: const Text('CONFIRM GO-LIVE LOCK'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 64),
            SizedBox(height: 24),
            Text(
              'This action is IRREVERSIBLE.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Once you confirm Go-Live, the Opening Stock system will be permanently locked. You will not be able to add opening stock anymore.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          CustomButton(
            label: 'LOCK FOREVER',
            onPressed: () async {
              Navigator.pop(ctx);
              await _openingService.markGoLiveCompleted();
              if (mounted) {
                setState(() => _isSystemLocked = true);
              }
            },
            variant: ButtonVariant.danger,
            isDense: true,
          ),
        ],
      ),
    );
  }
}
