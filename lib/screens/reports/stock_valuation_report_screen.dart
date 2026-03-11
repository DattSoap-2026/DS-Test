import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import '../../utils/app_toast.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class StockValuationReportScreen extends StatefulWidget {
  const StockValuationReportScreen({super.key});

  @override
  State<StockValuationReportScreen> createState() =>
      _StockValuationReportScreenState();
}

class _StockValuationReportScreenState extends State<StockValuationReportScreen>
    with ReportPdfMixin<StockValuationReportScreen> {
  late final ReportsService _reportsService;
  bool _isLoading = true;
  StockValuationReport? _report;

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportsService.getStockValuationReport();
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading valuation: $e');
      }
    }
  }

  @override
  bool get hasExportData => _report != null && _report!.items.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Product Name',
      'Category',
      'Stock Qty',
      'Cost/Unit (₹)',
      'Total Value (₹)',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    if (_report == null) return [];
    return _report!.items.map((item) {
      return [
        item.productName,
        item.category,
        '${item.stock} ${item.unit}',
        item.costPerUnit.toStringAsFixed(2),
        item.totalValue.toStringAsFixed(2),
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Total Inventory Value': _report != null
          ? '₹${_report!.totalValue.toStringAsFixed(2)}'
          : '-',
      'Active Products': _report != null ? '${_report!.items.length}' : '-',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Valuation'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Stock Valuation Report'),
            onPrint: () => printReport('Stock Valuation Report'),
            onRefresh: _loadReport,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_report != null) _buildTotalCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _report?.items.isEmpty ?? true
                ? const Center(child: Text('No active products found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _report!.items.length,
                    itemBuilder: (context, index) {
                      final item = _report!.items[index];
                      return _buildStockItemRow(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4f46e5), Color(0xFF7c3aed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Inventory Value',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_report!.totalValue.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Across ${_report!.items.length} active products',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItemRow(StockValuationItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.stock} ${item.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '@ ₹${item.costPerUnit.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '₹${item.totalValue.toStringAsFixed(0)}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
