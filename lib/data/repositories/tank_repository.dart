import 'package:isar/isar.dart';
import '../local/entities/tank_entity.dart';
import '../local/entities/tank_lot_entity.dart';
import '../local/entities/tank_transaction_entity.dart';
import '../../services/database_service.dart';
import '../../services/tank_service.dart';
import '../../services/inventory_movement_engine.dart';
import '../../services/inventory_projection_service.dart';
import '../../core/firebase/firebase_config.dart';
import '../local/base_entity.dart';
import '../../utils/storage_unit_helper.dart';
import '../local/entities/stock_balance_entity.dart';
import 'dart:developer' as developer;

class TankRepository {
  final DatabaseService _dbService;
  final TankService _tankService;
  late final InventoryProjectionService _inventoryProjectionService;
  late final InventoryMovementEngine _inventoryMovementEngine;

  TankRepository(
    this._dbService,
    FirebaseServices firebase, {
    TankService? tankService,
    InventoryProjectionService? inventoryProjectionService,
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _tankService = tankService ?? TankService(firebase, _dbService) {
    _inventoryProjectionService =
        inventoryProjectionService ?? InventoryProjectionService(_dbService);
    _inventoryMovementEngine =
        inventoryMovementEngine ??
        InventoryMovementEngine(_dbService, _inventoryProjectionService);
  }

  String _tankInventoryLocationId(String tankId) => 'virtual:tank:$tankId';

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

  // --- TANK OPERATIONS ---

  Future<List<Tank>> getTanks({String? bhattiName}) async {
    try {
      var query = _dbService.tanks.filter().isDeletedEqualTo(false);

      if (bhattiName != null && bhattiName.isNotEmpty) {
        query = query.assignedUnitEqualTo(bhattiName);
      }

      final entities = await query.findAll();
      final tanks = entities.map((TankEntity e) => e.toDomain()).toList();
      tanks.sort(Tank.compareByDisplayOrder);
      return tanks;
    } catch (e) {
      developer.log('Error getting tanks: $e');
      return [];
    }
  }

  Future<String?> saveTank(Tank tank) async {
    try {
      final normalizedId = tank.id.trim().isEmpty
          ? _tankService.generateId()
          : tank.id.trim();
      final normalizedTank = _normalizeTank(tank, forceId: normalizedId);
      final entity = TankEntity.fromDomain(normalizedTank);

      // 1. Save locally
      await _dbService.db.writeTxn(() async {
        await _dbService.tanks.put(entity);
      });

      // 2. Attempt push to Firebase (Offline handled by caller or SyncManager)
      try {
        await _tankService.createTank(normalizedTank);
        entity.syncStatus = SyncStatus.synced;
        await _dbService.db.writeTxn(() async {
          await _dbService.tanks.put(entity);
        });
      } catch (e) {
        developer.log('Firebase sync deferred: $e');
      }

      return normalizedId;
    } catch (e) {
      developer.log('Error saving tank: $e');
      return null;
    }
  }

  Future<void> updateTank(Tank tank) async {
    try {
      final normalizedTank = _normalizeTank(tank);
      final entity = TankEntity.fromDomain(normalizedTank);
      entity.syncStatus = SyncStatus.pending;

      // 1. Save locally
      await _dbService.db.writeTxn(() async {
        await _dbService.tanks.put(entity);
      });

      // 2. Sync to Firebase
      await _tankService.updateTank(normalizedTank);

      await _dbService.db.writeTxn(() async {
        entity.syncStatus = SyncStatus.synced;
        await _dbService.tanks.put(entity);
      });
    } catch (e) {
      developer.log('Error updating tank: $e');
      rethrow;
    }
  }

  Future<void> deleteTank(String tankId) async {
    try {
      // Deletes locally using soft-delete + queues for Firebase via TankService
      await _tankService.deleteTank(tankId);
    } catch (e) {
      developer.log('Error deleting tank: $e');
      rethrow;
    }
  }

  Future<void> refillTank({
    required String tankId,
    required double quantity,
    required String referenceId,
    required String operatorId,
    required String operatorName,
    String? supplierId,
    String? supplierName,
  }) async {
    try {
      // 0. Get tank details to find material
      final tank = await _dbService.tanks.getById(tankId);
      if (tank == null) {
        throw Exception('Tank not found: $tankId');
      }

      // 1. Deduct from purchase stock FIRST (atomic transaction)
      var inventoryAlreadyApplied = false;
      await _ensureWarehouseLocationReady();
      await _dbService.db.writeTxn(() async {
        // Find product by material name (case-insensitive)
        final products = await _dbService.products.where().findAll();

        final product = products.firstWhere(
          (p) =>
              !p.isDeleted &&
              p.name.toLowerCase() == tank.materialName.toLowerCase(),
          orElse: () => throw Exception(
            'Product not found for material: ${tank.materialName}',
          ),
        );

        final currentStock = product.stock ?? 0.0;
        if (currentStock < quantity) {
          throw Exception(
            'Insufficient purchase stock for ${tank.materialName}. Available: $currentStock, Required: $quantity',
          );
        }

        final occurredAt = DateTime.now();
        final inventoryCommand = InventoryCommand.internalTransfer(
          sourceLocationId: InventoryProjectionService.warehouseMainLocationId,
          destinationLocationId: _tankInventoryLocationId(tankId),
          referenceId: referenceId,
          productId: product.id,
          quantityBase: quantity,
          actorUid: operatorId.trim().isEmpty ? 'system' : operatorId.trim(),
          reasonCode: 'tank_refill',
          referenceType: 'tank_refill',
          createdAt: occurredAt,
        );
        final existingCommand = await _dbService.inventoryCommands.get(
          fastHash(inventoryCommand.commandId),
        );
        if (existingCommand?.appliedLocally == true) {
          inventoryAlreadyApplied = true;
          return;
        }
        await _seedWarehouseBalanceInTxn(
          productId: product.id,
          occurredAt: occurredAt,
        );
        await _inventoryMovementEngine.applyCommandInTxn(inventoryCommand);

        // T9-P4 REMOVED: direct local purchase-stock mutation is replaced by
        // the InventoryMovementEngine internal_transfer above.
        // product.stock = currentStock - quantity;
        // product.updatedAt = DateTime.now();
        // product.syncStatus = SyncStatus.pending;
        // await _dbService.products.put(product);
      });

      if (inventoryAlreadyApplied) {
        return;
      }

      // 2. Perform remote operation (Server ensures consistency/lots)
      final success = await _tankService.fillTank(
        tankId: tankId,
        quantity: quantity,
        referenceId: referenceId,
        operatorId: operatorId,
        operatorName: operatorName,
        supplierId: supplierId,
        supplierName: supplierName,
      );
      if (!success) {
        throw Exception(
          'Tank refill failed: unable to reach remote data source',
        );
      }

      // 3. Update local tank state and lot history
      await _dbService.db.writeTxn(() async {
        final now = DateTime.now();
        final tankEntity = await TankEntityQueryWhere(
          _dbService.tanks.where(),
        ).idEqualTo(tankId).findFirst();
        if (tankEntity != null) {
          final previousStock = tankEntity.currentStock;
          final newStockRaw = previousStock + quantity;
          final capacity = tankEntity.capacity;
          final newStock = capacity > 0
              ? newStockRaw.clamp(0.0, capacity).toDouble()
              : newStockRaw;
          final fillLevel = capacity > 0 ? (newStock / capacity) * 100 : 0.0;

          tankEntity.currentStock = newStock;
          tankEntity.fillLevel = fillLevel;
          tankEntity.status = _statusForFillLevel(fillLevel);
          tankEntity.unit = StorageUnitHelper.tonUnit;
          tankEntity.updatedAt = now;
          tankEntity.syncStatus = SyncStatus.synced;
          await _dbService.tanks.put(tankEntity);

          final lotId = 'lot_${now.microsecondsSinceEpoch}';
          final lotEntity = TankLotEntity()
            ..id = lotId
            ..tankId = tankId
            ..materialId = tankEntity.materialId
            ..materialName = tankEntity.materialName
            ..supplierId = supplierId ?? 'Unknown'
            ..supplierName = supplierName ?? 'Manual Refill'
            ..purchaseOrderId = referenceId
            ..receivedDate = now
            ..quantity = quantity
            ..initialQuantity = quantity
            ..status = 'active'
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced;
          await _dbService.tankLots.put(lotEntity);

          final txEntity = TankTransactionEntity()
            ..id = 'tx_${now.microsecondsSinceEpoch}'
            ..tankId = tankId
            ..tankName = tankEntity.name
            ..type = 'fill'
            ..quantity = quantity
            ..previousStock = previousStock
            ..newStock = newStock
            ..materialId = tankEntity.materialId
            ..materialName = tankEntity.materialName
            ..referenceId = referenceId
            ..referenceType = 'issue'
            ..operatorId = operatorId
            ..operatorName = operatorName
            ..lotId = lotId
            ..timestamp = now
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced;
          await _dbService.tankTransactions.put(txEntity);
        }
      });
    } catch (e) {
      developer.log('Error refilling tank: $e');
      rethrow;
    }
  }

  // --- TRANSACTION OPERATIONS ---

  Future<void> saveTransaction(TankTransactionEntity transaction) async {
    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.tankTransactions.put(transaction);
      });
    } catch (e) {
      developer.log('Error saving transaction: $e');
    }
  }

  // --- SYNC HELPERS ---

  Future<void> fetchAndCacheTanks({String? bhattiName}) async {
    try {
      final remoteTanks = await _tankService.fetchRemoteTanks(
        bhattiName: bhattiName,
      );
      final remoteIds = remoteTanks.map((t) => t.id).toSet();

      await _dbService.db.writeTxn(() async {
        // Protect pending changes
        final pendingEntities = await _dbService.tanks
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .findAll();
        final pendingIds = pendingEntities.map((e) => e.id).toSet();

        // 1. Update/insert tanks from remote that aren't pending locally
        final entitiesToUpdate = remoteTanks
            .where((t) => !pendingIds.contains(t.id))
            .map((t) {
              final entity = TankEntity.fromDomain(_normalizeTank(t));
              entity.syncStatus = SyncStatus.synced;
              return entity;
            })
            .toList();
        await _dbService.tanks.putAll(entitiesToUpdate);

        // 2. Mark local synced tanks as deleted if they no longer exist on remote
        final allLocalSynced = await _dbService.tanks
            .filter()
            .syncStatusEqualTo(SyncStatus.synced)
            .findAll();
        for (var local in allLocalSynced) {
          if (!remoteIds.contains(local.id)) {
            local.isDeleted = true;
            await _dbService.tanks.put(local);
          }
        }
      });
    } catch (e) {
      developer.log('Error caching tanks: $e');
    }
  }

  Tank _normalizeTank(Tank tank, {String? forceId}) {
    final canonicalId = forceId ?? tank.id;
    final boundedFill = tank.capacity > 0
        ? ((tank.currentStock / tank.capacity) * 100)
              .clamp(0.0, 100.0)
              .toDouble()
        : 0.0;

    return Tank(
      id: canonicalId,
      name: tank.name,
      materialId: tank.materialId,
      materialName: tank.materialName,
      capacity: tank.capacity,
      currentStock: tank.currentStock,
      fillLevel: boundedFill,
      status: _statusForFillLevel(boundedFill),
      unit: StorageUnitHelper.tonUnit,
      updatedAt: tank.updatedAt,
      createdAt: tank.createdAt,
      department: tank.department,
      assignedUnit: tank.assignedUnit,
      type: tank.type,
      bags: tank.bags,
      maxBags: tank.maxBags,
      minStockLevel: tank.minStockLevel,
      isBhattiSourced: tank.isBhattiSourced,
    );
  }

  String _statusForFillLevel(double fillLevel) {
    if (fillLevel < 5) return 'critical';
    if (fillLevel < 15) return 'low-stock';
    return 'active';
  }
}
