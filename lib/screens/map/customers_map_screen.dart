import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/customers_service.dart'; // For Customer model
import '../../data/repositories/customer_repository.dart';
import '../../services/vehicles_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../constants/role_access_matrix.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';

class CustomersMapScreen extends StatefulWidget {
  const CustomersMapScreen({super.key});

  @override
  State<CustomersMapScreen> createState() => _CustomersMapScreenState();
}

class _CustomersMapScreenState extends State<CustomersMapScreen> {
  static const LatLng _defaultMapCenter = LatLng(20.5937, 78.9629);
  static const double _defaultMapZoom = 5.8;
  static const double _minMapZoom = 3.2;
  static const double _maxMapZoom = 18.0;

  List<Customer> _customers = [];
  List<String> _routes = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  String _searchQuery = '';
  String _selectedRoute = 'All';
  final Map<String, String> _routeIdByName = {};
  final Map<String, String> _routeNameById = {};

  AuthProvider? _tryAuthProvider({bool listen = false}) {
    try {
      return Provider.of<AuthProvider>(context, listen: listen);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_canAccessCustomersMap(_currentViewer())) {
      _loadData();
    } else {
      _isLoading = false;
    }
  }

  AppUser? _currentViewer({AuthProvider? authProvider}) {
    return (authProvider ?? _tryAuthProvider())?.currentUser;
  }

  bool _canAccessCustomersMap(AppUser? viewer) {
    if (viewer == null) return false;
    return RoleAccessMatrix.hasCapability(
          viewer.role,
          RoleCapability.mapViewAll,
        ) ||
        RoleAccessMatrix.hasCapability(
          viewer.role,
          RoleCapability.mapPlanRoutes,
        );
  }

  Widget _buildAccessDenied() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 44,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Customers Map Restricted',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your role does not have customers map access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }
      final customerRepo = context.read<CustomerRepository>();
      final vehiclesService = context.read<VehiclesService>();
      final results = await Future.wait([
        customerRepo.getAllCustomers(),
        vehiclesService.getRoutes(refreshRemote: true),
      ]);

      if (!mounted) return;

      final customerEntities = results[0] as List<dynamic>;
      final routeData = results[1] as List<Map<String, dynamic>>;
      final customers = customerEntities
          .map((e) => e.toDomain() as Customer)
          .toList();

      final routeIdByName = <String, String>{};
      final routeNameById = <String, String>{};
      final routeLabelByToken = <String, String>{};

      // [LOCKED] Maintain name <-> id map so route filters remain stable when
      // customer stores route name but assignments/store route id.
      for (final route in routeData) {
        final routeName = (route['name'] ?? route['routeName'] ?? '')
            .toString()
            .trim();
        final routeId = (route['id'] ?? route['routeId'] ?? '')
            .toString()
            .trim();
        final normalizedName = _normalizeRouteTokenOrNull(routeName);
        final normalizedId = _normalizeRouteTokenOrNull(routeId);
        if (normalizedName != null) {
          routeLabelByToken.putIfAbsent(normalizedName, () => routeName);
        }
        if (normalizedName != null && normalizedId != null) {
          routeIdByName[normalizedName] = routeId;
          routeNameById[normalizedId] = routeName;
          routeLabelByToken.putIfAbsent(normalizedId, () => routeName);
        }
      }

      for (final customer in customers) {
        final label = _firstNonEmptyRoute(customer);
        if (label == null) continue;
        final normalized = _normalizeRouteTokenOrNull(label);
        if (normalized == null) continue;
        routeLabelByToken.putIfAbsent(normalized, () => label);
      }

      final nextRoutes = <String>[
        'All',
        ...routeLabelByToken.values
            .where((route) => route.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
      ];

      final nextSelectedRoute = nextRoutes.contains(_selectedRoute)
          ? _selectedRoute
          : 'All';

      setState(() {
        _routeIdByName
          ..clear()
          ..addAll(routeIdByName);
        _routeNameById
          ..clear()
          ..addAll(routeNameById);
        _customers = customers;
        _routes = nextRoutes;
        _selectedRoute = nextSelectedRoute;
        _isLoading = false;
      });

      final customersToFit = customers
          .where(
            (customer) =>
                _customerMatchesSelectedRoute(customer, nextSelectedRoute),
          )
          .toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fitMapToCustomers(customersToFit);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading map data: $e')));
      }
    }
  }

  void _showCustomerDetails(Customer customer) {
    final customerRouteLabel = _routeLabelForCustomer(customer);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      customer.shopName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customerRouteLabel,
                      style: const TextStyle(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Owner: ${customer.ownerName}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 8),
                  Text(customer.mobile),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(customer.address)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isValidCoordinatePair(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (latitude.abs() > 90 || longitude.abs() > 180) return false;
    if (latitude == 0 && longitude == 0) return false;
    return true;
  }

  bool _hasValidCoordinates(Customer customer) {
    return _isValidCoordinatePair(customer.latitude, customer.longitude);
  }

  String _normalizeRouteToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeRouteTokenOrNull(String? value) {
    if (value == null) return null;
    final normalized = _normalizeRouteToken(value);
    return normalized.isEmpty ? null : normalized;
  }

  String? _firstNonEmptyRoute(Customer customer) {
    final salesRoute = customer.salesRoute?.trim();
    if (salesRoute != null && salesRoute.isNotEmpty) {
      return salesRoute;
    }
    final route = customer.route.trim();
    if (route.isNotEmpty) {
      return route;
    }
    return null;
  }

  Set<String> _selectedRouteTokens(String routeLabel) {
    final tokens = <String>{};
    final normalizedLabel = _normalizeRouteTokenOrNull(routeLabel);
    if (normalizedLabel == null) return tokens;
    tokens.add(normalizedLabel);

    final linkedId = _routeIdByName[normalizedLabel];
    final normalizedLinkedId = _normalizeRouteTokenOrNull(linkedId);
    if (normalizedLinkedId != null) {
      tokens.add(normalizedLinkedId);
    }

    final linkedName = _routeNameById[normalizedLabel];
    final normalizedLinkedName = _normalizeRouteTokenOrNull(linkedName);
    if (normalizedLinkedName != null) {
      tokens.add(normalizedLinkedName);
    }

    return tokens;
  }

  bool _customerMatchesSelectedRoute(Customer customer, String routeLabel) {
    if (routeLabel == 'All') return true;
    final selectedTokens = _selectedRouteTokens(routeLabel);
    if (selectedTokens.isEmpty) return true;

    final customerTokens = <String>{};

    void addToken(String? routeValue) {
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

    addToken(customer.route);
    addToken(customer.salesRoute);

    return customerTokens.any(selectedTokens.contains);
  }

  String _routeLabelForCustomer(Customer customer) {
    final primary = _firstNonEmptyRoute(customer);
    if (primary == null) return 'No Route';

    final normalizedPrimary = _normalizeRouteTokenOrNull(primary);
    if (normalizedPrimary == null) return 'No Route';

    final mappedName = _routeNameById[normalizedPrimary];
    if (mappedName != null && mappedName.trim().isNotEmpty) {
      return mappedName.trim();
    }
    return primary;
  }

  void _fitMapToCustomers(List<Customer> customers) {
    final points = customers
        .where(_hasValidCoordinates)
        .map((c) => LatLng(c.latitude!, c.longitude!))
        .toList();

    if (points.isEmpty) {
      try {
        _mapController.move(_defaultMapCenter, _defaultMapZoom);
      } catch (_) {
        // Map may not be attached yet.
      }
      return;
    }

    if (points.length == 1) {
      try {
        _mapController.move(points.first, 11.5);
      } catch (_) {
        // Map may not be attached yet.
      }
      return;
    }

    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(56),
          minZoom: _minMapZoom,
          maxZoom: 14.8,
        ),
      );
    } catch (_) {
      // Keep current camera on any fit failure.
    }
  }

  List<Customer> _filteredCustomersForView() {
    final selectedRouteValue = _routes.contains(_selectedRoute)
        ? _selectedRoute
        : 'All';
    final routeFilter = selectedRouteValue;
    final query = _searchQuery.toLowerCase();

    return _customers.where((customer) {
      final routeLabel = _routeLabelForCustomer(customer);
      final matchesSearch =
          customer.shopName.toLowerCase().contains(query) ||
          (customer.city?.toLowerCase().contains(query) ?? false) ||
          routeLabel.toLowerCase().contains(query);
      final matchesRoute = _customerMatchesSelectedRoute(customer, routeFilter);
      return matchesSearch && matchesRoute;
    }).toList();
  }

  void _scheduleFitToCurrentFilter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitMapToCustomers(_filteredCustomersForView());
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewer = _currentViewer(authProvider: _tryAuthProvider(listen: true));
    if (!_canAccessCustomersMap(viewer)) {
      return _buildAccessDenied();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedRouteValue = _routes.contains(_selectedRoute)
        ? _selectedRoute
        : 'All';
    final filtered = _filteredCustomersForView();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Territory Mapping',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh_rounded),
                      iconSize: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(
                      context,
                    ).scale(1.0);
                    final isCompact =
                        constraints.maxWidth < 720 || textScale > 1.15;

                    InputDecoration fieldDecoration({
                      required String? labelText,
                      Widget? prefixIcon,
                    }) {
                      return InputDecoration(
                        labelText: labelText,
                        prefixIcon: prefixIcon,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                      );
                    }

                    final searchField = TextField(
                      decoration: fieldDecoration(
                        labelText: null,
                        prefixIcon: const Icon(Icons.search, size: 20),
                      ).copyWith(hintText: 'Search shop or city...'),
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                        _scheduleFitToCurrentFilter();
                      },
                    );

                    final routeField = DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedRouteValue,
                      decoration: fieldDecoration(labelText: 'Route'),
                      items: _routes
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedRoute = val ?? 'All');
                        _scheduleFitToCurrentFilter();
                      },
                    );

                    // [LOCKED] Use adaptive layout to avoid RenderFlex overflow on
                    // desktop scaling / long route names.
                    if (isCompact) {
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 10),
                          routeField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 12),
                        SizedBox(width: 220, child: routeField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Showing ${filtered.length} customers',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _defaultMapCenter,
                          initialZoom: _defaultMapZoom,
                          minZoom: _minMapZoom,
                          maxZoom: _maxMapZoom,
                          keepAlive: true,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                          cameraConstraint:
                              const CameraConstraint.containLatitude(),
                          onMapReady: () => _fitMapToCustomers(filtered),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.dattsoap.flutter_app',
                          ),
                          MarkerLayer(
                            markers: filtered
                                .where(_hasValidCoordinates)
                                .map(
                                  (customer) => Marker(
                                    point: LatLng(
                                      customer.latitude!,
                                      customer.longitude!,
                                    ),
                                    width: 110,
                                    height: 66,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showCustomerDetails(customer),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.store,
                                            color: AppColors.info,
                                            size: 30,
                                          ),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 100,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.surface,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: colorScheme.shadow
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                customer.shopName,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      if (filtered.where(_hasValidCoordinates).isEmpty)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(
                                alpha: 0.95,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              'No GPS coordinates in current filter.',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
