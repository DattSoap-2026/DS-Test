import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/reports_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../widgets/ui/unified_card.dart';
import '../../utils/app_toast.dart';
import '../../utils/responsive.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class SalesDispatchReportScreen extends StatefulWidget {
  const SalesDispatchReportScreen({super.key});

  @override
  State<SalesDispatchReportScreen> createState() =>
      _SalesDispatchReportScreenState();
}

class _SalesDispatchReportScreenState extends State<SalesDispatchReportScreen>
    with
        SingleTickerProviderStateMixin,
        ReportPdfMixin<SalesDispatchReportScreen> {
  late ReportsService _reportsService;
  late UsersService _usersService;
  late TabController _tabController;

  bool _isLoading = true;
  bool _loadingSalesmen = true;

  // Data
  SalesDispatchReport? _report;
  List<dynamic> _salesmen = [];

  // Filters
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  String _selectedSalesmanId = 'all';
  String _transactionType = 'all'; // all, customer, dealer, salesman

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _usersService = context.read<UsersService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadSalesmen();
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesmen() async {
    try {
      final s = await _usersService.getUsers(role: UserRole.salesman);
      if (mounted) {
        setState(() {
          _salesmen = s;
          _loadingSalesmen = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading salesmen: $e");
      if (mounted) setState(() => _loadingSalesmen = false);
    }
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      final results = await _reportsService.getSalesDispatchReport(
        FilterOptions(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
          salesmanId: _selectedSalesmanId == 'all' ? null : _selectedSalesmanId,
          dealerId: _transactionType == 'all' ? null : _transactionType,
        ),
      );

      if (mounted) {
        setState(() {
          _report = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading report: $e');
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await ResponsiveDatePickers.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadReport();
    }
  }

  @override
  bool get hasExportData => _report != null && _report!.sales.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    if (_tabController.index == 1) {
      // Products Tab
      return ['Product Name', 'Units Sold', 'Revenue (₹)'];
    } else if (_tabController.index == 2) {
      // Salesmen Tab
      return ['Salesman', 'Transactions', 'Revenue (₹)'];
    } else {
      // Overview Tab (Export raw transactions)
      return ['Date', 'Invoice', 'Customer', 'Type', 'Salesman', 'Amount (₹)'];
    }
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_report == null) return [];

    if (_tabController.index == 1) {
      // Products
      final productStats = <String, Map<String, dynamic>>{};
      for (var sale in _report!.sales) {
        final items = (sale['items'] as List?) ?? [];
        for (var item in items) {
          final pName = item['name'] as String? ?? 'Unknown';
          final qty = (item['quantity'] as num? ?? 0).toInt();
          final price = (item['price'] as num? ?? 0).toDouble();

          if (!productStats.containsKey(pName)) {
            productStats[pName] = {
              'name': pName,
              'quantity': 0,
              'revenue': 0.0,
            };
          }
          productStats[pName]!['quantity'] += qty;
          productStats[pName]!['revenue'] += (qty * price);
        }
      }

      final sortedList = productStats.values.toList()
        ..sort(
          (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
        );

      return sortedList
          .map(
            (item) => [
              item['name'],
              item['quantity'].toString(),
              (item['revenue'] as double).toStringAsFixed(2),
            ],
          )
          .toList();
    } else if (_tabController.index == 2) {
      // Salesmen
      final salesmanStats = <String, Map<String, dynamic>>{};
      for (var sale in _report!.sales) {
        final sName = sale['salesmanName'] as String? ?? 'Unknown';
        final amt = (sale['totalAmount'] as num? ?? 0).toDouble();

        if (!salesmanStats.containsKey(sName)) {
          salesmanStats[sName] = {'name': sName, 'revenue': 0.0, 'count': 0};
        }
        salesmanStats[sName]!['revenue'] += amt;
        salesmanStats[sName]!['count'] += 1;
      }

      final sortedList = salesmanStats.values.toList()
        ..sort(
          (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
        );

      return sortedList
          .map(
            (item) => [
              item['name'],
              item['count'].toString(),
              (item['revenue'] as double).toStringAsFixed(2),
            ],
          )
          .toList();
    } else {
      // Overview
      final sales = List<Map<String, dynamic>>.from(_report!.sales);
      // Sort by date descending
      sales.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      return sales.map((sale) {
        final dateParsed = DateTime.tryParse(sale['createdAt'] ?? '');
        final dateStr = dateParsed != null
            ? DateFormat('dd-MM-yyyy').format(dateParsed)
            : '-';
        return [
          dateStr,
          sale['humanReadableId'] ?? '-',
          sale['recipientName'] ?? '-',
          sale['gstType'] ?? '-',
          sale['salesmanName'] ?? '-',
          (sale['totalAmount'] as num? ?? 0).toStringAsFixed(2),
        ];
      }).toList();
    }
  }

  @override
  Map<String, String> buildFilterSummary() {
    String typeName = 'All Types';
    if (_transactionType == 'customer') typeName = 'Customer Sales';
    if (_transactionType == 'dealer') typeName = 'Dealer Dispatch';
    if (_transactionType == 'salesman') typeName = 'Salesman Dispatch';

    String salesmanName = 'All Salesmen';
    if (_selectedSalesmanId != 'all') {
      try {
        salesmanName = _salesmen
            .firstWhere((s) => s.id == _selectedSalesmanId)
            .name;
      } catch (_) {}
    }

    String reportType = 'Detailed Transactions';
    if (_tabController.index == 1) reportType = 'Products Summary';
    if (_tabController.index == 2) reportType = 'Salesmen Summary';

    return {
      'Report Type': reportType,
      'Date Range':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Transaction Type': typeName,
      'Salesman Filter': salesmanName,
      'Total Revenue': _report != null
          ? '₹${_report!.totalRevenue.toStringAsFixed(2)}'
          : '-',
      'Total Transactions': _report != null
          ? '${_report!.totalTransactions}'
          : '-',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Dispatch'),
        centerTitle: false,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Sales Dispatch Report'),
            onPrint: () => printReport('Sales Dispatch Report'),
          ),
        ],
        bottom: ThemedTabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.22),
          indicatorBorderColor: colorScheme.primary.withValues(alpha: 0.4),
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Products'),
            Tab(text: 'Salesmen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProductsTab(),
          _buildSalesmenTab(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return UnifiedCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              final dateRangeFilter = UnifiedCard(
                onTap: _selectDateRange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                backgroundColor:
                    theme.cardTheme.color ?? colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            "${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM').format(_dateRange.end)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final typeFilter = DropdownButtonFormField<String>(
                initialValue: _transactionType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Type',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor:
                      theme.cardTheme.color ?? colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Types')),
                  DropdownMenuItem(
                    value: 'customer',
                    child: Text('Customer Sales'),
                  ),
                  DropdownMenuItem(
                    value: 'dealer',
                    child: Text('Dealer Dispatch'),
                  ),
                  DropdownMenuItem(
                    value: 'salesman',
                    child: Text('Salesman Dispatch'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _transactionType = val);
                    _loadReport();
                  }
                },
              );

              if (isCompact) {
                return Column(
                  children: [
                    dateRangeFilter,
                    const SizedBox(height: 10),
                    typeFilter,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: dateRangeFilter),
                  const SizedBox(width: 12),
                  Expanded(child: typeFilter),
                ],
              );
            },
          ),
          ReportDateRangeButtons(
            value: _dateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onChanged: (range) {
              setState(() => _dateRange = range);
              _loadReport();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedSalesmanId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Salesman',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              filled: true,
              fillColor:
                  theme.cardTheme.color ?? colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All Salesmen')),
              ..._salesmen.map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: _loadingSalesmen
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _selectedSalesmanId = val);
                      _loadReport();
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_report == null) return const Center(child: Text("No report data"));
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilters(),
          _buildKPIGrid(),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Daily Trends",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: Responsive.clamp(
                context,
                min: 200,
                max: 260,
                ratio: 0.24,
              ),
              maxHeight: Responsive.clamp(
                context,
                min: 220,
                max: 320,
                ratio: 0.28,
              ),
            ),
            child: _buildTrendChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid() {
    final cards = [
      _buildStatCard(
        'Total Revenue',
        '\u20B9${_report!.totalRevenue.toStringAsFixed(0)}',
        Icons.currency_rupee,
        Theme.of(context).colorScheme.primary,
      ),
      _buildStatCard(
        'Transactions',
        '${_report!.totalTransactions}',
        Icons.receipt_long,
        Theme.of(context).colorScheme.tertiary,
      ),
      _buildStatCard(
        'Top Salesman',
        _report!.topSalesmanName,
        Icons.person,
        Theme.of(context).colorScheme.secondary,
        subtext: '\u20B9${_report!.topSalesmanRevenue.toStringAsFixed(0)}',
      ),
      _buildStatCard(
        'Top Product',
        _report!.topProductName,
        Icons.widgets,
        Theme.of(context).colorScheme.tertiary,
        subtext: '${_report!.topProductQuantity} units',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= Responsive.tabletBreakpoint
            ? 4
            : constraints.maxWidth >= Responsive.mobileBreakpoint
            ? 2
            : 1;
        const spacing = 8.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: itemWidth),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtext,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return UnifiedCard(
      onTap: null,
      backgroundColor: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtext != null) ...[
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final report = _report;
    if (report == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final axisLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    // Group by date
    final data = <DateTime, double>{};
    for (var sale in report.sales) {
      final dateStr = (sale['createdAt'] as String).split('T')[0];
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;
      final amt = (sale['totalAmount'] as num? ?? 0).toDouble();

      // Normalize date to day
      final day = DateTime(date.year, date.month, date.day);
      data[day] = (data[day] ?? 0) + amt;
    }

    final sortedKeys = data.keys.toList()..sort();
    if (sortedKeys.isEmpty) {
      return const Center(child: Text("No data for chart"));
    }

    final spots = sortedKeys.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), data[e.value]!);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
                  // Show only first, middle, last or limited labels to avoid crowding
                  if (value.toInt() %
                          (sortedKeys.length > 5
                              ? sortedKeys.length ~/ 5
                              : 1) ==
                      0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('dd/MM').format(sortedKeys[value.toInt()]),
                        style: axisLabelStyle,
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, {IconData icon = Icons.info_outline}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_report == null) return _buildEmptyState('No report data');
    if (_report!.sales.isEmpty) {
      return _buildEmptyState('No product sales found for selected filters');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final productStats = <String, Map<String, dynamic>>{};
    for (var sale in _report!.sales) {
      final items = (sale['items'] as List?) ?? [];
      for (var item in items) {
        final pName = item['name'] as String? ?? 'Unknown';
        final qty = (item['quantity'] as num? ?? 0).toInt();
        final price = (item['price'] as num? ?? 0).toDouble();

        if (!productStats.containsKey(pName)) {
          productStats[pName] = {'name': pName, 'quantity': 0, 'revenue': 0.0};
        }
        productStats[pName]!['quantity'] += qty;
        productStats[pName]!['revenue'] += (qty * price);
      }
    }

    final sortedList = productStats.values.toList()
      ..sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: theme.cardTheme.color,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item['quantity']} units sold',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Text(
                '₹${(item['revenue'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesmenTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_report == null) return _buildEmptyState('No report data');
    if (_report!.sales.isEmpty) {
      return _buildEmptyState('No salesman transactions found for selected filters');
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final salesmanStats = <String, Map<String, dynamic>>{};
    for (var sale in _report!.sales) {
      final sName = sale['salesmanName'] as String? ?? 'Unknown';
      final amt = (sale['totalAmount'] as num? ?? 0).toDouble();

      if (!salesmanStats.containsKey(sName)) {
        salesmanStats[sName] = {'name': sName, 'revenue': 0.0, 'count': 0};
      }
      salesmanStats[sName]!['revenue'] += amt;
      salesmanStats[sName]!['count'] += 1;
    }

    final sortedList = salesmanStats.values.toList()
      ..sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: theme.cardTheme.color,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  (item['name'] as String)[0],
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item['count']} transactions',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Text(
                '₹${(item['revenue'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
