import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Actually I don't see share_plus in pubspec. I will just save to file.
import '../../models/types/sales_types.dart';
import '../../services/sales_service.dart';
import '../../widgets/ui/unified_card.dart';
import 'package:provider/provider.dart';
import '../../utils/app_toast.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';

class GstReportScreen extends StatefulWidget {
  const GstReportScreen({super.key});

  @override
  State<GstReportScreen> createState() => _GstReportScreenState();
}

class _GstReportScreenState extends State<GstReportScreen>
    with ReportPdfMixin<GstReportScreen> {
  late SalesService _salesService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _salesService = context.read<SalesService>();
  }

  bool _isLoading = true;
  List<Sale> _sales = [];
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
    _loadSales();
  }

  Future<void> _loadSales() async {
    if (_dateRange == null) return;

    setState(() => _isLoading = true);

    try {
      final filtered = await _salesService.getSalesClient(
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
      );

      if (mounted) {
        setState(() {
          _sales = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading sales: $e');
      }
    }
  }

  Future<void> _selectDateRange() async {
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now().add(const Duration(days: 365));
    final currentStart = _dateRange?.start ?? DateTime.now();
    final currentEnd = _dateRange?.end ?? currentStart;

    final initialStart = currentStart.isBefore(firstDate)
        ? firstDate
        : currentStart.isAfter(lastDate)
        ? lastDate
        : currentStart;

    final initialEnd = currentEnd.isBefore(initialStart)
        ? initialStart
        : currentEnd;

    final picked = await ResponsiveDatePickers.pickDateRange(
      firstDate: firstDate,
      lastDate: lastDate,
      context: context,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd.isAfter(lastDate) ? lastDate : initialEnd,
      ),
      helpText: 'Select Date Range',
      confirmText: 'Apply',
    );
    if (picked == null) return;

    final normalizedStart = DateTime(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    final normalizedEnd = DateTime(
      picked.end.year,
      picked.end.month,
      picked.end.day,
      23,
      59,
      59,
    );

    if (!mounted) return;
    setState(() {
      _dateRange = DateTimeRange(start: normalizedStart, end: normalizedEnd);
    });
    _loadSales();
  }

  Map<String, double> _calculateTotals() {
    double totalTax = 0;
    double totalCgst = 0;
    double totalSgst = 0;
    double totalIgst = 0;

    for (final sale in _sales) {
      totalCgst += sale.cgstAmount ?? 0;
      totalSgst += sale.sgstAmount ?? 0;
      totalIgst += sale.igstAmount ?? 0;
      totalTax +=
          (sale.cgstAmount ?? 0) +
          (sale.sgstAmount ?? 0) +
          (sale.igstAmount ?? 0);
    }

    return {
      'totalTax': totalTax,
      'totalCgst': totalCgst,
      'totalSgst': totalSgst,
      'totalIgst': totalIgst,
    };
  }

  @override
  bool get hasExportData => _sales.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Invoice No',
      'Date',
      'Customer',
      'Type',
      'Taxable',
      'CGST',
      'SGST',
      'IGST',
      'Total Tax',
      'Total Amt',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _sales.map((sale) {
      final totalTax =
          (sale.cgstAmount ?? 0) +
          (sale.sgstAmount ?? 0) +
          (sale.igstAmount ?? 0);
      final totalAmount = sale.taxableAmount + totalTax;

      return [
        sale.humanReadableId ?? '-',
        _formatDateSafe(sale.createdAt, pattern: 'dd-MM-yyyy'),
        sale.recipientName,
        sale.gstType,
        sale.taxableAmount.toStringAsFixed(2),
        (sale.cgstAmount ?? 0).toStringAsFixed(2),
        (sale.sgstAmount ?? 0).toStringAsFixed(2),
        (sale.igstAmount ?? 0).toStringAsFixed(2),
        totalTax.toStringAsFixed(2),
        totalAmount.toStringAsFixed(2),
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Date Range': _dateRange == null
          ? 'All Time'
          : '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Report'),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('GST Report'),
            onPrint: () => printReport('GST Report'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            UnifiedCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  _dateRange == null
                      ? 'Select Date Range'
                      : '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectDateRange,
              ),
            ),
            ReportDateRangeButtons(
              value:
                  _dateRange ??
                  DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now(),
                  ),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onChanged: (range) {
                final normalizedStart = DateTime(
                  range.start.year,
                  range.start.month,
                  range.start.day,
                );
                final normalizedEnd = DateTime(
                  range.end.year,
                  range.end.month,
                  range.end.day,
                  23,
                  59,
                  59,
                );
                setState(() {
                  _dateRange = DateTimeRange(
                    start: normalizedStart,
                    end: normalizedEnd,
                  );
                });
                _loadSales();
              },
            ),
            const SizedBox(height: 16),

            // Tax Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.sizeOf(context).width < 520 ? 1 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: MediaQuery.sizeOf(context).width < 520
                  ? 1.7
                  : 1.25,
              children: [
                _buildTaxCard(
                  'Total Tax',
                  totals['totalTax']!,
                  _sales.length,
                  Theme.of(context).colorScheme.primary,
                ),
                _buildTaxCard(
                  'CGST',
                  totals['totalCgst']!,
                  null,
                  Theme.of(context).colorScheme.secondary,
                ),
                _buildTaxCard(
                  'SGST',
                  totals['totalSgst']!,
                  null,
                  Theme.of(context).colorScheme.tertiary,
                ),
                _buildTaxCard(
                  'IGST',
                  totals['totalIgst']!,
                  null,
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sales Table
            UnifiedCard(
              padding: EdgeInsets.zero,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Detailed Tax Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_sales.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No sales found for selected period',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sales.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final sale = _sales[index];
                          return UnifiedCard(
                            onTap: null,
                            backgroundColor: Theme.of(context).cardTheme.color,
                            child: _buildSaleRow(sale),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxCard(String title, double amount, int? count, Color color) {
    return UnifiedCard(
      onTap: null,
      backgroundColor: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                Icon(Icons.currency_rupee, size: 16, color: color),
              ],
            ),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (count != null)
              Text(
                'Across $count invoice${count == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleRow(Sale sale) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalTax =
        (sale.cgstAmount ?? 0) +
        (sale.sgstAmount ?? 0) +
        (sale.igstAmount ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.humanReadableId ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sale.recipientName,
                      style: TextStyle(
                        fontSize: 12,
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
                    _formatDateSafe(sale.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sale.gstType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildTaxRow('Taxable Amount', sale.taxableAmount),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _buildTaxRow(
                        'CGST',
                        sale.cgstAmount ?? 0,
                        small: true,
                      ),
                    ),
                    Expanded(
                      child: _buildTaxRow(
                        'SGST',
                        sale.sgstAmount ?? 0,
                        small: true,
                      ),
                    ),
                    Expanded(
                      child: _buildTaxRow(
                        'IGST',
                        sale.igstAmount ?? 0,
                        small: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildTaxRow('Total Tax', totalTax, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }

  Widget _buildTaxRow(
    String label,
    double amount, {
    bool bold = false,
    bool small = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: small ? 10 : 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: small ? Theme.of(context).textTheme.bodySmall?.color : null,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: small ? 10 : 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
