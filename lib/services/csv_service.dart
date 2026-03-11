import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/types/product_types.dart';
import '../utils/app_logger.dart';
import '../core/utils/platform/web_downloader.dart';

class CsvService {
  Future<void> exportProducts(List<Product> products) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'ID',
      'Name',
      'SKU',
      'Category',
      'Type',
      'Price',
      'Stock',
      'Unit',
      'Status',
    ]);

    // Data
    for (final product in products) {
      rows.add([
        product.id,
        product.name,
        product.sku,
        product.category,
        product.itemType.value,
        product.price,
        product.stock,
        product.unit,
        product.status,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    // Save and Share
    if (kIsWeb) {
      // Web export
      final filename =
          'products_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      downloadCsvWeb(csvData, filename);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/products_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles([XFile(path)], text: 'Products Export');
    }
  }

  Future<void> generateTemplate() async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'Name',
      'SKU',
      'Category',
      'Type', // Raw Material, Finished Good, etc.
      'Price',
      'Stock',
      'Unit', // kg, ltr, pcs
      'Description',
    ]);

    // Example: Finished Good
    rows.add([
      'Example Soap Bar',
      'FG-SOAP-001',
      'Soaps',
      'Finished Good',
      '50.0',
      '100',
      'pcs',
      'Standard Bath Soap',
    ]);

    // Example: Raw Material
    rows.add([
      'Coconut Oil',
      'RM-OIL-001',
      'Oils',
      'Raw Material',
      '200.0',
      '500',
      'ltr',
      'Premium grade coconut oil',
    ]);

    // Example: Traded Good
    rows.add([
      'Branded Perfume',
      'TG-PERF-001',
      'Perfumes',
      'Traded Good',
      '450.0',
      '50',
      'pcs',
      'Resale item',
    ]);

    // Example: Semi Finished
    rows.add([
      'Soap Base',
      'SF-BASE-001',
      'Base',
      'Semi Finished',
      '120.0',
      '200',
      'kg',
      'Unscented soap base',
    ]);

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/product_import_template.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(path)], text: 'Product Import Template');
  }

  Future<List<Map<String, dynamic>>> pickAndParseCsv() async {
    try {
      AppLogger.info('Opening file picker for CSV...', tag: 'CSV');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        AppLogger.info('No file selected', tag: 'CSV');
        return [];
      }

      AppLogger.info('File selected: ${result.files.single.name}', tag: 'CSV');
      final file = File(result.files.single.path!);

      // Read as string directly to handle EOLs better
      String csvContent = await file.readAsString();

      // Normalize line endings to \n
      csvContent = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final fields = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvContent);

      AppLogger.info('CSV parsed: ${fields.length} rows found', tag: 'CSV');

      if (fields.isEmpty) {
        AppLogger.warning('CSV file is empty', tag: 'CSV');
        return [];
      }

      // Assume first row is header
      final headers = fields.first
          .map((e) => e.toString().trim().toLowerCase())
          .toList();
      AppLogger.info('CSV Headers: $headers', tag: 'CSV');

      final data = <Map<String, dynamic>>[];

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        final Map<String, dynamic> rowMap = {};

        for (int j = 0; j < headers.length && j < row.length; j++) {
          rowMap[headers[j]] = row[j];
        }
        data.add(rowMap);
      }

      AppLogger.info('CSV data rows extracted: ${data.length}', tag: 'CSV');
      return data;
    } catch (e) {
      AppLogger.error('Error parsing CSV', error: e, tag: 'CSV');
      rethrow;
    }
  }
}
