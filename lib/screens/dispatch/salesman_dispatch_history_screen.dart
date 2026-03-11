import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/inventory_service.dart';
import '../../models/inventory/stock_dispatch.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import '../../core/theme/app_colors.dart';

class SalesmanDispatchHistoryScreen extends StatefulWidget {
  const SalesmanDispatchHistoryScreen({super.key});

  @override
  State<SalesmanDispatchHistoryScreen> createState() =>
      _SalesmanDispatchHistoryScreenState();
}

class _SalesmanDispatchHistoryScreenState
    extends State<SalesmanDispatchHistoryScreen> {
  late final InventoryService _inventoryService;
  bool _isLoading = true;
  List<StockDispatch> _allDispatches = [];
  List<StockDispatch> _dispatches = [];
  List<String> _routeOptions = const [];
  String? _selectedRoute;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryService>();
    _loadDispatches();
  }

  Future<void> _loadDispatches() async {
    try {
      final auth = context.read<AuthProvider>().state;
      if (auth.user == null) {
        if (!mounted) return;
        setState(() {
          _allDispatches = const [];
          _dispatches = const [];
          _routeOptions = const [];
          _isLoading = false;
          _error = 'User not authenticated';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dispatches = await _inventoryService.getDispatchesForSalesman(
        salesmanId: auth.user!.id,
        limit: 50, // Reasonable limit for history
      );

      if (mounted) {
        setState(() {
          _allDispatches = dispatches;
          _routeOptions = _extractRouteOptions(dispatches);
          if (_selectedRoute != null &&
              !_routeOptions.contains(_selectedRoute)) {
            _selectedRoute = null;
          }
          _dispatches = _applyRouteFilter(
            dispatches,
            selectedRoute: _selectedRoute,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<String> _extractRouteOptions(List<StockDispatch> dispatches) {
    final routeSet = <String>{};
    for (final dispatch in dispatches) {
      final route = dispatch.dispatchRoute.trim().isNotEmpty
          ? dispatch.dispatchRoute.trim()
          : dispatch.salesRoute.trim();
      if (route.isNotEmpty) {
        routeSet.add(route);
      }
    }
    final routes = routeSet.toList()..sort();
    return routes;
  }

  List<StockDispatch> _applyRouteFilter(
    List<StockDispatch> source, {
    String? selectedRoute,
  }) {
    final route = selectedRoute?.trim();
    if (route == null || route.isEmpty) {
      return source;
    }
    return source.where((dispatch) {
      return dispatch.dispatchRoute.trim() == route ||
          dispatch.salesRoute.trim() == route;
    }).toList();
  }

  Future<void> _handleReceive(StockDispatch dispatch) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => ResponsiveAlertDialog(
          title: const Text('Confirm Receipt'),
          content: Text(
            'Are you sure you want to receive Dispatch ${dispatch.dispatchId}?\n\n'
            'This will add ${dispatch.totalQuantity} items to your stock.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm Receive'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      if (!mounted) return;

      // Optimistic Update or Loading Overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      await _inventoryService.receiveDispatch(dispatch.id);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispatch received successfully!')),
      );

      _loadDispatches(); // Refresh list to show updated status
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error receiving dispatch: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDispatches,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loadDispatches,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _dispatches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dispatch history found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_routeOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey<String?>(
                        _selectedRoute == null
                            ? 'all_routes'
                            : 'route_${_selectedRoute!}',
                      ),
                      initialValue: _selectedRoute,
                      decoration: const InputDecoration(
                        labelText: 'Route Filter',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Routes'),
                        ),
                        ..._routeOptions.map(
                          (route) => DropdownMenuItem<String?>(
                            value: route,
                            child: Text(route),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoute = value;
                          _dispatches = _applyRouteFilter(
                            _allDispatches,
                            selectedRoute: _selectedRoute,
                          );
                        });
                      },
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dispatches.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      return _buildDispatchCard(_dispatches[index], theme);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDispatchCard(StockDispatch dispatch, ThemeData theme) {
    final isReceived = dispatch.status == DispatchStatus.received;
    final dateStr = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(dispatch.createdAt);

    final vehicleLabel = dispatch.vehicleNumber.trim().isNotEmpty
        ? dispatch.vehicleNumber
        : 'Unknown';

    return UnifiedCard(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: const Border(), // Remove default border
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isReceived
                ? Colors.green.withValues(alpha: 0.1)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isReceived
                ? Icons.check_circle_outline
                : Icons.local_shipping_outlined,
            color: isReceived ? Colors.green : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          dispatch.dispatchId,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildTag(
                  dispatch.status.name.toUpperCase(),
                  isReceived ? Colors.green : Colors.orange,
                  theme,
                ),
                if (dispatch.dispatchRoute.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildTag(
                    dispatch.dispatchRoute.trim(),
                    Colors.blueGrey,
                    theme,
                  ),
                ],
                if (dispatch.isOrderBasedDispatch) ...[
                  const SizedBox(width: 8),
                  _buildTag(
                    dispatch.orderNo?.trim().isNotEmpty == true
                        ? dispatch.orderNo!.trim()
                        : 'ORDER',
                    Colors.deepPurple,
                    theme,
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  '${dispatch.totalQuantity} Items',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Vehicle: $vehicleLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Items:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...dispatch.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item.productName)),
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isReceived)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _handleReceive(dispatch),
                      icon: const Icon(Icons.check),
                      label: const Text('Receive Stock'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildTag(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
