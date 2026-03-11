import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/platform/web_downloader.dart';
import '../../services/reports_service.dart';
import '../../utils/app_toast.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../utils/responsive.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../widgets/ui/unified_card.dart';

enum _SalesReportPeriodMode { custom, monthly, yearly }

enum _SalesDataExportOption {
  csvDetailed,
  csvSummary,
  excelDetailed,
  excelSummary,
}

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen>
    with ReportPdfMixin<SalesReportScreen> {
  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final ReportsService _reportsService;

  bool _isLoading = true;
  bool _isMetaLoading = true;
  SalesReportFilterMeta? _meta;
  SalesAdvancedReport? _report;

  _SalesReportPeriodMode _periodMode = _SalesReportPeriodMode.monthly;
  SalesReportGroupBy _groupBy = SalesReportGroupBy.monthly;
  bool _includeCancelled = false;

  DateTimeRange _customRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  int _selectedMonth = DateTime.now().month;
  int _selectedMonthYear = DateTime.now().year;
  int _selectedYear = DateTime.now().year;

  String _recipientType = 'all';
  String _division = 'all';
  String _district = 'all';
  String _route = 'all';
  String _salesmanId = 'all';
  String _dealerId = 'all';
  bool _isDataExporting = false;

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _loadInitialData();
  }

  @override
  bool get hasExportData => _report != null && _report!.records.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return const [
      'Date',
      'Invoice',
      'Recipient',
      'Type',
      'Salesman',
      'Route',
      'District',
      'Division',
      'Dealer',
      'Line Items',
      'Quantity',
      'Amount',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final rows = <List<dynamic>>[];
    final report = _report;
    if (report == null) return rows;

    for (final record in report.records) {
      rows.add([
        DateFormat('dd-MM-yyyy').format(record.createdAt),
        record.invoiceId,
        record.recipientName,
        record.recipientType,
        record.salesmanName,
        record.route,
        record.district,
        record.division,
        record.dealerName,
        record.lineItems.toString(),
        record.quantity.toString(),
        record.totalAmount.toStringAsFixed(2),
      ]);
    }
    return rows;
  }

  @override
  Map<String, String> buildFilterSummary() {
    final report = _report;
    return {
      'Period': _currentPeriodLabel(),
      'Group By': _groupByLabel(_groupBy),
      'Recipient Type': _recipientTypeLabel(_recipientType),
      'Division': _division == 'all' ? 'All Divisions' : _division,
      'District': _district == 'all' ? 'All Districts' : _district,
      'Route': _route == 'all' ? 'All Routes' : _route,
      'Salesman': _salesmanLabel(),
      'Dealer': _dealerLabel(),
      'Include Cancelled': _includeCancelled ? 'Yes' : 'No',
      'Total Revenue': report == null
          ? 'Rs 0.00'
          : 'Rs ${report.totalRevenue.toStringAsFixed(2)}',
      'Transactions': report == null ? '0' : '${report.totalTransactions}',
    };
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isMetaLoading = true;
    });
    try {
      final meta = await _reportsService.getSalesReportFilterMeta();
      if (!mounted) return;

      final years = meta.years.isNotEmpty
          ? meta.years
          : <int>[DateTime.now().year];
      setState(() {
        _meta = meta;
        if (!years.contains(_selectedMonthYear)) {
          _selectedMonthYear = years.first;
        }
        if (!years.contains(_selectedYear)) {
          _selectedYear = years.first;
        }
        _isMetaLoading = false;
      });
      await _loadReport();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isMetaLoading = false;
        _isLoading = false;
      });
      AppToast.showError(context, 'Unable to load report filters: $e');
    }
  }

  Future<void> _loadReport() async {
    if (_isMetaLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final report = await _reportsService.getSalesAdvancedReport(
        _buildQuery(),
      );
      if (!mounted) return;
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppToast.showError(context, 'Unable to generate sales report: $e');
    }
  }

  SalesReportQuery _buildQuery() {
    final range = _currentRange();
    return SalesReportQuery(
      startDate: range.start,
      endDate: range.end,
      recipientType: _recipientType == 'all' ? null : _recipientType,
      division: _division == 'all' ? null : _division,
      district: _district == 'all' ? null : _district,
      route: _route == 'all' ? null : _route,
      salesmanId: _salesmanId == 'all' ? null : _salesmanId,
      dealerId: _dealerId == 'all' ? null : _dealerId,
      groupBy: _groupBy,
      includeCancelled: _includeCancelled,
    );
  }

  DateTimeRange _currentRange() {
    switch (_periodMode) {
      case _SalesReportPeriodMode.custom:
        return _customRange;
      case _SalesReportPeriodMode.monthly:
        return DateTimeRange(
          start: DateTime(_selectedMonthYear, _selectedMonth, 1),
          end: DateTime(_selectedMonthYear, _selectedMonth + 1, 0),
        );
      case _SalesReportPeriodMode.yearly:
        return DateTimeRange(
          start: DateTime(_selectedYear, 1, 1),
          end: DateTime(_selectedYear, 12, 31),
        );
    }
  }

  List<int> _availableYears() {
    final years = _meta?.years ?? const <int>[];
    if (years.isNotEmpty) return years;
    return <int>[DateTime.now().year];
  }

  String _currentPeriodLabel() {
    final range = _currentRange();
    if (_periodMode == _SalesReportPeriodMode.monthly) {
      return '${_monthNames[_selectedMonth - 1]} $_selectedMonthYear';
    }
    if (_periodMode == _SalesReportPeriodMode.yearly) {
      return _selectedYear.toString();
    }
    return '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}';
  }

  String _groupByLabel(SalesReportGroupBy value) {
    switch (value) {
      case SalesReportGroupBy.daily:
        return 'Daily';
      case SalesReportGroupBy.monthly:
        return 'Monthly';
      case SalesReportGroupBy.yearly:
        return 'Yearly';
    }
  }

  String _recipientTypeLabel(String value) {
    switch (value) {
      case 'customer':
        return 'Customer';
      case 'dealer':
        return 'Dealer';
      case 'salesman':
        return 'Salesman';
      default:
        return 'All';
    }
  }

  String _salesmanLabel() {
    if (_salesmanId == 'all') return 'All Salesmen';
    final meta = _meta;
    if (meta == null) return _salesmanId;
    for (final option in meta.salesmen) {
      if (option.id == _salesmanId) return option.label;
    }
    return _salesmanId;
  }

  String _dealerLabel() {
    if (_dealerId == 'all') return 'All Dealers';
    final meta = _meta;
    if (meta == null) return _dealerId;
    for (final option in meta.dealers) {
      if (option.id == _dealerId) return option.label;
    }
    return _dealerId;
  }

  void _resetAdvancedFilters() {
    final currentMonth = DateTime.now().month;
    final years = _availableYears();
    setState(() {
      _recipientType = 'all';
      _division = 'all';
      _district = 'all';
      _route = 'all';
      _salesmanId = 'all';
      _dealerId = 'all';
      _includeCancelled = false;
      _groupBy = SalesReportGroupBy.monthly;
      _periodMode = _SalesReportPeriodMode.monthly;
      _selectedMonth = currentMonth;
      _selectedMonthYear = years.first;
      _selectedYear = years.first;
      _customRange = DateTimeRange(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime.now(),
      );
    });
  }

  List<List<dynamic>> _buildDetailedExportRows() {
    final report = _report;
    if (report == null || report.records.isEmpty) {
      return const <List<dynamic>>[];
    }

    final rows = <List<dynamic>>[
      [
        'Date',
        'Invoice',
        'Recipient Type',
        'Recipient Name',
        'Salesman',
        'Route',
        'District',
        'Division',
        'Dealer',
        'Status',
        'Line Items',
        'Quantity',
        'Amount',
      ],
    ];

    for (final record in report.records) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(record.createdAt),
        record.invoiceId,
        record.recipientType,
        record.recipientName,
        record.salesmanName,
        record.route,
        record.district,
        record.division,
        record.dealerName,
        record.status,
        record.lineItems,
        record.quantity,
        record.totalAmount,
      ]);
    }
    return rows;
  }

  List<List<dynamic>> _buildSummaryExportRows() {
    final report = _report;
    if (report == null) {
      return const <List<dynamic>>[];
    }

    final rows = <List<dynamic>>[];
    rows.add(['Sales Report Summary']);
    rows.add([
      'Generated At',
      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    ]);
    rows.add(['Period', _currentPeriodLabel()]);
    rows.add(['Group By', _groupByLabel(_groupBy)]);
    rows.add(['Recipient Type', _recipientTypeLabel(_recipientType)]);
    rows.add(['Division', _division == 'all' ? 'All Divisions' : _division]);
    rows.add(['District', _district == 'all' ? 'All Districts' : _district]);
    rows.add(['Route', _route == 'all' ? 'All Routes' : _route]);
    rows.add(['Salesman', _salesmanLabel()]);
    rows.add(['Dealer', _dealerLabel()]);
    rows.add(['Include Cancelled', _includeCancelled ? 'Yes' : 'No']);
    rows.add([]);

    rows.add(['KPI', 'Value']);
    rows.add(['Total Revenue', report.totalRevenue]);
    rows.add(['Total Transactions', report.totalTransactions]);
    rows.add(['Total Line Items', report.totalLineItems]);
    rows.add(['Total Quantity', report.totalQuantity]);
    rows.add(['Average Order Value', report.averageOrderValue]);

    void addSection(String title, List<SalesReportBucket> buckets) {
      rows.add([]);
      rows.add([title]);
      rows.add(['Label', 'Transactions', 'Quantity', 'Line Items', 'Revenue']);
      final visible = buckets.take(50).toList();
      for (final bucket in visible) {
        rows.add([
          bucket.label,
          bucket.transactions,
          bucket.quantity,
          bucket.lineItems,
          bucket.revenue,
        ]);
      }
      if (buckets.length > visible.length) {
        rows.add(['Showing top ${visible.length} of ${buckets.length} rows']);
      }
    }

    addSection('Trend', report.trend);
    addSection('Division Wise', report.byDivision);
    addSection('District Wise', report.byDistrict);
    addSection('Route Wise', report.byRoute);
    addSection('Salesman Wise', report.bySalesman);
    addSection('Dealer Wise', report.byDealer);

    return rows;
  }

  Future<void> _exportSalesData(_SalesDataExportOption option) async {
    final isCsv =
        option == _SalesDataExportOption.csvDetailed ||
        option == _SalesDataExportOption.csvSummary;
    final isSummary =
        option == _SalesDataExportOption.csvSummary ||
        option == _SalesDataExportOption.excelSummary;

    final rows = isSummary
        ? _buildSummaryExportRows()
        : _buildDetailedExportRows();
    if (rows.isEmpty) {
      AppToast.showInfo(context, 'No sales data available to export.');
      return;
    }

    if (_isDataExporting) return;
    setState(() {
      _isDataExporting = true;
    });

    try {
      final range = _currentRange();
      final stamp =
          '${DateFormat('yyyyMMdd').format(range.start)}_to_${DateFormat('yyyyMMdd').format(range.end)}';
      final modeSuffix = isSummary ? 'summary' : 'detailed';

      if (isCsv) {
        final fileName = 'sales_report_${modeSuffix}_$stamp.csv';
        await _exportRowsAsCsv(rows, fileName);
      } else {
        final fileName = 'sales_report_${modeSuffix}_$stamp.xlsx';
        await _exportRowsAsExcel(rows, fileName);
      }

      if (!mounted) return;
      AppToast.showSuccess(
        context,
        isCsv
            ? 'Sales ${isSummary ? 'summary' : 'detailed'} exported to CSV'
            : 'Sales ${isSummary ? 'summary' : 'detailed'} exported to Excel',
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, 'Export failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDataExporting = false;
        });
      }
    }
  }

  Future<void> _exportRowsAsCsv(
    List<List<dynamic>> rows,
    String fileName,
  ) async {
    final csvData = const ListToCsvConverter().convert(rows);
    if (kIsWeb) {
      downloadCsvWeb(csvData, fileName);
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(path)], text: 'Sales Report Export');
  }

  Future<void> _exportRowsAsExcel(
    List<List<dynamic>> rows,
    String fileName,
  ) async {
    if (kIsWeb) {
      throw StateError(
        'Excel export is currently available on mobile/desktop. Use CSV on web.',
      );
    }

    final excel = xls.Excel.createExcel();
    final sheet = excel['Sales Report'];

    for (final row in rows) {
      final cells = row.map<xls.CellValue>((value) {
        if (value is int) return xls.IntCellValue(value);
        if (value is double) return xls.DoubleCellValue(value);
        if (value is num) return xls.DoubleCellValue(value.toDouble());
        return xls.TextCellValue(value.toString());
      }).toList();
      sheet.appendRow(cells);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Unable to generate Excel bytes');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(path)], text: 'Sales Report Export');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Sales Report'),
            onPrint: () => printReport('Sales Report'),
            onRefresh: _loadReport,
          ),
          if (_isDataExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            PopupMenuButton<_SalesDataExportOption>(
              tooltip: 'Export Data',
              icon: const Icon(Icons.download_rounded),
              onSelected: _exportSalesData,
              itemBuilder: (context) => const [
                PopupMenuItem<_SalesDataExportOption>(
                  value: _SalesDataExportOption.csvDetailed,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.table_view_outlined),
                    title: Text('CSV Detailed'),
                  ),
                ),
                PopupMenuItem<_SalesDataExportOption>(
                  value: _SalesDataExportOption.csvSummary,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.summarize_outlined),
                    title: Text('CSV Summary'),
                  ),
                ),
                PopupMenuItem<_SalesDataExportOption>(
                  value: _SalesDataExportOption.excelDetailed,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.grid_on_rounded),
                    title: Text('Excel Detailed'),
                  ),
                ),
                PopupMenuItem<_SalesDataExportOption>(
                  value: _SalesDataExportOption.excelSummary,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.dataset_outlined),
                    title: Text('Excel Summary'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isMetaLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: ListView(
                padding: Responsive.screenPadding(context),
                children: [
                  _buildFiltersCard(),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const UnifiedCard(
                      useLayoutBuilder: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_report == null || _report!.records.isEmpty)
                    UnifiedCard(
                      useLayoutBuilder: false,
                      backgroundColor: colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Icon(
                              Icons.insights_outlined,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No sales found for selected filters',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try changing period or route/dealer filters and generate again.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _buildOverviewSection(_report!),
                    const SizedBox(height: 12),
                    _buildBucketSection(
                      title: 'Trend',
                      subtitle: '${_groupByLabel(_groupBy)} performance trend',
                      buckets: _report!.trend,
                    ),
                    const SizedBox(height: 12),
                    _buildBucketSection(
                      title: 'Division Wise',
                      subtitle: 'Revenue and quantity split by division',
                      buckets: _report!.byDivision,
                    ),
                    const SizedBox(height: 12),
                    _buildBucketSection(
                      title: 'District Wise',
                      subtitle: 'Revenue and quantity split by district',
                      buckets: _report!.byDistrict,
                    ),
                    const SizedBox(height: 12),
                    _buildBucketSection(
                      title: 'Route Wise',
                      subtitle: 'Revenue and quantity split by route',
                      buckets: _report!.byRoute,
                    ),
                    const SizedBox(height: 12),
                    _buildBucketSection(
                      title: 'Salesman Wise',
                      subtitle: 'Revenue and quantity split by salesman',
                      buckets: _report!.bySalesman,
                    ),
                    const SizedBox(height: 12),
                    _buildBucketSection(
                      title: 'Dealer Wise',
                      subtitle: 'Revenue and quantity split by dealer',
                      buckets: _report!.byDealer,
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionsSection(_report!),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildFiltersCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final meta = _meta;
    if (meta == null) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      useLayoutBuilder: false,
      padding: const EdgeInsets.all(16),
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _SalesReportPeriodMode.values.map((mode) {
              return ChoiceChip(
                label: Text(
                  mode == _SalesReportPeriodMode.custom
                      ? 'Custom'
                      : mode == _SalesReportPeriodMode.monthly
                      ? 'Monthly'
                      : 'Yearly',
                ),
                selected: _periodMode == mode,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _periodMode = mode;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildPeriodSelector(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1200
                  ? 3
                  : constraints.maxWidth >= 720
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;

              final fields = <Widget>[
                _buildDropdownField(
                  label: 'Group By',
                  value: _groupBy.name,
                  items: SalesReportGroupBy.values
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.name,
                          child: Text(_groupByLabel(option)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _groupBy = SalesReportGroupBy.values.firstWhere(
                        (option) => option.name == value,
                        orElse: () => SalesReportGroupBy.monthly,
                      );
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Recipient Type',
                  value: _recipientType,
                  items: const [
                    DropdownMenuItem<String>(value: 'all', child: Text('All')),
                    DropdownMenuItem<String>(
                      value: 'customer',
                      child: Text('Customer'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'dealer',
                      child: Text('Dealer'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'salesman',
                      child: Text('Salesman'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _recipientType = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Division',
                  value: _division,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Divisions'),
                    ),
                    ...meta.divisions.map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _division = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'District',
                  value: _district,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Districts'),
                    ),
                    ...meta.districts.map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _district = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Route',
                  value: _route,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Routes'),
                    ),
                    ...meta.routes.map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _route = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Salesman',
                  value: _salesmanId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Salesmen'),
                    ),
                    ...meta.salesmen.map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(
                          option.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _salesmanId = value;
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Dealer',
                  value: _dealerId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Dealers'),
                    ),
                    ...meta.dealers.map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(
                          option.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _dealerId = value;
                    });
                  },
                ),
              ];

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: fields
                    .map((field) => SizedBox(width: width, child: field))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: _includeCancelled,
                onChanged: (value) {
                  setState(() {
                    _includeCancelled = value;
                  });
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Include cancelled invoices',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _resetAdvancedFilters,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loadReport,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Generate Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final years = _availableYears();

    if (_periodMode == _SalesReportPeriodMode.custom) {
      final range = _currentRange();
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Range: ${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ReportDateRangeButtons(
              value: _customRange,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 1)),
              onChanged: (range) {
                setState(() {
                  _customRange = range;
                });
              },
            ),
          ],
        ),
      );
    }

    if (_periodMode == _SalesReportPeriodMode.monthly) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final yearField = _buildDropdownField(
            label: 'Year',
            value: _selectedMonthYear.toString(),
            items: years
                .map(
                  (year) => DropdownMenuItem<String>(
                    value: year.toString(),
                    child: Text('$year'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMonthYear = int.tryParse(value) ?? _selectedMonthYear;
              });
            },
          );

          final monthField = _buildDropdownField(
            label: 'Month',
            value: _selectedMonth.toString(),
            items: List<DropdownMenuItem<String>>.generate(
              12,
              (index) => DropdownMenuItem<String>(
                value: '${index + 1}',
                child: Text(_monthNames[index]),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedMonth = int.tryParse(value) ?? _selectedMonth;
              });
            },
          );

          if (isCompact) {
            return Column(
              children: [yearField, const SizedBox(height: 10), monthField],
            );
          }
          return Row(
            children: [
              Expanded(child: yearField),
              const SizedBox(width: 12),
              Expanded(child: monthField),
            ],
          );
        },
      );
    }

    return _buildDropdownField(
      label: 'Year',
      value: _selectedYear.toString(),
      items: years
          .map(
            (year) => DropdownMenuItem<String>(
              value: year.toString(),
              child: Text('$year'),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedYear = int.tryParse(value) ?? _selectedYear;
        });
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      items: items,
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }

  Widget _buildOverviewSection(SalesAdvancedReport report) {
    final cards = [
      _MetricCardData(
        title: 'Revenue',
        value: 'Rs ${report.totalRevenue.toStringAsFixed(2)}',
        icon: Icons.payments_outlined,
      ),
      _MetricCardData(
        title: 'Transactions',
        value: '${report.totalTransactions}',
        icon: Icons.receipt_long_outlined,
      ),
      _MetricCardData(
        title: 'Line Items',
        value: '${report.totalLineItems}',
        icon: Icons.list_alt_outlined,
      ),
      _MetricCardData(
        title: 'Quantity',
        value: '${report.totalQuantity}',
        icon: Icons.inventory_2_outlined,
      ),
      _MetricCardData(
        title: 'Avg Order',
        value: 'Rs ${report.averageOrderValue.toStringAsFixed(2)}',
        icon: Icons.insights_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 5
            : constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 460
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cards
              .map(
                (data) => SizedBox(
                  width: width,
                  child: UnifiedCard(
                    useLayoutBuilder: false,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          child: Icon(data.icon, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.value,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildBucketSection({
    required String title,
    required String subtitle,
    required List<SalesReportBucket> buckets,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visible = buckets.take(10).toList();

    return UnifiedCard(
      useLayoutBuilder: false,
      backgroundColor: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Text(
              'No data available for this split.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, _) => Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                height: 14,
              ),
              itemBuilder: (context, index) {
                final row = visible[index];
                return Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        row.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${row.transactions} tx',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${row.quantity} qty',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Rs ${row.revenue.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          if (buckets.length > visible.length) ...[
            const SizedBox(height: 8),
            Text(
              'Showing top ${visible.length} of ${buckets.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(SalesAdvancedReport report) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visible = report.records.take(120).toList();

    return UnifiedCard(
      useLayoutBuilder: false,
      backgroundColor: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transactions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${report.records.length} invoices in selected period',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visible.length,
            separatorBuilder: (_, _) => Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              height: 14,
            ),
            itemBuilder: (context, index) {
              final row = visible[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${row.invoiceId}  |  ${DateFormat('dd MMM yyyy').format(row.createdAt)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${row.recipientName} | ${row.route} | ${row.salesmanName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Division: ${row.division} | District: ${row.district} | Dealer: ${row.dealerName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${row.totalAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${row.quantity} qty',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          if (report.records.length > visible.length) ...[
            const SizedBox(height: 10),
            Text(
              'Showing first ${visible.length} rows in UI. Export PDF for full report.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
  });
}
