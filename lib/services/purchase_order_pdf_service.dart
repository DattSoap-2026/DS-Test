import 'dart:isolate';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

import '../utils/app_logger.dart';
import '../utils/pdf_theme.dart';
import '../models/types/purchase_order_types.dart';

class PurchaseOrderPdfService {
  static Future<void> generateAndShare(PurchaseOrder order) async {
    final pdf = await generatePdf(order);
    final bytes = await _savePdfBytesNonBlocking(pdf);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'PO_${order.poNumber}.pdf',
    );
  }

  static Future<void> generateAndPrint(PurchaseOrder order) async {
    final pdf = await generatePdf(order);
    final bytes = await _savePdfBytesNonBlocking(pdf);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'PO_${order.poNumber}',
    );
  }

  static Future<File> generatePdfFile(PurchaseOrder order) async {
    final pdf = await generatePdf(order);
    final bytes = await _savePdfBytesNonBlocking(pdf);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/PO_${order.poNumber}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> cleanup() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      final files = dir.listSync();
      for (var file in files) {
        if (file is File &&
            file.path.contains('PO_') &&
            file.path.endsWith('.pdf')) {
          await file.delete();
        }
      }
    } catch (e) {
      AppLogger.error('Error cleaning up temp PDFs', error: e, tag: 'PDF');
    }
  }

  static Future<pw.Document> generatePdf(PurchaseOrder order) async {
    final pdf = pw.Document();

    // Use built-in fonts for speed and reliable offline support
    final fontRegular = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (context) => [
          _buildHeader(order),
          pw.SizedBox(height: 20),
          _buildInfoSection(order),
          pw.SizedBox(height: 20),
          _buildItemsTable(order),
          pw.SizedBox(height: 20),
          _buildSummary(order),
        ],
        footer: (context) => _buildFooter(),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(PurchaseOrder order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'DattSoap ERP',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfThemeColors.primary,
              ),
            ),
            pw.Text('Quality Laundry Soaps & Chemicals'),
            pw.Text('GSTIN: [CONFIGURABLE_GSTIN]'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'PURCHASE ORDER',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfThemeColors.textSecondary,
              ),
            ),
            pw.Text('No: ${order.poNumber}'),
            pw.Text(
              'Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(order.createdAt))}',
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoSection(PurchaseOrder order) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SUPPLIER:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(order.supplierName),
              pw.Text('Supplier ID: ${_shortenId(order.supplierId)}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'EXPECTED DELIVERY:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                order.expectedDeliveryDate != null
                    ? DateFormat(
                        'dd-MM-yyyy',
                      ).format(DateTime.parse(order.expectedDeliveryDate!))
                    : 'Not Specified',
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'STATUS:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(order.status.value.toUpperCase()),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(PurchaseOrder order) {
    final headers = ['Item Name', 'Qty', 'Unit', 'Rate', 'GST %', 'Total'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: order.items
          .map(
            (item) => [
              item.name,
              item.quantity.toStringAsFixed(2),
              item.unit,
              'Rs.${item.unitPrice.toStringAsFixed(2)}',
              '${item.gstPercentage}%',
              'Rs.${item.total.toStringAsFixed(2)}',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfThemeColors.onPrimary,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfThemeColors.primary),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildSummary(PurchaseOrder order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _buildSummaryRow(
                'Subtotal',
                'Rs.${order.subtotal.toStringAsFixed(2)}',
              ),
              if (order.gstType == 'CGST+SGST') ...[
                _buildSummaryRow(
                  'CGST',
                  'Rs.${order.cgstAmount.toStringAsFixed(2)}',
                ),
                _buildSummaryRow(
                  'SGST',
                  'Rs.${order.sgstAmount.toStringAsFixed(2)}',
                ),
              ] else if (order.gstType == 'IGST') ...[
                _buildSummaryRow(
                  'IGST',
                  'Rs.${order.igstAmount.toStringAsFixed(2)}',
                ),
              ],
              _buildSummaryRow(
                'Round Off',
                'Rs.${order.roundOff.toStringAsFixed(2)}',
              ),
              pw.Divider(),
              _buildSummaryRow(
                'Grand Total',
                'Rs.${order.totalAmount.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
          pw.Text(
            value,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Terms & Conditions:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('1. Subject to Jaipur Jurisdiction.'),
                  pw.Text('2. Goods once sold will be replaced if defective.'),
                ],
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 30),
                      pw.Text('Receiver\'s Signature'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 30),
                      pw.Text('For DattSoap'),
                      pw.Text('(Authorized Signatory)'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _shortenId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8).toUpperCase();
  }

  static Future<Uint8List> _savePdfBytesNonBlocking(pw.Document pdf) async {
    try {
      return await Isolate.run(() => pdf.save());
    } catch (e) {
      AppLogger.warning(
        'PO PDF isolate save failed, using inline fallback: $e',
        tag: 'PDF',
      );
      return pdf.save();
    }
  }
}
