import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/local/entities/dealer_entity.dart';
import '../data/repositories/dealer_repository.dart';

class DealerImportService {
  final DealerRepository _dealerRepository;

  DealerImportService(this._dealerRepository);

  Future<Map<String, dynamic>> importDealers() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (result == null || result.files.isEmpty) {
        return {'success': false, 'message': 'No file selected'};
      }

      final file = result.files.first;
      List<Map<String, dynamic>> data = [];

      if (file.extension == 'xlsx') {
        data = await _parseExcel(file);
      } else if (file.extension == 'csv') {
        data = await _parseCSV(file);
      }

      if (data.isEmpty) {
        return {'success': false, 'message': 'No data found in file'};
      }

      int importedCount = 0;
      int errorCount = 0;

      for (var row in data) {
        try {
          final dealerName =
              row['Dealer Name']?.toString() ?? row['name']?.toString();
          final mobile = row['Mobile']?.toString() ?? row['mobile']?.toString();

          if (dealerName == null ||
              dealerName.isEmpty ||
              mobile == null ||
              mobile.isEmpty) {
            errorCount++;
            continue;
          }

          final entity = DealerEntity()
            ..id = const Uuid().v4()
            ..name = dealerName
            ..contactPerson =
                row['Contact Person']?.toString() ??
                row['contact_person']?.toString() ??
                ''
            ..mobile = mobile
            ..address =
                row['Address']?.toString() ?? row['address']?.toString() ?? ''
            ..city = row['City']?.toString() ?? row['city']?.toString()
            ..state = row['State']?.toString() ?? row['state']?.toString()
            ..pincode = row['Pincode']?.toString() ?? row['pincode']?.toString()
            ..email = row['Email']?.toString() ?? row['email']?.toString()
            ..gstin = row['GSTIN']?.toString() ?? row['gstin']?.toString()
            ..pan = row['PAN']?.toString() ?? row['pan']?.toString()
            ..status = 'active'
            ..createdAt = DateTime.now().toIso8601String()
            ..updatedAt = DateTime.now()
            ..isDeleted = false;

          await _dealerRepository.saveDealer(entity);
          importedCount++;
        } catch (e) {
          debugPrint('Error importing row: $e');
          errorCount++;
        }
      }

      return {
        'success': true,
        'message':
            'Successfully imported $importedCount dealers. Errors: $errorCount',
        'count': importedCount,
      };
    } catch (e) {
      return {'success': false, 'message': 'Import failed: $e'};
    }
  }

  Future<List<Map<String, dynamic>>> _parseExcel(PlatformFile file) async {
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    List<Map<String, dynamic>> results = [];

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.maxRows <= 1) continue;

      final headerRow = sheet.rows[0];
      final headers = headerRow
          .map((cell) => cell?.value?.toString().trim() ?? '')
          .toList();

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        Map<String, dynamic> rowData = {};
        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) {
            rowData[headers[j]] = row[j]?.value;
          }
        }
        results.add(rowData);
      }
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> _parseCSV(PlatformFile file) async {
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final csvString = utf8.decode(bytes);
    final List<List<dynamic>> rows = const CsvToListConverter().convert(
      csvString,
    );

    if (rows.isEmpty) return [];

    final headers = rows[0].map((e) => e.toString().trim()).toList();
    List<Map<String, dynamic>> results = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      Map<String, dynamic> rowData = {};
      for (int j = 0; j < headers.length; j++) {
        if (j < row.length) {
          rowData[headers[j]] = row[j];
        }
      }
      results.add(rowData);
    }
    return results;
  }
}
