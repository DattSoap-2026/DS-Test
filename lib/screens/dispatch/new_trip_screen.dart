import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dispatch_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/users_service.dart';
import '../../models/types/sales_types.dart';
import '../../models/types/user_types.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/unified_card.dart';
import '../../utils/responsive.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  late final DispatchService _dispatchService;
  late final VehiclesService _vehiclesService;
  late final UsersService _usersService;

  bool _isLoading = true;
  List<Sale> _availableSales = [];
  List<Vehicle> _vehicles = [];
  List<AppUser> _drivers = [];

  final List<String> _selectedSaleIds = [];
  Vehicle? _selectedVehicle;
  AppUser? _selectedDriver;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dispatchService = context.read<DispatchService>();
    _vehiclesService = context.read<VehiclesService>();
    _usersService = context.read<UsersService>();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sales = await _dispatchService.getDispatchableSales();
      final vehicles = await _vehiclesService.getVehicles(status: 'active');
      final drivers = await _usersService.getUsers(role: UserRole.driver);

      if (mounted) {
        setState(() {
          _availableSales = sales;
          _vehicles = vehicles;
          _drivers = drivers;
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

  double get _totalAmount {
    return _availableSales
        .where((s) => _selectedSaleIds.contains(s.id))
        .fold(0, (sum, s) => sum + s.totalAmount);
  }

  int get _totalItems {
    return _availableSales
        .where((s) => _selectedSaleIds.contains(s.id))
        .fold(
          0,
          (sum, s) =>
              sum + s.items.fold(0, (iSum, item) => iSum + item.quantity),
        );
  }

  Map<String, Sale> get _salesById => {
    for (final sale in _availableSales) sale.id: sale,
  };

  List<Sale> get _selectedSales =>
      _selectedSaleIds.map((id) => _salesById[id]).whereType<Sale>().toList();

  Future<void> _createTrip() async {
    if (_selectedSaleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one sale')),
      );
      return;
    }
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
      return;
    }
    if (_selectedDriver == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a driver')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _dispatchService.createDeliveryTrip(
        vehicleNumber: _selectedVehicle!.number,
        driverName: _selectedDriver!.name,
        driverPhone: _selectedDriver!.phone,
        salesIds: _selectedSaleIds,
        notes: _notesController.text,
      );

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery Trip created successfully')),
        );
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

  void _toggleSaleSelection(Sale sale) {
    setState(() {
      if (_selectedSaleIds.contains(sale.id)) {
        _selectedSaleIds.remove(sale.id);
      } else {
        _selectedSaleIds.add(sale.id);
      }
    });
  }

  void _removeSelectedSale(String id) {
    setState(() => _selectedSaleIds.remove(id));
  }

  void _reorderSelectedSales(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final id = _selectedSaleIds.removeAt(oldIndex);
      _selectedSaleIds.insert(newIndex, id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Create New Trip',
            subtitle: 'Assign vehicle and driver to pending orders',
            icon: Icons.add_road_rounded,
            color: theme.colorScheme.primary,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: Responsive.screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleDriverSection(),
                  const SizedBox(height: 24),
                  _buildOrdersLayout(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  // Extra bottom padding for footer
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 100),
                  ),
                ],
              ),
            ),
          ),
          _buildSummaryFooter(),
        ],
      ),
    );
  }

  Widget _buildVehicleDriverSection() {
    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Vehicle>(
                  initialValue: _selectedVehicle,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Vehicle',
                    prefixIcon: Icon(Icons.local_shipping_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  items: _vehicles
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            '${v.name} (${v.number})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVehicle = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<AppUser>(
            initialValue: _selectedDriver,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Driver',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            items: _drivers
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (d) => setState(() => _selectedDriver = d),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersLayout() {
    final isWide = Responsive.width(context) >= 1000;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildRouteSequenceSection()),
          const SizedBox(width: 24),
          Expanded(child: _buildSalesSelectionList()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRouteSequenceSection(),
        const SizedBox(height: 24),
        _buildSalesSelectionList(),
      ],
    );
  }

  Widget _buildRouteSequenceSection() {
    final theme = Theme.of(context);
    final selectedSales = _selectedSales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Route Sequence',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedSaleIds.length} stops',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Drag to reorder stops in delivery sequence',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (selectedSales.isEmpty)
          UnifiedCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.drag_handle_rounded,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select orders to build a route',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: selectedSales.length,
            onReorder: _reorderSelectedSales,
            itemBuilder: (context, index) {
              final sale = selectedSales[index];
              return _buildSelectedOrderTile(sale, index);
            },
          ),
      ],
    );
  }

  Widget _buildSelectedOrderTile(Sale sale, int index) {
    final theme = Theme.of(context);
    return Padding(
      key: ValueKey('selected-${sale.id}'),
      padding: const EdgeInsets.only(bottom: 12),
      child: UnifiedCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildSequenceBadge(index + 1),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.recipientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sale.items.length} items - Rs ${sale.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () => _removeSelectedSale(sale.id),
              tooltip: 'Remove',
              icon: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSequenceBadge(int index) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        index.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSalesSelectionList() {
    final theme = Theme.of(context);
    late final Widget content;
    if (_availableSales.isEmpty) {
      content = UnifiedCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No pending sales orders ready for dispatch',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    } else {
      content = ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _availableSales.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sale = _availableSales[index];
          final isSelected = _selectedSaleIds.contains(sale.id);
          return UnifiedCard(
            padding: EdgeInsets.zero,
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              value: isSelected,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                if (val == null) return;
                _toggleSaleSelection(sale);
              },
              title: Text(
                sale.recipientName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${sale.items.length} items · ₹${sale.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Orders',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildNotesSection() {
    return UnifiedCard(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Route Notes / Instructions',
          border: OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: EdgeInsets.all(16),
          hintText: 'e.g. Deliver via Bypass, Priority for Shop X',
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildSummaryFooter() {
    final theme = Theme.of(context);
    return Container(
      // Reverting to Container for footer as GlassContainer might not be suited for bottom fixed area or we can use it
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedSaleIds.length} Orders Selected',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Total Qty: $_totalItems · Value: ₹${_totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            CustomButton(
              label: 'CONFIRM TRIP',
              icon: Icons.check_rounded,
              onPressed: _isLoading ? null : _createTrip,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
