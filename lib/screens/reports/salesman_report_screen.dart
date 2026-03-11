import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/reports_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../widgets/ui/unified_card.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class SalesmanReportScreen extends StatefulWidget {
  const SalesmanReportScreen({super.key});

  @override
  State<SalesmanReportScreen> createState() => _SalesmanReportScreenState();
}

class _SalesmanReportScreenState extends State<SalesmanReportScreen>
    with ReportPdfMixin<SalesmanReportScreen> {
  late ReportsService _reportsService;
  late UsersService _usersService;

  bool _isLoading = true;
  bool _loadingSalesmen = true;

  // Data
  List<SalesmanPerformanceData> _reportData = [];
  SalesmanOverallStats _overallStats = SalesmanOverallStats();
  List<Map<String, dynamic>> _salesmen = [];

  // Filters
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  String _selectedSalesmanId = 'all';

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _usersService = context.read<UsersService>();
    _loadSalesmen();
    _loadReport();
  }

  Future<void> _loadSalesmen() async {
    setState(() => _loadingSalesmen = true);
    try {
      final users = await _usersService.getUsers(role: UserRole.salesman);
      if (mounted) {
        setState(() {
          _salesmen = users.map((u) => {'id': u.id, 'name': u.name}).toList();
          _salesmen.sort((a, b) => (a['name'] as String).compareTo(b['name']));
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
      final filters = FilterOptions(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        salesmanId: _selectedSalesmanId == 'all' ? null : _selectedSalesmanId,
      );

      final result = await _reportsService.getSalesmanPerformanceReport(
        filters,
      );

      if (mounted) {
        setState(() {
          _reportData = _parsePerformanceData(result['performanceData']);
          _overallStats = _parseOverallStats(result['overallStats']);
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

  List<SalesmanPerformanceData> _parsePerformanceData(dynamic raw) {
    if (raw is List<SalesmanPerformanceData>) {
      return raw;
    }
    if (raw is List) {
      return raw
          .map<SalesmanPerformanceData?>((item) {
            if (item is SalesmanPerformanceData) {
              return item;
            }
            if (item is Map<String, dynamic>) {
              return SalesmanPerformanceData.fromJson(item);
            }
            if (item is Map) {
              return SalesmanPerformanceData.fromJson(
                Map<String, dynamic>.from(item),
              );
            }
            return null;
          })
          .whereType<SalesmanPerformanceData>()
          .toList(growable: false);
    }
    return const <SalesmanPerformanceData>[];
  }

  SalesmanOverallStats _parseOverallStats(dynamic raw) {
    if (raw is SalesmanOverallStats) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      return SalesmanOverallStats.fromJson(raw);
    }
    if (raw is Map) {
      return SalesmanOverallStats.fromJson(Map<String, dynamic>.from(raw));
    }
    return SalesmanOverallStats();
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
  bool get hasExportData => _reportData.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Salesman',
      'Transactions',
      'Target (₹)',
      'Revenue (₹)',
      'Achievement %',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _reportData.map((d) {
      return [
        d.salesmanName,
        d.totalSales.toInt().toString(),
        d.totalTarget.toStringAsFixed(2),
        d.totalRevenue.toStringAsFixed(2),
        '${d.achievementPercentage.toStringAsFixed(1)}%',
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    String salesmanName = 'All Salesmen';
    if (_selectedSalesmanId != 'all') {
      try {
        salesmanName = _salesmen.firstWhere(
          (s) => s['id'] == _selectedSalesmanId,
        )['name'];
      } catch (_) {}
    }

    return {
      'Date Range':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Salesman Filter': salesmanName,
      'Total Revenue': '₹${_overallStats.totalRevenue.toStringAsFixed(2)}',
      'Total Sales': _overallStats.totalSales.toStringAsFixed(0),
      'Active Salesmen': _overallStats.activeSalesmen.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salesman Performance'),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Salesman Performance Report'),
            onPrint: () => printReport('Salesman Performance Report'),
            onRefresh: _loadReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            const Text(
              "Performance Metrics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildReportList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return UnifiedCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                backgroundColor: Theme.of(context).cardTheme.color,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
              );

              final salesmanFilter = DropdownButtonFormField<String>(
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
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'all',
                    child: Text('All Salesmen'),
                  ),
                  ..._salesmen.map(
                    (s) => DropdownMenuItem(
                      value: s['id'] as String,
                      child: Text(s['name'], overflow: TextOverflow.ellipsis),
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
              );

              if (isCompact) {
                return Column(
                  children: [
                    dateRangeFilter,
                    const SizedBox(height: 10),
                    salesmanFilter,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: dateRangeFilter),
                  const SizedBox(width: 12),
                  Expanded(child: salesmanFilter),
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
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Revenue',
                '₹${_overallStats.totalRevenue.toStringAsFixed(0)}',
                Icons.currency_rupee,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Total Sales',
                _overallStats.totalSales.toStringAsFixed(0),
                Icons.bar_chart,
                AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Items Sold',
                _overallStats.totalItemsSold.toString(),
                Icons.inventory_2,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Active Salesmen',
                _overallStats.activeSalesmen.toString(),
                Icons.people,
                AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return UnifiedCard(
      onTap: null,
      backgroundColor: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reportData.isEmpty) {
      return const Center(
        child: Text("No performance data found for selected period"),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reportData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = _reportData[index];
        final achievement = d.achievementPercentage;
        Color progressColor = achievement >= 100
            ? AppColors.success
            : (achievement > 50 ? AppColors.warning : AppColors.error);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UnifiedCard(
            onTap: null,
            backgroundColor: Theme.of(context).cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          d.salesmanName.isNotEmpty
                              ? d.salesmanName[0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.salesmanName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Target: ₹${d.totalTarget.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${d.totalRevenue.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            '${d.totalSales} Sales',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "Achievement",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${achievement.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (achievement / 100).clamp(0.0, 1.0),
                    backgroundColor: progressColor.withValues(alpha: 0.1),
                    color: progressColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
