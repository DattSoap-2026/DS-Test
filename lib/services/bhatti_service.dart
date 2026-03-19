import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import 'dart:convert';
import 'offline_first_service.dart';
import 'database_service.dart';
import 'inventory_service.dart';
import '../data/local/entities/bhatti_batch_entity.dart';
import '../data/local/entities/department_stock_entity.dart';
import '../data/local/entities/wastage_log_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/base_entity.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'outbox_codec.dart';
import 'delegates/firestore_query_delegate.dart';

import 'tank_service.dart';
import 'inventory_movement_engine.dart';
import 'department_master_service.dart';
import 'bom/bom_validation_service.dart';
import 'bom/formula_repository.dart';

const bhattiBatchesCollection = 'bhatti_batches';
const wastageLogsCollection = 'wastage_logs';
const departmentStocksCollection = 'department_stocks';
const productsCollection = 'products';
const bhattiOutputRulesCollection = 'public_settings';
const bhattiOutputRulesDocId = 'bhatti_output_rules';

// Models
class BhattiBatch {
  final String id;
  final String bhattiName;
  final String batchNumber;
  final String targetProductId;
  final String targetProductName;
  final int batchCount;
  final int outputBoxes;
  final String supervisorId;
  final String supervisorName;
  final String status; // 'cooking', 'completed'
  final List<Map<String, dynamic>> rawMaterialsConsumed;
  final List<Map<String, dynamic>> tankConsumptions;
  final double totalBatchCost;
  final double costPerBox;
  final String issueId;
  final String createdAt;
  final String updatedAt;

  BhattiBatch({
    required this.id,
    required this.bhattiName,
    required this.batchNumber,
    required this.targetProductId,
    required this.targetProductName,
    required this.batchCount,
    required this.outputBoxes,
    required this.supervisorId,
    required this.supervisorName,
    required this.status,
    required this.rawMaterialsConsumed,
    required this.tankConsumptions,
    required this.totalBatchCost,
    required this.costPerBox,
    required this.issueId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BhattiBatch.fromJson(Map<String, dynamic> json) {
    return BhattiBatch(
      id: json['id'] as String,
      bhattiName: json['bhattiName'] as String,
      batchNumber: json['batchNumber'] as String,
      targetProductId: json['targetProductId'] as String,
      targetProductName: json['targetProductName'] as String,
      batchCount: (json['batchCount'] as num).toInt(),
      outputBoxes: (json['outputBoxes'] as num).toInt(),
      supervisorId: json['supervisorId'] as String,
      supervisorName: json['supervisorName'] as String,
      status: json['status'] as String,
      rawMaterialsConsumed: List<Map<String, dynamic>>.from(
        json['rawMaterialsConsumed'] ?? [],
      ),
      tankConsumptions: List<Map<String, dynamic>>.from(
        json['tankConsumptions'] ?? [],
      ),
      totalBatchCost: (json['totalBatchCost'] as num?)?.toDouble() ?? 0.0,
      costPerBox: (json['costPerBox'] as num?)?.toDouble() ?? 0.0,
      issueId: json['issueId'] as String? ?? '',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bhattiName': bhattiName,
      'batchNumber': batchNumber,
      'targetProductId': targetProductId,
      'targetProductName': targetProductName,
      'batchCount': batchCount,
      'outputBoxes': outputBoxes,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'status': status,
      'rawMaterialsConsumed': rawMaterialsConsumed,
      'tankConsumptions': tankConsumptions,
      'totalBatchCost': totalBatchCost,
      'costPerBox': costPerBox,
      'issueId': issueId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class DepartmentStock {
  final String id;
  final String departmentName;
  final String productId;
  final String productName;
  final double stock;
  final String unit;

  DepartmentStock({
    required this.id,
    required this.departmentName,
    required this.productId,
    required this.productName,
    required this.stock,
    required this.unit,
  });

  factory DepartmentStock.fromJson(Map<String, dynamic> json) {
    return DepartmentStock(
      id: json['id'] as String,
      departmentName: json['departmentName'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      stock: (json['stock'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}

/// [BhattiService] manages production cycles (batches) at the Bhatti (furnace) level.
///
/// It handles:
/// - Creating and completing bhatti batches.
/// - Tracking ingredient consumption (raw materials and tank-based liquids).
/// - Managing departmental stock within the Bhatti area.
/// - Logging wastage and reusable by-products.
class BhattiService extends OfflineFirstService {
  final TankService _tankService;
  final DatabaseService _dbService;
  final InventoryService _inventoryService;
  final InventoryMovementEngine _inventoryMovementEngine;
  final BomValidationService _bomValidationService;
  final FormulaRepository _formulaRepository;
  Future<void> Function()? _centralQueueSync;
  bool _bhattiPermissionDenied = false;

  BhattiService(
    super._firebase,
    this._dbService,
    this._tankService,
    this._inventoryService,
    this._inventoryMovementEngine,
  ) : _bomValidationService = BomValidationService(),
      _formulaRepository = FormulaRepository();

  @override
  String get localStorageKey => 'bhatti_batches';

  static const String _outputRulesLocalKey = 'local_bhatti_output_rules';

  void bindCentralQueueSync(Future<void> Function() callback) {
    _centralQueueSync = callback;
  }

  Future<void> _enqueueSyncCommand({
    required String queueId,
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final commandPayload = OutboxCodec.ensureCommandPayload(
      collection: collection,
      action: action,
      payload: payload,
      queueId: queueId,
    );
    final documentId = payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) return;
    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: commandPayload,
    );
    if (_centralQueueSync != null) {
      await _centralQueueSync!.call();
    }
  }

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) => super.performSync(action, collection, data);

  Map<String, int> _defaultOutputRules() => const {'sona': 6, 'gita': 7};

  String _normalizeBhattiKey(String bhattiName) {
    final normalized = bhattiName.toLowerCase();
    if (normalized.contains('gita')) return 'gita';
    if (normalized.contains('sona')) return 'sona';
    return 'sona';
  }

  Map<String, int> _sanitizeOutputRules(Map<String, dynamic> source) {
    final defaults = _defaultOutputRules();

    int parseRule(dynamic value, int fallback) {
      if (value is num && value > 0) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null && parsed > 0) return parsed;
      }
      return fallback;
    }

    return {
      'sona': parseRule(
        source['sona'] ?? source['sonaBoxesPerBatch'],
        defaults['sona']!,
      ),
      'gita': parseRule(
        source['gita'] ?? source['gitaBoxesPerBatch'],
        defaults['gita']!,
      ),
    };
  }

  int getOutputBoxesPerBatchForBhatti(
    String bhattiName, {
    required Map<String, int> rules,
  }) {
    final key = _normalizeBhattiKey(bhattiName);
    final defaults = _defaultOutputRules();
    return rules[key] ?? defaults[key]!;
  }

  Future<Map<String, int>> getOutputBoxesRules({
    bool forceRefresh = false,
  }) async {
    final defaults = _defaultOutputRules();
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(_outputRulesLocalKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final decoded = jsonDecode(cached);
          if (decoded is Map) {
            return _sanitizeOutputRules(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {
          // Ignore corrupted cache and continue with remote/default.
        }
      }
    }

    final firestore = db;
    if (firestore != null) {
      try {
        final doc = await firestore
            .collection(bhattiOutputRulesCollection)
            .doc(bhattiOutputRulesDocId)
            .get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            final rules = _sanitizeOutputRules(Map<String, dynamic>.from(data));
            await prefs.setString(_outputRulesLocalKey, jsonEncode(rules));
            return rules;
          }
        }
      } catch (_) {
        // Remote fetch is best-effort.
      }
    }

    await prefs.setString(_outputRulesLocalKey, jsonEncode(defaults));
    return defaults;
  }

  Future<bool> updateOutputBoxesRules({
    required int sonaBoxesPerBatch,
    required int gitaBoxesPerBatch,
    required String updatedBy,
  }) async {
    try {
      if (sonaBoxesPerBatch <= 0 || gitaBoxesPerBatch <= 0) {
        throw Exception('Boxes per batch must be greater than zero');
      }

      final rules = {'sona': sonaBoxesPerBatch, 'gita': gitaBoxesPerBatch};
      final payload = <String, dynamic>{
        'id': bhattiOutputRulesDocId,
        'sona': sonaBoxesPerBatch,
        'gita': gitaBoxesPerBatch,
        'sonaBoxesPerBatch': sonaBoxesPerBatch,
        'gitaBoxesPerBatch': gitaBoxesPerBatch,
        'updatedBy': updatedBy,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_outputRulesLocalKey, jsonEncode(rules));

      await syncToFirebase(
        'set',
        payload,
        collectionName: bhattiOutputRulesCollection,
      );
      return true;
    } catch (e) {
      handleError(e, 'updateOutputBoxesRules');
      return false;
    }
  }

  Future<List<BhattiBatch>> getBhattiBatches({
    String? status,
    String? bhattiName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_bhattiPermissionDenied) return [];
    try {
      // 1. Load from Local (Optimized Isar)
      List<BhattiBatchEntity> localBatches;

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      if (bhattiName != null && bhattiName.trim().isNotEmpty) {
        localBatches = await _dbService.bhattiBatches
            .filter()
            .createdAtBetween(start, end)
            .and()
            .bhattiNameContains(bhattiName.trim(), caseSensitive: false)
            .findAll();
      } else {
        localBatches = await _dbService.bhattiBatches
            .filter()
            .createdAtBetween(start, end)
            .findAll();
      }

      localBatches = localBatches.where((batch) {
        if (batch.isDeleted) return false;
        if (status != null && batch.status != status) return false;
        // bhattiName filter already applied in Isar query
        return true;
      }).toList();

      localBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (localBatches.isNotEmpty) {
        final batches = localBatches.map((e) => e.toDomain()).toList();
        // DEDUPLICATE to prevent duplicate batches in UI
        return deduplicate(batches, (b) => b.id);
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return [];

      fs.Query fQuery = firestore
          .collection(bhattiBatchesCollection)
          .orderBy('createdAt', descending: true);

      if (startDate != null) {
        fQuery = fQuery.where(
          'createdAt',
          isGreaterThanOrEqualTo: startDate.toIso8601String(),
        );
      }
      if (endDate != null) {
        // Handle end of day
        final eod = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        fQuery = fQuery.where(
          'createdAt',
          isLessThanOrEqualTo: eod.toIso8601String(),
        );
      }

      if (status != null) {
        fQuery = fQuery.where('status', isEqualTo: status);
      }
      if (bhattiName != null) {
        fQuery = fQuery.where('bhattiName', isEqualTo: bhattiName);
      }

      final snapshot = await fQuery.get();
      final remoteBatchesData = snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return data;
          })
          .where((data) => data['isDeleted'] != true)
          .toList();

      // Save to local
      await _dbService.db.writeTxn(() async {
        for (var data in remoteBatchesData) {
          final entity = BhattiBatchEntity.fromFirebaseJson(data);
          await _dbService.bhattiBatches.put(entity);
        }
      });

      final remoteBatches = remoteBatchesData
          .map((d) => BhattiBatch.fromJson(d))
          .toList();
      // DEDUPLICATE remote batches
      return deduplicate(remoteBatches, (b) => b.id);
    } on fs.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _bhattiPermissionDenied = true;
        return [];
      }
      throw handleError(e, 'getBhattiBatches');
    } catch (e) {
      throw handleError(e, 'getBhattiBatches');
    }
  }

  Future<List<DepartmentStock>> getDepartmentStocks(
    String departmentName,
  ) async {
    try {
      // 1. Load from Local
      final localStocks = await _dbService.departmentStocks
          .filter()
          .departmentNameEqualTo(departmentName)
          .findAll();

      if (localStocks.isNotEmpty) {
        return localStocks
            .where((e) => !e.isDeleted)
            .map((e) => e.toDomain())
            .toList();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(departmentStocksCollection)
          .where('departmentName', isEqualTo: departmentName)
          .get();

      final remoteData = snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return data;
          })
          .where((data) => data['isDeleted'] != true)
          .toList();

      // Save to local
      await _dbService.db.writeTxn(() async {
        for (var data in remoteData) {
          final entity = DepartmentStockEntity.fromFirebaseJson(data);
          await _dbService.departmentStocks.put(entity);
        }
      });

      return remoteData.map((d) => DepartmentStock.fromJson(d)).toList();
    } catch (e) {
      throw handleError(e, 'getDepartmentStocks');
    }
  }

  Future<List<Map<String, dynamic>>> getWastageLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? bhattiName,
  }) async {
    try {
      // 1. Offline-First: Load from Isar
      // Note: We need to query WastageLogEntity
      List<WastageLogEntity> localLogs;

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      var query = _dbService.wastageLogs.filter().isDeletedEqualTo(false);

      if (bhattiName != null && bhattiName.isNotEmpty) {
        query = query.and().returnedToContains(
          bhattiName,
          caseSensitive: false,
        );
      }

      query = query.and().createdAtBetween(start, end);
      localLogs = await query.findAll();

      localLogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (localLogs.isNotEmpty) {
        return localLogs.map((e) => e.toFirebaseJson()).toList();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return [];

      fs.Query fQuery = firestore.collection(wastageLogsCollection);

      if (bhattiName != null && bhattiName.isNotEmpty) {
        fQuery = fQuery.where('returnedTo', isEqualTo: bhattiName);
      }

      fQuery = fQuery.orderBy('createdAt', descending: true);

      if (startDate != null) {
        fQuery = fQuery.where(
          'createdAt',
          isGreaterThanOrEqualTo: startDate.toIso8601String(),
        );
      }
      if (endDate != null) {
        final eod = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        fQuery = fQuery.where(
          'createdAt',
          isLessThanOrEqualTo: eod.toIso8601String(),
        );
      }

      final snapshot = await fQuery.get();
      final remoteData = snapshot.docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            data['id'] = doc.id;
            return data;
          })
          .where((data) => data['isDeleted'] != true)
          .toList();

      // Save to local
      await _dbService.db.writeTxn(() async {
        for (var data in remoteData) {
          final entity = WastageLogEntity.fromFirebaseJson(data);
          await _dbService.wastageLogs.put(entity);
        }
      });

      return remoteData;
    } catch (e) {
      throw handleError(e, 'getWastageLogs');
    }
  }

  // NOTE: Logic for calculating formula consumption moved to UI/Provider or helper method.
  // Here we expect the `rawMaterialsConsumed` list to be already calculated and passed.

  /// Creates a new production batch (Bhatti Batch) in its 'cooking' phase.
  ///
  /// This method performs critical stock validation and consumption logic:
  /// 1. Validates local departmental stock for all ingredients.
  /// 2. Deducts liquid ingredients from specified tanks (via [TankService]).
  /// 3. Deducts solid raw materials from the departmental stock.
  /// 4. Logs wastage/reusable materials if provided.
  /// 5. Saves a 'pending' batch entity for background synchronization.
  Future<bool> createBhattiBatch({
    required String bhattiName,
    required String targetProductId,
    required String targetProductName,
    required int batchCount,
    required int outputBoxes,
    required String supervisorId,
    required String supervisorName,
    required List<Map<String, dynamic>> rawMaterialsConsumed,
    List<Map<String, dynamic>>? tankConsumptions,
    double? wastageReusableQty,
    double? wastageLossQty,
    String? wastageMaterialId,
  }) async {
    // BUG 5 FIX: Normalize department name to avoid case-sensitive duplicates in Isar.
    final normalizedBhattiName = bhattiName.trim().toLowerCase();

    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final prefix = (bhattiName.toLowerCase().contains('gita')) ? 'GB' : 'SB';
      final batchId = generateId();

      await _dbService.db.writeTxn(() async {
        // 1. Generate Batch Number (Local Sequence)
        final batchNumber =
            "$prefix-$dateStr-${now.millisecondsSinceEpoch.toString().substring(10)}";

        // 1.1 Strict Local Stock Validation (Offline Safety)
        for (var material in rawMaterialsConsumed) {
          final mId = material['materialId'] ?? material['rawMaterialId'];
          final qty = (material['quantity'] as num).toDouble();
          final mName =
              material['materialName'] ??
              material['name'] ??
              'Unknown Material';

          // Skip water - it's not tracked in inventory
          if (mName.toLowerCase().trim() == 'water') {
            continue;
          }

          // Skip if tank sourced (TankService handles its own validation)
          final tankCons = tankConsumptions?.where(
            (tc) => tc['materialId'] == mId,
          );
          if (tankCons != null &&
              tankCons.isNotEmpty &&
              (tankCons.first['quantity'] as num) > 0) {
            continue;
          }

          // BUG 5 FIX: Use normalizedBhattiName for case-insensitive matching
          final stockEntity = await _dbService.departmentStocks
              .filter()
              .departmentNameEqualTo(normalizedBhattiName)
              .and()
              .productIdEqualTo(mId)
              .findFirst();

          final currentStock = stockEntity?.stock ?? 0.0;
          if (currentStock < qty) {
            throw Exception(
              "Insufficient stock for $mName.\nRequired: $qty\nAvailable: $currentStock",
            );
          }
        }

        // 2. Decrement Dept Stock & Costing
        double totalBatchCost = 0;
        final List<Map<String, dynamic>> finalTankConsumptions = [];

        for (var material in rawMaterialsConsumed) {
          final mId = material['materialId'] ?? material['rawMaterialId'];
          final qty = (material['quantity'] as num).toDouble();
          final mName =
              material['materialName'] ??
              material['name'] ??
              'Unknown Material';

          // Skip water - it's not tracked in inventory
          if (mName.toLowerCase().trim() == 'water') {
            continue;
          }

          // Simple local costing (average cost from local product entity)
          final productEntity = await _dbService.products.get(fastHash(mId));
          final price = productEntity?.price ?? 0.0;
          totalBatchCost += (price * qty);

          // Check if tank sourced
          final tankCons = tankConsumptions?.where(
            (tc) => tc['materialId'] == mId,
          );
          if (tankCons != null &&
              tankCons.isNotEmpty &&
              (tankCons.first['quantity'] as num) > 0) {
            final tQty = (tankCons.first['quantity'] as num).toDouble();

            // Calculate consumption logic (pure, no side effects yet)
            final consumptionResult = await _tankService.calculateConsumption(
              tankId: tankCons.first['tankId'],
              quantity: tQty,
              referenceId: batchId,
              operatorId: supervisorId,
              operatorName: supervisorName,
            );

            // Save Tank Entities (Atomic with Bhatti Batch)
            await _dbService.tanks.put(consumptionResult.tank);
            await _dbService.tankTransactions.put(
              consumptionResult.transaction,
            );
            for (var lot in consumptionResult.lots) {
              await _dbService.tankLots.put(lot);
            }

            finalTankConsumptions.add(consumptionResult.summary);
          } else {
            // Stock has been validated. The central engine handles ledger and deductions.
          }
        }

        // 2.5 Prepare consumptions list for MovementEngine
        final List<InventoryCommandItem> consumptionsList = [];
        for (var material in rawMaterialsConsumed) {
          final mId = material['materialId'] ?? material['rawMaterialId'];
          final qty = (material['quantity'] as num).toDouble();
          final mName =
              material['materialName'] ??
              material['name'] ??
              'Unknown Material';

          // Skip tank-sourced or water
          final tankCons = tankConsumptions?.where(
            (tc) => tc['materialId'] == mId,
          );
          if (mName.toLowerCase().trim() == 'water') continue;
          if (tankCons != null &&
              tankCons.isNotEmpty &&
              (tankCons.first['quantity'] as num) > 0) {
            continue;
          }

          consumptionsList.add(
            InventoryCommandItem(productId: mId, quantityBase: qty),
          );
        }

        // Calculate output KG
        final product = await _dbService.products.get(
          fastHash(targetProductId),
        );
        final boxWeightKg = ((product?.unitWeightGrams ?? 0) > 0)
            ? (product!.unitWeightGrams! / 1000)
            : 1.0;
        final outputQtyKg = outputBoxes * boxWeightKg;

        final List<InventoryCommandItem> outputsList = [
          InventoryCommandItem(
            productId: targetProductId,
            quantityBase: outputQtyKg,
          ),
        ];

        // 3. Handle Wastage (Migrated to Movement Engine)
        if (wastageReusableQty != null &&
            wastageReusableQty > 0 &&
            wastageMaterialId != null) {
          outputsList.add(
            InventoryCommandItem(
              productId: wastageMaterialId,
              quantityBase: wastageReusableQty,
            ),
          );
        }

        final bhattiLocationId =
            DepartmentMasterService(
              _dbService,
            ).resolveCanonicalDepartmentId(normalizedBhattiName) ??
            'dept_${normalizedBhattiName.replaceAll(' ', '_')}';
        final command = InventoryCommand.bhattiProductionComplete(
          batchId: batchId,
          consumptionLocationId: bhattiLocationId,
          outputLocationId: bhattiLocationId,
          consumptions: consumptionsList,
          outputs: outputsList,

          actorUid: supervisorId,
          createdAt: now,
        );

        await _inventoryMovementEngine.applyCommand(command);

        // BOM Validation (Warning Mode - Phase 2)
        final formula = _formulaRepository.getFormula(targetProductId);
        if (formula != null) {
          final actualInputs = <String, double>{};
          for (var material in rawMaterialsConsumed) {
            final mId = material['materialId'] ?? material['rawMaterialId'];
            final qty = (material['quantity'] as num).toDouble();
            actualInputs[mId] = qty;
          }

          final actualOutputs = {targetProductId: outputQtyKg};
          if (wastageReusableQty != null &&
              wastageReusableQty > 0 &&
              wastageMaterialId != null) {
            actualOutputs[wastageMaterialId] = wastageReusableQty;
          }

          final validationResult = _bomValidationService.validateBatch(
            formula: formula,
            actualInputs: actualInputs,
            actualOutputs: actualOutputs,
            tolerancePercent: 5.0,
          );

          if (!validationResult.isValid) {
            debugPrint(
              '[BOM WARNING] Batch $batchId: ${validationResult.message}',
            );
          } else {
            debugPrint(
              '[BOM OK] Batch $batchId: ${validationResult.yieldPercent?.toStringAsFixed(1)}% yield',
            );
          }
        }

        // 4. Save Bhatti Batch Entity
        final costPerBox = outputBoxes > 0 ? totalBatchCost / outputBoxes : 0.0;
        final batchEntity = BhattiBatchEntity()
          ..id = batchId
          ..bhattiName = normalizedBhattiName
          ..batchNumber = batchNumber
          ..targetProductId = targetProductId
          ..targetProductName = targetProductName
          ..batchCount = batchCount
          ..outputBoxes = outputBoxes
          ..supervisorId = supervisorId
          ..supervisorName = supervisorName
          ..status = 'completed'
          ..rawMaterialsConsumed = rawMaterialsConsumed
              .map((e) => ConsumedItem.fromJson(e))
              .toList()
          ..tankConsumptions = finalTankConsumptions
              .map((e) => TankConsumptionItem.fromJson(e))
              .toList()
          ..totalBatchCost = totalBatchCost
          ..costPerBox = costPerBox
          ..createdAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;

        await _dbService.bhattiBatches.put(batchEntity);
      });

      // 5. Queue for Firebase Sync
      final bhattiData = await BhattiBatchEntityQueryWhere(
        _dbService.bhattiBatches.where(),
      ).idEqualTo(batchId).findFirst();
      if (bhattiData != null) {
        await _enqueueSyncCommand(
          queueId: 'bhatti_batch_create_$batchId',
          collection: bhattiBatchesCollection,
          action: 'add',
          payload: bhattiData.toFirebaseJson(),
        );
      }

      return true;
    } catch (e) {
      throw handleError(e, 'createBhattiBatch');
    }
  }

  Future<bool> completeBhattiBatch({
    required String batchId,
    required int outputBoxes, // If changed
  }) async {
    try {
      final now = DateTime.now();

      await _dbService.db.writeTxn(() async {
        // 1. Fetch Batch
        final batchEntity = await _dbService.bhattiBatches.get(
          fastHash(batchId),
        );

        if (batchEntity == null) {
          throw Exception("Batch not found locally: $batchId");
        }

        if (batchEntity.status == 'completed') {
          batchEntity.updatedAt = now;
          batchEntity.syncStatus = SyncStatus.pending;
          await _dbService.bhattiBatches.put(batchEntity);
          return;
        }

        // 2. Update Batch Status
        batchEntity.status = 'completed';
        batchEntity.outputBoxes = outputBoxes;
        batchEntity.updatedAt = now;
        batchEntity.syncStatus = SyncStatus.pending;

        await _dbService.bhattiBatches.put(batchEntity);

        // 3. Update Main Product Stock & Avg Cost
        // Note: The actual stock output and ledger entry for the output
        // were already handled in `createBhattiBatch` via the InventoryMovementEngine.
        // We only update the batch document status here.

        await _dbService.bhattiBatches.put(batchEntity);

        // 4.5 Create Stock Ledger Entry for Production Output (Audit Trail)
        // BUG 1 FIX: Use KG quantity and 'Kg' unit; BUG 5 FIX: normalized dept name
        // This section is now obsolete as the InventoryMovementEngine handles ledger entries.
      });

      // 5. Queue for Sync
      final updatedBatch = await _dbService.bhattiBatches.get(
        fastHash(batchId),
      );
      if (updatedBatch != null) {
        await _enqueueSyncCommand(
          queueId: 'bhatti_batch_complete_$batchId',
          collection: bhattiBatchesCollection,
          action: 'update',
          payload: updatedBatch.toFirebaseJson(),
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'completeBhattiBatch');
      return false;
    }
  }

  Future<bool> addWastageLog({
    required String returnedTo, // department
    required String productId,
    required String productName,
    required double quantity,
    required String unit,
    required String reason,
    required String reportedBy,
  }) async {
    // BUG 5 FIX: Normalize returnedTo (department) for consistent Isar key matching
    final normalizedReturnedTo = returnedTo.trim().toLowerCase();

    try {
      final now = DateTime.now();
      final logId = generateId();

      await _dbService.db.writeTxn(() async {
        // 1. Save Log Locally
        final logEntity = WastageLogEntity()
          ..id = logId
          ..returnedTo = normalizedReturnedTo
          ..productId = productId
          ..productName = productName
          ..quantity = quantity
          ..unit = unit
          ..reason = reason
          ..reportedBy = reportedBy
          ..createdAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;

        await _dbService.wastageLogs.put(logEntity);

        // 2. Increment Dept Stock (return) — using InventoryMovementEngine
        final bhattiLocationId =
            DepartmentMasterService(
              _dbService,
            ).resolveCanonicalDepartmentId(normalizedReturnedTo) ??
            'dept_${normalizedReturnedTo.replaceAll(' ', '_')}';

        final command = InventoryCommand.departmentReturn(
          departmentLocationId: bhattiLocationId,
          referenceId: logId,
          productId: productId,
          quantityBase: quantity,
          actorUid: reportedBy,
          reasonCode: 'wastage_return_to_store',
          createdAt: now,
        );

        await _inventoryMovementEngine.applyCommand(command);
      });

      // 3. Queue for Sync
      final logData = await _dbService.wastageLogs.get(fastHash(logId));
      if (logData != null) {
        await _enqueueSyncCommand(
          queueId: 'bhatti_wastage_$logId',
          collection: wastageLogsCollection,
          action: 'add',
          payload: logData.toFirebaseJson(),
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'addWastageLog');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyEntries({
    required DateTime startDate,
    required DateTime endDate,
    String? bhattiName,
  }) async {
    try {
      final firestore = db;
      // BUG 3 FIX: Previously returned [] only due to null check — safe offline
      // behavior: return empty list rather than crashing.
      if (firestore == null) {
        debugPrint(
          '[BhattiService] getDailyEntries: offline, returning empty list.',
        );
        return [];
      }

      final filters = <FirestoreQueryFilter>[
        FirestoreQueryFilter(
          field: 'date',
          operator: FirestoreQueryOperator.isGreaterThanOrEqualTo,
          value: startDate.toIso8601String().split('T')[0],
        ),
        FirestoreQueryFilter(
          field: 'date',
          operator: FirestoreQueryOperator.isLessThanOrEqualTo,
          value: endDate.toIso8601String().split('T')[0],
        ),
        if (bhattiName != null)
          FirestoreQueryFilter(
            field: 'bhattiName',
            operator: FirestoreQueryOperator.isEqualTo,
            value: bhattiName,
          ),
      ];
      final snapshot = await FirestoreQueryDelegate(firestore).getCollection(
        collection: 'bhatti_daily_entries',
        filters: filters,
      );
      return snapshot.docs
          .map((doc) => doc.data())
          .where((data) => data['isDeleted'] != true)
          .toList();
    } catch (e) {
      // BUG 3 FIX: Return empty list on any error (including network errors) instead of rethrowing.
      debugPrint('[BhattiService] getDailyEntries error: $e');
      return [];
    }
  }

  Future<void> saveDailyEntry(Map<String, dynamic> entryData) async {
    try {
      final firestore = db;
      // BUG 3 FIX: Previously threw 'Offline' as a raw exception causing UI crash.
      // Now log and return silently — caller UI should show a snackbar if needed.
      if (firestore == null) {
        debugPrint(
          '[BhattiService] saveDailyEntry: offline, entry not persisted to Firestore.',
        );
        return;
      }

      await _enqueueSyncCommand(
        queueId: 'bhatti_daily_entry_${entryData['id']}',
        collection: 'bhatti_daily_entries',
        action: 'set',
        payload: entryData,
      );
    } catch (e) {
      throw handleError(e, 'saveBhattiDailyEntry');
    }
  }

  Future<BhattiBatch?> getBhattiBatchById(String batchId) async {
    try {
      // 1. Local
      final localBatch = await _dbService.bhattiBatches.get(fastHash(batchId));
      if (localBatch != null) {
        if (localBatch.isDeleted) return null;
        return localBatch.toDomain();
      }

      // 2. Remote
      final firestore = db;
      if (firestore == null) return null;

      final doc = await firestore
          .collection(bhattiBatchesCollection)
          .doc(batchId)
          .get();
      if (!doc.exists) return null;

      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;
      if (data['isDeleted'] == true) {
        return null;
      }

      // Save to local
      final entity = BhattiBatchEntity.fromFirebaseJson(data);
      await _dbService.db.writeTxn(() => _dbService.bhattiBatches.put(entity));

      return entity.toDomain();
    } catch (e) {
      throw handleError(e, 'getBhattiBatchById');
    }
  }

  Future<BhattiBatch?> getLastBatch(String bhattiName) async {
    try {
      final batches = await _dbService.bhattiBatches
          .filter()
          .bhattiNameEqualTo(bhattiName.toLowerCase())
          .sortByCreatedAtDesc()
          .limit(1)
          .findAll();
      if (batches.isEmpty) return null;
      return batches.first.toDomain();
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateBhattiBatch({
    required String batchId,
    required List<Map<String, dynamic>> newRawMaterials,
    required int newOutputBoxes,
    double newFuelConsumption = 0.0,
  }) async {
    try {
      final now = DateTime.now();

      await _dbService.db.writeTxn(() async {
        final existingEntity = await _dbService.bhattiBatches.get(
          fastHash(batchId),
        );
        if (existingEntity == null) throw Exception("Batch not found locally");

        // BUG 2 FIX: Tank consumption reversal is not implemented.
        // Editing a batch that consumed from a tank would leave the tank stock
        // permanently understated. Block the edit to prevent data corruption.
        if (existingEntity.tankConsumptions.isNotEmpty) {
          throw Exception(
            'Cannot edit a batch with tank consumptions. '
            'Tank stock reversals are not supported. Please create a new batch.',
          );
        }

        final oldMaterials = existingEntity.rawMaterialsConsumed;
        final bhattiName = existingEntity.bhattiName
            .trim()
            .toLowerCase(); // BUG 5 FIX: normalize
        final oldOutputBoxes = existingEntity.outputBoxes;
        final targetProductId = existingEntity.targetProductId;
        final targetProductName = existingEntity.targetProductName;

        // 1. Reconcile Stock
        // For each material in OLD but not in NEW (or different qty), adjust stock
        // To simplify, let's reverse ALL old consumption and apply ALL new consumption
        // This is safer for consistency than calculating deltas manually for nested maps

        for (var old in oldMaterials) {
          final mId = old.materialId;
          final q = old.quantity ?? 0.0;
          if (mId == null) continue;

          // Revert old consumption (add back to stock)
          // BUG 5 FIX: bhattiName is already normalized above
          await _inventoryService.applyDepartmentStockChangeInTxn(
            departmentName: bhattiName,
            productId: mId,
            quantityChange: q,
            updatedAt: now,
            markSyncPending: true,
            createIfMissing: false,
          );
          final revertedProduct = await _inventoryService
              .applyProductStockChangeInTxn(
                productId: mId,
                quantityChange: q,
                updatedAt: now,
                markSyncPending: true,
                allowMissing: true,
              );

          // T12: Create reversal ledger entry for audit trail
          final reversalLedger = StockLedgerEntity()
            ..id = generateId()
            ..productId = mId
            ..warehouseId = bhattiName
            ..transactionDate = now
            ..transactionType = 'PRODUCTION_REVERSAL'
            ..referenceId = batchId
            ..quantityChange = q
            ..runningBalance = revertedProduct?.stock ?? 0.0
            ..unit = 'Kg'
            ..performedBy = existingEntity.supervisorId
            ..notes =
                'Bhatti Batch Edit: reversed old consumption of ${old.name ?? "material"}'
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await _dbService.stockLedger.put(reversalLedger);
        }

        // Apply new consumption
        double newTotalCost = 0;
        for (var material in newRawMaterials) {
          final mId = material['materialId'] ?? material['rawMaterialId'];
          final q = (material['quantity'] as num).toDouble();
          final mName = material['materialName'] ?? 'Unknown';

          // BUG 5 FIX: bhattiName is already normalized — consistent Isar key
          final stockEntity = await _dbService.departmentStocks
              .filter()
              .departmentNameEqualTo(bhattiName)
              .and()
              .productIdEqualTo(mId)
              .findFirst();

          if (stockEntity == null || stockEntity.stock < q) {
            throw Exception("Insufficient stock for $mName ($q required)");
          }

          await _inventoryService.applyDepartmentStockChangeInTxn(
            departmentName: bhattiName,
            productId: mId,
            quantityChange: -q,
            updatedAt: now,
            markSyncPending: true,
            createIfMissing: false,
          );
          final consumedProduct = await _inventoryService
              .applyProductStockChangeInTxn(
                productId: mId,
                quantityChange: -q,
                updatedAt: now,
                markSyncPending: true,
                allowMissing: true,
              );

          // T12: Create consumption ledger entry for audit trail
          final consumptionLedger = StockLedgerEntity()
            ..id = generateId()
            ..productId = mId
            ..warehouseId = bhattiName
            ..transactionDate = now
            ..transactionType = 'PRODUCTION_CONSUMPTION'
            ..referenceId = batchId
            ..quantityChange = -q
            ..runningBalance = consumedProduct?.stock ?? 0.0
            ..unit = 'Kg'
            ..performedBy = existingEntity.supervisorId
            ..notes = 'Bhatti Batch Edit: new consumption of $mName'
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await _dbService.stockLedger.put(consumptionLedger);

          // Recalculate cost
          final productEntity = await _dbService.products.get(fastHash(mId));
          newTotalCost += (productEntity?.price ?? 0.0) * q;
        }

        // 1.5 Reconcile production output stock if output boxes changed.
        final outputDeltaBoxes = newOutputBoxes - oldOutputBoxes;
        if (outputDeltaBoxes != 0) {
          final outputProduct = await _dbService.products.get(
            fastHash(targetProductId),
          );
          final boxWeightKg = ((outputProduct?.unitWeightGrams ?? 0) > 0)
              ? (outputProduct!.unitWeightGrams! / 1000)
              : 1.0;
          final outputDeltaKg = outputDeltaBoxes * boxWeightKg;

          final updatedProduct = await _inventoryService
              .applyProductStockChangeInTxn(
                productId: targetProductId,
                quantityChange: outputDeltaKg,
                updatedAt: now,
                markSyncPending: true,
                enforceNonNegative: true,
              );

          // BUG 5 FIX: bhattiName normalized above
          await _inventoryService.applyDepartmentStockChangeInTxn(
            departmentName: bhattiName,
            productId: targetProductId,
            quantityChange: outputDeltaKg,
            productName: targetProductName,
            unit: 'Kg',
            updatedAt: now,
            markSyncPending: true,
            createIfMissing: true,
            enforceNonNegative: true,
          );

          final outputAdjustmentLedger = StockLedgerEntity()
            ..id = generateId()
            ..productId = targetProductId
            ..warehouseId = bhattiName
            ..transactionDate = now
            ..transactionType = 'PRODUCTION_ADJUSTMENT'
            ..referenceId = batchId
            ..quantityChange = outputDeltaKg
            ..runningBalance = updatedProduct?.stock ?? 0.0
            ..unit = 'Kg'
            ..performedBy = existingEntity.supervisorId
            ..notes =
                'Bhatti Batch Edit: output adjusted from $oldOutputBoxes to $newOutputBoxes boxes'
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await _dbService.stockLedger.put(outputAdjustmentLedger);
        }

        // 2. Update Entity
        existingEntity.rawMaterialsConsumed = newRawMaterials
            .map((e) => ConsumedItem.fromJson(e))
            .toList();
        existingEntity.outputBoxes = newOutputBoxes;
        existingEntity.totalBatchCost = newTotalCost;
        existingEntity.costPerBox = newOutputBoxes > 0
            ? newTotalCost / newOutputBoxes
            : 0.0;
        existingEntity.updatedAt = now;
        existingEntity.syncStatus = SyncStatus.pending;

        await _dbService.bhattiBatches.put(existingEntity);
      });

      // 3. Sync
      final updated = await _dbService.bhattiBatches.get(fastHash(batchId));
      if (updated != null) {
        await _enqueueSyncCommand(
          queueId: 'bhatti_batch_update_$batchId',
          collection: bhattiBatchesCollection,
          action: 'update',
          payload: updated.toFirebaseJson(),
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'updateBhattiBatch');
      return false;
    }
  }
}
