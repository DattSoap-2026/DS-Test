import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/types/product_types.dart';
import '../../models/types/sales_types.dart';
import '../../services/dealers_service.dart';
import '../../services/products_service.dart';
import '../../services/sales_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/schemes_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../modules/hr/models/employee_model.dart';
import '../../modules/hr/services/hr_service.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/release_data_guard.dart';
import '../../utils/unit_converter.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import '../../services/whatsapp_invoice_pipeline_service.dart';

class NewDealerSaleScreen extends StatefulWidget {
  const NewDealerSaleScreen({super.key});

  @override
  State<NewDealerSaleScreen> createState() => _NewDealerSaleScreenState();
}

class _NewDealerSaleScreenState extends State<NewDealerSaleScreen> {
  // Services
  late final DealersService _dealersService;
  late final ProductsService _productsService;
  late final VehiclesService _vehiclesService;
  late final SchemesService _schemesService;
  late final SettingsService _settingsService;
  late final UsersService _usersService;
  late final HrService _hrService;

  // Data
  List<Dealer> _allDealers = [];
  List<Product> _allProducts = [];
  List<Vehicle> _allVehicles = [];
  List<AppUser> _allDrivers = [];
  List<Scheme> _allSchemes = [];
  List<String> _routes = [];
  final Map<String, String> _routeIdByName = {};
  CompanyProfileData? _companyProfile;

  // Form State
  Vehicle? _selectedVehicle;
  AppUser? _selectedDriver;
  Dealer? _selectedDealer;
  String? _selectedRoute;
  final TextEditingController _routeDropdownController =
      TextEditingController();
  bool _isProgrammaticRouteTextUpdate = false;

  // Cart
  final List<CartItem> _cart = [];
  final TextEditingController _productSearchController =
      TextEditingController();
  TextEditingController? _productAutocompleteController;
  FocusNode? _productAutocompleteFocusNode;
  Product? _selectedSearchProduct;
  String _productFilterType = ProductType.finishedGood.value;
  final Map<String, TextEditingController> _qtyControllers = {};

  // Financials
  double _additionalDiscountPercentage = 0;
  double _specialDiscountPercentage = 0;
  bool _isSpecialDiscountEnabled = false;
  String _gstType = 'None';
  double _gstPercentage = 0;

  bool _allowDealerGstToggle = true;
  bool _allowDealerAdditionalDiscountToggle = true;
  bool _allowDealerSpecialDiscountToggle = true;
  List<double> _dealerAdditionalDiscountOptions = const [2, 5, 10, 15];
  double _dealerAdditionalDiscountDefault = 5.0;
  List<double> _dealerSpecialDiscountOptions = const [1, 2, 3, 5];
  double _dealerSpecialDiscountDefault = 5.0;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dealersService = context.read<DealersService>();
    _productsService = context.read<ProductsService>();
    _vehiclesService = context.read<VehiclesService>();
    _schemesService = context.read<SchemesService>();
    _settingsService = context.read<SettingsService>();
    _usersService = context.read<UsersService>();
    _hrService = context.read<HrService>();
    _routeDropdownController.addListener(_handleRouteDropdownTextChange);
    _loadData();
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _routeDropdownController.removeListener(_handleRouteDropdownTextChange);
    _routeDropdownController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

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

  bool _isReleaseBlockedProduct(Product product) {
    return shouldHideInRelease(
      name: product.name,
      secondaryName: product.category,
      id: product.id,
      sku: product.sku,
      extra: <String?>[product.itemType.value, product.status],
    );
  }

  bool _isReleaseBlockedDealer(Dealer dealer) {
    return shouldHideInRelease(
      name: dealer.name,
      secondaryName: dealer.contactPerson,
      id: dealer.id,
      email: dealer.email,
      extra: <String?>[
        dealer.mobile,
        dealer.alternateMobile,
        dealer.assignedRouteId,
        dealer.assignedRouteName,
        dealer.territory,
      ],
    );
  }

  void _setRouteDropdownText(String? route) {
    final next = route ?? '';
    if (_routeDropdownController.text == next) {
      return;
    }
    _isProgrammaticRouteTextUpdate = true;
    _routeDropdownController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _isProgrammaticRouteTextUpdate = false;
  }

  void _handleRouteDropdownTextChange() {
    if (_isProgrammaticRouteTextUpdate) {
      return;
    }
    if (_routeDropdownController.text.trim().isNotEmpty) {
      return;
    }
    if (_selectedRoute != null) {
      _onRouteChanged(null);
    }
  }

  bool _isReleaseBlockedUser(AppUser user) {
    return shouldHideInRelease(
      name: user.name,
      secondaryName: user.department,
      id: user.id,
      email: user.email,
      extra: <String?>[
        user.phone,
        user.assignedBhatti,
        user.assignedVehicleName,
      ],
    );
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
        .where((u) => !_isReleaseBlockedUser(u))
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
        .where((u) => !_isReleaseBlockedUser(u))
        .toList();

    final deduped = _dedupeUsers(strictDrivers);
    deduped.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return deduped;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final drivers = await _loadDriverCandidates();
      final results = await Future.wait([
        _dealersService.getDealers(status: 'active'),
        _productsService.getProducts(status: 'active'),
        _vehiclesService.getVehicles(status: 'active'),
        _vehiclesService.getRoutes(),
        _schemesService.getSchemes(status: 'active'),
        _settingsService.getCompanyProfileClient(),
        _settingsService.getGeneralSettings(forceRefresh: true),
      ]);

      if (mounted) {
        final routeData = results[3] as List<Map<String, dynamic>>;
        final activeRoutes = routeData
            .where((r) => r['status'] == 'active' || r['isActive'] == true)
            .toList();
        final routeNames = <String>[];
        final routeIdByName = <String, String>{};
        for (final route in activeRoutes) {
          final name = (route['name'] ?? '').toString().trim();
          if (name.isEmpty) continue;
          routeNames.add(name);
          final id = (route['id'] ?? '').toString().trim();
          if (id.isNotEmpty) {
            routeIdByName[_normalizeRouteToken(name)] = id;
          }
        }
        routeNames.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final uniqueRouteNames = routeNames.toSet().toList();

        setState(() {
          _allDealers = (results[0] as List<Dealer>)
              .where((dealer) => !_isReleaseBlockedDealer(dealer))
              .toList();
          _allProducts = (results[1] as List<Product>)
              .where((product) => !_isReleaseBlockedProduct(product))
              .toList();
          _allVehicles = (results[2] as List<Vehicle>);
          _routeIdByName
            ..clear()
            ..addAll(routeIdByName);
          _routes = _deriveDealerMappedRoutes(uniqueRouteNames);
          _allSchemes = (results[4] as List<Scheme>);
          _allDrivers = drivers;
          final normalizedSelectedRoute = _normalizeRouteTokenOrNull(
            _selectedRoute,
          );
          if (normalizedSelectedRoute != null) {
            _selectedRoute = _routes.firstWhere(
              (route) => _normalizeRouteToken(route) == normalizedSelectedRoute,
              orElse: () => '',
            );
            if (_selectedRoute != null && _selectedRoute!.isEmpty) {
              _selectedRoute = null;
            }
          }
          _selectedDealer = _resolveDealerSelectionForRoute(
            _selectedRoute,
            previousDealer: _selectedDealer,
          );
          _companyProfile = results[5] as CompanyProfileData?;
          _applyDealerDiscountSettings(
            results[6] as GeneralSettingsData?,
            initializeValues: true,
          );
          _isLoading = false;
        });
        _setRouteDropdownText(_selectedRoute);

        if (_allDrivers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active drivers found in HR employees.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
    if (normalizedName == null) return tokens;
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

  List<String> _deriveDealerMappedRoutes(List<String> masterRouteNames) {
    final mappedRoutes = <String>{};
    for (final route in masterRouteNames) {
      final hasMappedDealer = _allDealers.any(
        (dealer) => _dealerMatchesRoute(dealer, route),
      );
      if (hasMappedDealer) {
        mappedRoutes.add(route);
      }
    }

    if (mappedRoutes.isEmpty) {
      for (final dealer in _allDealers) {
        final routeName = dealer.assignedRouteName?.trim();
        final territory = dealer.territory?.trim();
        final fallbackRoute = (routeName != null && routeName.isNotEmpty)
            ? routeName
            : ((territory != null && territory.isNotEmpty) ? territory : null);
        if (fallbackRoute == null) continue;
        mappedRoutes.add(fallbackRoute);

        final routeId = dealer.assignedRouteId?.trim();
        if (routeId != null && routeId.isNotEmpty) {
          _routeIdByName[_normalizeRouteToken(fallbackRoute)] = routeId;
        }
      }
    }

    final routes = mappedRoutes.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return routes;
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

  List<String> _routesForDealer(Dealer? dealer) {
    if (dealer == null) {
      return _routes;
    }

    final matchingRoutes =
        _routes.where((route) => _dealerMatchesRoute(dealer, route)).toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    if (matchingRoutes.isNotEmpty) {
      return matchingRoutes;
    }

    final resolvedRoute = _resolveRouteForDealer(dealer);
    return resolvedRoute == null ? _routes : <String>[resolvedRoute];
  }

  void _onRouteChanged(String? route) {
    setState(() {
      _selectedRoute = route;
      _selectedDealer = _resolveDealerSelectionForRoute(
        route,
        previousDealer: _selectedDealer,
      );
    });
    _setRouteDropdownText(_selectedRoute);
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
    _setRouteDropdownText(_selectedRoute);
  }

  bool _isFinishedGood(Product product) {
    return product.itemType.value == ProductType.finishedGood.value ||
        product.type == ProductTypeEnum.finished;
  }

  bool _isTradedGood(Product product) {
    return product.itemType.value == ProductType.tradedGood.value ||
        product.type == ProductTypeEnum.traded;
  }

  String _productStockLabel(Product product) {
    final hasDual = UnitConverter.hasSecondaryUnit(
      product.secondaryUnit,
      product.conversionFactor,
    );
    if (!hasDual) {
      return '${product.stock.toInt()} ${product.baseUnit}';
    }
    return UnitConverter.formatDual(
      baseQty: product.stock,
      baseUnit: product.baseUnit,
      secondaryUnit: product.secondaryUnit,
      conversionFactor: product.conversionFactor,
    );
  }

  String _cartStockLabel(CartItem item) {
    final availableBaseQty = (item.salesmanStock ?? item.stock).toDouble();
    final hasDual = UnitConverter.hasSecondaryUnit(
      item.secondaryUnit,
      item.conversionFactor ?? 1.0,
    );
    if (!hasDual) {
      return '${availableBaseQty.toInt()} ${item.baseUnit}';
    }
    return UnitConverter.formatDual(
      baseQty: availableBaseQty,
      baseUnit: item.baseUnit,
      secondaryUnit: item.secondaryUnit,
      conversionFactor: item.conversionFactor ?? 1.0,
    );
  }

  List<Product> _searchableProductsForFilter() {
    if (_productFilterType == ProductType.tradedGood.value) {
      return _allProducts.where(_isTradedGood).toList();
    }
    return _allProducts.where(_isFinishedGood).toList();
  }

  void _onProductFilterChanged(String filterType) {
    if (_productFilterType == filterType) return;
    setState(() {
      _productFilterType = filterType;
      if (_selectedSearchProduct != null) {
        final selected = _selectedSearchProduct!;
        final isValidForFilter = filterType == ProductType.tradedGood.value
            ? _isTradedGood(selected)
            : _isFinishedGood(selected);
        if (!isValidForFilter) {
          _clearProductSearchSelection();
        }
      }
    });
  }

  double _sanitizeDiscount(double? value) {
    return (value ?? 0).clamp(0.0, 100.0);
  }

  double _clampDiscount(double value) {
    return value.clamp(0.0, 100.0).toDouble();
  }

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
      values.addAll(fallback.where((e) => e > 0));
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

  void _applyDealerDiscountSettings(
    GeneralSettingsData? settings, {
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

    if (!_allowDealerGstToggle) {
      _gstType = 'None';
      _gstPercentage = 0.0;
    } else if (initializeValues) {
      if (_gstType.isEmpty) _gstType = 'None';
      _gstPercentage = _clampDiscount(_gstPercentage);
    }

    if (!_allowDealerAdditionalDiscountToggle) {
      _additionalDiscountPercentage = 0.0;
    } else if (initializeValues) {
      _additionalDiscountPercentage = _normalizeDiscountSelection(
        _additionalDiscountPercentage > 0
            ? _additionalDiscountPercentage
            : _dealerAdditionalDiscountDefault,
        _dealerAdditionalDiscountOptions,
      );
    }

    if (!_allowDealerSpecialDiscountToggle) {
      _isSpecialDiscountEnabled = false;
      _specialDiscountPercentage = _normalizeDiscountSelection(
        _dealerSpecialDiscountDefault,
        _dealerSpecialDiscountOptions,
      );
    } else if (initializeValues) {
      _specialDiscountPercentage = _normalizeDiscountSelection(
        _specialDiscountPercentage > 0
            ? _specialDiscountPercentage
            : _dealerSpecialDiscountDefault,
        _dealerSpecialDiscountOptions,
      );
    }
  }

  void _onDealerGstToggleChanged(bool enabled) {
    if (!_allowDealerGstToggle) return;
    setState(() {
      if (enabled) {
        if (_gstType == 'None') {
          _gstType = 'CGST+SGST';
        }
        if (_gstPercentage <= 0) {
          _gstPercentage = 5.0;
        }
      } else {
        _gstType = 'None';
        _gstPercentage = 0.0;
      }
    });
  }

  void _onDealerAdditionalToggleChanged(bool enabled) {
    if (!_allowDealerAdditionalDiscountToggle) return;
    setState(() {
      if (enabled) {
        _additionalDiscountPercentage = _normalizeDiscountSelection(
          _additionalDiscountPercentage > 0
              ? _additionalDiscountPercentage
              : _dealerAdditionalDiscountDefault,
          _dealerAdditionalDiscountOptions,
        );
      } else {
        _additionalDiscountPercentage = 0.0;
      }
    });
  }

  void _onDealerSpecialToggleChanged(bool enabled) {
    if (!_allowDealerSpecialDiscountToggle) return;
    setState(() {
      _isSpecialDiscountEnabled = enabled;
      if (enabled) {
        _specialDiscountPercentage = _normalizeDiscountSelection(
          _specialDiscountPercentage > 0
              ? _specialDiscountPercentage
              : _dealerSpecialDiscountDefault,
          _dealerSpecialDiscountOptions,
        );
      } else {
        _specialDiscountPercentage = 0.0;
      }
    });
  }

  String _qtyControllerKey(CartItem item) => '${item.productId}_${item.isFree}';

  TextEditingController _quantityControllerFor(CartItem item) {
    final key = _qtyControllerKey(item);
    final controller = _qtyControllers.putIfAbsent(
      key,
      () => TextEditingController(text: item.quantity.toString()),
    );
    final targetText = item.quantity.toString();
    if (controller.text != targetText) {
      controller.value = controller.value.copyWith(
        text: targetText,
        selection: TextSelection.collapsed(offset: targetText.length),
      );
    }
    return controller;
  }

  void _removeQtyController(CartItem item) {
    final controller = _qtyControllers.remove(_qtyControllerKey(item));
    controller?.dispose();
  }

  void _commitManualQty(int index, String rawQty) {
    final qty = int.tryParse(rawQty.trim()) ?? 0;
    _updateCartQty(index, qty);
  }

  Widget _buildProductTypeButton(String label, String value, ThemeData theme) {
    return ChoiceChip(
      label: Text(label),
      selected: _productFilterType == value,
      onSelected: (_) => _onProductFilterChanged(value),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.25,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _productFilterType == value
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: _productFilterType == value
            ? theme.colorScheme.primary.withValues(alpha: 0.45)
            : theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
    );
  }

  void _clearProductSearchSelection({bool unfocus = false}) {
    _selectedSearchProduct = null;
    _productSearchController.clear();
    _productAutocompleteController?.clear();
    if (unfocus) {
      _productAutocompleteFocusNode?.unfocus();
    }
  }

  void _addToCart({Product? selectedProduct}) {
    final product = selectedProduct ?? _selectedSearchProduct;
    if (product == null) return;

    final existingIndex = _cart.indexWhere(
      (item) => item.productId == product.id && !item.isFree,
    );
    if (existingIndex != -1) {
      _updateCartQty(existingIndex, _cart[existingIndex].quantity + 1);
    } else {
      setState(() {
        _cart.add(
          CartItem(
            productId: product.id,
            name: product.name,
            quantity: 1,
            price: product.price,
            baseUnit: product.baseUnit,
            stock: product.stock.toInt(),
            isFree: false,
            discount: _sanitizeDiscount(product.defaultDiscount),
          ),
        );
        _applySchemes();
      });
    }
    setState(() => _clearProductSearchSelection(unfocus: true));
  }

  void _updateCartQty(int index, int qty) {
    if (qty <= 0) {
      setState(() {
        final removed = _cart.removeAt(index);
        if (!removed.isFree) {
          _removeQtyController(removed);
        }
        _applySchemes();
      });
      return;
    }
    setState(() {
      _cart[index] = _cart[index].copyWith(quantity: qty);
      _applySchemes();
    });
  }

  void _applySchemes() {
    _cart.removeWhere((item) => item.isFree);

    if (_allProducts.isEmpty) {
      return;
    }

    List<CartItem> newFreeItems = [];
    Map<String, double> productQuantities = {};
    for (var item in _cart) {
      if (!item.isFree) {
        productQuantities[item.productId] =
            (productQuantities[item.productId] ?? 0) + item.quantity;
      }
    }

    for (var scheme in _allSchemes) {
      final buyQty = productQuantities[scheme.buyProductId];
      if (buyQty != null && buyQty >= scheme.buyQuantity) {
        final timesQualified = (buyQty / scheme.buyQuantity).floor();
        final freeQty = timesQualified * scheme.getQuantity;
        final matchingProducts = _allProducts
            .where((p) => p.id == scheme.getProductId)
            .toList();
        if (matchingProducts.isEmpty) {
          continue;
        }
        final freeProduct = matchingProducts.first;
        if (freeQty > 0) {
          newFreeItems.add(
            CartItem(
              productId: freeProduct.id,
              name: freeProduct.name,
              quantity: freeQty.toInt(),
              price: 0,
              isFree: true,
              baseUnit: freeProduct.baseUnit,
              stock: 9999,
              schemeName: scheme.name,
              discount: 0,
            ),
          );
        }
      }
    }
    setState(() {
      _cart.addAll(newFreeItems);
    });
  }

  double get _grossSubtotal =>
      _cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _itemDiscounts => _cart.fold(
    0,
    (sum, item) => sum + (item.price * item.quantity * (item.discount / 100)),
  );
  double get _subtotalAfterItemDisc => _grossSubtotal - _itemDiscounts;
  double get _additionalDiscountAmount =>
      _subtotalAfterItemDisc * (_additionalDiscountPercentage / 100);
  double get _subtotalAfterAdditionalDisc =>
      _subtotalAfterItemDisc - _additionalDiscountAmount;
  double get _effectiveSpecialDiscountPercentage =>
      _isSpecialDiscountEnabled ? _specialDiscountPercentage : 0;
  double get _specialDiscountAmount =>
      _subtotalAfterAdditionalDisc *
      (_effectiveSpecialDiscountPercentage / 100);
  double get _taxableAmount =>
      _subtotalAfterAdditionalDisc - _specialDiscountAmount;
  double get _totalGst {
    if (_gstType == 'None' || _gstPercentage <= 0) return 0;
    return _taxableAmount * (_gstPercentage / 100);
  }

  double get _cgstAmount =>
      _gstType == 'CGST+SGST' ? _round2(_totalGst / 2) : 0;
  double get _sgstAmount =>
      _gstType == 'CGST+SGST' ? _round2(_totalGst - _cgstAmount) : 0;
  double get _igstAmount => _gstType == 'IGST' ? _round2(_totalGst) : 0;
  double get _grandTotal => _taxableAmount + _totalGst;

  double _round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  int get _totalDispatchQty => _cart
      .where((item) => !item.isFree)
      .fold(0, (sum, item) => sum + item.quantity);

  Future<bool> _showDispatchInvoicePreview() async {
    final authProvider = context.read<AuthProvider>();
    final dispatcherName = authProvider.currentUser?.name.trim();
    final dispatchBy = (dispatcherName == null || dispatcherName.isEmpty)
        ? 'System'
        : dispatcherName;
    final companyName = _companyProfile?.name?.trim().isNotEmpty == true
        ? _companyProfile!.name!.trim()
        : 'Datt Soap';
    final now = DateTime.now();
    final dealerName = _selectedDealer?.name ?? 'N/A';
    final routeName =
        _selectedRoute ??
        _selectedDealer?.assignedRouteName ??
        _selectedDealer?.territory ??
        'N/A';
    final vehicleNo = _selectedVehicle?.number ?? 'N/A';
    final driverName = _selectedDriver?.name ?? 'N/A';
    final paidItems = _cart
        .where((item) => !item.isFree)
        .toList(growable: false);

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _DealerDispatchInvoicePreviewPage(
          companyName: companyName,
          dispatchBy: dispatchBy,
          dealerName: dealerName,
          routeName: routeName,
          vehicleNo: vehicleNo,
          driverName: driverName,
          now: now,
          paidItems: paidItems,
          totalDispatchQty: _totalDispatchQty,
          grossSubtotal: _grossSubtotal,
          itemDiscounts: _itemDiscounts,
          additionalDiscountPercentage: _additionalDiscountPercentage,
          additionalDiscountAmount: _additionalDiscountAmount,
          isSpecialDiscountEnabled: _isSpecialDiscountEnabled,
          specialDiscountPercentage: _specialDiscountPercentage,
          specialDiscountAmount: _specialDiscountAmount,
          taxableAmount: _taxableAmount,
          gstType: _gstType,
          gstPercentage: _gstPercentage,
          totalGst: _totalGst,
          cgstAmount: _cgstAmount,
          sgstAmount: _sgstAmount,
          igstAmount: _igstAmount,
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
      await _createDispatch();
    }
  }

  Future<void> _createDispatch() async {
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

    setState(() => _isSaving = true);
    try {
      final salesService = context.read<SalesService>();
      final authProvider = context.read<AuthProvider>();
      final now = DateTime.now();

      final saleId = await salesService.createSale(
        recipientType: RecipientType.dealer.name,
        recipientId: _selectedDealer!.id,
        recipientName: _selectedDealer!.name,
        items: _cart.map((e) => e.toSaleItemForUI()).toList(),
        discountPercentage: _additionalDiscountPercentage,
        additionalDiscountPercentage: _effectiveSpecialDiscountPercentage,
        gstPercentage: _gstType == 'None' ? 0.0 : _gstPercentage,
        gstType: _gstType,
        route:
            _selectedRoute ??
            _selectedDealer!.assignedRouteName ??
            _selectedDealer!.territory,
        vehicleNumber: _selectedVehicle?.number,
        driverName: _selectedDriver?.name,
        saleType: SaleType.directDealer.name, // Added
        dispatchRequired: true, // Added
        status: SaleStatus.created.value, // Added
        createdByRole: authProvider.currentUser?.role.value, // Added
      );

      if (!mounted) return;
      Sale? persistedSale;
      try {
        persistedSale = await salesService.getSale(saleId);
      } catch (_) {}

      final sale =
          persistedSale ??
          Sale(
            id: saleId,
            recipientType: RecipientType.dealer.name,
            recipientId: _selectedDealer!.id,
            recipientName: _selectedDealer!.name,
            items: _cart.map((e) => e.toSaleItem()).toList(),
            itemProductIds: _cart.map((e) => e.productId).toList(),
            subtotal: _grossSubtotal,
            itemDiscountAmount: _itemDiscounts,
            discountPercentage: _additionalDiscountPercentage,
            discountAmount: _additionalDiscountAmount,
            additionalDiscountPercentage: _effectiveSpecialDiscountPercentage,
            additionalDiscountAmount: _specialDiscountAmount,
            taxableAmount: _taxableAmount,
            gstType: _gstType,
            gstPercentage: _gstType == 'None' ? 0.0 : _gstPercentage,
            cgstAmount: _cgstAmount,
            sgstAmount: _sgstAmount,
            igstAmount: _igstAmount,
            totalAmount: _grandTotal,
            roundOff: 0.0,
            saleType: SaleType.directDealer.name,
            createdByRole: authProvider.currentUser?.role.value,
            status: SaleStatus.created.value,
            dispatchRequired: true,
            vehicleNumber: _selectedVehicle?.number,
            driverName: _selectedDriver?.name,
            route:
                _selectedRoute ??
                _selectedDealer?.assignedRouteName ??
                _selectedDealer?.territory,
            salesmanId: authProvider.currentUser?.id ?? '',
            salesmanName: authProvider.currentUser?.name ?? '',
            createdAt: now.toIso8601String(),
            month: now.month,
            year: now.year,
          );

      _queueWhatsAppInvoicePdfInBackground(
        sale: sale,
        customerName: _selectedDealer?.name ?? sale.recipientName,
        customerPhone: _selectedDealer?.mobile,
      );
      if (!mounted) return;
      _showSuccessDialog(sale);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Let MainScaffold handle background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliveryDetails(),
            const SizedBox(height: 24),
            _buildRecipientDetails(),
            const SizedBox(height: 24),
            _buildProductSection(),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Delivery Details',
          'Select vehicle and driver for this sale',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildStyledDropdown<Vehicle>(
                      'Vehicle',
                      'Select vehicle...',
                      _selectedVehicle,
                      _allVehicles
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(v.number),
                            ),
                          )
                          .toList(),
                      (val) => setState(() => _selectedVehicle = val),
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDropdown<AppUser>(
                      'Driver',
                      'Select driver...',
                      _selectedDriver,
                      _allDrivers
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                d.phone != null && d.phone!.trim().isNotEmpty
                                    ? '${d.name} (${d.phone})'
                                    : d.name,
                              ),
                            ),
                          )
                          .toList(),
                      (val) => setState(() => _selectedDriver = val),
                      context: context,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildStyledDropdown<Vehicle>(
                      'Vehicle',
                      'Select vehicle...',
                      _selectedVehicle,
                      _allVehicles
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(v.number),
                            ),
                          )
                          .toList(),
                      (val) => setState(() => _selectedVehicle = val),
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildStyledDropdown<AppUser>(
                      'Driver',
                      'Select driver...',
                      _selectedDriver,
                      _allDrivers
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                d.phone != null && d.phone!.trim().isNotEmpty
                                    ? '${d.name} (${d.phone})'
                                    : d.name,
                              ),
                            ),
                          )
                          .toList(),
                      (val) => setState(() => _selectedDriver = val),
                      context: context,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientDetails() {
    final theme = Theme.of(context);
    final filteredDealers = _dealersForRoute(_selectedRoute);
    final filteredRoutes = _routesForDealer(_selectedDealer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recipient Details'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _buildStyledDropdown<String>(
                          'Route',
                          'Select a route...',
                          _selectedRoute,
                          filteredRoutes
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                          _onRouteChanged,
                          controller: _routeDropdownController,
                          context: context,
                        ),
                        const SizedBox(height: 12),
                        _buildStyledDropdown<Dealer>(
                          'Dealer',
                          'Select a dealer...', // Hint
                          _selectedDealer,
                          filteredDealers
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('${d.name} (${d.contactPerson})'),
                                ),
                              )
                              .toList(),
                          _onDealerChanged,
                          hideLabel: true,
                          context: context,
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildStyledDropdown<String>(
                          'Route',
                          'Select a route...',
                          _selectedRoute,
                          filteredRoutes
                              .map(
                                (r) =>
                                    DropdownMenuItem(value: r, child: Text(r)),
                              )
                              .toList(),
                          _onRouteChanged,
                          controller: _routeDropdownController,
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStyledDropdown<Dealer>(
                          'Dealer',
                          'Select a dealer...', // Hint
                          _selectedDealer,
                          filteredDealers
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('${d.name} (${d.contactPerson})'),
                                ),
                              )
                              .toList(),
                          _onDealerChanged,
                          hideLabel: true,
                          context: context,
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (_selectedRoute != null) ...[
                const SizedBox(height: 10),
                Text(
                  filteredDealers.isEmpty
                      ? 'No dealers mapped to this route.'
                      : '${filteredDealers.length} dealer(s) available for selected route.',
                  style: TextStyle(
                    fontSize: 12,
                    color: filteredDealers.isEmpty
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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

  void _resetForNewSale() {
    setState(() {
      for (final controller in _qtyControllers.values) {
        controller.dispose();
      }
      _qtyControllers.clear();
      _cart.clear();
      _selectedDealer = null;
      _selectedDriver = null;
      _selectedVehicle = null;
      _selectedRoute = null;
      _gstType = 'None';
      _gstPercentage = 0.0;
      _additionalDiscountPercentage = _allowDealerAdditionalDiscountToggle
          ? _normalizeDiscountSelection(
              _dealerAdditionalDiscountDefault,
              _dealerAdditionalDiscountOptions,
            )
          : 0.0;
      _specialDiscountPercentage = _allowDealerSpecialDiscountToggle
          ? _normalizeDiscountSelection(
              _dealerSpecialDiscountDefault,
              _dealerSpecialDiscountOptions,
            )
          : 0.0;
      _isSpecialDiscountEnabled = false;
      _clearProductSearchSelection();
    });
    _setRouteDropdownText(null);
  }

  void _showSuccessDialog(Sale sale) {
    final companyProfile =
        _companyProfile ?? CompanyProfileData(name: 'Datt Soap');
    final invoiceId = sale.humanReadableId ?? sale.id;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 56,
            ),
            const SizedBox(height: 12),
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
        source: 'new_dealer_sale',
      ),
    );
  }

  Widget _buildProductSection() {
    final theme = Theme.of(context);
    final filteredProducts = _searchableProductsForFilter();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final searchField = Autocomplete<Product>(
                key: ValueKey('product_search_$_productFilterType'),
                displayStringForOption: (option) => option.name,
                optionsBuilder: (textEditingValue) {
                  final query = textEditingValue.text.trim().toLowerCase();
                  if (query.isEmpty) return filteredProducts;
                  return filteredProducts.where(
                    (p) =>
                        p.name.toLowerCase().contains(query) ||
                        p.sku.toLowerCase().contains(query),
                  );
                },
                onSelected: (product) {
                  _addToCart(selectedProduct: product);
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      _productAutocompleteController = controller;
                      _productAutocompleteFocusNode = focusNode;
                      if (controller.text.isEmpty &&
                          _selectedSearchProduct == null) {
                        _productSearchController.text = '';
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration:
                            _inputDecoration(
                              context,
                              'Search for a product...',
                            ).copyWith(
                              suffixIcon: Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  final optionList = options.toList(growable: false);
                  if (optionList.isEmpty) return const SizedBox.shrink();

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: constraints.maxWidth,
                        constraints: const BoxConstraints(maxHeight: 320),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: optionList.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final option = optionList[index];
                            final hasDual = UnitConverter.hasSecondaryUnit(
                              option.secondaryUnit,
                              option.conversionFactor,
                            );
                            final stockLabel = _productStockLabel(option);
                            final isInStock = option.stock > 0;
                            return ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -2),
                              title: Text(
                                option.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'SKU: ${option.sku} | ₹${option.price.toStringAsFixed(2)}/${option.baseUnit}'
                                    '${hasDual && option.secondaryPrice != null ? ' | ₹${option.secondaryPrice!.toStringAsFixed(2)}/${option.secondaryUnit}' : ''}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Stock: $stockLabel',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isInStock
                                          ? AppColors.success
                                          : theme.colorScheme.error,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.add_circle_outline_rounded,
                                color: isInStock
                                    ? AppColors.success
                                    : theme.colorScheme.error.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );

              if (constraints.maxWidth < 860) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildProductTypeButton(
                          'Finished Good',
                          ProductType.finishedGood.value,
                          theme,
                        ),
                        _buildProductTypeButton(
                          'Traded Good',
                          ProductType.tradedGood.value,
                          theme,
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  _buildProductTypeButton(
                    'Finished Good',
                    ProductType.finishedGood.value,
                    theme,
                  ),
                  const SizedBox(width: 8),
                  _buildProductTypeButton(
                    'Traded Good',
                    ProductType.tradedGood.value,
                    theme,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: Tap a product from search results to add it directly to cart.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 16),

          if (_cart.isEmpty)
            Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No Data',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Please add products to cart.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          else
            _buildCartTable(),
        ],
      ),
    );
  }

  Widget _buildCartTable() {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile Card View
          return Column(
            children: _cart.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.isFree)
                                  Text(
                                    item.schemeName ?? 'Free',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (!item.isFree && item.discount > 0)
                                  Text(
                                    'Default discount: ${item.discount.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                Text(
                                  'Stock: ${_cartStockLabel(item)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!item.isFree)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AppColors.error,
                              ),
                              onPressed: () => _updateCartQty(index, 0),
                            ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuantityControl(item, index, compact: true),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${item.price}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        // Desktop/Tablet Table View
        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
              ),
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('')),
              ],
              rows: _cart.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (item.isFree)
                            Text(
                              item.schemeName ?? 'Free',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                              ),
                            ),
                          if (!item.isFree && item.discount > 0)
                            Text(
                              'Default ${item.discount.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            'Stock: ${_cartStockLabel(item)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(_buildQuantityControl(item, index)),
                    DataCell(Text('₹${item.price}')),
                    DataCell(
                      Text(
                        '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                      ),
                    ),
                    DataCell(
                      item.isFree
                          ? const SizedBox()
                          : IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: AppColors.error,
                              ),
                              onPressed: () => _updateCartQty(index, 0),
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityControl(
    CartItem item,
    int index, {
    bool compact = false,
  }) {
    if (item.isFree) {
      return Text(
        'Qty: ${item.quantity}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    final controller = _quantityControllerFor(item);
    final iconSize = compact ? 18.0 : 16.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, size: iconSize),
          visualDensity: VisualDensity.compact,
          onPressed: () => _updateCartQty(index, item.quantity - 1),
        ),
        SizedBox(
          width: 84,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: '00000',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onChanged: (value) {
              if (value.trim().isEmpty) return;
              final parsed = int.tryParse(value);
              if (parsed == null || parsed <= 0) return;
              _updateCartQty(index, parsed);
            },
            onSubmitted: (value) => _commitManualQty(index, value),
            onTapOutside: (_) {
              _commitManualQty(index, controller.text);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, size: iconSize),
          visualDensity: VisualDensity.compact,
          onPressed: () => _updateCartQty(index, item.quantity + 1),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final theme = Theme.of(context);
    final gstEnabled = _gstType != 'None' && _gstPercentage > 0;
    final additionalEnabled = _additionalDiscountPercentage > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Controls',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildControlToggleChip(
                context: context,
                label: 'GST',
                enabled: gstEnabled,
                locked: !_allowDealerGstToggle,
                onChanged: _onDealerGstToggleChanged,
              ),
              _buildControlToggleChip(
                context: context,
                label: 'Additional',
                enabled: additionalEnabled,
                locked: !_allowDealerAdditionalDiscountToggle,
                onChanged: _onDealerAdditionalToggleChanged,
              ),
              _buildControlToggleChip(
                context: context,
                label: 'Special',
                enabled: _isSpecialDiscountEnabled,
                locked: !_allowDealerSpecialDiscountToggle,
                onChanged: _onDealerSpecialToggleChanged,
              ),
            ],
          ),
          if (gstEnabled) ...[
            const SizedBox(height: 12),
            _buildGstControls(context),
          ],
          if (additionalEnabled) ...[
            const SizedBox(height: 12),
            _buildDiscountSelector(
              context: context,
              label: 'Additional Discount (%)',
              value: _additionalDiscountPercentage,
              options: _dealerAdditionalDiscountOptions,
              onChanged: (val) =>
                  setState(() => _additionalDiscountPercentage = val),
              enabled: _allowDealerAdditionalDiscountToggle,
            ),
          ],
          if (_isSpecialDiscountEnabled) ...[
            const SizedBox(height: 12),
            _buildDiscountSelector(
              context: context,
              label: 'Special Discount (%)',
              value: _specialDiscountPercentage,
              options: _dealerSpecialDiscountOptions,
              onChanged: (val) =>
                  setState(() => _specialDiscountPercentage = val),
              enabled: _allowDealerSpecialDiscountToggle,
            ),
          ],
          const Divider(height: 32),
          _buildTotalRow(
            'Subtotal (Gross):',
            '₹${_grossSubtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          if (_itemDiscounts > 0) ...[
            _buildTotalRow(
              'Default Discount:',
              '-₹${_itemDiscounts.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
          ],
          if (_additionalDiscountAmount > 0) ...[
            _buildTotalRow(
              'Additional Discount (${_additionalDiscountPercentage.toStringAsFixed(0)}%):',
              '-₹${_additionalDiscountAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
          ],
          if (_isSpecialDiscountEnabled && _specialDiscountAmount > 0) ...[
            _buildTotalRow(
              'Special Discount (${_specialDiscountPercentage.toStringAsFixed(0)}%):',
              '-₹${_specialDiscountAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
          ],
          _buildTotalRow(
            'Taxable Value:',
            '₹${_taxableAmount.toStringAsFixed(2)}',
          ),
          if (_gstType == 'CGST+SGST' && _gstPercentage > 0) ...[
            const SizedBox(height: 8),
            _buildTotalRow(
              'CGST (${(_gstPercentage / 2).toStringAsFixed(2)}%):',
              '₹${_cgstAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildTotalRow(
              'SGST (${(_gstPercentage / 2).toStringAsFixed(2)}%):',
              '₹${_sgstAmount.toStringAsFixed(2)}',
            ),
          ],
          if (_gstType == 'IGST' && _gstPercentage > 0) ...[
            const SizedBox(height: 8),
            _buildTotalRow(
              'IGST (${_gstPercentage.toStringAsFixed(2)}%):',
              '₹${_igstAmount.toStringAsFixed(2)}',
            ),
          ],
          if (_totalGst > 0) const SizedBox(height: 8),
          _buildTotalRow(
            'Grand Total:',
            '₹${_grandTotal.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _confirmAndCreateDispatch,
              icon: _isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isSaving ? 'Processing...' : 'Create Dispatch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSelector({
    required BuildContext context,
    required String label,
    required double value,
    required List<double> options,
    required ValueChanged<double> onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final normalizedOptions =
        options
            .where((e) => e >= 0 && e <= 100)
            .map((e) => e.toDouble())
            .toSet()
            .toList()
          ..sort();
    final selectable = normalizedOptions.isEmpty
        ? <double>[0, 5]
        : normalizedOptions;
    final selected = selectable.contains(value) ? value : selectable.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: Responsive.clamp(context, min: 110, max: 140, ratio: 0.16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: enabled ? 0.3 : 0.18,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              value: selected,
              dropdownColor: theme.cardTheme.color,
              items: selectable
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e % 1 == 0
                            ? '${e.toInt()}%'
                            : '${e.toStringAsFixed(2)}%',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (val) {
                      if (val == null) return;
                      onChanged(val);
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlToggleChip({
    required BuildContext context,
    required String label,
    required bool enabled,
    required bool locked,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: locked
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          Switch(value: enabled, onChanged: locked ? null : onChanged),
        ],
      ),
    );
  }

  Widget _buildGstControls(BuildContext context) {
    final selectedType = _gstType == 'None' ? 'CGST+SGST' : _gstType;
    final rateOptions = <double>{5, 12, 18, 28};
    if (_gstPercentage > 0) rateOptions.add(_gstPercentage);
    final rates = rateOptions.toList()..sort();
    final selectedRate = rates.contains(_gstPercentage) && _gstPercentage > 0
        ? _gstPercentage
        : rates.first;

    final typeField = DropdownButtonFormField<String>(
      initialValue: selectedType,
      decoration: const InputDecoration(
        labelText: 'GST Method',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        'CGST+SGST',
        'IGST',
      ].map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
      onChanged: _allowDealerGstToggle
          ? (value) {
              if (value == null) return;
              setState(() => _gstType = value);
            }
          : null,
    );

    final rateField = DropdownButtonFormField<double>(
      initialValue: selectedRate,
      decoration: const InputDecoration(
        labelText: 'GST %',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: rates
          .map(
            (e) => DropdownMenuItem<double>(
              value: e,
              child: Text(
                e % 1 == 0 ? '${e.toInt()}%' : '${e.toStringAsFixed(2)}%',
              ),
            ),
          )
          .toList(),
      onChanged: _allowDealerGstToggle
          ? (value) {
              if (value == null) return;
              setState(() => _gstPercentage = value);
            }
          : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [typeField, const SizedBox(height: 10), rateField],
          );
        }
        return Row(
          children: [
            Expanded(child: typeField),
            const SizedBox(width: 12),
            Expanded(child: rateField),
          ],
        );
      },
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, [String? subtitle]) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null && subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        fontSize: 13,
      ),
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildStyledDropdown<T>(
    String label,
    String hint,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged, {
    bool hideLabel = false,
    TextEditingController? controller,
    required BuildContext context,
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
        if (!hideLabel) ...[
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<T>(
              key: ValueKey('${label}_${value}_${entries.length}'),
              enabled: isEnabled,
              width: constraints.maxWidth,
              controller: controller,
              initialSelection: value,
              hintText: hint,
              enableFilter: true,
              requestFocusOnTap: true,
              menuHeight: 300,
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
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
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
                    borderRadius: BorderRadius.circular(14),
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
  final double itemDiscounts;
  final double additionalDiscountPercentage;
  final double additionalDiscountAmount;
  final bool isSpecialDiscountEnabled;
  final double specialDiscountPercentage;
  final double specialDiscountAmount;
  final double taxableAmount;
  final String gstType;
  final double gstPercentage;
  final double totalGst;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
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
    required this.itemDiscounts,
    required this.additionalDiscountPercentage,
    required this.additionalDiscountAmount,
    required this.isSpecialDiscountEnabled,
    required this.specialDiscountPercentage,
    required this.specialDiscountAmount,
    required this.taxableAmount,
    required this.gstType,
    required this.gstPercentage,
    required this.totalGst,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.grandTotal,
  });

  String _currency(double value) => '₹${value.toStringAsFixed(2)}';

  TableRow _itemHeaderRow(TextStyle style) {
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

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 17 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
                      'Dispatch Date: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _infoRow('Dispatch By', dispatchBy),
                    _infoRow('Dealer', dealerName),
                    _infoRow('Route', routeName),
                    _infoRow('Vehicle', vehicleNo),
                    _infoRow('Driver', driverName),
                    _infoRow('Total Items', '$totalDispatchQty'),
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
                            _itemHeaderRow(bodyStyle),
                            ...paidItems.map(
                              (item) => _itemRow(item, bodyStyle),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _summaryRow('Subtotal', _currency(grossSubtotal)),
                    if (itemDiscounts > 0)
                      _summaryRow(
                        'Default Discount',
                        '-${_currency(itemDiscounts)}',
                      ),
                    if (additionalDiscountAmount > 0)
                      _summaryRow(
                        'Additional Discount (${additionalDiscountPercentage.toStringAsFixed(0)}%)',
                        '-${_currency(additionalDiscountAmount)}',
                      ),
                    if (isSpecialDiscountEnabled && specialDiscountAmount > 0)
                      _summaryRow(
                        'Special Discount (${specialDiscountPercentage.toStringAsFixed(0)}%)',
                        '-${_currency(specialDiscountAmount)}',
                      ),
                    _summaryRow('Taxable Value', _currency(taxableAmount)),
                    if (gstType == 'CGST+SGST' && gstPercentage > 0) ...[
                      _summaryRow(
                        'CGST (${(gstPercentage / 2).toStringAsFixed(2)}%)',
                        _currency(cgstAmount),
                      ),
                      _summaryRow(
                        'SGST (${(gstPercentage / 2).toStringAsFixed(2)}%)',
                        _currency(sgstAmount),
                      ),
                    ],
                    if (gstType == 'IGST' && gstPercentage > 0)
                      _summaryRow(
                        'IGST (${gstPercentage.toStringAsFixed(2)}%)',
                        _currency(igstAmount),
                      ),
                    if (totalGst > 0)
                      _summaryRow('Total GST', _currency(totalGst)),
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
