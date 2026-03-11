import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/diesel_service.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class VehicleMileageScreen extends StatefulWidget {
  const VehicleMileageScreen({super.key});

  @override
  State<VehicleMileageScreen> createState() => _VehicleMileageScreenState();
}

class _VehicleMileageScreenState extends State<VehicleMileageScreen> {
  late final DieselService _dieselService;

  bool _isLoading = true;
  List<DieselLog> _logs = [];
  Map<String, dynamic> _stats = {
    'avgMileage': 0.0,
    'totalDiesel': 0.0,
    'totalCost': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    // Defer fetching until we have access to provider state, usually safely done in post-frame or didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLogs();
    });
  }

  Future<void> _fetchLogs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Check if user has assigned vehicle
    // We handle the case where assignedVehicleId might be missing elegantly
    String? vehicleId;
    if (user != null) {
      // Use dynamic access or check if field exists.
      // Assuming AppUser has it based on context.
      // If strict typing fails, we might need to cast or fix model.
      // For now, access strongly typed.
      vehicleId = user.assignedVehicleId;
    }

    if (vehicleId == null || vehicleId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final logs = await _dieselService.getDieselLogs(
        vehicleId: vehicleId,
        limitCount: 10,
      );

      if (mounted) {
        setState(() {
          _logs = logs;
          _calculateStats(logs);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mileage logs: $e')),
        );
      }
    }
  }

  void _calculateStats(List<DieselLog> logs) {
    if (logs.isEmpty) return;

    final validLogs = logs
        .where((l) => l.mileage != null && l.mileage! > 0)
        .toList();

    double avg = 0;
    if (validLogs.isNotEmpty) {
      final totalMileage = validLogs.fold<double>(
        0,
        (sum, item) => sum + (item.mileage ?? 0),
      );
      avg = totalMileage / validLogs.length;
    }

    final totalD = logs.fold<double>(0, (sum, item) => sum + item.liters);
    final totalC = logs.fold<double>(0, (sum, item) => sum + item.totalCost);

    _stats = {'avgMileage': avg, 'totalDiesel': totalD, 'totalCost': totalC};
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user?.assignedVehicleId == null || user!.assignedVehicleId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mileage Stats'),
          backgroundColor: const Color(0xFF4f46e5),
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_transfer,
                size: 64,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No vehicle assigned.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mileage Stats'),
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLogs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              if (_stats['avgMileage'] > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Avg Km/L',
                        value: (_stats['avgMileage'] as double).toStringAsFixed(
                          2,
                        ),
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Liters (Last 10)',
                        value: (_stats['totalDiesel'] as double)
                            .toStringAsFixed(1),
                        icon: Icons.opacity,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              Text(
                'Recent Fills',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (_logs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'No diesel logs found.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final mileage = log.mileage;
                    final isGoodMileage =
                        mileage != null &&
                        mileage > 3; // Threshold from React code

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDateSafe(log.fillDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${log.liters.toStringAsFixed(1)} L @ ₹${log.rate}/L',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isGoodMileage
                                      ? AppColors.successBg
                                      : colorScheme.surfaceContainerHighest,
                                  border: Border.all(
                                    color: isGoodMileage
                                        ? AppColors.success.withValues(alpha: 0.24)
                                        : colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  mileage != null
                                      ? '${mileage.toStringAsFixed(2)} km/l'
                                      : 'N/A',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isGoodMileage
                                        ? AppColors.success
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${log.totalCost.toStringAsFixed(0)}', // Using number format conceptually
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }
}


