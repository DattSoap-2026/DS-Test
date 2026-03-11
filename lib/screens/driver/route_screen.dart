import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/dispatch_service.dart';
import '../../services/sales_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/sales_types.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late final DispatchService _dispatchService;
  late final SalesService _salesService;

  bool _isLoading = true;
  DeliveryTrip? _activeTrip;
  List<Sale> _stops = [];

  @override
  void initState() {
    super.initState();
    _dispatchService = context.read<DispatchService>();
    _salesService = context.read<SalesService>();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final trip = await _dispatchService.getActiveDriverTrip(user.name);
      if (trip != null) {
        final stops = await _salesService.getSalesByIds(trip.salesIds);
        if (mounted) {
          setState(() {
            _activeTrip = trip;
            _stops = stops;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _activeTrip = null;
            _stops = [];
            _isLoading = false;
          });
        }
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
        title: const Text('My Route'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRouteData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activeTrip == null
            ? _buildEmptyState()
            : _buildRouteView(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Trip Found',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You will see your delivery stops once a trip is assigned.',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadRouteData,
            child: const Text('Refresh Status'),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripHeader(),
        const SizedBox(height: 24),
        const Text(
          'Delivery Stops',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._stops.map((stop) => _buildStopCard(stop)),
      ],
    );
  }

  Widget _buildTripHeader() {
    return Card(
      color: AppColors.infoBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 32,
                  color: AppColors.info,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activeTrip!.tripId,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Active | Assigned to ${_activeTrip!.vehicleNumber}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(Sale stop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.warning.withValues(alpha: 0.16),
          child: const Icon(Icons.place, color: AppColors.warning),
        ),
        title: Text(
          stop.recipientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Amount: ₹${stop.totalAmount.toStringAsFixed(2)}'),
            Text('Items: ${stop.items.length}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/dashboard/sales/details/${stop.id}'),
      ),
    );
  }
}


