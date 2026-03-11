import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../services/settings_service.dart';
import '../../services/sales_targets_service.dart';
import '../../services/sales_service.dart';
import '../../services/customers_service.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/types/sales_types.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/responsive.dart';

import '../ui/shimmer_loading.dart';
import '../../utils/app_logger.dart';
import '../../widgets/dashboard/kpi_card.dart';

class DailyBreakdownData {
  final String date;
  final int counters;
  final double totalSale;
  final double dailyIncentive;
  final bool isWorkDay;

  DailyBreakdownData({
    required this.date,
    required this.counters,
    required this.totalSale,
    required this.dailyIncentive,
    required this.isWorkDay,
  });
}

class PerformanceSummary {
  final int totalWorkDays;
  final double totalSalesAmount;
  final int newCounters;
  final double totalEarnings;
  final List<DailyBreakdownData> dailyBreakdown;

  PerformanceSummary({
    required this.totalWorkDays,
    required this.totalSalesAmount,
    required this.newCounters,
    required this.totalEarnings,
    required this.dailyBreakdown,
  });
}

class TargetAnalysisWidget extends StatefulWidget {
  final bool showDailyBreakdown;
  final String? className;

  const TargetAnalysisWidget({
    super.key,
    this.showDailyBreakdown = false,
    this.className,
  });

  @override
  State<TargetAnalysisWidget> createState() => _TargetAnalysisWidgetState();
}

class _TargetAnalysisWidgetState extends State<TargetAnalysisWidget> {
  late SettingsService _settingsService;
  late SalesTargetsService _targetsService;
  late SalesService _salesService;
  late CustomersService _customersService;

  bool _loading = true;
  ReportsPreferences? _prefs;
  SalesTarget? _currentTarget;
  PerformanceSummary? _summary;
  int _newCountersCount = 0;

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _targetsService = context.read<SalesTargetsService>();
    _customersService = context.read<CustomersService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _salesService = context.read<SalesService>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.state.user;
    if (user == null) return;

    if (mounted) setState(() => _loading = true);

    try {
      _prefs = await _settingsService.getReportsPreferences();
      final targets = await _targetsService.getSalesTargets(user.id);
      final now = DateTime.now();
      _currentTarget = targets.firstWhere(
        (t) => t.month == now.month && t.year == now.year,
        orElse: () => SalesTarget(
          id: '',
          salesmanId: user.id,
          salesmanName: user.name,
          month: now.month,
          year: now.year,
          targetAmount: 0,
          achievedAmount: 0,
        ),
      );

      // Feature flag for backward compatibility
      bool useOldCalculation = false;

      final monthStart = DateTime(now.year, now.month, 1);

      double aggregatedAchievedAmount = 0.0;
      if (!useOldCalculation) {
        aggregatedAchievedAmount = await _salesService.getAggregateSalesTotal(
          salesmanId: user.id,
          startDate: monthStart,
          endDate: now,
        );
      }

      if (!useOldCalculation && _currentTarget != null) {
        _currentTarget = SalesTarget(
          id: _currentTarget!.id,
          salesmanId: _currentTarget!.salesmanId,
          salesmanName: _currentTarget!.salesmanName,
          month: _currentTarget!.month,
          year: _currentTarget!.year,
          targetAmount: _currentTarget!.targetAmount,
          achievedAmount: aggregatedAchievedAmount,
          routeTargets: _currentTarget!.routeTargets,
          createdAt: _currentTarget!.createdAt,
        );
      }
      final sales = await _salesService.getSalesClient(
        salesmanId: user.id,
        startDate: monthStart,
        endDate: now,
      );

      if (user.assignedRoutes != null && user.assignedRoutes!.isNotEmpty) {
        final customers = await _customersService.getCustomers(
          routes: user.assignedRoutes,
        );
        final monthStartStr = monthStart.toIso8601String();
        _newCountersCount = customers
            .where((c) => c.createdAt.compareTo(monthStartStr) >= 0)
            .length;
      }

      _calculatePerformance(sales);
    } catch (e) {
      AppLogger.error(
        'Error fetching performance data',
        error: e,
        tag: 'Dashboard',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _calculatePerformance(List<Sale> sales) {
    if (_prefs == null) return;

    final dailyIncentiveTarget = _prefs!.dailyCounterTarget;
    final dailyIncentiveAmount = _prefs!.dailyIncentiveAmount;
    final newCustomerIncentive = _prefs!.newCustomerIncentive;

    final Map<String, List<Sale>> salesByDay = {};
    for (var sale in sales) {
      final dateStr = sale.createdAt.split('T')[0];
      if (!salesByDay.containsKey(dateStr)) salesByDay[dateStr] = [];
      salesByDay[dateStr]!.add(sale);
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = now.difference(monthStart).inDays + 1;

    double totalDailyIncentive = 0;
    final List<DailyBreakdownData> breakdown = [];

    for (int i = 0; i < daysInMonth; i++) {
      final date = monthStart.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final daySales = salesByDay[dateStr] ?? [];

      final counters = daySales.map((s) => s.recipientId).toSet().length;
      final totalSale = daySales.fold(0.0, (sum, s) => sum + s.totalAmount);
      final earnedIncentive = counters >= dailyIncentiveTarget
          ? dailyIncentiveAmount
          : 0.0;

      if (earnedIncentive > 0) totalDailyIncentive += earnedIncentive;

      breakdown.add(
        DailyBreakdownData(
          date: dateStr,
          counters: counters,
          totalSale: totalSale,
          dailyIncentive: earnedIncentive,
          isWorkDay: daySales.isNotEmpty,
        ),
      );
    }

    final totalNewCustomerIncentive = _newCountersCount * newCustomerIncentive;

    _summary = PerformanceSummary(
      totalWorkDays: salesByDay.length,
      totalSalesAmount: sales.fold(0.0, (sum, s) => sum + s.totalAmount),
      newCounters: _newCountersCount,
      totalEarnings: totalDailyIncentive + totalNewCustomerIncentive,
      dailyBreakdown: breakdown.reversed.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Column(
        children: [
          ShimmerLoading(
            child: Container(
              height: Responsive.clamp(
                context,
                min: 160,
                max: 240,
                ratio: 0.25,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ShimmerLoading(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final achievementPercentage = (_currentTarget?.targetAmount ?? 0) > 0
        ? ((_currentTarget?.achievedAmount ?? 0) /
                  _currentTarget!.targetAmount) *
              100
        : 0.0;

    final requiredWorkDays = _prefs?.requiredMonthlyWorkDays ?? 18;
    final dailyIncentiveTarget = _prefs?.dailyCounterTarget ?? 10;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayData = _summary?.dailyBreakdown.firstWhere(
      (d) => d.date == todayStr,
      orElse: () => DailyBreakdownData(
        date: todayStr,
        counters: 0,
        totalSale: 0,
        dailyIncentive: 0,
        isWorkDay: false,
      ),
    );
    final todayCounters = todayData?.counters ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthlySummary(achievementPercentage),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            final cards = _buildKPICards(
              achievementPercentage,
              requiredWorkDays,
              dailyIncentiveTarget,
              todayCounters,
            );

            if (isMobile) {
              return Column(
                children: cards
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: c,
                      ),
                    )
                    .toList(),
              );
            }

            return Row(
              children: cards
                  .map(
                    (w) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: w,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        if (widget.showDailyBreakdown) ...[
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Daily Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildBreakdownList(),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildMonthlySummary(double achievementPct) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final bool isAchieved = achievementPct >= 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Target Achievement',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievementPct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAchieved ? Icons.military_tech : Icons.trending_up,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (achievementPct / 100).clamp(0, 1),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.4,
                        ),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(
                'Current',
                currencyFormat.format(_currentTarget?.achievedAmount ?? 0),
              ),
              _summaryItem(
                'Target',
                currencyFormat.format(_currentTarget?.targetAmount ?? 0),
              ),
              _summaryItem(
                'Earning',
                currencyFormat.format(_summary?.totalEarnings ?? 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildKPICards(
    double achievementPct,
    int requiredWorkDays,
    int dailyTarget,
    int todayCounters,
  ) {
    final int workDays = _summary?.totalWorkDays ?? 0;
    final int remainingDays = max(0, requiredWorkDays - workDays);

    return [
      KPICard(
        title: 'Work Days',
        value: '$workDays Days',
        subtitle: '$remainingDays more needed',
        icon: Icons.calendar_today,
        color: AppColors.info,
        progress: requiredWorkDays > 0 ? workDays / requiredWorkDays : 0,
      ),
      KPICard(
        title: "Today's Shops",
        value: '$todayCounters Shops',
        subtitle: todayCounters >= dailyTarget
            ? 'Incentive Earned!'
            : '${dailyTarget - todayCounters} more for incentive',
        icon: Icons.storefront,
        color: AppColors.warning,
        progress: dailyTarget > 0 ? todayCounters / dailyTarget : 0,
      ),
      KPICard(
        title: 'New Counters',
        value: '$_newCountersCount',
        subtitle: 'Monthly Contribution',
        icon: Icons.person_add,
        color: AppColors.success,
        progress: 1.0,
      ),
    ];
  }

  Widget _buildBreakdownList() {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final data = _summary?.dailyBreakdown ?? [];

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No performance data for this month.',
            style: TextStyle(color: AppColors.lightTextMuted),
          ),
        ),
      );
    }

    return Column(
      children: data.map((day) {
        final date = DateTime.parse(day.date);
        final bool isToday =
            DateFormat('yyyy-MM-dd').format(date) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.counters} Shop Visits',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Revenue: ${currencyFormat.format(day.totalSale)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Incentive', style: TextStyle(fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      day.dailyIncentive > 0
                          ? currencyFormat.format(day.dailyIncentive)
                          : '₹0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: day.dailyIncentive > 0
                            ? AppColors.success
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      day.isWorkDay ? Icons.check_circle : Icons.cancel,
                      color: day.isWorkDay
                          ? AppColors.success
                          : Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.isWorkDay ? 'Work' : 'Off',
                      style: TextStyle(
                        fontSize: 10,
                        color: day.isWorkDay
                            ? AppColors.success
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
