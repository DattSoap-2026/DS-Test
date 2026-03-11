import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'base_service.dart';
import 'database_service.dart';
// Entity imports removed as they were unused

// Add other entity imports as needed for casting, though dynamic is easier for generic export

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;

enum BackupSource { local, firebase }

// List of logical collections to backup
// These keys must map to both Firestore collections and Isar collections where applicable.
const List<String> collectionsToBackup = [
  'users',
  'products',
  'raw_materials', // Firestore only? Check Isar
  'customers',
  'dealers',
  'sales',
  'production_logs', // Maps to productionEntries in Isar?
  'production_targets',
  'detailed_production_logs',
  'maintenance_logs',
  'diesel_logs',
  'tyre_logs',
  'vehicles', // tank_entity? Or vehicle_maintenance?
  'purchase_orders',
  'returns',
  'settings',
  'formulas',
  'sales_targets',
  'schemes',
  'custom_roles',
  // Local specific additions can be handled or mapped
  'bhatti_entries', // bhattiDailyEntryEntitys
  'stock_ledger',
];

class BackupData {
  final String version;
  final String timestamp;
  final Map<String, Map<String, dynamic>> firebaseData;
  final Map<String, List<Map<String, dynamic>>> localData;

  BackupData({
    required this.version,
    required this.timestamp,
    this.firebaseData = const {},
    this.localData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'timestamp': timestamp,
      'firebase': firebaseData,
      'local': localData,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    // Handle legacy format where 'collections' was the root for firebase data
    Map<String, Map<String, dynamic>> firebase = {};
    if (json.containsKey('collections')) {
      firebase = (json['collections'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    } else if (json.containsKey('firebase')) {
      firebase = (json['firebase'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    }

    Map<String, List<Map<String, dynamic>>> local = {};
    if (json.containsKey('local')) {
      local = (json['local'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => Map<String, dynamic>.from(e)).toList(),
        ),
      );
    }

    return BackupData(
      version: json['version'] as String? ?? '1.0',
      timestamp:
          json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      firebaseData: firebase,
      localData: local,
    );
  }
}

class BackupService extends BaseService {
  BackupService(super.firebase);

  /// Creates a backup from selected sources
  Future<BackupData> createFullBackup({
    required List<BackupSource> sources,
    Function(int current, int total, String message)? onProgress,
  }) async {
    Map<String, Map<String, dynamic>> firebaseData = {};
    Map<String, List<Map<String, dynamic>>> localData = {};

    // Estimate total steps: 1 per collection per source
    int totalSteps = 0;
    if (sources.contains(BackupSource.firebase)) {
      totalSteps += collectionsToBackup.length;
    }
    if (sources.contains(BackupSource.local)) {
      totalSteps += _getLocalCollectionNames().length;
    }

    int currentStep = 0;

    try {
      // 1. Firebase Backup
      if (sources.contains(BackupSource.firebase)) {
        final firestore = db;
        if (firestore == null) throw Exception("Firestore not initialized");

        for (final collectionName in collectionsToBackup) {
          if (onProgress != null) {
            onProgress(currentStep, totalSteps, 'Firebase: $collectionName...');
          }

          try {
            final querySnapshot = await firestore
                .collection(collectionName)
                .get();
            final Map<String, dynamic> docs = {};
            for (var doc in querySnapshot.docs) {
              docs[doc.id] = doc.data();
            }
            firebaseData[collectionName] = docs;
          } catch (e) {
            developer.log('Failed backup firebase $collectionName', error: e);
            firebaseData[collectionName] = {
              '_error': {'message': e.toString()},
            };
          }
          currentStep++;
        }
      }

      // 2. Local Backup
      if (sources.contains(BackupSource.local)) {
        final dbService = DatabaseService.instance;
        // Ensure initialized? It usually is, but just in case
        // await dbService.init(); // Assuming it's already init in main

        final localMap = _getLocalCollectionMap(dbService);

        for (final entry in localMap.entries) {
          if (onProgress != null) {
            onProgress(currentStep, totalSteps, 'Local: ${entry.key}...');
          }

          try {
            // Export to JSON
            final jsonList = await entry.value.where().exportJson();
            localData[entry.key] = jsonList;
          } catch (e) {
            developer.log('Failed backup local ${entry.key}', error: e);
            // We can't really store error in list easily without breaking schema expectation
          }
          currentStep++;
        }
      }

      if (onProgress != null) {
        onProgress(totalSteps, totalSteps, 'Backup Complete!');
      }

      return BackupData(
        version: '2.0',
        timestamp: DateTime.now().toIso8601String(),
        firebaseData: firebaseData,
        localData: localData,
      );
    } catch (e) {
      throw handleError(e, 'createBackup');
    }
  }

  /// Restores data to selected targets
  Future<void> restoreBackup(
    BackupData backupData, {
    required List<BackupSource> targets,
    Function(int current, int total, String message)? onProgress,
  }) async {
    int totalSteps = 0;
    if (targets.contains(BackupSource.firebase)) {
      backupData.firebaseData.forEach(
        (_, docs) => totalSteps += (docs.length / 450).ceil(),
      );
    }
    if (targets.contains(BackupSource.local)) {
      totalSteps += backupData.localData.length;
    }

    int currentStep = 0;

    try {
      // 1. Restore Firebase
      if (targets.contains(BackupSource.firebase)) {
        final firestore = db;
        if (firestore != null) {
          const int batchSize = 450;

          for (var entry in backupData.firebaseData.entries) {
            final collectionName = entry.key;
            final docs = entry.value;

            final docEntries = docs.entries.toList();

            for (int i = 0; i < docEntries.length; i += batchSize) {
              final batch = firestore.batch();
              final end = (i + batchSize < docEntries.length)
                  ? i + batchSize
                  : docEntries.length;
              final chunk = docEntries.sublist(i, end);

              for (var docEntry in chunk) {
                // Skip errors or metadata if strictly data
                if (docEntry.key == '_error') {
                  continue;
                }

                final docRef = firestore
                    .collection(collectionName)
                    .doc(docEntry.key);
                batch.set(docRef, docEntry.value, SetOptions(merge: true));
              }

              await batch.commit();
              currentStep++;
              if (onProgress != null) {
                onProgress(
                  currentStep,
                  totalSteps,
                  'Restoring Fire: $collectionName...',
                );
              }
            }
          }
        }
      }

      // 2. Restore Local
      if (targets.contains(BackupSource.local)) {
        final dbService = DatabaseService.instance;
        final localMap = _getLocalCollectionMap(dbService);

        for (var entry in backupData.localData.entries) {
          final collectionName = entry.key;
          final jsonList = entry.value;

          if (!localMap.containsKey(collectionName)) {
            developer.log('Skipping unknown local collection: $collectionName');
            continue;
          }

          final collection = localMap[collectionName]!;

          if (onProgress != null) {
            onProgress(
              currentStep,
              totalSteps,
              'Restoring Local: $collectionName...',
            );
          }

          // Import JSON
          await dbService.db.writeTxn(() async {
            // We use importJson. By default it upserts based on ID.
            await collection.importJson(jsonList);
          });

          currentStep++;
        }
      }
    } catch (e) {
      throw handleError(e, 'restoreBackup');
    }
  }

  // Helpers

  Map<String, IsarCollection<dynamic>> _getLocalCollectionMap(
    DatabaseService s,
  ) {
    // Map logical names to IsarCollections
    return {
      'users': s.users,
      'products': s.products,
      'customers': s.customers,
      'dealers': s.dealers,
      'sales': s.sales,
      'returns': s.returns,
      'production_entries': s.productionEntries,
      'bhatti_entries': s.bhattiEntries,
      'tanks': s.tanks,
      'tank_transactions': s.tankTransactions,
      'stock_ledger': s.stockLedgers,
      'department_stocks': s.departmentStocks,
      'production_targets': s.productionTargets,
      'detailed_production_logs': s.detailedProductionLogs,
      'duty_sessions': s.dutySessions,
      'employees': s.employees,
      'audit_logs': s.auditLogs,
      'routes_sessions': s.routeSessions,
      'customer_visits': s.customerVisits,
      'opening_stocks': s.openingStocks,
      // Add others as needed
    };
  }

  List<String> _getLocalCollectionNames() =>
      _getLocalCollectionMap(DatabaseService.instance).keys.toList();

  /// Saves backup data to a JSON file
  Future<String?> saveBackupToFile(BackupData data) async {
    try {
      final jsonStr = jsonEncode(data.toJson());
      final String fileName =
          'datt_erp_backup_v2_${DateTime.now().toIso8601String().split('T')[0]}.json';

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(jsonStr);
          return outputFile;
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonStr);
        return file.path;
      }
      return null;
    } catch (e) {
      throw handleError(e, 'saveBackupToFile');
    }
  }

  /// Picks and reads a backup file
  Future<BackupData?> pickBackupFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return BackupData.fromJson(json);
      }
      return null;
    } catch (e) {
      developer.log('Error picking/reading backup file', error: e);
      rethrow;
    }
  }
}
