import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/customers_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../services/products_service.dart';
import '../../services/sales_service.dart';
import '../../services/inventory_service.dart';
import '../../services/schemes_service.dart';
import '../../models/types/product_types.dart'; // Product model
import '../../models/types/user_types.dart';
import '../../models/types/sales_types.dart';
import '../../models/customer.dart';
import '../../domain/engines/sale_calculation_engine.dart';
import '../../utils/service_handler.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/dialogs/responsive_dialog.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import '../../services/whatsapp_invoice_pipeline_service.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/sales/new_sale/sale_header_widget.dart';
import '../../widgets/sales/new_sale/product_selector_widget.dart';
import '../../widgets/sales/new_sale/cart_list_widget.dart';
import '../../services/settings_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/warehouse_service.dart';
import '../../data/local/entities/inventory_location_entity.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/sales/new_sale/sale_totals_widget.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../utils/release_data_guard.dart';

class NewSaleScreen extends StatefulWidget {
  final Customer? preSelectedCustomer;

  const NewSaleScreen({super.key, this.preSelectedCustomer});

  @override
  // LOCKED: UI Fixes for Visibility and Search - 2026-02-02
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  late ProductsService _productsService;
  late SalesService _salesService;
  late SettingsService _settingsService;
  late InventoryService _inventoryService;
  late SchemesService _schemesService;
  late VehiclesService _vehiclesService;
  late WarehouseService _warehouseService;
  final SaleCalculationEngine _calculationEngine = SaleCalculationEngine();

  Customer? _selectedCustomer;
  CompanyProfileData? _companyProfile;
  List<Product> _allProducts = [];
  List<Customer> _allCustomers = []; // For offline search
  List<Scheme> _activeSchemes = []; // List of active schemes
  Map<String, StockUsageData> _salesmanStockMap =
      {}; // ProductId -> StockUsageData
  final List<CartItem> _cart = [];

  bool _isSaving = false;
  bool _isSubmittingConfirm = false;
  bool _isApplyingSchemesLock = false;
  bool _isSalesman = false;
  bool _isSalesmanSpecialDiscountEnabled = false;
  bool _allowSalesmanGstToggle = true;
  bool _allowSalesmanAdditionalDiscountToggle = true;
  bool _allowSalesmanSpecialDiscountToggle = true;
  double _salesmanSpecialDiscountPercentage = 5.0;
  double _salesmanCustomerSpecialDiscountSetting = 5.0;
  double _salesmanDealerSpecialDiscountSetting = 5.0;
  List<double> _salesmanSpecialDiscountOptions = const [1, 2, 3, 5];
  double _salesmanCustomerAdditionalDiscountSetting = 5.0;
  double _salesmanDealerAdditionalDiscountSetting = 5.0;
  List<double> _salesmanAdditionalDiscountOptions = const [5, 8, 13];
  final Map<String, double> _defaultDiscountByProductId = {};

  // Route management for salesmen
  String? _selectedRoute;
  List<String> _availableRoutes = [];
  List<Customer> _filteredCustomers = [];
  final Map<String, String> _routeIdByName = {};
  final Map<String, String> _routeNameById = {};
  List<Map<String, dynamic>> _routeReferences = const [];

  // Warehouse management
  List<InventoryLocationEntity> _warehouses = [];
  String? _selectedWarehouseId;

  // Financials
  final double _discountPercentage = 0;
  double _additionalDiscountPercentage = 0;
  String _gstType = 'None';
  double _gstPercentage = 0;

  bool _showBreakdown = true;
  int _currentStep = 0; // Stepper state
  final ScrollController _stepperScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _productsService = context.read<ProductsService>();
    _salesService = context.read<SalesService>();
    _settingsService = context.read<SettingsService>();
    _inventoryService = context.read<InventoryService>();
    _schemesService = context.read<SchemesService>();
    _vehiclesService = context.read<VehiclesService>();
    _warehouseService = context.read<WarehouseService>();

    if (widget.preSelectedCustomer != null) {
      _selectedCustomer = widget.preSelectedCustomer;
    }

    // Detect Role
    final authProvider = context.read<AuthProvider>();
    _isSalesman = authProvider.state.user?.role == UserRole.salesman;

    _loadProducts();
    _loadSchemes();
    _loadCompanyProfile();
    _loadWarehouses();
    _loadSalesDiscountControls();

    // Serialize route/customer loading to ensure robust route-token filtering.
    _loadSalesContext();
  }

  @override
  void dispose() {
    _stepperScrollController.dispose();
    super.dispose();
  }

  void _scrollStepperToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_stepperScrollController.hasClients) return;
      _stepperScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
      Future<void>.delayed(const Duration(milliseconds: 280), () {
        if (!_stepperScrollController.hasClients) return;
        _stepperScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  Future<void> _loadSalesContext() async {
    await _loadRouteReferenceMaps();
    await _loadCustomers();
    await _loadAvailableRoutes();
  }

  String _normalizeRouteToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeRouteTokenOrNull(String? value) {
    if (value == null) return null;
    final normalized = _normalizeRouteToken(value);
    return normalized.isEmpty ? null : normalized;
  }

  Future<void> _loadRouteReferenceMaps() async {
    try {
      final routeData = await _vehiclesService.getRoutes(refreshRemote: true);
      final routeIdByName = <String, String>{};
      final routeNameById = <String, String>{};
      final routeReferences = <Map<String, dynamic>>[];
      for (final route in routeData) {
        final routeName = (route['name'] ?? route['routeName'] ?? '')
            .toString()
            .trim();
        final routeId = (route['id'] ?? route['routeId'] ?? '')
            .toString()
            .trim();
        final normalizedName = _normalizeRouteTokenOrNull(routeName);
        final normalizedId = _normalizeRouteTokenOrNull(routeId);
        if (normalizedName == null || normalizedName.isEmpty) continue;
        if (normalizedId != null && normalizedId.isNotEmpty) {
          routeIdByName[normalizedName] = routeId;
          routeNameById[normalizedId] = routeName;
        }
        routeReferences.add({...route, 'id': routeId, 'name': routeName});
      }
      if (!mounted) return;
      setState(() {
        _routeIdByName
          ..clear()
          ..addAll(routeIdByName);
        _routeNameById
          ..clear()
          ..addAll(routeNameById);
        _routeReferences = routeReferences;
      });
    } catch (e) {
      debugPrint('Error loading route references: $e');
    }
  }

  Set<String> _selectedRouteTokens(String? routeName) {
    final tokens = <String>{};
    final normalizedName = _normalizeRouteTokenOrNull(routeName);
    if (normalizedName == null) return tokens;
    tokens.add(normalizedName);

    final linkedName = _routeNameById[normalizedName];
    final normalizedLinkedName = _normalizeRouteTokenOrNull(linkedName);
    if (normalizedLinkedName != null) {
      tokens.add(normalizedLinkedName);
    }

    final linkedId = _routeIdByName[normalizedName];
    final normalizedLinkedId = _normalizeRouteTokenOrNull(linkedId);
    if (normalizedLinkedId != null) {
      tokens.add(normalizedLinkedId);
    }
    return tokens;
  }

  bool _isRouteAssignedToSalesman(Map<String, dynamic> route, AppUser user) {
    final userTokens = <String>{
      _normalizeRouteTokenOrNull(user.id) ?? '',
      _normalizeRouteTokenOrNull(user.name) ?? '',
      _normalizeRouteTokenOrNull(user.email) ?? '',
    }..removeWhere((value) => value.isEmpty);
    if (userTokens.isEmpty) return false;

    final routeTokens = <String>{
      _normalizeRouteTokenOrNull((route['salesmanId'] ?? '').toString()) ?? '',
      _normalizeRouteTokenOrNull((route['salesmanName'] ?? '').toString()) ??
          '',
    }..removeWhere((value) => value.isEmpty);
    if (routeTokens.isEmpty) return false;

    return routeTokens.any(userTokens.contains);
  }

  Set<String> _resolveSalesmanRouteTokens(AppUser user) {
    // [LOCKED] Merge user assigned route fields with master route assignments.
    final tokens = <String>{};

    void addRouteToken(String? routeValue) {
      final normalized = _normalizeRouteTokenOrNull(routeValue);
      if (normalized == null || normalized.isEmpty) return;
      tokens.add(normalized);
      final linkedId = _routeIdByName[normalized];
      final normalizedLinkedId = _normalizeRouteTokenOrNull(linkedId);
      if (normalizedLinkedId != null && normalizedLinkedId.isNotEmpty) {
        tokens.add(normalizedLinkedId);
      }
      final linkedName = _routeNameById[normalized];
      final normalizedLinkedName = _normalizeRouteTokenOrNull(linkedName);
      if (normalizedLinkedName != null && normalizedLinkedName.isNotEmpty) {
        tokens.add(normalizedLinkedName);
      }
    }

    if (user.assignedRoutes != null) {
      for (final route in user.assignedRoutes!) {
        addRouteToken(route);
      }
    }
    addRouteToken(user.assignedSalesRoute);
    addRouteToken(user.assignedDeliveryRoute);

    for (final route in _routeReferences) {
      if (!_isRouteAssignedToSalesman(route, user)) continue;
      addRouteToken((route['name'] ?? '').toString());
      addRouteToken((route['id'] ?? '').toString());
    }
    return tokens;
  }

  bool _customerMatchesRouteTokens(Customer customer, Set<String> routeTokens) {
    if (routeTokens.isEmpty) return true;
    final customerTokens = <String>{};

    void addCustomerToken(String? routeValue) {
      final normalized = _normalizeRouteTokenOrNull(routeValue);
      if (normalized == null) return;
      customerTokens.add(normalized);
      final linkedId = _routeIdByName[normalized];
      final normalizedLinkedId = _normalizeRouteTokenOrNull(linkedId);
      if (normalizedLinkedId != null) {
        customerTokens.add(normalizedLinkedId);
      }
      final linkedName = _routeNameById[normalized];
      final normalizedLinkedName = _normalizeRouteTokenOrNull(linkedName);
      if (normalizedLinkedName != null) {
        customerTokens.add(normalizedLinkedName);
      }
    }

    addCustomerToken(customer.route);
    addCustomerToken(customer.salesRoute);
    return customerTokens.any(routeTokens.contains);
  }

  bool _isReleaseBlockedProduct(Product product) {
    return shouldHideInRelease(
      name: product.name,
      secondaryName: product.category,
      id: product.id,
      sku: product.sku,
      extra: <String?>[product.itemType.value, product.status],
    );
  }

  bool _isReleaseBlockedCustomer(Customer customer) {
    return shouldHideInRelease(
      name: customer.shopName,
      secondaryName: customer.ownerName,
      id: customer.id,
      email: customer.email,
      extra: <String?>[
        customer.mobile,
        customer.alternateMobile,
        customer.route,
        customer.salesRoute,
      ],
    );
  }

  Future<void> _loadCustomers() async {
    try {
      final customerRepo = context.read<CustomerRepository>();
      final user = context.read<AuthProvider>().state.user;
      final isSalesman = user?.role == UserRole.salesman;
      final entities = await customerRepo.getAllCustomers();
      var customers = entities
          .map((e) => e.toDomain())
          .where((c) => !_isReleaseBlockedCustomer(c))
          .toList();
      if (isSalesman && user != null) {
        final allowedRouteTokens = _resolveSalesmanRouteTokens(user);
        customers = customers
            .where((c) => _customerMatchesRouteTokens(c, allowedRouteTokens))
            .toList();
      }
      if (mounted) {
        setState(() {
          _allCustomers = customers;
          final selectedCustomerId = _selectedCustomer?.id;
          if (selectedCustomerId != null &&
              !_allCustomers.any((c) => c.id == selectedCustomerId)) {
            _selectedCustomer = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
  }

  Future<void> _loadWarehouses() async {
    if (_isSalesman) return;
    try {
      final result = await _warehouseService.getWarehouseOptions();
      if (mounted) {
        setState(() {
          _warehouses =
              result.warehouses
                  .map(
                    (w) => InventoryLocationEntity()
                      ..id = w.id
                      ..name = w.name
                      ..type = 'warehouse'
                      ..updatedAt = DateTime.now(),
                  )
                  .toList();
          if (_warehouses.isNotEmpty) {
            _selectedWarehouseId = _warehouses.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading warehouses: $e');
    }
  }

  Future<void> _loadCompanyProfile() async {
    try {
      final profile = await _settingsService.getCompanyProfileClient();
      if (mounted) {
        setState(() => _companyProfile = profile);
      }
    } catch (e) {
      debugPrint('Error loading company profile: $e');
      if (mounted) {
        setState(() => _companyProfile = CompanyProfileData(name: 'Company'));
      }
    }
  }

  Future<void> _loadAvailableRoutes() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.state.user;
      if (user != null && user.role == UserRole.salesman) {
        final assignedRoutes = _resolveSalesmanRoutes(user);
        if (mounted) {
          setState(() {
            _availableRoutes = assignedRoutes;
            if (_availableRoutes.length == 1) {
              _selectedRoute = _availableRoutes.first;
              _filterCustomersByRoute();
            } else if (_selectedRoute != null &&
                !_availableRoutes.contains(_selectedRoute)) {
              _selectedRoute = null;
              _filteredCustomers = [];
            }
          });
        }
        return;
      }

      final allRoutes = _allCustomers
          .map((c) => c.route.trim())
          .where((r) => r.isNotEmpty)
          .map((route) {
            final normalized = _normalizeRouteTokenOrNull(route);
            if (normalized == null) return route;
            return _routeNameById[normalized] ?? route;
          })
          .cast<String>()
          .toSet()
          .toList();

      if (mounted) {
        setState(() {
          _availableRoutes = allRoutes.cast<String>();
        });
      }
    } catch (e) {
      debugPrint('Error loading salesman routes: $e');
    }
  }

  List<String> _resolveSalesmanRoutes(AppUser user) {
    final routeSet = <String>{};

    void addRoute(String? route) {
      final normalized = _normalizeRouteTokenOrNull(route);
      if (normalized == null) return;
      final routeName = _routeNameById[normalized];
      if (routeName != null && routeName.trim().isNotEmpty) {
        routeSet.add(routeName.trim());
      } else {
        routeSet.add(route!.trim());
      }
    }

    if (user.assignedRoutes != null) {
      for (final route in user.assignedRoutes!) {
        addRoute(route);
      }
    }

    addRoute(user.assignedSalesRoute);
    addRoute(user.assignedDeliveryRoute);

    for (final route in _routeReferences) {
      if (!_isRouteAssignedToSalesman(route, user)) continue;
      addRoute((route['name'] ?? '').toString());
      addRoute((route['id'] ?? '').toString());
    }

    final routes = routeSet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return routes;
  }

  void _filterCustomersByRoute() {
    if (_selectedRoute == null) {
      setState(() => _filteredCustomers = []);
      return;
    }

    final selectedTokens = _selectedRouteTokens(_selectedRoute);
    setState(() {
      _filteredCustomers = _allCustomers
          .where((c) => _customerMatchesRouteTokens(c, selectedTokens))
          .toList();
    });
  }

  Future<void> _loadSalesDiscountControls() async {
    try {
      final settings = await _settingsService.getGeneralSettings(
        forceRefresh: true,
      );
      if (!mounted || settings == null) return;

      final customerSpecial = _clampDiscount(
        settings.salesmanCustomerSpecialDiscount ?? 5.0,
      );
      final dealerSpecial = _clampDiscount(
        settings.salesmanDealerSpecialDiscount ?? 5.0,
      );
      final specialOptions = _sanitizeSpecialDiscountOptions(
        settings.salesmanSpecialDiscountOptions,
        ensureValues: [customerSpecial, dealerSpecial],
      );
      final customerAdditional = _clampDiscount(
        settings.salesmanCustomerAdditionalDiscount ?? 5.0,
      );
      final dealerAdditional = _clampDiscount(
        settings.salesmanDealerAdditionalDiscount ?? 5.0,
      );
      final additionalOptions = _sanitizeAdditionalDiscountOptions(
        settings.salesmanAdditionalDiscountOptions,
        ensureValues: [customerAdditional, dealerAdditional],
      );

      setState(() {
        _salesmanCustomerSpecialDiscountSetting = customerSpecial;
        _salesmanDealerSpecialDiscountSetting = dealerSpecial;
        _salesmanSpecialDiscountOptions = specialOptions;
        _salesmanCustomerAdditionalDiscountSetting = customerAdditional;
        _salesmanDealerAdditionalDiscountSetting = dealerAdditional;
        _salesmanAdditionalDiscountOptions = additionalOptions;
        _allowSalesmanGstToggle = settings.allowSalesmanGstToggle ?? true;
        _allowSalesmanAdditionalDiscountToggle =
            settings.allowSalesmanAdditionalDiscountToggle ?? true;
        _allowSalesmanSpecialDiscountToggle =
            settings.allowSalesmanSpecialDiscountToggle ?? true;

        if (!_allowSalesmanGstToggle) {
          _gstType = 'None';
          _gstPercentage = 0.0;
        }
        if (!_allowSalesmanAdditionalDiscountToggle) {
          _additionalDiscountPercentage = 0.0;
        } else {
          final baselineAdditional =
              _resolveSalesmanAdditionalDefaultForCurrentSale();
          if (_additionalDiscountPercentage <= 0) {
            _additionalDiscountPercentage =
                _normalizeAdditionalDiscountSelection(baselineAdditional);
          } else {
            _additionalDiscountPercentage =
                _normalizeAdditionalDiscountSelection(
                  _additionalDiscountPercentage,
                );
          }
        }
        if (!_allowSalesmanSpecialDiscountToggle) {
          _isSalesmanSpecialDiscountEnabled = false;
        }

        final baselineSpecial = _resolveSalesmanSpecialDefaultForCurrentSale();
        if (_isSalesmanSpecialDiscountEnabled) {
          _salesmanSpecialDiscountPercentage =
              _normalizeSpecialDiscountSelection(
                _salesmanSpecialDiscountPercentage > 0
                    ? _salesmanSpecialDiscountPercentage
                    : baselineSpecial,
              );
        } else {
          _salesmanSpecialDiscountPercentage =
              _normalizeSpecialDiscountSelection(baselineSpecial);
        }
        _syncCartDiscountsWithSalesmanSpecialInPlace();
      });
    } catch (e) {
      debugPrint('Error loading sales discount controls: $e');
    }
  }

  double _clampDiscount(double value) {
    return value.clamp(0.0, 100.0).toDouble();
  }

  List<double> _sanitizeSpecialDiscountOptions(
    List<double>? rawValues, {
    List<double> ensureValues = const <double>[],
  }) {
    final options = <double>{};
    for (final value in rawValues ?? const <double>[]) {
      final normalized = _clampDiscount(value);
      if (normalized > 0) options.add(normalized);
    }
    for (final value in ensureValues) {
      final normalized = _clampDiscount(value);
      if (normalized > 0) options.add(normalized);
    }
    if (options.isEmpty) {
      options.addAll(<double>{1, 2, 3, 5});
    }
    final sorted = options.toList()..sort();
    return sorted;
  }

  List<double> _sanitizeAdditionalDiscountOptions(
    List<double>? rawValues, {
    List<double> ensureValues = const <double>[],
  }) {
    final options = <double>{};
    for (final value in rawValues ?? const <double>[]) {
      final normalized = _clampDiscount(value);
      if (normalized > 0) options.add(normalized);
    }
    for (final value in ensureValues) {
      final normalized = _clampDiscount(value);
      if (normalized > 0) options.add(normalized);
    }
    if (options.isEmpty) {
      options.addAll(<double>{5, 8, 13});
    }
    final sorted = options.toList()..sort();
    return sorted;
  }

  double _normalizeSpecialDiscountSelection(double value) {
    final safeOptions = _salesmanSpecialDiscountOptions.isEmpty
        ? const <double>[1, 2, 3, 5]
        : _salesmanSpecialDiscountOptions;
    final normalized = _clampDiscount(value);
    if (safeOptions.contains(normalized)) return normalized;
    return safeOptions.first;
  }

  double _normalizeAdditionalDiscountSelection(double value) {
    final safeOptions = _salesmanAdditionalDiscountOptions.isEmpty
        ? const <double>[5, 8, 13]
        : _salesmanAdditionalDiscountOptions;
    final normalized = _clampDiscount(value);
    if (normalized == 0) return 0;
    if (safeOptions.contains(normalized)) return normalized;
    return safeOptions.first;
  }

  String _formatDiscountPercent(double value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  double _resolveSalesmanSpecialDefaultForCurrentSale({
    String recipientType = 'customer',
  }) {
    return recipientType == 'dealer'
        ? _salesmanDealerSpecialDiscountSetting
        : _salesmanCustomerSpecialDiscountSetting;
  }

  double _resolveSalesmanAdditionalDefaultForCurrentSale({
    String recipientType = 'customer',
  }) {
    return recipientType == 'dealer'
        ? _salesmanDealerAdditionalDiscountSetting
        : _salesmanCustomerAdditionalDiscountSetting;
  }

  String get _lineDiscountLabel {
    if (!_isSalesman || !_isSalesmanSpecialDiscountEnabled) {
      return 'Product Discount';
    }
    return 'Product + SP Discount (${_formatDiscountPercent(_salesmanSpecialDiscountPercentage)}%)';
  }

  double _resolveBaseDefaultDiscount(
    String productId, {
    double fallback = 0.0,
  }) {
    final mapped = _defaultDiscountByProductId[productId];
    if (mapped != null) return _clampDiscount(mapped);
    return _clampDiscount(fallback);
  }

  double _resolveEffectiveCartDiscount(double baseDiscount) {
    if (!_isSalesman ||
        !_isSalesmanSpecialDiscountEnabled ||
        _salesmanSpecialDiscountPercentage <= 0) {
      return _clampDiscount(baseDiscount);
    }
    return _clampDiscount(baseDiscount + _salesmanSpecialDiscountPercentage);
  }

  void _syncCartDiscountsWithSalesmanSpecialInPlace() {
    for (var i = 0; i < _cart.length; i++) {
      final item = _cart[i];
      if (item.isFree) continue;
      final baseDiscount = _resolveBaseDefaultDiscount(
        item.productId,
        fallback: item.discount,
      );
      _cart[i] = item.copyWith(
        discount: _resolveEffectiveCartDiscount(baseDiscount),
      );
    }
  }

  Future<void> _loadProducts() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.state.user;
      final masterProducts = await _productsService.getProducts(
        status: 'active',
      );
      final visibleMasterProducts = masterProducts
          .where((p) => !_isReleaseBlockedProduct(p))
          .toList();
      final masterProductById = <String, Product>{
        for (final p in visibleMasterProducts) p.id: p,
      };

      if (_isSalesman && user != null) {
        final currentStock = await _inventoryService.getSalesmanCurrentStock(
          user.id,
        );
        final effectiveStock = currentStock.isNotEmpty
            ? currentStock
            : (user.allocatedStock ?? <String, AllocatedStockItem>{});

        if (effectiveStock.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No stock allocated. Please contact admin.'),
                duration: Duration(seconds: 4),
              ),
            );
            setState(() {
              _allProducts = [];
              _defaultDiscountByProductId.clear();
            });
          }
          return;
        }

        // Fetch allocated stock usage for salesman (local-first with fallback)
        final usageData = await _inventoryService.calculateStockUsage(
          user.id,
          effectiveStock,
        );

        if (mounted) {
          setState(() {
            _salesmanStockMap = {for (var e in usageData) e.productId: e};
            // For salesman, allProducts are only those allocated to them
            _allProducts = usageData
                .where((e) => e.remainingTotal > 0)
                .where((e) {
                  final master = masterProductById[e.productId];
                  return !shouldHideInRelease(
                    name: master?.name ?? e.productName,
                    secondaryName: master?.category ?? e.category,
                    id: e.productId,
                    sku: master?.sku,
                  );
                })
                .map((e) {
                  final master = masterProductById[e.productId];
                  final allocated = effectiveStock[e.productId];
                  final defaultDiscount =
                      allocated?.defaultDiscount ??
                      master?.defaultDiscount ??
                      0.0;
                  return Product(
                    id: e.productId,
                    name: master?.name ?? e.productName,
                    sku: master?.sku ?? '',
                    category: master?.category ?? e.category ?? '',
                    price: e.price,
                    secondaryPrice: e.secondaryPrice ?? master?.secondaryPrice,
                    baseUnit: e.baseUnit,
                    secondaryUnit: e.secondaryUnit ?? master?.secondaryUnit,
                    conversionFactor: e.conversionFactor,
                    stock: e.remainingTotal,
                    status: master?.status ?? 'active',
                    itemType: master?.itemType ?? ProductType.finishedGood,
                    type: master?.type ?? ProductTypeEnum.finished,
                    unitWeightGrams: master?.unitWeightGrams ?? 0,
                    createdAt:
                        master?.createdAt ?? DateTime.now().toIso8601String(),
                    defaultDiscount: defaultDiscount.clamp(0.0, 100.0),
                    gstRate: master?.gstRate,
                    simpleSchemeBuy: master?.simpleSchemeBuy,
                    simpleSchemeGet: master?.simpleSchemeGet,
                  );
                })
                .toList();
            _defaultDiscountByProductId
              ..clear()
              ..addEntries(
                _allProducts.map(
                  (p) =>
                      MapEntry(p.id, _clampDiscount(p.defaultDiscount ?? 0.0)),
                ),
              );
            _syncCartDiscountsWithSalesmanSpecialInPlace();
          });
        }
      } else {
        // Fetching all active products for other roles
        // Exclude Semi-Finished products - they are not sellable, only used in production
        if (mounted) {
          setState(() {
            _allProducts = visibleMasterProducts
                .where(
                  (p) =>
                      p.itemType != ProductType.semiFinishedGood &&
                      p.type != ProductTypeEnum.semi,
                )
                .toList();
            _defaultDiscountByProductId
              ..clear()
              ..addEntries(
                _allProducts.map(
                  (p) =>
                      MapEntry(p.id, _clampDiscount(p.defaultDiscount ?? 0.0)),
                ),
              );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  Future<void> _loadSchemes() async {
    try {
      final schemes = await _schemesService.getSchemes(status: 'active');
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          _activeSchemes = schemes.where((s) {
            final from = DateTime.tryParse(s.validFrom);
            final to = DateTime.tryParse(s.validTo);
            if (from == null || to == null) return false;
            return from.isBefore(now) && to.isAfter(now);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading schemes: $e');
    }
  }

  // --- Calculations ---

  SaleCalculationResult get _uiCalculation {
    final items = _cart
        .map((item) => item.toSaleItemForUI())
        .toList(growable: false);
    return _calculationEngine.calculateSale(
      items: items,
      discountPercentage: _discountPercentage,
      additionalDiscountPercentage: _additionalDiscountPercentage,
      gstPercentage: _gstPercentage,
      gstType: _gstType,
    );
  }

  double get _subtotal => _uiCalculation.subtotal;

  double get _lineItemDiscountsTotal => _uiCalculation.itemDiscountTotal;

  double get _discountAmount => _uiCalculation.discountAmount;

  double get _additionalDiscountAmount =>
      _uiCalculation.additionalDiscountAmount;

  double get _taxableAmount => _uiCalculation.taxableAmount;

  double get _totalGst => _uiCalculation.totalGstAmount;

  double get _grandTotal => _uiCalculation.totalAmount;

  double _round(double val) => (val * 100).roundToDouble() / 100;

  // --- Actions ---

  void _applySchemes() {
    if (_isApplyingSchemesLock) return;
    _isApplyingSchemesLock = true;

    try {
      // 1. Remove all auto-added free items first
      _cart.removeWhere((item) => item.isFree && item.schemeName != null);

      final newFreeItems = <CartItem>[];

      for (var scheme in _activeSchemes) {
        if (scheme.type == 'buy_x_get_y_free') {
          final buyItem = _cart
              .where((i) => !i.isFree && i.productId == scheme.buyProductId)
              .firstOrNull;

          if (buyItem != null && buyItem.quantity >= scheme.buyQuantity) {
            final timesQualified = (buyItem.quantity / scheme.buyQuantity)
                .floor();
            final freeQty = timesQualified * scheme.getQuantity;

            if (freeQty > 0) {
              final freeProduct = _allProducts
                  .where((p) => p.id == scheme.getProductId)
                  .firstOrNull;
              if (freeProduct != null) {
                newFreeItems.add(
                  CartItem(
                    productId: freeProduct.id,
                    name: freeProduct.name,
                    quantity: freeQty,
                    price: freeProduct.price,
                    isFree: true,
                    discount: 0,
                    secondaryPrice: freeProduct.secondaryPrice,
                    baseUnit: freeProduct.baseUnit,
                    conversionFactor: freeProduct.conversionFactor,
                    secondaryUnit: freeProduct.secondaryUnit,
                    schemeName: scheme.name,
                    stock: freeProduct.stock.toInt(),
                    salesmanStock: _isSalesman
                        ? freeProduct.stock.toInt()
                        : null,
                  ),
                );
              }
            }
          }
        }
      }

      if (newFreeItems.isNotEmpty) {
        _cart.addAll(newFreeItems);
      }
    } finally {
      _isApplyingSchemesLock = false;
    }
  }

  void _addToCart(Product product) {
    if (_isSaving) return;
    setState(() {
      _defaultDiscountByProductId[product.id] = _clampDiscount(
        product.defaultDiscount ??
            (_defaultDiscountByProductId[product.id] ?? 0),
      );
      final existingIndex = _cart.indexWhere(
        (item) => item.productId == product.id && !item.isFree,
      );
      double availableStock = product.stock;

      if (_isSalesman) {
        availableStock = _salesmanStockMap[product.id]?.remainingTotal ?? 0.0;
      }

      if (existingIndex >= 0) {
        // Increment quantity
        final existing = _cart[existingIndex];
        if (existing.quantity + 1 > availableStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot exceed available stock ($availableStock)'),
            ),
          );
          return;
        }

        _cart[existingIndex] = CartItem(
          productId: existing.productId,
          name: existing.name,
          quantity: existing.quantity + 1,
          price: existing.price,
          baseUnit: existing.baseUnit,
          stock: availableStock.toInt(),
          salesmanStock: _isSalesman ? availableStock.toInt() : null,
          isFree: existing.isFree,
          discount: existing.discount > 0
              ? existing.discount
              : _resolveEffectiveCartDiscount(
                  _resolveBaseDefaultDiscount(
                    product.id,
                    fallback: product.defaultDiscount ?? 0.0,
                  ),
                ),
          secondaryPrice: existing.secondaryPrice,
          secondaryUnit: existing.secondaryUnit,
          conversionFactor: existing.conversionFactor,
        );
      } else {
        // Add new
        if (availableStock <= 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product out of stock')));
          return;
        }

        _cart.add(
          CartItem(
            productId: product.id,
            name: product.name,
            quantity: 1,
            price: product.price, // Selling Price
            baseUnit: product.baseUnit,
            stock: availableStock.toInt(),
            salesmanStock: _isSalesman ? availableStock.toInt() : null,
            isFree: false,
            discount: _resolveEffectiveCartDiscount(
              _resolveBaseDefaultDiscount(
                product.id,
                fallback: product.defaultDiscount ?? 0.0,
              ),
            ),
            secondaryPrice: product.secondaryPrice,
            secondaryUnit: product.secondaryUnit,
            conversionFactor: product.conversionFactor,
          ),
        );
      }
      _applySchemes();
    });
  }

  void _updateCartItemQty(int index, int newQty) {
    if (_isSaving) return;
    if (newQty <= 0) {
      _removeFromCart(index);
      return;
    }
    setState(() {
      final item = _cart[index];
      double available = _isSalesman
          ? (_salesmanStockMap[item.productId]?.remainingTotal ?? 0.0)
          : item.stock.toDouble();

      if (newQty > available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: Quantity exceeds available stock ($available)',
            ),
          ),
        );
        if (_isSalesman) return; // Hard block for salesman
      }

      _cart[index] = CartItem(
        productId: item.productId,
        name: item.name,
        quantity: newQty,
        price: item.price,
        baseUnit: item.baseUnit,
        stock: item.stock,
        salesmanStock: item.salesmanStock,
        isFree: item.isFree,
        discount: item.discount,
        secondaryPrice: item.secondaryPrice,
        secondaryUnit: item.secondaryUnit,
        conversionFactor: item.conversionFactor,
        schemeName: item.schemeName,
      );
      _applySchemes();
    });
  }

  void _removeFromCart(int index) {
    if (_isSaving) return;
    setState(() {
      _cart.removeAt(index);
      _applySchemes();
    });
  }

  bool _validateStockBeforeSave() {
    for (final item in _cart) {
      if (item.isFree) continue;
      final available = _isSalesman
          ? (_salesmanStockMap[item.productId]?.remainingTotal ?? 0.0)
          : item.stock.toDouble();

      if (item.quantity > available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.name}: Insufficient stock (Available: ${available.toInt()}, Required: ${item.quantity})',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _saveSale() async {
    if (_isSaving || _isSubmittingConfirm) return;
    final selectedCustomer = _selectedCustomer;
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    // ✅ VALIDATE STOCK BEFORE SHOWING CONFIRMATION
    if (!_validateStockBeforeSave()) return;

    final selectedCustomerSnapshot = selectedCustomer;
    final cartSnapshot = _cart
        .map((item) => item.copyWith())
        .toList(growable: false);
    final normalizedGstType = _gstType.trim().isEmpty
        ? 'None'
        : _gstType.trim();
    final gstPercentageSnapshot = normalizedGstType == 'None'
        ? 0.0
        : _gstPercentage;
    final routeSnapshot = (_selectedRoute?.trim().isNotEmpty ?? false)
        ? _selectedRoute!.trim()
        : selectedCustomerSnapshot.route;
    final calcSnapshot = _calculationEngine.calculateSale(
      items: cartSnapshot
          .map((item) => item.toSaleItemForUI())
          .toList(growable: false),
      discountPercentage: _discountPercentage,
      additionalDiscountPercentage: _additionalDiscountPercentage,
      gstPercentage: gstPercentageSnapshot,
      gstType: normalizedGstType,
    );

    setState(() => _isSubmittingConfirm = true);
    bool? confirmed;
    try {
      confirmed = await _showConfirmationDialog(
        selectedCustomerSnapshot: selectedCustomerSnapshot,
        cartSnapshot: cartSnapshot,
        totalsSnapshot: calcSnapshot,
        routeSnapshot: routeSnapshot,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingConfirm = false);
      }
    }
    if (confirmed != true) return;

    setState(() => _isSaving = true);

    if (!mounted) return;

    final saleId = await ServiceHandler.execute<String>(
      context,
      action: () => _salesService.createSale(
        recipientType: 'customer',
        recipientId: selectedCustomerSnapshot.id,
        recipientName: selectedCustomerSnapshot.shopName.isNotEmpty
            ? selectedCustomerSnapshot.shopName
            : selectedCustomerSnapshot.ownerName,
        items: cartSnapshot,
        discountPercentage: _discountPercentage,
        additionalDiscountPercentage: _additionalDiscountPercentage,
        gstPercentage: gstPercentageSnapshot,
        gstType: normalizedGstType,
        route: routeSnapshot,
        saleType: 'salesmanSale',
        status: 'completed',
      ),
    );

    Sale? saleForDialog;
    var saleSavedSuccessfully = false;

    if (saleId != null && mounted) {
      final authUser = context.read<AuthProvider>().state.user;
      if (authUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
      } else {
        Sale? persistedSale;
        try {
          persistedSale = await _salesService.getSale(saleId);
        } catch (e) {
          debugPrint('Unable to reload saved sale ($saleId): $e');
        }

        final now = DateTime.now();
        final firebaseUid = FirebaseAuth.instance.currentUser?.uid.trim();
        final sale =
            persistedSale ??
            Sale(
              id: saleId,
              recipientType: 'customer',
              recipientId: selectedCustomerSnapshot.id,
              recipientName: selectedCustomerSnapshot.shopName.isNotEmpty
                  ? selectedCustomerSnapshot.shopName
                  : selectedCustomerSnapshot.ownerName,
              items: cartSnapshot
                  .map((item) => item.toSaleItem())
                  .toList(growable: false),
              itemProductIds: cartSnapshot
                  .map((item) => item.productId)
                  .toList(growable: false),
              subtotal: calcSnapshot.subtotal,
              itemDiscountAmount: calcSnapshot.itemDiscountTotal,
              discountPercentage: _discountPercentage,
              discountAmount: calcSnapshot.discountAmount,
              additionalDiscountPercentage: _additionalDiscountPercentage,
              additionalDiscountAmount: calcSnapshot.additionalDiscountAmount,
              taxableAmount: calcSnapshot.taxableAmount,
              gstType: normalizedGstType,
              gstPercentage: gstPercentageSnapshot,
              cgstAmount: calcSnapshot.cgstAmount,
              sgstAmount: calcSnapshot.sgstAmount,
              igstAmount: calcSnapshot.igstAmount,
              totalAmount: calcSnapshot.totalAmount,
              sourceWarehouseId: _selectedWarehouseId,
              roundOff: _round(
                calcSnapshot.totalAmount -
                    (calcSnapshot.taxableAmount + calcSnapshot.totalGstAmount),
              ),
              salesmanId: (firebaseUid != null && firebaseUid.isNotEmpty)
                  ? firebaseUid
                  : '',
              salesmanName: authUser.name,
              createdAt: now.toIso8601String(),
              month: now.month,
              year: now.year,
              saleType: 'Direct',
              status: 'completed',
            );

        _queueWhatsAppInvoicePdfInBackground(
          sale: sale,
          customerName: selectedCustomerSnapshot.shopName.isNotEmpty
              ? selectedCustomerSnapshot.shopName
              : selectedCustomerSnapshot.ownerName,
          customerPhone: selectedCustomerSnapshot.mobile,
        );
        saleForDialog = sale;
        saleSavedSuccessfully = true;
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (saleSavedSuccessfully) {
          _resetSaleDraftInPlace();
        }
      });
    }
    if (mounted && saleSavedSuccessfully && saleForDialog != null) {
      _showSuccessDialog(saleForDialog, customer: selectedCustomerSnapshot);
    }
  }

  void _resetSaleDraftInPlace() {
    _cart.clear();
    _selectedCustomer = null;
    _currentStep = 0;
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

  Future<bool?> _showConfirmationDialog({
    required Customer selectedCustomerSnapshot,
    required List<CartItem> cartSnapshot,
    required SaleCalculationResult totalsSnapshot,
    required String? routeSnapshot,
  }) async {
    final authUser = context.read<AuthProvider>().state.user;
    final now = DateTime.now();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResponsiveDialog(
        maxWidth: 600,
        maxHeightFactor: 0.9,
        borderRadius: BorderRadius.circular(28),
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 420;
                  final textBlock = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVOICE PREVIEW',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review details before completion',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textBlock,
                        const SizedBox(height: 12),
                        Icon(
                          Icons.receipt_long_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textBlock,
                      Icon(
                        Icons.receipt_long_rounded,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Scrollable Content
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section (Company Info)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 420;
                        final companyInfo = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (_companyProfile?.name ?? 'Company')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MIDC, Railway Station Area\nPh: 9988099933',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                        final dateInfo = Column(
                          crossAxisAlignment: isNarrow
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${now.day}/${now.month}/${now.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              companyInfo,
                              const SizedBox(height: 8),
                              dateInfo,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: companyInfo),
                            dateInfo,
                          ],
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1),
                    ),

                    // Customer Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BILL TO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedCustomerSnapshot.shopName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Owner: ${selectedCustomerSnapshot.ownerName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Salesman: ${authUser?.name ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (routeSnapshot != null &&
                            routeSnapshot.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Route: ${routeSnapshot.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Product List Title
                    Text(
                      'ORDER ITEMS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Items List (Table-like appearance with cards)
                    ...cartSnapshot.asMap().entries.map((entry) {
                      final item = entry.value;
                      final hasSecondary =
                          item.secondaryUnit != null &&
                          item.conversionFactor != null &&
                          item.conversionFactor! > 1;
                      final secondaryQty = hasSecondary
                          ? (item.quantity / item.conversionFactor!).floor()
                          : 0;
                      final baseQty = hasSecondary
                          ? (item.quantity % item.conversionFactor!).toInt()
                          : item.quantity;

                      double itemTotal = item.price * item.quantity;
                      if (hasSecondary &&
                          item.secondaryPrice != null &&
                          item.secondaryPrice! > 0) {
                        itemTotal =
                            (secondaryQty * item.secondaryPrice!) +
                            (baseQty * item.price);
                      }
                      final itemDiscountAmount = item.isFree
                          ? 0.0
                          : itemTotal * (item.discount.clamp(0.0, 100.0) / 100);
                      final itemNetAmount = item.isFree
                          ? 0.0
                          : (itemTotal - itemDiscountAmount).clamp(
                              0.0,
                              double.infinity,
                            );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (item.isFree)
                                    Text(
                                      'PROMO: ${item.schemeName ?? "Free Item"}',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  if (!item.isFree && item.discount > 0)
                                    Text(
                                      'Disc ${item.discount.toStringAsFixed(item.discount.truncateToDouble() == item.discount ? 0 : 1)}%',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                hasSecondary
                                    ? '$secondaryQty${item.secondaryUnit} $baseQty${item.baseUnit}'
                                    : '${item.quantity} ${item.baseUnit}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item.isFree
                                        ? '\u20B90.00'
                                        : '\u20B9${itemNetAmount.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (!item.isFree && itemDiscountAmount > 0)
                                    Text(
                                      '-\u20B9${itemDiscountAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Financial Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: isDark ? 0.35 : 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryDialogRow(
                            'GROSS SUB TOTAL',
                            '\u20B9${totalsSnapshot.subtotal.toStringAsFixed(2)}',
                          ),
                          if (totalsSnapshot.itemDiscountTotal > 0)
                            _buildSummaryDialogRow(
                              _lineDiscountLabel.toUpperCase(),
                              '-\u20B9${totalsSnapshot.itemDiscountTotal.toStringAsFixed(2)}',
                              valueColor: AppColors.error,
                            ),
                          if (totalsSnapshot.itemDiscountTotal > 0)
                            _buildSummaryDialogRow(
                              'DISCOUNTED SUBTOTAL',
                              '\u20B9${(totalsSnapshot.subtotal - totalsSnapshot.itemDiscountTotal).toStringAsFixed(2)}',
                            ),
                          if (totalsSnapshot.discountAmount > 0)
                            _buildSummaryDialogRow(
                              'PRIMARY DISCOUNT',
                              '-\u20B9${totalsSnapshot.discountAmount.toStringAsFixed(2)}',
                              valueColor: AppColors.error,
                            ),
                          if (totalsSnapshot.additionalDiscountAmount > 0)
                            _buildSummaryDialogRow(
                              'ADDITIONAL DISCOUNT',
                              '-\u20B9${totalsSnapshot.additionalDiscountAmount.toStringAsFixed(2)}',
                              valueColor: AppColors.error,
                            ),
                          if (totalsSnapshot.totalGstAmount > 0)
                            _buildSummaryDialogRow(
                              'TOTAL TAX (GST)',
                              '\u20B9${totalsSnapshot.totalGstAmount.toStringAsFixed(2)}',
                            ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          _buildSummaryDialogRow(
                            'TOTAL DUE',
                            '\u20B9${totalsSnapshot.totalAmount.toStringAsFixed(2)}',
                            isBold: true,
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final editButton = OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'EDIT ORDER',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                  final confirmButton = ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.success.withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'CONFIRM & SAVE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );

                  if (constraints.maxWidth < 460) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        editButton,
                        const SizedBox(height: 12),
                        confirmButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: editButton),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: confirmButton),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDialogRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 11,
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
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold
                  ? null
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
              color:
                  valueColor ??
                  (isBold ? Theme.of(context).colorScheme.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runInvoiceAction(
    Future<void> Function() action, {
    required String label,
  }) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label failed: $e')));
    }
  }

  void _showSuccessDialog(Sale sale, {required Customer customer}) {
    final invoiceLabel = _invoiceDisplayId(sale);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResponsiveAlertDialog(
        title: Icon(Icons.check_circle, color: AppColors.success, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sale Completed Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Invoice No: $invoiceLabel'),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                _actionColumn(
                  Icons.print,
                  'Print',
                  () async => _runInvoiceAction(
                    () => PdfGenerator.generateAndPrintSaleInvoice(
                      sale,
                      _companyProfile ?? CompanyProfileData(name: 'Company'),
                    ),
                    label: 'Print',
                  ),
                ),
                _actionColumn(
                  Icons.share,
                  'Share',
                  () async => _runInvoiceAction(
                    () => PdfGenerator.shareSaleInvoice(
                      sale,
                      _companyProfile ?? CompanyProfileData(name: 'Company'),
                    ),
                    label: 'Share',
                  ),
                ),
                _actionColumn(
                  Icons.message,
                  'WhatsApp',
                  () async => _runInvoiceAction(
                    () => _shareWhatsApp(sale, customer),
                    label: 'WhatsApp',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(this.context); // Exit screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareWhatsApp(Sale sale, Customer customer) async {
    try {
      final normalizedPhone = _normalizeWhatsAppPhone(customer.mobile);
      if (normalizedPhone == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid customer mobile number')),
          );
        }
        return;
      }
      final invoiceLabel = _invoiceDisplayId(sale);

      final message =
          '''
*DattSoap Invoice*

Invoice: $invoiceLabel
Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Customer: ${customer.shopName}
Total: \u20B9${sale.totalAmount.toStringAsFixed(2)}

Thank you for your business!
''';

      // Use wa.me deep-link with normalized international number.
      final url =
          'https://wa.me/$normalizedPhone?text=${Uri.encodeComponent(message)}';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing to WhatsApp: $e')),
        );
      }
    }
  }

  String? _normalizeWhatsAppPhone(String rawPhone) {
    final cleaned = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) return null;
    if (cleaned.length == 10) return '91$cleaned';
    return cleaned;
  }

  void _queueWhatsAppInvoicePdfInBackground({
    required Sale sale,
    required String customerName,
    required String? customerPhone,
  }) {
    final company = _companyProfile ?? CompanyProfileData(name: 'Company');
    unawaited(
      WhatsAppInvoicePipelineService.instance.enqueueInvoicePdfJob(
        sale: sale,
        companyProfile: company,
        customerName: customerName,
        customerPhone: customerPhone,
        source: 'sales_new',
      ),
    );
  }

  Widget _actionColumn(
    IconData icon,
    String label,
    Future<void> Function() onTap,
  ) {
    return InkWell(
      onTap: () async => onTap(),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.infoBg,
            child: Icon(icon, color: AppColors.info),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_isSaving) return;
    if (_currentStep == 0) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_cart.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_isSaving) return;
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onSalesmanAdditionalDiscountChanged(double? value) {
    if (_isSaving || value == null || !_allowSalesmanAdditionalDiscountToggle) {
      return;
    }
    setState(() {
      _additionalDiscountPercentage = _normalizeAdditionalDiscountSelection(
        value,
      );
    });
  }

  void _onSalesmanSpecialDiscountToggleChanged(bool enabled) {
    if (_isSaving || !_allowSalesmanSpecialDiscountToggle) return;
    setState(() {
      _isSalesmanSpecialDiscountEnabled = enabled;
      if (enabled) {
        _salesmanSpecialDiscountPercentage = _normalizeSpecialDiscountSelection(
          _salesmanSpecialDiscountPercentage > 0
              ? _salesmanSpecialDiscountPercentage
              : _resolveSalesmanSpecialDefaultForCurrentSale(),
        );
      }
      _syncCartDiscountsWithSalesmanSpecialInPlace();
    });
  }

  void _onSalesmanSpecialDiscountPercentageChanged(double? value) {
    if (_isSaving || value == null || !_allowSalesmanSpecialDiscountToggle) {
      return;
    }
    setState(() {
      _salesmanSpecialDiscountPercentage = _normalizeSpecialDiscountSelection(
        value,
      );
      _syncCartDiscountsWithSalesmanSpecialInPlace();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'New Sale',
            subtitle: 'Create a new sale order',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 600;

                if (_isSalesman) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      24 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SaleHeaderWidget(
                          isMobile: isMobile,
                          isSalesman: _isSalesman,
                          availableRoutes: _availableRoutes,
                          selectedRoute: _selectedRoute,
                          selectedCustomer: _selectedCustomer,
                          filteredCustomers: _filteredCustomers,
                          allCustomers: _allCustomers,
                          showSourceWarehouse: !_isSalesman,
                          warehouses: _warehouses,
                          selectedWarehouseId: _selectedWarehouseId,
                          onWarehouseChanged: (warehouseId) {
                            setState(() {
                              _selectedWarehouseId = warehouseId;
                            });
                          },
                          onInputInteraction: _scrollStepperToTop,
                          onRouteChanged: (val) {
                            if (_isSaving) return;
                            setState(() {
                              _selectedRoute = val;
                              _selectedCustomer = null;
                              _filterCustomersByRoute();
                            });
                          },
                          onCustomerSelected: (val) {
                            if (_isSaving) return;
                            setState(() => _selectedCustomer = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        ProductSelectorWidget(
                          isMobile: isMobile,
                          enabled: !_isSaving,
                          allProducts: _allProducts,
                          onSearchInteraction: _scrollStepperToTop,
                          selectedProductIds: _cart
                              .where((item) => !item.isFree)
                              .map((item) => item.productId)
                              .toSet(),
                          onProductSelected: _addToCart,
                        ),
                        const SizedBox(height: 16),
                        CartListWidget(
                          isMobile: isMobile,
                          cart: _cart,
                          isEditable: !_isSaving,
                          onRemoveItem: _removeFromCart,
                          onUpdateQty: (index, qty) {
                            if (qty <= 0) {
                              _removeFromCart(index);
                            } else {
                              _updateCartItemQty(index, qty);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SaleTotalsWidget(
                          isMobile: isMobile,
                          useSalesmanToggles: _isSalesman,
                          spDefaultDiscountEnabled:
                              _isSalesmanSpecialDiscountEnabled,
                          gstToggleLocked: !_allowSalesmanGstToggle,
                          additionalToggleLocked:
                              !_allowSalesmanAdditionalDiscountToggle,
                          specialToggleLocked:
                              !_allowSalesmanSpecialDiscountToggle,
                          specialDiscountPercentage:
                              _salesmanSpecialDiscountPercentage,
                          specialDiscountOptions:
                              _salesmanSpecialDiscountOptions,
                          additionalDiscountOptions:
                              _salesmanAdditionalDiscountOptions,
                          showBreakdown: _showBreakdown,
                          lineDiscountLabel: _lineDiscountLabel,
                          onToggleBreakdown: () =>
                              setState(() => _showBreakdown = !_showBreakdown),
                          subtotal: _subtotal,
                          lineItemDiscountsTotal: _lineItemDiscountsTotal,
                          discountPercentage: _discountPercentage,
                          discountAmount: _discountAmount,
                          additionalDiscountPercentage:
                              _additionalDiscountPercentage,
                          additionalDiscountAmount: _additionalDiscountAmount,
                          taxableAmount: _taxableAmount,
                          gstType: _gstType,
                          gstPercentage: _gstPercentage,
                          totalGst: _totalGst,
                          grandTotal: _grandTotal,
                          onGstTypeChanged: (val) {
                            if (_isSaving) return;
                            setState(() => _gstType = val ?? 'None');
                          },
                          onGstPercentageChanged: (val) {
                            if (_isSaving) return;
                            setState(() => _gstPercentage = val ?? 0);
                          },
                          onAdditionalDiscountChanged: (val) {
                            if (_isSaving) return;
                            if (_isSalesman) {
                              _onSalesmanAdditionalDiscountChanged(val);
                            } else {
                              setState(() {
                                _additionalDiscountPercentage = (val ?? 0)
                                    .clamp(0.0, 100.0);
                              });
                            }
                          },
                          onSpDefaultDiscountToggleChanged: _isSalesman
                              ? _onSalesmanSpecialDiscountToggleChanged
                              : null,
                          onSpecialDiscountPercentageChanged: _isSalesman
                              ? _onSalesmanSpecialDiscountPercentageChanged
                              : null,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: (_isSaving || _isSubmittingConfirm)
                              ? null
                              : _saveSale,
                          label: 'COMPLETE SALE (Rs ${_grandTotal.toInt()})',
                          isLoading: _isSaving || _isSubmittingConfirm,
                          variant: ButtonVariant.primary,
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Stepper(
                    // Keep Customer/Cart/Pay in one top row across screen sizes.
                    type: StepperType.horizontal,
                    controller: _stepperScrollController,
                    currentStep: _currentStep,
                    elevation: 0,
                    onStepContinue: _nextStep,
                    onStepCancel: _prevStep,
                    onStepTapped: (step) {
                      if (_isSaving) return;
                      if (step < _currentStep) {
                        setState(() => _currentStep = step);
                      }
                    },
                    controlsBuilder: (context, details) {
                      final isLastStep = _currentStep == 2;
                      final stackControls =
                          isMobile || MediaQuery.sizeOf(context).width < 420;
                      if (stackControls) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_currentStep > 0) ...[
                                CustomButton(
                                  onPressed: (_isSaving || _isSubmittingConfirm)
                                      ? null
                                      : details.onStepCancel,
                                  label: 'BACK',
                                  variant: ButtonVariant.outline,
                                ),
                                const SizedBox(height: 10),
                              ],
                              CustomButton(
                                onPressed: (_isSaving || _isSubmittingConfirm)
                                    ? null
                                    : (isLastStep
                                          ? _saveSale
                                          : details.onStepContinue),
                                label: isLastStep
                                    ? 'COMPLETE SALE (Rs ${_grandTotal.toInt()})'
                                    : 'CONTINUE',
                                isLoading: isLastStep
                                    ? (_isSaving || _isSubmittingConfirm)
                                    : false,
                                variant: ButtonVariant.primary,
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: CustomButton(
                                  onPressed: (_isSaving || _isSubmittingConfirm)
                                      ? null
                                      : details.onStepCancel,
                                  label: 'BACK',
                                  variant: ButtonVariant.outline,
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: CustomButton(
                                onPressed: (_isSaving || _isSubmittingConfirm)
                                    ? null
                                    : (isLastStep
                                          ? _saveSale
                                          : details.onStepContinue),
                                label: isLastStep
                                    ? 'COMPLETE SALE (Rs ${_grandTotal.toInt()})'
                                    : 'CONTINUE',
                                isLoading: isLastStep
                                    ? (_isSaving || _isSubmittingConfirm)
                                    : false,
                                variant: ButtonVariant.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      Step(
                        title: const Text('Customer'),
                        content: SaleHeaderWidget(
                          isMobile: isMobile,
                          isSalesman: _isSalesman,
                          availableRoutes: _availableRoutes,
                          selectedRoute: _selectedRoute,
                          selectedCustomer: _selectedCustomer,
                          filteredCustomers: _filteredCustomers,
                          allCustomers: _allCustomers,
                          onInputInteraction: _scrollStepperToTop,
                          onRouteChanged: (val) {
                            if (_isSaving) return;
                            setState(() {
                              _selectedRoute = val;
                              _selectedCustomer = null;
                              _filterCustomersByRoute();
                            });
                          },
                          onCustomerSelected: (val) {
                            if (_isSaving) return;
                            setState(() => _selectedCustomer = val);
                          },
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.editing,
                      ),
                      Step(
                        title: const Text('Cart'),
                        content: Column(
                          children: [
                            ProductSelectorWidget(
                              isMobile: isMobile,
                              enabled: !_isSaving,
                              allProducts: _allProducts,
                              onSearchInteraction: _scrollStepperToTop,
                              selectedProductIds: _cart
                                  .where((item) => !item.isFree)
                                  .map((item) => item.productId)
                                  .toSet(),
                              onProductSelected: _addToCart,
                            ),
                            const SizedBox(height: 16),
                            CartListWidget(
                              isMobile: isMobile,
                              cart: _cart,
                              isEditable: !_isSaving,
                              onRemoveItem: _removeFromCart,
                              onUpdateQty: (index, qty) {
                                if (qty <= 0) {
                                  _removeFromCart(index);
                                } else {
                                  _updateCartItemQty(index, qty);
                                }
                              },
                            ),
                          ],
                        ),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.editing,
                      ),
                      Step(
                        title: const Text('Pay'),
                        content: SaleTotalsWidget(
                          isMobile: isMobile,
                          useSalesmanToggles: _isSalesman,
                          spDefaultDiscountEnabled:
                              _isSalesmanSpecialDiscountEnabled,
                          gstToggleLocked: !_allowSalesmanGstToggle,
                          additionalToggleLocked:
                              !_allowSalesmanAdditionalDiscountToggle,
                          specialToggleLocked:
                              !_allowSalesmanSpecialDiscountToggle,
                          specialDiscountPercentage:
                              _salesmanSpecialDiscountPercentage,
                          specialDiscountOptions:
                              _salesmanSpecialDiscountOptions,
                          additionalDiscountOptions:
                              _salesmanAdditionalDiscountOptions,
                          showBreakdown: _showBreakdown,
                          lineDiscountLabel: _lineDiscountLabel,
                          onToggleBreakdown: () =>
                              setState(() => _showBreakdown = !_showBreakdown),
                          subtotal: _subtotal,
                          lineItemDiscountsTotal: _lineItemDiscountsTotal,
                          discountPercentage: _discountPercentage,
                          discountAmount: _discountAmount,
                          additionalDiscountPercentage:
                              _additionalDiscountPercentage,
                          additionalDiscountAmount: _additionalDiscountAmount,
                          taxableAmount: _taxableAmount,
                          gstType: _gstType,
                          gstPercentage: _gstPercentage,
                          totalGst: _totalGst,
                          grandTotal: _grandTotal,
                          onGstTypeChanged: (val) {
                            if (_isSaving) return;
                            setState(() => _gstType = val ?? 'None');
                          },
                          onGstPercentageChanged: (val) {
                            if (_isSaving) return;
                            setState(() => _gstPercentage = val ?? 0);
                          },
                          onAdditionalDiscountChanged: (val) {
                            if (_isSaving) return;
                            if (_isSalesman) {
                              _onSalesmanAdditionalDiscountChanged(val);
                            } else {
                              setState(() {
                                _additionalDiscountPercentage = (val ?? 0)
                                    .clamp(0.0, 100.0);
                              });
                            }
                          },
                          onSpDefaultDiscountToggleChanged: _isSalesman
                              ? _onSalesmanSpecialDiscountToggleChanged
                              : null,
                          onSpecialDiscountPercentageChanged: _isSalesman
                              ? _onSalesmanSpecialDiscountPercentageChanged
                              : null,
                        ),
                        isActive: _currentStep >= 2,
                        state: _currentStep == 2
                            ? StepState.editing
                            : StepState.complete,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
