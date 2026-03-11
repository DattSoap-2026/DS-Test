import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../models/types/cutting_types.dart';
import '../../models/types/task_types.dart';
import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/cutting_batch_service.dart';
import '../../services/production_stats_service.dart';
import '../../services/tasks_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/ui/offline_banner.dart';
import '../../services/products_service.dart';
import '../../utils/unit_scope_utils.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/dashboard/route_order_alert_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/utils/responsive.dart';
import '../../utils/mobile_header_typography.dart';

class ProductionDashboardConsolidatedScreen extends StatefulWidget {
  const ProductionDashboardConsolidatedScreen({super.key});

  @override
  State<ProductionDashboardConsolidatedScreen> createState() =>
      _ProductionDashboardConsolidatedScreenState();
}

class _ProductionDashboardConsolidatedScreenState
    extends State<ProductionDashboardConsolidatedScreen> {
  late final CuttingBatchService _cuttingService;
  late final ProductsService _productsService;
  late final ProductionStatsService _statsService;

  @override
  void initState() {
    super.initState();
    _cuttingService = context.read<CuttingBatchService>();
    _productsService = context.read<ProductsService>();
    _statsService = context.read<ProductionStatsService>();
    _checkAccess();
    _startAutoRefresh();
  }

  void _checkAccess() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.role.canAccessProduction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: Production operations restricted to authorized roles')),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
    });
  }

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  bool _isOnline = true;

  // Production Summary (Today)
  DailyProductionSummary? _todaySummary;

  List<CuttingBatch> _recentCuttingBatches = [];
  List<Map<String, dynamic>> _trendData = [];
  Map<String, dynamic> _todaysMix = {};

  List<Map<String, dynamic>> _lowStockItems = [];
  int _activeBatchesCount = 0;
  int _pendingTasksCount = 0;
  UserUnitScope _unitScope = const UserUnitScope(canViewAll: true, keys: {});
  bool _isScopeFallbackMode = false;
  Timer? _autoRefreshTimer;

  Future<void> _loadDashboardData({bool forcePageLoader = false}) async {
    if (!mounted) return;
    if (_isRefreshing) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });

    try {
      final currentUser = context.read<AuthProvider>().state.user;
      _unitScope = resolveUserUnitScope(currentUser);
      final hasNoScopeTokens = !_unitScope.canViewAll && _unitScope.keys.isEmpty;
      final isSupervisorCompatibilityMode =
          hasNoScopeTokens && currentUser?.role == UserRole.productionSupervisor;
      final effectiveScope = hasNoScopeTokens ? null : _unitScope;
      final showScopeFallbackBanner =
          hasNoScopeTokens && !isSupervisorCompatibilityMode;

      // 1. Check Connectivity Logic (Real check)
      final connectivityResult = await Connectivity().checkConnectivity();
      final isActuallyOffline = connectivityResult == ConnectivityResult.none;

      final today = DateTime.now();
      final dateStr = today.toIso8601String().split('T')[0];

      // Load cutting batch data
      final summary = await _cuttingService.getDailySummary(
        date: dateStr,
        shift: ShiftType.day,
        unitScope: effectiveScope,
      );
      final activeBatchesCount = await _cuttingService.getActiveBatchesCount(
        unitScope: effectiveScope,
      );
      final recentBatches = await _cuttingService.getCuttingBatches(
        limit: 10,
        unitScope: effectiveScope,
      );

      // Load analytics data (offline-first)
      final trendData = await _statsService.get7DayTrend(unitScope: effectiveScope);
      final todaysMix = await _statsService.getTodaysMix(unitScope: effectiveScope);

      // Load low stock items (from inventory service if available)
      final lowStockItems = await _getLowStockItems(unitScope: effectiveScope);

      if (mounted) {
        setState(() {
          _todaySummary = summary;
          _activeBatchesCount = activeBatchesCount;
          _recentCuttingBatches = recentBatches;
          _trendData = trendData;
          _todaysMix = todaysMix;

          _lowStockItems = lowStockItems;
          _isScopeFallbackMode = showScopeFallbackBanner;
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
          _isOnline = !isActuallyOffline;
        });

        // Load tasks (background)
        final user = context.read<AuthProvider>().state.user;
        if (user != null) {
          final tasksService = context.read<TasksService>();
          tasksService.getTasksForUser(user.id).then((tasks) {
            if (mounted) {
              setState(() {
                _pendingTasksCount = tasks
                    .where((t) => t.status != TaskStatus.completed)
                    .length;
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading production dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
          // Don't assume offline just because of error, but retain previous state or check connectivity again
        });

        // Check connectivity one last time to be sure
        final connectivityResult = await Connectivity().checkConnectivity();
        setState(() {
          _isOnline = connectivityResult != ConnectivityResult.none;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getLowStockItems({
    UserUnitScope? unitScope,
  }) async {
    try {
      final products = await _productsService.getProducts(status: 'active');
      final lowStock = products
          .where((p) => p.reorderLevel != null)
          .where((p) => p.stock <= (p.reorderLevel ?? 0))
          .where(
            (p) => matchesUnitScope(
              scope: unitScope ?? const UserUnitScope(canViewAll: true, keys: {}),
              tokens: [p.departmentId, ...p.allowedDepartmentIds],
              defaultIfNoScopeTokens: unitScope == null,
            ),
          )
          .map((p) {
            final reorderLevel = p.reorderLevel ?? 0.0;
            final stockRatio = reorderLevel > 0 ? (p.stock / reorderLevel) : 0.0;
            final stockPercent = reorderLevel > 0 ? stockRatio * 100 : 0.0;
            return {
              'productName': p.name,
              'stock': p.stock,
              'reorderLevel': reorderLevel,
              'unit': p.baseUnit,
              'stockRatio': stockRatio,
              'stockPercent': stockPercent,
              'isNegativeStock': p.stock < 0,
            };
          })
          .toList();
      lowStock.sort((a, b) {
        final aNeg = (a['isNegativeStock'] as bool?) ?? false;
        final bNeg = (b['isNegativeStock'] as bool?) ?? false;
        if (aNeg != bNeg) return aNeg ? -1 : 1;
        final ratioCompare = (a['stockRatio'] as double).compareTo(
          b['stockRatio'] as double,
        );
        if (ratioCompare != 0) return ratioCompare;
        return (a['stock'] as double).compareTo(b['stock'] as double);
      });
      return lowStock.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted || _isLoading || _isRefreshing) return;
      _loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;
    final isMobile = Responsive.width(context) < 900;
    final horizontalPagePadding = isMobile ? 12.0 : 24.0;
    final topPagePadding = isMobile ? 12.0 : 24.0;
    final bottomPagePadding = isMobile ? 20.0 : 24.0;

    return Scaffold(
      body: (_isLoading && !_hasLoadedOnce)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPagePadding,
                  topPagePadding,
                  horizontalPagePadding,
                  bottomPagePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offline Banner
                    OfflineBanner(isOffline: !_isOnline),
                    if (_isScopeFallbackMode) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No unit assigned. Contact admin.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // [LOCKED] Compact welcome header for Production Supervisor.
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 14,
                        vertical: isMobile ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Welcome back, ${user?.name ?? 'Supervisor'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: isMobile ? mobileHeaderTitleFontSize : null,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isMobile ? -0.1 : 0,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const RouteOrderAlertCard(),
                    SizedBox(height: isMobile ? 20 : 32),

                    // Top KPI Grid (Cards)
                    _buildKPIGrid(isMobile),
                    SizedBox(height: isMobile ? 16 : 24),

                    // Charts Section (Trend & Mix)
                    isMobile
                        ? Column(
                            children: [
                              _build7DayTrendCard(),
                              SizedBox(height: isMobile ? 16 : 24),
                              _buildTodaysMixCard(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _build7DayTrendCard()),
                              const SizedBox(width: 24),
                              Expanded(flex: 1, child: _buildTodaysMixCard()),
                            ],
                          ),
                    const SizedBox(height: 24),

                    // Recent Production & Low Stock
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recent Batches',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _recentCuttingBatches.isEmpty
                                  ? _buildEmptyState('No active batches')
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _recentCuttingBatches.length,
                                      itemBuilder: (context, index) {
                                        final batch =
                                            _recentCuttingBatches[index];
                                        return _buildBatchListItem(batch);
                                      },
                                    ),
                            ],
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alerts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildLowStockAlertCard(isMobile),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (isMobile && _lowStockItems.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Alerts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLowStockAlertCard(isMobile),
                    ],

                    const SizedBox(height: 32),
                    // Reports Links
                    const Text(
                      'Quick Actions & Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildActionCard(
                          'Cutting Yield',
                          Icons.analytics_outlined,
                          AppColors.info,
                          () => context.go('/dashboard/reports/cutting-yield'),
                        ),
                        _buildActionCard(
                          'Waste Analysis',
                          Icons.delete_outline,
                          AppColors.error,
                          () => context.go('/dashboard/reports/waste-analysis'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: null,
    );
  }

  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid(bool isMobile) {
    // Calculate total output from summary
    final totalUnits = _todaySummary?.totalFinishedUnits ?? 0;
    final rawEfficiency = _todaySummary?.avgEfficiency ?? 0.0;
    final efficiency = rawEfficiency.isFinite
        ? rawEfficiency.clamp(0.0, 100.0)
        : 0.0;
    final theme = Theme.of(context);

    // [LOCKED] Production Supervisor mobile KPI layout: always 2 cards per row.
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: isMobile ? 12 : 16,
      crossAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.2 : 1.35,
      children: [
        KPICard(
          title: 'Total Output',
          value: '$totalUnits',
          icon: Icons.inventory_2_outlined,
          color: theme.colorScheme.primary,
        ),
        KPICard(
          title: 'In-Progress',
          value: '$_activeBatchesCount',
          icon: Icons.layers_outlined,
          color: AppColors.warning,
        ),
        KPICard(
          title: 'Efficiency',
          value: '${efficiency.toStringAsFixed(1)}%',
          icon: Icons.speed,
          color: efficiency >= 90
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
        ),
        KPICard(
          title: 'Pending Tasks',
          value: '$_pendingTasksCount',
          icon: Icons.assignment_turned_in_outlined,
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _build7DayTrendCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = Responsive.width(context) < 900;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
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
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '7-Day Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: Responsive.clamp(
                context,
                min: 180,
                max: 260,
                ratio: 0.25,
              ),
            ),
            child: _trendData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 100,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.1,
                            ),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
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
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < _trendData.length) {
                                final date = _trendData[value.toInt()]['date']
                                    .toString()
                                    .split('-')
                                    .last;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _trendData.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              (e.value['units'] as num).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMixCard() {
    final theme = Theme.of(context);
    final isMobile = Responsive.width(context) < 900;
    final productMix =
        (_todaysMix['productMix'] as Map<String, dynamic>?) ?? {};

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Mix",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (productMix.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "No production logs",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...productMix.entries
                .take(5)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${e.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBatchListItem(CuttingBatch batch) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.2 : 0.1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${batch.finishedGoodName} - ${batch.unitsProduced} units',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              batch.stage.value.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.success,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
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
            color: theme.cardTheme.color,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockAlertCard(bool isMobile) {
    final theme = Theme.of(context);
    final isHealthy = _lowStockItems.isEmpty;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: isHealthy
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHealthy
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: isHealthy
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isHealthy ? 'All Stock Healthy' : 'Top 5 Low Stock Products',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHealthy
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isHealthy)
            Text(
              'No low stock products found for your current scope.',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.go('/dashboard/production/stock?filter=low-stock'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: _lowStockItems.map((item) {
                    final stock = (item['stock'] as num?)?.toDouble() ?? 0.0;
                    final reorder =
                        (item['reorderLevel'] as num?)?.toDouble() ?? 0.0;
                    final percent =
                        (item['stockPercent'] as num?)?.toDouble() ?? 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current: ${stock.toStringAsFixed(2)} ${item['unit']}  |  Reorder: ${reorder.toStringAsFixed(2)} ${item['unit']}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stock %: ${percent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: stock < 0
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
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
      ),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
