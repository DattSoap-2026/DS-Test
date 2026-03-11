import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:isar/isar.dart' hide Query;
import 'package:flutter_app/core/constants/collection_registry.dart';
import '../constants/role_access_matrix.dart';
import 'package:flutter_app/services/outbox_codec.dart';
import 'offline_first_service.dart';
import 'inventory_service.dart';
import 'inventory_movement_engine.dart';
import 'inventory_projection_service.dart';
import 'database_service.dart';
import 'service_capability_guard.dart';
import '../data/local/entities/production_target_entity.dart';
import '../data/local/entities/detailed_production_log_entity.dart';
import '../data/local/entities/production_entry_entity.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/entities/stock_balance_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../utils/app_logger.dart';

const productionTargetsCollection = CollectionRegistry.productionTargets;
const productionLogsCollection = CollectionRegistry.productionLogs;
const detailedProductionLogsCollection =
    CollectionRegistry.detailedProductionLogs;
const productsCollection = CollectionRegistry.products;
const tanksCollection = CollectionRegistry.tanks;
const stockLedgerCollection = CollectionRegistry.stockLedger; // Added
const productionEntriesCollection = CollectionRegistry.productionEntries;

// Models
class ProductionTarget {
  final String id;
  final String productId;
  final String productName;
  final String targetDate; // YYYY-MM-DD
  final int targetQuantity;
  final int achievedQuantity;
  final String status;
  final String createdAt;

  ProductionTarget({
    required this.id,
    required this.productId,
    required this.productName,
    required this.targetDate,
    required this.targetQuantity,
    required this.achievedQuantity,
    required this.status,
    required this.createdAt,
  });

  factory ProductionTarget.fromJson(Map<String, dynamic> json) {
    return ProductionTarget(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      targetDate: json['targetDate'] as String,
      targetQuantity: (json['targetQuantity'] as num).toInt(),
      achievedQuantity: (json['achievedQuantity'] as num).toInt(),
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] as String,
    );
  }
}

class DetailedProductionLog {
  final String id;
  final String batchNumber;
  final String productId;
  final String productName;
  final int totalBatchQuantity;
  final String unit;
  final String supervisorId;
  final String supervisorName;
  final String? issueId;
  final double totalBatchCost;
  final double costPerUnit;
  final String createdAt;
  final List<Map<String, dynamic>>? semiFinishedGoodsUsed;
  final List<Map<String, dynamic>>? packagingMaterialsUsed;
  final List<Map<String, dynamic>>? additionalRawMaterialsUsed;
  final Map<String, dynamic>? cuttingWastage;

  DetailedProductionLog({
    required this.id,
    required this.batchNumber,
    required this.productId,
    required this.productName,
    required this.totalBatchQuantity,
    required this.unit,
    required this.supervisorId,
    required this.supervisorName,
    this.issueId,
    this.totalBatchCost = 0,
    this.costPerUnit = 0,
    required this.createdAt,
    this.semiFinishedGoodsUsed,
    this.packagingMaterialsUsed,
    this.additionalRawMaterialsUsed,
    this.cuttingWastage,
  });
}

class AddDetailedProductionLogPayload {
  final String batchNumber;
  final String productId;
  final String productName;
  final int totalBatchQuantity;
  final String unit;
  final String supervisorId;
  final String supervisorName;
  final List<Map<String, dynamic>>? semiFinishedGoodsUsed;
  final List<Map<String, dynamic>>? packagingMaterialsUsed;
  final List<Map<String, dynamic>>? additionalRawMaterialsUsed;
  final Map<String, dynamic>? cuttingWastage;

  AddDetailedProductionLogPayload({
    required this.batchNumber,
    required this.productId,
    required this.productName,
    required this.totalBatchQuantity,
    required this.unit,
    required this.supervisorId,
    required this.supervisorName,
    this.semiFinishedGoodsUsed,
    this.packagingMaterialsUsed,
    this.additionalRawMaterialsUsed,
    this.cuttingWastage,
  });

  Map<String, dynamic> toJson() {
    return {
      'batchNumber': batchNumber,
      'productId': productId,
      'productName': productName,
      'totalBatchQuantity': totalBatchQuantity,
      'unit': unit,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
      'semiFinishedGoodsUsed': semiFinishedGoodsUsed,
      'packagingMaterialsUsed': packagingMaterialsUsed,
      'additionalRawMaterialsUsed': additionalRawMaterialsUsed,
      'cuttingWastage': cuttingWastage,
    };
  }
}

class ProductionService extends OfflineFirstService {
  // ignore: unused_field
  final InventoryService _inventoryService;
  final DatabaseService _dbService;
  final InventoryMovementEngine _inventoryMovementEngine;
  Future<void> Function()? _centralQueueSync;

  ProductionService(
    super.firebase,
    this._inventoryService,
    this._dbService, {
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _inventoryMovementEngine =
           inventoryMovementEngine ??
           InventoryMovementEngine(
             _dbService,
             InventoryProjectionService(_dbService),
           );

  ServiceCapabilityGuard get _capabilityGuard =>
      ServiceCapabilityGuard(auth: auth, dbService: _dbService);

  @override
  String get localStorageKey => 'production_data_v2'; // Updated to avoid conflict with old collection-based keys

  void bindCentralQueueSync(Future<void> Function() callback) {
    _centralQueueSync = callback;
  }

  Future<void> _enqueueSyncCommand({
    required String queueId,
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now();
    final commandPayload = OutboxCodec.ensureCommandPayload(
      collection: collection,
      action: action,
      payload: payload,
      queueId: queueId,
    );
    final queueEntity = SyncQueueEntity()
      ..id = queueId
      ..collection = collection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: commandPayload,
        existingMeta: null,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(queueEntity);
    });
    if (_centralQueueSync != null) {
      await _centralQueueSync!.call();
    }
  }

  Future<void> _ensureWarehouseLocationReady() async {
    final existing = await _dbService.inventoryLocations.get(
      fastHash(InventoryProjectionService.warehouseMainLocationId),
    );
    if (existing != null) {
      return;
    }
    await InventoryProjectionService(_dbService).ensureCanonicalFoundation();
  }

  List<InventoryCommandItem> _commandItemsFromRawMaterials(
    List<Map<String, dynamic>> materials,
  ) {
    return materials
        .map(
          (material) => InventoryCommandItem(
            productId: material['productId']?.toString().trim() ?? '',
            quantityBase: (material['quantity'] as num?)?.toDouble() ?? 0.0,
          ),
        )
        .where(
          (item) =>
              item.productId.isNotEmpty && item.quantityBase.abs() >= 1e-9,
        )
        .toList(growable: false);
  }

  List<InventoryCommandItem> _commandItemsFromOutputs(
    Map<String, dynamic> data,
  ) {
    final items = <InventoryCommandItem>[];
    final productId = data['productId']?.toString().trim() ?? '';
    final totalBatchQuantity =
        (data['totalBatchQuantity'] as num?)?.toDouble() ?? 0.0;
    if (productId.isNotEmpty && totalBatchQuantity.abs() >= 1e-9) {
      items.add(
        InventoryCommandItem(
          productId: productId,
          quantityBase: totalBatchQuantity,
        ),
      );
    }

    final cuttingWastage = data['cuttingWastage'];
    if (cuttingWastage is Map) {
      final wastageMaterialId =
          cuttingWastage['materialId']?.toString().trim() ?? '';
      final wastageQuantity =
          (cuttingWastage['quantity'] as num?)?.toDouble() ?? 0.0;
      if (wastageMaterialId.isNotEmpty && wastageQuantity.abs() >= 1e-9) {
        items.add(
          InventoryCommandItem(
            productId: wastageMaterialId,
            quantityBase: wastageQuantity,
          ),
        );
      }
    }

    return items;
  }

  Future<void> _seedWarehouseBalancesInTxn({
    required List<InventoryCommandItem> items,
    required DateTime occurredAt,
  }) async {
    for (final item in items) {
      final balanceId = StockBalanceEntity.composeId(
        InventoryProjectionService.warehouseMainLocationId,
        item.productId,
      );
      final existing = await _dbService.stockBalances.get(fastHash(balanceId));
      if (existing != null) {
        continue;
      }
      final product = await _dbService.products.get(fastHash(item.productId));
      final balance = StockBalanceEntity()
        ..id = balanceId
        ..locationId = InventoryProjectionService.warehouseMainLocationId
        ..productId = item.productId
        ..quantity = product?.stock ?? 0.0
        ..updatedAt = occurredAt
        ..syncStatus = product?.syncStatus ?? SyncStatus.pending
        ..isDeleted = false;
      await _dbService.stockBalances.put(balance);
    }
  }

  Future<bool> _hasExistingLocalProductionInventory(String logId) async {
    final existingLog = await _dbService.detailedProductionLogs.get(
      fastHash(logId),
    );
    if (existingLog == null) {
      return false;
    }
    final existingLedger = await _dbService.stockLedger
        .filter()
        .referenceIdEqualTo(logId)
        .findFirst();
    return existingLedger != null;
  }

  Future<void> _applyProductionInventoryCommandsIfNeeded({
    required String batchId,
    required List<InventoryCommandItem> rawMaterialItems,
    required List<InventoryCommandItem> outputItems,
    required String actorUid,
    required DateTime occurredAt,
  }) async {
    if (rawMaterialItems.isEmpty && outputItems.isEmpty) {
      return;
    }

    await _ensureWarehouseLocationReady();
    await _dbService.db.writeTxn(() async {
      await _seedWarehouseBalancesInTxn(
        items: rawMaterialItems,
        occurredAt: occurredAt,
      );
      if (rawMaterialItems.isNotEmpty) {
        final rawCommand = InventoryCommand.bhattiProductionComplete(
          batchId: batchId,
          consumptionLocationId:
              InventoryProjectionService.warehouseMainLocationId,
          outputLocationId: InventoryProjectionService.warehouseMainLocationId,
          consumptions: rawMaterialItems,
          outputs: const <InventoryCommandItem>[],
          actorUid: actorUid,
          createdAt: occurredAt,
        );
        await _inventoryMovementEngine.applyCommandInTxn(rawCommand);
      }
      if (outputItems.isNotEmpty) {
        final outputCommand = InventoryCommand.cuttingProductionComplete(
          batchId: batchId,
          consumptionLocationId:
              InventoryProjectionService.warehouseMainLocationId,
          outputLocationId: InventoryProjectionService.warehouseMainLocationId,
          consumptions: const <InventoryCommandItem>[],
          outputs: outputItems,
          actorUid: actorUid,
          createdAt: occurredAt,
        );
        await _inventoryMovementEngine.applyCommandInTxn(outputCommand);
      }
    });
  }

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final firestore = db;
    if (firestore == null) return;

    try {
      if (action == 'add' && collection == detailedProductionLogsCollection) {
        final String logId = data['id'];
        final commandKey =
            OutboxCodec.readIdempotencyKey(data) ??
            OutboxCodec.buildCommandKey(
              collection: collection,
              action: action,
              payload: data,
            );

        // 1. Idempotency Guard (Read outside batch)
        final docRef = firestore.collection(collection).doc(logId);
        final existingLog = await docRef.get();
        if (existingLog.exists) {
          final existingData = existingLog.data();
          if (existingData?[OutboxCodec.idempotencyKeyField] == commandKey ||
              existingData?['isSynced'] == true) {
            return;
          }
        }

        // 2. Data Parsing
        final productId = data['productId'];
        final totalBatchQuantity = (data['totalBatchQuantity'] as num).toInt();
        final rawMaterials = <Map<String, dynamic>>[];

        void collect(List<dynamic>? list, String key, String nameKey) {
          if (list == null) return;
          for (var m in list) {
            rawMaterials.add({
              'productId': m[key],
              'name': m[nameKey] ?? 'Unknown Material',
              'quantity': (m['quantity'] as num).toDouble(),
              'movementType': 'out',
            });
          }
        }

        collect(data['semiFinishedGoodsUsed'], 'productId', 'productName');
        collect(data['packagingMaterialsUsed'], 'materialId', 'materialName');
        collect(
          data['additionalRawMaterialsUsed'],
          'materialId',
          'materialName',
        );

        final rawMaterialItems = _commandItemsFromRawMaterials(rawMaterials);
        final outputItems = _commandItemsFromOutputs(data);
        final actorUid =
            data['supervisorId']?.toString().trim().isNotEmpty == true
            ? data['supervisorId'].toString().trim()
            : 'system';
        final rawCreatedAt = data['createdAt'];
        final occurredAt = rawCreatedAt is fs.Timestamp
            ? rawCreatedAt.toDate()
            : rawCreatedAt is String
            ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
            : DateTime.now();
        if (!await _hasExistingLocalProductionInventory(logId)) {
          await _applyProductionInventoryCommandsIfNeeded(
            batchId: logId,
            rawMaterialItems: rawMaterialItems,
            outputItems: outputItems,
            actorUid: actorUid,
            occurredAt: occurredAt,
          );
        }

        // 3. Prepare Batch
        final batch = firestore.batch();

        // T9-P4 REMOVED: direct Firestore stock mutations now flow through
        // InventoryMovementEngine commands (`bhatti:{batchId}` and
        // `cutting:{batchId}`) with durable inventory outbox handling.
        // for (var rm in rawMaterials) {
        //   final rmRef = firestore
        //       .collection(productsCollection)
        //       .doc(rm['productId']);
        //   batch.update(rmRef, {
        //     'stock': fs.FieldValue.increment(-(rm['quantity'] as double)),
        //   });
        // }
        // final fgRef = firestore.collection(productsCollection).doc(productId);
        // batch.update(fgRef, {
        //   'stock': fs.FieldValue.increment(totalBatchQuantity),
        // });
        // if (data['cuttingWastage'] != null &&
        //     (data['cuttingWastage']['quantity'] as num) > 0) {
        //   final wId = data['cuttingWastage']['materialId'];
        //   final wQty = (data['cuttingWastage']['quantity'] as num).toDouble();
        //   final wRef = firestore.collection(productsCollection).doc(wId);
        //   batch.update(wRef, {'stock': fs.FieldValue.increment(wQty)});
        // }

        // 7. Update Production Target (Find by Product + Date)
        String dateStr;
        if (rawCreatedAt is fs.Timestamp) {
          dateStr = rawCreatedAt.toDate().toIso8601String().split('T')[0];
        } else if (rawCreatedAt is String) {
          dateStr = rawCreatedAt.split('T')[0];
        } else {
          dateStr = DateTime.now().toIso8601String().split('T')[0];
        }

        // Target fetch (Read outside batch)
        final targetQuery = await firestore
            .collection(productionTargetsCollection)
            .where('productId', isEqualTo: productId)
            .where('targetDate', isEqualTo: dateStr)
            .limit(1)
            .get();

        if (targetQuery.docs.isNotEmpty) {
          final tRef = targetQuery.docs.first.reference;
          batch.update(tRef, {
            'achievedQuantity': fs.FieldValue.increment(totalBatchQuantity),
          });
        }

        // 8. Apply Log with Metadata
        batch.set(docRef, {
          ...data,
          OutboxCodec.idempotencyKeyField: commandKey,
          'createdAt': data['createdAt'] ?? fs.FieldValue.serverTimestamp(),
          'updatedAt': fs.FieldValue.serverTimestamp(),
          'isSynced': true,
        }, fs.SetOptions(merge: true));

        // 9. Atomic Commit
        await batch.commit();
        return;
      }

      await super.performSync(action, collection, data);
    } catch (e) {
      AppLogger.error(
        'Production performSync failed for $action on $collection',
        error: e,
        tag: 'Production',
      );
      rethrow;
    }
  }

  // Targets
  Future<List<ProductionTarget>> getProductionTargets({
    bool activeOnly = false,
  }) async {
    try {
      // 1. Local (Isar) (Filtered in Dart to avoid Type errors)
      final allEntities = await _dbService.productionTargets.where().findAll();

      var entities = allEntities;
      if (activeOnly) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        entities = entities.where((e) => e.targetDate == today).toList();
      }

      // Return mapped domain objects
      final targets = entities
          .map(
            (e) => ProductionTarget(
              id: e.id,
              productId: e.productId,
              productName: e.productName,
              targetDate: e.targetDate,
              targetQuantity: e.targetQuantity,
              achievedQuantity: e.achievedQuantity,
              status: e.status,
              createdAt: e.createdAt.toIso8601String(),
            ),
          )
          .toList();

      targets.sort((a, b) => b.targetDate.compareTo(a.targetDate));

      // DEDUPLICATE to prevent duplicate targets in UI
      return deduplicate(targets, (t) => t.id);
    } catch (e) {
      handleError(e, 'getProductionTargets');
      return [];
    }
  }

  Future<List<ProductionTarget>> getProductionTargetsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = start.toIso8601String().split('T')[0];
      final endStr = end.toIso8601String().split('T')[0];

      final entities = await _dbService.productionTargets
          .filter()
          .targetDateBetween(startStr, endStr, includeUpper: true)
          .findAll();

      final targets = entities
          .map(
            (e) => ProductionTarget(
              id: e.id,
              productId: e.productId,
              productName: e.productName,
              targetDate: e.targetDate,
              targetQuantity: e.targetQuantity,
              achievedQuantity: e.achievedQuantity,
              status: e.status,
              createdAt: e.createdAt.toIso8601String(),
            ),
          )
          .toList();

      targets.sort((a, b) => b.targetDate.compareTo(a.targetDate));

      return targets;
    } catch (e) {
      handleError(e, 'getProductionTargetsInDateRange');
      return [];
    }
  }

  Future<List<DetailedProductionLog>> getDetailedProductionLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Optimized Isar Query
      // Use query builder directly instead of loading all
      // 1. Optimized Isar Query
      List<DetailedProductionLogEntity> entities;

      if (startDate != null && endDate != null) {
        entities = await _dbService.detailedProductionLogs
            .filter()
            .createdAtBetween(startDate, endDate)
            .findAll();
      } else if (startDate != null) {
        entities = await _dbService.detailedProductionLogs
            .filter()
            .createdAtGreaterThan(startDate, include: true)
            .findAll();
      } else {
        entities = await _dbService.detailedProductionLogs.where().findAll();
      }

      // Sort desc
      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final localLogs = entities.map((e) {
        return DetailedProductionLog(
          id: e.id,
          batchNumber: e.batchNumber,
          productId: e.productId,
          productName: e.productName,
          totalBatchQuantity: e.totalBatchQuantity,
          unit: e.unit,
          supervisorId: e.supervisorId,
          supervisorName: e.supervisorName,
          issueId: e.issueId,
          totalBatchCost: e.totalBatchCost,
          costPerUnit: e.costPerUnit,
          createdAt: e.createdAt.toIso8601String(),
          semiFinishedGoodsUsed: e.semiFinishedGoodsUsed
              .map((m) => m.toJson())
              .toList(),
          packagingMaterialsUsed: e.packagingMaterialsUsed
              .map((m) => m.toJson())
              .toList(),
          additionalRawMaterialsUsed: e.additionalRawMaterialsUsed
              .map((m) => m.toJson())
              .toList(),
          cuttingWastage: e.cuttingWastage?.toJson(),
        );
      }).toList();

      if (localLogs.isNotEmpty) {
        // DEDUPLICATE local logs
        return deduplicate(localLogs, (log) => log.id);
      }

      // 2. Fallback to Firestore (Only if needed and date range is provided reasonably)
      // fetch logic is omitted for brevity as syncing should handle this via generic sync ideally,
      // but if we need explicit fetch:
      final firestore = db;
      if (firestore == null) return [];

      fs.Query fQuery = firestore
          .collection(detailedProductionLogsCollection)
          .orderBy('createdAt', descending: true);

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
          .map((doc) => doc.data() as Map<String, dynamic>..['id'] = doc.id)
          .toList();

      // Save to local
      await _dbService.db.writeTxn(() async {
        for (var data in remoteData) {
          final entity = DetailedProductionLogEntity.fromFirebaseJson(data);
          await _dbService.detailedProductionLogs.put(entity);
        }
      });

      final remoteLogs = remoteData.map((data) {
        // Re-map from json logic duplicated above or use helper
        return DetailedProductionLog(
          id: data['id'],
          batchNumber: data['batchNumber'],
          productId: data['productId'],
          productName: data['productName'],
          totalBatchQuantity: (data['totalBatchQuantity'] as num).toInt(),
          unit: data['unit'],
          supervisorId: data['supervisorId'],
          supervisorName: data['supervisorName'],
          issueId: data['issueId'],
          totalBatchCost: (data['totalBatchCost'] as num?)?.toDouble() ?? 0,
          costPerUnit: (data['costPerUnit'] as num?)?.toDouble() ?? 0,
          createdAt: data['createdAt'],
          semiFinishedGoodsUsed: (data['semiFinishedGoodsUsed'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
          packagingMaterialsUsed: (data['packagingMaterialsUsed'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
          additionalRawMaterialsUsed:
              (data['additionalRawMaterialsUsed'] as List?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList(),
          cuttingWastage: data['cuttingWastage'],
        );
      }).toList();

      // DEDUPLICATE remote logs
      return deduplicate(remoteLogs, (log) => log.id);
    } catch (e) {
      throw handleError(e, 'getDetailedProductionLogs');
    }
  }

  Future<bool> addProductionTarget({
    required String productId,
    required String productName,
    required String targetDate,
    required int targetQuantity,
  }) async {
    try {
      // TASK-16: Reject non-positive target quantities
      if (targetQuantity <= 0) {
        throw ArgumentError.value(
          targetQuantity,
          'targetQuantity',
          'Production target quantity must be greater than zero',
        );
      }

      await _capabilityGuard.requireCapability(
        RoleCapability.productionTargetMutate,
        operation: 'create production target',
      );
      final now = DateTime.now();
      final targetId = generateId();

      final entity = ProductionTargetEntity()
        ..id = targetId
        ..productId = productId
        ..productName = productName
        ..targetDate = targetDate
        ..targetQuantity = targetQuantity
        ..achievedQuantity = 0
        ..status = 'active'
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;

      // 1. Save to Isar
      await _dbService.db.writeTxn(() async {
        await _dbService.productionTargets.put(entity);
      });

      // 2. Sync
      await syncToFirebase(
        'add',
        entity.toFirebaseJson(),
        collectionName: productionTargetsCollection,
      );
      return true;
    } catch (e) {
      handleError(e, 'addProductionTarget');
      return false;
    }
  }

  Future<bool> deleteProductionTarget(String id) async {
    try {
      await _capabilityGuard.requireCapability(
        RoleCapability.productionTargetMutate,
        operation: 'delete production target',
      );
      final now = DateTime.now();
      // 1. Soft delete Local (Isar)
      await _dbService.db.writeTxn(() async {
        final entity = await _dbService.productionTargets.get(fastHash(id));
        if (entity == null) return;
        entity
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await _dbService.productionTargets.put(entity);
      });

      // 2. Sync
      await syncToFirebase('delete', {
        'id': id,
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      }, collectionName: productionTargetsCollection);
      return true;
    } catch (e) {
      handleError(e, 'deleteProductionTarget');
      return false;
    }
  }

  // Logs
  Future<bool> addDetailedProductionLog(
    AddDetailedProductionLogPayload log,
  ) async {
    try {
      try {
        await _capabilityGuard.requireCapability(
          RoleCapability.productionLogMutate,
          operation: 'create detailed production log',
        );
      } catch (e) {
        final isAuthRequiredError = e.toString().contains(
          'Authentication required',
        );
        final hasSupervisorContext =
            log.supervisorId.trim().isNotEmpty &&
            log.supervisorName.trim().isNotEmpty;
        if (!(isAuthRequiredError &&
            auth?.currentUser == null &&
            hasSupervisorContext)) {
          rethrow;
        }
        AppLogger.warning(
          'Proceeding without authenticated actor for production log write; '
          'using supervisor payload context.',
          tag: 'Security',
        );
      }
      final now = getCurrentTimestamp();
      final logId = generateId();
      final issueId = generateId();

      // Determine warehouse from supervisor assignment
      String targetWarehouseId = 'Main';
      try {
        final supervisorEntity = await _dbService.users.get(
          fastHash(log.supervisorId),
        );
        if (supervisorEntity?.assignedWarehouseId != null &&
            supervisorEntity!.assignedWarehouseId!.isNotEmpty) {
          targetWarehouseId = supervisorEntity.assignedWarehouseId!;
          AppLogger.info(
            'Production entry auto-assigned to warehouse: $targetWarehouseId',
            tag: 'Production',
          );
        }
      } catch (e) {
        AppLogger.warning(
          'Could not fetch supervisor warehouse assignment, using Main',
          tag: 'Production',
        );
      }

      // 1. Process Stock Adjustments (Local + Sync Log) via InventoryService
      // A. Consolidate Raw Materials (OUT)
      final rawMaterials = <Map<String, dynamic>>[];

      void collect(
        List<Map<String, dynamic>>? list,
        String key,
        String nameKey,
      ) {
        if (list == null) return;
        for (var m in list) {
          rawMaterials.add({
            'productId': m[key],
            'name': m[nameKey] ?? 'Unknown Material',
            'quantity': (m['quantity'] as num).toDouble(),
            'movementType': 'out',
            'unit': m['unit'] ?? 'Unit',
          });
        }
      }

      collect(log.semiFinishedGoodsUsed, 'productId', 'productName');
      collect(log.packagingMaterialsUsed, 'materialId', 'materialName');
      collect(log.additionalRawMaterialsUsed, 'materialId', 'materialName');

      // B. Finished Goods (IN)
      final finishedGoods = {
        'productId': log.productId,
        'name': log.productName,
        'quantity': log.totalBatchQuantity.toDouble(),
        'movementType': 'in',
        'unit': log.unit,
      };

      // C. Wastage (IN - Credit)
      Map<String, dynamic>? wastageCredit;
      if (log.cuttingWastage != null &&
          (log.cuttingWastage!['quantity'] as num) > 0) {
        wastageCredit = {
          'productId': log.cuttingWastage!['materialId'],
          'name': log.cuttingWastage!['materialName'] ?? 'Wastage Material',
          'quantity': (log.cuttingWastage!['quantity'] as num).toDouble(),
          'movementType': 'in',
          'unit': 'Kg',
        };
      }

      // C.1 Strict Local Stock Validation (Offline Safety)
      // Check if we have enough raw materials locally
      for (var rm in rawMaterials) {
        final pId = rm['productId'];
        final qty = rm['quantity'] as double;
        final name = rm['name'];

        final productEntity = await _dbService.products.get(fastHash(pId));
        final currentStock = productEntity?.stock ?? 0.0;

        if (currentStock < qty) {
          throw Exception(
            "Insufficient raw material stock for $name.\nRequired: $qty\nAvailable: $currentStock",
          );
        }
      }

      // D. Apply Adjustments
      final allItems = [...rawMaterials, finishedGoods];
      if (wastageCredit != null) {
        allItems.add(wastageCredit);
      }

      // D. ATOMIC TRANSACTION: Stocks + Targets + Logs + Ledger
      await _dbService.db.writeTxn(() async {
        // 1. Process Stock & Ledger
        for (var item in allItems) {
          final pId = item['productId'];
          final qty = (item['quantity'] as num).toDouble();
          final type = item['movementType']; // 'in' or 'out'
          final name = item['name'];
          final unit = item['unit'] ?? 'Unit';

          final product = await _dbService.products.get(fastHash(pId));
          var currentStock = product?.stock ?? 0.0;

          // Re-check Constraint inside Txn
          if (type == 'out' && currentStock < qty) {
            throw Exception(
              "Insufficient raw material stock for $name. Available: $currentStock",
            );
          }

          final change = type == 'in' ? qty : -qty;
          final updatedProduct = await _inventoryService
              .applyProductStockChangeInTxn(
                productId: pId,
                quantityChange: change,
                updatedAt: DateTime.parse(now),
                markSyncPending: true,
                allowMissing: true,
              );

          // Create Ledger Entry
          final runningBalance =
              updatedProduct?.stock ?? (product?.stock ?? 0.0);
          final ledger = StockLedgerEntity()
            ..id = generateId()
            ..productId = pId
            ..warehouseId = targetWarehouseId
            ..transactionDate = DateTime.parse(now)
            ..transactionType = 'PRODUCTION_${type.toUpperCase()}'
            ..quantityChange = type == 'in' ? qty : -qty
            ..runningBalance = runningBalance
            ..unit = unit
            ..performedBy = log.supervisorId
            ..notes = 'Production Batch: ${log.batchNumber} ($type) - Warehouse: $targetWarehouseId'
            ..referenceId = logId
            ..syncStatus = SyncStatus.pending
            ..updatedAt = DateTime.parse(now);

          await _dbService.stockLedger.put(ledger);
        }

        // 2. Update Production Target
        final today = now.split('T')[0];
        final allTargets = await _dbService.productionTargets.where().findAll();
        final targetToUpdate = allTargets
            .cast<ProductionTargetEntity?>()
            .firstWhere(
              (t) => t!.productId == log.productId && t.targetDate == today,
              orElse: () => null,
            );

        if (targetToUpdate != null) {
          targetToUpdate.achievedQuantity =
              targetToUpdate.achievedQuantity + log.totalBatchQuantity;
          targetToUpdate.syncStatus = SyncStatus.pending;
          await _dbService.productionTargets.put(targetToUpdate);
        }

        // 3. Create Detailed Log
        final entity = DetailedProductionLogEntity()
          ..id = logId
          ..batchNumber = log.batchNumber
          ..productId = log.productId
          ..productName = log.productName
          ..totalBatchQuantity = log.totalBatchQuantity
          ..unit = log.unit
          ..supervisorId = log.supervisorId
          ..supervisorName = log.supervisorName
          ..issueId = issueId
          ..totalBatchCost = 0.0
          ..costPerUnit = 0.0
          ..createdAt = DateTime.parse(now)
          ..updatedAt = DateTime.parse(now)
          ..semiFinishedGoodsUsed = (log.semiFinishedGoodsUsed ?? [])
              .map((e) => ProductionMaterialItem.fromJson(e))
              .toList()
          ..packagingMaterialsUsed = (log.packagingMaterialsUsed ?? [])
              .map((e) => ProductionMaterialItem.fromJson(e))
              .toList()
          ..additionalRawMaterialsUsed = (log.additionalRawMaterialsUsed ?? [])
              .map((e) => ProductionMaterialItem.fromJson(e))
              .toList()
          ..cuttingWastage = log.cuttingWastage != null
              ? ProductionMaterialItem.fromJson(log.cuttingWastage!)
              : null
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;

        await _dbService.detailedProductionLogs.put(entity);
      });

      // 4. Enqueue durable sync command
      final logData = {
        'id': logId,
        'batchNumber': log.batchNumber,
        'productId': log.productId,
        'productName': log.productName,
        'totalBatchQuantity': log.totalBatchQuantity,
        'unit': log.unit,
        'supervisorId': log.supervisorId,
        'supervisorName': log.supervisorName,
        'issueId': issueId,
        'totalBatchCost': 0.0,
        'costPerUnit': 0.0,
        'createdAt': now,
        'semiFinishedGoodsUsed': log.semiFinishedGoodsUsed,
        'packagingMaterialsUsed': log.packagingMaterialsUsed,
        'additionalRawMaterialsUsed': log.additionalRawMaterialsUsed,
        'cuttingWastage': log.cuttingWastage,
        'isSynced': false,
      };
      final queueId = 'production_log_$logId';
      await _enqueueSyncCommand(
        queueId: queueId,
        collection: detailedProductionLogsCollection,
        action: 'add',
        payload: logData,
      );

      return true;
    } catch (e) {
      handleError(e, 'addDetailedProductionLog');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyEntries({
    required DateTime startDate,
    required DateTime endDate,
    String? departmentCode,
  }) async {
    try {
      // 1. Local (Isar)
      // Use Dart filtering for simplicity
      final allEntities = await _dbService.productionEntries.where().findAll();

      var entities = allEntities;
      final start = startDate.toIso8601String().split('T')[0];
      final end = endDate.toIso8601String().split('T')[0];

      // Filter by date (date stored as YYYY-MM-DD string? No, Entity has DateTime date)
      // Let's check entity schema. ProductionDailyEntryEntity has DateTime date.
      // But we just want YYYY-MM-DD comparison.

      entities = entities.where((e) {
        final d = e.date.toIso8601String().split('T')[0];
        return d.compareTo(start) >= 0 && d.compareTo(end) <= 0;
      }).toList();

      if (departmentCode != null) {
        entities = entities
            .where((e) => e.departmentCode == departmentCode)
            .toList();
      }

      return entities.map((e) => e.toFirebaseJson()).toList();
    } catch (e) {
      handleError(e, 'getProductionDailyEntries');
      return [];
    }
  }

  Future<void> saveDailyEntry(Map<String, dynamic> entryData) async {
    try {
      await _capabilityGuard.requireCapability(
        RoleCapability.productionLogMutate,
        operation: 'save production daily entry',
      );
      final normalizedData = Map<String, dynamic>.from(entryData);
      final nowIso = DateTime.now().toIso8601String();
      final createdAt = normalizedData['createdAt'];
      final updatedAt = normalizedData['updatedAt'];
      normalizedData['createdAt'] = createdAt is DateTime
          ? createdAt.toIso8601String()
          : (createdAt?.toString().isNotEmpty == true
                ? createdAt.toString()
                : nowIso);
      normalizedData['updatedAt'] = updatedAt is DateTime
          ? updatedAt.toIso8601String()
          : (updatedAt?.toString().isNotEmpty == true
                ? updatedAt.toString()
                : nowIso);

      // 1. Update Local (Isar)
      final entity = ProductionDailyEntryEntity.fromFirebaseJson(
        normalizedData,
      );

      await _dbService.db.writeTxn(() async {
        await _dbService.productionEntries.put(entity);
      });

      // 2. Sync
      final firestore = db;
      if (firestore != null) {
        await firestore
            .collection(productionEntriesCollection)
            .doc(normalizedData['id'])
            .set(normalizedData, fs.SetOptions(merge: true));
      }
    } catch (e) {
      // Offline fallback is already handled by local Isar save
      handleError(e, 'saveProductionDailyEntry');
    }
  }
}
