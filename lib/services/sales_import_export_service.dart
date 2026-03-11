import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/types/sales_types.dart';
import '../services/customers_service.dart';
import '../services/users_service.dart';
import '../services/products_service.dart';
import '../services/sales_service.dart';
import '../utils/app_logger.dart';
import '../core/utils/platform/web_downloader.dart';

class SalesImportExportService {
  final CustomersService _customersService;
  final UsersService _usersService;
  final ProductsService _productsService;
  final SalesService _salesService;

  SalesImportExportService(
    this._customersService,
    this._usersService,
    this._productsService,
    this._salesService,
  );

  // ==================== EXPORT ====================

  Future<void> exportSalesToCsv({
    required List<Sale> sales,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Sale ID',
      'Date',
      'Salesman Name',
      'Salesman ID',
      'Customer Name',
      'Customer ID',
      'Route',
      'Product SKU',
      'Product Name',
      'Quantity',
      'Unit',
      'Rate',
      'Line Amount',
      'Discount',
      'Tax',
      'Total Amount',
      'Payment Mode',
      'Status',
      'Created At',
    ]);

    // Data
    for (final sale in sales) {
      for (final item in sale.items) {
        rows.add([
          sale.humanReadableId ?? sale.id,
          DateFormat('yyyy-MM-dd').format(DateTime.parse(sale.createdAt)),
          sale.salesmanName,
          sale.salesmanId,
          sale.recipientName,
          sale.recipientId,
          sale.route ?? '',
          item.productId,
          item.name,
          item.quantity,
          item.baseUnit.isEmpty ? 'pcs' : item.baseUnit,
          item.price,
          item.lineNetAmount ?? (item.price * item.quantity),
          item.discount,
          item.lineTaxAmount ?? 0,
          sale.totalAmount,
          'Cash',
          sale.status ?? 'Completed',
          sale.createdAt,
        ]);
      }
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final dateRange = startDate != null && endDate != null
        ? '_${DateFormat('yyyyMMdd').format(startDate)}_to_${DateFormat('yyyyMMdd').format(endDate)}'
        : '';
    final filename = 'sales_export$dateRange.csv';

    if (kIsWeb) {
      downloadCsvWeb(csvData, filename);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(path)], text: 'Sales Export');
    }
  }

  Future<void> exportSalesToExcel({
    required List<Sale> sales,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sales'];

    // Header
    sheet.appendRow([
      TextCellValue('Sale ID'),
      TextCellValue('Date'),
      TextCellValue('Salesman Name'),
      TextCellValue('Customer Name'),
      TextCellValue('Route'),
      TextCellValue('Product SKU'),
      TextCellValue('Product Name'),
      TextCellValue('Quantity'),
      TextCellValue('Rate'),
      TextCellValue('Amount'),
      TextCellValue('Payment Mode'),
      TextCellValue('Status'),
    ]);

    // Data
    for (final sale in sales) {
      for (final item in sale.items) {
        sheet.appendRow([
          TextCellValue(sale.humanReadableId ?? sale.id),
          TextCellValue(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(sale.createdAt)),
          ),
          TextCellValue(sale.salesmanName),
          TextCellValue(sale.recipientName),
          TextCellValue(sale.route ?? ''),
          TextCellValue(item.productId),
          TextCellValue(item.name),
          IntCellValue(item.quantity),
          DoubleCellValue(item.price),
          DoubleCellValue(item.lineNetAmount ?? (item.price * item.quantity)),
          TextCellValue('Cash'),
          TextCellValue(sale.status ?? 'Completed'),
        ]);
      }
    }

    final dateRange = startDate != null && endDate != null
        ? '_${DateFormat('yyyyMMdd').format(startDate)}_to_${DateFormat('yyyyMMdd').format(endDate)}'
        : '';
    final filename = 'sales_export$dateRange.xlsx';

    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final bytes = excel.encode();
      if (bytes != null) {
        final file = File(path);
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(path)], text: 'Sales Export');
      }
    }
  }

  // ==================== IMPORT ====================

  Future<Map<String, dynamic>> importSalesFromCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return {'success': 0, 'failed': 0, 'errors': []};

      final file = File(result.files.single.path!);
      String csvContent = await file.readAsString();
      csvContent = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final fields = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvContent);

      if (fields.isEmpty) {
        return {'success': 0, 'failed': 0, 'errors': ['CSV file is empty']};
      }

      final headers = fields.first.map((e) => e.toString().trim().toLowerCase()).toList();
      
      // Load master data
      final customers = await _customersService.getCustomers();
      final users = await _usersService.getUsers();
      final products = await _productsService.getProducts();

      final customerMap = {for (var c in customers) c.shopName.toLowerCase(): c};
      final salesmanMap = {for (var u in users) u.name.toLowerCase(): u};
      final productMap = {for (var p in products) p.sku.toLowerCase(): p};

      int successCount = 0;
      int failedCount = 0;
      List<String> errors = [];

      for (int i = 1; i < fields.length; i++) {
        try {
          final row = fields[i];
          final Map<String, dynamic> rowMap = {};
          for (int j = 0; j < headers.length && j < row.length; j++) {
            rowMap[headers[j]] = row[j];
          }

          // Validate required fields
          final date = _parseDate(rowMap['date']?.toString() ?? '');
          final salesmanName = rowMap['salesmanname']?.toString().trim().toLowerCase() ?? '';
          final customerName = rowMap['customername']?.toString().trim().toLowerCase() ?? '';
          final productSku = rowMap['productsku']?.toString().trim().toLowerCase() ?? '';
          final quantity = int.tryParse(rowMap['quantity']?.toString() ?? '0') ?? 0;
          final rate = double.tryParse(rowMap['rate']?.toString() ?? '0') ?? 0;

          if (date == null) {
            errors.add('Row $i: Invalid date format');
            failedCount++;
            continue;
          }

          final salesman = salesmanMap[salesmanName];
          if (salesman == null) {
            errors.add('Row $i: Salesman "$salesmanName" not found');
            failedCount++;
            continue;
          }

          final customer = customerMap[customerName];
          if (customer == null) {
            errors.add('Row $i: Customer "$customerName" not found');
            failedCount++;
            continue;
          }

          final product = productMap[productSku];
          if (product == null) {
            errors.add('Row $i: Product "$productSku" not found');
            failedCount++;
            continue;
          }

          if (quantity <= 0) {
            errors.add('Row $i: Invalid quantity');
            failedCount++;
            continue;
          }

          if (rate <= 0) {
            errors.add('Row $i: Invalid rate');
            failedCount++;
            continue;
          }

          // Create sale
          await _salesService.createSale(
            recipientType: 'customer',
            recipientId: customer.id,
            recipientName: customer.shopName,
            items: [
              SaleItemForUI(
                productId: product.id,
                name: product.name,
                quantity: quantity,
                price: rate,
                baseUnit: product.baseUnit,
                isFree: false,
                discount: 0.0,
                stock: product.stock.floor(),
              ),
            ],
            discountPercentage: 0.0,
            route: rowMap['route']?.toString(),
          );
          successCount++;
        } catch (e) {
          errors.add('Row $i: ${e.toString()}');
          failedCount++;
        }
      }

      return {
        'success': successCount,
        'failed': failedCount,
        'errors': errors,
      };
    } catch (e) {
      AppLogger.error('Sales import failed', error: e, tag: 'SalesImport');
      rethrow;
    }
  }

  Future<void> generateImportTemplate() async {
    final List<List<dynamic>> rows = [];
    
    rows.add([
      'Date',
      'SalesmanName',
      'CustomerName',
      'Route',
      'ProductSKU',
      'Quantity',
      'Rate',
      'PaymentMode',
      'Status',
    ]);

    rows.add([
      '2024-01-15',
      'John Doe',
      'ABC Store',
      'Route 1',
      'FG-001',
      '100',
      '50.00',
      'Cash',
      'Completed',
    ]);

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sales_import_template.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(path)], text: 'Sales Import Template');
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Try YYYY-MM-DD
      if (dateStr.contains('-')) {
        return DateTime.parse(dateStr);
      }
      // Try DD/MM/YYYY
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
