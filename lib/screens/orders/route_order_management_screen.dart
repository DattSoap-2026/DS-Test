import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/types/product_types.dart';
import '../../models/types/route_order_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/dealers_service.dart';
import '../../services/products_service.dart';
import '../../services/route_order_service.dart';
import '../../services/users_service.dart';
import '../../services/vehicles_service.dart';

class RouteOrderManagementScreen extends StatefulWidget {
  const RouteOrderManagementScreen({super.key});

  @override
  State<RouteOrderManagementScreen> createState() =>
      _RouteOrderManagementScreenState();
}

enum _OrderTimelineFilter { active, history }
enum _OrderRowAction { markReady, edit, cancel, delete, dispatch }

class _RouteOrderManagementScreenState
    extends State<RouteOrderManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _ordersTableHorizontalController =
      ScrollController();
  final ScrollController _ordersTableVerticalController = ScrollController();
  Timer? _searchDebounce;
  late final AnimationController _flowMotionController;
  late final Animation<double> _gearTurns;

  late final RouteOrderService _routeOrderService;
  late final UsersService _usersService;
  late final DealersService _dealersService;
  late final VehiclesService _vehiclesService;
  late final ProductsService _productsService;

  bool _loadingMasters = true;
  String? _mastersError;

  List<Map<String, dynamic>> _routes = const [];
  List<AppUser> _salesmen = const [];
  List<Dealer> _dealers = const [];
  List<Product> _products = const [];
  List<Vehicle> _vehicles = const [];

  String? _routeFilter;
  String? _salesmanFilter;
  _OrderTimelineFilter _timelineFilter = _OrderTimelineFilter.active;
  bool _ordersAccessDenied = false;
  Stream<List<RouteOrder>>? _ordersStream;
  String? _ordersStreamUserId;
  String? _ordersStreamRouteFilter;
  String? _ordersStreamSalesmanFilter;

  @override
  void initState() {
    super.initState();
    _flowMotionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _gearTurns = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flowMotionController, curve: Curves.linear),
    );
    _routeOrderService = context.read<RouteOrderService>();
    _usersService = context.read<UsersService>();
    _dealersService = context.read<DealersService>();
    _vehiclesService = context.read<VehiclesService>();
    _productsService = context.read<ProductsService>();
    _loadMasterData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _ordersTableHorizontalController.dispose();
    _ordersTableVerticalController.dispose();
    _flowMotionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  AppUser? get _currentUser => context.read<AuthProvider>().state.user;

  bool get _canCreate {
    final user = _currentUser;
    if (user == null) return false;
    return user.role == UserRole.salesman ||
        user.role == UserRole.dealerManager ||
        user.isAdmin;
  }

  bool get _canDispatch {
    final user = _currentUser;
    if (user == null) return false;
    return user.isAdmin || user.role == UserRole.storeIncharge;
  }

  bool get _canMarkProductionReady {
    final user = _currentUser;
    if (user == null) return false;
    return user.isAdmin ||
        user.role == UserRole.productionSupervisor ||
        user.role == UserRole.productionManager;
  }

  bool _isProductionRole(AppUser user) {
    return user.role == UserRole.productionSupervisor ||
        user.role == UserRole.productionManager;
  }

  bool _isOrderActiveForUser(RouteOrder order, AppUser user) {
    if (order.dispatchStatus != RouteOrderDispatchStatus.pending) {
      return false;
    }
    // LOCKED: production queue is active only while production is pending.
    if (_isProductionRole(user)) {
      return order.productionStatus == RouteOrderProductionStatus.pending;
    }
    // Store/Admin/Sales roles keep pending-dispatch orders in active queue.
    return true;
  }

  List<RouteOrder> _applyTimelineFilter(List<RouteOrder> orders, AppUser user) {
    return orders.where((order) {
      final active = _isOrderActiveForUser(order, user);
      return _timelineFilter == _OrderTimelineFilter.active ? active : !active;
    }).toList();
  }

  String _emptyStateText() {
    return _timelineFilter == _OrderTimelineFilter.active
        ? 'No active route orders found.'
        : 'No route order history found.';
  }

  List<Product> _normalizeProducts(List<Product> products) {
    final uniqueById = <String, Product>{};
    for (final product in products) {
      if (product.id.trim().isEmpty) continue;
      uniqueById[product.id] = product;
    }
    final normalized = uniqueById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return normalized;
  }

  Future<void> _loadMasterData() async {
    if (!mounted) return;
    setState(() {
      _loadingMasters = true;
      _mastersError = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _vehiclesService.getRoutes(refreshRemote: true),
        _usersService.getUsers(role: UserRole.salesman),
        _dealersService.getDealers(limitCount: 500),
        _productsService.getProducts(status: 'active'),
        _vehiclesService.getVehicles(),
      ]);

      if (!mounted) return;
      final rawProducts = List<Product>.from(results[3] as List);
      setState(() {
        _routes = List<Map<String, dynamic>>.from(results[0] as List);
        _salesmen = List<AppUser>.from(results[1] as List);
        _dealers = List<Dealer>.from(results[2] as List);
        _products = _normalizeProducts(rawProducts);
        _vehicles = List<Vehicle>.from(results[4] as List);
        _loadingMasters = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMasters = false;
        _mastersError = e.toString();
      });
    }
  }

  Future<void> _openCreateOrderDialog() async {
    final user = _currentUser;
    if (user == null) return;
    if (_ordersAccessDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Orders access denied. Firestore rules deploy/update required.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final dialog = _CreateRouteOrderDialog(
      routes: _routes,
      salesmen: _salesmen,
      dealers: _dealers,
      products: _products,
      currentUser: user,
      createdByRole: user.role,
      fullScreen: isMobile,
    );

    _RouteOrderDraft? draft;
    if (isMobile) {
      draft = await navigator.push<_RouteOrderDraft>(
        MaterialPageRoute(builder: (_) => dialog),
      );
    } else {
      draft = await showDialog<_RouteOrderDraft>(
        context: navigator.context,
        builder: (_) => dialog,
      );
    }

    if (draft == null || !mounted) return;

    try {
      await _routeOrderService.createOrder(
        routeId: draft.routeId,
        routeName: draft.routeName,
        salesmanId: draft.salesmanId,
        salesmanName: draft.salesmanName,
        dealerId: draft.dealerId,
        dealerName: draft.dealerName,
        dispatchBeforeDate: draft.dispatchBeforeDate,
        createdByRole: user.role.value,
        source: draft.source,
        isOrderBasedDispatch: draft.isOrderBasedDispatch,
        items: draft.items,
        createdById: user.id,
        createdByName: user.name,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Route order created successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      if (e.toString().toLowerCase().contains('permission-denied')) {
        _scheduleOrdersAccessDeniedState(true);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markReady(RouteOrder order) async {
    final user = _currentUser;
    if (user == null) return;
    try {
      await _routeOrderService.updateProductionStatus(
        orderId: order.id,
        status: RouteOrderProductionStatus.ready,
        updatedById: user.id,
        updatedByName: user.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${order.orderNo} marked ready.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update production status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _dispatchOrder(RouteOrder order) async {
    final user = _currentUser;
    if (user == null) return;

    final vehicle = await showDialog<Vehicle>(
      context: context,
      builder: (_) => _SelectVehicleDialog(vehicles: _vehicles),
    );

    if (vehicle == null || !mounted) return;

    final payload = RouteOrderDispatchPayload(
      routeOrderId: order.id,
      routeOrderNo: order.orderNo,
      source: order.source,
      routeId: order.routeId,
      routeName: order.routeName,
      salesmanId: order.salesmanId,
      salesmanName: order.salesmanName,
      dealerId: order.dealerId,
      dealerName: order.dealerName,
      vehicleId: vehicle.id,
      vehicleNumber: vehicle.number,
      items: order.items,
      dispatchBeforeDate: order.dispatchBeforeDate,
    );

    final targetPath = order.source == RouteOrderSource.dealerManager
        ? '/dashboard/dispatch/dashboard'
        : '/dashboard/dispatch';

    if (!mounted) return;
    context.push(targetPath, extra: payload.toJson());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Review ${order.orderNo} items and confirm dispatch on the next screen.',
        ),
      ),
    );
  }

  bool _canEditOrder(RouteOrder order) {
    final user = _currentUser;
    if (user == null) return false;
    if (order.dispatchStatus != RouteOrderDispatchStatus.pending) {
      return false;
    }
    if (user.role != UserRole.salesman && user.role != UserRole.dealerManager) {
      return false;
    }
    final createdById = (order.createdById ?? '').trim();
    if (createdById.isNotEmpty) {
      return createdById == user.id;
    }
    return order.salesmanId == user.id;
  }

  bool _canCancelOrder(RouteOrder order) {
    return _canEditOrder(order);
  }

  bool _canDeleteOrder(RouteOrder order) {
    return _canEditOrder(order);
  }

  Future<bool> _confirmOrderAction({
    required String title,
    required String message,
    required String confirmLabel,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              style: confirmColor == null
                  ? null
                  : FilledButton.styleFrom(backgroundColor: confirmColor),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _cancelOrder(RouteOrder order) async {
    final user = _currentUser;
    if (user == null) return;
    if (!_canCancelOrder(order)) return;

    final shouldCancel = await _confirmOrderAction(
      title: 'Cancel order?',
      message:
          'Are you sure you want to cancel ${order.orderNo}? This order will not be dispatchable.',
      confirmLabel: 'Cancel Order',
      confirmColor: Colors.orange.shade700,
    );
    if (!shouldCancel || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _routeOrderService.cancelOrderBeforeDispatch(
        orderId: order.id,
        cancelledById: user.id,
        cancelledByName: user.name,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${order.orderNo} cancelled successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteOrder(RouteOrder order) async {
    final user = _currentUser;
    if (user == null) return;
    if (!_canDeleteOrder(order)) return;

    final shouldDelete = await _confirmOrderAction(
      title: 'Delete order?',
      message:
          'Delete ${order.orderNo}? This action removes it from the active order list.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
    );
    if (!shouldDelete || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _routeOrderService.deleteOrderBeforeDispatch(
        orderId: order.id,
        deletedById: user.id,
        deletedByName: user.name,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${order.orderNo} deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to delete order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openEditOrderDialog(RouteOrder order) async {
    final user = _currentUser;
    if (user == null) return;
    if (!_canEditOrder(order)) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final dialog = _CreateRouteOrderDialog(
      routes: _routes,
      salesmen: _salesmen,
      dealers: _dealers,
      products: _products,
      currentUser: user,
      createdByRole: user.role,
      fullScreen: isMobile,
      isEditMode: true,
      initialOrder: order,
    );

    _RouteOrderDraft? draft;
    if (isMobile) {
      draft = await navigator.push<_RouteOrderDraft>(
        MaterialPageRoute(builder: (_) => dialog),
      );
    } else {
      draft = await showDialog<_RouteOrderDraft>(
        context: navigator.context,
        builder: (_) => dialog,
      );
    }

    if (draft == null || !mounted) return;

    try {
      await _routeOrderService.updateOrderBeforeDispatch(
        orderId: order.id,
        items: draft.items,
        dispatchBeforeDate: draft.dispatchBeforeDate,
        updatedById: user.id,
        updatedByName: user.name,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${order.orderNo} updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<RouteOrder> _applySearch(List<RouteOrder> orders) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return orders;
    return orders.where((order) {
      return order.orderNo.toLowerCase().contains(query) ||
          order.routeName.toLowerCase().contains(query) ||
          order.salesmanName.toLowerCase().contains(query) ||
          order.dealerName.toLowerCase().contains(query) ||
          (order.dispatchBeforeDate ?? '').toLowerCase().contains(query) ||
          order.source.value.toLowerCase().contains(query);
    }).toList();
  }

  bool _shouldLockToCurrentUserOrders(AppUser user) {
    return user.role == UserRole.salesman ||
        user.role == UserRole.dealerManager;
  }

  String? _resolveStreamRouteFilter({required bool isMobile}) {
    if (isMobile) return null;
    return _routeFilter;
  }

  String? _resolveStreamSalesmanFilter({
    required AppUser user,
    required bool isMobile,
  }) {
    if (_shouldLockToCurrentUserOrders(user)) {
      return user.id;
    }
    if (isMobile) return null;
    return _salesmanFilter;
  }

  void _scheduleOrdersAccessDeniedState(bool denied) {
    if (_ordersAccessDenied == denied) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _ordersAccessDenied == denied) return;
      setState(() => _ordersAccessDenied = denied);
    });
  }

  Stream<List<RouteOrder>> _resolveOrdersStream({
    required AppUser user,
    required bool isMobile,
  }) {
    final streamRouteFilter = _resolveStreamRouteFilter(isMobile: isMobile);
    final streamSalesmanFilter = _resolveStreamSalesmanFilter(
      user: user,
      isMobile: isMobile,
    );
    final shouldRefresh =
        _ordersStream == null ||
        _ordersStreamUserId != user.id ||
        _ordersStreamRouteFilter != streamRouteFilter ||
        _ordersStreamSalesmanFilter != streamSalesmanFilter;

    if (shouldRefresh) {
      _ordersStreamUserId = user.id;
      _ordersStreamRouteFilter = streamRouteFilter;
      _ordersStreamSalesmanFilter = streamSalesmanFilter;
      _ordersStream = _routeOrderService.watchOrders(
        routeId: streamRouteFilter,
        salesmanId: streamSalesmanFilter,
        limit: 400,
      );
    }
    return _ordersStream!;
  }

  String? _extractFirstUrl(String text) {
    final match = RegExp(r'https?://[^\s]+').firstMatch(text);
    if (match == null) return null;
    var link = match.group(0) ?? '';
    while (link.isNotEmpty &&
        '.,);]'.contains(link.substring(link.length - 1))) {
      link = link.substring(0, link.length - 1);
    }
    return link.isEmpty ? null : link;
  }

  Future<void> _openIndexLink(String link) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(link);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invalid index link.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to open link.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyIndexLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Index link copied.')));
  }

  Widget _buildOrderLoadError(String errorText) {
    final normalizedError = errorText.toLowerCase();
    if (normalizedError.contains('permission-denied')) {
      return const Center(
        child: Text(
          'Orders access denied. Firestore rules deploy/update required.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final indexLink = _extractFirstUrl(errorText);
    final isIndexError =
        normalizedError.contains('failed-precondition') &&
        indexLink != null &&
        indexLink.isNotEmpty;
    if (!isIndexError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            'Failed to load orders: $errorText',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Firestore index required/building.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use this link to create/open index in Firebase Console.',
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(indexLink),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _openIndexLink(indexLink),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Index Link'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copyIndexLink(indexLink),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Link'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: const Text('Technical Details'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SelectableText(
                        'Failed to load orders: $errorText',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to load user context.')),
      );
    }
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final ordersStream = _resolveOrdersStream(user: user, isMobile: isMobile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Order Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh Master Data',
            onPressed: _loadMasterData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(user: user, isMobile: isMobile),
          if (_loadingMasters) const LinearProgressIndicator(minHeight: 2),
          if (_mastersError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _mastersError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<RouteOrder>>(
              stream: ordersStream,
              builder: (context, snapshot) {
                final denied =
                    snapshot.hasError &&
                    snapshot.error.toString().toLowerCase().contains(
                      'permission-denied',
                    );
                _scheduleOrdersAccessDeniedState(denied);

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final errorText = snapshot.error.toString();
                  return _buildOrderLoadError(errorText);
                }

                final timelineFiltered = _applyTimelineFilter(
                  snapshot.data ?? const [],
                  user,
                );
                final orders = _applySearch(timelineFiltered);
                if (orders.isEmpty) {
                  return Center(child: Text(_emptyStateText()));
                }
                return _buildOrdersContent(orders);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar({required AppUser user, required bool isMobile}) {
    final lockToCurrentUser = _shouldLockToCurrentUserOrders(user);
    final seenRouteIds = <String>{};
    final validRoutes = _routes.where((route) {
      final id = (route['id'] ?? '').toString().trim();
      if (id.isEmpty) return false;
      if (seenRouteIds.contains(id)) return false;
      seenRouteIds.add(id);
      return true;
    }).toList();

    final searchField = TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Search Orders',
        border: OutlineInputBorder(),
        isDense: true,
        prefixIcon: Icon(Icons.search),
      ),
    );

    final createButton = FilledButton.icon(
      onPressed:
          (_loadingMasters || _mastersError != null || _ordersAccessDenied)
          ? null
          : _openCreateOrderDialog,
      icon: const Icon(Icons.add),
      label: const Text('Create Order'),
    );

    final timelineToggle = _buildTimelineToggle(user: user);

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: searchField),
                if (_canCreate) ...[const SizedBox(width: 8), createButton],
              ],
            ),
            const SizedBox(height: 8),
            timelineToggle,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(width: 260, child: searchField),
          timelineToggle,
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String?>(
              isExpanded: true,
              key: ValueKey<String?>(_routeFilter ?? 'all_route_filter'),
              initialValue: _routeFilter,
              decoration: const InputDecoration(
                labelText: 'Route',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Routes'),
                ),
                ...validRoutes.map((route) {
                  final id = (route['id'] ?? '').toString();
                  final name = (route['name'] ?? id).toString();
                  return DropdownMenuItem<String?>(
                    value: id,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _routeFilter = value),
            ),
          ),
          if (!lockToCurrentUser)
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                isExpanded: true,
                key: ValueKey<String?>(
                  _salesmanFilter ?? 'all_salesman_filter',
                ),
                initialValue: _salesmanFilter,
                decoration: const InputDecoration(
                  labelText: 'Salesman',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Salesmen'),
                  ),
                  ..._salesmen.map(
                    (salesman) => DropdownMenuItem<String?>(
                      value: salesman.id,
                      child: Text(
                        salesman.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _salesmanFilter = value),
              ),
            ),
          if (_canCreate) createButton,
        ],
      ),
    );
  }

  Widget _buildTimelineToggle({required AppUser user}) {
    final isProduction = _isProductionRole(user);
    final activeLabel = isProduction ? 'Active (Pending Prod)' : 'Active';
    final historyLabel = isProduction ? 'History (Ready/Closed)' : 'History';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(activeLabel),
          selected: _timelineFilter == _OrderTimelineFilter.active,
          onSelected: (_) {
            if (_timelineFilter == _OrderTimelineFilter.active) return;
            setState(() => _timelineFilter = _OrderTimelineFilter.active);
          },
        ),
        ChoiceChip(
          label: Text(historyLabel),
          selected: _timelineFilter == _OrderTimelineFilter.history,
          onSelected: (_) {
            if (_timelineFilter == _OrderTimelineFilter.history) return;
            setState(() => _timelineFilter = _OrderTimelineFilter.history);
          },
        ),
      ],
    );
  }

  List<_OrderRowAction> _rowActionsForOrder(RouteOrder order) {
    final actions = <_OrderRowAction>[];
    final isPendingDispatch =
        order.dispatchStatus == RouteOrderDispatchStatus.pending;

    if (_canMarkProductionReady &&
        isPendingDispatch &&
        order.productionStatus == RouteOrderProductionStatus.pending) {
      actions.add(_OrderRowAction.markReady);
    }
    if (_canEditOrder(order)) actions.add(_OrderRowAction.edit);
    if (_canCancelOrder(order)) actions.add(_OrderRowAction.cancel);
    if (_canDeleteOrder(order)) actions.add(_OrderRowAction.delete);
    if (_canDispatch && isPendingDispatch) actions.add(_OrderRowAction.dispatch);

    return actions;
  }

  Future<void> _runRowAction(_OrderRowAction action, RouteOrder order) async {
    switch (action) {
      case _OrderRowAction.markReady:
        await _markReady(order);
      case _OrderRowAction.edit:
        await _openEditOrderDialog(order);
      case _OrderRowAction.cancel:
        await _cancelOrder(order);
      case _OrderRowAction.delete:
        await _deleteOrder(order);
      case _OrderRowAction.dispatch:
        await _dispatchOrder(order);
    }
  }

  String _rowActionLabel(_OrderRowAction action) {
    switch (action) {
      case _OrderRowAction.markReady:
        return 'Mark Ready';
      case _OrderRowAction.edit:
        return 'Edit';
      case _OrderRowAction.cancel:
        return 'Cancel';
      case _OrderRowAction.delete:
        return 'Delete';
      case _OrderRowAction.dispatch:
        return 'Dispatch';
    }
  }

  IconData _rowActionIcon(_OrderRowAction action) {
    switch (action) {
      case _OrderRowAction.markReady:
        return Icons.done_all_rounded;
      case _OrderRowAction.edit:
        return Icons.edit_outlined;
      case _OrderRowAction.cancel:
        return Icons.cancel_outlined;
      case _OrderRowAction.delete:
        return Icons.delete_outline;
      case _OrderRowAction.dispatch:
        return Icons.local_shipping_outlined;
    }
  }

  Color? _rowActionColor(BuildContext context, _OrderRowAction action) {
    switch (action) {
      case _OrderRowAction.cancel:
        return Colors.orange.shade700;
      case _OrderRowAction.delete:
        return Colors.red;
      case _OrderRowAction.markReady:
      case _OrderRowAction.edit:
      case _OrderRowAction.dispatch:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  Widget _buildOrderActions(RouteOrder order, {required bool compact}) {
    final actions = _rowActionsForOrder(order);

    if (compact) {
      if (actions.isEmpty) {
        if (order.dispatchStatus == RouteOrderDispatchStatus.dispatched) {
          return const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          );
        }
        return const SizedBox.shrink();
      }
      return PopupMenuButton<_OrderRowAction>(
        tooltip: 'Order actions',
        icon: const Icon(Icons.more_vert),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 180),
        onSelected: (action) => _runRowAction(action, order),
        itemBuilder: (context) {
          return actions.map((action) {
            final color = _rowActionColor(context, action);
            return PopupMenuItem<_OrderRowAction>(
              value: action,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_rowActionIcon(action), size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    _rowActionLabel(action),
                    style: color == null ? null : TextStyle(color: color),
                  ),
                ],
              ),
            );
          }).toList();
        },
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          switch (action) {
            _OrderRowAction.markReady => OutlinedButton(
              onPressed: () => _markReady(order),
              child: const Text('Mark Ready'),
            ),
            _OrderRowAction.edit => OutlinedButton(
              onPressed: () => _openEditOrderDialog(order),
              child: const Text('Edit'),
            ),
            _OrderRowAction.cancel => OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
              ),
              onPressed: () => _cancelOrder(order),
              child: const Text('Cancel'),
            ),
            _OrderRowAction.delete => OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _deleteOrder(order),
              child: const Text('Delete'),
            ),
            _OrderRowAction.dispatch => FilledButton(
              onPressed: () => _dispatchOrder(order),
              child: const Text('Dispatch'),
            ),
          },
        if (order.dispatchStatus == RouteOrderDispatchStatus.dispatched)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
      ],
    );
  }

  String _shortSourceLabel(RouteOrderSource source) {
    switch (source) {
      case RouteOrderSource.salesman:
        return 'sales';
      case RouteOrderSource.dealerManager:
        return 'dealer';
    }
  }

  Widget _buildOrderStageChip(RouteOrder order, {bool compact = false}) {
    final isCancelled = order.dispatchStatus == RouteOrderDispatchStatus.cancelled;
    final stageIndex = _orderProgressIndex(order);

    late final String emoji;
    late final String label;
    late final Color color;
    if (isCancelled) {
      emoji = '\u26A0\uFE0F';
      label = compact ? 'Cancel' : 'Cancelled';
      color = Colors.red;
    } else if (stageIndex == 2) {
      emoji = '\u{1F69A}';
      label = compact ? 'Disp' : 'Dispatched';
      color = const Color(0xFF10B981);
    } else if (stageIndex == 1) {
      emoji = '\u2699\uFE0F';
      label = compact ? 'Proc' : 'Processing';
      color = const Color(0xFFF59E0B);
    } else {
      emoji = '\u{1F4E6}';
      label = compact ? 'New' : 'New Order';
      color = const Color(0xFF3B82F6);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: compact ? 12 : 13, height: 1)),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<RouteOrder> orders, {required double maxWidth}) {
    final isCompact = maxWidth < 1650;
    final isUltraCompact = maxWidth < 1450;
    final dateFormat = DateFormat(isCompact ? 'dd MMM' : 'dd MMM yyyy');
    final dispatchBeforeFormat = DateFormat(isCompact ? 'dd MMM' : 'dd MMM yyyy');
    final useCompactActions = maxWidth < 2200;
    final useCompactProgress = maxWidth < 1850;
    final columnSpacing = isCompact ? 12.0 : 20.0;
    final orderNoWidth = isUltraCompact ? 128.0 : 150.0;
    final routeWidth = isUltraCompact ? 82.0 : 100.0;
    final salesmanWidth = isUltraCompact ? 110.0 : 130.0;
    final dealerWidth = isUltraCompact ? 140.0 : 170.0;
    final dateWidth = isCompact ? 76.0 : 112.0;
    final dueWidth = isCompact ? 84.0 : 120.0;
    final itemsWidth = isUltraCompact ? 185.0 : 235.0;
    final sourceWidth = isCompact ? 66.0 : 106.0;
    // [LOCKED] Keep DataTable row heights normalized to avoid
    // BoxConstraints asserts (minHeight must be <= maxHeight).
    const tableRowMinHeight = 56.0;
    const tableRowMaxHeight = 96.0;
    // [LOCKED] Route orders table must expose visible horizontal scrollbar
    // so all right-side columns remain reachable on desktop widths.
    return Scrollbar(
      controller: _ordersTableHorizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 10,
      radius: const Radius.circular(10),
      notificationPredicate: (notification) =>
          notification.metrics.axis == Axis.horizontal,
      child: SingleChildScrollView(
        controller: _ordersTableHorizontalController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: maxWidth),
          child: Scrollbar(
            controller: _ordersTableVerticalController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 8,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: _ordersTableVerticalController,
              child: DataTable(
            columnSpacing: columnSpacing,
            headingRowHeight: 46,
            dataRowMinHeight: tableRowMinHeight,
            dataRowMaxHeight: tableRowMaxHeight,
            columns: [
              DataColumn(label: Text(isCompact ? 'Ord#' : 'Order No')),
              DataColumn(label: Text(isCompact ? 'Rt' : 'Route')),
              DataColumn(label: Text(isCompact ? 'Sales' : 'Salesman')),
              DataColumn(label: Text('Dealer')),
              DataColumn(label: Text(isCompact ? 'Dt' : 'Date')),
              DataColumn(label: Text(isCompact ? 'Due' : 'Dispatch Before')),
              DataColumn(label: Text('Items')),
              const DataColumn(label: Text('Prod')),
              const DataColumn(label: Text('Disp')),
              DataColumn(label: Text(isCompact ? 'Stage' : 'Progress')),
              DataColumn(label: Text(isCompact ? 'Src' : 'Source')),
              DataColumn(label: Text(isCompact ? 'Act' : 'Action')),
            ],
                rows: orders.map((order) {
                  final itemsSummary = _buildItemsSummary(order);
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: orderNoWidth,
                          child: Text(
                            order.orderNo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: routeWidth,
                          child: Text(
                            order.routeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: salesmanWidth,
                          child: Text(
                            order.salesmanName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dealerWidth,
                          child: Text(
                            order.dealerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dateWidth,
                          child: Text(dateFormat.format(order.createdDateTime)),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dueWidth,
                          child: Text(
                            order.dispatchBeforeDateTime == null
                                ? '-'
                                : dispatchBeforeFormat.format(
                                    order.dispatchBeforeDateTime!,
                                  ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: itemsWidth,
                          child: Tooltip(
                            message: itemsSummary,
                            child: Text(
                              itemsSummary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        _statusChip(
                          order.productionStatus.value,
                          order.productionStatus ==
                                  RouteOrderProductionStatus.ready
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      DataCell(
                        _statusChip(
                          order.dispatchStatus.value,
                          _dispatchStatusColor(order.dispatchStatus),
                        ),
                      ),
                      DataCell(
                        useCompactProgress
                            ? _buildOrderStageChip(order, compact: true)
                            : _buildOrderProgressTimeline(order, compact: true),
                      ),
                      DataCell(
                        SizedBox(
                          width: sourceWidth,
                          child: Text(
                            isCompact
                                ? _shortSourceLabel(order.source)
                                : order.source.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: useCompactActions ? 56 : 320,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildOrderActions(
                              order,
                              compact: useCompactActions,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersContent(List<RouteOrder> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) => _buildOrderCard(orders[index]),
          );
        }
        return _buildOrdersTable(orders, maxWidth: constraints.maxWidth);
      },
    );
  }

  Widget _buildOrderCard(RouteOrder order) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final dueDate = order.dispatchBeforeDateTime == null
        ? '-'
        : dateFormat.format(order.dispatchBeforeDateTime!);
    final useCompactActions = MediaQuery.sizeOf(context).width < 1100;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.orderNo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Route: ${order.routeName}'),
            Text('Salesman: ${order.salesmanName}'),
            Text('Dealer: ${order.dealerName}'),
            Text('Dispatch Before: $dueDate'),
            const SizedBox(height: 6),
            Text('Items: ${_buildItemsSummary(order)}'),
            const SizedBox(height: 10),
            _buildOrderProgressTimeline(order),
            const SizedBox(height: 10),
            if (useCompactActions)
              Align(
                alignment: Alignment.centerRight,
                child: _buildOrderActions(order, compact: true),
              )
            else
              _buildOrderActions(order, compact: false),
          ],
        ),
      ),
    );
  }

  Color _dispatchStatusColor(RouteOrderDispatchStatus status) {
    switch (status) {
      case RouteOrderDispatchStatus.pending:
        return Colors.orange;
      case RouteOrderDispatchStatus.dispatched:
        return Colors.green;
      case RouteOrderDispatchStatus.cancelled:
        return Colors.red;
    }
  }

  int _orderProgressIndex(RouteOrder order) {
    if (order.dispatchStatus == RouteOrderDispatchStatus.dispatched) {
      return 2;
    }
    if (order.productionStatus == RouteOrderProductionStatus.ready) {
      return 1;
    }
    return 0;
  }

  Widget _buildOrderProgressTimeline(RouteOrder order, {bool compact = false}) {
    const steps = <_OrderProgressStep>[
      _OrderProgressStep(
        label: 'New Order',
        emoji: '\u{1F4E6}',
        color: Color(0xFF3B82F6),
      ),
      _OrderProgressStep(
        label: 'Processing',
        emoji: '\u2699\uFE0F',
        color: Color(0xFFF59E0B),
      ),
      _OrderProgressStep(
        label: 'Dispatched',
        emoji: '\u{1F69A}',
        color: Color(0xFF10B981),
      ),
    ];

    final activeIndex = _orderProgressIndex(order);
    final isCancelled = order.dispatchStatus == RouteOrderDispatchStatus.cancelled;
    final canAnimate = !isCancelled && activeIndex < steps.length - 1;
    final gap = compact ? 6.0 : 8.0;
    final connectorWidth = compact ? 16.0 : 24.0;

    return AnimatedBuilder(
      animation: _flowMotionController,
      builder: (context, _) {
        final pulse = 0.7 + (_flowMotionController.value * 0.3);
        final chips = <Widget>[];

        for (int i = 0; i < steps.length; i++) {
          final step = steps[i];
          final isDone = i < activeIndex;
          final isActive = i == activeIndex && !isCancelled;
          final isPending = i > activeIndex && !isCancelled;
          final baseColor = step.color;

          final backgroundColor = isDone
              ? baseColor.withValues(alpha: 0.2)
              : isActive
              ? baseColor.withValues(alpha: compact ? 0.18 : 0.2)
              : isPending
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.08)
              : Colors.red.withValues(alpha: 0.12);
          final borderColor = isDone || isActive
              ? baseColor.withValues(alpha: 0.8)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
          final textColor = isDone || isActive
              ? baseColor
              : Theme.of(context).colorScheme.onSurfaceVariant;

          Widget iconWidget = Text(
            step.emoji,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              height: 1,
            ),
          );

          if (isActive && step.label == 'Processing' && canAnimate) {
            iconWidget = Transform.rotate(
              angle: _gearTurns.value * (2 * math.pi),
              child: iconWidget,
            );
          }

          Widget stepChip = Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
              boxShadow: isActive && canAnimate
                  ? [
                      BoxShadow(
                        color: baseColor.withValues(alpha: 0.22 * pulse),
                        blurRadius: 12,
                        spreadRadius: 1.5,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                SizedBox(width: compact ? 4 : 6),
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          );

          if (isActive && canAnimate) {
            stepChip = Transform.scale(
              scale: compact ? 1.0 : 1.0 + (0.02 * pulse),
              child: stepChip,
            );
          }

          chips.add(stepChip);
          if (i < steps.length - 1) {
            final connectorFilled = i < activeIndex;
            chips.add(
              Container(
                width: connectorWidth,
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: gap),
                decoration: BoxDecoration(
                  color: connectorFilled
                      ? steps[i + 1].color.withValues(alpha: 0.8)
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }
        }

        if (isCancelled) {
          chips.add(SizedBox(width: gap));
          chips.add(
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
                vertical: compact ? 5 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                '\u26A0\uFE0F Cancelled',
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: chips,
          ),
        );
      },
    );
  }

  String _buildItemsSummary(RouteOrder order) {
    if (order.items.isEmpty) return '-';
    final preview = order.items
        .take(2)
        .map((item) => '${item.name} x${item.qty}')
        .join(', ');
    final suffix = order.items.length > 2
        ? ' +${order.items.length - 2} more'
        : '';
    return '$preview$suffix';
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RouteOrderDraft {
  final String routeId;
  final String routeName;
  final String salesmanId;
  final String salesmanName;
  final String dealerId;
  final String dealerName;
  final String dispatchBeforeDate;
  final RouteOrderSource source;
  final bool isOrderBasedDispatch;
  final List<RouteOrderItem> items;

  const _RouteOrderDraft({
    required this.routeId,
    required this.routeName,
    required this.salesmanId,
    required this.salesmanName,
    required this.dealerId,
    required this.dealerName,
    required this.dispatchBeforeDate,
    required this.source,
    required this.isOrderBasedDispatch,
    required this.items,
  });
}

class _OrderProgressStep {
  final String label;
  final String emoji;
  final Color color;

  const _OrderProgressStep({
    required this.label,
    required this.emoji,
    required this.color,
  });
}

enum _OrderProductCategoryFilter { all, finished, traded }

class _CreateRouteOrderDialog extends StatefulWidget {
  final List<Map<String, dynamic>> routes;
  final List<AppUser> salesmen;
  final List<Dealer> dealers;
  final List<Product> products;
  final AppUser currentUser;
  final UserRole createdByRole;
  final bool fullScreen;
  final bool isEditMode;
  final RouteOrder? initialOrder;

  const _CreateRouteOrderDialog({
    required this.routes,
    required this.salesmen,
    required this.dealers,
    required this.products,
    required this.currentUser,
    required this.createdByRole,
    this.fullScreen = false,
    this.isEditMode = false,
    this.initialOrder,
  });

  @override
  State<_CreateRouteOrderDialog> createState() =>
      _CreateRouteOrderDialogState();
}

class _CreateRouteOrderDialogState extends State<_CreateRouteOrderDialog> {
  // LOCKED: Products already added in cart must not be selectable again.
  static const bool _hideAlreadyAddedProductsInSearch = true;

  Map<String, dynamic>? _selectedRoute;
  AppUser? _selectedSalesman;
  Dealer? _selectedDealer;
  Product? _selectedProduct;
  late RouteOrderSource _selectedSource;
  final TextEditingController _qtyController = TextEditingController(text: '0');
  final TextEditingController _routeSearchController = TextEditingController();
  final TextEditingController _salesmanSearchController =
      TextEditingController();
  final TextEditingController _dealerSearchController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();
  Timer? _salesmanSearchDebounce;
  Timer? _dealerSearchDebounce;
  Timer? _productSearchDebounce;
  final FocusNode _salesmanSearchFocusNode = FocusNode();
  final FocusNode _dealerSearchFocusNode = FocusNode();
  final FocusNode _productSearchFocusNode = FocusNode();
  final List<RouteOrderItem> _items = [];
  DateTime? _dispatchBeforeDate;
  _OrderProductCategoryFilter _productCategoryFilter =
      _OrderProductCategoryFilter.all;
  bool _showSalesmanDropdown = false;
  bool _showDealerDropdown = false;
  bool _showProductDropdown = false;
  bool _rebuildQueued = false;

  bool get _isSalesmanCreator => widget.currentUser.role == UserRole.salesman;
  bool get _isDealerManagerCreator =>
      widget.currentUser.role == UserRole.dealerManager;
  bool get _isSalesmanLocked => _isSalesmanCreator || _isDealerManagerCreator;
  String get _dialogTitle =>
      widget.isEditMode ? 'Edit Route Order' : 'Create Route Order';
  String get _submitLabel =>
      widget.isEditMode ? 'Save Changes' : 'Create Order';

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.createdByRole == UserRole.dealerManager
        ? RouteOrderSource.dealerManager
        : RouteOrderSource.salesman;
    if (widget.isEditMode && widget.initialOrder != null) {
      _applyEditDefaults(widget.initialOrder!);
    } else {
      _applyRoleDefaults();
    }
    if (_selectedRoute != null) {
      _routeSearchController.text = (_selectedRoute!['name'] ?? '').toString();
    }
    _syncSalesmanSearchFromSelection();
    _syncDealerSearchFromSelection();
    _routeSearchController.addListener(_onInputStateChanged);
    _salesmanSearchController.addListener(_onSalesmanSearchChanged);
    _dealerSearchController.addListener(_onDealerSearchChanged);
    _productSearchController.addListener(_onProductSearchChanged);
    _salesmanSearchFocusNode.addListener(_onInputStateChanged);
    _dealerSearchFocusNode.addListener(_onInputStateChanged);
    _productSearchFocusNode.addListener(_onInputStateChanged);
  }

  void _onSalesmanSearchChanged() {
    _salesmanSearchDebounce?.cancel();
    _salesmanSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _onInputStateChanged();
    });
  }

  void _onDealerSearchChanged() {
    _dealerSearchDebounce?.cancel();
    _dealerSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _onInputStateChanged();
    });
  }

  void _onProductSearchChanged() {
    _productSearchDebounce?.cancel();
    _productSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _onInputStateChanged();
    });
  }

  @override
  void dispose() {
    _salesmanSearchDebounce?.cancel();
    _dealerSearchDebounce?.cancel();
    _productSearchDebounce?.cancel();
    _routeSearchController.removeListener(_onInputStateChanged);
    _salesmanSearchController.removeListener(_onSalesmanSearchChanged);
    _dealerSearchController.removeListener(_onDealerSearchChanged);
    _productSearchController.removeListener(_onProductSearchChanged);
    _salesmanSearchFocusNode.removeListener(_onInputStateChanged);
    _dealerSearchFocusNode.removeListener(_onInputStateChanged);
    _productSearchFocusNode.removeListener(_onInputStateChanged);
    _qtyController.dispose();
    _routeSearchController.dispose();
    _salesmanSearchController.dispose();
    _dealerSearchController.dispose();
    _productSearchController.dispose();
    _salesmanSearchFocusNode.dispose();
    _dealerSearchFocusNode.dispose();
    _productSearchFocusNode.dispose();
    super.dispose();
  }

  String _normalizeToken(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[\s_\-]+'),
      '',
    );
  }

  String _digitsOnly(String? value) {
    return (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  }

  void _onInputStateChanged() {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(() {});
      return;
    }
    if (_rebuildQueued) return;
    _rebuildQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rebuildQueued = false;
      if (!mounted) return;
      setState(() {});
    });
  }

  bool _isSemiFinishedProduct(Product product) {
    final itemType = product.itemType.value.toLowerCase();
    final category = product.category.toLowerCase();
    final entityType = (product.entityType ?? '').toLowerCase();
    return product.type == ProductTypeEnum.semi ||
        entityType == 'semi_finished' ||
        (itemType.contains('semi') && itemType.contains('finish')) ||
        (category.contains('semi') && category.contains('finish'));
  }

  bool _isFinishedProduct(Product product) {
    if (_isSemiFinishedProduct(product)) return false;
    final itemType = product.itemType.value.toLowerCase();
    final category = product.category.toLowerCase();
    final entityType = (product.entityType ?? '').toLowerCase();
    final normalizedItemType = ProductType.fromString(
      itemType,
    ).value.toLowerCase();
    return product.type == ProductTypeEnum.finished ||
        entityType == 'finished' ||
        normalizedItemType == ProductType.finishedGood.value.toLowerCase() ||
        (itemType.contains('finished') && !itemType.contains('semi')) ||
        category.contains('finish');
  }

  bool _isTradedProduct(Product product) {
    final itemType = product.itemType.value.toLowerCase();
    final category = product.category.toLowerCase();
    return itemType.contains('traded') ||
        product.type == ProductTypeEnum.traded ||
        category.contains('traded');
  }

  bool _isOrderableProduct(Product product) {
    final status = product.status.trim().toLowerCase();
    return status == 'active' &&
        (_isFinishedProduct(product) || _isTradedProduct(product));
  }

  bool _matchesCategoryFilter(Product product) {
    switch (_productCategoryFilter) {
      case _OrderProductCategoryFilter.finished:
        return _isFinishedProduct(product);
      case _OrderProductCategoryFilter.traded:
        return _isTradedProduct(product);
      case _OrderProductCategoryFilter.all:
        return _isFinishedProduct(product) || _isTradedProduct(product);
    }
  }

  List<Product> get _orderableProducts {
    final uniqueById = <String, Product>{};
    for (final product in widget.products) {
      final id = product.id.trim();
      if (id.isEmpty) continue;
      if (!_isOrderableProduct(product)) continue;
      uniqueById[id] = product;
    }
    final products = uniqueById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }

  List<Product> get _filteredProductsByCategory =>
      _orderableProducts.where(_matchesCategoryFilter).toList();

  Set<String> get _addedProductIds => _items
      .map((item) => item.productId.trim())
      .where((id) => id.isNotEmpty)
      .toSet();

  List<Product> get _searchableProducts {
    final baseProducts = _filteredProductsByCategory;
    if (!_hideAlreadyAddedProductsInSearch) return baseProducts;
    final addedProductIds = _addedProductIds;
    if (addedProductIds.isEmpty) return baseProducts;
    return baseProducts
        .where((product) => !addedProductIds.contains(product.id.trim()))
        .toList();
  }

  List<Product> get _filteredProductsBySearch {
    final rawQuery = _productSearchController.text.trim();
    if (rawQuery.isEmpty) return const [];
    final query = _normalizeToken(rawQuery);
    final digitQuery = _digitsOnly(rawQuery);

    final matches = _searchableProducts.where((product) {
      final nameToken = _normalizeToken(product.name);
      final skuToken = _normalizeToken(product.sku);
      final idToken = _normalizeToken(product.id);
      if (nameToken.contains(query) ||
          skuToken.contains(query) ||
          idToken.contains(query)) {
        return true;
      }
      if (digitQuery.isEmpty) return false;
      final nameDigits = _digitsOnly(product.name);
      final skuDigits = _digitsOnly(product.sku);
      return nameDigits.contains(digitQuery) || skuDigits.contains(digitQuery);
    }).toList();

    matches.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final queryLower = rawQuery.toLowerCase();
      final aStarts = aName.startsWith(queryLower) ? 0 : 1;
      final bStarts = bName.startsWith(queryLower) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return aName.compareTo(bName);
    });
    return matches.take(30).toList();
  }

  List<AppUser> get _salesmanOptions {
    final uniqueById = <String, AppUser>{};
    for (final salesman in widget.salesmen) {
      if (salesman.id.trim().isEmpty) continue;
      uniqueById[salesman.id] = salesman;
    }
    final options = uniqueById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return options;
  }

  List<AppUser> get _filteredSalesmenBySearch {
    final options = _salesmanOptions;
    final queryRaw = _salesmanSearchController.text.trim();
    if (queryRaw.isEmpty) {
      return options.take(40).toList();
    }

    final query = _normalizeToken(queryRaw);
    final digitQuery = _digitsOnly(queryRaw);
    final matches = options.where((salesman) {
      final nameToken = _normalizeToken(salesman.name);
      final idToken = _normalizeToken(salesman.id);
      final emailToken = _normalizeToken(salesman.email);
      if (nameToken.contains(query) ||
          idToken.contains(query) ||
          emailToken.contains(query)) {
        return true;
      }
      if (digitQuery.isEmpty) return false;
      final mobileDigits = _digitsOnly(salesman.phone);
      final altMobileDigits = _digitsOnly(salesman.secondaryPhone);
      return mobileDigits.contains(digitQuery) ||
          altMobileDigits.contains(digitQuery);
    }).toList();

    matches.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final queryLower = queryRaw.toLowerCase();
      final aStarts = aName.startsWith(queryLower) ? 0 : 1;
      final bStarts = bName.startsWith(queryLower) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return aName.compareTo(bName);
    });
    return matches.take(40).toList();
  }

  List<Map<String, dynamic>> get _routeOptions {
    final uniqueById = <String, Map<String, dynamic>>{};
    for (final route in widget.routes) {
      final id = (route['id'] ?? '').toString().trim();
      final name = (route['name'] ?? '').toString().trim();
      if (id.isEmpty || name.isEmpty) continue;
      uniqueById[id] = {...route, 'id': id, 'name': name};
    }
    final options = uniqueById.values.toList()
      ..sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });
    return options;
  }

  List<Map<String, dynamic>> get _salesmanRouteTokens {
    final tokens = <String>{};
    final assignedSalesRoute = _normalizeToken(
      widget.currentUser.assignedSalesRoute,
    );
    if (assignedSalesRoute.isNotEmpty) {
      tokens.add(assignedSalesRoute);
    }
    final assignedRoutes = widget.currentUser.assignedRoutes ?? const [];
    for (final route in assignedRoutes) {
      final token = _normalizeToken(route);
      if (token.isNotEmpty) {
        tokens.add(token);
      }
    }
    return _routeOptions.where((route) {
      final idToken = _normalizeToken((route['id'] ?? '').toString());
      final nameToken = _normalizeToken((route['name'] ?? '').toString());
      return tokens.contains(idToken) || tokens.contains(nameToken);
    }).toList();
  }

  List<Map<String, dynamic>> get _salesmanRouteOptions {
    if (!_isSalesmanCreator) return _routeOptions;
    return _salesmanRouteTokens;
  }

  Map<String, dynamic>? _findRouteById(
    String routeId, {
    bool salesmanScope = false,
  }) {
    final source = salesmanScope ? _salesmanRouteOptions : _routeOptions;
    for (final route in source) {
      final id = (route['id'] ?? '').toString();
      if (id == routeId) return route;
    }
    return null;
  }

  Map<String, dynamic>? _findRouteByTokens(Iterable<String?> tokens) {
    final routeEntries = widget.routes
        .map((route) {
          final id = (route['id'] ?? '').toString().trim();
          final name = (route['name'] ?? '').toString().trim();
          return {'id': id, 'name': name, 'raw': route};
        })
        .where((entry) => (entry['id'] as String).isNotEmpty);

    final routeMap = <String, Map<String, dynamic>>{};
    for (final route in routeEntries) {
      final idToken = _normalizeToken(route['id'] as String);
      final nameToken = _normalizeToken(route['name'] as String);
      if (idToken.isNotEmpty) {
        routeMap[idToken] = route['raw'] as Map<String, dynamic>;
      }
      if (nameToken.isNotEmpty) {
        routeMap[nameToken] = route['raw'] as Map<String, dynamic>;
      }
    }

    for (final token in tokens) {
      final normalized = _normalizeToken(token);
      if (normalized.isEmpty) continue;
      final matched = routeMap[normalized];
      if (matched != null) return matched;
    }
    return null;
  }

  Dealer? _resolveDealerForCurrentUser() {
    final current = widget.currentUser;
    final currentName = _normalizeToken(current.name);
    final currentEmail = current.email.trim().toLowerCase();
    final currentPhone = _digitsOnly(current.phone);
    final currentSecondaryPhone = _digitsOnly(current.secondaryPhone);

    for (final dealer in widget.dealers) {
      if (dealer.id == current.id) return dealer;
    }
    for (final dealer in widget.dealers) {
      if (_normalizeToken(dealer.name) == currentName &&
          currentName.isNotEmpty) {
        return dealer;
      }
    }
    if (currentEmail.isNotEmpty) {
      for (final dealer in widget.dealers) {
        if ((dealer.email ?? '').trim().toLowerCase() == currentEmail) {
          return dealer;
        }
      }
    }
    final currentPhones = {currentPhone, currentSecondaryPhone}
      ..removeWhere((value) => value.isEmpty);
    if (currentPhones.isNotEmpty) {
      for (final dealer in widget.dealers) {
        final dealerPhone = _digitsOnly(dealer.mobile);
        final dealerAltPhone = _digitsOnly(dealer.alternateMobile);
        if (currentPhones.contains(dealerPhone) ||
            currentPhones.contains(dealerAltPhone)) {
          return dealer;
        }
      }
    }
    return null;
  }

  bool _dealerMatchesSelectedRoute(Dealer dealer, Map<String, dynamic>? route) {
    if (route == null) return true;
    final routeIdToken = _normalizeToken((route['id'] ?? '').toString());
    final routeNameToken = _normalizeToken((route['name'] ?? '').toString());
    if (routeIdToken.isEmpty && routeNameToken.isEmpty) return true;

    final dealerTokens = <String>{
      _normalizeToken(dealer.assignedRouteId),
      _normalizeToken(dealer.assignedRouteName),
      _normalizeToken(dealer.territory),
    }..removeWhere((value) => value.isEmpty);
    return dealerTokens.contains(routeIdToken) ||
        dealerTokens.contains(routeNameToken);
  }

  List<Dealer> get _dealerOptions {
    final uniqueById = <String, Dealer>{};
    for (final dealer in widget.dealers) {
      if (dealer.id.trim().isEmpty) continue;
      uniqueById[dealer.id] = dealer;
    }
    final allDealers = uniqueById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (_selectedRoute == null) return allDealers;

    final filtered = allDealers
        .where((dealer) => _dealerMatchesSelectedRoute(dealer, _selectedRoute))
        .toList();
    if (_isSalesmanCreator) {
      return filtered;
    }
    final options = filtered.isEmpty ? allDealers : filtered;
    final selectedDealer = _selectedDealer;
    if (selectedDealer != null &&
        !options.any((dealer) => dealer.id == selectedDealer.id)) {
      return [...options, selectedDealer];
    }
    return options;
  }

  List<Dealer> get _filteredDealersBySearch {
    final options = _dealerOptions;
    final queryRaw = _dealerSearchController.text.trim();
    if (queryRaw.isEmpty) {
      return options.take(40).toList();
    }

    final query = _normalizeToken(queryRaw);
    final digitQuery = _digitsOnly(queryRaw);
    final matches = options.where((dealer) {
      final nameToken = _normalizeToken(dealer.name);
      final idToken = _normalizeToken(dealer.id);
      final routeToken = _normalizeToken(dealer.assignedRouteName);
      final territoryToken = _normalizeToken(dealer.territory);
      if (nameToken.contains(query) ||
          idToken.contains(query) ||
          routeToken.contains(query) ||
          territoryToken.contains(query)) {
        return true;
      }
      if (digitQuery.isEmpty) return false;
      final mobileDigits = _digitsOnly(dealer.mobile);
      final altMobileDigits = _digitsOnly(dealer.alternateMobile);
      return mobileDigits.contains(digitQuery) ||
          altMobileDigits.contains(digitQuery);
    }).toList();

    matches.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final q = queryRaw.toLowerCase();
      final aStarts = aName.startsWith(q) ? 0 : 1;
      final bStarts = bName.startsWith(q) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return aName.compareTo(bName);
    });
    return matches.take(40).toList();
  }

  bool get _shouldShowSalesmanSearchResults {
    if (_isSalesmanLocked) return false;
    final query = _salesmanSearchController.text.trim();
    final selected = _selectedSalesman;
    final isSameAsSelected =
        selected != null &&
        _normalizeToken(selected.name) == _normalizeToken(query);
    if (_showSalesmanDropdown) return true;
    if (_salesmanSearchFocusNode.hasFocus) return true;
    return query.isNotEmpty && !isSameAsSelected;
  }

  bool get _shouldShowDealerSearchResults {
    if (_isSalesmanCreator) return false;
    final query = _dealerSearchController.text.trim();
    final selected = _selectedDealer;
    final isSameAsSelected =
        selected != null &&
        _normalizeToken(selected.name) == _normalizeToken(query);
    if (_showDealerDropdown) return true;
    if (_dealerSearchFocusNode.hasFocus) return true;
    return query.isNotEmpty && !isSameAsSelected;
  }

  bool get _shouldShowProductSearchResults {
    final query = _productSearchController.text.trim();
    final selected = _selectedProduct;
    final isSameAsSelected =
        selected != null &&
        _normalizeToken(selected.name) == _normalizeToken(query);
    if (_showProductDropdown) return true;
    if (_productSearchFocusNode.hasFocus) return true;
    return query.isNotEmpty && !isSameAsSelected;
  }

  Dealer? _resolveSalesmanDealerForRoute() {
    if (_selectedRoute == null) return null;
    final matched = _dealerOptions;
    if (matched.isEmpty) return null;
    return matched.first;
  }

  Map<String, dynamic>? _resolveRouteForDealer(Dealer? dealer) {
    if (dealer == null) return null;
    return _findRouteByTokens([
      dealer.assignedRouteId,
      dealer.assignedRouteName,
      dealer.territory,
    ]);
  }

  void _syncDealerSearchFromSelection() {
    final name = _selectedDealer?.name ?? '';
    if (_dealerSearchController.text == name) return;
    _dealerSearchController.text = name;
    _dealerSearchController.selection = TextSelection.fromPosition(
      TextPosition(offset: name.length),
    );
  }

  void _syncSalesmanSearchFromSelection() {
    final name = _selectedSalesman?.name ?? '';
    if (_salesmanSearchController.text == name) return;
    _salesmanSearchController.text = name;
    _salesmanSearchController.selection = TextSelection.fromPosition(
      TextPosition(offset: name.length),
    );
  }

  void _onSelectSalesman(AppUser salesman) {
    setState(() {
      _selectedSalesman = salesman;
      _salesmanSearchController.text = salesman.name;
      _salesmanSearchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _salesmanSearchController.text.length),
      );
      _showSalesmanDropdown = false;
    });
    _salesmanSearchFocusNode.unfocus();
  }

  void _onSelectDealer(Dealer dealer, {required bool syncRouteFromDealer}) {
    setState(() {
      _selectedDealer = dealer;
      _dealerSearchController.text = dealer.name;
      _dealerSearchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _dealerSearchController.text.length),
      );
      if (syncRouteFromDealer) {
        _selectedRoute = _resolveRouteForDealer(dealer);
        final routeName = (_selectedRoute?['name'] ?? '').toString();
        _routeSearchController.text = routeName;
      }
      _showDealerDropdown = false;
    });
    _dealerSearchFocusNode.unfocus();
  }

  void _onRouteChanged(Map<String, dynamic>? route) {
    setState(() {
      _selectedRoute = route;
      if (route == null) {
        _routeSearchController.clear();
      } else {
        final routeName = (route['name'] ?? '').toString();
        if (_routeSearchController.text != routeName) {
          _routeSearchController.text = routeName;
        }
      }
      if (_isSalesmanCreator) {
        _selectedDealer = _resolveSalesmanDealerForRoute();
      } else if (_isDealerManagerCreator) {
        _selectedDealer ??= _resolveDealerForCurrentUser();
        _selectedRoute = _resolveRouteForDealer(_selectedDealer);
      }
      _syncDealerSearchFromSelection();
    });
  }

  void _applyRoleDefaults() {
    if (_isSalesmanLocked) {
      _selectedSalesman = widget.currentUser;
    }
    _dispatchBeforeDate = DateTime.now().add(const Duration(days: 1));

    if (_isDealerManagerCreator) {
      _selectedDealer = _resolveDealerForCurrentUser();
      _selectedRoute = _resolveRouteForDealer(_selectedDealer);
      return;
    }

    if (_isSalesmanCreator) {
      final routes = _salesmanRouteOptions;
      if (routes.length == 1) {
        _selectedRoute = routes.first;
      } else if (routes.isNotEmpty) {
        final routeFromUser = _findRouteByTokens([
          widget.currentUser.assignedSalesRoute,
          ...?widget.currentUser.assignedRoutes,
        ]);
        _selectedRoute = routeFromUser ?? routes.first;
      } else {
        _selectedRoute = null;
      }
      _selectedDealer = _resolveSalesmanDealerForRoute();
      return;
    }

    final routeFromDealer = _findRouteByTokens([
      _selectedDealer?.assignedRouteId,
      _selectedDealer?.assignedRouteName,
      _selectedDealer?.territory,
    ]);
    final routeFromUser = _findRouteByTokens([
      widget.currentUser.assignedSalesRoute,
      ...?widget.currentUser.assignedRoutes,
    ]);
    _selectedRoute = routeFromDealer ?? routeFromUser;
  }

  AppUser? _findSalesmanById(String salesmanId) {
    final target = salesmanId.trim();
    if (target.isEmpty) return null;
    for (final salesman in _salesmanOptions) {
      if (salesman.id == target) return salesman;
    }
    return null;
  }

  Dealer? _findDealerById(String dealerId) {
    final target = dealerId.trim();
    if (target.isEmpty) return null;
    for (final dealer in widget.dealers) {
      if (dealer.id == target) return dealer;
    }
    return null;
  }

  void _applyEditDefaults(RouteOrder order) {
    _selectedSource = order.source;
    _dispatchBeforeDate =
        order.dispatchBeforeDateTime ??
        DateTime.now().add(const Duration(days: 1));

    _selectedRoute =
        _findRouteById(order.routeId, salesmanScope: _isSalesmanCreator) ??
        _findRouteById(order.routeId) ??
        _findRouteByTokens([order.routeId, order.routeName]) ??
        <String, dynamic>{'id': order.routeId, 'name': order.routeName};

    _selectedSalesman = _isSalesmanLocked
        ? widget.currentUser
        : (_findSalesmanById(order.salesmanId) ?? _selectedSalesman);

    _selectedDealer =
        _findDealerById(order.dealerId) ??
        (_isDealerManagerCreator
            ? _resolveDealerForCurrentUser()
            : _selectedDealer);

    _items
      ..clear()
      ..addAll(
        order.items
            .where((item) => item.qty > 0 && item.productId.trim().isNotEmpty)
            .map((item) => item.copyWith(subtotal: item.qty * item.price)),
      );
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  void _onSelectProduct(Product product) {
    if (_hideAlreadyAddedProductsInSearch &&
        _addedProductIds.contains(product.id.trim())) {
      _showValidationMessage('${product.name} already added in cart.');
      return;
    }
    setState(() {
      _selectedProduct = product;
      _productSearchController.text = product.name;
      _productSearchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _productSearchController.text.length),
      );
      _showProductDropdown = false;
    });
    _productSearchFocusNode.unfocus();
  }

  void _normalizeQtyInput(String rawValue) {
    if (rawValue.isEmpty) {
      _qtyController.value = const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
      return;
    }
    var normalized = rawValue;
    if (normalized.length > 1) {
      normalized = normalized.replaceFirst(RegExp(r'^0+'), '');
      if (normalized.isEmpty) {
        normalized = '0';
      }
    }
    if (normalized == rawValue) return;
    _qtyController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  void _addItem() {
    final product = _selectedProduct;
    if (product == null) {
      _showValidationMessage('Select a product from the list.');
      return;
    }
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      _showValidationMessage('Enter a valid quantity.');
      return;
    }

    setState(() {
      final existingIndex = _items.indexWhere(
        (item) => item.productId == product.id,
      );
      if (existingIndex >= 0) {
        final existing = _items[existingIndex];
        final updatedQty = existing.qty + qty;
        _items[existingIndex] = existing.copyWith(
          qty: updatedQty,
          subtotal: updatedQty * existing.price,
        );
      } else {
        _items.add(
          RouteOrderItem(
            productId: product.id,
            name: product.name,
            qty: qty,
            price: product.price,
            subtotal: qty * product.price,
            baseUnit: product.baseUnit,
          ),
        );
      }
      _qtyController.text = '0';
      _selectedProduct = null;
      _productSearchController.clear();
      _showProductDropdown = false;
    });
  }

  void _submit() {
    final selectedRoute = _selectedRoute;
    final selectedSalesman = _isSalesmanLocked
        ? widget.currentUser
        : _selectedSalesman;
    final selectedDealer = _selectedDealer;

    if (_dispatchBeforeDate == null) {
      _showValidationMessage('Dispatch before date required hai.');
      return;
    }
    if (_items.isEmpty) {
      _showValidationMessage('At least one product item add karein.');
      return;
    }

    if (_isSalesmanCreator) {
      if (selectedRoute == null) {
        _showValidationMessage('Assigned route select karein.');
        return;
      }
      if (!widget.isEditMode) {
        final allowedRouteIds = _salesmanRouteOptions
            .map((route) => (route['id'] ?? '').toString())
            .where((id) => id.trim().isNotEmpty)
            .toSet();
        final selectedRouteId = (selectedRoute['id'] ?? '').toString();
        if (!allowedRouteIds.contains(selectedRouteId)) {
          _showValidationMessage(
            'Aap sirf assigned route par order bana sakte hain.',
          );
          return;
        }
      }
    } else if (_isDealerManagerCreator) {
      if (selectedDealer == null) {
        _showValidationMessage('Dealer select karein.');
        return;
      }
      if (selectedRoute == null) {
        _showValidationMessage('Selected dealer ka route mapped nahi hai.');
        return;
      }
    } else if (selectedRoute == null ||
        selectedSalesman == null ||
        selectedDealer == null) {
      _showValidationMessage('Route, salesman aur dealer required hain.');
      return;
    }

    final dealerId = _isSalesmanCreator
        ? '-'
        : (selectedDealer?.id.trim().isNotEmpty == true
              ? selectedDealer!.id
              : '-');
    final dealerName = _isSalesmanCreator
        ? '-'
        : (selectedDealer?.name.trim().isNotEmpty == true
              ? selectedDealer!.name
              : '-');
    final dispatchBeforeDate = DateTime(
      _dispatchBeforeDate!.year,
      _dispatchBeforeDate!.month,
      _dispatchBeforeDate!.day,
      23,
      59,
      59,
    ).toIso8601String();

    Navigator.of(context).pop(
      _RouteOrderDraft(
        routeId: (selectedRoute['id'] ?? '').toString(),
        routeName: (selectedRoute['name'] ?? '').toString(),
        salesmanId: selectedSalesman!.id,
        salesmanName: selectedSalesman.name,
        dealerId: dealerId,
        dealerName: dealerName,
        dispatchBeforeDate: dispatchBeforeDate,
        source: _selectedSource,
        isOrderBasedDispatch: true,
        items: List<RouteOrderItem>.from(_items),
      ),
    );
  }

  String _formatDispatchBeforeDate(DateTime? value) {
    if (value == null) return '';
    return DateFormat('dd MMM yyyy').format(value);
  }

  Future<void> _pickDispatchBeforeDate() async {
    final now = DateTime.now();
    final initial = _dispatchBeforeDate ?? now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, 12, 31),
      helpText: 'Dispatch Before Date',
    );
    if (picked == null || !mounted) return;
    setState(() => _dispatchBeforeDate = picked);
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return TextFormField(
      readOnly: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.lock_outline, size: 18),
      ),
    );
  }

  Widget _buildDatePickerField() {
    final value = _formatDispatchBeforeDate(_dispatchBeforeDate);
    return InkWell(
      onTap: _pickDispatchBeforeDate,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Dispatch Before Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          value.isEmpty ? 'Select date' : value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildProductFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _productCategoryFilter == _OrderProductCategoryFilter.all,
            onSelected: (_) => setState(() {
              _productCategoryFilter = _OrderProductCategoryFilter.all;
              _selectedProduct = null;
              _productSearchController.clear();
              _showProductDropdown = true;
            }),
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('Finished'),
            selected:
                _productCategoryFilter == _OrderProductCategoryFilter.finished,
            onSelected: (_) => setState(() {
              _productCategoryFilter = _OrderProductCategoryFilter.finished;
              _selectedProduct = null;
              _productSearchController.clear();
              _showProductDropdown = true;
            }),
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('Traded'),
            selected:
                _productCategoryFilter == _OrderProductCategoryFilter.traded,
            onSelected: (_) => setState(() {
              _productCategoryFilter = _OrderProductCategoryFilter.traded;
              _selectedProduct = null;
              _productSearchController.clear();
              _showProductDropdown = true;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesmanSearchField() {
    final hasQuery = _salesmanSearchController.text.trim().isNotEmpty;
    return TextField(
      controller: _salesmanSearchController,
      focusNode: _salesmanSearchFocusNode,
      onTap: () => setState(() => _showSalesmanDropdown = true),
      decoration: InputDecoration(
        labelText: 'Search Salesman',
        hintText: 'Type or select salesman',
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasQuery)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedSalesman = null;
                    _salesmanSearchController.clear();
                    _showSalesmanDropdown = false;
                  });
                },
                icon: const Icon(Icons.close),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showSalesmanDropdown = !_showSalesmanDropdown;
                  if (_showSalesmanDropdown) {
                    _salesmanSearchFocusNode.requestFocus();
                  } else {
                    _salesmanSearchFocusNode.unfocus();
                  }
                });
              },
              icon: Icon(
                _showSalesmanDropdown
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ),
          ],
        ),
      ),
      onChanged: (value) {
        final selected = _selectedSalesman;
        final isSameAsSelected =
            selected != null &&
            _normalizeToken(value) == _normalizeToken(selected.name);
        setState(() {
          _showSalesmanDropdown = true;
          if (!isSameAsSelected) {
            _selectedSalesman = null;
          }
        });
      },
    );
  }

  Widget _buildSalesmanSearchResults() {
    if (!_shouldShowSalesmanSearchResults) {
      return const SizedBox.shrink();
    }

    final matches = _filteredSalesmenBySearch;
    if (matches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No salesman found.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      );
    }

    final maxHeight = MediaQuery.sizeOf(context).height < 700 ? 220.0 : 280.0;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: matches.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Theme.of(context).dividerColor),
          itemBuilder: (context, index) {
            final salesman = matches[index];
            final isSelected = salesman.id == _selectedSalesman?.id;
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                salesman.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                salesman.email.isNotEmpty ? salesman.email : salesman.id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () => _onSelectSalesman(salesman),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDealerSearchField({required bool syncRouteFromDealer}) {
    final hasQuery = _dealerSearchController.text.trim().isNotEmpty;
    return TextField(
      controller: _dealerSearchController,
      focusNode: _dealerSearchFocusNode,
      onTap: () => setState(() => _showDealerDropdown = true),
      decoration: InputDecoration(
        labelText: 'Search Dealer',
        hintText: 'Type or select dealer',
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasQuery)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDealer = null;
                    _dealerSearchController.clear();
                    _showDealerDropdown = false;
                    if (syncRouteFromDealer) {
                      _selectedRoute = null;
                      _routeSearchController.clear();
                    }
                  });
                },
                icon: const Icon(Icons.close),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showDealerDropdown = !_showDealerDropdown;
                  if (_showDealerDropdown) {
                    _dealerSearchFocusNode.requestFocus();
                  } else {
                    _dealerSearchFocusNode.unfocus();
                  }
                });
              },
              icon: Icon(
                _showDealerDropdown
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ),
          ],
        ),
      ),
      onChanged: (value) {
        final selected = _selectedDealer;
        final isSameAsSelected =
            selected != null &&
            _normalizeToken(value) == _normalizeToken(selected.name);
        setState(() {
          _showDealerDropdown = true;
          if (!isSameAsSelected) {
            _selectedDealer = null;
            if (syncRouteFromDealer) {
              _selectedRoute = null;
              _routeSearchController.clear();
            }
          }
        });
      },
    );
  }

  Widget _buildDealerSearchResults({required bool syncRouteFromDealer}) {
    if (!_shouldShowDealerSearchResults) {
      return const SizedBox.shrink();
    }

    final matches = _filteredDealersBySearch;
    if (matches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No dealer found.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      );
    }

    final maxHeight = MediaQuery.sizeOf(context).height < 700 ? 220.0 : 280.0;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: matches.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Theme.of(context).dividerColor),
          itemBuilder: (context, index) {
            final dealer = matches[index];
            final isSelected = dealer.id == _selectedDealer?.id;
            final routeLabel =
                (dealer.assignedRouteName ?? dealer.territory ?? '').trim();
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                dealer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: routeLabel.isEmpty
                  ? null
                  : Text(
                      routeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () => _onSelectDealer(
                dealer,
                syncRouteFromDealer: syncRouteFromDealer,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRouteDropdown({
    required List<Map<String, dynamic>> options,
    required String label,
  }) {
    return DropdownMenu<String>(
      key: ValueKey<String>('route_menu_${_selectedRoute?['id'] ?? 'none'}'),
      controller: _routeSearchController,
      enableFilter: true,
      enableSearch: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      hintText: 'Search or select route',
      label: Text(label),
      initialSelection: (_selectedRoute?['id'] ?? '').toString().isEmpty
          ? null
          : (_selectedRoute?['id'] ?? '').toString(),
      dropdownMenuEntries: options.map((route) {
        final id = (route['id'] ?? '').toString();
        final name = (route['name'] ?? id).toString();
        return DropdownMenuEntry<String>(value: id, label: name);
      }).toList(),
      onSelected: (routeId) {
        if (routeId == null || routeId.trim().isEmpty) {
          _onRouteChanged(null);
          return;
        }
        final route = _findRouteById(
          routeId,
          salesmanScope: _isSalesmanCreator,
        );
        _onRouteChanged(route);
      },
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildProductSearchField() {
    final hasQuery = _productSearchController.text.trim().isNotEmpty;
    return TextField(
      controller: _productSearchController,
      focusNode: _productSearchFocusNode,
      onTap: () => setState(() => _showProductDropdown = true),
      decoration: InputDecoration(
        labelText: 'Search Product',
        hintText: 'Search or select product (Name / SKU)',
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasQuery)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedProduct = null;
                    _productSearchController.clear();
                    _showProductDropdown = false;
                  });
                },
                icon: const Icon(Icons.close),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showProductDropdown = !_showProductDropdown;
                  if (_showProductDropdown) {
                    _productSearchFocusNode.requestFocus();
                  } else {
                    _productSearchFocusNode.unfocus();
                  }
                });
              },
              icon: Icon(
                _showProductDropdown
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ),
          ],
        ),
      ),
      onChanged: (value) {
        final selected = _selectedProduct;
        final isSameAsSelected =
            selected != null &&
            _normalizeToken(value) == _normalizeToken(selected.name);
        setState(() {
          _showProductDropdown = true;
          if (!isSameAsSelected) {
            _selectedProduct = null;
          }
        });
      },
    );
  }

  Widget _buildProductSearchList() {
    if (!_shouldShowProductSearchResults) {
      return const SizedBox.shrink();
    }

    final query = _productSearchController.text.trim();
    final matches = query.isEmpty
        ? _searchableProducts.take(40).toList()
        : _filteredProductsBySearch;
    if (matches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No products found.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      );
    }

    final maxHeight = MediaQuery.sizeOf(context).height < 700 ? 220.0 : 280.0;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: matches.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Theme.of(context).dividerColor),
          itemBuilder: (context, index) {
            final product = matches[index];
            final label = _isFinishedProduct(product) ? 'Finished' : 'Traded';
            final isSelected = product.id == _selectedProduct?.id;
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '$label | SKU: ${product.sku} | Available: ${product.stock.toStringAsFixed(0)} ${product.baseUnit}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () => _onSelectProduct(product),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    );
  }

  Widget _buildCreateButton() {
    return FilledButton(onPressed: _submit, child: Text(_submitLabel));
  }

  Widget _buildFormFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isSalesmanCreator) ...[
          _buildRouteDropdown(
            options: _salesmanRouteOptions,
            label: 'Search Route',
          ),
          if (_salesmanRouteOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Aapko koi route assigned nahi hai.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ] else if (!_isDealerManagerCreator) ...[
          _buildRouteDropdown(options: _routeOptions, label: 'Route'),
          const SizedBox(height: 12),
          _buildSalesmanSearchField(),
          _buildSalesmanSearchResults(),
          const SizedBox(height: 12),
          _buildDealerSearchField(syncRouteFromDealer: false),
          _buildDealerSearchResults(syncRouteFromDealer: false),
          const SizedBox(height: 12),
        ],
        if (_isDealerManagerCreator) ...[
          _buildDealerSearchField(syncRouteFromDealer: true),
          _buildDealerSearchResults(syncRouteFromDealer: true),
          const SizedBox(height: 12),
          _buildReadOnlyField(
            label: 'Route',
            value: (_selectedRoute?['name'] ?? 'Dealer route not mapped')
                .toString(),
          ),
          const SizedBox(height: 12),
        ],
        _buildDatePickerField(),
        if (widget.createdByRole == UserRole.admin ||
            widget.createdByRole == UserRole.owner) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<RouteOrderSource>(
            isExpanded: true,
            key: ValueKey<String>(_selectedSource.value),
            initialValue: _selectedSource,
            decoration: const InputDecoration(
              labelText: 'Source',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<RouteOrderSource>(
                value: RouteOrderSource.salesman,
                child: Text('salesman'),
              ),
              DropdownMenuItem<RouteOrderSource>(
                value: RouteOrderSource.dealerManager,
                child: Text('dealerManager'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedSource = value);
            },
          ),
        ],
        const SizedBox(height: 12),
        _buildProductFilterChips(),
        const SizedBox(height: 8),
        _buildProductSearchField(),
        _buildProductSearchList(),
        if (_selectedProduct != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Product',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: Text(
                    '${_selectedProduct!.name} (Available: ${_selectedProduct!.stock.toStringAsFixed(0)} ${_selectedProduct!.baseUnit})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _normalizeQtyInput,
                  decoration: const InputDecoration(
                    labelText: 'Qty',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addItem, child: const Text('Add')),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (_items.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Subtotal')),
                DataColumn(label: Text('')),
              ],
              rows: _items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text(item.name)),
                    DataCell(Text(item.qty.toString())),
                    DataCell(Text(item.price.toStringAsFixed(2))),
                    DataCell(Text(item.subtotal.toStringAsFixed(2))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _items.removeAt(index)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width < 700 ? 560.0 : 560.0;

    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(title: Text(_dialogTitle)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _buildFormFields(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCancelButton(),
                    const SizedBox(width: 8),
                    _buildCreateButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(_dialogTitle),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(child: _buildFormFields()),
      ),
      actions: [_buildCancelButton(), _buildCreateButton()],
    );
  }
}

class _SelectVehicleDialog extends StatefulWidget {
  final List<Vehicle> vehicles;

  const _SelectVehicleDialog({required this.vehicles});

  @override
  State<_SelectVehicleDialog> createState() => _SelectVehicleDialogState();
}

class _SelectVehicleDialogState extends State<_SelectVehicleDialog> {
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dispatch From Order'),
      content: SizedBox(
        width: 420,
        child: DropdownButtonFormField<Vehicle>(
          isExpanded: true,
          key: ValueKey<String>('vehicle_${_selectedVehicle?.id ?? 'none'}'),
          initialValue: _selectedVehicle,
          decoration: const InputDecoration(
            labelText: 'Vehicle',
            border: OutlineInputBorder(),
          ),
          items: widget.vehicles.map((vehicle) {
            return DropdownMenuItem<Vehicle>(
              value: vehicle,
              child: Text(
                '${vehicle.number} (${vehicle.name})',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedVehicle = value),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedVehicle == null
              ? null
              : () => Navigator.of(context).pop(_selectedVehicle),
          child: const Text('Dispatch'),
        ),
      ],
    );
  }
}
