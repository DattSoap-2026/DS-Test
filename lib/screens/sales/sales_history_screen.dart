import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../models/types/product_types.dart';
import '../../models/types/sales_types.dart';
import '../../data/repositories/customer_repository.dart';
import '../../services/sales_service.dart';
import '../../services/settings_service.dart';
import '../../services/products_service.dart';
import '../../services/sales_import_export_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/pdf_generator.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/dialogs/responsive_dialog.dart';
import '../../widgets/ui/shimmer_list_loader.dart';
import '../../utils/debouncer.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late final SalesService _salesService;
  late final SettingsService _settingsService;
  late final SalesImportExportService? _importExportService;

  List<Sale> _sales = [];
  CompanyProfileData? _companyProfile;
  bool _isLoading = true;

  // Pagination
  final ScrollController _scrollController = ScrollController();
  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  static const int _pageSize = 50;

  // Filtering
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  List<Sale> get _filteredSales => _sales;

  double get _totalSalesAmount =>
      _filteredSales.fold(0.0, (sum, item) => sum + item.totalAmount);
  int get _totalOrdersCount => _filteredSales.length;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _salesService = context.read<SalesService>();
    _settingsService = context.read<SettingsService>();
    try {
      _importExportService = context.read<SalesImportExportService>();
    } catch (e) {
      _importExportService = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _load();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadSales(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.wait([_loadSales(), _loadCompanyProfile()]);
  }

  Future<void> _loadSales({bool loadMore = false}) async {
    if (loadMore && (_isFetchingMore || !_hasMore)) return;

    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _offset = 0;
          _hasMore = true;
          _sales = [];
        });
      } else {
        setState(() => _isFetchingMore = true);
      }

      final authProvider = context.read<AuthProvider>();
      final appUser = authProvider.state.user;

      if (appUser == null) {
        if (mounted) {
          setState(() {
            _sales = const [];
            _isLoading = false;
            _isFetchingMore = false;
          });
        }
        return;
      }

      final fetchedSales = await _salesService.getSalesClient(
        salesmanId: appUser.id,
        limit: _pageSize,
        offset: _offset,
        searchQuery: _searchQuery,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _sales.addAll(fetchedSales);
          } else {
            _sales = fetchedSales;
          }
          if (fetchedSales.length < _pageSize) {
            _hasMore = false;
          } else {
            _offset += _pageSize;
          }
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load sales: $e')));
        });
      }
    }
  }

  String _invoiceDisplayId(Sale sale) {
    final humanReadable = sale.humanReadableId?.trim();
    if (humanReadable != null && humanReadable.isNotEmpty) {
      return humanReadable.toUpperCase();
    }

    final rawId = sale.id.trim();
    if (rawId.isEmpty) return 'N/A';

    final compact = rawId.replaceAll('-', '').toUpperCase();
    if (compact.length <= 6) return compact;
    return compact.substring(compact.length - 6);
  }

  Future<void> _loadCompanyProfile() async {
    try {
      final profile = await _settingsService.getCompanyProfileClient();
      if (mounted) {
        setState(() => _companyProfile = profile);
      }
    } catch (e) {
      debugPrint('Error loading company profile: $e');
    }
  }

  bool _isSaleEditable(Sale sale) {
    final status = (sale.status ?? '').trim().toLowerCase();
    return status != 'cancelled';
  }

  Future<void> _showEditSaleDialog(Sale sale) async {
    if (!_isSaleEditable(sale)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancelled sale cannot be edited')),
      );
      return;
    }

    final screenContext = context;
    final quantityControllers = <String, TextEditingController>{};
    for (var index = 0; index < sale.items.length; index++) {
      quantityControllers['$index'] = TextEditingController(
        text: sale.items[index].quantity.toString(),
      );
    }
    final discountController = TextEditingController(
      text: sale.discountPercentage.toStringAsFixed(2),
    );
    final additionalDiscountController = TextEditingController(
      text: (sale.additionalDiscountPercentage ?? 0).toStringAsFixed(2),
    );
    final routeController = TextEditingController(
      text: (sale.route ?? '').trim(),
    );
    var isSaving = false;

    try {
      final customerRepo = screenContext.read<CustomerRepository>();
      final productsService = screenContext.read<ProductsService>();

      final customerEntities = await customerRepo.getAllCustomers();
      final customers = customerEntities.map((e) => e.toDomain()).toList()
        ..sort(
          (a, b) =>
              a.shopName.toLowerCase().compareTo(b.shopName.toLowerCase()),
        );

      final products = await productsService.getProducts(status: 'active');
      products.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      String resolveCustomerRoute(Customer customer) {
        final salesRoute = customer.salesRoute?.trim();
        if (salesRoute != null && salesRoute.isNotEmpty) {
          return salesRoute;
        }
        return customer.route.trim();
      }

      final customerNameById = <String, String>{};
      final customerRouteById = <String, String>{};
      final customerDisplayById = <String, String>{};

      for (final customer in customers) {
        final customerId = customer.id.trim();
        if (customerId.isEmpty) continue;

        final name = customer.shopName.trim();
        final owner = customer.ownerName.trim();
        final route = resolveCustomerRoute(customer);
        final routePart = route.isEmpty ? '' : ' • $route';
        final ownerPart = owner.isEmpty ? '' : ' • $owner';
        customerNameById[customerId] = name.isEmpty ? customerId : name;
        customerRouteById[customerId] = route;
        customerDisplayById[customerId] =
            '${name.isEmpty ? customerId : name}$routePart$ownerPart';
      }

      final fallbackRecipientId = sale.recipientId.trim();
      if (fallbackRecipientId.isNotEmpty &&
          !customerNameById.containsKey(fallbackRecipientId)) {
        final fallbackRoute = (sale.route ?? '').trim();
        final routePart = fallbackRoute.isEmpty ? '' : ' • $fallbackRoute';
        customerNameById[fallbackRecipientId] = sale.recipientName;
        customerRouteById[fallbackRecipientId] = fallbackRoute;
        customerDisplayById[fallbackRecipientId] =
            '${sale.recipientName}$routePart';
      }

      final customerIds = customerNameById.keys.toList()
        ..sort(
          (a, b) => (customerDisplayById[a] ?? a).toLowerCase().compareTo(
            (customerDisplayById[b] ?? b).toLowerCase(),
          ),
        );

      String? selectedCustomerId = customerIds.contains(fallbackRecipientId)
          ? fallbackRecipientId
          : (customerIds.isEmpty ? null : customerIds.first);

      if (routeController.text.trim().isEmpty && selectedCustomerId != null) {
        final selectedRoute = (customerRouteById[selectedCustomerId] ?? '')
            .trim();
        if (selectedRoute.isNotEmpty) {
          routeController.text = selectedRoute;
        }
      }

      final productById = <String, Product>{
        for (final product in products) product.id: product,
      };
      final productNameById = <String, String>{
        for (final product in products) product.id: product.name,
      };
      for (final item in sale.items) {
        final itemProductId = item.productId.trim();
        if (itemProductId.isEmpty) continue;
        productNameById.putIfAbsent(itemProductId, () => item.name);
      }

      final selectableProductIds = productNameById.keys.toList()
        ..sort(
          (a, b) => (productNameById[a] ?? a).toLowerCase().compareTo(
            (productNameById[b] ?? b).toLowerCase(),
          ),
        );

      final selectedProductByIndex = <String, String>{};
      for (var index = 0; index < sale.items.length; index++) {
        selectedProductByIndex['$index'] = sale.items[index].productId;
      }

      if (!screenContext.mounted) return;
      final saved = await showDialog<bool>(
        context: screenContext,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> submit() async {
                try {
                  final recipientId = (selectedCustomerId ?? '').trim();
                  if (recipientId.isEmpty) {
                    throw Exception('Please select a customer');
                  }

                  final recipientName = (customerNameById[recipientId] ?? '')
                      .trim();
                  if (recipientName.isEmpty) {
                    throw Exception('Invalid customer selected');
                  }

                  String? nextRoute = routeController.text.trim();
                  if (nextRoute.isEmpty) {
                    final mappedRoute = (customerRouteById[recipientId] ?? '')
                        .trim();
                    nextRoute = mappedRoute.isEmpty ? null : mappedRoute;
                  }

                  final editedItems = <SaleItemForUI>[];
                  for (var index = 0; index < sale.items.length; index++) {
                    final sourceItem = sale.items[index];
                    final selectedProductId =
                        (selectedProductByIndex['$index'] ??
                                sourceItem.productId)
                            .trim();
                    if (selectedProductId.isEmpty) {
                      throw Exception(
                        'Please select a product for line ${index + 1}',
                      );
                    }

                    final selectedProduct = productById[selectedProductId];
                    final isSameProduct =
                        selectedProductId == sourceItem.productId;
                    if (!isSameProduct && selectedProduct == null) {
                      throw Exception(
                        'Selected product not found for line ${index + 1}',
                      );
                    }

                    final quantityText = quantityControllers['$index']!.text
                        .trim();
                    final parsedQty = int.tryParse(quantityText);
                    if (parsedQty == null || parsedQty <= 0) {
                      throw Exception(
                        'Invalid quantity for ${sourceItem.name}. Enter positive whole number.',
                      );
                    }

                    final resolvedBaseUnit = isSameProduct
                        ? sourceItem.baseUnit
                        : ((selectedProduct?.baseUnit ?? sourceItem.baseUnit)
                                  .trim()
                                  .isEmpty
                              ? sourceItem.baseUnit
                              : (selectedProduct?.baseUnit ??
                                    sourceItem.baseUnit));

                    editedItems.add(
                      SaleItemForUI(
                        productId: selectedProductId,
                        name: isSameProduct
                            ? sourceItem.name
                            : (selectedProduct?.name ?? sourceItem.name),
                        quantity: parsedQty,
                        price: isSameProduct
                            ? sourceItem.price
                            : (selectedProduct?.price ?? sourceItem.price),
                        isFree: sourceItem.isFree,
                        discount: sourceItem.discount,
                        secondaryPrice: isSameProduct
                            ? sourceItem.secondaryPrice
                            : selectedProduct?.secondaryPrice,
                        conversionFactor: isSameProduct
                            ? sourceItem.conversionFactor
                            : selectedProduct?.conversionFactor,
                        baseUnit: resolvedBaseUnit,
                        secondaryUnit: isSameProduct
                            ? sourceItem.secondaryUnit
                            : selectedProduct?.secondaryUnit,
                        schemeName: isSameProduct
                            ? sourceItem.schemeName
                            : null,
                        returnedQuantity: sourceItem.returnedQuantity,
                        stock: isSameProduct
                            ? sourceItem.quantity
                            : (selectedProduct?.stock ??
                                      sourceItem.quantity.toDouble())
                                  .round(),
                      ),
                    );
                  }

                  final discountPct = double.tryParse(
                    discountController.text.trim(),
                  );
                  if (discountPct == null ||
                      discountPct < 0 ||
                      discountPct > 100) {
                    throw Exception(
                      'Primary discount must be between 0 and 100',
                    );
                  }

                  final additionalPct = double.tryParse(
                    additionalDiscountController.text.trim(),
                  );
                  if (additionalPct == null ||
                      additionalPct < 0 ||
                      additionalPct > 100) {
                    throw Exception(
                      'Additional discount must be between 0 and 100',
                    );
                  }

                  final editedByUserId =
                      screenContext.read<AuthProvider>().state.user?.id ??
                      'system';

                  setDialogState(() => isSaving = true);
                  await _salesService.editSale(
                    saleId: sale.id,
                    items: editedItems,
                    discountPercentage: discountPct,
                    additionalDiscountPercentage: additionalPct,
                    gstPercentage: sale.gstPercentage,
                    gstType: sale.gstType,
                    recipientId: recipientId,
                    recipientName: recipientName,
                    route: nextRoute,
                    editedBy: editedByUserId,
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop(true);
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(content: Text('Failed to edit sale: $e')),
                  );
                } finally {
                  if (dialogContext.mounted) {
                    setDialogState(() => isSaving = false);
                  }
                }
              }

              return ResponsiveDialog(
                maxWidth: 640,
                maxHeightFactor: 0.92,
                borderRadius: BorderRadius.circular(12),
                scrollable: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(dialogContext).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit Sale',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: routeController,
                              enabled: !isSaving,
                              decoration: InputDecoration(
                                labelText: 'Route',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: selectedCustomerId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Customer',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: customerIds
                                  .map(
                                    (customerId) => DropdownMenuItem<String>(
                                      value: customerId,
                                      child: Text(
                                        customerDisplayById[customerId] ??
                                            customerNameById[customerId] ??
                                            customerId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isSaving
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        selectedCustomerId = value;
                                        if (value == null) return;
                                        final mappedRoute =
                                            (customerRouteById[value] ?? '')
                                                .trim();
                                        if (mappedRoute.isNotEmpty) {
                                          routeController.text = mappedRoute;
                                        }
                                      });
                                    },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Update product and quantities',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            ...sale.items.asMap().entries.map((entry) {
                              final index = entry.key;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue:
                                            selectedProductByIndex['$index'],
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Product',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        items: selectableProductIds
                                            .map(
                                              (
                                                productId,
                                              ) => DropdownMenuItem<String>(
                                                value: productId,
                                                child: Text(
                                                  productNameById[productId] ??
                                                      productId,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: isSaving
                                            ? null
                                            : (value) {
                                                if (value == null) return;
                                                setDialogState(() {
                                                  selectedProductByIndex['$index'] =
                                                      value;
                                                });
                                              },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 90,
                                      child: TextField(
                                        controller:
                                            quantityControllers['$index'],
                                        enabled: !isSaving,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Qty',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            TextField(
                              controller: discountController,
                              enabled: !isSaving,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Primary Discount %',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: additionalDiscountController,
                              enabled: !isSaving,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Additional Discount %',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: isSaving ? null : submit,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(isSaving ? 'Saving...' : 'Save'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      if (saved == true) {
        await _loadSales();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to open edit form: $e')));
      }
    } finally {
      for (final controller in quantityControllers.values) {
        controller.dispose();
      }
      discountController.dispose();
      additionalDiscountController.dispose();
      routeController.dispose();
    }
  }

  void _viewInvoiceDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveDialog(
        maxWidth: 800,
        maxHeightFactor: 0.9,
        borderRadius: BorderRadius.circular(12),
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 620;
                  final companyInfo = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DATT SOAP FACTORY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '123,Railway Station MIDC,Chatrapati Sambhaji Nagar',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '0988099933 | sale@Dattsoap.com',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                  final invoiceInfo = Column(
                    crossAxisAlignment: isNarrow
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'INVOICE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${_invoiceDisplayId(sale)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Date: ${_formatDateSafe(sale.createdAt, pattern: 'dd MMMM yyyy')}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: companyInfo),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        invoiceInfo,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: companyInfo),
                      const SizedBox(width: 16),
                      invoiceInfo,
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill To & Dispatch Details
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 620;
                        final billTo = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BILL TO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sale.recipientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                        final dispatchDetails = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DISPATCH DETAILS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dispatched By: ${sale.salesmanName}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              billTo,
                              const SizedBox(height: 12),
                              dispatchDetails,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: billTo),
                            const SizedBox(width: 20),
                            dispatchDetails,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Products Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '#',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Product',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Qty',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Rate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Table Rows
                          ...sale.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final amount =
                                item.lineTotalAmount ??
                                item.lineNetAmount ??
                                item.lineSubtotal ??
                                (item.price *
                                    item.quantity *
                                    (1 - (item.discount / 100)));

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatCurrency(item.price),
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatCurrency(amount),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Summary
                    Builder(
                      builder: (context) {
                        final lineDiscountAmount = sale.itemDiscountAmount;
                        final additionalDiscountAmount =
                            sale.additionalDiscountAmount ?? 0.0;
                        final additionalDiscountPct =
                            sale.additionalDiscountPercentage ?? 0.0;
                        final normalizedGstType = _normalizeGstType(
                          sale.gstType,
                        );
                        final gstPct = sale.gstPercentage
                            .clamp(0.0, 100.0)
                            .toDouble();
                        double cgstAmount = sale.cgstAmount ?? 0.0;
                        double sgstAmount = sale.sgstAmount ?? 0.0;
                        double igstAmount = sale.igstAmount ?? 0.0;
                        var totalGstAmount =
                            cgstAmount + sgstAmount + igstAmount;
                        var fallbackGstAmount = _round2(
                          sale.totalAmount - sale.taxableAmount,
                        );
                        if (fallbackGstAmount < 0) fallbackGstAmount = 0.0;
                        if (totalGstAmount <= 0 && fallbackGstAmount > 0) {
                          totalGstAmount = fallbackGstAmount;
                          if (normalizedGstType == 'CGST+SGST') {
                            cgstAmount = _round2(totalGstAmount / 2);
                            sgstAmount = _round2(totalGstAmount - cgstAmount);
                          } else if (normalizedGstType == 'IGST') {
                            igstAmount = totalGstAmount;
                          }
                        }
                        if (normalizedGstType == 'CGST+SGST' &&
                            totalGstAmount > 0 &&
                            cgstAmount <= 0 &&
                            sgstAmount <= 0) {
                          cgstAmount = _round2(totalGstAmount / 2);
                          sgstAmount = _round2(totalGstAmount - cgstAmount);
                        }
                        if (normalizedGstType == 'IGST' &&
                            totalGstAmount > 0 &&
                            igstAmount <= 0) {
                          igstAmount = totalGstAmount;
                        }
                        final gstHalfPct = gstPct > 0 ? gstPct / 2 : 0.0;

                        return Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 420,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildSummaryRow(
                                        'Subtotal:',
                                        _formatCurrency(sale.subtotal),
                                      ),
                                      if (lineDiscountAmount > 0)
                                        _buildSummaryRow(
                                          '${_lineDiscountLabel(sale, lineDiscountAmount)}:',
                                          '-${_formatCurrency(lineDiscountAmount)}',
                                          valueColor: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      if (sale.discountAmount > 0)
                                        _buildSummaryRow(
                                          sale.discountPercentage > 0
                                              ? 'Primary Discount (${_formatPercent(sale.discountPercentage)}%):'
                                              : 'Primary Discount:',
                                          '-${_formatCurrency(sale.discountAmount)}',
                                          valueColor: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      if (additionalDiscountAmount > 0)
                                        _buildSummaryRow(
                                          additionalDiscountPct > 0
                                              ? 'Additional Discount (${_formatPercent(additionalDiscountPct)}%):'
                                              : 'Additional Discount:',
                                          '-${_formatCurrency(additionalDiscountAmount)}',
                                          valueColor: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      const Divider(),
                                      _buildSummaryRow(
                                        'Taxable Value:',
                                        _formatCurrency(sale.taxableAmount),
                                      ),
                                      if (cgstAmount > 0)
                                        _buildSummaryRow(
                                          'CGST (${_formatPercent(gstHalfPct)}%):',
                                          _formatCurrency(cgstAmount),
                                        ),
                                      if (sgstAmount > 0)
                                        _buildSummaryRow(
                                          'SGST (${_formatPercent(gstHalfPct)}%):',
                                          _formatCurrency(sgstAmount),
                                        ),
                                      if (igstAmount > 0)
                                        _buildSummaryRow(
                                          'IGST (${_formatPercent(gstPct)}%):',
                                          _formatCurrency(igstAmount),
                                        ),
                                      if ((sale.roundOff ?? 0).abs() > 0.009)
                                        _buildSummaryRow(
                                          'Round Off:',
                                          _formatCurrency(sale.roundOff ?? 0),
                                        ),
                                      const SizedBox(height: 8),
                                      _buildSummaryRow(
                                        'Grand Total:',
                                        _formatCurrency(sale.totalAmount),
                                        isBold: true,
                                        valueColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      if (sale.paidAmount > 0)
                                        _buildSummaryRow(
                                          'Paid:',
                                          _formatCurrency(sale.paidAmount),
                                          valueColor: AppColors.success,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  if (_isSaleEditable(sale))
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _showEditSaleDialog(sale);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_companyProfile != null) {
                        try {
                          await PdfGenerator.generateAndPrintSaleInvoice(
                            sale,
                            _companyProfile!,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Print failed: $e')),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_companyProfile != null) {
                        try {
                          await PdfGenerator.shareSaleInvoice(
                            sale,
                            _companyProfile!,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Share failed: $e')),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) => '₹${value.toStringAsFixed(2)}';

  double _round2(double value) => (value * 100).roundToDouble() / 100;

  String _formatPercent(double value) {
    final rounded = _round2(value);
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toStringAsFixed(0);
    }
    return rounded
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _lineDiscountLabel(Sale sale, double lineDiscountAmount) {
    if (lineDiscountAmount <= 0) return 'Line Discount';
    final itemDiscounts = sale.items
        .where((item) => !item.isFree && item.discount > 0)
        .map((item) => _round2(item.discount))
        .toSet();
    if (itemDiscounts.length == 1) {
      return 'Line Discount (${_formatPercent(itemDiscounts.first)}%)';
    }
    if (sale.subtotal > 0) {
      final effectivePct = _round2((lineDiscountAmount * 100) / sale.subtotal);
      return 'Line Discount (${_formatPercent(effectivePct)}%)';
    }
    return 'Line Discount';
  }

  String _normalizeGstType(String raw) {
    final normalized = raw.trim().toUpperCase();
    if (normalized == 'CGST+SGST') return 'CGST+SGST';
    if (normalized == 'IGST') return 'IGST';
    return 'NONE';
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          if (_importExportService != null) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'export_csv') {
                  await _exportToCSV();
                } else if (value == 'export_excel') {
                  await _exportToExcel();
                } else if (value == 'import') {
                  await _importFromCSV();
                } else if (value == 'template') {
                  await _downloadTemplate();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export_csv',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 12),
                      Text('Export to CSV'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, size: 20),
                      SizedBox(width: 12),
                      Text('Export to Excel'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.upload, size: 20),
                      SizedBox(width: 12),
                      Text('Import from CSV'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'template',
                  child: Row(
                    children: [
                      Icon(Icons.file_download, size: 20),
                      SizedBox(width: 12),
                      Text('Download Template'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const ShimmerListLoader(itemCount: 15)
          : _buildScrollableContent(),
    );
  }

  Widget _buildScrollableContent() {
    final hasSales = _filteredSales.isNotEmpty;
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCards()),
        SliverToBoxAdapter(child: _buildFilterBar()),
        if (!hasSales)
          SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
        else
          _buildSalesList(),
        if (_isFetchingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: KPICard(
              title: 'Total Sales',
              value: 'Rs ${NumberFormat('#,##,###').format(_totalSalesAmount)}',
              icon: Icons.payments_rounded,
              color: Theme.of(context).primaryColor,
              dense: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: KPICard(
              title: 'Total Orders',
              value: _totalOrdersCount.toString(),
              icon: Icons.receipt_long_rounded,
              color: AppColors.success,
              dense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final hasDateFilter = _startDate != null && _endDate != null;
    final dateLabel = hasDateFilter
        ? '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}'
        : 'All Dates';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                _debouncer.run(() {
                  setState(() => _searchQuery = value);
                  _loadSales();
                });
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search by client name...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range, size: 16),
              label: Text(
                dateLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadSales();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No sales match your filters.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_searchQuery.isNotEmpty || _startDate != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _startDate = null;
                  _endDate = null;
                });
                _loadSales();
              },
              child: const Text('Clear all filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final sale = _filteredSales[index];
          return UnifiedCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => _viewInvoiceDetails(sale),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 430;
                  final leadingIcon = Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                  final saleInfo = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.recipientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'INV-${_invoiceDisplayId(sale)} | ${_formatDateSafe(sale.createdAt, pattern: 'MMM d, yyyy')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                  final amountInfo = Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${NumberFormat('#,##,###.00').format(sale.totalAmount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        (sale.status ?? 'pending').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: sale.status == 'completed'
                              ? AppColors.success
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            leadingIcon,
                            const SizedBox(width: 12),
                            Expanded(child: saleInfo),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: amountInfo,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      leadingIcon,
                      const SizedBox(width: 16),
                      Expanded(child: saleInfo),
                      amountInfo,
                    ],
                  );
                },
              ),
            ),
          );
        }, childCount: _filteredSales.length),
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Future<void> _exportToCSV() async {
    try {
      await _importExportService!.exportSalesToCsv(
        sales: _filteredSales,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sales exported to CSV')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      await _importExportService!.exportSalesToExcel(
        sales: _filteredSales,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sales exported to Excel')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importFromCSV() async {
    try {
      final result = await _importExportService!.importSalesFromCsv();
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Complete'),
            content: Text(
              'Success: ${result['success']}\n'
              'Failed: ${result['failed']}\n\n'
              '${(result['errors'] as List).take(5).join('\n')}'
              '${(result['errors'] as List).length > 5 ? '\n...' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        await _loadSales();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      await _importExportService!.generateImportTemplate();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Template downloaded')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }
}
