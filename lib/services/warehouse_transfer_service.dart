import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory/warehouse_transfer.dart';
import 'database_service.dart';
import 'inventory_movement_engine.dart';
import '../utils/app_logger.dart';
import '../data/local/entities/stock_balance_entity.dart';

class WarehouseTransferService {
  final FirebaseFirestore _firestore;
  final DatabaseService _dbService;
  final InventoryMovementEngine _inventoryMovementEngine;
  final Uuid _uuid = const Uuid();

  WarehouseTransferService(
    this._dbService,
    this._inventoryMovementEngine, [
    FirebaseFirestore? firestore,
  ]) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _transfersRef =>
      _firestore.collection('warehouse_transfers');

  /// Transfer stock from one warehouse to another
  Future<void> transferStock({
    required String productId,
    required String productName,
    required String fromWarehouseId,
    required String fromWarehouseName,
    required String toWarehouseId,
    required String toWarehouseName,
    required double quantity,
    required String unit,
    required String transferredBy,
    required String transferredByName,
    String? notes,
    String? batchNumber,
  }) async {
    if (quantity <= 0) {
      throw Exception('Transfer quantity must be greater than zero');
    }

    if (fromWarehouseId == toWarehouseId) {
      throw Exception('Source and destination warehouses cannot be the same');
    }

    // Check if sufficient stock exists in source warehouse
    final balanceId = '${fromWarehouseId}_$productId';
    final sourceBalance = await _dbService.stockBalances.getById(balanceId);

    if (sourceBalance == null || sourceBalance.quantity < quantity) {
      throw Exception(
        'Insufficient stock in $fromWarehouseName. Available: ${sourceBalance?.quantity ?? 0}, Required: $quantity',
      );
    }

    final transferId = _uuid.v4();
    final now = DateTime.now();

    final transfer = WarehouseTransfer(
      id: transferId,
      productId: productId,
      productName: productName,
      fromWarehouseId: fromWarehouseId,
      fromWarehouseName: fromWarehouseName,
      toWarehouseId: toWarehouseId,
      toWarehouseName: toWarehouseName,
      quantity: quantity,
      unit: unit,
      transferredBy: transferredBy,
      transferredByName: transferredByName,
      transferDate: now,
      notes: notes,
      batchNumber: batchNumber,
      createdAt: now,
    );

    // Apply inventory movement command
    final command = InventoryCommand.warehouseTransfer(
      transferId: transferId,
      fromLocationId: fromWarehouseId,
      toLocationId: toWarehouseId,
      productId: productId,
      quantity: quantity,
      actorUid: transferredBy,
      createdAt: now,
      notes: notes,
    );

    await _inventoryMovementEngine.applyCommand(command);

    // Save transfer record to Firestore
    try {
      await _transfersRef.doc(transferId).set(transfer.toJson());
      AppLogger.success(
        'Stock transferred: $quantity $unit of $productName from $fromWarehouseName to $toWarehouseName',
        tag: 'Warehouse',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to save transfer record to Firestore',
        error: e,
        tag: 'Warehouse',
      );
      // Transfer already applied locally, so we don't rollback
    }
  }

  /// Get transfer history
  Future<List<WarehouseTransfer>> getTransferHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? warehouseId,
  }) async {
    try {
      Query query = _transfersRef.orderBy('transferDate', descending: true);

      if (startDate != null) {
        query = query.where(
          'transferDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'transferDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (warehouseId != null) {
        // Get transfers where warehouse is either source or destination
        final fromQuery = await _transfersRef
            .where('fromWarehouseId', isEqualTo: warehouseId)
            .orderBy('transferDate', descending: true)
            .get();

        final toQuery = await _transfersRef
            .where('toWarehouseId', isEqualTo: warehouseId)
            .orderBy('transferDate', descending: true)
            .get();

        final allDocs = [...fromQuery.docs, ...toQuery.docs];
        final uniqueDocs = <String, QueryDocumentSnapshot>{};
        for (final doc in allDocs) {
          uniqueDocs[doc.id] = doc;
        }

        return uniqueDocs.values
            .map((doc) => WarehouseTransfer.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => WarehouseTransfer.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to fetch transfer history',
        error: e,
        tag: 'Warehouse',
      );
      return [];
    }
  }
}
