import 'offline_first_service.dart';
import '../modules/accounting/compensation_strategy.dart';
import '../modules/accounting/posting_service.dart';
import '../modules/accounting/voucher_repository.dart';
import '../models/types/purchase_order_types.dart';
import '../data/local/entities/product_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import 'package:isar/isar.dart';
import 'inventory_service.dart';
import 'vehicles_service.dart';
import 'package:intl/intl.dart';
import '../utils/app_logger.dart';

const purchaseOrdersCollection = 'purchase_orders';
const productsCollection = 'products';
const accountingCompensationLogCollection = 'accounting_compensation_log';

class PurchaseOrderService extends OfflineFirstService {
  final InventoryService _inventoryService;
  final PostingService _postingService;
  final VehiclesService? _vehiclesService;
  static const String _pendingReceiveEventPrefix = 'pending:';
  static const String _appliedReceiveEventPrefix = 'applied:';

  PurchaseOrderService(
    super.firebase,
    this._inventoryService, [
    this._vehiclesService,
  ]) : _postingService = PostingService(firebase);

  @override
  String get localStorageKey => 'local_purchase_orders';

  /// Create a new Purchase Order
  Future<String> createPurchaseOrder({
    required String supplierId,
    required String supplierName,
    required List<PurchaseOrderItem> items,
    required String createdBy,
    required String createdByName,
    String? expectedDeliveryDate,
    String? notes,
    PurchaseOrderStatus status = PurchaseOrderStatus.draft,
    required double subtotal,
    required double totalGst,
    double cgstAmount = 0,
    double sgstAmount = 0,
    double igstAmount = 0,
    required double totalAmount,
    double roundOff = 0,
    String? gstType,
    String?
    supplierInvoiceNumber, // Supplier's invoice number for duplicate prevention
    String? invoiceDate,
  }) async {
    // VALIDATION: Duplicate Invoice Prevention
    // Same supplier + same invoice number = duplicate
    if (supplierInvoiceNumber != null &&
        supplierInvoiceNumber.trim().isNotEmpty) {
      final existing = await _findDuplicateInvoice(
        supplierId,
        supplierInvoiceNumber,
      );
      if (existing != null) {
        throw Exception(
          'Duplicate invoice! Supplier invoice "$supplierInvoiceNumber" already exists as PO: ${existing['poNumber']}',
        );
      }
    }

    final poId = generateId();
    final now = getCurrentTimestamp();

    // Improved PO Number generation: PO-YYYYMMDD-XXXX
    final dateToken = DateFormat('yyyyMMdd').format(DateTime.now());
    final randToken = poId.substring(0, 4).toUpperCase();
    final poNumber = 'PO-$dateToken-$randToken';

    final po = PurchaseOrder(
      id: poId,
      poNumber: poNumber,
      supplierId: supplierId,
      supplierName: supplierName,
      status: status,
      paymentStatus: PurchaseOrderPaymentStatus.pending,
      items: items,
      subtotal: subtotal,
      totalGst: totalGst,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      totalAmount: totalAmount,
      roundOff: roundOff,
      createdAt: now,
      createdBy: createdBy,
      createdByName: createdByName,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      gstType: gstType,
      supplierInvoiceNumber: supplierInvoiceNumber,
      invoiceDate: invoiceDate,
    );

    await addToLocal(po.toJson());
    final strictMode = await _postingService.isStrictAccountingModeEnabled();
    if (strictMode) {
      try {
        await _postPurchaseVoucherAfterSuccess(
          purchaseData: po.toJson(),
          postedByUserId: createdBy,
          postedByName: createdByName,
          strictModeOverride: true,
          strictBusinessWrite: StrictBusinessWrite(
            collection: purchaseOrdersCollection,
            docId: po.id,
            data: po.toJson(),
            merge: true,
          ),
        );
      } catch (e) {
        await _compensateStrictModeCreateFailure(
          po: po,
          userId: createdBy,
          userName: createdByName,
          reason: e.toString(),
        );
        rethrow;
      }
    }

    await syncToFirebase(
      'add',
      po.toJson(),
      collectionName: purchaseOrdersCollection,
      syncImmediately: false,
    );

    if (!strictMode) {
      await _postPurchaseVoucherAfterSuccess(
        purchaseData: po.toJson(),
        postedByUserId: createdBy,
        postedByName: createdByName,
        strictModeOverride: false,
      );
    }

    return poId;
  }

  /// Helper to find duplicate invoice entries
  /// ARCHITECTURE LOCK: Same supplier + same invoice number = duplicate
  Future<Map<String, dynamic>?> _findDuplicateInvoice(
    String supplierId,
    String supplierInvoiceNumber,
  ) async {
    try {
      final allPOs = await getAllPurchaseOrders();
      for (final po in allPOs) {
        // Skip cancelled POs
        if (po.status == PurchaseOrderStatus.cancelled) continue;

        if (po.supplierId == supplierId &&
            po.supplierInvoiceNumber != null &&
            po.supplierInvoiceNumber!.trim().toLowerCase() ==
                supplierInvoiceNumber.trim().toLowerCase()) {
          return po.toJson();
        }
      }
      return null;
    } catch (e) {
      handleError(e, '_findDuplicateInvoice');
      return null; // Fail open on error
    }
  }

  /// Update an existing Purchase Order
  Future<void> updatePurchaseOrder(
    String poId,
    Map<String, dynamic> updates,
  ) async {
    final normalizedUpdates = Map<String, dynamic>.from(updates);
    normalizedUpdates.remove('id');

    // Audit check: Received POs should be read-only (except notes)
    final existingMap = await findInLocal(poId);
    if (existingMap != null) {
      final existingPo = PurchaseOrder.fromJson(existingMap);
      final status = existingPo.status;
      if (status == PurchaseOrderStatus.partiallyReceived ||
          status == PurchaseOrderStatus.received) {
        final editableKeys = <String>{
          'notes',
          'supplierInvoiceNumber',
          'invoiceDate',
          'updatedAt',
        };
        final internalReceiveKeys = <String>{
          'status',
          'items',
          'receivedAt',
          'appliedReceiveEventIds',
          'updatedAt',
        };
        final isInternalReceiveUpdate =
            normalizedUpdates.isNotEmpty &&
            normalizedUpdates.keys.every(internalReceiveKeys.contains) &&
            normalizedUpdates.containsKey('items');

        if (!isInternalReceiveUpdate) {
          normalizedUpdates.removeWhere(
            (key, value) => !editableKeys.contains(key),
          );
          if (normalizedUpdates.isEmpty) return;
        }
      }
    }

    // Add timestamp
    normalizedUpdates['updatedAt'] = getCurrentTimestamp();

    await updateInLocal(poId, normalizedUpdates);
    await syncToFirebase(
      'update',
      {'id': poId, ...normalizedUpdates},
      collectionName: purchaseOrdersCollection,
      syncImmediately: false,
    );
  }

  /// Delete a Purchase Order
  Future<void> deletePurchaseOrder(String poId) async {
    await deleteFromLocal(poId);
    await syncToFirebase(
      'delete',
      {'id': poId},
      collectionName: purchaseOrdersCollection,
      syncImmediately: false,
    );
  }

  /// Change PO Status (e.g. Draft -> Ordered)
  Future<void> updateStatus(String poId, PurchaseOrderStatus newStatus) async {
    if (newStatus == PurchaseOrderStatus.received) {
      throw Exception('Use receiveStock() for receiving goods');
    }
    await updatePurchaseOrder(poId, {'status': newStatus.value});
  }

  /// Receive Stock from a Purchase Order (GRN)
  /// This updates the PO status to 'received' or 'partially_received' AND updates inventory
  Future<void> receiveStock({
    required String poId,
    required String userId,
    required String userName,
    List<Map<String, double>>? receivedQtys, // Map of productId -> quantity
    String? receiveEventId,
  }) async {
    final poMap = await findInLocal(poId);
    if (poMap == null) throw Exception('Purchase Order not found: $poId');
    final po = PurchaseOrder.fromJson(poMap);
    final strictMode = await _postingService.isStrictAccountingModeEnabled();
    final receiveEventState = _parseReceiveEventState(
      ((poMap['appliedReceiveEventIds'] as List?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
    );
    final pendingReceiveEventIds = <String>{...receiveEventState.pendingIds};
    final appliedReceiveEventIds = <String>{...receiveEventState.appliedIds};
    final normalizedReceiveEventId = _resolveReceiveEventId(
      poId: poId,
      receivedQtys: receivedQtys,
      explicitReceiveEventId: receiveEventId,
    );
    var skipInventoryPostingForReplay = false;

    if (appliedReceiveEventIds.contains(normalizedReceiveEventId)) {
      AppLogger.info(
        'Skipped duplicate receive replay for PO $poId, eventId=$normalizedReceiveEventId',
        tag: 'Procurement',
      );
      return;
    }
    if (pendingReceiveEventIds.contains(normalizedReceiveEventId)) {
      final inventoryAlreadyPosted = await _hasInventoryPostingForReceiveEvent(
        poId: poId,
        receiveEventId: normalizedReceiveEventId,
      );
      if (inventoryAlreadyPosted) {
        skipInventoryPostingForReplay = true;
        AppLogger.warning(
          'Resuming pending receive finalize for PO $poId, eventId=$normalizedReceiveEventId',
          tag: 'Procurement',
        );
      } else {
        pendingReceiveEventIds.remove(normalizedReceiveEventId);
        await _persistReceiveEventMarkers(
          poId: poId,
          pendingReceiveEventIds: pendingReceiveEventIds,
          appliedReceiveEventIds: appliedReceiveEventIds,
        );
        AppLogger.warning(
          'Cleared stale pending receive marker for PO $poId, eventId=$normalizedReceiveEventId',
          tag: 'Procurement',
        );
      }
    }

    if (po.status == PurchaseOrderStatus.received) {
      throw Exception('Purchase Order already fully received and closed.');
    }

    // 1. Process Items (Bulk) and Calculate New PO State
    final List<Map<String, dynamic>> bulkItems = [];
    final List<PurchaseOrderItem> updatedItems = [];
    final List<Map<String, dynamic>> tyreImportDrafts = [];
    final tyreDecisionCache = <String, bool>{};
    bool allItemsFullyReceived = true;
    double receiptTaxableAmount = 0;
    double receiptCgstAmount = 0;
    double receiptSgstAmount = 0;
    double receiptIgstAmount = 0;
    double receiptTotalAmount = 0;
    final incomingQtyByProduct = <String, double>{};

    if (receivedQtys != null) {
      final poProductIds = po.items.map((e) => e.productId).toSet();
      for (final entry in receivedQtys) {
        if (entry.length != 1) {
          throw Exception(
            'Invalid received quantity payload. Each entry must contain exactly one productId and quantity.',
          );
        }

        final rawProductId = entry.keys.first;
        final productId = rawProductId.trim();
        final qtyIncoming = entry.values.first;

        if (productId.isEmpty) {
          throw Exception(
            'Invalid received quantity payload: productId is empty.',
          );
        }
        if (!poProductIds.contains(productId)) {
          throw Exception(
            'Invalid receive quantity: product "$productId" does not exist in this PO.',
          );
        }
        if (incomingQtyByProduct.containsKey(productId)) {
          throw Exception(
            'Invalid received quantity payload: duplicate product "$productId".',
          );
        }
        if (qtyIncoming.isNaN || qtyIncoming.isInfinite || qtyIncoming <= 0) {
          throw Exception(
            'Invalid receive quantity for "$productId". Quantity must be greater than zero.',
          );
        }

        incomingQtyByProduct[productId] = qtyIncoming;
      }
    }

    for (final item in po.items) {
      // Determine quantity being received NOW
      double qtyIncoming = 0.0;
      if (receivedQtys != null) {
        qtyIncoming = incomingQtyByProduct[item.productId] ?? 0.0;
      } else {
        // Default: Receive remaining quantity
        final alreadyRec = item.receivedQuantity ?? 0.0;
        qtyIncoming = (item.quantity - alreadyRec).clamp(0.0, double.infinity);
      }

      // Update Item Metadata
      final oldRec = item.receivedQuantity ?? 0.0;
      final remainingQty = (item.quantity - oldRec)
          .clamp(0.0, double.infinity)
          .toDouble();
      if (qtyIncoming > remainingQty + 0.000001) {
        throw Exception(
          'Invalid receive quantity for ${item.name}. Pending: ${remainingQty.toStringAsFixed(3)}, incoming: ${qtyIncoming.toStringAsFixed(3)}.',
        );
      }
      final newRec = oldRec + qtyIncoming;

      updatedItems.add(
        PurchaseOrderItem(
          productId: item.productId,
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          unitPrice: item.unitPrice,
          taxableAmount: item.taxableAmount,
          discount: item.discount,
          gstPercentage: item.gstPercentage,
          gstAmount: item.gstAmount,
          total: item.total,
          receivedQuantity: newRec, // Updated
          baseUnit: item.baseUnit,
          conversionFactor: item.conversionFactor,
        ),
      );

      // Check if this item is fully received
      if (newRec < item.quantity) {
        allItemsFullyReceived = false;
      }

      // Prepare Inventory Movement if qty > 0
      if (qtyIncoming > 0) {
        final double proportion = item.quantity > 0
            ? (qtyIncoming / item.quantity).clamp(0.0, 1.0)
            : 0.0;
        // Round each interim amount to avoid floating-point paise drift
        final incomingTaxable = _round2(item.taxableAmount * proportion);
        final incomingGst = _round2(item.gstAmount * proportion);

        receiptTaxableAmount += incomingTaxable;
        if ((po.gstType ?? '').toUpperCase().contains('IGST')) {
          receiptIgstAmount += incomingGst;
        } else {
          // Split CGST/SGST — round each half individually
          receiptCgstAmount += _round2(incomingGst / 2);
          receiptSgstAmount += _round2(incomingGst / 2);
        }
        receiptTotalAmount += incomingTaxable + incomingGst;

        // Convert to base unit for inventory
        double baseQty = qtyIncoming;
        if (item.baseUnit != null &&
            item.conversionFactor != null &&
            item.unit != item.baseUnit) {
          baseQty = qtyIncoming * item.conversionFactor!;
        }

        bulkItems.add({
          'productId': item.productId,
          'productName': item.name,
          'quantity': baseQty,
          'unitPrice': item.unitPrice,
        });

        if (_vehiclesService != null &&
            await _isTyrePurchaseItem(item, tyreDecisionCache)) {
          final tyreCount = _toWholeTyreCount(qtyIncoming);
          if (tyreCount > 0) {
            tyreImportDrafts.addAll(
              _buildTyreImportDrafts(
                item: item,
                incomingCount: tyreCount,
                poNumber: po.poNumber,
              ),
            );
          } else {
            AppLogger.warning(
              'Skipped tyre auto-import for ${item.name}: non-whole quantity $qtyIncoming',
              tag: 'Procurement',
            );
          }
        }
      }
    }

    if (!skipInventoryPostingForReplay) {
      pendingReceiveEventIds.add(normalizedReceiveEventId);
      await _persistReceiveEventMarkers(
        poId: poId,
        pendingReceiveEventIds: pendingReceiveEventIds,
        appliedReceiveEventIds: appliedReceiveEventIds,
      );
    }

    var inventoryPostingCompleted = skipInventoryPostingForReplay;
    try {
      // Process Inventory Updates
      if (!skipInventoryPostingForReplay && bulkItems.isNotEmpty) {
        await _inventoryService.processBulkGRN(
          items: bulkItems,
          referenceId: po.id,
          referenceNumber: _buildReceiveReferenceNumber(
            poNumber: po.poNumber,
            receiveEventId: normalizedReceiveEventId,
          ),
          userId: userId,
          userName: userName,
        );
      }
      inventoryPostingCompleted = true;

      final vehiclesService = _vehiclesService;
      if (vehiclesService != null && tyreImportDrafts.isNotEmpty) {
        try {
          final imported = await vehiclesService.importTyresFromPurchase(
            poId: po.id,
            poNumber: po.poNumber,
            tyres: tyreImportDrafts,
            supplierName: po.supplierName,
          );
          AppLogger.info(
            'Tyre auto-import completed: $imported item(s) from ${po.poNumber}',
            tag: 'Procurement',
          );
        } catch (e) {
          AppLogger.warning(
            'Tyre auto-import failed for ${po.poNumber}: $e',
            tag: 'Procurement',
          );
        }
      }

      // 2. Determine New Status
      PurchaseOrderStatus newStatus = po.status;
      if (allItemsFullyReceived) {
        newStatus = PurchaseOrderStatus.received;
      } else {
        // If at least one item received > 0, strict partial
        // If we are here, it means NOT ALL items are fully received.
        // Check if ANY item has received quantity > 0
        final hasAnyReceived = updatedItems.any(
          (i) => (i.receivedQuantity ?? 0) > 0,
        );
        if (hasAnyReceived) {
          newStatus = PurchaseOrderStatus.partiallyReceived;
        } else {
          // No items received? Keep existing (e.g. Ordered)
          newStatus = po.status;
        }
      }

      pendingReceiveEventIds.remove(normalizedReceiveEventId);
      appliedReceiveEventIds.add(normalizedReceiveEventId);
      final finalizedReceiveMarkers = _buildReceiveEventMarkers(
        pendingReceiveEventIds: pendingReceiveEventIds,
        appliedReceiveEventIds: appliedReceiveEventIds,
      );

      // 3. Update PO
      await updatePurchaseOrder(poId, {
        'status': newStatus.value,
        'items': updatedItems.map((e) => e.toJson()).toList(),
        if (newStatus == PurchaseOrderStatus.received)
          'receivedAt': getCurrentTimestamp(),
        'appliedReceiveEventIds': finalizedReceiveMarkers,
        'updatedAt': getCurrentTimestamp(),
      });

      if (receiptTotalAmount > 0) {
        final voucherPayload = {
          ...po.toJson(),
          'id': '${po.id}-grn-${DateTime.now().millisecondsSinceEpoch}',
          'sourcePoId': po.id,
          'sourcePoNumber': po.poNumber,
          'status': newStatus.value,
          'items': updatedItems.map((e) => e.toJson()).toList(),
          if (newStatus == PurchaseOrderStatus.received)
            'receivedAt': getCurrentTimestamp(),
          'subtotal': _round2(receiptTaxableAmount),
          'cgstAmount': _round2(receiptCgstAmount),
          'sgstAmount': _round2(receiptSgstAmount),
          'igstAmount': _round2(receiptIgstAmount),
          'totalAmount': _round2(receiptTotalAmount),
          'totalGst': _round2(
            receiptCgstAmount + receiptSgstAmount + receiptIgstAmount,
          ),
          'roundOff': 0.0,
          'createdAt': getCurrentTimestamp(),
          'voucherSource': 'grn',
        };

        if (strictMode) {
          try {
            await _postPurchaseVoucherAfterSuccess(
              purchaseData: voucherPayload,
              postedByUserId: userId,
              postedByName: userName,
              strictModeOverride: true,
              strictBusinessWrite: StrictBusinessWrite(
                collection: purchaseOrdersCollection,
                docId: po.id,
                data: {
                  'id': po.id,
                  'status': newStatus.value,
                  'items': updatedItems.map((e) => e.toJson()).toList(),
                  if (newStatus == PurchaseOrderStatus.received)
                    'receivedAt': getCurrentTimestamp(),
                  'appliedReceiveEventIds': finalizedReceiveMarkers,
                  'updatedAt': getCurrentTimestamp(),
                },
                merge: true,
              ),
            );
          } catch (e) {
            await _compensateStrictModeReceiveFailure(
              poBeforeReceive: po,
              appliedBulkItems: bulkItems,
              userId: userId,
              userName: userName,
              reason: e.toString(),
            );
            rethrow;
          }
        } else {
          await _postPurchaseVoucherAfterSuccess(
            purchaseData: voucherPayload,
            postedByUserId: userId,
            postedByName: userName,
            strictModeOverride: false,
          );
        }
      }
    } catch (e) {
      if (!inventoryPostingCompleted) {
        pendingReceiveEventIds.remove(normalizedReceiveEventId);
        await _persistReceiveEventMarkers(
          poId: poId,
          pendingReceiveEventIds: pendingReceiveEventIds,
          appliedReceiveEventIds: appliedReceiveEventIds,
        );
      }
      rethrow;
    }
  }

  Future<bool> _isTyrePurchaseItem(
    PurchaseOrderItem item,
    Map<String, bool> cache,
  ) async {
    final cacheKey = item.productId.isNotEmpty
        ? item.productId
        : item.name.trim().toLowerCase();
    final cached = cache[cacheKey];
    if (cached != null) return cached;

    final product = item.productId.isNotEmpty
        ? await dbService.products.getById(item.productId)
        : null;
    final searchableText = [
      item.name,
      item.unit,
      item.baseUnit ?? '',
      product?.name ?? '',
      product?.sku ?? '',
      product?.itemType ?? '',
      product?.type ?? '',
      product?.category ?? '',
      product?.subcategory ?? '',
      product?.description ?? '',
    ].join(' ').toLowerCase();

    final isTyre =
        searchableText.contains('tyre') || searchableText.contains('tire');
    cache[cacheKey] = isTyre;
    return isTyre;
  }

  int _toWholeTyreCount(double qtyIncoming) {
    if (qtyIncoming <= 0) return 0;
    final rounded = qtyIncoming.round();
    if ((qtyIncoming - rounded).abs() > 0.0001) {
      return 0;
    }
    return rounded;
  }

  List<Map<String, dynamic>> _buildTyreImportDrafts({
    required PurchaseOrderItem item,
    required int incomingCount,
    required String poNumber,
  }) {
    final drafts = <Map<String, dynamic>>[];
    final brand = _extractTyreBrand(item.name);
    final size = _extractTyreSize(item.name);
    final type = _extractTyreType(item.name);
    final poToken = poNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final tokenLength = item.productId.length > 6 ? 6 : item.productId.length;
    final productToken = item.productId.isNotEmpty
        ? item.productId.substring(0, tokenLength)
        : 'ITEM';

    for (var index = 0; index < incomingCount; index++) {
      final suffix = (index + 1).toString().padLeft(2, '0');
      drafts.add({
        'brand': brand,
        'size': size,
        'serialNumber':
            'AUTO-$poToken-$productToken-$suffix-${generateId().substring(0, 4).toUpperCase()}',
        'type': type,
        'cost': item.unitPrice,
        'purchaseDate': DateTime.now().toIso8601String(),
        'notes': 'Auto-imported from PO $poNumber for ${item.name}',
      });
    }

    return drafts;
  }

  String _extractTyreBrand(String itemName) {
    final cleaned = itemName.trim();
    if (cleaned.isEmpty) return 'Generic';
    return cleaned.split(RegExp(r'\s+')).first;
  }

  String _extractTyreSize(String itemName) {
    final normalized = itemName.toUpperCase();
    final sizePattern = RegExp(
      r'(\d{2,4}[X/\-]\d{2,4}(?:[X/\-]\d{2,4})?|R\d{2}|R\d{2}\.\d)',
    );
    final match = sizePattern.firstMatch(normalized);
    if (match == null) return 'Standard';
    return match.group(0) ?? 'Standard';
  }

  String _extractTyreType(String itemName) {
    final normalized = itemName.toLowerCase();
    if (normalized.contains('remold') || normalized.contains('retread')) {
      return 'Remold';
    }
    return 'New';
  }

  Future<void> _postPurchaseVoucherAfterSuccess({
    required Map<String, dynamic> purchaseData,
    required String postedByUserId,
    String? postedByName,
    bool? strictModeOverride,
    StrictBusinessWrite? strictBusinessWrite,
  }) async {
    final strictMode =
        strictModeOverride ??
        await _postingService.isStrictAccountingModeEnabled();
    try {
      final result = await _postingService.postPurchaseVoucher(
        purchaseData: purchaseData,
        postedByUserId: postedByUserId,
        postedByName: postedByName,
        strictModeOverride: strictMode,
        strictBusinessWrite: strictBusinessWrite,
      );
      if (!result.success) {
        final message =
            result.errorMessage ?? 'Purchase voucher posting failed';
        if (strictMode) {
          throw Exception(message);
        }
        AppLogger.warning(message, tag: 'Accounting');
      }
    } catch (e) {
      if (strictMode) {
        rethrow;
      }
      AppLogger.warning(
        'Purchase posted without voucher in Phase-1 safe mode: $e',
        tag: 'Accounting',
      );
    }
  }

  Future<void> _compensateStrictModeCreateFailure({
    required PurchaseOrder po,
    required String userId,
    required String userName,
    required String reason,
  }) async {
    final compensationId =
        'comp_po_${po.id}_${DateTime.now().microsecondsSinceEpoch}';
    await deleteFromLocal(po.id);
    await createAuditLog(
      collectionName: accountingCompensationLogCollection,
      docId: compensationId,
      action: 'create',
      changes: {
        'purchaseOrderId': po.id,
        'reason': reason,
        'status': 'compensated',
      },
      userId: userId,
      userName: userName,
    );
  }

  Future<void> _compensateStrictModeReceiveFailure({
    required PurchaseOrder poBeforeReceive,
    required List<Map<String, dynamic>> appliedBulkItems,
    required String userId,
    required String userName,
    required String reason,
  }) async {
    final compensationId =
        'comp_grn_${poBeforeReceive.id}_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();
    final rollbackPlan = CompensationStrategy.purchaseReceiveRollbackPlan(
      purchaseOrderId: poBeforeReceive.id,
      appliedBulkItems: appliedBulkItems,
    );
    try {
      await dbService.db.writeTxn(() async {
        for (final item in appliedBulkItems) {
          final productId = (item['productId'] ?? '').toString();
          final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
          if (productId.isEmpty || quantity <= 0) continue;
          await _inventoryService.applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: -quantity,
            updatedAt: now,
            markSyncPending: true,
            createLedger: true,
            transactionType: 'GRN_COMPENSATION_OUT',
            performedBy: userId,
            reason: 'Strict mode compensation',
            referenceId: poBeforeReceive.id,
            notes: 'Compensation rollback for strict accounting failure',
          );
        }
      });

      final restored = {
        ...poBeforeReceive.toJson(),
        'id': poBeforeReceive.id,
        'updatedAt': getCurrentTimestamp(),
      };
      await upsertToLocal(restored);
      await syncToFirebase(
        'update',
        restored,
        collectionName: purchaseOrdersCollection,
        syncImmediately: false,
      );

      final payload = {
        'id': compensationId,
        'module': 'purchase_orders',
        'transactionRefId': poBeforeReceive.id,
        'transactionType': 'purchase',
        'status': 'compensated',
        'reason': reason,
        'compensatedAt': getCurrentTimestamp(),
        'performedBy': userId,
        'reversedItems': appliedBulkItems,
        'operations': rollbackPlan.operations,
      };
      await createAuditLog(
        collectionName: accountingCompensationLogCollection,
        docId: compensationId,
        action: 'create',
        changes: payload,
        userId: userId,
        userName: userName,
      );
    } catch (e) {
      AppLogger.error(
        'Failed strict purchase compensation',
        error: e,
        tag: 'Accounting',
      );
      rethrow;
    }
  }

  double _round2(double value) => (value * 100).roundToDouble() / 100;

  _ReceiveEventState _parseReceiveEventState(List<String> rawMarkers) {
    final pending = <String>{};
    final applied = <String>{};
    for (final raw in rawMarkers) {
      final marker = raw.trim();
      if (marker.isEmpty) continue;
      if (marker.startsWith(_pendingReceiveEventPrefix)) {
        final id = marker.substring(_pendingReceiveEventPrefix.length).trim();
        if (id.isNotEmpty) pending.add(id);
        continue;
      }
      if (marker.startsWith(_appliedReceiveEventPrefix)) {
        final id = marker.substring(_appliedReceiveEventPrefix.length).trim();
        if (id.isNotEmpty) applied.add(id);
        continue;
      }
      // Backward compatibility with pre-state markers.
      applied.add(marker);
    }
    return _ReceiveEventState(pendingIds: pending, appliedIds: applied);
  }

  List<String> _buildReceiveEventMarkers({
    required Set<String> pendingReceiveEventIds,
    required Set<String> appliedReceiveEventIds,
  }) {
    final pending =
        pendingReceiveEventIds
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final applied =
        appliedReceiveEventIds
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .where((e) => !pending.contains(e))
            .toSet()
            .toList()
          ..sort();
    return <String>[
      ...pending.map((id) => '$_pendingReceiveEventPrefix$id'),
      ...applied.map((id) => '$_appliedReceiveEventPrefix$id'),
    ];
  }

  Future<void> _persistReceiveEventMarkers({
    required String poId,
    required Set<String> pendingReceiveEventIds,
    required Set<String> appliedReceiveEventIds,
  }) async {
    await updatePurchaseOrder(poId, {
      'appliedReceiveEventIds': _buildReceiveEventMarkers(
        pendingReceiveEventIds: pendingReceiveEventIds,
        appliedReceiveEventIds: appliedReceiveEventIds,
      ),
      'updatedAt': getCurrentTimestamp(),
    });
  }

  String _buildReceiveLedgerEventToken(String receiveEventId) {
    return 'event=$receiveEventId';
  }

  String _buildReceiveReferenceNumber({
    required String poNumber,
    required String receiveEventId,
  }) {
    return '$poNumber | ${_buildReceiveLedgerEventToken(receiveEventId)}';
  }

  Future<bool> _hasInventoryPostingForReceiveEvent({
    required String poId,
    required String receiveEventId,
  }) async {
    try {
      final eventToken = _buildReceiveLedgerEventToken(receiveEventId);
      final existingLedgers = await dbService.stockLedger
          .filter()
          .notesContains(eventToken)
          .findAll();
      return existingLedgers.isNotEmpty;
    } catch (e) {
      // Fail-safe: if detection is unavailable, prefer skip to avoid double-post.
      AppLogger.warning(
        'Receive event ledger probe failed for PO $poId, eventId=$receiveEventId: $e',
        tag: 'Procurement',
      );
      return true;
    }
  }

  String _resolveReceiveEventId({
    required String poId,
    required List<Map<String, double>>? receivedQtys,
    String? explicitReceiveEventId,
  }) {
    final explicit = explicitReceiveEventId?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    return _buildReceiveSignature(poId: poId, receivedQtys: receivedQtys);
  }

  String _buildReceiveSignature({
    required String poId,
    required List<Map<String, double>>? receivedQtys,
  }) {
    if (receivedQtys == null || receivedQtys.isEmpty) {
      return 'receive_${poId}_full_remaining';
    }
    final normalizedEntries = <String>[];
    for (final entry in receivedQtys) {
      for (final pair in entry.entries) {
        normalizedEntries.add(
          '${pair.key.trim()}:${pair.value.toStringAsFixed(6)}',
        );
      }
    }
    normalizedEntries.sort();
    return 'receive_${poId}_${normalizedEntries.join('|')}';
  }

  /// Get unique product IDs ordered from this supplier recently
  Future<List<String>> getRecentProductsForSupplier(String supplierId) async {
    try {
      final pos = await getAllPurchaseOrders();
      // Filter by supplier and sort by date desc
      final supplierPos =
          pos.where((po) => po.supplierId == supplierId).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Capture all unique product IDs from these POs
      final productIds = <String>{};
      for (final po in supplierPos.take(10)) {
        for (final item in po.items) {
          productIds.add(item.productId);
        }
      }
      return productIds.toList();
    } catch (e) {
      handleError(e, 'getRecentProductsForSupplier');
      return [];
    }
  }

  /// Get all POs
  Future<List<PurchaseOrder>> getAllPurchaseOrders() async {
    try {
      var list = await loadFromLocal();
      if (list.isEmpty) {
        list = await bootstrapFromFirebase(
          collectionName: purchaseOrdersCollection,
        );
      }
      return list.map((e) => PurchaseOrder.fromJson(e)).toList();
    } catch (e) {
      handleError(e, 'getAllPurchaseOrders');
      return [];
    }
  }
}

class _ReceiveEventState {
  final Set<String> pendingIds;
  final Set<String> appliedIds;

  const _ReceiveEventState({
    required this.pendingIds,
    required this.appliedIds,
  });
}
