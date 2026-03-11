import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';
import '../app_toast.dart';
import '../pdf_generator.dart';

/// Mixin to handle PDF export and printing logic for report screens
mixin ReportPdfMixin<T extends StatefulWidget> on State<T> {
  bool isExporting = false;

  /// Build the headers for the PDF table
  List<String> buildPdfHeaders();

  /// Build the rows for the PDF table
  List<List<dynamic>> buildPdfRows();

  /// Build the filter summary to display at the top of the PDF
  Map<String, String>? buildFilterSummary() => null;

  /// Check if there is data to export safely. By default returns true.
  /// Override this to check if local report data is null or empty before allowing export.
  bool get hasExportData => true;

  Future<void> _runSafeExportAction(
    String reportTitle,
    Future<void> Function(
      String title,
      List<String> headers,
      List<List<dynamic>> rows,
      CompanyProfileData company,
      Map<String, String>? filterSummary,
    )
    action,
  ) async {
    if (!hasExportData) {
      if (mounted) {
        AppToast.showInfo(context, 'No data available to export/print.');
      }
      return;
    }

    setState(() => isExporting = true);
    try {
      final settingsService = context.read<SettingsService>();
      final company = await settingsService.getCompanyProfileClient();

      final headers = buildPdfHeaders();
      final rows = buildPdfRows();
      final filters = buildFilterSummary();

      await action(
        reportTitle,
        headers,
        rows,
        company ?? CompanyProfileData(),
        filters,
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, 'Failed to process report: $e');
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  /// Print the report
  Future<void> printReport(String reportTitle) async {
    await _runSafeExportAction(
      reportTitle,
      (title, headers, rows, company, filters) =>
          PdfGenerator.generateAndPrintGenericReport(
            title,
            headers,
            rows,
            company,
            subtitle: _buildSubtitle(filters),
            filterSummary: filters,
          ),
    );
  }

  /// Export the report as PDF
  Future<void> exportReport(String reportTitle) async {
    await _runSafeExportAction(
      reportTitle,
      (title, headers, rows, company, filters) =>
          PdfGenerator.shareGenericReport(
            title,
            headers,
            rows,
            company,
            subtitle: _buildSubtitle(filters),
            filterSummary: filters,
            filename: buildPdfFilename(reportTitle),
          ),
    );
  }

  String _buildSubtitle(Map<String, String>? filters) {
    if (filters == null || filters.isEmpty) {
      return 'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}';
    }

    // Convert filters into a readable subtitle string for compact use in older methods
    final filterParts = filters.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(' | ');
    return filterParts;
  }

  /// Build standard filename
  String buildPdfFilename(String reportTitle) {
    final sanitizedTitle = reportTitle.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9]+'),
      '_',
    );
    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    return '${sanitizedTitle}_$dateStr.pdf';
  }
}
