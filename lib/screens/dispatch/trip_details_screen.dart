import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/dispatch_service.dart';
import '../../services/sales_service.dart';
import '../../models/types/sales_types.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/custom_button.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late final DispatchService _dispatchService;
  late final SalesService _salesService;

  bool _isLoading = true;
  DeliveryTrip? _trip;
  List<Sale> _linkedSales = [];

  @override
  void initState() {
    super.initState();
    _dispatchService = context.read<DispatchService>();
    _salesService = context.read<SalesService>();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    setState(() => _isLoading = true);
    try {
      final trips = await _dispatchService.getDeliveryTrips();
      final trip = trips.cast<DeliveryTrip?>().firstWhere(
            (t) => t?.id == widget.tripId,
            orElse: () => null,
          );
      if (trip == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip not found')),
          );
        }
        return;
      }

      final List<Sale> sales = [];
      for (final saleId in trip.salesIds) {
        final sale = await _salesService.getSale(saleId);
        if (sale != null) sales.add(sale);
      }

      if (mounted) {
        setState(() {
          _trip = trip;
          _linkedSales = sales;
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

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      String? startedAt;
      String? completedAt;
      if (status == 'in_transit') startedAt = DateTime.now().toIso8601String();
      if (status == 'completed') completedAt = DateTime.now().toIso8601String();

      final success = await _dispatchService.updateTripStatus(
        _trip!.id,
        status,
        startedAt: startedAt,
        completedAt: completedAt,
      );

      if (success) {
        if (!mounted) return;
        _loadTripDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip status updated to $status')),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_trip == null) {
      return const Scaffold(body: Center(child: Text('Trip not found')));
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          MasterScreenHeader(
            title: 'Trip Details',
            subtitle: _trip!.id,
            icon: Icons.local_shipping_rounded,
            color: theme.colorScheme.primary,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildSalesList(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  // Bottom padding
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle: ${_trip!.vehicleNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Driver: ${_trip!.driverName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(_trip!.status),
            ],
          ),
          Divider(height: 32, color: theme.colorScheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaInfo('Created', _formatDate(_trip!.createdAt)),
              if (_trip!.startedAt != null)
                _buildMetaInfo('Started', _formatDate(_trip!.startedAt!)),
              if (_trip!.completedAt != null)
                _buildMetaInfo('Completed', _formatDate(_trip!.completedAt!)),
            ],
          ),
          if (_trip!.notes != null && _trip!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'NOTES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _trip!.notes!,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaInfo(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final theme = Theme.of(context);
    Color color = theme.colorScheme.outline;
    if (status == 'pending') color = AppColors.warning;
    if (status == 'in_transit') color = AppColors.info;
    if (status == 'completed') color = AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSalesList() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONNECTED DELIVERIES',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: theme.colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        ..._linkedSales.map(
          (sale) => AnimatedCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(
                  sale.recipientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'ID: ${sale.humanReadableId ?? '...'} · Value: ₹${sale.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.outline,
                ),
                onTap: () {
                  // Navigate to Sale Details if implemented
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_trip!.status == 'completed') return const SizedBox.shrink();

    return Row(
      children: [
        if (_trip!.status == 'pending')
          Expanded(
            child: CustomButton(
              onPressed: () => _updateStatus('in_transit'),
              icon: Icons.play_arrow_rounded,
              label: 'START DELIVERY',
              color: AppColors.info,
              textColor: Theme.of(context).colorScheme.onPrimary,
              isLoading: _isLoading,
            ),
          ),
        if (_trip!.status == 'in_transit')
          Expanded(
            child: CustomButton(
              onPressed: () => _updateStatus('completed'),
              icon: Icons.done_all_rounded,
              label: 'MARK COMPLETED',
              color: AppColors.success,
              textColor: Theme.of(context).colorScheme.onPrimary,
              isLoading: _isLoading,
            ),
          ),
      ],
    );
  }

  String _formatDate(String ts) {
    try {
      final date = DateTime.parse(ts);
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return ts;
    }
  }
}

