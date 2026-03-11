import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth/auth_provider.dart';
import '../../services/customers_service.dart';
import '../../services/sales_service.dart';
import '../../services/sales_targets_service.dart';
import '../../services/settings_service.dart';
import '../../models/types/sales_types.dart';
import '../../utils/app_toast.dart';
import '../../utils/mobile_header_typography.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../widgets/dashboard/target_analysis_widget.dart';
import '../../widgets/reports/report_export_actions.dart';

class MyPerformanceScreen extends StatefulWidget {
  const MyPerformanceScreen({super.key});

  @override
  State<MyPerformanceScreen> createState() => _MyPerformanceScreenState();
}

class _MyPerformanceScreenState extends State<MyPerformanceScreen>
    with ReportPdfMixin<MyPerformanceScreen> {
  late final SettingsService _settingsService;
  late final SalesTargetsService _targetsService;
  late final SalesService _salesService;
  late final CustomersService _customersService;

  List<_DailyPerformanceExportRow> _dailyRows = [];
  bool _loadingExportData = true;
  int _widgetVersion = 0;

  String _salesmanName = 'N/A';
  DateTime _activeMonth = DateTime.now();
  double _targetAmount = 0;
  double _achievedAmount = 0;
  double _totalSales = 0;
  double _totalIncentive = 0;
  int _workDays = 0;
  int _newCounters = 0;

  Future<void> _handleBackNavigation() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      await navigator.maybePop();
      return;
    }
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _targetsService = context.read<SalesTargetsService>();
    _salesService = context.read<SalesService>();
    _customersService = context.read<CustomersService>();
    _loadExportData();
  }

  Future<void> _loadExportData() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) {
      if (mounted) {
        setState(() {
          _dailyRows = [];
          _loadingExportData = false;
          _salesmanName = 'N/A';
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _loadingExportData = true);
    }

    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      final prefs = await _settingsService.getReportsPreferences();
      final targets = await _targetsService.getSalesTargets(user.id);
      final currentTarget = targets.firstWhere(
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
      final sales = await _salesService.getSalesClient(
        salesmanId: user.id,
        startDate: monthStart,
        endDate: monthEnd,
      );

      var newCountersCount = 0;
      if (user.assignedRoutes != null && user.assignedRoutes!.isNotEmpty) {
        final customers = await _customersService.getCustomers(
          routes: user.assignedRoutes,
        );
        final monthStartStr = monthStart.toIso8601String();
        newCountersCount = customers
            .where((c) => c.createdAt.compareTo(monthStartStr) >= 0)
            .length;
      }

      final dailyCounterTarget = prefs.dailyCounterTarget;
      final dailyIncentiveAmount = prefs.dailyIncentiveAmount.toDouble();

      final groupedSales = <String, List<Sale>>{};
      for (final sale in sales) {
        final day = sale.createdAt.split('T').first;
        groupedSales.putIfAbsent(day, () => <Sale>[]).add(sale);
      }

      final today = DateTime.now();
      final daysToInclude = today.difference(monthStart).inDays + 1;

      var totalDailyIncentive = 0.0;
      final rows = <_DailyPerformanceExportRow>[];
      for (var i = 0; i < daysToInclude; i++) {
        final date = monthStart.add(Duration(days: i));
        final dayKey = DateFormat('yyyy-MM-dd').format(date);
        final daySales = groupedSales[dayKey] ?? const <Sale>[];

        final uniqueCounters = daySales.map((s) => s.recipientId).toSet().length;
        final dayAmount = daySales.fold<double>(
          0,
          (sum, s) => sum + s.totalAmount,
        );
        final dayIncentive = uniqueCounters >= dailyCounterTarget
            ? dailyIncentiveAmount
            : 0.0;
        totalDailyIncentive += dayIncentive;

        rows.add(
          _DailyPerformanceExportRow(
            date: dayKey,
            counters: uniqueCounters,
            totalSale: dayAmount,
            dailyIncentive: dayIncentive,
            isWorkDay: daySales.isNotEmpty,
          ),
        );
      }

      final totalSalesAmount = sales.fold<double>(
        0,
        (sum, s) => sum + s.totalAmount,
      );
      final newCustomerIncentive = prefs.newCustomerIncentive.toDouble();
      final totalIncentive = totalDailyIncentive +
          (newCountersCount * newCustomerIncentive);

      if (mounted) {
        setState(() {
          _dailyRows = rows.reversed.toList();
          _salesmanName = user.name;
          _activeMonth = now;
          _targetAmount = currentTarget.targetAmount;
          _achievedAmount = currentTarget.achievedAmount;
          _totalSales = totalSalesAmount;
          _totalIncentive = totalIncentive;
          _workDays = groupedSales.length;
          _newCounters = newCountersCount;
          _loadingExportData = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingExportData = false);
      AppToast.showError(context, 'Failed to load performance export data: $e');
    }
  }

  @override
  bool get hasExportData => _dailyRows.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Date',
      'Counters',
      'Sales (Rs)',
      'Daily Incentive (Rs)',
      'Work Day',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _dailyRows
        .map(
          (row) => [
            DateFormat('dd-MMM-yyyy').format(DateTime.parse(row.date)),
            row.counters,
            row.totalSale.toStringAsFixed(2),
            row.dailyIncentive.toStringAsFixed(2),
            row.isWorkDay ? 'Yes' : 'No',
          ],
        )
        .toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Salesman': _salesmanName,
      'Month': DateFormat('MMM yyyy').format(_activeMonth),
      'Target': '₹${_targetAmount.toStringAsFixed(0)}',
      'Achieved': '₹${_achievedAmount.toStringAsFixed(0)}',
      'Total Sales': '₹${_totalSales.toStringAsFixed(0)}',
      'Total Earnings': '₹${_totalIncentive.toStringAsFixed(0)}',
      'Work Days': _workDays.toString(),
      'New Counters': _newCounters.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final useMobileTypography = useMobileHeaderTypographyForWidth(width);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isMobile)
                IconButton(
                  onPressed: _handleBackNavigation,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                ),
              Expanded(
                child: Text(
                  'My Performance',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: useMobileTypography
                        ? mobileHeaderTitleFontSize
                        : 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: useMobileTypography ? -0.2 : 0,
                  ),
                ),
              ),
              ReportExportActions(
                isLoading: isExporting || _loadingExportData,
                onExport: () => exportReport('My Performance Report'),
                onPrint: () => printReport('My Performance Report'),
                onRefresh: () async {
                  setState(() => _widgetVersion++);
                  await _loadExportData();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track your monthly progress and achieved targets.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          TargetAnalysisWidget(
            key: ValueKey(_widgetVersion),
            showDailyBreakdown: true,
          ),
        ],
      ),
    );
  }
}

class _DailyPerformanceExportRow {
  final String date;
  final int counters;
  final double totalSale;
  final double dailyIncentive;
  final bool isWorkDay;

  const _DailyPerformanceExportRow({
    required this.date,
    required this.counters,
    required this.totalSale,
    required this.dailyIncentive,
    required this.isWorkDay,
  });
}
