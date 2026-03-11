import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/purchase_order_service.dart';
import '../../models/types/purchase_order_types.dart';
import '../../services/products_service.dart';
import '../../models/types/product_types.dart';
import '../../services/suppliers_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/app_toast.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/themed_segment_control.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

bool hasDuplicateProductLine(List<PurchaseOrderItem> items, String productId) {
  final normalized = productId.trim();
  if (normalized.isEmpty) return false;
  return items.any((item) => item.productId.trim() == normalized);
}

class PurchaseOrderFormScreen extends StatefulWidget {
  final String? poId;
  const PurchaseOrderFormScreen({super.key, this.poId});

  @override
  State<PurchaseOrderFormScreen> createState() =>
      _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState extends State<PurchaseOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _notesController = TextEditingController();
  final _qtyController = TextEditingController(text: '0');
  final _priceController = TextEditingController();
  final _gstPercentController = TextEditingController(text: '18');
  final _itemTotalController = TextEditingController();
  final _supplierSearchController = TextEditingController();
  final _productSearchController = TextEditingController();
  final _supplierInvoiceController = TextEditingController();

  // State
  DateTime? _expectedDate;
  DateTime? _invoiceDate;
  Supplier? _selectedSupplier;
  final List<PurchaseOrderItem> _items = [];
  bool _isLoading = false;
  bool _isInitLoading = true;
  bool _isLockedAfterReceiveStart = false;
  String _gstType = 'CGST+SGST'; // Default to Local (CGST+SGST)

  // Data
  List<Product> _allProducts = [];
  List<Supplier> _allSuppliers = [];
  Product? _selectedProduct;
  ProductType _itemCategoryFilter = ProductType.rawMaterial;
  List<String> _suggestedProductIds = [];

  static const List<ProductType> _purchaseCategories = [
    ProductType.rawMaterial,
    ProductType.tradedGood,
    ProductType.oilsLiquids,
    ProductType.packagingMaterial,
  ];

  String _categoryLabel(ProductType category) {
    if (category == ProductType.rawMaterial) return 'Raw Material';
    if (category == ProductType.tradedGood) return 'Traded Goods';
    if (category == ProductType.oilsLiquids) return 'Oils & Liquids';
    if (category == ProductType.packagingMaterial) return 'Packaging';
    return category.value;
  }

  IconData _categoryIcon(ProductType category) {
    if (category == ProductType.rawMaterial) {
      return Icons.inventory_2_outlined;
    }
    if (category == ProductType.tradedGood) return Icons.handshake_outlined;
    if (category == ProductType.oilsLiquids) return Icons.opacity_outlined;
    if (category == ProductType.packagingMaterial) return Icons.inventory_2;
    return Icons.category_outlined;
  }

  ProductTypeEnum _enumTypeForCategory(ProductType category) {
    if (category == ProductType.tradedGood) return ProductTypeEnum.traded;
    if (category == ProductType.packagingMaterial) {
      return ProductTypeEnum.packaging;
    }
    return ProductTypeEnum.raw;
  }

  bool _matchesSelectedCategory(Product product) {
    final normalizedType = ProductType.fromString(product.itemType.value);
    return normalizedType == _itemCategoryFilter;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prodService = context.read<ProductsService>();
      final supService = context.read<SuppliersService>();

      final results = await Future.wait([
        prodService.getProducts(),
        supService.getSuppliers(),
      ]);

      _allProducts = results[0] as List<Product>;
      _allSuppliers = results[1] as List<Supplier>;

      if (!mounted) return; // Add this here

      if (widget.poId != null) {
        // Edit mode logic
        final service = context.read<PurchaseOrderService>();
        final orders = await service.getAllPurchaseOrders();
        if (!mounted) return;
        final order = orders.cast<PurchaseOrder?>().firstWhere(
          (o) => o?.id == widget.poId,
          orElse: () => null,
        );
        if (order == null) {
          if (mounted) {
            setState(() => _isInitLoading = false);
            AppToast.showError(context, 'Purchase order not found');
          }
          return;
        }

        setState(() {
          if (_allSuppliers.isEmpty) {
            AppToast.showError(context, 'No suppliers available');
          } else {
            _selectedSupplier = _allSuppliers.firstWhere(
              (s) => s.id == order.supplierId,
              orElse: () => _allSuppliers.first,
            );
          }
          _items.addAll(order.items);
          _notesController.text = order.notes ?? '';
          _supplierInvoiceController.text = order.supplierInvoiceNumber ?? '';
          _invoiceDate = order.invoiceDate != null
              ? DateTime.tryParse(order.invoiceDate!)
              : null;
          _expectedDate = order.expectedDeliveryDate != null
              ? DateTime.tryParse(order.expectedDeliveryDate!)
              : null;
          _gstType = order.gstType ?? 'CGST+SGST';
          _isLockedAfterReceiveStart =
              order.status == PurchaseOrderStatus.partiallyReceived ||
              order.status == PurchaseOrderStatus.received;
        });
      }

      setState(() => _isInitLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isInitLoading = false);
        AppToast.showError(context, 'Error: $e');
      }
    }
  }

  void _addItem() {
    if (_isLockedAfterReceiveStart) {
      AppToast.showWarning(
        context,
        'Item editing is locked after receiving has started.',
      );
      return;
    }

    if (_selectedProduct == null ||
        _qtyController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }

    if (hasDuplicateProductLine(_items, _selectedProduct!.id)) {
      AppToast.showWarning(
        context,
        'This product is already added in the purchase order.',
      );
      return;
    }

    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final gstP = double.tryParse(_gstPercentController.text) ?? 18;

    if (qty <= 0 || price <= 0) return;

    final taxableAmount = qty * price;
    final gstAmount = taxableAmount * (gstP / 100);
    final itemTotal = taxableAmount + gstAmount;

    setState(() {
      _items.add(
        PurchaseOrderItem(
          productId: _selectedProduct!.id,
          name: _selectedProduct!.name,
          quantity: qty,
          unit: _selectedProduct!.baseUnit,
          unitPrice: price,
          taxableAmount: taxableAmount,
          gstPercentage: gstP,
          gstAmount: gstAmount,
          total: itemTotal,
          baseUnit: _selectedProduct!.baseUnit,
          conversionFactor: _selectedProduct!.conversionFactor,
        ),
      );

      _selectedProduct = null;
      _qtyController.text = '0';
      _priceController.clear();
      _itemTotalController.clear();
      _productSearchController.clear();
    });
  }

  void _updateItemTotal() {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final gstP = double.tryParse(_gstPercentController.text) ?? 0;

    if (qty > 0 && price > 0) {
      final taxable = qty * price;
      final total = taxable + (taxable * (gstP / 100));
      _itemTotalController.text = total.toStringAsFixed(2);
    } else {
      _itemTotalController.clear();
    }
  }

  void _removeItem(int index) {
    if (_isLockedAfterReceiveStart) {
      AppToast.showWarning(
        context,
        'Item editing is locked after receiving has started.',
      );
      return;
    }
    setState(() => _items.removeAt(index));
  }

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.taxableAmount);
  double get _totalGst => _items.fold(0, (sum, item) => sum + item.gstAmount);
  double get _rawTotal => _subtotal + _totalGst;
  double get _totalAmount => _rawTotal.roundToDouble();
  double get _roundOff => _totalAmount - _rawTotal;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      AppToast.showError(context, 'Please select a supplier');
      return;
    }
    if (_items.isEmpty) {
      AppToast.showError(context, 'Please add at least one item');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = context.read<PurchaseOrderService>();
      final currentUser = context.read<AuthProvider>().currentUser;

      // GST Calculation Breakdown based on type
      double cgst = 0;
      double sgst = 0;
      double igst = 0;

      if (_gstType == 'CGST+SGST') {
        cgst = _totalGst / 2;
        sgst = _totalGst / 2;
      } else if (_gstType == 'IGST') {
        igst = _totalGst;
      }

      if (widget.poId == null) {
        await service.createPurchaseOrder(
          supplierId: _selectedSupplier!.id,
          supplierName: _selectedSupplier!.name,
          items: _items,
          createdBy: currentUser?.id ?? 'unknown',
          createdByName: currentUser?.name ?? 'Unknown',
          notes: _notesController.text,
          expectedDeliveryDate: _expectedDate?.toIso8601String(),
          subtotal: _subtotal,
          totalGst: _totalGst,
          cgstAmount: cgst,
          sgstAmount: sgst,
          igstAmount: igst,
          totalAmount: _totalAmount,
          roundOff: _roundOff,
          gstType: _gstType,
          supplierInvoiceNumber: _supplierInvoiceController.text.trim().isEmpty
              ? null
              : _supplierInvoiceController.text.trim(),
          invoiceDate: _invoiceDate?.toIso8601String(),
        );
      } else {
        if (_isLockedAfterReceiveStart) {
          await service.updatePurchaseOrder(widget.poId!, {
            'notes': _notesController.text,
            'supplierInvoiceNumber':
                _supplierInvoiceController.text.trim().isEmpty
                ? null
                : _supplierInvoiceController.text.trim(),
            'invoiceDate': _invoiceDate?.toIso8601String(),
          });
        } else {
          await service.updatePurchaseOrder(widget.poId!, {
            'supplierId': _selectedSupplier!.id,
            'supplierName': _selectedSupplier!.name,
            'items': _items.map((e) => e.toJson()).toList(),
            'notes': _notesController.text,
            'supplierInvoiceNumber':
                _supplierInvoiceController.text.trim().isEmpty
                ? null
                : _supplierInvoiceController.text.trim(),
            'invoiceDate': _invoiceDate?.toIso8601String(),
            'expectedDeliveryDate': _expectedDate?.toIso8601String(),
            'subtotal': _subtotal,
            'totalGst': _totalGst,
            'cgstAmount': cgst,
            'sgstAmount': sgst,
            'igstAmount': igst,
            'totalAmount': _totalAmount,
            'roundOff': _roundOff,
            'gstType': _gstType,
          });
        }
      }

      if (mounted) {
        context.pop();
        AppToast.showSuccess(
          context,
          widget.poId == null
              ? 'Purchase Order Created!'
              : 'Purchase Order Updated!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Forcing dark for this specific screen request
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        theme.colorScheme.onSurface;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodySmall?.color ??
        theme.colorScheme.onSurfaceVariant;
    final borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.2);

    if (_isInitLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              widget.poId == null ? 'Create Purchase Order' : 'Edit Order',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            Text(
              'Fill in the details to create or update a purchase order.',
              style: GoogleFonts.inter(fontSize: 12, color: secondaryTextColor),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier Section
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<Supplier>(
                    width: constraints.maxWidth,
                    controller: _supplierSearchController,
                    enabled: !_isLockedAfterReceiveStart,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    leadingIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    label: const Text('Search Supplier'),
                    menuHeight: 300,
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    dropdownMenuEntries: _allSuppliers
                        .map<DropdownMenuEntry<Supplier>>((Supplier s) {
                          return DropdownMenuEntry<Supplier>(
                            value: s,
                            label: s.name,
                            style: MenuItemButton.styleFrom(
                              foregroundColor: textColor,
                            ),
                          );
                        })
                        .toList(),
                    onSelected: _isLockedAfterReceiveStart
                        ? null
                        : (Supplier? supplier) async {
                            if (supplier != null) {
                              final poService = context
                                  .read<PurchaseOrderService>();
                              final recentIds = await poService
                                  .getRecentProductsForSupplier(supplier.id);
                              setState(() {
                                _selectedSupplier = supplier;
                                _suggestedProductIds = recentIds;
                              });
                            } else {
                              setState(() {
                                _selectedSupplier = null;
                                _suggestedProductIds = [];
                              });
                            }
                          },
                    textStyle: TextStyle(color: textColor),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(cardColor),
                      surfaceTintColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              initialValue: _gstType,
                              isExpanded: true,
                              dropdownColor: cardColor,
                              decoration: const InputDecoration(
                                labelText: 'GST Type',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(color: textColor),
                              items: ['None', 'CGST+SGST', 'IGST']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isLockedAfterReceiveStart
                                  ? null
                                  : (v) {
                                      setState(() {
                                        _gstType = v!;
                                        if (_gstType == 'None') {
                                          _gstPercentController.text = '0';
                                        } else if (_gstPercentController.text ==
                                            '0') {
                                          _gstPercentController.text = '18';
                                        }
                                      });
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _isLockedAfterReceiveStart ? null : _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            child: IgnorePointer(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Expected Delivery',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: _expectedDate == null
                                      ? 'Select Date'
                                      : DateFormat(
                                          'dd-MM-yyyy',
                                        ).format(_expectedDate!),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_isLockedAfterReceiveStart) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'Receiving has started. Supplier, items, quantities, and totals are locked. You can update notes and invoice reference only.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _supplierInvoiceController,
                      decoration: _inputDecoration(
                        'Supplier Invoice Number (Optional)',
                        cardColor,
                        borderColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickInvoiceDate,
                      child: IgnorePointer(
                        child: TextField(
                          decoration:
                              _inputDecoration(
                                'Invoice Date (Optional)',
                                cardColor,
                                borderColor,
                              ).copyWith(
                                hintText: _invoiceDate == null
                                    ? 'Select Date'
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(_invoiceDate!),
                                suffixIcon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'Notes',
                  cardColor,
                  borderColor,
                ).copyWith(hintText: 'Optional notes'),
              ),

              const SizedBox(height: 32),
              _buildLabel('Order Items', textColor),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: _selectedSupplier == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Please select a supplier first to add products',
                                  style: TextStyle(color: secondaryTextColor),
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: secondaryTextColor.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items added yet',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Toggle
                          _buildLabel('Select Category', textColor),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ThemedSegmentControl<ProductType>(
                              segments: _purchaseCategories
                                  .map(
                                    (category) => ButtonSegment<ProductType>(
                                      value: category,
                                      label: Text(_categoryLabel(category)),
                                      icon: Icon(_categoryIcon(category)),
                                    ),
                                  )
                                  .toList(growable: false),
                              selected: {_itemCategoryFilter},
                              onSelectionChanged: (Set<ProductType> newVal) {
                                if (_isLockedAfterReceiveStart) return;
                                setState(() {
                                  _itemCategoryFilter = newVal.first;
                                  _selectedProduct = null;
                                  _productSearchController.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Add Item Form (Single Row)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Product Search
                              Expanded(
                                flex: 4,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return DropdownMenu<Product>(
                                      width: constraints.maxWidth,
                                      controller: _productSearchController,
                                      enabled: !_isLockedAfterReceiveStart,
                                      enableFilter: true,
                                      requestFocusOnTap: true,
                                      label: const Text('Product'),
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                            filled: true,
                                            fillColor: cardColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                          ),
                                      menuHeight: 300,
                                      dropdownMenuEntries: [
                                        // 1. "Add New" Option
                                        DropdownMenuEntry<Product>(
                                          value: Product(
                                            id: 'NEW_PRODUCT',
                                            name: ' Add New Product',
                                            sku: '',
                                            itemType: _itemCategoryFilter,
                                            type: _enumTypeForCategory(
                                              _itemCategoryFilter,
                                            ),
                                            category: '',
                                            stock: 0,
                                            price: 0,
                                            baseUnit: '',
                                            conversionFactor: 1,
                                            status: 'active',
                                            createdAt: '',
                                            unitWeightGrams: 0,
                                          ),
                                          label:
                                              ' Add New ${_categoryLabel(_itemCategoryFilter)}',
                                          style: MenuItemButton.styleFrom(
                                            foregroundColor:
                                                theme.colorScheme.primary,
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        // 2. Filtered Products mapped to entries
                                        ..._allProducts
                                            .where(_matchesSelectedCategory)
                                            .map<DropdownMenuEntry<Product>>((
                                              Product p,
                                            ) {
                                              final isSuggested =
                                                  _suggestedProductIds.contains(
                                                    p.id,
                                                  );
                                              return DropdownMenuEntry<Product>(
                                                value: p,
                                                label: isSuggested
                                                    ? '${p.name} (Suggested)'
                                                    : p.name,
                                                style: MenuItemButton.styleFrom(
                                                  foregroundColor: isSuggested
                                                      ? theme
                                                            .colorScheme
                                                            .primary
                                                      : textColor,
                                                ),
                                              );
                                            }),
                                      ],
                                      onSelected: _isLockedAfterReceiveStart
                                          ? null
                                          : (Product? p) async {
                                              if (p?.id == 'NEW_PRODUCT') {
                                                final newProduct = await context
                                                    .pushNamed<Product>(
                                                      'management_product_new',
                                                      queryParameters: {
                                                        'type':
                                                            _itemCategoryFilter
                                                                .value,
                                                        'supplierId':
                                                            _selectedSupplier
                                                                ?.id,
                                                        'supplierName':
                                                            _selectedSupplier
                                                                ?.name,
                                                      },
                                                    );

                                                if (newProduct != null) {
                                                  setState(() {
                                                    _allProducts.add(
                                                      newProduct,
                                                    );
                                                    _selectedProduct =
                                                        newProduct;
                                                    _priceController.text =
                                                        newProduct.purchasePrice
                                                            ?.toString() ??
                                                        '0';
                                                    _gstPercentController.text =
                                                        newProduct.gstRate
                                                            ?.toString() ??
                                                        '18';
                                                    _productSearchController
                                                            .text =
                                                        newProduct.name;
                                                    _updateItemTotal();
                                                  });
                                                }
                                                return;
                                              }
                                              setState(() {
                                                _selectedProduct = p;
                                                if (p != null) {
                                                  _priceController.text =
                                                      p.purchasePrice
                                                          ?.toString() ??
                                                      '0';
                                                  _gstPercentController.text =
                                                      p.gstRate?.toString() ??
                                                      '18';
                                                  _updateItemTotal();
                                                }
                                              });
                                            },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Rate
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  readOnly: _isLockedAfterReceiveStart,
                                  style: TextStyle(color: textColor),
                                  onChanged: _isLockedAfterReceiveStart
                                      ? null
                                      : (_) => _updateItemTotal(),
                                  decoration: _inputDecoration(
                                    'Rate',
                                    cardColor,
                                    borderColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Qty
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  readOnly: _isLockedAfterReceiveStart,
                                  inputFormatters: [
                                    NormalizedNumberInputFormatter.decimal(
                                      keepZeroWhenEmpty: true,
                                    ),
                                  ],
                                  style: TextStyle(color: textColor),
                                  onChanged: _isLockedAfterReceiveStart
                                      ? null
                                      : (_) => _updateItemTotal(),
                                  decoration: _inputDecoration(
                                    'Qty',
                                    cardColor,
                                    borderColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // GST%
                              Expanded(
                                flex: 2,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return DropdownMenu<String>(
                                      width: constraints.maxWidth,
                                      controller: _gstPercentController,
                                      enabled: !_isLockedAfterReceiveStart,
                                      enableFilter: true,
                                      requestFocusOnTap: true,
                                      label: const Text('GST%'),
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                            filled: true,
                                            fillColor: cardColor,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: borderColor,
                                              ),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                          ),
                                      dropdownMenuEntries:
                                          ['5', '12', '18', '28'].map((e) {
                                            return DropdownMenuEntry(
                                              value: e,
                                              label: '$e%',
                                            );
                                          }).toList(),
                                      onSelected: _isLockedAfterReceiveStart
                                          ? null
                                          : (v) {
                                              if (v != null) {
                                                _gstPercentController.text = v;
                                                _updateItemTotal();
                                              }
                                            },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Total
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _itemTotalController,
                                  readOnly: true,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: _inputDecoration(
                                    'Total',
                                    cardColor,
                                    borderColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Add Button
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: _isLockedAfterReceiveStart
                                      ? null
                                      : _addItem,
                                  icon: Icon(
                                    Icons.add_rounded,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Items Table
                          if (_items.isNotEmpty)
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              separatorBuilder: (c, i) =>
                                  Divider(color: borderColor, thickness: 1),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item.quantity} ${item.unit} x \u20B9${item.unitPrice} (+${item.gstPercentage}% GST)',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\u20B9${item.total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        onPressed: _isLockedAfterReceiveStart
                                            ? null
                                            : () => _removeItem(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 32),
              // Totals Section
              if (_items.isNotEmpty) ...[
                _buildSummaryRow(
                  'Subtotal (Taxable)',
                  '\u20B9${_subtotal.toStringAsFixed(2)}',
                  textColor,
                  secondaryTextColor,
                ),
                const SizedBox(height: 8),
                if (_gstType == 'CGST+SGST') ...[
                  _buildSummaryRow(
                    'CGST (${(_totalGst / 2).toStringAsFixed(2)})',
                    '\u20B9${(_totalGst / 2).toStringAsFixed(2)}',
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'SGST (${(_totalGst / 2).toStringAsFixed(2)})',
                    '\u20B9${(_totalGst / 2).toStringAsFixed(2)}',
                    textColor,
                    secondaryTextColor,
                  ),
                ] else if (_gstType == 'IGST') ...[
                  _buildSummaryRow(
                    'IGST (${_totalGst.toStringAsFixed(2)})',
                    '\u20B9${_totalGst.toStringAsFixed(2)}',
                    textColor,
                    secondaryTextColor,
                  ),
                ],
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Round Off',
                  '\u20B9${_roundOff.toStringAsFixed(2)}',
                  textColor,
                  secondaryTextColor,
                ),
                const Divider(height: 32),
                _buildSummaryRow(
                  'Grand Total',
                  '\u20B9${_totalAmount.toStringAsFixed(2)}',
                  textColor,
                  secondaryTextColor,
                  isTotal: true,
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.poId == null
                            ? 'Create Order'
                            : (_isLockedAfterReceiveStart
                                  ? 'Save Notes & Invoice'
                                  : 'Update Order'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color textColor,
    Color secondaryColor, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? textColor : secondaryColor,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFF3B82F6) : textColor,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 20 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, Color textColor) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    Color fillColor,
    Color borderColor,
  ) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: '0',
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      labelStyle: const TextStyle(fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.dark
              ? ThemeData.dark()
              : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _expectedDate = date);
    }
  }

  Future<void> _pickInvoiceDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 3, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDate: _invoiceDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.dark
              ? ThemeData.dark()
              : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _invoiceDate = date);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _gstPercentController.dispose();
    _itemTotalController.dispose();
    _supplierSearchController.dispose();
    _productSearchController.dispose();
    _supplierInvoiceController.dispose();
    super.dispose();
  }
}
