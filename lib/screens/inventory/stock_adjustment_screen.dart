import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/inventory_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/app_toast.dart';
import '../../models/types/user_types.dart';
import '../../utils/normalized_number_input_formatter.dart';

import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/master_screen_header.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class StockAdjustmentScreen extends StatefulWidget {
  final Product? initialProduct;
  const StockAdjustmentScreen({super.key, this.initialProduct});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  late final InventoryService _inventoryService;
  late final ProductsService _productsService;

  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;

  // Logic: User inputs 'Actual Stock', we calculate 'Adjustment Qty'
  final TextEditingController _actualStockController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Underlying fields for submission
  String _movementType = 'in'; // 'in' or 'out'
  double _calculatedAdjustment = 0;

  String _reason = 'Adjustment';
  bool _isSubmitting = false;
  bool _isLoadingProducts = true;
  List<Product> _allProducts = [];

  // Filters
  String _selectedCategoryTab = 'All';
  List<String> _categoryTabs = [
    'All',
    'Finished',
    'Traded',
    'Raw',
    'Semi',
    'Oils',
    'Chem',
    'Pkg',
  ];
  final ScrollController _categoryTabsScrollController = ScrollController();
  late Map<String, GlobalKey> _categoryTabKeys;

  final List<String> _reasons = [
    'Adjustment',
    'Damage',
    'Loss',
    'Return from Client',
    'Waste',
    'Correction',
    'Expired',
    'Found Stock',
  ];

  @override
  void initState() {
    super.initState();
    _categoryTabKeys = {for (final tab in _categoryTabs) tab: GlobalKey()};
    _inventoryService = context.read<InventoryService>();
    _productsService = context.read<ProductsService>();
    _loadProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedCategoryTab(animate: false);
    });
  }

  Future<void> _loadProducts() async {
    try {
      var products = await _productsService.getProducts();

      // Filter by role (Stock Visibility Filtering)
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      if (currentUser != null) {
        if (currentUser.role == UserRole.bhattiSupervisor) {
          products = products
              .where(
                (p) =>
                    p.itemType.value == 'Raw Material' ||
                    p.itemType.value == 'Semi-Finished Good' ||
                    p.itemType.value == 'Oils & Liquids' ||
                    p.itemType.value == 'Chemicals & Additives',
              )
              .toList();
        } else if (currentUser.role == UserRole.productionSupervisor) {
          products = products
              .where(
                (p) =>
                    p.itemType.value == 'Semi-Finished Good' ||
                    p.itemType.value == 'Finished Good' ||
                    p.itemType.value == 'Packaging Material',
              )
              .toList();
        }
      }

      // Sort alphabetically
      products.sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _allProducts = products;

          // Rebuild tabs based on allowed types
          if (currentUser?.role == UserRole.bhattiSupervisor) {
            _categoryTabs = ['All', 'Raw', 'Semi', 'Oils', 'Chem'];
          } else if (currentUser?.role == UserRole.productionSupervisor) {
            _categoryTabs = ['All', 'Finished', 'Semi', 'Pkg'];
          }
          if (!_categoryTabs.contains(_selectedCategoryTab)) {
            _selectedCategoryTab = 'All';
          }
          _categoryTabKeys = {
            for (final tab in _categoryTabs) tab: GlobalKey(),
          };

          _isLoadingProducts = false;

          if (widget.initialProduct != null) {
            _onProductSelected(widget.initialProduct!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  @override
  void dispose() {
    _actualStockController.dispose();
    _notesController.dispose();
    _categoryTabsScrollController.dispose();
    super.dispose();
  }

  void _centerSelectedCategoryTab({bool animate = true}) {
    final targetContext =
        _categoryTabKeys[_selectedCategoryTab]?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      duration: animate ? const Duration(milliseconds: 220) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  void _onProductSelected(Product product) {
    setState(() {
      _selectedProduct = product;
      _actualStockController.text = product.stock
          .toString(); // Default to current
      _calculateAdjustment();
    });
  }

  void _calculateAdjustment() {
    if (_selectedProduct == null) return;

    final currentStock = _selectedProduct!.stock;
    final actualStock =
        double.tryParse(_actualStockController.text) ?? currentStock;

    final diff = actualStock - currentStock;

    setState(() {
      _calculatedAdjustment = diff.abs();
      _movementType = diff >= 0 ? 'in' : 'out';
    });
  }

  Future<void> _submit() async {
    debugPrint('[StockAdjustmentScreen] _submit initiated.');
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      AppToast.showWarning(
        context,
        'Please select a product and enter valid quantity',
      );
      return;
    }

    if (_calculatedAdjustment == 0) {
      AppToast.showInfo(
        context,
        'No adjustment needed (Actual = System Stock)',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      debugPrint(
        '[StockAdjustmentScreen] Calling InventoryService.adjustStock...',
      );
      debugPrint(
        '   Product: ${_selectedProduct!.name}, Qty: $_calculatedAdjustment, Type: $_movementType',
      );

      final ok = await _inventoryService.adjustStock(
        items: [
          {
            'productId': _selectedProduct!.id,
            'name': _selectedProduct!.name,
            'quantity': _calculatedAdjustment,
            'movementType': _movementType,
          },
        ],
        reason: _reason,
        userId: currentUser.id,
        userName: currentUser.name,
        userRole: currentUser.role,
        notes: _notesController.text,
      );

      debugPrint(
        '[StockAdjustmentScreen] adjustStock completed. Result: $ok, Mounted: $mounted',
      );

      if (!mounted) return;

      if (ok) {
        AppToast.showSuccess(context, 'Stock adjusted successfully');
        debugPrint('[StockAdjustmentScreen] Popping screen...');
        // Small delay to allow toast to start animating (optional but safe)
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) Navigator.pop(context, true);
      } else {
        AppToast.showError(context, 'Failed to adjust stock');
      }
    } catch (e, stack) {
      debugPrint('[StockAdjustmentScreen] EXCEPTION in _submit: $e');
      debugPrint('Stack: $stack');
      if (mounted) {
        AppToast.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Inventory Adjustment',
            subtitle: 'Correct digital inventory to match physical stock',
            icon: Icons.inventory_2_rounded,
            color: theme.colorScheme.primary,
            onBack: () => context.go('/dashboard/inventory/stock-overview'),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.lightbulb_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Select a product and enter the "Actual Physical Quantity". The system will automatically calculate the adjustment needed.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    UnifiedCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. PRODUCT SELECTION
                          Text(
                            'Select Product',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryTabs(theme), // TABS
                          const SizedBox(height: 16),
                          _isLoadingProducts
                              ? const LinearProgressIndicator()
                              : _buildProductSelector(theme),

                          // 2. RECONCILIATION UI
                          if (_selectedProduct != null) ...[
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SYSTEM STOCK (Read only)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SYSTEM AVAILABLE',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.outline
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedProduct!.stock
                                                  .toStringAsFixed(2),
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            Text(
                                              _selectedProduct!.baseUnit,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // ACTUAL STOCK (Input)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ACTUAL PHYSICAL QTY',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: theme.colorScheme.primary,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        label: '',
                                        controller: _actualStockController,
                                        hintText: '0.00',
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          NormalizedNumberInputFormatter.decimal(
                                            keepZeroWhenEmpty: true,
                                          ),
                                        ],
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            _selectedProduct!.baseUnit,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                        onChanged: (_) =>
                                            _calculateAdjustment(),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return 'Required';
                                          }
                                          if (double.tryParse(val) == null) {
                                            return 'Invalid';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // DIFFERENCE INDICATOR
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: _calculatedAdjustment == 0
                                    ? AppColors.success.withValues(alpha: 0.05)
                                    : (_movementType == 'in'
                                          ? theme.colorScheme.primary
                                                .withValues(alpha: 0.05)
                                          : AppColors.warning.withValues(
                                              alpha: 0.05,
                                            )),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _calculatedAdjustment == 0
                                        ? Icons.check_circle_rounded
                                        : (_movementType == 'in'
                                              ? Icons.add_circle_rounded
                                              : Icons.remove_circle_rounded),
                                    color: _calculatedAdjustment == 0
                                        ? AppColors.success
                                        : (_movementType == 'in'
                                              ? theme.colorScheme.primary
                                              : AppColors.warning),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _calculatedAdjustment == 0
                                          ? 'Stock matches physical record.'
                                          : 'Adjustment: ${_movementType.toUpperCase()} ${_calculatedAdjustment.toStringAsFixed(2)} ${_selectedProduct!.baseUnit}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: _calculatedAdjustment == 0
                                                ? AppColors.success
                                                : theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 24),

                          // 3. REASON & NOTES
                          Text(
                            'REASON & NOTES',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return UnifiedCard(
                                isGlass: true,
                                showShadow: false,
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                child: DropdownMenu<String>(
                                  width: constraints.maxWidth,
                                  initialSelection: _reason,
                                  onSelected: (value) {
                                    if (value != null) {
                                      setState(() => _reason = value);
                                    }
                                  },
                                  dropdownMenuEntries: _reasons.map((r) {
                                    return DropdownMenuEntry<String>(
                                      value: r,
                                      label: r,
                                      style: MenuItemButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        foregroundColor:
                                            theme.colorScheme.onSurface,
                                      ),
                                    );
                                  }).toList(),
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: Colors
                                        .transparent, // Handled by GlassContainer
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Internal Notes',
                            controller: _notesController,
                            hintText: 'Why is this adjustment being made?',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 32),

                          // ACTIONS
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final useStackedActions =
                                  constraints.maxWidth < 520;
                              if (useStackedActions) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomButton(
                                        label: 'CANCEL',
                                        onPressed: () => context.go(
                                          '/dashboard/inventory/stock-overview',
                                        ),
                                        variant: ButtonVariant.outline,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomButton(
                                        label: 'CONFIRM UPDATE',
                                        onPressed: _submit,
                                        isLoading: _isSubmitting,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      label: 'CANCEL',
                                      onPressed: () => context.go(
                                        '/dashboard/inventory/stock-overview',
                                      ),
                                      variant: ButtonVariant.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: CustomButton(
                                      label: 'CONFIRM UPDATE',
                                      onPressed: _submit,
                                      isLoading: _isSubmitting,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme) {
    return SingleChildScrollView(
      controller: _categoryTabsScrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryTabs.map((cat) {
          final isSelected = _selectedCategoryTab == cat;
          return Padding(
            key: _categoryTabKeys[cat],
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategoryTab = cat;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _centerSelectedCategoryTab();
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    cat.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductSelector(ThemeData theme) {
    // Filter list based on selected tab first
    final filteredList = _allProducts.where(_dategoryTabMatches).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return UnifiedCard(
          isGlass: true,
          showShadow: false,
          padding: EdgeInsets.zero,
          child: DropdownMenu<Product>(
            width: constraints.maxWidth,
            menuHeight: 350,
            hintText: 'Search Product...',
            leadingIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary,
            ),
            enableFilter: true,
            initialSelection: _selectedProduct,
            requestFocusOnTap: true,
            dropdownMenuEntries: filteredList.map<DropdownMenuEntry<Product>>((
              Product p,
            ) {
              return DropdownMenuEntry<Product>(
                value: p,
                label: '${p.name} (${p.sku})',
                style: MenuItemButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
              );
            }).toList(),
            onSelected: (Product? product) {
              if (product != null) {
                _onProductSelected(product);
              }
            },
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.transparent, // Handled by GlassContainer
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _dategoryTabMatches(Product p) {
    if (_selectedCategoryTab == 'All') return true;
    final type = p.itemType.value; // String value
    switch (_selectedCategoryTab) {
      case 'Finished':
        return type == 'Finished Good';
      case 'Traded':
        return type == 'Traded Good';
      case 'Raw':
        return type == 'Raw Material';
      case 'Semi':
        return type == 'Semi-Finished Good';
      case 'Oils':
        return type == 'Oils & Liquids';
      case 'Chem':
        return type == 'Chemicals & Additives';
      case 'Pkg':
        return type == 'Packaging Material';
      default:
        return true;
    }
  }
}
