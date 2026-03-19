import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'offline_first_service.dart';
import '../data/local/entities/tank_lot_entity.dart';
import '../services/database_service.dart';
import '../data/local/entities/tank_entity.dart';
import '../data/local/entities/tank_transaction_entity.dart';
import '../data/local/entities/product_entity.dart';
import '../data/local/base_entity.dart';
import 'inventory_movement_engine.dart';
import 'inventory_projection_service.dart';
import '../data/local/entities/stock_balance_entity.dart';
import 'package:isar/isar.dart';
import '../utils/storage_unit_helper.dart';

const tanksCollection = 'tanks';
const tankTransactionsCollection = 'tank_transactions';
const tankTransfersCollection = 'tank_transfers';
const productsCollection = 'products';
const tankLotsCollection = 'tank_lots';

// Models
class Tank {
  final String id;
  final String name;
  final String materialId;
  final String materialName;
  final double capacity;
  final double currentStock;
  final double fillLevel;
  final String status; // 'active', 'low-stock', 'critical', 'inactive'
  final String unit;
  final String updatedAt;
  final bool isBhattiSourced;
  final double minStockLevel;
  final String createdAt;
  final String department;
  final String? assignedUnit; // Team/Sub-unit code (e.g., 'gita', 'radha')
  final String type; // 'tank' or 'godown'
  final int? bags; // For godowns
  final int? maxBags; // For godowns

  Tank({
    required this.id,
    required this.name,
    required this.materialId,
    required this.materialName,
    required this.capacity,
    required this.currentStock,
    required this.fillLevel,
    required this.status,
    required this.unit,
    required this.updatedAt,
    this.isBhattiSourced = false,
    this.minStockLevel = 0.0,
    required this.createdAt,
    this.department = 'Main',
    this.assignedUnit,
    this.type = 'tank',
    this.bags,
    this.maxBags,
  });

  factory Tank.fromJson(Map<String, dynamic> json) {
    return Tank(
      id: json['id'] as String,
      name: json['name'] as String,
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      currentStock: (json['currentStock'] as num).toDouble(),
      fillLevel: (json['fillLevel'] as num).toDouble(),
      status: json['status'] as String? ?? 'active',
      unit: StorageUnitHelper.tonUnit,
      updatedAt: json['updatedAt'] as String,
      isBhattiSourced: json['isBhattiSourced'] as bool? ?? false,
      minStockLevel: (json['minStockLevel'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      department: json['department'] as String? ?? 'Main',
      assignedUnit: json['assignedUnit'] as String?,
      type: json['type'] as String? ?? 'tank',
      bags: json['bags'] as int?,
      maxBags: json['maxBags'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'materialId': materialId,
      'materialName': materialName,
      'capacity': capacity,
      'currentStock': currentStock,
      'fillLevel': fillLevel,
      'status': status,
      'unit': StorageUnitHelper.tonUnit,
      'updatedAt': updatedAt,
      'isBhattiSourced': isBhattiSourced,
      'minStockLevel': minStockLevel,
      'createdAt': createdAt,
      'department': department,
      if (assignedUnit != null) 'assignedUnit': assignedUnit,
      'type': type,
      if (bags != null) 'bags': bags,
      if (maxBags != null) 'maxBags': maxBags,
    };
  }

  static int compareAlphaNumericText(String left, String right) {
    final tokenPattern = RegExp(r'(\d+)|(\D+)');
    final leftTokens = tokenPattern
        .allMatches(left.trim().toLowerCase())
        .map((m) => m.group(0)!)
        .toList();
    final rightTokens = tokenPattern
        .allMatches(right.trim().toLowerCase())
        .map((m) => m.group(0)!)
        .toList();
    final sharedLength = leftTokens.length < rightTokens.length
        ? leftTokens.length
        : rightTokens.length;

    for (var i = 0; i < sharedLength; i++) {
      final leftToken = leftTokens[i];
      final rightToken = rightTokens[i];
      final leftNumber = int.tryParse(leftToken);
      final rightNumber = int.tryParse(rightToken);

      final comparison = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : leftToken.compareTo(rightToken);
      if (comparison != 0) return comparison;
    }

    return leftTokens.length.compareTo(rightTokens.length);
  }

  static int compareByDisplayOrder(Tank a, Tank b) {
    final byDepartment = compareAlphaNumericText(a.department, b.department);
    if (byDepartment != 0) return byDepartment;

    final byName = compareAlphaNumericText(a.name, b.name);
    if (byName != 0) return byName;

    final byType = compareAlphaNumericText(a.type, b.type);
    if (byType != 0) return byType;

    return compareAlphaNumericText(a.id, b.id);
  }
}

class TankTransaction {
  final String id;
  final String tankId;
  final String tankName;
  final String type; // 'fill', 'consumption', 'adjustment'
  final double quantity;
  final double previousStock;
  final double newStock;
  final String materialId;
  final String materialName;
  final String referenceId;
  final String referenceType;
  final String operatorId;
  final String operatorName;
  final String? lotId;
  final String? supplierId;
  final String? supplierName;
  final String timestamp;

  TankTransaction({
    required this.id,
    required this.tankId,
    required this.tankName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.materialId,
    required this.materialName,
    required this.referenceId,
    required this.referenceType,
    required this.operatorId,
    required this.operatorName,
    this.lotId,
    this.supplierId,
    this.supplierName,
    required this.timestamp,
  });

  factory TankTransaction.fromJson(Map<String, dynamic> json) {
    return TankTransaction(
      id: json['id'] as String,
      tankId: json['tankId'] as String,
      tankName: json['tankName'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      previousStock: (json['previousStock'] as num).toDouble(),
      newStock: (json['newStock'] as num).toDouble(),
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      referenceId: json['referenceId'] as String,
      referenceType: json['referenceType'] as String,
      operatorId: json['operatorId'] as String,
      operatorName: json['operatorName'] as String,
      lotId: json['lotId'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }
}

class TankLot {
  final String id;
  final String tankId;
  final String materialId;
  final String materialName;
  final String supplierId;
  final String supplierName;
  final String purchaseOrderId;
  final DateTime receivedDate;
  final double quantity;
  final double initialQuantity;
  final String status;

  TankLot({
    required this.id,
    required this.tankId,
    required this.materialId,
    required this.materialName,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseOrderId,
    required this.receivedDate,
    required this.quantity,
    required this.initialQuantity,
    required this.status,
  });

  factory TankLot.fromJson(Map<String, dynamic> json) {
    return TankLot(
      id: json['id'] as String,
      tankId: json['tankId'] as String,
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      purchaseOrderId: json['purchaseOrderId'] as String? ?? 'N/A',
      receivedDate: DateTime.parse(json['receivedDate'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      initialQuantity: (json['initialQuantity'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}

class TankConsumptionResult {
  final TankEntity tank;
  final TankTransactionEntity transaction;
  final List<TankLotEntity> lots;
  final Map<String, dynamic> summary;

  TankConsumptionResult({
    required this.tank,
    required this.transaction,
    required this.lots,
    required this.summary,
  });
}

class TankService extends OfflineFirstService {
  final DatabaseService _db;
  late final InventoryProjectionService _inventoryProjectionService;
  late final InventoryMovementEngine _inventoryMovementEngine;
  bool _tankPermissionDenied = false;

  TankService(
    super.firebase,
    this._db, {
    InventoryProjectionService? inventoryProjectionService,
    InventoryMovementEngine? inventoryMovementEngine,
  }) {
    _inventoryProjectionService =
        inventoryProjectionService ?? InventoryProjectionService(_db);
    _inventoryMovementEngine =
        inventoryMovementEngine ??
        InventoryMovementEngine(_db, _inventoryProjectionService);
  }

  @override
  String get localStorageKey => 'local_tanks';

  String _statusForFillLevel(double fillLevel) {
    if (fillLevel < 5) return 'critical';
    if (fillLevel < 15) return 'low-stock';
    return 'active';
  }

  double _safeFillLevel({required double stock, required double capacity}) {
    if (capacity <= 0) return 0.0;
    return (stock / capacity) * 100;
  }

  String _tankInventoryLocationId(String tankId) => 'virtual:tank:$tankId';

  Future<void> _ensureWarehouseLocationReady() async {
    final existing = await _db.inventoryLocations.get(
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
    final existing = await _db.stockBalances.get(fastHash(balanceId));
    if (existing != null) {
      return;
    }
    final product = await _db.products.getById(productId);
    final balance = StockBalanceEntity()
      ..id = balanceId
      ..locationId = InventoryProjectionService.warehouseMainLocationId
      ..productId = productId
      ..quantity = product?.stock ?? 0.0
      ..updatedAt = occurredAt
      ..syncStatus = product?.syncStatus ?? SyncStatus.pending
      ..isDeleted = false;
    await _db.stockBalances.put(balance);
  }

  Map<String, dynamic> _tankLotSyncPayload(TankLotEntity lot) {
    return {
      'id': lot.id,
      'tankId': lot.tankId,
      'materialId': lot.materialId,
      'materialName': lot.materialName,
      'supplierId': lot.supplierId,
      'supplierName': lot.supplierName,
      'purchaseOrderId': lot.purchaseOrderId,
      'receivedDate': lot.receivedDate.toIso8601String(),
      'quantity': lot.quantity,
      'initialQuantity': lot.initialQuantity,
      'status': lot.status,
      'updatedAt': lot.updatedAt.toIso8601String(),
      'isDeleted': lot.isDeleted,
      'deletedAt': lot.deletedAt?.toIso8601String(),
    };
  }

  Future<void> _queueTankAndLotTransactionSync({
    required TankEntity tank,
    required TankTransactionEntity transaction,
    List<TankLotEntity> lots = const <TankLotEntity>[],
    List<Map<String, dynamic>> extraPayloads = const <Map<String, dynamic>>[],
    bool syncImmediately = true,
  }) async {
    await syncToFirebase(
      'update',
      tank.toDomain().toJson(),
      collectionName: tanksCollection,
      syncImmediately: syncImmediately,
    );

    for (final lot in lots) {
      await syncToFirebase(
        'set',
        _tankLotSyncPayload(lot),
        collectionName: tankLotsCollection,
        syncImmediately: syncImmediately,
      );
    }

    await syncToFirebase(
      'set',
      transaction.toFirebaseJson(),
      collectionName: tankTransactionsCollection,
      syncImmediately: syncImmediately,
    );

    for (final payload in extraPayloads) {
      final action = (payload['action'] as String?) ?? 'set';
      final collection = payload['collection'] as String?;
      final data = payload['data'] as Map<String, dynamic>?;
      if (collection == null || data == null) continue;
      await syncToFirebase(
        action,
        data,
        collectionName: collection,
        syncImmediately: syncImmediately,
      );
    }
  }

  Future<String> createTank(Tank tank) async {
    try {
      final existingId = tank.id.trim();
      final tankId = existingId.isEmpty ? generateId() : existingId;
      final now = DateTime.now();
      final fillLevel = tank.capacity > 0
          ? (tank.currentStock / tank.capacity) * 100
          : 0.0;

      final entity = TankEntity()
        ..id = tankId
        ..name = tank.name
        ..materialId = tank.materialId
        ..materialName = tank.materialName
        ..capacity = tank.capacity
        ..currentStock = tank.currentStock
        ..fillLevel = fillLevel
        ..status = tank.status
        ..unit = StorageUnitHelper.tonUnit
        ..department = tank.department
        ..assignedUnit = tank.assignedUnit
        ..type = tank.type
        ..bags = tank.bags
        ..maxBags = tank.maxBags
        ..minStockLevel = tank.minStockLevel
        ..isBhattiSourced = tank.isBhattiSourced
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;

      // 1. Save to Local
      await _db.db.writeTxn(() async {
        await _db.tanks.put(entity);
      });

      // 2. Queue for Firebase
      await syncToFirebase(
        'set',
        entity.toDomain().toJson(),
        collectionName: tanksCollection,
      );

      return tankId;
    } catch (e) {
      throw handleError(e, 'createTank');
    }
  }

  Future<void> updateTank(Tank tank) async {
    try {
      final now = DateTime.now();
      final normalizedFill = _safeFillLevel(
        stock: tank.currentStock,
        capacity: tank.capacity,
      );
      final updatedTank = Tank(
        id: tank.id,
        name: tank.name,
        materialId: tank.materialId,
        materialName: tank.materialName,
        capacity: tank.capacity,
        currentStock: tank.currentStock,
        fillLevel: normalizedFill,
        status: _statusForFillLevel(normalizedFill),
        unit: StorageUnitHelper.tonUnit,
        updatedAt: now.toIso8601String(),
        createdAt: tank.createdAt,
        department: tank.department,
        assignedUnit: tank.assignedUnit,
        type: tank.type,
        bags: tank.bags,
        maxBags: tank.maxBags,
        minStockLevel: tank.minStockLevel,
        isBhattiSourced: tank.isBhattiSourced,
      );

      final entity = TankEntity.fromDomain(updatedTank)
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;
      await _db.db.writeTxn(() async {
        await _db.tanks.put(entity);
      });

      // 2. Sync to Firebase
      await syncToFirebase(
        'update',
        updatedTank.toJson(),
        collectionName: tanksCollection,
      );
    } catch (e) {
      throw handleError(e, 'updateTank');
    }
  }

  Future<List<Tank>> getTanks() async {
    try {
      final entities = await _db.tanks
          .filter()
          .isDeletedEqualTo(false)
          .findAll();
      final tanks = entities.map((e) => e.toDomain()).toList();
      tanks.sort(Tank.compareByDisplayOrder);
      return tanks;
    } catch (e) {
      throw handleError(e, 'getTanks');
    }
  }

  Future<List<Tank>> fetchRemoteTanks({String? bhattiName}) async {
    if (_tankPermissionDenied) return [];
    try {
      final firestore = db;
      if (firestore == null) return [];

      fs.Query query = firestore.collection(tanksCollection);
      if (bhattiName != null) {
        query = query.where('assignedUnit', isEqualTo: bhattiName);
      }

      final snapshot = await query.get();
      final result = <Tank>[];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        if (data['isDeleted'] == true) continue;
        data['id'] = doc.id;
        data['unit'] = StorageUnitHelper.tonUnit;
        result.add(Tank.fromJson(data));
      }
      result.sort(Tank.compareByDisplayOrder);
      return result;
    } catch (e) {
      throw handleError(e, 'fetchRemoteTanks');
    }
  }

  Future<Tank?> getTankById(String tankId) async {
    try {
      // 1. Check Local First (Query by String ID)
      final localByQuery = await _db.tanks
          .filter()
          .idEqualTo(tankId)
          .findFirst();
      if (localByQuery != null) {
        if (localByQuery.isDeleted) return null;
        return localByQuery.toDomain();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return null;

      final docSnap = await firestore
          .collection(tanksCollection)
          .doc(tankId)
          .get();
      if (docSnap.exists) {
        final data = Map<String, dynamic>.from(docSnap.data() as Map);
        data['id'] = docSnap.id;
        if (data['isDeleted'] == true) {
          return null;
        }
        final tank = Tank.fromJson(data);

        // Cache to local for next time
        // We'd need to convert domain Tank back to Entity here to save,
        // but let's just return it for now to avoid complexity in this specific patch
        // unless we want to fully heal.
        return tank;
      }
      return null;
    } catch (e) {
      throw handleError(e, 'getTankById');
    }
  }

  Future<List<TankTransaction>> getTankTransactions(
    String tankId, {
    int limitCount = 20,
  }) async {
    try {
      // 1. Check Local First
      // Note: We need to filter by tankId and sort by timestamp desc
      final localTransactions = await _db.tankTransactions
          .filter()
          .tankIdEqualTo(tankId)
          .sortByTimestampDesc()
          .limit(limitCount)
          .findAll();

      if (localTransactions.isNotEmpty) {
        return localTransactions
            .map((e) => TankTransaction.fromJson(e.toDomainMap()))
            .toList();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(tankTransactionsCollection)
          .where('tankId', isEqualTo: tankId)
          .orderBy('timestamp', descending: true)
          .limit(limitCount)
          .get();

      final remoteTransactions = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return TankTransaction.fromJson(data);
      }).toList();

      // Optional: Cache remote trans to local?
      // For now, adhere to strict remediation: just allow reading what's there.
      // If we don't save remote ones to local, offline view will only show LOCALLY generated transactions.
      // This is acceptable behavior for "offline hardening" without full sync engine refactor.

      return remoteTransactions;
    } catch (e) {
      throw handleError(e, 'getTankTransactions');
    }
  }

  Future<List<TankLot>> getActiveLots(String tankId) async {
    try {
      final entities = await _db.tankLots
          .filter()
          .tankIdEqualTo(tankId)
          .statusEqualTo('active')
          .sortByReceivedDate()
          .findAll();
      return entities.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw handleError(e, 'getActiveLots');
    }
  }

  Future<TankLot?> getLatestLotForTank(String tankId) async {
    if (_tankPermissionDenied) return null;
    try {
      // 1. Check local cache first
      final localLots = await _db.tankLots
          .filter()
          .tankIdEqualTo(tankId)
          .findAll();
      if (localLots.isNotEmpty) {
        localLots.sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
        return localLots.first.toDomain();
      }

      // 2. Fallback to Firebase
      final firestore = db;
      if (firestore == null) return null;

      final snapshot = await firestore
          .collection(tankLotsCollection)
          .where('tankId', isEqualTo: tankId)
          .limit(100)
          .get();

      if (snapshot.docs.isEmpty) return null;
      final lots = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return TankLot.fromJson(data);
      }).toList()..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));

      return lots.first;
    } on fs.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _tankPermissionDenied = true;
        return null;
      }
      throw handleError(e, 'getLatestLotForTank');
    } catch (e) {
      throw handleError(e, 'getLatestLotForTank');
    }
  }

  // FIFO Consumption Engine
  // Note: Exposed as static/helper or instance method depending on architecture.
  // Since other services need to call this IN A TRANSACTION, we need a way to pass the transaction object.
  // Flutter/Dart Firebase SDK transactions work via a callback. We can't easily "pass" a transaction object
  // to another method unless that method accepts it.

  // Helper for internal use and external services
  Future<List<Map<String, dynamic>>> consumeLotsFromTankInTransaction(
    fs.Transaction transaction,
    String tankId,
    String materialId,
    double requiredQty,
    String operatorId,
    String operatorName,
  ) async {
    Object.hash(transaction, operatorId, operatorName);
    final activeLots = await TankLotEntityQueryFilter(_db.tankLots.filter())
        .tankIdEqualTo(tankId)
        .and()
        .materialIdEqualTo(materialId)
        .and()
        .statusEqualTo('active')
        .sortByReceivedDate()
        .findAll();

    if (activeLots.isEmpty) {
      throw Exception('No active lots found for material in tank $tankId');
    }

    double remainingToDeduct = requiredQty;
    final List<Map<String, dynamic>> consumedLots = [];

    for (final lot in activeLots) {
      if (remainingToDeduct <= 0) break;
      final currentQty = lot.quantity;

      if (currentQty <= 0) continue;

      final deductFromThisLot = (currentQty >= remainingToDeduct)
          ? remainingToDeduct
          : currentQty;
      final newLotQty = currentQty - deductFromThisLot;

      consumedLots.add({
        'lotId': lot.id,
        'supplierId': lot.supplierId,
        'supplierName': lot.supplierName,
        'quantity': deductFromThisLot,
        'remainingQuantity': newLotQty,
      });

      remainingToDeduct -= deductFromThisLot;
    }

    return consumedLots;
  }

  // ======================================
  // LOCAL STORAGE OPERATIONS (OFFLINE-FIRST)
  // ======================================

  /// Structure to hold modified entities for transactional saving
  Future<TankConsumptionResult> calculateConsumption({
    required String tankId,
    required double quantity,
    required String referenceId,
    required String operatorId,
    required String operatorName,
  }) async {
    final tank = await TankEntityQueryWhere(
      _db.tanks.where(),
    ).idEqualTo(tankId).findFirst();

    if (tank == null) throw Exception("Tank not found locally: $tankId");
    if (quantity <= 0) throw Exception("Quantity must be positive.");
    if (tank.currentStock < quantity) {
      throw Exception(
        "Insufficient stock in ${tank.name}. Available: ${tank.currentStock}",
      );
    }

    // 1. FIFO Lot Consumption
    var activeLots = await TankLotEntityQueryFilter(_db.tankLots.filter())
        .tankIdEqualTo(tankId)
        .and()
        .materialIdEqualTo(tank.materialId)
        .and()
        .statusEqualTo('active')
        .sortByReceivedDate()
        .findAll();

    if (activeLots.isEmpty) {
      // Backward compatibility:
      // Some legacy/seeded tanks (especially godowns) may have stock but no lot
      // records. Seed one synthetic lot so consumption can proceed offline.
      final seededLot = TankLotEntity()
        ..id = 'legacy_lot_${generateId()}'
        ..tankId = tankId
        ..materialId = tank.materialId
        ..materialName = tank.materialName
        ..supplierId = 'legacy_stock'
        ..supplierName = 'Legacy Stock'
        ..purchaseOrderId = 'legacy'
        ..receivedDate = DateTime.now()
        ..quantity = tank.currentStock
        ..initialQuantity = tank.currentStock
        ..status = tank.currentStock > 0 ? 'active' : 'exhausted'
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      activeLots = <TankLotEntity>[seededLot];
    }

    double remainingToDeduct = quantity;
    final List<Map<String, dynamic>> consumedLotsData = [];
    final List<TankLotEntity> modifiedLots = [];

    for (final lot in activeLots) {
      if (remainingToDeduct <= 0) break;
      final currentQty = lot.quantity;
      if (currentQty <= 0) continue;

      final deductFromThisLot = (currentQty >= remainingToDeduct)
          ? remainingToDeduct
          : currentQty;

      // Clone/Modify lot
      lot.quantity -= deductFromThisLot;
      lot.status = lot.quantity <= 0.001 ? 'exhausted' : 'active';
      lot.updatedAt = DateTime.now();
      lot.syncStatus = SyncStatus.pending;

      modifiedLots.add(lot);
      consumedLotsData.add({
        'lotId': lot.id,
        'supplierId': lot.supplierId,
        'supplierName': lot.supplierName,
        'quantity': deductFromThisLot,
      });

      remainingToDeduct -= deductFromThisLot;
    }

    if (remainingToDeduct > 0.001) {
      throw Exception(
        'Insufficient stock in available local lots. Missing: $remainingToDeduct',
      );
    }

    // 2. Update Tank
    tank.currentStock -= quantity;
    tank.fillLevel = _safeFillLevel(
      stock: tank.currentStock,
      capacity: tank.capacity,
    );
    tank.status = _statusForFillLevel(tank.fillLevel);
    tank.updatedAt = DateTime.now();
    tank.syncStatus = SyncStatus.pending;

    // 3. Create Transaction
    final transId = DateTime.now().millisecondsSinceEpoch.toString();
    final transaction = TankTransactionEntity()
      ..id = transId
      ..tankId = tankId
      ..tankName = tank.name
      ..type = 'consumption'
      ..quantity = quantity
      ..previousStock = tank.currentStock + quantity
      ..newStock = tank.currentStock
      ..materialId = tank.materialId
      ..materialName = tank.materialName
      ..referenceId = referenceId
      ..referenceType = 'production'
      ..operatorId = operatorId
      ..operatorName = operatorName
      ..timestamp = DateTime.now()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending;

    return TankConsumptionResult(
      tank: tank,
      transaction: transaction,
      lots: modifiedLots,
      summary: {
        'tankId': tankId,
        'name': tank.name,
        'materialId': tank.materialId,
        'materialName': tank.materialName,
        'lotConsumptions': consumedLotsData,
      },
    );
  }

  /// Local version of tank consumption using Isar
  Future<Map<String, dynamic>> consumeFromTankLocal({
    required String tankId,
    required double quantity,
    required String referenceId,
    required String operatorId,
    required String operatorName,
  }) async {
    try {
      final result = await calculateConsumption(
        tankId: tankId,
        quantity: quantity,
        referenceId: referenceId,
        operatorId: operatorId,
        operatorName: operatorName,
      );

      // Save atomically if NOT already in a transaction
      // NOTE: This assumes caller is NOT in a transaction.
      // If caller IS in a transaction, this call to writeTxn will fail.
      // Callers inside transactions should use calculateConsumption and save manually.
      await _db.db.writeTxn(() async {
        await _db.tanks.put(result.tank);
        await _db.tankTransactions.put(result.transaction);
        for (var lot in result.lots) {
          await _db.tankLots.put(lot);
        }
      });

      return result.summary;
    } catch (e) {
      handleError(e, 'consumeFromTankLocal');
      rethrow;
    }
  }

  // Deprecated/Internal usage replaced by calculateConsumption
  Future<List<Map<String, dynamic>>> consumeLotsFromTankLocal({
    required String tankId,
    required String materialId,
    required double requiredQty,
  }) async {
    // Legacy wrapper if needed, or remove. keeping empty or throwing generic
    throw UnimplementedError("Use calculateConsumption instead");
  }

  // Public wrapper calling internal helper logic
  Future<Map<String, dynamic>> _consumeFromTankInTransaction(
    fs.Transaction transaction,
    String tankId,
    double quantity,
    String referenceId,
    String operatorId,
    String operatorName,
  ) async {
    identityHashCode(transaction);
    final result = await calculateConsumption(
      tankId: tankId,
      quantity: quantity,
      referenceId: referenceId,
      operatorId: operatorId,
      operatorName: operatorName,
    );
    await _db.db.writeTxn(() async {
      await _db.tanks.put(result.tank);
      await _db.tankTransactions.put(result.transaction);
      if (result.lots.isNotEmpty) {
        await _db.tankLots.putAll(result.lots);
      }
    });
    await _queueTankAndLotTransactionSync(
      tank: result.tank,
      transaction: result.transaction,
      lots: result.lots,
      syncImmediately: false,
    );
    return result.summary;
  }

  // Helper designed for use by OTHER Services (like BhattiService) in THEIR transactions
  // They must pass the transaction object.
  Future<Map<String, dynamic>> consumeFromTankInTransactionHelper(
    fs.Transaction transaction,
    String tankId,
    double quantity,
    String referenceId,
    String operatorId,
    String operatorName,
  ) async {
    return _consumeFromTankInTransaction(
      transaction,
      tankId,
      quantity,
      referenceId,
      operatorId,
      operatorName,
    );
  }

  Future<bool> fillTank({
    required String tankId,
    required double quantity,
    required String referenceId,
    required String operatorId,
    required String operatorName,
    String? supplierId,
    String? supplierName,
  }) async {
    try {
      if (quantity <= 0) throw Exception("Quantity must be positive.");
      final now = DateTime.now();
      TankEntity? updatedTank;
      TankLotEntity? createdLot;
      TankTransactionEntity? createdTransaction;

      await _db.db.writeTxn(() async {
        final tank = await TankEntityQueryWhere(
          _db.tanks.where(),
        ).idEqualTo(tankId).findFirst();

        if (tank == null || tank.isDeleted) {
          throw Exception("Tank not found locally: $tankId");
        }

        final currentStock = tank.currentStock;
        final capacity = tank.capacity;
        final newStock = currentStock + quantity;

        if (newStock > capacity + 1e-9) {
          throw Exception(
            "Exceeds capacity! Capacity: $capacity, Current: $currentStock, Trying to add: $quantity",
          );
        }

        final fillLevel = _safeFillLevel(stock: newStock, capacity: capacity);
        tank
          ..currentStock = newStock
          ..fillLevel = fillLevel
          ..status = _statusForFillLevel(fillLevel)
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await _db.tanks.put(tank);

        final lot = TankLotEntity()
          ..id = 'lot_${generateId()}'
          ..tankId = tankId
          ..materialId = tank.materialId
          ..materialName = tank.materialName
          ..supplierId = supplierId ?? 'Unknown'
          ..supplierName = supplierName ?? 'Manual Fill'
          ..purchaseOrderId = referenceId
          ..receivedDate = now
          ..quantity = quantity
          ..initialQuantity = quantity
          ..status = 'active'
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;
        await _db.tankLots.put(lot);

        final transaction = TankTransactionEntity()
          ..id = 'tx_${generateId()}'
          ..tankId = tankId
          ..tankName = tank.name
          ..type = 'fill'
          ..quantity = quantity
          ..previousStock = currentStock
          ..newStock = newStock
          ..materialId = tank.materialId
          ..materialName = tank.materialName
          ..referenceId = referenceId
          ..referenceType = 'issue'
          ..operatorId = operatorId
          ..operatorName = operatorName
          ..lotId = lot.id
          ..timestamp = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;
        await _db.tankTransactions.put(transaction);

        updatedTank = tank;
        createdLot = lot;
        createdTransaction = transaction;
      });

      await _queueTankAndLotTransactionSync(
        tank: updatedTank!,
        transaction: createdTransaction!,
        lots: <TankLotEntity>[createdLot!],
      );
      return true;
    } catch (e) {
      throw handleError(e, 'fillTank');
    }
  }

  Future<bool> consumeFromTank({
    required String tankId,
    required double quantity,
    required String referenceId,
    required String operatorId,
    required String operatorName,
  }) async {
    try {
      final result = await calculateConsumption(
        tankId: tankId,
        quantity: quantity,
        referenceId: referenceId,
        operatorId: operatorId,
        operatorName: operatorName,
      );

      await _db.db.writeTxn(() async {
        await _db.tanks.put(result.tank);
        await _db.tankTransactions.put(result.transaction);
        if (result.lots.isNotEmpty) {
          await _db.tankLots.putAll(result.lots);
        }
      });

      await _queueTankAndLotTransactionSync(
        tank: result.tank,
        transaction: result.transaction,
        lots: result.lots,
      );

      // Audit log (fire and forget)
      createAuditLog(
        collectionName: tanksCollection,
        docId: tankId,
        action: 'update',
        changes: {
          'currentStock': {'oldValue': 'consumed', 'newValue': -quantity},
        },
        userId: operatorId,
      );

      return true;
    } catch (e) {
      throw handleError(e, 'consumeFromTank');
    }
  }

  Future<bool> transferToTank({
    required String sourceProductId,
    required String destinationTankId,
    required double quantity,
    required String operatorId,
    required String operatorName,
    required String unit,
    String? supplierId,
    String? supplierName,
    String? purchaseOrderId,
    String? destinationTankName,
  }) async {
    try {
      if (quantity <= 0) throw Exception("Quantity must be positive");
      final now = DateTime.now();
      TankEntity? updatedTank;
      TankLotEntity? createdLot;
      TankTransactionEntity? createdTransaction;
      Map<String, dynamic>? transferPayload;
      var inventoryAlreadyApplied = false;

      await _ensureWarehouseLocationReady();
      await _db.db.writeTxn(() async {
        final product = await _db.products.getById(sourceProductId);
        if (product == null || product.isDeleted) {
          throw Exception("Source product not found locally");
        }

        final tank = await TankEntityQueryWhere(
          _db.tanks.where(),
        ).idEqualTo(destinationTankId).findFirst();
        if (tank == null || tank.isDeleted) {
          throw Exception("Destination tank not found locally");
        }

        if (tank.materialId != sourceProductId) {
          throw Exception(
            "Material mismatch: ${tank.name} is mapped to ${tank.materialName}",
          );
        }

        final currentProductStock = (product.stock ?? 0).toDouble();
        if (currentProductStock < quantity - 1e-9) {
          throw Exception(
            "Insufficient stock in warehouse. Available: $currentProductStock",
          );
        }

        final currentTankStock = tank.currentStock;
        final newTankStock = currentTankStock + quantity;
        if (newTankStock > tank.capacity + 1e-9) {
          throw Exception(
            "Exceeds tank capacity! Capacity: ${tank.capacity}, Current: $currentTankStock, Transferring: $quantity",
          );
        }

        final transferId = 'transfer_${generateId()}';
        final inventoryCommand = InventoryCommand.internalTransfer(
          sourceLocationId: InventoryProjectionService.warehouseMainLocationId,
          destinationLocationId: _tankInventoryLocationId(destinationTankId),
          referenceId: transferId,
          productId: sourceProductId,
          quantityBase: quantity,
          actorUid: operatorId.trim().isEmpty ? 'system' : operatorId.trim(),
          reasonCode: 'tank_transfer',
          referenceType: 'tank_transfer',
          createdAt: now,
        );
        final existingCommand = await _db.inventoryCommands.get(
          fastHash(inventoryCommand.commandId),
        );
        if (existingCommand?.appliedLocally == true) {
          inventoryAlreadyApplied = true;
          return;
        }
        await _seedWarehouseBalanceInTxn(
          productId: sourceProductId,
          occurredAt: now,
        );
        await _inventoryMovementEngine.applyCommandInTxn(inventoryCommand);

        // T9-P4 REMOVED: direct local warehouse product stock mutation is
        // replaced by the InventoryMovementEngine internal_transfer above.
        // product
        //   ..stock = currentProductStock - quantity
        //   ..updatedAt = now
        //   ..syncStatus = SyncStatus.pending;
        // await _db.products.put(product);

        final fillLevel = _safeFillLevel(
          stock: newTankStock,
          capacity: tank.capacity,
        );
        tank
          ..currentStock = newTankStock
          ..fillLevel = fillLevel
          ..status = _statusForFillLevel(fillLevel)
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await _db.tanks.put(tank);

        final lot = TankLotEntity()
          ..id = 'lot_${generateId()}'
          ..tankId = destinationTankId
          ..materialId = tank.materialId
          ..materialName = tank.materialName
          ..supplierId = supplierId ?? 'Inventory'
          ..supplierName = supplierName ?? 'Warehouse Transfer'
          ..purchaseOrderId = purchaseOrderId ?? 'N/A'
          ..receivedDate = now
          ..quantity = quantity
          ..initialQuantity = quantity
          ..status = 'active'
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;
        await _db.tankLots.put(lot);

        final transaction = TankTransactionEntity()
          ..id = 'tx_${generateId()}'
          ..tankId = destinationTankId
          ..tankName = tank.name
          ..type = 'fill'
          ..quantity = quantity
          ..previousStock = currentTankStock
          ..newStock = newTankStock
          ..materialId = tank.materialId
          ..materialName = tank.materialName
          ..referenceId = transferId
          ..referenceType = 'issue'
          ..operatorId = operatorId
          ..operatorName = operatorName
          ..lotId = lot.id
          ..timestamp = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;
        await _db.tankTransactions.put(transaction);

        transferPayload = {
          'id': transferId,
          'sourceProductId': sourceProductId,
          'destinationTankId': destinationTankId,
          'destinationTankName': destinationTankName ?? tank.name,
          'quantity': quantity,
          'unit': StorageUnitHelper.tonUnit,
          'operatorId': operatorId,
          'operatorName': operatorName,
          'supplierId': supplierId,
          'supplierName': supplierName,
          'purchaseOrderId': purchaseOrderId,
          'timestamp': now.toIso8601String(),
        };

        updatedTank = tank;
        createdLot = lot;
        createdTransaction = transaction;
      });

      if (inventoryAlreadyApplied) {
        return true;
      }

      await _queueTankAndLotTransactionSync(
        tank: updatedTank!,
        transaction: createdTransaction!,
        lots: <TankLotEntity>[createdLot!],
        extraPayloads: <Map<String, dynamic>>[
          // T9-P4 REMOVED: remote product stock sync now flows through the
          // InventoryMovementEngine inventory command outbox.
          {
            'action': 'set',
            'collection': tankTransfersCollection,
            'data': transferPayload!,
          },
        ],
      );

      await createAuditLog(
        collectionName: tanksCollection,
        docId: destinationTankId,
        action: 'update',
        changes: {
          'currentStock': {'oldValue': 'transferred', 'newValue': quantity},
        },
        userId: operatorId,
      );

      return true;
    } catch (e) {
      throw handleError(e, 'transferToTank');
    }
  }

  Future<void> deleteTank(String tankId) async {
    try {
      final now = DateTime.now();
      await _db.db.writeTxn(() async {
        final local = await _db.tanks.filter().idEqualTo(tankId).findFirst();
        if (local != null) {
          local
            ..isDeleted = true
            ..syncStatus = SyncStatus.pending
            ..updatedAt = now;
          await _db.tanks.put(local);
        }
      });

      await syncToFirebase(
        'update',
        {'id': tankId, 'isDeleted': true, 'updatedAt': now.toIso8601String()},
        collectionName: tanksCollection,
        syncImmediately: false,
      );

      // Audit log
      // Note: We might want to keep the log even if tank is deleted, or delete related logs?
      // Usually keep logs.
    } catch (e) {
      throw handleError(e, 'deleteTank');
    }
  }

  Future<bool> adjustTankStock({
    required String tankId,
    required double newStock,
    required String reason,
    required String operatorId,
    required String operatorName,
  }) async {
    try {
      final now = DateTime.now();
      TankEntity? updatedTank;
      Map<String, dynamic>? adjustmentPayload;

      await _db.db.writeTxn(() async {
        final tank = await TankEntityQueryWhere(
          _db.tanks.where(),
        ).idEqualTo(tankId).findFirst();
        if (tank == null || tank.isDeleted) {
          throw Exception("Tank not found locally: $tankId");
        }

        final oldStock = tank.currentStock;
        final finalStock = newStock.clamp(0.0, tank.capacity);
        final fillLevel = _safeFillLevel(
          stock: finalStock,
          capacity: tank.capacity,
        );

        tank
          ..currentStock = finalStock
          ..fillLevel = fillLevel
          ..status = _statusForFillLevel(fillLevel)
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending;
        await _db.tanks.put(tank);

        final adjustment = TankTransactionEntity()
          ..id = 'tx_${generateId()}'
          ..tankId = tankId
          ..tankName = tank.name
          ..type = 'adjustment'
          ..quantity = finalStock - oldStock
          ..newStock = finalStock
          ..previousStock = oldStock
          ..materialId = tank.materialId
          ..materialName = tank.materialName
          ..referenceId = 'adjustment:$tankId:${now.millisecondsSinceEpoch}'
          ..referenceType = 'manual_adjustment'
          ..operatorId = operatorId
          ..operatorName = operatorName
          ..timestamp = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isDeleted = false;
        await _db.tankTransactions.put(adjustment);

        updatedTank = tank;
        adjustmentPayload = {
          ...adjustment.toFirebaseJson(),
          'reason': reason,
          'createdAt': now.toIso8601String(),
        };
      });

      await syncToFirebase(
        'update',
        updatedTank!.toDomain().toJson(),
        collectionName: tanksCollection,
        syncImmediately: false,
      );
      await syncToFirebase(
        'set',
        adjustmentPayload!,
        collectionName: tankTransactionsCollection,
        syncImmediately: false,
      );
      return true;
    } catch (e) {
      throw handleError(e, 'adjustTankStock');
    }
  }
}
