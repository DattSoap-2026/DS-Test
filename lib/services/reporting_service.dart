import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/types/sales_types.dart';
import '../modules/hr/models/employee_model.dart';

class ReportingService {
  // 1. Generate Invoice PDF
  Future<Uint8List> generateInvoicePdf(Sale sale) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('TAX INVOICE')),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Datt Soap Factory',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Industrial Area, City'),
                      pw.Text('GSTIN: 24XXXXXXXXXXXXX'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: ${sale.humanReadableId ?? sale.id}'),
                      pw.Text(
                        'Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(sale.createdAt))}',
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(),
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(sale.recipientName),
              pw.SizedBox(height: 20),

              // Items Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Item', 'Qty', 'Price', 'Total'],
                data: sale.items
                    .map(
                      (item) => [
                        item.name,
                        item.quantity.toString(),
                        item.price.toStringAsFixed(2),
                        (item.quantity * item.price).toStringAsFixed(2),
                      ],
                    )
                    .toList(),
              ),

              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ${sale.subtotal.toStringAsFixed(2)}'),
                      pw.Text(
                        'GST (${sale.gstPercentage}%): ${((sale.cgstAmount ?? 0) + (sale.sgstAmount ?? 0) + (sale.igstAmount ?? 0)).toStringAsFixed(2)}',
                      ),
                      pw.Divider(),
                      pw.Text(
                        'TOTAL: ${sale.totalAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return _savePdfBytesNonBlocking(pdf);
  }

  // 2. Generate Payslip PDF
  Future<Uint8List> generatePayslipPdf({
    required Employee employee,
    required DateTime month,
    required double totalHours,
    required double baseSalary,
    required double netSalary,
    double otHours = 0,
    double bonuses = 0,
    double deductions = 0,
  }) async {
    final pdf = pw.Document();
    final monthStr = DateFormat('MMMM yyyy').format(month);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'DATT SOAP FACTORY',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(child: pw.Text('PAYSLIP - $monthStr')),
                pw.SizedBox(height: 30),

                // Employee Details Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      children: [
                        _pdfCell('Employee Name:', bold: true),
                        _pdfCell(employee.name),
                        _pdfCell('Employee ID:', bold: true),
                        _pdfCell(employee.employeeId),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _pdfCell('Department:', bold: true),
                        _pdfCell(employee.department),
                        _pdfCell('Role:', bold: true),
                        _pdfCell(employee.roleType),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _pdfCell('Payment Method:', bold: true),
                        _pdfCell(employee.paymentMethod ?? 'N/A'),
                        _pdfCell('Bank Details:', bold: true),
                        _pdfCell(employee.bankDetails ?? 'N/A'),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _pdfCell('Joining Date:', bold: true),
                        _pdfCell(DateFormat('dd-MM-yyyy').format(employee.joiningDate)),
                        _pdfCell('OT Multiplier:', bold: true),
                        _pdfCell('${employee.overtimeMultiplier}x'),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                // Salary Components Table
                pw.Text(
                  'Salary Components',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _pdfCell('Description', bold: true),
                        _pdfCell('Amount / Value', bold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _pdfCell('Basic Salary ${employee.isMonthly ? '(Monthly)' : '(per Hour)'}'),
                        _pdfCell('Rs. ${baseSalary.toStringAsFixed(2)}'),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _pdfCell('Working Hours'),
                        _pdfCell('${totalHours.toStringAsFixed(1)} Hrs'),
                      ],
                    ),
                    if (otHours > 0)
                      pw.TableRow(
                        children: [
                          _pdfCell('Overtime Hours'),
                          _pdfCell('${otHours.toStringAsFixed(1)} Hrs'),
                        ],
                      ),
                    if (bonuses > 0)
                      pw.TableRow(
                        children: [
                          _pdfCell('Incentives / Bonuses'),
                          _pdfCell('Rs. ${bonuses.toStringAsFixed(2)}'),
                        ],
                      ),
                    if (deductions > 0)
                      pw.TableRow(
                        children: [
                          _pdfCell('Deductions (Advances/Late)'),
                          _pdfCell('Rs. ${deductions.toStringAsFixed(2)}', color: PdfColors.red),
                        ],
                      ),
                    pw.TableRow(
                      children: [
                        _pdfCell('NET PAYABLE', bold: true),
                        _pdfCell('Rs. ${netSalary.toStringAsFixed(2)}', bold: true),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'This is a computer generated document and does not require a signature.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return _savePdfBytesNonBlocking(pdf);
  }

  pw.Widget _pdfCell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  // 3. Save and Open PDF
  Future<void> saveAndOpenPdf(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    // In a real app, use open_file to open it or printing.sharePdf
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  Future<Uint8List> _savePdfBytesNonBlocking(pw.Document pdf) async {
    try {
      return await Isolate.run(() => pdf.save());
    } catch (_) {
      return pdf.save();
    }
  }
}
