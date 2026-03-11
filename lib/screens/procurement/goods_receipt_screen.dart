import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/inventory_service.dart';
import '../../services/purchase_order_service.dart';
import '../../services/products_service.dart';
import '../../models/types/purchase_order_types.dart';
import '../../models/types/product_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/app_toast.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/shared/app_card.dart';
import '../../widgets/ui/custom_states.dart';
import '../../widgets/ui/themed_segment_control.dart';
import '../inventory/dialogs/post_grn_distribution_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

// DEPRECATED: use PurchaseOrderService.receiveStock() for PO-based receiving.
class GoodsReceiptScreen extends StatefulWidget {
  final String? poId; // Optional if starting from a specific PO
  const GoodsReceiptScreen({super.key, this.poId});

  @override
  State<GoodsReceiptScreen> createState() => _GoodsReceiptScreenState();
}

class _GoodsReceiptScreenState extends State<GoodsReceiptScreen> {
  bool _isPOBased = true;
  bool _isLoading = false;
  bool _isInitLoading = true;

  // Data
  List<PurchaseOrder> _availablePOs = [];
  PurchaseOrder? _selectedPO;
  List<Product> _allProducts = [];
  Product? _selectedProduct;

  // Form State for items being received
  final List<GRNItem> _receivingItems = [];

  @override
  void initState() {
    super.initState();
    _isPOBased = widget.poId != null;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final poService = context.read<PurchaseOrderService>();
      final prodService = context.read<ProductsService>();

      final results = await Future.wait([
        poService.getAllPurchaseOrders(),
        prodService.getProducts(),
      ]);

      _availablePOs = (results[0] as List<PurchaseOrder>)
          .where(
            (po) =>
                po.status == PurchaseOrderStatus.ordered ||
                po.status == PurchaseOrderStatus.partiallyReceived,
          )
          .toList();
      _allProducts = results[1] as List<Product>;

      if (!mounted) return;

      if (widget.poId != null) {
        if (_availablePOs.isEmpty) {
          AppToast.showWarning(context, 'No open purchase orders found');
        } else {
          _selectedPO = _availablePOs.cast<PurchaseOrder?>().firstWhere(
            (po) => po?.id == widget.poId,
            orElse: () => null,
          );
          if (_selectedPO == null) {
            AppToast.showWarning(context, 'Purchase order not found');
          } else {
            _pullItemsFromPO(_selectedPO!);
          }
        }
      }

      if (mounted) {
        setState(() => _isInitLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading GRN data: $e');
      if (mounted) {
        setState(() => _isInitLoading = false);
        AppToast.showError(context, 'Failed to load data: $e');
      }
    }
  }

  void _pullItemsFromPO(PurchaseOrder po) {
    setState(() {
      _receivingItems.clear();
      for (var item in po.items) {
        // Calculate remaining qty
        final double received = item.receivedQuantity ?? 0.0;
        final double remaining = item.quantity - received;

        if (remaining > 0) {
          _receivingItems.add(
            GRNItem(
              productId: item.productId,
              name: item.name,
              orderedQty: item.quantity,
              previouslyReceivedQty: received,
              receivingQty: remaining,
              unitPrice: item.unitPrice,
              unit: item.unit,
              baseUnit: item.baseUnit ?? item.unit,
              conversionFactor: item.conversionFactor ?? 1.0,
            ),
          );
        }
      }
    });
  }

  void _addItemDirectly(Product product) {
    setState(() {
      _receivingItems.add(
        GRNItem(
          productId: product.id,
          name: product.name,
          orderedQty: 0,
          previouslyReceivedQty: 0,
          receivingQty: 0,
          unitPrice: product.purchasePrice ?? 0,
          unit: product.baseUnit,
          baseUnit: product.baseUnit,
          conversionFactor: 1.0,
        ),
      );
    });
  }

  Future<void> _submitGRN() async {
    if (_receivingItems.isEmpty) {
      AppToast.showWarning(context, 'No items to receive');
      return;
    }

    // Validate if any qty is 0 or less
    if (_receivingItems.any((i) => i.receivingQty <= 0)) {
      AppToast.showError(context, 'Receiving quantity must be greater than 0');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final poService = context.read<PurchaseOrderService>();
      final auth = context.read<AuthProvider>();
      final currentUser = auth.currentUser;
      final distributionProducts =
          _buildDistributionProductsFromReceivingItems();
      final referenceId =
          _selectedPO?.id ??
          'DIRECT_GRN_${DateTime.now().millisecondsSinceEpoch}';
      final referenceNumber =
          _selectedPO?.poNumber ??
          'GRN-${DateFormat('yyyyMMdd').format(DateTime.now())}';

      if (_selectedPO != null) {
        final receivedQtys = _receivingItems
            .where((item) => item.receivingQty > 0)
            .map((item) => {item.productId: item.receivingQty})
            .toList();
        await poService.receiveStock(
          poId: _selectedPO!.id,
          userId: currentUser?.id ?? 'unknown',
          userName: currentUser?.name ?? 'Unknown',
          receivedQtys: receivedQtys,
        );
      } else {
        final inventoryService = context.read<InventoryService>();
        final itemsToProcess = _receivingItems
            .map(
              (item) => {
                'productId': item.productId,
                'productName': item.name,
                'quantity': _effectiveBaseQty(item),
                'unitPrice': item.unitPrice,
                'lotNumber': item.lotNumber,
                'expiryDate': item.expiryDate?.toIso8601String(),
              },
            )
            .toList();
        await inventoryService.processBulkGRN(
          items: itemsToProcess,
          referenceId: referenceId,
          referenceNumber: referenceNumber,
          userId: currentUser?.id ?? 'unknown',
          userName: currentUser?.name ?? 'Unknown',
        );
      }

      if (mounted) {
        AppToast.showSuccess(context, 'Goods received and inventory updated');
        if (distributionProducts.isNotEmpty && currentUser != null) {
          await _offerPostReceiptDistribution(
            referenceId: referenceId,
            referenceNumber: referenceNumber,
            operatorId: currentUser.id,
            operatorName: currentUser.name,
            products: distributionProducts,
          );
        }
        if (!mounted) return;
        context.pop();
      }
    } catch (e) {
      debugPrint('GRN Submit Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Failed to process GRN: $e');
      }
    }
  }

  List<PostGrnDistributionProduct>
  _buildDistributionProductsFromReceivingItems() {
    final qtyByProduct = <String, double>{};
    final nameByProduct = <String, String>{};
    final unitByProduct = <String, String>{};

    for (final item in _receivingItems) {
      if (item.receivingQty <= 0) continue;
      final effectiveQty = _effectiveBaseQty(item);
      if (effectiveQty <= 0) continue;
      qtyByProduct[item.productId] =
          (qtyByProduct[item.productId] ?? 0) + effectiveQty;
      nameByProduct[item.productId] = item.name;
      unitByProduct[item.productId] = _effectiveBaseUnit(item);
    }

    return qtyByProduct.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) => PostGrnDistributionProduct(
            productId: entry.key,
            productName: nameByProduct[entry.key] ?? entry.key,
            availableQty: entry.value,
            unit: unitByProduct[entry.key] ?? 'Unit',
          ),
        )
        .toList();
  }

  Future<void> _offerPostReceiptDistribution({
    required String referenceId,
    required String referenceNumber,
    required String operatorId,
    required String operatorName,
    required List<PostGrnDistributionProduct> products,
  }) async {
    if (products.isEmpty || !mounted) return;

    final shouldDistribute = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Distribute Received Stock'),
        content: const Text(
          'Do you want to distribute this received stock now to Tanks/Godowns and Departments?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Distribute Now'),
          ),
        ],
      ),
    );

    if (shouldDistribute != true || !mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => PostGrnDistributionDialog(
        referenceId: referenceId,
        referenceNumber: referenceNumber,
        operatorId: operatorId,
        operatorName: operatorName,
        products: products,
      ),
    );

    if (result == null || !mounted) return;
    final storageCount = (result['storageTransfers'] as num?)?.toInt() ?? 0;
    final departmentCount =
        (result['departmentTransfers'] as num?)?.toInt() ?? 0;
    AppToast.showSuccess(
      context,
      'Distribution completed: $storageCount storage transfer(s), $departmentCount department transfer(s).',
    );
  }

  double _effectiveBaseQty(GRNItem item) {
    if (item.conversionFactor <= 0) {
      return item.receivingQty;
    }
    if (item.unit == item.baseUnit) {
      return item.receivingQty;
    }
    return item.receivingQty * item.conversionFactor;
  }

  String _effectiveBaseUnit(GRNItem item) {
    return item.baseUnit.trim().isEmpty ? item.unit : item.baseUnit;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(
        body: CustomLoadingIndicator(message: 'Initializing GRN...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Receipt Note (GRN)'),
        actions: [
          if (_receivingItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: _submitGRN,
                      tooltip: 'Submit GRN',
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildModeSelector(),
          const Divider(height: 1),
          if (_isPOBased) _buildPOSelector(),
          if (!_isPOBased) _buildProductSelector(),
          Expanded(
            child: _receivingItems.isEmpty
                ? _buildEmptyState()
                : _buildItemsList(),
          ),
        ],
      ),
      bottomNavigationBar: _receivingItems.isEmpty
          ? null
          : _buildBottomSummary(),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ThemedSegmentControl<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            label: Text('PO Based'),
            icon: Icon(Icons.description_outlined),
          ),
          ButtonSegment(
            value: false,
            label: Text('Direct GRN'),
            icon: Icon(Icons.add_shopping_cart),
          ),
        ],
        selected: {_isPOBased},
        onSelectionChanged: (val) {
          setState(() {
            _isPOBased = val.first;
            _selectedPO = null;
            _selectedProduct = null;
            _receivingItems.clear();
          });
        },
      ),
    );
  }

  Widget _buildPOSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<PurchaseOrder>(
        initialValue: _selectedPO,
        decoration: const InputDecoration(
          labelText: 'Select Purchase Order',
          prefixIcon: Icon(Icons.receipt_long),
          border: OutlineInputBorder(),
        ),
        items: _availablePOs.map((po) {
          return DropdownMenuItem(
            value: po,
            child: Text('${po.poNumber} - ${po.supplierName}'),
          );
        }).toList(),
        onChanged: (po) {
          if (po != null) {
            setState(() {
              _selectedPO = po;
              _pullItemsFromPO(po);
            });
          }
        },
      ),
    );
  }

  Widget _buildProductSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<Product>(
        initialValue: _selectedProduct,
        decoration: const InputDecoration(
          labelText: 'Add Product',
          prefixIcon: Icon(Icons.inventory_2_outlined),
          border: OutlineInputBorder(),
        ),
        items: _allProducts.map((p) {
          return DropdownMenuItem(value: p, child: Text(p.name));
        }).toList(),
        onChanged: (p) {
          if (p != null) {
            _addItemDirectly(p);
            setState(() => _selectedProduct = null);
          }
        },
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivingItems.length,
      itemBuilder: (context, index) {
        final item = _receivingItems[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _isPOBased
                  ? 'Ordered: ${item.orderedQty} ${item.unit} | Prev. Recv: ${item.previouslyReceivedQty}'
                  : 'Direct Entry',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => setState(() => _receivingItems.removeAt(index)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.receivingQty.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Receiving Qty',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              NormalizedNumberInputFormatter.decimal(
                                keepZeroWhenEmpty: true,
                              ),
                            ],
                            onChanged: (v) =>
                                item.receivingQty = double.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Lot/Batch No.',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => item.lotNumber = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (date != null) {
                          setState(() => item.expiryDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              item.expiryDate == null
                                  ? 'Expiry Date (Optional)'
                                  : 'Expiry: ${DateFormat('dd-MM-yyyy').format(item.expiryDate!)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 64,
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _isPOBased
                ? 'Select a Purchase Order to start receiving'
                : 'Add products to start a Direct GRN',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    final colorScheme = Theme.of(context).colorScheme;
    final double totalQty = _receivingItems.fold(
      0,
      (sum, i) => sum + i.receivingQty,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items: ${_receivingItems.length}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Total Qty: ${totalQty.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitGRN,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('SUBMIT GRN'),
            ),
          ],
        ),
      ),
    );
  }
}

class GRNItem {
  final String productId;
  final String name;
  final double orderedQty;
  final double previouslyReceivedQty;
  double receivingQty;
  final double unitPrice;
  final String unit;
  final String baseUnit;
  final double conversionFactor;
  String? lotNumber;
  DateTime? expiryDate;

  GRNItem({
    required this.productId,
    required this.name,
    required this.orderedQty,
    required this.previouslyReceivedQty,
    required this.receivingQty,
    required this.unitPrice,
    required this.unit,
    required this.baseUnit,
    required this.conversionFactor,
  });
}
