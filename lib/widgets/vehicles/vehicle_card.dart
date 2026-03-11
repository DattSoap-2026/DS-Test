import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/ui/custom_card.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    String statusText;

    switch (vehicle.status.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        statusText = 'Active';
        break;
      case 'maintenance':
      case 'under_maintenance':
        statusColor = AppColors.warning;
        statusText = 'Maintenance';
        break;
      case 'inactive':
        statusColor = theme.colorScheme.outline;
        statusText = 'Inactive';
        break;
      default:
        statusColor = AppColors.info;
        statusText = vehicle.status;
    }

    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [theme.cardColor, theme.cardColor.withValues(alpha: 0.95)],
          ),
        ),
        child: Column(
          children: [
            Container(height: 4, width: double.infinity, color: statusColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 360;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isNarrow ? 6 : 8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    size: isNarrow ? 18 : 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.number,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isNarrow ? 14 : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        vehicle.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isNarrow ? 12 : 13,
                                          color: theme.hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: isNarrow ? 92 : 120,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isNarrow ? 11 : 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStat(
                              context,
                              'Mileage',
                              '${vehicle.dieselAverage.toStringAsFixed(1)} km/L',
                              Icons.speed,
                              isNarrow: isNarrow,
                            ),
                          ),
                          Expanded(
                            child: _buildStat(
                              context,
                              'Cost/Km',
                              'Rs${vehicle.costPerKm.toStringAsFixed(1)}',
                              Icons.currency_rupee,
                              isNarrow: isNarrow,
                            ),
                          ),
                          Expanded(
                            child: _buildStat(
                              context,
                              'Fuel',
                              '${vehicle.totalFuelConsumed.toStringAsFixed(0)} L',
                              Icons.local_gas_station,
                              isNarrow: isNarrow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    required bool isNarrow,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, size: 14, color: theme.hintColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isNarrow ? 11 : 12,
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isNarrow ? 14 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
