import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/reports_service.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/dashboard/kpi_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen>
    with SingleTickerProviderStateMixin, ReportPdfMixin<FinancialReportScreen> {
  late ReportsService _reportsService;
  late TabController _tabController;

  bool _isLoading = true;
  List<ProfitMarginData> _marginData = [];
  StockValuationReport? _stockReport;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final margins = await _reportsService.getProfitMarginReport(
        FilterOptions(startDate: _dateRange.start, endDate: _dateRange.end),
      );

      // Stock valuation is typically current state
      final stock = await _reportsService.getStockValuationReport();

      if (mounted) {
        setState(() {
          _marginData = margins;
          _stockReport = stock;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading reports: $e');
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
      _loadData();
    }
  }

  Map<String, dynamic> _calculateOverallMargins() {
    double revenue = 0;
    double cost = 0;
    double margin = 0;

    for (var m in _marginData) {
      revenue += m.totalRevenue;
      cost += m.totalCost;
      margin += m.grossMargin;
    }

    final percent = revenue > 0 ? (margin / revenue) * 100 : 0.0;

    return {
      'revenue': revenue,
      'cost': cost,
      'margin': margin,
      'percent': percent,
    };
  }

  @override
  bool get hasExportData => _tabController.index == 0
      ? _marginData.isNotEmpty
      : (_stockReport?.items.isNotEmpty ?? false);

  @override
  List<String> buildPdfHeaders() {
    if (_tabController.index == 0) {
      return ['Product Name', 'Revenue', 'Cost', 'Gross Margin', 'Margin %'];
    } else {
      return ['Product Name', 'Stock', 'Unit', 'Cost/Unit', 'Total Value'];
    }
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_tabController.index == 0) {
      return _marginData.map((item) {
        return [
          item.productName,
          item.totalRevenue.toStringAsFixed(2),
          item.totalCost.toStringAsFixed(2),
          item.grossMargin.toStringAsFixed(2),
          '${item.marginPercentage.toStringAsFixed(1)}%',
        ];
      }).toList();
    } else {
      if (_stockReport == null) return [];
      return _stockReport!.items.map((item) {
        return [
          item.productName,
          item.stock.toString(),
          item.unit,
          item.costPerUnit.toStringAsFixed(2),
          item.totalValue.toStringAsFixed(2),
        ];
      }).toList();
    }
  }

  @override
  Map<String, String> buildFilterSummary() {
    if (_tabController.index == 0) {
      return {
        'Report Type': 'Profit & Loss',
        'Date Range':
            '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      };
    } else {
      return {
        'Report Type': 'Stock Valuation',
        'Date': DateFormat('dd MMM yyyy HH:mm').format(DateTime.now()),
        'Total Inventory Value':
            '₹${_stockReport?.totalValue.toStringAsFixed(2) ?? '0.00'}',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: ThemedTabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                indicatorBorderColor: Colors.transparent,
                tabs: const [
                  Tab(height: 38, text: 'Profit & Loss'),
                  Tab(height: 38, text: 'Stock Valuation'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Financial Report'),
            onPrint: () => printReport('Financial Report'),
            onRefresh: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildProfitLossTab(), _buildStockValuationTab()],
            ),
    );
  }

  Widget _buildProfitLossTab() {
    final overall = _calculateOverallMargins();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section
          UnifiedCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('dd MMM').format(_dateRange.start)} - ${DateFormat('dd MMM').format(_dateRange.end)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _selectDateRange,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Change Range'),
                    ),
                  ],
                ),
                ReportDateRangeButtons(
                  value: _dateRange,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  onChanged: (range) {
                    setState(() => _dateRange = range);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KPI Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final crossAxisCount = constraints.maxWidth < 520
                  ? 1
                  : (isDesktop ? 4 : 2);
              final childAspectRatio = constraints.maxWidth < 520
                  ? 1.6
                  : (isDesktop ? 1.8 : 1.3);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  KPICard(
                    title: 'Total Revenue',
                    value: '₹${overall['revenue'].toStringAsFixed(0)}',
                    icon: Icons.currency_rupee,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  KPICard(
                    title: 'Total COGS',
                    value: '₹${overall['cost'].toStringAsFixed(0)}',
                    icon: Icons.shopping_bag_outlined,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  KPICard(
                    title: 'Gross Profit',
                    value: '₹${overall['margin'].toStringAsFixed(0)}',
                    icon: overall['margin'] >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: overall['margin'] >= 0
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                  ),
                  KPICard(
                    title: 'Margin %',
                    value: '${overall['percent'].toStringAsFixed(1)}%',
                    icon: Icons.pie_chart,
                    color: overall['percent'] >= 10
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Product-wise Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _marginData.length,
            itemBuilder: (context, index) {
              final item = _marginData[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UnifiedCard(
                  onTap: null,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (item.marginPercentage >= 20
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                            : item.marginPercentage >= 10
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.tertiary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.error)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.marginPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: item.marginPercentage >= 20
                                      ? Theme.of(context).colorScheme.secondary
                                      : (item.marginPercentage >= 10
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.tertiary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailColumn('Revenue', item.totalRevenue),
                            _buildDetailColumn('Cost', item.totalCost),
                            _buildDetailColumn(
                              'Profit',
                              item.grossMargin,
                              color: item.grossMargin >= 0
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStockValuationTab() {
    if (_stockReport == null) return const Center(child: Text('No Data'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Total Inventory Value',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${_stockReport!.totalValue.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  UnifiedCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    child: const Text(
                      'Current Stock * Average Cost',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Current Stock Valuation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stockReport!.items.length,
            itemBuilder: (context, index) {
              final item = _stockReport!.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UnifiedCard(
                  onTap: null,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.stock} ${item.unit} @ ₹${item.costPerUnit.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.totalValue.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, double value, {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
        ),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
