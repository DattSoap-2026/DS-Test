// ⚠️ CRITICAL FILE - DO NOT MODIFY WITHOUT PERMISSION
// Stock dispatch screen with auto-populated route field from salesman selection.
// Modified: Reordered fields (Salesman → Route → Vehicle), route auto-populates from salesman
// Contact: Developer before making changes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/themed_filter_chip.dart';
import '../../models/types/user_types.dart'; // Kept from original
import '../../models/types/sales_types.dart'; // Kept from original
import '../../models/types/product_types.dart';
import '../../models/types/route_order_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/inventory_service.dart';

import '../../services/users_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/route_order_service.dart';

import '../../services/products_service.dart';
import '../../services/schemes_service.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../utils/responsive.dart';
import '../../utils/unit_converter.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/app_logger.dart';

class DispatchScreen extends StatefulWidget {
  final Object? prefillExtra;

  const DispatchScreen({super.key, this.prefillExtra});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen>
    with AutomaticKeepAliveClientMixin, RouteAware {
  late final InventoryService _inventoryService;
  late final UsersService _usersService;
  late final VehiclesService _vehiclesService;
  late final RouteOrderService _routeOrderService;

  // ProductsService likely needs DB too, assuming it's provided:
  late final ProductsService _productsService;
  late final SchemesService _schemesService;

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryService>();
    _usersService = context.read<UsersService>();
    _vehiclesService = context.read<VehiclesService>();
    _routeOrderService = context.read<RouteOrderService>();

    _productsService = context.read<ProductsService>();
    _schemesService = context.read<SchemesService>();
    _loadMasterData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryApplyRouteOrderPrefill();
    });
  }

  // Form State
  String? _selectedRoute; // Dispatch Route
  AppUser? _selectedSalesman;
  Vehicle? _selectedVehicle;
  List<SaleItem> _cartItems = [];
  double _additionalDiscountAmount = 0;
  double _additionalDiscountPercent = 0;
  String _discountType = '%'; // '%' or '₹'

  // Master Data
  List<String> _routes = [];
  final Map<String, String> _routeIdByName = {};
  List<AppUser> _allSalesmen = [];
  List<Vehicle> _allVehicles = [];
  List<Product> _allProducts = [];
  List<Scheme> _allSchemes = [];

  // UI State
  String _productFilterType = 'Finished'; // 'Finished' | 'Traded'
  bool _isLoading = true;
  bool _isProcessing = false;
  TextEditingController? _internalProductSearchController;
  final Map<String, TextEditingController> _qtyControllers = {};
  int _todayDispatchCount = 0;
  int _todayItemsCount = 0;
  RouteOrderDispatchPayload? _routeOrderPayload;
  bool _routeOrderPrefillApplied = false;

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    // Autocomplete owns its controller; don't dispose it here.
    _internalProductSearchController = null;
    super.dispose();
  }

  RouteOrderDispatchPayload? _parseRouteOrderPayload(Object? raw) {
    if (raw == null) return null;
    if (raw is RouteOrderDispatchPayload) return raw;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final nested = map['routeOrderPrefill'];
      if (nested is Map) {
        try {
          return RouteOrderDispatchPayload.fromJson(
            Map<String, dynamic>.from(nested),
          );
        } catch (_) {}
      }
      try {
        return RouteOrderDispatchPayload.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _clearQtyControllers() {
    if (_qtyControllers.isEmpty) return;
    final controllers = _qtyControllers.values.toList(growable: false);
    _qtyControllers.clear();
    _disposeControllersLater(controllers);
  }

  String? _resolvePrefillRouteName(RouteOrderDispatchPayload payload) {
    final routeId = payload.routeId.trim();
    final routeName = payload.routeName.trim();

    for (final name in _routes) {
      final normalizedName = _normalizeRouteKey(name);
      final mappedRouteId = _routeIdByName[normalizedName];
      if (routeId.isNotEmpty && mappedRouteId == routeId) return name;
      if (routeName.isNotEmpty &&
          _normalizeRouteKey(name) == _normalizeRouteKey(routeName)) {
        return name;
      }
    }
    if (routeName.isNotEmpty) return routeName;
    return null;
  }

  AppUser? _resolvePrefillSalesman(
    RouteOrderDispatchPayload payload,
    String? routeName,
  ) {
    final salesmanId = payload.salesmanId.trim();
    if (salesmanId.isNotEmpty) {
      for (final salesman in _allSalesmen) {
        if (salesman.id == salesmanId) {
          return salesman;
        }
      }
    }
    return _findSalesmanForRoute(routeName, _allSalesmen);
  }

  Vehicle? _resolvePrefillVehicle(RouteOrderDispatchPayload payload) {
    final vehicleId = payload.vehicleId.trim();
    final vehicleNumber = payload.vehicleNumber.trim();
    for (final vehicle in _allVehicles) {
      if (vehicleId.isNotEmpty && vehicle.id == vehicleId) {
        return vehicle;
      }
      if (vehicleNumber.isNotEmpty &&
          vehicle.number.trim().toLowerCase() == vehicleNumber.toLowerCase()) {
        return vehicle;
      }
    }
    return null;
  }

  List<SaleItem> _buildCartItemsFromPayload(RouteOrderDispatchPayload payload) {
    final mergedByProductId = <String, SaleItem>{};
    for (final orderItem in payload.items) {
      final productId = orderItem.productId.trim();
      if (productId.isEmpty || orderItem.qty <= 0) continue;
      Product? product;
      for (final candidate in _allProducts) {
        if (candidate.id == productId) {
          product = candidate;
          break;
        }
      }
      final baseUnit = orderItem.baseUnit.trim().isNotEmpty
          ? orderItem.baseUnit.trim()
          : (product?.baseUnit ?? 'Unit');
      final price = orderItem.price > 0
          ? orderItem.price
          : (product?.price ?? 0.0);

      final existing = mergedByProductId[productId];
      final mergedQty = (existing?.quantity ?? 0) + orderItem.qty;
      mergedByProductId[productId] = SaleItem(
        productId: productId,
        name: orderItem.name.trim().isNotEmpty
            ? orderItem.name.trim()
            : (product?.name ?? 'Product'),
        quantity: mergedQty,
        price: price,
        discount: product?.defaultDiscount ?? 0,
        secondaryPrice: product?.secondaryPrice,
        conversionFactor: product?.conversionFactor,
        baseUnit: baseUnit,
        secondaryUnit: product?.secondaryUnit,
      );
    }
    return mergedByProductId.values.toList();
  }

  void _tryApplyRouteOrderPrefill() {
    if (!mounted || _isLoading || _routeOrderPrefillApplied) return;
    final payload = _parseRouteOrderPayload(widget.prefillExtra);
    if (payload == null || payload.routeOrderId.trim().isEmpty) return;

    final resolvedRoute = _resolvePrefillRouteName(payload);
    final resolvedSalesman = _resolvePrefillSalesman(payload, resolvedRoute);
    final resolvedVehicle = _resolvePrefillVehicle(payload);
    final prefillItems = _buildCartItemsFromPayload(payload);

    final nextRoutes = List<String>.from(_routes);
    if (resolvedRoute != null && resolvedRoute.trim().isNotEmpty) {
      final exists = nextRoutes.any(
        (route) =>
            _normalizeRouteKey(route) == _normalizeRouteKey(resolvedRoute),
      );
      if (!exists) {
        nextRoutes.add(resolvedRoute);
        nextRoutes.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
    }

    _clearQtyControllers();
    setState(() {
      _routeOrderPayload = payload;
      _routeOrderPrefillApplied = true;
      _routes = nextRoutes;
      if (resolvedRoute != null && resolvedRoute.trim().isNotEmpty) {
        _selectedRoute = resolvedRoute;
        if (payload.routeId.trim().isNotEmpty) {
          _routeIdByName[_normalizeRouteKey(resolvedRoute)] = payload.routeId
              .trim();
        }
      }
      _selectedSalesman = resolvedSalesman ?? _selectedSalesman;
      _selectedVehicle = resolvedVehicle ?? _selectedVehicle;
      _cartItems = prefillItems;
      _additionalDiscountAmount = 0;
      _additionalDiscountPercent = 0;
      _discountType = '%';
    });

    _recalculateSchemes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Route order ${payload.routeOrderNo} loaded. Review items and confirm dispatch.',
        ),
      ),
    );
  }

  Future<void> _loadMasterData() async {
    try {
      final results = await Future.wait([
        _vehiclesService.getRoutes(), // Load routes from Master Data
        _usersService.getUsers(role: UserRole.salesman),
        _vehiclesService.getVehicles(status: 'active'),
        _productsService.getProducts(
          status: 'active',
          // itemType: 'Finished Good', // Load all to support filtering
        ),
        _schemesService.getSchemes(status: 'active'),
      ]);

      // Extract route names from Master Data routes
      final routeData = results[0] as List<Map<String, dynamic>>;
      final activeRoutes = routeData
          .where((r) => r['status'] == 'active' || r['isActive'] == true)
          .toList();
      final routeNames = <String>[];
      final routeIdByName = <String, String>{};
      for (final route in activeRoutes) {
        final name = (route['name'] as String?)?.trim();
        if (name == null || name.isEmpty) {
          continue;
        }
        routeNames.add(name);
        final id = route['id'];
        if (id != null) {
          final idString = id.toString().trim();
          if (idString.isNotEmpty) {
            routeIdByName[_normalizeRouteKey(name)] = idString;
          }
        }
      }

      setState(() {
        _routes = routeNames;
        _routeIdByName
          ..clear()
          ..addAll(routeIdByName);
        _allSalesmen = results[1] as List<AppUser>;
        _allVehicles = results[2] as List<Vehicle>;
        _allProducts = results[3] as List<Product>;
        _allSchemes = results[4] as List<Scheme>;
        if (_selectedRoute != null) {
          _selectedSalesman = _findSalesmanForRoute(
            _selectedRoute,
            _allSalesmen,
          );
        }
        _isLoading = false;
      });
      _tryApplyRouteOrderPrefill();
    } catch (e) {
      debugPrint('Error loading master data: $e');
      setState(() => _isLoading = false);
      _tryApplyRouteOrderPrefill();
    } finally {
      await _loadDispatchStats();
    }
  }

  bool _isDispatchRecord(Map<String, dynamic> data) {
    return data['dispatchId'] != null &&
        data['salesmanId'] != null &&
        data['items'] is List;
  }

  int _safeQuantity(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _loadDispatchStats() async {
    try {
      final records = await _inventoryService.loadFromLocal();
      if (records.isEmpty) {
        if (!mounted) return;
        setState(() {
          _todayDispatchCount = 0;
          _todayItemsCount = 0;
        });
        return;
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      int dispatchCount = 0;
      int itemsCount = 0;

      for (final record in records) {
        if (!_isDispatchRecord(record)) continue;
        final createdAtStr = record['createdAt']?.toString();
        if (createdAtStr == null || createdAtStr.isEmpty) continue;
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt == null) continue;
        if (createdAt.toLocal().isBefore(todayStart)) continue;

        dispatchCount += 1;
        final items = record['items'];
        if (items is List) {
          for (final item in items) {
            if (item is Map) {
              itemsCount += _safeQuantity(item['quantity']);
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _todayDispatchCount = dispatchCount;
        _todayItemsCount = itemsCount;
      });
    } catch (e) {
      debugPrint('Error loading dispatch stats: $e');
    }
  }

  void _addProduct(Product product) {
    // Check if product already in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id && !item.isFree,
    );

    if (existingIndex != -1) {
      // Show error or increment quantity? User screenshots show a table,
      // let's just add a new row or alert. Usually it's better to update existing.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} is already in the list')),
      );
      return;
    }

    setState(() {
      _cartItems.add(
        SaleItem(
          productId: product.id,
          name: product.name,
          quantity: 0,
          price: product.price,
          discount: product.defaultDiscount ?? 0,
          baseUnit: product.baseUnit,
          secondaryUnit: product.secondaryUnit,
          conversionFactor: product.conversionFactor,
          secondaryPrice: product.secondaryPrice,
        ),
      );
    });
    // Call outside setState to avoid nested setState (render issue)
    _recalculateSchemes();
  }

  void _recalculateSchemes() {
    // Remove existing free items
    _cartItems.removeWhere((item) => item.isFree);

    final List<SaleItem> freeItems = [];
    for (final item in _cartItems) {
      // Find matching schemes
      final matchingSchemes = _allSchemes.where(
        (s) =>
            s.buyProductId == item.productId && item.quantity >= s.buyQuantity,
      );

      for (final scheme in matchingSchemes) {
        final multiplier = (item.quantity ~/ scheme.buyQuantity);
        final freeQuantity = multiplier * scheme.getQuantity;

        if (freeQuantity > 0) {
          // Find the free product name
          final freeProduct = _allProducts.firstWhere(
            (p) => p.id == scheme.getProductId,
            orElse: () => Product(
              id: scheme.getProductId,
              name: 'Free Item',
              sku: '',
              itemType: ProductType.finishedGood,
              type: ProductTypeEnum.finished,
              category: '',
              stock: 0,
              baseUnit: 'Pcs',
              conversionFactor: 1,
              price: 0,
              status: 'active',
              unitWeightGrams: 0,
              createdAt: DateTime.now().toIso8601String(),
            ),
          );

          freeItems.add(
            SaleItem(
              productId: scheme.getProductId,
              name: freeProduct.name,
              quantity: freeQuantity,
              price: 0,
              isFree: true,
              baseUnit: freeProduct.baseUnit,
              schemeName: scheme.name,
            ),
          );
        }
      }
    }
    setState(() {
      _cartItems.addAll(freeItems);
    });
  }

  double get _grossSubtotal {
    double total = 0;
    for (final item in _cartItems) {
      if (item.isFree) continue;
      total += item.price * item.quantity;
    }
    return total;
  }

  double get _itemLevelDiscounts {
    double total = 0;
    for (final item in _cartItems) {
      if (item.isFree) continue;
      final itemSubtotal = item.price * item.quantity;
      final itemDiscount = itemSubtotal * (item.discount / 100);
      total += itemDiscount;
    }
    return total;
  }

  double get _subtotal => _grossSubtotal - _itemLevelDiscounts;

  double get _grandTotal {
    if (_discountType == '%') {
      return _subtotal * (1 - (_additionalDiscountPercent / 100));
    } else {
      return _subtotal - _additionalDiscountAmount;
    }
  }

  Future<void> _handleCreateDispatch() async {
    if (_selectedRoute == null ||
        _selectedSalesman == null ||
        _selectedVehicle == null ||
        _cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and add items'),
        ),
      );
      return;
    }
    if (_cartItems.any((item) => item.quantity <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dispatch quantity har item ke liye 0 se zyada honi chahiye',
          ),
        ),
      );
      return;
    }

    final requiredByProduct = <String, int>{};
    final nameByProduct = <String, String>{};
    for (final item in _cartItems) {
      if (item.isFree) continue; // Free/scheme items skip stock validation
      requiredByProduct[item.productId] =
          (requiredByProduct[item.productId] ?? 0) + item.quantity;
      nameByProduct[item.productId] = item.name;
    }
    final availableByProduct = <String, int>{
      for (final product in _allProducts) product.id: product.stock.floor(),
    };

    final shortages = <String>[];
    requiredByProduct.forEach((productId, requiredQty) {
      final availableQty = availableByProduct[productId] ?? 0;
      if (requiredQty > availableQty) {
        final label = nameByProduct[productId] ?? productId;
        shortages.add('$label: req $requiredQty, avail $availableQty');
      }
    });

    if (shortages.isNotEmpty) {
      final preview = shortages.take(3).join('\n');
      final suffix = shortages.length > 3 ? '\n...' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient main stock:\n$preview$suffix'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildConfirmationDialog(ctx),
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      AppLogger.info('Starting dispatch process', tag: 'Dispatch');

      final auth = context.read<AuthProvider>().state;
      final routeOrderPayload = _routeOrderPayload;
      final isRouteOrderDispatch = routeOrderPayload != null;
      final salesRoute =
          _selectedSalesman!.assignedSalesRoute ??
          ((_selectedSalesman!.assignedRoutes != null &&
                  _selectedSalesman!.assignedRoutes!.isNotEmpty)
              ? _selectedSalesman!.assignedRoutes!.first
              : '');

      AppLogger.info('Calling inventory service dispatch', tag: 'Dispatch');

      // Add timeout to prevent UI hanging
      final dispatchIdString = await _inventoryService
          .dispatchToSalesman(
            salesman: _selectedSalesman!,
            vehicleId: _selectedVehicle!.id,
            vehicleNumber: _selectedVehicle!.number,
            dispatchRoute: _selectedRoute!,
            salesRoute: salesRoute,
            items: _cartItems,
            subtotal: _subtotal,
            totalAmount: _grandTotal,
            userId: auth.user!.id,
            userName: auth.user!.name,
            additionalDiscount: _discountType == '%'
                ? (_subtotal * (_additionalDiscountPercent / 100))
                : _additionalDiscountAmount,
            isOrderBasedDispatch: isRouteOrderDispatch,
            sourceOrderId: routeOrderPayload?.routeOrderId,
            sourceOrderNo: routeOrderPayload?.routeOrderNo,
            sourceDealerId: routeOrderPayload?.dealerId,
            sourceDealerName: routeOrderPayload?.dealerName,
            dispatchSource: isRouteOrderDispatch ? 'order' : 'direct',
          )
          .timeout(const Duration(seconds: 45));

      AppLogger.success('Dispatch created: $dispatchIdString', tag: 'Dispatch');

      if (isRouteOrderDispatch) {
        try {
          await _routeOrderService.markOrderDispatched(
            orderId: routeOrderPayload.routeOrderId,
            dispatchId: dispatchIdString,
            dispatchedById: auth.user!.id,
            dispatchedByName: auth.user!.name,
          );
        } catch (markError) {
          AppLogger.warning(
            'Dispatch created but route order update failed: $markError',
            tag: 'Dispatch',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Dispatch done, but route order status update failed: $markError',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }

      if (!mounted) {
        return;
      }

      _showSuccessDialog(dispatchIdString);

      setState(() {
        _cartItems = [];
        _selectedRoute = null;
        _selectedSalesman = null;
        _selectedVehicle = null;
        _additionalDiscountAmount = 0;
        _additionalDiscountPercent = 0;
        _discountType = '%';
        _routeOrderPayload = null;
        _routeOrderPrefillApplied = true;
        _isProcessing = false;
      });
      final controllers = _qtyControllers.values.toList();
      _qtyControllers.clear();
      _disposeControllersLater(controllers);
      await _loadDispatchStats();
    } catch (e) {
      AppLogger.error('Dispatch failed: $e', tag: 'Dispatch');
      if (!mounted) {
        return;
      }
      setState(() => _isProcessing = false);

      String errorMessage = 'Error: ${e.toString()}';
      if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'Dispatch operation timed out. Please check your connection and try again.';
      } else if (e.toString().contains('Insufficient stock')) {
        errorMessage =
            'Insufficient stock for one or more items. Please refresh and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _normalizeRouteKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeRouteKeyOrNull(String? value) {
    if (value == null) return null;
    final normalized = _normalizeRouteKey(value);
    return normalized.isEmpty ? null : normalized;
  }

  AppUser? _findSalesmanForRoute(String? route, List<AppUser> salesmen) {
    final normalizedRoute = _normalizeRouteKeyOrNull(route);
    if (normalizedRoute == null) {
      return null;
    }

    final routeTokens = <String>{normalizedRoute};
    final routeId = _routeIdByName[normalizedRoute];
    final normalizedRouteId = _normalizeRouteKeyOrNull(routeId);
    if (normalizedRouteId != null) {
      routeTokens.add(normalizedRouteId);
    }

    for (final salesman in salesmen) {
      final deliveryRoute = _normalizeRouteKeyOrNull(
        salesman.assignedDeliveryRoute,
      );
      if (deliveryRoute != null && routeTokens.contains(deliveryRoute)) {
        return salesman;
      }

      final salesRoute = _normalizeRouteKeyOrNull(salesman.assignedSalesRoute);
      if (salesRoute != null && routeTokens.contains(salesRoute)) {
        return salesman;
      }

      final assignedRoutes = salesman.assignedRoutes;
      if (assignedRoutes != null) {
        for (final assigned in assignedRoutes) {
          final normalizedAssigned = _normalizeRouteKeyOrNull(assigned);
          if (normalizedAssigned != null &&
              routeTokens.contains(normalizedAssigned)) {
            return salesman;
          }
        }
      }
    }
    return null;
  }

  void _onSalesmanChanged(AppUser? salesman) {
    setState(() {
      _selectedSalesman = salesman;
      _selectedRoute = null; // Clear route when salesman changes
    });
  }

  List<String> _getRoutesForSalesman(AppUser? salesman) {
    if (salesman == null) return [];
    
    final routes = <String>{};
    
    if (salesman.assignedRoutes != null && salesman.assignedRoutes!.isNotEmpty) {
      routes.addAll(salesman.assignedRoutes!);
    }
    if (salesman.assignedDeliveryRoute != null && salesman.assignedDeliveryRoute!.isNotEmpty) {
      routes.add(salesman.assignedDeliveryRoute!);
    }
    if (salesman.assignedSalesRoute != null && salesman.assignedSalesRoute!.isNotEmpty) {
      routes.add(salesman.assignedSalesRoute!);
    }
    
    return routes.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Route observer not needed for basic keep alive
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispatch',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage & Track Shipments',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (Responsive.isMobile(context))
                  IconButton(
                    onPressed: () =>
                        context.push('/dashboard/dispatch/history'),
                    icon: const Icon(Icons.history_rounded),
                    tooltip: 'History',
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/dashboard/dispatch/history'),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMasterData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsHeader(),
                    const SizedBox(height: 24),
                    _buildSelectionForm(),
                    const SizedBox(height: 24),
                    _buildProductEntry(),
                    const SizedBox(height: 24),
                    _buildCartTable(),
                    const SizedBox(height: 24),
                    _buildSummaryAndActions(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final theme = Theme.of(context);
    final cards = [
      _buildStatCard(
        'Today Dispatches',
        _todayDispatchCount.toString(),
        Icons.local_shipping,
        theme.colorScheme.primary,
      ),
      _buildStatCard(
        'Items Count',
        _todayItemsCount.toString(),
        Icons.inventory,
        theme.colorScheme.tertiary,
      ),
      _buildStatCard(
        'Vehicles Active',
        _allVehicles.length.toString(),
        Icons.directions_car,
        AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        final isMobile = constraints.maxWidth < 600;
        if (!isMobile) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          );
        }

        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        final compact = constraints.maxWidth < 190;
        return UnifiedCard(
          padding: EdgeInsets.all(compact ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 8 : 10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: compact ? 18 : 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style:
                          (compact
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.headlineSmall)
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 16),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionForm() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dispatch Configuration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final fields = [
                _buildDropdownField<AppUser>(
                  'Salesman Name',
                  _selectedSalesman,
                  _allSalesmen
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.name)),
                      )
                      .toList(),
                  _onSalesmanChanged,
                  hint: 'Select Salesman',
                  icon: Icons.person_outline,
                ),
                _buildDropdownField<String>(
                  'Dispatch Route',
                  _selectedRoute,
                  _getRoutesForSalesman(_selectedSalesman)
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r)),
                      )
                      .toList(),
                  (val) => setState(() => _selectedRoute = val),
                  hint: 'Select Route',
                  icon: Icons.route_outlined,
                ),
                _buildDropdownField<Vehicle>(
                  'Vehicle Number',
                  _selectedVehicle,
                  _allVehicles
                      .map(
                        (v) =>
                            DropdownMenuItem(value: v, child: Text(v.number)),
                      )
                      .toList(),
                  (val) => setState(() => _selectedVehicle = val),
                  hint: 'Select Vehicle',
                  icon: Icons.directions_car_outlined,
                ),
              ];

              if (isMobile) {
                return Column(
                  children: fields.asMap().entries.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: e.key == fields.length - 1 ? 0 : 20,
                      ),
                      child: e.value,
                    );
                  }).toList(),
                );
              }
              return Row(
                children: fields.asMap().entries.map((e) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: e.key == fields.length - 1 ? 0 : 16,
                      ),
                      child: e.value,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged, {
    String? hint,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final entries = items
        .where((item) => item.value != null)
        .map(
          (item) => DropdownMenuEntry<T>(
            value: item.value as T,
            label: _dropdownItemLabel(item.child),
          ),
        )
        .toList();
    final isEnabled = entries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
              return const SizedBox.shrink();
            }

            return UnifiedCard(
              padding: EdgeInsets.zero,
              child: DropdownMenu<T>(
                key: ValueKey('${label}_${value}_${entries.length}'),
                enabled: isEnabled,
                width: constraints.maxWidth,
                initialSelection: value,
                hintText: hint ?? 'Select $label',
                enableFilter: true,
                requestFocusOnTap: true,
                menuHeight: 320,
                leadingIcon: icon == null
                    ? Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      )
                    : Icon(
                        icon,
                        size: 18,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.85,
                        ),
                      ),
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                onSelected: onChanged,
                dropdownMenuEntries: entries,
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                menuStyle: MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surface,
                  ),
                  elevation: const WidgetStatePropertyAll(14),
                  surfaceTintColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _dropdownItemLabel(Widget child) {
    if (child is Text) {
      return child.data ?? '';
    }
    if (child is RichText) {
      return child.text.toPlainText();
    }
    return child.toStringShort();
  }

  // LOCKED: Products already present in cart must not appear/select again.
  Iterable<Product> _availableProductsForSelection(Iterable<Product> source) {
    final cartProductIds = _cartItems
        .where((item) => !item.isFree)
        .map((item) => item.productId)
        .toSet();
    return source.where((product) => !cartProductIds.contains(product.id));
  }



  Widget _buildProductEntry() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Autocomplete<Product>(
              displayStringForOption: (option) => option.name,
              optionsBuilder: (textEditingValue) {
                final typeFiltered = _allProducts.where((p) {
                  if (_productFilterType == 'Finished') {
                    return p.type == ProductTypeEnum.finished ||
                        p.itemType.value == 'Finished Good';
                  } else {
                    return p.type == ProductTypeEnum.traded ||
                        p.itemType.value == 'Traded Good';
                  }
                });

                final availableProducts = _availableProductsForSelection(
                  typeFiltered,
                );

                if (textEditingValue.text == '') {
                  return availableProducts;
                }

                return availableProducts.where(
                  (p) =>
                      p.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ) ||
                      p.sku.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                );
              },
              onSelected: (product) {
                _addProduct(product);
                _internalProductSearchController?.clear();
                FocusScope.of(context).unfocus();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _internalProductSearchController = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search product name or SKU...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  controller.clear();
                                  focusNode.requestFocus();
                                },
                              )
                            : Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.3),
                              ),
                      ),
                      onTap: () {
                        if (controller.text.isEmpty) {
                          controller.text = '';
                        }
                      },
                      onSubmitted: (value) {
                        onFieldSubmitted();
                        controller.clear();
                      },
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      elevation: 20,
                      shadowColor: theme.shadowColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: Responsive.width(context) * 0.45,
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final Product option = options.elementAt(index);
                            final bool isSelected = index == 0;
                            final hasBox = UnitConverter.hasSecondaryUnit(
                              option.secondaryUnit,
                              option.conversionFactor,
                            );
                            final stockDisplay = hasBox
                                ? UnitConverter.formatDual(
                                    baseQty: option.stock,
                                    baseUnit: option.baseUnit,
                                    secondaryUnit: option.secondaryUnit,
                                    conversionFactor: option.conversionFactor,
                                  )
                                : '${option.stock.toStringAsFixed(0)} ${option.baseUnit}';
                            return ListTile(
                              tileColor: isSelected
                                  ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.2)
                                  : null,
                              hoverColor: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.1),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  option.type == ProductTypeEnum.finished
                                      ? Icons.inventory_2_outlined
                                      : Icons.shopping_basket_outlined,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                option.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    'SKU: ${option.sku}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 1,
                                    height: 10,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    size: 11,
                                    color: option.stock > 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    stockDisplay,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: option.stock > 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterChip('Finished', 'Finished'),
          const SizedBox(width: 8),
          _buildFilterChip('Traded', 'Traded'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _productFilterType == value;
    return ThemedFilterChip(
      label: label,
      selected: isSelected,
      onSelected: () => setState(() => _productFilterType = value),
    );
  }

  Widget _buildCartTable() {
    final theme = Theme.of(context);
    if (_cartItems.isEmpty) {
      return UnifiedCard(
        padding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 220),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your dispatch cart is empty',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search and add products above to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return UnifiedCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text('PRODUCT NAME', style: _headerStyle(theme)),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('QUANTITY', style: _headerStyle(theme)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('RATE', style: _headerStyle(theme)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('TOTAL', style: _headerStyle(theme)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('ACTION', style: _headerStyle(theme)),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable List of Items
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 24,
              endIndent: 24,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              final amount = item.price * item.quantity;
              final hasBox = UnitConverter.hasSecondaryUnit(
                item.secondaryUnit,
                item.conversionFactor ?? 1.0,
              );

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // Product Info
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (item.isFree) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.schemeName ?? 'FREE SCHEME ITEM',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                          if (hasBox)
                            Text(
                              '1 ${item.secondaryUnit} = ${item.conversionFactor?.toInt()} ${item.baseUnit}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: item.isFree
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildQuantityInput(item, index),
                                  if (hasBox && item.quantity > 0)
                                    _buildBoxPcsBreakdown(
                                      theme: theme,
                                      baseQty: item.quantity.toDouble(),
                                      baseUnit: item.baseUnit,
                                      secondaryUnit: item.secondaryUnit!,
                                      conversionFactor:
                                          item.conversionFactor ?? 1,
                                    ),
                                ],
                              ),
                      ),
                    ),
                    // Rate
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: item.isFree
                            ? const Text('-')
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹${item.price.toStringAsFixed(0)}/${item.baseUnit}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (hasBox && item.secondaryPrice != null)
                                    Text(
                                      '₹${item.secondaryPrice!.toStringAsFixed(0)}/${item.secondaryUnit}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                    // Amount
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          item.isFree ? '₹0' : '₹${amount.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    // Delete Button
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _cartItems.removeAt(index);
                              final removed = _qtyControllers.remove(
                                item.productId,
                              );
                              if (removed != null) {
                                _disposeControllersLater([removed]);
                              }
                              if (!item.isFree) _recalculateSchemes();
                            });
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.5,
                            ),
                            size: 20,
                          ),
                          hoverColor: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.2),
                          tooltip: 'Remove Item',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(ThemeData theme) {
    return theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );
  }

  /// Shows "= 2 Box + 3 Pcs" breakdown below quantity input for multi-unit products.
  Widget _buildBoxPcsBreakdown({
    required ThemeData theme,
    required double baseQty,
    required String baseUnit,
    required String secondaryUnit,
    required double conversionFactor,
  }) {
    final boxes = UnitConverter.fullSecondaryUnits(baseQty, conversionFactor);
    final loose = UnitConverter.remainingBaseUnitsExact(
      baseQty,
      conversionFactor,
    );
    final looseDisplay = (loose - loose.roundToDouble()).abs() < 0.001
        ? loose.round().toString()
        : loose.toStringAsFixed(1);
    final label = boxes > 0 && loose > 0.001
        ? '$boxes $secondaryUnit + $looseDisplay $baseUnit'
        : boxes > 0
        ? '$boxes $secondaryUnit'
        : '$looseDisplay $baseUnit';
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '= $label',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary.withValues(alpha: 0.75),
          fontWeight: FontWeight.w700,
          fontSize: 9,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _disposeControllersLater(Iterable<TextEditingController> controllers) {
    if (controllers.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        for (final controller in controllers) {
          controller.dispose();
        }
      }
    });
  }

  Widget _buildQuantityInput(SaleItem item, int index) {
    final theme = Theme.of(context);
    final controller = _qtyControllers.putIfAbsent(
      item.productId,
      () => TextEditingController(
        text: item.quantity == 0 ? '0' : item.quantity.toString(),
      ),
    );
    final targetText = item.quantity == 0 ? '0' : item.quantity.toString();
    if (controller.text != targetText && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.text != targetText) {
          controller.value = controller.value.copyWith(
            text: targetText,
            selection: TextSelection.collapsed(offset: targetText.length),
          );
        }
      });
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 104),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: [
            NormalizedNumberInputFormatter.integer(keepZeroWhenEmpty: true),
          ],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: theme.colorScheme.primary,
          maxLines: 1,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
                width: 1.4,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            hintText: '0',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          onChanged: (val) {
            final qty = int.tryParse(val) ?? 0;
            setState(() {
              _cartItems[index] = SaleItem(
                productId: item.productId,
                name: item.name,
                quantity: qty,
                price: item.price,
                discount: item.discount,
                baseUnit: item.baseUnit,
                secondaryUnit: item.secondaryUnit,
                conversionFactor: item.conversionFactor,
                secondaryPrice: item.secondaryPrice,
              );
              _recalculateSchemes();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSummaryAndActions() {
    return UnifiedCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 700;
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildNotesSection()),
                const SizedBox(width: 48),
                Expanded(flex: 1, child: _buildSummarySection()),
              ],
            );
          }
          return Column(
            children: [
              _buildSummarySection(),
              const SizedBox(height: 32),
              _buildNotesSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotesSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notes_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              'Additional Notes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 4,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText:
                'Enter any specific instructions or notes for this dispatch...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow.withValues(
              alpha: 0.5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildSummaryRow(
          'SUBTOTAL (GROSS)',
          '₹${_grossSubtotal.toStringAsFixed(2)}',
        ),
        if (_itemLevelDiscounts > 0) ...[
          const SizedBox(height: 12),
          _buildSummaryRow(
            'PRODUCT DISCOUNT',
            '-₹${_itemLevelDiscounts.toStringAsFixed(2)}',
            valueColor: AppColors.success,
          ),
        ],
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1),
        ),
        _buildSummaryRow(
          'GRAND TOTAL',
          '₹${_grandTotal.toStringAsFixed(2)}',
          isBold: true,
          fontSize: 18,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _handleCreateDispatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 8,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isProcessing
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onPrimary,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'CREATE DISPATCH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: isBold ? fontSize - 4 : fontSize,
            color: isBold
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
            color:
                valueColor ??
                (isBold
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.state.user;
    final now = DateTime.now();
    final dialogConstraints = Responsive.dialogConstraints(
      context,
      maxWidth: 700,
      maxHeightFactor: 0.9,
    );
    final dialogWidth = dialogConstraints.maxWidth.clamp(320.0, 700.0);
    final contentMaxHeight = (dialogConstraints.maxHeight - 180).clamp(
      240.0,
      900.0,
    );

    // Flex weights for the table columns (no fixed widths → no overflow)
    const int serialFlex = 1;
    const int productFlex = 5;
    const int qtyFlex = 2;
    const int rateFlex = 2;
    const int amountFlex = 2;

    final dateText =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      insetPadding: Responsive.dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispatch Challan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Date: $dateText  |  Time: $timeText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: contentMaxHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Datt Soap Factory',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '123 Railway Station MIDC Chatrapati Sambhaji Nagar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Salesman: ${_selectedSalesman!.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Vehicle: ${_selectedVehicle!.number}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Dispatched By: ${currentUser?.name ?? "Datt Soap"}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Flexible table — Expanded columns, no fixed widths, no overflow
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: serialFlex,
                              child: const Text(
                                '#',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: productFlex,
                              child: const Text(
                                'Product',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: qtyFlex,
                              child: const Text(
                                'Qty',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: rateFlex,
                              child: const Text(
                                'Rate',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: amountFlex,
                              child: const Text(
                                'Amount',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Data rows
                      ..._cartItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final amount = item.price * item.quantity;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: serialFlex,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              Expanded(
                                flex: productFlex,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.isFree)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withValues(alpha: 0.16),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.schemeName ?? 'Free',
                                            style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: qtyFlex,
                                child: Text(
                                  '${item.quantity} u',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        item.isFree ? AppColors.success : null,
                                    fontWeight: item.isFree
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: rateFlex,
                                child: Text(
                                  item.isFree
                                      ? '-'
                                      : '₹${item.price.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              Expanded(
                                flex: amountFlex,
                                child: Text(
                                  item.isFree
                                      ? '₹0.00'
                                      : '₹${amount.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 280,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryDialogRow(
                          'Subtotal (Gross):',
                          '\u20B9${_grossSubtotal.toStringAsFixed(2)}',
                        ),
                        if (_itemLevelDiscounts > 0)
                          _buildSummaryDialogRow(
                            'Product Discount:',
                            '-\u20B9${_itemLevelDiscounts.toStringAsFixed(2)}',
                            valueColor: AppColors.success,
                          ),
                        const Divider(height: 16),
                        _buildSummaryDialogRow(
                          'Total Amount:',
                          '\u20B9${_grandTotal.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          // Use the dialog's own context (ctx), not the parent widget context
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10b981),
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text(
            'Confirm & Dispatch',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDialogRow(
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
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String dispatchId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResponsiveAlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: theme.colorScheme.primary,
          size: 64,
        ),
        title: const Text('Dispatch Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dispatch ID: $dispatchId',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'The stock has been moved from main inventory to salesman allocated stock.',
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
