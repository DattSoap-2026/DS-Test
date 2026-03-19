import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import '../models/types/cutting_types.dart';
import 'offline_first_service.dart';
import 'database_service.dart';
import 'inventory_movement_engine.dart';
import 'inventory_projection_service.dart';
import '../data/local/entities/cutting_batch_entity.dart';
import '../data/local/base_entity.dart';
import '../utils/unit_scope_utils.dart';
import 'outbox_codec.dart';

const String cuttingBatchesCollection = 'cutting_batches';

class _SemiStockPlan {
  const _SemiStockPlan({
    required this.quantity,
    required this.unit,
    required this.source,
  });

  final double quantity;
  final String unit;
  final String source;
}

class CuttingBatchService extends OfflineFirstService {
  final DatabaseService _dbService;
  final InventoryMovementEngine _inventoryMovementEngine;
  String? _lastCreateBatchError;
  Future<void> Function()? _centralQueueSync;
  static const String _outputRulesLocalKey = 'local_bhatti_output_rules';
  static const String _outputRulesCollection = 'public_settings';
  static const String _outputRulesDocId = 'bhatti_output_rules';

  CuttingBatchService(
    super.firebase,
    this._dbService,
    this._inventoryMovementEngine,
  );

  @override
  String get localStorageKey => 'cutting_batches';

  String? get lastCreateBatchError => _lastCreateBatchError;

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

  bool _matchesBatchUnitScope(CuttingBatch batch, UserUnitScope? unitScope) {
    if (unitScope == null) return true;
    return matchesUnitScope(
      scope: unitScope,
      tokens: [
        batch.departmentId,
        batch.departmentName,
        batch.semiFinishedProductName,
        batch.finishedGoodName,
      ],
      defaultIfNoScopeTokens: false,
    );
  }

  Map<String, int> _defaultOutputRules() => const {'sona': 6, 'gita': 7};

  Map<String, int> _sanitizeOutputRules(Map<String, dynamic> source) {
    final defaults = _defaultOutputRules();

    int parse(dynamic value, int fallback) {
      if (value is num && value > 0) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null && parsed > 0) return parsed;
      }
      return fallback;
    }

    return {
      'sona': parse(
        source['sona'] ?? source['sonaBoxesPerBatch'],
        defaults['sona']!,
      ),
      'gita': parse(
        source['gita'] ?? source['gitaBoxesPerBatch'],
        defaults['gita']!,
      ),
    };
  }

  String _resolveBhattiKey({
    required String departmentName,
    required String semiFinishedProductName,
  }) {
    final department = departmentName.toLowerCase();
    final semiName = semiFinishedProductName.toLowerCase();

    if (department.contains('gita') || semiName.contains('gita')) return 'gita';
    if (department.contains('sona') ||
        department.contains('bhatti') ||
        semiName.contains('sona')) {
      return 'sona';
    }
    return '';
  }

  Future<Map<String, int>> getOutputBoxesRules({bool forceRefresh = false}) {
    return _getOutputRules(forceRefresh: forceRefresh);
  }

  Future<Map<String, int>> _getOutputRules({bool forceRefresh = false}) async {
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
          // Ignore corrupted cache and fall back.
        }
      }
    }

    final firestore = db;
    if (firestore != null) {
      try {
        final doc = await firestore
            .collection(_outputRulesCollection)
            .doc(_outputRulesDocId)
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

    return defaults;
  }

  Future<_SemiStockPlan> _resolveSemiStockPlan({
    required String departmentName,
    required String semiFinishedProductName,
    required String semiBaseUnit,
    required double fallbackWeightKg,
    required int batchCount,
    int? explicitBoxesCount,
    double? semiBoxWeightKg,
  }) async {
    final normalizedBatchCount = batchCount > 0 ? batchCount.toDouble() : 1.0;
    final normalizedBaseUnit = semiBaseUnit.trim();
    final baseUnitLower = normalizedBaseUnit.toLowerCase();
    final consumesInWeight =
        baseUnitLower == 'kg' ||
        baseUnitLower == 'kgs' ||
        baseUnitLower == 'kilogram' ||
        baseUnitLower == 'kilograms';

    if (consumesInWeight) {
      final weightFromBatch = (semiBoxWeightKg != null && semiBoxWeightKg > 0)
          ? normalizedBatchCount * semiBoxWeightKg
          : 0.0;
      final resolvedWeight = weightFromBatch > 0
          ? weightFromBatch
          : (fallbackWeightKg > 0 ? fallbackWeightKg : normalizedBatchCount);
      return _SemiStockPlan(
        quantity: resolvedWeight,
        unit: 'Kg',
        source: 'weight-batch',
      );
    }

    if (normalizedBaseUnit.isNotEmpty) {
      return _SemiStockPlan(
        quantity: normalizedBatchCount,
        unit: normalizedBaseUnit,
        source: 'batch-count',
      );
    }

    final bhattiKey = _resolveBhattiKey(
      departmentName: departmentName,
      semiFinishedProductName: semiFinishedProductName,
    );

    if (bhattiKey.isNotEmpty) {
      final rules = await _getOutputRules();
      final perBatchBoxes =
          (rules[bhattiKey] ?? _defaultOutputRules()[bhattiKey] ?? 0)
              .toDouble();
      if (perBatchBoxes > 0) {
        final computedBoxes =
            explicitBoxesCount != null && explicitBoxesCount > 0
            ? explicitBoxesCount.toDouble()
            : perBatchBoxes * normalizedBatchCount;
        if (computedBoxes <= 0) {
          return _SemiStockPlan(
            quantity: fallbackWeightKg,
            unit: 'Kg',
            source: 'weight',
          );
        }
        final normalizedBoxWeight =
            semiBoxWeightKg != null && semiBoxWeightKg > 0
            ? semiBoxWeightKg
            : null;
        if (normalizedBoxWeight != null) {
          return _SemiStockPlan(
            quantity: computedBoxes * normalizedBoxWeight,
            unit: 'Kg',
            source: '$bhattiKey-rule',
          );
        }
        return _SemiStockPlan(
          quantity: computedBoxes,
          unit: 'Box',
          source: '$bhattiKey-rule-box',
        );
      }
    }

    return _SemiStockPlan(
      quantity: fallbackWeightKg,
      unit: 'Kg',
      source: 'weight',
    );
  }

  /// Resolve stock plan for UI validation
  /// Returns the exact unit and quantity that will be consumed
  Future<Map<String, dynamic>> resolveStockPlan({
    required String semiFinishedProductId,
    required String departmentName,
    required int batchCount,
    int? boxesCount,
  }) async {
    try {
      final semiProduct = await _dbService.products.get(
        fastHash(semiFinishedProductId),
      );

      if (semiProduct == null) {
        return {
          'consumptionUnit': 'BOX',
          'consumptionQuantity': 0.0,
          'availableStock': 0.0,
          'isAvailable': false,
          'error': 'Product not found',
        };
      }

      final semiBoxWeightGm = semiProduct.unitWeightGrams ?? 0;
      final semiBoxWeightKg = semiBoxWeightGm > 0 ? semiBoxWeightGm / 1000 : null;
      final semiBaseUnit = semiProduct.baseUnit.trim();
      final fallbackWeightKg = boxesCount != null && boxesCount > 0 && semiBoxWeightKg != null
          ? boxesCount * semiBoxWeightKg
          : 0.0;

      final plan = await _resolveSemiStockPlan(
        departmentName: departmentName,
        semiFinishedProductName: semiProduct.name,
        semiBaseUnit: semiBaseUnit,
        fallbackWeightKg: fallbackWeightKg,
        batchCount: batchCount,
        explicitBoxesCount: boxesCount,
        semiBoxWeightKg: semiBoxWeightKg,
      );

      final availableStock = semiProduct.stock ?? 0.0;
      final isAvailable = availableStock >= plan.quantity;

      return {
        'consumptionUnit': plan.unit,
        'consumptionQuantity': plan.quantity,
        'availableStock': availableStock,
        'isAvailable': isAvailable,
        'error': null,
      };
    } catch (e) {
      handleError(e, 'resolveStockPlan');
      return {
        'consumptionUnit': 'BOX',
        'consumptionQuantity': 0.0,
        'availableStock': 0.0,
        'isAvailable': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate batch number: CTYYMMDD-RAND
  String generateBatchNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = (now.month).toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (100 + DateTime.now().millisecond % 900).toString().padLeft(
      3,
      '0',
    );
    return 'CT$year$month$day-$random';
  }

  /// Generate SHA256 batch genealogy ID
  String generateBatchGeneId(String input) {
    final uuid = generateId();
    final data = '$input-$uuid';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate weight against product tolerance
  WeightValidation validateWeight(
    double actualWeightGm,
    double standardWeightGm,
    double tolerancePercent,
  ) {
    final minWeight =
        standardWeightGm - (standardWeightGm * tolerancePercent / 100);
    final isValid = actualWeightGm >= minWeight;
    final difference = actualWeightGm - standardWeightGm;

    return WeightValidation(
      isValid: isValid,
      message: isValid
          ? 'Weight validation passed'
          : 'Weight below minimum: ${actualWeightGm.toStringAsFixed(1)} gm (min: ${minWeight.toStringAsFixed(1)} gm)',
      actualWeight: actualWeightGm,
      standardWeight: standardWeightGm,
      tolerance: tolerancePercent,
      difference: difference,
    );
  }

  /// Calculate weight balance (input vs output + waste)
  Map<String, dynamic> calculateWeightBalance({
    required double inputWeightKg,
    required double outputWeightKg,
    required double wasteWeightKg,
  }) {
    final totalOutKg = outputWeightKg + wasteWeightKg;
    final differenceKg = (inputWeightKg - totalOutKg).abs();
    final differencePercent = inputWeightKg > 0
        ? (differenceKg / inputWeightKg) * 100
        : 0.0;
    // Allow if percent is <= 0.5% OR absolute difference is <= 20kg (User Request)
    final isValid = differencePercent <= 0.5 || differenceKg <= 20.0;

    return {
      'inputWeightKg': inputWeightKg,
      'outputWeightKg': outputWeightKg,
      'wasteWeightKg': wasteWeightKg,
      'weightDifferenceKg': differenceKg,
      'weightDifferencePercent': differencePercent,
      'weightBalanceValid': isValid,
    };
  }

  /// Create cutting batch with automatic stock adjustments
  Future<bool> createCuttingBatch({
    required String semiFinishedProductId,
    required String semiFinishedProductName,
    required String finishedGoodId,
    required String finishedGoodName,
    required String departmentId,
    required String departmentName,
    required String operatorId,
    required String operatorName,
    required String supervisorId,
    required String supervisorName,
    required ShiftType shift,
    required double totalBatchWeightKg,
    required double standardWeightGm,
    required double actualAvgWeightGm,
    required double tolerancePercent,
    required int batchCount,
    required int unitsProduced,
    required double cuttingWasteKg,
    required WasteType wasteType,
    int? boxesCount,
    List<Map<String, dynamic>>? packagingConsumptions,
    String? wasteRemark,
  }) async {
    try {
      _lastCreateBatchError = null;
      final batchId = generateId();
      final batchNumber = generateBatchNumber();
      // Genealogy ID can be simplified to batchId or kept as is
      final batchGeneId = batchId;
      final now = DateTime.now();
      final dateStr = now.toIso8601String().split('T')[0];
      final normalizedBatchCount = batchCount > 0 ? batchCount : 1;
      final semiProductForPlan = await _dbService.products.get(
        fastHash(semiFinishedProductId),
      );
      final semiBoxWeightGm = semiProductForPlan?.unitWeightGrams ?? 0;
      final semiBoxWeightKg = semiBoxWeightGm > 0
          ? semiBoxWeightGm / 1000
          : null;
      final semiBaseUnit = (semiProductForPlan?.baseUnit ?? '').trim();
      final semiStockPlan = await _resolveSemiStockPlan(
        departmentName: departmentName,
        semiFinishedProductName: semiFinishedProductName,
        semiBaseUnit: semiBaseUnit,
        fallbackWeightKg: totalBatchWeightKg,
        batchCount: normalizedBatchCount,
        explicitBoxesCount: boxesCount,
        semiBoxWeightKg: semiBoxWeightKg,
      );

      // Calculate avg box weight if boxes count provided
      final avgBoxWeightKg = boxesCount != null && boxesCount > 0
          ? totalBatchWeightKg / boxesCount
          : null;

      // Validate weight
      final weightValidation = validateWeight(
        actualAvgWeightGm,
        standardWeightGm,
        tolerancePercent,
      );

      if (!weightValidation.isValid) {
        throw Exception(
          'Weight validation failed: ${weightValidation.message}',
        );
      }

      // Calculate finished goods weight
      final totalFinishedWeightKg =
          (unitsProduced * actualAvgWeightGm) / 1000.0;

      // Calculate weight balance
      final weightBalance = calculateWeightBalance(
        inputWeightKg: totalBatchWeightKg,
        outputWeightKg: totalFinishedWeightKg,
        wasteWeightKg: cuttingWasteKg,
      );

      await _dbService.db.writeTxn(() async {
        // 1. Adjust Semi-Finished Stock (Input)
        final semiProduct = await _dbService.products.get(
          fastHash(semiFinishedProductId),
        );
        if (semiProduct == null) {
          throw Exception(
            'Semi-finished product not found: $semiFinishedProductId',
          );
        }

        final currentSemiStock = semiProduct.stock ?? 0.0;
        if (currentSemiStock < semiStockPlan.quantity) {
          throw Exception(
            'Insufficient semi-finished stock: available $currentSemiStock, '
            'required ${semiStockPlan.quantity} ${semiStockPlan.unit}',
          );
        }

        // --- 1 to 3.5 Use Movement Engine instead of explicit manual mutations ---
        final consumptions = <InventoryCommandItem>[
          InventoryCommandItem(
            productId: semiFinishedProductId,
            quantityBase: semiStockPlan.quantity,
          ),
        ];

        final outputs = <InventoryCommandItem>[
          if (finishedGoodId.isNotEmpty)
            InventoryCommandItem(
              productId: finishedGoodId,
              quantityBase: unitsProduced.toDouble(),
            ),
        ];

        if (packagingConsumptions != null) {
          for (var pm in packagingConsumptions) {
            consumptions.add(
              InventoryCommandItem(
                productId: pm['materialId'],
                quantityBase: (pm['quantity'] as num).toDouble(),
              ),
            );
          }
        }

        // Fetch the department to get its mapped location (shed)
        final departmentEntity =
            await _dbService.departmentMasters.get(fastHash(departmentId));
        final shedLocationId = departmentEntity?.sourceWarehouseId ??
            InventoryProjectionService.warehouseMainLocationId;

        final command = InventoryCommand.cuttingProductionComplete(
          batchId: batchId,
          consumptionLocationId: shedLocationId,
          outputLocationId: shedLocationId,
          consumptions: consumptions,
          outputs: outputs,
          actorUid: operatorId,
          createdAt: now,
        );

        await _inventoryMovementEngine.applyCommand(command);

        // 4. Record Cutting Batch Entity
        final batchEntity = CuttingBatchEntity()
          ..id = batchId
          ..batchNumber = batchNumber
          ..batchGeneId = batchGeneId
          ..date = DateTime.parse(dateStr)
          ..shift = shift.value
          ..departmentId = departmentId
          ..departmentName = departmentName
          ..operatorId = operatorId
          ..operatorName = operatorName
          ..semiFinishedProductId = semiFinishedProductId
          ..semiFinishedProductName = semiFinishedProductName
          ..totalBatchWeightKg = totalBatchWeightKg
          ..boxesCount = boxesCount ?? 0
          ..avgBoxWeightKg = avgBoxWeightKg
          ..finishedGoodId = finishedGoodId
          ..finishedGoodName = finishedGoodName
          ..standardWeightGm = standardWeightGm
          ..actualAvgWeightGm = actualAvgWeightGm
          ..tolerancePercent = tolerancePercent
          ..unitsProduced = unitsProduced
          ..totalFinishedWeightKg = totalFinishedWeightKg
          ..weightValidationPassed = weightValidation.isValid
          ..weightValidationMessage = weightValidation.message
          ..cuttingWasteKg = cuttingWasteKg
          ..wasteType = wasteType.value
          ..wasteRemark = wasteRemark
          ..inputWeightKg = (weightBalance['inputWeightKg'] as num).toDouble()
          ..outputWeightKg = (weightBalance['outputWeightKg'] as num).toDouble()
          ..wasteWeightKg = (weightBalance['wasteWeightKg'] as num).toDouble()
          ..weightDifferenceKg = (weightBalance['weightDifferenceKg'] as num)
              .toDouble()
          ..weightDifferencePercent =
              (weightBalance['weightDifferencePercent'] as num).toDouble()
          ..weightBalanceValid = weightBalance['weightBalanceValid'] as bool
          ..stage = CuttingStage.completed.value
          ..semiFinishedStockAdjusted = true
          ..finishedGoodsStockAdjusted = true
          ..wasteStockAdjusted = true
          ..supervisorId = supervisorId
          ..supervisorName = supervisorName
          ..packagingConsumptions = packagingConsumptions ?? []
          ..createdAt = now
          ..updatedAt = now
          ..completedAt = now
          ..syncStatus = SyncStatus.pending;

        await _dbService.cuttingBatches.put(batchEntity);
      });

      // 5. Sync to Firebase
      final savedBatch = await _dbService.cuttingBatches.get(fastHash(batchId));
      if (savedBatch != null) {
        await _enqueueSyncCommand(
          queueId: 'cutting_batch_create_$batchId',
          collection: cuttingBatchesCollection,
          action: 'add',
          payload: savedBatch.toFirebaseJson(),
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'createCuttingBatch');
      _lastCreateBatchError = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  /// Get cutting batches for date range
  Future<List<CuttingBatch>> getCuttingBatchesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? productId,
    String? operatorId,
    UserUnitScope? unitScope,
  }) async {
    try {
      final start = startDate;
      final end = endDate;

      // 1. Load from Local (Isar) (Filtered in Dart)
      final allBatches = await _dbService.cuttingBatches.where().findAll();

      var localBatches = allBatches.where((b) {
        return (b.date.isAfter(start) || b.date.isAtSameMomentAs(start)) &&
            (b.date.isBefore(end) || b.date.isAtSameMomentAs(end));
      }).toList();

      if (productId != null) {
        localBatches = localBatches
            .where((b) => b.finishedGoodId == productId)
            .toList();
      }
      if (operatorId != null) {
        localBatches = localBatches
            .where((b) => b.operatorId == operatorId)
            .toList();
      }
      // Manual sort if sortByCreatedAtDesc is not available in generated code yet
      localBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (localBatches.isNotEmpty) {
        final domainBatches = localBatches.map((e) => e.toDomain()).toList();
        return domainBatches
            .where((b) => _matchesBatchUnitScope(b, unitScope))
            .toList();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return [];

      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];

      var fQuery = firestore
          .collection(cuttingBatchesCollection)
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr);

      if (productId != null) {
        fQuery = fQuery.where('finishedGoodId', isEqualTo: productId);
      }
      if (operatorId != null) {
        fQuery = fQuery.where('operatorId', isEqualTo: operatorId);
      }

      final snapshot = await fQuery.get();
      final batches = snapshot.docs
          .map((doc) => CuttingBatch.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      return batches
          .where((b) => _matchesBatchUnitScope(b, unitScope))
          .toList();
    } catch (e) {
      handleError(e, 'getCuttingBatchesByDateRange');
      return [];
    }
  }

  /// Get single cutting batch
  Future<CuttingBatch?> getCuttingBatch(String id) async {
    try {
      final firestore = db;
      if (firestore == null) return null;

      final doc = await firestore
          .collection(cuttingBatchesCollection)
          .doc(id)
          .get();
      if (!doc.exists) return null;

      return CuttingBatch.fromJson({'id': doc.id, ...?doc.data()});
    } catch (e) {
      handleError(e, 'getCuttingBatch');
      return null;
    }
  }

  /// Get all cutting batches (with pagination)
  Future<List<CuttingBatch>> getCuttingBatches({
    int limit = 50,
    UserUnitScope? unitScope,
  }) async {
    try {
      final local = await _dbService.cuttingBatches.where().findAll();
      if (local.isNotEmpty) {
        local.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final localBatches = local
            .take(limit)
            .map((entity) => entity.toDomain())
            .where((batch) => _matchesBatchUnitScope(batch, unitScope))
            .toList();
        if (localBatches.isNotEmpty) return localBatches;
      }

      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(cuttingBatchesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final batches = snapshot.docs
          .map((doc) => CuttingBatch.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      return batches
          .where((b) => _matchesBatchUnitScope(b, unitScope))
          .toList();
    } catch (e) {
      handleError(e, 'getCuttingBatches');
      return [];
    }
  }

  Future<int> getActiveBatchesCount({UserUnitScope? unitScope}) async {
    try {
      bool isActiveStage(String? stage) {
        final normalized = (stage ?? '').trim().toUpperCase();
        return normalized == CuttingStage.pending.value ||
            normalized == CuttingStage.inProgress.value;
      }

      final local = await _dbService.cuttingBatches.where().findAll();
      final localCount = local
          .where((entity) => isActiveStage(entity.stage))
          .map((entity) => entity.toDomain())
          .where((batch) => _matchesBatchUnitScope(batch, unitScope))
          .length;
      if (localCount > 0) return localCount;

      final firestore = db;
      if (firestore == null) return 0;

      final snapshot = await firestore
          .collection(cuttingBatchesCollection)
          .where(
            'stage',
            whereIn: [
              CuttingStage.pending.value,
              CuttingStage.inProgress.value,
            ],
          )
          .get();
      final batches = snapshot.docs
          .map((doc) => CuttingBatch.fromJson({'id': doc.id, ...doc.data()}))
          .where((batch) => _matchesBatchUnitScope(batch, unitScope))
          .toList();
      return batches.length;
    } catch (e) {
      handleError(e, 'getActiveBatchesCount');
      return 0;
    }
  }

  /// Get daily summary for reports
  Future<DailyProductionSummary?> getDailySummary({
    required String date,
    required ShiftType shift,
    UserUnitScope? unitScope,
  }) async {
    try {
      String normalizeDate(DateTime value) =>
          value.toIso8601String().split('T')[0];

      List<CuttingBatch> batches = [];

      final local = await _dbService.cuttingBatches.where().findAll();
      if (local.isNotEmpty) {
        final localBatches = local
            .where((entity) => normalizeDate(entity.date) == date)
            .map((entity) => entity.toDomain())
            .where((batch) => _matchesBatchUnitScope(batch, unitScope))
            .toList();
        if (localBatches.isNotEmpty) {
          batches = localBatches;
        }
      }

      if (batches.isEmpty) {
        final firestore = db;
        if (firestore == null) return null;

        final snapshot = await firestore
            .collection(cuttingBatchesCollection)
            .where('date', isEqualTo: date)
            .get();
        if (snapshot.docs.isEmpty) return null;

        batches = snapshot.docs
            .map((doc) => CuttingBatch.fromJson({'id': doc.id, ...doc.data()}))
            .where((batch) => _matchesBatchUnitScope(batch, unitScope))
            .toList();
      }

      if (batches.isEmpty) return null;

      final totalBatches = batches.length;
      final totalInputKg = batches.fold(
        0.0,
        (sum, b) => sum + b.totalBatchWeightKg,
      );
      final totalFinishedUnits = batches.fold(
        0,
        (sum, b) => sum + b.unitsProduced,
      );
      final totalWasteKg = batches.fold(
        0.0,
        (sum, b) => sum + b.cuttingWasteKg,
      );
      final yieldPercent = totalInputKg > 0
          ? (batches.fold(0.0, (sum, b) => sum + b.outputWeightKg) /
                    totalInputKg) *
                100
          : 0.0;
      final avgEfficiency = totalBatches > 0
          ? (batches.fold(
                      0,
                      (sum, b) => sum + (b.weightValidationPassed ? 1 : 0),
                    ) /
                    totalBatches) *
                100
          : 0.0;

      return DailyProductionSummary(
        date: date,
        shift: shift,
        totalBatches: totalBatches,
        totalInputKg: totalInputKg,
        totalFinishedUnits: totalFinishedUnits,
        totalWasteKg: totalWasteKg,
        yieldPercent: yieldPercent,
        avgEfficiency: avgEfficiency,
      );
    } catch (e) {
      handleError(e, 'getDailySummary');
      return null;
    }
  }

  /// Get yield report for product
  Future<CuttingYieldReport?> getYieldReport({
    required String finishedGoodId,
    required DateTime startDate,
    required DateTime endDate,
    UserUnitScope? unitScope,
  }) async {
    try {
      final batches = await getCuttingBatchesByDateRange(
        startDate: startDate,
        endDate: endDate,
        productId: finishedGoodId,
        unitScope: unitScope,
      );

      if (batches.isEmpty) return null;

      final totalInputKg = batches.fold(
        0.0,
        (sum, b) => sum + b.totalBatchWeightKg,
      );
      final totalUnitsProduced = batches.fold(
        0,
        (sum, b) => sum + b.unitsProduced,
      );
      final totalWasteKg = batches.fold(
        0.0,
        (sum, b) => sum + b.cuttingWasteKg,
      );
      final yieldPercent = totalInputKg > 0
          ? (batches.fold(0.0, (sum, b) => sum + b.outputWeightKg) /
                    totalInputKg) *
                100
          : 0.0;
      final avgWeightDiff = batches.isNotEmpty
          ? batches.fold(0.0, (sum, b) => sum + b.weightDifferencePercent) /
                batches.length
          : 0.0;

      return CuttingYieldReport(
        productName: batches.first.finishedGoodName,
        productId: finishedGoodId,
        batchCount: batches.length,
        totalInputKg: totalInputKg,
        totalUnitsProduced: totalUnitsProduced,
        totalWasteKg: totalWasteKg,
        yieldPercent: yieldPercent,
        avgWeightDifference: avgWeightDiff,
        batches: batches,
      );
    } catch (e) {
      handleError(e, 'getYieldReport');
      return null;
    }
  }

  /// Get waste analysis for product
  Future<WasteAnalysisReport?> getWasteAnalysis({
    required String finishedGoodId,
    required DateTime startDate,
    required DateTime endDate,
    UserUnitScope? unitScope,
  }) async {
    try {
      final batches = await getCuttingBatchesByDateRange(
        startDate: startDate,
        endDate: endDate,
        productId: finishedGoodId,
        unitScope: unitScope,
      );

      if (batches.isEmpty) return null;

      final totalInputKg = batches.fold(
        0.0,
        (sum, b) => sum + b.totalBatchWeightKg,
      );
      final totalWasteKg = batches.fold(
        0.0,
        (sum, b) => sum + b.cuttingWasteKg,
      );
      final scrapKg = batches
          .where((b) => b.wasteType == WasteType.scrap)
          .fold(0.0, (sum, b) => sum + b.cuttingWasteKg);
      final reprocessKg = batches
          .where((b) => b.wasteType == WasteType.reprocess)
          .fold(0.0, (sum, b) => sum + b.cuttingWasteKg);
      final wastePercentage = totalInputKg > 0
          ? (totalWasteKg / totalInputKg) * 100
          : 0.0;

      return WasteAnalysisReport(
        productName: batches.first.finishedGoodName,
        productId: finishedGoodId,
        totalWasteKg: totalWasteKg,
        wastePercentage: wastePercentage,
        scrapKg: scrapKg,
        reprocessKg: reprocessKg,
        batches: batches,
      );
    } catch (e) {
      handleError(e, 'getWasteAnalysis');
      return null;
    }
  }

  /// Get operator performance metrics
  Future<OperatorPerformance?> getOperatorPerformance({
    required String operatorId,
    required DateTime startDate,
    required DateTime endDate,
    UserUnitScope? unitScope,
  }) async {
    try {
      final batches = await getCuttingBatchesByDateRange(
        startDate: startDate,
        endDate: endDate,
        operatorId: operatorId,
        unitScope: unitScope,
      );

      if (batches.isEmpty) return null;

      final totalInputKg = batches.fold(
        0.0,
        (sum, b) => sum + b.totalBatchWeightKg,
      );
      final totalUnitsProduced = batches.fold(
        0,
        (sum, b) => sum + b.unitsProduced,
      );
      final avgYieldPercent =
          batches.fold(0.0, (sum, b) {
            final input = b.totalBatchWeightKg;
            final output = b.outputWeightKg;
            final yield = input > 0 ? (output / input) * 100 : 0.0;
            return sum + yield;
          }) /
          batches.length;

      final passedCount = batches.where((b) => b.weightValidationPassed).length;
      final avgWeightAccuracy = (passedCount / batches.length) * 100;

      final totalWasteKg = batches.fold(
        0.0,
        (sum, b) => sum + b.cuttingWasteKg,
      );
      final avgWastePercent = totalInputKg > 0
          ? (totalWasteKg / totalInputKg) * 100
          : 0.0;

      return OperatorPerformance(
        operatorId: operatorId,
        operatorName: batches.first.operatorName,
        batchesCompleted: batches.length,
        totalInputKg: totalInputKg,
        totalUnitsProduced: totalUnitsProduced,
        avgYieldPercent: avgYieldPercent,
        avgWeightAccuracy: avgWeightAccuracy,
        avgWastePercent: avgWastePercent,
      );
    } catch (e) {
      handleError(e, 'getOperatorPerformance');
      return null;
    }
  }
}
