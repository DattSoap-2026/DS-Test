import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../utils/responsive.dart';

class SalesProductionLineChart extends StatelessWidget {
  final List<FlSpot> salesSpots;
  final List<FlSpot> productionSpots;
  final List<String> dates;

  const SalesProductionLineChart({
    super.key,
    required this.salesSpots,
    required this.productionSpots,
    required this.dates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < dates.length &&
                    dates.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[value.toInt()],
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: salesSpots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: productionSpots,
            isCurved: true,
            color: AppColors.warning,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withValues(alpha: 0.2),
                  AppColors.warning.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.barIndex == 0 ? "Sales" : "Prod"}: ₹${spot.y.toStringAsFixed(0)}',
                  TextStyle(
                    color: spot.barIndex == 0
                        ? theme.colorScheme.primary
                        : AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class SalesBarChart extends StatelessWidget {
  final List<double> monthlyRevenue;

  const SalesBarChart({super.key, required this.monthlyRevenue});

  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) {
      return value;
    }
    return value
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String _formatCompactAmount(double value, {bool withCurrency = false}) {
    final abs = value.abs();
    double scaled = value;
    String suffix = '';

    if (abs >= 10000000) {
      scaled = value / 10000000;
      suffix = 'Cr';
    } else if (abs >= 100000) {
      scaled = value / 100000;
      suffix = 'L';
    } else if (abs >= 1000) {
      scaled = value / 1000;
      suffix = 'K';
    }

    final precision = scaled.abs() >= 100 ? 0 : (scaled.abs() >= 10 ? 1 : 2);
    final formatted = _trimTrailingZeros(scaled.toStringAsFixed(precision));
    return withCurrency ? 'Rs $formatted$suffix' : '$formatted$suffix';
  }

  double _yAxisInterval(double maxY) {
    if (maxY <= 0) return 1;
    final rough = maxY / 4;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor());
    final normalized = rough / magnitude;
    double step;
    if (normalized <= 1) {
      step = 1;
    } else if (normalized <= 2) {
      step = 2;
    } else if (normalized <= 5) {
      step = 5;
    } else {
      step = 10;
    }
    return step * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxRevenue = monthlyRevenue.isNotEmpty
        ? monthlyRevenue.reduce(math.max)
        : 0.0;
    final maxY = maxRevenue <= 0 ? 1.0 : maxRevenue * 1.2;
    final yInterval = _yAxisInterval(maxY);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = _formatCompactAmount(rod.toY, withCurrency: true);
              return BarTooltipItem(
                value,
                theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ) ??
                    const TextStyle(fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final monthIndex = (value.toInt() - 1) % 12;
                if (monthIndex < 0 || monthIndex >= _monthLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _monthLabels[monthIndex],
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                if (value < 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    _formatCompactAmount(value),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: value == 0
                ? theme.colorScheme.outline.withValues(alpha: 0.24)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: value == 0 ? 1.2 : 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.24),
              width: 1,
            ),
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
              width: 1,
            ),
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),
        barGroups: List.generate(
          monthlyRevenue.length,
          (i) => BarChartGroupData(
            x: i + 1,
            barRods: [
              BarChartRodData(
                toY: monthlyRevenue[i],
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockDonutChart extends StatelessWidget {
  final List<PieChartSectionData> sections;

  const StockDonutChart({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Center(
        child: Text(
          'No stock data',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final chartFlex = isNarrow ? 5 : 4;
        final legendFlex = isNarrow ? 5 : 6;
        final chartLegendGap = isNarrow ? 12.0 : 20.0;
        final legendDotGap = isNarrow ? 10.0 : 8.0;
        final legendRowPadding = isNarrow ? 5.0 : 4.0;

        return Row(
          children: [
            Expanded(
              flex: chartFlex,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: isNarrow ? 40 : 46,
                  sections: sections,
                ),
              ),
            ),
            SizedBox(width: chartLegendGap),
            Expanded(
              flex: legendFlex,
              child: Padding(
                padding: EdgeInsets.only(right: isNarrow ? 4 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections.map((section) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: legendRowPadding),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: section.color,
                            ),
                          ),
                          SizedBox(width: legendDotGap),
                          Expanded(
                            child: Text(
                              section.title,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProductionGaugeChart extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final String label;

  const ProductionGaugeChart({
    super.key,
    required this.percentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safePercentage = percentage.clamp(0.0, 1.0);
    final color = safePercentage > 0.8
        ? AppColors.success
        : (safePercentage > 0.5 ? AppColors.warning : AppColors.error);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: Responsive.clamp(context, min: 120, max: 180, ratio: 0.16),
          height: Responsive.clamp(context, min: 120, max: 180, ratio: 0.16),
          child: CircularProgressIndicator(
            value: safePercentage,
            strokeWidth: 15,
            strokeCap: StrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(safePercentage * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
