import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../services/vehicles_service.dart';
import '../../../widgets/ui/custom_card.dart';
import '../../../widgets/ui/themed_filter_chip.dart';
import '../../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class TyresTab extends StatefulWidget {
  const TyresTab({super.key});

  @override
  State<TyresTab> createState() => _TyresTabState();
}

class _TyresTabState extends State<TyresTab>
    with SingleTickerProviderStateMixin {
  late final VehiclesService _vehiclesService;
  late TabController _tabController;

  bool _isLoading = true;
  List<TyreStockItem> _stock = [];
  List<TyreLog> _logs = [];
  List<Vehicle> _vehicles = [];
  List<String> _brands = [];

  // Filters
  String _statusFilter = 'All'; // All, In Stock, Mounted, Scrapped
  String _brandFilter = 'All';

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _vehiclesService
            .getAvailableTyres(), // Note: This gets 'In Stock' only? Need ALL?
        _vehiclesService.getTyreLogs(limitCount: 50),
        _vehiclesService.getVehicles(),
        _vehiclesService.getTyreBrands(),
        _vehiclesService.getAllTyres(), // Custom method to get ALL tyres
      ]);

      // getAvailableTyres only returns 'In Stock'. We want complete inventory.
      // So use index 4 (custom fetch) for stock list.

      if (mounted) {
        setState(() {
          _logs = futures[1] as List<TyreLog>;
          _vehicles = futures[2] as List<Vehicle>;
          _brands = futures[3] as List<String>;
          _stock = futures[4] as List<TyreStockItem>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: ThemedTabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 6,
            ),
            tabs: const [
              Tab(text: 'Tyre Inventory'),
              Tab(text: 'History Logs'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildInventoryTab(), _buildHistoryTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryTab() {
    // Filter Stock
    final filteredStock = _stock.where((item) {
      if (_statusFilter != 'All' && item.status != _statusFilter) return false;
      if (_brandFilter != 'All' && item.brand != _brandFilter) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                _buildFilterChip(
                  'In Stock',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                _buildFilterChip(
                  'Mounted',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                _buildFilterChip(
                  'Scrapped',
                  _statusFilter,
                  (v) => setState(() => _statusFilter = v),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _brandFilter,
                  items: ['All', ..._brands]
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _brandFilter = v!),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _openAddStockPage,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Add Stock'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredStock.length + 1, // +1 for Fab spacer
              itemBuilder: (context, index) {
                if (index == filteredStock.length) {
                  return const SizedBox(height: 80);
                }
                final item = filteredStock[index];
                return _buildTyreCard(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String current,
    Function(String) onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ThemedFilterChip(
        label: label,
        selected: current == label,
        onSelected: () => onSelect(label),
      ),
    );
  }

  Widget _buildTyreCard(TyreStockItem item) {
    final isMounted = item.status == 'Mounted';
    final isScrapped = item.status == 'Scrapped';

    final theme = Theme.of(context);
    Color statusColor = theme.colorScheme.onSurfaceVariant;
    if (item.status == 'In Stock' || item.status == 'Available') {
      statusColor = AppColors.success;
    }
    if (isMounted) statusColor = AppColors.info;
    if (isScrapped) statusColor = AppColors.error;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.brand} ${item.size}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('S/N: ${item.serialNumber} - ${item.type}'),
            if (isMounted)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mounted on: ${item.vehicleNumber ?? "Unknown"} (${item.position ?? "Unknown Pos"})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            if (item.notes != null && item.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Note: ${item.notes}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isScrapped && !isMounted)
                  TextButton.icon(
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('Mount'),
                    onPressed: () => _showMountDialog(item),
                  ),
                if (isMounted)
                  TextButton.icon(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.warning,
                    ),
                    label: const Text('Dismount'),
                    onPressed: () => _showDismountDialog(item),
                  ),
                if (!isScrapped && !isMounted)
                  TextButton(
                    child: const Text(
                      'Scrap',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onPressed: () => _changeStatus(item, 'Scrapped'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_logs.isEmpty) return const Center(child: Text('No history found'));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.history)),
            title: Text('${log.vehicleNumber} - ${log.reason}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_formatDate(log.installationDate)}'),
                Text('${log.items.length} tyres affected'),
              ],
            ),
            trailing: Text(
              '\u20B9${log.totalCost.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // --- Actions ---

  Future<void> _openAddStockPage() async {
    final refresh = await context.push<bool>('/dashboard/vehicles/tyres/stock');
    if (!mounted) return;
    if (refresh == true) {
      await _loadData();
    }
  }

  Future<void> _showMountDialog(TyreStockItem item) async {
    if (_vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No vehicles available to mount this tyre'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Vehicle? selectedVehicle;
    String position = 'Front Right';
    DateTime date = DateTime.now();

    final positions = [
      'Front Right',
      'Front Left',
      'Rear Right Outer',
      'Rear Right Inner',
      'Rear Left Outer',
      'Rear Left Inner',
      'Spare',
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ResponsiveAlertDialog(
          title: Text('Mount Tyre ${item.serialNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Vehicle>(
                decoration: const InputDecoration(labelText: 'Select Vehicle'),
                items: _vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text('${v.name} (${v.number})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedVehicle = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(position),
                initialValue: position,
                decoration: const InputDecoration(labelText: 'Position'),
                items: positions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => position = v!),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(DateFormat('dd MMM yyyy').format(date)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedVehicle == null) return;

                final log = TyreLog(
                  id: '',
                  vehicleId: selectedVehicle!.id,
                  vehicleNumber: selectedVehicle!.number,
                  installationDate: date.toIso8601String(),
                  reason: 'Installation',
                  items: [
                    TyreLogItem(
                      tyrePosition: position,
                      newTyreType: item.type,
                      tyreItemId: item.id,
                      tyreBrand: item.brand,
                      tyreNumber: item.serialNumber,
                      cost: item.cost,
                      oldTyreDisposition:
                          'Kept as Spare', // Default if checking old tyre not implemented yet
                    ),
                  ],
                  totalCost: 0, // Installation cost? keeping 0 for now
                );

                await _vehiclesService.addTyreLog(log);
                if (context.mounted) Navigator.pop(context);
                _loadData(); // Refresh
              },
              child: const Text('Mount'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDismountDialog(TyreStockItem item) async {
    String disposition = 'Kept as Spare';
    String reason = 'Rotation';

    // Find vehicle ID
    final vehicle = _vehicles.cast<Vehicle?>().firstWhere(
      (v) => v?.number == item.vehicleNumber,
      orElse: () => null,
    );
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle not found for this tyre'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ResponsiveAlertDialog(
          title: const Text('Dismount Tyre'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${item.brand} (S/N: ${item.serialNumber})'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(disposition),
                initialValue: disposition,
                decoration: const InputDecoration(labelText: 'Disposition'),
                items: ['Kept as Spare', 'Remolded', 'Scrapped']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => disposition = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: reason,
                decoration: const InputDecoration(labelText: 'Reason'),
                onChanged: (v) => reason = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final log = TyreLog(
                  id: '',
                  vehicleId: vehicle.id, // Best effort
                  vehicleNumber: item.vehicleNumber ?? 'Unknown',
                  installationDate: DateTime.now().toIso8601String(),
                  reason: reason,
                  items: [
                    TyreLogItem(
                      tyrePosition: item.position ?? 'Unknown',
                      newTyreType: '', // None
                      tyreItemId: '', // None, we are dismounting
                      tyreBrand: '',
                      tyreNumber: '',
                      cost: 0,
                      oldTyreDisposition: disposition,
                      oldTyreBrand: item.brand,
                      oldTyreNumber: item.serialNumber,
                      oldTyreItemId: item.id,
                    ),
                  ],
                  totalCost: 0,
                );

                await _vehiclesService.addTyreLog(log);
                if (context.mounted) Navigator.pop(context);
                _loadData();
              },
              child: const Text('Dismount'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeStatus(TyreStockItem item, String status) async {
    try {
      await _vehiclesService.updateTyreStockStatus(
        tyreItemId: item.id,
        status: status,
        vehicleNumber: status == 'Mounted' ? item.vehicleNumber : null,
        position: status == 'Mounted' ? item.position : null,
        notes: status == 'Scrapped'
            ? 'Marked as scrapped from tyre inventory'
            : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tyre status updated to $status')));
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update tyre status: $e')),
      );
    }
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
