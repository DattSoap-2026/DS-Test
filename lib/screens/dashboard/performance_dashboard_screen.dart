import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/sales_service.dart';
import '../../services/products_service.dart';
import '../../services/dispatch_service.dart';
import 'package:intl/intl.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../services/alert_service.dart';
import '../../services/customers_service.dart';
import '../../services/production_stats_service.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../utils/responsive.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class PerformanceDashboardScreen extends StatefulWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  State<PerformanceDashboardScreen> createState() =>
      _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState
    extends State<PerformanceDashboardScreen> {
  late final SalesService _salesService;
  late final ProductsService _productsService;
  late final DispatchService _dispatchService;
  late final CustomersService _customersService;
  late final ProductionStatsService _productionStatsService;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  double _todaySales = 0;
  double _monthSales = 0;
  int _pendingDispatches = 0;
  int _lowStockItems = 0;
  int _customerCount = 0;
  int _todaysProduction = 0;
  double _stockValue = 0;
  List<double> _weeklySalesData = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    _salesService = context.read<SalesService>();
    _productsService = context.read<ProductsService>();
    _dispatchService = context.read<DispatchService>();
    _customersService = context.read<CustomersService>();
    _productionStatsService = context.read<ProductionStatsService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadStats();
    });
  }

  Future<void> _loadStats({bool forcePageLoader = false}) async {
    if (!mounted || _isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });
    try {
      final sales = await _salesService.getSales();
      final products = await _productsService.getProducts();
      final dispatches = await _dispatchService.getTrips(status: 'pending');
      final customers = await _customersService.getCustomers();
      final productionMix = await _productionStatsService.getTodaysMix();

      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      double todayTotal = 0;
      double monthTotal = 0;
      List<double> dailyTotals = List.filled(7, 0.0);

      for (var sale in sales) {
        if (sale.createdAt.startsWith(todayStr)) {
          todayTotal += sale.totalAmount;
        }
        if (sale.month == now.month && sale.year == now.year) {
          monthTotal += sale.totalAmount;
        }

        final saleDate = DateTime.tryParse(sale.createdAt);
        if (saleDate != null) {
          final diff = now.difference(saleDate).inDays;
          if (diff >= 0 && diff < 7) {
            dailyTotals[6 - diff] += sale.totalAmount;
          }
        }
      }

      final lowStockCount = products
          .where((p) => p.stock < (p.stockAlertLevel ?? 10))
          .length;

      double totalStockValue = 0;
      for (var p in products) {
        totalStockValue += p.stock * (p.purchasePrice ?? p.price);
      }

      if (mounted) {
        // Trigger alerts
        final alertService = context.read<AlertService>();
        alertService.checkStockAlerts(products.map((p) => p.toJson()).toList());

        setState(() {
          _todaySales = todayTotal;
          _monthSales = monthTotal;
          _pendingDispatches = dispatches.length;
          _lowStockItems = lowStockCount;
          _weeklySalesData = dailyTotals;
          _customerCount = customers.length;
          _todaysProduction = productionMix['totalUnits'] ?? 0;
          _stockValue = totalStockValue;
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 24),
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildMainDashboardRow(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildGoalSection(),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            const Color(0xFF6366F1).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    color: onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Business metrics and operational performance',
                  style: TextStyle(
                    color: onPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Flexible(
            child: Material(
            color: onPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _loadStats,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: onPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sync',
                      style: TextStyle(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final user = context.read<AuthProvider>().state.user;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1400
            ? 5
            : (constraints.maxWidth > 900
                  ? 3
                  : (constraints.maxWidth > 600 ? 2 : 1));

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 1200
              ? 1.55
              : (constraints.maxWidth > 760 ? 1.3 : 1.05),
          children: [
            if (user?.role == UserRole.admin ||
                user?.role == UserRole.owner) ...[
              KPICard(
                title: 'Monthly Revenue',
                value: '₹${(_monthSales / 1000).toStringAsFixed(1)}K',
                icon: Icons.payments_outlined,
                color: AppColors.info,
                trend: '+12.5%',
                isTrendPositive: true,
              ),
              KPICard(
                title: 'Stock Value',
                value: '₹${(_stockValue / 1000000).toStringAsFixed(1)}M',
                icon: Icons.inventory_2_outlined,
                color: AppColors.info,
                trend: '+5.2%',
                isTrendPositive: true,
              ),
            ],
            KPICard(
              title: 'Customers',
              value: '$_customerCount',
              icon: Icons.people_outline,
              color: AppColors.warning,
              trend: '+18',
              isTrendPositive: true,
            ),
            KPICard(
              title: 'Low Stock',
              value: '$_lowStockItems',
              icon: Icons.notification_important_outlined,
              color: AppColors.error,
              trend: 'Alert',
              isTrendPositive: false,
            ),
            KPICard(
              title: 'Pending Trips',
              value: '$_pendingDispatches',
              icon: Icons.local_shipping_outlined,
              color: AppColors.lightPrimary,
              trend: 'Active',
              isTrendPositive: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainDashboardRow() {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              _buildChartCard(
                'Weekly Revenue Trend',
                theme.colorScheme.primary,
                _buildBarChart(),
              ),
              const SizedBox(height: 24),
              KPICard(
                title: 'Today\'s Sales',
                value: '₹${_todaySales.toStringAsFixed(0)}',
                icon: Icons.shopping_cart,
                color: AppColors.success,
              ),
              const SizedBox(height: 24),
              KPICard(
                title: 'Today\'s Production',
                value: '$_todaysProduction Units',
                icon: Icons.precision_manufacturing,
                color: AppColors.info,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildChartCard(
                'Weekly Revenue Trend',
                theme.colorScheme.primary,
                _buildBarChart(),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  KPICard(
                    title: 'Today\'s Sales',
                    value: '₹${_todaySales.toStringAsFixed(0)}',
                    icon: Icons.shopping_cart,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 24),
                  KPICard(
                    title: 'Today\'s Production',
                    value: '$_todaysProduction Units',
                    icon: Icons.precision_manufacturing,
                    color: AppColors.info,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartCard(String title, Color color, Widget chart) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'More chart actions are not available yet.',
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: Responsive.clamp(
                context,
                min: 200,
                max: 280,
                ratio: 0.25,
              ),
            ),
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final theme = Theme.of(context);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _weeklySalesData.isEmpty
            ? 100
            : (_weeklySalesData.reduce((a, b) => a > b ? a : b) * 1.2),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                theme.colorScheme.surfaceContainerHighest,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${rod.toY.toStringAsFixed(0)}',
                TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final index = val.toInt() % 7;
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _weeklySalesData[i],
                color: theme.colorScheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Yearly Sales Goal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '65.4%',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 10,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.05,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '₹42.5M of ₹65M target achieved',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Admin Operations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/dashboard/management'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1000
                ? 4
                : (constraints.maxWidth > 560 ? 2 : 1);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: constraints.maxWidth > 1000 ? 1.7 : 1.25,
              children: [
                _buildActionCard(
                  'User Ops',
                  'Manage Roles',
                  Icons.manage_accounts_outlined,
                  AppColors.info,
                  () => context.push('/dashboard/management/users'),
                ),
                _buildActionCard(
                  'Products',
                  'Inventory',
                  Icons.inventory_2_outlined,
                  AppColors.warning,
                  () => context.push('/dashboard/management/products'),
                ),
                _buildActionCard(
                  'Sales Target',
                  'Set Goals',
                  Icons.track_changes_rounded,
                  AppColors.success,
                  () => context.push('/dashboard/management/sales-targets'),
                ),
                _buildActionCard(
                  'Routes',
                  'Mapping',
                  Icons.route_outlined,
                  AppColors.info,
                  () => context.push('/dashboard/management/routes'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
