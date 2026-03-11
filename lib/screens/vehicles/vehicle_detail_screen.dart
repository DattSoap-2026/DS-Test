import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/vehicles_service.dart';
import '../../services/diesel_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import 'edit_vehicle_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;
  final Vehicle? vehicle;

  const VehicleDetailScreen({super.key, required this.vehicleId, this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen>
    with SingleTickerProviderStateMixin {
  static const int _historyTabCount = 3;

  late TabController _tabController;
  late VehiclesService _vehiclesService;
  late DieselService _dieselService;

  Vehicle? _vehicle;
  List<MaintenanceLog> _maintenanceLogs = [];
  List<DieselLog> _dieselLogs = [];
  List<TyreLog> _tyreLogs = [];
  bool _isLoading = true;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
    _vehiclesService = context.read<VehiclesService>();
    _dieselService = context.read<DieselService>();
    _tabController = TabController(
      length: _historyTabCount,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // If vehicle object is stale or null, fetch it
      final vehicleFuture = _vehiclesService.getVehicle(widget.vehicleId);
      final maintFuture = _vehiclesService.getMaintenanceLogs(
        vehicleId: widget.vehicleId,
      );
      final dieselFuture = _dieselService.getDieselLogs(
        vehicleId: widget.vehicleId,
      );
      final tyreFuture = _vehiclesService.getTyreLogs(
        vehicleId: widget.vehicleId,
      );
      final results = await Future.wait([
        vehicleFuture,
        maintFuture,
        dieselFuture,
        tyreFuture,
      ]);

      if (mounted) {
        setState(() {
          _vehicle = results[0] as Vehicle?;
          _maintenanceLogs = results[1] as List<MaintenanceLog>;
          _dieselLogs = results[2] as List<DieselLog>;
          _tyreLogs = results[3] as List<TyreLog>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicle details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _vehicle == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final vehicle = _vehicle!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          vehicle.number,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditVehicleScreen(vehicle: vehicle),
                ),
              );
              if (result == true) _loadData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleSummaryCard(vehicle),
            const SizedBox(height: 16),
            if (Responsive.isMobile(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildComplianceCard(vehicle),
                  const SizedBox(height: 16),
                  _buildLifetimeAnalytics(vehicle),
                  const SizedBox(height: 16),
                  _buildHistoryTabs(),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildComplianceCard(vehicle),
                        const SizedBox(height: 16),
                        _buildLifetimeAnalytics(vehicle),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: _buildHistoryTabs()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSummaryCard(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.number,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      vehicle.model ?? vehicle.name,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(vehicle.status),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'MAINTENANCE',
                _currencyFormat.format(vehicle.totalMaintenanceCost),
              ),
              _buildSummaryItem(
                'TYRES',
                _currencyFormat.format(vehicle.totalTyreCost),
              ),
              _buildSummaryItem(
                'FUEL',
                _currencyFormat.format(vehicle.totalDieselCost),
              ),
              _buildSummaryItem(
                'DISTANCE',
                '${vehicle.totalDistance.toStringAsFixed(0)} KM',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceCard(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance Details',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildComplianceRow('Insurance', vehicle.insuranceExpiryDate),
          _buildComplianceRow('PUC', vehicle.pucExpiryDate),
          _buildComplianceRow('Permit', vehicle.permitExpiryDate),
          _buildComplianceRow('Fitness', vehicle.fitnessExpiryDate),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(String label, DateTime? expiry) {
    final bool isExpired = expiry != null && expiry.isBefore(DateTime.now());
    final bool isExpiringSoon =
        expiry != null &&
        !isExpired &&
        expiry.difference(DateTime.now()).inDays < 30;

    Color statusColor = AppColors.success;
    String statusText = 'Active';

    if (expiry == null) {
      statusColor = Theme.of(context).disabledColor;
      statusText = 'N/A';
    } else if (isExpired) {
      statusColor = AppColors.error;
      statusText = 'Expired';
    } else if (isExpiringSoon) {
      statusColor = AppColors.warning;
      statusText = 'Expiring';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeAnalytics(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lifetime Analytics',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularCounter(
                Icons.build,
                'Service',
                vehicle.totalServicesCompleted,
                AppColors.info,
              ),
              _buildCircularCounter(
                Icons.local_gas_station,
                'Fuel',
                _dieselLogs.length,
                AppColors.warning,
              ),
              _buildCircularCounter(
                Icons.change_circle,
                'Tyres',
                _tyreLogs.length,
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCounter(
    IconData icon,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: 0.7, // Visual placeholder
                strokeWidth: 3,
                color: color,
                backgroundColor: color.withValues(alpha: 0.1),
              ),
            ),
            Icon(icon, color: color, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTabs() {
    return SizedBox(
      height: Responsive.clamp(context, min: 360, max: 520, ratio: 0.55),
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          ThemedTabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Service'),
              Tab(text: 'Fuel'),
              Tab(text: 'Tyres'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServiceTab(),
                _buildDieselTab(),
                _buildTyresTab(),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = AppColors.success;
    String label = 'Active';
    if (status == 'inactive') {
      color = AppColors.error;
      label = 'Inactive';
    } else if (status == 'under_maintenance') {
      color = AppColors.warning;
      label = 'In Service';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTab() {
    if (_maintenanceLogs.isEmpty) {
      return const Center(child: Text('No service history'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _maintenanceLogs.length,
      itemBuilder: (context, index) {
        final log = _maintenanceLogs[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const Icon(Icons.build_circle, color: AppColors.info),
            title: Text(
              _formatDateSafe(log.serviceDate),
            ),
            subtitle: Text(log.type),
            trailing: Text(_currencyFormat.format(log.totalCost)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (log.mechanicName?.isNotEmpty == true)
                      Text('Mechanic: ${log.mechanicName}'),
                    if (log.description.isNotEmpty)
                      Text('Notes: ${log.description}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Parts:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...log.items.map(
                      (e) => Text(
                        '• ${e.partName}: ${e.quantity} @ ₹${e.price.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDieselTab() {
    // Simple list for now, chart can be added later
    if (_dieselLogs.isEmpty) return const Center(child: Text('No fuel logs'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dieselLogs.length,
      itemBuilder: (context, index) {
        final log = _dieselLogs[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.local_gas_station, color: AppColors.warning),
            title: Text('${log.liters.toStringAsFixed(1)}L @ ₹${log.rate}'),
            subtitle: Text(
              _formatDateSafe(log.fillDate, pattern: 'dd MMM'),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFormat.format(log.totalCost),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (log.cycleEfficiency != null)
                  Text(
                    '${log.cycleEfficiency!.toStringAsFixed(1)} kmpl',
                    style: const TextStyle(fontSize: 12, color: AppColors.success),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTyresTab() {
    // Show tyre logs filtered
    if (_tyreLogs.isEmpty) return const Center(child: Text('No tyre history'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tyreLogs.length,
      itemBuilder: (context, index) {
        final log = _tyreLogs[index];
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(log.reason), // 'Installation'
            subtitle: Text('${log.items.length} tyres affected'),
            trailing: Text(
              _formatDateSafe(log.installationDate, pattern: 'dd MMM'),
            ),
          ),
        );
      },
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }
}
