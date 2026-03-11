import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../models/types/production_types.dart';
import '../data/local/base_entity.dart';
import 'database_service.dart';
import 'department_master_service.dart';
import 'inventory_movement_engine.dart';
import 'inventory_projection_service.dart';
import '../data/local/entities/stock_balance_entity.dart';

const String productionBatchesCollection = 'production_batches';

class ProductionBatchService extends BaseService {
  final DatabaseService _dbService;
  late final DepartmentMasterService _departmentMasterService;
  late final InventoryProjectionService _inventoryProjectionService;
  late final InventoryMovementEngine _inventoryMovementEngine;

  ProductionBatchService(
    super.firebase, {
    DatabaseService? dbService,
    DepartmentMasterService? departmentMasterService,
    InventoryProjectionService? inventoryProjectionService,
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _dbService = dbService ?? DatabaseService.instance {
    _departmentMasterService =
        departmentMasterService ?? DepartmentMasterService(_dbService);
    _inventoryProjectionService =
        inventoryProjectionService ??
        InventoryProjectionService(
          _dbService,
          departmentMasterService: _departmentMasterService,
        );
    _inventoryMovementEngine =
        inventoryMovementEngine ??
        InventoryMovementEngine(_dbService, _inventoryProjectionService);
  }

  // Generate Batch Number
  String generateBatchNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = (now.month).toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (100 + DateTime.now().millisecond % 900).toString().padLeft(
      3,
      '0',
    );
    return 'B$year$month$day-$random';
  }

  // Generate SHA256 Hash for Genealogy
  Future<String> generateBatchGeneId(String input) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (1000 + DateTime.now().microsecond % 9000).toString();
    final data = '$input-$timestamp-$random';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _resolveDepartmentLocationId({
    required String departmentId,
    required String departmentName,
  }) {
    final byId = _departmentMasterService.resolveCanonicalDepartmentId(
      departmentId,
    );
    if (byId != null) {
      return byId;
    }
    final byName = _departmentMasterService.resolveCanonicalDepartmentId(
      departmentName,
    );
    if (byName != null) {
      return byName;
    }
    throw StateError(
      'Canonical department location not found for $departmentId / $departmentName',
    );
  }

  Future<void> _ensureDepartmentLocationReady(String locationId) async {
    final existing = await _dbService.inventoryLocations.get(
      fastHash(locationId),
    );
    if (existing != null) {
      return;
    }
    await _inventoryProjectionService.ensureCanonicalFoundation();
    final refreshed = await _dbService.inventoryLocations.get(
      fastHash(locationId),
    );
    if (refreshed == null) {
      throw StateError('Inventory location not found: $locationId');
    }
  }

  Future<void> _ensureWarehouseLocationReady() async {
    final existing = await _dbService.inventoryLocations.get(
      fastHash(InventoryProjectionService.warehouseMainLocationId),
    );
    if (existing != null) {
      return;
    }
    await _inventoryProjectionService.ensureCanonicalFoundation();
  }

  Future<void> _seedWarehouseBalanceInTxn({
    required String productId,
    required DateTime occurredAt,
  }) async {
    final balanceId = StockBalanceEntity.composeId(
      InventoryProjectionService.warehouseMainLocationId,
      productId,
    );
    final existing = await _dbService.stockBalances.get(fastHash(balanceId));
    if (existing != null) {
      return;
    }
    final product = await _dbService.products.get(fastHash(productId));
    final balance = StockBalanceEntity()
      ..id = balanceId
      ..locationId = InventoryProjectionService.warehouseMainLocationId
      ..productId = productId
      ..quantity = product?.stock ?? 0.0
      ..updatedAt = occurredAt
      ..syncStatus = product?.syncStatus ?? SyncStatus.pending
      ..isDeleted = false;
    await _dbService.stockBalances.put(balance);
  }

  Future<void> _applyCuttingBatchIssueInventory({
    required String batchId,
    required String departmentId,
    required String departmentName,
    required String productId,
    required double quantity,
    required String actorUid,
    required DateTime occurredAt,
  }) async {
    if (quantity <= 0) {
      return;
    }
    final departmentLocationId = _resolveDepartmentLocationId(
      departmentId: departmentId,
      departmentName: departmentName,
    );
    await _ensureWarehouseLocationReady();
    await _ensureDepartmentLocationReady(departmentLocationId);
    await _dbService.db.writeTxn(() async {
      await _seedWarehouseBalanceInTxn(
        productId: productId,
        occurredAt: occurredAt,
      );
      final command = InventoryCommand.departmentIssue(
        departmentLocationId: departmentLocationId,
        referenceId: batchId,
        productId: productId,
        quantityBase: quantity,
        actorUid: actorUid,
        createdAt: occurredAt,
      );
      await _inventoryMovementEngine.applyCommandInTxn(command);
    });
  }

  Future<void> _applyCuttingBatchReadyInventory({
    required String batchId,
    required String departmentId,
    required String departmentName,
    required String productId,
    required double quantity,
    required String actorUid,
    required DateTime occurredAt,
  }) async {
    if (quantity <= 0) {
      return;
    }
    final departmentLocationId = _resolveDepartmentLocationId(
      departmentId: departmentId,
      departmentName: departmentName,
    );
    await _ensureWarehouseLocationReady();
    await _ensureDepartmentLocationReady(departmentLocationId);
    await _dbService.db.writeTxn(() async {
      final command = InventoryCommand.departmentReturn(
        departmentLocationId: departmentLocationId,
        referenceId: batchId,
        productId: productId,
        quantityBase: quantity,
        actorUid: actorUid,
        createdAt: occurredAt,
      );
      final existingCommand = await _dbService.inventoryCommands.get(
        fastHash(command.commandId),
      );
      if (existingCommand?.appliedLocally == true) {
        return;
      }
      final balanceId = StockBalanceEntity.composeId(
        departmentLocationId,
        productId,
      );
      final existingBalance = await _dbService.stockBalances.get(
        fastHash(balanceId),
      );
      if ((existingBalance?.quantity ?? 0.0) < quantity - 1e-9) {
        final stagedBalance = existingBalance ?? StockBalanceEntity();
        stagedBalance
          ..id = balanceId
          ..locationId = departmentLocationId
          ..productId = productId
          ..quantity = quantity
          ..updatedAt = occurredAt
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;
        await _dbService.stockBalances.put(stagedBalance);
      }
      await _inventoryMovementEngine.applyCommandInTxn(command);
    });
  }

  // Create Production Batch
  Future<bool> createProductionBatch({
    required String semiFinishedProductId,
    required String semiFinishedProductName,
    required String departmentId,
    required String departmentName,
    required String finishedGoodId,
    required String finishedGoodName,
    required int numberOfBatches,
    required int weightPerUnitGrams,
    int? physicalFinishedQty,
  }) async {
    final authUser = auth?.currentUser;
    if (authUser == null) {
      handleError('Authentication required', 'createProductionBatch');
      return false;
    }

    try {
      final batchNumber = generateBatchNumber();
      final batchGeneId = await generateBatchGeneId(semiFinishedProductId);

      // Calculate planned quantity from number of batches
      final plannedQty =
          numberOfBatches * 100; // Each batch = 100 units (standard)

      // Calculate cutting wastage if physical finished qty is provided
      final actualPhysicalFinishedQty = physicalFinishedQty ?? 0;
      final cuttingQty = actualPhysicalFinishedQty;

      // Wastage calculation: (Expected - Actual) / Expected * 100
      // Expected per batch = 100 units, so for N batches = N * 100
      final expectedQty = numberOfBatches * 100;
      final cuttingWastageDrums = actualPhysicalFinishedQty > 0
          ? (expectedQty - actualPhysicalFinishedQty) ~/ 100
          : 0;
      final cuttingWastageKg =
          cuttingWastageDrums * 100.0; // Each drum = 100 kg

      final now = DateTime.now().toIso8601String();

      final newBatch = {
        'batchNumber': batchNumber,
        'batchGeneId': batchGeneId,

        // Source
        'semiFinishedProductId': semiFinishedProductId,
        'semiFinishedProductName': semiFinishedProductName,
        'departmentId': departmentId,
        'departmentName': departmentName,

        // Output
        'finishedGoodId': finishedGoodId,
        'finishedGoodName': finishedGoodName,

        // Quantities
        'plannedQty': plannedQty,
        'cuttingQty': cuttingQty,
        'physicalFinishedQty': actualPhysicalFinishedQty,
        'weightPerUnitGrams': weightPerUnitGrams,

        // Wastage
        'cuttingWastageDrums': cuttingWastageDrums,
        'cuttingWastageKg': cuttingWastageKg,

        // Mass Balance (initialized)
        'batchTotalKg': 0.0,
        'expectedOutputKg': 0.0,
        'actualOutputKg': 0.0,
        'lossKg': 0.0,
        'efficiencyPercent': 0.0,

        // Pipeline
        'stage': 'CUTTING',

        // Timestamps
        'cuttingStartedAt': now,

        // Audit
        'supervisorId': authUser.uid,
        'supervisorName': authUser.displayName ?? 'Supervisor',
        'createdAt': now,
        'updatedAt': now,
      };

      final firestore = db;
      if (firestore == null) return false;

      final batchRef = firestore.collection(productionBatchesCollection).doc();
      final semiProductRef = firestore
          .collection('products')
          .doc(semiFinishedProductId);

      final bool isWindows =
          defaultTargetPlatform == TargetPlatform.windows && !kIsWeb;

      if (isWindows) {
        // Windows Desktop: Use Batch instead of Transaction to avoid FFI segfault
        final semiProductDoc = await semiProductRef.get();
        if (!semiProductDoc.exists) {
          throw Exception('Semi-finished product not found');
        }

        final currentStock = (semiProductDoc.data()?['stock'] ?? 0) as int;
        if (currentStock < numberOfBatches) {
          throw Exception(
            'Insufficient stock. Available: $currentStock, Required: $numberOfBatches',
          );
        }

        final batch = firestore.batch();
        batch.set(batchRef, newBatch);
        // T9-P4 REMOVED: direct Firestore semi-finished stock decrement is
        // replaced by the InventoryMovementEngine department_issue command.
        // batch.update(semiProductRef, {
        //   'stock': FieldValue.increment(-numberOfBatches),
        //   'updatedAt': FieldValue.serverTimestamp(),
        // });
        await batch.commit();

        // Audit log (outside batch since it's a separate collection/add)
        await createAuditLog(
          collectionName: productionBatchesCollection,
          docId: batchRef.id,
          action: 'create',
          changes: {
            'batchNumber': {'oldValue': null, 'newValue': batchNumber},
            'finishedGoodName': {
              'oldValue': null,
              'newValue': finishedGoodName,
            },
            'semiFinishedStockReduced': {
              'oldValue': currentStock,
              'newValue': currentStock - numberOfBatches,
            },
          },
          userId: authUser.uid,
          userName: authUser.displayName,
        );
      } else {
        await firestore.runTransaction((transaction) async {
          // Get current semi-finished product stock
          final semiProductDoc = await transaction.get(semiProductRef);
          if (!semiProductDoc.exists) {
            throw Exception('Semi-finished product not found');
          }

          final currentStock = (semiProductDoc.data()?['stock'] ?? 0) as int;
          if (currentStock < numberOfBatches) {
            throw Exception(
              'Insufficient stock. Available: $currentStock, Required: $numberOfBatches',
            );
          }

          // Create the production batch
          transaction.set(batchRef, newBatch);

          // T9-P4 REMOVED: direct Firestore semi-finished stock decrement is
          // replaced by the InventoryMovementEngine department_issue command.
          // transaction.update(semiProductRef, {
          //   'stock': FieldValue.increment(-numberOfBatches),
          //   'updatedAt': FieldValue.serverTimestamp(),
          // });

          // Audit log
          await createAuditLog(
            collectionName: productionBatchesCollection,
            docId: batchRef.id,
            action: 'create',
            changes: {
              'batchNumber': {'oldValue': null, 'newValue': batchNumber},
              'finishedGoodName': {
                'oldValue': null,
                'newValue': finishedGoodName,
              },
              'semiFinishedStockReduced': {
                'oldValue': currentStock,
                'newValue': currentStock - numberOfBatches,
              },
            },
            userId: authUser.uid,
            userName: authUser.displayName,
          );
        });
      }

      await _applyCuttingBatchIssueInventory(
        batchId: batchRef.id,
        departmentId: departmentId,
        departmentName: departmentName,
        productId: semiFinishedProductId,
        quantity: numberOfBatches.toDouble(),
        actorUid: authUser.uid,
        occurredAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      handleError(e, 'createProductionBatch');
      return false;
    }
  }

  // Update Batch (for cutting completion, etc.)
  Future<bool> updateProductionBatch({
    required String id,
    int? cuttingQty,
    int? physicalFinishedQty,
    int? cuttingWastageDrums,
    ProductionStage? stage,
  }) async {
    final authUser = auth?.currentUser;
    if (authUser == null) {
      handleError('Authentication required', 'updateProductionBatch');
      return false;
    }

    try {
      final firestore = db;
      if (firestore == null) return false;

      final batchRef = firestore
          .collection(productionBatchesCollection)
          .doc(id);

      final bool isWindows =
          defaultTargetPlatform == TargetPlatform.windows && !kIsWeb;
      ProductionBatch? readyBatch;
      var readyFinishedQty = 0;

      if (isWindows) {
        final batchDoc = await batchRef.get();
        if (!batchDoc.exists) throw Exception('Batch not found');

        final batchData = batchDoc.data();
        final batch = ProductionBatch.fromJson({
          'id': batchDoc.id,
          ...batchData!,
        });

        final updates = _prepareBatchUpdates(
          batch,
          cuttingQty,
          physicalFinishedQty,
          cuttingWastageDrums,
          stage,
        );

        final writeBatch = firestore.batch();
        writeBatch.update(batchRef, updates);

        // Handle inventory logic for READY stage
        if (stage == ProductionStage.ready) {
          final finishedQty = physicalFinishedQty ?? batch.physicalFinishedQty;
          if (finishedQty > 0 && batch.finishedGoodId.isNotEmpty) {
            readyBatch = batch;
            readyFinishedQty = finishedQty;
            // T9-P4 REMOVED: direct Firestore finished-good stock increment is
            // replaced by the InventoryMovementEngine cutting_production_complete
            // output command after the batch update commits.
            // final finishedProductRef = firestore
            //     .collection('products')
            //     .doc(batch.finishedGoodId);
            // writeBatch.update(finishedProductRef, {
            //   'stock': FieldValue.increment(finishedQty),
            //   'updatedAt': FieldValue.serverTimestamp(),
            // });
          }
        }

        await writeBatch.commit();
      } else {
        await firestore.runTransaction((transaction) async {
          final batchDoc = await transaction.get(batchRef);
          if (!batchDoc.exists) throw Exception('Batch not found');

          final batchData = batchDoc.data();
          final batch = ProductionBatch.fromJson({
            'id': batchDoc.id,
            ...batchData!,
          });

          final updates = _prepareBatchUpdates(
            batch,
            cuttingQty,
            physicalFinishedQty,
            cuttingWastageDrums,
            stage,
          );

          transaction.update(batchRef, updates);

          // Handle inventory logic for READY stage
          if (stage == ProductionStage.ready) {
            final finishedQty =
                physicalFinishedQty ?? batch.physicalFinishedQty;
            if (finishedQty > 0 && batch.finishedGoodId.isNotEmpty) {
              readyBatch = batch;
              readyFinishedQty = finishedQty;
              // T9-P4 REMOVED: direct Firestore finished-good stock increment is
              // replaced by the InventoryMovementEngine cutting_production_complete
              // output command after the batch update commits.
              // final finishedProductRef = firestore
              //     .collection('products')
              //     .doc(batch.finishedGoodId);
              // transaction.update(finishedProductRef, {
              //   'stock': FieldValue.increment(finishedQty),
              //   'updatedAt': FieldValue.serverTimestamp(),
              // });
            }
          }
        });
      }

      if (readyBatch != null &&
          readyFinishedQty > 0 &&
          readyBatch!.finishedGoodId.isNotEmpty) {
        await _applyCuttingBatchReadyInventory(
          batchId: id,
          departmentId: readyBatch!.departmentId,
          departmentName: readyBatch!.departmentName,
          productId: readyBatch!.finishedGoodId,
          quantity: readyFinishedQty.toDouble(),
          actorUid: authUser.uid,
          occurredAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      handleError(e, 'updateProductionBatch');
      return false;
    }
  }

  Map<String, dynamic> _prepareBatchUpdates(
    ProductionBatch batch,
    int? cuttingQty,
    int? physicalFinishedQty,
    int? cuttingWastageDrums,
    ProductionStage? stage,
  ) {
    // Calculate mass balance if quantities provided
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (cuttingQty != null) updates['cuttingQty'] = cuttingQty;
    if (physicalFinishedQty != null) {
      updates['physicalFinishedQty'] = physicalFinishedQty;

      // Auto-calculate mass balance
      final weightPerUnitKg = batch.weightPerUnitGrams / 1000.0;
      final physicalProductionKg = physicalFinishedQty * weightPerUnitKg;
      final wastageKg =
          (cuttingWastageDrums ?? batch.cuttingWastageDrums) * 100.0;
      final actualOutputKg = physicalProductionKg + wastageKg;

      updates['physicalProductionKg'] = physicalProductionKg;
      updates['cuttingWastageKg'] = wastageKg;
      updates['actualOutputKg'] = actualOutputKg;
      updates['batchTotalKg'] = batch.batchTotalKg > 0
          ? batch.batchTotalKg
          : physicalProductionKg + wastageKg;
      updates['lossKg'] =
          (batch.batchTotalKg > 0 ? batch.batchTotalKg : 0) - actualOutputKg;
      updates['efficiencyPercent'] = batch.batchTotalKg > 0
          ? (physicalProductionKg / batch.batchTotalKg) * 100
          : 100.0;
    }

    if (cuttingWastageDrums != null) {
      updates['cuttingWastageDrums'] = cuttingWastageDrums;
    }

    if (stage != null) {
      updates['stage'] = stage.value;
      final now = DateTime.now().toIso8601String();

      // Update stage-specific timestamps
      if (stage == ProductionStage.qc) {
        updates['cuttingCompletedAt'] = now;
        updates['qcStartedAt'] = now;
      } else if (stage == ProductionStage.packing) {
        updates['qcCompletedAt'] = now;
        updates['packingStartedAt'] = now;
      } else if (stage == ProductionStage.ready) {
        updates['packingCompletedAt'] = now;
        updates['readyAt'] = now;
      } else if (stage == ProductionStage.dispatched) {
        updates['dispatchedAt'] = now;
      }
    }

    return updates;
  }

  // Fetch production batches query builder
  Query getProductionBatchesQuery({
    ProductionStage? stage,
    String? departmentId,
    int limit = 50,
  }) {
    final firestore = db;
    if (firestore == null) {
      // Return a dummy query or handle appropriately.
      // Since this returns Query, and we can't easily fake a Query from null db,
      // we might need to adjust the caller to handle null or return valid empty query if possible.
      // However, typical pattern here:
      throw Exception('Firestore not available');
    }

    Query query = firestore.collection(productionBatchesCollection);

    if (stage != null) {
      query = query.where('stage', isEqualTo: stage.value);
    }
    if (departmentId != null) {
      query = query.where('departmentId', isEqualTo: departmentId);
    }

    return query.limit(limit);
  }

  // Fetch production batches (one-time pull)
  Future<List<ProductionBatch>> getProductionBatches({
    ProductionStage? stage,
    String? departmentId,
    int limit = 50,
  }) async {
    try {
      final q = getProductionBatchesQuery(
        stage: stage,
        departmentId: departmentId,
        limit: limit,
      );
      final snapshot = await q.get();
      final batches = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return ProductionBatch.fromJson({'id': doc.id, ...data});
      }).toList();

      // Sort in memory to avoid index issues
      batches.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return batches;
    } catch (e) {
      handleError(e, 'getProductionBatches');
      return [];
    }
  }

  // Get single batch
  Future<ProductionBatch?> getProductionBatch(String id) async {
    try {
      final firestore = db;
      if (firestore == null) return null;

      final batchDoc = await firestore
          .collection(productionBatchesCollection)
          .doc(id)
          .get();
      if (!batchDoc.exists) return null;

      final data = batchDoc.data()!;
      return ProductionBatch.fromJson({'id': batchDoc.id, ...data});
    } catch (e) {
      handleError(e, 'getProductionBatch');
      return null;
    }
  }
}
