// ⚠️ CRITICAL FILE - DO NOT MODIFY WITHOUT PERMISSION
// Dealer dispatch screen with auto-populated route field from dealer selection.
// Modified: Reordered fields (Dealer → Route → Driver → Vehicle), route auto-populates from dealer
// Contact: Developer before making changes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/engines/sale_calculation_engine.dart';
import '../../services/dealers_service.dart';
import '../../services/products_service.dart';
import '../../services/sales_service.dart';
import '../../services/schemes_service.dart';
import '../../services/users_service.dart';
import '../../services/vehicles_service.dart';
import '../../models/types/product_types.dart';
import '../../models/types/route_order_types.dart';
import '../../models/types/sales_types.dart';
import '../../models/types/user_types.dart';
import '../../services/settings_service.dart';
import '../../modules/hr/models/employee_model.dart';
import '../../modules/hr/services/hr_service.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../utils/responsive.dart';
import '../../utils/service_handler.dart';
import '../../widgets/ui/hoverable_container.dart';
import '../../widgets/ui/themed_filter_chip.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/route_order_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/app_logger.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import '../../services/whatsapp_invoice_pipeline_service.dart';

class DealerDispatchScreen extends StatefulWidget {
  final Object? prefillExtra;

  const DealerDispatchScreen({super.key, this.prefillExtra});

  @override
  State<DealerDispatchScreen> createState() => _DealerDispatchScreenState();
}

class _DealerDispatchScreenState extends State<DealerDispatchScreen>
    with AutomaticKeepAliveClientMixin, RouteAware {
  // Services
  late SalesService _salesService;
  late final ProductsService _productsService;
  late final DealersService _dealersService;
  late final SchemesService _schemesService;
  late final UsersService _usersService;
  late final VehiclesService _vehiclesService;
  late final SettingsService _settingsService;
  late final HrService _hrService;
  late final RouteOrderService _routeOrderService;

  // Data
  List<Dealer> _allDealers = [];
  List<Product> _allProducts = [];
  List<Scheme> _allSchemes = [];
  List<AppUser> _allDrivers = [];
  List<Vehicle> _allVehicles = [];
  List<String> _routes = [];
  final Map<String, String> _routeIdByName = {};
  CompanyProfileData? _companyProfile;

  // Selection
  Dealer? _selectedDealer;
  AppUser? _selectedDriver;
  Vehicle? _selectedVehicle;
  String? _selectedRoute;

  // Cart
  final List<CartItem> _cart = [];
  final Map<String, TextEditingController> _qtyControllers = {};
  TextEditingController? _internalProductSearchController;

  // Financials
  final SaleCalculationEngine _calculationEngine = SaleCalculationEngine();
  double _discountPercentage = 0;
  double _specialDiscountPercentage = 0;
  bool _gstEnabled = false;
  double _gstPercentage = 0;
  String _gstType = 'None';
  bool _allowDealerGstToggle = true;
  bool _allowDealerAdditionalDiscountToggle = true;
  bool _allowDealerSpecialDiscountToggle = true;
  List<double> _dealerAdditionalDiscountOptions = const [2, 5, 10, 15];
  double _dealerAdditionalDiscountDefault = 5.0;
  List<double> _dealerSpecialDiscountOptions = const [1, 2, 3, 5];
  double _dealerSpecialDiscountDefault = 5.0;
  bool _gstDefaultEnabled = false;
  double _gstDefaultPercentage = 18.0;
  String _gstDefaultType = 'None';

  bool _isLoading = true;
  bool _isSaving = false;
  String _productFilterType = 'Finished'; // 'Finished' | 'Traded'
  final ScrollController _productFilterScrollController = ScrollController();
  final Map<String, GlobalKey> _productFilterKeys = {
    'Finished': GlobalKey(),
    'Traded': GlobalKey(),
  };
  RouteOrderDispatchPayload? _routeOrderPayload;
  bool _routeOrderPrefillApplied = false;

  List<AppUser> _dedupeUsers(List<AppUser> users) {
    final map = <String, AppUser>{};
    for (final user in users) {
      map[user.id] = user;
    }
    return map.values.toList();
  }

  String _normalizeRole(String value) {
    return value
        .trim()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toLowerCase();
  }

  bool _isActiveUser(AppUser user) {
    final status = (user.status ?? '').trim().toLowerCase();
    return user.isActive &&
        (status.isEmpty ||
            status == 'active' ||
            status == 'enabled' ||
            status == 'approved');
  }

  AppUser _driverFromEmployee(Employee employee) {
    final linkedUserId = employee.linkedUserId?.trim();
    final userId = (linkedUserId != null && linkedUserId.isNotEmpty)
        ? linkedUserId
        : 'emp_${employee.employeeId}';

    return AppUser(
      id: userId,
      name: employee.name,
      email: '${employee.employeeId.toLowerCase()}@hr.local',
      role: UserRole.driver,
      department: employee.department,
      phone: employee.mobile,
      departments: const [],
      status: employee.isActive ? 'active' : 'inactive',
      isActive: employee.isActive,
      createdAt: employee.createdAt.toIso8601String(),
    );
  }

  Future<List<AppUser>> _loadDriverCandidates() async {
    final employees = await _hrService.getAllEmployees(forceRefresh: true);
    final hrDrivers = employees
        .where((e) => e.isActive && _normalizeRole(e.roleType) == 'driver')
        .map(_driverFromEmployee)
        .toList();

    if (hrDrivers.isNotEmpty) {
      final deduped = _dedupeUsers(hrDrivers);
      deduped.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return deduped;
    }

    final users = await _usersService.getUsers(role: UserRole.driver);
    final strictDrivers = users
        .where((u) => u.role == UserRole.driver && _isActiveUser(u))
        .toList();

    final deduped = _dedupeUsers(strictDrivers);
    deduped.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return deduped;
  }

  @override
  void initState() {
    super.initState();
    _schemesService = context.read<SchemesService>();
    _salesService = context.read<SalesService>();
    _productsService = context.read<ProductsService>();
    _dealersService = context.read<DealersService>();
    _usersService = context.read<UsersService>();
    _vehiclesService = context.read<VehiclesService>();
    _settingsService = context.read<SettingsService>();
    _hrService = context.read<HrService>();
    _routeOrderService = context.read<RouteOrderService>();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedProductFilter(animate: false);
      _tryApplyRouteOrderPrefill();
    });
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _qtyControllers.clear();
    _internalProductSearchController?.dispose();
    _productFilterScrollController.dispose();
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
      final normalizedName = _normalizeRouteToken(name);
      final mappedRouteId = _routeIdByName[normalizedName];
      if (routeId.isNotEmpty && mappedRouteId == routeId) return name;
      if (routeName.isNotEmpty &&
          _normalizeRouteToken(name) == _normalizeRouteToken(routeName)) {
        return name;
      }
    }
    if (routeName.isNotEmpty) return routeName;
    return null;
  }

  Dealer? _resolvePrefillDealer(RouteOrderDispatchPayload payload) {
    final dealerId = payload.dealerId.trim();
    if (dealerId.isNotEmpty) {
      for (final dealer in _allDealers) {
        if (dealer.id == dealerId) return dealer;
      }
    }
    return _resolveDealerSelectionForRoute(payload.routeName);
  }

  Vehicle? _resolvePrefillVehicle(RouteOrderDispatchPayload payload) {
    final vehicleId = payload.vehicleId.trim();
    final vehicleNumber = payload.vehicleNumber.trim().toLowerCase();
    for (final vehicle in _allVehicles) {
      if (vehicleId.isNotEmpty && vehicle.id == vehicleId) {
        return vehicle;
      }
      if (vehicleNumber.isNotEmpty &&
          vehicle.number.trim().toLowerCase() == vehicleNumber) {
        return vehicle;
      }
    }
    return null;
  }

  List<CartItem> _buildCartItemsFromPayload(RouteOrderDispatchPayload payload) {
    final mergedByProductId = <String, CartItem>{};
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

      final existing = mergedByProductId[productId];
      final mergedQty = (existing?.quantity ?? 0) + orderItem.qty;
      final price = orderItem.price > 0
          ? orderItem.price
          : (product?.price ?? 0.0);

      mergedByProductId[productId] = CartItem(
        productId: productId,
        name: orderItem.name.trim().isNotEmpty
            ? orderItem.name.trim()
            : (product?.name ?? 'Product'),
        quantity: mergedQty,
        price: price,
        discount: product?.defaultDiscount ?? 0,
        baseUnit: orderItem.baseUnit.trim().isNotEmpty
            ? orderItem.baseUnit
            : (product?.baseUnit ?? 'Unit'),
        stock: product?.stock.toInt() ?? 0,
        secondaryPrice: product?.secondaryPrice,
        conversionFactor: product?.conversionFactor,
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
    final resolvedDealer = _resolvePrefillDealer(payload);
    final resolvedVehicle = _resolvePrefillVehicle(payload);
    final prefilledCart = _buildCartItemsFromPayload(payload);

    final nextRoutes = List<String>.from(_routes);
    if (resolvedRoute != null && resolvedRoute.trim().isNotEmpty) {
      final exists = nextRoutes.any(
        (route) =>
            _normalizeRouteToken(route) == _normalizeRouteToken(resolvedRoute),
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
          _routeIdByName[_normalizeRouteToken(resolvedRoute)] = payload.routeId
              .trim();
        }
      }
      _selectedDealer = resolvedDealer ?? _selectedDealer;
      _selectedVehicle = resolvedVehicle ?? _selectedVehicle;
      _cart
        ..clear()
        ..addAll(prefilledCart);
      _resetPricingSelections();
    });

    _applySchemes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Route order ${payload.routeOrderNo} loaded. Review items and confirm dispatch.',
        ),
      ),
    );
  }

  void _centerSelectedProductFilter({bool animate = true}) {
    final targetContext =
        _productFilterKeys[_productFilterType]?.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      duration: animate ? const Duration(milliseconds: 220) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  void _setProductFilterType(String value) {
    setState(() => _productFilterType = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedProductFilter();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final drivers = await _loadDriverCandidates();

      final results = await Future.wait([
        _dealersService.getDealers(status: 'active'),
        _productsService.getProducts(status: 'active'),
        _schemesService.getSchemes(status: 'active'),
        _vehiclesService.getVehicles(status: 'active'),
        _vehiclesService.getRoutes(), // Load routes from Master Data
        _settingsService.getCompanyProfileClient(),
        _settingsService.getGeneralSettings(forceRefresh: true),
        _settingsService.getGstSettings(),
      ]);

      if (mounted) {
        // Extract route names from Master Data routes
        final routeData = results[4] as List<Map<String, dynamic>>;
        final activeRoutes = routeData
            .where((r) => r['status'] == 'active' || r['isActive'] == true)
            .toList();
        final routeNames = <String>[];
        final routeIdByName = <String, String>{};
        for (final route in activeRoutes) {
          final name = (route['name'] ?? '').toString().trim();
          if (name.isEmpty) {
            continue;
          }
          routeNames.add(name);
          final id = (route['id'] ?? '').toString().trim();
          if (id.isNotEmpty) {
            routeIdByName[_normalizeRouteToken(name)] = id;
          }
        }
        routeNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final uniqueRouteNames = routeNames.toSet().toList();

        setState(() {
          _allDealers = results[0] as List<Dealer>;
          _allProducts = results[1] as List<Product>;
          _allSchemes = results[2] as List<Scheme>;
          _allDrivers = drivers;
          _allVehicles = results[3] as List<Vehicle>;
          _routes = uniqueRouteNames;
          _routeIdByName
            ..clear()
            ..addAll(routeIdByName);
          _selectedDealer = _resolveDealerSelectionForRoute(
            _selectedRoute,
            previousDealer: _selectedDealer,
          );
          _companyProfile = results[5] as CompanyProfileData?;
          _applyDealerPricingSettings(
            results[6] as GeneralSettingsData?,
            results[7] as GstSettings?,
            initializeValues: true,
          );
          _isLoading = false;
        });

        if (_allDrivers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active drivers found in HR employees.'),
            ),
          );
        }
        _tryApplyRouteOrderPrefill();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        setState(() => _isLoading = false);
        _tryApplyRouteOrderPrefill();
      }
    }
  }

  double _clampDiscount(double value) => value.clamp(0.0, 100.0).toDouble();

  List<double> _normalizeDiscountOptions(
    List<double>? rawValues, {
    required List<double> fallback,
    List<double> ensureValues = const <double>[],
  }) {
    final values = <double>{};
    for (final value in rawValues ?? const <double>[]) {
      final normalized = _clampDiscount(value);
      if (normalized > 0) values.add(normalized);
    }
    for (final value in ensureValues) {
      final normalized = _clampDiscount(value);
      if (normalized > 0) values.add(normalized);
    }
    if (values.isEmpty) {
      values.addAll(fallback.where((entry) => entry > 0));
    }
    final sorted = values.toList()..sort();
    return sorted;
  }

  double _normalizeDiscountSelection(
    double value,
    List<double> options, {
    bool allowZero = true,
  }) {
    final normalized = _clampDiscount(value);
    if (allowZero && normalized == 0) return 0;
    if (options.contains(normalized)) return normalized;
    return options.first;
  }

  String _normalizeGstType(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'cgst+sgst' || normalized == 'cgst_sgst') {
      return 'CGST+SGST';
    }
    if (normalized == 'igst') {
      return 'IGST';
    }
    return 'None';
  }

  double _defaultAdditionalDiscountSelection() {
    if (!_allowDealerAdditionalDiscountToggle) return 0.0;
    return _normalizeDiscountSelection(
      _dealerAdditionalDiscountDefault,
      _dealerAdditionalDiscountOptions,
    );
  }

  double _defaultSpecialDiscountSelection() {
    if (!_allowDealerSpecialDiscountToggle) return 0.0;
    return _normalizeDiscountSelection(
      _dealerSpecialDiscountDefault,
      _dealerSpecialDiscountOptions,
    );
  }

  void _resetPricingSelections() {
    _discountPercentage = _defaultAdditionalDiscountSelection();
    _specialDiscountPercentage = _defaultSpecialDiscountSelection();
    _gstEnabled = _allowDealerGstToggle && _gstDefaultEnabled;
    _gstType = _gstEnabled ? _gstDefaultType : 'None';
    _gstPercentage = _gstEnabled ? _gstDefaultPercentage : 0.0;
  }

  void _applyDealerPricingSettings(
    GeneralSettingsData? settings,
    GstSettings? gstSettings, {
    bool initializeValues = false,
  }) {
    final allowGst = settings?.allowDealerGstToggle ?? true;
    final allowAdditional =
        settings?.allowDealerAdditionalDiscountToggle ?? true;
    final allowSpecial = settings?.allowDealerSpecialDiscountToggle ?? true;
    final additionalDefault = _clampDiscount(
      settings?.dealerAdditionalDiscountDefault ?? 5.0,
    );
    final specialDefault = _clampDiscount(
      settings?.dealerSpecialDiscountDefault ?? 5.0,
    );
    final additionalOptions = _normalizeDiscountOptions(
      settings?.dealerAdditionalDiscountOptions,
      fallback: const [2, 5, 10, 15],
      ensureValues: [additionalDefault],
    );
    final specialOptions = _normalizeDiscountOptions(
      settings?.dealerSpecialDiscountOptions,
      fallback: const [1, 2, 3, 5],
      ensureValues: [specialDefault],
    );

    _allowDealerGstToggle = allowGst;
    _allowDealerAdditionalDiscountToggle = allowAdditional;
    _allowDealerSpecialDiscountToggle = allowSpecial;
    _dealerAdditionalDiscountDefault = additionalDefault;
    _dealerSpecialDiscountDefault = specialDefault;
    _dealerAdditionalDiscountOptions = additionalOptions;
    _dealerSpecialDiscountOptions = specialOptions;
    _gstDefaultEnabled = gstSettings?.isEnabled ?? false;
    _gstDefaultType = _normalizeGstType(gstSettings?.defaultGstType);
    _gstDefaultPercentage = _clampDiscount(
      gstSettings?.defaultGstPercentage ?? 18.0,
    );

    if (!_allowDealerAdditionalDiscountToggle) {
      _discountPercentage = 0.0;
    } else if (initializeValues) {
      _discountPercentage = _normalizeDiscountSelection(
        _discountPercentage > 0
            ? _discountPercentage
            : _dealerAdditionalDiscountDefault,
        _dealerAdditionalDiscountOptions,
      );
    }

    if (!_allowDealerSpecialDiscountToggle) {
      _specialDiscountPercentage = 0.0;
    } else if (initializeValues) {
      _specialDiscountPercentage = _normalizeDiscountSelection(
        _specialDiscountPercentage > 0
            ? _specialDiscountPercentage
            : _dealerSpecialDiscountDefault,
        _dealerSpecialDiscountOptions,
      );
    }

    if (!_allowDealerGstToggle) {
      _gstEnabled = false;
      _gstType = 'None';
      _gstPercentage = 0.0;
    } else if (initializeValues) {
      _gstEnabled = _gstEnabled || _gstDefaultEnabled;
      _gstType = _gstEnabled ? _gstDefaultType : 'None';
      _gstPercentage = _gstEnabled ? _gstDefaultPercentage : 0.0;
    }
  }

  String _formatPercent(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.001) {
      return rounded.toStringAsFixed(0);
    }
    final singleDecimal = double.parse(value.toStringAsFixed(1));
    if ((value - singleDecimal).abs() < 0.001) {
      return singleDecimal.toStringAsFixed(1);
    }
    return value.toStringAsFixed(2);
  }

  List<double> get _dealerAdditionalDiscountDropdownOptions {
    final values = <double>{0.0, ..._dealerAdditionalDiscountOptions};
    final sorted = values.toList()..sort();
    return sorted;
  }

  String get _productDiscountLabel {
    final discounts = _cart
        .where((item) => !item.isFree && item.quantity > 0 && item.discount > 0)
        .map((item) => _clampDiscount(item.discount))
        .toSet()
        .toList()
      ..sort();
    if (discounts.length == 1) {
      return 'PRODUCT DISCOUNT (${_formatPercent(discounts.first)}%)';
    }
    return 'PRODUCT DISCOUNT';
  }

  String _normalizeRouteToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeRouteTokenOrNull(String? value) {
    if (value == null) return null;
    final normalized = _normalizeRouteToken(value);
    return normalized.isEmpty ? null : normalized;
  }

  Set<String> _selectedRouteTokens(String? routeName) {
    final tokens = <String>{};
    final normalizedName = _normalizeRouteTokenOrNull(routeName);
    if (normalizedName == null) {
      return tokens;
    }
    tokens.add(normalizedName);

    final routeId = _routeIdByName[normalizedName];
    final normalizedRouteId = _normalizeRouteTokenOrNull(routeId);
    if (normalizedRouteId != null) {
      tokens.add(normalizedRouteId);
    }
    return tokens;
  }

  bool _dealerMatchesRoute(Dealer dealer, String? routeName) {
    if (routeName == null || routeName.trim().isEmpty) {
      return true;
    }

    final selectedTokens = _selectedRouteTokens(routeName);
    if (selectedTokens.isEmpty) {
      return true;
    }

    final dealerTokens = <String>{};
    final routeIdToken = _normalizeRouteTokenOrNull(dealer.assignedRouteId);
    final routeNameToken = _normalizeRouteTokenOrNull(dealer.assignedRouteName);
    final territoryToken = _normalizeRouteTokenOrNull(dealer.territory);
    if (routeIdToken != null) dealerTokens.add(routeIdToken);
    if (routeNameToken != null) dealerTokens.add(routeNameToken);
    if (territoryToken != null) dealerTokens.add(territoryToken);

    if (dealerTokens.isEmpty) {
      return false;
    }

    return dealerTokens.any(selectedTokens.contains);
  }

  List<Dealer> _dealersForRoute(String? routeName) {
    final filtered =
        _allDealers
            .where((dealer) => _dealerMatchesRoute(dealer, routeName))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    return filtered;
  }

  Dealer? _resolveDealerSelectionForRoute(
    String? routeName, {
    Dealer? previousDealer,
  }) {
    final filteredDealers = _dealersForRoute(routeName);
    if (filteredDealers.isEmpty) {
      return null;
    }

    if (previousDealer != null) {
      final stillValid = filteredDealers.where(
        (d) => d.id == previousDealer.id,
      );
      if (stillValid.isNotEmpty) {
        return stillValid.first;
      }
    }

    if (filteredDealers.length == 1) {
      return filteredDealers.first;
    }
    return null;
  }

  String? _resolveRouteForDealer(Dealer dealer) {
    final dealerTokens = <String>{};
    final routeIdToken = _normalizeRouteTokenOrNull(dealer.assignedRouteId);
    final routeNameToken = _normalizeRouteTokenOrNull(dealer.assignedRouteName);
    final territoryToken = _normalizeRouteTokenOrNull(dealer.territory);
    if (routeIdToken != null) dealerTokens.add(routeIdToken);
    if (routeNameToken != null) dealerTokens.add(routeNameToken);
    if (territoryToken != null) dealerTokens.add(territoryToken);
    if (dealerTokens.isEmpty) {
      return null;
    }

    for (final route in _routes) {
      final normalizedRoute = _normalizeRouteToken(route);
      final mappedRouteId = _routeIdByName[normalizedRoute];
      final mappedRouteIdToken = _normalizeRouteTokenOrNull(mappedRouteId);
      if (dealerTokens.contains(normalizedRoute) ||
          (mappedRouteIdToken != null &&
              dealerTokens.contains(mappedRouteIdToken))) {
        return route;
      }
    }

    final fallbackName = dealer.assignedRouteName?.trim();
    if (fallbackName != null && fallbackName.isNotEmpty) {
      return fallbackName;
    }
    final fallbackTerritory = dealer.territory?.trim();
    if (fallbackTerritory != null && fallbackTerritory.isNotEmpty) {
      return fallbackTerritory;
    }
    return null;
  }

  void _ensureRouteExists(String routeName, {String? routeId}) {
    final normalized = _normalizeRouteToken(routeName);
    if (_routes.every((route) => _normalizeRouteToken(route) != normalized)) {
      _routes = [..._routes, routeName]
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    final normalizedRouteId = _normalizeRouteTokenOrNull(routeId);
    if (normalizedRouteId != null) {
      _routeIdByName[normalized] = routeId!.trim();
    }
  }



  void _onDealerChanged(Dealer? dealer) {
    setState(() {
      _selectedDealer = dealer;
      if (dealer == null) {
        return;
      }

      final resolvedRoute = _resolveRouteForDealer(dealer);
      if (resolvedRoute == null) {
        return;
      }

      _ensureRouteExists(resolvedRoute, routeId: dealer.assignedRouteId);
      _selectedRoute = _routes.firstWhere(
        (route) =>
            _normalizeRouteToken(route) == _normalizeRouteToken(resolvedRoute),
        orElse: () => resolvedRoute,
      );
    });
  }

  void _addToCart(Product product) {
    // Check if exists
    final existingIndex = _cart.indexWhere(
      (item) => item.productId == product.id && !item.isFree,
    );
    if (existingIndex != -1) {
      _updateCartItemQty(existingIndex, _cart[existingIndex].quantity + 1);
    } else {
      setState(() {
        _cart.add(
          CartItem(
            productId: product.id,
            name: product.name,
            quantity: 0,
            price: product.price,
            discount: product.defaultDiscount ?? 0,
            baseUnit: product.baseUnit,
            stock: product.stock.toInt(),
            salesmanStock: null,
          ),
        );
        _applySchemes();
      });
    }
  }

  void _applySchemes() {
    // Remove existing free items
    _cart.removeWhere((item) => item.isFree);

    if (_allProducts.isEmpty) {
      return;
    }

    List<CartItem> newFreeItems = [];

    // Group paid items by product ID
    Map<String, double> productQuantities = {};
    for (var item in _cart) {
      if (!item.isFree) {
        productQuantities[item.productId] =
            (productQuantities[item.productId] ?? 0) + item.quantity;
      }
    }

    // Check schemes
    for (var scheme in _allSchemes) {
      final buyQty = productQuantities[scheme.buyProductId];
      if (buyQty != null && buyQty >= scheme.buyQuantity) {
        final timesQualified = (buyQty / scheme.buyQuantity).floor();
        final freeQty = timesQualified * scheme.getQuantity;

        final freeProduct = _allProducts.firstWhere(
          (p) => p.id == scheme.getProductId,
          orElse: () => _allProducts.first, // Fallback
        );

        if (freeQty > 0) {
          newFreeItems.add(
            CartItem(
              productId: freeProduct.id,
              name: freeProduct.name,
              quantity: freeQty.toInt(),
              price: 0,
              isFree: true,
              baseUnit: freeProduct.baseUnit,
              stock: 9999, // Assumption for free items
              schemeName: scheme.name,
            ),
          );
        }
      }
    }

    setState(() {
      _cart.addAll(newFreeItems);
    });
  }

  void _removeFromCart(int index) {
    final item = _cart[index];
    setState(() {
      _cart.removeAt(index);
      if (!item.isFree) {
        final removed = _qtyControllers.remove(item.productId);
        if (removed != null) {
          _disposeControllersLater([removed]);
        }
      }
      _applySchemes();
    });
  }

  CartItem _updateCartItem(CartItem item, int newQty) {
    return CartItem(
      productId: item.productId,
      name: item.name,
      quantity: newQty,
      price: item.price,
      discount: item.discount,
      baseUnit: item.baseUnit,
      stock: item.stock,
      isFree: item.isFree,
      schemeName: item.schemeName,
      secondaryPrice: item.secondaryPrice,
      conversionFactor: item.conversionFactor,
      secondaryUnit: item.secondaryUnit,
      salesmanStock: item.salesmanStock,
    );
  }

  void _updateCartItemQty(int index, int newQty) {
    final normalizedQty = newQty < 0 ? 0 : newQty;
    setState(() {
      final item = _cart[index];
      _cart[index] = _updateCartItem(item, normalizedQty);
      _applySchemes();
    });
  }

  // Calculations
  double get _grossSubtotal {
    return _pricing.subtotal;
  }

  double get _itemLevelDiscounts {
    return _pricing.itemDiscountTotal;
  }

  double get _discountedSubtotal => _grossSubtotal - _itemLevelDiscounts;

  double get _effectiveAdditionalDiscountPercentage =>
      _allowDealerAdditionalDiscountToggle ? _discountPercentage : 0.0;

  double get _effectiveSpecialDiscountPercentage =>
      _allowDealerSpecialDiscountToggle ? _specialDiscountPercentage : 0.0;

  bool get _effectiveGstEnabled => _allowDealerGstToggle && _gstEnabled;

  double get _effectiveGstPercentage => _effectiveGstEnabled ? _gstPercentage : 0;

  String get _effectiveGstType => _effectiveGstEnabled ? _gstType : 'None';

  SaleCalculationResult get _pricing {
    final items = _cart.map((item) => item.toSaleItemForUI()).toList();
    return _calculationEngine.calculateSale(
      items: items,
      discountPercentage: _effectiveAdditionalDiscountPercentage,
      additionalDiscountPercentage: _effectiveSpecialDiscountPercentage,
      gstPercentage: _effectiveGstPercentage,
      gstType: _effectiveGstType,
    );
  }

  double get _discountAmount => _pricing.discountAmount;

  double get _specialDiscountAmount => _pricing.additionalDiscountAmount;

  double get _taxableAmount => _pricing.taxableAmount;

  double get _totalGst => _pricing.totalGstAmount;

  double get _grandTotal => _pricing.totalAmount;
  int get _totalDispatchQty => _cart
      .where((item) => !item.isFree)
      .fold(0, (sum, item) => sum + item.quantity);

  Future<bool> _showDispatchInvoicePreview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dispatchBy = authProvider.state.user?.name.trim();
    final companyName = _companyProfile?.name?.trim();
    final paidItems = _cart
        .where((item) => !item.isFree)
        .toList(growable: false);

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _DealerDispatchInvoicePreviewPage(
          companyName: (companyName == null || companyName.isEmpty)
              ? 'Datt Soap Industry'
              : companyName,
          dispatchBy: (dispatchBy == null || dispatchBy.isEmpty)
              ? 'System'
              : dispatchBy,
          dealerName: _selectedDealer?.name ?? 'N/A',
          routeName:
              _selectedRoute ??
              _selectedDealer?.assignedRouteName ??
              _selectedDealer?.territory ??
              'N/A',
          vehicleNo: _selectedVehicle?.number ?? 'N/A',
          driverName: _selectedDriver?.name ?? 'N/A',
          now: DateTime.now(),
          paidItems: paidItems,
          totalDispatchQty: _totalDispatchQty,
          grossSubtotal: _grossSubtotal,
          itemLevelDiscounts: _itemLevelDiscounts,
          discountedSubtotal: _discountedSubtotal,
          productDiscountLabel: _productDiscountLabel,
          discountPercentage: _effectiveAdditionalDiscountPercentage,
          discountAmount: _discountAmount,
          specialDiscountPercentage: _effectiveSpecialDiscountPercentage,
          specialDiscountAmount: _specialDiscountAmount,
          taxableAmount: _taxableAmount,
          gstEnabled: _effectiveGstEnabled,
          gstLabel: 'GST (${_formatPercent(_effectiveGstPercentage)}%)',
          totalGst: _totalGst,
          grandTotal: _grandTotal,
        ),
      ),
    );

    return confirmed == true;
  }

  Future<void> _confirmAndCreateDispatch() async {
    if (_selectedDealer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a dealer')));
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final shouldCreate = await _showDispatchInvoicePreview();
    if (shouldCreate) {
      await _saveSale();
    }
  }

  void _resetForNewSale() {
    _clearQtyControllers();
    setState(() {
      _cart.clear();
      _selectedDealer = null;
      _selectedDriver = null;
      _selectedVehicle = null;
      _selectedRoute = null;
      _resetPricingSelections();
      _routeOrderPayload = null;
      _routeOrderPrefillApplied = true;
      _internalProductSearchController?.clear();
    });
  }

  Future<void> _saveSale() async {
    if (_selectedDealer == null || _cart.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.state.user;
      final routeOrderPayload = _routeOrderPayload;
      final isRouteOrderDispatch = routeOrderPayload != null;

      final saleId = await ServiceHandler.execute<String>(
        context,
        action: () => _salesService.createSale(
          recipientType: RecipientType.dealer.name,
          recipientId: _selectedDealer!.id,
          recipientName: _selectedDealer!.name,
          items: _cart.map((e) => e.toSaleItemForUI()).toList(),
          discountPercentage: _effectiveAdditionalDiscountPercentage,
          additionalDiscountPercentage: _effectiveSpecialDiscountPercentage,
          gstPercentage: _effectiveGstPercentage,
          gstType: _effectiveGstType,
          vehicleNumber: _selectedVehicle?.number,
          driverName: _selectedDriver?.name,
          route: _selectedRoute,
          status: 'created',
        ),
      );

      if (saleId != null) {
        if (isRouteOrderDispatch) {
          final dispatchedByIdValue = (user?.id ?? '').trim();
          final dispatchedByNameValue = (user?.name ?? '').trim();
          final dispatchedById = dispatchedByIdValue.isNotEmpty
              ? dispatchedByIdValue
              : 'system';
          final dispatchedByName = dispatchedByNameValue.isNotEmpty
              ? dispatchedByNameValue
              : 'System';
          try {
            await _routeOrderService.markOrderDispatched(
              orderId: routeOrderPayload.routeOrderId,
              dispatchId: saleId,
              dispatchedById: dispatchedById,
              dispatchedByName: dispatchedByName,
            );
          } catch (markError) {
            AppLogger.warning(
              'Dealer dispatch created but route order update failed: $markError',
              tag: 'DealerDispatch',
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

        Sale? persistedSale;
        try {
          persistedSale = await _salesService.getSale(saleId);
        } catch (_) {}

        final sale =
            persistedSale ??
            Sale(
              id: saleId,
              recipientType: 'dealer',
              recipientId: _selectedDealer!.id,
              recipientName: _selectedDealer!.name,
              items: _cart.map((e) => e.toSaleItem()).toList(),
              itemProductIds: _cart.map((e) => e.productId).toList(),
              subtotal: _grossSubtotal,
              itemDiscountAmount: _itemLevelDiscounts,
              discountPercentage: _effectiveAdditionalDiscountPercentage,
              discountAmount: _discountAmount,
              additionalDiscountPercentage: _effectiveSpecialDiscountPercentage,
              additionalDiscountAmount: _specialDiscountAmount,
              taxableAmount: _taxableAmount,
              gstType: _effectiveGstType,
              gstPercentage: _effectiveGstPercentage,
              totalAmount: _grandTotal,
              roundOff: 0.0,
              vehicleNumber: _selectedVehicle?.number,
              driverName: _selectedDriver?.name,
              route: _selectedRoute,
              salesmanId: user?.id ?? '',
              salesmanName: user?.name ?? '',
              createdAt: DateTime.now().toIso8601String(),
              month: DateTime.now().month,
              year: DateTime.now().year,
              saleType: SaleType.directDealer.name,
            );
        _queueWhatsAppInvoicePdfInBackground(
          sale: sale,
          customerName: _selectedDealer?.name ?? sale.recipientName,
          customerPhone: _selectedDealer?.mobile,
        );
        _showSuccessDialog(sale);
        if (isRouteOrderDispatch && mounted) {
          setState(() {
            _routeOrderPayload = null;
            _routeOrderPrefillApplied = true;
          });
        }
      }
    } catch (e) {
      // Handled by ServiceHandler
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog(Sale sale) {
    final theme = Theme.of(context);
    final companyProfile =
        _companyProfile ?? CompanyProfileData(name: 'Datt Soap');
    final invoiceId = sale.humanReadableId ?? sale.id;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ResponsiveAlertDialog(
        maxWidth: 560,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text('Dispatch Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dispatch created successfully!'),
            const SizedBox(height: 8),
            Text(
              'ID: $invoiceId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Saved to dispatch history. Use options below to print/share invoice PDF.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetForNewSale();
            },
            child: const Text('New Sale'),
          ),
          OutlinedButton.icon(
            onPressed: () => _runInvoiceAction(
              () => PdfGenerator.generateAndPrintSaleInvoice(
                sale,
                companyProfile,
              ),
              label: 'Print',
            ),
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Print'),
          ),
          ElevatedButton.icon(
            onPressed: () => _runInvoiceAction(
              () => PdfGenerator.shareSaleInvoice(sale, companyProfile),
              label: 'Share',
            ),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share PDF'),
          ),
        ],
      ),
    );
  }

  void _queueWhatsAppInvoicePdfInBackground({
    required Sale sale,
    required String customerName,
    required String? customerPhone,
  }) {
    final company = _companyProfile ?? CompanyProfileData(name: 'Datt Soap');
    unawaited(
      WhatsAppInvoicePipelineService.instance.enqueueInvoicePdfJob(
        sale: sale,
        companyProfile: company,
        customerName: customerName,
        customerPhone: customerPhone,
        source: 'dealer_dispatch',
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

  void _disposeControllersLater(Iterable<TextEditingController> controllers) {
    if (controllers.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
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
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    );
  }

  Widget _buildSelectionForm() {
    final theme = Theme.of(context);
    final filteredDealers = _dealersForRoute(_selectedRoute);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
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
              final fields = [
                _buildDropdownField<Dealer>(
                  'Dealer',
                  _selectedDealer,
                  filteredDealers
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
                  _onDealerChanged,
                ),
                _buildReadOnlyRouteField(),
                _buildDropdownField<AppUser>(
                  'Driver',
                  _selectedDriver,
                  _allDrivers
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
                  (val) => setState(() => _selectedDriver = val),
                ),
                _buildDropdownField<Vehicle>(
                  'Vehicle',
                  _selectedVehicle,
                  _allVehicles
                      .map(
                        (v) =>
                            DropdownMenuItem(value: v, child: Text(v.number)),
                      )
                      .toList(),
                  (val) => setState(() => _selectedVehicle = val),
                ),
              ];

              final maxWidth = constraints.maxWidth;
              final columns = maxWidth >= 900 ? 4 : 2;
              const spacing = 12.0;
              final itemWidth = (maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: fields
                    .map((field) => SizedBox(width: itemWidth, child: field))
                    .toList(),
              );
            },
          ),
          if (_selectedRoute != null) ...[
            const SizedBox(height: 12),
            Text(
              filteredDealers.isEmpty
                  ? 'No dealers are assigned to this route. Assign route in Business Partners > Dealer.'
                  : '${filteredDealers.length} dealer(s) mapped to selected route.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: filteredDealers.isEmpty
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) {
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return HoverableContainer(
              child: DropdownMenu<T>(
                key: ValueKey('${label}_${value}_${entries.length}'),
                enabled: isEnabled,
                width: constraints.maxWidth,
                initialSelection: value,
                hintText: 'Select $label',
                enableFilter: true,
                requestFocusOnTap: true,
                menuHeight: 320,
                leadingIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
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
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
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

  Widget _buildReadOnlyRouteField() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'ROUTE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        HoverableContainer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 18,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedRoute ?? 'Auto-assigned from dealer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _selectedRoute != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // LOCKED: Products already present in cart must not appear/select again.
  Iterable<Product> _availableProductsForSelection(Iterable<Product> source) {
    final cartIds = _cart
        .where((item) => !item.isFree)
        .map((item) => item.productId)
        .toSet();
    return source.where((product) => !cartIds.contains(product.id));
  }

  Widget _buildProductEntry() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 760;
          final searchField = Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
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

                    final available = _availableProductsForSelection(
                      typeFiltered,
                    );
                    if (textEditingValue.text.isEmpty) return available;
                    return available.where(
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
                    _addToCart(product);
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
                            hintText: 'Search or Select Product...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                            ),
                            border: InputBorder.none,
                            suffixIcon: controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                    ),
                                    onPressed: () => controller.clear(),
                                  )
                                : Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                          ),
                          onSubmitted: (_) {
                            onFieldSubmitted();
                            controller.clear();
                          },
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    final optionsWidth = Responsive.isMobile(context)
                        ? (Responsive.width(context) - 32).clamp(280, 560)
                        : Responsive.width(context) * 0.45;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Material(
                          elevation: 12,
                          shadowColor: theme.colorScheme.shadow.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: optionsWidth.toDouble(),
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  onTap: () => onSelected(option),
                                  hoverColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.05),
                                  title: Text(
                                    option.name.toUpperCase(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          'SKU: ${option.sku}',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (option.stock > 0
                                                        ? AppColors.success
                                                        : AppColors.error)
                                                    .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'AVAILABLE: ${option.stock.toStringAsFixed(0)} ${option.baseUnit}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: option.stock > 0
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
            ],
          );

          final filters = SingleChildScrollView(
            controller: _productFilterScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  key: _productFilterKeys['Finished'],
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip('Finished Goods', 'Finished'),
                ),
                Padding(
                  key: _productFilterKeys['Traded'],
                  padding: const EdgeInsets.only(right: 2),
                  child: _buildFilterChip('Traded Goods', 'Traded'),
                ),
              ],
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [searchField, const SizedBox(height: 10), filters],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12),
              filters,
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _productFilterType == value;
    return ThemedFilterChip(
      label: label,
      selected: isSelected,
      onSelected: () => _setProductFilterType(value),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  Widget _buildCartTable() {
    final theme = Theme.of(context);
    if (_cart.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 220),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
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
              'Dealer dispatch cart is empty',
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
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
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
          // Items
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cart.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 24,
              endIndent: 24,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final item = _cart[index];
              final amount = item.price * item.quantity;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
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
                        ],
                      ),
                    ),
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
                            : _buildQuantityInput(item, index),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          item.isFree
                              ? '-'
                              : '₹${item.price.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
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
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => _removeFromCart(index),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.5,
                            ),
                            size: 20,
                          ),
                          hoverColor: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.2),
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

  Widget _buildQuantityInput(CartItem item, int index) {
    final theme = Theme.of(context);
    final controller = _qtyControllers.putIfAbsent(
      item.productId,
      () => TextEditingController(text: item.quantity.toString()),
    );
    final targetText = item.quantity.toString();
    if (controller.text != targetText) {
      controller.value = controller.value.copyWith(
        text: targetText,
        selection: TextSelection.collapsed(offset: targetText.length),
      );
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
            _updateCartItemQty(index, qty);
          },
        ),
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

  Widget _buildSummaryAndActions() {
    final theme = Theme.of(context);
    final discountOptions = _dealerAdditionalDiscountDropdownOptions;
    final discountValue = discountOptions.contains(
      _effectiveAdditionalDiscountPercentage,
    )
        ? _effectiveAdditionalDiscountPercentage
        : discountOptions.first;
    final showPricingControls =
        _allowDealerAdditionalDiscountToggle ||
        _allowDealerSpecialDiscountToggle ||
        _allowDealerGstToggle;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showPricingControls) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_allowDealerAdditionalDiscountToggle) ...[
                        Text(
                          'ADDITIONAL DISCOUNT (%)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: Responsive.clamp(
                              context,
                              min: 96,
                              max: 140,
                              ratio: 0.2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<double>(
                                value: discountValue,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                items: discountOptions
                                    .map(
                                      (value) => DropdownMenuItem<double>(
                                        value: value,
                                        child: Center(
                                          child: Text(
                                            '${_formatPercent(value)}%',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => setState(
                                  () => _discountPercentage = value ?? 0.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_allowDealerSpecialDiscountToggle) ...[
                        SizedBox(
                          height:
                              _allowDealerAdditionalDiscountToggle ? 16 : 0,
                        ),
                        Text(
                          'SPECIAL DISCOUNT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            '${_formatPercent(_effectiveSpecialDiscountPercentage)}% default applied',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_allowDealerGstToggle) ...[
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GST ENABLED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            _effectiveGstEnabled
                                ? '${_formatPercent(_effectiveGstPercentage)}% applied'
                                : 'Tax free',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _gstEnabled,
                        onChanged: (val) => setState(() {
                          _gstEnabled = val;
                          _gstType = val ? _gstDefaultType : 'None';
                          _gstPercentage = val ? _gstDefaultPercentage : 0.0;
                        }),
                        activeTrackColor: theme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        thumbColor: WidgetStatePropertyAll(
                          _gstEnabled ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1),
            ),
          ],
          _summaryRow('SUBTOTAL (GROSS)', '₹${_grossSubtotal.toStringAsFixed(2)}'),
          if (_itemLevelDiscounts > 0) ...[
            const SizedBox(height: 12),
            _summaryRow(
              _productDiscountLabel,
              '-₹${_itemLevelDiscounts.toStringAsFixed(2)}',
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            _summaryRow(
              'DISCOUNTED SUBTOTAL',
              '\u20B9${_discountedSubtotal.toStringAsFixed(2)}',
            ),
          ],
          if (_effectiveAdditionalDiscountPercentage > 0) ...[
            const SizedBox(height: 12),
            _summaryRow(
              'ADDITIONAL DISCOUNT (${_formatPercent(_effectiveAdditionalDiscountPercentage)}%)',
              '-₹${_discountAmount.toStringAsFixed(2)}',
              color: AppColors.error,
            ),
          ],
          if (_effectiveSpecialDiscountPercentage > 0) ...[
            const SizedBox(height: 12),
            _summaryRow(
              'SPECIAL DISCOUNT (${_formatPercent(_effectiveSpecialDiscountPercentage)}%)',
              '-₹${_specialDiscountAmount.toStringAsFixed(2)}',
              color: AppColors.error,
            ),
          ],
          if (_effectiveGstEnabled) ...[
            const SizedBox(height: 12),
            _summaryRow(
              'GST (${_formatPercent(_effectiveGstPercentage)}%)',
              '₹${_totalGst.toStringAsFixed(2)}',
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _summaryRow(
            'GRAND TOTAL',
            '₹${_grandTotal.toStringAsFixed(2)}',
            isBold: true,
            fontSize: 20,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _confirmAndCreateDispatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
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
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'CONFIRM DISPATCH',
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
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 13,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: isBold ? fontSize - 3 : fontSize,
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
                color ??
                (isBold
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

class _DealerDispatchInvoicePreviewPage extends StatelessWidget {
  final String companyName;
  final String dispatchBy;
  final String dealerName;
  final String routeName;
  final String vehicleNo;
  final String driverName;
  final DateTime now;
  final List<CartItem> paidItems;
  final int totalDispatchQty;
  final double grossSubtotal;
  final double itemLevelDiscounts;
  final double discountedSubtotal;
  final String productDiscountLabel;
  final double discountPercentage;
  final double discountAmount;
  final double specialDiscountPercentage;
  final double specialDiscountAmount;
  final double taxableAmount;
  final bool gstEnabled;
  final String gstLabel;
  final double totalGst;
  final double grandTotal;

  const _DealerDispatchInvoicePreviewPage({
    required this.companyName,
    required this.dispatchBy,
    required this.dealerName,
    required this.routeName,
    required this.vehicleNo,
    required this.driverName,
    required this.now,
    required this.paidItems,
    required this.totalDispatchQty,
    required this.grossSubtotal,
    required this.itemLevelDiscounts,
    required this.discountedSubtotal,
    required this.productDiscountLabel,
    required this.discountPercentage,
    required this.discountAmount,
    required this.specialDiscountPercentage,
    required this.specialDiscountAmount,
    required this.taxableAmount,
    required this.gstEnabled,
    required this.gstLabel,
    required this.totalGst,
    required this.grandTotal,
  });

  String _currency(double amount) => 'Rs ${amount.toStringAsFixed(2)}';

  Widget _infoRow(BuildContext context, String label, String value) {
    final labelWidth = Responsive.clamp(
      context,
      min: 96,
      max: 140,
      ratio: 0.14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 320;
          final labelWidget = Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
          final valueWidget = Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 17 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelWidget,
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerRight, child: valueWidget),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: labelWidget),
              const SizedBox(width: 12),
              valueWidget,
            ],
          );
        },
      ),
    );
  }

  TableRow _headerRow(TextStyle style) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0x0DFFFFFF)),
      children: [
        _cell('Item', style, align: TextAlign.left, isHeader: true),
        _cell('Qty', style, align: TextAlign.center, isHeader: true),
        _cell('Rate', style, align: TextAlign.right, isHeader: true),
        _cell('Amount', style, align: TextAlign.right, isHeader: true),
      ],
    );
  }

  TableRow _itemRow(CartItem item, TextStyle style) {
    return TableRow(
      children: [
        _cell(item.name, style, align: TextAlign.left),
        _cell('${item.quantity}', style, align: TextAlign.center),
        _cell(_currency(item.price), style, align: TextAlign.right),
        _cell(
          _currency(item.price * item.quantity),
          style.copyWith(fontWeight: FontWeight.w600),
          align: TextAlign.right,
        ),
      ],
    );
  }

  Widget _cell(
    String value,
    TextStyle style, {
    required TextAlign align,
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        value,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isHeader
            ? style.copyWith(fontWeight: FontWeight.w700)
            : style.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle =
        theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Invoice Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dispatch Date: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _infoRow(context, 'Dispatch By', dispatchBy),
                    _infoRow(context, 'Dealer', dealerName),
                    _infoRow(context, 'Route', routeName),
                    _infoRow(context, 'Vehicle', vehicleNo),
                    _infoRow(context, 'Driver', driverName),
                    _infoRow(context, 'Total Items', '$totalDispatchQty'),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 700),
                        child: Table(
                          border: TableBorder.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.25,
                            ),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FlexColumnWidth(1.3),
                            2: FlexColumnWidth(1.7),
                            3: FlexColumnWidth(1.8),
                          },
                          children: [
                            _headerRow(bodyStyle),
                            ...paidItems.map(
                              (item) => _itemRow(item, bodyStyle),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _summaryRow('Subtotal (Gross)', _currency(grossSubtotal)),
                    if (itemLevelDiscounts > 0)
                      _summaryRow(
                        productDiscountLabel,
                        '-${_currency(itemLevelDiscounts)}',
                        valueColor: AppColors.error,
                      ),
                    if (itemLevelDiscounts > 0)
                      _summaryRow(
                        'Discounted Subtotal',
                        _currency(discountedSubtotal),
                      ),
                    if (discountAmount > 0)
                      _summaryRow(
                        'Additional Discount (${discountPercentage.toStringAsFixed(0)}%)',
                        '-${_currency(discountAmount)}',
                        valueColor: AppColors.error,
                      ),
                    if (specialDiscountAmount > 0)
                      _summaryRow(
                        'Special Discount (${specialDiscountPercentage.toStringAsFixed(0)}%)',
                        '-${_currency(specialDiscountAmount)}',
                        valueColor: AppColors.error,
                      ),
                    if ((discountedSubtotal -
                                discountAmount -
                                specialDiscountAmount -
                                taxableAmount)
                            .abs() >
                        0.0001)
                      _summaryRow('Taxable Amount', _currency(taxableAmount)),
                    if (gstEnabled)
                      _summaryRow(gstLabel, _currency(totalGst)),
                    const Divider(height: 24),
                    _summaryRow(
                      'Grand Total',
                      _currency(grandTotal),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Dispatch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
