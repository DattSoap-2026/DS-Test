import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/inventory_service.dart';
import '../../services/users_service.dart';
import '../../models/inventory/stock_dispatch.dart';
import '../../models/types/user_types.dart';

class AdminDispatchHistoryScreen extends StatefulWidget {
  const AdminDispatchHistoryScreen({super.key});

  @override
  State<AdminDispatchHistoryScreen> createState() =>
      _AdminDispatchHistoryScreenState();
}

class _AdminDispatchHistoryScreenState
    extends State<AdminDispatchHistoryScreen> {
  late final InventoryService _inventoryService;
  late final UsersService _usersService;

  bool _isLoading = true;
  List<StockDispatch> _dispatches =
      []; // All fetched dispatches (could be paginated)
  List<AppUser> _salesmen = [];

  // Filters
  DateTimeRange? _dateRange;
  AppUser? _selectedSalesman;

  // Stats
  int _totalDispatches = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _inventoryService = context.read<InventoryService>();
    _usersService = context.read<UsersService>();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final salesmen = await _usersService.getUsers(role: UserRole.salesman);
      final now = DateTime.now();
      _dateRange = DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      );

      setState(() {
        _salesmen = salesmen;
      });

      await _loadDispatches();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadDispatches() async {
    setState(() => _isLoading = true);
    try {
      final endDate = _dateRange?.end.add(const Duration(days: 1));
      final dispatches = await _inventoryService.getAllDispatches(
        salesmanId: _selectedSalesman?.id,
        startDate: _dateRange?.start,
        endDate: endDate,
      );

      setState(() {
        _dispatches = dispatches;
        _isLoading = false;
        _calculateStats();
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _calculateStats() {
    _totalDispatches = _dispatches.length;
    _totalItems = _dispatches.fold(0, (sum, d) => sum + d.totalQuantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch History (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDispatches,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildStats(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _dispatches.length,
                    itemBuilder: (ctx, index) =>
                        _buildDispatchTile(_dispatches[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<AppUser>(
                value: _selectedSalesman,
                hint: const Text('All Salesmen'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Salesmen'),
                  ),
                  ..._salesmen.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s.name)),
                  ),
                ],
                onChanged: (val) {
                  setState(() => _selectedSalesman = val);
                  _loadDispatches();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                  _loadDispatches();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Dispatches', '$_totalDispatches'),
          _statItem('Total Items', '$_totalItems'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDispatchTile(StockDispatch dispatch) {
    final statusColor = dispatch.status == DispatchStatus.received
        ? Colors.green
        : Colors.orange;
    final recipientName = _resolveDispatchRecipient(dispatch);
    final vehicleLabel = dispatch.vehicleNumber.trim().isNotEmpty
        ? dispatch.vehicleNumber
        : 'Unknown';
    return ExpansionTile(
      title: Text(recipientName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dispatch.dispatchId} - ${DateFormat('MMM dd').format(dispatch.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  dispatch.status.name.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Text('${dispatch.totalQuantity} Items'),
            ],
          ),
        ],
      ),
      children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.person_outline, size: 18),
          title: const Text('Dispatched To'),
          subtitle: Text(recipientName),
        ),
        if ((dispatch.dealerName ?? '').trim().isNotEmpty)
          ListTile(
            dense: true,
            leading: const Icon(Icons.store_mall_directory_outlined, size: 18),
            title: const Text('Source Dealer'),
            subtitle: Text(dispatch.dealerName!.trim()),
          ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.local_shipping_outlined, size: 18),
          title: const Text('Vehicle'),
          subtitle: Text(vehicleLabel),
        ),
        ...dispatch.items.map(
          (item) => ListTile(
            title: Text(item.productName),
            trailing: Text('${item.quantity} ${item.unit}'),
            dense: true,
          ),
        ),
      ],
    );
  }

  String _resolveDispatchRecipient(StockDispatch dispatch) {
    final salesmanName = dispatch.salesmanName.trim();
    final dealerName = (dispatch.dealerName ?? '').trim();
    if (salesmanName.isNotEmpty && dealerName.isNotEmpty) {
      return '$salesmanName -> $dealerName';
    }
    if (salesmanName.isNotEmpty) return salesmanName;
    if (dealerName.isNotEmpty) return dealerName;
    return 'Unknown Recipient';
  }
}
