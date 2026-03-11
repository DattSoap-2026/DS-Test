import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import '../../widgets/ui/shared/app_card.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/dashboard/kpi_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  late final ReportsService _reportsService;
  bool _isLoading = true;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  SalesDispatchReport? _reportData;

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final filters = FilterOptions(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );

      final data = await _reportsService.getSalesDispatchReport(filters);

      if (mounted) {
        setState(() {
          _reportData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading analytics: $e')));
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MasterScreenHeader(
              title: 'Sales Analytics',
              subtitle: 'Performance insights & trends',
              icon: Icons.analytics_rounded,
              color: AppColors.info,
              actions: [
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    '${DateFormat('MMM d').format(_dateRange.start)} - ${DateFormat('MMM d').format(_dateRange.end)}',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_reportData == null)
            const SliverFillRemaining(
              child: Center(child: Text('No data available')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildMainChartsRow(),
                  const SizedBox(height: 24),
                  _buildTopPerformersRow(),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final data = _reportData;
    if (data == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final cardWidth = isWide
            ? (constraints.maxWidth - (3 * 16)) / 4
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isWide ? cardWidth : double.infinity,
              child: KPICard(
                title: 'Total Revenue',
                value: '₹${NumberFormat.compact().format(data.totalRevenue)}',
                icon: Icons.currency_rupee,
                color: AppColors.success,
                trend: '+12%',
              ),
            ),
            SizedBox(
              width: isWide ? cardWidth : double.infinity,
              child: KPICard(
                title: 'Transactions',
                value: '${data.totalTransactions}',
                icon: Icons.receipt_long,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: isWide ? cardWidth : double.infinity,
              child: KPICard(
                title: 'Avg. Ticket',
                value:
                    '₹${NumberFormat.compact().format(data.avgTransactionValue)}',
                icon: Icons.shopping_cart,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: isWide ? cardWidth : double.infinity,
              child: KPICard(
                title: 'Items Sold',
                value: '${data.totalItemsSold}',
                icon: Icons.inventory_2,
                color: AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (!isWide) {
          return Column(
            children: [
              _buildRevenueChart(),
              const SizedBox(height: 24),
              _buildCategoryPieChart(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRevenueChart()),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildCategoryPieChart()),
          ],
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return AppCard(
      title: const Text('Revenue Trend'),
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: Responsive.clamp(context, min: 220, max: 320, ratio: 0.34),
        child: _reportData!.sales.isEmpty
            ? const Center(child: Text('No data for chart'))
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxRevenue() * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Simplify: Just showing index for now, ideally map to dates
                          // Would need to aggregate sales by day in logic
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            NumberFormat.compact().format(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _getDailyBarGroups(),
                ),
              ),
      ),
    );
  }

  double _getMaxRevenue() {
    if (_reportData == null || _reportData!.sales.isEmpty) return 1000;

    final maxVal = _reportData!.sales
        .map((e) => (e['totalAmount'] as num? ?? 0).toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return maxVal < 100 ? 100 : maxVal;
  }

  List<BarChartGroupData> _getDailyBarGroups() {
    // Quick aggregation: Group by Day Index (0-6 or 0-30 based on range)
    // For MVP, just showing last 7 sales as bars or similar.
    // Ideally we aggregate daily.
    if (_reportData == null) return [];

    // Aggregate by day
    final dailyMap = <int, double>{};
    for (var sale in _reportData!.sales) {
      final createdAtStr = sale['createdAt'] as String? ?? '';
      final dt = DateTime.tryParse(createdAtStr);
      if (dt == null) continue; // Skip malformed dates

      final day = dt.day; // Simple day of month bucket
      final amount = (sale['totalAmount'] as num? ?? 0).toDouble();
      dailyMap[day] = (dailyMap[day] ?? 0) + amount;
    }

    final sortedKeys = dailyMap.keys.toList()..sort();

    return sortedKeys.map((day) {
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: dailyMap[day]!,
            color: AppColors.info,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryPieChart() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      title: const Text('Sales by Channel'),
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: Responsive.clamp(context, min: 220, max: 320, ratio: 0.34),
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: AppColors.info,
                value: _reportData?.totalCustomerSales ?? 1,
                title:
                    '${_calculatePercent(_reportData?.totalCustomerSales ?? 0)}%',
                radius: 50,
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              PieChartSectionData(
                color: AppColors.success,
                value: _reportData?.totalDealerDispatches ?? 0,
                title:
                    '${_calculatePercent(_reportData?.totalDealerDispatches ?? 0)}%',
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
                radius: 50,
              ),
              PieChartSectionData(
                color: AppColors.warning,
                value: _reportData?.totalSalesmanDispatches ?? 0,
                title:
                    '${_calculatePercent(_reportData?.totalSalesmanDispatches ?? 0)}%',
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
                radius: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculatePercent(double val) {
    if (_reportData == null || _reportData!.totalRevenue == 0) return 0;
    return ((val / _reportData!.totalRevenue) * 100).round();
  }

  Widget _buildTopPerformersRow() {
    final data = _reportData;
    if (data == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        final children = [
          AppCard(
            title: const Text('Top Products'),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Column(
              children: List.generate(5, (index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Product ${index + 1}'),
                  trailing: Text('₹${10000 - (index * 500)}'),
                );
              }),
            ),
          ),
          const SizedBox(height: 24, width: 24),
          AppCard(
            title: const Text('Top Salesmen'),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.emoji_events, color: AppColors.warning),
                  ),
                  title: Text(
                    data.topSalesmanName.isEmpty ? 'N/A' : data.topSalesmanName,
                  ),
                  subtitle: const Text('Best Performer'),
                  trailing: Text(
                    '₹${NumberFormat.compact().format(data.topSalesmanRevenue)}',
                  ),
                ),
              ],
            ),
          ),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: 24),
              Expanded(child: children[2]),
            ],
          );
        }

        return Column(
          children: [children[0], const SizedBox(height: 24), children[2]],
        );
      },
    );
  }
}

