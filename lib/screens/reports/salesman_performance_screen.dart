import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import 'package:intl/intl.dart';

import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class SalesmanPerformanceScreen extends StatefulWidget {
  final String? salesmanId;
  const SalesmanPerformanceScreen({super.key, this.salesmanId});

  @override
  State<SalesmanPerformanceScreen> createState() =>
      _SalesmanPerformanceScreenState();
}

class _SalesmanPerformanceScreenState extends State<SalesmanPerformanceScreen>
    with ReportPdfMixin<SalesmanPerformanceScreen> {
  late final ReportsService _reportsService;
  bool _isLoading = true;
  List<SalesmanPerformanceData> _performanceData = [];
  SalesmanOverallStats _overallStats = SalesmanOverallStats();

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  bool get hasExportData => _performanceData.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return const [
      'Salesman',
      'Sales',
      'Items Sold',
      'Revenue',
      'Target',
      'Achievement %',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _performanceData
        .map(
          (d) => [
            d.salesmanName,
            d.totalSales.toInt().toString(),
            d.totalItemsSold.toString(),
            d.totalRevenue.toStringAsFixed(2),
            d.totalTarget.toStringAsFixed(2),
            d.achievementPercentage.toStringAsFixed(2),
          ],
        )
        .toList(growable: false);
  }

  @override
  Map<String, String> buildFilterSummary() {
    final df = DateFormat('dd MMM yyyy');
    return {
      'Period': '${df.format(_dateRange.start)} to ${df.format(_dateRange.end)}',
      'Total Revenue': _overallStats.totalRevenue.toStringAsFixed(2),
      'Total Sales': _overallStats.totalSales.toInt().toString(),
    };
  }

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final filters = FilterOptions(
        salesmanId: widget.salesmanId,
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );
      final result = await _reportsService.getSalesmanPerformanceReport(
        filters,
      );
      if (mounted) {
        setState(() {
          _performanceData = _parsePerformanceData(result['performanceData']);
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
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _dateRange,
    );
    if (picked != null && picked != _dateRange) {
      setState(() => _dateRange = picked);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salesman Performance'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Salesman Performance Report'),
            onPrint: () => printReport('Salesman Performance Report'),
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildDateHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _performanceData.isEmpty
                ? const Center(child: Text('No data found for this period'))
                : ListView.builder(
                    itemCount: _performanceData.length,
                    itemBuilder: (context, index) {
                      final data = _performanceData[index];
                      return _buildPerformanceCard(data);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final df = DateFormat('MMM dd, yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Period: ${df.format(_dateRange.start)} - ${df.format(_dateRange.end)}',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
              ),
            ],
          ),
          ReportDateRangeButtons(
            value: _dateRange,
            firstDate: DateTime(2023),
            lastDate: DateTime.now().add(const Duration(days: 1)),
            onChanged: (range) {
              setState(() => _dateRange = range);
              _loadReport();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryCard(
            'Total Revenue',
            '₹${_overallStats.totalRevenue.toStringAsFixed(0)}',
            AppColors.info,
          ),
          const SizedBox(width: 8),
          _summaryCard(
            'Total Sales',
            '${_overallStats.totalSales.toInt()}',
            AppColors.success,
          ),
          const SizedBox(width: 8),
          _summaryCard(
            'Items Sold',
            '${_overallStats.totalItemsSold}',
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(SalesmanPerformanceData data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  child: Text(
                    data.salesmanName[0],
                    style: const TextStyle(color: AppColors.info),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.salesmanName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${data.totalSales.toInt()} Sales | ${data.totalItemsSold} Items',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${data.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniMetric(
                  'Target',
                  '₹${data.totalTarget.toStringAsFixed(0)}',
                ),
                _miniMetric(
                  'Achievement',
                  '${data.achievementPercentage.toStringAsFixed(1)}%',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (data.achievementPercentage / 100).clamp(0, 1),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  data.achievementPercentage >= 100
                      ? AppColors.success
                      : AppColors.info,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
