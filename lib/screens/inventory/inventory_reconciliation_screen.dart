import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/inventory_service.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/app_toast.dart';
import '../../utils/responsive.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class InventoryReconciliationScreen extends StatefulWidget {
  const InventoryReconciliationScreen({super.key});

  @override
  State<InventoryReconciliationScreen> createState() =>
      _InventoryReconciliationScreenState();
}

class _InventoryReconciliationScreenState
    extends State<InventoryReconciliationScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  // Map to store physical counts: productId -> count
  final Map<String, double> _physicalCounts = {};
  // Map to store controllers to avoid recreating them
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final productService = context.read<ProductsService>();
      final products = await productService.getProducts();

      // Sort by Name
      products.sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;

          // Initialize physical counts with current stock
          for (var p in products) {
            _physicalCounts[p.id] = p.stock;
            _controllers[p.id] = TextEditingController(
              text: p.stock.toString(),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading products: $e');
      }
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _allProducts);
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(lower) ||
            p.sku.toLowerCase().contains(lower);
      }).toList();
    });
  }

  void _onCountChanged(String productId, String value) {
    final val = double.tryParse(value);
    if (val != null) {
      setState(() {
        _physicalCounts[productId] = val;
      });
    }
  }

  Future<void> _submitReconciliation() async {
    // 1. Identify Changes
    final List<Map<String, dynamic>> changes = [];
    for (var p in _allProducts) {
      final current = p.stock;
      final physical = _physicalCounts[p.id] ?? current;

      if ((physical - current).abs() > 0.001) {
        changes.add({
          'productId': p.id,
          'productName': p.name,
          'physicalCount': physical,
          'systemStock': current,
        });
      }
    }

    if (changes.isEmpty) {
      AppToast.showInfo(context, 'No discrepancies found to reconcile.');
      return;
    }

    // Capture providers before async gap
    final inventoryService = context.read<InventoryService>();
    final currentUser = context.read<AuthProvider>().currentUser;

    // 2. Confirm Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Confirm Reconciliation'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are about to adjust stock for ${changes.length} products.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Significant Changes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...changes
                .take(5)
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${c['productName']}: ${c['systemStock']} -> ${c['physicalCount']} '
                      '(${((c['physicalCount'] - c['systemStock']) as double) > 0 ? '+' : ''}'
                      '${(c['physicalCount'] - c['systemStock']).toStringAsFixed(2)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            if (changes.length > 5)
              Text(
                '+ ${changes.length - 5} more...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Confirm & Adjust'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 3. Process
    setState(() => _isSubmitting = true);
    try {
      final result = await inventoryService.reconcileInventory(
        items: changes,
        userId: currentUser?.id ?? 'unknown',
        userName: currentUser?.name ?? 'Admin',
        notes: 'Bulk Reconciliation via App',
      );

      if (mounted) {
        AppToast.showSuccess(
          context,
          'Successfully reconciled ${result['adjustments']} products.',
        );
        _loadData(); // Reload to refresh system stock
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Reconciliation failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Stock Reconciliation',
            subtitle: 'Bulk reconcile digital vs physical stock',
            icon: Icons.inventory_rounded,
            color: theme.colorScheme.primary,
            onBack: () => context.go('/dashboard/inventory/stock-overview'),
            actions: [
              if (_allProducts.isNotEmpty)
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Products',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 20,
                          child: CustomTextField(
                            label: '',
                            controller: _searchController,
                            hintText: 'Search Product / SKU...',
                            prefixIcon: Icons.search_rounded,
                            isDense: true,
                            onChanged: _filterProducts,
                          ),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'PRODUCT INFO',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'SYSTEM',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'PHYSICAL COUNT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final system = product.stock;
                            final physical =
                                _physicalCounts[product.id] ?? system;
                            final diff = physical - system;

                            Color? diffColor;
                            if (diff > 0) diffColor = AppColors.success;
                            if (diff < 0) diffColor = AppColors.error;

                            return AnimatedCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                borderRadius: 20,
                                color: diff.abs() > 0.001
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.03,
                                      )
                                    : theme.colorScheme.surface,
                                child: Row(
                                  children: [
                                    // Product Name & SKU
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            product.sku,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // System Stock
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          Text(
                                            system.toStringAsFixed(2),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          if (diff.abs() > 0.001) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              diff > 0
                                                  ? '+${diff.toStringAsFixed(2)}'
                                                  : diff.toStringAsFixed(2),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: diffColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Physical Input
                                    Expanded(
                                      flex: 2,
                                      child: CustomTextField(
                                        label: '',
                                        controller: _controllers[product.id],
                                        hintText: '0.00',
                                        isDense: true,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          NormalizedNumberInputFormatter.decimal(
                                            keepZeroWhenEmpty: true,
                                          ),
                                        ],
                                        textAlign: TextAlign.right,
                                        onChanged: (val) =>
                                            _onCountChanged(product.id, val),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _isSubmitting
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomButton(
                label: 'RECONCILE ALL DISCREPANCIES',
                onPressed: _submitReconciliation,
                isLoading: _isSubmitting,
                width: Responsive.clamp(
                  context,
                  min: 220,
                  max: 360,
                  ratio: 0.5,
                ),
                icon: Icons.check_circle_rounded,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

