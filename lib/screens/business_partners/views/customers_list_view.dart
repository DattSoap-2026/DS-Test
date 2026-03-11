import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../services/customers_service.dart'; // Keep for Customer model only
import '../../../models/types/user_types.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../services/vehicles_service.dart';
import '../business_partner_form_dialog.dart';
import '../widgets/partner_transaction_history_dialog.dart';
import '../partner_data_cache.dart';
import '../../../widgets/ui/glass_container.dart';
import '../../../widgets/ui/animated_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class CustomersListView extends StatefulWidget {
  const CustomersListView({super.key});

  @override
  State<CustomersListView> createState() => _CustomersListViewState();
}

class _CustomersListViewState extends State<CustomersListView>
    with AutomaticKeepAliveClientMixin {
  // Uses Repo instead of Service directly as per original screen
  List<Customer> _allCustomers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoute = 'All Routes';
  final Map<String, String> _routeIdByName = {};
  final Map<String, String> _routeNameById = {};
  List<Map<String, dynamic>> _routeReferences = const [];
  List<String> _salesmanRouteOptions = [];
  DateTime? _lastLoadedAt;
  bool _silentRefreshScheduled = false;
  static const Duration _staleDataWindow = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _restoreFromCache();
    _loadCustomers(showLoader: _allCustomers.isEmpty);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _restoreFromCache() {
    final cached = BusinessPartnersDataCache.customers;
    if (cached == null) return;
    _allCustomers = cached.customers;
    _routeIdByName
      ..clear()
      ..addAll(cached.routeIdByName);
    _routeNameById
      ..clear()
      ..addAll(cached.routeNameById);
    _routeReferences = cached.routeReferences;
    _salesmanRouteOptions = cached.salesmanRouteOptions;
    _isLoading = false;
  }

  Future<void> _loadCustomers({
    bool showLoader = true,
    bool refreshRouteReferences = false,
  }) async {
    try {
      if (mounted && showLoader) {
        setState(() => _isLoading = true);
      }
      final customerRepo = context.read<CustomerRepository>();
      final currentUser = context.read<AuthProvider>().state.user;
      final isSalesman = currentUser?.role == UserRole.salesman;

      await _loadRouteReferenceMaps(refreshRemote: refreshRouteReferences);
      final customerEntities = await customerRepo.getAllCustomers();

      var customers = customerEntities
          .map((entity) => entity.toDomain())
          .toList();
      var salesmanRouteOptions = <String>[];
      if (isSalesman && currentUser != null) {
        final allowedRouteTokens = _resolveSalesmanRouteTokens(currentUser);
        customers = customers
            .where(
              (customer) =>
                  _customerMatchesRouteTokens(customer, allowedRouteTokens),
            )
            .toList();
        salesmanRouteOptions = _resolveSalesmanRouteLabels(currentUser);
      }

      if (mounted) {
        setState(() {
          if (_selectedRoute != 'All Routes') {
            final selectedTokens = _selectedRouteTokens(_selectedRoute);
            final hasSelectedRouteCustomers = customers.any(
              (customer) =>
                  _customerMatchesRouteTokens(customer, selectedTokens),
            );
            if (!hasSelectedRouteCustomers) {
              _selectedRoute = 'All Routes';
            }
          }
          _allCustomers = customers;
          _salesmanRouteOptions = salesmanRouteOptions;
          BusinessPartnersDataCache.customers = CustomersTabCacheSnapshot(
            customers: customers,
            routeIdByName: _routeIdByName,
            routeNameById: _routeNameById,
            routeReferences: _routeReferences,
            salesmanRouteOptions: salesmanRouteOptions,
          );
          _lastLoadedAt = DateTime.now();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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

  Future<void> _loadRouteReferenceMaps({bool refreshRemote = false}) async {
    try {
      final vehiclesService = context.read<VehiclesService>();
      final routeData = await vehiclesService.getRoutes(
        refreshRemote: refreshRemote,
      );
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
        if (normalizedName == null) continue;
        if (normalizedId != null) {
          routeIdByName[normalizedName] = routeId;
          routeNameById[normalizedId] = routeName;
        }
        routeReferences.add({...route, 'id': routeId, 'name': routeName});
      }

      _routeIdByName
        ..clear()
        ..addAll(routeIdByName);
      _routeNameById
        ..clear()
        ..addAll(routeNameById);
      _routeReferences = routeReferences;
    } catch (e) {
      debugPrint('Error loading customer route references: $e');
    }
  }

  List<String> _distinctRouteLabels(Iterable<String> labels) {
    final byToken = <String, String>{};
    for (final raw in labels) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed == 'No Route') continue;
      final token = _normalizeRouteTokenOrNull(trimmed);
      if (token == null) continue;
      byToken.putIfAbsent(token, () => trimmed);
    }
    final unique = byToken.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return unique;
  }

  void _scheduleSilentRefreshIfStale() {
    if (_silentRefreshScheduled || _isLoading) return;
    final lastLoadedAt = _lastLoadedAt;
    if (lastLoadedAt != null &&
        DateTime.now().difference(lastLoadedAt) < _staleDataWindow) {
      return;
    }
    _silentRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        await _loadCustomers(showLoader: false, refreshRouteReferences: true);
      } finally {
        _silentRefreshScheduled = false;
      }
    });
  }

  Future<void> _refreshFromUi() async {
    await _loadCustomers(showLoader: false, refreshRouteReferences: true);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Customers refreshed')));
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
    // [LOCKED] Salesman route access must remain token-based (route name/id tolerant)
    // to prevent empty customer lists when assignments store ids but customers store names.
    final tokens = <String>{};

    void addRouteToken(String? routeValue) {
      final normalized = _normalizeRouteTokenOrNull(routeValue);
      if (normalized == null) return;
      tokens.add(normalized);
      final linkedId = _routeIdByName[normalized];
      final normalizedLinkedId = _normalizeRouteTokenOrNull(linkedId);
      if (normalizedLinkedId != null) {
        tokens.add(normalizedLinkedId);
      }
      final linkedName = _routeNameById[normalized];
      final normalizedLinkedName = _normalizeRouteTokenOrNull(linkedName);
      if (normalizedLinkedName != null) {
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

  List<String> _resolveSalesmanRouteLabels(AppUser user) {
    final labels = <String>{};

    void addRouteLabel(String? routeValue) {
      final normalized = _normalizeRouteTokenOrNull(routeValue);
      if (normalized == null) return;
      final mappedName = _routeNameById[normalized];
      if (mappedName != null && mappedName.trim().isNotEmpty) {
        labels.add(mappedName.trim());
      } else {
        labels.add(routeValue!.trim());
      }
    }

    if (user.assignedRoutes != null) {
      for (final route in user.assignedRoutes!) {
        addRouteLabel(route);
      }
    }
    addRouteLabel(user.assignedSalesRoute);
    addRouteLabel(user.assignedDeliveryRoute);

    for (final route in _routeReferences) {
      if (!_isRouteAssignedToSalesman(route, user)) continue;
      addRouteLabel((route['name'] ?? '').toString());
      addRouteLabel((route['id'] ?? '').toString());
    }

    final sorted = labels.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
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

  String _canonicalRouteLabel(String? rawRoute) {
    final normalized = _normalizeRouteTokenOrNull(rawRoute);
    if (normalized == null) return '';
    final mappedName = _routeNameById[normalized];
    if (mappedName != null && mappedName.trim().isNotEmpty) {
      return mappedName.trim();
    }
    return rawRoute!.trim();
  }

  String _displayRouteForCustomer(Customer customer) {
    final salesRoute = customer.salesRoute?.trim();
    if (salesRoute != null && salesRoute.isNotEmpty) {
      final label = _canonicalRouteLabel(salesRoute);
      if (label.isNotEmpty) return label;
    }
    final route = customer.route.trim();
    if (route.isNotEmpty) {
      final label = _canonicalRouteLabel(route);
      if (label.isNotEmpty) return label;
    }
    return 'No Route';
  }

  int _countCustomersForRoute(String routeLabel) {
    if (routeLabel == 'All Routes') return _allCustomers.length;
    final routeTokens = _selectedRouteTokens(routeLabel);
    return _allCustomers
        .where((customer) => _customerMatchesRouteTokens(customer, routeTokens))
        .length;
  }

  Map<String, int> _buildRouteWiseCounts(List<String> routeOptions) {
    // [LOCKED] Route-wise counts must be based on route mapping only,
    // not search query, so selected/total remains stable while typing.
    final counts = <String, int>{
      for (final route in routeOptions)
        if (route != 'All Routes') route: 0,
    };
    for (final customer in _allCustomers) {
      final routeLabel = _displayRouteForCustomer(customer);
      final existing = counts[routeLabel];
      if (existing == null) continue;
      counts[routeLabel] = existing + 1;
    }
    return counts;
  }

  Widget _buildRouteCountPanel({
    required ThemeData theme,
    required List<String> routeOptions,
    required Map<String, int> routeCounts,
    required String selectedRoute,
    required int totalCustomers,
  }) {
    final visibleRoutes = routeOptions.where((route) => route != 'All Routes');

    Widget buildTile({
      required String label,
      required int count,
      required bool selected,
      required VoidCallback onTap,
    }) {
      final selectedColor = theme.colorScheme.primary;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$count',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: selected ? selectedColor : AppColors.success,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GlassContainer(
      borderRadius: 20,
      color: theme.colorScheme.primary.withValues(alpha: 0.04),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            buildTile(
              label: 'All Routes',
              count: totalCustomers,
              selected: selectedRoute == 'All Routes',
              onTap: () => setState(() => _selectedRoute = 'All Routes'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: visibleRoutes.length,
                itemBuilder: (context, index) {
                  final route = visibleRoutes.elementAt(index);
                  return buildTile(
                    label: route,
                    count: routeCounts[route] ?? 0,
                    selected: selectedRoute == route,
                    onTap: () => setState(() => _selectedRoute = route),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerDialog([Customer? customer]) async {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    if (isMobile) {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (routeContext) => BusinessPartnerFormDialog(
            initialType: PartnerType.customer,
            existingPartner: customer,
            fullScreen: true,
            onSaved: () => Navigator.of(routeContext).pop(true),
          ),
        ),
      );
      if (saved == true && mounted) {
        _selectedRoute = 'All Routes';
        _loadCustomers(showLoader: false, refreshRouteReferences: true);
      }
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => BusinessPartnerFormDialog(
        initialType: PartnerType.customer,
        existingPartner: customer,
        onSaved: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (saved == true && mounted) {
      _selectedRoute = 'All Routes';
      _loadCustomers(showLoader: false, refreshRouteReferences: true);
    }
  }

  Future<void> _showCustomerHistory(Customer customer) async {
    await PartnerTransactionHistoryDialog.showSalesHistory(
      context,
      partnerId: customer.id,
      partnerName: customer.shopName,
      recipientType: 'customer',
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _scheduleSilentRefreshIfStale();
    final theme = Theme.of(context);
    final currentUser = context.read<AuthProvider>().state.user;
    final isSalesman = currentUser?.role == UserRole.salesman;

    final customerRouteLabels = _allCustomers
        .map(_displayRouteForCustomer)
        .where((route) => route != 'No Route');
    final masterRouteLabels = _routeReferences
        .map((route) => (route['name'] ?? '').toString().trim())
        .where((route) => route.isNotEmpty);
    final routePool = <String>[
      ...customerRouteLabels,
      if (isSalesman) ..._salesmanRouteOptions else ...masterRouteLabels,
    ];
    final routes = <String>['All Routes', ..._distinctRouteLabels(routePool)];

    final effectiveSelectedRoute = routes.contains(_selectedRoute)
        ? _selectedRoute
        : 'All Routes';
    final selectedRouteTokens = effectiveSelectedRoute == 'All Routes'
        ? <String>{}
        : _selectedRouteTokens(effectiveSelectedRoute);
    final routeWiseCounts = _buildRouteWiseCounts(routes);
    final selectedRouteCount = effectiveSelectedRoute == 'All Routes'
        ? _allCustomers.length
        : (routeWiseCounts[effectiveSelectedRoute] ??
              _countCustomersForRoute(effectiveSelectedRoute));
    final totalCustomers = _allCustomers.length;

    // Filter customers
    final query = _searchController.text.toLowerCase();
    final displayCustomers = _allCustomers.where((c) {
      final routeLabel = _displayRouteForCustomer(c).toLowerCase();
      final matchesQuery =
          c.shopName.toLowerCase().contains(query) ||
          c.ownerName.toLowerCase().contains(query) ||
          c.mobile.contains(query) ||
          routeLabel.contains(query);
      final matchesRoute =
          effectiveSelectedRoute == 'All Routes' ||
          _customerMatchesRouteTokens(c, selectedRouteTokens);

      return matchesQuery && matchesRoute;
    }).toList();
    final listView = displayCustomers.isEmpty
        ? Center(
            child: Text(
              'No customers found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
            itemCount: displayCustomers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final customer = displayCustomers[index];
              final isActive = customer.status == 'active';

              return AnimatedCard(
                onTap: () => _showCustomerDialog(customer),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  color: theme.colorScheme.surface,
                  child: Row(
                    children: [
                      // Avatar
                      InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () => _showCustomerHistory(customer),
                        child: SortedAvatar(
                          name: customer.shopName,
                          size: 56,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.shopName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Owner & Mobile
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                _buildInfoTag(
                                  theme,
                                  Icons.person_outline_rounded,
                                  customer.ownerName,
                                ),
                                _buildInfoTag(
                                  theme,
                                  Icons.phone_iphone_rounded,
                                  customer.mobile,
                                ),
                                _buildInfoTag(
                                  theme,
                                  Icons.route_rounded,
                                  _displayRouteForCustomer(customer),
                                  isRoute: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status Indicator
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.success
                                  : theme.colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isActive
                                              ? AppColors.success
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant)
                                          .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          IconButton(
                            tooltip: 'Edit customer',
                            onPressed: () => _showCustomerDialog(customer),
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 520;
                      final searchField = SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: IconButton(
                                tooltip: 'Back',
                                onPressed: () => Navigator.of(context).maybePop(),
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: 'Search customers...',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      );

                      final routeDropdown = SizedBox(
                        height: 52,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: 20,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.05,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: routes.contains(_selectedRoute)
                                  ? _selectedRoute
                                  : effectiveSelectedRoute,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              items: routes.map((String route) {
                                return DropdownMenuItem<String>(
                                  value: route,
                                  child: Text(
                                    route.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedRoute = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      );
                      final selectedVsTotalBadge = GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        borderRadius: 14,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        child: Text(
                          '$selectedRouteCount/$totalCustomers',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                          ),
                        ),
                      );

                      final refreshButton = Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: IconButton(
                          tooltip: 'Refresh customers',
                          onPressed: _isLoading ? null : _refreshFromUi,
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );

                      final addButton = Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: IconButton(
                          tooltip: 'Add customer',
                          onPressed: () => _showCustomerDialog(),
                          icon: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            searchField,
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: routeDropdown),
                                const SizedBox(width: 10),
                                selectedVsTotalBadge,
                                const SizedBox(width: 10),
                                refreshButton,
                                const SizedBox(width: 10),
                                addButton,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 2, child: searchField),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: routeDropdown),
                          const SizedBox(width: 10),
                          selectedVsTotalBadge,
                          const SizedBox(width: 10),
                          refreshButton,
                          const SizedBox(width: 10),
                          addButton,
                        ],
                      );
                    },
                  ),
                ),

                // Customer List
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final showRoutePanel =
                          constraints.maxWidth >= 1150 && routes.length > 1;
                      if (!showRoutePanel) return listView;

                      return Row(
                        children: [
                          Expanded(child: listView),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 330,
                            child: _buildRouteCountPanel(
                              theme: theme,
                              routeOptions: routes,
                              routeCounts: routeWiseCounts,
                              selectedRoute: effectiveSelectedRoute,
                              totalCustomers: totalCustomers,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoTag(
    ThemeData theme,
    IconData icon,
    String label, {
    bool isRoute = false,
  }) {
    final maxWidth = isRoute ? 180.0 : 150.0;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isRoute
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isRoute
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isRoute
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isRoute ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SortedAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;

  const SortedAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    // Deterministic color based on name
    final colorIndex =
        name.codeUnits.fold(0, (p, c) => p + c) % Colors.primaries.length;
    final color = Colors.primaries[colorIndex];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
