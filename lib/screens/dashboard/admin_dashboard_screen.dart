import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/delegates/firestore_query_delegate.dart';
import '../../services/sales_service.dart';
import '../../services/products_service.dart';
import '../../services/dispatch_service.dart';
import '../../services/inventory_service.dart';
import '../../services/production_stats_service.dart';
import '../../services/reports_service.dart';
import '../../models/inventory/stock_dispatch.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/dashboard/dashboard_charts.dart';
import '../../widgets/dashboard/dashboard_tables.dart';
import '../../widgets/dashboard/sales_vs_production_card.dart';
import '../../widgets/dashboard/route_order_alert_card.dart';
import '../../widgets/dashboard/stuck_queue_alert_card.dart';
import '../../widgets/dashboard/department_stock_summary_card.dart';
import '../../widgets/common/key_tip.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../utils/responsive.dart';
// import '../../widgets/ui/animated_card.dart'; // Removed to prevent double-boxing
import '../../widgets/ui/custom_button.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final SalesService _salesService;
  late final ProductsService _productsService;
  late final DispatchService _dispatchService;
  late final InventoryService _inventoryService;
  late final ProductionStatsService _productionStatsService;
  late final ReportsService _reportsService;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;

  // Real-time listeners
  final List<StreamSubscription> _listeners = [];

  // KPI Data
  double _todayAllocated = 0;
  double _todaySold = 0;
  double _availableStock = 0;
  int _outOfStockItems = 0;

  // Trends
  String _soldTrend = '';
  bool _soldTrendPositive = true;
  String _allocatedTrend = '';
  bool _allocatedTrendPositive = true;

  // Chart Data
  List<double> _monthlyRevenue = List.filled(12, 0.0);
  List<PieChartSectionData> _stockSections = [];
  double _productionAchievement = 0.0;

  // Table Data
  List<Map<String, dynamic>> _lowStockItems = [];
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _recentDispatches = [];
  List<Map<String, dynamic>> _recentBatches = [];
  List<Map<String, dynamic>> _topProducts = [];

  // Data for Sales vs Production Card
  List<dynamic> _yearSales = [];
  List<dynamic> _monthProductionBatches = [];

  @override
  void initState() {
    super.initState();
    _salesService = context.read<SalesService>();
    _productsService = context.read<ProductsService>();
    _dispatchService = context.read<DispatchService>();
    _inventoryService = context.read<InventoryService>();
    _productionStatsService = context.read<ProductionStatsService>();
    _reportsService = context.read<ReportsService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setupRealtimeListeners();
      _loadAllData();
    });
  }

  @override
  void dispose() {
    for (var listener in _listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  void _setupRealtimeListeners() {
    final delegate = FirestoreQueryDelegate();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Listen to sales changes (today onwards)
    _listeners.add(
      delegate
          .watchCollection(
            collection: 'sales',
            filters: <FirestoreQueryFilter>[
              FirestoreQueryFilter(
                field: 'createdAt',
                operator: FirestoreQueryOperator.isGreaterThanOrEqualTo,
                value: todayStart.toIso8601String(),
              ),
            ],
          )
          .listen((_) => _autoRefresh()),
    );

    // Listen to product stock changes
    _listeners.add(
      delegate
          .watchCollection(collection: 'products')
          .listen((_) => _autoRefresh()),
    );

    // Listen to dispatch changes
    _listeners.add(
      delegate
          .watchCollection(collection: 'dispatches')
          .listen((_) => _autoRefresh()),
    );

    // Listen to production batches (bhatti + cutting)
    _listeners.add(
      delegate
          .watchCollection(collection: 'bhatti_batches')
          .listen((_) => _autoRefresh()),
    );
    _listeners.add(
      delegate
          .watchCollection(collection: 'cutting_batches')
          .listen((_) => _autoRefresh()),
    );
    _listeners.add(
      delegate
          .watchCollection(collection: 'detailed_production_logs')
          .listen((_) => _autoRefresh()),
    );
  }

  void _autoRefresh() {
    if (!mounted || _isRefreshing || _isLoading) return;
    _loadAllData();
  }

  Future<void> _loadAllData({bool forcePageLoader = false}) async {
    if (!mounted || _isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      // Fetch data for trends and charts (Last 8 days: Today + 7 days back)
      final eightDaysAgo = todayStart.subtract(const Duration(days: 7));

      // 1. Fetch KPI & Chart Data concurrently
      final results = await Future.wait([
        _salesService.getSales(
          startDate: eightDaysAgo,
          endDate: now,
        ), // Fetch recent sales for trends/charts
        _productsService.getProducts(),
        _dispatchService.getTrips(status: 'pending'),
        _productionStatsService.getProductionTargets(),
        _reportsService.getStockValuationReport(),
        _salesService.getSales(
          startDate: DateTime(now.year, 1, 1),
          endDate: now,
        ), // Fetch year's sales for monthly revenue
        _productionStatsService.getBatchesForDateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        ), // Fetch month's production for Sales vs Production card
        _inventoryService.getAllDispatches(limit: 20),
      ]);

      final recentSales = results[0] as List;
      final products = results[1] as List;
      // results[2] is pendingTrips
      final productionTargets = results[3] as Map<String, dynamic>;
      final stockValuation = results[4] as StockValuationReport;
      final yearSales = results[5] as List;
      final monthBatches = results[6] as List;
      final recentDispatches = results[7] as List<StockDispatch>;

      _yearSales = yearSales;
      _monthProductionBatches = monthBatches;

      // --- 2. Calculate KPIs & Trends ---

      // Filter Lists
      final todaySalesList = recentSales.where((s) {
        final d = DateTime.tryParse(s.createdAt);
        if (d == null) return false;
        return d.isAfter(todayStart) || d.isAtSameMomentAs(todayStart);
      }).toList();

      final yesterdaySalesList = recentSales.where((s) {
        final d = DateTime.tryParse(s.createdAt);
        if (d == null) return false;
        return (d.isAfter(yesterdayStart) ||
                d.isAtSameMomentAs(yesterdayStart)) &&
            d.isBefore(todayStart);
      }).toList();

      // Helper for aggregation
      double sumAmount(List sales, bool Function(dynamic) filter) {
        return sales
            .where(filter)
            .fold(0.0, (total, s) => total + s.totalAmount);
      }

      // Logic: Sold = Customer + Dealer | Allocated = Salesman
      final todaySoldTotal = sumAmount(
        todaySalesList,
        (s) => s.recipientType == 'customer' || s.recipientType == 'dealer',
      );
      final yesterdaySoldTotal = sumAmount(
        yesterdaySalesList,
        (s) => s.recipientType == 'customer' || s.recipientType == 'dealer',
      );

      final todayAllocatedTotal = sumAmount(
        todaySalesList,
        (s) => s.recipientType == 'salesman',
      );
      final yesterdayAllocatedTotal = sumAmount(
        yesterdaySalesList,
        (s) => s.recipientType == 'salesman',
      );

      // Calculate Trends
      String calcTrend(double current, double previous) {
        if (previous == 0) return current > 0 ? '+100%' : '0%';
        final diff = current - previous;
        final p = (diff / previous) * 100;
        return '${p >= 0 ? '+' : ''}${p.toStringAsFixed(1)}%';
      }

      final soldTrendStr = calcTrend(todaySoldTotal, yesterdaySoldTotal);
      final allocatedTrendStr = calcTrend(
        todayAllocatedTotal,
        yesterdayAllocatedTotal,
      );

      // --- 3. Process Charts ---

      // Monthly Revenue
      final monthRevenueMap = <int, double>{};
      for (var sale in yearSales) {
        if (sale.recipientType == 'customer' ||
            sale.recipientType == 'dealer') {
          final date = DateTime.tryParse(sale.createdAt);
          if (date == null) continue;
          if (date.year == now.year) {
            monthRevenueMap[date.month] =
                (monthRevenueMap[date.month] ?? 0) + sale.totalAmount;
          }
        }
      }
      _monthlyRevenue = List.generate(12, (i) => monthRevenueMap[i + 1] ?? 0.0);

      // Stock Donut (Existing Logic is good - Valuation by Category)
      final categories = <String, double>{};
      for (var item in stockValuation.items) {
        categories[item.category] =
            (categories[item.category] ?? 0) + item.totalValue;
      }
      final sortedCats = categories.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final colors = [
        AppColors.lightPrimary,
        AppColors.warning,
        AppColors.info,
        AppColors.success,
        AppColors.error,
      ];
      final totalStockValue = stockValuation.totalValue;
      _stockSections = sortedCats.take(5).toList().asMap().entries.map((e) {
        final percentage = totalStockValue > 0
            ? (e.value.value / totalStockValue * 100).toStringAsFixed(0)
            : '0';
        return PieChartSectionData(
          color: colors[e.key % colors.length],
          value: e.value.value,
          title: '${e.value.key} ($percentage%)',
          showTitle: false,
          radius: 36,
        );
      }).toList();

      // Production Gauge
      _productionAchievement =
          (productionTargets['achievementPercent'] as int) / 100.0;

      // --- 4. Tables ---

      _lowStockItems = products
          .where((p) => p.stock <= (p.stockAlertLevel ?? 10))
          .take(5)
          .map(
            (p) => {
              'name': p.name,
              'stock': p.stock,
              'threshold': p.stockAlertLevel ?? 10,
              'unit': p.baseUnit,
            },
          )
          .toList();

      _pendingOrders = recentSales
          .where((s) => s.status == 'pending' || s.status == 'pending_dispatch')
          .take(5)
          .map(
            (s) => {
              'id': s.id,
              'customerName': s.recipientName,
              'amount': s.totalAmount,
            },
          )
          .toList();

      _recentDispatches = recentDispatches.take(5).map((dispatch) {
        final dispatchNo = dispatch.dispatchId.trim().isNotEmpty
            ? dispatch.dispatchId.trim()
            : dispatch.id;
        final recipientName = dispatch.salesmanName.trim().isNotEmpty
            ? dispatch.salesmanName.trim()
            : 'Unknown';
        final dealerName = dispatch.dealerName?.trim();
        final route = dispatch.dispatchRoute.trim().isNotEmpty
            ? dispatch.dispatchRoute.trim()
            : dispatch.salesRoute.trim();
        final isDealer = dealerName != null && dealerName.isNotEmpty;
        return {
          'dispatchId': dispatchNo,
          'recipientName': recipientName,
          'dealerName': dealerName,
          'route': route,
          'quantity': dispatch.totalQuantity,
          'createdAt': dispatch.createdAt,
          'status': dispatch.status.name,
          'isDealer': isDealer,
          'totalAmount': dispatch.totalAmount,
          'items': dispatch.items
              .map(
                (item) => {
                  'productName': item.productName,
                  'quantity': item.quantity,
                  'unit': item.unit,
                  'rate': item.rate,
                  'amount': item.amount,
                },
              )
              .toList(),
        };
      }).toList();

      _recentBatches = await _productionStatsService.getRecentLogs(limit: 5);

      // Top Products - Calculate from Recent Sales (Last 7 days) instead of Valuation
      final productSalesMap = <String, double>{};
      for (var sale in recentSales) {
        if (sale.recipientType == 'customer' ||
            sale.recipientType == 'dealer') {
          for (var item in sale.items) {
            productSalesMap[item.name] =
                (productSalesMap[item.name] ?? 0) + item.quantity.toDouble();
          }
        }
      }
      // Map to Map<productName, quantity>
      // We also need Revenue if possible, but let's stick to sold qty for 'sold' column.
      // Or we can get unit price from products list if needed, or approx from sales.

      final sortedEntries = productSalesMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      _topProducts = sortedEntries.take(5).map((e) {
        // Find estimated revenue or price
        final p = products.firstWhere(
          (p) => p.name == e.key,
          orElse: () => null,
        );
        final price = p?.price ?? 0.0;
        return {
          'name': e.key,
          'sold': e.value.toInt(),
          'revenue': e.value * price,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _todaySold = todaySoldTotal;
          _todayAllocated = todayAllocatedTotal;
          _availableStock = stockValuation.totalValue;
          _outOfStockItems = products.where((p) => p.stock <= 0).length;

          _soldTrend = soldTrendStr;
          _soldTrendPositive = !soldTrendStr.startsWith('-');

          _allocatedTrend = allocatedTrendStr;
          _allocatedTrendPositive = !allocatedTrendStr.startsWith('-');

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
    final theme = Theme.of(context);

    if (_isLoading && !_hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          padding: Responsive.screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const RouteOrderAlertCard(),
              const StuckQueueAlertCard(),
              const SizedBox(height: 24),
              _buildKPIs(),
              const SizedBox(height: 24),
              _buildCharts(),
              const SizedBox(height: 24),
              const DepartmentStockSummaryCard(),
              const SizedBox(height: 24),
              _buildTables(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final keepInlineActions = Responsive.width(context) >= 420;
    return MasterScreenHeader(
      title: 'Dashboard',
      subtitle: 'Overview of your factory operations',
      icon: Icons.dashboard_rounded,
      color: theme.colorScheme.primary,
      isDashboardHeader: true,
      actionsInline: keepInlineActions,
      forceActionsBelowTitle: !keepInlineActions,
      actions: [
        CustomButton(
          label: 'RECONCILE',
          icon: Icons.inventory_2_outlined,
          onPressed: () => context.push('/dashboard/inventory/reconciliation'),
          variant: ButtonVariant.outline,
          isDense: true,
        ),
        const SizedBox(width: 8),
        CustomButton(
          label: 'REPORTS',
          icon: Icons.summarize_outlined,
          onPressed: () => context.push('/dashboard/reports'),
          variant: ButtonVariant.outline,
          isDense: true,
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _loadAllData,
          icon: const Icon(Icons.sync_rounded),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primaryContainer.withValues(
              alpha: 0.5,
            ),
            foregroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= Responsive.tabletBreakpoint
            ? 4
            : 2;
        const spacing = 16.0;
        final usableWidth = constraints.maxWidth - spacing * (columns - 1);
        final itemWidth = (usableWidth > 0 ? usableWidth : 0.0) / columns;

        final cards = [
          KeyTip(
            label: '1',
            description: 'Today Allocated',
            onTrigger: () => context.push('/dashboard/reports/sales-dispatch'),
            child: KPICard(
              title: 'Today Allocated',
              value: '₹${(_todayAllocated / 1000).toStringAsFixed(1)}K',
              trend: _allocatedTrend,
              isTrendPositive: _allocatedTrendPositive,
              icon: Icons.assignment_outlined,
              color: AppColors.info,
              isGlass: true,
              onTap: () => context.push('/dashboard/reports/sales-dispatch'),
            ),
          ),
          KeyTip(
            label: '2',
            description: 'Today Sold',
            onTrigger: () => context.push('/dashboard/reports/sales-dispatch'),
            child: KPICard(
              title: 'Today Sold',
              value: '₹${(_todaySold / 1000).toStringAsFixed(1)}K',
              trend: _soldTrend,
              isTrendPositive: _soldTrendPositive,
              icon: Icons.shopping_bag_outlined,
              color: AppColors.success,
              isGlass: true,
              onTap: () => context.push('/dashboard/reports/sales-dispatch'),
            ),
          ),
          KeyTip(
            label: '3',
            description: 'Available Stock',
            onTrigger: () => context.push('/dashboard/reports/stock-valuation'),
            child: KPICard(
              title: 'Available Stock',
              value: '₹${(_availableStock / 1000000).toStringAsFixed(1)}M',
              trend: '', // No trend available for stock snapshot
              isTrendPositive: true,
              icon: Icons.inventory_2_outlined,
              color: AppColors.warning,
              isGlass: true,
              onTap: () => context.push('/dashboard/reports/stock-valuation'),
            ),
          ),
          KeyTip(
            label: '4',
            description: 'Out of Stock Items',
            onTrigger: () =>
                context.push('/dashboard/inventory/stock-overview'),
            child: KPICard(
              title: 'Out of Stock Items',
              value: '$_outOfStockItems',
              subtitle: 'Critical action required',
              icon: Icons.warning_amber_rounded,
              color: AppColors.error,
              isGlass: true,
              onTap: () => context.push('/dashboard/inventory/stock-overview'),
            ),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildCharts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout =
            constraints.maxWidth < Responsive.mobileBreakpoint;
        const spacing = 24.0;
        final compactChartHeight = Responsive.clamp(
          context,
          min: 220,
          max: 280,
          ratio: 0.55,
        );
        final wideChartHeight = Responsive.clamp(
          context,
          min: 220,
          max: 300,
          ratio: 0.22,
        );
        final gaugeChartHeight = Responsive.clamp(
          context,
          min: 180,
          max: 240,
          ratio: 0.18,
        );

        // Mobile: stack charts vertically
        if (isMobileLayout) {
          return Column(
            children: [
              _buildChartWrapper(
                'Sales vs Production',
                SalesVsProductionCard(
                  sales: _yearSales,
                  productionBatches: _monthProductionBatches,
                ),
                height: compactChartHeight,
                actions: [
                  _ChartAction(
                    label: 'View Sales & Dispatch',
                    icon: Icons.summarize_outlined,
                    onTap: () =>
                        context.push('/dashboard/reports/sales-dispatch'),
                  ),
                  _ChartAction(
                    label: 'View Production Report',
                    icon: Icons.factory_outlined,
                    onTap: () => context.push('/dashboard/reports/production'),
                  ),
                  _ChartAction(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onTap: _loadAllData,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildChartWrapper(
                'Monthly Revenue',
                SalesBarChart(monthlyRevenue: _monthlyRevenue),
                height: compactChartHeight,
                actions: [
                  _ChartAction(
                    label: 'Open Reports Hub',
                    icon: Icons.analytics_outlined,
                    onTap: () => context.push('/dashboard/reports'),
                  ),
                  _ChartAction(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onTap: _loadAllData,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildChartWrapper(
                'Stock Distribution',
                StockDonutChart(sections: _stockSections),
                height: compactChartHeight,
                actions: [
                  _ChartAction(
                    label: 'View Stock Valuation',
                    icon: Icons.inventory_2_outlined,
                    onTap: () =>
                        context.push('/dashboard/reports/stock-valuation'),
                  ),
                  _ChartAction(
                    label: 'Open Inventory',
                    icon: Icons.warehouse_outlined,
                    onTap: () =>
                        context.push('/dashboard/inventory/stock-overview'),
                  ),
                  _ChartAction(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onTap: _loadAllData,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildChartWrapper(
                'Production Capacity',
                Center(
                  child: ProductionGaugeChart(
                    percentage: _productionAchievement,
                    label: 'Target Achievement',
                  ),
                ),
                height: gaugeChartHeight,
                actions: [
                  _ChartAction(
                    label: 'View Production Report',
                    icon: Icons.factory_outlined,
                    onTap: () => context.push('/dashboard/reports/production'),
                  ),
                  _ChartAction(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onTap: _loadAllData,
                  ),
                ],
              ),
            ],
          );
        }

        final chartCards = [
          _buildChartWrapper(
            'Sales vs Production',
            SalesVsProductionCard(
              sales: _yearSales,
              productionBatches: _monthProductionBatches,
            ),
            height: wideChartHeight,
            actions: [
              _ChartAction(
                label: 'View Sales & Dispatch',
                icon: Icons.summarize_outlined,
                onTap: () => context.push('/dashboard/reports/sales-dispatch'),
              ),
              _ChartAction(
                label: 'View Production Report',
                icon: Icons.factory_outlined,
                onTap: () => context.push('/dashboard/reports/production'),
              ),
              _ChartAction(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onTap: _loadAllData,
              ),
            ],
          ),
          _buildChartWrapper(
            'Monthly Revenue',
            SalesBarChart(monthlyRevenue: _monthlyRevenue),
            height: wideChartHeight,
            actions: [
              _ChartAction(
                label: 'Open Reports Hub',
                icon: Icons.analytics_outlined,
                onTap: () => context.push('/dashboard/reports'),
              ),
              _ChartAction(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onTap: _loadAllData,
              ),
            ],
          ),
          _buildChartWrapper(
            'Stock Distribution',
            StockDonutChart(sections: _stockSections),
            height: wideChartHeight,
            actions: [
              _ChartAction(
                label: 'View Stock Valuation',
                icon: Icons.inventory_2_outlined,
                onTap: () => context.push('/dashboard/reports/stock-valuation'),
              ),
              _ChartAction(
                label: 'Open Inventory',
                icon: Icons.warehouse_outlined,
                onTap: () =>
                    context.push('/dashboard/inventory/stock-overview'),
              ),
              _ChartAction(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onTap: _loadAllData,
              ),
            ],
          ),
          _buildChartWrapper(
            'Production Capacity',
            Center(
              child: ProductionGaugeChart(
                percentage: _productionAchievement,
                label: 'Target Achievement',
              ),
            ),
            height: gaugeChartHeight,
            actions: [
              _ChartAction(
                label: 'View Production Report',
                icon: Icons.factory_outlined,
                onTap: () => context.push('/dashboard/reports/production'),
              ),
              _ChartAction(
                label: 'Refresh',
                icon: Icons.refresh_rounded,
                onTap: _loadAllData,
              ),
            ],
          ),
        ];

        return _buildResponsiveGrid(
          context,
          chartCards,
          spacing: spacing,
          twoColumnsOnTablet: true,
        );
      },
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    List<Widget> children, {
    double spacing = 24.0,
    bool twoColumnsOnTablet = false,
  }) {
    final useTwoColumnLayout =
        Responsive.isDesktop(context) ||
        (twoColumnsOnTablet && Responsive.isTablet(context));

    if (useTwoColumnLayout) {
      final List<Widget> rows = [];
      for (int i = 0; i < children.length; i += 2) {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              if (i + 1 < children.length) ...[
                SizedBox(width: spacing),
                Expanded(child: children[i + 1]),
              ] else ...[
                SizedBox(width: spacing),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        );
      }
      return Column(
        children: rows
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: EdgeInsets.only(
                  bottom: e.key == rows.length - 1 ? 0 : spacing,
                ),
                child: e.value,
              ),
            )
            .toList(),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: EdgeInsets.only(
                  bottom: e.key == children.length - 1 ? 0 : spacing,
                ),
                child: e.value,
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildTables() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableHeight = Responsive.clamp(
          context,
          min: 320,
          max: 420,
          ratio: 0.35,
        );

        final tables = [
          _buildTableWrapper(
            LowStockTable(
              items: _lowStockItems,
              onViewAll: () =>
                  context.push('/dashboard/inventory/stock-overview'),
            ),
            tableHeight: tableHeight,
          ),
          _buildTableWrapper(
            PendingDispatchTable(
              orders: _pendingOrders,
              onViewAll: () =>
                  context.push('/dashboard/reports/sales-dispatch'),
            ),
            tableHeight: tableHeight,
          ),
          _buildTableWrapper(
            RecentDispatchTable(
              dispatches: _recentDispatches,
              onViewAll: () => context.push('/dashboard/dispatch/history'),
            ),
            tableHeight: tableHeight,
          ),
          _buildTableWrapper(
            RecentBatchesTable(
              batches: _recentBatches,
              onViewAll: () => context.push('/dashboard/reports/production'),
            ),
            tableHeight: tableHeight,
          ),
          _buildTableWrapper(
            TopProductsTable(
              products: _topProducts,
              onViewAll: () =>
                  context.push('/dashboard/reports/sales-dispatch'),
            ),
            tableHeight: tableHeight,
          ),
          _buildTableWrapper(
            DashboardTable(
              title: 'System Activity',
              columns: const ['Component', 'Status', 'Last Checked'],
              rows: [
                [
                  'Sync Engine',
                  const DashboardStatusBadge(
                    label: 'Online',
                    color: AppColors.success,
                  ),
                  'Just now',
                ],
                [
                  'Local Database',
                  const DashboardStatusBadge(
                    label: 'Optimized',
                    color: AppColors.info,
                  ),
                  '2m ago',
                ],
                [
                  'API Subsystem',
                  const DashboardStatusBadge(
                    label: 'Stable',
                    color: AppColors.success,
                  ),
                  '5m ago',
                ],
                [
                  'Authentication',
                  const DashboardStatusBadge(
                    label: 'Secure',
                    color: AppColors.success,
                  ),
                  '12m ago',
                ],
              ],
            ),
            tableHeight: tableHeight,
          ),
        ];

        return _buildResponsiveGrid(context, tables, spacing: 24.0);
      },
    );
  }

  Widget _buildTableWrapper(Widget table, {required double tableHeight}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: tableHeight * 0.8,
        maxHeight: tableHeight,
      ),
      child: table,
    );
  }

  Widget _buildChartWrapper(
    String title,
    Widget chart, {
    double height = 240,
    List<_ChartAction> actions = const [],
  }) {
    final theme = Theme.of(context);
    return UnifiedCard(
      isGlass: true,
      showShadow: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (actions.isNotEmpty)
                PopupMenuButton<_ChartAction>(
                  tooltip: 'Options',
                  onSelected: (action) => action.onTap(),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  itemBuilder: (context) => actions
                      .map(
                        (action) => PopupMenuItem<_ChartAction>(
                          value: action,
                          child: Row(
                            children: [
                              Icon(
                                action.icon,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(action.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              else
                Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height * 0.75,
              maxHeight: height,
            ),
            child: chart,
          ),
        ],
      ),
    );
  }
}

class _ChartAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ChartAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
