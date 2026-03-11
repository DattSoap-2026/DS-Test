import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../data/local/entities/cutting_batch_entity.dart';
import '../../utils/responsive.dart';
import 'dashboard_tables.dart' show DashboardStatusBadge;

class SalesVsProductionCard extends StatefulWidget {
  final List<dynamic> sales; // List<SaleEntity>
  final List<dynamic> productionBatches; // List<CuttingBatchEntity>

  const SalesVsProductionCard({
    super.key,
    required this.sales,
    required this.productionBatches,
  });

  @override
  State<SalesVsProductionCard> createState() => _SalesVsProductionCardState();
}

class _SalesVsProductionCardState extends State<SalesVsProductionCard> {
  String _selectedFilter = 'Today';
  final List<String> _filters = ['Today', 'This Week', 'This Month'];

  double _totalProduction = 0;
  double _totalSales = 0;
  double _stockImpact = 0;
  double _differencePercent = 0;

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  @override
  void didUpdateWidget(covariant SalesVsProductionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sales != oldWidget.sales ||
        widget.productionBatches != oldWidget.productionBatches) {
      _calculateMetrics();
    }
  }

  double _extractSoldUnits(SaleEntity sale) {
    final items = sale.items;
    if (items == null || items.isEmpty) return 0.0;

    var totalUnits = 0;
    for (final item in items) {
      final units = item.finalBaseQuantity ?? item.quantity ?? 0;
      if (units > 0) {
        totalUnits += units;
      }
    }
    return totalUnits.toDouble();
  }

  void _calculateMetrics() {
    final now = DateTime.now();
    DateTime startDate;

    if (_selectedFilter == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedFilter == 'This Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else {
      startDate = DateTime(now.year, now.month, 1);
    }

    // Calculate Production
    _totalProduction = 0;
    for (var batch in widget.productionBatches) {
      if (batch is CuttingBatchEntity) {
        if (batch.createdAt.isAfter(startDate) ||
            batch.createdAt.isAtSameMomentAs(startDate)) {
          _totalProduction += batch.unitsProduced;
        }
      }
    }

    // Calculate Sales (Units Sold)
    _totalSales = 0;
    for (var sale in widget.sales) {
      if (sale is SaleEntity) {
        final d = DateTime.tryParse(sale.createdAt);
        if (d != null &&
            (d.isAfter(startDate) || d.isAtSameMomentAs(startDate))) {
          if (sale.recipientType == 'customer' ||
              sale.recipientType == 'dealer') {
            _totalSales += _extractSoldUnits(sale);
          }
        }
      }
    }

    _stockImpact = _totalProduction - _totalSales;
    if (_totalProduction > 0) {
      _differencePercent = (_stockImpact / _totalProduction) * 100;
    } else if (_totalSales > 0) {
      _differencePercent = -100.0;
    } else {
      _differencePercent = 0.0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default Status logic
    String statusLabel = 'Balanced';
    Color statusColor = AppColors.info;
    IconData trendIcon = Icons.trending_flat;

    if (_differencePercent > 10) {
      statusLabel = 'Overproduction';
      statusColor = AppColors.warning;
      trendIcon = Icons.trending_up;
    } else if (_differencePercent < -10) {
      statusLabel = 'Shortage Risk';
      statusColor = AppColors.error;
      trendIcon = Icons.trending_down;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Sales vs Production',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFilter = newValue;
                        _calculateMetrics();
                      });
                    }
                  },
                  items: _filters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricColumn(
              context,
              'Production',
              _totalProduction.toStringAsFixed(0),
              AppColors.warning,
            ),
            Container(
              width: 1,
              height: 48,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            _buildMetricColumn(
              context,
              'Sales',
              _totalSales.toStringAsFixed(0),
              theme.colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Impact',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(trendIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_stockImpact > 0 ? '+' : ''}${_stockImpact.toStringAsFixed(0)} Units',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              DashboardStatusBadge(
                label: statusLabel,
                color: statusColor,
                compact: Responsive.isMobile(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricColumn(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

