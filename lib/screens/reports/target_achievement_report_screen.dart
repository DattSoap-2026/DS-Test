import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../services/sales_targets_service.dart';
import '../../services/sales_service.dart';

import '../../services/users_service.dart';

import '../../models/types/sales_types.dart';
import '../../models/types/user_types.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/app_toast.dart';
import '../../utils/responsive.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class TargetAchievementReportScreen extends StatefulWidget {
  const TargetAchievementReportScreen({super.key});

  @override
  State<TargetAchievementReportScreen> createState() =>
      _TargetAchievementReportScreenState();
}

class _TargetAchievementReportScreenState
    extends State<TargetAchievementReportScreen>
    with ReportPdfMixin<TargetAchievementReportScreen> {
  late final SalesTargetsService _targetsService;
  late final SalesService _salesService;
  late final UsersService _usersService;

  bool _isLoading = true;
  bool _loadingData = false;

  List<AppUser> _salesmen = [];
  String? _selectedSalesmanId;
  DateTime _selectedDate = DateTime.now();

  SalesTarget? _currentTarget;
  SalesTarget? _prevTarget;
  List<Sale> _currentSales = [];
  List<Sale> _prevSales = [];
  final ScrollController _monthScrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  static const double _routeColumnWidth = 120;
  static const double _monthSectionWidth = 300;
  static const double _tableHeaderHeight = 68;
  static const double _tableRowHeight = 44;

  @override
  void initState() {
    super.initState();
    _targetsService = context.read<SalesTargetsService>();
    _salesService = context.read<SalesService>();
    _usersService = context.read<UsersService>();
    _init();
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    if (user.role == UserRole.salesman) {
      _selectedSalesmanId = user.id;
      _isLoading = false;
      _loadData();
    } else {
      try {
        final salesmen = await _usersService.getUsers(role: UserRole.salesman);
        if (mounted) {
          setState(() {
            _salesmen = salesmen;
            if (salesmen.isNotEmpty) _selectedSalesmanId = salesmen[0].id;
            _isLoading = false;
          });
          if (_selectedSalesmanId != null) _loadData();
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadData() async {
    if (_selectedSalesmanId == null) return;

    setState(() => _loadingData = true);
    try {
      final currentStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final currentEnd = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        0,
        23,
        59,
        59,
      );

      final prevDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      final prevStart = DateTime(prevDate.year, prevDate.month, 1);
      final prevEnd = DateTime(
        prevDate.year,
        prevDate.month + 1,
        0,
        23,
        59,
        59,
      );

      // Fetch targets
      final allTargets = await _targetsService.getSalesTargets(
        _selectedSalesmanId,
      );
      final currentT = allTargets.firstWhere(
        (t) => t.month == _selectedDate.month && t.year == _selectedDate.year,
        orElse: () => SalesTarget(
          id: '',
          salesmanId: _selectedSalesmanId ?? '',
          salesmanName: '',
          month: _selectedDate.month,
          year: _selectedDate.year,
          targetAmount: 0,
          achievedAmount: 0,
          routeTargets: {},
        ),
      );
      final prevT = allTargets.firstWhere(
        (t) => t.month == prevDate.month && t.year == prevDate.year,
        orElse: () => SalesTarget(
          id: '',
          salesmanId: _selectedSalesmanId ?? '',
          salesmanName: '',
          month: prevDate.month,
          year: prevDate.year,
          targetAmount: 0,
          achievedAmount: 0,
          routeTargets: {},
        ),
      );

      // Fetch sales
      final cSales = await _salesService.getSalesClient(
        salesmanId: _selectedSalesmanId,
        startDate: currentStart,
        endDate: currentEnd,
        recipientType: 'customer',
      );
      final pSales = await _salesService.getSalesClient(
        salesmanId: _selectedSalesmanId,
        startDate: prevStart,
        endDate: prevEnd,
        recipientType: 'customer',
      );

      if (mounted) {
        setState(() {
          _currentTarget = currentT;
          _prevTarget = prevT;
          _currentSales = cSales;
          _prevSales = pSales;
          _isLoading = false;
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingData = false;
        });
        AppToast.showError(context, 'Error loading target comparison: $e');
      }
    }
  }

  @override
  bool get hasExportData => _currentTarget != null || _currentSales.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return ['Route', 'Target (₹)', 'Sales (₹)', 'Achievement %'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final routes = <String>{};
    if (_currentTarget?.routeTargets != null) {
      routes.addAll(_currentTarget!.routeTargets!.keys);
    }
    if (_prevTarget?.routeTargets != null) {
      routes.addAll(_prevTarget!.routeTargets!.keys);
    }
    for (var s in _currentSales) {
      if (s.route != null) routes.add(s.route!);
    }
    for (var s in _prevSales) {
      if (s.route != null) routes.add(s.route!);
    }

    final sortedRoutes = routes.toList()..sort();

    return sortedRoutes.map((route) {
      final tgt = (_currentTarget?.routeTargets?[route] as num? ?? 0)
          .toDouble();
      final sold = _currentSales
          .where((s) => s.route == route)
          .fold(0.0, (sum, s) => sum + s.totalAmount);
      final ach = tgt > 0 ? (sold / tgt * 100) : 0.0;

      return [
        route,
        tgt.toStringAsFixed(2),
        sold.toStringAsFixed(2),
        '${ach.toStringAsFixed(1)}%',
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    String salesmanName = 'N/A';
    if (_selectedSalesmanId != null) {
      try {
        salesmanName = _salesmen
            .firstWhere((s) => s.id == _selectedSalesmanId)
            .name;
      } catch (_) {}
    }

    final double totalCurrentTgt = (_currentTarget?.targetAmount ?? 0)
        .toDouble();
    final double totalCurrentSale = _currentSales.fold(
      0.0,
      (sum, s) => sum + s.totalAmount,
    );
    final currentAch = totalCurrentTgt > 0
        ? (totalCurrentSale / totalCurrentTgt * 100)
        : 0.0;

    return {
      'Month/Year': DateFormat('MMM yyyy').format(_selectedDate),
      'Salesman': salesmanName,
      'Total Target': '₹${NumberFormat.compact().format(totalCurrentTgt)}',
      'Current Sold': '₹${NumberFormat.compact().format(totalCurrentSale)}',
      'Overall Achievement': '${currentAch.toStringAsFixed(1)}%',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Achievement'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Target Achievement Report'),
            onPrint: () => printReport('Target Achievement Report'),
            onRefresh: _loadData,
          ),
        ],
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      'Detailed breakdown of targets and achievements.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (user?.role != UserRole.salesman && _salesmen.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _buildSalesmanSelector(theme),
                    ),
                  _buildHorizontalMonthPicker(theme),
                  const SizedBox(height: 16),
                  if (_loadingData)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildReportContent(theme),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildSalesmanSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSalesmanId,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          items: _salesmen
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          (s.name.trim().isNotEmpty ? s.name.trim()[0] : '?')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _selectedSalesmanId = val);
            _loadData();
          },
        ),
      ),
    );
  }

  List<DateTime> _visibleMonths(DateTime now) {
    return List.generate(6, (i) {
      return DateTime(now.year, now.month - i, 1);
    }).reversed.toList();
  }

  void _scrollToSelectedMonth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_monthScrollController.hasClients) return;

      final months = _visibleMonths(DateTime.now());
      final selectedIndex = months.indexWhere(
        (d) => d.year == _selectedDate.year && d.month == _selectedDate.month,
      );

      if (selectedIndex >= 0) {
        _monthScrollController.animateTo(
          selectedIndex * 100.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildHorizontalMonthPicker(ThemeData theme) {
    final now = DateTime.now();
    _scrollToSelectedMonth();
    final months = _visibleMonths(now);

    return SingleChildScrollView(
      controller: _monthScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: months.map((date) {
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedDate = date);
                _loadData();
                _scrollToSelectedMonth();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(
                  minWidth: 80,
                  maxWidth: 100,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(date).toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.year.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportContent(ThemeData theme) {
    // Process data for route-wise view
    final routes = <String>{};
    if (_currentTarget?.routeTargets != null) {
      routes.addAll(_currentTarget!.routeTargets!.keys);
    }
    if (_prevTarget?.routeTargets != null) {
      routes.addAll(_prevTarget!.routeTargets!.keys);
    }
    for (var s in _currentSales) {
      if (s.route != null) routes.add(s.route!);
    }
    for (var s in _prevSales) {
      if (s.route != null) routes.add(s.route!);
    }

    final sortedRoutes = routes.toList()..sort();

    final double totalCurrentTgt = (_currentTarget?.targetAmount ?? 0)
        .toDouble();
    final double totalCurrentSale = _currentSales.fold(
      0.0,
      (sum, s) => sum + s.totalAmount,
    );
    final double totalPrevSale = _prevSales.fold(
      0.0,
      (sum, s) => sum + s.totalAmount,
    );
    final double totalPrevTgt = (_prevTarget?.targetAmount ?? 0).toDouble();

    final currentAch = totalCurrentTgt > 0
        ? (totalCurrentSale / totalCurrentTgt * 100)
        : 0.0;
    final prevAch = totalPrevTgt > 0
        ? (totalPrevSale / totalPrevTgt * 100)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonSection(
            theme,
            currentAch,
            prevAch,
            totalCurrentSale,
            totalPrevSale,
          ),
          SizedBox(height: Responsive.isMobile(context) ? 12 : 24),
          _buildSummaryWrapGrid(
            theme,
            totalCurrentTgt,
            totalCurrentSale,
            totalPrevSale,
          ),
          const SizedBox(height: 24),
          Text(
            'Route Breakdown',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildScrollableTable(theme, sortedRoutes),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildScrollableTable(ThemeData theme, List<String> routes) {
    final prevMonth = DateFormat('MM-yyyy').format(
      DateTime(_selectedDate.year, _selectedDate.month - 1),
    );
    final currentMonth = DateFormat('MM-yyyy').format(_selectedDate);
    final metricsWidth = _monthSectionWidth * 2;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _routeColumnWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFrozenHeaderCell(theme),
                ...routes.map((route) => _buildFrozenRouteCell(theme, route)),
                _buildFrozenTotalCell(theme),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _tableScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: metricsWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildScrollableHeaderRow(theme, prevMonth, currentMonth),
                    ...routes.map((route) => _buildScrollableDataRow(theme, route)),
                    _buildScrollableTotalRow(theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrozenHeaderCell(ThemeData theme) {
    return _buildFrozenDragTarget(
      child: Container(
        height: _tableHeaderHeight,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        color: theme.colorScheme.primary,
        child: Text(
          'Round',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFrozenRouteCell(ThemeData theme, String route) {
    return _buildFrozenDragTarget(
      child: Container(
        height: _tableRowHeight,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Text(
          route,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFrozenTotalCell(ThemeData theme) {
    return _buildFrozenDragTarget(
      child: Container(
        height: _tableRowHeight,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.2),
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
          ),
        ),
        child: const Text(
          'Total Sale',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFrozenDragTarget({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        if (!_tableScrollController.hasClients) return;
        final currentOffset = _tableScrollController.offset;
        final maxOffset = _tableScrollController.position.maxScrollExtent;
        final nextOffset = (currentOffset - details.delta.dx).clamp(
          0.0,
          maxOffset,
        );
        _tableScrollController.jumpTo(nextOffset);
      },
      child: child,
    );
  }

  Widget _buildScrollableHeaderRow(
    ThemeData theme,
    String prevMonth,
    String currentMonth,
  ) {
    return SizedBox(
      height: _tableHeaderHeight,
      child: Container(
        color: theme.colorScheme.primary,
        child: Row(
          children: [
            _buildMonthHeader(theme, prevMonth),
            _buildMonthHeader(theme, currentMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(ThemeData theme, String month) {
    return Container(
      width: _monthSectionWidth,
      height: _tableHeaderHeight,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.colorScheme.onPrimary.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          Text(
            month,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Target',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sale',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Difference',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableDataRow(ThemeData theme, String route) {
    final prevTgt = (_prevTarget?.routeTargets?[route] as num? ?? 0).toDouble();
    final prevSold = _prevSales
        .where((s) => s.route == route)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
    final prevDiff = prevSold - prevTgt;

    final currentTgt = (_currentTarget?.routeTargets?[route] as num? ?? 0).toDouble();
    final currentSold = _currentSales
        .where((s) => s.route == route)
        .fold(0.0, (sum, s) => sum + s.totalAmount);
    final currentDiff = currentSold - currentTgt;

    return SizedBox(
      height: _tableRowHeight,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            _buildMonthData(theme, prevTgt, prevSold, prevDiff),
            _buildMonthData(theme, currentTgt, currentSold, currentDiff),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthData(ThemeData theme, double target, double sale, double diff) {
    final isPositive = diff >= 0;

    return Container(
      width: _monthSectionWidth,
      height: _tableRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '₹${NumberFormat('#,##,###').format(target.round())}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '₹${NumberFormat('#,##,###').format(sale.round())}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${isPositive ? '' : '-'}₹${NumberFormat('#,##,###').format(diff.abs().round())}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableTotalRow(ThemeData theme) {
    final totalPrevTgt = (_prevTarget?.targetAmount ?? 0).toDouble();
    final totalPrevSale = _prevSales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalPrevDiff = totalPrevSale - totalPrevTgt;

    final totalCurrentTgt = (_currentTarget?.targetAmount ?? 0).toDouble();
    final totalCurrentSale = _currentSales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalCurrentDiff = totalCurrentSale - totalCurrentTgt;

    return SizedBox(
      height: _tableRowHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.2),
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
          ),
        ),
        child: Row(
          children: [
            _buildMonthData(theme, totalPrevTgt, totalPrevSale, totalPrevDiff),
            _buildMonthData(theme, totalCurrentTgt, totalCurrentSale, totalCurrentDiff),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(
    ThemeData theme,
    double currentAch,
    double prevAch,
    double currentSale,
    double prevSale,
  ) {
    final onPrimary = theme.colorScheme.onPrimary;
    final isMobile = Responsive.isMobile(context);
    final progress = (currentAch / 100).clamp(0.0, 1.0).toDouble();

    if (isMobile) {
      final bool isUp = currentSale >= prevSale;
      final double diffPercent = prevSale > 0
          ? ((currentSale - prevSale) / prevSale * 100).abs()
          : 0;
      final progressPercent = (progress * 100).toStringAsFixed(0);
      final diffText = 'vs Prev ${prevAch.toStringAsFixed(1)}%';
      final barColor = progress >= 1.0
          ? AppColors.success
          : theme.colorScheme.primary;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.10),
              theme.colorScheme.secondary.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Overall Achievement',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '$progressPercent%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.65,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(color: barColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (isUp ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isUp ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${diffPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isUp ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  diffText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final bool isUp = currentSale >= prevSale;
    final double diffPercent = prevSale > 0
        ? ((currentSale - prevSale) / prevSale * 100).abs()
        : 0;
    const EdgeInsets cardPadding = EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    );
    const double metricLabelSize = 12;
    const double metricValueSize = 26;
    const double trendFontSize = 11;
    const double trendIconSize = 12;
    const double progressHeight = 6;
    const double sectionGap = 12;
    const double footerGap = 8;

    final achievementColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Achievement',
          style: TextStyle(
            color: onPrimary.withValues(alpha: 0.78),
            fontSize: metricLabelSize,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${currentAch.toStringAsFixed(1)}%',
          style: TextStyle(
            color: onPrimary,
            fontSize: metricValueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final trendBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            color: isUp ? AppColors.success : AppColors.error,
            size: trendIconSize,
          ),
          const SizedBox(width: 4),
          Text(
            '${diffPercent.toStringAsFixed(1)}%',
            style: TextStyle(
              color: isUp ? AppColors.success : AppColors.error,
              fontSize: trendFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [achievementColumn, trendBadge],
          ),
          const SizedBox(height: sectionGap),
          Stack(
            children: [
              Container(
                height: progressHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: progressHeight,
                  decoration: BoxDecoration(
                    color: onPrimary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: onPrimary.withValues(alpha: 0.4),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: footerGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'vs Prev: ${prevAch.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: onPrimary.withValues(alpha: 0.66),
                  fontSize: 11,
                ),
              ),
              Text(
                'Target: 100%',
                style: TextStyle(
                  color: onPrimary.withValues(alpha: 0.66),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryWrapGrid(
    ThemeData theme,
    double tgt,
    double sale,
    double prevSale,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactMetric('Total Target', tgt, AppColors.info),
          _buildDivider(theme),
          _buildCompactMetric('Current Sold', sale, AppColors.warning),
          _buildDivider(theme),
          _buildCompactMetric('Prev Sold', prevSale, Colors.grey),
          _buildDivider(theme),
          _buildCompactMetric('Remaining', max(0.0, tgt - sale), AppColors.info),
        ],
      ),
    );
  }

  Widget _buildCompactMetric(String label, double value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat.compact().format(value)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 30,
      color: theme.dividerColor,
    );
  }
}
