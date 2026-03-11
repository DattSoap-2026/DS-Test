import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/trips_repository.dart';
import '../../data/repositories/sales_repository.dart';
import '../../services/dispatch_service.dart';
import '../../services/vehicles_service.dart';
import '../../models/types/sales_types.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../utils/responsive.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../widgets/responsive/responsive_layout.dart';

class DispatchDashboardScreen extends StatefulWidget {
  const DispatchDashboardScreen({super.key});

  @override
  State<DispatchDashboardScreen> createState() =>
      _DispatchDashboardScreenState();
}

class _DispatchDashboardScreenState extends State<DispatchDashboardScreen> {
  // final DispatchService _dispatchService = DispatchService(firebaseServices); // Removed
  late final VehiclesService _vehiclesService;

  bool _isLoading = true;
  List<DeliveryTrip> _activeTrips = [];
  List<Sale> _pendingSales = [];
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Offline-First: Fetch Active Trips & Pending Sales
      final tripsRepo = context.read<TripsRepository>();
      final salesRepo = context.read<SalesRepository>();

      final tripEntities = await tripsRepo.getActiveTrips();
      final trips = tripEntities.map((e) => e.toDomain()).toList();

      final saleEntities = await salesRepo.getPendingDispatchSales();
      final pendingSales = saleEntities.map((e) => e.toDomain()).toList();

      // Online-Only: Fetch Vehicles (Pending Migration)
      List<Vehicle> vehicles = [];
      try {
        vehicles = await _vehiclesService.getVehicles();
      } catch (e) {
        debugPrint('Online data fetch failed (expected if offline): $e');
      }

      if (mounted) {
        setState(() {
          _activeTrips = trips;
          _pendingSales = pendingSales;
          _vehicles = vehicles;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMapSection(),
              const SizedBox(height: 24),
              _buildSummaryGrid(),
              const SizedBox(height: 24),
              _buildActiveTripsSection(),
              const SizedBox(height: 24),
              _buildPendingLoadsSection(),
              const SizedBox(height: 24),
              _buildFleetStatusSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return MasterScreenHeader(
      title: 'Dispatch Dashboard',
      subtitle: 'Manage trips, fleet, and loads',
      icon: Icons.local_shipping_rounded,
      color: AppColors.warning,
      isDashboardHeader: true,
      actions: [
        CustomButton(
          label: 'NEW TRIP',
          icon: Icons.add_road_rounded,
          onPressed: () async {
            final result = await context.push('/dashboard/dispatch/new-trip');
            if (result == true) {
              _loadDashboardData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isMobileLayout ? 1 : (constraints.maxWidth < 900 ? 2 : 3),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isMobileLayout ? 1.15 : 1.25,
          children: [
            KPICard(
              title: 'Pending Loads',
              value: _pendingSales.length.toString(),
              icon: Icons.pending_actions,
              color: AppColors.warning,
            ),
            KPICard(
              title: 'Active Trips',
              value: _activeTrips.length.toString(),
              icon: Icons.local_shipping,
              color: AppColors.info,
            ),
            KPICard(
              title: 'Available Fleet',
              value: _vehicles
                  .where((v) => v.status == 'active')
                  .length
                  .toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = Responsive.width(context) < 700;

    final activeFleetCount = _vehicles
        .where((v) => v.status == 'active')
        .length;

    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            wrapBelowWidth: 900,
            spacing: 12,
            runSpacing: 10,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Fleet Map',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time overview of vehicles and active trips',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_tethering_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMapPill(
                Icons.local_shipping_rounded,
                '$activeFleetCount Active Fleet',
                AppColors.success,
              ),
              _buildMapPill(
                Icons.route_outlined,
                '${_activeTrips.length} Active Trips',
                AppColors.info,
              ),
              _buildMapPill(
                Icons.pending_actions_rounded,
                '${_pendingSales.length} Pending Loads',
                AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: isMobile ? 4 / 3 : 16 / 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final markerTrips = _activeTrips.take(5).toList();
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    theme.colorScheme.surfaceContainerHighest,
                                    theme.colorScheme.surface,
                                  ]
                                : [
                                    AppColors.lightBackground,
                                    theme.colorScheme.surface,
                                  ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DispatchMapPainter(
                            lineColor: theme.colorScheme.primary.withValues(
                              alpha: 0.18,
                            ),
                            glowColor: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                      ),
                      if (markerTrips.isEmpty)
                        Center(
                          child: Text(
                            'No active trips right now',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        ...List.generate(markerTrips.length, (index) {
                          final trip = markerTrips[index];
                          final dx =
                              (0.15 + (index + 1) / (markerTrips.length + 1)) *
                              size.width *
                              0.7;
                          final dy = (index.isEven ? 0.3 : 0.68) * size.height;
                          return Positioned(
                            left: dx,
                            top: dy,
                            child: _buildMapMarker(
                              label: trip.vehicleNumber.isNotEmpty
                                  ? trip.vehicleNumber
                                  : trip.tripId,
                              color: _statusToColor(trip.status),
                            ),
                          );
                        }),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _buildMapLegend(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegend() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Status',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendRow('Pending', AppColors.warning),
          _buildLegendRow('In Transit', AppColors.info),
          _buildLegendRow('Completed', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker({required String label, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.local_shipping,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .inverseSurface
                .withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTripsSection() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Active Trips',
            count: _activeTrips.length,
          ),
          const SizedBox(height: 16),
          if (_activeTrips.isEmpty)
            _buildEmptyState(
              icon: Icons.route_outlined,
              message: 'No active trips currently',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeTrips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = _activeTrips[index];
                return UnifiedCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    context.push('/dashboard/dispatch/trips/${trip.id}');
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: AppColors.info,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.tripId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${trip.vehicleNumber} · ${trip.driverName}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(trip.status),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusToColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Color _statusToColor(String status) {
    if (status == 'pending') return AppColors.warning;
    if (status == 'in_transit') return AppColors.info;
    if (status == 'completed') return AppColors.success;
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Widget _buildPendingLoadsSection() {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Pending Loads',
            count: _pendingSales.length,
          ),
          const SizedBox(height: 16),
          if (_pendingSales.isEmpty)
            _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'All orders dispatched',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingSales.length > 5 ? 5 : _pendingSales.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final sale = _pendingSales[index];
                return UnifiedCard(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      sale.recipientName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${sale.items.length} items · Total: ₹${sale.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ID: ${sale.humanReadableId ?? '...'}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFleetStatusSection() {
    return UnifiedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: 'Fleet Overview'),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              return ResponsiveRow(
                wrapBelowWidth: compact ? 9999 : 640,
                rowMainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 24,
                runSpacing: 16,
                children: [
                  _buildFleetMiniStat(
                    'Active',
                    _vehicles.where((v) => v.status == 'active').length,
                    AppColors.success,
                  ),
                  _buildFleetMiniStat(
                    'In Transit',
                    _activeTrips.length,
                    AppColors.info,
                  ),
                  _buildFleetMiniStat(
                    'Maintenance',
                    _vehicles.where((v) => v.status == 'under_maintenance').length,
                    AppColors.error,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFleetMiniStat(String label, int count, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, int? count}) {
    final theme = Theme.of(context);
    return ResponsiveRow(
      wrapBelowWidth: 520,
      rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 10,
      runSpacing: 8,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DispatchMapPainter extends CustomPainter {
  final Color lineColor;
  final Color glowColor;

  _DispatchMapPainter({required this.lineColor, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final pathPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.1,
        size.width * 0.7,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.6,
        size.width * 0.55,
        size.height * 0.8,
      );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, pathPaint);

    final secondPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.65,
        size.width * 0.9,
        size.height * 0.4,
      );

    canvas.drawPath(secondPath, glowPaint);
    canvas.drawPath(secondPath, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _DispatchMapPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor ||
        glowColor != oldDelegate.glowColor;
  }
}
