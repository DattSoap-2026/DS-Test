import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/user_types.dart';
import '../../models/types/sales_types.dart';
import '../../services/sales_service.dart';
import '../../services/database_service.dart';
import '../sales/sales_history_screen.dart';
import '../sales/salesman_kpi_drilldown_screen.dart';
import '../../services/sync_manager.dart';
import '../../widgets/ui/offline_banner.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/ui/unified_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import '../../utils/mobile_header_typography.dart';
import '../../services/sales_targets_service.dart';
import '../../services/settings_service.dart';

class SalesmanDashboardScreen extends StatefulWidget {
  const SalesmanDashboardScreen({super.key});

  @override
  State<SalesmanDashboardScreen> createState() =>
      _SalesmanDashboardScreenState();
}

class _SalesmanDashboardScreenState extends State<SalesmanDashboardScreen> {
  late final SalesService _salesService;
  late final SalesTargetsService _targetsService;
  late final SettingsService _settingsService;
  StreamSubscription<void>? _salesSubscription;
  Timer? _salesRefreshDebounce;
  String? _watchedSalesmanId;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasLoadedOnce = false;
  bool _isOnline = true;
  double _todaySalesAmount = 0;
  int _todayShopVisits = 0;
  double _monthlySalesAmount = 0;
  bool _isGpsTrackingEnabled = true;
  List<Sale> _recentSales = [];
  String _recentActivityDayLabel = '';
  List<double> _dailySalesTotals = List.filled(7, 0.0);
  List<String> _dailyLabels = [];
  
  // Target data
  double _targetAmount = 0;
  double _prevMonthSales = 0;
  int _workDaysCount = 0;
  int _totalWorkDays = 0;
  int _shopVisitsCount = 0;
  int _incentiveGoal = 0;

  @override
  void initState() {
    super.initState();
    _salesService = context.read<SalesService>();
    _targetsService = context.read<SalesTargetsService>();
    _settingsService = context.read<SettingsService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSalesWatcher();
      _loadDashboardData();
      Future.microtask(_runBackgroundSync);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<AuthProvider>(context).state.user;
    _startSalesWatcherForUser(user?.id);
  }

  void _startSalesWatcher() {
    final user = context.read<AuthProvider>().state.user;
    _startSalesWatcherForUser(user?.id);
  }

  void _startSalesWatcherForUser(String? userId) {
    final salesmanId = userId?.trim();
    if (salesmanId == null || salesmanId.isEmpty) return;
    if (_salesSubscription != null && _watchedSalesmanId == salesmanId) return;

    _salesSubscription?.cancel();
    _watchedSalesmanId = salesmanId;

    final dbService = context.read<DatabaseService>();
    _salesSubscription = dbService.sales
        .watchLazy(fireImmediately: false)
        .listen((_) => _scheduleDashboardReload());
  }

  DateTime? _parseSaleDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Failed to parse sale date: $dateStr');
      return null;
    }
  }

  void _scheduleDashboardReload() {
    _salesRefreshDebounce?.cancel();
    _salesRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _loadDashboardData();
    });
  }

  Future<void> _runBackgroundSync() async {
    try {
      await context.read<SyncManager>().syncOfflineSalesViaService();
    } catch (_) {
      // Best-effort sync only; dashboard should remain responsive.
    }
    if (!mounted) return;
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData({bool forcePageLoader = false}) async {
    if (!mounted || _isRefreshing || _isLoading) return;
    setState(() {
      final showFullLoader = forcePageLoader && !_hasLoadedOnce;
      _isLoading = showFullLoader;
      _isRefreshing = !showFullLoader;
    });

    try {
      final user = context.read<AuthProvider>().state.user;
      if (user != null) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final startOfToday = DateTime(now.year, now.month, now.day);

        // Fetch targets
        final targets = await _targetsService.getSalesTargets(user.id);
        final currentTarget = targets.cast<SalesTarget?>().firstWhere(
          (t) => t!.month == now.month && t.year == now.year,
          orElse: () => null,
        );

        // Fetch all sales for this salesman for this month
        final monthlySales = await _salesService.getSalesClient(
          salesmanId: user.id,
          startDate: startOfMonth,
        );
        
        // Fetch previous month sales
        final prevDate = DateTime(now.year, now.month - 1);
        final prevMonthStart = DateTime(prevDate.year, prevDate.month, 1);
        final prevMonthEnd = DateTime(prevDate.year, prevDate.month + 1, 0, 23, 59, 59);
        final prevMonthSales = await _salesService.getSalesClient(
          salesmanId: user.id,
          startDate: prevMonthStart,
          endDate: prevMonthEnd,
        );
        
        // Get settings for incentive calculation
        final prefs = await _settingsService.getReportsPreferences();
        final dailyCounterTarget = prefs.dailyCounterTarget;

        if (mounted) {
          setState(() {
            _targetAmount = currentTarget?.targetAmount ?? 0;
            
            _monthlySalesAmount = monthlySales.fold(
              0.0,
              (sum, s) => sum + s.totalAmount,
            );
            
            _prevMonthSales = prevMonthSales.fold(
              0.0,
              (sum, s) => sum + s.totalAmount,
            );

            final todaySales = monthlySales.where((s) {
              final createdAt = _parseSaleDate(s.createdAt);
              if (createdAt == null) return false;
              return createdAt.isAfter(startOfToday) ||
                  createdAt.isAtSameMomentAs(startOfToday);
            }).toList();

            _todaySalesAmount = todaySales.fold(
              0.0,
              (sum, s) => sum + s.totalAmount,
            );
            _todayShopVisits = todaySales
                .map((s) => s.recipientId)
                .toSet()
                .length;
            
            // Calculate work days (days with sales)
            final daysWithSales = <String>{};
            for (final sale in monthlySales) {
              final createdAt = _parseSaleDate(sale.createdAt);
              if (createdAt != null) {
                daysWithSales.add(DateFormat('yyyy-MM-dd').format(createdAt));
              }
            }
            _workDaysCount = daysWithSales.length;
            _totalWorkDays = now.day; // Days passed in current month
            
            // Calculate unique shops visited this month
            _shopVisitsCount = monthlySales
                .map((s) => s.recipientId)
                .toSet()
                .length;
            _incentiveGoal = dailyCounterTarget;

            // Calculate daily trend for last 7 days
            final dailyTotals = List.filled(7, 0.0);
            final labels = <String>[];
            final dateFormat = DateFormat('MMM dd');

            for (int i = 0; i < 7; i++) {
              final date = now.subtract(Duration(days: 6 - i));
              labels.add(dateFormat.format(date));

              final dateStart = DateTime(date.year, date.month, date.day);
              final dateEnd = DateTime(
                date.year,
                date.month,
                date.day,
                23,
                59,
                59,
                999,
              );

              final daySales = monthlySales.where((s) {
                final createdAt = _parseSaleDate(s.createdAt);
                if (createdAt == null) return false;
                return (createdAt.isAfter(dateStart) ||
                        createdAt.isAtSameMomentAs(dateStart)) &&
                    (createdAt.isBefore(dateEnd) ||
                        createdAt.isAtSameMomentAs(dateEnd));
              });

              dailyTotals[i] = daySales.fold(
                0.0,
                (sum, s) => sum + s.totalAmount,
              );
            }

            _dailySalesTotals = dailyTotals;
            _dailyLabels = labels;

            // Recent sales (latest activity day only, max 5 entries)
            final recentSales = [...monthlySales]
              ..sort((a, b) {
                final aDate = _parseSaleDate(a.createdAt);
                final bDate = _parseSaleDate(b.createdAt);
                if (aDate == null && bDate == null) return 0;
                if (aDate == null) return 1;
                if (bDate == null) return -1;
                return bDate.compareTo(aDate);
              });

            DateTime? latestActivityDay;
            for (final sale in recentSales) {
              final createdAt = _parseSaleDate(sale.createdAt);
              if (createdAt == null) continue;
              final day = DateTime(
                createdAt.year,
                createdAt.month,
                createdAt.day,
              );
              if (latestActivityDay == null || day.isAfter(latestActivityDay)) {
                latestActivityDay = day;
              }
            }

            final activityDay = latestActivityDay;
            if (activityDay != null) {
              final nextDay = activityDay.add(const Duration(days: 1));
              _recentSales = recentSales
                  .where((sale) {
                    final createdAt = _parseSaleDate(sale.createdAt);
                    if (createdAt == null) return false;
                    return !createdAt.isBefore(activityDay) &&
                        createdAt.isBefore(nextDay);
                  })
                  .take(5)
                  .toList();
              _recentActivityDayLabel = DateFormat(
                'dd MMM yyyy',
              ).format(activityDay);
            } else {
              _recentSales = [];
              _recentActivityDayLabel = '';
            }
            _isLoading = false;
            _isRefreshing = false;
            _hasLoadedOnce = true;
            _isOnline = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isRefreshing = false;
            _hasLoadedOnce = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading salesman stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _hasLoadedOnce = true;
          _isOnline = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    _salesRefreshDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_hasLoadedOnce) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = context.watch<AuthProvider>().state.user;
    if (user == null) return const Scaffold(body: Center(child: Text('User not found')));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          if (!_isOnline) OfflineBanner(isOffline: !_isOnline),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadDashboardData(forcePageLoader: false),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;
                  final double horizontalPadding = isMobile ? 12.0 : 24.0;
                  final double verticalPadding = isMobile ? 12.0 : 24.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeBanner(user, isMobile),
                        const SizedBox(height: 24),
                        _buildKPIsGrid(isMobile),
                        const SizedBox(height: 24),
                        _buildChartAndTargetRow(isMobile),
                        const SizedBox(height: 24),
                        _buildRecentSalesSection(isMobile),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(AppUser user, bool isMobile) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
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
                  'Welcome, ${user.name}!',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: isMobile ? mobileHeaderTitleFontSize : 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isMobile ? -0.1 : 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your sales performance overview',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: theme.colorScheme.onPrimary.withValues(
              alpha: _isGpsTrackingEnabled ? 0.2 : 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isGpsTrackingEnabled = !_isGpsTrackingEnabled;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isGpsTrackingEnabled
                          ? Icons.gps_fixed_rounded
                          : Icons.gps_off_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isGpsTrackingEnabled ? 'GPS' : 'GPS',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOCKED: UI Overflow Fix - 2026-02-02
  Widget _buildKPIsGrid(bool isMobile) {
    const spacing = 16.0;
    final cards = [
      KPICard(
        title: 'Today\'s Sale',
        value: '₹${_todaySalesAmount.toStringAsFixed(2)}',
        subtitle: '$_todayShopVisits shops visited',
        icon: Icons.attach_money,
        color: AppColors.success,
        onTap: _openDailyShopSalesDrilldown,
      ),
      KPICard(
        title: 'Today\'s Shops',
        value: '$_todayShopVisits',
        subtitle: 'Unique customers',
        icon: Icons.people_outline,
        color: AppColors.info,
        onTap: _openDailyShopSalesDrilldown,
      ),
      KPICard(
        title: 'Monthly Sales',
        value: 'Rs ${_monthlySalesAmount.toStringAsFixed(2)}',
        subtitle: 'Current month',
        icon: Icons.trending_up_rounded,
        color: AppColors.info,
        onTap: _openMonthlyRouteSalesDrilldown,
      ),
      KPICard(
        title: 'Pending Returns',
        value: '0',
        subtitle: 'Approval needed',
        icon: Icons.refresh,
        color: AppColors.warning,
        onTap: _openPendingReturns,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth < 360
            ? 1
            : maxWidth < 760
            ? 2
            : maxWidth < 1120
            ? 3
            : 4;
        final usableWidth = maxWidth - spacing * (columns - 1);
        final cardWidth = (usableWidth > 0 ? usableWidth : 0.0) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  void _openDailyShopSalesDrilldown() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesmanKpiDrilldownScreen(
          mode: SalesmanKpiDrilldownMode.dailyShopSales,
        ),
      ),
    );
  }

  void _openMonthlyRouteSalesDrilldown() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesmanKpiDrilldownScreen(
          mode: SalesmanKpiDrilldownMode.monthlyRouteSales,
        ),
      ),
    );
  }

  void _openPendingReturns() {
    context.push('/dashboard/returns-management');
  }

  Widget _buildChartAndTargetRow(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildCompactTargetCard(isMobile),
          const SizedBox(height: 16),
          _buildSalesChartCard(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildSalesChartCard(isMobile)),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildCompactTargetCard(isMobile)),
      ],
    );
  }

  Widget _buildSalesChartCard(bool isMobile) {
    final theme = Theme.of(context);
    final peakDailySales = _dailySalesTotals.fold<double>(
      0.0,
      (maxValue, value) => value > maxValue ? value : maxValue,
    );
    final chartMaxY = peakDailySales <= 0
        ? 1000.0
        : (peakDailySales * 1.2).ceilToDouble();

    return UnifiedCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Daily Sales Trend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: isMobile ? 220 : 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMaxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _dailyLabels.length) {
                          return const SizedBox.shrink();
                        }
                        if (isMobile && index % 2 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _dailyLabels[index],
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        if (value % 4000 == 0) {
                          return Text(
                            '${(value / 1000).toInt()}K',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 9,
                            ),
                          );
                        }
                        return const Text('');
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
                barGroups: List.generate(_dailySalesTotals.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _dailySalesTotals[i],
                        color: theme.colorScheme.primary,
                        width: isMobile ? 12 : 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTargetCard(bool isMobile) {
    final theme = Theme.of(context);
    final progress = _targetAmount > 0 ? (_monthlySalesAmount / _targetAmount).clamp(0.0, 1.0) : 0.0;
    final remaining = (_targetAmount - _monthlySalesAmount).clamp(0.0, double.infinity);

    return UnifiedCard(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${DateFormat('MMMM').format(DateTime.now())} Target',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Compact Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildCompactMetric(
                  '₹${NumberFormat.compact().format(_monthlySalesAmount)}',
                  '₹${NumberFormat.compact().format(_targetAmount)}',
                  theme,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: theme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _buildCompactMetric(
                  'Prev',
                  '₹${NumberFormat.compact().format(_prevMonthSales)}',
                  theme,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: theme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _buildCompactMetric(
                  'Rem',
                  '₹${NumberFormat.compact().format(remaining)}',
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Compact Bottom Row: Work Days | Incentive | Achievement
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_workDaysCount/$_totalWorkDays Days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 12,
                color: theme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Text(
                  '$_shopVisitsCount/$_incentiveGoal shops',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 12,
                color: theme.dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      _monthlySalesAmount >= _prevMonthSales ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: _monthlySalesAmount >= _prevMonthSales ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _prevMonthSales > 0 
                        ? '${(((_monthlySalesAmount - _prevMonthSales) / _prevMonthSales) * 100).abs().toStringAsFixed(1)}%'
                        : '0%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _monthlySalesAmount >= _prevMonthSales ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSalesSection(bool isMobile) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            if (_recentActivityDayLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _recentActivityDayLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesHistoryScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentSales.isEmpty)
          UnifiedCard(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  _recentActivityDayLabel.isEmpty
                      ? 'No transactions found'
                      : 'No transactions on $_recentActivityDayLabel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ..._recentSales.map((sale) {
            return UnifiedCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.recipientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _formatDateSafe(sale.createdAt, pattern: 'hh:mm a'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${sale.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = _parseSaleDate(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }
}

