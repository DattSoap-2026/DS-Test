import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/types/return_types.dart';
import '../models/types/sales_types.dart';
import '../services/payments_service.dart';
import '../services/settings_service.dart';
import 'pdf_theme.dart';

class PdfGenerator {
  static Future<void> generateAndPrintSaleInvoice(
    Sale sale,
    CompanyProfileData company,
  ) async {
    final pdf = await _createSaleInvoice(sale, company);
    final bytes = await _savePdfInIsolate(pdf);
    final fileName = _toSafePdfFileName(
      'Invoice_${sale.humanReadableId ?? sale.id}',
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: fileName,
    );
  }

  static Future<void> shareSaleInvoice(
    Sale sale,
    CompanyProfileData company,
  ) async {
    final pdf = await _createSaleInvoice(sale, company);
    final bytes = await _savePdfInIsolate(pdf);
    await _sharePdfBytes(
      bytes: bytes,
      filename: 'Invoice_${sale.humanReadableId ?? sale.id}.pdf',
    );
  }

  static Future<Uint8List> generateSaleInvoicePdfBytes(
    Sale sale,
    CompanyProfileData company,
  ) async {
    final pdf = await _createSaleInvoice(sale, company);
    return _savePdfInIsolate(pdf);
  }

  static Future<void> generateAndPrintPaymentReceipt(
    ManualPayment payment,
    CompanyProfileData company,
  ) async {
    final pdf = await _createPaymentReceipt(payment, company);
    final bytes = await _savePdfInIsolate(pdf);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static Future<void> sharePaymentReceipt(
    ManualPayment payment,
    CompanyProfileData company,
  ) async {
    final pdf = await _createPaymentReceipt(payment, company);
    final bytes = await _savePdfInIsolate(pdf);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Receipt_${payment.id}.pdf',
    );
  }

  static Future<void> generateAndPrintGenericReport(
    String title,
    List<String> headers,
    List<List<dynamic>> rows,
    CompanyProfileData company, {
    String? subtitle,
    Map<String, String>? filterSummary,
  }) async {
    final pdf = await _createGenericReport(
      title,
      headers,
      rows,
      company,
      subtitle: subtitle,
      filterSummary: filterSummary,
    );
    final bytes = await _savePdfInIsolate(pdf);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static Future<void> shareGenericReport(
    String title,
    List<String> headers,
    List<List<dynamic>> rows,
    CompanyProfileData company, {
    String? subtitle,
    String? filename,
    Map<String, String>? filterSummary,
  }) async {
    final pdf = await _createGenericReport(
      title,
      headers,
      rows,
      company,
      subtitle: subtitle,
      filterSummary: filterSummary,
    );
    final bytes = await _savePdfInIsolate(pdf);
    await Printing.sharePdf(
      bytes: bytes,
      filename: filename ?? '${_toSafeFileName(title)}.pdf',
    );
  }

  static Future<void> generateAndPrintPageSnapshot(
    Uint8List pngBytes, {
    String? title,
  }) async {
    final pdf = pw.Document();
    final snapshotImage = pw.MemoryImage(pngBytes);
    final reportTitle = title?.trim();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (reportTitle != null && reportTitle.isNotEmpty) ...[
                pw.Text(
                  _sanitizePdfText(reportTitle),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfThemeColors.textPrimary,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Printed on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfThemeColors.textSecondary,
                  ),
                ),
                pw.SizedBox(height: 14),
              ],
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(snapshotImage, fit: pw.BoxFit.contain),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await _savePdfInIsolate(pdf);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static Future<pw.Document> _createGenericReport(
    String title,
    List<String> headers,
    List<List<dynamic>> rows,
    CompanyProfileData company, {
    String? subtitle,
    Map<String, String>? filterSummary,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final safeHeaders = headers.map(_sanitizePdfText).toList(growable: false);
    final safeRows = rows
        .map(
          (row) => row
              .map((cell) => _sanitizePdfText((cell ?? '').toString()))
              .toList(growable: false),
        )
        .toList(growable: false);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _sanitizePdfText(company.name ?? 'Datt Soap'),
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfThemeColors.primary,
                        ),
                      ),
                      pw.Text(
                        _sanitizePdfText(company.address ?? ''),
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Date: $dateStr',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                _sanitizePdfText(title),
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfThemeColors.textPrimary,
                ),
              ),
              if (subtitle != null &&
                  (filterSummary == null || filterSummary.isEmpty)) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  _sanitizePdfText(subtitle),
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfThemeColors.textSecondary,
                  ),
                ),
              ],
              if (filterSummary != null && filterSummary.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfThemeColors.surfaceMuted,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                    border: pw.Border.all(color: PdfThemeColors.border),
                  ),
                  child: pw.Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: filterSummary.entries
                        .map(
                          (e) => pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                '${e.key}: ',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                  color: PdfThemeColors.textSecondary,
                                ),
                              ),
                              pw.Text(
                                _sanitizePdfText(e.value),
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              pw.Divider(
                thickness: 1,
                height: 32,
                color: PdfThemeColors.primary,
              ),
              pw.SizedBox(height: 10),
            ],
          ),
          pw.TableHelper.fromTextArray(
            headers: safeHeaders,
            data: safeRows,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfThemeColors.onPrimary,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfThemeColors.primary),
            cellHeight: 25,
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerAlignments: {
              for (var i = 0; i < safeHeaders.length; i++)
                i: pw.Alignment.center,
            },
            cellAlignments: {
              for (var i = 0; i < safeHeaders.length; i++)
                i: pw.Alignment.centerLeft,
            },
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated by DattSoap ERP System',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfThemeColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return pdf;
  }

  static Future<pw.Document> _createSaleInvoice(
    Sale sale,
    CompanyProfileData company,
  ) async {
    final pdf = pw.Document();
    final createdAt =
        DateTime.tryParse(sale.createdAt.trim()) ?? DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
    final lineDiscountAmount = sale.itemDiscountAmount;
    final primaryDiscountAmount = sale.discountAmount;
    final additionalDiscountAmount = sale.additionalDiscountAmount ?? 0.0;
    final primaryDiscountPct = sale.discountPercentage;
    final additionalDiscountPct = sale.additionalDiscountPercentage ?? 0.0;
    final normalizedGstType = _normalizeGstType(sale.gstType);
    final gstPercentage = sale.gstPercentage.clamp(0.0, 100.0).toDouble();

    double cgstAmount = sale.cgstAmount ?? 0.0;
    double sgstAmount = sale.sgstAmount ?? 0.0;
    double igstAmount = sale.igstAmount ?? 0.0;
    var totalGstAmount = cgstAmount + sgstAmount + igstAmount;
    var fallbackGstAmount = _round2(sale.totalAmount - sale.taxableAmount);
    if (fallbackGstAmount < 0) fallbackGstAmount = 0.0;
    if (totalGstAmount <= 0 && fallbackGstAmount > 0) {
      totalGstAmount = fallbackGstAmount;
      if (normalizedGstType == 'CGST+SGST') {
        cgstAmount = _round2(totalGstAmount / 2);
        sgstAmount = _round2(totalGstAmount - cgstAmount);
      } else if (normalizedGstType == 'IGST') {
        igstAmount = totalGstAmount;
      }
    }
    if (normalizedGstType == 'CGST+SGST' &&
        totalGstAmount > 0 &&
        cgstAmount <= 0 &&
        sgstAmount <= 0) {
      cgstAmount = _round2(totalGstAmount / 2);
      sgstAmount = _round2(totalGstAmount - cgstAmount);
    }
    if (normalizedGstType == 'IGST' && totalGstAmount > 0 && igstAmount <= 0) {
      igstAmount = totalGstAmount;
    }
    final gstHalfPct = gstPercentage > 0 ? gstPercentage / 2 : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          _sanitizePdfText(company.name ?? 'Datt Soap'),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfThemeColors.primary,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _sanitizePdfText(
                            company.address ?? 'Factory Address',
                          ),
                          style: const pw.TextStyle(fontSize: 10),
                          maxLines: 2,
                        ),
                        pw.Text(
                          'GSTIN: ${_sanitizePdfText(company.gstin ?? "N/A")}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Phone: ${_sanitizePdfText(company.phone ?? "N/A")}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TAX INVOICE',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfThemeColors.textSecondary,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Invoice No: ${_displayInvoiceNumber(sale)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Date: $dateStr',
                          textAlign: pw.TextAlign.right,
                        ),
                        if ((sale.driverName ?? '').trim().isNotEmpty)
                          pw.Text(
                            'Driver: ${_sanitizePdfText(sale.driverName!.trim())}',
                            textAlign: pw.TextAlign.right,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(
                thickness: 2,
                color: PdfThemeColors.primary,
                height: 32,
              ),

              // Billing Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILL TO:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfThemeColors.textSecondary,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _sanitizePdfText(sale.recipientName),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      // In a real app we'd fetch customer address here
                      // pw.Text('Route: ${sale.route ?? "N/A"}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SALESMAN:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfThemeColors.textSecondary,
                        ),
                      ),
                      pw.Text(_sanitizePdfText(sale.salesmanName)),
                      if ((sale.vehicleNumber ?? '').trim().isNotEmpty)
                        pw.Text(
                          'Vehicle: ${_sanitizePdfText(sale.vehicleNumber!.trim())}',
                        ),
                      if ((sale.route ?? '').trim().isNotEmpty)
                        pw.Text(
                          'Route: ${_sanitizePdfText(sale.route!.trim())}',
                        ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfThemeColors.border),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(100),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfThemeColors.primarySoft,
                    ),
                    children: [
                      _tableCell('S.No', isHeader: true),
                      _tableCell('Product Name', isHeader: true),
                      _tableCell('Qty', isHeader: true),
                      _tableCell('Price', isHeader: true),
                      _tableCell('Total', isHeader: true),
                    ],
                  ),
                  // Table Rows
                  ...List.generate(sale.items.length, (index) {
                    final item = sale.items[index];
                    final safeItemName = _sanitizePdfText(item.name);
                    final safeBaseUnit = _sanitizePdfText(item.baseUnit);
                    return pw.TableRow(
                      children: [
                        _tableCell('${index + 1}'),
                        _tableCell(safeItemName),
                        _tableCell('${item.quantity} $safeBaseUnit'),
                        _tableCell(_formatInr(item.price)),
                        _tableCell(
                          _formatInr(
                            item.lineTotalAmount ??
                                (item.price * item.quantity),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 24),

              // Summary
              pw.Row(
                children: [
                  pw.Spacer(flex: 2),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal', sale.subtotal),
                        if (lineDiscountAmount > 0)
                          _summaryRow(
                            _lineDiscountLabel(sale, lineDiscountAmount),
                            -lineDiscountAmount,
                          ),
                        if (primaryDiscountAmount > 0)
                          _summaryRow(
                            primaryDiscountPct > 0
                                ? 'Primary Discount (${_formatPercent(primaryDiscountPct)}%)'
                                : 'Primary Discount',
                            -primaryDiscountAmount,
                          ),
                        if (additionalDiscountAmount > 0)
                          _summaryRow(
                            additionalDiscountPct > 0
                                ? 'Addl. Discount (${_formatPercent(additionalDiscountPct)}%)'
                                : 'Addl. Discount',
                            -additionalDiscountAmount,
                          ),
                        pw.Divider(),
                        _summaryRow('Taxable Value', sale.taxableAmount),
                        if (cgstAmount > 0)
                          _summaryRow(
                            'CGST (${_formatPercent(gstHalfPct)}%)',
                            cgstAmount,
                          ),
                        if (sgstAmount > 0)
                          _summaryRow(
                            'SGST (${_formatPercent(gstHalfPct)}%)',
                            sgstAmount,
                          ),
                        if (igstAmount > 0)
                          _summaryRow(
                            'IGST (${_formatPercent(gstPercentage)}%)',
                            igstAmount,
                          ),
                        if ((sale.roundOff ?? 0).abs() > 0.009)
                          _summaryRow('Round Off', sale.roundOff ?? 0),
                        pw.Divider(),
                        _summaryRow(
                          'Grand Total',
                          sale.totalAmount,
                          isBold: true,
                        ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfThemeColors.surfaceMuted,
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                _sanitizePdfText(
                                  'Paid: ${_formatInr(sale.paidAmount)}',
                                ),
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              // Footer
              pw.Divider(color: PdfThemeColors.border),
              pw.Text(
                'Terms & Conditions:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                '- Goods once sold will not be taken back.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '- All disputes are subject to local jurisdiction.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'This is a computer generated invoice and does not require a signature.',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfThemeColors.textMuted,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  static Future<pw.Document> _createPaymentReceipt(
    ManualPayment payment,
    CompanyProfileData company,
  ) async {
    final pdf = pw.Document();
    final dateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(payment.date));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5, // Smaller for receipts
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfThemeColors.primary, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      _sanitizePdfText(company.name ?? 'Datt Soap'),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfThemeColors.primary,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      color: PdfThemeColors.primary,
                      child: pw.Text(
                        'PAYMENT RECEIPT',
                        style: pw.TextStyle(
                          color: PdfThemeColors.onPrimary,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Receipt No: ${payment.id.substring(payment.id.length - 8).toUpperCase()}',
                    ),
                    pw.Text('Date: $dateStr'),
                  ],
                ),
                pw.Divider(height: 24),

                pw.RichText(
                  text: pw.TextSpan(
                    text: 'Received with thanks from ',
                    style: const pw.TextStyle(fontSize: 12),
                    children: [
                      pw.TextSpan(
                        text: payment.customerName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.RichText(
                  text: pw.TextSpan(
                    text: 'The sum of ',
                    style: const pw.TextStyle(fontSize: 12),
                    children: [
                      pw.TextSpan(
                        text: 'INR ${payment.amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      pw.TextSpan(text: ' towards outstanding balance.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Mode of Payment: ${payment.mode.toString().split('.').last.toUpperCase()}',
                ),
                if (payment.reference != null)
                  pw.Text('Reference: ${payment.reference}'),

                pw.SizedBox(height: 24),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Collector: ${payment.collectorName}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.SizedBox(
                          height: 20,
                          width: 100,
                          child: pw.Divider(color: PdfThemeColors.textPrimary),
                        ),
                        pw.Text(
                          'Authorized Signatory',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf;
  }

  /// Saves the PDF document, isolating the heavy byte-encoding work.
  static Future<Uint8List> _savePdfInIsolate(pw.Document pdf) async {
    try {
      return await Isolate.run(() => pdf.save());
    } catch (_) {
      // Keep backward compatibility if any runtime blocks sending the document
      // object to an isolate.
      return pdf.save();
    }
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        _sanitizePdfText(text),
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 10 : 9,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            _sanitizePdfText(label),
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            _formatInr(amount),
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static double _round2(double amount) {
    return (amount * 100).roundToDouble() / 100;
  }

  static String _normalizeGstType(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    if (normalized == 'CGST+SGST') return 'CGST+SGST';
    if (normalized == 'IGST') return 'IGST';
    return 'NONE';
  }

  static String _formatPercent(double value) {
    final rounded = _round2(value);
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toStringAsFixed(0);
    }
    return rounded
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String _lineDiscountLabel(Sale sale, double lineDiscountAmount) {
    if (lineDiscountAmount <= 0) return 'Line Discount';
    final itemDiscounts = sale.items
        .where((item) => !item.isFree && item.discount > 0)
        .map((item) => _round2(item.discount))
        .toSet();
    if (itemDiscounts.length == 1) {
      return 'Line Discount (${_formatPercent(itemDiscounts.first)}%)';
    }
    if (sale.subtotal > 0) {
      final effectivePct = _round2((lineDiscountAmount * 100) / sale.subtotal);
      return 'Line Discount (${_formatPercent(effectivePct)}%)';
    }
    return 'Line Discount';
  }

  static String _formatInr(double amount) {
    return 'Rs ${amount.toStringAsFixed(2)}';
  }

  static String _displayInvoiceNumber(Sale sale) {
    final humanReadable = sale.humanReadableId?.trim();
    if (humanReadable != null && humanReadable.isNotEmpty) {
      return _sanitizePdfText(humanReadable);
    }

    final id = sale.id.trim();
    if (id.isEmpty) return 'INV-NA';
    final compact = id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (compact.isEmpty) return 'INV-NA';
    final suffix = compact.length > 8
        ? compact.substring(compact.length - 8)
        : compact;
    return 'INV-$suffix';
  }

  static String _sanitizePdfText(String text) {
    if (text.isEmpty) return text;
    var value = text
        .replaceAll('\u20B9', 'Rs ')
        .replaceAll(r'\u20B9', 'Rs ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (value.isEmpty) return value;

    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final isPrintableAscii = rune >= 0x20 && rune <= 0x7E;
      final isLatinSupplement = rune >= 0xA0 && rune <= 0xFF;
      if (isPrintableAscii || isLatinSupplement) {
        buffer.writeCharCode(rune);
      } else {
        buffer.write(' ');
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _toSafeFileName(String input) {
    final value = input.trim().toLowerCase();
    if (value.isEmpty) return 'report';
    return value
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String _toSafePdfFileName(String input) {
    final normalized = input.trim();
    final noExt = normalized.toLowerCase().endsWith('.pdf')
        ? normalized.substring(0, normalized.length - 4)
        : normalized;
    final safe = _toSafeFileName(noExt);
    if (safe.isEmpty) return 'document.pdf';
    return '$safe.pdf';
  }

  static Future<void> _sharePdfBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeFileName = _toSafePdfFileName(filename);

    try {
      await Printing.sharePdf(bytes: bytes, filename: safeFileName);
      return;
    } catch (_) {
      // Fallback to SharePlus below.
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$safeFileName');
      await tempFile.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([
        XFile(tempFile.path, mimeType: 'application/pdf', name: safeFileName),
      ], subject: safeFileName);
      return;
    } catch (_) {
      // If both flows fail, throw from printing call below.
    }

    await Printing.sharePdf(bytes: bytes, filename: safeFileName);
  }

  static Future<void> generateAndPrintCreditNote(
    ReturnRequest request,
    CompanyProfileData company,
  ) async {
    final pdf = await _createCreditNote(request, company);
    final bytes = await _savePdfInIsolate(pdf);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static Future<void> shareCreditNote(
    ReturnRequest request,
    CompanyProfileData company,
  ) async {
    final pdf = await _createCreditNote(request, company);
    final bytes = await _savePdfInIsolate(pdf);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'CreditNote_${request.id}.pdf',
    );
  }

  static Future<pw.Document> _createCreditNote(
    ReturnRequest request,
    CompanyProfileData company,
  ) async {
    final pdf = pw.Document();
    final dateStr = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.parse(request.createdAt));

    // Calculate totals
    final totalAmount = request.items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * (item.price ?? 0)),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _sanitizePdfText(company.name ?? 'Datt Soap'),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfThemeColors.primary,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        _sanitizePdfText(company.address ?? 'Factory Address'),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'GSTIN: ${company.gstin ?? "N/A"}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Phone: ${company.phone ?? "N/A"}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'CREDIT NOTE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfThemeColors.textSecondary,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'CN No: ${request.id.substring(0, 8).toUpperCase()}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Date: $dateStr'),
                    ],
                  ),
                ],
              ),
              pw.Divider(
                thickness: 2,
                color: PdfThemeColors.primary,
                height: 32,
              ),

              // Customer & Return Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CREDIT TO:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfThemeColors.textSecondary,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        request.customerName ?? 'Unknown Customer',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SALESMAN:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfThemeColors.textSecondary,
                        ),
                      ),
                      pw.Text(request.salesmanName),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Reason: ${request.reason}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfThemeColors.border),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(80),
                  4: const pw.FixedColumnWidth(100),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfThemeColors.primarySoft,
                    ),
                    children: [
                      _tableCell('S.No', isHeader: true),
                      _tableCell('Product Name', isHeader: true),
                      _tableCell('Qty', isHeader: true),
                      _tableCell('Price', isHeader: true),
                      _tableCell('Total', isHeader: true),
                    ],
                  ),
                  // Table Rows
                  ...List.generate(request.items.length, (index) {
                    final item = request.items[index];
                    return pw.TableRow(
                      children: [
                        _tableCell('${index + 1}'),
                        _tableCell(item.name),
                        _tableCell('${item.quantity} ${item.unit}'),
                        _tableCell(_formatInr(item.price ?? 0)),
                        _tableCell(
                          _formatInr((item.price ?? 0) * item.quantity),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 24),

              // Summary
              pw.Row(
                children: [
                  pw.Spacer(flex: 2),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      children: [
                        _summaryRow('Total Credit', totalAmount, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              // Footer
              pw.Divider(color: PdfThemeColors.border),
              pw.Text(
                'Note:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'This credit note can be used against future purchases.',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'This is a computer generated document and does not require a signature.',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfThemeColors.textMuted,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }
}
