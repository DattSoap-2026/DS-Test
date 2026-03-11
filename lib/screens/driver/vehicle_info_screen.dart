import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/vehicles_service.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  late final VehiclesService _vehiclesService;
  bool _isLoading = true;
  Vehicle? _vehicle;

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _loadVehicleInfo();
  }

  Future<void> _loadVehicleInfo() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null || user.assignedVehicleId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final vehicle = await _vehiclesService.getVehicle(
        user.assignedVehicleId!,
      );
      if (mounted) {
        setState(() {
          _vehicle = vehicle;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicle'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicle == null
          ? _buildNoVehicleState()
          : _buildVehicleDetails(),
    );
  }

  Widget _buildNoVehicleState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 80,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Vehicle Assigned',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Please contact the administrator to assign a vehicle to your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildStatCards(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car,
              size: 64,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _vehicle!.vehicleNumber,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            _vehicle!.displayName,
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusChip(_vehicle!.status),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            _infoRow(Icons.type_specimen, 'Type', _vehicle!.type),
            _infoRow(Icons.person, 'Ownership', _vehicle!.ownership ?? 'N/A'),
            _infoRow(
              Icons.speed,
              'Odometer',
              '${_vehicle!.currentOdometer} km',
            ),
            _infoRow(
              Icons.line_weight,
              'Capacity',
              _vehicle!.capacity != null
                  ? '${_vehicle!.capacity} units'
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Diesel Avg',
            '${_vehicle!.dieselAverage} kmpl',
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            'Cost / KM',
            '₹${_vehicle!.costPerKm.toStringAsFixed(2)}',
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.outlineVariant),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status.toLowerCase() == 'active'
        ? AppColors.success
        : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}


