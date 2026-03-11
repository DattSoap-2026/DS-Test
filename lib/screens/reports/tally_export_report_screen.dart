import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';
import '../../services/tally_export_service.dart';
import '../../utils/app_toast.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../widgets/dialogs/responsive_date_pickers.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_card.dart';

class TallyExportReportScreen extends StatefulWidget {
  const TallyExportReportScreen({super.key});

  @override
  State<TallyExportReportScreen> createState() =>
      _TallyExportReportScreenState();
}

class _TallyExportReportScreenState extends State<TallyExportReportScreen>
    with ReportPdfMixin<TallyExportReportScreen> {
  late final TallyExportService _tallyService;
  late final SettingsService _settingsService;

  DateTime? _startDate;
  DateTime? _endDate;
  final String _voucherType = 'sales';
  bool _includeExported = false;
  bool _isExporting = false;
  bool _isPreviewLoading = false;
  Map<String, dynamic>? _preview;

  @override
  bool get hasExportData {
    final preview = _preview;
    if (preview == null) return false;
    final count = preview['count'];
    if (count is int) return count > 0;
    if (count is num) return count.toInt() > 0;
    return false;
  }

  @override
  List<String> buildPdfHeaders() {
    return const ['Voucher Type', 'From', 'To', 'Invoices', 'Total'];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    final range = _effectiveDateRange;
    final countValue = _preview?['count'];
    final totalValue = _preview?['total'];
    final count = (countValue is num) ? countValue.toInt() : 0;
    final total = (totalValue is num) ? totalValue.toDouble() : 0.0;
    return <List<dynamic>>[
      <dynamic>[
        _voucherType,
        DateFormat('dd MMM yyyy').format(range.start),
        DateFormat('dd MMM yyyy').format(range.end),
        count.toString(),
        total.toStringAsFixed(2),
      ],
    ];
  }

  @override
  Map<String, String> buildFilterSummary() {
    final range = _effectiveDateRange;
    return {
      'Period':
          '${DateFormat('dd MMM yyyy').format(range.start)} to ${DateFormat('dd MMM yyyy').format(range.end)}',
      'Voucher Type': _voucherType,
      'Include Exported': _includeExported ? 'Yes' : 'No',
    };
  }

  DateTimeRange get _effectiveDateRange {
    final now = DateTime.now();
    final start = _startDate ?? DateTime(now.year, now.month, 1);
    final end = _endDate ?? now;
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    if (normalizedEnd.isBefore(normalizedStart)) {
      return DateTimeRange(start: normalizedStart, end: normalizedStart);
    }
    return DateTimeRange(start: normalizedStart, end: normalizedEnd);
  }

  @override
  void initState() {
    super.initState();
    _tallyService = context.read<TallyExportService>();
    _settingsService = context.read<SettingsService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export to Tally'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Tally Export Preview Report'),
            onPrint: () => printReport('Tally Export Preview Report'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildExportForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to import in Tally:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('1. Open Tally Prime or Tally ERP 9'),
                Text('2. Gateway of Tally -> Import Data -> Vouchers'),
                Text('3. Select the downloaded XML file'),
                Text('4. Review and accept the import'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportForm() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Export Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'Start Date',
                    value: _startDate,
                    onChanged: (date) {
                      setState(() {
                        _startDate = date;
                        if (date != null &&
                            _endDate != null &&
                            _endDate!.isBefore(date)) {
                          _endDate = date;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePicker(
                    label: 'End Date',
                    value: _endDate,
                    onChanged: (date) {
                      setState(() {
                        _endDate = date;
                        if (date != null &&
                            _startDate != null &&
                            date.isBefore(_startDate!)) {
                          _startDate = date;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ReportDateRangeButtons(
              margin: EdgeInsets.zero,
              value: _effectiveDateRange,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              onChanged: (range) {
                setState(() {
                  _startDate = DateTime(
                    range.start.year,
                    range.start.month,
                    range.start.day,
                  );
                  _endDate = DateTime(
                    range.end.year,
                    range.end.month,
                    range.end.day,
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _voucherType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Voucher Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sales', child: Text('Sales Invoices')),
              ],
              onChanged: null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _includeExported,
              onChanged: (val) =>
                  setState(() => _includeExported = val ?? false),
              title: const Text('Include already exported invoices'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            if (_preview != null) ...[
              _buildPreviewCard(),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Preview',
                    variant: ButtonVariant.outline,
                    onPressed: _handlePreview,
                    isLoading: _isPreviewLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: 'Export XML',
                    variant: ButtonVariant.filled,
                    onPressed: _handleExport,
                    isLoading: _isExporting,
                    icon: Icons.download,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await ResponsiveDatePickers.pickDate(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value)
              : 'Select Date',
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final count = ((_preview?['count'] as num?) ?? 0).toInt();
    final total = ((_preview?['total'] as num?) ?? 0).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiaryContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Preview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoices: $count'),
              Text('Total: Rs ${total.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePreview() async {
    if (_startDate == null || _endDate == null) {
      AppToast.showError(context, 'Please select date range');
      return;
    }

    setState(() => _isPreviewLoading = true);
    try {
      final result = await _tallyService.getExportPreview(
        _startDate!,
        _endDate!,
        voucherType: _voucherType,
        includeExported: _includeExported,
      );
      if (mounted) {
        setState(() => _preview = result);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Preview failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isPreviewLoading = false);
      }
    }
  }

  Future<void> _handleExport() async {
    if (_startDate == null || _endDate == null) return;

    setState(() => _isExporting = true);
    try {
      final companyName = await _resolveCompanyName();
      final payload = await _tallyService
          .generateTallyExportPayloadForDateRange(
            _startDate!,
            _endDate!,
            voucherType: _voucherType,
            companyName: companyName,
            includeExported: _includeExported,
          );
      if (payload.count == 0 || payload.xmlContent.isEmpty) {
        if (mounted) {
          AppToast.showInfo(context, 'No data found for export');
        }
        return;
      }

      final fileName =
          'Tally_Export_${DateFormat('yyyyMMdd').format(_startDate!)}_${DateFormat('yyyyMMdd').format(_endDate!)}.xml';
      var saved = false;
      var savedPath = '';

      if (Platform.isWindows) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Tally XML',
          fileName: fileName,
          allowedExtensions: ['xml'],
          type: FileType.custom,
        );
        if (outputFile != null) {
          await File(outputFile).writeAsString(payload.xmlContent);
          saved = true;
          savedPath = outputFile;
        } else {
          if (mounted) {
            AppToast.showInfo(context, 'Export cancelled');
          }
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(payload.xmlContent);
        saved = true;
        savedPath = file.path;
      }

      if (saved) {
        await _tallyService.markSalesAsExported(payload.exportedSaleKeys);
        if (mounted) {
          AppToast.showSuccess(
            context,
            'Saved $fileName (${payload.count} vouchers) to $savedPath',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Export failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<String> _resolveCompanyName() async {
    try {
      final profile = await _settingsService.getCompanyProfileClient();
      final name = profile?.name?.trim() ?? '';
      if (name.isNotEmpty) {
        return name;
      }
    } catch (_) {
      // Keep export stable with fallback in offline/error scenarios.
    }
    return 'Datt Soap';
  }
}
