import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/dispatch_service.dart';
import '../../providers/auth/auth_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  late final DispatchService _dispatchService;
  bool _isLoading = true;
  List<DeliveryTrip> _trips = [];

  @override
  void initState() {
    super.initState();
    _dispatchService = context.read<DispatchService>();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final trips = await _dispatchService.getDriverTrips(user.name);
      if (mounted) {
        setState(() {
          _trips = trips;
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
        title: const Text('My Trips'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _trips.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _trips.length,
                itemBuilder: (context, index) {
                  final trip = _trips[index];
                  return _buildTripCard(trip);
                },
              ),
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
            Icons.history,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No trips found',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Your past delivery trips will appear here'),
        ],
      ),
    );
  }

  Widget _buildTripCard(DeliveryTrip trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = trip.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/dashboard/dispatch/trips/${trip.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.tripId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(trip.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text('Vehicle: ${trip.vehicleNumber}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text('Loads: ${trip.salesIds.length}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_formatDate(trip.createdAt)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  if (isCompleted && trip.completedAt != null)
                    Text(
                      'Completed: ${_formatDate(trip.completedAt!)}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    switch (status) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'in_transit':
      case 'in_progress':
        color = AppColors.info;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      default:
        color = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String ts) {
    final date = DateTime.tryParse(ts);
    if (date == null) return ts;
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

