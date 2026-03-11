import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/vehicles_service.dart';
import '../../services/diesel_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class VehicleAnalyticsDashboard extends StatefulWidget {
  const VehicleAnalyticsDashboard({super.key});

  @override
  State<VehicleAnalyticsDashboard> createState() => _VehicleAnalyticsDashboardState();
}

class _VehicleAnalyticsDashboardState extends State<VehicleAnalyticsDashboard> {
  bool _isLoading = true;
  List<Vehicle> _vehicles = [];
  List<MaintenanceLog> _maintenanceLogs = [];
  List<DieselLog> _dieselLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vehiclesService = context.read<VehiclesService>();
    final dieselService = context.read<DieselService>();

    final results = await Future.wait([
      vehiclesService.getVehicles(),
      vehiclesService.getMaintenanceLogs(),
      dieselService.getDieselLogs(),
    ]);

    if (mounted) {
      setState(() {
        _vehicles = results[0] as List<Vehicle>;
        _maintenanceLogs = results[1] as List<MaintenanceLog>;
        _dieselLogs = results[2] as List<DieselLog>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vehicle Analytics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalCost = _vehicles.fold<double>(0, (sum, v) => sum + v.totalMaintenanceCost + v.totalDieselCost + v.totalTyreCost);
    final avgCostPerKm = _vehicles.isNotEmpty 
        ? _vehicles.map((v) => v.costPerKm).reduce((a, b) => a + b) / _vehicles.length.toDouble() 
        : 0.0;
    final totalDistance = _vehicles.fold<double>(0, (sum, v) => sum + v.totalDistance);
    final avgFuelEfficiency = _dieselLogs.where((l) => l.cycleEfficiency != null).isNotEmpty
        ? _dieselLogs.where((l) => l.cycleEfficiency != null).map((l) => l.cycleEfficiency!).reduce((a, b) => a + b) / _dieselLogs.where((l) => l.cycleEfficiency != null).length.toDouble()
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKPIRow(totalCost, avgCostPerKm, totalDistance, avgFuelEfficiency),
            const SizedBox(height: 24),
            _buildTopCostVehicles(),
            const SizedBox(height: 24),
            _buildFuelEfficiencyComparison(),
            const SizedBox(height: 24),
            _buildMaintenanceTrend(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIRow(double totalCost, double avgCostPerKm, double totalDistance, double avgFuelEfficiency) {
    return Row(
      children: [
        Expanded(child: _buildKPICard('Total Cost', NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0).format(totalCost), AppColors.error)),
        const SizedBox(width: 12),
        Expanded(child: _buildKPICard('Avg Cost/km', 'Rs ${avgCostPerKm.toStringAsFixed(2)}', AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _buildKPICard('Total Distance', '${totalDistance.toStringAsFixed(0)} km', AppColors.info)),
        const SizedBox(width: 12),
        Expanded(child: _buildKPICard('Avg Efficiency', '${avgFuelEfficiency.toStringAsFixed(1)} kmpl', AppColors.success)),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTopCostVehicles() {
    final sorted = List<Vehicle>.from(_vehicles)..sort((a, b) => b.costPerKm.compareTo(a.costPerKm));
    final top5 = sorted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top 5 Expensive Vehicles (Cost/km)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...top5.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(v.number, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('Rs ${v.costPerKm.toStringAsFixed(2)}/km', style: TextStyle(color: AppColors.error)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelEfficiencyComparison() {
    final vehicleEfficiency = <String, double>{};
    for (final log in _dieselLogs) {
      if (log.cycleEfficiency != null) {
        vehicleEfficiency[log.vehicleNumber] = (vehicleEfficiency[log.vehicleNumber] ?? 0) + log.cycleEfficiency!;
      }
    }

    final sorted = vehicleEfficiency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top 5 Fuel Efficient Vehicles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...top5.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${e.value.toStringAsFixed(1)} kmpl', style: TextStyle(color: AppColors.success)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTrend() {
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    final recentLogs = _maintenanceLogs.where((l) => DateTime.tryParse(l.serviceDate)?.isAfter(last30Days) ?? false).toList();
    final totalCost = recentLogs.fold<double>(0, (sum, l) => sum + l.totalCost);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Maintenance Trend (Last 30 Days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Services: ${recentLogs.length}', style: const TextStyle(fontSize: 14)),
                Text('Total Cost: ${NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0).format(totalCost)}', style: TextStyle(fontSize: 14, color: AppColors.error, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
